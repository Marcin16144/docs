# 012 — Delegacja: ask_helper, decompose_and_execute, model pomocniczy

## Rola
Inżynier orkiestracji. Model pomocniczy + narzędzia delegacji.

## Ważne: warstwa współdzielona
`TerminalAi.Services` (delegacja) — **identyczna jak w wersji Blazor**. Zaimplementuj **dokładnie wg**
[`../aplikacja-blazor/012-delegacja-helper.md`](../aplikacja-blazor/012-delegacja-helper.md):
- Tryby `HelperMode`: Off/Auto/Parallel/Delegate/Split.
- Lista pomocników (`ConsoleHelperList`) + failover (po porażce → następny; reset FailCount po sukcesie;
  auto-deaktywacja po ≥3 porażkach). Pomocnik dostaje workspace tools + `run_command` jeśli sesja ma.
- `ask_helper(task)` — sub-pętla na modelu pomocniczym.
- `decompose_and_execute(goal, sub_tasks[stringi], verify_first, stop_on_failure)` — plan z weryfikacją
  każdego kroku (werdykt na FAKTYCZNYCH tool-callach), `verify_first` (build krok 0), no-op=SUKCES,
  **anti-empty-success guard**, możliwość decyzji usera po porażce (modal 015).
- System prompt pomocnika (write_file obowiązkowe; brak `.csproj` NIE jest wymówką; bez fabrykowania outputu).

> UWAGA — patrz wątek 016 sekcja „klasyfikacja zadań w weryfikatorze": zadania typu **„sprawdź wersję
> X / dotnet --version"** to KOMENDA (`run_command` wymagany), NIE inspekcja plikowa. Weryfikator MUSI
> to poprawnie klasyfikować, inaczej daje sprzeczny werdykt (SUKCES + krok oznaczony jako porażka).

## Różnice/uwagi dla WinForms
- Sub-pętle pomocnika reużywają `ToolLoopRunner` (jak główny obieg); progress sub-tasków przez
  `IProgress`/`ConsoleProgress.Json` do okna podzadań (015).
- Decyzja po porażce kroku: `PlanDecisionDialog` (modal WinForms) z timeoutem (np. 120 s → domyślnie
  przerwij), zamiast pollingu HTTP jak w wersji web.

## Kryteria akceptacji
- [ ] 5 trybów działa; `ask_helper`/`decompose_and_execute` jak w wersji Blazor.
- [ ] Failover + auto-deaktywacja; weryfikator oparty na realnych tool-callach; verify_first przerywa gdy build OK.
- [ ] Klasyfikacja zadań w weryfikatorze poprawnie rozróżnia komendę vs inspekcję (patrz 016).

## Następny wątek
[013-profile-modeli.md](013-profile-modeli.md)
