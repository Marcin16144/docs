# 060 — Kurs: odtwarzacz z resume + Picture-in-Picture

## Cel
Odtwarzanie wideo/audio z dysku w aplikacji, z zapamiętywaniem miejsca i opcją
przeniesienia filmu na drugi ekran.

## Zadanie
1. **Serwowanie plików z dysku do WebView**: w Rust włącz feature
   `tauri` = `["protocol-asset"]`, w `tauri.conf.json`
   `app.security.assetProtocol = { enable: true, scope: ["**"] }`. W kodzie:
   `convertFileSrc(absPath)` jako `src` dla `<video>`/`<audio>`.
2. **MediaPlayer** (`forwardRef`, uchwyt `{ seek, getTime, togglePip }`):
   - zapis pozycji co ~5 s, przy pauzie, przy przełączeniu materiału (unmount)
     oraz przy ukryciu/zamknięciu okna (`pagehide`, `visibilitychange`);
   - wznawianie: w `onLoadedMetadata` ustaw `currentTime` na zapisaną pozycję;
   - **PiP**: `requestPictureInPicture()` / `exitPictureInPicture()` (tylko wideo)
     — pływające okienko do przeniesienia na drugi monitor.
3. **Panel materiału** (`MaterialDetail`): nagłówek (typ, nazwa), przyciski
   ⭐ ulubione, ✓ ukończone, ⧉ „Drugi ekran”; odtwarzacz; informacja
   „Zatrzymano na mm:ss”; dla dokumentów przycisk „Otwórz w domyślnej aplikacji”
   (plugin opener, `opener:allow-open-path`).
4. Zapis stanu przez `item_state` (pozycja/duration/done/favorite), klucz =
   `relPath` (skan) lub `linked:<id>`.
5. Przycisk **„▶ Kontynuuj”** na górze Kursu → otwiera ostatni materiał w miejscu
   przerwania.

## Kryteria akceptacji
- Po ponownym otwarciu materiału film/audio wznawia się w miejscu zatrzymania.
- PiP odrywa wideo do osobnego, przeciągalnego okienka.
