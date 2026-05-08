# Czym są VST plugins — wprowadzenie

## Co to jest plugin audio?

**Audio plugin** to moduł oprogramowania który przetwarza dźwięk w czasie rzeczywistym wewnątrz aplikacji-hosta (DAW = Digital Audio Workstation). Plugin nie jest samodzielną aplikacją — jest **biblioteką dynamiczną** (DLL na Windows, .vst3 / .component na macOS) ładowaną przez DAW.

```
┌─────────────────────────────────────────┐
│        DAW (Host application)            │
│   Ableton Live, Logic Pro, FL Studio,    │
│   Reaper, Cubase, Pro Tools, Bitwig...   │
│                                          │
│   ┌─────────┐  ┌─────────┐  ┌────────┐ │
│   │ Plugin  │  │ Plugin  │  │ Plugin │ │
│   │ (EQ)    │→│ (Comp)  │→│ (Reverb)│ │
│   └─────────┘  └─────────┘  └────────┘ │
│        ↓ audio buffer flow              │
│   ┌─────────────────────────────────┐  │
│   │    Audio output (speakers)       │  │
│   └─────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## Typy pluginów

### Wg funkcji:

| Typ | Co robi | Przykłady |
|-----|---------|-----------|
| **Effect** (FX) | Przetwarza audio | EQ, kompresor, reverb, delay, distortion |
| **Instrument** (synth) | Generuje audio z MIDI | Synth, sampler, drum machine |
| **MIDI Effect** | Przetwarza MIDI | Arpeggiator, chord generator, scale snapping |
| **Analyzer** | Wizualizacja (no audio out) | Spectrum analyzer, loudness meter, tuner |
| **Sidechain** | Audio routing | Sidechain compressor, ducker |

### Wg formatu:

| Format | Twórca | Platformy | Status 2026 |
|--------|--------|-----------|-------------|
| **VST3** | Steinberg | Win, macOS, Linux | ⭐ Standard |
| **VST2** | Steinberg (legacy) | Win, macOS, Linux | ❌ Deprecated (od 2018) |
| **AU (Audio Unit)** | Apple | macOS, iOS only | ⭐ Standard na Apple |
| **AAX** | Avid | Win, macOS | ⭐ Pro Tools |
| **CLAP** | Bitwig + u-he | Win, macOS, Linux | 🆕 Open source, growing |
| **LV2** | Linux Audio Devs | Linux głównie | Niche, Linux DAW |
| **AUv3** | Apple | iOS, macOS | Mobile-friendly |
| **Component** (Mac) | Apple | macOS | Audio Unit container |
| **iLok** | PACE | Cross-platform DRM | Pro/legal protection |

**W praktyce 2026:** Trzeba wspierać minimum **VST3** (Win) + **AU** (macOS). AAX jeśli targetujesz Pro Tools (studyjne workflow). CLAP jest świeży i zyskuje (Bitwig, FL Studio, Reaper supportują).

## Architektura plugin (high level)

```cpp
// Plugin lifecycle (uproszczone, JUCE-style)
class MyPlugin {
public:
    // 1. Konstruktor — DAW ładuje plugin
    MyPlugin();

    // 2. prepareToPlay — DAW informuje o sample rate i buffer size
    void prepareToPlay(double sampleRate, int samplesPerBlock);

    // 3. processBlock — wywoływane CIĄGLE przez DAW
    //    Tu dzieje się magia — przetwarzasz audio sample-po-sample
    void processBlock(AudioBuffer<float>& buffer, MidiBuffer& midi);

    // 4. releaseResources — gdy DAW zatrzymuje playback
    void releaseResources();

    // 5. Parametry — DAW może zmieniać w czasie rzeczywistym
    void setParameter(int index, float value);
    float getParameter(int index);

    // 6. State save/load — DAW zapisuje stan plugin w projekcie
    void getStateInformation(MemoryBlock& destData);
    void setStateInformation(const void* data, int sizeInBytes);

    // 7. GUI (opcjonalnie) — okno plugin
    AudioProcessorEditor* createEditor();
};
```

## Kluczowe pojęcia DSP

### Sample rate (częstotliwość próbkowania)
- Ile razy na sekundę jest próbkowany sygnał audio
- Standard: **44100 Hz** (CD), **48000 Hz** (video, modern), **96000 Hz** (high-quality), **192000 Hz** (mastering)
- DAW przekazuje sample rate w `prepareToPlay`

### Buffer size
- Liczba sampli przetwarzanych w jednym wywołaniu `processBlock`
- Typowe: 64, 128, 256, 512, 1024 sampli
- **Mniejszy buffer = niższa latencja, ale więcej CPU** (więcej wywołań/sec)

```
Latencja ≈ buffer_size / sample_rate
np. 256 / 48000 = 5.3 ms
```

### Real-time constraints (KRYTYCZNE!)

`processBlock` jest wywoływane w **wątku audio o najwyższym priorytecie**. **NIE WOLNO**:
- ❌ Alokować pamięci (`new`, `malloc`, `std::vector::resize`)
- ❌ Lockować mutexów (priority inversion → glitch)
- ❌ Wykonywać I/O (file, network, console)
- ❌ Rzucać wyjątków
- ❌ Wywoływać funkcji o nieprzewidywalnym czasie

**Zasada:** wszystko co potrzebujesz (bufory, lookup tables, voices) **alokuj w `prepareToPlay`**, w `processBlock` tylko **arytmetyka i operacje na pre-alokowanych zasobach**.

### Channels (mono, stereo, multichannel)

```cpp
void processBlock(AudioBuffer<float>& buffer, MidiBuffer& midi) {
    int numChannels = buffer.getNumChannels();  // 1 = mono, 2 = stereo, 6 = 5.1
    int numSamples = buffer.getNumSamples();

    for (int ch = 0; ch < numChannels; ++ch) {
        float* channelData = buffer.getWritePointer(ch);
        for (int i = 0; i < numSamples; ++i) {
            // process sample
            channelData[i] *= 0.5f;  // np. -6dB volume
        }
    }
}
```

### MIDI

- **MIDI** = Musical Instrument Digital Interface
- Komunikuje noty, velocity, controlery, aftertouch, pitch bend
- Plugin instrumentalny **konsumuje** MIDI, generuje audio
- Plugin efektowy zwykle **ignoruje** MIDI (lub używa do MIDI Learn)

```cpp
for (auto metadata : midi) {
    auto message = metadata.getMessage();
    if (message.isNoteOn()) {
        int noteNumber = message.getNoteNumber();    // 60 = middle C
        float velocity = message.getFloatVelocity();  // 0.0 - 1.0
        // Start playing note...
    } else if (message.isNoteOff()) {
        // Release note...
    }
}
```

### Parametry

- DAW może zmieniać parametry w czasie rzeczywistym (automation)
- Parametry są **thread-safe atomic floats** zwykle
- Każdy parametr ma: name, label (dB, Hz, %), range, default, value->string conversion

```cpp
// JUCE AudioParameterFloat
gain = new AudioParameterFloat(
    "gain",           // ID
    "Gain",           // Display name
    0.0f, 1.0f,       // Min, max
    0.5f              // Default
);
```

## Host vs Plugin

| Aspekt | Host (DAW) | Plugin |
|--------|------------|--------|
| Życie | Standalone application | Loaded DLL/dylib |
| Audio I/O | Bezpośredni dostęp do hardware | Przekazuje host przez buffery |
| Threading | Zarządza wszystkim | Wywoływany przez host |
| GUI | Główne okno | Sub-window (modal lub embedded) |
| MIDI | Routes z controllers | Receives od host |
| State | Project file | Per-instance state |
| Crash | Niesie cały DAW down | Niesie cały DAW down (jeśli host nie sandboxuje) |

**Plugin sandboxing** (od macOS Logic, Bitwig, niektóre wersje Cubase) izoluje pluginy w osobnych procesach — jeden crashujący plugin nie zabija DAW.

## Popularne hosty (DAW) 2026

| DAW | Platforma | Cena | Target user |
|-----|-----------|------|-------------|
| **Ableton Live** | Win, Mac | $99-749 | Electronic, live performance |
| **FL Studio** | Win, Mac | $99-499 | Beat making, EDM |
| **Logic Pro** | Mac only | $199 | Songwriting, Apple ecosystem |
| **Cubase** | Win, Mac | $99-579 | Studio, MIDI editing |
| **Pro Tools** | Win, Mac | $30/mc-$299/yr | Professional studio, mixing |
| **Reaper** | Win, Mac, Linux | $60 (rozsądna licencja) | Power users, scripting |
| **Bitwig Studio** | Win, Mac, Linux | $99-399 | Modern, modular workflow |
| **Studio One** | Win, Mac | $99-399 | All-in-one |
| **Reason** | Win, Mac | $99-399 | Rack-style modular |
| **GarageBand** | Mac, iOS | Free | Beginners |
| **Cakewalk** | Win | Free | Budget |
| **Ardour** | Win, Mac, Linux | Open source | Linux users |

**Plugin developer musi testować w wielu DAW** — każdy ma quirks (np. Logic ma własne AU validation, Pro Tools ma AAX-only itp.).

## Standardy audio

### VST3 (Steinberg)

**Aktualne (2026):** VST3 SDK 3.7.x

- C++ API
- Manifest XML (vst3 to faktycznie folder na macOS, plik .vst3 na Windows)
- Multiple instances per plugin
- 64-bit only (od dawna)
- Free dla wszystkich (od 2018), wcześniej GPL/proprietary
- **Steinberg License** (mostly permissive ale z atrybucją)

### AU (Audio Unit) — Apple

- Tylko macOS (i iOS jako AUv3)
- C / Objective-C / Swift API
- AU SDK przez Apple
- Wymagany dla Logic, GarageBand
- Bundle structure: `MyPlugin.component`

### AAX — Avid

- Pro Tools only
- C++ API z AAX SDK
- **Wymaga PACE/iLok** — anti-piracy, podpisywanie
- Komercyjny developer registration ($295+ za rok)
- Bardziej restrykcyjny niż VST3

### CLAP (Clever Audio Plugin)

- **Open source** (MIT license)
- C API (cleaner niż VST3 C++ API)
- Wsparcie nowoczesnych features (modulation, polyphonic params)
- Rosnąca lista DAW: Bitwig, Reaper, FL Studio, Ableton (eksperymentalne)
- **Trend 2026:** więcej developerów dodaje CLAP support

## Jak DAW ładuje plugin?

### Windows

DAW skanuje katalogi:
```
C:\Program Files\Common Files\VST3\
C:\Program Files\Common Files\VST2\        (legacy)
C:\Program Files\Steinberg\VstPlugins\     (legacy VST2)
%LOCALAPPDATA%\Programs\Common\VST3\        (per user)
```

Plugin = `.vst3` plik (technically folder structure DLL).

### macOS

DAW skanuje:
```
/Library/Audio/Plug-Ins/VST3/         (system)
~/Library/Audio/Plug-Ins/VST3/         (user)
/Library/Audio/Plug-Ins/Components/    (AU system)
~/Library/Audio/Plug-Ins/Components/   (AU user)
```

Plugin = bundle (folder z `.vst3` lub `.component` extension).

### Linux

```
/usr/lib/vst3/
~/.vst3/
/usr/lib/lv2/
```

## Performance — co krytyczne?

### CPU usage
- Plugin używa hosta CPU
- 50 instancji EQ × 5% CPU each = 250% CPU = klient nienawidzi
- **Cel: <1% CPU per typical instance**

### Latency
- Każdy plugin może dodać latencję (np. lookahead w limiterze)
- DAW kompensuje (PDC = Plugin Delay Compensation), ale dodaje do total latency tracku
- **Zero-latency design** preferowany gdzie możliwy

### Memory
- Sampler load 4GB samples → klient nie może mieć 100 instances
- Mind your memory footprint

### Glitches / dropouts
- Buffer underrun = audible click/pop
- Każda alokacja w `processBlock` ryzyko
- Profile thoroughly!

## Plugin licencjonowanie i ochrona

### Komercyjne plugins zwykle wymagają:
1. **License key** validation (online lub offline)
2. **Anti-piracy** measure (challenge-response, hardware ID lock)
3. **Trial mode** (15-30 dni, lub time-limited)
4. **iLok** dla AAX (obowiązkowe)

### Popularne systemy DRM:
- **iLok** (PACE) — fizyczny USB key lub cloud, dominuje w pro audio
- **eLicenser** (Steinberg) — głównie dla Steinberg products, deprecated 2024
- **PACE Anti-Piracy** — multi-developer
- **Custom serwer** — wielu indie developers
- **CodeMeter (Wibu)** — alternatywa

Szczegóły w **rozdziale 09** (Dystrybucja).

## Workflow tworzenia pluginu — overview

```
┌────────────────────────────────────┐
│ 1. Idea + research konkurencji    │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 2. DSP design (algorytm)           │
│    Prototyp w Pythonie / MATLAB    │
│    (NumPy, scipy.signal)           │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 3. Implementacja w C++ (JUCE)      │
│    processBlock + parametry        │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 4. GUI design                      │
│    JUCE LookAndFeel / własne SVG   │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 5. Testy w wielu DAW               │
│    Reaper, Live, Logic, Pro Tools  │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 6. Cross-platform builds           │
│    Windows + macOS                 │
│    Code signing + notarization     │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 7. Beta testers                    │
└────────────┬───────────────────────┘
             ▼
┌────────────────────────────────────┐
│ 8. Marketing + sprzedaż            │
│    Plugin Boutique, własna strona  │
└────────────────────────────────────┘
```

## Real-time programming mindset

Audio thread = **hard real-time**. Cokolwiek co może blokować lub trwać nieprzewidywalnie długo → **dropout (audible glitch)**.

```cpp
// ZŁE w processBlock:
void processBlock(AudioBuffer<float>& buffer, MidiBuffer& midi) {
    std::vector<float> temp;       // ❌ alokacja!
    temp.resize(buffer.getNumSamples());

    std::ofstream log("debug.log"); // ❌ I/O!
    log << "Processing\n";

    std::lock_guard<std::mutex> lk(my_mutex);  // ❌ lock!

    auto* data = new float[1024];  // ❌ alokacja heap!
    delete[] data;
}

// DOBRZE:
class MyPlugin {
    std::array<float, 4096> tempBuffer;  // pre-allocated
    std::atomic<float> gain{0.5f};       // lock-free
public:
    void prepareToPlay(double sr, int blockSize) {
        // Tu alokuj wszystko co będzie potrzebne
        if (blockSize > tempBuffer.size()) {
            // Realokuj (NIE w processBlock!)
        }
    }

    void processBlock(AudioBuffer<float>& buffer, MidiBuffer& midi) {
        float currentGain = gain.load(std::memory_order_relaxed);
        // Tylko arytmetyka, brak alokacji, brak locks
        for (int ch = 0; ch < buffer.getNumChannels(); ++ch) {
            float* data = buffer.getWritePointer(ch);
            for (int i = 0; i < buffer.getNumSamples(); ++i) {
                data[i] *= currentGain;
            }
        }
    }
};
```

## Co dalej?

- **Rozdział 02** — Języki i frameworki (C++, JUCE, iPlug2, Rust)
- **Rozdział 03** — Narzędzia programistyczne (IDE, SDK, build systems)
- **Rozdział 04** — DSP podstawy (filtry, oscylatory, FFT)
- **Rozdział 05** — Tworzenie pierwszej wtyczki (Hello VST3 w JUCE)
- **Rozdział 06** — Cross-platform: Windows + macOS

## Zasoby do nauki

### Książki:
- **The Audio Programming Book** (MIT Press, Boulanger)
- **Designing Audio Effect Plugins in C++** (Will Pirkle) — biblia
- **Designing Software Synthesizer Plugins in C++** (Pirkle)
- **The Computer Music Tutorial** (Roads) — fundamenty DSP
- **DAFX: Digital Audio Effects** (Zölzer)

### Online:
- **JUCE Tutorials**: juce.com/learn/tutorials
- **The Audio Programmer** (YouTube) — Joshua Hodge, świetne tutoriale
- **Music DSP** (musicdsp.org) — repozytorium algorytmów
- **Faust documentation** — DSP-specific language
- **DSP Stack Exchange**: dsp.stackexchange.com
- **KVR Audio Forum**: kvraudio.com — community

### Kursy:
- **The Audio Programmer Academy**
- **Coursera: Audio Signal Processing**
- **Kadenze: Plugin Development with JUCE**

### Open source projects do studiowania:
- **JUCE Examples** (github.com/juce-framework/JUCE)
- **Vital Synth** (github.com/mtytel/vital) — modern wavetable synth
- **Surge XT** (surge-synthesizer.github.io) — open source synth
- **Dexed** (DX7 emulator)
- **TAL-NoiseMaker** (open source)

## Podsumowanie

VST development to **C++ + DSP + real-time programming + GUI + cross-platform deployment**. Krzywa uczenia stroma, ale ekosystem dojrzały (JUCE, iPlug2). W 2026 plugin market jest dorosły — konkurencja silna, ale niszowy plugin z dobrym brzmieniem i marketingiem może zarobić.

**Twoja roadmapa:**
1. Naucz się C++ (jeśli nie znasz)
2. Zrozum DSP fundamentals
3. Wybierz framework (JUCE = #1 wybór)
4. Zbuduj pierwszy efect (gain plugin → EQ → delay → reverb)
5. Naucz się testować w wielu DAW
6. Mac + Windows builds + signing
7. Idź na rynek
