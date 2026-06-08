# 160 — Pomysły na rozszerzenia

Lista możliwych kolejnych funkcji. Każdy punkt można rozpisać jako osobny prompt
(np. 161, 162, …).

## Notatki i wiedza
- **Eksport notatek** do Markdown / PDF / HTML (per materiał lub zbiorczo);
  uwzględnij timestampy i tagi.
- **Globalne wyszukiwanie pełnotekstowe** po treści notatek (nie tylko po tagach)
  — np. SQLite FTS5 na desktopie.
- **Edycja istniejących notatek** (obecnie dodawanie/kasowanie) + sortowanie i
  filtrowanie listy.
- **Menedżer tagów**: zmiana nazwy/scalanie tagów w całej bazie.

## Nauka
- **Statystyki i streak**: dzienny postęp, wykres powtórek, liczba ukończonych
  materiałów; kafelki na Pulpicie.
- **Import/eksport fiszek**: CSV oraz pakiety Anki (.apkg); generowanie fiszek z
  zaznaczeń w notatkach.
- **SRS także dla materiałów kursu** (planowanie powtórek lekcji).
- **Napisy/transkrypcja** do wideo (np. Whisper lokalnie) + notatki z klikalną
  transkrypcją.

## AI (lokalny Ollama — patrz 120)
- **Strumieniowanie odpowiedzi** (tekst na bieżąco) zamiast pojedynczej odpowiedzi.
- **Zapis historii rozmów** + wątki tematyczne.
- Tryby: „popraw mój tekst”, „wyjaśnij gramatykę”, „ułóż ćwiczenie z tego
  materiału/notatki”.
- Generowanie fiszek ze słów, które sprawiały trudność w rozmowie.

## Platformy i dystrybucja
- **macOS / Linux**: GitHub Actions + `tauri-action` (build przy tagu).
- **Mobile**: Tauri v2 mobile lub Capacitor na froncie webowym (Android/iOS).
- **Auto-update** aplikacji desktopowej (Tauri updater).

## Jakość życia
- **Skróty klawiszowe** (nawigacja, sterowanie odtwarzaczem, dodanie notatki).
- **Kopia zapasowa / przywracanie** bazy (eksport pliku `llang.db` / IndexedDB).
- **Ręczne przestawianie kolejności** w drzewach (drag & drop), gdy auto-sort się
  pomyli.
- **Wiele bibliotek/profili** (np. różne kursy lub osoby uczące się).

## Kryteria akceptacji (ogólne)
- Każde rozszerzenie korzysta z istniejącej warstwy danych (030) i nie psuje
  trybu web (funkcje desktopowe za `isDesktop`).
