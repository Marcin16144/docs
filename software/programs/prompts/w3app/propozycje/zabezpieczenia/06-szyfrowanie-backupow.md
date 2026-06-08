# 06 — Szyfrowanie i integralność backupów

**Priorytet:** 🔴 Wysoki · **Trudność implementacji:** Średnia

---

## Problem

Pliki backupów (`var/backups/*.sql`) przechowywane są jako plain-text. Zrzut SQL zawiera
**wszystkie dane bazy** — konta użytkowników (loginy, hasze haseł), treści, domeny.

Scenariusze ryzyka:
- Dostęp do systemu plików (hosting współdzielony, błąd konfiguracji nginx/Apache)
- Kradzież dysku / snapshotów VM
- Niebezpieczne pobieranie — plik `.sql` przesyłany przez HTTP bez dodatkowej ochrony
- Wyciek przez błąd w systemie backupów

Obecna ochrona: katalog `var/backups/` jest poza webroot — dobry start, ale niewystarczający.

---

## Rozwiązanie

Dwa niezależne mechanizmy:

1. **Szyfrowanie AES-256-CBC** — backup zaszyfrowany kluczem z konfiguracji tenanta.
   Bez klucza plik `.sql.enc` jest bezużyteczny.
2. **Podpis integralności SHA-256** — plik `.sha256` obok backupu. Przy przywracaniu
   weryfikacja skrótu — wykrycie manipulacji.

---

## Implementacja

### Klucz szyfrowania (konfiguracja)

```php
// configs/<host>.php
'backup_encryption_key' => 'base64:' . base64_encode(random_bytes(32)),
// Wygeneruj: php -r "echo 'base64:' . base64_encode(random_bytes(32)) . PHP_EOL;"
```

Klucz musi być 32 bajty (256 bit) zakodowane w base64. Przechowuj go **poza repozytorium**
(`.env`, vault, zmienna środowiskowa serwera).

### Funkcje szyfrowania (admcore.php)

```php
function backupEncryptionKey(): ?string
{
    $raw = (string)Config::get('backup_encryption_key', '');
    if ($raw === '') {
        return null;   // szyfrowanie wyłączone
    }
    if (str_starts_with($raw, 'base64:')) {
        return base64_decode(substr($raw, 7)) ?: null;
    }
    return $raw;
}

/**
 * Szyfruje plik backupu. Zwraca ścieżkę do zaszyfrowanego pliku (.enc).
 * Jeśli klucz nie jest skonfigurowany — zwraca oryginał (bez szyfrowania).
 */
function backupEncrypt(string $sqlPath): string
{
    $key = backupEncryptionKey();
    if ($key === null) {
        return $sqlPath;
    }

    $iv         = random_bytes(16);               // 128-bit IV
    $plain      = file_get_contents($sqlPath);
    $cipher     = openssl_encrypt($plain, 'AES-256-CBC', $key, OPENSSL_RAW_DATA, $iv);
    $encPath    = $sqlPath . '.enc';

    // Format: [4 bajty magic][16 bajtów IV][dane]
    file_put_contents($encPath, "K2BC" . $iv . $cipher);
    unlink($sqlPath);   // usuń niezaszyfrowany

    return $encPath;
}

/**
 * Deszyfruje plik .enc do tymczasowego .sql przed przywróceniem.
 */
function backupDecrypt(string $encPath): string
{
    $key = backupEncryptionKey();
    if ($key === null || !str_ends_with($encPath, '.enc')) {
        return $encPath;
    }

    $raw = file_get_contents($encPath);
    if (substr($raw, 0, 4) !== 'K2BC') {
        throw new \RuntimeException('Nieprawidłowy format zaszyfrowanego backupu.');
    }
    $iv     = substr($raw, 4, 16);
    $cipher = substr($raw, 20);
    $plain  = openssl_decrypt($cipher, 'AES-256-CBC', $key, OPENSSL_RAW_DATA, $iv);
    if ($plain === false) {
        throw new \RuntimeException('Błąd odszyfrowania — nieprawidłowy klucz?');
    }

    $tmpPath = sys_get_temp_dir() . '/k2_restore_' . uniqid() . '.sql';
    file_put_contents($tmpPath, $plain);
    return $tmpPath;
}
```

### Podpis integralności

```php
/**
 * Tworzy plik .sha256 obok backupu.
 */
function backupSign(string $backupPath): void
{
    $hash = hash_file('sha256', $backupPath);
    file_put_contents($backupPath . '.sha256', $hash . '  ' . basename($backupPath) . "\n");
}

/**
 * Weryfikuje integralność backupu przed przywróceniem.
 * Rzuca wyjątek jeśli niezgodność lub brak pliku .sha256.
 */
function backupVerify(string $backupPath): void
{
    $sigPath = $backupPath . '.sha256';
    if (!file_exists($sigPath)) {
        // Starsze backupy bez podpisu — ostrzeżenie, nie blokada
        Logger::get('Backup')->warn('Brak pliku .sha256 — integralność niezweryfikowana', properties: [
            'file' => basename($backupPath),
        ]);
        return;
    }
    [$expectedHash] = explode(' ', file_get_contents($sigPath));
    $actualHash     = hash_file('sha256', $backupPath);
    if (!hash_equals($expectedHash, $actualHash)) {
        throw new \RuntimeException('Integralność backupu NARUSZONA — plik może być zmodyfikowany.');
    }
}
```

### Integracja z istniejącymi funkcjami backupu (admbackup.php)

```php
// Po createBackup() — zaszyfruj i podpisz:
$encPath = backupEncrypt($rawSqlPath);
backupSign($encPath);

// Przed restoreBackup() — zweryfikuj i odszyfruj:
backupVerify($encPath);
$sqlPath = backupDecrypt($encPath);
// … przywrócenie z $sqlPath …
if ($sqlPath !== $encPath) {
    unlink($sqlPath);   // usuń tymczasowy plik
}
```

### Bezpieczne pobieranie (download)

Obecna implementacja pobierania backupu powinna weryfikować nazwę pliku przed
serwowaniem — zabezpieczenie przed path traversal:

```php
// admbackup.php — akcja backup_download
$filename = basename((string)($_GET['backup_download'] ?? ''));
$allowed  = preg_match('/^[\w\-\.]+\.(sql|enc|sha256)$/', $filename);
$path     = ROOT . '/var/backups/' . $filename;

if (!$allowed || !is_file($path) || !str_starts_with(realpath($path), ROOT . '/var/backups/')) {
    http_response_code(404);
    exit;
}
// Serwuj plik…
header('Content-Disposition: attachment; filename="' . $filename . '"');
readfile($path);
exit;
```

---

## Uwagi

- Klucz szyfrowania to najważniejszy element całego systemu — **utrata klucza = utrata wszystkich zaszyfrowanych backupów**.
  Przechowuj go osobno od backupów (np. menedżer haseł, vault).
- Zaszyfrowane backupy są nieczytelne bez klucza, więc kopia na S3 / SFTP jest bezpieczna nawet przy wycieku bucketu.
- Rozważ rotację kluczy: nowe backupy nowym kluczem, stare możliwe do odszyfrowania starym.
- `openssl_encrypt` używa PHP ext-openssl (standardowa biblioteka). Brak zewnętrznych zależności.
