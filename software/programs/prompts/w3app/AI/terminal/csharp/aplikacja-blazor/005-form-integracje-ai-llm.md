# 005 — Formularze konfiguracji LLM (Integracje AI)

## Rola
Programista Blazor. Zbuduj sekcję **„Integracje AI"** z zakładkami konfiguracji providerów LLM.
Każda zakładka to **osobny formularz** (etap) z zapisem do bazy i testem połączenia.

## Cel
Strona `/ai` z zakładkami: **Claude, Ollama, Groq, Gemini, GitHub Models, OpenRouter**.
(Wyszukiwarki i snippety — wątki 006-007.)

## Wzorzec UI (Blazor, układ zakładek)
- `AiSettings.razor` (strona `/ai`) z nawigacją zakładek (Bootstrap `nav-tabs`), każda zakładka =
  osobny komponent `Ai/ClaudeTab.razor`, `Ai/OllamaTab.razor`, itd.
- Wspólny komponent `Ai/ProviderTestPanel.razor` (przycisk „Testuj", spinner, wynik testu,
  data ostatniego testu, status OK/błąd) reużywany w każdej zakładce.
- Zapis: `EditForm` + walidacja; po zapisie toast „Zapisano". Operacje async (serwis → repozytorium).

## Zakładka Claude
Pola: tryb `Env` (production/development — przełącznik), per-tryb `ApiKey` + `Model`
(dropdown: `claude-opus-4-7` „najmocniejszy", `claude-sonnet-4-6` „zbalansowany",
`claude-haiku-4-5-20251001` „najszybszy"), `MaxTokens`, `Temperature` (0-1), `SystemPrompt` (textarea).
Walidacja klucza: prefiks `sk-ant-`. Test: krótki prompt do `/v1/messages`, pokaż zużyte tokeny.

## Zakładka Ollama (multi-instance — najbardziej rozbudowana)
- **Lista instancji** (wiele komputerów w sieci): tabela instancji (`Label`, `ServerUrl`,
  `DefaultModel`, status) + przyciski „Dodaj instancję" / „Usuń" / edycja.
- Formularz instancji: `Label`, `ServerUrl` (walidacja `https?://host[:port]`), `DefaultModel`,
  `Temperature`, `NumPredict` (-1 = bez limitu), `Timeout` (s), `NumCtx` (def 16384),
  `KeepAlive` (def `30m`), `SystemPrompt`.
- „Odśwież modele" → `GET /api/tags`, zapisz listę do `LastTestModels`, pokaż w dropdownie.
- Test instancji: `GET /api/version` + krótki czat; pokaż wersję i liczbę modeli.

## Zakładki Groq / Gemini / GitHub Models / OpenRouter
Wspólny szablon (jeden komponent generyczny `OpenAiLikeTab.razor` parametryzowany providerem):
- `ApiKey`, `Model` (dropdown z cache `LastTestModels` lub lista domyślna), `Temperature`,
  `MaxTokens`, `SystemPrompt`, „Odśwież modele", „Testuj".
- Gemini dodatkowo: `ThinkingEffort` (none/low/medium/high).
- OpenRouter dodatkowo: `SiteUrl`, `SiteName` (nagłówki HTTP-Referer / X-Title).
- Filtruj listę modeli do **chat-capable** (odsiej whisper/TTS/embedding) — funkcja per provider.

## Logika zapisu/testu
1. „Zapisz" → walidacja → `IAiConfigRepository.SaveAsync(kind, config)`.
2. „Testuj" → `IAiProviderFactory.Get(kind).TestAsync()` → zapisz `LastTest*` → odśwież panel.
3. Dropdowny modeli zasilane z `LastTestModels` (JSON w bazie); fallback do listy domyślnej
   gdy puste (np. Groq: `llama-3.3-70b-versatile`, `llama-3.1-8b-instant`, …).

## Wymagania
- Każdy provider to osobny, samodzielny formularz (etapowo dodawalny).
- Klucze API maskowane w UI (pokaż prefiks + `••••`), pełny zapisywany do bazy.
- Brak blokowania UI (test/odświeżanie modeli w tle, spinner).
- Po teście status widoczny (zielony OK / czerwony błąd + komunikat z providera).

## Kryteria akceptacji
- [ ] `/ai` pokazuje zakładki wszystkich 6 providerów LLM.
- [ ] Zapis i odczyt konfiguracji działa dla każdego (round-trip do SQLite).
- [ ] Test połączenia zwraca i pokazuje wynik; lista modeli ląduje w dropdownie.
- [ ] Ollama obsługuje wiele instancji (dodaj/usuń/edytuj), każda z własnym `NumCtx`/`KeepAlive`.

## Następny wątek
[006-form-integracje-ai-wyszukiwarki.md](006-form-integracje-ai-wyszukiwarki.md)
