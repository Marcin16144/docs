# Narzędzia programistyczne dla VST plugin development

## Przegląd toolchain

Tworzenie wtyczki VST/AU/AAX wymaga koordynacji wielu narzędzi: IDE, SDK, system buildów, debugger, host testowy, validator, system kontroli wersji, CI/CD. W tym rozdziale przejdziemy przez kompletny zestaw, którego potrzebuje plugin developer w 2026.

```
┌────────────────────────────────────────────────────┐
│                  Toolchain VST 2026                 │
├────────────────────────────────────────────────────┤
│  Edytor / IDE   →  Visual Studio / Xcode / CLion   │
│  SDK            →  VST3 SDK + AU SDK + (AAX SDK)   │
│  Framework      →  JUCE 8.x (lub iPlug2)           │
│  Build system   →  CMake 3.22+                     │
│  Debugger       →  VS / LLDB / Reaper-as-host       │
│  Validator      →  pluginval, AU validator         │
│  Host testowy   →  Reaper, Ableton, Logic, ProTools│
│  Source control →  Git + Git LFS (samples)         │
│  CI/CD          →  GitHub Actions (matrix builds)  │
└────────────────────────────────────────────────────┘
```

## IDE — wybór środowiska

### Visual Studio 2022 / 2025 (Windows)

**Najlepszy wybór dla Windows.** Edycja **Community** (free dla solo dev / firm < $1M revenue) ma wszystko, czego potrzeba.

**Komponenty do zainstalowania:**
- Workload **Desktop development with C++**
- **Windows 11 SDK** (najnowszy)
- **C++ CMake tools for Windows**
- **Git for Windows** (jeśli nie ma)
- **C++ Clang Compiler for Windows** (opcjonalnie — second-pass walidacja)

**Dlaczego VS:**
- Najlepszy debugger dla C++ na Windows (przeglądanie pamięci, watch, conditional breakpoints)
- IntelliSense bardzo dojrzały
- CMake support natywny od 2017+
- Hot Reload dla C++ (od VS 2022 17.5)
- Profilery: CPU usage, memory, concurrency

```
File → Open → CMake...
Wybierz CMakeLists.txt
VS automatycznie skonfiguruje CMake i pozwoli buildować F7 / F5
```

### Xcode (macOS)

**Wymagany dla macOS** — Apple toolchain dla AU validation, code signing i notarization.

**Instalacja:**
```bash
# App Store: Xcode (najnowszy stable)
# LUB Apple Developer: developer.apple.com/xcode
xcode-select --install   # command-line tools
```

**Wersja w 2026:** Xcode 16.x (z Swift 6, ale dla VST używamy C++/Obj-C++).

**Co Xcode daje:**
- Apple AU SDK wbudowany w macOS SDK
- LLDB debugger
- Instruments (profilowanie pamięci, CPU, Time Profiler dla audio)
- Built-in Code Signing UI
- Notarization tooling (`xcrun notarytool`)
- AU Lab i AU validator (`auval`)

### CLion (cross-platform)

**JetBrains CLion** — świetny wybór gdy pracujesz na **obu platformach** (Win + Mac) i chcesz spójny IDE.

**Cena 2026:**
- Indywidualnie: **$229/yr** lub **$22.90/mc**
- Firma: **$549/yr** per user
- Educational: **free**
- Subskrypcja taniejąca po 2-3 latach (loyalty discount)

**Plusy:**
- CMake first-class support (zdecydowanie lepszy niż VS)
- Refactoringi automatyczne (rename, extract, move)
- Spójność UI Win ↔ Mac ↔ Linux
- Remote development (build na zdalnej Mac z Windows host)
- Integrated Valgrind, Google Test, sanitizers

**Minusy:**
- Wolniejszy niż natywne IDE
- Płatny
- Mniej zoptymalizowany dla AU/Xcode-specific tasks

### VS Code

Lekka alternatywa, popularna wśród minimalists. Wymaga setup:
```
Extensions:
- C/C++ (Microsoft)
- CMake Tools (Microsoft)
- clangd (LLVM) — alternatywa dla cpptools
- CodeLLDB lub GDB debugger
- GitLens
```

Dobry dla quick edits, debugging-friendly z extensionami, ale dla heavy plugin dev VS / Xcode / CLion wygodniejsze.

## VST3 SDK (Steinberg)

### Pobranie

```bash
git clone https://github.com/steinbergmedia/vst3sdk.git
cd vst3sdk
git submodule update --init --recursive
```

**Wersja w 2026:** VST3 SDK 3.7.x (3.8 zapowiedziane).

**Struktura katalogów:**
```
vst3sdk/
├── base/              # Core helpers (FUID, atomics, IO)
├── pluginterfaces/    # VST3 API interfaces (.h)
├── public.sdk/        # Helper classes
├── vstgui4/           # VSTGUI framework (alternatywa do JUCE GUI)
├── doc/               # Documentation
└── samples/           # Sample plugins (studiuj!)
```

### VST3 Validator

Po zbudowaniu pluginu **zawsze** waliduj go:

```bash
# Linux/macOS
./validator MyPlugin.vst3

# Windows
validator.exe MyPlugin.vst3
```

Validator sprawdza:
- Czy plugin loaduje się
- Czy parametry są poprawnie zarejestrowane
- Czy stan zapisuje/odczytuje się
- Czy `processBlock` nie alokuje (sprawdzane przez instrumentację)
- Edge cases: zero buffer, single sample, channel switches

**Validator MUST PASS** zanim wypuścisz wtyczkę — w przeciwnym razie część DAW odrzuci.

### License VST3 SDK

Dual licence (od 2018):
- **GPLv3** — open source friendly
- **Steinberg License** — komercyjna (wymaga atrybucji w plugin info)

W 2026 większość commercial plugins używa Steinberg License.

## Apple AU SDK

**Audio Unit SDK** jest wbudowany w macOS przez Xcode — nie pobierasz osobnego pakietu.

```objc
// Headers (Objective-C / C++)
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudioKit/CoreAudioKit.h>     // dla AUv3 GUI
#import <AVFoundation/AVFoundation.h>
```

### AU Validator (auval)

Wbudowany w macOS — sprawdza poprawność AU bundle:

```bash
# Lista zainstalowanych AU
auval -a

# Walidacja konkretnego pluginu
# format: aufx (effect) lub aumu (musical generator) + manufacturer + plugin code
auval -v aufx Mcmp Plug

# Verbose
auval -V aufx Mcmp Plug
```

**Logic Pro nie załaduje AU, który nie przeszedł `auval -v`.**

### AUv2 vs AUv3

W 2026:
- **AUv2** (legacy) — Component bundle, wszystkie hosty
- **AUv3** (modern) — Extension-based, sandboxed, wymagany dla App Store, iOS, mac App

JUCE generuje oba automatycznie. Dla nowych pluginów w 2026 rób **AUv3** (lepiej wspierane, sandbox-ready).

## AAX SDK (Avid)

**AAX** jest gated — musisz zarejestrować się jako Avid Developer.

### Rejestracja

1. Wejdź na **developer.avid.com**
2. Aplikacja Avid Developer Program: **$295/year minimum**
3. NDA + zatwierdzenie (kilka dni)
4. Otrzymujesz dostęp do AAX SDK download

### Wymagania techniczne AAX

- **PACE/iLok integration** — anti-piracy obowiązkowe
- **PACE Eden** code signing tool (do każdego buildu)
- iLok USB key lub iLok Cloud do testowania
- Code signing certyfikat + Apple Developer (na macOS)

### Kiedy warto?

- Targetujesz **Pro Tools** (studyjne workflow)
- Plugin ma profesjonalny use case (mixing, mastering)
- Akceptujesz $295/yr + iLok overhead

Dla indie / hobbysty zacznij od **VST3 + AU**, dodaj AAX dopiero gdy klienci o to proszą.

## JUCE — Projucer vs CMake

### Projucer (legacy)

GUI tool do generowania projektów IDE:
```
JUCE/Projucer.exe → New project → Audio Plug-In →
genujesz Visual Studio solution / Xcode project
```

**Plusy:**
- GUI, klikany setup
- Auto-managed module dependencies
- Eksportery dla VS, Xcode, Make, CodeBlocks

**Minusy:**
- Trudniejsze do automatyzacji (CI/CD)
- Manualnie trzeba "Save and Open in IDE" po każdej zmianie
- Mniej elastyczny niż CMake

### CMake (preferowany w 2026)

**JUCE od wersji 6 ma natywne wsparcie CMake** — to jest droga w 2026.

**Plusy:**
- Standardowy build system C++ ekosystemu
- Łatwa automatyzacja (CI, Docker)
- Cross-platform z jednym plikiem `CMakeLists.txt`
- Integracja z Conan, vcpkg dla dependencies
- IDE-agnostic (każdy IDE rozumie CMake)

## Pełny CMakeLists.txt — przykład

```cmake
cmake_minimum_required(VERSION 3.22)
project(MyAwesomePlugin VERSION 1.0.0)

# C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# macOS — Universal Binary (Intel + Apple Silicon)
if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "" FORCE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.13" CACHE STRING "" FORCE)
endif()

# Windows — statyczna runtime (mniej zewnętrznych zależności)
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    add_compile_options(/MP /W4)
endif()

# JUCE jako submoduł
add_subdirectory(external/JUCE)

# Plugin
juce_add_plugin(MyAwesomePlugin
    VERSION 1.0.0
    COMPANY_NAME "AcmePlugins"
    COMPANY_WEBSITE "https://example.com"
    COMPANY_EMAIL "support@example.com"
    PLUGIN_MANUFACTURER_CODE "Acme"
    PLUGIN_CODE "Awsm"
    FORMATS VST3 AU Standalone
    PRODUCT_NAME "Awesome Plugin"
    BUNDLE_ID "com.acme.awesomeplugin"
    IS_SYNTH FALSE
    NEEDS_MIDI_INPUT FALSE
    NEEDS_MIDI_OUTPUT FALSE
    IS_MIDI_EFFECT FALSE
    EDITOR_WANTS_KEYBOARD_FOCUS FALSE
    COPY_PLUGIN_AFTER_BUILD TRUE     # automatycznie kopiuj do user plugins folder
)

target_sources(MyAwesomePlugin PRIVATE
    Source/PluginProcessor.cpp
    Source/PluginProcessor.h
    Source/PluginEditor.cpp
    Source/PluginEditor.h
    Source/Dsp/Filter.cpp
    Source/Dsp/Filter.h
)

target_compile_definitions(MyAwesomePlugin PRIVATE
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    JUCE_VST3_CAN_REPLACE_VST2=0
)

target_link_libraries(MyAwesomePlugin PRIVATE
    juce::juce_audio_utils
    juce::juce_dsp
    juce::juce_audio_plugin_client
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags
)
```

**Build commands:**
```bash
# Windows
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release

# macOS Universal
cmake -B build -G "Xcode"
cmake --build build --config Release

# Linux
cmake -B build -G "Ninja"
cmake --build build --config Release
```

## Debugowanie pluginów

### Visual Studio Debugger (Windows)

Najlepszy debugger dla Windows. Skonfiguruj plugin do uruchamiania w hoście testowym:

```
Project Properties → Debugging:
  Command: C:\Program Files\REAPER (x64)\reaper.exe
  Command Arguments: (puste lub ścieżka projektu)
  Working Directory: C:\ProgramData\REAPER\
```

F5 — Reaper startuje, ładuje plugin, breakpointy działają.

**Warto włączyć:**
- **Address Sanitizer** (od VS 2022): wykrywa use-after-free, buffer overflows
- **C++ Concurrency Visualizer** dla threading bugs

### LLDB (macOS)

LLDB jest debuggerem standardowym dla Xcode. Aby debugować plugin w Logic / Reaper:

```bash
# Załączenie do działającego procesu
lldb -p $(pgrep Logic)

# Lub w Xcode:
Debug → Attach to Process → Logic Pro
```

**Tip:** stwórz Xcode scheme **AU validation** uruchamiające `auval -v aufx Acme Awsm` i debuguj walidację.

### Reaper jako host dla debugowania

**Reaper** jest **najlepszym hostem deweloperskim**:
- Tani ($60 dożywotnio)
- Szybki start (sekundy vs Logic-y minuty)
- Restartuje skanowanie pluginów łatwo
- Dostępny crash reporter
- Cross-platform (Win, Mac, Linux)
- Skryptowanie ReaScript do automatyzacji testów

```
Settings → Plug-ins → VST → Re-scan
Plugin path: D:\Builds\MyPlugin_artefacts\Release\VST3
```

### GDB (Linux)

```bash
gdb --args reaper /path/to/test-project.rpp
(gdb) break MyPlugin::processBlock
(gdb) run
```

### Sanitizers

Niezbędne do wykrywania niewidocznych bugów:

```cmake
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    if(NOT MSVC)
        add_compile_options(-fsanitize=address -fsanitize=undefined)
        add_link_options(-fsanitize=address -fsanitize=undefined)
    endif()
endif()
```

**ASan (AddressSanitizer)** — wycieki, use-after-free, buffer overrun.
**UBSan (UndefinedBehaviorSanitizer)** — overflow integer, niewłaściwe casty.
**TSan (ThreadSanitizer)** — race conditions (incompatible with ASan, użyj osobno).

## Validatory pluginów

### pluginval

**Najlepszy uniwersalny validator** dla VST3 + AU. Autorstwa Tracktion (twórcy Waveform DAW).

```bash
git clone https://github.com/Tracktion/pluginval.git
cd pluginval
cmake -B build -G "Visual Studio 17 2022"
cmake --build build --config Release
```

**Użycie:**
```bash
pluginval --strictness-level 10 --validate MyPlugin.vst3
```

Strictness levels 1-10. **10 = paranoid** (rozmaite edge cases, nieprawdopodobne stany). Dobry plugin powinien przejść level 10.

### AU Validator (auval)

```bash
auval -v aufx Acme Awsm   # Type: aufx (effect), Manufacturer: Acme, Code: Awsm
```

Wbudowany w macOS, **MUST PASS** dla Logic.

### VST3 Validator

W VST3 SDK:
```bash
validator MyPlugin.vst3
```

### AAX Validator

W AAX SDK (po rejestracji jako Avid Developer):
```
DigiShell.exe (Pro Tools developer tool) — auto-validates podczas Pro Tools loading
```

### Strategia walidacji

```
Build → pluginval level 5 → pluginval level 10 → auval (Mac) →
   → load w Reaper → load w Live → load w Logic / Cubase → user beta
```

CI powinno minimum łapać `pluginval level 5` automatycznie po każdym pushu.

## DAW do testowania

### Reaper — top wybór dla developerów

| Cecha | Reaper |
|-------|--------|
| Cena | **$60** (rozsądna licencja indywidualna) |
| Platformy | Win, macOS, Linux |
| Start time | ~1 sekunda |
| Plugin formaty | VST2/3, AU (Mac), CLAP, LV2 |
| API | ReaScript (Lua, Python, EEL2) |
| Crash recovery | Wyśmienity |

**Reaper jest dla VST devs tym, czym Vim dla devops** — szybki, hackowalny, oszczędny.

### Ableton Live

- **$99 (Intro) — $749 (Suite)** w 2026
- Świetny do testowania w kontekście produkcyjnym (electronic, beat making)
- Wymagający dla pluginów (sandbox, automation testing)
- VST2/3, AU (Mac)

### Logic Pro

- **$199** (one-time payment, Mac only)
- **MUST TEST** dla plugin sprzedawanego dla profesjonalistów Mac
- AU only (no VST3 support)
- Bardzo restrykcyjne walidowanie AU
- Free Logic alternatywa: **GarageBand**

### Pro Tools

- **$30/mc — $299/yr** subscription (lub perpetual $599)
- AAX only
- **Konieczność testowania jeśli sprzedajesz AAX**
- Test session: utwórz session, dodaj plugin, automate parametrów, save/load session

### FL Studio, Cubase, Bitwig, Studio One

Każdy ma quirks. **Top 5 do testowania w 2026:**
1. Reaper (dev workhorse)
2. Logic Pro (Mac standard)
3. Ableton Live (electronic standard)
4. Pro Tools (jeśli AAX)
5. Cubase (Steinberg, native VST3 host)

## Source control: Git + Git LFS

### Setup repo

```bash
git init
git add CMakeLists.txt Source/ external/JUCE
git commit -m "Initial plugin scaffold"
```

### .gitignore dla VST projektu

```gitignore
# Build output
build/
out/
cmake-build-*/
.vs/
.vscode/
*.vcxproj.user

# Xcode
*.xcodeproj/
DerivedData/
*.dSYM/

# JUCE intermediate
JuceLibraryCode/
*Generated*

# Plugins built
*.vst3
*.component
*.aaxplugin

# OS junk
.DS_Store
Thumbs.db

# Secrets
secrets/
*.pem
*.p12
*.cer
codesign_keys/
```

### Git LFS dla samples

Pluginy z sampli (drum samplers, IRs do convolution reverbs) — sample to **gigabajty binarnych danych**. Git LFS:

```bash
git lfs install
git lfs track "*.wav"
git lfs track "*.aif"
git lfs track "*.flac"
git lfs track "Resources/Samples/**"
git add .gitattributes
git commit -m "Configure Git LFS for samples"
```

LFS storage:
- GitHub: 1 GB free + $5/mc za 50 GB
- GitLab: 10 GB free
- Azure DevOps: 250 GB free

### Git branching strategy

```
main (production releases, tagged: v1.0.0, v1.1.0)
  ├── develop (integration)
  │     ├── feature/lookahead-limiter
  │     ├── feature/ui-redesign
  │     └── feature/clap-support
  └── hotfix/v1.0.1-crash-fix
```

Tag releases: `v1.0.0` — CI/CD automatycznie buduje i publikuje binaria.

## CI/CD — GitHub Actions

### Cross-platform build matrix

```yaml
name: Build Plugin

on:
  push:
    branches: [main, develop]
    tags: ['v*']
  pull_request:
    branches: [main, develop]

jobs:
  build:
    name: Build ${{ matrix.os }}
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [windows-2022, macos-14, ubuntu-22.04]

    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          submodules: recursive
          lfs: true

      - name: Install Linux deps
        if: runner.os == 'Linux'
        run: |
          sudo apt-get update
          sudo apt-get install -y libasound2-dev libjack-jackd2-dev \
            libcurl4-openssl-dev libfreetype6-dev libx11-dev libxcomposite-dev \
            libxcursor-dev libxext-dev libxinerama-dev libxrandr-dev \
            libxrender-dev libwebkit2gtk-4.0-dev libglu1-mesa-dev

      - name: Configure CMake (Windows)
        if: runner.os == 'Windows'
        run: cmake -B build -G "Visual Studio 17 2022" -A x64

      - name: Configure CMake (macOS)
        if: runner.os == 'macOS'
        run: cmake -B build -G "Xcode" -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64"

      - name: Configure CMake (Linux)
        if: runner.os == 'Linux'
        run: cmake -B build -G "Ninja" -DCMAKE_BUILD_TYPE=Release

      - name: Build
        run: cmake --build build --config Release --parallel

      - name: Run pluginval
        run: |
          # download pluginval (cached jest dobry pomysł)
          # uruchom w trybie strict
          ./pluginval --strictness-level 5 --validate-in-process \
            build/MyAwesomePlugin_artefacts/Release/VST3/MyAwesomePlugin.vst3

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: plugin-${{ matrix.os }}
          path: build/MyAwesomePlugin_artefacts/Release/

  release:
    name: Release
    needs: build
    if: startsWith(github.ref, 'refs/tags/v')
    runs-on: ubuntu-latest
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            plugin-windows-2022/**
            plugin-macos-14/**
            plugin-ubuntu-22.04/**
```

### Code signing w CI

**macOS:**
- Zapisz `Developer ID Application` certyfikat jako secret (`MACOS_CERT_P12_BASE64`)
- Zapisz hasło certyfikatu (`MACOS_CERT_PASSWORD`)
- Zapisz Apple ID + team ID + app-specific password do notarization
- Skrypt importuje cert do tymczasowego keychain, podpisuje, notarizes, staples

**Windows:**
- Hardware token cert nie da się trzymać w chmurze (od 2023)
- Workaround: cloud signing usługi (DigiCert KeyLocker, Azure Key Vault)
- Lub: dedicated self-hosted runner w sieci, gdzie hardware token jest podłączony

## Profilowanie wydajności

### Windows: Visual Studio Profiler

```
Debug → Performance Profiler → CPU Usage
Run with profiler attached, generate audio in Reaper, stop profiler
```

### macOS: Instruments

```
Xcode → Open Developer Tool → Instruments
Time Profiler template → Attach to Logic / Reaper
```

Sprawdź:
- Hot spots w `processBlock`
- Memory allocations w audio thread (powinno być **zero**)
- Cache misses (Instruments **Counters** template)

### Audio-specific:

- **Reaper VU + plugin CPU meter** — szybkie szacunki
- **Plugin Doctor** (Auburn Sounds, $30) — automatyzowane testy DSP (impulse response, latencja, denormals)

## Lista narzędzi — checklist instalacji

### Windows dev box

- [ ] Visual Studio 2022 / 2025 Community + Desktop C++ workload
- [ ] Git for Windows (z Git LFS)
- [ ] CMake 3.27+ (lub przez VS)
- [ ] JUCE (clone do `C:\dev\JUCE`)
- [ ] VST3 SDK (clone do `C:\dev\vst3sdk`)
- [ ] Reaper x64 (test host)
- [ ] Ableton Live trial (sekundarny test host)
- [ ] pluginval (clone + build)
- [ ] Process Monitor (Sysinternals) — debugging plugin loading

### macOS dev box

- [ ] Xcode (latest stable)
- [ ] Command Line Tools (`xcode-select --install`)
- [ ] Homebrew (`brew install cmake git git-lfs`)
- [ ] JUCE clone
- [ ] VST3 SDK clone
- [ ] Reaper for Mac (test host)
- [ ] Logic Pro (test host, jeśli sprzedajesz Mac plugin)
- [ ] AU Lab (free, AU testing)
- [ ] Apple Developer Account ($99/yr, dla code sign + notarization)

## Podsumowanie

**Stack 2026 dla nowego projektu:**

| Warstwa | Wybór |
|---------|-------|
| IDE Win | Visual Studio 2022/2025 Community |
| IDE Mac | Xcode 16 |
| IDE cross | CLion (gdy budżet pozwala) |
| Framework | JUCE 8 |
| Build | CMake 3.22+ |
| Source | Git + GitHub + Git LFS |
| CI | GitHub Actions matrix |
| Validator | pluginval level 10 + auval |
| Test DAW | Reaper (zawsze), Logic + Live + Pro Tools (target-specific) |
| Code sign | Apple Developer + Sectigo EV |

**Złota zasada:** w pierwszym tygodniu projektu skonfiguruj **CI z cross-platform buildem i pluginvalem** — odkryjesz 80% problemów zanim pojawią się u userów.

## Co dalej?

- **Rozdział 04** — DSP podstawy (filtry, oscylatory, real-time math)
- **Rozdział 05** — Tworzenie pierwszej wtyczki (Hello World w JUCE)
- **Rozdział 06** — Cross-platform: build, signing, notarization
