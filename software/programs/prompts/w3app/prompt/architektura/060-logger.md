# Prompt 060: Logger (structured, kanały, poziomy, fallback) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [050 System migracji](050-system-migracji.md) · Następny: [070 Modele aplikacji (appdb)](070-modele-aplikacji-appdb.md) →

Ten krok buduje **warstwę logowania** — `core/Log/Logger.php`: ustrukturyzowany rejestrator wzorowany na NLog (C#). Loguje przez kanały (`Logger::get('Auth')`, `'Gallery'`, `'System'`), filtruje po poziomach (TRACE < DEBUG < INFO < WARN < ERROR < FATAL) z progiem z configu `log_level`, zapisuje rekord per zdarzenie do tabeli `<tenant>_logs` (INSERT), a gdy baza niedostępna — degraduje do `var/logs/app.log`, ostatecznie do `error_log()` PHP. Każdy wpis niesie bogaty kontekst (IP, User-Agent, URI, ID użytkownika, PID, wersja aplikacji, callsite). Wymaga z wcześniejszych kroków: klasy `Config` (`Config::get('log_level')`, `Config::get('tenant')`), połączenia `Connection::get()` (krok 030) oraz klasy `Core\Version`.

Tabelę `<tenant>_logs` opisuje model `App\Appdb\Models\LogsModel` (prefiks kolumn `Log`) — powstaje w kroku [070](070-modele-aplikacji-appdb.md). Logger zna tylko nazwy kolumn (`LogID`, `LogLevel`, …) i wstawia do nich wiersze.

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Wklej do asystenta LLM — prompt jest samowystarczalny.
3. Zapisz wygenerowany plik jako `core/Log/Logger.php`.
4. Zweryfikuj wg sekcji **Weryfikacja** (m.in. wpis do `<tenant>_logs`, fallback do `var/logs/app.log`).

---

## PROMPT
```
Jesteś generatorem warstwy logowania silnika K2 CMS (PHP 8.1+, MySQL 8). Wygeneruj
JEDEN plik PHP: ustrukturyzowany rejestrator zdarzeń wzorowany na NLog (C#).

## KONTEKST PROJEKTU

- K2 CMS jest wielodostępny (multi-tenant): wielu klientów w jednej bazie, izolacja
  przez PREFIKS TENANTA z configu (`tenant.prefix`, np. `def`). Logi trafiają do
  tabeli bieżącego tenanta: `<prefix>_logs` (gdy prefiks pusty → `logs`).
- Dostępne zależności (już istnieją — NIE generuj ich):
    - `Config` (klasa globalna): `Config::get(string $key, $default = null)` zwraca
      wartość configu; `Config::get('log_level')` (string), `Config::get('tenant')`
      (array z `prefix`).
    - `Connection` (klasa globalna): `Connection::get()` zwraca PDO; używasz
      `->prepare($sql)->execute($params)` (zwraca bool).
    - `Core\Version`: `Version::current(): string` — wersja aplikacji (np. `2026.05`).
- Tabela logów ma kolumny z prefiksem `Log` (model App\Appdb\Models\LogsModel):
  LogID, LogLevel, LogLogger, LogMessage, LogException, LogClass, LogMethod,
  LogLineNumber, LogFile, LogProperties, LogHostName, LogProcessId, LogAppVersion,
  LogRequestUri, LogIpAddress, LogUserAgent, LogUserID. Logger zna te nazwy i wstawia
  do nich wiersze (nie tworzy tabeli).

## ŚCIEŻKA

- core/Log/Logger.php   (namespace Core\Log)

## ZASADY NACZELNE

- Logowanie NIGDY nie rzuca wyjątku ani nie przerywa aplikacji. Cała ścieżka logowania
  jest osłonięta `try { … } catch (Throwable) {}`. Błąd INSERT-u → zapis awaryjny
  do `var/logs/app.log`; gdy i to zawiedzie → `error_log()` PHP.
- Poziomy (jak NLog), rosnąco: TRACE < DEBUG < INFO < WARN < ERROR < FATAL. Próg
  filtrowania z `Config::get('log_level', 'TRACE')` (domyślnie TRACE = zapisuj wszystko).
- GUID-y (LogID) powstają w warstwie aplikacji (UUID v4 generowany w PHP).

## SPECYFIKACJA: core/Log/Logger.php

`final class Logger`, `declare(strict_types=1)`, `namespace Core\Log`,
`use Core\Version; use Throwable;`.

Stałe i pola:
- `private const LEVELS` — mapa nazwa→waga: TRACE=0, DEBUG=1, INFO=2, WARN=3, ERROR=4, FATAL=5.
- `private static ?string $userId = null` — ID użytkownika dołączane do kolejnych logów.
- Konstruktor PRYWATNY: `__construct(private readonly string $name)` — nazwa kanału.

Fabryki / konfiguracja statyczna:
- `public static get(string $name = 'app'): self` — logger o nazwie kanału.
- `public static forCurrentClass(): self` — nazwa = klasa wywołująca; ustal ją z
  `debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 2)[1]['class']` (fallback `'app'`).
- `public static setUserId(?string $userId): void` — ustawia `self::$userId`.

Metody poziomów (każda deleguje do prywatnej `log()`):
- `trace/debug/info/warn/error/fatal(string $message, ?Throwable $exception = null,
  array $properties = []): void`.

Globalne handlery:
- `public static registerHandlers(): void` — rejestruje (woła się raz przy starcie):
    - `set_exception_handler` → log kanału 'php', poziom FATAL z wyjątkiem;
    - `set_error_handler` → pomiń błędy wyciszone (`(error_reporting() & $no) === 0`
      → return false); mapuj `$no` na poziom: WARNING→warn, NOTICE/DEPRECATED→debug,
      reszta→error; zaloguj z properties `errno/file/line`; zwróć false (nie tłum);
    - `register_shutdown_function` → `error_get_last()`; dla E_ERROR/E_PARSE/
      E_CORE_ERROR/E_COMPILE_ERROR zaloguj FATAL z properties `file/line`.

Rdzeń (prywatny):
- `private log(string $level, string $message, ?Throwable $exception, array $properties): void`
    — całość w try/catch(Throwable){}. Jeśli `LEVELS[$level] < minLevel()` → return.
      Zbuduj wiersz `buildRow(...)`. Jeśli `insert($row)` zwróci false → `fallback($row)`.
- `private buildRow(...): array` — kontekst callsite z `debug_backtrace(
  DEBUG_BACKTRACE_IGNORE_ARGS, 4)`: `[2]` = miejsce wywołania (line, file),
  `[3]` = klasa+metoda, w której to nastąpiło. Zbuduj asocjacyjny wiersz:
    LogID=uuid(), LogLevel=$level, LogLogger=cut(name,190), LogMessage=$message,
    LogException = $exception!==null ? (string)$exception : null,
    LogClass=cut(context['class'] ?? null,190), LogMethod=cut(context['function'] ?? null,190),
    LogLineNumber = at['line'] ?? null (int), LogFile=cut(at['file'] ?? null,255),
    LogProperties = $properties!==[] ? json_encode($properties, JSON_UNESCAPED_UNICODE) : null,
    LogHostName=cut(gethostname() ?: null,190), LogProcessId=getmypid() ?: null,
    LogAppVersion=cut(Version::current(),20),
    LogRequestUri=cut($_SERVER['REQUEST_URI'] ?? null,500),
    LogIpAddress=cut($_SERVER['REMOTE_ADDR'] ?? null,45),
    LogUserAgent=cut($_SERVER['HTTP_USER_AGENT'] ?? null,500),
    LogUserID=self::$userId.
- `private insert(array $row): bool` — w try/catch(Throwable){ return false }:
    zbuduj `INSERT INTO <table()> (kolumny) VALUES (?, ?, …)` z `array_keys/array_fill`;
    `return \Connection::get()->prepare($sql)->execute(array_values($row))`.
- `private fallback(array $row): void` — sformatuj jedną linię:
    `[Y-m-d H:i:s] LEVEL  Logger | Message[ | EXC: <wyjątek w jednej linii>]`;
    katalog `dirname(__DIR__, 2) . '/var/logs'`; utwórz gdy trzeba (`@mkdir(...,0775,true)`);
    dopisz do `app.log` (`@file_put_contents(..., FILE_APPEND | LOCK_EX)`); gdy to zawiedzie
    → `error_log('K2LOG ' . trim($line))`.
- `private minLevel(): int` — `LEVELS[strtoupper(Config::get('log_level','TRACE'))]
   ?? LEVELS['TRACE']`.
- `private static table(): string` — prefiks z `Config::get('tenant')['prefix']`;
   `<prefix>_logs` lub `logs` przy pustym.
- `private static uuid(): string` — UUID v4 z `random_bytes(16)` (ustaw warianty bitów
   wersji/wariantu), sformatuj `8-4-4-4-12`.
- `private static cut(?string $value, int $max): ?string` — przytnij `mb_substr` do `$max`;
   null bez zmian.

## API UŻYCIA (do uwzględnienia w PHPDoc klasy)

  $log = Logger::get('Auth');
  $log->info('Użytkownik zalogowany', properties: ['login' => $login]);
  $log->warn('Nieudana próba logowania', properties: ['login' => $login, 'ip' => $ip]);
  $log->error('Nie udało się wysłać', $exception);
  Logger::setUserId($userId);
  Logger::registerHandlers(); // raz przy starcie aplikacji

## ZASADY OGÓLNE

- `declare(strict_types=1);`, `final class`, prywatny konstruktor.
- Komentarze PHPDoc po polsku, zwięzłe.
- Sygnatury metod poziomów: `(string $message, ?Throwable $exception = null,
  array $properties = [])` — argument nazwany `properties:` musi działać.

## ZADANIE

1. Wygeneruj kompletny `core/Log/Logger.php` wg specyfikacji.
2. Zadbaj, by żadna ścieżka logowania nie mogła wywrócić aplikacji (try/catch wokół
   `log()` i wokół `insert()`).
3. Callsite (LogClass/LogMethod/LogLineNumber/LogFile) musi wskazywać miejsce wywołania
   metody poziomu, nie wnętrze Loggera.
Zwróć tylko plik, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] Powstał plik `core/Log/Logger.php` w przestrzeni `Core\Log`, klasa `final` z prywatnym konstruktorem.
- [ ] Kanały: `Logger::get('Auth'|'Gallery'|'System'|…)` ustawiają kolumnę `LogLogger`; `forCurrentClass()` nazywa logger wg klasy wywołującej.
- [ ] Poziomy TRACE<DEBUG<INFO<WARN<ERROR<FATAL; `Config::get('log_level')` ustawia próg (np. `WARN` ⇒ INFO i niższe są pomijane).
- [ ] `Logger::get('System')->info('test', properties: ['k'=>'v'])` wstawia wiersz do `<tenant>_logs` z `LogProperties` jako JSON (UTF-8 bez escapowania).
- [ ] Wiersz zawiera kontekst: `LogIpAddress`, `LogUserAgent`, `LogRequestUri`, `LogProcessId`, `LogAppVersion`, `LogHostName`, `LogUserID` oraz callsite (`LogClass`/`LogMethod`/`LogLineNumber`/`LogFile`).
- [ ] `Logger::setUserId('…')` dokleja `LogUserID` do kolejnych logów.
- [ ] Fallback: gdy baza niedostępna, wpis trafia do `var/logs/app.log`; gdy i to zawiedzie — do `error_log()` z prefiksem `K2LOG`.
- [ ] Logowanie nie rzuca wyjątku nawet przy błędnym połączeniu/configu (cała ścieżka osłonięta).
- [ ] `Logger::registerHandlers()` przechwytuje nieobsłużone wyjątki (FATAL), błędy PHP (mapowanie na poziom) i błędy fatalne w shutdown.
- [ ] Wartości dłuższe niż limit kolumny są przycinane (`LogLogger` 190, `LogFile` 255, `LogRequestUri`/`LogUserAgent` 500, `LogIpAddress` 45, `LogAppVersion` 20).

## Powiązane
- [070 Modele aplikacji (appdb)](070-modele-aplikacji-appdb.md) — `LogsModel` definiujący tabelę `<tenant>_logs`, do której Logger wstawia wiersze.
- [030 Połączenie z bazą](030-polaczenie-z-baza.md) — `Connection::get()` używane przez `insert()`.
- [docs/architektura/architektura.md §4.3 (Logger)](../../architektura/architektura.md).
