# Prompt 070: Modele aplikacji (app/Appdb) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [060 Logger](060-logger.md) · Następny: [080 Panel — front controller](080-panel-front-controller.md) →

Buduje **kompletną warstwę modeli aplikacyjnych** `app/Appdb/Models/` (13 modeli + tabela operacyjna `login_attempts`) wraz z odpowiadającymi migracjami `app/Appdb/Migrations/`. Wymaga gotowego rdzenia: `Core\Models\TableModel`, `Core\Models\Column`, `Core\Models\Index` (z [040 Modele tabel](040-modele-tabel.md)) oraz `Core\Migrations\TenantMigration` (z [050 System migracji](050-system-migracji.md)). Każdy model deklaratywnie opisuje jedną tabelę tenant-prefixed; każda migracja jest cienka i woła wyłącznie `createTableSql()` / `dropTableSql()`.

## Jak używać
1. Upewnij się, że rdzeń modeli i migracji jest gotowy (prompty 040 i 050).
2. Skopiuj blok **PROMPT** poniżej do asystenta LLM.
3. Asystent wygeneruje hurtowo wszystkie 13 modeli + 13 migracji CREATE + migrację `login_attempts`.
4. Zapisz pliki w `app/Appdb/Models/` i `app/Appdb/Migrations/`.
5. Zweryfikuj: `php bin/migrate appdb migrations:status`, potem `php bin/migrate appdb migrations:migrate`.

---

## PROMPT
```
Jesteś generatorem warstwy DB silnika K2 CMS. Wygeneruj HURTOWO wszystkie modele
aplikacyjne komponentu „Appdb" oraz odpowiadające im migracje CREATE.

## KONTEKST PROJEKTU

- PHP 8.1+, doctrine/migrations 3.x, MySQL 8 (InnoDB, utf8mb4_unicode_ci).
- Wielodomenowość (multi-tenant): jedna instalacja, wiele domen. Każda tabela ma
  prefiks tenanta wstrzykiwany w runtime z konfiguracji `tenant.prefix` (np. `def`).
- Model rozszerza `Core\Models\TableModel`, używa fabryk `Core\Models\Column`
  i `Core\Models\Index`. Renderuje SQL przez `createTableSql(string $prefix)`
  i `dropTableSql(string $prefix)`.
- Migracja rozszerza `Core\Migrations\TenantMigration`; w `up()`/`down()` woła TYLKO
  `$this->addSql((new <Model>())->createTableSql($this->tenantPrefix()))` /
  `dropTableSql(...)`. Bez raw SQL (wyjątek: tabela operacyjna `login_attempts`).
- Komponent `appdb` ma własną tabelę śledzącą migracji `<tenant>_migrations_appdb`
  (generowana automatycznie przez runner — NIE tworzysz jej modelem ani migracją).

## ŚCIEŻKI

- Modele:   `app/Appdb/Models/<Entity>Model.php`     — namespace `App\Appdb\Models`
- Migracje: `app/Appdb/Migrations/Version<YYYYMMDDHHMMSS>.php` — namespace `App\Appdb\Migrations`

## KONWENCJA KOLUMN

Każda tabela biznesowa zaczyna od trzech kolumn bazowych (w tej kolejności):

  Column::guid('ID')->primaryKey()                       // <C>ID CHAR(36) — GUID v4 PK (generowany w PHP)
  Column::dateTime('DateTime')->default('CURRENT_TIMESTAMP')  // <C>DateTime — data utworzenia
  Column::autoInc('IDAuto')->uniqueKey('idauto')         // <C>IDAuto INT UNSIGNED AUTO_INCREMENT UNIQUE — kolejność wstawiania

`<C>` to 3–8 znakowy prefiks kolumnowy (PascalCase), unikalny per tabela. Kolumny
w modelu podaje się BEZ prefiksu (`'Login'`, `'Email'`) — prefiks dokleja `TableModel`.
VARCHAR z `uniqueKey()` ≤ 190 znaków (limit indeksu utf8mb4). Tabele pivot (M:N) NIE
mają kolumn bazowych — tylko złożony klucz główny z dwóch kolumn `guid(...)->primaryKey()`.

## MODYFIKATORY

  ->nullable() ->notNull() ->default(val|null) ->primaryKey()
  ->uniqueKey('label') ->indexKey('label') ->onUpdate('expr') ->comment('text')

Indeksy wielokolumnowe w `indexes()`: `Index::index('label', ['Col1','Col2'])`.

## SZABLON MODELU

<?php
declare(strict_types=1);
namespace App\Appdb\Models;
use Core\Models\Column;
use Core\Models\Index;
use Core\Models\TableModel;

final class <Entity>Model extends TableModel
{
    public function entity(): string       { return '<encja_snake>'; }
    public function columnPrefix(): string { return '<C>'; }
    public function columns(): array { return [ /* kolumny */ ]; }
    public function indexes(): array { return [ /* indeksy wielokolumnowe lub [] */ ]; }
}

## SZABLON MIGRACJI

<?php
declare(strict_types=1);
namespace App\Appdb\Migrations;
use App\Appdb\Models\<Entity>Model;
use Core\Migrations\TenantMigration;
use Doctrine\DBAL\Schema\Schema;

final class Version<TIMESTAMP> extends TenantMigration
{
    public function getDescription(): string
    {
        return 'Appdb: CREATE TABLE <encja_snake> (model: <Entity>Model)';
    }
    public function up(Schema $schema): void
    {
        $this->addSql((new <Entity>Model())->createTableSql($this->tenantPrefix()));
    }
    public function down(Schema $schema): void
    {
        $this->addSql((new <Entity>Model())->dropTableSql($this->tenantPrefix()));
    }
}

## KOMPLET TABEL DO WYGENEROWANIA

Wygeneruj WSZYSTKIE poniższe modele. Kolumny biznesowe (po trzech bazowych) wg specyfikacji.

1) UsersModel — encja `users`, prefiks `Use` — konta panelu administracyjnego
   Column::varchar('Login', 64)->uniqueKey('login')
   Column::varchar('Password', 255)                       // bcrypt hash
   Column::varchar('Email', 190)->nullable()->uniqueKey('email')
   Column::tinyInt('IsActive')->default(1)
   Column::guid('GroupID')->nullable()->indexKey('group') // FK → <t>_groups.GruID
   Column::dateTime('LastLogin')->nullable()

2) GroupsModel — encja `groups`, prefiks `Gru` — grupy uprawnień (role)
   Dodaj stałe GUID grup domyślnych jako publiczne const klasy:
     const ADMIN_GROUP_ID = 'a0000000-0000-4000-8000-000000000001';
     const USER_GROUP_ID  = 'a0000000-0000-4000-8000-000000000002';
   Column::varchar('Name', 64)->uniqueKey('name')
   Column::varchar('Description', 255)->nullable()

3) DomainsModel — encja `domains`, prefiks `Dom` — definicje stron zarządzanych w CMS
   Column::varchar('Protocol', 8)                  // http | https
   Column::varchar('Name', 190)->uniqueKey('name') // nazwa domeny, np. example.pl
   Column::varchar('CmsName', 190)                 // nazwa wyświetlana w CMS
   Column::varchar('Config', 64)->nullable()       // nazwa pliku z configs/ (bez .php)

4) NavigationModel — encja `navigation`, prefiks `Nav` — drzewo menu (folder/page)
   Column::guid('DomID')->indexKey('domain')           // FK → <t>_domains.DomID
   Column::guid('ParentID')->nullable()->indexKey('parent') // NULL = poziom najwyższy
   Column::int('Sort')->default(0)
   Column::varchar('Type', 16)->default('page')        // folder | page
   Column::varchar('Title', 190)
   Column::varchar('Path', 190)->nullable()            // URL pozycji-liścia
   Column::tinyInt('IsActive')->default(1)
   Column::varchar('SeoTitle', 190)->nullable()
   Column::text('SeoDescription')->nullable()
   Column::varchar('SeoKeywords', 255)->nullable()

5) NavigationMenusModel — encja `navigation_menus`, prefiks `NavMenu` — zestawy menu
   Column::guid('DomID')->indexKey('domain')
   Column::varchar('Name', 190)   // nazwa w panelu, np. „Menu główne"
   Column::varchar('Slug', 64)    // kod dla front-endu, np. „main", „footer"
   Column::int('Sort')->default(0)

6) NavigationHistoryModel — encja `navigation_history`, prefiks `NavHist` — snapshoty menu
   Column::guid('DomID')->indexKey('domain')
   Column::varchar('Label', 255)->nullable()  // opis zmiany
   Column::mediumText('Items')                // JSON — płaska lista pozycji z chwili zapisu

7) GalleriesModel — encja `galleries`, prefiks `Gal` — galerie zdjęć
   Column::guid('DomID')->indexKey('domain')
   Column::varchar('Name', 190)
   Column::text('Description')->nullable()->default(null)
   Column::guid('CoverPhotoID')->nullable()->default(null)  // okładka → GalPhotoID
   Column::int('Sort')->default(0)
   Column::varchar('Status', 20)->default('active')

8) GalleryPhotosModel — encja `gallery_photos`, prefiks `GalPhoto` — zdjęcia
   Column::guid('GalID')->indexKey('gallery')
   Column::varchar('Filename', 255)                         // UUID.ext — plik na dysku
   Column::varchar('OrigName', 255)->nullable()->default(null)  // oryginalna nazwa
   Column::varchar('Hash', 64)->nullable()->default(null)->indexKey('hash')  // SHA-256, dedup
   Column::varchar('Title', 190)->nullable()->default(null)
   Column::varchar('Alt', 190)->nullable()->default(null)
   Column::varchar('Caption', 500)->nullable()->default(null)
   Column::int('Width', true)->nullable()->default(null)    // true = unsigned
   Column::int('Height', true)->nullable()->default(null)
   Column::bigInt('Size', true)->nullable()->default(null)
   Column::varchar('Mime', 64)->default('image/jpeg')
   Column::int('Sort')->default(0)
   Column::dateTime('DeletedAt')->nullable()->default(null) // NULL = aktywne; NOT NULL = kosz (soft-delete)

9) GalleryCategoriesModel — encja `gallery_categories`, prefiks `GalCat` — kategorie per-domena
   Column::guid('DomID')->indexKey('domain')
   Column::varchar('Name', 190)
   Column::varchar('Slug', 64)
   Column::int('Sort')->default(0)

10) GalleryTagsModel — encja `gallery_tags`, prefiks `GalTag` — tagi per-domena
   Column::guid('DomID')->indexKey('domain')
   Column::varchar('Name', 190)
   Column::varchar('Slug', 64)

11) GalleryCatRelModel — encja `gallery_cat_rel`, prefiks `GalCatRel` — pivot galeria↔kategoria (M:N)
   BEZ kolumn bazowych. Tylko złożony klucz główny:
   Column::guid('GalID')->primaryKey()
   Column::guid('CatID')->primaryKey()

12) GalleryTagRelModel — encja `gallery_tag_rel`, prefiks `GalTagRel` — pivot galeria↔tag (M:N)
   BEZ kolumn bazowych. Tylko złożony klucz główny:
   Column::guid('GalID')->primaryKey()
   Column::guid('TagID')->primaryKey()

13) LogsModel — encja `logs`, prefiks `Log` — strukturalny log w stylu NLog (C#)
   Column::varchar('Level', 10)->indexKey('level')              // TRACE..FATAL
   Column::varchar('Logger', 190)->nullable()->indexKey('logger')
   Column::text('Message')
   Column::mediumText('Exception')->nullable()
   Column::varchar('Class', 190)->nullable()
   Column::varchar('Method', 190)->nullable()
   Column::int('LineNumber', unsigned: true)->nullable()
   Column::varchar('File', 255)->nullable()
   Column::json('Properties')->nullable()
   Column::varchar('HostName', 190)->nullable()
   Column::int('ProcessId', unsigned: true)->nullable()
   Column::varchar('AppVersion', 20)->nullable()->indexKey('appversion')
   Column::varchar('RequestUri', 500)->nullable()
   Column::varchar('IpAddress', 45)->nullable()               // IPv4 i IPv6
   Column::varchar('UserAgent', 500)->nullable()
   Column::guid('UserID')->nullable()->indexKey('user')       // FK audytowy → <t>_users.UseID
   indexes(): Index::index('level_datetime', ['Level', 'DateTime'])

## TABELA OPERACYJNA login_attempts (osobna migracja, BEZ modelu)

Tabela rate-limitingu logowania — celowo NIE jest encją biznesową (brak GUID/DateTime/IDAuto).
Wygeneruj OSOBNĄ migrację (najnowszy timestamp) zawierającą raw SQL z guardem
„CREATE jeśli nie istnieje" przez information_schema:

  $t = $this->table('login_attempts');
  $exists = (int) $this->connection->fetchOne(
      'SELECT COUNT(*) FROM information_schema.TABLES '
      . 'WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?', [$t]);
  if ($exists === 0) {
      $this->addSql("CREATE TABLE `{$t}` (
          `LaBucket`  VARCHAR(64)  NOT NULL,          -- SHA-256(REMOTE_ADDR) — 64 znaki hex
          `LaCount`   INT UNSIGNED NOT NULL DEFAULT 1,-- licznik prób w bieżącym oknie
          `LaFirstAt` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP, -- początek okna (15 min)
          PRIMARY KEY (`LaBucket`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
  }
  // down(): DROP TABLE IF EXISTS `{$t}`

## ZADANIE

1. Wygeneruj 13 modeli (pliki `app/Appdb/Models/<Entity>Model.php`) wg specyfikacji.
2. Dla każdego modelu wygeneruj cienką migrację CREATE (`app/Appdb/Migrations/Version<TS>.php`)
   z rosnącym timestampem (`YYYYMMDDHHMMSS`), wołającą tylko `createTableSql()` / `dropTableSql()`.
3. Wygeneruj OSOBNĄ migrację dla `login_attempts` (raw SQL z guardem information_schema) — najnowszy timestamp.
4. NIE generuj modelu ani migracji dla `<tenant>_migrations_appdb` (tworzy ją runner).
5. Każdy plik poprzedź jedną linią-komentarzem ze ścieżką, np. „// === app/Appdb/Models/UsersModel.php ===".
6. Kolumny w modelach BEZ prefiksu kolumnowego (prefiks dokleja TableModel). Pivoty bez kolumn bazowych.

Zwróć tylko pliki/kod, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] Powstało 13 modeli w `app/Appdb/Models/` (Users, Groups, Domains, Navigation, NavigationMenus, NavigationHistory, Galleries, GalleryPhotos, GalleryCategories, GalleryTags, GalleryCatRel, GalleryTagRel, Logs).
- [ ] `GroupsModel` ma stałe `ADMIN_GROUP_ID` i `USER_GROUP_ID`.
- [ ] Modele pivot (`GalleryCatRelModel`, `GalleryTagRelModel`) NIE mają kolumn `ID`/`DateTime`/`IDAuto` — tylko złożony PK.
- [ ] Każdy model biznesowy ma trzy kolumny bazowe w kolejności: `guid('ID')->primaryKey()`, `dateTime('DateTime')->default('CURRENT_TIMESTAMP')`, `autoInc('IDAuto')->uniqueKey('idauto')`.
- [ ] `LogsModel` ma indeks wielokolumnowy `Index::index('level_datetime', ['Level','DateTime'])`.
- [ ] Migracja `login_attempts` używa raw SQL z guardem information_schema (kolumny `LaBucket`/`LaCount`/`LaFirstAt`).
- [ ] `php bin/migrate appdb migrations:status` pokazuje wszystkie migracje jako nowe.
- [ ] `php bin/migrate appdb migrations:migrate` przechodzi bez błędu i tworzy tabelę śledzącą `<tenant>_migrations_appdb`.

## Powiązane
- [040 Modele tabel](040-modele-tabel.md) — rdzeń `TableModel` / `Column` / `Index`.
- [050 System migracji](050-system-migracji.md) — `TenantMigration`, runner, prefiks tenanta.
- [migracja-tabeli.md](../migracja-tabeli.md) — wzorzec pojedynczej pary model + migracja.
- [Architektura §5 (Warstwa aplikacji)](../../architektura/architektura.md) i [§9 (Multi-tenant)](../../architektura/architektura.md).
