# 010 — Narzędzie `run_command` + zgoda operatora

## Rola
Inżynier narzędzi. Zaimplementuj `run_command` — uruchamianie poleceń powłoki w folderze
roboczym, z **kontrolą zgody operatora** i mapowaniem powłoki, oraz wykrywaniem zapętleń.

## Definicja narzędzia
`run_command` — `command`(string, wymagany), `purpose`(string, krótki cel), `shell`(opcjonalny:
`auto`|`cmd`|`powershell`|`bash`). Dostępne tylko gdy operator włączył „Komendy" i workdir ustawiony.

## Wykonanie
- Uruchom w katalogu workdir, przechwyć **stdout+stderr+exit code**, z timeoutem. Zwróć wynik
  sformatowany: `$ <command>  — [SUKCES (exit 0)]` lub `[NIEPOWODZENIE (exit N)]` + output (ucięty
  do rozsądnego limitu).
- Windows: domyślnie PowerShell; mapuj typowe uniksowe komendy na PS jeśli trzeba (np. `ls`→`Get-ChildItem`,
  `cat`→`Get-Content`) — zachowaj prostą tabelę mapowań (jak `cmd_ps_map` w oryginale) lub uruchom
  przez `cmd /c` / `pwsh -c` zależnie od `shell`.
- `.NET`: `System.Diagnostics.Process` z `RedirectStandardOutput/Error`, async (`WaitForExitAsync`),
  `CancellationToken` (kill po timeoutcie/abort).

## Zgoda operatora (model zgody)
- **cmd_allow**: lista dozwolonych programów (np. `dotnet`, `git`, `npm`, `node`, `python`) —
  komendy zaczynające się od nich uruchamiają się **automatycznie**.
- Inne programy → status **PROPOSED**: nie uruchamiaj od razu; zwróć do UI propozycję komendy,
  pokaż **modal zgody** (wątek 015); po akceptacji wykonaj (opcja „pozwól w tej sesji" dodaje program do cmd_allow).
- **Komendy destrukcyjne** (`rm -rf`, `git reset --hard`, `del /s`, `format`, `Remove-Item -Recurse`…)
  zawsze wymagają jawnej zgody, nawet jeśli program jest na liście.
- Tryb AUTO (operator włączył): mniej pytań, ale destrukcyjne nadal pytają.

## Anty-halucynacja / anty-pętla
- Jeśli `run_command` NIEdostępne, a zadanie wymaga uruchomienia — narzędzie/serwis zwraca jasny
  komunikat „run_command unavailable — włącz Komendy"; model NIE może udawać outputu (detekcja w 016).
- STUCK-IN-LOOP: 3× identyczna komenda z identycznym wynikiem → przerwij z podpowiedzią (LoopGuard, 008).
- Po zapisie pliku `.cs`/`.ts`/itp. narzędzie/silnik może podpowiedzieć build (`dotnet build`,
  `npx tsc --noEmit`) jeśli w workdir jest odpowiedni marker projektu.

## Kontrakt UI (dla wątku 015)
- `ToolLoopResult`/progress niesie listę `PendingCommands` (propozycje czekające na zgodę).
- UI woła serwis „zatwierdź komendę (id, allowSession)" → komenda wykonuje się i wynik wraca do rozmowy.

## Kryteria akceptacji
- [ ] `run_command` uruchamia polecenia w workdir, zwraca stdout/stderr/exit z czytelnym statusem.
- [ ] Programy z cmd_allow startują automatycznie; inne → propozycja do zatwierdzenia.
- [ ] Komendy destrukcyjne zawsze wymagają zgody.
- [ ] Timeout i abort (`CancellationToken`) zabijają proces.
- [ ] Mapowanie/wybór powłoki działa na Windows.

## Następny wątek
[011-narzedzia-web-rag.md](011-narzedzia-web-rag.md)
