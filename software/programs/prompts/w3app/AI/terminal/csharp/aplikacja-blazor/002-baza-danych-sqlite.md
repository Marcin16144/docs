# 002 — Baza danych SQLite (EF Core)

## Rola
Inżynier danych. Zaprojektuj **schemat SQLite** (EF Core, code-first) odwzorowujący tabele
oryginału. Oryginał używał MySQL z prefiksem tenanta (`def_api_*`, `def_console_*`); tu jedna
lokalna baza `app.db`, bez prefiksów. Zachowaj **nazwy logiczne kolumn** (mapowanie 1:1), bo
korzystają z nich serwisy.

## Cel
Encje EF + `AppDbContext` + pierwsza migracja + seeder. Po tym wątku baza ma komplet tabel.

## Tabele konfiguracji providerów (single-row, klucz = 1)

Każdy provider LLM ma jeden wiersz konfiguracji. Typy SQLite: `INTEGER`, `TEXT`, `REAL`.
`DATETIME` → przechowuj jako `TEXT` ISO-8601 (EF konwertuje). `TINYINT(1)` → `INTEGER` (0/1).

**Claude** (`ApiClaude`): `Id`(PK=1), `Env`(`production`|`development`), `ProdApiKey`,
`ProdModel`(def `claude-opus-4-7`), `DevApiKey`, `DevModel`(def `claude-haiku-4-5-20251001`),
`MaxTokens`(int, def 4096), `Temperature`(real, def 1.0), `SystemPrompt`(text null),
`LastTestAt`, `LastTestEnv`, `LastTestOk`(bool), `LastTestMessage`, `LastTestTokens`(int), `UpdatedAt`.

**Ollama** (`ApiOllama`) — **multi-row** (wiele instancji w sieci!): `Id`(PK autoinc),
`Label`, `ServerUrl`(def `http://localhost:11434`), `DefaultModel`(def `llama3.2`),
`Temperature`(real .80), `NumPredict`(int, def -1), `Timeout`(int s, def 300), `SystemPrompt`,
`LastTestAt`, `LastTestOk`, `LastTestMessage`, `LastTestVersion`, `LastTestModels`(text=JSON), `UpdatedAt`.
> Dodaj kolumny `NumCtx`(int, def 16384) i `KeepAlive`(text, def `'30m'`) — używane przy
> wywołaniach Ollamy (wątek 004) by trzymać model w VRAM i nie obcinać kontekstu.

**Groq** (`ApiGroq`): `Id`(=1), `ApiKey`, `Model`(def `llama-3.3-70b-versatile`), `Temperature`(1.0),
`MaxTokens`(4096), `SystemPrompt`, `LastTestAt/Ok/Message/Tokens`, `LastTestModels`(JSON), `UpdatedAt`.

**Gemini** (`ApiGemini`): `Id`(=1), `ApiKey`, `Model`(def `gemini-2.5-flash`), `Temperature`(1.0),
`MaxTokens`(4096), `ThinkingEffort`(`none`|`low`|`medium`|`high`, def `high`), `SystemPrompt`,
`LastTestAt/Ok/Message/Tokens`, `LastTestModels`(JSON), `UpdatedAt`.

**GitHub Models** (`ApiGithubModels`): `Id`(=1), `ApiKey`(PAT), `Model`(def `openai/gpt-4o-mini`),
`Temperature`(1.0), `MaxTokens`(4096), `SystemPrompt`, `LastTestAt/Ok/Message/Tokens`, `LastTestModels`(JSON), `UpdatedAt`.

**OpenRouter** (`ApiOpenRouter`): `Id`(=1), `ApiKey`(`sk-or-v1-…`), `Model`(def `openai/gpt-4o-mini`),
`Temperature`(1.0), `MaxTokens`(4096), `SystemPrompt`, `SiteUrl`, `SiteName`,
`LastTestAt/Ok/Message/Tokens`, `LastTestModels`(JSON), `UpdatedAt`.

## Tabele wyszukiwarek (single-row, klucz = 1)
- **Brave** (`ApiBrave`): `Id`, `ApiKey`, `LastTestAt/Ok/Message`, `LastTestResults`(int), `UpdatedAt`.
- **Tavily** (`ApiTavily`): jw. (`ApiKey` `tvly-…`).
- **ScrapeGraph** (`ApiScrapeGraph`): jw. (`ApiKey` `sgai-…`).
- **SearxNG** (`ApiSearxng`): `Id`, `BaseUrl`(np. `http://localhost:8888`), `LastTestAt/Ok/Message`, `LastTestResults`, `UpdatedAt`.

## Search chain (multi-row, klucz = Provider)
**`SearchChain`**: `Provider`(PK text), `SortOrder`(int), `Active`(bool), `UpdatedAt`.
Seed (kolejność/aktywność):
```
tavily=1, scrapegraph=2, searxng_selfhosted=3, ddg_html=4, ddg_lite=5, searxng_public=6, brave=7  (wszystkie Active=1)
```

## Tabele Terminala

**`ConsoleMessage`** (historia czatu): `Id`(PK autoinc), `UserId`, `SessionId`,
`Role`(`user`|`assistant`|`system`), `Content`(text), `Provider`, `Model`,
`TokensInput`(int), `TokensOutput`(int), `Error`(text null), `ToolCalls`(text=JSON null),
`Images`(text=JSON null), `CreatedAt`. Indeks: (`UserId`,`SessionId`,`CreatedAt`).

**`ConsolePrefs`** (preferencje per user): `UserId`(PK), `Workdir`, `MainProvider`,
`MainModel`, `HelperModel`, `HelperMode`, `AutoMode`(bool), `UpdatedAt`.

**`PromptSnippet`** (wstawki promptu): `Id`(PK autoinc), `Group`(def `Ogólne`), `Label`,
`Text`, `Active`(bool=1), `SortOrder`(int), `CreatedAt`, `UpdatedAt`. Indeksy: (`Group`,`SortOrder`,`Id`), (`Active`).

**`ConsoleProgress`** (stan tury, live): klucz złożony (`UserId`,`SessionId`),
`Status`(`idle`|`running`|`done`|`error`), `Provider`, `Model`, `StartedAt`, `FinishedAt`,
`UpdatedAt`, `Json`(text — serializowany stan: faza, sub-taski, live tool-calls).

**`ConsoleHelperList`** (lista modeli pomocniczych z priorytetem): `Id`(PK autoinc), `UserId`,
`SortOrder`(int), `Provider`, `Model`, `OllId`(int=1), `Active`(bool=1), `FailCount`(int), `UpdatedAt`.
Indeks: (`UserId`,`SortOrder`,`Active`).

**`ConsoleBatchItem`** (kolejka wątków — „rozbij prompt na zadania"): `Id`(PK autoinc),
`UserId`, `SessionId`, `BatchId`(text), `SortOrder`(int), `Content`(text),
`Status`(`pending`|`running`|`done`|`failed`|`skipped`), `Response`(text null), `CreatedAt`, `UpdatedAt`.
Indeks: (`UserId`,`SessionId`,`BatchId`,`SortOrder`,`Id`).

## Wymagania
1. **Code-first** z konfiguracją Fluent API (klucze, indeksy, wartości domyślne, długości).
2. **Konwersje**: `bool`↔`INTEGER`, `DateTime`↔`TEXT` (ISO 8601 UTC). Pola `*Models`,
   `ToolCalls`, `Images`, `Json` to **TEXT z JSON-em** — trzymaj jako `string`, serializację
   robią serwisy (nie value-converter na obiekt, by mieć kontrolę).
3. **Seeder** (`DbInitializer.SeedAsync`): wstaw po jednym wierszu (Id=1) do każdej tabeli
   single-row konfiguracji (jeśli pusta), wypełnij `SearchChain` (7 wierszy), dodaj kilka
   przykładowych `PromptSnippet` (np. grupa „Kod": „Napraw błąd", „Dodaj testy"; grupa „Analiza").
4. **Migracje**: `dotnet ef migrations add Initial` + `Migrate()` na starcie (z 001).
5. **Repozytoria** (interfejsy w Domain, implementacje w Data): `IAiConfigRepository`
   (get/save per provider), `IConsoleMessageRepository`, `IPromptSnippetRepository`,
   `IConsolePrefsRepository`, `IHelperListRepository`, `IBatchRepository`, `IProgressRepository`,
   `ISearchChainRepository`.

## Kryteria akceptacji
- [ ] `dotnet ef migrations add Initial` generuje migrację ze wszystkimi tabelami.
- [ ] Po starcie `app.db` zawiera wszystkie tabele + zaseedowane wiersze (Id=1, chain, snippety).
- [ ] Repozytoria CRUD działają (prosty test: zapis i odczyt konfiguracji Claude).
- [ ] Wielowierszowa `ApiOllama` pozwala dodać >1 instancję.

## Następny wątek
[003-modele-domenowe.md](003-modele-domenowe.md) — modele domenowe, enumy, kontrakty.
