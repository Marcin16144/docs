# 004 — Warstwa providerów AI (klienci HTTP)

## Rola
Inżynier integracji. Zaimplementuj `IAiProvider` dla wszystkich sześciu providerów LLM oraz
fabrykę `IAiProviderFactory`. To warstwa, której używa silnik narzędzi (008) i formularze testu (005).

## Cel
Jednolite wywołanie czatu (z narzędziami i bez), test połączenia i listowanie modeli dla:
**Claude, Ollama, Groq, Gemini, GitHub Models, OpenRouter**.

## Endpointy i format
| Provider | Endpoint | Auth | Format |
|----------|----------|------|--------|
| Claude | `https://api.anthropic.com/v1/messages` | nagłówek `x-api-key` + `anthropic-version: 2023-06-01` | Anthropic Messages (tools natywne) |
| Ollama | `{ServerUrl}/api/chat` | brak | Ollama chat (OpenAI-like, `tools`, `options`) |
| Groq | `https://api.groq.com/openai/v1/chat/completions` | `Authorization: Bearer` | OpenAI chat completions |
| Gemini | `https://generativelanguage.googleapis.com/v1beta/openai/chat/completions` | `Authorization: Bearer` | OpenAI-compatible |
| GitHub Models | `https://models.github.ai/inference/chat/completions` | `Authorization: Bearer {PAT}` | OpenAI-compatible |
| OpenRouter | `https://openrouter.ai/api/v1/chat/completions` | `Authorization: Bearer` (+ `HTTP-Referer`, `X-Title`) | OpenAI-compatible |

Cztery z nich (Groq/Gemini/GitHub/OpenRouter) dzielą **bazę OpenAI-completions** — wydziel
wspólną klasę `OpenAiCompatibleProvider` parametryzowaną (base URL, auth, mapowanie modeli).

## Mapowanie wiadomości
- Wewnętrzny `ChatMessage` → format providera. Anthropic: `system` osobno, role user/assistant,
  bloki `content`. OpenAI-like: tablica `messages` z `role`/`content`, `tool_calls` na assistant,
  `role:"tool"` z `tool_call_id`. Ollama: jak OpenAI, ale `tool_calls.function.arguments` to
  **obiekt** (nie string), a `role:"tool"` bez `tool_call_id`.
- Obrazy (vision): Anthropic/OpenAI — blok `image_url`/`source` base64; Ollama — pole `images`
  (base64 bez prefiksu) tylko dla modeli vision (`llava`/`bakllava`/`*vision*`).

## Narzędzia (function calling)
- Konwertuj `ToolDefinition` na format providera: Anthropic `tools:[{name,description,input_schema}]`,
  OpenAI `tools:[{type:"function",function:{name,description,parameters}}]`, Ollama analogicznie.
- **Profil modelu może wyłączyć natywne `tools`** (`SkipNativeTools=true`, wątek 013) — wtedy
  NIE wysyłaj pola `tools`; opis narzędzi wstrzykuje profil tekstowo do system promptu, a parser
  wyłuskuje wywołania z treści (text-emulation; patrz 013).

## Ollama — opcje generacji (KLUCZOWE)
W `options` ustaw: `temperature`, `top_p` (0.9), `repeat_penalty` (1.15), `num_predict`
(z konfigu; -1/-2 honoruj; >0 klamruj do [256, 16384]) oraz **`num_ctx`** (z konfigu lub 16384)
i payload-level **`keep_alive`** (z konfigu lub `"30m"`).
> Uzasadnienie: bez `num_ctx` Ollama leci na domyślnych ~4096 → ucina historię agenta i model
> re-czyta pliki w kółko. Bez `keep_alive` model wypada z VRAM po 5 min → reload 5-30 s.
> `num_ctx` MUSI być spójny między główną pętlą a wywołaniami pomocnika (inaczej reload modelu).
Profil modelu może nadpisać opcje (qwen3→num_ctx 32768, gemma→8192) — patrz 013.

## Test połączenia (`TestAsync`)
- Krótki prompt („Odpowiedz jednym słowem: ping?", max ~32 tok). Zwróć `TestResult(ok, message, tokensUsed, version?, models?)`.
- Ollama: dodatkowo `GET /api/version` (wersja) i `GET /api/tags` (lista modeli) → zapisz do
  `LastTestModels`. Pozostali: po sukcesie pobierz listę modeli (`ListModelsAsync`) i zacache'uj.
- Zapisz wynik testu do konfiguracji (`LastTestAt/Ok/Message/Tokens/Models`).

## Obsługa błędów (zachowaj komunikaty pomocne dla usera)
- Ollama HTTP 400 „looks like object" → podpowiedz: podnieś num_predict / użyj lepszego modelu /
  wyczyść historię / zaktualizuj Ollamę. HTTP 404 model → „wykonaj `ollama pull <model>`".
- 429/limit (cloud) → czytelny komunikat; silnik (008) może zrobić auto-fallback providera.
- **Higiena HTTP**: jeden `HttpClient` z `IHttpClientFactory` per provider; timeouty z konfigu
  (Ollama `Timeout`, cloud ~30-90 s); zwalniaj zasoby (using/Dispose response).

## Detekcja możliwości
- `SupportsVision`: Claude=true; Gemini=true; Groq/GitHub — po nazwie (gpt-4o, llama-4, llava…);
  OpenRouter — regex; Ollama — `vision|llava|bakllava`.
- `SupportsTools`: cloud=true; Ollama — `false` dla `llava|bakllava|codellama|llama2|llama3:[^.]`,
  inaczej `null` (spróbuj, reactive fallback).

## Fabryka
`AiProviderFactory.Get(kind, ollId)` — buduje providera z aktualną konfiguracją z repozytorium;
dla Ollamy wybiera instancję po `OllId`. Rejestracja w DI (`Program.cs`).

## Kryteria akceptacji
- [ ] Każdy provider: `ChatAsync` zwraca `ChatTurnResult` (z `ToolCalls` gdy model je wywołał).
- [ ] Test połączenia działa i zapisuje wynik + listę modeli do bazy.
- [ ] Ollama wysyła `num_ctx` i `keep_alive`; obrazy trafiają tylko do modeli vision.
- [ ] Czterej providerzy OpenAI-compatible dzielą wspólną bazę (mało duplikacji).
- [ ] Brak wycieków `HttpClient`/response; wszystko async z `CancellationToken`.

## Następny wątek
[005-form-integracje-ai-llm.md](005-form-integracje-ai-llm.md) — formularze konfiguracji LLM.
