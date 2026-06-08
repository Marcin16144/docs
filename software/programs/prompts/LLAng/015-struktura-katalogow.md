# 015 — Struktura katalogów (mapa plików)

Docelowa mapa plików projektu. W nawiasie numer promptu, który dany plik tworzy.

```
LLAng/
├─ index.html
├─ package.json
├─ vite.config.ts                 (020)
├─ tailwind / postcss             (020 — Tailwind v4 przez @tailwindcss/vite)
├─ src/
│  ├─ main.tsx                    (020/130 — HashRouter + init motywu)
│  ├─ App.tsx                     (140 — layout, nawigacja, overlay Kursu)
│  ├─ index.css                   (020/080/130 — Tailwind, style notatek, motyw czarny)
│  ├─ data/
│  │  ├─ models.ts                (030+ — typy domenowe, classifyUrl, kindy)
│  │  ├─ db.ts                    (030 — interfejs + wybór implementacji)
│  │  ├─ db.web.ts                (030 — IndexedDB/Dexie)
│  │  ├─ db.tauri.ts              (030 — SQLite)
│  │  └─ seed.ts                  (040 — startowe słówka)
│  ├─ store/
│  │  ├─ useDeck.ts               (040 — sesja fiszek)
│  │  ├─ useLibrary.ts            (050/060 — biblioteka kursu)
│  │  ├─ useMaterials.ts          (100/110 — drzewo materiałów)
│  │  └─ useNotes.ts              (070 — wspólne notatki)
│  ├─ features/
│  │  ├─ srs/sm2.ts               (040 — algorytm powtórek)
│  │  ├─ tts/speak.ts             (040 — wymowa)
│  │  ├─ course/library.ts        (050 — skan, drzewo, sortowanie, fmt)
│  │  ├─ chat/ollama.ts           (120 — wywołania Ollamy)
│  │  └─ theme.ts                 (130 — applyTheme/getInitialTheme)
│  ├─ components/
│  │  ├─ AudioButton.tsx          (040)
│  │  ├─ FlashCard.tsx            (040)
│  │  ├─ ThemeToggle.tsx          (130)
│  │  ├─ TagInput.tsx             (070)
│  │  ├─ RichNoteEditor.tsx       (080)
│  │  ├─ TimedNotesPanel.tsx      (070 — używany w Kursie i Materiałach)
│  │  ├─ MediaPlayer.tsx          (060 — resume + PiP + seek)
│  │  ├─ CourseTree.tsx           (050)
│  │  ├─ MaterialDetail.tsx       (060 — panel materiału kursu)
│  │  ├─ AddMaterialModal.tsx     (050 — dowiązanie pliku do rozdziału)
│  │  ├─ IntegrityPanel.tsx       (090)
│  │  ├─ MaterialsTree.tsx        (100/110 — drzewo Materiałów)
│  │  ├─ MaterialReader.tsx       (100 — wybór czytnika pliku)
│  │  ├─ PdfReader.tsx            (100 — pdf.js)
│  │  ├─ EpubReader.tsx           (100 — epub.js)
│  │  ├─ YouTubeReader.tsx        (110 — IFrame API)
│  │  └─ UrlMaterialView.tsx      (110 — youtube/video/web + notatki)
│  └─ pages/
│     ├─ Dashboard.tsx            (040)
│     ├─ Course.tsx               (050/060/070)
│     ├─ Materials.tsx            (100/110)
│     ├─ Chat.tsx                 (120)
│     ├─ Flashcards.tsx           (040)
│     └─ Settings.tsx             (050 — ścieżka biblioteki, motyw środowiska)
└─ src-tauri/
   ├─ Cargo.toml                  (zależności: tauri[protocol-asset], plugin-sql,
   │                               plugin-dialog, plugin-opener, blake3, reqwest)
   ├─ build.rs
   ├─ tauri.conf.json             (okno, assetProtocol, bundle)
   ├─ capabilities/default.json   (uprawnienia: sql, dialog, opener, ...)
   ├─ icons/
   └─ src/
      ├─ main.rs
      └─ lib.rs                   (komendy: scan_library, file_exists, hash_file,
                                   ollama_models, ollama_chat)
```

> `src/App.css` z szablonu jest nieużywany — można usunąć.
