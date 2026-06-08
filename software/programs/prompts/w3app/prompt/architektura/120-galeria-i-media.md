# Prompt 120: Galeria i media — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [110 Podstrony panelu](110-podstrony-panelu.md) · Następny: [130 Kopie zapasowe](130-kopie-zapasowe.md) →

Buduje **warstwę galerii i mediów** panelu: 6 tabel tenant-prefixed tworzonych leniwie przez `ensureGalleryTables()`, strukturę katalogów `media/originals/<host>/` i `media/cache/<host>/`, obróbkę obrazów PHP GD oraz wzorce odpornościowe — kaskadowy INSERT i soft-delete (kosz). Wymaga gotowych modeli galerii z [070 Modele aplikacji](070-modele-aplikacji-appdb.md) oraz wspólnych funkcji panelu (`Connection`, `Config`, `uuidv4()`).

## Jak używać
1. Upewnij się, że istnieją modele `Gallery*Model` (prompt 070) i rdzeń `Connection`/`Config`.
2. Skopiuj blok **PROMPT** poniżej do asystenta LLM.
3. Asystent wygeneruje funkcje galerii (PHP, do `admin/admcore_gallery*.php`) i strukturę `media/`.
4. Zweryfikuj upload, miniaturowanie, kosz i strukturę katalogów wg sekcji **Weryfikacja**.

---

## PROMPT
```
Jesteś inżynierem PHP odtwarzającym warstwę galerii i mediów panelu K2 CMS.
Wygeneruj funkcje galerii oraz strukturę katalogów media/.

## KONTEKST PROJEKTU

- PHP 8.1+, MySQL 8 (InnoDB, utf8mb4), wielodomenowość (tabele z prefiksem tenanta).
- Dostępne globalnie: `Core\Connection::get(): PDO`, `Core\Config::get($key)`,
  `uuidv4(): string`, stała `ROOT` (katalog główny projektu).
- Modele tabel galerii istnieją w `App\Appdb\Models\` (GalleriesModel, GalleryPhotosModel,
  GalleryCategoriesModel, GalleryTagsModel, GalleryCatRelModel, GalleryTagRelModel)
  i renderują SQL przez `->createTableSql($prefix)`.
- Funkcje trafiają do `admin/admcore_gallery.php` (CRUD, kosz, leniwe tabele)
  oraz `admin/admcore_gallery_upload.php` (upload, GD), dołączanych z `admcore.php`.

## ŚCIEŻKI

- admin/admcore_gallery.php        — leniwe tabele, CRUD galerii/zdjęć, kosz
- admin/admcore_gallery_upload.php — upload + obróbka GD
- media/originals/<tenant-host>/   — oryginały (per-domena; podfolder rok/mc, np. 202605)
- media/cache/<tenant-host>/       — wersja skalowana (web) + podkatalog thumb/
- media/originals/.gitignore, media/cache/.gitignore — reguła: * / !.gitignore / !.gitkeep

## TABELE (6, tenant-prefixed)

  <t>_galleries          nagłówki galerii (DomID, Name, Description, CoverPhotoID, Sort, Status)
  <t>_gallery_photos     zdjęcia (patrz kolumny niżej)
  <t>_gallery_categories kategorie per-domena
  <t>_gallery_tags       tagi per-domena
  <t>_gallery_cat_rel    pivot galeria↔kategoria (M:N)
  <t>_gallery_tag_rel    pivot galeria↔tag (M:N)

Kluczowe kolumny `<t>_gallery_photos`:
  GalPhotoFilename  VARCHAR(255)        UUID.ext — nazwa pliku na dysku
  GalPhotoOrigName  VARCHAR(255) NULL   oryginalna nazwa przy uploadzie
  GalPhotoHash      VARCHAR(64)  NULL   SHA-256 do deduplikacji plików (indeks)
  GalPhotoSort      INT DEFAULT 0       pozycja drag & drop
  GalPhotoDeletedAt DATETIME NULL       NULL = aktywne; NOT NULL = w koszu (soft-delete)
  (+ Title/Alt/Caption/Width/Height/Size/Mime/Folder)

## ZASADA: LENIWE TWORZENIE TABEL — ensureGalleryTables(): bool

  - Idempotentna ze statyczną pamięcią (static $done/$result) — wykonuje pracę raz na żądanie.
  - Pobiera prefiks z Config::get('tenant')['prefix'].
  - Dla każdego z 6 modeli woła $model->createTableSql($prefix), podmieniając
    'CREATE TABLE ' → 'CREATE TABLE IF NOT EXISTS ' i wykonując przez $pdo->exec().
  - Po utworzeniu robi „inline-migracje" tabeli zdjęć: SHOW COLUMNS FROM `<photos>`,
    a brakujące kolumny dodaje ALTER-em (GalPhotoCaption, GalPhotoOrigName,
    GalPhotoDeletedAt + indeks idx_..._trash, GalPhotoMime, GalPhotoHash + indeks,
    GalPhotoFolder). Dzięki temu stare instalacje bez wszystkich migracji nadal działają.
  - Tworzy pomocnicze tabele klucz-wartość (ustawienia galerii) i tabelę plików cache
    `<t>_gallery_cache_files` (GalCfPhotoID, GalCfVariant 'cache'|'thumb', GalCfFilename,
    wymiary, rozmiar, jakość; UNIQUE (GalCfPhotoID, GalCfVariant)).
  - Fail-open: cały blok w try/catch(Throwable) — przy błędzie zwraca false i ponawia
    przy kolejnym żądaniu. Wołane na początku listGalleryPhotos()/listGalleryTrash().

## ZASADA: STRUKTURA KATALOGÓW MEDIÓW

  media/originals/<host>/<subfolder?>/<uuid>.<ext>            oryginał
  media/cache/<host>/<subfolder?>/<uuid>_<q>[_<w>_<h>].<ext>  wersja web (skalowana)
  media/cache/<host>/<subfolder?>/thumb/<plik-cache>          miniatura (kwadrat)

  - <host> = galleryMediaFolder($domain): bazuje na DomCmsName (priorytet) lub DomName;
    usuwa ":", inne niedozwolone znaki zamienia na "_".
  - <subfolder> = rok+miesiąc (np. "202605"), TYLKO gdy kolumna GalPhotoFolder istnieje
    w DB (galleryCurrentSubFolder()). Inaczej płaska struktura (kompatybilność wsteczna).
  - Katalogi tworzone mkdir(..., 0755, true) przy uploadzie.
  - .gitignore w media/originals/ i media/cache/: reguła * / !.gitignore / !.gitkeep
    (oryginały i cache NIE są wersjonowane w git).

## ZASADA: KASKADOWY INSERT (odporność na brak migracji)

  Upload wstawia rekord wariantami od najbogatszego do minimalnego. Przy złapaniu
  PDOException z komunikatem zawierającym 'Unknown column' próbuje uboższy wariant;
  inny błąd DB przerywa pętlę natychmiast.

    $variants = [
      [$sqlHashFolder,  $paramsHashFolder],   // A: GalPhotoHash + GalPhotoFolder + reszta
      [$sqlFolder,      $paramsFolder],       // B: GalPhotoFolder, bez Hash
      [$sqlOrigName,    $paramsOrigName],     // B2: GalPhotoOrigName, bez Hash/Folder
      [$sqlMinimal,     $paramsMinimal],      // C: tylko kolumny podstawowe
    ];
    $inserted = false;
    foreach ($variants as [$sql, $params]) {
      try { $pdo->prepare($sql)->execute($params); $inserted = true; break; }
      catch (\PDOException $e) {
        if (str_contains($e->getMessage(), 'Unknown column')) { continue; }
        break; // inny błąd — przerwij
      }
    }
    if (!$inserted) { /* rollback plików (@unlink orig + cache + thumb) i zwrot błędu */ }

## ZASADA: SOFT-DELETE (kosz)

  listGalleryPhotos($galleryId): WHERE GalPhotoDeletedAt IS NULL  (+ try/catch fallback
    bez filtra, gdy kolumna nie istnieje); sort GalPhotoSort ASC, GalPhotoIDAuto ASC.
  listGalleryTrash($galleryId):  WHERE GalPhotoDeletedAt IS NOT NULL; sort DeletedAt DESC;
    [] gdy kolumna niedostępna.

  deleteGalleryPhoto($photoId, $domain):     SET GalPhotoDeletedAt = NOW() (pliki zachowane);
    czyści okładkę galerii (GalCoverPhotoID = NULL) wskazującą na to zdjęcie → 'photo_trashed'.
  restoreGalleryPhoto($photoId):             SET GalPhotoDeletedAt = NULL → 'photo_restored'.
  permanentDeleteGalleryPhoto($photoId,$d):  DELETE rekordu, potem unlink plików TYLKO gdy
    countGalleryPhotoRefs(filename) === 0 (ochrona współdzielonych plików przy dedup)
    → 'photo_perm_deleted'.
  emptyGalleryTrash($galleryId,$domain):     DELETE batch (DeletedAt IS NOT NULL) + unlink
    plików bez referencji → 'trash_emptied'.
  countGalleryPhotoRefs($filename): SELECT COUNT(*) WHERE GalPhotoFilename = ?.

## ZASADA: OBRÓBKA OBRAZÓW (PHP GD)

  Wejście: JPEG / PNG / GIF / WEBP (wykrywanie przez getimagesize() + IMAGETYPE_*).
  Format wyjściowy zachowuje typ wejścia (jpg/png/gif/webp); kanał alfa zachowany dla PNG/GIF.

  galleryScaleImage($src, $dst, $maxW, $maxH, $typeConst): bool
    - $ratio = min($maxW/$w, $maxH/$h); nowe wymiary = round(orig * ratio), min 1 px.
    - imagecreatetruecolor + alfa (PNG/GIF) + imagecopyresampled; zapis przez galleryImageSave().
    - Gdy źródła nie da się wczytać → fallback copy($src,$dst). Domyślne limity z konfiguracji
      gallery.max_width (1920) / gallery.max_height (1080), nadpisywalne ustawieniami galerii.

  galleryMakeThumbnail($src, $dst, $size, $typeConst): bool
    - crop kwadratowy ze środka: $min = min($w,$h); srcX/srcY = (wymiar - $min)/2.
    - imagecopyresampled do $size×$size; zapis przez galleryImageSave(). Domyślny rozmiar
      z gallery.thumb_size (300), nadpisywalny ustawieniem galerii.

  galleryImageSave($img, $path, $typeConst, $q?): JPEG → imagejpeg($img,$path,$q),
    PNG → imagepng($img,$path,6), GIF → imagegif, WEBP → imagewebp($img,$path,$q).
    $q domyślnie z ustawienia jpeg_quality (90), zaciśnięte do 1..100.

## ZADANIE

1. Odtwórz ensureGalleryTables(): bool — leniwe CREATE IF NOT EXISTS 6 tabel z modeli,
   inline-ALTER brakujących kolumn tabeli zdjęć, tabele pomocnicze, fail-open.
2. Odtwórz CRUD galerii (list/get/create/update/delete) i odczyt zdjęć
   (listGalleryPhotos, listGalleryTrash, getGalleryPhoto, countGalleryPhotoRefs).
3. Odtwórz uploadGalleryPhoto($galleryId,$tmpPath,$origName,$domain): array — walidacja
   MIME/rozszerzenia, SHA-256 + deduplikacja, mkdir struktury katalogów, zapis oryginału
   (move_uploaded_file z fallbackiem rename), skalowanie + miniatura GD, kaskadowy INSERT
   z rollbackiem plików, zwrot tablicy { ok, photo_id, filename, cache_file, ... }.
4. Odtwórz soft-delete (delete/restore/permanentDelete/emptyTrash) wg zasad powyżej —
   unlink tylko gdy refs <= 0/1.
5. Odtwórz funkcje GD (galleryScaleImage, galleryMakeThumbnail, helpery create/alpha/save).
6. Utwórz strukturę media/originals/ i media/cache/ z plikami .gitignore (* / !.gitignore / !.gitkeep) i .gitkeep.
7. Funkcje zwracają kody notice ('photo_trashed','photo_restored','photo_perm_deleted',
   'trash_emptied','err_db','err_gal_notfound') lub tablice — bez echo/HTML.

Zwróć tylko pliki/kod, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] `ensureGalleryTables()` jest idempotentne (static), tworzy 6 tabel `CREATE TABLE IF NOT EXISTS` z modeli i nie rzuca wyjątku (fail-open).
- [ ] Brakujące kolumny tabeli zdjęć (`GalPhotoDeletedAt`, `GalPhotoHash`, `GalPhotoFolder`, `GalPhotoOrigName`, `GalPhotoCaption`, `GalPhotoMime`) są dodawane inline-ALTER-em po SHOW COLUMNS.
- [ ] Upload zapisuje oryginał do `media/originals/<host>/...` i wersję web + `thumb/` do `media/cache/<host>/...`.
- [ ] Nazwa pliku to `uuidv4()` + rozszerzenie; identyczny plik (ten sam SHA-256) jest reużywany bez ponownego zapisu.
- [ ] Kaskadowy INSERT degraduje wariant po złapaniu `Unknown column`; inny błąd DB przerywa i wyzwala rollback plików.
- [ ] „Usuń" ustawia `GalPhotoDeletedAt = NOW()` (plik zostaje); „Przywróć" zeruje znacznik; „Usuń na stałe"/„Opróżnij kosz" robią `unlink` tylko gdy `countGalleryPhotoRefs()` nie wskazuje innych referencji.
- [ ] `galleryScaleImage`/`galleryMakeThumbnail` obsługują JPEG/PNG/GIF/WEBP na wejściu, zachowują typ i alfę, mają fallback `copy()`.
- [ ] `media/originals/.gitignore` i `media/cache/.gitignore` mają regułę `* / !.gitignore / !.gitkeep`; katalogi `<host>` nie trafiają do gita.

## Powiązane
- [070 Modele aplikacji (Appdb)](070-modele-aplikacji-appdb.md) — modele `Gallery*Model`.
- [110 Podstrony panelu](110-podstrony-panelu.md) — strona `admgallery` (widok + akcje POST/AJAX).
- [130 Kopie zapasowe](130-kopie-zapasowe.md) — archiwizacja katalogów `media/` (full/media).
- [Architektura §7 (Galeria i media)](../../architektura/architektura.md).
