# 01 — Dwuetapowe logowanie (2FA / TOTP)

**Priorytet:** 🔴 Wysoki · **Trudność implementacji:** Duża

---

## Problem

Hasło to pojedynczy czynnik uwierzytelnienia. Jeśli wycieknie (phishing, reuse z innego
serwisu, keylogger), atakujący ma pełen dostęp do panelu. Dwuetapowe logowanie (2FA)
wymaga czegoś, co użytkownik **posiada** (telefon) — nawet znając hasło, atakujący
nie zaloguje się bez drugiego czynnika.

---

## Rozwiązanie — TOTP (RFC 6238)

TOTP (Time-based One-Time Password) generuje 6-cyfrowy kod zmieniający się co 30 sekund.
Kompatybilny z: Google Authenticator, Authy, Microsoft Authenticator, Bitwarden.

Algorytm: `HMAC-SHA1(shared_secret, floor(timestamp / 30))` — obliczalny offline.

### Przepływ logowania z 2FA

```
1. Użytkownik podaje login + hasło → poprawne
2. Sprawdzamy czy konto ma włączone 2FA
   a. NIE → logujemy (dotychczasowe zachowanie)
   b. TAK → przekierowanie na ekran TOTP (sesja w stanie "pre-auth")
3. Użytkownik podaje 6-cyfrowy kod z aplikacji
4. Serwer weryfikuje TOTP → poprawny → sesja staje się "auth"
```

### Stan "pre-auth"

```php
// Po poprawnym haśle, jeśli konto ma 2FA:
$_SESSION['admin_2fa_pending'] = true;
$_SESSION['admin_2fa_user']   = $authUser;
// NIE ustawiamy $_SESSION['admin'] = true
header('Location: ' . $panelUrl . '?_step=2fa');
exit;
```

---

## Implementacja

### Tabela `<tenant>_user_2fa`

```sql
CREATE TABLE `<tenant>_user_2fa` (
    `TfaID`       CHAR(36)     NOT NULL,
    `TfaDateTime` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `TfaIDAuto`   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `TfaUserID`   CHAR(36)     NOT NULL,          -- FK → users.UseID
    `TfaSecret`   VARCHAR(64)  NOT NULL,          -- Base32 shared secret
    `TfaEnabled`  TINYINT(1)   NOT NULL DEFAULT 0,
    `TfaVerified` TINYINT(1)   NOT NULL DEFAULT 0, -- potwierdzone przez użytkownika
    `TfaBackupCodes` TEXT      NULL,              -- JSON — kody awaryjne (jednorazowe)
    PRIMARY KEY (`TfaID`),
    UNIQUE KEY `uniq_<t>_user_2fa_idauto` (`TfaIDAuto`),
    UNIQUE KEY `uniq_<t>_user_2fa_user` (`TfaUserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Biblioteka PHP

Zamiast pisać TOTP od zera użyj `spomky-labs/otphp` (PSR-compatible, bez zależności
zewnętrznych w runtime):

```bash
composer require spomky-labs/otphp
```

Lub zaimplementuj ręcznie (TOTP to ~30 linii PHP):

```php
function totpGenerate(string $secret, int $timestamp = null): string
{
    $timestamp ??= time();
    $counter = pack('N*', 0, (int)floor($timestamp / 30));
    $key     = base32Decode($secret);
    $hash    = hash_hmac('sha1', $counter, $key, true);
    $offset  = ord($hash[19]) & 0x0f;
    $code    = (
        ((ord($hash[$offset])     & 0x7f) << 24) |
        ((ord($hash[$offset + 1]) & 0xff) << 16) |
        ((ord($hash[$offset + 2]) & 0xff) <<  8) |
         (ord($hash[$offset + 3]) & 0xff)
    ) % 1_000_000;
    return str_pad((string)$code, 6, '0', STR_PAD_LEFT);
}

function totpVerify(string $secret, string $code, int $window = 1): bool
{
    $now = time();
    for ($i = -$window; $i <= $window; $i++) {
        if (hash_equals(totpGenerate($secret, $now + $i * 30), $code)) {
            return true;
        }
    }
    return false;
}
```

`$window = 1` dopuszcza kod z poprzedniego lub następnego okna — tolerancja zegarowa.

### Generowanie sekretu i kodu QR

```php
function tfa2faGenerateSecret(): string
{
    // 20 bajtów → Base32 → 32 znaki
    return base32Encode(random_bytes(20));
}

function tfa2faQrUrl(string $secret, string $login, string $issuer = 'K2 CMS'): string
{
    $label = rawurlencode($issuer . ':' . $login);
    return 'otpauth://totp/' . $label
        . '?secret=' . $secret
        . '&issuer=' . rawurlencode($issuer)
        . '&algorithm=SHA1&digits=6&period=30';
}
// Wyświetl jako QR kod — np. endoidem qr-code lub JS qrcode.js (lokalnie)
```

### Kody awaryjne (backup codes)

8 jednorazowych kodów na wypadek utraty telefonu:

```php
function tfa2faGenerateBackupCodes(): array
{
    $codes = [];
    for ($i = 0; $i < 8; $i++) {
        $codes[] = strtoupper(bin2hex(random_bytes(4)));   // np. "A3F8B21C"
    }
    return $codes;
}
// Zapisz jako JSON z hashami (nie plain-text):
$hashed = array_map(fn($c) => password_hash($c, PASSWORD_DEFAULT), $codes);
```

---

## Ekrany do zaimplementowania

| Ekran | Gdzie | Opis |
|---|---|---|
| Konfiguracja 2FA | Panel konta użytkownika | QR kod + pole weryfikacji pierwszego kodu |
| Wyłączenie 2FA | Panel konta | Wymaga potwierdzenia aktualnym kodem TOTP |
| Ekran weryfikacji | Ekran logowania (krok 2) | Pole 6-cyfrowe + link „użyj kodu awaryjnego" |
| Kody awaryjne | Panel konta | Wyświetl raz, pobierz jako TXT |

---

## Uwagi bezpieczeństwa

- Sekret TOTP przechowuj zaszyfrowany (`openssl_encrypt`) lub w oddzielnej bazie/vault.
- Każdy kod TOTP powinien być zużywalny tylko raz — zapisuj ostatnio użyty timestamp.
- Kody awaryjne po użyciu natychmiast kasuj z bazy (jednorazowe).
- 2FA powinno być opcjonalne per konto lub wymagane globalnie (config `require_2fa`).
