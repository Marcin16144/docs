# 003 — Modele domenowe, enumy, kontrakty

## Rola
Projektant domeny. Zdefiniuj warstwę `TerminalAi.Domain` (modele, enumy, interfejsy).

## Ważne: warstwa współdzielona
`TerminalAi.Domain` jest **framework-agnostyczna** — identyczna jak w wersji Blazor. Zaimplementuj
ją **dokładnie wg** [`../aplikacja-blazor/003-modele-domenowe.md`](../aplikacja-blazor/003-modele-domenowe.md):
te same enumy (`AiProviderKind`, `MessageRole`, `HelperMode`, `WebMode`, `WorkdirAccess`, `ToolName`,
`TurnFinish`, `BatchItemStatus`), rekordy (`ChatMessage`, `ToolDefinition`, `ToolCall`, `ChatTurnResult`,
`Usage`, …), modele konfiguracji i kontrakty (`IAiProvider`, `IAiProviderFactory`, `IModelProfile`,
`IModelProfileRegistry`, `ITool`, `IToolLoopRunner`, konteksty `AiCallContext`/`ToolContext`/
`ToolLoopRequest`/`ProgressUpdate`/`ToolLoopResult`).

## Różnice/uwagi dla WinForms
- `IToolLoopRunner.RunAsync(request, IProgress<ProgressUpdate>, ct)` — `IProgress<T>` utworzysz
  na wątku UI (`new Progress<T>(...)`), by raporty trafiały bezpiecznie do kontrolek (`Control.Invoke`
  nie jest wtedy potrzebny — `Progress<T>` marshaluje na SynchronizationContext UI).
- `RunStreamAsync(...): IAsyncEnumerable<StreamEvent>` — konsumpcja `await foreach` w handlerze
  formularza (async void/Task), aktualizacje kontrolki też przez kontekst UI.
- `Domain` nie zna WinForms — żadnych `using System.Windows.Forms` tutaj.

## Kryteria akceptacji
- [ ] `TerminalAi.Domain` kompiluje się bez zależności poza BCL + `System.Text.Json`.
- [ ] Komplet typów zgodny z wersją Blazor (te same nazwy — warstwa współdzielona).

## Następny wątek
[004-warstwa-providerow-ai.md](004-warstwa-providerow-ai.md)
