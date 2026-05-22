# Cross-platform build: Windows + macOS

Plugin VST jest dziś z definicji **cross-platform**. Sprzedanie tylko jednej wersji platformowej to natychmiastowa utrata połowy rynku. W tym rozdziale: jak zbudować ten sam plugin na Windows i macOS, podpisać kod, znotaryzować na macOS, i zautomatyzować wszystko w GitHub Actions.

## Dlaczego obie platformy mają znaczenie

Rynek pluginów audio dzieli się asymetrycznie:

| Platforma | Udział użytkowników | Profil | Średnia cena pluginu |
|-----------|---------------------|--------|----------------------|
| **Windows** | ~55-60% | Większy install base, hobby + pro, FL/Cubase/Reaper/Ableton | $30-100 |
| **macOS** | ~35-40% | Logic Pro market, profesjonalne studia, premium | $50-200 |
| **Linux** | <5% | Power users, niche, Bitwig/Ardour | często free/donate |

**Dlaczego macOS = premium:**
- Logic Pro to flagship DAW Apple — milionów producentów (Logic +1.7M users globally w 2026)
- Studio profesjonalne preferują Mac (Pro Tools, Logic, Cubase)
- Klienci macOS częściej kupują (mniejsza piracy, wyższe budżety)
- AU jest wymagany dla Logic — VST3 nie wystarczy

**Dlaczego Windows = volume:**
- Największy install base (gaming, FL Studio, Reaper)
- Polski rynek = w 80% Windows
- Niższe ceny ale większe wolumeny sprzedaży
- Łatwiejszy entry point dla beginners (tańszy hardware)

**Wniosek:** musisz wspierać **obie platformy od dnia 1**. Wydanie tylko Windows == zignorowanie 35-40% rynku i ~50-60% revenue (bo macOS users płacą więcej).

## Środowisko deweloperskie macOS

### Wymagania sprzętowe

- **Mac z Apple Silicon (M1/M2/M3/M4)** — preferowane w 2026, native arm64
- Albo **Intel Mac** (legacy ale wciąż działa do 2027)
- **Minimum 16 GB RAM**, 32 GB komfortowe
- **macOS 13 Ventura minimum**, 14 Sonoma / 15 Sequoia rekomendowane

### Software setup

```bash
# 1. Xcode z App Store (~10 GB) — IDE + kompilator
# Wersja: Xcode 15+ dla macOS 14, Xcode 16+ dla macOS 15

# 2. Command Line Tools (oddzielnie!)
xcode-select --install

# 3. Homebrew — package manager
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. CMake + Ninja (faster builds)
brew install cmake ninja git

# 5. Verify
clang --version    # Apple clang version 15.0.0+
cmake --version    # cmake version 3.27+
```

### Apple Silicon vs Intel x86_64

W 2026 musimy wciąż supportować **obie architektury** macOS:

- **arm64** — Apple Silicon (M1, M2, M3, M4) — większość nowych Maców od 2020
- **x86_64** — Intel — wszystkie Maki sprzed listopada 2020 (jeszcze ~25% userów)

Rozwiązanie: **Universal Binary** — jeden plik `.vst3` zawierający kod na obie architektury (lipo). DAW automatycznie wybiera właściwą.

## Universal Binary — fat binary na macOS

CMake na macOS budujący universal:

```cmake
# W CMakeLists.txt, na samej górze (PRZED juce_add_plugin):
if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "Architectures" FORCE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "Min macOS" FORCE)
endif()
```

`CMAKE_OSX_DEPLOYMENT_TARGET 11.0` = Big Sur — pierwszy macOS z arm64. Niżej nie ma sensu (M1 wymaga 11.0+).

Sprawdź co wyszło:

```bash
# Po buildzie:
file MyGainPlugin.vst3/Contents/MacOS/MyGainPlugin
# Output:
# MyGainPlugin: Mach-O universal binary with 2 architectures: 
#   [x86_64:Mach-O 64-bit executable x86_64] 
#   [arm64:Mach-O 64-bit executable arm64]

lipo -info MyGainPlugin.vst3/Contents/MacOS/MyGainPlugin
# Architectures in the fat file: arm64 x86_64
```

## Środowisko deweloperskie Windows

### Wymagania

- **Windows 10/11 64-bit** (Win 11 preferowane w 2026)
- **Visual Studio 2022 Community** (darmowe) albo **Pro** ($45/mies) albo **VS 2025** (nowsze)
- **Workload "Desktop development with C++"** (zaznacz przy instalacji)
- **Windows SDK 10.0.22621+**
- **CMake** (samodzielnie albo z VS Installer)
- **Git for Windows**

### Instalacja

```powershell
# Visual Studio 2022 Community:
# https://visualstudio.microsoft.com/downloads/
# Workloads do zaznaczenia:
#   - Desktop development with C++
#     - MSVC v143 - VS 2022 C++ x64/x86 build tools
#     - Windows 11 SDK
#     - C++ CMake tools for Windows
#     - C++ AddressSanitizer (przydatne do debugowania)

# Verify (z Developer PowerShell):
cl              # Microsoft (R) C/C++ Optimizing Compiler Version 19.4x
cmake --version # cmake version 3.28+
```

## Single CMakeLists.txt dla obu platform

Cała sztuka cross-platform: **jeden plik konfiguracyjny**. CMake sam wykrywa platformę.

```cmake
cmake_minimum_required(VERSION 3.22)

# macOS-specific: universal binary + minimum macOS version
if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64" CACHE STRING "" FORCE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0" CACHE STRING "" FORCE)
endif()

# Windows-specific: static runtime (samowystarczalny .vst3)
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    add_compile_options(/MP)   # parallel compilation
endif()

project(MyPlugin VERSION 1.0.0)

add_subdirectory(JUCE)

# Format AAX tylko jeśli mamy SDK; AU tylko na macOS
if(APPLE)
    set(PLUGIN_FORMATS VST3 AU Standalone)
else()
    set(PLUGIN_FORMATS VST3 Standalone)
endif()

juce_add_plugin(MyPlugin
    COMPANY_NAME "MyCompany"
    BUNDLE_ID com.mycompany.myplugin
    PLUGIN_MANUFACTURER_CODE Mcmp
    PLUGIN_CODE Mpln
    FORMATS ${PLUGIN_FORMATS}
    PRODUCT_NAME "My Plugin"
    HARDENED_RUNTIME_ENABLED TRUE     # macOS notarization wymaga
    HARDENED_RUNTIME_OPTIONS
        com.apple.security.device.audio-input
        com.apple.security.cs.allow-unsigned-executable-memory
)

target_sources(MyPlugin PRIVATE
    Source/PluginProcessor.cpp
    Source/PluginEditor.cpp
)

target_link_libraries(MyPlugin PRIVATE
    juce::juce_audio_utils
    juce::juce_dsp
    juce::juce_audio_plugin_client
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags
)
```

Build:

```bash
# Windows (PowerShell)
mkdir build; cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release

# macOS (Terminal)
mkdir build && cd build
cmake .. -G Xcode
cmake --build . --config Release
```

## Różnice formatów per platforma

| Format | Windows | macOS | Pliki |
|--------|---------|-------|-------|
| **VST3** | TAK | TAK | Win: `.vst3` (folder lub pojedynczy plik), Mac: `.vst3` bundle (folder) |
| **AU** | NIE | TAK | `.component` bundle |
| **AAX** | TAK | TAK | `.aaxplugin` bundle |
| **CLAP** | TAK | TAK | `.clap` |
| **Standalone** | `.exe` | `.app` | Aplikacja |

### Foldery instalacji

**Windows:**
```
VST3:  C:\Program Files\Common Files\VST3
AAX:   C:\Program Files\Common Files\Avid\Audio\Plug-Ins
```

**macOS:**
```
VST3:  /Library/Audio/Plug-Ins/VST3              (system-wide)
       ~/Library/Audio/Plug-Ins/VST3              (user-only)
AU:    /Library/Audio/Plug-Ins/Components
       ~/Library/Audio/Plug-Ins/Components
AAX:   /Library/Application Support/Avid/Audio/Plug-Ins
```

JUCE `COPY_PLUGIN_AFTER_BUILD TRUE` automatycznie kopiuje do user-folder.

## Code signing — Windows

### Dlaczego trzeba podpisywać

- **SmartScreen warning** — niesigned EXE/DLL pokazuje "Windows protected your PC" alert. 70% userów porzuca instalację.
- **Antywirusy** — niesigned binaries flagują się jako podejrzane (false positives)
- **Korporacyjne środowiska** — często blokują niesigned software przez Group Policy

### Co kupić

W 2026 Microsoft wymaga **EV Code Signing Certificate** dla pełnego SmartScreen reputation:

| Provider | Cena/rok | Plus |
|----------|----------|------|
| **Sectigo (dawniej Comodo)** | ~$400-500 | Najbardziej popularne, dobry support |
| **DigiCert** | ~$700-1000 | Premium, enterprise-grade |
| **SSL.com** | ~$300-450 | Tańsze |
| **Certum (PL)** | ~1500-2000 zł | Polski wystawca |

**Uwaga:** od czerwca 2023 EV certs są dostarczane jako **HSM token** (USB) albo **cloud HSM** (np. SSL.com eSigner) — nie da się tylko exportować do `.pfx`.

### Komenda signtool

```powershell
# signtool jest w Windows SDK
& "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe" sign `
    /tr http://timestamp.sectigo.com `
    /td sha256 `
    /fd sha256 `
    /a `
    "C:\Program Files\Common Files\VST3\My Plugin.vst3\Contents\x86_64-win\My Plugin.vst3"

# Verify
signtool verify /pa /v "My Plugin.vst3"
```

Flagi:
- `/tr` — timestamp server (zapobiega wygaśnięciu po expirze cert)
- `/td sha256` — timestamp digest
- `/fd sha256` — file digest
- `/a` — auto-select najlepszy cert z magazynu

## Code signing + notarization — macOS

### Apple Developer Account

Wymagany **$99/rok** Apple Developer Program (`developer.apple.com`).

Po włączeniu: w **Keychain Access** instalujesz dwa certyfikaty:
- **Developer ID Application** — do podpisywania `.app`/`.vst3`/`.component`
- **Developer ID Installer** — do podpisywania `.pkg` (instalatorów)

### codesign — komendy

```bash
# 1. Podpisz wszystkie binaria w bundle (deep)
codesign --force --options runtime --timestamp \
    --sign "Developer ID Application: Your Name (TEAM_ID)" \
    --deep \
    "/Library/Audio/Plug-Ins/VST3/My Plugin.vst3"

codesign --force --options runtime --timestamp \
    --sign "Developer ID Application: Your Name (TEAM_ID)" \
    --deep \
    "/Library/Audio/Plug-Ins/Components/My Plugin.component"

# 2. Verify
codesign --verify --deep --verbose=2 "My Plugin.vst3"
spctl --assess --verbose "My Plugin.vst3"
```

`--options runtime` = enables hardened runtime (wymagany przez notarization).

### Notarization — co i dlaczego

**Notarization** = Apple skanuje binarkę pod kątem malware i wystawia "ticket" potwierdzający bezpieczeństwo. Bez notarization plugin pokazuje **"Cannot be opened because the developer cannot be verified"** na nowych macOS (od 10.15 Catalina).

**Workflow:**
1. Spakuj plugin do `.zip` (notarytool wymaga archiwum)
2. Wyślij do Apple
3. Apple skanuje (~1-15 min)
4. Pobierz ticket i staple do bundle
5. Verify

```bash
# 1. Zarchiwizuj
ditto -c -k --keepParent "My Plugin.vst3" "MyPlugin.zip"

# 2. Wyślij do notarization (notarytool — nowy, od Xcode 13+)
xcrun notarytool submit "MyPlugin.zip" \
    --apple-id "your@email.com" \
    --team-id "TEAM_ID" \
    --password "app-specific-password" \
    --wait

# 3. Po success — staple ticket do bundle (offline verification)
xcrun stapler staple "My Plugin.vst3"

# 4. Verify
xcrun stapler validate "My Plugin.vst3"
spctl --assess --type install --verbose "My Plugin.vst3"
```

**App-specific password:** wygeneruj na `appleid.apple.com` → Security → App-Specific Passwords. Nie używaj głównego hasła Apple ID.

### Hardened Runtime entitlements

Plugin często wymaga uprawnień (mic input, audio device access). Podaj w `entitlements.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.device.audio-input</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
</dict>
</plist>
```

Stosujesz przy podpisywaniu: `codesign --entitlements entitlements.plist ...`

## GitHub Actions — automatyczny cross-platform build

Najczęstszy setup w 2026 — push do main → automatyczny build na Win + Mac → artefakty downloadowe.

```yaml
# .github/workflows/build.yml
name: Build Plugin

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
    branches: [main]

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        os: [windows-latest, macos-latest]

    runs-on: ${{ matrix.os }}

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive    # JUCE jako submodule

      - name: Configure CMake
        run: cmake -B build -DCMAKE_BUILD_TYPE=Release

      - name: Build
        run: cmake --build build --config Release --parallel

      # macOS: codesign + notarize (tylko na tagach release)
      - name: Codesign macOS
        if: matrix.os == 'macos-latest' && startsWith(github.ref, 'refs/tags/')
        env:
          DEVELOPER_ID: ${{ secrets.MACOS_DEVELOPER_ID }}
          NOTARY_USER: ${{ secrets.NOTARY_USER }}
          NOTARY_PASSWORD: ${{ secrets.NOTARY_PASSWORD }}
          NOTARY_TEAM: ${{ secrets.NOTARY_TEAM }}
        run: |
          codesign --force --options runtime --timestamp \
            --sign "$DEVELOPER_ID" --deep \
            "build/MyPlugin_artefacts/Release/VST3/My Plugin.vst3"
          
          ditto -c -k --keepParent \
            "build/MyPlugin_artefacts/Release/VST3/My Plugin.vst3" \
            "MyPlugin-mac.zip"
          
          xcrun notarytool submit MyPlugin-mac.zip \
            --apple-id "$NOTARY_USER" \
            --password "$NOTARY_PASSWORD" \
            --team-id "$NOTARY_TEAM" \
            --wait
          
          xcrun stapler staple "build/MyPlugin_artefacts/Release/VST3/My Plugin.vst3"

      # Windows: codesign (jeśli mamy cert)
      - name: Codesign Windows
        if: matrix.os == 'windows-latest' && startsWith(github.ref, 'refs/tags/')
        env:
          CERT_PATH: ${{ secrets.WIN_CERT_PATH }}
          CERT_PASSWORD: ${{ secrets.WIN_CERT_PASSWORD }}
        run: |
          signtool sign /tr http://timestamp.sectigo.com /td sha256 /fd sha256 `
            /f $env:CERT_PATH /p $env:CERT_PASSWORD `
            "build/MyPlugin_artefacts/Release/VST3/My Plugin.vst3"

      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: MyPlugin-${{ matrix.os }}
          path: build/MyPlugin_artefacts/Release/
```

### Sekrety GitHub do dodania (Settings → Secrets):

- `MACOS_DEVELOPER_ID` — np. `Developer ID Application: Twoja Firma (TEAMID)`
- `NOTARY_USER` — Twój Apple ID email
- `NOTARY_PASSWORD` — app-specific password
- `NOTARY_TEAM` — 10-znakowy Team ID
- `WIN_CERT_PATH` — ścieżka do `.pfx` (jeśli software cert)
- `WIN_CERT_PASSWORD` — hasło do `.pfx`

## Testowanie cross-platform

| Platforma | DAW priorytet 1 | DAW priorytet 2 | Test scenarios |
|-----------|-----------------|-----------------|----------------|
| **Windows** | Reaper, FL Studio | Ableton Live, Cubase | scan time, parameter automation, undo/redo, save/load project |
| **macOS** | Logic Pro (AU!), Reaper | Ableton Live, Pro Tools (AAX) | M1 + Intel Mac, scan, automation, AU validation tool |

**AU validation:** zawsze sprawdź `auval -v aufx Mpln Mcmp` na macOS — Logic Pro nie załaduje pluginu który nie przechodzi auval.

## Częste problemy cross-platform

<div class="card">

### Path separators

Windows: `\` (backslash). macOS: `/` (forward slash). Używaj `juce::File::getSeparatorString()` zamiast hardcoded.

```cpp
auto file = juce::File::getSpecialLocation(juce::File::userDocumentsDirectory)
              .getChildFile("MyPlugin")
              .getChildFile("preset.xml");
// JUCE samo zarządzi separatorami
```

</div>

<div class="card">

### Line endings

Windows: CRLF (`\r\n`). macOS/Linux: LF (`\n`). W repo używaj `.gitattributes`:

```
* text=auto
*.cpp text eol=lf
*.h text eol=lf
*.cmake text eol=lf
CMakeLists.txt text eol=lf
*.bat text eol=crlf
*.cmd text eol=crlf
```

</div>

<div class="card">

### Bundle vs file

Windows VST3 może być pojedynczym plikiem `.vst3` LUB folderem `.vst3/Contents/x86_64-win/file.vst3`. macOS ZAWSZE bundle (folder). JUCE używa formatu **bundle** na obu — bezpieczniej.

</div>

<div class="card">

### Apple Silicon native vs Rosetta

Plugin x86_64 zadziała na M1/M2 przez Rosetta 2 — ALE wolniej (5-10x w pewnych operacjach DSP). Universal binary jest **must** dla 2026.

DAW też matters: jeśli host jest x86_64 (np. starszy Logic), załaduje TYLKO x86_64 partition Twojego pluginu. Jeśli host jest arm64 — załaduje arm64 partition.

</div>

<div class="card">

### macOS sandboxing — security policies

Niektóre DAW (Logic Pro, GarageBand) ładują pluginy w sandboxed processes (`AUv3`). Tradycyjny VST3/AU NIE jest sandboxed, ale i tak musisz mieć hardened runtime + entitlements jeśli plugin używa kamery/mic/network.

</div>

<div class="card">

### Wolny startup pluginu na macOS Gatekeeper

Pierwszy raz załadowany plugin na nowym Macu = Gatekeeper sprawdza notarization online. Może zająć **30-60 sekund** za pierwszym razem. Stąd `xcrun stapler staple` — załącza ticket lokalnie i nie trzeba pytać Apple online.

</div>

## Distribution per platforma

### Windows

- **Inno Setup** (darmowy) — najpopularniejszy installer creator
- **NSIS** (open source) — alternatywa
- **WiX** (do enterprise, MSI)
- Plugin trafia do `C:\Program Files\Common Files\VST3`

### macOS

- **Packages.app** (darmowy, package builder) — preferowany
- **PackageMaker** (legacy)
- Plugin trafia do `/Library/Audio/Plug-Ins/VST3` i `/Library/Audio/Plug-Ins/Components`
- `.pkg` musi być **podpisany Developer ID Installer** + **notarized**

### Cross-platform alternative

Niektórzy używają jednego customowego launchera (Electron app, Qt installer) który downloaduje właściwą wersję per-OS. Overkill dla małych pluginów.

## Co dalej

Mając cross-platform build setup + signing pipeline, możesz spokojnie pracować nad GUI (rozdział 7) i zaawansowanym DSP (rozdział 8). Każdy commit do main daje gotowe binarki dla obu platform via GitHub Actions.

**Checklist gotowości do release:**
- [ ] Build na Win + Mac przechodzi w CI
- [ ] Universal binary dla macOS (arm64 + x86_64) — verified `lipo -info`
- [ ] Code signed na Windows (timestamp server!)
- [ ] Code signed + notarized + stapled na macOS
- [ ] AU passes `auval -v` na macOS
- [ ] Tested w min. 3 DAW per platforma
- [ ] Installer dla Windows (Inno) i macOS (.pkg, signed + notarized)
