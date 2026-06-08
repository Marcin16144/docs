# 009 — Folder roboczy + narzędzia plikowe + bezpieczeństwo + weryfikacja zapisu

## Rola
Inżynier narzędzi. Narzędzia plikowe: `list_dir`, `read_file`, `write_file` (+dry-run),
`find_and_replace`, `apply_diff` + bezpieczeństwo ścieżek + weryfikacja zapisu.

## Ważne: warstwa współdzielona
`TerminalAi.Services/Tools` (część plikowa) — **identyczna jak w wersji Blazor**. Zaimplementuj
**dokładnie wg** [`../aplikacja-blazor/009-narzedzia-plikowe-workspace.md`](../aplikacja-blazor/009-narzedzia-plikowe-workspace.md):
- Definicje i parametry narzędzi; limity (read 512 KB, write 1 MB, list 500); whitelist rozszerzeń.
- Bezpieczeństwo ścieżek (kanonizacja, anty-`..`/null-byte, auto-strip bezwzględnych, case-insensitive,
  kontrola przodka/symlinków).
- Anty-błędy LLM: placeholder content, blind-overwrite block (read-before-write per tura),
  size-shrink guard, syntax check po zapisie, backup ring (N=3), style/EOL warning.

## Różnice/uwagi dla WinForms
- Folder roboczy wybierasz `FolderBrowserDialog` (okno workdir, wątek 015) lub własna przeglądarka;
  ścieżka zapisywana w `ConsolePrefs.Workdir`. Tryb dostępu (odczyt / odczyt+zapis) jako ustawienie.
- Operacje plikowe `async` (`File.ReadAllTextAsync`/`WriteAllTextAsync`), z `CancellationToken`.
- Backup ring trzymaj w `%TEMP%`/podfolderze aplikacji.

## Kryteria akceptacji
- [ ] 5 narzędzi działa w workdir; ścieżki poza rootem odrzucane; limity/whitelist egzekwowane.
- [ ] `write_file dry_run` zwraca diff; guardy (placeholder/blind-overwrite/size-shrink) działają.
- [ ] Backup ring zachowuje poprzednie wersje.

## Następny wątek
[010-narzedzie-komend.md](010-narzedzie-komend.md)
