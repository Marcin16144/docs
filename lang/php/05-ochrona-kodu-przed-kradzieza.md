# Ochrona kodu PHP przed kradzieżą

## Problem: PHP to język interpretowany

W przeciwieństwie do C# / Java, **PHP nie kompiluje się do bytecode** dystrybuowanego (chociaż OPcache cachuje skompilowany bytecode na serwerze). Kod źródłowy w plikach `.php` jest **plain text** — czytelny dla każdego z dostępem do serwera.

```
PHP deployment:
  source code (.php) → uploaded to server → executed

vs

C# deployment:
  source code (.cs) → compiled to .dll → deployed → executed
```

Dla developerów którzy sprzedają oprogramowanie (CMS, plugins, libraries) — to ryzyko **utraty IP**.

## Modele ochrony

### 1. Obfuskacja (Obfuscation)
Zniekształca kod aby był nieczytelny dla człowieka, ale wciąż wykonywalny.
```php
// Przed
function calculateTotal($items) {
    return array_sum($items);
}

// Po obfuskacji
function _0x1f3a($_0xa1) {
    return array_sum($_0xa1);
}
```

**Zalety:** Tanie/free, nie wymaga rozszerzeń serwerowych
**Wady:** Można odwrócić (deobfuskacja)

### 2. Bytecode encoding
Konwertuje PHP do encoded format. Wymaga **rozszerzenia (loader)** na serwerze.

```
source.php → encoder → encoded.php (binary blob) → loader extension → execute
```

**Zalety:** Trudne/niemożliwe do odwrócenia
**Wady:** Wymaga loader extension na serwerze, koszty licencji, ograniczona wydajność

### 3. License management
Dodaje weryfikację licencji do kodu (call home, license key validation).

### 4. Native compilation (najnowszy trend)
Kompilacja do natywnego binary. PHP nie miał dobrej opcji do 2024.

## Komercyjne enkodery (state-of-the-art 2026)

### ionCube — najpopularniejszy

**ionCube** to lider rynku. Używany przez większość komercyjnych skryptów PHP (np. Laravel Spark, BoxBilling, WHMCS).

**Plusy:**
- Najszerzej dostępny loader (większość hostingów ma preinstalled)
- Wsparcie PHP 8.0/8.1/8.2/8.3/8.4
- Bardzo trudny do odwrócenia (state-of-the-art encoding)
- License management built-in (expiry, domain locking, IP locking)
- Free loader, encoder płatny

**Minusy:**
- Encoder płatny: $199 jednorazowo (Basic) do $499 (24-month support)
- Lekka degradacja wydajności (~5-10%)
- Encoded files są większe niż oryginalne

**Workflow:**
```bash
# Linux/Mac
./ioncube_encoder.sh --encode myapp.php

# Windows
ioncube_encoder.exe --encode myapp.php

# Output: encoded myapp.php (lookable jak: <?php //00fb840000018000000041000091a000... ?>)
```

**License binding:**
```bash
# Bind do domeny
./ioncube_encoder.sh --license-allowed-server "example.com"

# Bind do IP
./ioncube_encoder.sh --license-allowed-server "192.168.1.100"

# Expiry
./ioncube_encoder.sh --license-expire-on "2027-12-31"
```

**Loader installation (na serwerze klienta):**
```bash
# Pobierz loader dla wersji PHP
wget https://www.ioncube.com/loaders/ioncube_loaders_lin_x86-64.tar.gz
tar xvf ioncube_loaders_lin_x86-64.tar.gz

# Skopiuj odpowiedni loader
cp ioncube_loader_lin_8.3.so /usr/lib/php/20230831/

# Dodaj do php.ini
echo "zend_extension = /usr/lib/php/20230831/ioncube_loader_lin_8.3.so" >> /etc/php/8.3/fpm/php.ini

# Restart
systemctl restart php8.3-fpm
```

### SourceGuardian — silny konkurent

**SourceGuardian** — UK firma, podobnie do ionCube.

**Plusy:**
- Bardzo silne encoding
- Dobre license management
- Wsparcie najnowszych wersji PHP
- Można się ma "encrypted" mode (wymaga klucza klienta)

**Minusy:**
- Mniej hostingów ma preinstalled loader (vs ionCube)
- Encoder $399+ jednorazowo

**Workflow:**
```bash
sourceguardian -o protected.php source.php
sourceguardian --bind-to-domain "example.com" -o protected.php source.php
```

### Zend Guard / Zend Studio (legacy)

**Zend Guard** był pionierem, ale **nie obsługuje PHP 8+** od dłuższego czasu. Większość firm migruje do ionCube/SourceGuardian.

**Status 2026:** legacy, używaj tylko jeśli musisz dla starych projektów.

### Cobwwweb (PHP 8 friendly)

Nowsze rozwiązanie, focus na PHP 8.x. Niszowe ale wzmianki w community.

## Open source / free alternatywy

### blenc (BLENd Crypt)
Rozszerzenie PECL do encrypt PHP scripts.
- Free, open source
- Rzadko aktualizowane
- Słabe encryption (można reverse)

### POBS (PHP Obfuscator)
Open source obfuskator (zmienia nazwy zmiennych, removuje whitespace, encoduje stringi).
- Free
- Tylko obfuskacja, nie encoding
- Łatwy do odwrócenia z wystarczającym wysiłkiem

### YAK Pro PHP Obfuscator
Profesjonalny obfuskator open source. Bardziej zaawansowany.

```bash
composer require pk-fr/yakpro-po
yakpro-po source/ -o obfuscated/
```

Robi:
- Renaming (variables, functions, classes, methods, namespaces)
- String encoding
- Code shuffling
- Control flow obfuscation
- Junk code insertion

**Zalety:** Free, no loader needed (czysty PHP)
**Wady:** Można odwrócić z determinacją (samo PHP wciąż jest), słabszy niż ionCube

### eval+base64 (NIE rób tego!)

```php
eval(base64_decode("PD9waHAgZWNobyAnSGVsbG8nOyA/Pg=="));
```

Klasyczny "amateur protection". **Złe pomysł** — można odwrócić w 5 sekund:
```php
echo base64_decode("PD9waHAgZWNobyAnSGVsbG8nOyA/Pg==");
```

Większość AV i hostingów blokuje takie wzorce jako malware.

## Native compilation — nowy trend

### FrankenPHP + AOT compilation
**FrankenPHP** (od Symfony team, 2024+) — modern PHP runtime z możliwością **embed PHP w Go binary**.

```go
// main.go
package main

import (
    _ "embed"
    "github.com/dunglas/frankenphp"
)

//go:embed public
var publicFS embed.FS

func main() {
    frankenphp.Init(...)
    // PHP source jest embedded w binary!
}
```

**Build:**
```bash
go build -o myapp
# Single binary z PHP source jako embedded resource
# Trudne do extract bez odpowiednich tools
```

**Zalety:**
- Single binary deployment
- Source jest "ukryty" (nie w pliku .php)
- Modern, performant

**Wady:**
- Wymaga Go knowledge
- Source nie jest **encrypted** — można wyciągnąć z binary z wysiłkiem
- Younger ecosystem

### NativePHP / Tauri PHP
Dla desktop apps — kompiluje PHP do native desktop binary.

## Strategia ochrony — multi-layer

**Pojedyncza warstwa nie wystarcza.** Dobra ochrona = wiele warstw:

```
1. Frontend obfuscation (np. ionCube)
2. License key validation (online check)
3. Domain/IP binding
4. Hardware fingerprinting
5. Anti-debug measures
6. Server-side critical logic (klient nie ma kodu)
7. Watermarking (tracking po kradzieży)
8. Legal (license agreement, EULA)
```

### Pattern: Hybrid SaaS + Self-hosted

Najlepszy model w 2026 dla komercyjnych aplikacji:

```
Klient instaluje Twój encoded plugin (ionCube)
      ↓
Plugin łączy się z TWOIM API (cloud)
      ↓
Krytyczne business logic wykonywane PO STRONIE TWOJEGO API
      ↓
Klient dostaje tylko WYNIK
```

**Zalety:**
- Klient nie ma critical code
- Możesz update/disable per klient
- Telemetry, usage tracking
- Łatwiej monetyzować (subscription)

**Tak działa:** WHMCS, BoxBilling, ProcessWire Pro, większość commercial pluginów.

## License management

### Walidacja online (call home)

```php
class LicenseChecker {
    private string $apiUrl = 'https://api.yourcompany.com/license/verify';

    public function isValid(string $licenseKey): bool {
        $response = file_get_contents(
            $this->apiUrl . '?key=' . urlencode($licenseKey)
            . '&domain=' . urlencode($_SERVER['SERVER_NAME'])
            . '&hash=' . hash('sha256', $licenseKey . self::SECRET)
        );

        $data = json_decode($response, true);
        return $data['valid'] === true
            && $data['expires_at'] > time();
    }
}

// W bootstrap:
if (!$license->isValid(LICENSE_KEY)) {
    die('Invalid or expired license');
}
```

**Best practices:**
- Cache result (sprawdzaj raz na dobę, nie każdy request)
- Graceful degradation (nie kładź aplikacji jeśli API down)
- Hardware fingerprint (bind do server hostname/MAC)
- Encrypted communication (HTTPS + signed responses)
- Anti-replay (nonces)

### Offline license (signed JWT)

```php
$jwt = "eyJhbGciOiJSUzI1NiJ9...";

// Verify with public key (klient nie ma private)
$publicKey = openssl_pkey_get_public('file://public.key');
$valid = openssl_verify(
    $payload,
    $signature,
    $publicKey,
    OPENSSL_ALGO_SHA256
);
```

**Zalety:** Działa offline, weryfikacja przez asymmetric crypto
**Wady:** Trudniej revoke (klient już ma valid JWT)

## Anti-tampering

```php
// Self-integrity check
class IntegrityChecker {
    private array $expectedHashes = [
        'app/core/License.php' => 'sha256:abcd1234...',
        'app/core/Auth.php' => 'sha256:efgh5678...',
    ];

    public function verify(): bool {
        foreach ($this->expectedHashes as $file => $expected) {
            $actual = 'sha256:' . hash_file('sha256', __DIR__ . '/' . $file);
            if ($actual !== $expected) {
                $this->onTampering($file);
                return false;
            }
        }
        return true;
    }

    private function onTampering(string $file): void {
        // Disable, log, alert
    }
}
```

**Uwaga:** Klient z determinacją może zmodyfikować ten kod też. To **opóźnia** atak, nie zatrzymuje.

## Watermarking — fingerprint per klient

Dla każdego klienta — **unikalna kompilacja** z embedded fingerprint.

```php
// Per klient encoder:
ioncube_encoder --license-property "client_id=ABC123" \
                --watermark "$(uuidgen)" \
                source.php
```

Jeśli kod wycieknie → możesz zidentyfikować źródło.

## Praktyczne rekomendacje (2026)

### Dla pojedynczego komercyjnego pluginu/skryptu (low budget):
```
1. Obfuskacja: YAK Pro (free)
2. License validation: simple online API
3. Trust legal (EULA, copyright)
```

### Dla mid-size product (CMS, business app):
```
1. ionCube Encoder ($199-499)
2. License management: online + offline JWT
3. Domain/IP binding
4. Hybrid: critical logic w cloud
```

### Dla enterprise / large product:
```
1. ionCube + SourceGuardian (multiple layers)
2. Custom license server
3. Hardware fingerprinting
4. Anti-debug, anti-tampering
5. Code watermarking (per-customer builds)
6. Cloud-first architecture (klient ma minimum kodu)
7. Aggressive legal protection (DMCA monitoring)
```

### Dla SaaS:
```
Klient nie dostaje kodu w ogóle.
Tylko thin client / API calls.
Nie potrzebujesz obfuskacji w ogóle.
```

## Workflow: setup ionCube dla projektu

```bash
# 1. Kup encoder (ioncube.com)

# 2. Pobierz encoder dla swojego OS
wget https://download.ioncube.com/encoder/ioncube_encoder_lin_x86-64.tar.gz
tar xvf ioncube_encoder_lin_x86-64.tar.gz

# 3. Encode całego projektu
./ioncube_encoder \
    --encode . \
    --target encoded/ \
    --skip-defaults \
    --license-property "domain=example.com" \
    --license-property "expires=2027-01-01" \
    --without-runtime-loader-support  # wymusza loader

# 4. Test loader
echo "<?php phpinfo(); ?>" > test.php
php -d zend_extension=ioncube_loader_lin_8.3.so test.php
# Powinno pokazać "with the ionCube PHP Loader" w phpinfo

# 5. Test encoded code
php -d zend_extension=ioncube_loader_lin_8.3.so encoded/index.php

# 6. Pakuj do dystrybucji (z instrukcją instalacji loader dla klienta)
```

## Co NIE działa (anty-patterns)

### ❌ "Ukryję plik z license"
Plik tekstowy z license key w `.htaccess` zaprotected → klient znajdzie w 5 sekund.

### ❌ "Custom encryption w PHP"
```php
$decoded = my_custom_decrypt($encrypted);
eval($decoded);
```
Klient odpali debugger lub `php -r "echo my_custom_decrypt('...');"` → ma plain code.

### ❌ "Compiled SOAP binding"
Pomijam wszystkie warstwy security przez exposed API.

### ❌ "JS frontend z business logic"
Cały kod w przeglądarce → nic nie chronisz.

### ❌ Tylko EULA
"Nie wolno modyfikować" w EULA = legal protection ale fizycznie nikt tego nie sprawdza. Połącz z technical protection.

## Wydajność po enkodowaniu

| Encoding | Przykładowy overhead |
|----------|---------------------|
| Plain PHP (oryginalny) | 100% (baseline) |
| OPcache enabled | ~95% (5-10% szybciej!) |
| ionCube encoded | 105-115% (5-15% wolniejsze) |
| ionCube + OPcache | 95-105% (porównywalne do plain) |
| YAK Pro obfuscated | 100-105% (similar) |
| SourceGuardian | 105-115% (similar to ionCube) |

**Praktyka:** OPcache w produkcji eliminuje większość różnicy. Encoded code jest nieco wolniejszy ale niezauważalnie.

## Bezpieczeństwo loader-ów

Czasem znajdują się **vulnerabilities w loader-ach**. Updateuj!

- **ionCube**: regularne updates, free
- **SourceGuardian**: regularne
- **Zend Guard**: legacy, brak updates → security risk

Sprawdzaj CVE database regularnie.

## Aspekty prawne

### Copyright
PHP source code ma automatyczną ochronę copyright (od momentu utworzenia). **Rejestracja** w odpowiedniej organizacji (np. US Copyright Office, ZAIKS w PL) wzmacnia pozycję prawną.

### EULA / License
Twój **EULA** powinien zawierać:
- Zakaz reverse engineering
- Zakaz dystrybucji
- Zakaz modyfikacji core
- Limit na liczbę użytkowników/serwerów
- Term i renewal
- Liability limitation
- Governing law

### DMCA / European equivalents
Jeśli ktoś dystrybuuje skradziony kod online — DMCA takedown notice (US) lub odpowiednik w EU.

### Trade Secret
Niektóre algorytmy mogą być chronione jako trade secret. Wymagana **NDA** z pracownikami i kontraktorami.

## Monitorowanie i wykrywanie kradzieży

### Tools:
- **GitHub search** — szukaj fragmentów Twojego kodu
- **Google search** — unique strings z Twojego kodu
- **DMCA scanner services**: Pixsy, Markmonitor (commercial)
- **Telemetry w aplikacji** — track gdzie i kiedy uruchamiana
- **License server analytics** — anomalie w użyciu

### Watermarking practices:
```php
// Unique per-customer comment / variable name
// (zostaje po deobfuskacji bo to legalna część logiki)

class LicenseChecker {
    // Internal ref: CUSTOMER_8a4f2c
    private const REF = 'CUSTOMER_8a4f2c';
}
```

Jeśli ktoś wrzuci na GitHub — łatwo zidentyfikujesz klienta-leakera.

## Stack rekomendacji 2026

### "Sprzedaję plugin do popularnego CMS"
- **Encoder:** ionCube (largest hosting compatibility)
- **License:** online check + cache
- **Anti-tamper:** integrity check w bootstrap
- **Pricing:** subscription with auto-disable on non-payment

### "Sprzedaję self-hosted business app"
- **Encoder:** ionCube + custom license server
- **Architecture:** core encoded + cloud API for critical features
- **Anti-tamper:** multiple checks, watermarking
- **Updates:** signed updates, server-validated
- **Backup:** klient ma encoded code, backup ma source (tylko Ty)

### "Open source z paid features"
- **Free tier:** open source GitHub
- **Pro tier:** ionCube encoded module
- **Community plugin marketplace:** signing system (verified publishers)

## Ważne: ochrona ≠ niemożność kradzieży

**Żadna ochrona nie jest 100%.** ionCube był crackowany w przeszłości (chociaż rzadko, z wysiłkiem). YAK Pro można odwrócić determined reverse engineer.

**Cel ochrony:** zwiększyć **koszt** kradzieży powyżej **wartości** dla atakującego.

Jeśli plugin kosztuje $50 → ionCube wystarczy (nikt nie wyda 100h na crack)
Jeśli system kosztuje $50,000 → potrzebujesz multiple layers + cloud architecture

## Linki i zasoby

- **ionCube**: ioncube.com
- **SourceGuardian**: sourceguardian.com
- **YAK Pro**: github.com/pk-fr/yakpro-po
- **POBS**: github.com/php-obfuscator/php-obfuscator
- **FrankenPHP**: frankenphp.dev
- **PHP-Parser** (do custom obfuskatorów): github.com/nikic/PHP-Parser

## Następne kroki

- **Rozdział 04** — bezpieczeństwo aplikacji (OWASP, walidacja)
- **Rozdział 06** — narzędzia i deployment
- W folderze **architektura/08-bezpieczenstwo** — fundamenty bezpieczeństwa
