# Logowanie zdarzeń

Mechanizm rejestrowania zdarzeń w stylu **NLog** (C#). Klasa
[core/Log/Logger.php](../core/Log/Logger.php) (`Core\Log\Logger`) zapisuje
structured logi do tabeli `<tenant>_logs`.

Struktura tabeli: [docs/changelog-db.md](changelog-db.md) (komponent `appdb`,
model [LogsModel](../app/Appdb/Models/LogsModel.php)).

---

## 1. Szybki start

```php
use Core\Log\Logger;

$log = Logger::get('Auth');

$log->info('Użytkownik zalogowany', properties: ['login' => $login]);
$log->warn('Nietypowy adres IP', properties: ['ip' => $ip]);
$log->error('Nie udało się wysłać e-maila', $exception);
```

Logger wymaga załadowanego `Config` i działającego `Connection` (jak każdy
entrypoint projektu). Klasa jest autoładowana przez Composera (PSR-4 `Core\`).

---

## 2. Poziomy

Jak w NLog, w kolejności ważności:

| Metoda | Poziom | Zastosowanie |
|---|---|---|
| `trace()` | TRACE | Bardzo szczegółowy ślad wykonania. |
| `debug()` | DEBUG | Informacje diagnostyczne. |
| `info()`  | INFO  | Normalne zdarzenia biznesowe. |
| `warn()`  | WARN  | Sytuacje nietypowe, ale nieprzerywające pracy. |
| `error()` | ERROR | Błędy operacji. |
| `fatal()` | FATAL | Błędy krytyczne. |

Każda metoda ma tę samą sygnaturę:

```php
function level(string $message, ?Throwable $exception = null, array $properties = []): void
```

Argument `properties` najwygodniej podać przez argument nazwany:
`$log->info('...', properties: ['klucz' => 'wartość'])`.

---

## 3. Tworzenie loggera

```php
Logger::get('NazwaKanału');   // logger o jawnej nazwie kanału (kolumna LogLogger)
Logger::forCurrentClass();    // nazwa = klasa wywołująca — jak NLog GetCurrentClassLogger()
```

---

## 4. Co trafia do logu

Dla każdego wpisu Logger wypełnia automatycznie:

- **poziom, kanał, wiadomość** — argumenty wywołania,
- **wyjątek** (`LogException`) — pełna treść `Throwable` (komunikat + stack trace),
- **callsite** — `LogClass` / `LogMethod` / `LogLineNumber` / `LogFile`, czyli
  miejsce w kodzie, z którego wywołano logger (przez `debug_backtrace()`),
- **kontekst** — `properties` jako JSON, nazwa hosta, PID procesu, wersja
  aplikacji ([Core\Version](../core/Version.php)),
- **kontekst HTTP** — URI żądania, adres IP, User-Agent (jeśli log z requestu),
- **`LogUserID`** — jeśli ustawiono `Logger::setUserId('<UseID>')`.

```php
Logger::setUserId($userId);   // np. po zalogowaniu — dopina się do kolejnych logów
```

---

## 5. Konfiguracja

Klucz `log_level` w configu tenanta ustala minimalny zapisywany poziom — wpisy
poniżej progu są pomijane:

```php
// configs/_default.php
'log_level' => 'INFO',   // TRACE | DEBUG | INFO | WARN | ERROR | FATAL
```

Domyślnie `TRACE` — zapisywane jest wszystko.

---

## 6. Globalne przechwytywanie błędów (opcjonalne)

```php
Logger::registerHandlers();
```

Rejestruje handlery, które automatycznie logują:

- nieobsłużone wyjątki → `FATAL`,
- błędy PHP → `WARN` / `DEBUG` / `ERROR` (wg wagi błędu),
- błędy fatalne (przez `register_shutdown_function`) → `FATAL`.

Wywołać raz, przy starcie aplikacji (np. w entrypoincie).

---

## 7. Odporność

Logowanie **nigdy nie rzuca wyjątku ani nie przerywa aplikacji**. Gdy zapis do
bazy się nie powiedzie (np. baza niedostępna), wpis trafia awaryjnie do pliku
`var/logs/app.log`, a gdyby i to zawiodło — do logu błędów PHP (`error_log`).

---

## 8. Przeglądanie logów

```sql
-- Ostatnie błędy
SELECT LogDateTime, LogLevel, LogLogger, LogMessage, LogClass, LogMethod, LogLineNumber
FROM def_logs
WHERE LogLevel IN ('ERROR', 'FATAL')
ORDER BY LogDateTime DESC
LIMIT 50;

-- Błędy z ostatniej godziny (indeks compound idx_<tenant>_logs_level_datetime)
SELECT * FROM def_logs
WHERE LogLevel = 'ERROR' AND LogDateTime >= NOW() - INTERVAL 1 HOUR;
```
