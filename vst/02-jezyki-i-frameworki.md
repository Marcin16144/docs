# Języki i frameworki dla VST plugin development

## Wybór języka — zwycięzca: C++

```
Popularność (2026):
C++         ━━━━━━━━━━━━━━━━━━━━ 90%
Rust        ━━━━ 5%
D           ━ 2% (DPlug)
Swift       ━ 2% (only macOS native)
Faust       ━ 1% (DSL)
RNBO/JS     ━ <1% (Cycling '74)
```

**Dlaczego C++ dominuje:**
- Wszystkie SDK (VST3, AU, AAX) są C++ first
- Najlepsze frameworki (JUCE, iPlug2) są C++
- DSP libraries (intel IPP, Apple vDSP) są C/C++
- Real-time performance (kontrola alokacji, brak GC)
- Cross-platform (Windows, macOS, Linux, iOS, embedded)
- Dojrzały ekosystem audio od 30+ lat

**Wymagana wersja:** **C++17 minimum**, **C++20** preferowane (concepts, ranges), **C++23** zaczyna się pojawiać w 2026.

## Frameworki audio — porównanie

### JUCE ⭐ (zwycięzca)

**JUCE** (Roli/Raw Material) — **#1 wybór** w 2026, ~80% komercyjnych plugins.

**Plusy:**
- Cross-platform (Win, macOS, Linux, iOS, Android, web via Emscripten)
- Wsparcie wszystkich formatów: VST3, AU, AAX, AUv3, LV2, CLAP (od JUCE 8)
- Sprawdzony przez setki komercyjnych plugins
- Bogata dokumentacja, tutoriale, community
- Built-in GUI framework (potężny)
- Audio + MIDI + DSP utilities w jednym pakiecie
- DSP module z gotowymi filtrami, oscylatorami
- Projucer (project manager) lub CMake support

**Licencja (2026):**
- **Personal/Education**: Free (revenue limit < $50k/year)
- **Indie**: $35/month — projects do określonego revenue
- **Pro**: $130/month — bez limitu
- **Education**: Free (akredytowane uczelnie)

**Kluczowe klasy:**
```cpp
juce::AudioProcessor       // Core plugin class
juce::AudioProcessorEditor  // GUI window
juce::AudioParameterFloat  // Parametry
juce::AudioBuffer<float>   // Audio data
juce::MidiBuffer            // MIDI events
juce::dsp::*               // DSP utilities (IIR, FFT, oscillators)
juce::Component             // GUI building blocks
juce::Slider, juce::Button  // GUI controls
juce::OpenGLContext        // GPU acceleration
```

**Hello World JUCE plugin:**
```cpp
class MyGainPlugin : public juce::AudioProcessor {
    juce::AudioParameterFloat* gain;
public:
    MyGainPlugin() {
        addParameter(gain = new juce::AudioParameterFloat(
            "gain", "Gain", 0.0f, 1.0f, 0.5f));
    }

    void prepareToPlay(double sampleRate, int samplesPerBlock) override {}
    void releaseResources() override {}

    void processBlock(juce::AudioBuffer<float>& buffer,
                      juce::MidiBuffer& midi) override {
        const float currentGain = gain->get();
        for (int ch = 0; ch < buffer.getNumChannels(); ++ch) {
            buffer.applyGain(ch, 0, buffer.getNumSamples(), currentGain);
        }
    }

    // ...boilerplate (getName, hasEditor, etc.)
};
```

### iPlug2 ⭐ (silny konkurent)

**iPlug2** (Oli Larkin et al.) — **darmowy**, open source, alternatywa JUCE.

**Plusy:**
- W pełni darmowy (MIT license)
- Wsparcie VST3, AU, AAX, web (WAM/WebAssembly), iOS
- Mała wielkość binary (mniejsza niż JUCE)
- C++ first, lekki
- Aktywny rozwój

**Minusy:**
- Mniejsza społeczność niż JUCE
- Mniej dokumentacji
- GUI framework prostszy

**Kiedy wybrać:** budget zero (free), preferujesz lightweight, OR potrzebujesz web export (WebAssembly).

### DPlug (D language)

**DPlug** — framework w **języku D**.

**Plusy:**
- Język D = "C++ done right" (mówią autorzy)
- Bardzo szybki (D ma compile-time programming)
- Free, open source
- Sprawdzony (Auburn Sounds, Cut Through Recordings używają)

**Minusy:**
- Niche język (mała społeczność, rzadko spotykany w praktyce)
- Mniej developerów zna D niż C++
- Ekosystem mniejszy

**Use case:** lubisz D, chcesz lighter framework niż JUCE.

### nih-plug (Rust)

**nih-plug** to plugin framework w **Rust**.

**Plusy:**
- Rust = memory safety, no segfaults
- Modern language features
- Cross-platform
- Open source

**Minusy:**
- Niedojrzały (2026: vs JUCE = 5 lat vs 20 lat)
- Mniejsza społeczność audio Rust
- GUI w Rust audio = wciąż painful (egui, vizia, iced)
- Mniej DAW testerów dla Rust pluginów

**Use case:** love Rust, są okay z bleeding edge, edukacyjny project.

### CLAP-validator (do validacji CLAP plugins)
Standalone tool, nie framework dla samego rozwoju.

### RNBO (Cycling '74)

**RNBO** = **R**eactive **N**otation for **B**uilders **O**rganized — generator C++ z patcherów Max/MSP.

```
Max/MSP patch (visual) → RNBO → generated C++ → kompiluje do plugin
```

**Plusy:**
- Wizualne programowanie DSP (familiar dla Max users)
- Szybki prototyping
- Generuje C++ (możesz dalej edytować)
- Export do VST3, AU, web (WASM), Raspberry Pi

**Minusy:**
- Wymaga Max ($25/month subscription)
- Mniej kontroli niż czysty C++
- Wciąż młody (od 2022)

**Use case:** masz Max experience, chcesz szybko prototypować, niskie budżet.

### Faust (DSL)

**Faust** to **DSL** (domain-specific language) dla DSP. Generuje C++ / Rust / WebAssembly / etc.

```faust
// Faust: simple gain plugin
import("stdfaust.lib");
gain = hslider("gain", 0.5, 0, 1, 0.01);
process = _ * gain;
```

```bash
faust2juce -arch ladspa myplugin.dsp
# Generuje pełny JUCE plugin z Faust DSP code
```

**Plusy:**
- Bardzo prosty język DSP (matematyka audio)
- Generuje wiele platform (CPU, GPU, web, embedded)
- Open source, akademiczny

**Minusy:**
- Ograniczony do DSP (brak GUI, MIDI processing trudniejsze)
- Krzywa uczenia (functional, mathematical)
- Wciąż potrzebujesz wrap w JUCE/iPlug dla full plugin

**Use case:** prototype DSP, naukowe research, wieloplatformowy export DSP.

### Native SDK (czyste C++ bez frameworka)

Możesz pisać używając tylko Steinberg VST3 SDK / Apple AU SDK bezpośrednio:

```cpp
// VST3 SDK direct
class MyProcessor : public Steinberg::Vst::AudioEffect {
    // Pisanie w czystym VST3 SDK
};
```

**Plusy:**
- Pełna kontrola
- Brak narzutu frameworka
- Brak licencji JUCE

**Minusy:**
- **OGROMNY boilerplate** (każdy plugin = setki linii setup)
- Musisz sam pisać GUI framework
- Cross-platform porting trudny
- Każdy format (VST3, AU, AAX) wymaga osobnej implementacji

**Use case:** akademicki, super-niche, nie polecane dla większości projektów.

## Steinberg VST3 SDK

**VST3 SDK** to oficjalne narzędzia od Steinberg.

```bash
git clone https://github.com/steinbergmedia/vst3sdk.git
cd vst3sdk
git submodule update --init --recursive
```

**Co zawiera:**
- VST3 API headers
- Validator (`validator` tool — sprawdza czy plugin jest poprawny)
- VSTGUI (klasyczny GUI framework Steinberg, alternatywa do JUCE)
- Helper classes (FUID generator, parametry, helpers)
- Sample plugins do studiowania

**Licencja:** dual GPLv3 + Steinberg License (mostly permissive z atrybucją).

## Apple AU SDK

**Audio Unit SDK** od Apple — wbudowane w macOS / Xcode.

```bash
# Headers w SDKach Xcode
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/...

# AUv3 modern API
#import <CoreAudioKit/CoreAudioKit.h>
```

**Trends:**
- AUv2 (legacy) — Component bundle
- **AUv3** (modern) — Extension architecture, sandboxed, App Store ready
- W 2026 nowe pluginy powinny używać AUv3 (chyba że klient ma stare AUv2 hosts)

## AAX SDK (Avid)

**AAX** = Avid Audio eXtension dla Pro Tools.

**Wymagania:**
- **Avid Developer Account** ($295/year minimum)
- **PACE/iLok** integration (anti-piracy)
- AAX SDK download (gated)
- Apple Developer account dla macOS notarization

**Tylko dla AAX:**
- Pro Tools jest jedynym hostem
- Code signing wymagane (PACE certified)
- Każdy build musi być signed via PACE Eden tool

## Build systems

### CMake — preferowany w 2026

CMake jest **standardem** dla nowoczesnych projektów C++ audio.

```cmake
cmake_minimum_required(VERSION 3.22)
project(MyPlugin VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# JUCE
add_subdirectory(JUCE)

juce_add_plugin(MyPlugin
    COMPANY_NAME "MyCompany"
    PLUGIN_MANUFACTURER_CODE "Mcmp"
    PLUGIN_CODE "Plug"
    FORMATS VST3 AU Standalone
    PRODUCT_NAME "My Plugin"
    BUNDLE_ID "com.mycompany.myplugin"
)

target_sources(MyPlugin PRIVATE
    Source/PluginProcessor.cpp
    Source/PluginEditor.cpp
)

target_link_libraries(MyPlugin PRIVATE
    juce::juce_audio_utils
    juce::juce_dsp
    juce::juce_audio_plugin_client
)

# Cross-platform: zarówno Win i Mac działa identycznie
```

```bash
# Build na Windows
cmake -B build -G "Visual Studio 17 2022" -A x64
cmake --build build --config Release

# Build na macOS
cmake -B build -G "Xcode"
cmake --build build --config Release
```

### Projucer (legacy)
JUCE wciąż wspiera Projucer (GUI project generator). **CMake jest preferowany w 2026**.

### Xcode (macOS native)
Dla AU bundle development. CMake może generować Xcode projects.

### MSBuild / Visual Studio (Windows)
CMake może generować Visual Studio solutions. Bezpośrednie używanie .vcxproj rzadkie.

## IDE / Editors

### Visual Studio 2022 / 2025 (Windows preferred)
- **Visual Studio Community** — free dla solo dev, indie
- IntelliSense, debugger native
- Built-in Git

### Xcode (macOS preferred)
- Free, by Apple
- Wymagany dla iOS/AUv3
- AU validation built-in
- AppStore submission tooling

### CLion (cross-platform)
- JetBrains, $19/month indie, $79/month commercial
- CMake first-class support
- Świetny dla cross-platform development
- Płatny (ale są free educational licenses)

### VS Code + clangd / cpptools
- Free
- Lighter niż VS / CLion
- Wymaga setup CMake + extensions
- Popular dla minimalists

### Rider (JetBrains, .NET focus)
Mniej popularny dla audio C++.

## DSP libraries

### Standard C++ + STL
Podstawowe operacje. Nie jest specjalna dla DSP.

### Intel IPP (Integrated Performance Primitives)
- Hand-optimized SIMD
- Free dla wszystkich (od Intel)
- Tylko x86/x64 (no ARM)

### Apple Accelerate / vDSP
- Built-in macOS / iOS
- Optimized dla Apple Silicon (ARM NEON)
- FFT, filters, vectorops

### KissFFT
- Tiny, header-only FFT library
- Free
- Cross-platform

### FFTW (Fastest Fourier Transform in the West)
- "Najszybszy" open FFT
- GPL (problematyczne dla komercyjnych) — kup commercial license $$
- Lub użyj alternative

### libsndfile
- Reading/writing audio files (WAV, FLAC, AIFF)
- LGPL — OK do dynamic linking

### r8brain
- Sample rate conversion
- Free, BSD

### JUCE dsp module
- W JUCE built-in (jeśli używasz JUCE)
- IIR filters, FIR, oscillators, FFT, convolution

### Q (cycfi/q)
- Modern C++ DSP library
- Header-only, no dependencies
- Free

## MIDI processing libraries

### JUCE midi module (built-in)
Standardowo wystarcza.

### libsmf
SMF (Standard MIDI File) reading.

### RtMidi
Cross-platform MIDI input/output dla standalone apps.

## GUI options

### JUCE GUI (preferred)
- Built-in z JUCE
- Components, Lookandfeel, custom paint
- Hardware-accelerated (OpenGL)
- Vector graphics, SVG support

### VSTGUI (Steinberg)
- Wbudowany w VST3 SDK
- Alternatywa do JUCE GUI
- C++ classic style

### Web-based GUI (eksperymentalne)
- Plugin host loaded HTML/CSS/JS w native window
- Tools: WebView2 (Win), WKWebView (Mac)
- Modern look, ale audio↔web bridge wymaga pracy
- Examples: **Choc** (header-only WebView wrapper)

### Custom OpenGL/Metal/DirectX
- Najwięcej kontroli, najwięcej wysiłku
- Dla zaawansowanych wizualizacji (spectrum, oscilloscope, 3D)

### Skia (Google)
- Cross-platform 2D graphics (z Chrome i Android)
- Czasem używane w nowoczesnych pluginach

## Real-time safe collections

```cpp
// Standard library NIE jest real-time safe
std::vector<float> v;
v.push_back(1.0f);  // może allocate!

// JUCE alternatywy:
juce::Array<float>           // może allocate
juce::AudioBuffer<float>     // pre-allocated, RT-safe
juce::HeapBlock<float>       // raw memory, RT-safe gdy raz alokowane
juce::AbstractFifo           // lock-free FIFO

// External RT-safe:
choc::fifo::SingleReaderSingleWriterFIFO  // header-only
boost::lockfree::*           // lock-free queues
moodycamel::ConcurrentQueue  // popular lock-free queue
```

## Threading w plugin

```cpp
class MyPlugin : public juce::AudioProcessor {
    // Audio thread (real-time, najwyższy priorytet)
    void processBlock(...) {
        // Tylko atomics, lock-free, no allocations
    }

    // Message thread (GUI, niski priorytet)
    void parameterChanged(int idx, float val) {
        // GUI updates, file I/O, etc.
    }

    // Background thread (worker)
    juce::Thread::launch([this]() {
        // Heavy computation (e.g., loading sample, FFT analysis)
    });

    // Communication audio ↔ GUI: lock-free FIFOs
};
```

## Code signing — MUST mieć w 2026

### Windows
- **Standard cert** (~$200-400/yr): Sectigo, GlobalSign
- **EV cert** (~$400-800/yr): instant SmartScreen reputation
- Hardware token wymagany od 2023 dla EV
- `signtool sign /f cert.pfx ...`

### macOS
- **Apple Developer Program**: $99/year (obowiązkowe!)
- **Developer ID Application** certificate (free w membership)
- **Notarization**: Apple skanuje i podpisuje binary jako safe
- Bez tego: SmartScreen-equivalent ostrzeże user

```bash
# macOS code signing
codesign --deep --force --verify --verbose \
    --sign "Developer ID Application: Your Name" \
    --options runtime \
    --entitlements entitlements.plist \
    MyPlugin.vst3

# Notarization
xcrun notarytool submit MyPlugin.zip \
    --apple-id you@example.com \
    --team-id ABC123XYZ \
    --password app-specific-password \
    --wait

# Staple notarization ticket to bundle
xcrun stapler staple MyPlugin.vst3
```

## Languages comparison: szybka decyzja

| Język | Plus | Minus | Best for |
|-------|------|-------|----------|
| **C++** | Standard, ekosystem, perf | Verbose, manual memory | **99% przypadków, default choice** |
| **Rust** | Memory safety, modern | Mała społeczność audio | Hobbyści, edukacyjne |
| **D (DPlug)** | Lightweight, fast compile | Niche | Lubisz D, indie |
| **Swift** | Modern, Apple native | Tylko macOS, brak Win/Linux | macOS-only AUv3 |
| **Faust** | DSL DSP, simple | Tylko DSP, brak GUI | Prototyping, scientific |
| **JS/HTML** (web GUI) | Modern UI, web tech | Audio bridge complex | Modern UX layer poverall C++ |

**Decyzja w 99% przypadków: C++ + JUCE.**

## Stack dla początkującego

```
Język:        C++17 / C++20
Framework:    JUCE (free dla startup)
Build:        CMake
IDE:          Visual Studio Community (Win) + Xcode (Mac)
DSP:          JUCE dsp module (sufficient)
GUI:          JUCE Components
Format:       VST3 + AU (Standalone dla testing)
Hosting:      Reaper (cheap $60, świetne dla dev)
DAW testing:  Reaper, Ableton Live, Logic Pro, Pro Tools
Code sign:    Apple Developer ($99/yr) + Windows EV cert ($400/yr)
```

## Stack dla zaawansowanego / komercyjnego

```
Język:        C++20 / C++23
Framework:    JUCE Pro lub iPlug2
Build:        CMake + GitHub Actions CI
IDE:          CLion + Xcode dla macOS
DSP:          Custom + JUCE + Intel IPP / Apple Accelerate
GUI:          Custom (OpenGL/Skia/web-based) lub JUCE z heavy customization
Formats:      VST3, AU, AAX (jeśli Pro Tools), CLAP
Code virt:    VMProtect dla critical algorithms
Anti-piracy:  iLok / PACE / Custom license server
DAW testing:  10+ DAW na obu platformach
Distribution: Plugin Boutique + własna strona
Updates:      Auto-update mechanism (e.g., Sparkle on macOS)
```

## Linki i zasoby

- **JUCE**: juce.com
- **iPlug2**: github.com/iPlug2/iPlug2
- **DPlug**: github.com/AuburnSounds/Dplug
- **nih-plug** (Rust): github.com/robbert-vdh/nih-plug
- **Steinberg VST3 SDK**: github.com/steinbergmedia/vst3sdk
- **CLAP**: github.com/free-audio/clap
- **Faust**: faust.grame.fr
- **RNBO**: rnbo.cycling74.com
- **The Audio Programmer**: theaudioprogrammer.com
- **KVR Audio Forum**: kvraudio.com/forum
- **Audio Programmer Discord**: bardzo aktywne community

## Następne kroki

- **Rozdział 03** — Narzędzia programistyczne (IDE, SDK setup)
- **Rozdział 04** — DSP podstawy
- **Rozdział 05** — Tworzenie pierwszej wtyczki w JUCE
- **Rozdział 06** — Cross-platform: Windows + macOS deployment
