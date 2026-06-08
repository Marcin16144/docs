# 008 — Silnik pętli narzędzi (ToolLoopRunner)

## Rola
Inżynier rdzenia. Zaimplementuj `IToolLoopRunner` — **wieloturową pętlę agentową**: model
generuje odpowiedź lub wywołania narzędzi, system je wykonuje i oddaje wyniki modelowi, aż do
finalnej odpowiedzi tekstowej. To serce Terminala.

## Cel
`ToolLoopRunner.RunAsync(request, progress, ct)` zwracający `ToolLoopResult`.

## Algorytm (jedna tura = jedno wywołanie modelu)
```
iter = 0; messages = request.History; ct sprawdzany na początku każdej iteracji
pętla while (iter < maxIter && !ct):
  1. KOMPAKCJA kontekstu (ContextCompactor) — patrz niżej.
  2. progress: faza "thinking" (iter, model, liczba wiadomości).
  3. wynik = provider.ChatAsync(messages, systemPrompt, tools, ct).
  4. profil.CleanContent(wynik.Content)  (wątek 013).
  5. jeśli błąd tool-callingu → graceful fallback (patrz niżej), retry raz.
  6. progress: faza "parsing".
  7. jeśli wynik.ToolCalls puste → to finalna odpowiedź: zwróć ToolLoopResult(Ok, reply=Content...).
  8. dopisz assistant-message z tool_calls do messages.
  9. dla każdego tool call: progress "executing" → wykonaj (ToolExecutor) → dopisz tool-message.
 10. zastosuj LoopGuard (anty-pętla) — może wstrzyknąć nudge lub przerwać.
 11. iter++.
po pętli: timeout/limit iteracji → zwróć wynik z komunikatem.
```

## Limity i czasy (jak w oryginale)
- `maxIter`: gdy dostępne `run_command` → **16**, inaczej **8**. Profil modelu może podnieść
  (qwen3≈24). „Productive-iter extension": jeśli w ostatnich iteracjach były mutacje i liczba
  błędów maleje — dorzuć +4 iteracje (raz).
- `maxTurnSeconds`: domyślnie **1200 s** (profil może nadpisać). Po przekroczeniu — przerwij
  z komunikatem „Przekroczono limit czasu tury — użyj szybszego modelu".
- **Abort**: `CancellationToken` z UI (przycisk „Stop") przerywa pętlę natychmiast.

## Kompakcja kontekstu (ContextCompactor — osobna klasa)
Gdy historia zbliża się do okna modelu, **eliduj najstarsze duże wyniki narzędzi** (zrzuty
`read_file`, długie outputy komend), zostawiając N=4 najnowsze w całości; starsze zamień na
stub „[⋯ wynik `tool` (N zn.) pominięty — wywołaj ponownie jeśli potrzebny]". Nigdy nie ruszaj
system promptu ani ostatniej wiadomości. Budżet: dla Ollamy ≈ `num_ctx - 8000` (qwen3-coder
32768, reszta 16384); dla chmury ≈ 120000. Szacowanie ≈ 3.5 znaku/token.

## Graceful fallback (błąd tool-callingu)
Jeśli model nie wspiera narzędzi lub zwrócił malformed tool-call (komunikaty typu
`does not support tools`, `tool_use_failed`, `failed_generation`, `tool call validation failed`):
zrzuć `tools=null`, wykonaj **auto-RAG** (wątek 011) i ponów turę bez narzędzi. Tylko raz na rozmowę.
Auto-switch providera po 429/quota — opcjonalnie, raz.

## Wykonanie narzędzi (ToolExecutor)
- Sanityzacja argumentów (strip ```` ``` ```` fence'ów, normalizacja ścieżek), walidacja względem
  schematu (brak wymaganych param → błąd przed wykonaniem), wykonanie `ITool.ExecuteAsync`,
  prosty self-heal retry (1×), wzbogacenie błędu o schemat narzędzia, klastrowanie powtarzających
  się błędów → meta-podpowiedź po 3 takich samych.
- **Read-cache**: nie czytaj 2× tego samego pliku w jednej turze (zwróć z cache).

## LoopGuard (anty-pętla — osobna klasa)
Liczniki w obrębie tury: powtarzalne `run_command` (fingerprint — 3× identyczny wynik = STUCK),
„jałowe odczyty" (not-found/re-read; nudge przy 4, stop przy 8), kolejne iteracje wyłącznie
read-only (nudge 6/9, stop 14). Nudge = dopisanie podpowiedzi do ostatniej tool-message.

## Wynik i detekcja (po zakończeniu)
Zwróć `ToolLoopResult` z `Reply`, `ToolCalls`, `Usage`, `Iterations` oraz flagami:
`HallucinatedOutput`, `TutorMode`, `FakeAction` (detektory — wątek 016, wywołane na finalnej odpowiedzi).

## Postęp (IProgress)
Emituj `ProgressUpdate` z fazą (`thinking`/`parsing`/`executing`), numerem iteracji, modelem
i — w trybie decompose — stanem sub-tasków. UI (014) renderuje to jako wskaźnik „pisze…".
W Blazor: aktualizuj stan komponentu przez `InvokeAsync(StateHasChanged)`.

## Kryteria akceptacji
- [ ] Pętla wykonuje cykl model→tool→model i kończy się finalną odpowiedzią.
- [ ] Limity iteracji/czasu i abort (`CancellationToken`) działają.
- [ ] Kompakcja elidująca stare wyniki narzędzi działa przy długiej historii.
- [ ] Graceful fallback i LoopGuard zapobiegają zawieszeniu/pętlom.
- [ ] `IProgress` raportuje fazy; UI może je pokazać.

## Następny wątek
[009-narzedzia-plikowe-workspace.md](009-narzedzia-plikowe-workspace.md)
