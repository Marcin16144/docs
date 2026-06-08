# 100 — Materiały: drzewo + czytnik PDF/EPUB

## Cel
Osobna zakładka „Materiały”: własne drzewo (foldery + pliki) budowane przez
użytkownika, z wbudowanym czytnikiem PDF/EPUB i zapamiętywaniem strony/pozycji.
Funkcja desktopowa.

## Zadanie
1. Model `MaterialNode { id, parentId, type:"folder"|"file"|"url", name,
   absPath, url, ext, docKind, created }` i `ReadingProgress { nodeId, page,
   total, location, updated }`. Tabele `material_nodes`, `reading_progress`.
   `docKind` dla plików: `pdf | epub | other`.
2. Hook `useMaterials`: ładowanie węzłów, budowa drzewa z `parentId`
   (foldery najpierw), postęp; akcje `addFolder`, `addFiles` (plugin-dialog),
   `rename`, `removeNode` (kaskadowo całe poddrzewo), `saveProgress`.
3. **Czytnik PDF** (`PdfReader`): biblioteka `pdfjs-dist` v6; worker przez
   `import workerUrl from "pdfjs-dist/build/pdf.worker.min.mjs?url"` →
   `GlobalWorkerOptions.workerSrc`. Wczytaj plik:
   `fetch(convertFileSrc(absPath)).arrayBuffer()` → `getDocument({data})`.
   Render strony na `<canvas>`; nawigacja prev/next + pole numeru + zoom.
   Zapis bieżącej strony do `reading_progress.page` (+ `total`), wznawianie.
4. **Czytnik EPUB** (`EpubReader`): biblioteka `epubjs`;
   `ePub(convertFileSrc(absPath)).renderTo(div, {...})`; nawigacja prev/next;
   zapis `location` = CFI z eventu `relocated`, wznawianie przez `display(cfi)`.
   Fallback „Otwórz w domyślnej aplikacji”, gdy render się nie powiedzie.
5. **MaterialReader** wybiera czytnik wg `docKind`. **Strona Materiały**: lewa
   kolumna = drzewo z akcjami (➕ Folder / ➕ Plik / zmień nazwę / usuń), prawa =
   czytnik. Zapamiętuj ostatnio otwarty plik (`materials.lastItem`).

## Kryteria akceptacji
- Dodanie PDF/EPUB i czytanie w aplikacji; po powrocie wznawia od ostatniej
  strony/pozycji.
