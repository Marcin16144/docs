# Darmowe wtyczki VST z permisywną licencją (rozbudowa + sprzedaż komercyjna)

## TL;DR — pułapka GPL

**KLUCZOWA WIEDZA:** Większość "open source" wtyczek VST jest na licencji **GPL** lub **LGPL**, co **uniemożliwia** sprzedaż komercyjną zamkniętego forka.

```
Co możesz LEGALNIE zrobić z wtyczką open-source?

Plugin pod MIT / BSD / Apache 2.0 / Boost / ISC:
  ✓ Forknąć
  ✓ Modyfikować
  ✓ Sprzedawać komercyjnie
  ✓ Closed-source
  ✓ Bez ujawniania zmian
  ✓ Zachować swoje IP
  → Tylko zachowaj copyright notice w pluginie

Plugin pod LGPL:
  ⚠️ Forknąć — tak (twój fork pozostaje LGPL)
  ⚠️ Linkować dynamicznie — można w komercji
  ❌ Statycznie linkować bez share source
  ⚠️ Modyfikacje LGPL kodu muszą być open

Plugin pod GPL / GPLv3:
  ✓ Forknąć — TYLKO jeśli też GPL
  ❌ NIE MOŻNA sprzedawać closed-source
  ❌ Cały Twój kod musi być GPL (viral effect)
  ✓ Możesz świadczyć usługi support paid
```

**99% open source synthów to GPL.** To NIE jest przypadek — autorzy chcą żeby ich praca pozostała wolna. Jeśli forknesz GPL synth i sprzedajesz closed-source — **łamiesz prawo**.

## Klasyfikacja licencji

| Licencja | Komercja closed-source | Sprzedaż | Modyfikacja | Atrybucja | Copyleft |
|----------|------------------------|----------|-------------|-----------|----------|
| **MIT** | ✅ tak | ✅ tak | ✅ tak | wymagana | brak |
| **BSD-2/3-Clause** | ✅ tak | ✅ tak | ✅ tak | wymagana | brak |
| **Apache 2.0** | ✅ tak | ✅ tak | ✅ tak | wymagana | brak (patent grant) |
| **ISC** | ✅ tak | ✅ tak | ✅ tak | wymagana | brak |
| **Boost** | ✅ tak | ✅ tak | ✅ tak | minimalna | brak |
| **Unlicense / CC0** | ✅ tak | ✅ tak | ✅ tak | brak | brak (public domain) |
| **MPL 2.0** | ⚠️ tak* | ✅ tak | ✅ tak | wymagana | per-file copyleft |
| **LGPL 2.1/3** | ⚠️ dynamic only | ⚠️ z warunkami | ⚠️ tak* | wymagana | weak copyleft |
| **GPL 2/3** | ❌ nie | ❌ nie | ✅ tak (jako GPL) | wymagana | strong copyleft |
| **AGPL 3** | ❌ nie | ❌ nie | ✅ tak (jako AGPL) | wymagana | strongest copyleft |
| **Custom non-comm** | ❌ nie | ❌ nie | ⚠️ varies | tak | varies |

\*MPL: zmiany w plikach MPL muszą być open, ale Twój kod może być closed
\*LGPL: zmiany w bibliotece LGPL muszą być open, Twój kod może być closed (jeśli dynamic link)

## Frameworki dla rozwoju komercyjnego

### iPlug2 — najlepszy free framework dla komercji ⭐

**Licencja:** zlib (permisywna, podobna do MIT)
**Repo:** github.com/iPlug2/iPlug2
**Status 2026:** dojrzały, aktywnie rozwijany

**Co możesz zrobić:**
- ✅ Forknąć
- ✅ Sprzedawać komercyjnie (bez royalty)
- ✅ Closed-source forki
- ✅ Modyfikować bez share back
- ✅ Linkować statycznie

**Dlaczego idealny:**
- Wsparcie VST3, AU, AAX, web (WAM)
- Cross-platform (Win, macOS, iOS)
- Mały binary footprint
- Sprawdzony — Auburn Sounds, Cut Through Recordings, wiele firm używa
- Lekki, szybki kompilacja

```bash
git clone --recursive https://github.com/iPlug2/iPlug2.git
cd iPlug2/Examples
# Skopiuj IPlugEffect jako swój nowy projekt
```

### DPlug (D language) — Boost license

**Licencja:** Boost Software License (super permisywna)
**Repo:** github.com/AuburnSounds/Dplug

**Co możesz:**
- ✅ Wszystko co z MIT, plus:
- ✅ Brak wymagania atrybucji w pliku binarnym (różni się od MIT)
- ✅ Stosowane przez Auburn Sounds (komercyjne wtyczki)

**Język:** D (nie C++) — niche, ale pluginy są niewielkie i szybkie.

### CLAP framework — MIT ⭐

**Licencja:** MIT
**Repo:** github.com/free-audio/clap

**Co to:** Modern open standard dla pluginów (alternatywa VST3, AU). MIT licencja całego SDK.

**Status 2026:** Wsparcie w Bitwig, Reaper, FL Studio. Rośnie. Wybór nowoczesnych developerów.

**Co możesz:**
- ✅ Pełna swoboda — MIT
- ✅ Można sprzedawać komercyjnie
- ✅ Brak royalty

```bash
git clone https://github.com/free-audio/clap-juce-extensions.git
# Ten dodatek pozwala JUCE plugin eksportować do CLAP
```

### DPF (DISTRHO Plugin Framework) — ISC

**Licencja:** ISC (jak MIT)
**Repo:** github.com/DISTRHO/DPF
**Status:** Stable, solid

**Co możesz:**
- ✅ Komercja, modyfikacja, closed-source
- ✅ Cross-platform
- ✅ Wsparcie VST2/3, AU, LV2, JACK, CLAP

**Niche:** popularny wśród Linux audio, ale działa wszędzie.

### nih-plug (Rust) — ISC

**Licencja:** ISC (jak MIT)
**Repo:** github.com/robbert-vdh/nih-plug

**Co to:** Modern Rust framework dla pluginów. Memory safe.

**Status 2026:** Wciąż rozwijany, ale używany do komercyjnych wtyczek.

### JUCE — pułapka licencji

**JUCE** ma **dual license**:
- **GPL v3** (free) — Twoja wtyczka MUSI być GPL też
- **Komercyjna** — $35-130/mc subscription

Czyli **JUCE w wersji free NIE jest dobry dla closed-source komercji!** Musisz kupić licencję ($35/mc Indie pozwala na revenue do określonego limitu).

**Wyjątek:** JUCE Personal/Education jest free dla revenue < $50k/rok — wystarczy dla bootstrapping.

### VST3 SDK — Steinberg dual license

**Steinberg** udostępnia VST3 SDK pod:
- **GPL v3** — open source
- **Steinberg Proprietary License** — free dla komercyjnych closed-source!

Tak więc VST3 SDK **MOŻNA** używać do closed-source komercji, ale musisz akceptować Steinberg License (atrybucja "VST3" jako trademark Steinberg, brak wykorzystania w konkurencyjnych SDK).

## Konkretne open-source pluginy z permisywnymi licencjami

### Reverb / Delay

**Dragonfly Reverb** (Reverb suite)
- **Licencja:** GPL 3 ❌ (nie do closed-source)
- Algorytmy permisywne (z Faust)

**Aether** (algoritmic reverb)
- Licencja: GPL ❌

**Klangschatten** lub forki:
- Sprawdzaj per repo

**Element Plugins / KX Studio:**
- Większość GPL ❌

**MVerb** (Martin Eastwood)
- **Licencja:** GPL ❌

**Ratatouille / community reverb chowdhury:**
- **chowdsp_utils** — **BSD-3** ✅ (DSP utilities, możesz używać w komercji!)

### EQ / Filter

**Dolce QQ** (parametric EQ)
- Licencja: GPL ❌

**Three Body Technology free EQ examples:**
- Niektóre BSD/MIT ✅

**Vital filter algorithms** (z Vital open source):
- GPL ❌

### DSP Libraries (najbardziej wartościowe!)

**chowdsp_utils** ⭐
- **Licencja:** BSD 3-Clause ✅
- Repo: github.com/Chowdhury-DSP/chowdsp_utils
- **Co to:** Najlepsza darmowa biblioteka DSP dla JUCE
- **Zawiera:** filtry, IIR designs, oversampling, modulation, plugin utilities
- **Komercja:** ✅ Pełna swoboda (BSD)

**Q DSP Library** (cycfi/q)
- **Licencja:** MIT ✅
- Repo: github.com/cycfi/q
- Modern C++17 DSP, header-only
- ✅ Komercja bez ograniczeń

**RTNeural** (neural networks dla audio real-time)
- **Licencja:** BSD-3 ✅
- Repo: github.com/jatinchowdhury18/RTNeural
- Używane w komercyjnych ML-based pluginach (Neural Amp Modeler bazuje na podobnym)
- ✅ Pełna swoboda

**KFR (Kotoshenko's Fast Realtime)**
- **Licencja:** GPL OR Commercial
- ⚠️ GPL = open source projekty, commercial = $$ subscription

**FFTW** (Fastest Fourier Transform in the West)
- **Licencja:** GPL OR Commercial ($)
- ⚠️ GPL = problem dla closed source
- ✅ Alternatywa: **PocketFFT**, **FFTS**, **muFFT**, **kissfft** (BSD)

**KissFFT**
- **Licencja:** BSD ✅
- Mała, prosta, header-only
- ✅ Świetne dla komercji

**JUCE dsp module** — JUCE license (problem)
**Apple Accelerate / vDSP** — Apple SDK (free dla macOS apps)
**Intel IPP** — free dla wszystkich (Intel)

**fmt** (formatting)
- **Licencja:** MIT ✅

**spdlog** (logging)
- **Licencja:** MIT ✅

**nlohmann/json**
- **Licencja:** MIT ✅

### Synthesis primitives

**STK (Synthesis ToolKit)**
- **Licencja:** custom permisywna (jak BSD) ✅
- Repo: github.com/thestk/stk
- Klasyczne algorytmy synthesizers (oscillators, filters, physical modeling)
- ✅ Komercja OK

**SoundTouch** (pitch shifting, time stretching)
- **Licencja:** LGPL ⚠️
- Można w komercji z dynamic linking
- Lub **kup commercial license** od autora

**Rubber Band Library** (pitch/time)
- **Licencja:** GPL OR Commercial $$$
- ⚠️ GPL trap dla komercji

**Soundpipe** (DSP modules)
- **Licencja:** MIT ✅
- Repo: github.com/PaulBatchelor/Soundpipe
- Setki algorytmów DSP

**Faust** (DSL + standard library)
- **Licencja:** specyficzna ✅
- Generowany kod jest pod **TWOJĄ** licencją (możesz wybrać MIT/komercyjna)
- Standard library (`stdfaust.lib`) ma faust-specific clarification — generowany kod nie wymaga GPL

### Plugin Templates / Boilerplate

**pamplejuce** (Sudara) ⭐
- **Licencja:** MIT ✅
- Repo: github.com/sudara/pamplejuce
- **Co to:** Modern JUCE template z CMake, GitHub Actions, signing setup
- ✅ Komercja, ale plugin sam wciąż używa JUCE (więc JUCE license dotyczy)

**JUCE_CMake_Plugin_Template** (różne forki MIT)
- ✅ MIT — sam template, ale uwaga na JUCE underneath

**iPlug2 Examples** (oficjalne)
- ✅ zlib — pełna komercja

**DPF Examples**
- ✅ ISC — pełna komercja

### Specjalistyczne komponenty (BSD/MIT)

**Eigen** (linear algebra) — MPL2 ✅ (mostly OK dla komercji)
**ImGui** (GUI w grach, można w pluginach) — MIT ✅
**SoLoud** (audio engine, czasem używane jako baza) — Zlib ✅
**Choc** (utility headers, JUCE alternatives) — ISC ✅ (Cmajor team)
**SymbolicSummary** — varies
**libsamplerate** — BSD ✅
**libsndfile** — LGPL ⚠️ (dynamic OK)
**Tracktion Engine** — JUCE-based, GPL ❌

### Vital Synth (case study)

**Vital** (Matt Tytel) — popularny wavetable synth.

- **Code:** **GPL v3** ❌
- **Plugin do użytku:** free + paid premium content
- **Co możesz** legalnie zrobić:
  - Forknąć kod (twój fork też GPL)
  - Sprzedawać support / shaping serwis
  - Tworzyć preset packs (te są poza GPL)
  - **NIE** sprzedawać forku jako closed-source

**Dlaczego ważne:** wielu zaczynających myli "free" z "MIT". Vital jest **free do użytku** ale jego kod jest **GPL** — nie możesz zbudować na nim closed-source biznesu.

### Surge XT (synth)

- **Licencja:** GPL v3 ❌
- Świetny synth, ale **tylko jako baza dla GPL projektów**

### ZynAddSubFX

- **Licencja:** GPL v2 ❌

### Argotlunar (granular delay)

- **Licencja:** MIT ✅ ⭐
- Repo: github.com/mhetrick/argotlunar (lub pamphlet)
- **Możesz** rozbudować i sprzedać komercyjnie

### Wolf Shaper / Wolf Spectrum

- **Licencja:** GPL ❌

## Strategie wykorzystywania open source w komercji

### Strategia 1: Tylko biblioteki DSP z permisywną licencją

Najbezpieczniejsza droga:
```
Twój kod (closed, własność Twoja)
   ↓ używa
Permisywne biblioteki DSP (chowdsp_utils, RTNeural, KissFFT)
   ↓ na bazie
Permisywny framework (iPlug2 lub CLAP)
```

Przykład:
- Plugin: Twój własny kod (closed)
- Framework: **iPlug2** (zlib)
- DSP: **chowdsp_utils** (BSD), **RTNeural** (BSD), **STK** (BSD)
- FFT: **KissFFT** (BSD)
- Logging: **spdlog** (MIT)

→ **Wszystko legalne dla komercji.**

### Strategia 2: JUCE + komercyjna licencja

```
Twój kod (closed)
   ↓ na bazie
JUCE (commercial license $35-130/mc)
   ↓ + permisywne libraries (chowdsp_utils itp.)
```

Najpopularniejszy wybór profesjonalnych dev-ów. Cena licencji = budget item.

### Strategia 3: Dual licensing własnego pluginu

Jeśli chcesz sprzedawać i jednocześnie udostępnić kod:
- **Free wersja:** GPL (open source community)
- **Commercial wersja:** Twoja proprietary license (płatna)

Wymaga że **Ty** trzymasz copyright (wszyscy contributors muszą podpisać CLA — Contributor License Agreement).

Tak działa np. **Qt** (Trolltech/Digia/Nokia/now Qt Company).

### Strategia 4: Studiowanie GPL bez kopiowania

**Możesz studiować** GPL kod (Vital, Surge) i pisać własny od zera z tymi samymi koncepcjami matematycznymi. Algorytmy DSP nie są copyright-able (są matematyką), implementacja jest.

```
Studiuj Vital wavetable engine — koncepcje
   ↓
Zaimplementuj samodzielnie w czystym C++
   ↓
Twój kod = Twoja licencja (MIT, closed, cokolwiek)
```

⚠️ **Uwaga:** clean room implementation. Bezpieczniej, gdy ktoś inny implementuje na podstawie Twojej specyfikacji.

### Strategia 5: License audit przed sprzedażą

Przed sprzedażą plugin:

```bash
# Audit wszystkich dependencies
1. Lista bibliotek + licencji
2. Sprawdź czy każda licencja pozwala na komercję
3. Dodaj wymagane atrybucje (LICENSE.txt w bundlu)
4. Sprawdź czy żadna nie wymaga otwarcia kodu
5. Wyklucz GPL/AGPL libs (lub rezygnuj z komercji)
```

**Tools:**
- **FOSSA** — automated license compliance scanning
- **WhiteSource / Mend** — enterprise solution
- **License Finder** (open source)
- **scancode-toolkit** (open source)

## Lista TOP open source projektów z permisywną licencją (2026)

### Frameworki (komercja-friendly):
1. **iPlug2** — zlib license — github.com/iPlug2/iPlug2
2. **DPlug** — Boost license — github.com/AuburnSounds/Dplug
3. **DPF** — ISC — github.com/DISTRHO/DPF
4. **nih-plug** (Rust) — ISC — github.com/robbert-vdh/nih-plug
5. **CLAP SDK** — MIT — github.com/free-audio/clap

### DSP Libraries:
1. **chowdsp_utils** — BSD-3 — Chowdhury DSP
2. **Q DSP Library** — MIT — cycfi/q
3. **RTNeural** — BSD-3 — for ML in audio
4. **STK** — permisywna — Stanford
5. **KissFFT** — BSD — szybkie FFT
6. **PocketFFT** — BSD — alternative FFT
7. **Soundpipe** — MIT — algorithm collection

### Utility libs:
1. **fmt** — MIT
2. **spdlog** — MIT
3. **nlohmann/json** — MIT
4. **Choc** — ISC (Cmajor team — utility headers, file io, audio file readers)

### Templates / Starters:
1. **pamplejuce** — MIT (template, JUCE underneath = JUCE license)
2. **iPlug2 Examples** — zlib

### Vintage/Legacy good projects:
- **JSFX scripts** (Reaper) — większość permisywne lub public domain
- Niektóre **Pure Data** patches — BSD (Pure Data sam jest BSD)

## Praktyczny workflow: zbuduj komercyjny EQ od zera

```
KROK 1: Wybierz framework
→ iPlug2 (zlib) — pełna swoboda

KROK 2: Wybierz DSP library
→ chowdsp_utils (BSD) — gotowe filtry IIR

KROK 3: Stwórz projekt
git clone --recursive https://github.com/iPlug2/iPlug2.git
cp -r iPlug2/Examples/IPlugEffect MyEQ
cd MyEQ
# edit config.h, project files

KROK 4: Implementuj DSP
#include "chowdsp_utils/chowdsp_filters.h"
chowdsp::IIRFilter<2, float> filter;
filter.calcCoefsLowPass(freq, q, sampleRate);
// w processBlock:
buffer[i] = filter.processSample(buffer[i]);

KROK 5: License compliance
- LICENSE.txt w bundlu zawiera:
  * iPlug2 license (zlib)
  * chowdsp_utils license (BSD)
  * VST3 SDK Steinberg License notice
  * Twój copyright

KROK 6: Build + sprzedaż
- Code signing (Apple Developer, Windows EV cert)
- Plugin Boutique submission
- Twoja własna strona z licencjonowaniem
```

**Efekt:** legalna, komercyjna wtyczka 100% Twoja własność.

## License compatibility matrix

Czy licencje są kompatybilne? (Możesz mieszać kod):

```
                MIT  BSD  Apache  ISC  zlib  Boost  LGPL  GPL  AGPL
MIT             ✓    ✓    ✓       ✓    ✓    ✓     ⚠    ⚠   ⚠
BSD-3           ✓    ✓    ✓       ✓    ✓    ✓     ⚠    ⚠   ⚠
Apache 2.0      ✓    ✓    ✓       ✓    ✓    ✓     ⚠*   ⚠*  ⚠*
ISC             ✓    ✓    ✓       ✓    ✓    ✓     ⚠    ⚠   ⚠
zlib (iPlug2)   ✓    ✓    ✓       ✓    ✓    ✓     ⚠    ⚠   ⚠
Boost (DPlug)   ✓    ✓    ✓       ✓    ✓    ✓     ⚠    ⚠   ⚠
LGPL            ⚠    ⚠    ⚠       ⚠    ⚠    ⚠     ✓    ⚠   ⚠
GPL             ⚠    ⚠    ⚠       ⚠    ⚠    ⚠     ⚠    ✓   ⚠
AGPL            ⚠    ⚠    ⚠       ⚠    ⚠    ⚠     ⚠    ⚠   ✓

⚠ = Można TYLKO jeśli cały produkt = GPL/LGPL/AGPL
✓ = Pełna kompatybilność
* = Apache 2.0 niekompatybilny z GPL v2 (kompatybilny z GPL v3)
```

## Najczęstsze błędy

### ❌ "Plugin jest free więc mogę sprzedawać forka"
NIE. **Free** ≠ **MIT**. Większość free pluginów to GPL.

### ❌ "Sklonuję Vital i zmienię nazwę"
Vital jest GPL. Twój fork też musi być GPL → **nie możesz** sprzedawać closed-source.

### ❌ "JUCE jest free więc komercja OK"
JUCE Personal jest free do $50k revenue/rok. Powyżej — **musisz kupić licencję** ($35-130/mc).

### ❌ "Skopiuję trochę GPL kodu, nikt nie zauważy"
Kopiowanie GPL kodu = naruszenie copyright. Jeśli ktoś to wykryje (a wielu autorów monitoruje GitHuba i marketplace) — **DMCA takedown**, sprawa sądowa.

### ❌ "Atrybucja w EULA wystarczy"
**MIT/BSD** wymaga zachowania **pełnego tekstu licencji** w produkcie (zwykle LICENSE.txt w bundlu lub w "About" w plugin GUI).

### ❌ "Wezmę Faust generated code i sprzedam"
Faust generuje C++ pod **Twoją** licencją, ALE: standard library `stdfaust.lib` ma swoje warunki. Sprawdź dla każdej funkcji którą importujesz.

## Praktyczna reguła: ZAWSZE sprawdź licencję!

Przed wykorzystaniem ANY open source kodu w komercyjnym projekcie:

1. **Sprawdź plik LICENSE w repo** (nie tylko README!)
2. **Sprawdź header każdego pliku** (czasem różne licencje per plik)
3. **Sprawdź subdependencies** (rekursywnie)
4. **Skonsultuj z prawnikiem** dla projektów >$10k revenue
5. **Dokumentuj** wszystkie używane licencje w project README

## Rekomendowany stack dla komercji w 2026

### "Indie producer, niski budżet, zero royalty"
```
Framework:       iPlug2 (zlib)
DSP utilities:   chowdsp_utils (BSD)
FFT:             KissFFT (BSD)
Math:            Eigen (MPL2)
Logging:         spdlog (MIT)
JSON:            nlohmann/json (MIT)
Build:           CMake (BSD)
CI/CD:           GitHub Actions (free dla open source / paid commercial)

Total cost:      $0 (frameworks) + Apple Dev $99/yr + Win EV cert $400/yr
```

### "Premium plugin maker, robust ecosystem"
```
Framework:       JUCE Indie/Pro ($35-130/mc subscription)
DSP utilities:   chowdsp_utils (BSD) + JUCE dsp module
GUI:             JUCE Components + LookAndFeel
ML/AI:           RTNeural (BSD) + ONNX Runtime (MIT)
Distribution:    iLok (PACE) — paid

Total cost:      $35-130/mc + iLok $295/yr + Apple Dev $99/yr + Win EV $400/yr
```

### "AAX + Pro Tools (premium target)"
```
Framework:       JUCE (Pro license required for AAX) lub iPlug2
AAX SDK:         Avid Developer Account ($295/yr)
Anti-piracy:     iLok obowiązkowe
Distribution:    Plugin Alliance, Native Instruments (curated)

Total cost:      $$$ (significant upfront)
```

## Linki

- **OSI license list:** opensource.org/licenses
- **Choose a License:** choosealicense.com (interactive)
- **TLDR Legal:** tldrlegal.com (proste tłumaczenia)
- **iPlug2:** github.com/iPlug2/iPlug2
- **chowdsp_utils:** github.com/Chowdhury-DSP/chowdsp_utils
- **CLAP:** github.com/free-audio/clap
- **DPF:** github.com/DISTRHO/DPF
- **DPlug:** github.com/AuburnSounds/Dplug
- **RTNeural:** github.com/jatinchowdhury18/RTNeural

## Disclaimer

**Powyższe NIE jest poradą prawną.** Licencje ewoluują, sprawy sądowe ustanawiają precedensy. Dla komercyjnych projektów z dużym budżetem — **skonsultuj z prawnikiem specjalizującym się w open source / IP law** w Twojej jurysdykcji.

W razie wątpliwości:
- **Rezygnuj** z biblioteki o niejasnej licencji
- **Wybieraj** sprawdzone permisywne (MIT/BSD/Apache)
- **Dokumentuj** każdą decyzję licencyjną w project log
- **Nie kopiuj** GPL kodu nawet "tylko kawałka"

## Następne kroki

- **Rozdział 09** — Dystrybucja i instalator (license enforcement, anti-piracy)
- **Rozdział 10** — Marketing i sprzedaż
- **Rozdział 02** — Frameworki i języki (deep dive iPlug2 vs JUCE)
