# GUI i grafika pluginu

GUI to **pierwsza i najważniejsza rzecz**, którą widzi klient. Możesz mieć najlepszy DSP na świecie, ale jeśli plugin wygląda na zrobiony w 1998, ludzie go nie kupią. W tym rozdziale: jak budować profesjonalny, responsywny, retina-ready interfejs w JUCE — od podstaw `Component` do customowych pokręteł i level meterów.

## Hierarchia GUI w JUCE — Component class

W JUCE wszystko co jest na ekranie dziedziczy z `juce::Component`. Slidery, przyciski, etykiety, custom widgets — to wszystko `Component`y. Każdy ma:

- **Bounds** (pozycję i rozmiar w parent coords)
- **paint()** metodę (rysowanie)
- **resized()** metodę (layout dzieci)
- **Listener interfaces** (onClick, onValueChanged, etc.)

```cpp
class MyComponent : public juce::Component
{
public:
    void paint(juce::Graphics& g) override
    {
        // Tu rysujemy. Wykonuje się gdy komponent się repainted.
        g.fillAll(juce::Colours::darkblue);
        g.setColour(juce::Colours::white);
        g.drawText("Hello", getLocalBounds(), juce::Justification::centred);
    }

    void resized() override
    {
        // Tu układamy dzieci (children components).
        // getLocalBounds() = bounds w lokalnych współrzędnych.
    }
};
```

### Graphics — rysowanie 2D

`juce::Graphics&` w `paint()` to context oferujący:

```cpp
void paint(juce::Graphics& g) override
{
    auto bounds = getLocalBounds().toFloat();

    // Tło
    g.fillAll(juce::Colour(0xff1a1a2e));

    // Wypełniony prostokąt
    g.setColour(juce::Colour(0xff0f3460));
    g.fillRoundedRectangle(bounds.reduced(10), 8.0f);

    // Obrys (stroke)
    g.setColour(juce::Colour(0xffe94560));
    g.drawRoundedRectangle(bounds.reduced(10), 8.0f, 2.0f);

    // Linia
    g.drawLine(0.0f, bounds.getCentreY(), bounds.getWidth(), bounds.getCentreY(), 1.5f);

    // Okrąg
    g.fillEllipse(bounds.reduced(40));

    // Tekst
    g.setFont(juce::Font(juce::FontOptions(18.0f).withStyle("Bold")));
    g.setColour(juce::Colours::white);
    g.drawText("Plugin", bounds, juce::Justification::centred);

    // Path — dowolny kształt
    juce::Path path;
    path.startNewSubPath(0, 0);
    path.lineTo(50, 50);
    path.cubicTo(60, 60, 70, 30, 100, 50);
    path.closeSubPath();
    g.strokePath(path, juce::PathStrokeType(2.0f));

    // Gradient
    juce::ColourGradient gradient(
        juce::Colours::pink, 0, 0,
        juce::Colours::purple, bounds.getWidth(), bounds.getHeight(), false);
    g.setGradientFill(gradient);
    g.fillRect(bounds);
}
```

## Resizable plugins

Producenci profesjonalni żądają możliwości resizowania okna pluginu (różne ekrany, różne układy DAW). W JUCE:

```cpp
// W konstruktorze AudioProcessorEditor:
setResizable(true, true);                    // resizable + użyj resize-corner
setResizeLimits(400, 300, 1600, 1200);       // min/max rozmiar

// Aspekt ratio (np. 16:10):
constrainer = std::make_unique<juce::ComponentBoundsConstrainer>();
constrainer->setFixedAspectRatio(16.0 / 10.0);
setConstrainer(constrainer.get());
```

W `resized()` przelicz layout proporcjonalnie:

```cpp
void resized() override
{
    auto area = getLocalBounds().reduced(10);
    
    auto headerArea = area.removeFromTop(area.getHeight() / 8);
    titleLabel.setBounds(headerArea);

    auto knobsArea = area;
    int knobWidth = knobsArea.getWidth() / 3;
    
    gainKnob.setBounds(knobsArea.removeFromLeft(knobWidth).reduced(10));
    panKnob.setBounds(knobsArea.removeFromLeft(knobWidth).reduced(10));
    mixKnob.setBounds(knobsArea.reduced(10));
}
```

## HiDPI / Retina support

W 2026 wszystkie nowe Maki mają Retina (2x scale), Windows ma 1.25x/1.5x/1.75x/2x scaling. **Twój plugin MUSI wyglądać ostro na każdym scale.**

### Złota zasada: używaj wektorów, nie bitmap

```cpp
// ZŁE: hardcoded bitmap, rozmazuje się na 2x:
auto img = juce::ImageCache::getFromMemory(BinaryData::knob_png, BinaryData::knob_pngSize);
g.drawImage(img, 0, 0, 100, 100, 0, 0, 256, 256);

// DOBRE: rysowanie wektorowe:
g.drawEllipse(bounds.toFloat(), 2.0f);
g.fillPath(myPathShape);
```

### SVG support

JUCE czyta SVG z `juce::Drawable::createFromSVG()`:

```cpp
const auto svgString = R"(<svg viewBox="0 0 100 100">
    <circle cx="50" cy="50" r="40" fill="hotpink"/>
</svg>)";

auto xml = juce::XmlDocument::parse(svgString);
auto drawable = juce::Drawable::createFromSVG(*xml);

// W paint():
drawable->drawWithin(g, getLocalBounds().toFloat(),
    juce::RectanglePlacement::centred, 1.0f);
```

### Auto-scaling factor

```cpp
// JUCE robi auto, ale jeśli musisz manualnie:
auto scale = juce::Desktop::getInstance().getDisplays()
                .getPrimaryDisplay()->scale;
// scale = 2.0 na Retina, 1.5 na Win 150% scaling, etc.
```

## Custom LookAndFeel — branded look

`LookAndFeel` to klasa zmieniająca wygląd wszystkich standardowych komponentów (slidery, przyciski). Definiujesz raz — wszystko wygląda spójnie.

```cpp
class MyLookAndFeel : public juce::LookAndFeel_V4
{
public:
    MyLookAndFeel()
    {
        setColour(juce::Slider::thumbColourId, juce::Colour(0xffec4899));
        setColour(juce::Slider::rotarySliderFillColourId, juce::Colour(0xffec4899));
        setColour(juce::Slider::rotarySliderOutlineColourId, juce::Colour(0xff334155));
        setColour(juce::Slider::textBoxOutlineColourId, juce::Colour(0));
        setColour(juce::Slider::textBoxBackgroundColourId, juce::Colour(0xff1e293b));
        setColour(juce::Slider::textBoxTextColourId, juce::Colour(0xffe2e8f0));
    }

    void drawRotarySlider(juce::Graphics& g, int x, int y, int width, int height,
                          float sliderPosProportional, float rotaryStartAngle,
                          float rotaryEndAngle, juce::Slider& slider) override
    {
        auto radius = juce::jmin(width / 2, height / 2) - 8.0f;
        auto centreX = x + width * 0.5f;
        auto centreY = y + height * 0.5f;
        auto angle = rotaryStartAngle + sliderPosProportional * (rotaryEndAngle - rotaryStartAngle);

        // Tło knob
        g.setColour(juce::Colour(0xff334155));
        g.fillEllipse(centreX - radius, centreY - radius, radius * 2, radius * 2);

        // Łuk wskazujący wartość
        juce::Path arc;
        arc.addCentredArc(centreX, centreY, radius - 4, radius - 4, 0,
                          rotaryStartAngle, angle, true);
        g.setColour(juce::Colour(0xffec4899));
        g.strokePath(arc, juce::PathStrokeType(4.0f, juce::PathStrokeType::curved,
                                                juce::PathStrokeType::rounded));

        // Wskaźnik
        juce::Path pointer;
        pointer.addRectangle(-2, -radius + 4, 4, radius * 0.5f);
        pointer.applyTransform(juce::AffineTransform::rotation(angle).translated(centreX, centreY));
        g.setColour(juce::Colour(0xfff472b6));
        g.fillPath(pointer);
    }
};
```

Aplikujesz w editorze:

```cpp
// W AudioProcessorEditor konstruktor:
setLookAndFeel(&customLookAndFeel);

// W destruktorze (KRYTYCZNE):
~MyEditor() override { setLookAndFeel(nullptr); }
```

Jeśli zapomnisz `setLookAndFeel(nullptr)` — crashy przy zamykaniu pluginu (dangling pointer).

## OpenGL acceleration

Dla skomplikowanych UI (oscylloskop, spectrogram, animacje) — software rendering CPU może wyciągać 5-10% CPU. OpenGL przenosi to na GPU (~0.5-1% CPU).

```cpp
class MyEditor : public juce::AudioProcessorEditor
{
public:
    MyEditor(MyProcessor& p) : AudioProcessorEditor(&p)
    {
        // Zaczepia OpenGL context do okna
        openGLContext.attachTo(*getTopLevelComponent());
        openGLContext.setContinuousRepainting(false);  // tylko gdy potrzeba
    }

    ~MyEditor() override
    {
        openGLContext.detach();
    }

private:
    juce::OpenGLContext openGLContext;
};
```

**Uwagi:**
- Na macOS OpenGL jest **deprecated** (Apple chce Metal). JUCE 7+ ma backend Metal też, ale OpenGL nadal działa.
- Niektóre stare DAW (np. Pro Tools w pre-2022 wersjach) krzaczą się z OpenGL — testuj.
- Włączaj OpenGL **tylko jeśli faktycznie potrzeba** (skomplikowana wizualizacja, animacje 60fps). Dla statycznych GUI — szkoda zachodu.

## Komponenty UI — rotary knob, slider, button, combo box

JUCE ma komplet standardowych:

```cpp
// Rotary knob
juce::Slider gainKnob;
gainKnob.setSliderStyle(juce::Slider::RotaryHorizontalVerticalDrag);
gainKnob.setRange(-60.0, 12.0, 0.1);
gainKnob.setValue(0.0);
gainKnob.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
gainKnob.setTextValueSuffix(" dB");
addAndMakeVisible(gainKnob);

// Linear slider (vertical)
juce::Slider volumeSlider;
volumeSlider.setSliderStyle(juce::Slider::LinearVertical);
volumeSlider.setRange(0.0, 1.0);
addAndMakeVisible(volumeSlider);

// Toggle button (on/off)
juce::ToggleButton bypassButton;
bypassButton.setButtonText("Bypass");
bypassButton.onClick = [this]() {
    bool isOn = bypassButton.getToggleState();
    // ...
};
addAndMakeVisible(bypassButton);

// Combo box (dropdown)
juce::ComboBox modeBox;
modeBox.addItem("Soft", 1);
modeBox.addItem("Medium", 2);
modeBox.addItem("Hard", 3);
modeBox.setSelectedId(1);
modeBox.onChange = [this]() {
    int selected = modeBox.getSelectedId();
    // ...
};
addAndMakeVisible(modeBox);

// Text input
juce::TextEditor nameInput;
nameInput.setMultiLine(false);
nameInput.setText("Preset 1");
addAndMakeVisible(nameInput);
```

## Attachments — łączenie z parametrami APVTS

`AudioProcessorValueTreeState::Attachment` automatycznie synchronizuje GUI z parametrami:

```cpp
class MyEditor : public juce::AudioProcessorEditor
{
private:
    juce::Slider gainSlider;
    juce::ToggleButton bypassButton;
    juce::ComboBox modeBox;

    using SliderAttachment = juce::AudioProcessorValueTreeState::SliderAttachment;
    using ButtonAttachment = juce::AudioProcessorValueTreeState::ButtonAttachment;
    using ComboBoxAttachment = juce::AudioProcessorValueTreeState::ComboBoxAttachment;

    std::unique_ptr<SliderAttachment> gainAttachment;
    std::unique_ptr<ButtonAttachment> bypassAttachment;
    std::unique_ptr<ComboBoxAttachment> modeAttachment;

public:
    MyEditor(MyProcessor& p) : AudioProcessorEditor(&p)
    {
        addAndMakeVisible(gainSlider);
        addAndMakeVisible(bypassButton);
        addAndMakeVisible(modeBox);
        modeBox.addItem("Soft", 1);
        modeBox.addItem("Hard", 2);

        gainAttachment = std::make_unique<SliderAttachment>(p.parameters, "gain", gainSlider);
        bypassAttachment = std::make_unique<ButtonAttachment>(p.parameters, "bypass", bypassButton);
        modeAttachment = std::make_unique<ComboBoxAttachment>(p.parameters, "mode", modeBox);
    }
};
```

To wszystko — host automation, undo/redo, save/load presets — wszystko działa "za darmo".

## Custom rotary knob — pełny przykład

```cpp
class CustomRotaryKnob : public juce::Slider
{
public:
    CustomRotaryKnob()
    {
        setSliderStyle(juce::Slider::RotaryHorizontalVerticalDrag);
        setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
        setColour(juce::Slider::textBoxOutlineColourId, juce::Colour(0));
    }

    void paint(juce::Graphics& g) override
    {
        auto bounds = getLocalBounds().reduced(8);
        auto knobArea = bounds.removeFromTop(bounds.getHeight() - 24).toFloat();
        auto centre = knobArea.getCentre();
        auto radius = juce::jmin(knobArea.getWidth(), knobArea.getHeight()) * 0.5f - 4.0f;

        // Wartość 0..1
        const float value = (float)valueToProportionOfLength(getValue());
        const float startAngle = juce::MathConstants<float>::pi * 1.25f;   // 225°
        const float endAngle   = juce::MathConstants<float>::pi * 2.75f;   // 495° (135°+360°)
        const float angle = startAngle + value * (endAngle - startAngle);

        // Tło knob (ciemny okrąg)
        g.setColour(juce::Colour(0xff1e293b));
        g.fillEllipse(centre.x - radius, centre.y - radius, radius * 2, radius * 2);

        // Outline
        g.setColour(juce::Colour(0xff334155));
        g.drawEllipse(centre.x - radius, centre.y - radius, radius * 2, radius * 2, 2.0f);

        // Łuk wskazujący wartość (gradient pink-purple)
        juce::Path arc;
        arc.addCentredArc(centre.x, centre.y, radius - 6, radius - 6, 0,
                          startAngle, angle, true);
        juce::ColourGradient grad(
            juce::Colour(0xffec4899), centre.x - radius, centre.y,
            juce::Colour(0xffa78bfa), centre.x + radius, centre.y, false);
        g.setGradientFill(grad);
        g.strokePath(arc, juce::PathStrokeType(4.0f,
            juce::PathStrokeType::curved, juce::PathStrokeType::rounded));

        // Wskaźnik (kreska)
        juce::Path pointer;
        pointer.startNewSubPath(centre.x, centre.y - radius * 0.4f);
        pointer.lineTo(centre.x, centre.y - radius * 0.85f);
        pointer.applyTransform(juce::AffineTransform::rotation(
            angle - juce::MathConstants<float>::halfPi, centre.x, centre.y));
        g.setColour(juce::Colour(0xfff472b6));
        g.strokePath(pointer, juce::PathStrokeType(3.0f, juce::PathStrokeType::curved,
                                                    juce::PathStrokeType::rounded));
    }

    void mouseDoubleClick(const juce::MouseEvent&) override
    {
        // Double-click = reset do default
        setValue(getDoubleClickReturnValue());
    }
};
```

## Level meter — animowany VU

```cpp
class LevelMeter : public juce::Component, private juce::Timer
{
public:
    LevelMeter() { startTimerHz(30); }   // 30 FPS update

    void setLevel(float newLevel) noexcept
    {
        // Zewnętrzny processor wywołuje to z processBlock (atomic store)
        targetLevel.store(newLevel);
    }

    void paint(juce::Graphics& g) override
    {
        auto bounds = getLocalBounds().toFloat();
        const float lvl = currentLevel;   // już smoothed

        // Tło
        g.setColour(juce::Colour(0xff0d1117));
        g.fillRoundedRectangle(bounds, 4.0f);

        // Słupek (gradient: zielony -> żółty -> czerwony)
        auto fillHeight = bounds.getHeight() * juce::jlimit(0.0f, 1.0f, lvl);
        auto fillBounds = bounds.removeFromBottom(fillHeight);
        
        juce::ColourGradient grad(
            juce::Colour(0xffef4444), 0, bounds.getY(),                // czerwony góra
            juce::Colour(0xff4ade80), 0, bounds.getBottom(), false);    // zielony dół
        grad.addColour(0.7, juce::Colour(0xfff59e0b));                  // żółty środek
        g.setGradientFill(grad);
        g.fillRoundedRectangle(fillBounds, 4.0f);

        // Peak hold (kreska na top)
        if (peakLevel > 0.01f)
        {
            float peakY = bounds.getBottom() - bounds.getHeight() * peakLevel;
            g.setColour(juce::Colours::white);
            g.fillRect(0.0f, peakY - 1.0f, bounds.getWidth(), 2.0f);
        }
    }

private:
    void timerCallback() override
    {
        // Smoothing — eksponencjalny decay
        const float target = targetLevel.load();
        currentLevel = currentLevel * 0.7f + target * 0.3f;

        // Peak hold (slow decay)
        if (target > peakLevel)
            peakLevel = target;
        else
            peakLevel *= 0.99f;

        repaint();
    }

    std::atomic<float> targetLevel { 0.0f };
    float currentLevel { 0.0f };
    float peakLevel { 0.0f };
};
```

W processorze:

```cpp
// W processBlock, na końcu:
const float rms = buffer.getRMSLevel(0, 0, buffer.getNumSamples());
levelForGUI.store(rms);   // MyProcessor ma std::atomic<float> levelForGUI
```

W editorze (z timer):

```cpp
void timerCallback() override
{
    leftMeter.setLevel(processorRef.levelForGUI.load());
    repaint();
}
```

## Animacja i timery

Każdy `Component` może być `Timer`. `startTimerHz(30)` = 30 callbacks/sec.

```cpp
class MyAnimatedComp : public juce::Component, private juce::Timer
{
public:
    MyAnimatedComp() { startTimerHz(60); }

    void timerCallback() override
    {
        phase += 0.01f;
        if (phase > juce::MathConstants<float>::twoPi)
            phase = 0;
        repaint();
    }

    void paint(juce::Graphics& g) override
    {
        const float radius = 30 + 10 * std::sin(phase);
        g.fillEllipse(getWidth()/2 - radius, getHeight()/2 - radius,
                      radius*2, radius*2);
    }

private:
    float phase = 0.0f;
};
```

**Performance tip:** nie ustawiaj 120 Hz timer dla każdego komponentu. Jeden timer w editorze, repaint() tylko widoczne komponenty.

## Drawing waveforms, spectrums, EQ curves

### Waveform (z bufora audio)

```cpp
class WaveformDisplay : public juce::Component, private juce::Timer
{
public:
    WaveformDisplay() { startTimerHz(30); }

    void pushSample(float sample) noexcept
    {
        buffer[writeIndex] = sample;
        writeIndex = (writeIndex + 1) % bufferSize;
    }

    void paint(juce::Graphics& g) override
    {
        g.setColour(juce::Colour(0xff0d1117));
        g.fillAll();

        g.setColour(juce::Colour(0xffec4899));
        juce::Path waveform;
        const float midY = getHeight() * 0.5f;
        const float scaleY = midY * 0.95f;

        waveform.startNewSubPath(0, midY);
        for (int x = 0; x < getWidth(); ++x)
        {
            int idx = (writeIndex + x * bufferSize / getWidth()) % bufferSize;
            float y = midY - buffer[idx] * scaleY;
            waveform.lineTo((float)x, y);
        }
        g.strokePath(waveform, juce::PathStrokeType(1.5f));
    }

private:
    void timerCallback() override { repaint(); }

    static constexpr int bufferSize = 512;
    std::array<float, bufferSize> buffer { };
    int writeIndex = 0;
};
```

### EQ curve

Dla EQ pluginu — rysuj response filtru:

```cpp
void paintEQCurve(juce::Graphics& g)
{
    auto bounds = getLocalBounds().toFloat();
    juce::Path curve;

    const int numPoints = (int)bounds.getWidth();
    for (int i = 0; i < numPoints; ++i)
    {
        // Frekwencja log-skala 20 Hz - 20 kHz
        float freq = 20.0f * std::pow(1000.0f, (float)i / numPoints);

        // Magnitude z filtru
        float magDb = filter.getMagnitudeForFrequency(freq, sampleRate);
        magDb = juce::jlimit(-24.0f, 24.0f, juce::Decibels::gainToDecibels(magDb));

        float y = juce::jmap(magDb, -24.0f, 24.0f, bounds.getHeight(), 0.0f);

        if (i == 0) curve.startNewSubPath((float)i, y);
        else curve.lineTo((float)i, y);
    }

    g.setColour(juce::Colour(0xffec4899));
    g.strokePath(curve, juce::PathStrokeType(2.0f));
}
```

## Custom slider behavior

```cpp
// Drag w trybie fine-tune (Shift = 10x precyzyjniej)
class FineSlider : public juce::Slider
{
public:
    void mouseDrag(const juce::MouseEvent& e) override
    {
        if (e.mods.isShiftDown())
        {
            // Skopiowane zachowanie ale z 10x mniejszą czułością
            auto modified = e.withNewPosition(
                e.getPosition() / 10 + e.getMouseDownPosition() * 9 / 10);
            juce::Slider::mouseDrag(modified);
        }
        else
            juce::Slider::mouseDrag(e);
    }

    void mouseDoubleClick(const juce::MouseEvent&) override
    {
        setValue(getDoubleClickReturnValue());
    }
};
```

## MIDI Learn implementation

```cpp
class MidiLearnSlider : public juce::Slider, public juce::MidiInputCallback
{
public:
    void startLearning() { learning = true; }

    void handleIncomingMidiMessage(juce::MidiInput*, const juce::MidiMessage& msg) override
    {
        if (!learning || !msg.isController())
            return;

        learnedCC = msg.getControllerNumber();
        learnedChannel = msg.getChannel();
        learning = false;
    }

    // W timerCallback() albo na MIDI received w processorze:
    void mapMidiCC(int cc, int channel, float value)
    {
        if (cc == learnedCC && channel == learnedChannel)
        {
            const float min = (float)getMinimum();
            const float max = (float)getMaximum();
            setValue(min + value * (max - min));
        }
    }

private:
    bool learning = false;
    int learnedCC = -1;
    int learnedChannel = -1;
};
```

W processorze: w `processBlock` iterujesz `MidiBuffer` i wywołujesz mapping na każdym slider który ma uczony CC.

## Trendy UI 2026

| Trend | Opis | Przykłady producentów |
|-------|------|------------------------|
| **Flat / Modern dark** | Ciemne tło, akcenty kolorystyczne, bez 3D | FabFilter, Soundtoys |
| **Skeuomorphic premium** | Realistyczne pokrętła, lampy, igły VU | Waves, IK Multimedia, Universal Audio |
| **Neumorphism (lekko)** | Soft shadows, embossed elements | Niektóre nowe boutique |
| **Brutalist** | Duże fonty, kontrast, geometrycznie | u-he Diva, Bitwig |
| **Bento layouts** | Sekcje pogrupowane w bloki | iZotope Ozone 11, FL Studio |

**Trend wiodący 2026:** dark mode by default, akcent kolorystyczny per kategoria pluginu (EQ = niebieski, comp = pomarańczowy, reverb = fiolet), dużo whitespace, czyste typo.

## Performance — nie repainta za dużo

```cpp
// ZŁE: 60 FPS repaint całego okna nawet gdy nic się nie dzieje
startTimerHz(60);
void timerCallback() { repaint(); }

// LEPIEJ: repaint tylko zmienionego komponentu
levelMeter.repaint();   // tylko meter, nie całe okno

// JESZCZE LEPIEJ: tylko gdy faktycznie wartość się zmieniła
void timerCallback()
{
    auto newLevel = processor.getLevel();
    if (std::abs(newLevel - lastLevel) > 0.001f)
    {
        levelMeter.setLevel(newLevel);
        lastLevel = newLevel;
    }
}
```

**Reguła:** GUI w pluginie powinno zużywać < 1% CPU. Jeśli jesteś > 5% — coś źle.

## Web-based GUI alternative — Choc + WebView

Niektórzy nowocześni developerzy idą **alternatywną drogą** — GUI w HTML/CSS/JS. Plugin ładuje WebView i komunikuje się z DSP przez bridge.

**Plusy:**
- Designerzy znają HTML/CSS lepiej niż JUCE Graphics
- React, Vue, web components do reużytku
- Łatwa zmiana stylowania (CSS!)

**Minusy:**
- Większy plugin (Chromium ~150 MB)
- Wolniejsze (web stack overhead)
- Bridge native↔web ma latencje

**Choc** (Cmajor company, juce-compatible) i **JUCE WebView** w wersji 8.0+ to opcje. Niektóre nowe pluginy (Output, Cradle, Splice własne) tak działają.

## BinaryData — wbudowane assety

JUCE ma narzędzie **BinaryBuilder** (z Projucer albo `juce_add_binary_data`) które pakuje obrazki/SVG/fonty do executable jako binary blobs.

```cmake
juce_add_binary_data(MyPluginAssets
    SOURCES
        Resources/logo.svg
        Resources/background.png
        Resources/Inter-Bold.ttf
)

target_link_libraries(MyPlugin PRIVATE MyPluginAssets)
```

W kodzie:

```cpp
auto logoSvg = juce::Drawable::createFromImageData(
    BinaryData::logo_svg, BinaryData::logo_svgSize);

auto interFont = juce::Typeface::createSystemTypefaceFor(
    BinaryData::InterBold_ttf, BinaryData::InterBold_ttfSize);
g.setFont(juce::Font(juce::FontOptions(interFont).withHeight(16.0f)));
```

## Co dalej

Mając kompetencje GUI — slidery, knoby, level metery, custom LookAndFeel, animacje — możesz zbudować profesjonalnie wyglądający plugin. Następne kroki:

- **Zaawansowane DSP** (rozdział 8) — convolution reverb, FFT, oversampling, multi-band
- **Dystrybucja i instalator** (rozdział 9) — Inno Setup, Packages, anti-piracy
- **Marketing** (rozdział 10) — Plugin Boutique, KVR, własna strona

**Ważne źródła GUI inspiracji:**
- `juce.com/learn/tutorials` (sekcja Graphics)
- Dribbble.com — "audio plugin UI"
- Studia komercyjnych pluginów (FabFilter, Soundtoys, Output) — ale nie kopiuj 1:1
- Reddit `/r/AudioPluginDev` — community feedback na GUI design
