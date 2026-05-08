# Certyfikaty SSL/TLS dla usług publicznych

## Wprowadzenie

W 2026 **HTTPS jest obowiązkowe** dla wszystkich publicznych usług. Bez certyfikatu:
- Przeglądarki blokują stronę ("Not Secure")
- HTTP/2, HTTP/3 wymagają TLS
- Browsers downgrade do HTTP/1.1
- Google deranking dla HTTP-only
- Niemożliwe service worker / PWA / wiele Web APIs

## Kluczowe pojęcia

| Pojęcie | Wyjaśnienie |
|---------|-------------|
| **TLS** | Transport Layer Security (następca SSL, dziś używamy TLS 1.2/1.3) |
| **SSL** | Stary protokół (1.0-3.0), już nie używaj |
| **CA** | Certificate Authority — zaufana instytucja podpisująca certyfikaty |
| **CSR** | Certificate Signing Request — żądanie certyfikatu (zawiera klucz publiczny) |
| **PFX/PKCS#12** | Format pliku zawierający cert + klucz prywatny (Windows) |
| **PEM** | Base64-encoded format (Linux/Apache/Nginx) |
| **CER/CRT** | Tylko certyfikat (bez klucza prywatnego) |
| **Wildcard** | Jeden cert dla `*.example.com` (subdomeny) |
| **SAN** | Subject Alternative Names — wiele domen w jednym cercie |
| **CT log** | Certificate Transparency — publiczne logi certyfikatów |
| **CRL** | Certificate Revocation List |
| **OCSP** | Online Certificate Status Protocol (sprawdzanie revokacji) |
| **HSTS** | HTTP Strict Transport Security (wymuszenie HTTPS) |

## Rodzaje certyfikatów

### Wg walidacji:

| Typ | Co weryfikuje | Czas wystawienia | Cena (2026) |
|-----|---------------|------------------|-------------|
| **DV (Domain Validated)** | Tylko kontrola domeny | minuty | $0 (Let's Encrypt) - $20/rok |
| **OV (Organization Validated)** | Domena + organizacja | dni | $50-200/rok |
| **EV (Extended Validation)** | Pełna weryfikacja firmy | tygodnie | $150-500/rok |

**W 2026:** DV (Let's Encrypt, ZeroSSL) wystarcza dla 95% przypadków. EV stracił "green bar" w przeglądarkach — bezsensowny dla większości.

### Wg zakresu:

| Typ | Pokrywa | Use case |
|-----|---------|----------|
| **Single** | Jedna domena (`api.example.com`) | Pojedynczy site |
| **Wildcard** | `*.example.com` (wszystkie subdomeny) | Wiele subdomen |
| **SAN/UCC** | Wiele konkretnych domen (multi-domain) | Klient z kilkoma domenami |

## Let's Encrypt — preferowany wybór 2026

**Let's Encrypt** to free Certificate Authority. **Auto-renew co 90 dni**, automatyzacja przez ACME protocol.

### Plusy:
- ✅ **Darmowy**
- ✅ **Wysoko zaufany** (wszystkie przeglądarki)
- ✅ **Automatic renewal**
- ✅ **Wildcard support** (od 2018)
- ✅ **Rate limits hojne** (50 certs/week per registered domain)

### Minusy:
- ⚠️ **90 dni TTL** (musisz mieć automatyzację!)
- ⚠️ **Tylko DV** (no OV/EV)
- ⚠️ **Wymaga publicznie dostępnej domeny** (DNS lub HTTP-01 challenge)

## Win-acme — najpopularniejszy klient ACME na Windows

**win-acme** (dawniej letsencrypt-win-simple) to dedicated ACME client dla Windows + IIS.

### Instalacja

```powershell
# Pobierz najnowszą wersję
Invoke-WebRequest -Uri "https://github.com/win-acme/win-acme/releases/latest/download/win-acme.v2.x.x.x64.pluggable.zip" -OutFile "win-acme.zip"

Expand-Archive -Path "win-acme.zip" -DestinationPath "C:\win-acme"
cd C:\win-acme
```

### Pierwsza certyfikacja (interactive)

```powershell
.\wacs.exe
```

Menu:
```
N - Create certificate (default settings)
M - Create certificate (full options)
R - Run renewals
A - Manage renewals
O - More options
Q - Quit
```

**Recommended flow:**
1. **N** (Create certificate)
2. Wybierz site z listy IIS
3. Wybierz binding(s)
4. win-acme automatycznie:
   - Generuje CSR
   - Doda binding HTTP do site
   - Spełni HTTP-01 challenge
   - Pobierze certyfikat
   - Doda binding HTTPS
   - Zaplanuje task do auto-renew

### Non-interactive (automation)

```powershell
.\wacs.exe `
    --target iis `
    --siteid 1 `
    --emailaddress admin@example.com `
    --accepttos `
    --usedefaulttaskuser
```

### Wildcard certificate (DNS-01 challenge)

Wildcard wymaga **DNS-01 challenge**. Czyli win-acme musi dodać rekord TXT w DNS.

**Plugins dla popularnych providerów DNS:**
- Cloudflare
- Azure DNS
- AWS Route 53
- GoDaddy
- DigitalOcean

```powershell
# Wildcard z Cloudflare DNS
.\wacs.exe `
    --target manual `
    --host *.example.com `
    --validation cloudflare `
    --cloudflareapitoken "..." `
    --emailaddress admin@example.com `
    --accepttos
```

### Renewal automation

win-acme automatycznie tworzy **Scheduled Task** który uruchamia się co 24h:
```
Task name: win-acme renew (acme-v02.api.letsencrypt.org)
Trigger: Daily at 09:00
Action: C:\win-acme\wacs.exe --renew --baseuri https://acme-v02.api.letsencrypt.org/
```

Renewal odbywa się **30 dni przed expiry** (czyli każdy cert ~co 60 dni).

### Lokalizacja certyfikatów

```
Cert store: LocalMachine\WebHosting (default dla IIS)
Klucze: C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys
Konfiguracja win-acme: C:\ProgramData\win-acme\
```

## Instalacja certyfikatu w IIS — manualnie

Jeśli kupiłeś cert (np. Sectigo, DigiCert):

### Krok 1: Wygeneruj CSR

**Via IIS Manager:**
1. IIS Manager → Server name → **Server Certificates**
2. Right side: **Create Certificate Request**
3. Wypełnij Common Name (CN), Org, Country, etc.
4. Wybierz Cryptographic Service Provider (Microsoft RSA SChannel)
5. Bit length: 2048 lub 4096
6. Save CSR do pliku .txt

**Via PowerShell:**
```powershell
$inf = @"
[Version]
Signature = "`$Windows NT`$"

[NewRequest]
Subject = "CN=www.example.com, O=My Company, C=PL, S=Mazowieckie, L=Warsaw"
KeySpec = 1
KeyLength = 2048
Exportable = TRUE
MachineKeySet = TRUE
SMIME = False
PrivateKeyArchive = FALSE
UserProtected = FALSE
UseExistingKeySet = FALSE
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = PKCS10
KeyUsage = 0xa0

[Strings]
szOID_SUBJECT_ALT_NAME2 = "2.5.29.17"
szOID_ENHANCED_KEY_USAGE = "2.5.29.37"
szOID_PKIX_KP_SERVER_AUTH = "1.3.6.1.5.5.7.3.1"
szOID_PKIX_KP_CLIENT_AUTH = "1.3.6.1.5.5.7.3.2"

[Extensions]
2.5.29.17 = "{text}"
_continue_ = "dns=www.example.com&"
_continue_ = "dns=example.com&"
"@

$inf | Out-File -FilePath "C:\temp\request.inf" -Encoding ASCII
certreq -new "C:\temp\request.inf" "C:\temp\request.csr"
```

### Krok 2: Wyślij CSR do CA

Wgraj plik .csr w portalu Certyfikatu (Sectigo, DigiCert, etc.). Po weryfikacji dostaniesz certyfikat (.cer lub .crt).

### Krok 3: Complete Certificate Request

**Via IIS Manager:**
1. Server Certificates → **Complete Certificate Request**
2. Wybierz plik .cer
3. Friendly name (np. "www.example.com")
4. Store: **Web Hosting**

**Via PowerShell:**
```powershell
certreq -accept "C:\temp\response.cer"
```

### Krok 4: Bind w IIS

```powershell
# Znajdź thumbprint
Get-ChildItem -Path "Cert:\LocalMachine\WebHosting" | Format-List Subject, Thumbprint

# Bind do site
$cert = Get-ChildItem -Path "Cert:\LocalMachine\WebHosting" | Where-Object {$_.Subject -like "*example.com*"}
New-WebBinding -Name "MySite" -Protocol https -Port 443 -HostHeader "www.example.com" -SslFlags 1
$binding = Get-WebBinding -Name "MySite" -Protocol "https"
$binding.AddSslCertificate($cert.Thumbprint, "WebHosting")
```

## TLS Hardening (kluczowe dla bezpieczeństwa!)

### Kolejność preferencji (2026):
- **TLS 1.3** ⭐ — używaj jeśli możesz
- **TLS 1.2** — minimum dla prod (kompatybilność)
- **TLS 1.0/1.1** — ❌ wyłącz (deprecated, security issues)
- **SSL 3.0/2.0** — ❌ ❌ wyłącz (POODLE, BEAST attacks)

### Cipher suites (preferowana kolejność):
```
TLS 1.3:
  TLS_AES_256_GCM_SHA384
  TLS_CHACHA20_POLY1305_SHA256
  TLS_AES_128_GCM_SHA256

TLS 1.2 (modern):
  ECDHE-ECDSA-AES256-GCM-SHA384
  ECDHE-RSA-AES256-GCM-SHA384
  ECDHE-ECDSA-CHACHA20-POLY1305
  ECDHE-RSA-CHACHA20-POLY1305
  ECDHE-ECDSA-AES128-GCM-SHA256
  ECDHE-RSA-AES128-GCM-SHA256
```

### Wyłącz słabe:
- ❌ SSLv2, SSLv3
- ❌ TLS 1.0, TLS 1.1
- ❌ RC4, DES, 3DES
- ❌ MD5, SHA1
- ❌ Export ciphers (40-bit, 56-bit)
- ❌ Anonymous DH
- ❌ NULL ciphers

### Konfiguracja via IIS Crypto

**Najlepsze narzędzie 2026: IIS Crypto** (Nartac Software, free).

GUI z presetami:
- **Best Practices** — modern config
- **PCI 4.0** — compliance dla payment cards
- **FIPS 140-2** — federal compliance
- **Strict** — maximum security

Po kliknięciu Apply → wymaga reboot (zmienia rejestr).

### Manualnie via Registry (bez IIS Crypto)

```powershell
# Disable SSLv2
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server"
New-Item -Path $path -Force
New-ItemProperty -Path $path -Name "Enabled" -Value 0 -PropertyType DWORD -Force
New-ItemProperty -Path $path -Name "DisabledByDefault" -Value 1 -PropertyType DWORD -Force

# Disable SSLv3, TLS 1.0, TLS 1.1 — analogicznie
# (zmień nazwy paths)

# Enable TLS 1.2 (default w nowszych Windows, ale upewnij się)
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server"
New-Item -Path $path -Force
New-ItemProperty -Path $path -Name "Enabled" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $path -Name "DisabledByDefault" -Value 0 -PropertyType DWORD -Force

# Enable TLS 1.3 (Server 2022+ wspiera natywnie)
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Server"
New-Item -Path $path -Force
New-ItemProperty -Path $path -Name "Enabled" -Value 1 -PropertyType DWORD -Force
New-ItemProperty -Path $path -Name "DisabledByDefault" -Value 0 -PropertyType DWORD -Force

# REBOOT WYMAGANY
Restart-Computer
```

## HSTS (HTTP Strict Transport Security)

**HSTS** mówi przeglądarce: "Zawsze używaj HTTPS dla tej domeny" (przez `max-age` sekund).

### Dodaj header:

```xml
<!-- web.config -->
<system.webServer>
  <httpProtocol>
    <customHeaders>
      <add name="Strict-Transport-Security"
           value="max-age=31536000; includeSubDomains; preload" />
    </customHeaders>
  </httpProtocol>
</system.webServer>
```

**Parametry:**
- `max-age=31536000` — 1 rok (sekundy)
- `includeSubDomains` — dotyczy też subdomen
- `preload` — chętny do bycia w preload list (hstspreload.org)

⚠️ **Uwaga:** HSTS jest **trwały** (klient pamięta przez max-age). Jeśli pomylisz konfigurację, **klienci nie będą mogli wejść** przez HTTPS!

**Strategia bezpieczna:**
1. Najpierw `max-age=300` (5 min) — test
2. Potem `max-age=86400` (1 dzień)
3. Po tygodniu OK → `max-age=31536000` (1 rok)
4. Jeśli wszystko działa → preload submission

## HTTP → HTTPS redirect

```xml
<!-- web.config — wymuszenie HTTPS -->
<system.webServer>
  <rewrite>
    <rules>
      <rule name="HTTPS Redirect" stopProcessing="true">
        <match url="(.*)" />
        <conditions>
          <add input="{HTTPS}" pattern="off" ignoreCase="true" />
          <!-- Wykluczyć ACME challenge (dla Let's Encrypt) -->
          <add input="{REQUEST_URI}" pattern="^/.well-known/acme-challenge/" negate="true" />
        </conditions>
        <action type="Redirect" url="https://{HTTP_HOST}/{R:1}"
                redirectType="Permanent" />
      </rule>
    </rules>
  </rewrite>
</system.webServer>
```

## Multi-site z certyfikatami (SNI)

```powershell
# Site A z certem A
$certA = Get-ChildItem Cert:\LocalMachine\WebHosting | Where {$_.Subject -like "*sitea.com*"}
New-WebBinding -Name "SiteA" -Protocol https -Port 443 -HostHeader "sitea.com" -SslFlags 1
(Get-WebBinding -Name "SiteA" -Protocol "https").AddSslCertificate($certA.Thumbprint, "WebHosting")

# Site B z certem B (ten sam port 443!)
$certB = Get-ChildItem Cert:\LocalMachine\WebHosting | Where {$_.Subject -like "*siteb.com*"}
New-WebBinding -Name "SiteB" -Protocol https -Port 443 -HostHeader "siteb.com" -SslFlags 1
(Get-WebBinding -Name "SiteB" -Protocol "https").AddSslCertificate($certB.Thumbprint, "WebHosting")
```

**SNI (Server Name Indication)** pozwala na **wiele certyfikatów na tym samym IP**. Wszystkie nowoczesne przeglądarki to wspierają (od 2010).

## Custom CA — Active Directory Certificate Services (AD CS)

Dla **wewnętrznych** usług (intranet, dev environments) — własna CA.

### Instalacja

```powershell
Install-WindowsFeature -Name AD-Certificate -IncludeManagementTools
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -CACommonName "Contoso Root CA" -KeyLength 4096 -HashAlgorithmName SHA256 -ValidityPeriod Years -ValidityPeriodUnits 20
```

### Workflow:
1. Stwórz template (np. "WebServer Custom" w Certificate Templates MMC)
2. Issue template w CA
3. Klient żąda cert via `certreq` lub Web Enrollment
4. Cert auto-deploys do trusted clients (via GPO)

### Auto-enrollment (Group Policy)

W AD environment, możesz skonfigurować auto-enrollment dla maszyn:
```
Group Policy:
Computer Configuration → Policies → Windows Settings →
Security Settings → Public Key Policies →
Certificate Services Client - Auto-Enrollment
```

## Certificate Pinning

**HPKP (HTTP Public Key Pinning)** — **DEPRECATED** (zbyt ryzykowne).

**Zamiast tego:**
- **CT (Certificate Transparency)** — automatyczne, w tle
- **CAA (DNS records)** — wskazuj które CA może wystawiać dla domeny:
  ```
  example.com.  CAA  0 issue "letsencrypt.org"
  example.com.  CAA  0 issuewild "letsencrypt.org"
  example.com.  CAA  0 iodef "mailto:security@example.com"
  ```

## Certificate Transparency (CT)

**CT logs** to publiczne logi wszystkich wystawionych certyfikatów. Każdy może sprawdzić.

### Sprawdź swoje certyfikaty:
- **crt.sh** — search interface po CT logs
- **Censys** — comprehensive dataset

```bash
# Wszystkie certy dla domeny
https://crt.sh/?q=example.com
```

**Use case:** monitoruj swoją domenę — wykryj nieautoryzowane wystawienie certu (np. ktoś przejął kontrolę nad DNS i zamówił cert).

## Monitoring i alerting

### Sprawdzanie expiry

```powershell
# Wszystkie cert na maszynie wygasające w ciągu 30 dni
Get-ChildItem -Path Cert:\LocalMachine\My -Recurse |
    Where-Object {$_.NotAfter -lt (Get-Date).AddDays(30) -and $_.NotAfter -gt (Get-Date)} |
    Select-Object Subject, Thumbprint, NotAfter
```

### Automated check (sprawdź zewnętrznie)

```powershell
# Sprawdź expiry zewnętrznie (sprawdza nie tylko local store!)
$url = "https://www.example.com"
$req = [Net.HttpWebRequest]::Create($url)
$req.GetResponse() | Out-Null
$cert = $req.ServicePoint.Certificate
$cert2 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $cert
$daysToExpiry = ($cert2.NotAfter - (Get-Date)).Days

if ($daysToExpiry -lt 30) {
    Send-MailMessage -To "admin@example.com" -Subject "Cert expires in $daysToExpiry days"
}
```

### Tools 2026:
- **Cert-Manager** (Kubernetes) — najlepsze dla K8s
- **Posh-ACME** — PowerShell ACME client (alternatywa do win-acme)
- **certbot** — przez WSL/Linux
- **Uptime monitoring** (Uptime Robot, Pingdom) — z cert expiry alerts
- **Grafana** dashboard z cert expiry

## Performance — TLS optimization

### Session resumption
- **Session ID** — server cache (cluster nie share)
- **Session tickets** — encrypted, share between servers
- **TLS 1.3** — 0-RTT resumption (najszybsze, ale replay risk)

### OCSP Stapling
Server pre-fetches OCSP response, dodaje do TLS handshake. Klient nie musi robić osobnego query do CA.

```powershell
# IIS — włączone domyślnie w Server 2022+
# Sprawdzenie:
Get-WebConfigurationProperty -Filter "system.webServer/security/access" -Name "sslFlags"
```

### HTTP/2 i HTTP/3

**HTTP/2** — domyślnie ON dla HTTPS bindings w IIS od Server 2016. Multiplexing → szybciej.

**HTTP/3 (QUIC)** — Server 2025 wsparcie wbudowane.
```powershell
# Włącz HTTP/3
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-HTTP3"
```

## Test i validation

### SSL Labs (najlepsze)
**ssllabs.com/ssltest/** — kompleksowy test, ocena A+ to cel.

Sprawdza:
- Protokoły (TLS 1.2/1.3)
- Cipher suites
- Forward Secrecy
- HSTS
- HPKP (deprecated)
- Vulnerabilities (Heartbleed, POODLE, etc.)
- Certificate chain
- Trust path

### Inne narzędzia:
- **testssl.sh** — CLI alternative
- **Mozilla Observatory** — comprehensive web security
- **DigiCert SSL Tools** — quick check
- **Hardenize** — DNS + TLS + email security

## Checklist publikacji aplikacji z HTTPS

```
☐ Domena zarejestrowana i skonfigurowana w DNS
☐ Serwer dostępny publicznie (port 80, 443 otwarte)
☐ IIS / web server zainstalowany i działa
☐ Site stworzony z bindingiem HTTP (port 80)
☐ Strona testowa HTTP działa
☐ Certyfikat zdobyty (Let's Encrypt lub komercyjny)
☐ Binding HTTPS dodany z certem
☐ HTTPS test z różnych przeglądarek
☐ HTTP → HTTPS redirect skonfigurowany
☐ HSTS header dodany (najpierw krótki max-age, potem długi)
☐ TLS 1.0/1.1 wyłączone, słabe ciphers wyłączone (IIS Crypto)
☐ Security headers: X-Content-Type-Options, X-Frame-Options, CSP, Referrer-Policy
☐ SSL Labs test → A+
☐ Auto-renewal scheduled (win-acme task)
☐ Monitoring expiry skonfigurowany
☐ CAA record w DNS dla zezwolonego CA
☐ Backup certyfikatu (export PFX z hasłem)
☐ Documentation: gdzie cert, kiedy expires, jak renew
```

## Częste błędy

### ❌ Self-signed cert w produkcji
Tylko dla dev/test. Klienci dostają warning, "Not Secure".

### ❌ Bad chain
Brakuje intermediate cert w łańcuchu → klienci dostają "untrusted".

```powershell
# Test chain
$url = "https://example.com"
$req = [Net.HttpWebRequest]::Create($url)
$req.GetResponse()
# Powinno przejść bez błędów
```

### ❌ Mixed content
HTTPS site ładuje HTTP zasoby (obrazki, CSS, JS) → przeglądarka blokuje. Wszystko musi być HTTPS.

### ❌ HSTS bez testowania
Włączasz HSTS z max-age=1 rok, błąd → klienci zablokowani na rok.

### ❌ Brak auto-renewal
Cert wygasa, zapomniałeś, strona down. Zawsze automatyzuj!

### ❌ Klucz prywatny w repo Git
**Catastrophic.** Trzymaj klucze w secure store (Vault, Key Vault, secret manager).

### ❌ Wildcard wszędzie
Jeden compromised wildcard = wszystkie subdomeny compromised. Używaj single certs gdzie możliwe.

## Linki i zasoby

- **Let's Encrypt**: letsencrypt.org
- **win-acme**: win-acme.com (i github.com/win-acme/win-acme)
- **Posh-ACME**: github.com/rmbolger/Posh-ACME (PowerShell ACME)
- **IIS Crypto**: nartac.com/Products/IISCrypto/
- **SSL Labs**: ssllabs.com/ssltest/
- **Mozilla SSL Configuration Generator**: ssl-config.mozilla.org
- **HSTS Preload**: hstspreload.org
- **CAA Records**: sslmate.com/caa/
- **CT Search**: crt.sh
- **OWASP TLS Cheat Sheet**: cheatsheetseries.owasp.org

## Następne kroki

- **Rozdział 06-01** — Let's Encrypt na Windows szczegółowo
- **Rozdział 06-02** — TLS hardening (ciphers, protocols, HSTS)
- **Rozdział 06-03** — Własne CA z AD CS dla intranet
- **Rozdział 09** — Publikowanie usług publicznych (architektura)
- **Rozdział 07** — Bezpieczeństwo fundamenty
