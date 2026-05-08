# Możliwości i funkcje VST plugins — co można zbudować

## Mapa funkcji VST plugins

```
┌──────────────────────────────────────────────────────────┐
│              CO MOŻE ROBIĆ PLUGIN VST?                    │
├──────────────────────────────────────────────────────────┤
│  EFFECT FX (przetwarza audio)                             │
│  ├─ Dynamics (compressor, limiter, gate, expander)        │
│  ├─ EQ / Filter (parametric, graphic, dynamic, linear-phase)│
│  ├─ Time-based (delay, reverb, echo)                      │
│  ├─ Modulation (chorus, flanger, phaser, tremolo)         │
│  ├─ Distortion (saturation, overdrive, fuzz, bit crusher) │
│  ├─ Pitch (auto-tune, harmonizer, octaver)               │
│  ├─ Spatial (panner, stereo widener, 3D, binaural)       │
│  └─ Special (vocoder, talkbox, ring mod, freeze)         │
├──────────────────────────────────────────────────────────┤
│  INSTRUMENT (generuje audio z MIDI)                       │
│  ├─ Synthesizers (subtractive, FM, additive, etc.)       │
│  ├─ Samplers (multi-sample, granular, drum machine)      │
│  ├─ Physical modeling (strings, brass, vocal)            │
│  └─ Hybrid (analog + digital + samples)                   │
├──────────────────────────────────────────────────────────┤
│  MIDI EFFECT (przetwarza MIDI)                            │
│  ├─ Arpeggiator                                           │
│  ├─ Chord generator                                       │
│  ├─ Scale snapping / quantizer                            │
│  ├─ Velocity randomization                                │
│  └─ Note sequencer                                        │
├──────────────────────────────────────────────────────────┤
│  ANALYZER (no audio out, tylko wizualizacja)              │
│  ├─ Spectrum analyzer                                     │
│  ├─ Loudness meter (LUFS, K-system, VU)                  │
│  ├─ Phase correlation                                     │
│  ├─ Tuner                                                 │
│  ├─ Goniometer / vector scope                             │
│  └─ Spectrogram                                           │
├──────────────────────────────────────────────────────────┤
│  UTILITY                                                   │
│  ├─ Gain / volume                                         │
│  ├─ Mid/Side encoder/decoder                              │
│  ├─ Polarity flip                                         │
│  ├─ Channel router                                        │
│  └─ Audio recorder / capture                              │
└──────────────────────────────────────────────────────────┘
```

## EFFECTS (FX) — przetwarzanie audio

### 1. Dynamics — kontrola dynamiki sygnału

Funkcje:
- **Compressor** — redukuje dynamikę (głośne ciszej, ciche głośniej)
- **Limiter** — twardy plafon (brick-wall, np. dla mastering)
- **Gate / Expander** — wycina ciche dźwięki (np. tło)
- **De-esser** — redukuje sybilanty (s, sz, ś) w wokalu
- **Multiband compressor** — kompresja per pasmo częstotliwości
- **Sidechain compressor** — kompresja sterowana z innego źródła (klasyczny "pumping" w EDM)
- **Transient shaper** — wzmacnia/redukuje transients (atak/sustain)
- **Upward compressor** — wzmacnia ciche fragmenty zamiast tłumić głośne

**Kluczowe parametry:**
- Threshold, Ratio, Attack, Release
- Knee (hard/soft)
- Makeup gain
- Lookahead (ms)
- Detection mode (peak vs RMS)

**Open-source implementacje (komercja-friendly):**
- `chowdsp_utils` (BSD) — `chowdsp::compressor` ready-to-use
- `STK` (permisywna) — basic dynamics
- DSP textbook implementations (Pirkle, Reiss)

**Przykład C++ (compressor core):**
```cpp
class SimpleCompressor {
    float threshold_dB = -20.0f;
    float ratio = 4.0f;
    float attackMs = 10.0f;
    float releaseMs = 100.0f;
    float envelope = 0.0f;

public:
    float process(float input) {
        float inputDB = 20.0f * std::log10(std::abs(input) + 1e-10f);
        float overshoot = std::max(0.0f, inputDB - threshold_dB);
        float reduction = overshoot * (1.0f - 1.0f/ratio);

        // Smooth envelope
        float target = reduction;
        float coef = (target > envelope) ? attackCoef : releaseCoef;
        envelope = coef * envelope + (1.0f - coef) * target;

        float gain = std::pow(10.0f, -envelope / 20.0f);
        return input * gain;
    }
};
```

### 2. EQ / Filter — kontrola częstotliwości

Funkcje:
- **Parametric EQ** — dowolne pasma z kontrolą freq/gain/Q
- **Graphic EQ** — stałe pasma z fader-ami
- **High-pass / Low-pass / Band-pass / Notch** — filtry
- **Shelf (high/low)** — wzmocnienie/tłumienie powyżej/poniżej
- **Linear-phase EQ** — bez przesunięcia fazy (mastering)
- **Dynamic EQ** — EQ z reagowaniem na sygnał (jak compressor + EQ)
- **Pitch-tracking EQ** — pasma podążają za nutami
- **Mid/Side EQ** — osobno dla środka i strony stereo
- **Surgical EQ** — ekstremalne Q dla precyzyjnych cięć
- **Match EQ** — kopiuje krzywą EQ z innego sygnału
- **Vintage emulation** — modeling klasycznych EQ (Pultec, Neve, API, SSL)

**Typy filtrów:**
- IIR (Biquad — najczęstszy: LP, HP, BP, Notch, Peak, Shelf)
- FIR (linear phase, dłuższe latency)
- State Variable Filter (SVF — analog-like)
- Chamberlin filter
- Moog ladder filter (legendary subtractive synth filter)

**Parametry biquad:**
- Frequency (cutoff/center)
- Q (resonance/bandwidth)
- Gain (peak/shelf)
- Filter type

**Open-source:**
- `chowdsp_utils` — IIR/FIR designs, vintage modeling, oversampling
- `Q DSP Library` — modern biquad, state variable filters
- `STK` — basic filter primitives

### 3. Time-based effects — opóźnienia i odbicia

Funkcje:
- **Delay / Echo** — opóźnione kopie sygnału
  - Tape delay (z modulacją + tape saturation)
  - Digital delay (czysty, precyzyjny)
  - Analog/BBD delay (ciepły, lo-fi)
  - Ping-pong delay (skacze L/R)
  - Multi-tap delay (wiele opóźnień)
  - Tempo-synced delay (BPM-aware)
  - Reverse delay
  - Ducking delay (cichszy gdy źródło głośne)
- **Reverb** — symulacja przestrzeni
  - Room/Hall/Plate/Chamber reverb (algorithmic)
  - Convolution reverb (impulse response — symulacja realnych miejsc)
  - Spring reverb (gitarowy, lo-fi)
  - Shimmer reverb (z pitch-shift)
  - Gated reverb (hard cutoff — 80s drums)
  - Reverse reverb (jak grany od tyłu)
- **Echo / Slap-back** — krótkie powtórzenie (rockabilly vocal)
- **Looper** — nagrywa i odtwarza (live performance)
- **Granular delay** — dzieli sygnał na ziarna z modyfikacją

**Kluczowe parametry reverb:**
- Decay time / RT60
- Pre-delay (ms)
- Damping (HF/LF)
- Diffusion / density
- Modulation (slight pitch wandering)
- Wet/dry mix

**Typy convolution reverb:**
- Direct (małe IR < 200ms — proste)
- Partitioned (dla długich IR — low latency)
- Frequency-domain (FFT-based — najszybsze)

**Open-source:**
- `Argotlunar` (MIT) — granular delay
- `Soundpipe` (MIT) — różne reverb implementacje
- `chowdsp_utils` (BSD) — convolution helpers
- IR samples free: openairlib.net (różne licencje)

### 4. Modulation effects — modulacja w czasie

Funkcje:
- **Chorus** — kopia sygnału z modulowanym opóźnieniem (pogrubia)
- **Flanger** — bardzo krótkie opóźnienie + modulacja (jet sound)
- **Phaser** — zmienne all-pass filtry (sweepy notch)
- **Tremolo** — modulacja amplitudy
- **Vibrato** — modulacja pitch (w przeciwieństwie do tremolo!)
- **Auto-pan** — modulacja pozycji stereo
- **Rotary speaker** — symulacja Leslie (organy)
- **Ensemble** — wzmocniony chorus (string synths)
- **Auto-wah** — modulowany band-pass
- **Frequency shifter** — przesunięcie pasma (ring mod-like)

**Komponenty modulation:**
- LFO (Low-Frequency Oscillator) — sine, triangle, square, S/H
- Envelope follower (auto-modulation z amplitude sygnału)
- Free running vs tempo-synced
- Stereo offset (różne fazy L/R = szerokość)

### 5. Distortion / Saturation — wprowadzenie zniekształceń

Funkcje:
- **Overdrive** — łagodne, soft clipping (gitara blues/rock)
- **Distortion** — twardsze, mocniejsze
- **Fuzz** — square wave-like, ekstremalne (Hendrix)
- **Bit crusher** — redukcja rozdzielczości bitowej (lo-fi, retro)
- **Sample rate reducer** — aliasing, downsampling
- **Tape saturation** — ciepła kompresja + harmoniczne (analog warmth)
- **Tube saturation** — emulacja lampowych preampów
- **Transformer saturation** — soft, gentle compression + harmonics
- **Multi-band saturation** — różne ilości w różnych pasmach
- **Wave shaper** — dowolna funkcja transferu (custom curves)
- **Hard / Soft clipping** — twardy lub miękki limit

**Anti-aliasing (kluczowe!):**
- Distortion tworzy aliasing → trzeba **oversampling** (2x, 4x, 8x)
- Lub band-limited synthesis

**Open-source:**
- `RTNeural` (BSD) — neural network amp simulation (Neural Amp Modeler-like)
- `chowdsp_utils` (BSD) — saturator helpers, oversampling
- IR samples cabinets — różne licencje

### 6. Pitch processing

Funkcje:
- **Pitch correction / Auto-Tune** — automatyczna korekcja pitch wokalu
- **Harmonizer** — generuje harmonie powyżej/poniżej
- **Octaver** — dodaje oktawy (gitara basowa, syntezator)
- **Pitch shifter** — zmiana pitch o stałą wartość
- **Time stretching** — zmiana tempa bez zmiany pitch
- **Formant shifting** — zmiana brzmienia ("kobieta → mężczyzna")
- **Vocoder** — analiza pitch + synteza (robotic voice)
- **Talk box** — rezonatory pitch-tracked

**Algorytmy pitch shifting:**
- PSOLA (Pitch Synchronous Overlap-Add) — dobry dla wokalu
- Phase Vocoder (FFT-based) — uniwersalny
- Granular pitch shifting — kreatywny, artifacty

**Algorytmy pitch detection:**
- Autocorrelation
- YIN algorithm
- CREPE (deep learning, 2018+)
- Cepstrum analysis

**Open-source:**
- `STK` — basic pitch primitives
- `Soundpipe` (MIT) — pitch detection, granular
- `RubberBand` GPL ❌ (nie do komercji bez płatnej licencji)
- `SoundTouch` LGPL ⚠ (dynamic OK)

### 7. Spatial / Stereo

Funkcje:
- **Stereo widener** — szerokość obrazu (Haas effect, M/S)
- **Mono → Stereo** — pseudo-stereo z mono źródła
- **Panner** — pozycja w stereo (constant power, linear)
- **Auto-panner** — modulacja pozycji
- **3D / Surround panner** — 5.1, 7.1, Atmos
- **Binaural (HRTF)** — realistyczne 3D w słuchawkach
- **Ambisonics** — 360° sound (VR/AR)
- **Mid/Side encoder/decoder**
- **Stereo image processor** — manipulation of M/S balance
- **Goniometer / phase scope** — wizualizacja stereo

**Open-source:**
- HRTF databases — różne licencje (CIPIC public domain, MIT KEMAR, Listen IRCAM permissive)
- Ambisonics libraries — często BSD/MIT (IEM Plug-in Suite)

### 8. Special / Creative

Funkcje:
- **Vocoder** — synteza z analizy spektralnej innego sygnału
- **Talkbox** — formanty z mowy aplikowane na inne źródło
- **Freeze / Hold** — zatrzymuje sygnał w pętli
- **Spectral processing** — modyfikacja w domenie częstotliwości
- **Spectral gate** — gate per pasmo
- **Spectral compressor** — kompresja per bin FFT
- **Resynthesis** — analiza + ponowna synteza
- **Glitch effect** — random retrigger, beat repeat
- **Granular effect** — dzielenie na ziarna + reorganizacja
- **AI-based effects** (2026 trend):
  - Source separation (vocal + instrumental z miksu)
  - Noise removal
  - Real-time amp simulation (NAM, AIDA-X)
  - Mastering AI (LANDR-style)

## INSTRUMENTS — generowanie dźwięku z MIDI

### Typy syntezy

#### 1. Subtractive synthesis (klasyczny analog)
**Idea:** generujesz harmoniczny sygnał (saw, square) i odejmujesz frequencies filtrami.

```
Oscillator (rich harmonic)
      ↓
Filter (LP/HP/BP, resonance)
      ↓
VCA (volume envelope)
      ↓
Output
```

**Słynne:** Moog, Roland Juno/Jupiter, Korg MS-20, Prophet
**Open-source przykłady:** Helm, ZynAddSubFX (oba GPL ❌)
**Komercja-friendly:** zbuduj samemu z `STK` (BSD), `Soundpipe` (MIT)

#### 2. FM (Frequency Modulation) synthesis
**Idea:** modulujesz pitch jednego oscillatora innym → kompleksowe spektrum.
**Słynne:** Yamaha DX7 (1983), Native Instruments FM8

**Open-source:** Dexed (DX7 emulator) — GPL ❌
**Komercja-friendly:** zaimplementuj sam — algorytmy FM są w domenie publicznej

#### 3. Additive synthesis
**Idea:** sumujesz wiele sinusów z różnymi częstotliwościami i amplitudami.
**Słynne:** Hammond organy, Kawai K5

**Komercja-friendly:** prosta implementacja w czystym C++

#### 4. Wavetable synthesis
**Idea:** odtwarzasz cykliczne tablice próbek, interpolujesz między nimi.
**Słynne:** PPG Wave (1981), Massive, Serum, Vital

**Open-source:** Vital (GPL ❌), Surge XT (GPL ❌)
**Komercja-friendly:** własna implementacja + wavetables z permissive licenses (Pamphleteers/free wavetables)

#### 5. Granular synthesis
**Idea:** dzielisz sample na małe "ziarna" (5-100ms) i odtwarzasz w różnych pozycjach/pitch.
**Słynne:** Native Instruments Reaktor, Output Portal, Granulator II

**Open-source:** `Soundpipe` (MIT) zawiera granular primitives
**Komercja-friendly:** ✓

#### 6. Physical modeling
**Idea:** symulacja fizyki instrumentu (struny, rezonatory, smyczki).
**Słynne:** Yamaha VL1, Modartt Pianoteq

**Open-source:**
- `STK` (permisywna) — Karplus-Strong strings, modal synthesis
- Faust — `physmodels.lib`

**Komercja-friendly:** ✓ STK jest klasyczne źródło

#### 7. Sample-based / Rompler
**Idea:** odtwarza nagrane próbki (multi-sampled instrument).
**Słynne:** Kontakt, Sampler libraries

**Komercja-friendly:** ✓ — implementuj sam, sample masz licencjonowane osobno

#### 8. Hybrid synthesis
Łączenie powyższych — np. wavetable oscillators + analog filters + samples.

### Architektura instrumentu

```
┌────────────────────────────────────┐
│           MIDI Input                │
└──────────────┬─────────────────────┘
               ▼
┌────────────────────────────────────┐
│        Voice Manager                │
│  (note allocation, polyphony)       │
└──────────────┬─────────────────────┘
               ▼
┌────────────────────────────────────┐
│  Voice 1     Voice 2    ...   Voice N│
│  ┌────┐      ┌────┐           ┌────┐│
│  │ Osc│  →   │Osc │     →     │Osc ││
│  │+Env│      │+Env│           │+Env││
│  │+Fil│      │+Fil│           │+Fil││
│  └─┬──┘      └─┬──┘           └─┬──┘│
└────┼───────────┼─────────────────┼──┘
     ▼           ▼                 ▼
   Sum (mix all voices)
     ▼
   Effects (chorus, reverb)
     ▼
   Output
```

**Komponenty:**
- **Voice manager** — alokacja notes do voices (mono/poly, voice stealing)
- **Oscillators** — generowanie podstawowego dźwięku
- **Envelopes** (ADSR — Attack, Decay, Sustain, Release) — kształt amplitudy/filtra w czasie
- **LFOs** — modulacja w czasie
- **Filters** — kształtowanie spektrum
- **Effects** — chorus, reverb, delay (wbudowane)
- **Modulation matrix** — routing wszystkiego (modular)

### Polifonia i głosy

- **Mono** (1 voice) — bass synths, leads
- **Poly** (8-32 voices) — pianos, pads
- **Voice stealing** — gdy max voices osiągnięty, kradnij najstarszy
- **Unison** — wiele voices na 1 note (grube brzmienie)
- **Detune** — voices lekko rozstrojonejaki

## MIDI EFFECTS — przetwarzanie MIDI

Funkcje:
- **Arpeggiator** — z akordu generuje arpeggio (pattern, rate, octaves)
- **Chord generator** — z 1 noty robi akord
- **Strum** — symulacja gitarowego strum
- **Scale snapping** — kwantyzuje noty do skali
- **Velocity randomization** — dodaje humanization
- **Note repeater** — buzz/roll efekty
- **Pattern sequencer** — wbudowany step sequencer
- **MIDI quantizer** — wyrównanie do siatki tempa
- **Humanizer** — random offsets dla naturalnego brzmienia
- **MIDI transformer** — replace notes, change channels, etc.

## ANALYZERS — wizualizacja (no audio output)

Funkcje:
- **Spectrum analyzer** — FFT-based wizualizacja częstotliwości
- **Real-time peak meter** — VU, peak, RMS
- **Loudness meter** — LUFS (integrated, short-term, momentary)
  - Standardy: EBU R128, ATSC A/85
- **Phase correlation meter** — czy stereo jest mono-compatible
- **Goniometer / vector scope** — wizualizacja stereo image
- **Spectrogram** — częstotliwość w czasie (waterfall)
- **Tuner** — pokazuje pitch (dla strojenia)
- **Oscilloscope** — sygnał w czasie

**Open-source:**
- `juce::dsp::FFT` (JUCE — JUCE license)
- `KissFFT` (BSD) — komercja OK
- `PocketFFT` (BSD)

## Mixing/mastering specific

### Mixing tools:
- **Bus compressor** — VCA-style (SSL G-bus, API 2500)
- **Mid/Side processor** — separacja środka/strony
- **Crossover** — multi-band split (Linkwitz-Riley)
- **Sidechain processor** — ducking, gating

### Mastering tools:
- **Linear-phase EQ** — surgical without phase artifacts
- **Multiband compressor** — kontrola dynamiki per pasmo
- **Maximizer / brick-wall limiter** — final loudness boost
- **Stereo imager** — manipulation szerokości
- **Loudness normalizer** — LUFS targeting
- **Dithering** — przy redukcji bit-depth
- **Truepeak limiter** — z oversampling, anti-clipping

## Specjalizowane (per source)

### Vocal processing:
- **Auto-tune / pitch correction** — Antares Auto-Tune, Melodyne
- **De-esser** — redukcja sybilantów
- **Vocal compressor** — preset dla wokalu
- **Vocal reverb** — krótszy, bardziej dense
- **Doubler / harmonizer** — pogrubienie/harmonie
- **Air enhancer** — high-shelf boost dla "powietrza"
- **De-noiser / restoration** — redukcja szumu, breaths
- **Vocal coding** — vocoder, formant shifting

### Guitar processing:
- **Amp simulator** — Marshall, Mesa, Fender emulacje
- **Cab simulator** — speaker IR (impulse response)
- **Stomp box emulations** — TS9, Fuzz Face, etc.
- **Pick-up modeling**
- **String simulator** (acoustic enhancement)

**2026 trend:** **Neural Amp Modeler (NAM)** i **AIDA-X** — neural networks emulating real amps. Open-source community samples.

### Drum processing:
- **Drum replacer** — automatic kick/snare replacement
- **Drum machine** — TR-808, TR-909 emulations
- **Transient designer** — ciężar / atak
- **Room emulator** — drum room reverb
- **Snare excitement / saturation**
- **Crusher / decimator** — lo-fi drum sounds

### Bass processing:
- **Bass enhancement** — sub-octave doubling
- **Bass compressor** — fast attack
- **DI box emulation**

## AI/ML w VST plugins (2026)

W 2026 ML zrewolucjonizowało plugins:

### Real-time amp simulation
- **Neural Amp Modeler (NAM)** — open source format
- **AIDA-X** (open source NeuralPi)
- Trainowanie własnych amp captures (neural network learns konkretny ampamp)

### Source separation
- **Demucs** (Meta) — vocal/drum/bass/other
- **Spleeter** (Deezer) — 4-stem separation
- iZotope RX 11 (komercyjny) — restoration suite

### Noise removal / restoration
- **NVIDIA RTX Voice / Broadcast** — real-time noise gate
- **iZotope RX** — szum, click, hum, restoration

### Mastering AI
- **LANDR** — automatic mastering
- **iZotope Ozone Master Assistant** — AI tone matching

### Generative
- **AIVA** — composition AI
- **Magenta** (Google) — open source music ML

### Frameworki ML w pluginach (komercja-friendly):
- **RTNeural** (BSD) — najpopularniejsze dla audio
- **ONNX Runtime** (MIT) — universal model deployment
- **TensorFlow Lite** (Apache 2.0) — mobile/edge
- **LibTorch** (BSD) — PyTorch C++

## Mapowanie funkcji → biblioteki open-source

### Tabela: chcę zbudować X, jakiej biblioteki użyć (komercja-friendly)?

| Co chcesz zbudować | Najlepsza darmowa biblioteka | Licencja |
|--------------------|------------------------------|----------|
| **EQ / Filter** | chowdsp_utils, Q DSP | BSD/MIT |
| **Compressor / Limiter** | chowdsp_utils + custom | BSD |
| **Reverb (algorithmic)** | Soundpipe + custom | MIT |
| **Reverb (convolution)** | KissFFT + custom partitioned conv | BSD |
| **Delay** | własna implementacja (proste) | - |
| **Chorus / Flanger / Phaser** | chowdsp_utils + LFO | BSD |
| **Distortion / Saturation** | chowdsp_utils oversampling | BSD |
| **Pitch shift** | własna PSOLA / phase vocoder | - |
| **Synth oscillators (saw/square)** | chowdsp_utils polyBLEP | BSD |
| **Wavetable synth** | własne + free wavetables | - |
| **Physical modeling** | STK | permisywna |
| **Granular** | Soundpipe | MIT |
| **FFT** | KissFFT, PocketFFT | BSD |
| **Neural network (AI)** | RTNeural | BSD |
| **MIDI processing** | własne (proste) | - |
| **Spectrum analyzer** | KissFFT + JUCE/iPlug2 | BSD |
| **Loudness meter (LUFS)** | libebur128 (MIT) | MIT |
| **Resampling** | libsamplerate (BSD) | BSD |
| **JSON config** | nlohmann/json | MIT |
| **Logging** | spdlog | MIT |
| **Plugin framework** | iPlug2 | zlib |
| **Plugin format** | CLAP | MIT |

## Złożoność implementacji per typ pluginu

| Plugin | Czas (solo dev) | DSP knowledge | Komercja-ready |
|--------|----------------|---------------|----------------|
| Volume / Gain | godziny | Beginner | Tak |
| Mute / Polarity | godziny | Beginner | Tak |
| Stereo widener (M/S) | dzień | Beginner | Tak |
| Tremolo / Vibrato | 1-3 dni | Beginner | Tak |
| Delay (basic) | 2-5 dni | Beginner | Tak |
| EQ (parametric, biquad) | 1 tydzień | Intermediate | Tak |
| Compressor | 1-2 tygodnie | Intermediate | Tak |
| Chorus / Flanger / Phaser | 1 tydzień | Intermediate | Tak |
| Distortion (z oversampling) | 1-2 tygodnie | Intermediate | Tak |
| Algorithmic reverb | 2-4 tygodnie | Advanced | Tak |
| Convolution reverb | 3-6 tygodni | Advanced | Tak |
| Multiband compressor | 4 tygodnie | Advanced | Tak |
| Linear-phase EQ | 4-6 tygodni | Advanced | Tak |
| Pitch shifter | 6-8 tygodni | Advanced | Wymaga testów |
| Auto-tune | 2-3 miesiące | Expert | Wymaga R&D |
| Synthesizer (basic subtractive) | 4-8 tygodni | Advanced | Tak |
| Synthesizer (wavetable, comprehensive) | 6+ miesięcy | Expert | Tak |
| Sampler (multi-sample) | 3-6 miesięcy | Expert | Tak |
| Vocoder | 2-3 miesiące | Expert | Tak |
| Neural amp simulator | 1-2 miesiące + ML | ML+Audio | Tak |

## Niche / kreatywne pomysły (2026)

Co jeszcze można zbudować jako niche product:

- **Game audio plugins** — adaptive music, footstep generators
- **Podcast-specific** — voice presets, leveler, intro/outro automation
- **Streaming-specific** — auto-ducking, loudness compliance
- **Live performance** — looper z real-time pitch correction
- **Music education** — chord/scale visualizers w pluginach
- **Accessibility** — visual feedback dla deaf users
- **Spatial audio (Atmos)** — Dolby Atmos object panners
- **VR/AR audio** — binaural, head-tracking
- **AI-assisted mixing** — auto-balance, auto-EQ
- **Stem mastering** — separate processing per stem
- **Metadata tools** — BWAV, broadcast metadata
- **Audio repair** — clip restoration, declick, dehum

## Trendy i przyszłość 2026+

### Co rośnie:
- **AI-based effects** — neural networks w real-time
- **Cross-platform native** (CLAP) — zastąpienie VST3
- **Web Audio plugins** (WAM, Web Audio Modules) — przeglądarkowe DAW
- **Spatial / Atmos** — Dolby Atmos production rośnie
- **AI mastering / mixing** — automation przy zachowaniu kontroli
- **Neural amp simulators** — NAM, AIDA-X
- **Source separation** — demucs/spleeter w czasie rzeczywistym
- **Mobile production** — iPad pluginy, AUv3

### Co maleje:
- **Skeuomorphic GUI** (analog modeling looks) → flat, minimal designs
- **Heavyweight RAM-hungry samplers** → cloud streaming samples
- **Closed proprietary formats** → CLAP/open standards

## Praktyczna rada

**Zacznij od prostego.** Twój pierwszy plugin to nie powinien być "Vital killer". Zacznij od:

1. **Volume + Mute** (godziny — naucz się frameworka)
2. **Tremolo** (LFO + amplitude — 1-2 dni)
3. **Delay** (circular buffer — 3-5 dni)
4. **Biquad EQ** (1 tydzień — fundament)
5. **Chorus** (delay + LFO — 1 tydzień)
6. **Compressor** (envelope follower — 2 tygodnie)
7. **Reverb** (algorithmic — 2-4 tygodnie)

Każdy z tych może być **commercial product** jeśli wystarczająco dobrze zrobiony. Lepiej **idealny limiter** niż **przeciętny synth**.

## Linki

- **musicdsp.org** — repo algorytmów (większość permisywne / public domain)
- **Pirkle's books** — "Designing Audio Effect Plugins" — biblia
- **DAFX (Digital Audio Effects)** book — Zölzer
- **JUCE forum** — kvraudio.com/forum
- **The Audio Programmer** YouTube — tutoriale od Joshua Hodge
- **Will Pirkle's textbooks** — comprehensive
- **Stanford CCRMA** — academic resources

## Następne kroki

- **Rozdział 04** — DSP podstawy (deep dive in algorithms)
- **Rozdział 08** — Zaawansowane DSP
- **Rozdział 11** — Open source libraries z permisywnymi licencjami
