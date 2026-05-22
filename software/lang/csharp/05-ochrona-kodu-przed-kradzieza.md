# Ochrona kodu C# / .NET przed kradzieżą

## Problem: .NET to kompilacja do bytecode czytelnego

W przeciwieństwie do PHP (interpretowany) lub C/C++ (natywne binary), **.NET kompiluje się do IL (Intermediate Language)** — bytecode dla CLR.

```
C# source (.cs)
   ↓ csc.exe / dotnet build
IL (.dll / .exe)
   ↓ JIT in runtime
Native code (in memory)
```

**Problem:** IL jest trywialnie czytelny przez decompiler (np. **dnSpy, ILSpy, dotPeek**). Każdy może zobaczyć pełny C# kod z `.dll` Twojej aplikacji.

```bash
# Pokażmy dnSpy
1. Otwórz MyApp.dll w dnSpy
2. Browse hierarchy → klasy, metody
3. Right-click → "Edit Class" → widzisz pełny C# kod
4. Możesz nawet modyfikować i save!
```

To **GIGANTYCZNE** ryzyko dla komercyjnych .NET aplikacji.

## Modele ochrony

### 1. Obfuskacja (zmiana nazw + struktur)
Nie zmienia funkcjonalności, tylko utrudnia czytanie.

### 2. Stringi i resources encryption
Ukrycie wrażliwych ciągów, kluczy, queries SQL.

### 3. Anti-tampering / Anti-debug
Wykrywanie debuggerów, modyfikacji binary.

### 4. AOT (Ahead-of-Time) compilation
Kompilacja do natywnego binary — **nie ma IL** w finalnym pliku.

### 5. Code virtualization
Najsilniejsza technika — przekształca IL w custom VM bytecode.

### 6. License management
Validacja licencji online/offline.

## Komercyjne obfuskatory (state-of-the-art 2026)

### Dotfuscator (PreEmptive)

**Najstarszy gracz**, w pakiecie z Visual Studio (Community Edition free, Pro/Enterprise paid).

**Plusy:**
- Free Community Edition (basic obfuscation)
- Integracja z Visual Studio
- Wsparcie .NET Framework, .NET Core, .NET 5+, Xamarin
- Anti-tamper, anti-debug w paid version
- Tag-based obfuscation (decyduje co obfuskować przez attributes)

**Minusy:**
- Community Edition bardzo limitowany
- Pro/Enterprise cena: $1500-5000+ rocznie
- Mniej agresywny niż konkurenci

**Workflow:**
```bash
# Z poziomu Visual Studio: Build → Tools → PreEmptive Protection - Dotfuscator
# Lub CLI:
dotfuscator MyApp.dll /out=protected/
```

### ConfuserEx 2 (open source)

**Free, open source, agresywny.** Najpopularniejszy free obfuskator dla .NET.

**Plusy:**
- W pełni darmowy
- Bardzo silna ochrona (renaming, control flow, anti-debug, anti-dump)
- Aktywna społeczność (ConfuserEx 2 fork z aktualizacjami)
- Wsparcie .NET Framework + .NET Core/5+
- Resource encryption, constants encryption

**Minusy:**
- Brak komercyjnego wsparcia
- Może być wykryty jako "malware" przez niektóre AV (false positive)
- Niektóre techniki crackowane (deobfuscatory dostępne np. **de4dot**)
- Skomplikowany config

**Konfiguracja (`MyApp.crproj`):**
```xml
<project outputDir="output" baseDir="C:\Project" xmlns="http://confuser.codeplex.com">
  <module path="MyApp.dll">
    <rule pattern="true">
      <protection id="rename" />
      <protection id="anti debug" />
      <protection id="anti dump" />
      <protection id="anti ildasm" />
      <protection id="anti tamper" />
      <protection id="ctrl flow" />
      <protection id="constants" />
      <protection id="ref proxy" />
      <protection id="resources" />
    </rule>
  </module>
</project>
```

```bash
ConfuserEx.exe MyApp.crproj
```

### Eazfuscator.NET

**Komercyjny, premium.** Wybierany przez wiele enterprise.

**Plusy:**
- Bardzo silna ochrona (homomorphic encryption, code virtualization w Pro)
- Excellent obfuscation quality
- Native code conversion (some methods)
- Active development
- Dobra dokumentacja

**Minusy:**
- Cena: $399 jednorazowo (Standard), $799 (Pro)
- Steeper learning curve

**Użycie:**
```xml
<!-- W .csproj -->
<PropertyGroup>
  <PostBuildEvent>
    eazfuscator.net "$(TargetPath)"
  </PostBuildEvent>
</PropertyGroup>
```

### .NET Reactor (Eziriz)

**Komercyjny, premium.** Najsilniejsza ochrona w klasie.

**Plusy:**
- **NecroBit technology** — converts IL into encrypted format
- Native code generation dla critical methods
- Anti-tamper, anti-debug, anti-dump
- License management built-in
- Code virtualization
- Wsparcie WPF, WinForms, ASP.NET, .NET Core
- AOT-like single-file output

**Minusy:**
- Cena: ~$180 jednorazowo (basic) do $560 (Multilanguage)
- Niektóre techniki crackowane

**Workflow:**
```bash
# CLI
dotnet_reactor.exe -file MyApp.exe -necrobit 1 -anti_tamp 1 -anti_debug 1 -encryption 1
```

### Babel Obfuscator

Komercyjny, profesjonalny. Konkurent Eazfuscator.

**Plusy:** silna obfuskacja, integracja z MSBuild, wsparcie modern .NET
**Minusy:** mniejsza społeczność niż konkurenci

### Smart Assembly (Red Gate)

**Komercyjny.** Specjalizuje się w error reporting + obfuskacja.

**Plusy:**
- Integracja z error tracking
- Łatwy w użyciu
- Wsparcie .NET Framework + .NET Core

**Minusy:**
- $795/rok subscription
- Mniej agresywny niż ConfuserEx/Reactor

## Porównanie — quick reference

| Tool | Cena | Free? | Strength | Best for |
|------|------|-------|----------|----------|
| **ConfuserEx 2** | Free | ✓ | High | Indie, hobbyists |
| **Dotfuscator CE** | Free w VS | ✓ | Low | Quick basic protection |
| **Dotfuscator Pro** | $1500+/yr | ✗ | High | Enterprise w VS workflow |
| **Eazfuscator.NET** | $399 | ✗ | Very High | Mid-size commercial |
| **.NET Reactor** | $180-560 | ✗ | Very High | Most commercial uses |
| **Babel** | $$$ | ✗ | Very High | Enterprise |
| **Smart Assembly** | $795/yr | ✗ | High | Error tracking + protection |

## Techniki obfuskacji — szczegółowo

### 1. Symbol renaming (basic)
```csharp
// Przed
public class Calculator {
    public int Add(int a, int b) => a + b;
}

// Po
public class a {
    public int b(int c, int d) => c + d;
}
```

**Decompiler widzi:** logikę, ale nazwy są nieczytelne. Dobre, **ale można częściowo odzyskać** przez context analysis.

### 2. Control flow obfuscation
Zamienia liniowy kod w skomplikowany graf.
```csharp
// Przed
if (x > 5) return "big"; else return "small";

// Po (uproszczone)
int state = 0;
while (true) {
    switch (state) {
        case 0: state = (x > 5) ? 1 : 2; break;
        case 1: return "big";
        case 2: return "small";
    }
}
```

### 3. String encryption
```csharp
// Przed
string apiKey = "sk-secret-key-123";

// Po
string apiKey = Decrypt(new byte[] { 0xa1, 0xf3, ... });
```

### 4. Constants/literals encryption
Liczby, stringi przez encrypted lookup.

### 5. Resource encryption
Embedded resources (images, jsons) szyfrowane.

### 6. Anti-debugging
```csharp
if (Debugger.IsAttached) Environment.Exit(0);
if (DetectDnSpy()) Crash();
if (CheckProcessParent() == "ollydbg.exe") FormatHardDrive(); // joke
```

### 7. Anti-tampering
Self-integrity check (hash binary, compare).

### 8. Anti-dump
Wykrywa próby dump procesu z pamięci.

### 9. Code virtualization (najsilniejsza!)
IL → custom VM bytecode → custom VM interpreter.
```
Original IL: ldarg.0, ldarg.1, add, ret
Virtualized: 0xA1 0xF3 0x21 0x88 (custom opcodes, custom VM)
```

Tylko `.NET Reactor`, `Eazfuscator Pro`, `VMProtect` (głównie native).

### 10. Native compilation
Konkretne metody kompilowane do natywnego binary, niedostępne dla IL decompilers.

## AOT (Ahead-of-Time) Compilation — game changer 2026

**.NET 8/9 wprowadziły production-ready Native AOT.** Kompiluje C# do natywnego binary — **bez IL!**

```bash
# Build z AOT
dotnet publish -r win-x64 -c Release \
    /p:PublishAot=true \
    /p:StripSymbols=true
```

**Plusy:**
- **Brak IL = brak decompiler attack**
- Single binary (no .dll dependencies)
- Szybszy startup (no JIT)
- Mniejszy memory footprint

**Minusy:**
- Limitations (no reflection, no Assembly.Load, etc.)
- Trim warnings (musisz adjust kod)
- Większy binary niż .dll
- Nie wszystkie biblioteki kompatybilne (rośnie co miesiąc w 2026)

**Konfiguracja w `.csproj`:**
```xml
<PropertyGroup>
    <PublishAot>true</PublishAot>
    <StripSymbols>true</StripSymbols>
    <InvariantGlobalization>true</InvariantGlobalization>
    <DebugType>none</DebugType>
    <DebugSymbols>false</DebugSymbols>
</PropertyGroup>
```

**W 2026:** AOT to **najlepsza ochrona** dla nowych projektów .NET.

## Single-file deployment

`.NET 6+` może produkować single executable (z embedded dependencies).

```bash
dotnet publish -r win-x64 -c Release \
    -p:PublishSingleFile=true \
    -p:IncludeNativeLibrariesForSelfExtract=true \
    -p:EnableCompressionInSingleFile=true
```

**Ale:** sam single-file nie chroni — embedded dlls można wyciągnąć. Połącz z **AOT** lub **obfuscation**.

## Strategia ochrony — multi-layer (rekomendowana 2026)

```
Layer 1: AOT compilation (jeśli możliwe)
Layer 2: Obfuscation (ConfuserEx Free / .NET Reactor Pro)
Layer 3: String/resource encryption
Layer 4: Anti-debug + anti-tamper
Layer 5: License validation (online + offline)
Layer 6: Critical logic w cloud (SaaS hybrid)
Layer 7: Hardware fingerprinting
Layer 8: Watermarking per-customer build
Layer 9: Legal (EULA, copyright)
Layer 10: Monitoring kradzieży (telemetry)
```

## Strong Naming

**Strong-named assemblies** mają public/private key signature.

```bash
# Generate key
sn -k mykey.snk

# Build z signing
dotnet build -p:SignAssembly=true -p:AssemblyOriginatorKeyFile=mykey.snk
```

**Czego NIE robi:**
- ❌ NIE chroni przed reverse engineering
- ❌ NIE szyfruje kodu

**Co robi:**
- ✓ Identyfikacja autora (zapobiega replacing w GAC)
- ✓ Wymaga rebuild z nowym kluczem żeby modify assembly
- ✓ Niewielki deterrent dla casual modification

**Limitations:** Można strip strong name z assembly (`sn -Vr` removes strong name verification).

## License management dla .NET

### Online validation

```csharp
public class LicenseManager
{
    private readonly HttpClient _http = new();
    private readonly string _apiUrl = "https://api.yourcompany.com/license/verify";

    public async Task<bool> IsValid(string licenseKey)
    {
        var response = await _http.PostAsJsonAsync(_apiUrl, new
        {
            Key = licenseKey,
            HardwareId = HardwareIdHelper.GetUnique(),
            ProductVersion = Assembly.GetExecutingAssembly().GetName().Version.ToString()
        });

        if (!response.IsSuccessStatusCode) return false;

        var data = await response.Content.ReadFromJsonAsync<LicenseResponse>();
        return data!.Valid && data.ExpiresAt > DateTime.UtcNow;
    }
}

public static class HardwareIdHelper
{
    public static string GetUnique()
    {
        var cpuId = GetCpuId();
        var motherboardSerial = GetMotherboardSerial();
        var biosUuid = GetBiosUuid();
        return ComputeHash(cpuId + motherboardSerial + biosUuid);
    }
}
```

### Offline JWT validation

```csharp
using System.IdentityModel.Tokens.Jwt;

public class OfflineLicenseValidator
{
    private readonly RSA _publicKey; // embedded w assembly

    public LicenseInfo Validate(string licenseToken)
    {
        var handler = new JwtSecurityTokenHandler();
        var validationParams = new TokenValidationParameters
        {
            IssuerSigningKey = new RsaSecurityKey(_publicKey),
            ValidateIssuer = true,
            ValidIssuer = "yourcompany.com",
            ValidateAudience = false,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.Zero
        };

        var principal = handler.ValidateToken(licenseToken, validationParams, out _);
        return ExtractLicenseInfo(principal);
    }
}
```

### Komercyjne biblioteki:
- **Treek's Licensing System** — popular, łatwy
- **PortableApps License Library**
- **Cryptolens** — SaaS, modern (free tier dostępny)
- **LicenseSpring** — managed, multi-platform
- **Keygen.sh** — open source server, paid SaaS

## Anti-tampering w praktyce

```csharp
public class IntegrityCheck
{
    private static readonly Dictionary<string, string> ExpectedHashes = new()
    {
        ["MyApp.dll"] = "ABC123DEF456...",
        ["MyApp.Core.dll"] = "789XYZ012..."
    };

    public static bool VerifyIntegrity()
    {
        foreach (var (file, expectedHash) in ExpectedHashes)
        {
            var path = Path.Combine(AppContext.BaseDirectory, file);
            if (!File.Exists(path)) return false;

            using var stream = File.OpenRead(path);
            using var sha = SHA256.Create();
            var hash = Convert.ToHexString(sha.ComputeHash(stream));

            if (hash != expectedHash) return false;
        }
        return true;
    }
}

// W bootstrap
if (!IntegrityCheck.VerifyIntegrity())
{
    Environment.FailFast("Integrity check failed");
}
```

**Uwaga:** atakujący może zmodyfikować ten kod. To **opóźnia** atak, nie zatrzymuje.

## Anti-debugging w .NET

```csharp
public static class AntiDebug
{
    public static bool IsDebugged()
    {
        if (Debugger.IsAttached) return true;
        if (Debugger.IsLogging()) return true;

        // Check for IsDebuggerPresent (Win32)
        if (NativeMethods.IsDebuggerPresent()) return true;

        // CheckRemoteDebuggerPresent
        bool isRemote = false;
        NativeMethods.CheckRemoteDebuggerPresent(
            Process.GetCurrentProcess().Handle, ref isRemote);
        if (isRemote) return true;

        // Check for common debugger processes
        var debuggers = new[] { "dnSpy", "ILSpy", "dotPeek", "x64dbg", "ollydbg" };
        if (Process.GetProcesses().Any(p => debuggers.Contains(p.ProcessName)))
            return true;

        return false;
    }
}
```

## NuGet Package Protection

Jeśli sprzedajesz NuGet package:

### Private NuGet feed
- **Azure Artifacts** — private feed
- **MyGet** — alternative
- **Sonatype Nexus** — self-hosted
- **GitHub Packages** — z GitHub Pro

Klient potrzebuje credentials do download → kontrolujesz dostęp.

### Package signing
```bash
# NuGet packages można sign (od 2018)
nuget sign MyPackage.nupkg \
    -CertificatePath cert.pfx \
    -CertificatePassword "..." \
    -Timestamper http://timestamp.digicert.com
```

Klient może verify integrity. Atakujący nie może modify package bez resign.

## Wybór strategii — practical guide

### "Sprzedaję desktop app (mała skala)"
- **AOT compilation** (jeśli możliwe)
- **ConfuserEx 2** (free, dobra ochrona)
- **License key validation** (online + offline JWT)
- **Cryptolens** dla license management (free tier)
- **Code signing certificate** (~$300/yr) dla SmartScreen reputation

### "Sprzedaję enterprise app .NET"
- **.NET Reactor** lub **Eazfuscator.NET Pro**
- **License manager** (Cryptolens, LicenseSpring)
- **Critical logic w cloud SaaS** (klient ma thin client)
- **Hardware fingerprinting**
- **Watermarking** per customer
- **Code signing** + **Anti-tamper checks**
- **Telemetry** (Microsoft Application Insights)

### "Sprzedaję NuGet library"
- **Strong naming**
- **Private NuGet feed** lub paid Packagist
- **License key system** w bibliotece
- **AOT-friendly code** (klient może AOT compile = lepsza ochrona dla niego)

### "Tworzę open source z paid features"
- **Free tier:** GitHub open source
- **Pro tier:** ConfuserEx encoded DLL
- **License validation** dla Pro features

### "Game/desktop SaaS"
- **Server-authoritative architecture** (klient nie może cheat)
- Native AOT dla launcher
- **Steamworks DRM** (jeśli na Steam)
- **VMProtect** dla anti-cheat (komercyjnie)

## Wydajność po obfuskacji

| Technique | Overhead |
|-----------|----------|
| Symbol renaming | <1% |
| Control flow obfuscation | 5-15% |
| String encryption | 2-5% |
| Anti-tamper | 1-5% |
| Code virtualization | 30-100%+ (drogie!) |
| AOT compilation | -10 do -30% (faster startup) |

**Praktyka:** Stack obfuscation dla większości kodu, virtualization tylko dla critical methods (license check, core algorithms).

## Co nie działa (anti-patterns)

### ❌ "DEBUG = false więc nie ma problemu"
Release vs Debug to różnica w optymalizacji + symbol info, ale IL wciąż jest plain.

### ❌ "Compiled to .exe = chronione"
.exe to też assembly z IL. Same problem.

### ❌ "Encrypted XML config"
Klucz encryption jest w binary → atakujący wyciąga klucz z decompiled code → odszyfrowuje config.

### ❌ "Custom encryption"
Większość roll-your-own crypto jest słabsza niż commercial.

### ❌ Client-only license check
Atakujący patchuje `if (licenseValid)` na `if (true)`. Trzeba server-side validation lub homomorphic encryption.

### ❌ Polegać tylko na 1 layer
Jeden tool = jedna metoda crack. Multi-layer = kompozycja kosztu.

## Crackowanie — perspektywa atakującego

Żeby zrozumieć obronę, zrozum atak:

### Tools używane przez crackerów:
- **dnSpy** — interactive .NET decompiler/debugger (gold standard)
- **ILSpy** — open source decompiler
- **dotPeek** (JetBrains) — free decompiler
- **de4dot** — generic .NET deobfuscator (radzi sobie z większością ConfuserEx, Eazfuscator low-tier, Reactor low-tier)
- **dnSpy + WinDbg** — advanced debugging
- **VirtualBox + tools** — sandbox testing
- **OllyDbg / x64dbg** — native debugging

### Typowy atak:
1. Open .dll w dnSpy
2. Find license check method (np. `IsValid`)
3. Patch to return `true`
4. Save modified .dll
5. Re-sign jeśli strong-named (lub `sn -Vr`)
6. Distribute "cracked" version

**Czas:** dla unprotected app = 5 minut. Z dobrą protection = godziny do dni.

### Twój cel:
**Przekrocz "frustrationthreshold"** — uczyń crack wystarczająco kosztownym żeby cracker poszedł do innego target.

## Monitoring kradzieży

### Telemetry
```csharp
// Send anonymous telemetry przy starcie
public static class Telemetry
{
    public static async Task SendStartup()
    {
        await Http.PostAsJsonAsync("https://telemetry.yourapp.com/startup", new
        {
            Version = AssemblyVersion(),
            HardwareId = HardwareIdHelper.GetUnique(),
            LicenseKey = LicenseKey,  // jeśli wymaga license
            // BEZ: PII, contents
        });
    }
}
```

Analizy:
- Anomalie (dziwne hardware IDs, masowo te same key)
- Geolocation (kraj który nie jest target market)
- Cracked indicators (np. modified binary hash)

### DMCA monitoring
Services które skanują internet pod kątem Twojego kodu:
- **Pixsy** — image/IP monitoring
- **Markmonitor** — brand protection
- **Custom scripts** — search GitHub, forums

## Code signing certificate

**Code signing** ≠ ochrona kodu, ale ważne:

```bash
# Sign executable
signtool sign /f cert.pfx /p password /tr http://timestamp.digicert.com /td sha256 /fd sha256 MyApp.exe
```

**Plusy:**
- Microsoft SmartScreen nie blokuje
- Windows installer pokazuje nazwę firmy zamiast "Unknown publisher"
- Uniemożliwia silent modification (modified binary loses signature)

**Cena:**
- **Standard:** $200-400/yr (Sectigo, Comodo)
- **EV (Extended Validation):** $400-800/yr — instant SmartScreen reputation
- **Hardware token** (od 2023 wymagany dla EV) — fizyczny USB

**Best practice 2026:** Code sign EVERY release, AND obfuscate.

## Updates strategy

```
1. Sign updates z private key
2. Verify signature przed install
3. Encrypt update payload
4. Server validates klient's license przed serving update
5. Differential updates (mniejsze, trudniej reverse)
```

## Linki i zasoby

- **ConfuserEx 2**: github.com/mkaring/ConfuserEx
- **.NET Reactor**: eziriz.com
- **Eazfuscator.NET**: eazfuscator.com
- **Dotfuscator**: preemptive.com
- **Babel Obfuscator**: babelfor.net
- **Cryptolens**: cryptolens.io (license management)
- **dnSpy** (do testowania): github.com/dnSpyEx/dnSpy
- **de4dot** (do testowania): github.com/de4dot/de4dot
- **NetGuard.NET**: alternative obfuscator

## Ważne: ochrona ≠ niemożność kradzieży

**Każdy obfuskator zostanie crackowany.** Ważne pytania:
- Ile to zajmie?
- Ile to kosztuje atakującego?
- Czy wartość Twojego software > koszt crack?

**Real targets:**
- $5 plugin → minimal protection (legalna ochrona głównie)
- $500 software → solid commercial obfuscator
- $50,000 enterprise → multi-layer + cloud architecture
- Anti-cheat / DRM gaming → VMProtect-grade + server-authoritative

## Następne kroki

- **Rozdział 04** — bezpieczeństwo aplikacji (OWASP, secure coding)
- **Rozdział 06** — narzędzia i deployment (AOT, single-file)
- W folderze **architektura/08-bezpieczenstwo** — fundamenty bezpieczeństwa
