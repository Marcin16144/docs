# Architektura techniczna K2 CMS

> **Wersja:** 0.8.0 · **Data:** 2026-05-24 · **Status:** aktualna

---

## Spis treści

1. [Przegląd systemu](#1-przegląd-systemu)
2. [Stos technologiczny](#2-stos-technologiczny)
3. [Struktura katalogów](#3-struktura-katalogów)
4. [Warstwa rdzenia (core/)](#4-warstwa-rdzenia-core)
5. [Warstwa aplikacji (app/)](#5-warstwa-aplikacji-app)
6. [Panel administracyjny (admin/)](#6-panel-administracyjny-admin)
7. [Galeria i media](#7-galeria-i-media)
8. [System kopii zapasowych](#8-system-kopii-zapasowych)
9. [Wzorzec multi-tenant](#9-wzorzec-multi-tenant)
10. [Bezpieczeństwo](#10-bezpieczeństwo)

---

## 1. Przegląd systemu

K2 CMS to wielodomenowy system zarządzania treścią napisany w PHP 8.1+. Jedna instalacja
obsługuje wiele domen (tenantów) — każda ma własny prefiks tabel, konfigurację i panel
administracyjny pod unikatowym, sekretnym adresem URL.

Panel oparty jest na szablonie **AdminLTE 3** (Bootstrap 4 + jQuery 3.6), w całości
zvendorowanym lokalnie — system działa **bez dostępu do internetu**, bez CDN.

**Moduły panelu administracyjnego:**

| Moduł | Zakres |
|---|---|
| Użytkownicy i grupy | CRUD kont, uprawnienia, snapshoty historii |
| Domeny | Konfiguracja tenantów, snapshoty historii |
| Nawigacja | Wielozestawowe drzewa menu, historia migawkowa |
| Galeria | Galerie zdjęć, upload, miniaturowanie, kosz (soft-delete) |
| Dziennik zdarzeń | Logi systemowe z filtrami (kanał, poziom, użytkownik, data) |
| Kopia zapasowa | SQL / ZIP+media / media-only; opcjonalne szyfrowanie AES-256 |
| Diagnostyka | Informacje o systemie, połączeniu BD, PHP |

---

## 2. Stos technologiczny

| Warstwa | Technologia | Wersja |
|---|---|---|
| Język | PHP | 8.1+ |
| Baza danych | MySQL | 8.x (InnoDB, utf8mb4_unicode_ci) |
| Baza alternatywna | SQLite | 3.x |
| Migracje | Doctrine Migrations | 3.x |
| Szablon UI | AdminLTE | 3.x (vendored) |
| CSS framework | Bootstrap | 4.x (vendored) |
| JS library | jQuery | 3.6 (vendored) |
| Ikony | Font Awesome | 6.x (vendored) |
| Obróbka obrazów | PHP GD | — (wbudowane) |
| Archiwizacja ZIP | PHP ZipArchive | ext-zip |
| Archiwizacja TAR.GZ | PHP PharData | ext-phar (fallback) |
| Szyfrowanie backupów | PHP OpenSSL | ext-openssl (opcjonalne) |
| Zależności | Composer | — |

Wszystkie pliki `vendor/`, `admin/assets/` są dostarczane razem z projektem —
żadne zasoby nie są pobierane z zewnętrznych serwerów w runtime.

---

## 3. Struktura katalogów

```
w3app/
├── admin/                    # Panel administracyjny
│   ├── assets/               # Vendored UI: adminlte/, bootstrap/, jquery/, fontawesome/, img/
│   ├── pages/
│   │   ├── desktop/dashboard/        admpulpit.php + .view.php
│   │   ├── gallery/                  admgallery.php + admgallery.view.php
│   │   │                             admgallerydetail.view.php
│   │   ├── navigation/menu/          admmenu.php + admmenuedit.php + admmenus.view.php
│   │   ├── settings/
│   │   │   ├── permissions/          admuprawnienia*.php
│   │   │   ├── groups/               admgrupy*.php
│   │   │   └── domains/              admdomeny*.php
│   │   └── system/
│   │       ├── diagnostics/          admsystem*.php
│   │       ├── events/               admevent*.php
│   │       └── backup/               admbackup*.php
│   ├── admcore.php           # Wspólne funkcje panelu (auth, CRUD, gallery, backup…)
│   ├── admlogin.view.php     # Ekran logowania
│   ├── admlayout.view.php    # Powłoka AdminLTE (sidebar, topbar, SVG logo)
│   ├── index.php             # Punkt wejścia, router, uwierzytelnianie
│   ├── index.css             # Style globalne (.card overflow:hidden, rounded-corners…)
│   └── index.js              # JS panelu (motywy, dostępność)
│
├── app/
│   ├── Appdb/
│   │   ├── Migrations/       # 22 pliki migracji (Version<YYYYMMDDHHMMSS>.php)
│   │   └── Models/           # 13 modeli tabel (Users, Groups, Domains, Nav*, Gallery*, Logs)
│   ├── Cms/
│   │   ├── Migrations/       # Migracje CMS (strony, treści)
│   │   └── Models/           # PagesModel
│   └── Shop/
│       └── Migrations/       # (placeholder — niezaimplementowane)
│
├── configs/
│   ├── _default.php          # Bazowa konfiguracja (db, tenant, admin_code…)
│   └── <hostname>.php        # Nadpisania per-tenant (np. klient1.local.php)
│
├── core/
│   ├── Config.php            # Ładowanie i dostęp do konfiguracji
│   ├── Connection.php        # Singleton PDO z fabryką sterowników
│   ├── version.php           # Stała wersji aplikacji
│   ├── db/                   # Sterowniki: MySqlDriver, PgSqlDriver, SqliteDriver
│   ├── Log/Logger.php        # Rejestrator zdarzeń (structured, wielopoziomowy)
│   ├── Migrations/           # TenantMigration, TenantMigrationFactory, MigrationRunner…
│   └── Models/               # TableModel, Column, Index — baza dla modeli tabel
│
├── docs/
│   ├── architektura/         # Dokumentacja architektury (MD + HTML)
│   ├── prompt/acms/          # Biblioteka promptów AI dla K2 CMS
│   └── propozycje/           # Propozycje rozbudowy
│
├── media/
│   ├── originals/            # Oryginały zdjęć per-tenant (nie wersjonowane, .gitignore)
│   └── cache/                # Miniatury i skale per-tenant (nie wersjonowane, .gitignore)
│
├── var/
│   ├── backups/              # Kopie zapasowe: .sql / .zip / .tar.gz (nie wersjonowane)
│   ├── logs/                 # Awaryjny log plikowy (gdy BD niedostępna)
│   └── schema-lock/          # Lock-plik migracji per środowisko
│
└── vendor/                   # Composer: doctrine/migrations, psr/log…
```

---

## 4. Warstwa rdzenia (core/)

### 4.1 Config

`core/Config.php` — ładuje konfigurację jako tablicę PHP przy pierwszym żądaniu.

```php
Config::load($_SERVER['HTTP_HOST']);   // ładuje _default.php + <host>.php (array_replace_recursive)
Config::get('tenant')['prefix'];       // zwraca prefix tabel, np. "def"
Config::get('admin_code');             // sekretny kod URL panelu
Config::get('db');                     // parametry połączenia z bazą
```

Plik `configs/_default.php` zawiera pełne wartości domyślne. Pliki `configs/<host>.php`
nadpisują wybrane klucze przez `array_replace_recursive` — wystarczy podać zmieniane pola.

### 4.2 Connection

`core/Connection.php` — singleton PDO z logieniem sterownika:

```
MySQL  → MySqlDriver  → DSN: "mysql:host=…;dbname=…;charset=utf8mb4"
PgSQL  → PgSqlDriver  → DSN: "pgsql:host=…;dbname=…"
SQLite → SqliteDriver → DSN: "sqlite:<ścieżka>"
```

Każdy driver implementuje `Driver` interface: `dsn(array $cfg): string` + `options(): array`.
PDO jest tworzony jednorazowo per żądanie; `Connection::reset()` reinicjuje (na potrzeby testów).

### 4.3 Logger

`core/Log/Logger.php` — ustrukturyzowany rejestrator wzorowany na NLog (C#):

- **Kanały:** `Logger::get('Auth')`, `Logger::get('Gallery')`, `Logger::get('System')` — każdy log
  niesie nazwę kanału w kolumnie `LogLogger`.
- **Poziomy** (rosnąco): `TRACE < DEBUG < INFO < WARN < ERROR < FATAL`. Próg filtrowania
  z klucza `log_level` w konfiguracji.
- **Zapis do bazy:** tabela `<tenant>_logs`, INSERT per-zdarzenie. Przy błędzie zapisu
  fallback do `var/logs/app.log`, ostatecznie do `error_log()` PHP.
- **Kontekst:** każdy rekord zawiera IP, User-Agent, URI, ID użytkownika (`LogUserID`),
  PID, wersję aplikacji, callsite (klasa/metoda/linia).

```php
Logger::get('Gallery')->info('Przesłano zdjęcie', properties: ['gallery_id' => $id, 'bytes' => $size]);
Logger::get('System')->warn('Backup bez sygnatury .sha256', properties: ['file' => $f]);
Logger::get('Auth')->warn('Nieudana próba logowania', properties: ['login' => $login, 'ip' => $ip]);
```

### 4.4 System migracji

Oparty na `doctrine/migrations`. Klucze:

- **`TenantMigration`** — abstrakcyjna klasa bazowa; dostarcza `table(string $name): string`
  wstrzykujące prefix tenanta (`def_navigation`, `kl1_navigation`).
- **`TenantMigrationFactory`** — tworzy instancje migracji i wstrzykuje prefix przez
  `setTenantPrefix()` przed każdym wywołaniem.
- **Komponent:** każdy komponent (`appdb`, `cms`, `shop`) ma osobny katalog migracji
  i osobną tabelę śledzącą (`<tenant>_migrations_appdb`).

```php
// Typowa migracja
final class Version20260524100000 extends TenantMigration {
    public function up(Schema $schema): void {
        $this->addSql("ALTER TABLE `{$this->table('gallery_photos')}` ADD COLUMN …");
    }
}
```

---

## 5. Warstwa aplikacji (app/)

### Modele tabel (app/Appdb/Models/)

Każdy model to podklasa `Core\Models\TableModel` opisująca schemat jednej tabeli:
kolumny (`Column`), indeksy (`Index`), metody `createTableSql(string $prefix)` i
`dropTableSql(string $prefix)`.

| Model | Tabela | Prefix kolumn |
|---|---|---|
| `UsersModel` | `<t>_users` | `Use` |
| `GroupsModel` | `<t>_groups` | `Grp` |
| `DomainsModel` | `<t>_domains` | `Dom` |
| `NavigationModel` | `<t>_navigation` | `Nav` |
| `NavigationMenusModel` | `<t>_navigation_menus` | `NavMenu` |
| `NavigationHistoryModel` | `<t>_navigation_history` | `NavHist` |
| `GalleriesModel` | `<t>_galleries` | `Gal` |
| `GalleryPhotosModel` | `<t>_gallery_photos` | `GalPhoto` |
| `GalleryCategoriesModel` | `<t>_gallery_categories` | `GalCat` |
| `GalleryTagsModel` | `<t>_gallery_tags` | `GalTag` |
| `GalleryCatRelModel` | `<t>_gallery_cat_rel` | `GalCatRel` |
| `GalleryTagRelModel` | `<t>_gallery_tag_rel` | `GalTagRel` |
| `LogsModel` | `<t>_logs` | `Log` |

---

## 6. Panel administracyjny (admin/)

### 6.1 Punkt wejścia i routing

`admin/index.php` pełni rolę front-controllera:

1. Bootstrap (autoload, Config, Connection, Logger)
2. Konfiguracja ciasteczka sesji i `session_start()`
3. Weryfikacja sekretnego kodu URL (`admin_code`)
4. Emisja nagłówków bezpieczeństwa HTTP
5. `require admcore.php`
6. Idle-timeout sesji (3 h)
7. Weryfikacja CSRF dla każdego POST
8. Akcje: `logout`, `login` (z honeypot + rate limit + autentykacja)
9. Routing podstron (`$page` → `$pageFile[$page]`) + kontrola uprawnień
10. `require pages/<sekcja>/adm<strona>.php` (backend)
11. `require admlayout.view.php` (render HTML)

Mapa routingu:

| `?page=` | Plik backendu | Tytuł |
|---|---|---|
| `dashboard` | `pages/desktop/dashboard/admpulpit` | Pulpit |
| `gallery` | `pages/gallery/admgallery` | Galeria |
| `permissions` | `pages/settings/permissions/admuprawnienia` | Uprawnienia |
| `groups` | `pages/settings/groups/admgrupy` | Grupy |
| `domains` | `pages/settings/domains/admdomeny` | Domeny |
| `navigation` | `pages/navigation/menu/admmenu` | Menu nawigacyjne |
| `system` | `pages/system/diagnostics/admsystem` | System |
| `events` | `pages/system/events/admevent` | Zdarzenia |
| `backup` | `pages/system/backup/admbackup` | Kopia zapasowa |

### 6.2 admcore.php — wspólne funkcje

Jeden plik z wszystkimi funkcjami globalnymi panelu (~3500 linii), dołączany przez `index.php`:

| Grupa funkcji | Przykładowe funkcje |
|---|---|
| CSRF | `csrfToken()`, `csrfVerify()` |
| Rate limiting | `loginIsBlocked()`, `loginRecordFailure()`, `loginClearFailures()` |
| Autentykacja | `authenticate()`, `findActiveUser()`, `touchLastLogin()` |
| Użytkownicy | `listUsers()`, `createUser()`, `updateUser()`, `deleteUser()`, `changePassword()` |
| Grupy | `listGroups()`, `assignGroup()` |
| Domeny | `listDomains()`, `createDomain()`, `updateDomain()`, `deleteDomain()` |
| Snapshoty historii | `saveNavigationSnapshot()`, `saveUsersSnapshot()`, `saveDomainsSnapshot()` |
| Nawigacja | `listNavigationItems()`, `createNavigationItem()`, `renderNavigationTree()`, `moveNavigationItem()` |
| Zestawy menu | `listNavigationMenus()`, `createNavigationMenu()`, `getOrCreateDefaultMenu()` |
| Galerie | `listGalleries()`, `createGallery()`, `updateGallery()`, `deleteGallery()` |
| Zdjęcia | `listGalleryPhotos()`, `uploadGalleryPhoto()`, `reorderGalleryPhotos()`, `setGalleryCover()` |
| Kosz zdjęć | `listGalleryTrash()`, `deleteGalleryPhoto()`, `restoreGalleryPhoto()`, `permanentDeleteGalleryPhoto()`, `emptyGalleryTrash()` |
| Kategorie/Tagi | `listGalleryCategories()`, `createGalleryCategory()`, `listGalleryTags()`, `setGalleryCategories()` |
| Backup | `listBackupFiles()`, `detectArchiver()`, `createMediaArchive()`, `backupSign()`, `backupVerify()` |
| Dziennik | `listEvents()`, `countEvents()`, `eventsFilterClause()` |
| Notices | `adminNotice(string $key): ?array` |
| Narzędzia | `uuidv4()`, `galleryScaleImage()`, `galleryMakeThumbnail()` |

### 6.3 Cykl żądania GET (zalogowany użytkownik)

```
Przeglądarka GET ?page=gallery&gallery=<GalID>
      │
      ▼
index.php
  ├── session_start() + cookie params
  ├── weryfikacja admin_code → 404 jeśli błędny
  ├── emisja nagłówków HTTP
  ├── require admcore.php
  ├── idle-timeout check
  ├── kontrola uprawnień ($canManageAccess)
  └── require pages/gallery/admgallery.php          ← backend
          ├── odczyt $galleryId, $domain
          ├── listGalleries(), listGalleryPhotos(), listGalleryTrash()
          ├── ustawia $pageView, $pageTitle
          └── (brak POST → brak redirect)
      └── require admlayout.view.php                ← render
              ├── <html><head>…</head><body>
              ├── sidebar z listą domen
              ├── topbar (tytuł + breadcrumb)
              ├── require pages/gallery/admgallery.view.php
              └── </body></html>
```

### 6.4 Cykl żądania POST (PRG)

```
Przeglądarka POST _action=upload_photo (multipart, AJAX)
      │
      ▼
index.php
  └── csrfVerify() → 403 jeśli błędny token
      └── require admgallery.php
              ├── move_uploaded_file() do /tmp
              ├── uploadGalleryPhoto($galleryId, $tmpPath, $origName, $domain)
              │     ├── walidacja MIME (JPEG / PNG / GIF / WEBP)
              │     ├── galleryScaleImage() → media/originals/<host>/<uuid>.jpg
              │     ├── galleryMakeThumbnail() → media/cache/<host>/<uuid>_thumb.jpg
              │     └── INSERT cascade (z fallbackiem na brakujące kolumny)
              └── JSON { "ok": true, "photo": {...} }  ← AJAX (nie PRG)

Przeglądarka POST _action=trash_photo (formularz)
      │
      └── deleteGalleryPhoto($photoId, $domain)   ← SET GalPhotoDeletedAt = NOW()
          └── header('Location: …?un=photo_trashed')
              └── exit                             ← REDIRECT
```

### 6.5 System powiadomień (adminNotice)

Centralna mapa klucz → komunikat. Funkcja `adminNotice(string $key): ?array` zwraca
`['type' => 'success|warning|danger', 'msg' => '…']` lub `null`.

Widoki odczytują go przez `$_GET['un']` po przekierowaniu PRG:

```php
$userNotice = adminNotice($_GET['un'] ?? '');  // w pliku .view.php
```

Kody notice (wybrane):

| Klucz | Typ | Wiadomość |
|---|---|---|
| `gallery_created` | success | Galeria została utworzona |
| `photo_trashed` | warning | Zdjęcie przeniesione do kosza |
| `photo_restored` | success | Zdjęcie przywrócone |
| `photo_perm_deleted` | success | Zdjęcie trwale usunięte |
| `trash_emptied` | success | Kosz galerii opróżniony |
| `backup_created` | success | Kopia zapasowa utworzona |
| `backup_restored` | success | Baza danych przywrócona z kopii |
| `err_db` | danger | Błąd bazy danych |

---

## 7. Galeria i media

### 7.1 Schemat bazy danych

Galeria jest zaimplementowana na 6 tabelach tenant-prefixed, tworzonych leniwie przez
`ensureGalleryTables()`:

```
<t>_galleries            ← nagłówki galerii (nazwa, opis, status, okładka)
<t>_gallery_photos       ← zdjęcia (plik, oryg. nazwa, hash SHA-256, tytuł, sort, soft-delete)
<t>_gallery_categories   ← kategorie per-domena
<t>_gallery_tags         ← tagi per-domena
<t>_gallery_cat_rel      ← relacja galeria ↔ kategoria (N:M)
<t>_gallery_tag_rel      ← relacja galeria ↔ tag (N:M)
```

Kluczowe kolumny `<t>_gallery_photos`:

```sql
GalPhotoFilename    VARCHAR(190)      -- UUID.jpg — nazwa pliku na dysku
GalPhotoOrigName    VARCHAR(255) NULL -- oryginalna nazwa przy uploadzie
GalPhotoHash        VARCHAR(64) NULL  -- SHA-256 do deduplikacji plików
GalPhotoSort        INT DEFAULT 0     -- pozycja drag & drop
GalPhotoDeletedAt   DATETIME NULL     -- NULL = aktywne, NOT NULL = w koszu
```

### 7.2 Pliki mediów

```
media/
  originals/<tenant-host>/
      <uuid>.jpg          ← oryginalny plik (skalowany do max 1920 px)
  cache/<tenant-host>/
      <uuid>.jpg          ← podgląd (max 1200×900)
      <uuid>_thumb.jpg    ← miniatura kwadratowa (200×200 crop)
```

Katalogi `originals/` i `cache/` nie są wersjonowane w git (`.gitignore` wewnątrz
każdego katalogu: `* / !.gitignore / !.gitkeep`).

### 7.3 Wzorzec soft-delete (kosz)

Zdjęcia usunięte przez użytkownika nie są od razu kasowane z bazy ani dysku:

```
"Usuń" (przycisk)  →  GalPhotoDeletedAt = NOW()   pliki zachowane
"Przywróć"         →  GalPhotoDeletedAt = NULL     nic nie zmienione
"Usuń na stałe"    →  DELETE + unlink()            pliki usunięte*
"Opróżnij kosz"    →  DELETE batch + unlink()      pliki usunięte*
```

\* Plik usuwany z dysku tylko gdy `countGalleryPhotoRefs(filename) <= 1`
(ochrona przed usunięciem współdzielonych plików przy deduplikacji).

`listGalleryPhotos()` filtruje `WHERE GalPhotoDeletedAt IS NULL`.
`listGalleryTrash()` filtruje `WHERE GalPhotoDeletedAt IS NOT NULL`.

### 7.4 Wzorzec cascade INSERT

Upload wstawia rekord wariantami od bogatego do minimalnego, łapiąc `Unknown column`
z PDOException — odporność na instalacje bez wszystkich migracji:

```php
$variants = [
    [$sqlWithHashAndOrigName, $paramsWithBoth],   // w/ GalPhotoHash + GalPhotoOrigName
    [$sqlWithOrigNameOnly,    $paramsWithOrig],   // w/ GalPhotoOrigName
    [$sqlMinimal,             $paramsMinimal],    // tylko kolumny podstawowe
];
foreach ($variants as [$sql, $params]) {
    try { $pdo->prepare($sql)->execute($params); $inserted = true; break; }
    catch (\PDOException $e) {
        if (!str_contains($e->getMessage(), 'Unknown column')) { break; }
    }
}
```

### 7.5 Obróbka obrazów (PHP GD)

```
galleryScaleImage($src, $dst, maxW=1920, maxH=1920)
  → skaluje zachowując proporcje, zapisuje JPEG quality 88

galleryMakeThumbnail($src, $dst, size=200)
  → crop do kwadratu (środek), zapisuje JPEG quality 80

Obsługiwane formaty wejściowe: JPEG · PNG · GIF · WEBP
Wyjście zawsze: JPEG
```

---

## 8. System kopii zapasowych

### 8.1 Tryby kopii

| Typ (`backup_type`) | Format | Zawartość |
|---|---|---|
| `db` | `.sql` lub `.sql.enc` | Dump SQL wszystkich tabel |
| `full` | `.zip` lub `.tar.gz` | `database.sql` + `media/originals/` + `media/cache/` |
| `media` | `.zip` lub `.tar.gz` | Tylko `media/originals/` + `media/cache/` |

### 8.2 Wykrywanie metody archiwizacji

```
detectArchiver() → 'zip' | 'tar_gz' | 'none'

Priorytet:
  1. ZipArchive  (ext-zip)   → pliki .zip  — standardowe rozszerzenie PHP
  2. PharData    (ext-phar)  → pliki .tar.gz — wbudowane w PHP core (fallback)
  3. brak                    → archiwa mediów niedostępne (tylko SQL)
```

PharData jest dostępny na praktycznie każdym hostingu (wbudowany w PHP), więc
tryby `full` i `media` działają nawet bez `ext-zip`.

### 8.3 Konwencja nazw plików

```
var/backups/
  backup_<STAMP>_mysql.sql               ← dump MySQL
  backup_<STAMP>_sqlite.sql              ← dump SQLite
  backup_<STAMP>_mysql.sql.enc           ← zaszyfrowany dump (AES-256-CBC)
  backup_<STAMP>_mysql_full.zip          ← pełna kopia ZIP
  backup_<STAMP>_mysql_full.tar.gz       ← pełna kopia TAR.GZ (fallback)
  backup_<STAMP>_media.zip               ← tylko media ZIP
  backup_<STAMP>_media.tar.gz            ← tylko media TAR.GZ (fallback)
  backup_<STAMP>_*.sha256                ← sygnatura integralności (sidecar)
```

`STAMP` = `Y-m-d_H-i-s` np. `2026-05-24_14-30-00`.

### 8.4 Integralność i szyfrowanie

**SHA-256 sidecar (`.sha256`):**
- Tworzony po każdym backupie przez `backupSign()`
- Format: `<hex-hash>  <basename>\n` (zgodny z `sha256sum`)
- Weryfikowany przez `backupVerify()` przed przywróceniem (blokujące) i pobieraniem (ostrzeżenie)

**AES-256-CBC (`.sql.enc`):**
- Aktywowany kluczem `backup_encryption_key = 'base64:<32B-key>'` w konfiguracji
- Format pliku: `[4B magic "K2BC"][16B IV][zaszyfrowane dane]`
- Dotyczy wyłącznie kopii SQL — archiwa ZIP/TAR.GZ nie są szyfrowane

**Pliki backupów nie są wersjonowane** — katalog `var/backups/` ma `.gitignore`
z regułą `* / !.gitignore / !.gitkeep`.

### 8.5 Archiwizacja katalogów (addDirToZip / addDirToPhar)

Obie funkcje używają iteratywnego stosu `scandir()` zamiast `RecursiveIteratorIterator`
— niezawodne na Windows (brak konfliktów uchwytów SPL + ZipArchive):

```php
$stack = [realpath($dir)];
while (!empty($stack)) {
    $current = array_pop($stack);
    foreach (@scandir($current) as $entry) {
        if ($entry === '.' || $entry === '..') continue;
        $fullPath = $current . DIRECTORY_SEPARATOR . $entry;
        $zipPath  = $zipPrefix . '/' . str_replace('\\', '/', substr($fullPath, $dirLen + 1));
        if (is_dir($fullPath)) { $zip->addEmptyDir($zipPath); $stack[] = $fullPath; }
        else                   { $zip->addFile($fullPath, $zipPath); }
    }
}
```

---

## 9. Wzorzec multi-tenant

### Konfiguracja per-tenant

```php
// configs/_default.php (baza)
return ['tenant' => ['prefix' => 'def'], 'admin_code' => 'panel1', …];

// configs/klient1.local.php (nadpisanie)
return ['tenant' => ['prefix' => 'kl1'], 'admin_code' => 'tajnyKod42', …];
```

`Config::load($_SERVER['HTTP_HOST'])` łączy oba przez `array_replace_recursive`.

### Nazwy tabel

```
prefix = Config::get('tenant')['prefix']   // np. "def"

def_users               def_groups              def_domains
def_navigation          def_navigation_menus    def_navigation_history
def_galleries           def_gallery_photos      def_gallery_categories
def_gallery_tags        def_gallery_cat_rel     def_gallery_tag_rel
def_logs                def_login_attempts
def_migrations_appdb
```

### Konwencja kolumn tabel

Każda tabela aplikacyjna zawiera trzy kolumny bazowe:

| Kolumna | Typ | Rola |
|---|---|---|
| `<C>ID` | `CHAR(36) NOT NULL` | PRIMARY KEY (GUID v4, generowany w PHP) |
| `<C>DateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | data utworzenia |
| `<C>IDAuto` | `INT UNSIGNED AUTO_INCREMENT UNIQUE` | sortowanie wstawiania |

`<C>` to 3–5 znakowy prefiks kolumnowy (PascalCase), unikalny per tabela.

---

## 10. Bezpieczeństwo

Panel administracyjny K2 CMS implementuje **wielowarstwową ochronę** — każda warstwa
działa niezależnie; kompromitacja jednej nie obala pozostałych.

```
┌─────────────────────────────────────────────────────────┐
│  Atakujący                                              │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│  10.1  Sekretny adres URL   (admin_code nie jest znany) │
└──────┬──────────────────────────────────────────────────┘
       │ adres znany
       ▼
┌─────────────────────────────────────────────────────────┐
│  10.7  Honeypot             (bot wypełnia ukryte pole)  │
└──────┬──────────────────────────────────────────────────┘
       │ człowiek
       ▼
┌─────────────────────────────────────────────────────────┐
│  10.5  Rate limiting        (max 10 prób / 15 min)      │
└──────┬──────────────────────────────────────────────────┘
       │ w limicie
       ▼
┌─────────────────────────────────────────────────────────┐
│  10.2  Uwierzytelnianie     (password_verify bcrypt)    │
└──────┬──────────────────────────────────────────────────┘
       │ zalogowany
       ▼
┌─────────────────────────────────────────────────────────┐
│  10.3  Ochrona sesji        (fixation, idle-timeout)    │
│  10.4  CSRF                 (synchronizer token)        │
│  10.8  Autoryzacja          (role, canManageAccess)     │
│  10.6  Nagłówki HTTP        (CSP, HSTS, X-Frame…)       │
└─────────────────────────────────────────────────────────┘
```

Każde zdarzenie bezpieczeństwa trafia do **10.9 Rejestratora** (`Logger`, kanał `Auth`).

---

### 10.1 Sekretny adres URL panelu

Panel działa wyłącznie pod `/admin/{admin_code}/`. Każda inna ścieżka zwraca **404 bez wskazówki**.
`hash_equals()` eliminuje timing attack przy porównaniu kodu.

> **Zalecenie:** `admin_code` min. 20 losowych znaków (`openssl rand -base64 18`).

---

### 10.2 Uwierzytelnianie

- Hasła przechowywane jako **bcrypt hash** (`password_hash(..., PASSWORD_DEFAULT)`).
- Weryfikacja przez `password_verify()` — odporność na timing attack wbudowana.
- Flaga `UseIsActive` — konto dezaktywowane nie może się zalogować.
- `touchLastLogin()` — aktualizuje `UseLastLogin` po udanym logowaniu (audyt).

**Konto bootstrap `admin`:**

| Warunek | Działanie |
|---|---|
| `<tenant>_users` pusta | Konto `admin` / `admin{rok}` działa; przy pierwszym logowaniu zakładane w bazie |
| `<tenant>_users` niepusta | Konto serwisowe wyłączone; działa tylko BD |

---

### 10.3 Ochrona sesji

**Session Fixation:** `session_regenerate_id(true)` wywołane przed zapisem `$_SESSION['admin']`.

**Idle-timeout (3 h):** Każde żądanie odświeża `$_SESSION['admin_last_activity']`.

**Bezpieczne ciasteczko:**
```php
session_set_cookie_params([
    'lifetime' => 0, 'path' => '/admin/…/',
    'secure' => true, 'httponly' => true, 'samesite' => 'Strict',
]);
ini_set('session.use_strict_mode', '1');
```

---

### 10.4 Ochrona CSRF

Synchronizer Token Pattern — token 64-znakowy hex generowany per-sesja.

```php
function csrfToken(): string { /* $_SESSION['csrf_token'] = bin2hex(random_bytes(32)); */ }
```

Każdy formularz POST: `<?= csrfToken() ?>` (generuje `<input type="hidden" name="_csrf">`).
Weryfikacja przez `hash_equals()`. Niezgodność logowana i odrzucana z HTTP 403.

---

### 10.5 Rate limiting logowania

Tabela `<tenant>_login_attempts`. Bucket = SHA-256(REMOTE_ADDR).
Okno: 15 minut. Limit: 10 prób. Fail-open: brak tabeli → blokada wyłączona.

---

### 10.6 Nagłówki HTTP bezpieczeństwa

| Nagłówek | Wartość |
|---|---|
| `X-Frame-Options` | `DENY` |
| `X-Content-Type-Options` | `nosniff` |
| `Referrer-Policy` | `strict-origin-when-cross-origin` |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=()` |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` (tylko HTTPS) |
| `Content-Security-Policy` | `default-src 'self'; script-src 'self' 'unsafe-inline'; …; frame-ancestors 'none'` |

---

### 10.7 Honeypot

Ukryte pole `.a11y-offscreen` (CSS `position: absolute; left: -9999px`) w formularzu
logowania. Boty je wypełniają → blokada bez wyczerpania budżetu rate limitera.

---

### 10.8 Kontrola dostępu (autoryzacja)

Sekcje wrażliwe (`permissions`, `groups`, `domains`, `backup`) wymagają `canManageAccess`:

```php
$canManageAccess = $adminUser === 'admin'
    || (string)($currentUser['UseGroupID'] ?? '') === GroupsModel::ADMIN_GROUP_ID;
```

---

### 10.9 Rejestrowanie zdarzeń bezpieczeństwa

| Zdarzenie | Poziom | Kanał |
|---|---|---|
| Udane logowanie | INFO | Auth |
| Nieudane logowanie | WARN | Auth |
| Honeypot wypełniony | WARN | Auth |
| Rate limit — blokada | WARN | Auth |
| CSRF mismatch | WARN | Auth |
| Sesja wygasła / brak | INFO/WARN | Auth |
| Dostęp bez uprawnień | WARN | Auth |
| Wylogowanie | INFO | Auth |
| Błąd tworzenia backupu | ERROR | System |
| Przywrócenie backupu | INFO | System |
| Naruszenie integralności backupu | ERROR | System |

---

*Dokumentacja generowana ręcznie — źródłem prawdy jest kod.*  
*Plik: `docs/architektura/architektura.md` · Wersja aplikacji: 0.8.0*
