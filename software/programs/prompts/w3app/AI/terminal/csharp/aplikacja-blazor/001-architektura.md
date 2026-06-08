# 001 — Architektura (Blazor Server)

## Rola
Jesteś architektem .NET. Zaprojektuj i wygeneruj **szkielet rozwiązania** dla aplikacji
**Blazor Server (.NET 8)**, która odtwarza dwa podsystemy: **„Integracje AI"** (konfiguracja
providerów LLM i wyszukiwarek) oraz **„Terminal"** (agentowy czat z wykonywaniem narzędzi).
Baza: **SQLite** (jeden plik `app.db`). To pierwszy z 16 wątków — tu powstaje fundament.

## Cel
Utwórz solution `TerminalAi.sln` z czterema projektami i działającym „pustym" hostem Blazor
(strona startowa + nawigacja do dwóch sekcji), gotowym do rozbudowy w kolejnych wątkach.

## Projekty
```
TerminalAi.sln
├─ TerminalAi.Domain        (classlib net8.0)   — modele, enumy, kontrakty (interfejsy)
├─ TerminalAi.Data          (classlib net8.0)   — EF Core DbContext, repozytoria, migracje
├─ TerminalAi.Services      (classlib net8.0)   — providerzy AI, silnik narzędzi, detektory
└─ TerminalAi.Web           (Blazor Server)     — komponenty Razor, DI, hosting
```
Zależności: `Web → Services → Data → Domain`. Domain nie zależy od niczego.

## Stack i pakiety
- `Microsoft.EntityFrameworkCore.Sqlite` (8.x) + `...Design` w `Data`.
- `Microsoft.Extensions.Http` (IHttpClientFactory) w `Services`.
- Blazor Server (interactive server render mode), Bootstrap 5 (CSS) — UI ma odwzorować
  wygląd oryginału (karty, modale, zakładki); dopuszczalny dowolny lekki zestaw CSS.
- Logowanie: `Microsoft.Extensions.Logging` (kategorie: `Ai`, `ConsoleAi`).

## Wymagania architektoniczne
1. **Warstwy bez przecieków**: komponenty Razor wołają tylko serwisy z `Services`
   (interfejsy). Serwisy wołają repozytoria z `Data`. Żadnego EF w komponentach.
2. **Async wszędzie**: każda operacja IO/sieć/baza jest `async` z `CancellationToken`.
3. **Konfiguracja DI w `Program.cs`**: `AddDbContext<AppDbContext>` (SQLite, connection string
   `Data Source=app.db`), rejestracja repozytoriów i serwisów (scoped/singleton wg sensu),
   `AddHttpClient` dla providerów.
4. **Inicjalizacja bazy przy starcie**: na starcie aplikuj migracje (`db.Database.Migrate()`)
   i seed danych (puste wiersze konfiguracji + chain wyszukiwarek + przykładowe snippety) —
   realna implementacja w wątku 002.
5. **Bezpieczeństwo**: aplikacja jednoużytkownikowa lokalna; identyfikator usera ustaw na
   stałą `"local"` (oryginał był wielouserowy — tu upraszczamy, ale **zostaw kolumny
   `UserId`/`SessionId`** w bazie, bo z nich korzysta historia i preferencje).
6. **CancellationToken**: pętla narzędzi (wątek 008) musi dać się przerwać z UI („Stop").

## Struktura folderów docelowa (orientacyjnie)
```
TerminalAi.Domain/
  Models/        (AiProviderConfig, ConsoleMessage, ToolCall, ModelProfile, ...)
  Enums/         (AiProvider, MessageRole, HelperMode, ToolName, ...)
  Contracts/     (IAiProvider, ITool, IToolLoopRunner, IModelProfile, ...)
TerminalAi.Data/
  AppDbContext.cs
  Configurations/  (Fluent API per encja)
  Repositories/    (IAiConfigRepository, IConsoleMessageRepository, ...)
  Migrations/
  DbInitializer.cs (migrate + seed)
TerminalAi.Services/
  Providers/     (ClaudeProvider, OllamaProvider, ... + AiProviderFactory)
  Tools/         (FileTools, CommandTool, WebTools, DelegationTools)
  Engine/        (ToolLoopRunner, ContextCompactor, LoopGuard, ...)
  Profiles/      (DeepSeekCoderProfile, Qwen3CoderProfile, GemmaProfile, ProfileRegistry)
  Detection/     (FakeActionDetector, HallucinationDetector, TutorModeDetector)
  Search/        (WebSearchChain + BraveClient, TavilyClient, ...)
TerminalAi.Web/
  Program.cs
  Components/
    Layout/      (MainLayout, NavMenu — dwie sekcje: „Integracje AI", „Terminal")
    Pages/       (AiSettings.razor, Terminal.razor — na razie puste placeholdery)
    Ai/          (komponenty zakładek providerów — wątki 005-007)
    Terminal/    (komponenty czatu i modali — wątki 014-015)
```

## Deliverable tego wątku
- Działające `dotnet run` z dwiema pustymi stronami: `/ai` (Integracje AI) i `/terminal`.
- Pusty `AppDbContext` z poprawnym connection stringiem i wywołaniem `Migrate()` przy starcie
  (migracje dodasz w 002 — tu wystarczy szkielet i kompilacja).
- Interfejsy-zaślepki: `IAiProvider`, `IToolLoopRunner`, `IAiConfigRepository` (puste, do wypełnienia).
- `NavMenu` z linkami do obu sekcji.

## Kryteria akceptacji
- [ ] Solution kompiluje się (`dotnet build`) bez błędów.
- [ ] `dotnet run` startuje, `/ai` i `/terminal` renderują się (placeholdery).
- [ ] Zależności projektów zgodne z `Web → Services → Data → Domain`.
- [ ] `Program.cs` rejestruje `AppDbContext` (SQLite) i woła inicjalizację bazy przy starcie.
- [ ] Plik `app.db` powstaje przy pierwszym uruchomieniu.

## Następny wątek
[002-baza-danych-sqlite.md](002-baza-danych-sqlite.md) — pełny schemat SQLite (wszystkie tabele).
