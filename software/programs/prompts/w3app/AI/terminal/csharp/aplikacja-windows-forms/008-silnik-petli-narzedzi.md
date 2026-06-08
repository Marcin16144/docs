# 008 — Silnik pętli narzędzi (ToolLoopRunner)

## Rola
Inżynier rdzenia. Zaimplementuj `IToolLoopRunner` — wieloturową pętlę agentową.

## Ważne: warstwa współdzielona
`TerminalAi.Services/Engine` jest **framework-agnostyczna** — identyczna jak w wersji Blazor.
Zaimplementuj **dokładnie wg** [`../aplikacja-blazor/008-silnik-petli-narzedzi.md`](../aplikacja-blazor/008-silnik-petli-narzedzi.md):
- Algorytm pętli (model→tool→model), limity iteracji (16 z `run_command`, inaczej 8; profil podnosi;
  productive-iter +4), `maxTurnSeconds` (1200), abort przez `CancellationToken`.
- `ContextCompactor` (elizja starych dużych wyników narzędzi; budżet zależny od `num_ctx`).
- Graceful fallback (drop tools + auto-RAG po błędzie tool-callingu, raz).
- `ToolExecutor` (sanityzacja args, walidacja schematu, self-heal retry, read-cache, meta-hinty).
- `LoopGuard` (STUCK run_command, jałowe odczyty, read-only streak → nudge/stop).
- Detektory na finalnej odpowiedzi (016): `FakeAction`/`Hallucinated`/`Tutor`.

## Różnice/uwagi dla WinForms
- **Postęp**: `IProgress<ProgressUpdate>` utwórz na wątku UI (`new Progress<>(...)`); raporty trafią
  bezpiecznie do kontrolek bez `Control.Invoke`. NIE aktualizuj kontrolek bezpośrednio z wnętrza pętli.
- **Abort**: `CancellationTokenSource` trzymany w formularzu czatu; przycisk „Stop" → `Cancel()`.
- **Brak ASP.NET**: serwis silnika to zwykła klasa z DI (rejestracja w `Program.Main`).

## Kryteria akceptacji
- [ ] Cykl model→tool→model kończy się finalną odpowiedzią; limity i abort działają.
- [ ] Kompakcja, graceful fallback, LoopGuard działają jak w wersji Blazor.
- [ ] `IProgress` raportuje fazy na wątek UI (bez zamrażania okna).

## Następny wątek
[009-narzedzia-plikowe-workspace.md](009-narzedzia-plikowe-workspace.md)
