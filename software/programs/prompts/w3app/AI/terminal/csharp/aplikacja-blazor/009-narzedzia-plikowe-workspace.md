# 009 — Folder roboczy + narzędzia plikowe + bezpieczeństwo + weryfikacja zapisu

## Rola
Inżynier narzędzi. Zaimplementuj narzędzia operujące na **folderze roboczym** (workdir):
`list_dir`, `read_file`, `write_file` (+dry-run), `find_and_replace`, `apply_diff`, wraz z
twardym **bezpieczeństwem ścieżek** i **weryfikacją zapisu**.

## Folder roboczy
- User wybiera katalog na dysku + tryb dostępu: **odczyt** lub **odczyt+zapis** (zapisz w `ConsolePrefs.Workdir`).
- Narzędzia plikowe są dostępne tylko gdy workdir ustawiony; `write_file`/`find_and_replace`/
  `apply_diff` tylko w trybie zapis. Wszystkie ścieżki **względne** do roota workdir.

## Definicje narzędzi (schematy dla modelu)
- **`list_dir`** — `path`(string, opcjonalny; "" lub "." = root). Listuje JEDEN poziom (nie
  rekurencyjnie), max **500** wpisów (przekroczenie → zaznacz że ucięto). Zwraca pliki+podfoldery.
- **`read_file`** — `path`(string, wymagany). Zwraca treść tekstową, do **512 KB** (większe ucinane),
  binarne odrzucane (null-byte). Notuje, że plik odczytano (na potrzeby read-before-write).
- **`write_file`** — `path`(wymagany), `content`(wymagany, PEŁNA nowa treść), `dry_run`(bool, opc).
  Nadpisuje cały plik; tworzy brakujące podfoldery; max **1 MB**. `dry_run=true` → zwróć unified
  diff bez zapisu.
- **`find_and_replace`** — `path`, `find`, `replace`, `count_expected`(int, def 1). Zamiana
  dokładnego fragmentu; jeśli liczba trafień ≠ oczekiwanej → błąd (bezpieczna edycja punktowa).
- **`apply_diff`** — `path`, `diff` (unified diff). Aplikuje patch do pliku.

## Bezpieczeństwo ścieżek (twarde)
- Kanonizuj root (`Path.GetFullPath`), normalizuj separatory. Odrzuć `..` i null-byte.
- **Auto-strip** ścieżek bezwzględnych: jeśli model poda `C:\workdir\sub\f.cs` a to jest wewnątrz
  roota — zamień na względną; jeśli poza rootem — błąd „outside working folder".
- Porównania **case-insensitive** (Windows). Sprawdzaj, że rozwiązana ścieżka (i jej istniejący
  przodek — łapie symlinki) mieści się w root.
- Whitelist rozszerzeń zapisu (kod/tekst/dokumentacja): php, cs, csproj, js, ts, json, xml, yaml,
  md, txt, sql, sh, ps1, html, css, py, go, rs, java, … + nazwy bez rozszerzenia: Dockerfile,
  Makefile, .gitignore, .env, .editorconfig. Inne → błąd.

## Anty-błędy LLM przy zapisie (zachowaj!)
1. **Placeholder content** — odrzuć gdy treść to `[ZAWARTOŚĆ_PLIKU]`/`{FILE_CONTENT}` lub
   komentarze typu `// Your existing code`, `// ... existing code ...`, `// rest of file unchanged`,
   `// TODO fill in`, puste ciało `{ }`, `throw new NotImplementedException()` (chyba że user
   wprost prosi o stub). Komunikat: „podaj PEŁNĄ realną treść; jeśli edytujesz część — read_file → merge → write_file".
2. **Blind overwrite block** — nie pozwól nadpisać **istniejącego** pliku, którego model NIE
   odczytał (`read_file`) w tej turze. (Nowy plik OK.)
3. **Size-shrink guard** — gdy istniejący >500 B, a nowy <50% rozmiaru → odrzuć (prawdopodobnie
   model napisał tylko fragment). User może świadomie nadpisać pełną krótszą treścią.
4. **Syntax check po zapisie** (best-effort): .json (parse), .xml/.html (parser), .cs/.ts/.php —
   opcjonalnie zewnętrzny walidator (pomiń jeśli niedostępny). Błąd składni → odrzuć zapis.
5. **Backup ring**: przed nadpisaniem zachowaj N=3 ostatnie wersje (np. w temp), do ewentualnego revertu.
6. **Style/EOL warning** (nie blokuje): ostrzeż gdy zmienia się tab↔spacje lub LF↔CRLF.

## Read-before-write (kontekst tury)
Trzymaj per-turę listę odczytanych ścieżek (reset na początku tury w 008). `write_file` na
istniejącym pliku sprawdza tę listę. To samo dla `find_and_replace`/`apply_diff`.

## Kryteria akceptacji
- [ ] Wszystkie 5 narzędzi działa w obrębie workdir; ścieżki poza rootem odrzucane.
- [ ] `write_file` z `dry_run` zwraca diff bez zapisu; bez — zapisuje pełną treść.
- [ ] Placeholder/blind-overwrite/size-shrink guardy odrzucają złe zapisy z czytelnym komunikatem.
- [ ] Limity (512 KB read, 1 MB write, 500 list) i whitelist rozszerzeń egzekwowane.
- [ ] Backup ring zachowuje poprzednie wersje.

## Następny wątek
[010-narzedzie-komend.md](010-narzedzie-komend.md)
