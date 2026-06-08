# 003 — Modele domenowe, enumy, kontrakty

## Rola
Projektant domeny. Zdefiniuj **modele, enumy i interfejsy** w `TerminalAi.Domain` — wspólny
język całej aplikacji. To „osobno modele" z wymagań: warstwa czysta, bez zależności od EF/UI.

## Cel
Komplet typów, na których oprą się providerzy (004), silnik narzędzi (008) i UI (014+).

## Enumy
```csharp
enum AiProviderKind { Claude, Ollama, Groq, Gemini, GitHubModels, OpenRouter }
enum SearchProviderKind { Tavily, ScrapeGraph, SearxngSelfhosted, DdgHtml, DdgLite, SearxngPublic, Brave }
enum MessageRole { User, Assistant, System, Tool }
enum HelperMode { Off, Auto, Parallel, Delegate, Split }   // tryby modelu pomocniczego
enum WebMode { Off, Auto, Rag }                            // dostęp do internetu w turze
enum WorkdirAccess { None, ReadOnly, ReadWrite }
enum ToolName { ListDir, ReadFile, WriteFile, FindAndReplace, ApplyDiff, RunCommand,
                WebSearch, FetchUrl, SaveFile, AskHelper, DecomposeAndExecute }
enum TurnFinish { Stop, ToolUse, Error }
enum BatchItemStatus { Pending, Running, Done, Failed, Skipped }
```

## Kontrakt rozmowy i narzędzi
```csharp
// Neutralny format wiadomości (niezależny od providera)
record ChatMessage(MessageRole Role, string Content) {
    public IReadOnlyList<ToolCall>? ToolCalls { get; init; }   // dla Assistant
    public IReadOnlyList<ImageRef>? Images { get; init; }      // dla User (vision)
    public string? ToolCallId { get; init; }                   // dla Tool
    public string? Name { get; init; }                         // nazwa narzędzia (Tool)
}
record ImageRef(string Mime, string Base64);

// Definicja narzędzia (schemat dla modelu) + wywołanie + wynik
record ToolDefinition(string Name, string Description, JsonSchema Parameters);
record ToolCall(string Id, string Name, IReadOnlyDictionary<string, object?> Args) {
    public string? Result { get; set; }   // wypełniane po wykonaniu (string, prefiks "ERROR:" = błąd)
}

// Wynik jednej tury modelu
record ChatTurnResult(bool Ok, TurnFinish Finish, string Content,
                      IReadOnlyList<ToolCall> ToolCalls, Usage Usage, string? Error);
record Usage(int InputTokens, int OutputTokens);
```

## Modele konfiguracji (DTO odpowiadające encjom z 002)
- `ClaudeConfig`, `OllamaInstance` (lista), `GroqConfig`, `GeminiConfig`, `GitHubModelsConfig`,
  `OpenRouterConfig` — pola jak w 002. Dodaj wspólny widok `AiModelOption(AiProviderKind Provider,
  int OllId, string Label, string Model, bool IsDefault)` używany przez dropdown wyboru modelu.
- `SearchProviderConfig` (Brave/Tavily/Searxng/ScrapeGraph) + `SearchChainEntry(string Provider, int SortOrder, bool Active)`.
- `PromptSnippet`, `ConsolePrefs`, `HelperEntry(int Id, AiProviderKind Provider, string Model, int OllId, bool Active, int FailCount)`.

## Kontrakty serwisów (interfejsy — implementacje w późniejszych wątkach)
```csharp
interface IAiProvider {
    AiProviderKind Kind { get; }
    bool SupportsVision(string model);
    bool? SupportsTools(string model);   // null = nieznane (reactive fallback)
    Task<ChatTurnResult> ChatAsync(AiCallContext ctx, IReadOnlyList<ChatMessage> messages,
        string systemPrompt, IReadOnlyList<ToolDefinition>? tools, CancellationToken ct);
    // streaming pojedynczej tury (wątek 016); domyślnie może rzucać NotSupported
    IAsyncEnumerable<string> ChatStreamAsync(AiCallContext ctx, IReadOnlyList<ChatMessage> messages,
        string systemPrompt, CancellationToken ct);
    Task<TestResult> TestAsync(CancellationToken ct);
    Task<IReadOnlyList<string>> ListModelsAsync(CancellationToken ct);
}
record TestResult(bool Ok, string Message, int TokensUsed, string? Version, IReadOnlyList<string>? Models);

interface IAiProviderFactory { IAiProvider Get(AiProviderKind kind, int ollId = 1); }

interface IModelProfile {            // dostrojenie per rodzina modeli (wątek 013)
    string Id { get; }
    bool Matches(AiProviderKind provider, string model);
    string PromptTail();                                  // doklejka do system promptu
    bool SkipNativeTools { get; }                         // tools jako tekst zamiast API
    string ToolsTextFormat(IReadOnlyList<ToolDefinition> tools);
    IReadOnlyDictionary<string, object?> OllamaOptions(IReadOnlyDictionary<string, object?> defaults);
    string CleanContent(string text);
    int? MaxIterations { get; }
    int? MaxTurnSeconds { get; }
}
interface IModelProfileRegistry { IModelProfile Get(AiProviderKind provider, string model); }

interface ITool {                    // pojedyncze narzędzie (wątki 009-012)
    ToolName Name { get; }
    ToolDefinition Definition { get; }
    Task<string> ExecuteAsync(IReadOnlyDictionary<string, object?> args, ToolContext ctx, CancellationToken ct);
}

interface IToolLoopRunner {          // serce Terminala (wątek 008)
    Task<ToolLoopResult> RunAsync(ToolLoopRequest request, IProgress<ProgressUpdate>? progress, CancellationToken ct);
    IAsyncEnumerable<StreamEvent> RunStreamAsync(ToolLoopRequest request, CancellationToken ct); // wątek 016
}
```

## Konteksty
- `AiCallContext` — wybrany model, instancja Ollamy (OllId), efektywne opcje, profil.
- `ToolContext` — `Workdir`, `WorkdirAccess`, `SessionId`, `CommandsEnabled`, `cmdAllow` (lista
  dozwolonych programów), callback zgody na komendę, referencje do repozytoriów/serwisów wyszukiwania.
- `ToolLoopRequest` — provider+model, historia `ChatMessage`, `systemPrompt`, dostępne narzędzia,
  `ToolContext`, ustawienia helpera (`HelperMode`, lista pomocników), `WebMode`.
- `ProgressUpdate` — `Phase` (`thinking`|`parsing`|`executing`), etykieta, numer iteracji, model,
  liczba wiadomości; oraz aktualizacje sub-tasków decompose.
- `ToolLoopResult` — `Ok`, finalny `Reply`, lista wykonanych `ToolCall`, `Usage`, `Iterations`,
  flagi detekcji (`HallucinatedOutput`, `TutorMode`, `FakeAction`).

## Wymagania
1. `Domain` **nie** referencuje EF, ASP.NET ani System.Data — tylko BCL + `System.Text.Json`.
2. Wszystkie kolekcje w kontraktach jako `IReadOnlyList`/`IReadOnlyDictionary`.
3. `JsonSchema` może być prostym typem opakowującym `JsonObject`/`string` (schemat narzędzia
   serializowany do formatu OpenAI/Anthropic w warstwie providerów).

## Kryteria akceptacji
- [ ] `TerminalAi.Domain` kompiluje się bez zależności zewnętrznych (poza BCL + Text.Json).
- [ ] Wszystkie enumy, rekordy i interfejsy z tej listy istnieją i są spójne nazewniczo z 002.
- [ ] Interfejsy `IAiProvider`, `ITool`, `IToolLoopRunner`, `IModelProfile` gotowe do implementacji.

## Następny wątek
[004-warstwa-providerow-ai.md](004-warstwa-providerow-ai.md) — klienci HTTP providerów.
