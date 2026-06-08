# 010 — Narzędzie `run_command` + zgoda operatora (Windows Forms)

## Rola
Inżynier narzędzi. `run_command` — uruchamianie poleceń w workdir, z kontrolą zgody i wykrywaniem zapętleń.

## Ważne: logika współdzielona
Zasady wykonania, mapowania powłoki, modelu zgody (cmd_allow, PROPOSED, komendy destrukcyjne,
tryb AUTO), anty-halucynacji i STUCK-IN-LOOP — **wg** [`../aplikacja-blazor/010-narzedzie-komend.md`](../aplikacja-blazor/010-narzedzie-komend.md).
Parametry narzędzia: `command`, `purpose`, `shell` (auto/cmd/powershell/bash).

## Różnice/uwagi dla WinForms
- Uruchamianie: `System.Diagnostics.Process` z `RedirectStandardOutput/Error`,
  `ProcessStartInfo { WorkingDirectory = workdir, UseShellExecute = false, CreateNoWindow = true }`.
  Windows: PowerShell (`powershell.exe -NonInteractive -Command`) lub `cmd /c` zależnie od `shell`.
- Async: `process.WaitForExitAsync(ct)`; przy abort/timeout `process.Kill(entireProcessTree:true)`.
- **Zgoda operatora**: gdy komenda jest PROPOSED → silnik zwraca propozycję; formularz czatu pokazuje
  **okno zgody** (`CommandApprovalDialog`, wątek 015) — „Uruchom" / „Uruchom i pozwól w sesji" /
  „Odrzuć"; komendy destrukcyjne wyróżnione. Po decyzji serwis wykonuje i wynik wraca do rozmowy.
- Czytaj stdout/stderr asynchronicznie (unik deadlocka na pełnym buforze).

## Kryteria akceptacji
- [ ] `run_command` w workdir zwraca stdout/stderr/exit z czytelnym statusem.
- [ ] cmd_allow auto-uruchamia; inne → okno zgody; destrukcyjne zawsze pytają.
- [ ] Timeout/abort zabija proces (z drzewem procesów potomnych).

## Następny wątek
[011-narzedzia-web-rag.md](011-narzedzia-web-rag.md)
