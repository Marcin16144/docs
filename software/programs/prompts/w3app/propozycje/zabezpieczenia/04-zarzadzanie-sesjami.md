# 04 — Zarządzanie aktywnymi sesjami

**Priorytet:** 🟠 Średni · **Trudność implementacji:** Średnia

---

## Problem

Obecnie panel nie śledzi aktywnych sesji. Nie można:
- zobaczyć skąd jesteś zalogowany (IP, urządzenie, czas),
- wylogować zdalnie konkretnej sesji (np. po kradzieży laptopa),
- wykryć sesji aktywnych równolegle z dwóch lokalizacji.

Jeśli atakujący przejmie `PHPSESSID` (XSS, sniffer na niezaszyfrowanym połączeniu,
dostęp fizyczny do komputera), może działać równolegle z prawdziwym użytkownikiem —
nikt tego nie zobaczy.

---

## Rozwiązanie

Tabela aktywnych sesji w bazie danych. Przy każdym zalogowaniu — INSERT. Przy każdym
żądaniu — UPDATE czasu ostatniej aktywności. Przy wylogowaniu — DELETE. Widok
w panelu „Moje sesje" z możliwością wylogowania wybranej sesji.

---

## Implementacja

### Tabela `<tenant>_sessions`

```sql
CREATE TABLE `<tenant>_sessions` (
    `SessID`        CHAR(36)     NOT NULL,
    `SessDateTime`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `SessIDAuto`    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `SessToken`     CHAR(64)     NOT NULL,          -- SHA-256(PHPSESSID)
    `SessUserID`    CHAR(36)     NOT NULL,
    `SessIp`        VARCHAR(45)  NOT NULL,
    `SessUserAgent` VARCHAR(500) NULL,
    `SessLastSeen`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `SessCreatedAt` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`SessID`),
    UNIQUE KEY `uniq_<t>_sessions_idauto`  (`SessIDAuto`),
    UNIQUE KEY `uniq_<t>_sessions_token`   (`SessToken`),
    KEY `idx_<t>_sessions_user` (`SessUserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

`SessToken = SHA-256(session_id())` — nie przechowujemy surowego ID sesji.

### Funkcje (admcore.php)

```php
function sessionsTable(): string
{
    $prefix = (string)(Config::get('tenant')['prefix'] ?? '');
    return $prefix === '' ? 'sessions' : "{$prefix}_sessions";
}

/** Rejestruje sesję po zalogowaniu. */
function sessionRegister(string $userId): void
{
    try {
        $t     = sessionsTable();
        $token = hash('sha256', session_id());
        Connection::get()->prepare(
            "INSERT INTO `{$t}` (SessID, SessToken, SessUserID, SessIp, SessUserAgent)
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE SessLastSeen = NOW(), SessIp = VALUES(SessIp)"
        )->execute([
            uuidv4(), $token, $userId,
            (string)($_SERVER['REMOTE_ADDR'] ?? ''),
            mb_substr((string)($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 500),
        ]);
    } catch (\Throwable) {}
}

/** Odświeża czas ostatniej aktywności sesji (wywoływać przy każdym żądaniu). */
function sessionTouch(): void
{
    try {
        $t     = sessionsTable();
        $token = hash('sha256', session_id());
        Connection::get()->prepare(
            "UPDATE `{$t}` SET SessLastSeen = NOW(), SessIp = ?
             WHERE SessToken = ?"
        )->execute([(string)($_SERVER['REMOTE_ADDR'] ?? ''), $token]);
    } catch (\Throwable) {}
}

/** Usuwa bieżącą sesję z tabeli (przy wylogowaniu). */
function sessionRevoke(): void
{
    try {
        $t     = sessionsTable();
        $token = hash('sha256', session_id());
        Connection::get()->prepare(
            "DELETE FROM `{$t}` WHERE SessToken = ?"
        )->execute([$token]);
    } catch (\Throwable) {}
}

/** Usuwa konkretną sesję użytkownika (zdalne wylogowanie). */
function sessionRevokeById(string $sessId, string $currentUserId): void
{
    try {
        $t = sessionsTable();
        // Można wylogować tylko własne sesje
        Connection::get()->prepare(
            "DELETE FROM `{$t}` WHERE SessID = ? AND SessUserID = ?"
        )->execute([$sessId, $currentUserId]);
    } catch (\Throwable) {}
}

/** Lista aktywnych sesji użytkownika (do widoku). */
function listUserSessions(string $userId): array
{
    try {
        $t    = sessionsTable();
        $stmt = Connection::get()->prepare(
            "SELECT SessID, SessIp, SessUserAgent, SessCreatedAt, SessLastSeen,
                    SessToken = ? AS IsCurrent
             FROM `{$t}` WHERE SessUserID = ?
             ORDER BY SessLastSeen DESC"
        );
        $stmt->execute([hash('sha256', session_id()), $userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC) ?: [];
    } catch (\Throwable) {
        return [];
    }
}
```

### Integracja z index.php

```php
// Po udanym logowaniu:
session_regenerate_id(true);
sessionRegister($_SESSION['admin_uid']);   // ← dodać

// Przy każdym żądaniu zalogowanego:
if (!empty($_SESSION['admin'])) {
    sessionTouch();                        // ← dodać
    // … idle-timeout check …
}

// Przy wylogowaniu:
sessionRevoke();                           // ← dodać
$_SESSION = [];
session_destroy();
```

### Czyszczenie wygasłych sesji

Cron job lub lazy cleanup przy każdym żądaniu (1% szansa):

```php
if (random_int(1, 100) === 1) {
    $t = sessionsTable();
    Connection::get()->exec(
        "DELETE FROM `{$t}` WHERE SessLastSeen < NOW() - INTERVAL 3 HOUR"
    );
}
```

---

## Widok w panelu

Nowy ekran „Moje sesje" (np. w sekcji konta użytkownika):

```
┌─────────┬──────────────┬───────────────────┬──────────────────┬────────┐
│ IP      │ Przeglądarka │ Zalogowano         │ Ostatnia aktyw.  │ Akcja  │
├─────────┼──────────────┼───────────────────┼──────────────────┼────────┤
│ 192.0.x │ Chrome / Win │ 23.05.2026 10:00  │ teraz            │ (tu)   │
│ 10.0.x  │ Firefox/ Mac │ 22.05.2026 18:30  │ 22.05 18:45      │ Wylog. │
└─────────┴──────────────┴───────────────────┴──────────────────┴────────┘
```

Przycisk „Wyloguj wszystkie inne sesje" — jednym kliknięciem przejęcie kontroli.

---

## Opcja: wykrywanie zmiany IP

Opcjonalne ostrzeżenie gdy bieżąca sesja zmienia IP w trakcie trwania (może być
nat, VPN, atak session hijacking):

```php
if ($_SESSION['admin_ip'] ?? '' !== ($_SERVER['REMOTE_ADDR'] ?? '')) {
    Logger::get('Auth')->warn('Sesja — zmiana IP', properties: [
        'old_ip' => $_SESSION['admin_ip'],
        'new_ip' => $_SERVER['REMOTE_ADDR'],
    ]);
    // Opcjonalnie: wymagaj ponownego logowania
}
$_SESSION['admin_ip'] = $_SERVER['REMOTE_ADDR'] ?? '';
```
