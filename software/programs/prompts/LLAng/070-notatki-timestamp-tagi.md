# 070 — Notatki z timestampem + tagi + wyszukiwanie

## Cel
Notatki powiązane z momentem nagrania, z tagami i wyszukiwaniem tematów.
Wspólny mechanizm dla Kursu i Materiałów.

## Zadanie
1. Model `TimedNote { id, itemKey, time, text(HTML), tags[], created }`. Tabela
   `notes` (tagi jako JSON w SQLite; w Dexie indeks `*tags`).
2. Hook `useNotes`: ładuje wszystkie notatki, grupuje po `itemKey`
   (`notesByItem`), liczy unikalne `allTags`, udostępnia `addNote/removeNote`.
3. Komponent `TimedNotesPanel` (reużywalny):
   - props: `itemKey`, `notes`, `allTags`, `onAddNote`, `onRemoveNote`,
     opcjonalnie `getTime()` i `onSeek(t)` (gdy materiał odtwarzany);
   - formularz dodawania: edytor treści (patrz 080) + pole tagów;
   - przy mediach przycisk „➕ Dodaj notatkę w bieżącym miejscu” zapisuje
     `time = floor(getTime())`;
   - lista notatek: każda z przyciskiem **▶ mm:ss** (skok `onSeek(time)`),
     treścią (render HTML) i tagami; kasowanie.
4. **Pole tagów** (`TagInput`): chipsy + autouzupełnianie z już użytych tagów
   (`<datalist>`), normalizacja do lowercase — bez literówek.
5. **Wyszukiwanie po tagu** (w Kursie): wybór tagu → lista materiałów mających
   notatkę z tym tagiem (np. „pokaż wszystkie, gdzie była mowa o #liczby”).
6. Klucz `itemKey`: `relPath`/`linked:<id>` (Kurs) lub `mat:<id>` (Materiały).

## Kryteria akceptacji
- Notatka z czasem; klik w timestamp przewija odtwarzacz.
- Tagi podpowiadane; wyszukiwarka znajduje materiały po tagu.
