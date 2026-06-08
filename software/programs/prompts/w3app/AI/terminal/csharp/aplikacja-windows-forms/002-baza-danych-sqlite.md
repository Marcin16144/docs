# 002 — Baza danych SQLite (Microsoft.Data.Sqlite + repozytoria)

## Rola
Inżynier danych. Zbuduj **schemat SQLite** i warstwę **repozytoriów ADO.NET** (bez ORM).
Te same tabele co w wersji Blazor — różnica wyłącznie w technice dostępu (raw SQL + `SqliteCommand`).

## Cel
`CREATE TABLE IF NOT EXISTS` dla wszystkich tabel + seed + repozytoria CRUD.

## SqliteConnectionFactory
- Connection string `Data Source={ścieżka}/app.db`. Włącz `PRAGMA foreign_keys=ON;` i `journal_mode=WAL;`.
- Krótkożyjące połączenia per operacja (using) albo jedno współdzielone — wybierz spójnie; pamiętaj
  o wątkowości (każdy `SqliteConnection` używany sekwencyjnie).

## Tabele (typy SQLite: INTEGER / TEXT / REAL; bool=INTEGER 0/1; daty=TEXT ISO-8601)

**Konfiguracja LLM (single-row, Id=1):**
- `ApiClaude`(Id, Env, ProdApiKey, ProdModel, DevApiKey, DevModel, MaxTokens, Temperature, SystemPrompt, LastTestAt, LastTestEnv, LastTestOk, LastTestMessage, LastTestTokens, UpdatedAt)
- `ApiOllama` **(multi-row, Id autoinc!)**: (Id, Label, ServerUrl, DefaultModel, Temperature, NumPredict, Timeout, NumCtx[def 16384], KeepAlive[def '30m'], SystemPrompt, LastTestAt, LastTestOk, LastTestMessage, LastTestVersion, LastTestModels[JSON], UpdatedAt)
- `ApiGroq`(Id, ApiKey, Model, Temperature, MaxTokens, SystemPrompt, LastTest…, LastTestModels, UpdatedAt)
- `ApiGemini`(… + ThinkingEffort[none/low/medium/high])
- `ApiGithubModels`(Id, ApiKey, Model, Temperature, MaxTokens, SystemPrompt, LastTest…, LastTestModels, UpdatedAt)
- `ApiOpenRouter`(… + SiteUrl, SiteName)

**Wyszukiwarki (single-row, Id=1):** `ApiBrave`(Id, ApiKey, LastTest…, LastTestResults, UpdatedAt),
`ApiTavily`(jw.), `ApiScrapeGraph`(jw.), `ApiSearxng`(Id, BaseUrl, LastTest…, LastTestResults, UpdatedAt).

**`SearchChain`** (multi-row, PK=Provider): (Provider, SortOrder, Active, UpdatedAt). Seed:
`tavily=1, scrapegraph=2, searxng_selfhosted=3, ddg_html=4, ddg_lite=5, searxng_public=6, brave=7` (Active=1).

**Terminal:**
- `ConsoleMessage`(Id autoinc, UserId, SessionId, Role[user/assistant/system], Content, Provider, Model, TokensInput, TokensOutput, Error, ToolCalls[JSON], Images[JSON], CreatedAt) — indeks (UserId,SessionId,CreatedAt).
- `ConsolePrefs`(UserId PK, Workdir, MainProvider, MainModel, HelperModel, HelperMode, AutoMode, UpdatedAt).
- `PromptSnippet`(Id autoinc, Group, Label, Text, Active, SortOrder, CreatedAt, UpdatedAt).
- `ConsoleProgress`(PK UserId+SessionId, Status[idle/running/done/error], Provider, Model, StartedAt, FinishedAt, UpdatedAt, Json).
- `ConsoleHelperList`(Id autoinc, UserId, SortOrder, Provider, Model, OllId, Active, FailCount, UpdatedAt).
- `ConsoleBatchItem`(Id autoinc, UserId, SessionId, BatchId, SortOrder, Content, Status[pending/running/done/failed/skipped], Response, CreatedAt, UpdatedAt).

## Repozytoria (interfejsy w Domain, ADO.NET w Data)
`IAiConfigRepository` (get/save per provider; dla Ollamy lista + add/remove/update instancji),
`IConsoleMessageRepository`, `IPromptSnippetRepository`, `IConsolePrefsRepository`,
`IHelperListRepository`, `IBatchRepository`, `IProgressRepository`, `ISearchChainRepository`.
- Mapowanie ręczne `SqliteDataReader` → modele; parametry przez `@p` (zero konkatenacji SQL).
- JSON-owe kolumny (`*Models`, `ToolCalls`, `Images`, `Json`) trzymaj jako `string`; (de)serializacja w serwisach.

## Seed (DbInitializer)
- Po `CREATE TABLE IF NOT EXISTS` wstaw `INSERT OR IGNORE` wiersz Id=1 do single-row konfiguracji,
  7 wierszy `SearchChain`, kilka przykładowych `PromptSnippet` (grupy „Kod"/„Analiza").

## Kryteria akceptacji
- [ ] Wszystkie tabele tworzone idempotentnie; `app.db` ma komplet po starcie.
- [ ] Repozytoria CRUD działają (round-trip: zapis/odczyt konfiguracji Claude; lista instancji Ollamy).
- [ ] Parametryzacja zapytań (brak SQL injection); JSON-owe kolumny jako string.

## Następny wątek
[003-modele-domenowe.md](003-modele-domenowe.md)
