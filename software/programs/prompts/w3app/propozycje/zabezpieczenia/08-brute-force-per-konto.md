# 08 — Brute-force per konto (nie tylko per IP)

**Priorytet:** 🟠 Średni · **Trudność implementacji:** Mała

---

## Problem

Obecny rate limiting (1.3) blokuje ataki per **adres IP**. Chronią przed tym scenariuszem:

```
Jeden atakujący, jeden IP → 10 prób → blokada 15 min
```

Nie chronią przed:

### Scenariusz 1: Distributed brute-force (botnet)

```
Bot 1 (IP: 1.2.3.4)  → 5 prób na konto "admin"
Bot 2 (IP: 5.6.7.8)  → 5 prób na konto "admin"
Bot 3 (IP: 9.0.1.2)  → 5 prób na konto "admin"
...
```

Każdy IP jest poniżej limitu. Konto `admin` może być atakowane bez ograniczeń.

### Scenariusz 2: Credential stuffing

Atakujący ma wyciek 1000 par login:hasło z innego serwisu. Testuje każdą parę z innego IP.
Żaden IP nie przekroczy limitu, ale konto może zostać przejęte.

---

## Rozwiązanie

Dodatkowy licznik per **nazwa konta** — niezależnie od IP. Limit mniej restrykcyjny
niż per-IP (wyższy próg, dłuższe okno), bo konto może być atakowane z wielu lokalizacji.

Proponowane parametry:
- **Limit:** 20 nieudanych prób na konto
- **Okno:** 1 godzina
- **Blokada:** 30 minut (i/lub powiadomienie e-mail)

---

## Implementacja

### Rozszerzenie tabeli `<tenant>_login_attempts`

Zamiast nowej tabeli — dodaj kolumnę do istniejącej lub stwórz osobną tabelę
`<tenant>_login_attempts_account`:

```sql
-- Opcja A: osobna tabela (czystsza separacja)
CREATE TABLE `<tenant>_login_attempts_account` (
    `LaaBucket`  VARCHAR(64)  NOT NULL,   -- SHA-256(lowercase(login))
    `LaaCount`   INT UNSIGNED NOT NULL DEFAULT 1,
    `LaaFirstAt` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`LaaBucket`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Opcja B: dodaj kolumny do istniejącej login_attempts
-- LaBucket (IP) zostaje, dodajemy:
ALTER TABLE `<tenant>_login_attempts`
    ADD COLUMN `LaLogin`      VARCHAR(64)  NULL,   -- SHA-256(login)
    ADD COLUMN `LaLoginCount` INT UNSIGNED NULL DEFAULT 0;
```

### Funkcje (admcore.php)

```php
/**
 * Sprawdza czy konkretne konto jest zablokowane (zbyt wiele prób z różnych IP).
 * Limit: 20 prób / 1 godzina.
 */
function loginAccountIsBlocked(string $login): bool
{
    try {
        $pdo    = Connection::get();
        $bucket = hash('sha256', mb_strtolower(trim($login)));
        $t      = loginAttemptsAccountTable();  // osobna tabela

        $stmt = $pdo->prepare(
            "SELECT LaaCount, LaaFirstAt FROM `{$t}` WHERE LaaBucket = ? LIMIT 1"
        );
        $stmt->execute([$bucket]);
        $rec = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$rec) {
            return false;
        }
        $windowAge = time() - (int) strtotime((string) $rec['LaaFirstAt']);
        if ($windowAge >= 3600) {
            loginAccountClearFailures($login);
            return false;
        }
        return (int) $rec['LaaCount'] >= 20;
    } catch (\Throwable) {
        return false;   // fail-open
    }
}

function loginAccountRecordFailure(string $login): void
{
    try {
        $pdo    = Connection::get();
        $bucket = hash('sha256', mb_strtolower(trim($login)));
        $t      = loginAttemptsAccountTable();

        $pdo->prepare(
            "INSERT INTO `{$t}` (LaaBucket, LaaCount, LaaFirstAt)
             VALUES (?, 1, NOW())
             ON DUPLICATE KEY UPDATE LaaCount = LaaCount + 1"
        )->execute([$bucket]);

        // Powiadomienie przy osiągnięciu progu (opcjonalnie)
        $stmt = $pdo->prepare("SELECT LaaCount FROM `{$t}` WHERE LaaBucket = ?");
        $stmt->execute([$bucket]);
        $count = (int)($stmt->fetchColumn() ?: 0);
        if ($count === 10 || $count === 20) {
            securityAlert("Podejrzane próby logowania na konto ({$count} prób)", [
                'login_bucket' => substr($bucket, 0, 8) . '…',   // nie ujawniamy pełnego loginu
            ]);
        }
    } catch (\Throwable) {}
}

function loginAccountClearFailures(string $login): void
{
    try {
        $pdo    = Connection::get();
        $bucket = hash('sha256', mb_strtolower(trim($login)));
        $t      = loginAttemptsAccountTable();
        $pdo->prepare("DELETE FROM `{$t}` WHERE LaaBucket = ?")->execute([$bucket]);
    } catch (\Throwable) {}
}

function loginAttemptsAccountTable(): string
{
    $prefix = (string)(Config::get('tenant')['prefix'] ?? '');
    return $prefix === '' ? 'login_attempts_account' : "{$prefix}_login_attempts_account";
}
```

### Integracja z index.php (logowanie)

```php
if (($_POST['hp_phone'] ?? '') !== '') {
    // honeypot
} elseif (loginIsBlocked($clientIp)) {
    // rate limit per IP
} elseif (loginAccountIsBlocked($login)) {         // ← nowe
    Logger::get('Auth')->warn('Konto zablokowane (distributed brute-force)', properties: [
        'login' => $login,
        'ip'    => $clientIp,
    ]);
    $loginError = 'Zbyt wiele nieudanych prób. Poczekaj 30 minut i spróbuj ponownie.';
} else {
    $authUser = authenticate($login, $password);
    if ($authUser !== null) {
        loginClearFailures($clientIp);
        loginAccountClearFailures($login);            // ← nowe
        // … sesja …
    } else {
        loginRecordFailure($clientIp);
        loginAccountRecordFailure($login);            // ← nowe
        $loginError = 'Niepoprawny login lub hasło.';
    }
}
```

---

## Porównanie obu poziomów rate limitingu

| Parametr | Per IP (1.3) | Per konto (nowe) |
|---|---|---|
| Klucz bucketu | SHA-256(IP) | SHA-256(lowercase(login)) |
| Limit prób | 10 | 20 |
| Okno | 15 min | 60 min |
| Chroni przed | jednym atakującym | botnetem na jedno konto |
| Blokuje po limicie | tak | tak |

---

## Uwagi

- **Atak DoS na konto:** atakujący może celowo blokować konto legalnego użytkownika
  przez wielokrotne próby z fałszywym loginem. Dlatego limit per-konto powinien być
  wyższy (20+) i okno dłuższe (60 min) niż per-IP — żeby utrudnić celowe blokowanie.
- **Konto `admin`:** konto serwisowe bootstrap jest szczególnie wrażliwe. Rozważ
  całkowite wyłączenie konta serwisowego (wymóg min. jednego konta w `<t>_users`)
  lub stały, niski limit per konto `admin`.
- Buckety loginów są SHA-256 — nie przechowujemy loginów plain-text w tabeli prób.
  Przy bardzo dużym wycieku bazy `login_attempts_account` atakujący musiałby odwrócić
  SHA-256 każdego loginu z osobna.
