# 02 — Polityka siły i historii haseł

**Priorytet:** 🟠 Średni · **Trudność implementacji:** Mała

---

## Problem

Obecny panel nie narzuca żadnych wymagań co do siły hasła. Użytkownik może ustawić `123`,
`admin` lub puste hasło — i system je przyjmie. Dodatkowo nie ma zabezpieczenia przed
ponownym użyciem poprzednich haseł.

---

## Rozwiązanie

Dwupoziomowa walidacja:
1. **Siła hasła** — minimalne wymagania przy tworzeniu/zmianie.
2. **Historia haseł** — ostatnie N haszy przechowywane w bazie; nie można ponownie użyć.

---

## Wymagania siły hasła (proponowane)

| Parametr | Wartość domyślna | Klucz konfiguracji |
|---|---|---|
| Minimalna długość | 12 znaków | `password_min_length` |
| Wymagaj cyfry | tak | `password_require_digit` |
| Wymagaj znaku specjalnego | tak | `password_require_special` |
| Wymagaj wielkich liter | nie (opcja) | `password_require_upper` |
| Historia haseł | 5 ostatnich | `password_history_count` |

---

## Implementacja

### Walidacja po stronie serwera (admcore.php)

```php
/**
 * Sprawdza siłę hasła wg polityki z konfiguracji.
 * Zwraca null jeśli OK, lub string z komunikatem błędu.
 */
function validatePasswordStrength(string $password): ?string
{
    $minLen  = (int)(Config::get('password_min_length', 12));
    $digit   = (bool)(Config::get('password_require_digit', true));
    $special = (bool)(Config::get('password_require_special', true));

    if (mb_strlen($password) < $minLen) {
        return "Hasło musi mieć co najmniej {$minLen} znaków.";
    }
    if ($digit && !preg_match('/\d/', $password)) {
        return 'Hasło musi zawierać co najmniej jedną cyfrę.';
    }
    if ($special && !preg_match('/[^a-zA-Z0-9]/', $password)) {
        return 'Hasło musi zawierać co najmniej jeden znak specjalny.';
    }
    return null;
}

/**
 * Sprawdza czy hasło jest w historii ostatnich N haszy użytkownika.
 */
function isPasswordReused(string $userId, string $newPassword): bool
{
    $count = (int)(Config::get('password_history_count', 5));
    if ($count === 0) {
        return false;
    }
    $t    = passwordHistoryTable();
    $pdo  = Connection::get();
    $rows = $pdo->prepare(
        "SELECT PhHash FROM `{$t}` WHERE PhUserID = ?
         ORDER BY PhIDAuto DESC LIMIT {$count}"
    );
    $rows->execute([$userId]);
    foreach ($rows->fetchAll(PDO::FETCH_COLUMN) as $hash) {
        if (password_verify($newPassword, (string)$hash)) {
            return true;
        }
    }
    return false;
}

/**
 * Zapisuje nowy hash do historii; usuwa wpisy ponad limit.
 */
function recordPasswordHistory(string $userId, string $passwordHash): void
{
    $count = (int)(Config::get('password_history_count', 5));
    $t     = passwordHistoryTable();
    $pdo   = Connection::get();
    $pdo->prepare(
        "INSERT INTO `{$t}` (PhID, PhUserID, PhHash)
         VALUES (?, ?, ?)"
    )->execute([uuidv4(), $userId, $passwordHash]);

    // Wyczyść stare ponad limit
    $oldest = $pdo->prepare(
        "SELECT PhID FROM `{$t}` WHERE PhUserID = ?
         ORDER BY PhIDAuto DESC LIMIT 999 OFFSET {$count}"
    );
    $oldest->execute([$userId]);
    foreach ($oldest->fetchAll(PDO::FETCH_COLUMN) as $id) {
        $pdo->prepare("DELETE FROM `{$t}` WHERE PhID = ?")->execute([$id]);
    }
}
```

### Tabela `<tenant>_password_history`

```sql
CREATE TABLE `<tenant>_password_history` (
    `PhID`       CHAR(36)     NOT NULL,
    `PhDateTime` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `PhIDAuto`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `PhUserID`   CHAR(36)     NOT NULL,     -- FK → users.UseID
    `PhHash`     VARCHAR(255) NOT NULL,     -- bcrypt hash
    PRIMARY KEY (`PhID`),
    UNIQUE KEY `uniq_<t>_password_history_idauto` (`PhIDAuto`),
    KEY `idx_<t>_password_history_user` (`PhUserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Użycie przy zmianie hasła

```php
// W admuprawnieniaedit.php (akcja change_password)
$newPassword = (string)($_POST['new_password'] ?? '');
$userId      = (string)$editUser['UseID'];

$error = validatePasswordStrength($newPassword);
if ($error !== null) {
    // Przekieruj z błędem
}
if (isPasswordReused($userId, $newPassword)) {
    // Przekieruj z błędem: "Nie możesz użyć jednego z ostatnich 5 haseł."
}
$hash = password_hash($newPassword, PASSWORD_DEFAULT);
recordPasswordHistory($userId, $hash);
// Zaktualizuj UsePassword w users
```

### Wskaźnik siły hasła (JavaScript)

Prosty wskaźnik po stronie klienta — informacyjny, nie zastępuje walidacji serwera:

```javascript
// Wstrzyknąć do formularza zmiany hasła w widoku
document.getElementById('new_password').addEventListener('input', function () {
    var pw = this.value;
    var score = 0;
    if (pw.length >= 12)              score++;
    if (/\d/.test(pw))                score++;
    if (/[^a-zA-Z0-9]/.test(pw))     score++;
    if (/[A-Z]/.test(pw))             score++;
    var labels = ['Bardzo słabe', 'Słabe', 'Średnie', 'Silne', 'Bardzo silne'];
    var colors = ['#dc2626', '#f97316', '#eab308', '#22c55e', '#16a34a'];
    document.getElementById('pw-strength-label').textContent = labels[score] ?? '';
    document.getElementById('pw-strength-bar').style.width   = (score * 25) + '%';
    document.getElementById('pw-strength-bar').style.background = colors[score] ?? '#ccc';
});
```

---

## Konfiguracja (configs/_default.php)

```php
'password_min_length'      => 12,
'password_require_digit'   => true,
'password_require_special' => true,
'password_history_count'   => 5,   // 0 = wyłączone
```

---

## Uwagi

- Walidacja siły hasła NIE dotyczy konta serwisowego bootstrap (`admin / admin{rok}`) —
  jest i tak wyłączone gdy tabela users nie jest pusta.
- Historia haseł powinna być aktywna od momentu wdrożenia — konta założone wcześniej
  zaczną budować historię przy pierwszej zmianie hasła.
- Nie przechowuj plain-text w historii — tylko bcrypt hash.
