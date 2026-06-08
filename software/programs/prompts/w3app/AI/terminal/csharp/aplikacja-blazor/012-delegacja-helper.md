# 012 — Delegacja: ask_helper, decompose_and_execute, model pomocniczy

## Rola
Inżynier orkiestracji. Zaimplementuj **model pomocniczy** (tańszy/lokalny) i narzędzia delegacji:
`ask_helper` (pojedyncze podzadanie) i `decompose_and_execute` (plan wielokrokowy), z **failoverem**
po liście pomocników i trybami współpracy.

## Tryby współpracy (HelperMode — ustawiane w UI, wątek 014/015)
- **Off** — tylko model główny.
- **Auto** — router: proste wiadomości → pomocnik, złożone → główny.
- **Parallel** — główny i pomocnik odpowiadają równolegle (druga odpowiedź do porównania).
- **Delegate** — główny ma narzędzie `ask_helper` i sam deleguje drobne podzadania.
- **Split** — pomocnik zbiera/streszcza kontekst (wiedza ogólna/plan), główny finalizuje.

## Lista pomocników + failover
- `ConsoleHelperList` (z 002): wielu pomocników z priorytetem (`SortOrder`), `Active`, `FailCount`.
- `HelperRunnerWithFailover`: idzie po liście; jeśli model zwróci błąd/pusto → następny. Po sukcesie
  zeruj `FailCount`; po ≥3 kolejnych porażkach auto-deaktywuj (`Active=0`).
- Pomocnik dostaje workspace tools + `run_command` **jeśli** główna sesja je ma (by realnie wykonał
  podzadanie, nie „udawał"). Otrzymuje też `cmd_allow`.

## `ask_helper`
- Parametr: `task` (samodzielna instrukcja z PEŁNYM kontekstem — pomocnik nie widzi rozmowy).
- Wykonanie: sub-pętla narzędzi (reużyj `ToolLoopRunner`) na modelu pomocniczym; zwróć tekst odpowiedzi.

## `decompose_and_execute` (plan wielokrokowy)
- Parametry: `goal`(string), `sub_tasks`(**tablica STRINGÓW** — każdy to jedno podzadanie; połącz
  krok+szczegóły w jeden string), `verify_first`(bool), `stop_on_failure`(bool, def true).
- `verify_first=true` → najpierw uruchom wykrytą komendę build/verify projektu (krok 0); jeśli
  przechodzi (exit 0) → zwróć „nie ma czego naprawiać" bez wykonywania kroków; jeśli nie — doklej
  output do kontekstu pierwszego kroku.
- Wykonanie: dla każdego podzadania uruchom sub-pętlę pomocnika; po każdym **weryfikator** ocenia
  (osobne wywołanie): czy zadanie wymagało zapisu (`write_file`/`find_and_replace`) lub komendy
  (`run_command`) i czy realnie je wywołano → SUKCES/PORAŻKA. Werdykt na FAKTYCZNYCH tool-callach,
  nie na deklaracjach. No-op (np. „już istnieje", „nothing to change") = SUKCES (pominięto).
- `stop_on_failure` → przerwij plan na pierwszej porażce; inaczej oznacz i kontynuuj. Po porażce
  podzadania możliwa decyzja usera (kontynuować/stop) — patrz modal w 015.
- Live progress: każdy sub-task raportowany (status, retry) do UI przez `IProgress`/`ConsoleProgress.Json`.

## Anti-empty-success guard
Jeśli weryfikator dał SUKCES, ale zadanie zawiera czasowniki akcji (utwórz/napraw/zbuduj/…) a NIE
było mutującego tool-calla i to nie jest no-op → wymuś PORAŻKĘ. (Przeciw „przeczytałem plik, OK".)

## System prompt pomocnika (kluczowe reguły)
„Jesteś modelem POMOCNICZYM wykonującym JEDNO podzadanie. Wołaj narzędzia, nie narracja.
write_file jest OBOWIĄZKOWE przy tworzeniu/edycji plików; brak `.csproj`/`package.json` NIE jest
powodem odmowy zapisu — napisz plik, kompilacja to osobne podzadanie. Nie fabrykuj outputu komend."

## Kryteria akceptacji
- [ ] Pięć trybów (Off/Auto/Parallel/Delegate/Split) działa zgodnie z opisem.
- [ ] `ask_helper` deleguje i zwraca wynik; `decompose_and_execute` wykonuje plan z weryfikacją kroków.
- [ ] Failover po liście pomocników + auto-deaktywacja po 3 porażkach.
- [ ] Weryfikator opiera werdykt na realnych tool-callach; anti-empty-success i no-op działają.
- [ ] `verify_first` potrafi przerwać plan gdy build już przechodzi.

## Następny wątek
[013-profile-modeli.md](013-profile-modeli.md)
