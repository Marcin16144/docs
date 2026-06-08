# LLAng — prompty budowy aplikacji

Zestaw promptów do zbudowania (lub odtworzenia) aplikacji **LLAng** — lokalnej
aplikacji do nauki języka angielskiego: jeden kod uruchamiany jako desktop
(`.exe`/macOS, Tauri) oraz jako strona WWW.

## Jak używać
Każdy plik to samodzielny prompt opisujący jeden fragment systemu. Wykonuj po
kolei (rosnąco). Każdy prompt zakłada, że poprzednie zostały zrealizowane.

## Spis części
- **010** — Przegląd i cele projektu
- **020** — Stack technologiczny i inicjalizacja
- **030** — Warstwa danych (SQLite + IndexedDB, wspólny interfejs)
- **040** — Fiszki: SRS (SM-2) + wymowa (TTS)
- **050** — Kurs: skan biblioteki + drzewo nawigacji
- **060** — Kurs: odtwarzacz z resume + Picture-in-Picture
- **070** — Notatki z timestampem + tagi + wyszukiwanie
- **080** — Edytor notatek WYSIWYG (TipTap)
- **090** — Kontrola integralności plików (BLAKE3)
- **100** — Materiały: drzewo + czytnik PDF/EPUB
- **110** — Materiały: adresy URL + YouTube w aplikacji
- **120** — Rozmowa z AI po angielsku (lokalny Ollama)
- **130** — Motyw jasny / ciemny / czarny
- **140** — Layout, nawigacja, wznawianie stanu
- **150** — Build i dystrybucja (.exe, instalatory, macOS)

## Konwencje wspólne
- Frontend w `src/`, warstwa natywna w `src-tauri/`.
- TypeScript, komponenty funkcyjne React, hooki w `src/store/`.
- Funkcje desktopowe (dostęp do dysku, czytniki, AI) działają tylko w aplikacji
  desktopowej; w przeglądarce pokazują komunikat „dostępne w wersji desktop".
- Postęp/notatki kluczowane stabilnym stringiem (ścieżka względna lub `mat:<id>`).
