# Tworzenie pierwszej wtyczki w JUCE — krok po kroku

Czas opuścić teorię i zbudować coś, co naprawdę działa. W tym rozdziale przejdziemy od pustego folderu do działającego pluginu Gain w formacie VST3 (i AU na macOS), który załaduje się w Reaperze i zmieni głośność audio. To samo szkielet posłuży później dla bardziej zaawansowanych efektów.

## Setup JUCE — instalacja i licencja

JUCE to nie tylko biblioteka — to cały ekosystem (framework + Projucer + dokumentacja + przykłady). Pobieramy go z **juce.com**.

### Wybór licencji (2026)

JUCE jest dual-licensed. Decydujesz przy starcie:

| Licencja | Cena | Kto może używać | Splash screen | Source code |
|----------|------|-----------------|---------------|-------------|
| **GPLv3** | Darmowa | Open-source projekty | nie | Twój kod też GPL |
| **Personal** | Darmowa | Roczne przychody < $40k | "Made with JUCE" | Twój kod prywatny |
| **Indie** | $40/mies (lub $800/rok) | Studia < $500k revenue | brak | Twój kod prywatny |
| **Pro** | $130/mies (lub $2600/rok) | Bez limitu revenue | brak | Twój kod prywatny |
| **Educational** | Darmowa | Szkoły, uniwersytety | brak | Akademickie |

**Dla początkujących:** zaczynaj od **Personal** — darmowe, działa na 100%. Dopiero gdy plugin zarobi pierwsze $40k upgrade'ujesz na Indie. Splash screen "Made with JUCE" pojawia się raz przy ładowaniu.

### Pobranie i instalacja

```bash
# Klon repo (najlepsza metoda — zawsze najnowsza wersja)
git clone https://github.com/juce-framework/JUCE.git
cd JUCE
git checkout 8.0.4   # albo aktualna stable

# Albo download zip z juce.com → "Get JUCE"
```

Po sklonowaniu masz folder `JUCE/` z całym frameworkiem (~250 MB). Nie potrzebujesz instalować go systemowo — będziemy go linkować z naszego projektu.

## Projucer vs CMake — wybierz CMake

Projucer to GUI-based generator projektów (tworzy `.vcxproj` dla VS, `.xcodeproj` dla Xcode). Działa, ale jest legacy approach. **Nowsze projekty używają CMake** — lepiej działa z CI/CD, GitHub Actions, automatyzacją buildów.

### Dlaczego CMake?

- Single source of truth — jeden `CMakeLists.txt` dla wszystkich platform
- Działa z VS 2022, Xcode, Ninja, Make jednocześnie
- Łatwe automatyczne buildy (GitHub Actions, GitLab CI)
- Modern C++ workflow (find_package, target-based)
- JUCE od wersji 6.0 ma pełny support CMake (module `juce_add_plugin`)

### Struktura projektu

```
MyGainPlugin/
├── CMakeLists.txt           # Definicja projektu
├── JUCE/                     # Submodule albo lokalny clone
├── Source/
│   ├── PluginProcessor.cpp   # Logika audio
│   ├── PluginProcessor.h
│   ├── PluginEditor.cpp      # GUI
│   └── PluginEditor.h
├── Resources/                # Grafika, presety (opcjonalnie)
└── build/                    # Generowane przez CMake (gitignore)
```

## CMakeLists.txt — minimalny szablon

```cmake
cmake_minimum_required(VERSION 3.22)

project(MyGainPlugin VERSION 0.1.0)

# Dodaj JUCE jako subdirectory
add_subdirectory(JUCE)

# Definicja pluginu
juce_add_plugin(MyGainPlugin
    COMPANY_NAME "MyCompany"
    BUNDLE_ID com.mycompany.mygainplugin
    PLUGIN_MANUFACTURER_CODE Mcmp           # 4 znaki, tylko 1 wielka
    PLUGIN_CODE Gain                         # 4 znaki, unikalny per plugin
    FORMATS VST3 AU Standalone               # AU tylko macOS, ignorowane na Win
    PRODUCT_NAME "My Gain Plugin"
    IS_SYNTH FALSE
    NEEDS_MIDI_INPUT FALSE
    NEEDS_MIDI_OUTPUT FALSE
    EDITOR_WANTS_KEYBOARD_FOCUS FALSE
    COPY_PLUGIN_AFTER_BUILD TRUE              # auto-instalacja po buildzie
)

# Pliki źródłowe
target_sources(MyGainPlugin PRIVATE
    Source/PluginProcessor.cpp
    Source/PluginEditor.cpp
)

# JUCE moduły do linkowania
target_link_libraries(MyGainPlugin PRIVATE
    juce::juce_audio_utils
    juce::juce_dsp
    juce::juce_audio_plugin_client
    juce::juce_recommended_config_flags
    juce::juce_recommended_lto_flags
    juce::juce_recommended_warning_flags
)

target_compile_definitions(MyGainPlugin PRIVATE
    JUCE_WEB_BROWSER=0
    JUCE_USE_CURL=0
    JUCE_VST3_CAN_REPLACE_VST2=0
)
```

### Build first time

```bash
# Z folderu projektu
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022" -A x64    # Windows
# albo
cmake .. -G Xcode                              # macOS
# albo
cmake .. -G Ninja                              # cross-platform fast

# Build
cmake --build . --config Release
```

Po buildzie plugin trafia do:
- **Windows:** `C:\Program Files\Common Files\VST3\My Gain Plugin.vst3`
- **macOS:** `~/Library/Audio/Plug-Ins/VST3/My Gain Plugin.vst3`
- **Standalone:** `build/MyGainPlugin_artefacts/Release/Standalone/My Gain Plugin.exe`

## AudioProcessor — serce pluginu

`AudioProcessor` to klasa abstrakcyjna definiująca lifecycle pluginu. Każdy plugin JUCE dziedziczy z niej.

### PluginProcessor.h

```cpp
#pragma once

#include <juce_audio_processors/juce_audio_processors.h>

class MyGainAudioProcessor : public juce::AudioProcessor
{
public:
    MyGainAudioProcessor();
    ~MyGainAudioProcessor() override;

    // Lifecycle
    void prepareToPlay(double sampleRate, int samplesPerBlock) override;
    void releaseResources() override;
    bool isBusesLayoutSupported(const BusesLayout& layouts) const override;

    // Audio processing
    void processBlock(juce::AudioBuffer<float>&, juce::MidiBuffer&) override;

    // Editor (GUI)
    juce::AudioProcessorEditor* createEditor() override;
    bool hasEditor() const override { return true; }

    // Metadata
    const juce::String getName() const override { return "MyGain"; }
    bool acceptsMidi() const override { return false; }
    bool producesMidi() const override { return false; }
    bool isMidiEffect() const override { return false; }
    double getTailLengthSeconds() const override { return 0.0; }

    // Programs (presets) — minimal
    int getNumPrograms() override { return 1; }
    int getCurrentProgram() override { return 0; }
    void setCurrentProgram(int) override {}
    const juce::String getProgramName(int) override { return {}; }
    void changeProgramName(int, const juce::String&) override {}

    // State save/load
    void getStateInformation(juce::MemoryBlock& destData) override;
    void setStateInformation(const void* data, int sizeInBytes) override;

    // Parameters — używamy AudioProcessorValueTreeState (APVTS)
    juce::AudioProcessorValueTreeState parameters;

private:
    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MyGainAudioProcessor)
};
```

### PluginProcessor.cpp — pełna implementacja

```cpp
#include "PluginProcessor.h"
#include "PluginEditor.h"

MyGainAudioProcessor::MyGainAudioProcessor()
    : AudioProcessor(BusesProperties()
        .withInput("Input", juce::AudioChannelSet::stereo(), true)
        .withOutput("Output", juce::AudioChannelSet::stereo(), true)),
      parameters(*this, nullptr, "Parameters",
        {
            std::make_unique<juce::AudioParameterFloat>(
                juce::ParameterID{"gain", 1},     // ID i wersja
                "Gain",                            // Nazwa wyświetlana
                juce::NormalisableRange<float>(-60.0f, 12.0f, 0.1f),  // -60..+12 dB
                0.0f,                              // domyślnie 0 dB
                "dB"
            )
        })
{
}

MyGainAudioProcessor::~MyGainAudioProcessor() {}

void MyGainAudioProcessor::prepareToPlay(double sampleRate, int samplesPerBlock)
{
    // Wywoływane raz przed startem audio
    // Tu inicjalizujemy bufory, filtry, smoothing
    juce::ignoreUnused(sampleRate, samplesPerBlock);
}

void MyGainAudioProcessor::releaseResources()
{
    // Zwalnianie zasobów po stopie (host wstrzymał audio)
}

bool MyGainAudioProcessor::isBusesLayoutSupported(const BusesLayout& layouts) const
{
    // Akceptujemy mono i stereo, in == out
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono() &&
        layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

    return layouts.getMainOutputChannelSet() == layouts.getMainInputChannelSet();
}

void MyGainAudioProcessor::processBlock(juce::AudioBuffer<float>& buffer,
                                         juce::MidiBuffer& midiMessages)
{
    juce::ScopedNoDenormals noDenormals;
    auto totalNumInputChannels = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    // Wyzeruj nieużywane kanały
    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear(i, 0, buffer.getNumSamples());

    // Pobierz parametr (atomic load — bezpieczne real-time)
    const float gainDb = parameters.getRawParameterValue("gain")->load();
    const float gainLinear = juce::Decibels::decibelsToGain(gainDb);

    // Zastosuj gain do każdego kanału
    for (int channel = 0; channel < totalNumInputChannels; ++channel)
    {
        auto* channelData = buffer.getWritePointer(channel);
        for (int sample = 0; sample < buffer.getNumSamples(); ++sample)
        {
            channelData[sample] *= gainLinear;
        }
    }
}

juce::AudioProcessorEditor* MyGainAudioProcessor::createEditor()
{
    return new MyGainAudioProcessorEditor(*this);
}

void MyGainAudioProcessor::getStateInformation(juce::MemoryBlock& destData)
{
    // Zapisz stan parametrów do XML → binary
    auto state = parameters.copyState();
    std::unique_ptr<juce::XmlElement> xml(state.createXml());
    copyXmlToBinary(*xml, destData);
}

void MyGainAudioProcessor::setStateInformation(const void* data, int sizeInBytes)
{
    // Wczytaj stan z binary → XML
    std::unique_ptr<juce::XmlElement> xmlState(getXmlFromBinary(data, sizeInBytes));
    if (xmlState != nullptr && xmlState->hasTagName(parameters.state.getType()))
    {
        parameters.replaceState(juce::ValueTree::fromXml(*xmlState));
    }
}

// Plugin entry point — host woła to żeby utworzyć instancję
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new MyGainAudioProcessor();
}
```

## AudioProcessorEditor — GUI

GUI w JUCE to osobna klasa. Komunikuje się z processorem przez `AudioProcessorValueTreeState`.

### PluginEditor.h

```cpp
#pragma once

#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_gui_basics/juce_gui_basics.h>
#include "PluginProcessor.h"

class MyGainAudioProcessorEditor : public juce::AudioProcessorEditor
{
public:
    explicit MyGainAudioProcessorEditor(MyGainAudioProcessor&);
    ~MyGainAudioProcessorEditor() override;

    void paint(juce::Graphics&) override;
    void resized() override;

private:
    MyGainAudioProcessor& processorRef;

    juce::Slider gainSlider;
    juce::Label gainLabel;

    // Attachment łączy slider z parametrem APVTS automatycznie
    using SliderAttachment = juce::AudioProcessorValueTreeState::SliderAttachment;
    std::unique_ptr<SliderAttachment> gainAttachment;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR(MyGainAudioProcessorEditor)
};
```

### PluginEditor.cpp

```cpp
#include "PluginEditor.h"

MyGainAudioProcessorEditor::MyGainAudioProcessorEditor(MyGainAudioProcessor& p)
    : AudioProcessorEditor(&p), processorRef(p)
{
    setSize(300, 250);

    // Slider — rotary knob
    gainSlider.setSliderStyle(juce::Slider::RotaryHorizontalVerticalDrag);
    gainSlider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 24);
    gainSlider.setTextValueSuffix(" dB");
    addAndMakeVisible(gainSlider);

    // Label
    gainLabel.setText("Gain", juce::dontSendNotification);
    gainLabel.setJustificationType(juce::Justification::centred);
    addAndMakeVisible(gainLabel);

    // Attachment — magia: GUI <-> APVTS w 1 linii
    gainAttachment = std::make_unique<SliderAttachment>(
        processorRef.parameters, "gain", gainSlider);
}

MyGainAudioProcessorEditor::~MyGainAudioProcessorEditor() {}

void MyGainAudioProcessorEditor::paint(juce::Graphics& g)
{
    g.fillAll(juce::Colour::fromRGB(20, 20, 30));
    g.setColour(juce::Colours::white);
    g.setFont(20.0f);
    g.drawFittedText("My Gain Plugin", getLocalBounds().removeFromTop(40),
                     juce::Justification::centred, 1);
}

void MyGainAudioProcessorEditor::resized()
{
    auto area = getLocalBounds();
    area.removeFromTop(40);   // miejsce na tytuł
    gainLabel.setBounds(area.removeFromTop(24));
    gainSlider.setBounds(area.reduced(20));
}
```

## Build i pierwsze uruchomienie

### Standalone (najszybszy test)

Po `cmake --build . --config Release` masz w `build/MyGainPlugin_artefacts/Release/Standalone/` plik `.exe` (Win) albo `.app` (macOS). Klikasz, otwiera się okno z pokrętłem, słyszysz audio z systemowego inputu (mic) → output (głośniki). Niezbędne do szybkiego testu logiki.

### Test w DAW — Reaper jako preferowany

Reaper to **must-have dla developerów pluginów**:

- **Darmowy do testów** (60-day full eval, potem $60 personal)
- **Najszybszy plugin scan** w branży (sekundy zamiast minut)
- **Świetny crash protection** — gdy plugin pada, Reaper zostaje
- **Wyświetla logi** z `juce::Logger::writeToLog()` w konsoli debug
- **VST3 + VST2 + AU + LV2** w jednym DAW
- **Re-scan na żądanie** — Options → Preferences → Plug-ins → VST → Re-scan

Po buildzie:
1. Otwórz Reaper
2. Wstaw track (Insert → New Track)
3. Add FX → szukaj "My Gain Plugin" → load
4. Zagraj cokolwiek (audio file na track albo input)
5. Kręć pokrętłem — głośność się zmienia

### Pierwszy test w innych DAW

| DAW | Cena | Plus | Minus dla developera |
|-----|------|------|----------------------|
| **Reaper** | $60 (eval 60 dni full) | Najszybszy scan, debug-friendly | Mało użytkowników w wide market |
| **FL Studio** | $99-499 | Polski producer market, łatwy | Wolniejszy scan, weird VST3 wrappery |
| **Ableton Live** | $99-749 | Live performance market | Wolny scan, sandbox crashe |
| **Logic Pro** | $200 (Mac only) | Premium AU market | AU only, brak VST3 |
| **Pro Tools** | $400+ | Pro audio post-production | Tylko AAX, ekosystem zamknięty |
| **Cubase** | $99-579 | Steinberg native VST3 | Wolny scan |

**Strategia:** rozwijaj w Reaperze, **finalnie testuj w 3-4 DAW** przed releasem (minimum: Reaper, Ableton, Logic, FL Studio).

## Częste problemy pierwszego pluginu

<div class="card">

### Plugin się nie ładuje (host go nie widzi)

- Czy plik `.vst3` jest w odpowiednim folderze? (Windows: `C:\Program Files\Common Files\VST3`)
- Czy host robi rescan? (Reaper: Options → Plug-ins → Re-scan)
- Czy build jest x64? (Większość DAW jest 64-bit; 32-bit deprecated)
- Czy `BUNDLE_ID` jest unikalny? (Powtarzający się może blokować załadowanie)

</div>

<div class="card">

### Brak dźwięku przez plugin

- Czy `processBlock` jest faktycznie wołany? (`DBG("processBlock")` w debugu)
- Czy `isBusesLayoutSupported` zwraca true dla aktualnego routingu?
- Czy `prepareToPlay` zostało wywołane przed `processBlock`?
- Sprawdź `buffer.getNumChannels()` — niektóre DAW (Logic Pro) wysyłają mono input nawet do stereo pluginu.

</div>

<div class="card">

### Parametry nie reagują

- Czy używasz `AudioProcessorValueTreeState` z attachmentami?
- Czy ID parametru w slider attachment zgadza się z ID w konstruktorze?
- Czy `getStateInformation`/`setStateInformation` są zaimplementowane? (Bez tego DAW nie zapisze stanu — i może go resetować)

</div>

<div class="card">

### Plugin crashuje przy ładowaniu

- Sprawdź `juce::Logger` output (Reaper konsola, albo log do pliku)
- Najczęściej: alokacja pamięci w `processBlock` (rzadkie ale crashuje), undefined behavior w destruktorze, brak `JUCE_DECLARE_NON_COPYABLE`
- Use-after-free w editor — `~AudioProcessorEditor()` musi być clean

</div>

## Od Gain do prostych efektów

Mając Gain plugin masz 90% szkieletu każdego efektu. Modyfikacje:

### Panner (stereo balance)

```cpp
// Dodaj parametr "pan" w konstruktorze:
std::make_unique<juce::AudioParameterFloat>(
    juce::ParameterID{"pan", 1}, "Pan",
    juce::NormalisableRange<float>(-1.0f, 1.0f, 0.01f), 0.0f)

// W processBlock — assume stereo:
float pan = parameters.getRawParameterValue("pan")->load();
float leftGain  = juce::jlimit(0.0f, 1.0f, 1.0f - pan);
float rightGain = juce::jlimit(0.0f, 1.0f, 1.0f + pan);

buffer.applyGain(0, 0, buffer.getNumSamples(), leftGain);
buffer.applyGain(1, 0, buffer.getNumSamples(), rightGain);
```

### Mute / bypass

```cpp
auto* muteParam = parameters.getRawParameterValue("mute");
if (muteParam->load() > 0.5f)
    buffer.clear();
```

### Polarity flip (faza)

```cpp
auto* flipParam = parameters.getRawParameterValue("flip");
if (flipParam->load() > 0.5f)
{
    for (int ch = 0; ch < buffer.getNumChannels(); ++ch)
        buffer.applyGain(ch, 0, buffer.getNumSamples(), -1.0f);
}
```

### M/S (Mid-Side) processing

```cpp
// Stereo → M/S
auto* L = buffer.getWritePointer(0);
auto* R = buffer.getWritePointer(1);
for (int i = 0; i < buffer.getNumSamples(); ++i)
{
    float mid  = (L[i] + R[i]) * 0.5f;
    float side = (L[i] - R[i]) * 0.5f;
    // ... przetwarzanie mid i side osobno
    L[i] = mid + side;
    R[i] = mid - side;
}
```

## Co dalej

Mając pluginy Gain, Pan, Mute, Polarity — masz fundament. Następne kroki:

- **Cross-platform build** (Windows + macOS + universal binary) — rozdział 6
- **Lepsze GUI** (custom knobs, level meters, waveform display) — rozdział 7
- **DSP advanced** (filtry, kompresja, reverb, delay, FFT) — rozdział 8
- **Dystrybucja** (instalatory, code signing, notarization) — rozdział 9

JUCE doc jest świetna — `juce.com/learn/documentation` i tutoriale na `juce.com/learn/tutorials`. Kod source frameworka też warto czytać — najlepsze examples siedzą w `JUCE/examples/Plugins/`.
