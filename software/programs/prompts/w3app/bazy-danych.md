# Bazy danych

Dokumentacja warstwy danych: połączenie, drivery, konfiguracja per-tenant i migracje.

---

## 1. Warstwa połączenia

### 1.1. Komponenty

| Plik | Rola |
|---|---|
| [core/Connection.php](../core/Connection.php) | Singleton PDO z lazy initialization. `Connection::get()` zwraca tę samą instancję w obrębie requestu, `Connection::reset()` ją zeruje (przydatne w testach). |
| [core/db/Driver.php](../core/db/Driver.php) | Abstrakcyjna klasa bazowa — kontrakt `dsn(array $cfg): string` + wspólne `options()` PDO (`ERRMODE_EXCEPTION`, `FETCH_ASSOC`, brak emulowanych prepare). |
| [core/db/MySqlDriver.php](../core/db/MySqlDriver.php) | DSN dla MySQL (host, port, dbname, charset). |
| [core/db/PgSqlDriver.php](../core/db/PgSqlDriver.php) | DSN dla PostgreSQL. |
| [core/db/SqliteDriver.php](../core/db/SqliteDriver.php) | DSN dla SQLite. Obsługuje `:memory:`, ścieżki absolutne i ścieżki względne rozwijane od `ROOT`. |

### 1.2. Rejestr driverów

Wybór silnika sterowany kluczem `db.driver` w configu:

```php
'db' => [
    'driver' => 'mysql',   // mysql | pgsql | sqlite
    // ...
]
```

Rejestr żyje w stałej `Connection::DRIVERS`. **Dodanie nowego silnika** = nowy plik w `core/db/` + jeden wpis w rejestrze. Nie trzeba ruszać `index.php`.

Pliki driverów ładuje `spl_autoload_register` w [index.php](../index.php) — przy konfiguracji MySQL pliki `PgSqlDriver.php` / `SqliteDriver.php` **nie trafiają do PHP**.

### 1.3. Konfiguracja

`username` i `password` są opcjonalne — driver żąda ich tylko jeśli faktycznie używa (np. SQLite ich nie potrzebuje).

```php
// configs/_default.php
'db' => [
    'driver'   => 'mysql',
    'host'     => 'localhost',
    'port'     => 3306,
    'database' => 'web_new',
    'username' => 'root',
    'password' => 'admin1234',
    'charset'  => 'utf8mb4',
],
```

---

## 2. Konfiguracja per-tenant

Każda domena (`$_SERVER['HTTP_HOST']`) może mieć własny plik `configs/<host>.php`, który nadpisuje wartości z `_default.php` przez `array_replace_recursive` ([core/Config.php](../core/Config.php)).

```php
// configs/klient1.local.php
return [
    'db' => [
        'database' => 'klient1_db',
        'username' => 'root',
        'password' => '',
    ],
];
```

Host przed wyborem pliku jest normalizowany regexem `[^a-z0-9.\-_]` — ochrona przed path traversal.

---

## 3. Migracje

### 3.1. Założenia

- **Niezależne komponenty** (`appdb`, `cms`, `shop`, `forum`, …) — każdy ze swoim katalogiem migracji i własną tabelą śledzącą.
- **`appdb`** (Application Main) — bazowy moduł obecny w każdym projekcie opartym o silnik. Zawiera autentykację panelu administracyjnego (tabela `users`) i jest niezależny od warstwy domenowej. CMS / shop / inne komponenty są **opcjonalnymi nadbudowami**; aplikacja czysto narzędziowa (np. SaaS, narzędzie wewnętrzne) może mieć wyłącznie `appdb`.
- **Prefix tenant** ([sekcja 3.11](#311-konwencja-nazewnictwa-tabel-i-kolumn)) jednoznacznie identyfikuje aplikację/domenę — wszystkie tabele wszystkich komponentów u danego klienta dostają ten sam prefix (`def_users`, `def_pages`, `def_migrations_cms`). Pozwala to trzymać wielu klientów w jednej fizycznej bazie bez kolizji.
- **Auto-discovery** — wystarczy fizycznie utworzyć folder `app/<Komponent>/Migrations/`; nie ma centralnego rejestru.
- **Trigger** — migrator startuje **tylko** przy logowaniu do panelu admin oraz z CLI. Frontend nie dotyka migratora.
- **Wydajność** — lock-pliki w `var/schema-lock/<slug>.lock` przechowują fingerprint listy plików migracji. Jeśli fingerprint zgodny ze stanem dysku, migrator nie wykonuje żadnego SQL-a.
- **Migracje pisane ręcznie** — czysty SQL przez `$this->addSql(...)` z Doctrine Migrations 3.x. Bez ORM, bez auto-diff.

### 3.2. Komponenty migratora

| Plik | Rola |
|---|---|
| [core/Migrations/Component.php](../core/Migrations/Component.php) | DTO: slug, namespace, katalog, tabela śledząca, klucz konfiguracji DB. |
| [core/Migrations/ComponentDiscovery.php](../core/Migrations/ComponentDiscovery.php) | Skan `app/*/Migrations/`. Czyta opcjonalny `app/<Komponent>/component.php` z nadpisaniami. |
| [core/Migrations/DbalConnectionFactory.php](../core/Migrations/DbalConnectionFactory.php) | Most między configiem PDO a `Doctrine\DBAL\Connection`. |
| [core/Migrations/MigratorFactory.php](../core/Migrations/MigratorFactory.php) | Buduje `DependencyFactory` Doctrine per komponent (osobna tabela śledząca, osobny namespace migracji). |
| [core/Migrations/SchemaLock.php](../core/Migrations/SchemaLock.php) | Fingerprint nazw plików migracji + `flock` (`var/schema-lock/<slug>.lock` i `<slug>.lock.flock`). |
| [core/Migrations/MigrationRunner.php](../core/Migrations/MigrationRunner.php) | `runPending()` — iteruje komponenty, pomija up-to-date, wykonuje `migrations:migrate` programowo. |
| [bin/migrate](../bin/migrate) | CLI: `php bin/migrate <komponent> <komenda-doctrine>`. |

### 3.3. Struktura komponentu

```
app/
├── Appdb/                      ← bazowy moduł (Application Main) — obecny w każdym projekcie
│   ├── Models/
│   │   └── UsersModel.php     ← deklaratywna definicja tabeli users
│   └── Migrations/
│       └── Version20260513130000.php   ← cienka migracja używająca UsersModel
├── Cms/
│   ├── Models/
│   │   └── PagesModel.php
│   ├── Migrations/
│   │   ├── Version20260513120000.php
│   │   └── Version20260514093000.php
│   └── component.php          ← opcjonalny: nadpisania (db, table)
└── Shop/
    ├── Models/
    ├── Migrations/
    │   └── Version20260601090000.php
    └── component.php
```

**Konwencje**:
- Slug komponentu = lowercase nazwy folderu (`Cms` → `cms`).
- Namespace migracji = `App\<Komponent>\Migrations`.
- Klasy migracji: `Version<YYYYMMDDHHMMSS>` rozszerzające `Doctrine\Migrations\AbstractMigration`.
- Domyślna tabela śledząca: `migrations_<slug>`.
- Domyślny klucz configu DB: `db` (wszystkie komponenty współdzielą połączenie).

### 3.4. Plik `component.php` (opcjonalny)

```php
// app/Shop/component.php
return [
    'db'    => 'db_shop',           // klucz w configs/*.php → osobna baza
    'table' => 'migrations_shop',   // domyślnie: migrations_<slug>
];
```

W configu klienta:

```php
// configs/klient1.local.php
return [
    'db'      => [ 'database' => 'klient1_cms',  /* ... */ ],
    'db_shop' => [ 'database' => 'klient1_shop', /* ... */ ],
];
```

Klient bez `db_shop` w configu → komponent `shop` użyje `db`. Brak `component.php` → wszystkie domyślne (`db` + `migrations_<slug>`).

### 3.5. Pisanie migracji

```php
<?php
declare(strict_types=1);

namespace App\Cms\Migrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20260513120000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'CMS: tabela pages';
    }

    public function up(Schema $schema): void
    {
        $this->addSql(<<<SQL
            CREATE TABLE pages (
                id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                slug        VARCHAR(190) NOT NULL,
                title       VARCHAR(255) NOT NULL,
                body        MEDIUMTEXT NULL,
                created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY uniq_pages_slug (slug)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        SQL);
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP TABLE pages');
    }
}
```

**Uwagi**:
- `addSql()` przyjmuje dowolny SQL — DDL, DML, triggery, procedury, seed-data.
- Parametr `Schema $schema` można zignorować — używaj go tylko jeśli wolisz Schema API (`$schema->createTable(...)`).
- Jeden statement na wywołanie `addSql()`. Dla kilku DDL-i wołaj kilka razy po kolei.
- `down()` można zostawić pusty — wiele zespołów polega na backupach zamiast rollbackach.

### 3.6. CLI

```bash
# Status (czego brakuje, co już wykonane)
php bin/migrate cms migrations:status

# Wykonaj wszystkie oczekujące migracje
php bin/migrate cms migrations:migrate

# Wygeneruj pusty plik Version<ts>.php do uzupełnienia
php bin/migrate cms migrations:generate

# Multi-tenant — wskaż hosta klienta (czyta configs/klient1.local.php)
HTTP_HOST=klient1.local php bin/migrate cms migrations:migrate
```

Dostępne są wszystkie komendy Doctrine Migrations: `migrations:execute`, `migrations:rollup`, `migrations:sync-metadata-storage`, `migrations:list`, itd.

### 3.7. Hook w panelu admin

[admin/index.php](../admin/index.php) — przy wejściu na stronę **System** panelu — wywołuje:

```php
(new MigrationRunner($discovery, $factory, $lock))->runPending();
```

Mechanizm:
1. Skan `app/*/Migrations/` → lista komponentów.
2. Dla każdego: porównanie fingerprintu (xxh3 nazw plików migracji) z `var/schema-lock/<slug>.lock`.
3. Zgodne → `status: up-to-date`, zero SQL-a.
4. Rozjazd → `flock` na `<slug>.lock.flock`, wykonanie `migrations:migrate`, zapis nowego fingerprintu.

Raport per komponent (`up-to-date` / `migrated` / `error` + bufor outputu) jest renderowany na stronie **System** panelu.

### 3.8. Wydajność

- **Frontend** ([index.php](../index.php)) nie dotyka katalogu `core/Migrations/` ani lock-plików. Composer ładuje Doctrine leniwie — kod migracji nie trafia do bytecode'u, dopóki nie wywoła go CLI lub admin.
- Po pierwszym loginie po deployu migracja idzie raz; kolejne loginy: jeden `glob()` + jeden `file_get_contents()` na komponent, zero zapytań SQL.

### 3.9. Bezpieczeństwo

- Migrator wymaga zalogowanego admina **przed** wywołaniem (sprawdzane w [admin/index.php](../admin/index.php) — `_SESSION['admin']`).
- Uwierzytelnianie panelu: konta w tabeli `<tenant>_users` (`password_verify()`); panel dostępny wyłącznie pod sekretnym adresem `admin/{kod}/` (klucz `admin_code` w configu). Pełny opis: [docs/panel-admin.md](panel-admin.md).
- W produkcji rozważ wyłączenie auto-trigger przez flagę w configu i poleganie wyłącznie na CLI uruchamianym z pipeline deployu.
- Każda migracja działa w transakcji (`transactional: true` w `MigratorFactory`). DDL w MySQL i tak nie jest transakcyjny, ale DML/seed-data mają atomowość.

### 3.10a. Modele tabel — deklaratywne źródło prawdy

Każda tabela ma swój **model** w `app/<Komponent>/Models/<Entity>Model.php`. Model deklaruje strukturę tabeli — każda kolumna jako osobna linia w `columns()`, każdy indeks jako osobna deklaracja w `indexes()`.

#### Po co model

- **Jedna linia = jedna kolumna** — łatwo zakomentować, dodać, zmienić typ.
- **Indeksy razem ze strukturą** — `uniqueKey('login')` przy kolumnie zamiast osobnej sekcji SQL.
- **Migracja CREATE jest cienka** — `$this->addSql((new UsersModel())->createTableSql($this->tenantPrefix()))`. Logika nazewnictwa (prefix tenant, prefix kolumn, format nazw indeksów) żyje w jednym miejscu — w `TableModel`.
- **Model jest dostępny z aplikacji** — w przyszłości warstwa repozytoriów / query buildera może pytać model o listę kolumn, prefix, klucze.

#### Bazowe klasy

| Plik | Rola |
|---|---|
| [core/Models/Column.php](../core/Models/Column.php) | Fluent builder kolumny (`Column::varchar('Login', 64)->uniqueKey('login')`). Fabryki: `guid`, `varchar`, `char`, `text`/`mediumText`/`longText`, `int`/`bigInt`/`smallInt`/`tinyInt`, `autoInc`, `decimal`, `dateTime`/`date`, `json`, `raw`. Modyfikatory: `nullable()`, `notNull()`, `default(...)`, `primaryKey()`, `uniqueKey(label)`, `indexKey(label)`, `onUpdate(expr)`, `comment(text)`. |
| [core/Models/Index.php](../core/Models/Index.php) | Indeks wielokolumnowy: `Index::unique('label', ['Col1','Col2'])` / `Index::index(...)`. |
| [core/Models/TableModel.php](../core/Models/TableModel.php) | Abstrakcyjna baza modelu. Wymaga `entity()`, `columnPrefix()`, `columns()`; opcjonalnie `indexes()`. Renderuje `createTableSql($tenantPrefix)` i `dropTableSql($tenantPrefix)`. |

#### Przykład: `app/Appdb/Models/UsersModel.php`

```php
final class UsersModel extends TableModel
{
    public function entity(): string      { return 'users'; }
    public function columnPrefix(): string { return 'Use'; }

    public function columns(): array
    {
        return [
            // ── Kolumny bazowe ───────────────────────────────────────────────
            Column::guid('ID')->primaryKey(),
            Column::dateTime('DateTime')->default('CURRENT_TIMESTAMP'),
            Column::autoInc('IDAuto')->uniqueKey('idauto'),

            // ── Kolumny biznesowe ────────────────────────────────────────────
            Column::varchar('Login', 64)->uniqueKey('login'),
            Column::varchar('Password', 255),
            Column::varchar('Email', 190)->nullable()->uniqueKey('email'),
            Column::tinyInt('IsActive')->default(1),
            Column::dateTime('LastLogin')->nullable(),
            // Column::varchar('Phone', 32)->nullable(),    // ← łatwo dodać / zaremować
        ];
    }
}
```

Migracja CREATE (cała zawartość `up()`/`down()`):

```php
public function up(Schema $schema): void
{
    $this->addSql((new UsersModel())->createTableSql($this->tenantPrefix()));
}

public function down(Schema $schema): void
{
    $this->addSql((new UsersModel())->dropTableSql($this->tenantPrefix()));
}
```

#### Cykl życia modelu po wdrożeniu

Model jest "obecnym, pożądanym stanem". **Edycja modelu sama z siebie NIE zmienia bazy** — wymaga osobnej migracji ALTER:

| Sytuacja | Działanie |
|---|---|
| Pierwsza migracja tabeli (CREATE) | Migracja używa `createTableSql()` z modelu. Stan tabeli = stan modelu. |
| Dodanie nowej kolumny | 1) Dodaj linię `Column::...()` w modelu. 2) Nowa migracja ALTER z ręcznym `ALTER TABLE <table> ADD COLUMN <FullName> ...`. |
| Zakomentowanie / usunięcie kolumny | 1) Zakomentuj linię w modelu. 2) Nowa migracja ALTER z `ALTER TABLE <table> DROP COLUMN <FullName>`. |
| Zmiana typu / długości / nullability | 1) Zmień w modelu. 2) Nowa migracja ALTER z `ALTER TABLE <table> MODIFY COLUMN ...`. |
| Zmiana / dodanie indeksu | 1) Zmień `uniqueKey`/`indexKey` lub `indexes()` w modelu. 2) Nowa migracja ALTER z `ALTER TABLE ... DROP INDEX ... ADD UNIQUE KEY ...`. |

**Model bez migracji** = świeże środowisko utworzy poprawną tabelę, ale istniejące bazy NIE dostaną zmiany — dlatego model zawsze wymaga sparowanej migracji ALTER dla istniejących wdrożeń.

#### Walidacja zgodności (planowane)

W przyszłości można dorzucić `bin/migrate <komponent> models:check` — porównanie modelu z `INFORMATION_SCHEMA` i raport, czy aktualny stan bazy zgadza się z bieżącym modelem. Na razie odpowiedzialność po stronie autora migracji.

### 3.11. Konwencja nazewnictwa tabel i kolumn

Cały silnik trzyma się jednej, sztywnej konwencji — dotyczy **wszystkich** migracji we **wszystkich** komponentach.

#### Prefix tabeli (tenant)

- Prefix jest atrybutem **tenanta** (aplikacji / domeny / klienta), nie komponentu. Wszystkie tabele wszystkich komponentów u danego klienta używają tego samego prefiksu.
- Konfigurowany w `configs/_default.php` (klucz `tenant.prefix`, domyślnie `'def'`); per-host nadpisywany w `configs/<host>.php` (`'tenant' => ['prefix' => 'kl1']`).
- Wstrzykiwany do migracji przez [TenantMigrationFactory](../core/Migrations/TenantMigrationFactory.php). Migracja wywołuje `$this->table('users')` → `def_users`.
- **Tabele systemowe migratora** też dostają prefix: `def_migrations_appm`, `def_migrations_cms`, `def_migrations_shop`, …

#### Bazowa struktura każdej tabeli

Każda tabela tworzona przez ten silnik zaczyna się od **trzech standardowych kolumn**, w tej kolejności:

| Kolumna | Typ | Rola | Klucz |
|---|---|---|---|
| `<C>ID` | `CHAR(36) NOT NULL` | GUID — generowany w warstwie aplikacji (`uniqid`, `Ramsey\Uuid`, `random_bytes`) | `PRIMARY KEY` |
| `<C>DateTime` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | Znacznik utworzenia rekordu | — |
| `<C>IDAuto` | `INT UNSIGNED NOT NULL AUTO_INCREMENT` | Kompaktowy identyfikator porządkowy (sortowanie, raporty, integracje) | `UNIQUE KEY uniq_<table>_idauto` |

`<C>` to **prefix kolumnowy** ustalany per tabela, 3–5 znaków, PascalCase, derywowany od logicznej nazwy encji:

| Tabela (po prefiksie) | Prefix kolumn (3 zn.) | Prefix kolumn (5 zn.) | Wybór |
|---|---|---|---|
| `users` | `Use` | `Users` | autor decyduje per migracja (preferencja: 3 zn., 5 zn. tylko gdy `Use*` byłoby mylące) |
| `pages` | `Pag` | `Pages` | 3 zn. |
| `orders` | `Ord` | `Order` | 3 zn. |
| `categories` | `Cat` | — | 3 zn. |
| `blog_posts` | `BlP` lub `Pos` | `Blogp` | autor decyduje — zwykle dominujący człon |

**Zasady kolumn biznesowych**:
- Wszystkie kolumny tabeli używają tego samego prefiksu co kolumny bazowe (`UseLogin`, `UseEmail`, `PagSlug`, `PagTitle`).
- Brak `created_at` / `updated_at` — `<C>DateTime` zastępuje `created_at`. Jeśli rekord wymaga znacznika modyfikacji, dorzuca się `<C>Modified DATETIME NULL` z `ON UPDATE CURRENT_TIMESTAMP`.

#### Konwencja indeksów i kluczy

- `PRIMARY KEY` — zawsze na `<C>ID` (GUID).
- `UNIQUE KEY uniq_<table>_<purpose>` — np. `uniq_def_users_login`, `uniq_def_pages_slug`.
- `INDEX idx_<table>_<purpose>` — zwykłe indeksy.
- `FOREIGN KEY fk_<table>_<column>` — referencje (tylko w obrębie tej samej fizycznej bazy; cross-component FK z rozwagą).
- Nazwy indeksów zawierają **pełną nazwę tabeli z prefiksem tenant** (`uniq_def_users_login`, nie `uniq_users_login`) — ułatwia diagnozę przy wielu tenantach w jednej bazie.

#### Przykład pełnej migracji

```php
final class Version20260513130000 extends \Core\Migrations\TenantMigration
{
    public function getDescription(): string
    {
        return 'Appdb: tabela users (prefiks kolumn Use)';
    }

    public function up(Schema $schema): void
    {
        $t = $this->table('users');   // -> def_users (zależnie od configu)

        $this->addSql(<<<SQL
            CREATE TABLE {$t} (
                UseID         CHAR(36)       NOT NULL,
                UseDateTime   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
                UseIDAuto     INT UNSIGNED   NOT NULL AUTO_INCREMENT,
                UseLogin      VARCHAR(64)    NOT NULL,
                UsePassword   VARCHAR(255)   NOT NULL,
                UseEmail      VARCHAR(190)   NULL,
                UseIsActive   TINYINT(1)     NOT NULL DEFAULT 1,
                UseLastLogin  DATETIME       NULL,
                PRIMARY KEY (UseID),
                UNIQUE KEY uniq_{$t}_idauto (UseIDAuto),
                UNIQUE KEY uniq_{$t}_login  (UseLogin),
                UNIQUE KEY uniq_{$t}_email  (UseEmail)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        SQL);
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP TABLE ' . $this->table('users'));
    }
}
```

#### GUID — generowanie

`<C>ID` nie ma `DEFAULT` na poziomie bazy (MySQL `DEFAULT (UUID())` byłby v1, czasowy, nie v4). GUID generuje warstwa aplikacji przed `INSERT`-em:

```php
// w4 (RFC 4122)
$guid = sprintf(
    '%04x%04x-%04x-%04x-%04x-%04x%04x%04x',
    random_int(0, 0xffff), random_int(0, 0xffff),
    random_int(0, 0xffff),
    random_int(0, 0x0fff) | 0x4000,
    random_int(0, 0x3fff) | 0x8000,
    random_int(0, 0xffff), random_int(0, 0xffff), random_int(0, 0xffff)
);
```

Lub `Ramsey\Uuid\Uuid::uuid4()->toString()`, jeśli pakiet zostanie dodany. W repozytoriach (warstwa modelu) zapewniamy generowanie w jednym miejscu, nie w każdym callsite.

### 3.10. Lock-pliki

`var/schema-lock/` jest w `.gitignore` — fingerprint to stan per-środowisko. Po deployu nowego pliku migracji lock jest "stary" → pierwszy login admina (lub `bin/migrate`) wyzwala migrację i odświeża fingerprint.

Manualny reset (rzadko potrzebny):
```bash
rm var/schema-lock/cms.lock
```

---

## 4. Dodawanie nowego komponentu

1. `mkdir -p app/Forum/Migrations`
2. (opcjonalnie) `app/Forum/component.php` z konfiguracją osobnej bazy / niestandardowej tabeli.
3. `php bin/migrate forum migrations:generate` → tworzy szkielet `Version<ts>.php`.
4. Wypełnij `up()` SQL-em, opcjonalnie `down()`.
5. Następne logowanie do `/admin/` (lub `php bin/migrate forum migrations:migrate`) wykona migrację.

Brak dodatkowych kroków rejestracji — komponent istnieje od chwili pojawienia się katalogu na dysku.

---

## 5. Wersja aplikacji

[core/Version.php](../core/Version.php) — `final class Core\Version` ze stałą `NUMBER` w formacie `YYYY.MM` (np. `'2026.05'`). Wartość bumpowana **ręcznie** raz na miesiąc przy wdrożeniu cyklicznym, niezależna od configu (deterministyczna względem deploya, identyczna dla wszystkich tenantów).

```php
use Core\Version;

$ver = Version::current();   // → "2026.05"
```

### Użycie w logach

Każdy wpis w `<tenant>_logs` zawiera wersję aplikacji w kolumnie `LogAppVersion` (`VARCHAR(20)`, indeksowana). Warstwa logująca dokleja ją automatycznie:

```php
$row = [
    // ... callsite, message, level, kontekst HTTP itd.
    'LogAppVersion' => \Core\Version::current(),
];
```

Indeks `idx_<tenant>_logs_appversion` pozwala szybko odfiltrować logi po konkretnym wdrożeniu — typowe zapytanie diagnostyczne *"co się zepsuło po deployu wersji X"*:

```sql
SELECT LogLevel, LogClass, LogMethod, LogLineNumber, LogMessage
FROM def_logs
WHERE LogAppVersion = '2026.05' AND LogLevel IN ('ERROR', 'FATAL')
ORDER BY LogDateTime DESC
LIMIT 100;
```

### Format `YYYY.MM` — uzasadnienie

- Łatwa do zapamiętania ("która wersja jest na produkcji?" → "ta z maja 2026")
- Ułatwia komunikację z klientem ("kiedy pojawi się funkcja X?" → "w wydaniu z lipca")
- Nie wymaga klasycznego semver (`MAJOR.MINOR.PATCH`) — projekt nie ma publicznego API w sensie biblioteki
- Margines w VARCHAR(20) pozwala wprowadzić suffix przy potrzebie (`2026.05.dev1`, `2026.05-hotfix1`)

---

## 6. Zewnętrzne zależności

- [`doctrine/dbal`](https://github.com/doctrine/dbal) — abstrakcja połączenia używana przez migrator (MIT).
- [`doctrine/migrations`](https://github.com/doctrine/migrations) `^3.9` — runner migracji (MIT, aktywnie rozwijany).
- [`doctrine/orm`](https://github.com/doctrine/orm) `^3.6` — wymagany przez composer, w runtime frontu nie używany. Można sięgnąć po niego per komponent, jeśli kiedyś zajdzie potrzeba.

Wszystkie na licencji MIT, bez kosztów komercyjnych.
