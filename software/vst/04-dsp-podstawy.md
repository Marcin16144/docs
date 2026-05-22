# DSP — podstawy programowania audio

## Czym jest DSP?

**DSP** = Digital Signal Processing — przetwarzanie sygnałów w postaci cyfrowej. W kontekście pluginów VST oznacza to **manipulację próbkami audio** (zwykle 32-bit float lub 64-bit double) wewnątrz funkcji `processBlock`.

```
Audio = ciąg próbek liczbowych w czasie

Próbka  -1.0  -0.5  0.0  +0.5  +1.0
   |     ─    ─    ─    ─    ─
   t →
   sample[0]=0.2, sample[1]=0.7, sample[2]=0.5, ...
```

**Próbka (sample)** to jedna liczba reprezentująca chwilowe ciśnienie akustyczne w danym punkcie czasu. W formacie float zwykle zakres `-1.0..+1.0`. Wartości poza tym zakresem to **clipping** (audio overload).

## Sample rate, buffer size, latencja

### Sample rate (częstotliwość próbkowania)

Liczba próbek na sekundę. Standardowe wartości:

| Sample rate | Zastosowanie |
|-------------|--------------|
| 22050 Hz | Stare podcasty, niska jakość |
| 44100 Hz | CD, większość muzyki streaming |
| 48000 Hz | Video, broadcasting, modern DAW default |
| 88200 Hz | Mastering audio |
| 96000 Hz | High-resolution audio, mastering |
| 176400 Hz | Niche, mastering |
| 192000 Hz | Top-tier mastering, archiwizacja |

**Twierdzenie Nyquista:** możesz reprezentować bezstratnie sygnał o częstotliwości max **sample_rate / 2**. Przy 48 kHz → 24 kHz max (powyżej tego wszystko aliasing-uje).

### Buffer size

Liczba próbek przekazywanych do pluginu w jednym wywołaniu `processBlock`. Plugin nie wie, kiedy przyjdzie kolejne wywołanie — przetwarza paczkami.

| Buffer size | Latencja @ 48 kHz | Use case |
|-------------|-------------------|----------|
| 32 | 0.67 ms | Live performance, niska latencja |
| 64 | 1.33 ms | Live performance |
| 128 | 2.67 ms | Tracking (nagrywanie) |
| 256 | 5.33 ms | Mixing |
| 512 | 10.67 ms | Mastering, mocniejsze wtyczki |
| 1024 | 21.33 ms | Background rendering |
| 2048 | 42.67 ms | Offline render |

```
Latencja = buffer_size / sample_rate

256 / 48000 = 0.00533 s = 5.33 ms
```

**Mniejszy buffer → niższa latencja, więcej CPU overhead.**

### Real-time constraint

W audio thread (wywołującym `processBlock`) czas przetworzenia bufora **musi być krótszy niż czas trwania bufora**. Jeśli plugin "spóźnia się" — DAW wyśle ciszę lub powtórzy poprzedni bufor → **dropout (audible click)**.

```
processBlock musi trwać:
  buffer_size = 256 @ 48000 Hz → masz 5.33 ms na przetworzenie 256 próbek
  
Realnie: zostawiasz margines bezpieczeństwa, np. zużywając < 50% CPU,
inaczej każdy peak load → glitch.
```

## Real-time constraints — nieprzekraczalne reguły

W audio thread **NIE WOLNO**:

```cpp
void processBlock(AudioBuffer<float>& buf, MidiBuffer& midi) {
    // ❌ ZAKAZANE — alokacja heap
    std::vector<float> tmp(buf.getNumSamples());
    auto* p = new float[1024];
    delete[] p;
    
    // ❌ ZAKAZANE — locks (priority inversion)
    std::lock_guard<std::mutex> lk(mutex);
    
    // ❌ ZAKAZANE — I/O
    std::ofstream("debug.log") << "test\n";
    printf("processing\n");
    
    // ❌ ZAKAZANE — system calls o nieprzewidywalnym czasie
    std::this_thread::sleep_for(...);
    
    // ❌ ZAKAZANE — wyjątki
    throw std::runtime_error("oops");
    
    // ❌ ZAKAZANE — dynamic dispatch z wirtualnymi tabelami
    // (drobny narzut, ale w hot loop dodaje się)
}
```

W audio thread **MOŻNA**:

```cpp
void processBlock(...) {
    // ✅ Arytmetyka
    sample = sample * gain + offset;
    
    // ✅ Atomic load/store (lock-free)
    float currentGain = gainAtomic.load(std::memory_order_relaxed);
    
    // ✅ Operacje na pre-alokowanej pamięci
    preAllocatedBuffer[i] = ...;
    
    // ✅ Lookup tables
    float val = sineTable[index];
    
    // ✅ Branchless math
    float out = (input > 0) ? input : -input;
}
```

**Reguła:** wszystko alokuj w `prepareToPlay`, w `processBlock` tylko przelicz.

## Filtry — fundament DSP

Filtry to **obwody przepuszczające/blokujące** wybrane częstotliwości. Cztery podstawowe rodzaje:

```
        Magnitude
          |
       1 -|━━━━━━━━━╲
          |          ╲
       0 -|           ╲___________
          +─────|────────────────→ Frequency
                fc (cutoff)
                       
          Lowpass: przepuszcza < fc, tłumi > fc

       1 -|        ___________╱━━━━━
          |       ╱
       0 -|━━━━━━╱
          +─────|────────────────→ Frequency
                fc
                       
          Highpass: przepuszcza > fc, tłumi < fc

       1 -|       ╱─╲
          |      ╱   ╲
       0 -|_____╱     ╲______
          +────|─|─|──────────→ Frequency
              f1 fc f2
                       
          Bandpass: przepuszcza pasmo wokół fc

       1 -|━━━━╲   ╱━━━━━
          |     ╲ ╱
       0 -|      ╳
          +─────|────────────→ Frequency
                fc
                       
          Notch: blokuje wąskie pasmo wokół fc
```

### IIR vs FIR

| Cecha | IIR (Infinite Impulse Response) | FIR (Finite Impulse Response) |
|-------|----------------------------------|-------------------------------|
| Charakter | Rekursywny (sprzężenie zwrotne) | Splotowy (tylko wejście) |
| Stabilność | Może być niestabilny | Zawsze stabilny |
| Latencja | Bardzo niska (1-2 próbki) | Linearna z długością |
| CPU | Tani | Drogi (długi splot) |
| Phase | Nieliniowy | Liniowy (możliwy) |
| Zastosowanie | EQ, sub kompresor, korekcja | Linear-phase EQ, FIR convolution |

**Większość pluginów używa IIR** dla efektów real-time (EQ, filtry analogowe). FIR dla linear-phase EQ i convolution reverb.

### Biquad — Roboczy filtr IIR

**Biquad** (bi-quadratic) to filtr drugiego rzędu — najbardziej uniwersalny IIR. Każdy parametryczny EQ to seria biquadów.

```
Transfer function:
       b0 + b1*z⁻¹ + b2*z⁻²
H(z) = ─────────────────────
       a0 + a1*z⁻¹ + a2*z⁻²

Difference equation (Direct Form II Transposed):
y[n] = (b0/a0)*x[n] + s1
s1 = (b1/a0)*x[n] - (a1/a0)*y[n] + s2
s2 = (b2/a0)*x[n] - (a2/a0)*y[n]
```

### Implementacja biquad w C++

```cpp
class Biquad {
public:
    // Direct Form II Transposed - numerycznie stabilny
    float processSample(float in) noexcept {
        float out = b0 * in + s1;
        s1 = b1 * in - a1 * out + s2;
        s2 = b2 * in - a2 * out;
        return out;
    }
    
    // RBJ Audio EQ Cookbook formulas
    void setLowpass(float sampleRate, float cutoffHz, float q) {
        const float w0 = 2.0f * M_PI * cutoffHz / sampleRate;
        const float cosw = std::cos(w0);
        const float sinw = std::sin(w0);
        const float alpha = sinw / (2.0f * q);
        
        const float a0_ = 1.0f + alpha;
        b0 = ((1.0f - cosw) * 0.5f) / a0_;
        b1 = (1.0f - cosw) / a0_;
        b2 = ((1.0f - cosw) * 0.5f) / a0_;
        a1 = (-2.0f * cosw) / a0_;
        a2 = (1.0f - alpha) / a0_;
    }
    
    void setHighpass(float sampleRate, float cutoffHz, float q) {
        const float w0 = 2.0f * M_PI * cutoffHz / sampleRate;
        const float cosw = std::cos(w0);
        const float sinw = std::sin(w0);
        const float alpha = sinw / (2.0f * q);
        
        const float a0_ = 1.0f + alpha;
        b0 = ((1.0f + cosw) * 0.5f) / a0_;
        b1 = -(1.0f + cosw) / a0_;
        b2 = ((1.0f + cosw) * 0.5f) / a0_;
        a1 = (-2.0f * cosw) / a0_;
        a2 = (1.0f - alpha) / a0_;
    }
    
    void setBandpass(float sampleRate, float cutoffHz, float q) {
        const float w0 = 2.0f * M_PI * cutoffHz / sampleRate;
        const float cosw = std::cos(w0);
        const float sinw = std::sin(w0);
        const float alpha = sinw / (2.0f * q);
        
        const float a0_ = 1.0f + alpha;
        b0 = alpha / a0_;
        b1 = 0.0f;
        b2 = -alpha / a0_;
        a1 = (-2.0f * cosw) / a0_;
        a2 = (1.0f - alpha) / a0_;
    }
    
    void reset() noexcept { s1 = s2 = 0.0f; }
    
private:
    float b0{1.0f}, b1{0.0f}, b2{0.0f};
    float a1{0.0f}, a2{0.0f};
    float s1{0.0f}, s2{0.0f};  // state variables
};

// Użycie:
Biquad lpf;
lpf.setLowpass(48000.0f, 1000.0f, 0.707f);  // 1 kHz cutoff, Q=0.707 (Butterworth)

void processBlock(AudioBuffer<float>& buf, MidiBuffer&) {
    auto* data = buf.getWritePointer(0);
    for (int i = 0; i < buf.getNumSamples(); ++i)
        data[i] = lpf.processSample(data[i]);
}
```

**Q (factor)** — rezonans / "spiczastość" filtra przy cutoff:
- `Q = 0.707` = Butterworth (gładki, no resonance)
- `Q = 1.0..2.0` = mild resonance
- `Q > 5.0` = mocny rezonans (synth-style)

## Oscylatory — generatory sygnału

Oscillator generuje cykliczną falę. Cztery podstawowe kształty:

### Sine (sinusoida)

```cpp
class SineOsc {
public:
    void setFrequency(float freqHz, float sampleRate) {
        phaseInc = 2.0f * M_PI * freqHz / sampleRate;
    }
    
    float processSample() noexcept {
        float out = std::sin(phase);
        phase += phaseInc;
        if (phase >= 2.0f * M_PI) phase -= 2.0f * M_PI;
        return out;
    }
private:
    float phase{0.0f};
    float phaseInc{0.0f};
};
```

**`std::sin` jest wolny.** Lookup table często szybsza:

```cpp
constexpr int TABLE_SIZE = 4096;
static const std::array<float, TABLE_SIZE> sineTable = []{
    std::array<float, TABLE_SIZE> t{};
    for (int i = 0; i < TABLE_SIZE; ++i)
        t[i] = std::sin(2.0f * M_PI * i / TABLE_SIZE);
    return t;
}();

float lookupSine(float phase01) {  // phase01 = 0..1
    const float idx = phase01 * TABLE_SIZE;
    const int i0 = static_cast<int>(idx) & (TABLE_SIZE - 1);
    const int i1 = (i0 + 1) & (TABLE_SIZE - 1);
    const float frac = idx - std::floor(idx);
    return sineTable[i0] * (1.0f - frac) + sineTable[i1] * frac;
}
```

### Saw, Square, Triangle — naive

```cpp
// Naive saw (-1..+1, ramping up)
float naiveSaw(float phase01) {
    return 2.0f * phase01 - 1.0f;
}

// Naive square (-1 lub +1)
float naiveSquare(float phase01) {
    return phase01 < 0.5f ? 1.0f : -1.0f;
}

// Naive triangle
float naiveTriangle(float phase01) {
    return phase01 < 0.5f
        ? 4.0f * phase01 - 1.0f
        : 3.0f - 4.0f * phase01;
}
```

**Problem:** naive waveforms aliasują (ostre krawędzie generują częstotliwości > Nyquista, które "zawijają się" do słyszalnego pasma).

### BLEP / BLAMP — anti-aliasing

**BLEP** (Band-Limited stEP) i **BLAMP** to techniki dodawania korekcji wokół nieciągłości w sygnale, eliminujące aliasing.

```cpp
// Polynomial BLEP correction (Välimäki, Huovilainen)
inline float polyBlep(float t, float dt) {
    if (t < dt) {
        const float x = t / dt;
        return x + x - x * x - 1.0f;
    } else if (t > 1.0f - dt) {
        const float x = (t - 1.0f) / dt;
        return x * x + x + x + 1.0f;
    }
    return 0.0f;
}

class BlepSawOsc {
    float phase{0.0f};
    float phaseInc{0.0f};
public:
    void setFrequency(float freqHz, float sr) {
        phaseInc = freqHz / sr;  // 0..1 per sample
    }
    
    float processSample() noexcept {
        float out = 2.0f * phase - 1.0f;          // naive saw
        out -= polyBlep(phase, phaseInc);          // correction
        phase += phaseInc;
        if (phase >= 1.0f) phase -= 1.0f;
        return out;
    }
};
```

**BLAMP** to całka z BLEP — używa się do triangle oscillator (ciągły, ale ma nieciągłość pochodnej).

## Wavetable synthesis

**Wavetable** = tablica gotowych fal (np. 2048 próbek). Oscylator iteruje po tablicy z dowolnym krokiem (= zmienia częstotliwość).

```cpp
class WavetableOsc {
public:
    void setWavetable(const std::vector<float>& table) {
        wavetable = table;  // CAUTION: kopiuj w prepareToPlay, nie w processBlock!
    }
    
    void setFrequency(float freqHz, float sr) {
        phaseInc = freqHz * wavetable.size() / sr;
    }
    
    float processSample() noexcept {
        const int i0 = static_cast<int>(phase) % wavetable.size();
        const int i1 = (i0 + 1) % wavetable.size();
        const float frac = phase - std::floor(phase);
        const float out = wavetable[i0] * (1.0f - frac) + wavetable[i1] * frac;
        
        phase += phaseInc;
        while (phase >= wavetable.size()) phase -= wavetable.size();
        return out;
    }
private:
    std::vector<float> wavetable;
    float phase{0.0f};
    float phaseInc{0.0f};
};
```

**Mip-mapped wavetables** — multiple wavetables w różnych "rozdzielczościach" dla różnych zakresów pitchu — eliminuje aliasing dla wysokich tonów. Używają tego: Serum, Vital, Massive X.

## FFT — analiza częstotliwościowa

**FFT** = Fast Fourier Transform. Rozkłada sygnał czasowy na **częstotliwości**.

```
Sygnał czasowy           Spektrum częstotliwości
(amplituda vs czas)  →   (amplituda vs Hz)

Time domain              Frequency domain
   ↓                        ↓
buf[N]                   bins[N/2+1]  (complex numbers)
                         każdy bin = magnitude + phase
```

### Kiedy używać FFT?

- **Spectrum analyzer** (wizualizacja FFT realtime)
- **Spectral processing** (vocoder, pitch shifter, denoiser)
- **Convolution** (FFT-based — szybsze dla długich impulse responses)
- **Frequency-domain effects** (Paulstretch, smudge, freeze)

### FFT w JUCE

```cpp
constexpr int fftOrder = 11;            // 2^11 = 2048
constexpr int fftSize = 1 << fftOrder;

juce::dsp::FFT fft{fftOrder};
std::array<float, 2 * fftSize> fftData{};

void analyseSpectrum(const float* timeData) {
    // Skopiuj dane
    std::copy(timeData, timeData + fftSize, fftData.begin());
    std::fill(fftData.begin() + fftSize, fftData.end(), 0.0f);
    
    // Forward FFT (real → complex)
    fft.performRealOnlyForwardTransform(fftData.data());
    
    // fftData zawiera teraz pary (real, imag) per bin
    for (int bin = 0; bin < fftSize / 2; ++bin) {
        const float re = fftData[2 * bin];
        const float im = fftData[2 * bin + 1];
        const float magnitude = std::sqrt(re * re + im * im);
        const float phase = std::atan2(im, re);
        // ... użyj magnitude / phase
    }
}
```

**Trade-offs FFT:**
- Mała ramka (256) → szybka odpowiedź czasowa, słaba rozdzielczość częstotliwości
- Duża ramka (4096) → dobra rozdzielczość Hz, słaba odpowiedź czasowa
- **Compromise:** 1024-2048 typowo dla effects

## Convolution — splot

**Convolution** = splot dwóch sygnałów. W audio: dźwięk × impulse response (IR) = dźwięk z charakterystyką tej IR.

```
input × IR(reverb sali) = ten sam dźwięk grany w sali
```

### Direct convolution (slow):

```cpp
// y[n] = sum_{k=0}^{N-1} x[n-k] * h[k]
void convolve(const std::vector<float>& input,
              const std::vector<float>& impulseResponse,
              std::vector<float>& output) {
    const int N = impulseResponse.size();
    for (int n = 0; n < input.size(); ++n) {
        float sum = 0.0f;
        for (int k = 0; k < N; ++k) {
            if (n - k >= 0)
                sum += input[n - k] * impulseResponse[k];
        }
        output[n] = sum;
    }
}
```

**Złożoność:** O(N×M). Dla IR 96000 sampli × buffer 256 = 24,576,000 operacji per buffer = **niedopuszczalne** w realtime.

### FFT-based convolution

Używając twierdzenia o splocie: splot w czasie = mnożenie w częstotliwości.

```
1. FFT(input) → X
2. FFT(IR) → H (raz, w prepareToPlay)
3. Y = X * H (element-wise)
4. iFFT(Y) → output
```

**Złożoność:** O(N log N). Realtime możliwe nawet dla minutowych IR.

### Partitioned convolution

Dla bardzo długich IR (cathedral reverb, 10+ sekund) — dzielisz IR na kawałki, processując każdy z opóźnieniem. **Zero-latency partitioned convolution** — znana m.in. z Altiverb, Waves IR-1.

JUCE oferuje `juce::dsp::Convolution`:

```cpp
juce::dsp::Convolution conv;

void prepareToPlay(double sr, int blockSize) {
    juce::dsp::ProcessSpec spec{sr, (uint32_t)blockSize, 2};
    conv.prepare(spec);
    conv.loadImpulseResponse(impulseFile,
                              juce::dsp::Convolution::Stereo::yes,
                              juce::dsp::Convolution::Trim::yes,
                              0);
}

void processBlock(AudioBuffer<float>& buf, MidiBuffer&) {
    juce::dsp::AudioBlock<float> block(buf);
    juce::dsp::ProcessContextReplacing<float> ctx(block);
    conv.process(ctx);
}
```

## Denormale — cichy zabójca CPU

**Denormale** (a.k.a. subnormals) to bardzo małe liczby zmiennoprzecinkowe (~10⁻³⁸..10⁻⁴⁵). Niektóre filtry IIR mają coraz mniejsze stany — w końcu wpadają w denormalny zakres.

**Problem:** procesor x86 obsługuje denormale przez **mikrokod** (~100x wolniejszy niż normalna arytmetyka). Plugin nagle bierze 50% CPU zamiast 1%.

### Rozwiązanie 1: FTZ + DAZ (CPU flag)

```cpp
#include <pmmintrin.h>     // SSE3
#include <xmmintrin.h>     // SSE

void enableFlushDenormalsToZero() {
    _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);            // FTZ
    _MM_SET_DENORMALS_ZERO_MODE(_MM_DENORMALS_ZERO_ON);    // DAZ
}

// Wywołaj raz na początku processBlock (lub w prepareToPlay)
void processBlock(...) {
    juce::ScopedNoDenormals noDenormals;  // JUCE helper
    // ... reszta
}
```

`juce::ScopedNoDenormals` ustawia flagi na czas scope i przywraca poprzedni stan.

### Rozwiązanie 2: DC injection (oldschool)

```cpp
// Dodaj mikroskopijną stałą do sygnału — zapobiega "zatonięciu" w denormale
constexpr float DC_OFFSET = 1.0e-25f;
sample += DC_OFFSET;
```

W 2026 **FTZ/DAZ jest standardem** — DC injection to legacy hack.

## DC blocking

**DC offset** (stała składowa) w sygnale powoduje:
- Asymetryczne clipping
- Marnowanie headroom
- Pozornie głośniejsze peaks

**DC blocker** = bardzo nisko-pasmowy highpass (~5-20 Hz):

```cpp
class DcBlocker {
    float x1{0.0f}, y1{0.0f};
    static constexpr float R = 0.995f;  // ~5 Hz @ 48 kHz
public:
    float processSample(float in) noexcept {
        const float out = in - x1 + R * y1;
        x1 = in;
        y1 = out;
        return out;
    }
};
```

Często wstawiany **na końcu pluginu** żeby "wyczyścić" wyjście (ważne dla nieliniowych efektów: distortion, saturation, kompresja).

## Smoothing parametrów — anti-zipper

Gdy user kręci pokrętłem szybko, parametr zmienia się skokowo. Bez smoothing → **zipper noise** (chrobotanie):

```cpp
// ❌ Nagle skok
gain = newGain;  // trzask!

// ✅ Smoothed (linear)
class LinearSmoother {
    float current{0.0f}, target{0.0f};
    float step{0.0f};
    int countdown{0};
public:
    void setRamp(float fromValue, float toValue, int numSamples) {
        current = fromValue;
        target = toValue;
        step = (target - current) / numSamples;
        countdown = numSamples;
    }
    
    float getNextValue() noexcept {
        if (countdown > 0) {
            current += step;
            --countdown;
        } else {
            current = target;
        }
        return current;
    }
};

// ✅ Smoothed (exponential, simple one-pole)
class ExpSmoother {
    float current{0.0f}, target{0.0f};
    float coeff{0.99f};
public:
    void setTimeMs(float timeMs, float sampleRate) {
        coeff = std::exp(-1.0f / (sampleRate * timeMs * 0.001f));
    }
    void setTarget(float t) { target = t; }
    float processSample() noexcept {
        current = target + coeff * (current - target);
        return current;
    }
};
```

JUCE ma gotowe `juce::SmoothedValue<float, ValueSmoothingTypes::Linear>` — używaj.

```cpp
juce::SmoothedValue<float> gainSmooth;

void prepareToPlay(double sr, int blockSize) {
    gainSmooth.reset(sr, 0.05);  // 50 ms ramp
    gainSmooth.setCurrentAndTargetValue(0.5f);
}

void processBlock(AudioBuffer<float>& buf, MidiBuffer&) {
    gainSmooth.setTargetValue(gainParam->get());
    for (int i = 0; i < buf.getNumSamples(); ++i) {
        const float g = gainSmooth.getNextValue();
        for (int ch = 0; ch < buf.getNumChannels(); ++ch)
            buf.getWritePointer(ch)[i] *= g;
    }
}
```

## Stereo processing — Mid/Side

**Mid/Side encoding:**
```
mid  = (L + R) / 2     // mono component
side = (L - R) / 2     // stereo component

Decoding:
L = mid + side
R = mid - side
```

Typowe użycia:
- **Stereo width** = side gain
- **Mono compatibility** = ile robisz z mid
- **Mid/Side EQ** — osobne EQ na środek (wokal, bas) i boki (reverb, ambient)
- **Stereo widener** — mocne narzędzie miksowania

```cpp
void processBlockMidSide(AudioBuffer<float>& buf) {
    auto* L = buf.getWritePointer(0);
    auto* R = buf.getWritePointer(1);
    const int N = buf.getNumSamples();
    
    for (int i = 0; i < N; ++i) {
        const float mid = 0.5f * (L[i] + R[i]);
        const float side = 0.5f * (L[i] - R[i]);
        
        // ... process mid i side osobno
        const float wideSide = side * sideGain;
        
        L[i] = mid + wideSide;
        R[i] = mid - wideSide;
    }
}
```

## Oversampling — dla nieliniowych procesów

**Aliasing** w nieliniowych operacjach (saturation, soft clipping, distortion) generuje częstotliwości > Nyquista, które "zawijają się" do słyszalnego pasma → brzydkie artefakty.

**Rozwiązanie:** oversampling. Up-samplujesz × 2/4/8, robisz nieliniowe processing, low-pass filtrujesz, down-samplujesz.

```
Original:        |─────────────|  (48 kHz)
                  ↓ upsample ×4
Oversampled:    |─────────────────────────────|  (192 kHz)
                  ↓ apply nonlinear (distortion)
Distorted:      |═════════════════════════════|  
                  ↓ lowpass filter (anti-aliasing)
                  ↓ downsample ×4
Output:          |─────────────|  (48 kHz, alias-free)
```

JUCE:

```cpp
juce::dsp::Oversampling<float> oversampling{
    2,                        // 2 channels
    2,                        // log2(factor) → 2 = 4x oversampling
    juce::dsp::Oversampling<float>::filterHalfBandPolyphaseIIR,
    true                      // max quality
};

void prepareToPlay(double sr, int blockSize) {
    oversampling.initProcessing(blockSize);
}

void processBlock(AudioBuffer<float>& buf, MidiBuffer&) {
    juce::dsp::AudioBlock<float> block(buf);
    auto upsampledBlock = oversampling.processSamplesUp(block);
    
    // Nieliniowe processing na upsampledBlock
    for (int ch = 0; ch < upsampledBlock.getNumChannels(); ++ch) {
        auto* data = upsampledBlock.getChannelPointer(ch);
        for (size_t i = 0; i < upsampledBlock.getNumSamples(); ++i)
            data[i] = std::tanh(data[i] * drive);  // soft clipping
    }
    
    oversampling.processSamplesDown(block);
}
```

**Koszt:** 4x oversampling = ~3-4x więcej CPU. Włącz tylko dla nieliniowych operacji, zostaw liniowe (EQ, delay) bez oversamplingu.

## Lookup tables i precomputation

```cpp
// Drogi: std::tanh w hot loop
for (int i = 0; i < N; ++i)
    out[i] = std::tanh(in[i] * drive);

// Lepiej: lookup table
constexpr int LUT_SIZE = 4096;
static const std::array<float, LUT_SIZE> tanhLut = []{
    std::array<float, LUT_SIZE> t{};
    for (int i = 0; i < LUT_SIZE; ++i) {
        const float x = -5.0f + 10.0f * i / (LUT_SIZE - 1);
        t[i] = std::tanh(x);
    }
    return t;
}();

float fastTanh(float x) {
    x = std::clamp(x, -5.0f, 5.0f);
    const float idx = (x + 5.0f) / 10.0f * (LUT_SIZE - 1);
    const int i0 = static_cast<int>(idx);
    const int i1 = std::min(i0 + 1, LUT_SIZE - 1);
    const float frac = idx - i0;
    return tanhLut[i0] * (1.0f - frac) + tanhLut[i1] * frac;
}
```

W 2026 **CPU-y są tak szybkie**, że często `std::tanh` jest wystarczający — ale w tight loops i obciążonych pluginach lookup wciąż się opłaca.

## SIMD — wektoryzacja

Modern CPU (AVX, NEON) potrafi wykonać **4-8 operacji float jednocześnie**:

```cpp
#include <immintrin.h>     // AVX

void multiplyArrays(float* a, const float* b, int n) {
    int i = 0;
    // SIMD: 8 floats per iteration
    for (; i + 8 <= n; i += 8) {
        __m256 va = _mm256_loadu_ps(&a[i]);
        __m256 vb = _mm256_loadu_ps(&b[i]);
        __m256 vc = _mm256_mul_ps(va, vb);
        _mm256_storeu_ps(&a[i], vc);
    }
    // Cleanup
    for (; i < n; ++i) a[i] *= b[i];
}
```

**JUCE alternatywa** — `juce::dsp::SIMDRegister<float>` (cross-platform: SSE / NEON / AVX).

**W 2026** kompilator (Clang, GCC) **auto-wektoryzuje** wiele pętli — często ręczny SIMD niepotrzebny. Sprawdź disassembly (`-O3 -mavx2 -fopt-info-vec`).

## Złota lista: checklist DSP-poprawnego pluginu

- [x] `prepareToPlay` alokuje wszystkie bufory
- [x] `processBlock` nie alokuje, nie locuje, nie I/O
- [x] `juce::ScopedNoDenormals` na początku `processBlock`
- [x] DC blocker na wyjściu (jeśli nieliniowe)
- [x] `juce::SmoothedValue` dla każdego parametru wpływającego na sygnał
- [x] Oversampling dla saturacji / clippingu / nieliniowych
- [x] Anti-aliasing dla oscylatorów (BLEP/BLAMP)
- [x] Lookup tables dla `tan`/`exp`/`pow` w hot loops
- [x] Atomic dla parametrów cross-thread
- [x] Test pluginval level 10 → 0 errors
- [x] Test 1000+ instances bez memory leak
- [x] Test różne sample rates (44.1, 48, 96, 192 kHz)
- [x] Test różne buffer sizes (32, 64, 128, ..., 2048)

## Materiały do nauki DSP

### Książki
- **The Audio Programming Book** — Boulanger, Lazzarini (MIT Press)
- **Designing Audio Effect Plugins in C++** — Will Pirkle
- **DAFX: Digital Audio Effects** — Udo Zölzer
- **Computer Music: Synthesis, Composition, and Performance** — Dodge & Jerse
- **The Theory and Technique of Electronic Music** — Miller Puckette (free PDF)

### Online
- **musicdsp.org** — repozytorium algorytmów
- **dsp.stackexchange.com** — Q&A
- **Will Pirkle YouTube** — rozdziały z książek
- **The Audio Programmer YouTube** — Joshua Hodge
- **Cytomic — Andy Simper papers** (ZDF/topology-preserving)
- **Vadim Zavalishin — The Art of VA Filter Design** (free PDF, fundamentalna)
- **JUCE DSP Tutorials** — juce.com/learn/tutorials

### Free DSP source
- **Vital Synth** (github.com/mtytel/vital) — wavetable
- **Surge XT** (github.com/surge-synthesizer/surge) — synth ogromnych rozmiarów
- **JUCE Examples** — gotowe oscillatory, filtry, FFT

## Co dalej?

- **Rozdział 05** — Tworzenie pierwszej wtyczki (JUCE Hello World)
- **Rozdział 06** — Cross-platform: build, signing, notarization
- **Rozdział 08** — Zaawansowane DSP (convolution reverb, multi-band, spectral FX)
