# 004 — Warstwa providerów AI (klienci HTTP)

## Rola
Inżynier integracji. Zaimplementuj `IAiProvider` dla wszystkich 6 providerów + fabrykę.

## Ważne: warstwa współdzielona
`TerminalAi.Services/Providers` jest **framework-agnostyczna** — identyczna jak w wersji Blazor.
Zaimplementuj **dokładnie wg** [`../aplikacja-blazor/004-warstwa-providerow-ai.md`](../aplikacja-blazor/004-warstwa-providerow-ai.md):
- Endpointy/format: Claude (Anthropic Messages), Ollama (`/api/chat`), Groq/Gemini/GitHub/OpenRouter
  (OpenAI-compatible — wspólna klasa bazowa).
- Mapowanie wiadomości/obrazów/narzędzi, detekcja vision/tools.
- **Ollama**: `num_ctx` (z konfigu/16384) + `keep_alive` (z konfigu/`30m`); `num_predict` klamrowane;
  opcje nadpisywane przez profil (013). `num_ctx` spójny main↔helper (inaczej reload modelu).
- `TestAsync` + `ListModelsAsync` (zapis `LastTest*` do bazy); higiena `HttpClient`.

## Różnice/uwagi dla WinForms
- `IHttpClientFactory` z `Microsoft.Extensions.Http` rejestrujesz w kontenerze DI z `Program.Main`
  (`services.AddHttpClient(...)`), nie w hoście ASP.NET.
- Wszystko `async` + `CancellationToken` (przekazywany z UI przez `CancellationTokenSource`).

## Kryteria akceptacji
- [ ] Każdy provider: `ChatAsync` (z/bez narzędzi), `TestAsync`, `ListModelsAsync`.
- [ ] Ollama wysyła `num_ctx`/`keep_alive`; obrazy tylko do modeli vision.
- [ ] Fabryka buduje providera z aktualnej konfiguracji (Ollama po `OllId`).

## Następny wątek
[005-form-integracje-ai-llm.md](005-form-integracje-ai-llm.md)
