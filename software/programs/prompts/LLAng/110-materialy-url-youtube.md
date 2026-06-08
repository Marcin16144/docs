# 110 — Materiały: adresy URL + YouTube w aplikacji

## Cel
Do drzewa Materiałów można dodawać **adresy URL** z automatyczną klasyfikacją.
YouTube odtwarza się w aplikacji jak film w Kursie, z notatkami z timestampem.

## Zadanie
1. Rozszerz model: `MaterialNode.type` o `"url"`, pole `url`, `DocKind` o
   `youtube | video | web`. W bazie dodaj kolumnę `url` (z `ALTER TABLE ... ADD
   COLUMN` dla istniejącej bazy, w try/catch).
2. **Klasyfikacja** `classifyUrl(url)`:
   - YouTube (`parseYouTubeId`: watch / youtu.be / embed / shorts / live) → `youtube`;
   - bezpośredni plik wideo (`.mp4/.webm/...`) → `video`;
   - reszta → `web`.
3. **YouTubeReader** (`forwardRef`, uchwyt `{ getTime, seek }`): ładuje oficjalne
   IFrame Player API (`https://www.youtube.com/iframe_api`), tworzy `YT.Player`;
   `getCurrentTime()` / `seekTo(s,true)`; wznawianie od zapisanej sekundy w
   `onReady`; zapis pozycji co 5 s i przy zmianie stanu →
   `reading_progress.page` (sekundy).
4. **UrlMaterialView**: youtube → YouTubeReader; video → `<video src={url}>` z
   resume; web → `<iframe src={url}>` + przycisk „🌐 Otwórz w przeglądarce”
   (`openUrl`, uprawnienie `opener:allow-open-url`). Pod spodem `TimedNotesPanel`
   (z 070) z `getTime/onSeek` dla mediów; klucz `mat:<id>`.
5. **Drzewo**: ikony URL (▶️ youtube / 🎬 video / 🔗 web), akcja „🔗+ Dodaj URL”,
   plakietka postępu `▶ mm:ss`. Strona: przycisk „➕ URL” (prompt na adres + nazwę),
   render `UrlMaterialView` dla węzłów `type==="url"` (klucz `key={node.id}`,
   by YouTube remountował się przy zmianie).
6. CSP: `csp: null` (pozwala ładować skrypt i osadzenie YouTube). Treść URL
   wymaga internetu.

## Kryteria akceptacji
- Wklejony link YouTube gra w aplikacji; notatka z timestampem przewija film.
- Pozycja odtwarzania zapamiętywana; web-strony osadzone lub otwierane w przeglądarce.
