# Dystrybucja, instalatory i ochrona

Wtyczka działa, kompiluje się, brzmi świetnie — ale to dopiero połowa pracy. Teraz musisz ją **zapakować**, **zabezpieczyć** przed piractwem i **dostarczyć** użytkownikowi w sposób, który nie będzie blokowany przez Windows Defender lub Gatekeeper macOS. Ten rozdział to praktyczny przewodnik.

## Pliki plugin per platforma

Każda platforma ma własną konwencję ścieżek instalacji. **Łamanie tych konwencji = plugin nie zostanie wykryty przez DAW.**

### Windows

| Format | Ścieżka |
|--------|---------|
| **VST3** | `C:\Program Files\Common Files\VST3\YourPlugin.vst3` |
| **VST2 (legacy)** | `C:\Program Files\VstPlugins\YourPlugin.dll` (zwyczajowo, brak standardu) |
| **AAX** | `C:\Program Files\Common Files\Avid\Audio\Plug-Ins\YourPlugin.aaxplugin` |
| **CLAP** | `C:\Program Files\Common Files\CLAP\YourPlugin.clap` |

VST3 na Windows to **bundle** (folder z rozszerzeniem `.vst3`), nie pojedynczy plik DLL — w środku struktura `Contents/x86_64-win/YourPlugin.vst3` (gdzie ostatni `.vst3` to już DLL).

### macOS

| Format | Ścieżka |
|--------|---------|
| **VST3** | `/Library/Audio/Plug-Ins/VST3/YourPlugin.vst3` |
| **AU (Audio Unit)** | `/Library/Audio/Plug-Ins/Components/YourPlugin.component` |
| **AAX** | `/Library/Application Support/Avid/Audio/Plug-Ins/YourPlugin.aaxplugin` |
| **CLAP** | `/Library/Audio/Plug-Ins/CLAP/YourPlugin.clap` |

Wszystkie te pliki na macOS to **bundle** (folder traktowany jako pojedynczy plik). User-level alternatives dostępne w `~/Library/Audio/Plug-Ins/...` — ale instalator zwykle pyta o admin password i wrzuca do system-level.

### Linux (opcjonalnie)

| Format | Ścieżka |
|--------|---------|
| **VST3** | `/usr/lib/vst3/` lub `~/.vst3/` |
| **CLAP** | `/usr/lib/clap/` lub `~/.clap/` |
| **LV2** | `/usr/lib/lv2/` lub `~/.lv2/` |

## Narzędzia tworzenia instalatorów

### Windows

| Narzędzie | Cena | Uwagi |
|-----------|------|-------|
| **Inno Setup** | Free | Najpopularniejszy w plugin community. Pascal Script. Wystarczający dla 95% przypadków. |
| **NSIS** | Free | Starszy, niższy poziom. Mniejsze, ale mniej user-friendly. |
| **WiX Toolset** | Free | MSI installers, enterprise-grade. Stroma krzywa nauki. |
| **Advanced Installer** | $$ | GUI builder, MSI + EXE, świetne support kodowania. |
| **InstallShield** | $$$$ | Enterprise. Rzadko używany w plugin world. |

**Rekomendacja:** **Inno Setup** dla małych/średnich, **WiX** jeśli musisz MSI (wymóg korporacyjny), **Advanced Installer** jeśli budżet pozwala i chcesz GUI.

### macOS

| Narzędzie | Cena | Uwagi |
|-----------|------|-------|
| **Packages** | Free | GUI tool, najpopularniejszy. Wymaga konfiguracji ale solidny. |
| **pkgbuild + productbuild** | Free | Apple command line. Skryptowalny, idealny do CI/CD. |
| **DMG creator (DropDMG, create-dmg)** | Free/Paid | Customowe DMG z designem. |
| **Munki / JAMF** | Free/$$ | Enterprise deployment. |

**Rekomendacja:** kombinacja `pkgbuild + productbuild` w skrypcie CI/CD, opcjonalnie **Packages** dla wizualnego setupu pierwszego instalatora.

## Inno Setup — przykładowy skrypt

```iss
[Setup]
AppName=Awesome Reverb
AppVersion=1.2.0
AppPublisher=YourCompany
AppPublisherURL=https://yourcompany.com
DefaultDirName={pf}\YourCompany\AwesomeReverb
DefaultGroupName=YourCompany\AwesomeReverb
OutputDir=installer_output
OutputBaseFilename=AwesomeReverb-1.2.0-Win-Setup
Compression=lzma2/ultra
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64
SetupIconFile=icon.ico
WizardImageFile=wizard.bmp
WizardSmallImageFile=wizard-small.bmp

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"

[Components]
Name: "vst3"; Description: "VST3 Plugin"; Types: full
Name: "aax";  Description: "AAX Plugin (Pro Tools)"; Types: full
Name: "presets"; Description: "Factory Presets"; Types: full

[Files]
; VST3 — folder bundle
Source: "build\AwesomeReverb.vst3\*"; \
  DestDir: "{commoncf}\VST3\AwesomeReverb.vst3"; \
  Flags: ignoreversion recursesubdirs createallsubdirs; \
  Components: vst3

; AAX
Source: "build\AwesomeReverb.aaxplugin\*"; \
  DestDir: "{commoncf}\Avid\Audio\Plug-Ins\AwesomeReverb.aaxplugin"; \
  Flags: ignoreversion recursesubdirs; \
  Components: aax

; Presets
Source: "presets\*.preset"; \
  DestDir: "{userdocs}\YourCompany\AwesomeReverb\Presets"; \
  Flags: ignoreversion recursesubdirs; \
  Components: presets

; Manual
Source: "docs\Manual.pdf"; \
  DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Manual"; Filename: "{app}\Manual.pdf"
Name: "{group}\Uninstall"; Filename: "{uninstallexe}"

[Code]
function InitializeSetup(): Boolean;
begin
  // Sprawdz licencje, wymagana wersja Windows itp.
  Result := True;
end;
```

Build z linii poleceń:
```bash
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss
```

## macOS — pkgbuild + productbuild

```bash
#!/bin/bash
PLUGIN_NAME="AwesomeReverb"
VERSION="1.2.0"
BUNDLE_ID="com.yourcompany.awesomereverb"
DEV_ID="Developer ID Installer: Your Company (XXXXXXXXXX)"

# 1. Code sign plugin bundles
codesign --force --deep --options runtime \
  --sign "Developer ID Application: Your Company (XXXXXXXXXX)" \
  build/${PLUGIN_NAME}.vst3

codesign --force --deep --options runtime \
  --sign "Developer ID Application: Your Company (XXXXXXXXXX)" \
  build/${PLUGIN_NAME}.component

# 2. pkgbuild dla kazdego formatu
pkgbuild --root build/${PLUGIN_NAME}.vst3 \
  --identifier ${BUNDLE_ID}.vst3 \
  --version ${VERSION} \
  --install-location "/Library/Audio/Plug-Ins/VST3/${PLUGIN_NAME}.vst3" \
  pkg-build/${PLUGIN_NAME}-VST3.pkg

pkgbuild --root build/${PLUGIN_NAME}.component \
  --identifier ${BUNDLE_ID}.au \
  --version ${VERSION} \
  --install-location "/Library/Audio/Plug-Ins/Components/${PLUGIN_NAME}.component" \
  pkg-build/${PLUGIN_NAME}-AU.pkg

# 3. productbuild laczy w jeden installer
productbuild \
  --distribution distribution.xml \
  --resources resources \
  --package-path pkg-build \
  --sign "${DEV_ID}" \
  ${PLUGIN_NAME}-${VERSION}.pkg

# 4. Notarization (Apple)
xcrun notarytool submit ${PLUGIN_NAME}-${VERSION}.pkg \
  --apple-id "you@yourcompany.com" \
  --team-id "XXXXXXXXXX" \
  --password "@keychain:notarytool-password" \
  --wait

# 5. Staple ticket
xcrun stapler staple ${PLUGIN_NAME}-${VERSION}.pkg

# 6. Pakuj do DMG
hdiutil create -volname "${PLUGIN_NAME} ${VERSION}" \
  -srcfolder ${PLUGIN_NAME}-${VERSION}.pkg \
  -ov -format UDZO \
  ${PLUGIN_NAME}-${VERSION}.dmg
```

`distribution.xml` definiuje wybór komponentów, wymagania OS, branding:

```xml
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
  <title>Awesome Reverb</title>
  <organization>com.yourcompany</organization>
  <domains enable_localSystem="true"/>
  <options customize="always" require-scripts="false" hostArchitectures="arm64,x86_64"/>
  <welcome file="welcome.rtf"/>
  <license file="license.rtf"/>
  <conclusion file="conclusion.rtf"/>
  <choices-outline>
    <line choice="vst3"/>
    <line choice="au"/>
  </choices-outline>
  <choice id="vst3" title="VST3 Plugin">
    <pkg-ref id="com.yourcompany.awesomereverb.vst3"/>
  </choice>
  <choice id="au" title="Audio Unit (AU)">
    <pkg-ref id="com.yourcompany.awesomereverb.au"/>
  </choice>
  <pkg-ref id="com.yourcompany.awesomereverb.vst3" version="1.2.0">AwesomeReverb-VST3.pkg</pkg-ref>
  <pkg-ref id="com.yourcompany.awesomereverb.au" version="1.2.0">AwesomeReverb-AU.pkg</pkg-ref>
</installer-gui-script>
```

## Bundle ID i podpisywanie kodu

### Windows code signing

Wymóg dla uniknięcia SmartScreen/Defender warnings. Procedura:

1. **Kup certyfikat** — Sectigo, DigiCert, GlobalSign, SSL.com (~$250-600/rok). **EV (Extended Validation)** lepszy — daje natychmiastową reputację (zamiast czekania aż wystarczająco userzy zainstalują żeby SmartScreen przestał ostrzegać).
2. **Hardware token** — od 2023 wszystkie code signing certs **muszą** być w HSM/USB token (np. SafeNet eToken). Programowe certyfikaty już niedostępne.
3. **Sign**:

```cmd
signtool sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 ^
  /a /v MyPlugin.vst3
signtool sign /tr http://timestamp.digicert.com /td sha256 /fd sha256 ^
  /a /v MyPluginInstaller.exe
```

Zawsze podpisuj **z timestampingiem** — bez tego sygnatura wygasa razem z certyfikatem.

### macOS code signing + notarization

**Apple Developer Account** wymagany ($99/rok). Procedura:

1. Wygeneruj **Developer ID Application** i **Developer ID Installer** certyfikaty w **xcode-select**.
2. Sign plugin bundles z `--options runtime` (Hardened Runtime).
3. Sign installer pkg.
4. **Notarize** — wyślij do Apple, czekaj 5-30 min.
5. **Staple** — przybij ticket do pliku, żeby Gatekeeper nie potrzebował internetu.

```bash
# Sprawdz czy plugin jest poprawnie podpisany
codesign --verify --deep --strict --verbose=2 build/MyPlugin.vst3
spctl -a -t exec -vv build/MyPlugin.vst3
```

Bez notarization: plugin nie ładuje się na nowych macOS (Gatekeeper blokuje), DAW pokazuje "damaged" lub "developer cannot be verified".

## Strategia cross-platform

**Złota zasada:** Windows i macOS = **dwa osobne instalatory**. Próby tworzenia uniwersalnego instalatora (Java InstallAnywhere, etc.) kończą się źle. User pobiera tylko jeden, zawsze.

```
yourcompany.com/downloads
├── AwesomeReverb-1.2.0-Win-Setup.exe      (Windows)
├── AwesomeReverb-1.2.0-macOS.dmg          (macOS Universal)
└── AwesomeReverb-1.2.0-Linux.tar.gz       (Linux, opcjonalne)
```

**macOS Universal Binary** — pojedynczy plugin obsługujący **arm64** (Apple Silicon) i **x86_64** (Intel) w jednym bundle, dzięki `lipo`. Wszystkie nowe pluginy 2026+ powinny być Universal.

## Anti-piracy — strategie

**Realistyczne podejście:** każda ochrona zostanie złamana. Pytanie brzmi — **kiedy** i **jakim kosztem**. Plugin software ma wysoki piracy rate (~50-80% w niszowych formatach). Najlepsze plugins (FabFilter, UAD, Waves) godzą się z tym i koncentrują na user experience.

| Metoda | Koszt impl | Trudność łamania | Polecane |
|--------|------------|------------------|----------|
| **Bez ochrony (free trial all-in)** | $0 | N/A | Indie, freeware |
| **Serial key + email** | Niski | Bardzo niska | Indie, taniej $20-50 |
| **Online activation + offline cache** | Średni | Niska/średnia | Mid-range $50-150 |
| **Hardware fingerprinting** | Średni | Średnia | Mid-range, customowe |
| **iLok (PACE)** | Wysoki ($) | Wysoka | Pro $200+, AAX, Plugin Alliance |
| **eLicenser** | N/A | Średnia | Deprecated 2024 (Steinberg) |
| **VMProtect + iLok kombinacja** | Bardzo wysoki | Bardzo wysoka | Tylko enterprise/AAX |

### iLok (PACE)

**Standard branżowy** dla pluginów premium. Wymóg dla AAX (Pro Tools). Wsparcie:
- **iLok Cloud** (online) — 2 device limit, no USB needed
- **iLok USB key** — 3rd-gen, $50, fizyczny token
- **Machine activation** — 2 maszyny, hardware-bound

Integracja przez **PACE Eden** SDK. Kosztuje **$$$$$ rocznie** + per-activation fees. Praktycznie tylko dla większych firm. Indie alternatywą jest **License key + online activation**.

### Custom license server

Najczęstsze rozwiązanie u indie devów. Server backend (Node/Go/Python) trzyma DB licencji, plugin wysyła hardware fingerprint + license key, server zwraca podpisany token cache'owany lokalnie z grace period (np. 30 dni offline).

```cpp
// Uproszczony przyklad walidacji licencji
class LicenseValidator {
public:
    bool validate(const std::string& licenseKey) {
        // 1. Spróbuj online aktywacji
        auto response = httpClient.post("https://api.yourcompany.com/activate", {
            {"license_key", licenseKey},
            {"hardware_id", getHardwareFingerprint()},
            {"product", "AwesomeReverb"},
            {"version", "1.2.0"}
        });

        if (response.statusCode == 200) {
            // Server zwraca podpisany token z signed expiration
            saveTokenLocally(response.body);
            return verifyTokenSignature(response.body);
        }

        // 2. Fallback: offline grace period
        auto cachedToken = loadTokenLocally();
        if (cachedToken.empty()) return false;
        if (!verifyTokenSignature(cachedToken)) return false;

        auto expiry = getTokenExpiry(cachedToken);
        auto now = std::chrono::system_clock::now();
        auto daysSinceLastCheck = std::chrono::duration_cast<std::chrono::hours>(
            now - getLastCheckTime()).count() / 24;

        return daysSinceLastCheck < 30;  // 30 dni offline
    }

    std::string getHardwareFingerprint() {
        // Combo: MAC address + CPU ID + motherboard serial
        return sha256(getMacAddress() + getCpuId() + getMotherboardSerial());
    }
};
```

**Best practice:** użyj **asymetrycznego podpisu** (ECDSA) — server podpisuje prywatnym kluczem, plugin weryfikuje publicznym (zaszytym w binary). Cracker musiałby znaleźć private key na serverze, nie w pluginie.

### Demo / trial implementation

| Pattern | Jak działa | Plusy | Minusy |
|---------|-----------|-------|--------|
| **Time limit** | 14-30 dni od first run | Pełna funkcjonalność | Łatwo cofnąć system clock |
| **Save/recall disabled** | Plugin działa, ale state nie zapisuje | User słyszy efekt | Wysoki refund rate jeśli niejasne |
| **Periodic noise / silence** | Co 60s plugin daje cisze 1s lub szum | Driving — user słyszy ograniczenie | Trudny dla mastering pluginów |
| **Watermark output** | Niskopoziomowy szum/efekt zawsze obecny | Sprzedaje sie | Trudno dobrac niewinny watermark |
| **Limited presets** | Demo ma 3 presety, full ma 50+ | Sprzedaze przez preset hunger | Tylko jeśli presety są atrakcją |

**Najpopularniejsze** w 2026: **time-limit (14 dni full features)** + **periodic short silence** dla pluginów po time-limit. Encore Software: "**Sing Mode**" — gdy plugin wykrywa CPU < threshold, dodaje delay/distortion.

## Update mechanisms

### macOS — Sparkle

**Sparkle Framework** to standard. Plugin ładuje XML feed (appcast.xml), sprawdza wersję, oferuje update.

```xml
<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" version="2.0">
  <channel>
    <title>AwesomeReverb Updates</title>
    <item>
      <title>Version 1.2.0</title>
      <pubDate>Wed, 15 Apr 2026 12:00:00 +0000</pubDate>
      <enclosure url="https://yourcompany.com/AwesomeReverb-1.2.0.dmg"
                 sparkle:version="1.2.0"
                 sparkle:edSignature="..."
                 length="12345678"
                 type="application/octet-stream"/>
      <description>Bug fixes, improved CPU performance.</description>
    </item>
  </channel>
</rss>
```

Plugin code signs updates kluczem EdDSA — bez tego Sparkle odmawia instalacji.

### Windows — custom solution

Brak standardu. Najczęściej:
- Plugin sprawdza JSON endpoint przy starcie
- Jeśli nowsza wersja — pokazuje banner "Update available"
- Klik otwiera browser do download (nie auto-install — bo permissions)

Niektórzy używają **Squirrel.Windows** lub **WinSparkle** (port Sparkle dla Win), ale rzadkość.

## VMProtect i obfuscation

**VMProtect** to komercyjny tool ($$$) który:
- Szyfruje sekcje kodu, deszyfruje runtime
- Wirtualizuje krytyczne funkcje (interpretowane VM-bytecode)
- Anti-debug, anti-VM detection
- Code obfuscation

Stosowane wraz z iLok dla AAX (Pro Tools) — dla PACE wymóg żeby krytyczna logika była VMProtected. Konfiguracja:

```cpp
// Markery dla VMProtect kompilatora
#include "VMProtectSDK.h"

bool validateLicense() {
    VMProtectBeginVirtualization("LicenseCheck");
    // Krytyczna logika tutaj — zamieniona na VM bytecode
    auto fingerprint = getHardwareFingerprint();
    auto valid = checkSignature(fingerprint);
    VMProtectEnd();
    return valid;
}
```

**Uwaga:** zbyt agresywny VMProtect = drastyczny spadek performance. **NIE** wirtualizuj `processBlock` ani innego DSP code — tylko license checks i license parsing.

## Dystrybucja — platformy

### Plugin Boutique

**Największy specjalistyczny store** dla pluginów audio. ~15-20% commission. Wymaga aplikacji ich curation team. Idealny dla nowych devów — driver organic traffic, mają loyal customer base, częste sale events.

**Plusy:** market reach, scheduled sales (Black Friday push), Loyalty Points system. **Minusy:** commission, oczekiwanie na approval (tygodnie), konkurencja w listing.

### Plugin Alliance

**Premium curation**, focus na pro audio. Niższy ratio aplikacji vs accept. Synchronizacja sales z Brainworx, Lindell, etc. Bardziej selektywny — jeśli przyjmą, to znaczy że masz quality plugin.

### Splice

Bardziej **subscription-based** (Splice Sounds), dla pluginów to **rent-to-own** model. Świetne dla onboardingu młodszych producentów (hip-hop, electronic). Inne demographics niż Plugin Boutique (raczej studyjne).

### Native Instruments / Komplete

**Gated**, bardzo trudne. NI selectionują tylko najlepsze, ale jak się dostaniesz w Komplete bundle — to game-changer dla sprzedaży. Lata aplikacji często.

### Własna strona (preferowane długoterminowo)

**Najwięcej zarobku, ale wymaga marketingu.** Stack:
- **Shopify** + **Digital Downloads app** — najprostszy
- **WordPress + WooCommerce + EDD** — bardziej customowe
- **FastSpring** lub **Paddle** — Merchant of Record (oni handlują VAT, refunds, fraud)
- **Stripe + custom backend** — jeśli masz dev resources

**FastSpring** popular w plugin world bo:
- Handluje VAT MOSS (UE), GST (AU), Japan tax
- Refund policy management
- Anti-fraud built-in
- Fee ~5.9% + $0.95 per transaction

## File size optimization

Userzy widzą "**157 MB plugin**" i robią abandonment. Optymalizacja:

| Technika | Jak | Saving |
|----------|-----|--------|
| **Strip debug symbols** | `strip -S MyPlugin` (macOS), default Release (MSVC) | 20-50% |
| **LTO (Link Time Optimization)** | `-flto` w build flags | 5-15% |
| **Compress samples/IRs** | FLAC zamiast WAV, OGG dla loops | 50-70% per asset |
| **Lazy load assets** | Załaduj IR przy pierwszym użyciu, nie przy startup | RAM, nie size |
| **Remove unused dependencies** | Audyt linked libs | Zmienne |
| **Optimize images** | WebP/AVIF zamiast PNG, skompresuj UI assets | 40-70% per asset |
| **Single-arch builds** | Per-platform, nie Universal jeśli unfinish | 50% (Mac) |
| **UPX compression DLL** | Tylko Windows, lekko ryzykowne (AV alarm) | 30-50% |

**Cel:** instalator pod 50MB dla efektów, pod 200MB dla samplerów. Convolution reverb z 4GB IR library to inna kategoria — komunikuj wprost przed download.

## Praktyczne checklisty

**Pre-release Windows:**
- [ ] VST3 podpisany Authenticode
- [ ] Instalator EXE podpisany Authenticode
- [ ] Test na czystym Windows 10/11 (świeża VM)
- [ ] SmartScreen warning poziom akceptowalny
- [ ] Antywirus scan (Windows Defender, Malwarebytes)
- [ ] Test instalacji bez admin rights (powinno fail gracefully)

**Pre-release macOS:**
- [ ] Universal Binary (arm64 + x86_64)
- [ ] Hardened Runtime enabled
- [ ] All bundles code signed
- [ ] Notarized + stapled
- [ ] DMG podpisany
- [ ] Test na świeżym macOS (VM lub second Mac)
- [ ] Test w Logic, Live, Reaper, Pro Tools

**License/protection:**
- [ ] License validation działa offline (grace period)
- [ ] Demo/trial flow przejrzysty
- [ ] Activation server stable (load tested)
- [ ] Fallback gdy server down
- [ ] Privacy policy zgodna z RODO/CCPA
