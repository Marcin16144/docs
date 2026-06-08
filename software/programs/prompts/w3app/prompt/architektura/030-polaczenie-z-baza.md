# Prompt 030: Połączenie z bazą (PDO + sterowniki) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [020 Konfiguracja i multi-tenant](020-konfiguracja-i-multitenant.md) · Następny: [040 …](040-modele-tabel.md) →

Ten krok buduje **warstwę połączenia z bazą**: singleton `core/Connection.php` (jedno PDO per żądanie + fabryka sterowników) oraz interfejs `core/db/Driver.php` i jego implementacje `MySqlDriver`, `PgSqlDriver`, `SqliteDriver`. Wymaga konfiguracji z kroku 020 (`Config::get('db')` zwraca parametry połączenia) oraz bootstrapu z kroku 010 (`spl_autoload_register` ładuje klasy z `core/db/`). Po nim `Connection::get()` zwraca gotowe PDO; kolejny krok (040) zacznie definiować modele i migracje tabel.

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Ten krok jest samowystarczalny — `## DANE WEJŚCIOWE` nie są potrzebne (parametry połączenia pochodzą z configu z kroku 020).
3. Wklej do asystenta LLM. Otrzymasz: `core/Connection.php`, `core/db/Driver.php`, `core/db/MySqlDriver.php`, `core/db/PgSqlDriver.php`, `core/db/SqliteDriver.php`.
4. Zapisz pliki wg **ŚCIEŻEK**.
5. Zweryfikuj wg sekcji **Weryfikacja** (np. tymczasowy `index.php` z kroku 010 wypisze „Połączenie z bazą: OK").

---

## PROMPT

```
Jesteś generatorem warstwy połączenia z bazą danych silnika K2 CMS.
Wygeneruj singleton PDO (core/Connection.php) z fabryką sterowników oraz
abstrakcyjny sterownik (core/db/Driver.php) i trzy implementacje:
MySqlDriver, PgSqlDriver, SqliteDriver.

## KONTEKST PROJEKTU

- PHP 8.1+. Połączenie z bazą realizowane przez PDO.
- Parametry połączenia pochodzą z konfiguracji: Config::get('db') zwraca tablicę
  z kluczami: driver, host, port, database, username, password, charset.
  (Config jest ładowany wcześniej przez Config::load($_SERVER['HTTP_HOST']).)
- Klasy z core/db/ są GLOBALNE (bez namespace) — ładowane przez spl_autoload_register
  z bootstrapu (index.php): require ROOT . '/core/db/<Class>.php'. NIE dodawaj namespace
  ani PSR-4 do tych klas.
- core/Connection.php jest dołączany bezpośrednio w bootstrapie (require), klasa Connection
  też jest globalna (bez namespace).
- Wspierane sterowniki: mysql (domyślny), pgsql, sqlite. MySQL używa utf8mb4.

## ŚCIEŻKI

- core/Connection.php       (klasa Connection — globalna)
- core/db/Driver.php        (abstrakcyjna klasa bazowa Driver — globalna)
- core/db/MySqlDriver.php   (class MySqlDriver extends Driver)
- core/db/PgSqlDriver.php   (class PgSqlDriver extends Driver)
- core/db/SqliteDriver.php  (class SqliteDriver extends Driver)

## KONWENCJE / ZASADY

1. Connection to singleton: private static ?PDO $instance = null.
   - Connection::get(): PDO — przy pierwszym wywołaniu tworzy PDO z Config::get('db'),
     potem zwraca tę samą instancję.
   - Connection::reset(): void — zeruje instancję (na potrzeby testów).
   - Mapa sterowników jako stała: 'mysql' => MySqlDriver::class, 'pgsql' => PgSqlDriver::class,
     'sqlite' => SqliteDriver::class.
   - create(array $cfg): PDO — pobiera klasę sterownika z mapy (nieznany driver →
     InvalidArgumentException z nazwą drivera), tworzy instancję, zwraca
     new PDO($driver->dsn($cfg), $cfg['username'] ?? null, $cfg['password'] ?? null,
     $driver->options()).

2. Driver (abstrakcyjna klasa bazowa):
   - abstract public function dsn(array $cfg): string;
   - public function options(): array — wspólne opcje PDO:
       PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
       PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
       PDO::ATTR_EMULATE_PREPARES   => false,

3. DSN-y:
   - MySQL: "mysql:host=%s;port=%d;dbname=%s;charset=%s" (charset domyślnie utf8mb4,
     host domyślnie localhost, port domyślnie 3306).
   - PgSQL: "pgsql:host=%s;port=%d;dbname=%s" (host domyślnie localhost, port domyślnie
     5432; brak charset w DSN).
   - SQLite: "sqlite:<ścieżka>". Jeśli ścieżka nie jest pusta, nie jest ':memory:'
     i nie jest absolutna (Windows "C:\..." / "C:/..." ani Unix "/..."), traktuj ją jako
     względną do ROOT: ROOT . '/' . ltrim($path, '/\\').

## SZABLON / KOD  (PEŁNE docelowe kody — odtwórz wiernie)

### core/Connection.php
<?php

declare(strict_types=1);

class Connection
{
    private const DRIVERS = [
        'mysql'  => MySqlDriver::class,
        'pgsql'  => PgSqlDriver::class,
        'sqlite' => SqliteDriver::class,
    ];

    private static ?PDO $instance = null;

    public static function get(): PDO
    {
        if (self::$instance === null) {
            self::$instance = self::create(Config::get('db'));
        }

        return self::$instance;
    }

    private static function create(array $cfg): PDO
    {
        $driverClass = self::DRIVERS[$cfg['driver']] ?? throw new \InvalidArgumentException(
            "Nieobsługiwany driver: {$cfg['driver']}"
        );

        /** @var Driver $driver */
        $driver = new $driverClass();

        return new PDO(
            $driver->dsn($cfg),
            $cfg['username'] ?? null,
            $cfg['password'] ?? null,
            $driver->options()
        );
    }

    public static function reset(): void
    {
        self::$instance = null;
    }
}

### core/db/Driver.php
<?php

declare(strict_types=1);

abstract class Driver
{
    abstract public function dsn(array $cfg): string;

    public function options(): array
    {
        return [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];
    }
}

### core/db/MySqlDriver.php
<?php

declare(strict_types=1);

class MySqlDriver extends Driver
{
    public function dsn(array $cfg): string
    {
        return sprintf(
            'mysql:host=%s;port=%d;dbname=%s;charset=%s',
            $cfg['host']    ?? 'localhost',
            $cfg['port']    ?? 3306,
            $cfg['database'],
            $cfg['charset'] ?? 'utf8mb4'
        );
    }
}

### core/db/PgSqlDriver.php
<?php

declare(strict_types=1);

class PgSqlDriver extends Driver
{
    public function dsn(array $cfg): string
    {
        return sprintf(
            'pgsql:host=%s;port=%d;dbname=%s',
            $cfg['host'] ?? 'localhost',
            $cfg['port'] ?? 5432,
            $cfg['database']
        );
    }
}

### core/db/SqliteDriver.php
<?php

declare(strict_types=1);

class SqliteDriver extends Driver
{
    public function dsn(array $cfg): string
    {
        $path = $cfg['database'] ?? '';

        if ($path !== '' && $path !== ':memory:' && !preg_match('#^([a-zA-Z]:[\\\\/]|/)#', $path)) {
            $path = ROOT . '/' . ltrim($path, '/\\');
        }

        return 'sqlite:' . $path;
    }
}

## ZADANIE

1. Wygeneruj core/Connection.php — wiernie wg sekcji SZABLON / KOD.
2. Wygeneruj core/db/Driver.php — wiernie wg sekcji SZABLON / KOD.
3. Wygeneruj core/db/MySqlDriver.php, core/db/PgSqlDriver.php, core/db/SqliteDriver.php
   — wiernie wg sekcji SZABLON / KOD.
4. Wszystkie klasy bez namespace (globalne). Każdy plik poprzedź jedną linią-komentarzem
   ze ścieżką, np. "// === core/Connection.php ===".
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] `Connection::get()` zwraca instancję `PDO` zbudowaną z `Config::get('db')`; ponowne wywołanie zwraca ten sam obiekt (singleton).
- [ ] `Connection::reset()` zeruje instancję — kolejne `get()` tworzy nowe PDO (przydatne w testach).
- [ ] Nieznany `driver` w configu → `InvalidArgumentException` z nazwą drivera.
- [ ] DSN MySQL zawiera `charset=utf8mb4`; opcje PDO: `ERRMODE_EXCEPTION`, `FETCH_ASSOC`, `EMULATE_PREPARES => false`.
- [ ] DSN PgSQL: `pgsql:host=…;port=5432;dbname=…` (bez charset); DSN SQLite: `sqlite:<ścieżka>`.
- [ ] SQLite ze ścieżką względną rozwija się do `ROOT/<ścieżka>`; `:memory:` i ścieżki absolutne (Windows/Unix) zostają bez zmian.
- [ ] Tymczasowy `index.php` z kroku 010 wypisuje „Połączenie z bazą: OK" przy poprawnej konfiguracji bazy.
- [ ] Wszystkie klasy są globalne (bez namespace) i ładują się przez `spl_autoload_register` z bootstrapu.

## Powiązane
- [docs/architektura/architektura.md §4.2 (Connection)](../../architektura/architektura.md)
- [Poprzedni krok: 020 Konfiguracja i multi-tenant](020-konfiguracja-i-multitenant.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
- [Powiązany prompt: nowa tabela (model + migracja)](../migracja-tabeli.md)
