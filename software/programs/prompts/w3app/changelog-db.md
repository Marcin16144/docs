# Changelog — struktury baz danych

Dziennik wyłącznie zmian strukturalnych w bazach danych: tabele, indeksy, kolumny, klucze, dane seed.

Format: pozycje grupowane per **komponent**, w obrębie komponentu — chronologicznie. Każdy wpis referuje konkretny plik migracji (`Version<YYYYMMDDHHMMSS>.php`), który jest źródłem prawdy dla SQL-a.

Zasady ogólne (pełna konwencja: [docs/bazy-danych.md §3.11](bazy-danych.md#311-konwencja-nazewnictwa-tabel-i-kolumn)):
- `ENGINE=InnoDB`, `CHARSET=utf8mb4`, `COLLATE=utf8mb4_unicode_ci`.
- Nazwa tabeli: `<tenant_prefix>_<entity>` (np. `def_users`, `kl1_pages`). Prefix w runtime z `configs/<host>.php` → `tenant.prefix`.
- **Bazowa struktura każdej tabeli** (kolumny obowiązkowe):
  - `<C>ID` `CHAR(36) NOT NULL` → `PRIMARY KEY` (GUID generowany w aplikacji)
  - `<C>DateTime` `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP`
  - `<C>IDAuto` `INT UNSIGNED AUTO_INCREMENT` → `UNIQUE KEY uniq_<table>_idauto`
- Prefix kolumnowy `<C>`: 3–5 znaków, PascalCase, per tabela (np. `Use` dla `users`, `Pag` dla `pages`).
- Identyfikatory kluczy: `PRIMARY KEY` (`<C>ID`), `UNIQUE KEY uniq_<table>_<purpose>`, `INDEX idx_<table>_<purpose>`, `FOREIGN KEY fk_<table>_<column>`. Nazwa indeksu zawiera pełną nazwę tabeli z prefiksem tenant.
- Brak `created_at` / `updated_at` — `<C>DateTime` zastępuje `created_at`; modyfikacje przez `<C>Modified DATETIME NULL ON UPDATE CURRENT_TIMESTAMP` jeśli potrzebne.

## Tabele systemowe migratora

Tworzone automatycznie przez `doctrine/migrations` przy pierwszym uruchomieniu — **nie** mają własnych plików migracji.

| Tabela | Komponent | Zawartość |
|---|---|---|
| `<tenant>_migrations_appdb` | appdb | Wersje migracji wykonane dla komponentu Application Main (`version`, `executed_at`, `execution_time`) |
| `<tenant>_migrations_cms` | cms | jw. dla komponentu CMS |
| `<tenant>_migrations_shop` | shop | jw. dla komponentu shop |
| `<tenant>_migrations_<slug>` | (każdy nowy komponent) | jw. dla dowolnego komponentu wykrytego przez `ComponentDiscovery` |

`<tenant>` = wartość `tenant.prefix` z configu (np. `def`, `kl1`).

---

## Komponent: appdb (Application Main — baza)

Migracje: [app/Appdb/Migrations/](../app/Appdb/Migrations/) · Tabela śledząca: `<tenant>_migrations_appdb`

Bazowy moduł obecny w **każdym** projekcie zbudowanym na tym silniku — niezależnie od tego, czy projekt zawiera CMS, sklep, czy jest aplikacją czysto narzędziową.

### [Version20260513130000](../app/Appdb/Migrations/Version20260513130000.php) — 2026-05-13

**Dodano: tabela `<tenant>_users`** (np. `def_users`) — bazowa autentykacja panelu administracyjnego. Prefix kolumn: `Use`.

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `UseID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID generowany w aplikacji |
| `UseDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | znacznik utworzenia |
| `UseIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY uniq_<tenant>_users_idauto` |
| `UseLogin` | `VARCHAR(64) NOT NULL` | `UNIQUE KEY uniq_<tenant>_users_login` |
| `UsePassword` | `VARCHAR(255) NOT NULL` | hash (`password_hash()` z `PASSWORD_BCRYPT` lub `PASSWORD_ARGON2ID`) |
| `UseEmail` | `VARCHAR(190) NULL` | `UNIQUE KEY uniq_<tenant>_users_email` — limit 190 dla utf8mb4 |
| `UseIsActive` | `TINYINT(1) NOT NULL DEFAULT 1` | miękkie wyłączenie konta bez kasowania rekordu |
| `UseLastLogin` | `DATETIME NULL` | aktualizowane przez warstwę aplikacji przy poprawnym loginie |

Rollback: `DROP TABLE <tenant>_users`.

**Seed**: brak w samej migracji. Pierwsze konto `admin` zakłada **automatycznie panel administracyjny** przy pierwszym logowaniu, gdy tabela jest pusta — hasło `admin` + bieżący rok (np. `admin2026`), zapisane jako hash. Kolejne konta tworzy się w panelu (Ustawienia → Uprawnienia). Szczegóły: [docs/panel-admin.md](panel-admin.md).

### [Version20260513140000](../app/Appdb/Migrations/Version20260513140000.php) — 2026-05-13

**Dodano: tabela `<tenant>_logs`** (np. `def_logs`) — strukturalny log aplikacji w stylu **NLog** (C#). Prefix kolumn: `Log`. Model: [LogsModel.php](../app/Appdb/Models/LogsModel.php).

Treść logu (NLog standard):

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `LogID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `LogDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | timestamp logu |
| `LogIDAuto` | `INT UNSIGNED AUTO_INCREMENT` | `UNIQUE KEY uniq_<tenant>_logs_idauto` |
| `LogLevel` | `VARCHAR(10) NOT NULL` | `INDEX idx_<tenant>_logs_level` — TRACE/DEBUG/INFO/WARN/ERROR/FATAL |
| `LogLogger` | `VARCHAR(190) NULL` | `INDEX idx_<tenant>_logs_logger` — źródło/kanał logu |
| `LogMessage` | `TEXT NOT NULL` | treść wiadomości |
| `LogException` | `MEDIUMTEXT NULL` | pełny stack trace wyjątku |

Callsite — gdzie nastąpił log/błąd (analog NLog `${callsite}`):

| Kolumna | Typ | Uwagi |
|---|---|---|
| `LogClass` | `VARCHAR(190) NULL` | FQCN klasy |
| `LogMethod` | `VARCHAR(190) NULL` | nazwa metody/funkcji |
| `LogLineNumber` | `INT UNSIGNED NULL` | numer wiersza w pliku źródłowym |
| `LogFile` | `VARCHAR(255) NULL` | ścieżka pliku |

Kontekst strukturalny i HTTP:

| Kolumna | Typ | Uwagi |
|---|---|---|
| `LogProperties` | `JSON NULL` | strukturalny słownik dodatkowy (NLog `${event-properties}`) |
| `LogHostName` | `VARCHAR(190) NULL` | `gethostname()` |
| `LogProcessId` | `INT UNSIGNED NULL` | `getmypid()` |
| `LogRequestUri` | `VARCHAR(500) NULL` | URI requestu HTTP |
| `LogIpAddress` | `VARCHAR(45) NULL` | IPv4 lub IPv6 |
| `LogUserAgent` | `VARCHAR(500) NULL` | nagłówek User-Agent |
| `LogUserID` | `CHAR(36) NULL` | `INDEX idx_<tenant>_logs_user` — referencja do `<tenant>_users.UseID` (kto wywołał) |

Indeks compound: `INDEX idx_<tenant>_logs_level_datetime (LogLevel, LogDateTime)` — przyspiesza zapytania typu *"błędy z ostatniej godziny"*.

Rollback: `DROP TABLE <tenant>_logs`.

**Jak wypełniać callsite** — `debug_backtrace()` w handlerze loggera:
```php
$trace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 2)[1] ?? [];
$row = [
    'LogClass'      => $trace['class']    ?? null,
    'LogMethod'     => $trace['function'] ?? null,
    'LogLineNumber' => $trace['line']     ?? null,
    'LogFile'       => $trace['file']     ?? null,
];
```
Dla wyjątków: `$throwable->getLine()` / `getFile()` dają miejsce *rzucenia*; `debug_backtrace` w loggerze — miejsce *zalogowania*. Często warto wpisać oba (line/file z exception, class/method z trace).

### [Version20260513150000](../app/Appdb/Migrations/Version20260513150000.php) — 2026-05-13

**ALTER tabeli `<tenant>_logs`** — dodanie kolumny `LogAppVersion` (wersja aplikacji w momencie logu).

| Operacja | SQL |
|---|---|
| ADD COLUMN | `LogAppVersion VARCHAR(20) NULL AFTER LogProcessId` |
| ADD INDEX | `INDEX idx_<tenant>_logs_appversion (LogAppVersion)` |

Wartość wypełniana przez warstwę aplikacji z [Core\Version::current()](../core/Version.php) (stała `'2026.05'`, format `YYYY.MM`). Indeks pozwala szybko filtrować logi per wersja deployu.

Synchronizacja z modelem [LogsModel.php](../app/Appdb/Models/LogsModel.php) — świeże wdrożenia dostają kolumnę natywnie w `CREATE TABLE` (nie potrzebują tej migracji ALTER).

Rollback: `DROP INDEX idx_<tenant>_logs_appversion` + `DROP COLUMN LogAppVersion`.

### [Version20260522120000](../app/Appdb/Migrations/Version20260522120000.php) — 2026-05-22

**Dodano: tabela `<tenant>_groups`** (np. `def_groups`) — grupy uprawnień (role) kont panelu. Prefix kolumn: `Gru`. Model: [GroupsModel.php](../app/Appdb/Models/GroupsModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GruID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `GruDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | znacznik utworzenia |
| `GruIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY uniq_<tenant>_groups_idauto` |
| `GruName` | `VARCHAR(64) NOT NULL` | `UNIQUE KEY uniq_<tenant>_groups_name` |
| `GruDescription` | `VARCHAR(255) NULL` | opis grupy |

**Seed**: dwie grupy domyślne o stałych GUID-ach (stałe `GroupsModel::ADMIN_GROUP_ID` / `USER_GROUP_ID`): `Administrator` (pełny dostęp do panelu) oraz `Użytkownik` (konto standardowe).

Rollback: `DROP TABLE <tenant>_groups`.

### [Version20260522120100](../app/Appdb/Migrations/Version20260522120100.php) — 2026-05-22

**ALTER tabeli `<tenant>_users`** — dodanie kolumny `UseGroupID` (grupa uprawnień konta).

| Operacja | SQL |
|---|---|
| ADD COLUMN | `UseGroupID CHAR(36) NULL AFTER UseIsActive` |
| ADD INDEX | `INDEX idx_<tenant>_users_group (UseGroupID)` |

`UseGroupID` to referencja do `<tenant>_groups.GruID` (indeks, bez twardego `FOREIGN KEY` — wzorzec jak `LogUserID`). ALTER wykonywany **warunkowo** (tylko gdy kolumny brak) — świeże wdrożenie tworzy ją natywnie z modelu `UsersModel`. Dodatkowo: istniejące konto `admin` zostaje przypisane do grupy Administrator (`UPDATE`).

Rollback: `DROP INDEX idx_<tenant>_users_group` + `DROP COLUMN UseGroupID`.

### [Version20260522130000](../app/Appdb/Migrations/Version20260522130000.php) — 2026-05-22

**Dodano: tabela `<tenant>_domains`** (np. `def_domains`) — definicje stron internetowych zarządzanych z poziomu CMS-a. Prefix kolumn: `Dom`. Model: [DomainsModel.php](../app/Appdb/Models/DomainsModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `DomID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `DomDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | znacznik utworzenia |
| `DomIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY uniq_<tenant>_domains_idauto` |
| `DomProtocol` | `VARCHAR(8) NOT NULL` | `http` lub `https` |
| `DomName` | `VARCHAR(190) NOT NULL` | `UNIQUE KEY uniq_<tenant>_domains_name` — nazwa domeny |
| `DomCmsName` | `VARCHAR(190) NOT NULL` | nazwa wyświetlana w CMS (pusta przy zapisie → kopiowana z `DomName`) |
| `DomConfig` | `VARCHAR(64) NULL` | nazwa pliku z `configs/` (bez `.php`) |

Rollback: `DROP TABLE <tenant>_domains`.

### [Version20260523120000](../app/Appdb/Migrations/Version20260523120000.php) — 2026-05-23

**Dodano: tabela `<tenant>_navigation`** (np. `def_navigation`) — drzewo menu nawigacyjnego dla witryn zarządzanych w CMS-ie. Każda pozycja należy do jednej domeny (`NavDomID`) i opcjonalnie do nadrzędnego folderu (`NavParentID`); kolejność wewnątrz rodzica steruje `NavSort`. Prefix kolumn: `Nav`. Model: [NavigationModel.php](../app/Appdb/Models/NavigationModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `NavID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `NavDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | znacznik utworzenia |
| `NavIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY uniq_<tenant>_navigation_idauto` |
| `NavDomID` | `CHAR(36) NOT NULL` | `INDEX idx_<tenant>_navigation_domain` — referencja do `<tenant>_domains.DomID` |
| `NavParentID` | `CHAR(36) NULL` | `INDEX idx_<tenant>_navigation_parent` — self-FK; NULL = najwyższy poziom |
| `NavSort` | `INT NOT NULL DEFAULT 0` | kolejność wewnątrz rodzica |
| `NavType` | `VARCHAR(16) NOT NULL DEFAULT 'page'` | `folder` (kontener) lub `page` (liść) |
| `NavTitle` | `VARCHAR(190) NOT NULL` | nazwa wyświetlana w menu |
| `NavPath` | `VARCHAR(190) NULL` | ścieżka URL (typowo dla pozycji-liści) |

Kaskada przez aplikację (brak FK w DB): usunięcie domeny w `deleteDomain()` najpierw kasuje wszystkie wpisy `<tenant>_navigation` o pasującym `NavDomID`. Usunięcie folderu w `deleteNavigationItem()` rekurencyjnie zbiera potomków (BFS) i kasuje całe poddrzewo jednym `DELETE … IN (…)`.

Rollback: `DROP TABLE <tenant>_navigation`.

### [Version20260523130000](../app/Appdb/Migrations/Version20260523130000.php) — 2026-05-23

**ALTER tabeli `<tenant>_navigation`** — dodanie kolumn edycji i SEO pozycji menu. Synchronizuje bazę z modelem `NavigationModel`; ALTER wykonywany warunkowo (kolumna po kolumnie przez `information_schema.COLUMNS`) — świeże wdrożenia dostają te kolumny natywnie z `CREATE TABLE`.

| Operacja | Kolumna | Typ / Wartość domyślna |
|---|---|---|
| ADD COLUMN | `NavIsActive` | `TINYINT(1) NOT NULL DEFAULT 1` — flaga aktywności pozycji |
| ADD COLUMN | `NavSeoTitle` | `VARCHAR(190) NULL` — tytuł SEO / og:title |
| ADD COLUMN | `NavSeoDescription` | `TEXT NULL` — meta description |
| ADD COLUMN | `NavSeoKeywords` | `VARCHAR(255) NULL` — meta keywords |

Rollback: `DROP COLUMN IF EXISTS` dla każdej z kolumn (w odwrotnej kolejności).

### [Version20260523140000](../app/Appdb/Migrations/Version20260523140000.php) — 2026-05-23

**Dodano: tabela `<tenant>_navigation_history`** (np. `def_navigation_history`) — automatyczne snapshoty stanu drzewa menu przed każdą operacją modyfikującą. Prefix kolumn: `NavHist`. Model: [NavigationHistoryModel.php](../app/Appdb/Models/NavigationHistoryModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `NavHistID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `NavHistDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | znacznik utworzenia snapshotu |
| `NavHistIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY uniq_<tenant>_navigation_history_idauto` |
| `NavHistDomID` | `CHAR(36) NOT NULL` | `INDEX idx_<tenant>_navigation_history_domain` — referencja do `<tenant>_domains.DomID` |
| `NavHistLabel` | `VARCHAR(255) NULL` | opis snapshotu (np. „Przed dodaniem: Kontakt") |
| `NavHistItems` | `MEDIUMTEXT NOT NULL` | JSON — płaska lista pozycji menu w chwili zapisu |

Rollback: `DROP TABLE <tenant>_navigation_history`.

### [Version20260523150000](../app/Appdb/Migrations/Version20260523150000.php) — 2026-05-23

**Dodano: tabela `<tenant>_navigation_menus`** (np. `def_navigation_menus`) — zestawy menu nawigacyjnego per-strona. Każda strona może mieć wiele niezależnych drzew menu; każdy zestaw ma unikalny kod menu per-strona używany przez front-end do identyfikacji menu. Prefix kolumn: `NavMenu`. Model: [NavigationMenusModel.php](../app/Appdb/Models/NavigationMenusModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `NavMenuID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `NavMenuDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | znacznik utworzenia |
| `NavMenuIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY uniq_<tenant>_navigation_menus_idauto` |
| `NavMenuDomID` | `CHAR(36) NOT NULL` | `INDEX idx_<tenant>_navigation_menus_domain` — referencja do `<tenant>_domains.DomID` |
| `NavMenuName` | `VARCHAR(190) NOT NULL` | nazwa wyświetlana w panelu (np. „Menu główne") |
| `NavMenuSlug` | `VARCHAR(64) NOT NULL` | identyfikator dla front-endu (np. `main`, `footer`) |
| `NavMenuSort` | `INT NOT NULL DEFAULT 0` | kolejność na liście zestawów |

Rollback: `DROP TABLE <tenant>_navigation_menus`.

### [Version20260523160000](../app/Appdb/Migrations/Version20260523160000.php) — 2026-05-23

**ALTER tabeli `<tenant>_navigation`** — dodanie kolumny `NavMenuID` (przynależność pozycji do zestawu menu). Kolumna nullable — istniejące pozycje przypisywane są do domyślnego zestawu przez funkcję `getOrCreateDefaultMenu()` przy pierwszym wejściu w obszar nawigacyjny. ALTER warunkowo (sprawdzanie `information_schema.COLUMNS`).

| Operacja | SQL |
|---|---|
| ADD COLUMN | `NavMenuID CHAR(36) NULL AFTER NavDomID` |
| ADD INDEX | `INDEX idx_<tenant>_navigation_menu (NavMenuID)` |

Rollback: `DROP KEY IF EXISTS idx_<tenant>_navigation_menu` + `DROP COLUMN IF EXISTS NavMenuID`.

### [Version20260523170000](../app/Appdb/Migrations/Version20260523170000.php) — 2026-05-23

**ALTER tabeli `<tenant>_navigation_history`** — dodanie kolumny `NavHistMenuID`. Historia migawkowa jest teraz scopowana per-zestaw menu (nie per-domena), co umożliwia niezależne snapshoty dla każdego zestawu. `NavHistDomID` pozostaje jako informacja kontekstowa. ALTER warunkowo (sprawdzanie `information_schema.COLUMNS`).

| Operacja | SQL |
|---|---|
| ADD COLUMN | `NavHistMenuID CHAR(36) NULL AFTER NavHistDomID` |
| ADD INDEX | `INDEX idx_<tenant>_navigation_history_menu (NavHistMenuID)` |

Rollback: `DROP KEY IF EXISTS idx_<tenant>_navigation_history_menu` + `DROP COLUMN IF EXISTS NavHistMenuID`.

### [Version20260523180000](../app/Appdb/Migrations/Version20260523180000.php) — 2026-05-23

**CREATE TABLE `<tenant>_login_attempts`** — rate limiting logowania. Tabela operacyjna (nie encja biznesowa): brak GUID PK, brak kolumn `<C>DateTime` / `<C>IDAuto`. Bucket = SHA-256 adresu IP — surowy IP nie jest przechowywany. Warunkowo tworzony (`information_schema.TABLES`).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `LaBucket` | `VARCHAR(64) NOT NULL` | `PRIMARY KEY` — SHA-256(IP), 64 znaki hex |
| `LaCount` | `INT UNSIGNED NOT NULL DEFAULT 1` | Licznik prób w bieżącym oknie |
| `LaFirstAt` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | Czas początku okna |

Semantyka: `INSERT … ON DUPLICATE KEY UPDATE LaCount = LaCount + 1`. Okno 900 s (15 min) liczone od `LaFirstAt`. Limit 10 prób. Rollback: `DROP TABLE IF EXISTS <tenant>_login_attempts`.

### [Version20260523190000](../app/Appdb/Migrations/Version20260523190000.php) — 2026-05-23

**Dodano: tabela `<tenant>_galleries`** — galerie zdjęć per-domena. Prefix kolumn: `Gal`. Model: [GalleriesModel.php](../app/Appdb/Models/GalleriesModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `GalDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | znacznik utworzenia |
| `GalIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY` |
| `GalDomID` | `CHAR(36) NOT NULL` | `INDEX idx_..._domain` — referencja do `<tenant>_domains.DomID` |
| `GalName` | `VARCHAR(190) NOT NULL` | nazwa galerii wyświetlana w panelu |
| `GalDescription` | `TEXT NULL` | opcjonalny opis galerii |
| `GalCoverPhotoID` | `CHAR(36) NULL` | GUID zdjęcia okładkowego (nullable) |
| `GalSort` | `INT NOT NULL DEFAULT 0` | kolejność na liście galerii |
| `GalStatus` | `VARCHAR(20) NOT NULL DEFAULT 'active'` | `active` / `hidden` |

Rollback: `DROP TABLE <tenant>_galleries`.

### [Version20260523200000](../app/Appdb/Migrations/Version20260523200000.php) — 2026-05-23

**Dodano: tabela `<tenant>_gallery_categories`** — kategorie galerii per-domena. Prefix kolumn: `GalCat`. Model: [GalleryCategoriesModel.php](../app/Appdb/Models/GalleryCategoriesModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalCatID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `GalCatDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | |
| `GalCatIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY` |
| `GalCatDomID` | `CHAR(36) NOT NULL` | `INDEX idx_..._domain` |
| `GalCatName` | `VARCHAR(190) NOT NULL` | nazwa kategorii |
| `GalCatSlug` | `VARCHAR(64) NOT NULL` | identyfikator URL kategorii |
| `GalCatSort` | `INT NOT NULL DEFAULT 0` | kolejność |

Rollback: `DROP TABLE <tenant>_gallery_categories`.

### [Version20260523210000](../app/Appdb/Migrations/Version20260523210000.php) — 2026-05-23

**Dodano: tabela `<tenant>_gallery_tags`** — tagi galerii per-domena. Prefix kolumn: `GalTag`. Model: [GalleryTagsModel.php](../app/Appdb/Models/GalleryTagsModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalTagID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `GalTagDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | |
| `GalTagIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY` |
| `GalTagDomID` | `CHAR(36) NOT NULL` | `INDEX idx_..._domain` |
| `GalTagName` | `VARCHAR(190) NOT NULL` | nazwa tagu |
| `GalTagSlug` | `VARCHAR(64) NOT NULL` | identyfikator URL tagu |

Rollback: `DROP TABLE <tenant>_gallery_tags`.

### [Version20260523220000](../app/Appdb/Migrations/Version20260523220000.php) — 2026-05-23

**Dodano: tabela `<tenant>_gallery_photos`** — zdjęcia w galeriach. Prefix kolumn: `GalPhoto`. Model: [GalleryPhotosModel.php](../app/Appdb/Models/GalleryPhotosModel.php).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalPhotoID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `GalPhotoDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | |
| `GalPhotoIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY` |
| `GalPhotoGalID` | `CHAR(36) NOT NULL` | `INDEX idx_..._gallery` — referencja do `<tenant>_galleries.GalID` |
| `GalPhotoFilename` | `VARCHAR(255) NOT NULL` | nazwa pliku (UUID + rozszerzenie) |
| `GalPhotoTitle` | `VARCHAR(190) NULL` | opcjonalny tytuł zdjęcia |
| `GalPhotoAlt` | `VARCHAR(190) NULL` | tekst alternatywny (SEO/a11y) |
| `GalPhotoWidth` | `INT UNSIGNED NULL` | szerokość po zapisaniu (px) |
| `GalPhotoHeight` | `INT UNSIGNED NULL` | wysokość po zapisaniu (px) |
| `GalPhotoSize` | `BIGINT UNSIGNED NULL` | rozmiar pliku (bajty) |
| `GalPhotoMime` | `VARCHAR(64) NOT NULL DEFAULT 'image/jpeg'` | typ MIME |
| `GalPhotoSort` | `INT NOT NULL DEFAULT 0` | kolejność w galerii |

Rollback: `DROP TABLE <tenant>_gallery_photos`.

### [Version20260523230000](../app/Appdb/Migrations/Version20260523230000.php) — 2026-05-23

**Dodano: tabela `<tenant>_gallery_cat_rel`** — relacja M:N galeria ↔ kategoria. Prefix kolumn: `GalCatRel`. Model: [GalleryCatRelModel.php](../app/Appdb/Models/GalleryCatRelModel.php). Tabela pivot — brak standardowych kolumn `ID / DateTime / IDAuto`; klucz główny kompozytowy.

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalCatRelGalID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` (część kompozytowa) |
| `GalCatRelCatID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` (część kompozytowa) |

Rollback: `DROP TABLE <tenant>_gallery_cat_rel`.

### [Version20260523240000](../app/Appdb/Migrations/Version20260523240000.php) — 2026-05-23

**Dodano: tabela `<tenant>_gallery_tag_rel`** — relacja M:N galeria ↔ tag. Prefix kolumn: `GalTagRel`. Model: [GalleryTagRelModel.php](../app/Appdb/Models/GalleryTagRelModel.php). Tabela pivot — klucz główny kompozytowy.

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalTagRelGalID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` (część kompozytowa) |
| `GalTagRelTagID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` (część kompozytowa) |

Rollback: `DROP TABLE <tenant>_gallery_tag_rel`.

### [Version20260523250000](../app/Appdb/Migrations/Version20260523250000.php) — 2026-05-23

**Zmieniono: tabela `<tenant>_gallery_photos`** — dodano kolumnę `GalPhotoOrigName`.

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalPhotoOrigName` | `VARCHAR(255) NULL DEFAULT NULL` | oryginalna nazwa pliku przesłanego przez użytkownika (np. `wakacje_01.jpg`) |

Rollback: `ALTER TABLE <tenant>_gallery_photos DROP COLUMN GalPhotoOrigName`.

### [Version20260523260000](../app/Appdb/Migrations/Version20260523260000.php) — 2026-05-24

**Zmieniono: tabela `<tenant>_gallery_photos`** — dodano kolumnę `GalPhotoHash` (deduplikacja plików).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalPhotoHash` | `VARCHAR(64) NULL DEFAULT NULL` | suma SHA-256 pliku oryginalnego; `INDEX idx_<tenant>_galphotos_hash`; ta sama wartość → ten sam plik fizyczny na dysku — rekord jest tworzony, plik nie jest kopiowany ponownie |

Rollback: `ALTER TABLE <tenant>_gallery_photos DROP INDEX idx_<tenant>_galphotos_hash, DROP COLUMN GalPhotoHash`.

### [Version20260524100000](../app/Appdb/Migrations/Version20260524100000.php) — 2026-05-24

**Zmieniono: tabela `<tenant>_gallery_photos`** — dodano kolumnę `GalPhotoDeletedAt` (kosz / soft-delete).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GalPhotoDeletedAt` | `DATETIME NULL DEFAULT NULL` | `NULL` = zdjęcie aktywne; `!NULL` = zdjęcie w koszu; `INDEX idx_<tenant>_galphotos_deleted`; plik fizyczny pozostaje do momentu trwałego usunięcia przez `permanentDeleteGalleryPhoto()` lub `emptyGalleryTrash()` |

Rollback: `ALTER TABLE <tenant>_gallery_photos DROP INDEX idx_<tenant>_galphotos_deleted, DROP COLUMN GalPhotoDeletedAt`.

---

## Komponent: cms

Migracje: [app/Cms/Migrations/](../app/Cms/Migrations/) · Tabela śledząca: `migrations_cms`

### [Version20260513120000](../app/Cms/Migrations/Version20260513120000.php) — 2026-05-13

**Dodano: tabela `<tenant>_pages`** (np. `def_pages`) — podstawowy magazyn stron CMS. Prefix kolumn: `Pag`.

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `PagID` | `CHAR(36) NOT NULL` | `PRIMARY KEY` — GUID |
| `PagDateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | znacznik utworzenia |
| `PagIDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | `UNIQUE KEY uniq_<tenant>_pages_idauto` |
| `PagSlug` | `VARCHAR(190) NOT NULL` | `UNIQUE KEY uniq_<tenant>_pages_slug` — limit 190 dla utf8mb4 (max indeks 767 B) |
| `PagTitle` | `VARCHAR(255) NOT NULL` | tytuł strony |
| `PagBody` | `MEDIUMTEXT NULL` | treść strony, dopuszczalna `NULL` |

Rollback: `DROP TABLE <tenant>_pages`.

---

## Komponent: shop

Migracje: [app/Shop/Migrations/](../app/Shop/Migrations/) · Tabela śledząca: `migrations_shop`

Brak migracji — komponent zarejestrowany przez istnienie katalogu, gotowy na pierwszy schemat.

---

## Komponent: settings/ai (Integracje AI — core)

Schemat tworzony przez [aiEnsureSchema()](../admin/pages/settings/ai/ai_lib.php) — idempotentny `CREATE TABLE IF NOT EXISTS` przy pierwszym wejściu na *Ustawienia → Integracje AI*. Tabele nie używają konwencji `<C>ID` GUID + `<C>DateTime` jak komponenty appdb/cms — są pluginowe (single-row config, klucz `INT AUTO_INCREMENT`).

### [aiEnsureSchema](../admin/pages/settings/ai/ai_lib.php) — 2026-05-26

**Dodano: tabela `<tenant>_api_claude`** (np. `def_api_claude`) — konfiguracja Claude / Anthropic API. Prefix kolumn: `Caf`. Single-row (`CafID=1`).

**Dodano: tabela `<tenant>_api_ollama`** — konfiguracja serwera Ollama. Prefix kolumn: `Oll`. **WIELO-wierszowa** (od 2026-05-29) — każdy wiersz = osobna instancja Ollamy (różne komputery w sieci); `OllID=1` to instancja podstawowa (odtwarzana przez `aiEnsureSchema`). Kolumna **`OllLabel` VARCHAR(64)** (migracja idempotentna) = etykieta instancji. Pozostałe kolumny per instancja: `OllServerUrl`, `OllDefaultModel`, `OllTemperature`, `OllNumPredict`, `OllTimeout`, `OllSystemPrompt`, `OllLastTest*`.

**Dodano: tabela `<tenant>_api_groq`** — konfiguracja Groq API (OpenAI-compatible). Prefix kolumn: `Grq`. Single-row.

### [aiEnsureSchema — 2026-05-27](../admin/pages/settings/ai/ai_lib.php) — Brave Search

**Dodano: tabela `<tenant>_api_brave`** (np. `def_api_brave`) — Brave Search API jako search-provider (NIE LLM). Używana jako fallback dla DuckDuckGo w Console AI. Single-row (`BraID=1`). Prefix kolumn: `Bra`.

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `BraID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `BraApiKey` | `VARCHAR(255) NOT NULL DEFAULT ''` | klucz z brave.com/search/api |
| `BraLastTestAt` | `DATETIME NULL` | timestamp ostatniego *Testuj połączenie* |
| `BraLastTestOk` | `TINYINT(1) NOT NULL DEFAULT 0` | wynik ostatniego testu |
| `BraLastTestMessage` | `TEXT NULL` | komunikat ostatniego testu |
| `BraLastTestResults` | `INT UNSIGNED NOT NULL DEFAULT 0` | liczba wyników w teście |
| `BraUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | auto-update przy modyfikacji |

### [aiEnsureSchema migracja max_tokens](../admin/pages/settings/ai/ai_lib.php) — 2026-05-27

`UPDATE def_api_claude SET CafMaxTokens=4096 WHERE CafMaxTokens=1024` (i analogicznie dla Groq) — bump domyślnego limitu generowanej odpowiedzi, fix obciętych długich odpowiedzi. Tylko gdy wartość była na starym defaulcie 1024.

### [aiEnsureSchema — 2026-05-30 — v0.7.24](../admin/pages/settings/ai/ai_lib.php) — Search chain ordering

**Dodano: tabela `<tenant>_api_search_chain`** (np. `def_api_search_chain`) — multi-row
(jeden wiersz per provider), sterująca kolejnością i aktywnością providerów w chain'ie
`tcWebSearch`. Seedowana 7 wierszami przy pierwszym wejściu (wszystkie aktywne, kolejność:
tavily → scrapegraph → searxng_selfhosted → ddg_html → ddg_lite → searxng_public → brave).

| Kolumna | Typ | Uwagi |
|---|---|---|
| `ScnProvider` | `VARCHAR(32)` | `PRIMARY KEY` — klucz providera (`tavily`, `scrapegraph`, `searxng_selfhosted`, `ddg_html`, `ddg_lite`, `searxng_public`, `brave`) |
| `ScnSortOrder` | `INT NOT NULL DEFAULT 0` | pozycja w chain'ie (rosnąco) |
| `ScnActive` | `TINYINT(1) NOT NULL DEFAULT 1` | 0 = pomijany w chain'ie, ale konfiguracja zostaje |
| `ScnUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | |

Konfiguracja przez *Ustawienia → Integracje Search → zakładka „Kolejność"* (handler
`ai_search_chain_save`, redirect z `#tab-chain`).

### [aiEnsureSchema — 2026-05-30 — v0.7.23](../admin/pages/settings/ai/ai_lib.php) — ScrapeGraphAI

**Dodano: tabela `<tenant>_api_scrapegraph`** (np. `def_api_scrapegraph`) — konfiguracja
search-providera ScrapeGraphAI (klucz `sgai-…` z scrapegraphai.com). Single-row.

| Kolumna | Typ | Uwagi |
|---|---|---|
| `SgaID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `SgaApiKey` | `VARCHAR(255) NOT NULL DEFAULT ''` | klucz `sgai-…` |
| `SgaLastTestAt` | `DATETIME NULL` | |
| `SgaLastTestOk` | `TINYINT(1) NOT NULL DEFAULT 0` | |
| `SgaLastTestMessage` | `TEXT NULL` | |
| `SgaLastTestResults` | `INT UNSIGNED NOT NULL DEFAULT 0` | liczba reference URL-i z testu |
| `SgaUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | |

### [aiEnsureSchema — 2026-05-30 — v0.7.22](../admin/pages/settings/ai/ai_lib.php) — Tavily + SearxNG self-hosted

**Dodano dwie tabele** dla search-providerów (NIE LLM): `<tenant>_api_tavily` i `<tenant>_api_searxng`.
Single-row, idempotentne.

#### `def_api_tavily`

| Kolumna | Typ | Uwagi |
|---|---|---|
| `TvlID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `TvlApiKey` | `VARCHAR(255) NOT NULL DEFAULT ''` | klucz `tvly-…` z tavily.com (bez karty, free 1k/mc) |
| `TvlLastTestAt` | `DATETIME NULL` | |
| `TvlLastTestOk` | `TINYINT(1) NOT NULL DEFAULT 0` | |
| `TvlLastTestMessage` | `TEXT NULL` | |
| `TvlLastTestResults` | `INT UNSIGNED NOT NULL DEFAULT 0` | liczba wyników z testu |
| `TvlUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | |

#### `def_api_searxng`

| Kolumna | Typ | Uwagi |
|---|---|---|
| `SrxID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `SrxBaseUrl` | `VARCHAR(500) NOT NULL DEFAULT ''` | URL własnej instancji (np. `http://localhost:8888`); puste = wyłączone |
| `SrxLastTestAt` | `DATETIME NULL` | |
| `SrxLastTestOk` | `TINYINT(1) NOT NULL DEFAULT 0` | |
| `SrxLastTestMessage` | `TEXT NULL` | |
| `SrxLastTestResults` | `INT UNSIGNED NOT NULL DEFAULT 0` | |
| `SrxUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | |

### [aiEnsureSchema — 2026-05-30](../admin/pages/settings/ai/ai_lib.php) — GitHub Models

**Dodano: tabela `<tenant>_api_github_models`** (np. `def_api_github_models`) — konfiguracja providera GitHub Models (Microsoft AI gateway, endpoint OpenAI-compatible `models.github.ai/inference`). Prefix kolumn: `Ghm`. Single-row (`GhmID=1`).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GhmID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `GhmApiKey` | `VARCHAR(255) NOT NULL DEFAULT ''` | GitHub PAT (`ghp_…` lub `github_pat_…`) scope `models:read` |
| `GhmModel` | `VARCHAR(96) NOT NULL DEFAULT 'openai/gpt-4o-mini'` | format `publisher/model` (np. `meta/Llama-3.3-70B-Instruct`) |
| `GhmTemperature` | `DECIMAL(3,2) NOT NULL DEFAULT 1.00` | 0–2 |
| `GhmMaxTokens` | `INT UNSIGNED NOT NULL DEFAULT 4096` | limit długości odpowiedzi (do 16384) |
| `GhmSystemPrompt` | `TEXT NULL` | opcjonalny system prompt |
| `GhmLastTestAt` | `DATETIME NULL` | timestamp ostatniego testu |
| `GhmLastTestOk` | `TINYINT(1) NOT NULL DEFAULT 0` | wynik ostatniego testu |
| `GhmLastTestMessage` | `TEXT NULL` | komunikat ostatniego testu |
| `GhmLastTestTokens` | `INT UNSIGNED NOT NULL DEFAULT 0` | tokeny zużyte w teście |
| `GhmLastTestModels` | `TEXT NULL` | JSON listy modeli z `/catalog/models` |
| `GhmUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | auto-update przy modyfikacji |

### [aiEnsureSchema — 2026-05-29](../admin/pages/settings/ai/ai_lib.php) — Google Gemini

**Dodano: tabela `<tenant>_api_gemini`** (np. `def_api_gemini`) — konfiguracja Google Gemini (AI Studio, endpoint OpenAI-compatible). Prefix kolumn: `Gem`. Single-row (`GemID=1`).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GemID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `GemApiKey` | `VARCHAR(255) NOT NULL DEFAULT ''` | klucz `AIza…` z aistudio.google.com/apikey |
| `GemModel` | `VARCHAR(64) NOT NULL DEFAULT 'gemini-2.0-flash'` | domyślny model |
| `GemTemperature` | `DECIMAL(3,2) NOT NULL DEFAULT 1.00` | 0–2 |
| `GemMaxTokens` | `INT UNSIGNED NOT NULL DEFAULT 4096` | limit długości odpowiedzi |
| `GemSystemPrompt` | `TEXT NULL` | opcjonalny system prompt |
| `GemLastTestAt` | `DATETIME NULL` | timestamp ostatniego testu |
| `GemLastTestOk` | `TINYINT(1) NOT NULL DEFAULT 0` | wynik ostatniego testu |
| `GemLastTestMessage` | `TEXT NULL` | komunikat ostatniego testu |
| `GemLastTestTokens` | `INT UNSIGNED NOT NULL DEFAULT 0` | tokeny zużyte w teście |
| `GemLastTestModels` | `TEXT NULL` | JSON listy modeli z `/models` (po odsianiu nie-czatowych) |
| `GemUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | auto-update przy modyfikacji |

---

## Komponent: consoleai/terminal (Console AI — Terminal)

### [Schema 2026-05-30 — v0.7.21](../admin/pages/consoleai/terminal/admterminal.php) — Live progress dla sub-agentów

**Dodano: tabela `<tenant>_console_progress`** (np. `def_console_progress`) — single row per
`(UserId, SessionId)` przechowujący live stan tury i interaktywnej pauzy planu. Tworzona
idempotentnie przy każdym wejściu do terminala (`CREATE TABLE IF NOT EXISTS`).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `CprgUserId` | `VARCHAR(64) NOT NULL` | część PK |
| `CprgSessionId` | `VARCHAR(64) NOT NULL` | część PK |
| `CprgStatus` | `ENUM('idle','running','done','error') NOT NULL DEFAULT 'idle'` | stan tury |
| `CprgProvider` | `VARCHAR(32) NOT NULL DEFAULT ''` | aktywny provider główny |
| `CprgModel` | `VARCHAR(128) NOT NULL DEFAULT ''` | aktywny model główny |
| `CprgStartedAt` | `DATETIME NULL` | timestamp startu tury (do elapsed) |
| `CprgFinishedAt` | `DATETIME NULL` | timestamp końca; gdy NULL → tura w toku |
| `CprgUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | |
| `CprgJson` | `MEDIUMTEXT NULL` | live state: `goal`, `helper`, `sub_tasks[]`, `awaiting_user_decision`, `user_decision` |
| PRIMARY KEY | `(CprgUserId, CprgSessionId)` | UPSERT pattern |

**Format `CprgJson`:**
```json
{
  "goal": "...",
  "helper": {"provider": "ollama", "model": "qwen3-coder:30b"},
  "total": 8,
  "sub_tasks": [
    {"index": 1, "total": 8, "task": "...", "status": "done", "started": 1234, "elapsed": 12, "reply": "..."},
    {"index": 2, "total": 8, "task": "...", "status": "running", "started": 1246},
    {"index": 3, "total": 8, "task": "...", "status": "pending"}
  ],
  "awaiting_user_decision": {                ← obecne TYLKO gdy backend czeka na decyzję
    "failed_step": 1, "total": 8, "remaining": 7, "since": 1234567890,
    "task": "...", "verdict": "PORAŻKA: ..."
  },
  "user_decision": "continue"                 ← wpisywane przez JS, czytane przez backend
}
```

**Use cases:**
- Polling endpoint `console_ai_progress` czyta stan co 1.5s (UI renderuje live indicator).
- `decompose_and_execute` zapisuje `awaiting_user_decision` przy porażce kroku i poll'uje pole `user_decision` co 1s przez 120s — modal w UI wpisuje decyzję przez `console_ai_plan_decision`.
- Brak indeksów poza PK — single row per sesja, brak query patterns wymagających skanowania.

### [Schema 2026-05-30](../admin/pages/consoleai/terminal/admterminal.php) — Słownik wstawek prompta

**Dodano: tabela `<tenant>_console_prompt_snippets`** (np. `def_console_prompt_snippets`) — biblioteka haseł dla modala „Wstaw prompt" w terminalu. Tworzona idempotentnie + seed 22 wpisów (CREATE TABLE IF NOT EXISTS + sprawdzenie pustości).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `SnpID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `SnpGroup` | `VARCHAR(64) NOT NULL DEFAULT 'Ogólne'` | kategoria; grupowanie w UI |
| `SnpLabel` | `VARCHAR(120) NOT NULL` | etykieta na chipie |
| `SnpText` | `TEXT NOT NULL` | treść doklejana u góry promptu (max 4096 znaków w warstwie aplikacyjnej) |
| `SnpActive` | `TINYINT(1) NOT NULL DEFAULT 1` | 0 = ukryte w modalu terminala, ale zostaje w edytorze |
| `SnpSortOrder` | `INT NOT NULL DEFAULT 0` | porządek w obrębie grupy |
| `SnpCreatedAt` | `DATETIME` | |
| `SnpUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | |
| index | `idx_group_sort (SnpGroup, SnpSortOrder, SnpID)` | szybkie wczytywanie pogrupowane |
| index | `idx_active (SnpActive)` | filtr aktywnych |

Edycja w *Ustawienia → Integracje AI → Wstawki prompta*. Handlery AJAX: `ai_prompt_snippets_save` (insert/update), `_delete`, `_toggle`.

### [prompt_manager.php — 2026-06-03 — v0.7.50](../admin/pages/settings/ai/prompt_manager.php) — Menedżer promptów (grupy + historia)

Wspólny moduł zarządzania promptami (Ustawienia + Terminal). Tabele tworzone
idempotentnie przez `consolePromptEnsureSchema()` (CREATE gdy brak + migracja), wołane
z [admterminal.php](../admin/pages/consoleai/terminal/admterminal.php) oraz
[admai.php](../admin/pages/settings/ai/admai.php). Pluginowe (`INT AUTO_INCREMENT`, bez konwencji GUID).

**Dodano: tabela `<tenant>_console_prompt_groups`** (prefix `Grp`) — grupy haseł: kolejność, aktywność, stan zwinięcia. Migracja seed: po jednym wierszu na każdą istniejącą `DISTINCT SnpGroup`.

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `GrpID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `GrpName` | `VARCHAR(64) NOT NULL` | `UNIQUE KEY uniq_name`; równe `SnpGroup` |
| `GrpSortOrder` | `INT NOT NULL DEFAULT 0` | kolejność grup (drag&drop) |
| `GrpActive` | `TINYINT(1) NOT NULL DEFAULT 1` | 0 = cała grupa ukryta w modalu terminala |
| `GrpCollapsed` | `TINYINT(1) NOT NULL DEFAULT 0` | domyślny stan zwinięcia (zapamiętany) |
| `GrpCreatedAt` / `GrpUpdatedAt` | `DATETIME` | `GrpUpdatedAt` ON UPDATE CURRENT_TIMESTAMP |
| index | `idx_sort (GrpSortOrder, GrpID)` | |

**Dodano: tabela `<tenant>_console_prompt_history`** (prefix `Cph`) — audyt zmian haseł i grup.

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `CphID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `CphEntity` | `ENUM('snippet','group') NOT NULL` | czego dotyczy |
| `CphRefId` | `INT UNSIGNED NULL` | SnpID/GrpID (NULL po delete / dla reorder) |
| `CphAction` | `VARCHAR(32) NOT NULL` | insert/update/delete/toggle/reorder/rename/group_* |
| `CphLabel` | `VARCHAR(160) NULL` | czytelny opis |
| `CphBefore` / `CphAfter` | `TEXT NULL` | snapshot JSON przed/po |
| `CphUser` | `VARCHAR(64) NOT NULL DEFAULT ''` | login operatora (`admin_user`) |
| `CphAt` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | `KEY idx_at (CphAt)` |
| index | `idx_entity (CphEntity, CphRefId)` | |

Handlery (wspólne, [prompt_manager_handlers.php](../admin/pages/settings/ai/prompt_manager_handlers.php)):
`ai_prompt_snippets_save|delete|toggle|reorder|list`, `ai_prompt_groups_save|delete|toggle|reorder|collapse`, `ai_prompt_history_list`.


Tabele tworzone idempotentnie przy wejściu na *Console AI → Terminal* ([admterminal.php](../admin/pages/consoleai/terminal/admterminal.php)) — sprawdzenie `information_schema` + `CREATE TABLE`. Pluginowe (bez konwencji GUID).

**`<tenant>_console_messages`** — wiadomości czatu (user/assistant), per `CmsUserId` + `CmsSessionId`. Prefix kolumn `Cms`. M.in.: `CmsRole`, `CmsContent` (MEDIUMTEXT), `CmsProvider`/`CmsModel`, `CmsTokensInput`/`CmsTokensOutput`, `CmsToolCalls` (JSON), `CmsImages` (JSON), `CmsCreatedAt`.

### [admterminal.php — 2026-05-29](../admin/pages/consoleai/terminal/admterminal.php) — preferencje terminala

**Dodano: tabela `<tenant>_console_prefs`** — trwałe preferencje terminala per użytkownik. Prefix `Cpr`. Obecnie przechowuje folder roboczy (wcześniej w `$_SESSION` → ginął po wylogowaniu).

| Kolumna | Typ | Klucz / Uwagi |
|---|---|---|
| `CprUserId` | `VARCHAR(64) NOT NULL` | `PRIMARY KEY` (id użytkownika panelu) |
| `CprWorkdir` | `VARCHAR(1000) NOT NULL DEFAULT ''` | folder roboczy (kanoniczna ścieżka); `''` = wyłączony |
| `CprUpdatedAt` | `DATETIME ON UPDATE CURRENT_TIMESTAMP` | auto-update przy modyfikacji |

---

## Komponent: ext/music (Wtyczka Muzyka)

Tabele tworzone idempotentnie przez [admin/ext/music/init.php](../admin/ext/music/init.php) przez `pluginEnsureTable()` / `pluginEnsureColumn()` przy każdym ładowaniu wtyczki. Tenant prefix → `<tenant>_m_<entity>` (np. `def_m_tracks`).

### Tabele istniejące (zarys)
- `<tenant>_m_tracks` — utwory (audio file, metadane, sync SoundCloud).
- `<tenant>_m_track_history` — historia zmian metadanych utworów.
- `<tenant>_m_api` — rejestr aktywnych integracji wtyczki.
- `<tenant>_m_api_soundcloud` — konfig SoundCloud OAuth + tokeny.
- `<tenant>_m_settings` — preferencje globalne wtyczki (single-row).
- `<tenant>_m_ai_history` — historia wywołań AI per utwór.

### [Wtyczka music — YouTube integration](../admin/ext/music/init.php) — 2026-05-27

**Dodano: tabela `<tenant>_m_api_youtube`** — single-row konfiguracja OAuth + tokeny YouTube Data API v3. Prefix kolumn: `Ytb`. Klucz `YtbID=1`.

| Kolumna | Typ | Uwagi |
|---|---|---|
| `YtbID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `YtbClientId` | `VARCHAR(255)` | Google Cloud Console OAuth Client ID |
| `YtbClientSecret` | `VARCHAR(512)` | client_secret |
| `YtbRedirectUri` | `VARCHAR(255)` | musi dokładnie zgadzać się z Google Cloud Console |
| `YtbAccessToken` | `TEXT NULL` | Bearer token (Google OAuth 2.0) |
| `YtbRefreshToken` | `TEXT NULL` | wygasa po 7 dniach w trybie Testing |
| `YtbTokenExpiresAt` | `DATETIME NULL` | aktualizowany przy refresh |
| `YtbChannelId` / `YtbChannelTitle` / `YtbHandle` | `VARCHAR` | metadane kanału z `/channels?mine=true` |
| `YtbAuthorizedAt` | `DATETIME NULL` | po initial OAuth |
| `YtbLastTestAt` / `YtbLastTestOk` / `YtbLastTestMessage` | — | wynik *Test: pobierz kanał* |
| `YtbOauthState` / `YtbOauthVerifier` / `YtbOauthStartedAt` | — | tymczasowy state OAuth (anti-replay, TTL 10 min) |
| `YtbLastAuthOk` / `YtbLastAuthMessage` / `YtbLastAuthAt` | — | komunikat z publicznego callbacka |

**Dodano: tabela `<tenant>_m_videos`** — lokalny cache filmów YouTube (offline-friendly). Prefix kolumn: `Vid`. Unique `VidYtId` (YouTube video ID, 11 znaków). Logika "merge przy konflikcie": pristine VidYt* zawsze nadpisywane wartościami z YT; edytowalne Vid* nadpisywane tylko gdy `VidHasPending=0`.

| Kolumna | Typ | Uwagi |
|---|---|---|
| `VidID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `VidYtId` | `VARCHAR(64)` | `UNIQUE KEY uq_yt_id` |
| `VidTitle` / `VidDescription` / `VidTags` | edytowalne lokalnie | przed push do YT |
| `VidCategoryId` / `VidDefaultLanguage` / `VidDefaultAudioLanguage` | edytowalne | — |
| `VidPrivacyStatus` / `VidThumbnail` / `VidPublishedAt` | read-only z YT | — |
| `VidViewCount` / `VidLikeCount` / `VidCommentCount` | `INT/BIGINT UNSIGNED` | statystyki, refreshed przy sync |
| `VidYtTitle` / `VidYtDescription` / `VidYtTags` / `VidYtCategoryId` | pristine YT values | do porównań |
| `VidYtSyncedAt` / `VidYtPushedAt` | `DATETIME NULL` | timestampy operacji |
| `VidHasPending` | `TINYINT(1)` | 1 = lokalne zmiany czekają na push |

Indeksy: `idx_pending (VidHasPending)`, `idx_published (VidPublishedAt)`.

**Dodano: tabela `<tenant>_m_video_history`** — historia zmian SEO per film. Prefix kolumn: `Vhs`. Każda zmiana edytowalnego pola = jeden wiersz.

| Kolumna | Typ | Uwagi |
|---|---|---|
| `VhsID` | `BIGINT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `VhsVidID` | `INT UNSIGNED` | FK do `def_m_videos.VidID` (logiczny, bez constraint) |
| `VhsField` | `VARCHAR(64)` | nazwa pola (title/description/tags/categoryId/…) |
| `VhsOldValue` / `VhsNewValue` | `MEDIUMTEXT NULL` | wartości przed/po |
| `VhsChangedAt` / `VhsChangedBy` | — | audit |
| `VhsSyncedToYtAt` | `DATETIME NULL` | NULL = pending, ustawiane przy successful push |
| `VhsSyncResult` | `VARCHAR(255)` | "OK" lub komunikat błędu |

Indeksy: `idx_vid (VhsVidID, VhsChangedAt)`, `idx_pending (VhsSyncedToYtAt, VhsVidID)`.

**Dodano: tabela `<tenant>_m_video_ai_history`** — historia wywołań AI per film YouTube. Identyczny model jak `<tenant>_m_ai_history`, ale klucz `VhiVideoId` = string YouTube ID zamiast lokalnego INT.

| Kolumna | Typ | Uwagi |
|---|---|---|
| `VhiID` | `BIGINT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `VhiVideoId` | `VARCHAR(64)` | YouTube ID (string) — niezależne od `def_m_videos.VidID` |
| `VhiProvider` / `VhiModel` / `VhiOperation` | — | konfig wywołania |
| `VhiSystemPrompt` / `VhiPrompt` / `VhiResponse` | TEXT | dane I/O AI |
| `VhiOk` / `VhiError` / `VhiUsageJson` | — | wynik + tokens |
| `VhiWasCustom` | `TINYINT(1)` | 1 jeśli user nadpisał template prompt |

Indeksy: `idx_vid_created (VhiVideoId, VhiCreatedAt DESC)`, `idx_op (VhiVideoId, VhiOperation, VhiCreatedAt DESC)`.

### [Wtyczka music — Mixcloud integration](../admin/ext/music/init.php) — 2026-05-28

**Dodano: tabela `<tenant>_m_api_mixcloud`** — single-row konfiguracja Mixcloud (Public API + OAuth). Prefix kolumn: `Mix`. Klucz `MixID=1`.

| Kolumna | Typ | Uwagi |
|---|---|---|
| `MixID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `MixClientId` / `MixClientSecret` | `VARCHAR(128)` | OAuth app (opcjonalne — Public API działa bez) |
| `MixAccessToken` | `VARCHAR(255)` | token OAuth (nie wygasa — brak refresh) |
| `MixUsername` | `VARCHAR(190)` | konto do sync cloudcastów |
| `MixEnabled` | `TINYINT(1)` | — |
| `MixRedirectUri` / `MixOauthState` / `MixOauthStartedAt` | — | OAuth flow (state NIE jest echo-wany przez Mixcloud → fallback na świeżość StartedAt) |
| `MixAuthorizedAt` / `MixLastAuthOk` / `MixLastAuthMessage` / `MixLastAuthAt` | — | wynik autoryzacji z publicznego callbacka |
| `MixLastTestAt` / `MixLastTestOk` / `MixLastTestMessage` / `MixLastTestResults` | — | wynik testu |

**Dodano: tabela `<tenant>_m_mixcloud_casts`** — import cloudcastów (mixów/audycji) z konta Mixcloud. Niezależne od `def_m_tracks`. Prefix kolumn: `Mcc`. Unique `MccKey`.

| Kolumna | Typ | Uwagi |
|---|---|---|
| `MccID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `MccKey` | `VARCHAR(255)` | `UNIQUE KEY uq_key` — klucz cloudcasta (`/user/slug/`) |
| `MccUrl` / `MccName` / `MccSlug` / `MccPicture` | `VARCHAR` | metadane |
| `MccPlayCount` / `MccFavoriteCount` / `MccCommentCount` / `MccListenerCount` / `MccRepostCount` | `INT UNSIGNED` | statystyki |
| `MccAudioLength` | `INT UNSIGNED` | sekundy |
| `MccTags` / `MccCreatedTime` | — | tagi (CSV), data publikacji na MC |
| `MccArchived` | `TINYINT(1)` | 1 = nieobecny w ostatnim sync (odwracalne) |
| `MccSyncedAt` / `MccCreatedAt` | `DATETIME` | — |

Indeks: `idx_plays (MccPlayCount)`.

**Dodano: kolumny w `<tenant>_m_tracks`** — upload na Mixcloud + osobne metadane per platforma.

| Kolumna | Typ | Uwagi |
|---|---|---|
| `TraMixKey` | `VARCHAR(255)` | klucz cloudcasta po uploadzie (`/user/slug/`) |
| `TraMixUrl` | `VARCHAR(500)` | URL na mixcloud.com |
| `TraMixUploadedAt` | `DATETIME NULL` | NULL = nie wysłany |
| `TraMixTitle` | `VARCHAR(255)` | tytuł Mixcloud (osobny od `TraTitle`) |
| `TraMixTags` | `VARCHAR(500)` | tagi Mixcloud (po przecinku, max 5 użyje MC) |
| `TraMixDescription` | `TEXT NULL` | opis Mixcloud (MC limituje do 1000 znaków) |

### [Wtyczka music — Audius integration](../admin/ext/music/init.php) — 2026-05-28

**Dodano: tabela `<tenant>_m_api_audius`** — single-row konfiguracja Audius (zdecentralizowane Public API, read-only). Prefix kolumn: `Aud`. Klucz `AudID=1`. Bez kluczy/OAuth — wymagany tylko `app_name`; host node ustalany przez discovery (`api.audius.co`).

| Kolumna | Typ | Uwagi |
|---|---|---|
| `AudID` | `INT UNSIGNED AUTO_INCREMENT` | `PRIMARY KEY` |
| `AudAppName` | `VARCHAR(128)` | identyfikator aplikacji (domyślnie `w3app_k2_music`) — wymagany przy każdym żądaniu |
| `AudHandle` | `VARCHAR(190)` | handle artysty (opcjonalnie, do testów/pobierania) |
| `AudEnabled` | `TINYINT(1)` | — |
| `AudLastTestAt` / `AudLastTestOk` / `AudLastTestMessage` / `AudLastTestResults` | — | wynik testu |
