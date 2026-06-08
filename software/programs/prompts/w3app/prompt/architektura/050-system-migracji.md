# Prompt 050: System migracji (Doctrine, multi-tenant) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [040 Rdzeń modeli tabel](040-modele-tabel.md) · Następny: [060 Logger](060-logger.md) →

Ten krok buduje **warstwę migracji** opartą na `doctrine/migrations`, świadomą wielodostępności (multi-tenant). Powstaje rdzeń `core/Migrations/*` (bazowa `TenantMigration` wstrzykująca prefiks tenanta, `TenantMigrationFactory`, `MigratorFactory` budujący `DependencyFactory` per komponent, `ComponentDiscovery` + `Component`, `SchemaLock`, `DbalConnectionFactory`, `MigrationRunner`) oraz skrypt CLI `bin/migrate`. Wymaga z wcześniejszych kroków: autoloadera `Core\` (010), klasy `Config` z `Config::load($host)` / `Config::get($key)` (020) oraz rdzenia modeli z kroku [040](040-modele-tabel.md) (migracje CREATE wołają `createTableSql()`).

Kluczowa idea: aplikacja dzieli się na **komponenty** (`appdb`, `cms`, `shop`) — każdy folder w `app/` z podkatalogiem `Migrations/`. Każdy komponent ma WŁASNĄ tabelę śledzącą migracje: `<tenant>_migrations_<komponent>` (np. `def_migrations_cms`). Prefiks tenanta dokleja się i do nazw tabel danych, i do nazwy tabeli śledzącej.

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Wklej do asystenta LLM — prompt jest samowystarczalny.
3. Zapisz wygenerowane pliki w `core/Migrations/` oraz skrypt `bin/migrate`.
4. Zweryfikuj wg sekcji **Weryfikacja**: `php bin/migrate <komponent> migrations:status`, potem `migrations:migrate`.

---

## PROMPT
```
Jesteś generatorem warstwy migracji silnika K2 CMS (PHP 8.1+, doctrine/migrations 3.x,
doctrine/dbal, symfony/console, MySQL 8). Wygeneruj komplet plików rdzenia migracji
oraz skrypt CLI.

## KONTEKST PROJEKTU

- K2 CMS jest wielodostępny (multi-tenant): wielu klientów współdzieli jedną bazę,
  izolację daje PREFIKS TENANTA z konfiguracji (`tenant.prefix`, np. `def`, `kl1`).
- Aplikacja dzieli się na KOMPONENTY: każdy folder w `app/` (np. `Appdb`, `Cms`, `Shop`)
  z podkatalogiem `Migrations/`. Slug komponentu = nazwa folderu lowercase (`appdb`,
  `cms`, `shop`).
- Każdy komponent ma WŁASNĄ tabelę śledzącą migracje: `<tenant>_migrations_<slug>`
  (np. `def_migrations_cms`). Migracje różnych komponentów są niezależne.
- Migracje CREATE TABLE używają modeli z kroku „rdzeń modeli": wołają
  `(new XxxModel())->createTableSql($this->tenantPrefix())`. Migracje ALTER piszą
  raw SQL z pomocą `$this->table('nazwa_encji')` (dokleja prefiks tenanta).
- Konfiguracja dostarcza klucze: `tenant` (z `prefix`), `db` (lub inny klucz DB per
  komponent: driver/host/port/database/username/password/charset).

## ŚCIEŻKI (namespace Core\Migrations, o ile nie wskazano inaczej)

- core/Migrations/TenantMigration.php
- core/Migrations/TenantMigrationFactory.php
- core/Migrations/Component.php
- core/Migrations/ComponentDiscovery.php
- core/Migrations/DbalConnectionFactory.php
- core/Migrations/MigratorFactory.php
- core/Migrations/SchemaLock.php
- core/Migrations/MigrationRunner.php
- bin/migrate                      (skrypt CLI, shebang #!/usr/bin/env php)

## SPECYFIKACJA: TenantMigration.php

Abstrakcyjna klasa bazowa migracji, `extends Doctrine\Migrations\AbstractMigration`.
- Prywatne pole `string $tenantPrefix = ''`.
- `setTenantPrefix(string $prefix): void` — ustawia prefiks (woła go fabryka).
- `protected table(string $name): string` — zwraca `$name` gdy prefiks pusty,
  inaczej `"{$tenantPrefix}_{$name}"`. Używane w migracjach ALTER.
- `protected tenantPrefix(): string` — zwraca prefiks (do `createTableSql()` w CREATE).
PHPDoc: opisz konwencję `<tenant>_<entity>`, trzy kolumny bazowe (<C>ID CHAR(36) PK,
<C>DateTime DATETIME DEFAULT CURRENT_TIMESTAMP, <C>IDAuto INT UNSIGNED AUTO_INCREMENT
UNIQUE) i nazwy kluczy (uniq_/idx_/fk_).

## SPECYFIKACJA: TenantMigrationFactory.php

`final` implementuje `Doctrine\Migrations\Version\MigrationFactory`.
- Konstruktor (readonly promoted): `Doctrine\DBAL\Connection $connection`,
  `Psr\Log\LoggerInterface $logger`, `string $tenantPrefix`.
- `createVersion(string $migrationClassName): Doctrine\Migrations\AbstractMigration`
  — tworzy `new $migrationClassName($this->connection, $this->logger)`; jeśli instancja
  jest `TenantMigration`, woła `setTenantPrefix($this->tenantPrefix)`; zwraca instancję.

## SPECYFIKACJA: Component.php

`final` — wartościowy DTO komponentu. Konstruktor z public readonly promoted:
`string $slug`, `string $namespace`, `string $migrationsDir`, `string $tableName`,
`string $dbConfigKey`.

## SPECYFIKACJA: ComponentDiscovery.php

`final` — wykrywa komponenty w katalogu `app/`.
- Konstruktor: `string $appDir` (readonly).
- `all(): array` (@return Component[]) — gdy `$appDir` nie istnieje → `[]`. Iteruj
  `\DirectoryIterator($appDir)`: pomiń kropki i nie-katalogi; pomiń foldery bez
  podkatalogu `Migrations`. Dla pozostałych zbuduj Component (patrz `build`).
  Posortuj rosnąco po `slug`.
- `bySlug(string $slug): ?Component` — zwraca pasujący komponent z `all()` lub null.
- `private build(string $name, string $componentDir, string $migrationsDir): Component`:
    - `slug = strtolower($name)`;
    - opcjonalne nadpisania z pliku `<componentDir>/component.php` (jeśli istnieje i
      `require` zwraca tablicę): klucze `table` i `db`;
    - `namespace = 'App\\' . $name . '\\Migrations'`;
    - `tableName = $overrides['table'] ?? ('migrations_' . $slug)`
      (UWAGA: to nazwa BEZ prefiksu tenanta — prefiks dokleja MigratorFactory);
    - `dbConfigKey = $overrides['db'] ?? 'db'`.

## SPECYFIKACJA: DbalConnectionFactory.php

`final` — buduje połączenie DBAL z tablicy konfiguracji.
- Stała `DRIVER_MAP`: `mysql`→`pdo_mysql`, `pgsql`→`pdo_pgsql`, `sqlite`→`pdo_sqlite`.
- `public static fromConfig(array $cfg): Doctrine\DBAL\Connection`:
    - driver z mapy wg `$cfg['driver'] ?? 'mysql'`; nieznany → `InvalidArgumentException`;
    - parametry: driver, host (`localhost`), port (int, 3306), dbname (`database`),
      user (`username`), password, charset (`utf8mb4`) — z fallbackami z `$cfg`;
    - dla `pdo_sqlite` z `$cfg['path']`: ustaw `path`, usuń host/port/dbname;
    - `return DriverManager::getConnection($params)`.

## SPECYFIKACJA: MigratorFactory.php

`final` — buduje `Doctrine\Migrations\DependencyFactory` dla komponentu.
- Konstruktor: `\Closure $configResolver` (readonly) — funkcja `(string $key) => mixed`
  zwracająca wartość configu pod kluczem.
- `forComponent(Component $component): DependencyFactory`:
    1. `$dbCfg = ($configResolver)($component->dbConfigKey)`; jeśli nie array →
       `RuntimeException` „Brak konfiguracji bazy pod kluczem …";
    2. `$tenantCfg = ($configResolver)('tenant')`; `$tenantPrefix` = `$tenantCfg['prefix']`
       (string) gdy array, inaczej '';
    3. `$connection = DbalConnectionFactory::fromConfig($dbCfg)`;
    4. `$metadataTable` = `migrations_<slug>` gdy prefiks pusty, inaczej
       `<prefix>_migrations_<slug>`;
    5. zbuduj `ConfigurationArray` z: `table_storage.table_name = $metadataTable`,
       `migrations_paths = [ $component->namespace => $component->migrationsDir ]`,
       `all_or_nothing = true`, `transactional = true`, `check_database_platform = false`;
    6. `$dependencyFactory = DependencyFactory::fromConnection($configuration,
       new ExistingConnection($connection))`;
    7. nadpisz usługę `MigrationFactory::class` instancją
       `new TenantMigrationFactory($connection, $dependencyFactory->getLogger(), $tenantPrefix)`;
    8. zwróć `$dependencyFactory`.

## SPECYFIKACJA: SchemaLock.php

`final` — odcisk palca (fingerprint) stanu plików migracji + blokada plikowa (flock),
aby uniknąć równoległego migrowania.
- Konstruktor: `string $lockDir` (readonly). Jeśli katalog nie istnieje → utwórz
  (`mkdir(..., 0775, true)`); przy niepowodzeniu → `RuntimeException`.
- `currentFingerprint(Component $component): string` — `glob(<migrationsDir>/Version*.php)`,
  posortuj; hash łańcuchowy: start `hash('xxh3','')`, dla każdego pliku
  `hash('xxh3', $hash . basename($file))`.
- `storedFingerprint(Component $component): ?string` — odczyt z pliku `.lock` (trim) lub null.
- `store(Component $component, string $fingerprint): void` — zapis do pliku `.lock` (LOCK_EX).
- `isUpToDate(Component $component): bool` — `storedFingerprint() === currentFingerprint()`.
- `acquireLock(Component $component): mixed` — `fopen(<path>.flock, 'c')`, `flock(LOCK_EX)`;
  zwraca handle; przy błędach → `RuntimeException`.
- `releaseLock(mixed $handle): void` — `flock(LOCK_UN)` + `fclose` gdy resource.
- `private path(Component $component): string` — `<lockDir>/<slug>.lock`.

## SPECYFIKACJA: MigrationRunner.php

`final` — programowe uruchamianie migracji (np. z panelu) z użyciem symfony/console
w pamięci. Konstruktor (readonly): `ComponentDiscovery $discovery`,
`MigratorFactory $factory`, `SchemaLock $lock`.
- `runPending(): array` — dla każdego komponentu z `discovery->all()` woła `runOne()`;
  zwraca mapę `slug => wynik`.
- `runOne(Component $component): array` (@return {status, output?, error?}):
    1. jeśli `lock->isUpToDate()` → `['status'=>'up-to-date']`;
    2. `$handle = lock->acquireLock()`; w `finally` zawsze `lock->releaseLock($handle)`;
    3. ponów sprawdzenie `isUpToDate()` (double-check po zajęciu locka) → up-to-date;
    4. `$df = factory->forComponent($component)`;
    5. zbuduj `Symfony\Component\Console\Application` (setAutoExit(false),
       setCatchExceptions(false)), dodaj `MigrateCommand($df)`;
    6. uruchom `migrations:migrate` z `--no-interaction` i `--allow-no-migration`,
       output do `BufferedOutput`;
    7. wyjątek → `['status'=>'error','error'=>msg,'output'=>...]`; exit≠0 →
       `['status'=>'error','error'=>"exit code N",'output'=>...]`;
    8. sukces → `lock->store($component, lock->currentFingerprint($component))`,
       `['status'=>'migrated','output'=>...]`.

## SPECYFIKACJA: bin/migrate

Skrypt CLI uruchamiany ręcznie: `php bin/migrate <komponent> <komenda-doctrine> [opcje]`.
- Shebang `#!/usr/bin/env php`, `declare(strict_types=1)`.
- `define('ROOT', dirname(__DIR__))`; `require ROOT.'/vendor/autoload.php'`;
  `require ROOT.'/core/Config.php'`.
- Zarejestruj prosty autoloader dla klas z `core/db/` (np. `Connection`).
- Ustal host: z `getenv('HTTP_HOST')`, inaczej z argumentu `--host <host>`
  (obsłuż też formę `--host=<host>`), inaczej `_default`. Wywołaj `Config::load($host)`.
- Jeśli `$argc < 2` → wypisz na STDERR użycie z przykładami
  (`migrations:status|migrate|generate`) i `exit(2)`.
- `$componentSlug = $argv[1]`. Przesuń argv tak, by od `$argv[2]` zostały tylko
  argumenty Doctrine (zaktualizuj `$_SERVER['argv']`/`argc` i lokalne `$argv`/`$argc`).
- `$discovery = new ComponentDiscovery(ROOT.'/app')`; `bySlug($componentSlug)`;
  gdy null → STDERR „Nieznany komponent …" + lista dostępnych, `exit(2)`.
- `$factory = new MigratorFactory(fn($key) => Config::get($key))`;
  `$df = $factory->forComponent($component)`.
- `Doctrine\Migrations\Tools\Console\ConsoleRunner::run([], $df)`.

## ZASADY OGÓLNE

- `declare(strict_types=1);` w każdym pliku; przestrzeń `Core\Migrations` (poza bin/migrate).
- Klasy `final` (poza abstrakcyjną `TenantMigration`).
- Komentarze PHPDoc po polsku; komunikaty błędów i użycia po polsku.
- Importy `use` dokładnie tych klas Doctrine/Symfony/PSR, których używasz.

## ZADANIE

1. Wygeneruj wszystkie pliki rdzenia z `core/Migrations/` wg specyfikacji.
2. Wygeneruj skrypt `bin/migrate`.
3. Zadbaj o spójność: `MigratorFactory` musi działać z `Component` z `ComponentDiscovery`
   i wstrzykiwać `TenantMigrationFactory`; `MigrationRunner` musi poprawnie używać
   `SchemaLock` i `MigratorFactory`.
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] Powstały pliki: `core/Migrations/{TenantMigration,TenantMigrationFactory,Component,ComponentDiscovery,DbalConnectionFactory,MigratorFactory,SchemaLock,MigrationRunner}.php` oraz `bin/migrate`.
- [ ] `ComponentDiscovery` wykrywa tylko foldery `app/<X>/` z podkatalogiem `Migrations/`; slug = lowercase nazwy folderu.
- [ ] Tabela śledząca migracje to `<tenant>_migrations_<slug>` (np. `def_migrations_cms`); przy pustym prefiksie — `migrations_<slug>`.
- [ ] `php bin/migrate cms migrations:status` listuje migracje komponentu `cms` (i tworzy tabelę śledzącą przy pierwszym uruchomieniu).
- [ ] `php bin/migrate cms migrations:migrate` wykonuje oczekujące migracje bez błędu; `--no-interaction` nie wymaga potwierdzeń.
- [ ] `php bin/migrate cms migrations:generate` tworzy szkielet `Version<TS>.php` w `app/Cms/Migrations/`.
- [ ] Wybór hosta działa: `php bin/migrate cms migrations:status --host klient1.local` ładuje config klienta (inny `tenant.prefix`).
- [ ] `TenantMigration::table('pages')` zwraca `def_pages` przy prefiksie `def`, a `tenantPrefix()` zwraca `def`.
- [ ] `SchemaLock` zakłada flock i go zwalnia (brak osieroconych `.flock`); `isUpToDate()` reaguje na dodanie nowego pliku `Version*.php`.

## Powiązane
- [040 Rdzeń modeli tabel](040-modele-tabel.md) — modele, których `createTableSql()` wołają migracje CREATE.
- [migracja-tabeli.md](../migracja-tabeli.md) — generator pary model + migracja CREATE dla konkretnej tabeli.
- [docs/architektura/architektura.md §4.4 (System migracji)](../../architektura/architektura.md) i [§9 (Multi-tenant)](../../architektura/architektura.md).
- [docs/bazy-danych.md §3.11 (Nazewnictwo tabel i kolumn)](../../bazy-danych.md#311-konwencja-nazewnictwa-tabel-i-kolumn).
