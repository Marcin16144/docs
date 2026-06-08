# 030 — Warstwa danych (SQLite + IndexedDB)

## Cel
Jeden interfejs danych, dwie implementacje: SQLite na desktopie, IndexedDB w web.
Reszta aplikacji nie wie, gdzie działa.

## Zadanie
1. Zdefiniuj interfejs `CardRepository` w `src/data/db.ts` z metodami dla:
   fiszek, ustawień (klucz→wartość), stanu materiałów, materiałów dowiązanych,
   integralności plików, notatek, drzewa materiałów i postępu czytania.
2. Wykrywanie środowiska:
   `export const isDesktop = typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;`
3. `getDb()` leniwie tworzy implementację:
   - desktop → `TauriSqliteRepo` (plugin `@tauri-apps/plugin-sql`, baza
     `sqlite:llang.db`; tabele tworzone w `init()`),
   - web → `WebDexieRepo` (Dexie / IndexedDB).
   Import implementacji **dynamiczny** (`await import(...)`), by web bundle nie
   ładował kodu desktopowego.
4. Strona Rust: zarejestruj `tauri-plugin-sql` z feature `sqlite`; w
   `capabilities` dodaj uprawnienia `sql:default` + allow-load/execute/select/close.

## Schemat danych (minimum)
- `settings(key PK, value)`
- `cards(id PK, en, pl, example, category, repetition, interval, ease, due)`
- `item_state(key PK, position, duration, done, favorite, note, updated)` — stan
  materiałów kursu, klucz = ścieżka względna lub `linked:<id>`
- `linked_materials(id PK, chapter, absPath, name, ext, kind, added)`
- `file_integrity(relPath PK, size, hash, checkedAt)`
- `notes(id PK, itemKey, time, text, tags, created)` — tagi jako JSON w SQLite
- `material_nodes(id PK, parentId, type, name, absPath, url, ext, docKind, created)`
- `reading_progress(nodeId PK, page, total, location, updated)`

## Zasady
- Booleany w SQLite jako 0/1; konwertuj przy odczycie.
- `ON CONFLICT ... DO UPDATE` dla upsertów.
- W Dexie wersjonuj schemat (`version(n).stores(...)`).

## Kryteria akceptacji
- Te same wywołania `getDb()` działają w web i desktop.
- Dane przeżywają restart aplikacji.
