# Zaawansowane DSP

Po opanowaniu podstaw DSP czas na techniki, które odróżniają hobby plugin od produktu komercyjnego. Convolution reverby, FFT, oversampling, lookahead, multi-band processing — to narzędzia każdego poważnego plugin developera.

## Convolution reverb

**Convolution** to mnożenie próbka po próbce sygnału wejściowego z **impulse response** (IR) — nagraniem akustycznym pomieszczenia (kościół, hala, sala koncertowa). Daje hiperrealistyczne reverby — bo IR pochodzi z prawdziwej przestrzeni.

### Direct convolution (naiwna)

```cpp
// Splot dwóch sygnałów: y[n] = sum(x[k] * h[n-k])
void directConvolution(const float* input, int inputLen,
                       const float* ir, int irLen,
                       float* output) {
    int outputLen = inputLen + irLen - 1;
    for (int n = 0; n < outputLen; ++n) {
        float sum = 0.0f;
        for (int k = 0; k < irLen; ++k) {
            if (n - k >= 0 && n - k < inputLen)
                sum += input[n - k] * ir[k];
        }
        output[n] = sum;
    }
}
```

**Problem:** IR o długości 4 sekund @ 48kHz = 192000 próbek. Per próbka audio: 192000 mnożeń. Na 48000 próbek/sek to **9.2 mld operacji/sek** — nierealne na CPU.

### Partitioned convolution (FFT-based)

Standardem jest **partitioned uniform convolution** — IR dzielony na mniejsze bloki, każdy konwolwowany w domenie częstotliwościowej (FFT). Złożoność O(N log N) zamiast O(N²).

```
IR (192k próbek)
  → podziel na bloki po 1024 próbek (188 bloków)
  → FFT każdego bloku → 188 spektr
  → input też FFT → mnożenie spektr → IFFT
  → overlap-add do output buffer
```

**Latency vs CPU tradeoff:** mały blok = niski latency ale więcej overhead, duży blok = wyższy latency ale niższe CPU. **Non-uniform partitioned convolution** rozwiązuje to — pierwsze bloki małe (zero latency), następne progresywnie większe.

**Biblioteki:**
- **FFTConvolver** (open source, partitioned)
- **HISSTools** (JUCE-friendly)
- **Intel IPP** (komercyjny, najszybszy)
- **Apple Accelerate vDSP_zvmul** (macOS native)

## FFT-based processing

**FFT** zamienia sygnał czasowy na spektrum częstotliwościowe. Rozmiar 1024-4096 próbek typowo. Trzeba aplikować **window function** (Hann, Hamming, Blackman) żeby uniknąć spectral leakage.

### Overlap-add vs overlap-save

Bo FFT operuje na blokach, a sygnał audio jest ciągły, potrzebujesz strategii nakładania:

| Metoda | Jak działa | Use case |
|--------|------------|----------|
| **Overlap-add (OLA)** | Bloki z window, output sumowany z poprzednim | Convolution, time stretching |
| **Overlap-save** | Bloki bez window na input, środek output zachowywany | Liniowy filtering FFT |
| **WOLA** (Weighted) | OLA + window na output, zwykle 50% overlap | Phase vocoder, spectral effects |

```cpp
// Overlap-add z 50% overlap, Hann window
constexpr int FFT_SIZE = 2048;
constexpr int HOP_SIZE = FFT_SIZE / 2;  // 50% overlap

void processWithOLA(juce::dsp::FFT& fft, float* input, float* output) {
    static float buffer[FFT_SIZE * 2] = {0};
    static float overlap[FFT_SIZE] = {0};

    // Zastosuj Hann window
    for (int i = 0; i < FFT_SIZE; ++i)
        buffer[i] = input[i] * 0.5f * (1.0f - std::cos(2.0f * M_PI * i / (FFT_SIZE - 1)));

    fft.performRealOnlyForwardTransform(buffer);
    // ... modyfikacja spektrum ...
    fft.performRealOnlyInverseTransform(buffer);

    // Overlap-add do output
    for (int i = 0; i < FFT_SIZE; ++i)
        output[i] = buffer[i] + (i < HOP_SIZE ? overlap[i] : 0);

    // Zapisz drugą połowę do overlap dla kolejnego bloku
    std::memcpy(overlap, buffer + HOP_SIZE, HOP_SIZE * sizeof(float));
}
```

## Spectral processing

### Pitch shifting (phase vocoder)

Standardowa metoda — zmiana pitch bez zmiany długości:

1. STFT (Short-Time Fourier Transform) — sygnał do spektrum
2. Modyfikacja faz proporcjonalnie do shift ratio
3. ISTFT — z powrotem do czasu z zmodyfikowanym hop size
4. Resampling do oryginalnej długości

**Artefakty:** phase smearing, "phasiness", transient smearing dla dużych shift. Lepsze algorytmy (np. Rubber Band Library, Elastique od zplane) używają detekcji transientów i fazy lokalnej.

### Time stretching

Odwrotność pitch shifting — zmiana długości bez zmiany pitch. Te same problemy z artefaktami. Dla muzyki z transientami (perkusja) trzeba detekcji onsetów żeby je zachować.

**Biblioteki:**
- **Rubber Band Library** (GPL/komercyjna licencja)
- **SoundTouch** (open source)
- **Elastique** od zplane (drogo, ale TOP — używana przez Pro Tools, Cubase)

## Oversampling — kluczowe dla nieliniowych efektów

Każdy nieliniowy proces (saturacja, distortion, waveshaping, clipping) generuje **harmoniczne** powyżej częstotliwości bazowej. Jeśli te harmoniczne przekroczą Nyquista (sample_rate / 2), **aliasują** się jako fałszywe częstotliwości — brzmią paskudnie.

**Rozwiązanie:** oversampling — przed efektem upsample audio do 2x/4x/8x sample rate, zaaplikuj efekt, downsample z powrotem z anti-aliasing filter.

```cpp
class Oversampler {
public:
    Oversampler(int factor) : oversamplingFactor(factor) {
        oversampler = std::make_unique<juce::dsp::Oversampling<float>>(
            2,  // numChannels
            std::log2(factor),  // factor as power of 2
            juce::dsp::Oversampling<float>::filterHalfBandPolyphaseIIR,
            true  // maxQuality
        );
    }

    void prepare(double sampleRate, int blockSize) {
        oversampler->initProcessing(blockSize);
        oversampler->reset();
    }

    void process(juce::AudioBuffer<float>& buffer) {
        juce::dsp::AudioBlock<float> block(buffer);
        auto oversampledBlock = oversampler->processSamplesUp(block);

        // Aplikuj nieliniowy efekt na oversampledBlock
        for (int ch = 0; ch < oversampledBlock.getNumChannels(); ++ch) {
            auto* data = oversampledBlock.getChannelPointer(ch);
            for (size_t i = 0; i < oversampledBlock.getNumSamples(); ++i)
                data[i] = std::tanh(data[i] * drive);  // saturacja
        }

        oversampler->processSamplesDown(block);
    }

private:
    int oversamplingFactor;
    std::unique_ptr<juce::dsp::Oversampling<float>> oversampler;
    float drive = 5.0f;
};
```

**Kompromis:**

| Factor | CPU cost | Aliasing reduction | Latency |
|--------|----------|-------------------|---------|
| 2x | +50% CPU | OK dla soft saturation | ~2-4 próbki |
| 4x | +120% CPU | Dobre dla heavy distortion | ~4-8 próbek |
| 8x | +250% CPU | Studio quality | ~8-16 próbek |
| 16x | +500% CPU | Mastering grade | ~16-32 próbek |

W praktyce **4x z polyphase IIR** jest sweet spot dla większości pluginów. Filtry FIR mają liniową fazę ale wyższy latency, IIR mają niższy latency ale phase distortion.

## Lookahead processing

**Lookahead** = plugin "widzi w przyszłość" buforując sygnał i opóźniając output. Klasyczny use case — **brickwall limiter**, który anticypuje peaki i redukuje gain *przed* nimi (zamiast reagować po).

```cpp
class LookaheadLimiter {
public:
    void prepare(double sampleRate, int lookaheadMs) {
        lookaheadSamples = (int)(sampleRate * lookaheadMs / 1000.0);
        delayBuffer.setSize(2, lookaheadSamples);
        gainEnvelope.resize(lookaheadSamples);
        writePos = 0;
    }

    void processBlock(juce::AudioBuffer<float>& buffer) {
        const int numSamples = buffer.getNumSamples();
        for (int i = 0; i < numSamples; ++i) {
            // Przeczytaj próbki opóźnione o lookahead
            float sampleL = delayBuffer.getSample(0, writePos);
            float sampleR = delayBuffer.getSample(1, writePos);

            // Zapisz nowe próbki do bufora
            delayBuffer.setSample(0, writePos, buffer.getSample(0, i));
            delayBuffer.setSample(1, writePos, buffer.getSample(1, i));

            // Wyznacz peak w oknie lookahead i odpowiednio przyciszaj
            float peak = findPeakInWindow();
            float gain = (peak > threshold) ? threshold / peak : 1.0f;

            buffer.setSample(0, i, sampleL * gain);
            buffer.setSample(1, i, sampleR * gain);

            writePos = (writePos + 1) % lookaheadSamples;
        }
    }

private:
    juce::AudioBuffer<float> delayBuffer;
    std::vector<float> gainEnvelope;
    int lookaheadSamples = 0, writePos = 0;
    float threshold = 0.95f;
};
```

**Cena:** plugin wprowadza **latency = lookahead time**. DAW musi to skompensować (PDC = Plugin Delay Compensation). Trzeba zaraportować latency w `getLatencySamples()` żeby DAW wiedział o ile cofnąć track.

## Multi-band processing

Dzielenie sygnału na pasma (low/mid/high) i osobne przetwarzanie każdego. Klasyk — **multiband compressor**, **multiband saturator**.

### Linkwitz-Riley crossover

Najpopularniejszy crossover dla audio — bo sumuje się **flat** (suma low + high = oryginał, bez phase issues w crossover frequency).

```cpp
// Linkwitz-Riley 4th order = dwa Butterworth 2nd order w kaskadzie
class LinkwitzRileyCrossover {
public:
    void setCrossoverFreq(double freq, double sampleRate) {
        // Butterworth 2nd order, kaskadowo dwa razy = LR4
        lowpass1.setCoefficients(juce::IIRCoefficients::makeLowPass(sampleRate, freq, 0.7071));
        lowpass2.setCoefficients(juce::IIRCoefficients::makeLowPass(sampleRate, freq, 0.7071));
        highpass1.setCoefficients(juce::IIRCoefficients::makeHighPass(sampleRate, freq, 0.7071));
        highpass2.setCoefficients(juce::IIRCoefficients::makeHighPass(sampleRate, freq, 0.7071));
    }

    void processBlock(juce::AudioBuffer<float>& low, juce::AudioBuffer<float>& high) {
        // Low band: dwukrotnie LP
        lowpass1.process(low);
        lowpass2.process(low);
        // High band: dwukrotnie HP, plus invert dla phase consistency
        highpass1.process(high);
        highpass2.process(high);
    }

private:
    juce::IIRFilter lowpass1, lowpass2, highpass1, highpass2;
};
```

**Pamiętaj** o **all-pass kompensacji** — nawet z LR4, sąsiednie pasma w 3-band crossoverze potrzebują kompensacji fazy. FabFilter Pro-MB słynnie radzi sobie z tym super.

## Dynamics processing

### Compressor (klasyczny)

```cpp
class Compressor {
public:
    void prepare(double sr, int blockSize) {
        sampleRate = sr;
        attackCoeff = std::exp(-1.0 / (attackMs * 0.001 * sampleRate));
        releaseCoeff = std::exp(-1.0 / (releaseMs * 0.001 * sampleRate));
    }

    void processBlock(float* data, int numSamples) {
        for (int i = 0; i < numSamples; ++i) {
            float input = data[i];
            float inputLevel = std::abs(input);

            // Detekcja envelope (peak follower)
            if (inputLevel > envelope)
                envelope = attackCoeff * envelope + (1.0f - attackCoeff) * inputLevel;
            else
                envelope = releaseCoeff * envelope + (1.0f - releaseCoeff) * inputLevel;

            // Compute gain reduction (w dB)
            float envDb = 20.0f * std::log10(envelope + 1e-9f);
            float gainDb = 0.0f;
            if (envDb > thresholdDb) {
                float overshoot = envDb - thresholdDb;
                gainDb = -overshoot * (1.0f - 1.0f / ratio);
            }

            float gain = std::pow(10.0f, gainDb / 20.0f);
            data[i] = input * gain * makeupGain;
        }
    }

private:
    double sampleRate = 44100;
    float thresholdDb = -20.0f, ratio = 4.0f;
    float attackMs = 5.0f, releaseMs = 100.0f;
    float attackCoeff = 0, releaseCoeff = 0;
    float envelope = 0, makeupGain = 1.0f;
};
```

### Limiter, expander, gate

| Procesor | Działanie | Typowe parametry |
|----------|-----------|------------------|
| **Compressor** | Redukuje gain powyżej threshold | Threshold, ratio, attack, release, knee |
| **Limiter** | Hard ratio (∞:1), zwykle z lookahead | Threshold, release, ceiling |
| **Expander** | Redukuje gain poniżej threshold (downward) | Threshold, ratio, attack, hold, release |
| **Gate** | Ostry expander (∞:1) | Threshold, attack, hold, release, range |
| **Upward compressor** | Boostuje sygnał poniżej threshold | Threshold, ratio (rzadko używane samodzielnie) |
| **Transient designer** | Manipuluje attack/sustain bez threshold | Attack, sustain |

## Modulation effects

### Chorus / Flanger / Phaser

Wszystkie te efekty używają **modulowanej linii opóźniającej** z różnymi czasami delay i feedback:

| Efekt | Delay range | Modulacja | Feedback |
|-------|-------------|-----------|----------|
| **Chorus** | 15-40 ms | Wolna LFO 0.1-1 Hz | Niski lub zero |
| **Flanger** | 1-10 ms | Średnia LFO 0.1-3 Hz | Wysoki, charakterystyczny "jet" |
| **Phaser** | (Brak delay — kaskada all-pass) | LFO moduluje pole all-pass | Średni |
| **Tremolo** | (Brak delay — modulacja amplitude) | LFO 1-20 Hz | N/A |
| **Vibrato** | 0-10 ms | LFO 1-10 Hz | Zero |

```cpp
class SimpleChorus {
public:
    void prepare(double sr) {
        sampleRate = sr;
        delayLine.setSize(1, (int)(sr * 0.05));  // 50ms max delay
        delayLine.clear();
    }

    float process(float input) {
        // LFO moduluje delay 15-25ms
        float lfo = 0.5f + 0.5f * std::sin(2.0f * M_PI * lfoPhase);
        lfoPhase += lfoFreq / sampleRate;
        if (lfoPhase >= 1.0f) lfoPhase -= 1.0f;

        float delayMs = 15.0f + 10.0f * lfo;
        float delaySamples = delayMs * sampleRate / 1000.0f;

        float delayed = delayLine.getInterpolatedSample(delaySamples);
        delayLine.pushSample(input + delayed * 0.3f);

        return input * (1.0f - mix) + delayed * mix;
    }

private:
    double sampleRate = 44100;
    juce::DelayLine<float> delayLine;
    float lfoPhase = 0, lfoFreq = 0.5f, mix = 0.5f;
};
```

## Pitch detection

Wykrywanie wysokości tonu — używane w tunerach, auto-tune, MIDI converterach.

### Autocorrelation

Najprostsza metoda — przesuwasz sygnał o offset i mnożysz ze sobą; maximum mnożenia daje period.

```cpp
float detectPitchAutocorrelation(const float* buffer, int size, double sampleRate) {
    float maxCorr = 0;
    int bestPeriod = 0;
    int minPeriod = (int)(sampleRate / 2000);  // 2000 Hz max
    int maxPeriod = (int)(sampleRate / 50);    // 50 Hz min

    for (int period = minPeriod; period < maxPeriod; ++period) {
        float corr = 0;
        for (int i = 0; i + period < size; ++i)
            corr += buffer[i] * buffer[i + period];
        if (corr > maxCorr) {
            maxCorr = corr;
            bestPeriod = period;
        }
    }
    return (float)(sampleRate / bestPeriod);
}
```

**Limitacje:** wolne, problemy z octave errors, słabe na sygnałach harmonicznych.

### YIN algorithm

Lepszy — bazuje na difference function zamiast korelacji, dodaje cumulative mean normalization. Standardem dla muzyki. Implementacja w bibliotece **aubio** lub **dywapitchtrack**.

**Nowoczesne 2026:** **CREPE** (deep learning pitch detection, model ~100MB, ale super dokładny), **SPICE** od Google.

## Time-domain vs frequency-domain

| Cecha | Time-domain | Frequency-domain (FFT) |
|-------|-------------|------------------------|
| **Latency** | Niski (~próbki) | Wyższy (rozmiar FFT) |
| **CPU dla short FIR** | Niski | Wyższy overhead |
| **CPU dla long FIR** | Wysoki O(N²) | Niski O(N log N) |
| **Linear phase filtering** | Trudne | Łatwe |
| **Spectral manipulacja** | Niemożliwa | Naturalna |
| **Przykłady** | EQ IIR, kompressor, delay | Convolution reverb, pitch shift, spectral gate |

**Reguła kciuka:** krótkie filtry (kilkadziesiąt taps) → time-domain. Długie (>1000 taps) lub spektralne → FFT.

## IIR filter design

### Klasyczne typy

| Typ | Charakterystyka | Use case |
|-----|----------------|----------|
| **Butterworth** | Maximally flat passband, brak ripple | Crossovers, ogólne LPF/HPF |
| **Chebyshev I** | Ripple w passband, sharper rolloff | Gdzie potrzeba szybszego cutoff |
| **Chebyshev II** | Ripple w stopband, flat passband | Anti-aliasing |
| **Elliptic (Cauer)** | Ripple w obu pasmach, najsztywniejszy rolloff | Dekonwolacja, oversampling |
| **Bessel** | Linear phase w passband | Bass management, woofers |
| **Linkwitz-Riley** | Crossover-friendly | Multi-band crossovers |

JUCE ma `juce::dsp::IIR::Coefficients::makeLowPass/HighPass/BandPass/Notch` itp. Dla bardziej zaawansowanych projektów — **Q library** (Joel de Guzman) lub **DSPFilters** (Vinnie Falco).

## Latency compensation

Plugin musi raportować swoją latency:

```cpp
int MyAudioProcessor::getLatencySamples() const {
    return lookaheadSamples + oversamplingLatency + fftLatency;
}
```

DAW wykorzystuje to w **PDC** (Plugin Delay Compensation) — wszystkie tracki w sesji są synchronizowane. **WAŻNE:** zmiana latency w trakcie playback (np. zmiana oversampling od 2x do 4x) musi być zaraportowana przez `setLatencySamples()`. Niektóre DAW (Reaper) handluje to dynamicznie, inne (Pro Tools) nie — wymaga reload.

## Wet/dry mix — parallel processing

Dla efektów destrukcyjnych (saturation, compression) **parallel processing** = duplikujesz sygnał, jeden tor zostaje czysty (dry), drugi przetwarzany (wet), miksujesz z powrotem.

```cpp
void processBlock(juce::AudioBuffer<float>& buffer) {
    juce::AudioBuffer<float> wetBuffer;
    wetBuffer.makeCopyOf(buffer);  // kopia dry → wet

    // Process tylko wet
    distortion.processBlock(wetBuffer);
    compressor.processBlock(wetBuffer);

    // Mix dry + wet
    for (int ch = 0; ch < buffer.getNumChannels(); ++ch) {
        auto* dry = buffer.getWritePointer(ch);
        auto* wet = wetBuffer.getReadPointer(ch);
        for (int i = 0; i < buffer.getNumSamples(); ++i)
            dry[i] = dry[i] * (1.0f - mixAmount) + wet[i] * mixAmount;
    }
}
```

**Uwaga na phase issues** — jeśli wet ma latency (np. lookahead, FFT), dry musi być opóźniony o tę samą wartość, inaczej miks robi comb filter.

## AI/ML w DSP — trendy 2026

Boom AI dotarł do audio:

### Neural amp modeling

**Neural Amp Modeler (NAM)** — open source, model neural network trenowany na nagraniach realnych wzmacniaczy gitarowych. Plugin runtime ładuje wytrenowany model (.nam file), real-time inference. Słynny — **Tone3000** repo z setkami modeli komercyjnych ampów.

**Konkurencja:** **Aida-X** (też neural), **Tonex** (od IK Multimedia, AI capture).

### AI-based mastering

**LANDR**, **iZotope Ozone Mastering Assistant**, **Neutron Visual Mixer** — analiza spektralna + ML model decyduje o EQ, kompresji, limiterze. **Sonible smart:eq3** używa ML do dynamicznej krzywej EQ per instrument.

### Noise reduction (RX/AudioStrip)

**iZotope RX** — używa deep learning do dialogue isolation, music rebalancing. **Adobe Enhance Speech**, **Krisp**, **NVIDIA Broadcast** — wszystko ML-based.

### Stem separation

**Spleeter** (Deezer), **Demucs** (Meta), **MVSEP** — separacja mix do wokal/perkusja/bas/inne. W 2026 mainstream w Logic, Ableton (Stem Splitter), FL Studio, Cubase.

### RNBO (Cycling '74)

**RNBO** to nowoczesny tool do tworzenia pluginów z **Max for Live** patches — eksport do C++ JUCE-ready. Łączy się z **TensorFlow.js** dla ML w real-time.

### Inference w pluginie

Bibliotekach do ML inference w C++:
- **ONNX Runtime** — Microsoft, support dla CoreML, DirectML, CUDA
- **TensorFlow Lite** — mobile-friendly, mały footprint
- **libtorch** (PyTorch C++) — duży, ale flexible
- **RTNeural** (audio-focused, real-time safe, JUCE-friendly)

```cpp
// Przykład RTNeural — load wytrenowanej sieci LSTM z JSON
#include <RTNeural/RTNeural.h>

RTNeural::ModelT<float, 1, 1,
    RTNeural::LSTMLayerT<float, 1, 16>,
    RTNeural::DenseT<float, 16, 1>> model;

std::ifstream jsonStream("amp_model.json");
nlohmann::json modelJson;
jsonStream >> modelJson;
model.parseJson(modelJson, true);

float processSample(float input) {
    return model.forward(&input);
}
```

## Biblioteki DSP — overview

| Biblioteka | Twórca | Licencja | Cechy |
|------------|--------|----------|-------|
| **Intel IPP** | Intel | Komercyjna | Najszybsza, x86 only, SSE/AVX optimized |
| **Apple Accelerate (vDSP)** | Apple | Bundled | Hyper-optimized for ARM/x86 macOS |
| **JUCE dsp** | JUCE | GPL/komercyjna | Filtry, FFT, oversampling, convolution |
| **Q library** | Joel de Guzman | Boost | Modern C++, przemyślane API |
| **kfr** | KFR | GPL/Comm | Templated, bardzo szybkie |
| **FFTW** | MIT | GPL/Comm | Standard FFT na CPU |
| **DSPFilters** | Vinnie Falco | MIT | Klasyczne IIR designs |
| **RTNeural** | Jatin Chowdhury | BSD | ML inference real-time |
| **CDSPResampler** | r8brain | BSD | Wysokiej jakości resampling |

## Praktyczne tipy

- **Profile, profile, profile.** CPU 5% w studio, 30% w live → katastrofa. Mierz na różnych buffer sizes (32, 64, 128, 256, 512, 1024).
- **SIMD intrinsics** — krytyczne dla performance, ale czytelność cierpi. Najpierw scalar implementacja, profile, potem SIMD tylko hot loops.
- **Denormals** — wyłączaj globalnie (`_MM_SET_FLUSH_ZERO_MODE`) lub dodawaj DC offset.
- **Tablice przelicz raz** — wszystkie współczynniki filtrów, LFO sin tables, pre-computed arrays trzymaj poza processBlock.
- **Branch prediction** — unikaj if w gorących pętlach gdy się da. Conditional move (`std::min/max`, `std::clamp`) lepsze.
- **Cache friendly** — preferuj struct-of-arrays nad array-of-structs, dane sekwencyjne nad rozproszone.

## Dalsze lektura

- **"The Audio Programming Book"** — Boulanger, Lazzarini
- **"DAFX: Digital Audio Effects"** — Udo Zölzer
- **"Designing Audio Effect Plug-ins in C++"** — Will Pirkle (must-read)
- **JUCE Tutorials DSP** — oficjalna dokumentacja JUCE
- **MusicDSP.org** — archiwum kodów algorytmów
- **KVR DSP Forum** — najaktywniejsze społeczność dyskutująca DSP
