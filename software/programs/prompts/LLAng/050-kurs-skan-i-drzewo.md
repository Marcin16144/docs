# 050 — Kurs: skan biblioteki + drzewo nawigacji

## Kontekst
Użytkownik ma kupiony kurs na dysku (foldery „Poziom / Rozdział” z plikami
mp4/mp3), bez nawigacji. Funkcja działa tylko w desktopie (przeglądarka nie
czyta dysku).

## Zadanie
1. **Rust** — komenda `scan_library(path) -> Vec<ScannedFile>` (rekurencyjny skan
   folderu; pola: `relPath` ze separatorami „/”, `absPath`, `name`, `ext`, `size`;
   filtruj rozszerzenia multimediów; `#[serde(rename_all="camelCase")]`).
   Dodatkowo `file_exists(path)`.
2. **Ścieżka biblioteki** ustawiana w Ustawieniach (folder-picker: plugin
   `tauri-plugin-dialog`, `open({directory:true})`); zapis w `settings`.
3. **Budowa drzewa** z płaskiej listy (`buildTree`): Poziom → Rozdział → Element.
   - Sortowanie **numeryczne**: wyłuskaj numer („Rozdział 10” po „Rozdział 2”);
     poziomy z liczb rzymskich; pliki wg prefiksu `00/01/02a/1a`.
   - Foldery bez numeru → na koniec.
   - Czyść nazwy do wyświetlenia (usuń prefiks numeracji i rozszerzenie).
4. **Ekran Kurs**: lewa kolumna = drzewo (zwijane foldery, plakietki postępu),
   prawa = panel materiału. Auto-rozwiń rozdział wznawianego materiału.
5. Hook `useLibrary`: ścieżka, skan, stany materiałów (z `item_state`),
   materiały dowiązane, wyliczenie „Kontynuuj” (ostatnio oglądany, nieukończony).

## Kryteria akceptacji
- Po wskazaniu folderu pojawia się poprawnie posortowane drzewo całego kursu.
- Element po kliknięciu otwiera się w panelu po prawej.
