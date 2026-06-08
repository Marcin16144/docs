# Prompt 090: admcore — wspólne funkcje panelu — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [080 Panel — front controller](080-panel-front-controller.md) · Następny: [100 Powłoka panelu (AdminLTE, offline)](100-layout-adminlte-offline.md) →

Ten krok odtwarza **bibliotekę wspólnych funkcji panelu** dołączaną przez `admin/index.php`. W repo jest to fasada `admin/admcore.php` (CSRF, AJAX, rate limiting, autentykacja + bootstrap konta `admin`, grupy, dziennik zdarzeń), która na końcu `require_once` dołącza moduły tematyczne (<1000 linii/plik, zgodnie z limitem rozmiaru): użytkownicy + domeny + `adminNotice()`, nawigacja, historia nawigacji + zestawy menu, snapshoty kont/domen, galeria, upload galerii. Publiczny interfejs (nazwy funkcji i stałych) jest płaski — wszystkie funkcje są globalne. Wymaga rdzenia (`Config`, `Connection`→PDO, `Core\Log\Logger`) i modeli Appdb (m.in. `GroupsModel::ADMIN_GROUP_ID`).

## Jak używać
1. Upewnij się, że rdzeń (Config, Connection, Logger) i modele Appdb są gotowe (kroki 010–070) oraz `admin/index.php` istnieje (krok 080).
2. Skopiuj blok **PROMPT** poniżej do asystenta LLM.
3. Asystent wygeneruje fasadę `admin/admcore.php` + moduły `admcore_*.php` z sygnaturami i kontraktami funkcji.
4. Zapisz pliki w katalogu `admin/`.
5. Zweryfikuj wg sekcji **Weryfikacja** (m.in. logowanie na świeżej bazie, CSRF, rate limit).

---

## PROMPT

```
Jesteś generatorem warstwy wspólnych funkcji panelu administracyjnego K2 CMS.
Wygeneruj plik admin/admcore.php (fasada) ORAZ moduły tematyczne admcore_*.php,
które fasada dołącza na końcu przez require_once. Wszystkie funkcje są GLOBALNE
(bez klas, bez namespace) — wspólny, płaski interfejs panelu.

## KONTEKST PROJEKTU

- K2 CMS — wielodomenowy CMS w PHP 8.1+ (declare(strict_types=1)).
- admcore.php jest dołączane przez admin/index.php po Config::load('_default')
  i przed routingiem. Funkcje są wołane z index.php oraz z backendów podstron
  pages/<sekcja>/adm<strona>.php.
- Dostępny rdzeń:
    Config::get($klucz, $default)         — odczyt konfiguracji (np. tenant.prefix)
    Connection::get(): PDO                 — połączenie z bazą (ERRMODE_EXCEPTION)
    \Core\Log\Logger::get($kanal)->info|warn|error(...)  — dziennik zdarzeń
- Modele aplikacji: App\Appdb\Models\GroupsModel ze stałą ADMIN_GROUP_ID.
- Multi-tenant: nazwy tabel są prefiksowane przez tenant.prefix z konfiguracji.
  Wzorzec helpera nazwy tabeli:
    function usersTable(): string {
        $prefix = (string)(Config::get('tenant')['prefix'] ?? '');
        return $prefix === '' ? 'users' : "{$prefix}_users";
    }
  (analogicznie groupsTable, domainsTable, eventsTable, navigationTable,
   loginAttemptsTable, galleriesTable, galleryPhotosTable, …).
- Konwencja kolumn: każda tabela ma prefiks kolumnowy (Use, Gro, Dom, Nav, Gal…).
  Konta: UseID (CHAR(36) GUID), UseLogin, UsePassword (bcrypt), UseEmail,
  UseIsActive, UseGroupID, UseLastLogin.

## KONWENCJE / ZASADY

- Każda funkcja sięgająca bazy używa PDO z prepared statements (placeholdery ?).
- Funkcje rate-limitingu są FAIL-OPEN: brak tabeli/błąd BD → nie blokują (try/catch → false/void).
- Hasła: password_hash(..., PASSWORD_DEFAULT) (bcrypt), weryfikacja password_verify().
- GUID v4 generuje uuidv4() (RFC 4122, wariant 8/9/a/b).
- Tabele zależne tworzone leniwie funkcjami ensure*Table()/ensureGalleryTables()
  (CREATE TABLE IF NOT EXISTS) — brak migracji nie wywraca panelu.
- Wzorzec PRG (POST→Redirect→GET): funkcje mutujące zwracają KOD NOTICE (string),
  który backend dokleja do URL jako ?un=<kod>; widok renderuje go przez
  adminNotice($_GET['un']). adminNotice(string $key): ?array zwraca [typ, treść]
  (typ: 'success' | 'warning' | 'danger' | 'info') lub null dla nieznanego klucza.
- Limit rozmiaru pliku: <1000 linii. Fasada admcore.php trzyma CSRF/AJAX/rate
  limiting/auth/grupy/zdarzenia, resztę delegujesz do modułów require_once.

## STRUKTURA PLIKÓW (fasada + moduły)

  admin/admcore.php               — fasada; na końcu require_once modułów:
      require_once __DIR__ . '/admcore_users_domains.php';
      require_once __DIR__ . '/admcore_navigation.php';
      require_once __DIR__ . '/admcore_nav_history.php';
      require_once __DIR__ . '/admcore_history.php';
      require_once __DIR__ . '/admcore_gallery.php';
      require_once __DIR__ . '/admcore_gallery_upload.php';

## GRUPY FUNKCJI I SYGNATURY (ODTWÓRZ DOKŁADNIE)

### admcore.php — CSRF, AJAX, narzędzia widoku, rate limiting, auth, grupy, zdarzenia

  // CSRF (synchronizer token, 64-hex per sesja)
  csrfToken(): string                  // generuje/zwraca $_SESSION['csrf_token'] = bin2hex(random_bytes(32))
  csrfVerify(): bool                   // hash_equals($_SESSION['csrf_token'], $_POST['_csrf']); WARN przy niezgodności
  csrfGuardOrFail(): void              // csrfVerify lub przerwij: ajaxJson(403) dla AJAX, inaczej 403 + tekst

  // Odpowiedzi AJAX i narzędzia
  ajaxJson(array $payload, ?int $statusCode = null): never  // czyści bufor, Content-Type JSON, JSON_INVALID_UTF8_SUBSTITUTE, exit
  iniSizeToBytes(string $value): int   // "16M"/"1G"/"512K" → bajty (0 dla pustego)
  renderNotice(?array $notice): void   // echo alertu Bootstrap z [typ, treść] lub nic gdy null

  // Rate limiting logowania (tabela <t>_login_attempts; bucket = SHA-256(IP); okno 900 s; limit 10)
  loginAttemptsTable(): string
  loginIsBlocked(string $ip): bool      // FAIL-OPEN; auto-czyści okno po 15 min
  loginRecordFailure(string $ip): void  // INSERT … ON DUPLICATE KEY UPDATE LaCount = LaCount + 1
  loginClearFailures(string $ip): void  // DELETE rekordu bucketu

  // Diagnostyka / autentykacja
  checkDbConnection(): array            // ['ok','version','info','tables'] lub ['ok'=>false,'error']
  authenticate(string $login, string $password): ?string  // login zalogowanego konta lub null
  usersExist(): bool
  ensureAdminAccount(): void            // tabela pusta → INSERT admin / bcrypt('admin'.date('Y')) + assignGroup(ADMIN_GROUP_ID)
  usersTable(): string
  groupsTable(): string

  // Grupy
  groupExists(string $groupId): bool
  assignGroup(string $userId, string $groupId): void
  listGroups(): array

  // Dziennik zdarzeń (tabela logów; filtry: kanał, poziom, użytkownik, zakres dat)
  eventsTable(): string
  eventsFilterClause(array $filters): array            // [whereSql, params]
  listEvents(int $limit = 30, int $offset = 0, array $filters = []): array
  countEvents(array $filters = []): int
  eventsPageUrl(int $pageNum, int $perPage, array $filters): string
  listEventChannels(): array
  listEventLevels(): array
  listEventUsers(): array
  eventLevelBadge(string $level): string               // klasa CSS badge wg poziomu

### admcore_users_domains.php — domeny, konta, narzędzia, adminNotice

  // Domeny (każda domena = osobna zakładka główna w menu)
  domainsTable(): string
  availableConfigs(): array                            // pliki configs/<host>.php do wyboru
  listDomains(): array
  getDomain(string $domainId): ?array
  createDomain(string $protocol, string $name, string $cmsName, string $config): string  // kod notice
  updateDomain(string $domainId, string $protocol, string $name, string $cmsName, string $config): string
  deleteDomain(string $domainId): void

  // Autentykacja (pomocnicze, używane przez authenticate())
  findActiveUser(string $login): ?array                // WHERE UseLogin = ? AND UseIsActive = 1
  touchLastLogin(string $userId): void                 // UseLastLogin = NOW()

  // Narzędzia
  uuidv4(): string                                     // GUID v4 (RFC 4122)

  // Konta użytkowników
  listUsers(): array
  countActiveAdmins(): int                             // zabezpieczenie „ostatni admin”
  createUser(string $login, string $password, string $email, string $groupId): string   // kod notice
  deleteUser(string $userId): void
  getUser(string $userId): ?array
  updateUser(string $userId, string $login, string $email, bool $active, string $groupId): string
  changePassword(string $userId, string $newPassword, string $confirm, string $oldPassword, bool $isSelf): string

  // System powiadomień (PRG)
  adminNotice(string $key): ?array                     // mapa klucz → ['success'|'warning'|'danger'|'info', 'treść'] lub null

### admcore_navigation.php — drzewo nawigacji jednej domeny

  navigationTable(): string
  listNavigationItems(string $menuId): array
  getNavigationItem(string $navId): ?array
  buildNavigationTree(array $items, ?string $parentId = null): array
  createNavigationItem( … ): string                    // dodaje pozycję (folder|page), zwraca kod notice
  updateNavigationItem( … ): string
  isNavigationDescendant(string $ancestorId, string $candidateId): bool   // ochrona przed cyklem rodzica
  deleteNavigationItem(string $navId): void
  renderNavigationTree(array $tree, string $domainId, string $menuId = '', bool $root = true, ?string $parentId = null): string
  moveNavigationItem(string $navId, string $direction): string            // 'up' | 'down'
  saveNavigationItemsOrder(string $domainId, ?string $parentId, array $orderedIds): string  // drag & drop
  flattenNavigationFolders(array $tree, int $depth = 0): array

### admcore_nav_history.php — snapshoty nawigacji + zestawy menu

  navigationHistoryTable(): string
  ensureNavigationHistoryTable(): bool
  saveNavigationSnapshot(string $domainId, string $menuId, string $label): bool   // zapisuje stan przed zmianą
  listNavigationHistory(string $menuId, int $limit = 50): array
  getNavigationSnapshot(string $histId): ?array
  applyNavigationSnapshot(string $histId): string      // przywraca wersję; bieżący stan → historia
  renderNavigationTreeDiff(array $snapItems, array $currentItems, string $histId): array
  renderNavigationTreeReadOnly(array $tree, bool $root = true): string
  // Zestawy menu (jedna domena może mieć wiele zestawów)
  navigationMenusTable(): string
  ensureNavigationMenusTable(): bool
  listNavigationMenus(string $domainId): array
  getNavigationMenu(string $menuId): ?array
  createNavigationMenu(string $domainId, string $name, string $slug): string
  updateNavigationMenu(string $menuId, string $name, string $slug): string
  deleteNavigationMenu(string $menuId): string
  getOrCreateDefaultMenu(string $domainId): string     // gwarantuje istnienie domyślnego zestawu

### admcore_history.php — snapshoty kont i domen

  usersHistoryTable(): string
  ensureUsersHistoryTable(): bool
  saveUsersSnapshot(string $label): bool
  listUsersHistory(int $limit = 50): array
  getUsersSnapshot(string $histId): ?array
  applyUsersSnapshot(string $histId): string
  renderUsersSnapshotTable(array $items): string
  renderUsersDiff(array $snapItems, array $currentItems, string $histId): array
  domainsHistoryTable(): string
  ensureDomainsHistoryTable(): bool
  saveDomainsSnapshot(string $label): bool
  listDomainsHistory(int $limit = 50): array
  getDomainsSnapshot(string $histId): ?array
  applyDomainsSnapshot(string $histId): string
  renderDomainsSnapshotTable(array $items): string
  renderDomainsDiff(array $snapItems, array $currentItems, string $histId): array

### admcore_gallery.php — galerie, zdjęcia, kosz (soft-delete), ustawienia

  galleriesTable(): string · galleryPhotosTable(): string · galleryCategoriesTable(): string
  galleryTagsTable(): string · galleryCatRelTable(): string · galleryTagRelTable(): string
  gallerySettingsTable(): string · galleryCacheFilesTable(): string
  ensureGalleryTables(): bool                          // CREATE IF NOT EXISTS dla wszystkich tabel galerii
  getGallerySetting(string $key, string $default = ''): string · setGallerySetting(string $key, string $value): void · listGallerySettings(): array
  galleryMediaFolder(array $domain): string
  listGalleries(string $domainId): array · getGallery(string $galleryId): ?array
  createGallery(string $domainId, string $name, string $description = ''): string
  updateGallery(string $galleryId, string $name, string $description, string $status): string
  deleteGallery(string $galleryId, array $domain): string
  listGalleryPhotos(string $galleryId): array          // WHERE GalPhotoDeletedAt IS NULL
  listGalleryTrash(string $galleryId): array           // WHERE GalPhotoDeletedAt IS NOT NULL
  getGalleryPhoto(string $photoId): ?array · galleryAuthorizePhoto(string $photoId, string $domainId): ?array
  countGalleryPhotoRefs(string $filename): int         // ochrona współdzielonych plików (deduplikacja)
  deleteGalleryPhoto(string $photoId, array $domain): string        // soft-delete: GalPhotoDeletedAt = NOW()
  restoreGalleryPhoto(string $photoId): string · permanentDeleteGalleryPhoto(string $photoId, array $domain): string
  emptyGalleryTrash(string $galleryId, array $domain): string · setGalleryCover(string $galleryId, string $photoId): string

### admcore_gallery_upload.php — kategorie/tagi, upload, obróbka GD

  listGalleryCategories(string $domainId): array · createGalleryCategory(string $domainId, string $name): string · deleteGalleryCategory(string $catId): string
  listGalleryTags(string $domainId): array · createGalleryTag(string $domainId, string $name): string · deleteGalleryTag(string $tagId): string
  getGalleryCategoryIds(string $galleryId): array · setGalleryCategories(string $galleryId, array $catIds): void
  getGalleryTagIds(string $galleryId): array · setGalleryTags(string $galleryId, array $tagIds): void
  getAllowedFileExtensions(): array · setAllowedFileExtensions(array $exts): void
  uploadGalleryPhoto(string $galleryId, string $tmpPath, string $origName, array $domain): array  // walidacja MIME + skalowanie + cascade INSERT
  reorderGalleryPhotos(array $sortedIds, string $galleryId): void
  galleryScaleImage(string $srcPath, string $dstPath, int $maxW, int $maxH, int $typeConst): bool
  galleryMakeThumbnail(string $srcPath, string $dstPath, int $size, int $typeConst): bool
  galleryMakePreview(string $srcPath, string $dstPath, int $targetW, int $typeConst): bool

## KONTRAKTY KLUCZOWE (ODTWÓRZ WIERNIE)

csrfToken():
  if (empty($_SESSION['csrf_token'])) { $_SESSION['csrf_token'] = bin2hex(random_bytes(32)); }
  return (string)$_SESSION['csrf_token'];

csrfVerify():
  $valid = $stored !== '' && hash_equals($stored, (string)($_POST['_csrf'] ?? ''));
  if (!$valid) { Logger::get('Auth')->warn('CSRF token mismatch', properties: […]); }
  return $valid;

authenticate($login, $password):
  $tableWasEmpty = !usersExist();
  if ($tableWasEmpty) { ensureAdminAccount(); }
  // konto serwisowe działa TYLKO gdy tabela była pusta:
  if ($tableWasEmpty && $login === 'admin' && hash_equals('admin'.date('Y'), $password)) { return 'admin'; }
  $user = findActiveUser($login);
  if ($user !== null && password_verify($password, (string)$user['UsePassword'])) {
      touchLastLogin((string)$user['UseID']); return (string)$user['UseLogin'];
  }
  return null;

ensureAdminAccount():
  // gdy tabela users pusta → INSERT (UseID=uuidv4(), UseLogin='admin',
  //   UsePassword=password_hash('admin'.date('Y'), PASSWORD_DEFAULT), UseIsActive=1)
  //   + assignGroup($adminId, GroupsModel::ADMIN_GROUP_ID); całość w try/catch.

loginIsBlocked($ip):
  // bucket = hash('sha256',$ip); SELECT LaCount, LaFirstAt … LIMIT 1; brak rekordu → false;
  // okno (time()-strtotime(LaFirstAt)) >= 900 → loginClearFailures + false; inaczej LaCount >= 10;
  // całość w try/catch → false (FAIL-OPEN).

adminNotice($key):
  // mapa klucz → [typ, treść], np.:
  //   'created'=>['success','Konto zostało utworzone.'], 'err_taken'=>['danger','Konto o tym loginie już istnieje.'],
  //   'dom_created'=>['success','Domena została dodana.'], 'nav_moved'=>['success','Kolejność pozycji menu została zaktualizowana.'],
  //   'gallery_created'=>['success','Galeria została dodana.'], 'photo_trashed'=>['success','Zdjęcie zostało usunięte.'],
  //   'err_last_admin'=>['danger',…], 'err_db'=>['danger','Błąd bazy danych — operacja nieudana.'], …
  // return $map[$key] ?? null;

## ZADANIE

1. Wygeneruj admin/admcore.php (fasada) z grupami: CSRF, AJAX, narzędzia widoku,
   rate limiting, diagnostyka/auth, grupy, dziennik zdarzeń — wg sygnatur powyżej —
   a na końcu sekcję require_once modułów admcore_*.php (w podanej kolejności).
2. Wygeneruj moduły admcore_users_domains.php, admcore_navigation.php,
   admcore_nav_history.php, admcore_history.php, admcore_gallery.php,
   admcore_gallery_upload.php z funkcjami z odpowiednich grup; zachowaj DOKŁADNE
   sygnatury (nazwy, parametry, typy zwrotów) i kontrakty z sekcji KONTRAKTY.
3. Wszystkie funkcje globalne (bez klas/namespace). Dostęp do bazy przez
   Connection::get() z prepared statements; nazwy tabel przez helpery *Table().
4. Funkcje mutujące dla PRG zwracają kod notice (string) zgodny z adminNotice().
   Funkcje rate-limitingu i ensure*Table() są fail-open (try/catch).
5. Każdy plik poprzedź jedną linią-komentarzem ze ścieżką, np.
   „// === admin/admcore.php ===”. Każdy plik zaczyna od „<?php” + declare(strict_types=1).
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] `admin/admcore.php` na końcu `require_once` dołącza 6 modułów `admcore_*.php` w podanej kolejności; publiczny interfejs (nazwy funkcji) bez zmian.
- [ ] Na świeżej (pustej) bazie logowanie `admin` / `admin<rok>` działa raz, zakłada konto w `<t>_users` i przypisuje grupę `ADMIN_GROUP_ID`; po pojawieniu się konta logowanie idzie wyłącznie przez bazę.
- [ ] `csrfToken()` zwraca 64-znakowy hex per sesja; `csrfVerify()` używa `hash_equals` i loguje WARN przy niezgodności.
- [ ] `loginIsBlocked()`/`loginRecordFailure()`/`loginClearFailures()` są fail-open: brak tabeli `<t>_login_attempts` nie wywraca logowania; limit 10 prób / 15 min na bucket SHA-256(IP).
- [ ] Wszystkie funkcje mutujące zwracają kod notice rozumiany przez `adminNotice()`; `adminNotice('zly_klucz')` zwraca `null`.
- [ ] `listGalleryPhotos()` filtruje `GalPhotoDeletedAt IS NULL`, `listGalleryTrash()` — `IS NOT NULL`; `deleteGalleryPhoto()` ustawia `GalPhotoDeletedAt = NOW()` (soft-delete).
- [ ] Każdy moduł ma < 1000 linii (limit rozmiaru pliku); brak duplikacji nazw funkcji między modułami.

## Powiązane
- [docs/architektura/architektura.md §6.2 (admcore.php — wspólne funkcje)](../../architektura/architektura.md)
- [docs/architektura/architektura.md §6.5 (System powiadomień adminNotice)](../../architektura/architektura.md)
- [docs/architektura/architektura.md §10 (Bezpieczeństwo — CSRF, rate limiting, autentykacja)](../../architektura/architektura.md)
- [Poprzedni krok: 080 Panel — front controller](080-panel-front-controller.md)
- [Następny krok: 100 Powłoka panelu (AdminLTE, offline)](100-layout-adminlte-offline.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
