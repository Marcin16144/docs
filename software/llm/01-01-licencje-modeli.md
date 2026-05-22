# Licencje LLM — co możesz, czego nie możesz (2026)

## TL;DR — szybka tabela

| Model | Licencja | Komercja | Resale | Continued Pre-training | Uwagi |
|-------|----------|----------|--------|------------------------|-------|
| **Llama 4** | Llama Community License | ✅ tak* | ⚠️ ograniczone | ✅ tak | *Limit 700M MAU |
| **Llama 3.x** | Llama Community License | ✅ tak* | ⚠️ ograniczone | ✅ tak | *Limit 700M MAU |
| **Mistral 7B / Mixtral** | Apache 2.0 | ✅ tak | ✅ tak | ✅ tak | Najbardziej liberalna |
| **Mistral Large** | Mistral Research / Commercial | ❌/✅ | ✅ płatna | ✅ tak | Wymaga licencji komercyjnej |
| **Qwen 2.5 / 3** | Apache 2.0 (większość) | ✅ tak | ✅ tak | ✅ tak | 72B+ wymaga zgody |
| **DeepSeek V3 / R1** | MIT (model) + custom | ✅ tak | ✅ tak | ✅ tak | Bardzo liberalne |
| **Gemma 2 / 3** | Gemma Terms of Use | ✅ tak | ⚠️ ograniczone | ✅ tak | Custom Google license |
| **Phi-3 / Phi-4** | MIT | ✅ tak | ✅ tak | ✅ tak | Microsoft, bardzo liberalne |
| **Falcon 3 / 180B** | Apache 2.0 / TII Falcon | ✅ tak | ✅ tak | ✅ tak | TII (UAE) |
| **OLMo 2** | Apache 2.0 | ✅ tak | ✅ tak | ✅ tak | AI2, w pełni open |
| **Pythia** | Apache 2.0 | ✅ tak | ✅ tak | ✅ tak | EleutherAI, research |
| **GPT-NeoX / GPT-J** | Apache 2.0 | ✅ tak | ✅ tak | ✅ tak | EleutherAI |
| **Bloom** | BLOOM RAIL License | ✅ tak* | ⚠️ ograniczone | ✅ tak | *Use restrictions |
| **Yi 1.5** | Apache 2.0 | ✅ tak | ✅ tak | ✅ tak | 01.AI |
| **Command R/R+** | CC-BY-NC | ❌ NIE | ❌ NIE | ❌ NIE | Tylko research! |

**Komercja** = używanie w produktach komercyjnych
**Resale** = sprzedawanie modelu / pochodnych jako produktu
**Continued Pre-training** = trenowanie dalej na własnych danych

## Trzy kategorie licencji

### 1. Apache 2.0 / MIT (najbardziej liberalne)
**Możesz prawie wszystko:**
- ✅ Komercyjne użycie
- ✅ Modyfikacja
- ✅ Dystrybucja
- ✅ Sublicensing
- ✅ Sprzedaż jako produkt
- ✅ Continued pre-training i fine-tuning
- ✅ Closed-source pochodne

**Ograniczenia:**
- Musisz zachować copyright notice
- Apache 2.0: musisz zaznaczyć zmiany

### 2. Custom Source-Available Licenses (np. Llama, Gemma)
**Generalnie pozwalają komercję, ALE z restrykcjami:**
- ⚠️ Mogą być limity skali (np. 700M MAU dla Llamy)
- ⚠️ Acceptable Use Policy (zakazane zastosowania)
- ⚠️ Wymaganie atrybucji
- ⚠️ Restrykcje na trenowanie konkurencyjnych modeli
- ⚠️ Możliwy trademark restrictions

### 3. Non-Commercial / Research Only
**NIE możesz używać komercyjnie:**
- ❌ CC-BY-NC (Cohere Command, niektóre research modele)
- ❌ Custom non-commercial licenses
- ❌ Llama 2 dla EU (kiedyś, już nie aktualne)

## Szczegółowo — najważniejsze modele

### Meta Llama (4, 3.x)

**Licencja:** Llama Community License Agreement

**✅ Możesz:**
- Używać komercyjnie do prawie wszystkiego
- Continued pre-training na własnych danych
- Fine-tuning (LoRA, QLoRA, FFT)
- Wdrażać w aplikacjach komercyjnych
- Tworzyć i sprzedawać produkty oparte na modelu

**⚠️ Ograniczenia:**
- **MAU limit**: Jeśli aplikacja ma >700M aktywnych użytkowników miesięcznie — wymagasz dodatkowej licencji od Meta
- **Konkurenci**: Nie możesz używać do trenowania innych modeli LLM (z wyjątkiem fine-tuningu Llama)
- **Atrybucja**: Musisz wskazać "Built with Llama"
- **AUP**: Acceptable Use Policy — zakazane: hate speech, broń, etc.
- **Naming**: Pochodne modele muszą zaczynać się od "Llama" (np. "Llama-3.1-Polish")

**Sprzedaż:** Możesz sprzedawać produkty (API, aplikacje), trudniej sprzedawać sam model jako data product (zwłaszcza dystrybucja wag może wymagać zgody Meta).

**Continued pre-training:** ✅ Tak, w pełni dozwolone.

### Mistral

**Open weights (Apache 2.0):** Mistral 7B, Mixtral 8x7B, Mixtral 8x22B, Mistral Nemo
- Pełna swoboda — jak Apache 2.0
- ✅ Komercja, resale, continued pre-training

**Mistral Research License:** Mistral Large, Codestral
- ❌ NIE komercyjnie z tej licencji
- Wymaga **commercial license** od Mistral AI

### Qwen (Alibaba)

**Apache 2.0** — większość modeli (Qwen 2.5 0.5B-14B, niektóre 72B):
- ✅ Pełna swoboda

**Tongyi Qianwen License** — niektóre większe modele:
- ⚠️ Wymaga zgody dla >100M MAU
- Ogólnie liberalna

### DeepSeek

**MIT License (model)** + DeepSeek License (use):
- ✅ Wagi modelu pod MIT (najbardziej liberalna)
- ⚠️ Use case restrictions (AUP)
- ✅ Komercja, resale, continued pre-training
- ✅ Można sprzedawać pochodne

**DeepSeek R1** (reasoning) — najnowszy hit 2025:
- Same liberal license
- Świetny dla komercyjnych zastosowań

### Google Gemma

**Gemma Terms of Use:**
- ✅ Komercyjne użycie
- ✅ Continued pre-training
- ⚠️ Acceptable Use Policy
- ⚠️ Restricted use list (medyczne diagnozy bez zatwierdzenia, etc.)
- ⚠️ Atrybucja wymagana

### Microsoft Phi

**MIT License** (Phi-3, Phi-4):
- ✅ Najbardziej liberalna licencja
- ✅ Komercja, resale, continued pre-training
- Bardzo dobre dla małych modeli (3B, 7B, 14B)

### EleutherAI (Pythia, GPT-NeoX, GPT-J)

**Apache 2.0:**
- ✅ Pełna swoboda
- Stary, ale w pełni open
- Dobre dla research / nauki treningu

### TII Falcon

**Falcon 3 (1B-10B):** Falcon-LLM License (custom, ale liberalna)
- ✅ Komercja, resale, continued pre-training
- Bardzo permisive

**Falcon 180B:** TII Falcon LLM License
- ✅ Komercja
- ⚠️ Hosting jako serwis (>$1M revenue) wymaga osobnej licencji

### AI2 OLMo 2

**Apache 2.0:**
- ✅ Pełna swoboda
- W pełni open: dane, kod, checkpointy
- Najlepsze dla research i transparency

### BigScience BLOOM

**BLOOM RAIL License** (Responsible AI License):
- ✅ Komercyjne użycie
- ⚠️ Use case restrictions (medyczna diagnoza, autonomous weapons, etc.)
- Restrykcje są specyficzne — przeczytaj uważnie

## Modele zamknięte (API only)

Tych **NIE MOŻESZ** distribute, ale używanie API jest legalne:

| Model | Dostawca | Licencja użycia |
|-------|----------|-----------------|
| **Claude** (Opus, Sonnet, Haiku) | Anthropic | Anthropic Usage Policies |
| **GPT** (GPT-5, GPT-4o) | OpenAI | OpenAI Usage Policies |
| **Gemini** | Google | Gemini API Terms |
| **Cohere Command** (API) | Cohere | Cohere Terms |

**Co możesz z API:**
- ✅ Budować aplikacje komercyjne
- ✅ Sprzedawać aplikacje
- ✅ Dane wyjściowe — TY jesteś właścicielem (sprawdź szczegóły)

**Czego NIE możesz:**
- ❌ Pobrać modelu lokalnie
- ❌ Trenować pochodnych ("używać outputu do trenowania konkurencyjnych modeli" — zazwyczaj zakazane)
- ❌ Reverse engineering

**Wyjątek:** OpenAI GPT-4o-mini fine-tuning — możesz trenować, ale używać tylko via OpenAI API. Anthropic Haiku fine-tuning podobnie.

## Najlepsze opcje dla różnych scenariuszy

### "Chcę zbudować i sprzedać produkt komercyjny"

**Najlepiej (najbardziej liberalne):**
1. **DeepSeek V3 / R1** — MIT, świetna jakość
2. **Mistral 7B / Mixtral** — Apache 2.0, dojrzałe
3. **Phi-4** — MIT, mały i szybki
4. **Qwen 2.5** — Apache 2.0, multilingual

**Dobrze, ale uważaj:**
5. **Llama 4** — bardzo dobra jakość, ale 700M MAU limit i atrybucja
6. **Gemma 3** — dobra jakość, AUP restrictions

**Unikaj:**
- Cohere Command (CC-BY-NC = research only)
- Stable Diffusion XL Turbo (custom non-commercial)

### "Chcę continued pre-training na danych prawniczych"

**Najlepiej:**
1. **OLMo 2** — w pełni open, perfekcyjne dla research
2. **DeepSeek V3** — najlepsza baza w 2026
3. **Llama 4** — sprawdzona, dobra jakość
4. **Mistral 7B / Mixtral** — Apache 2.0

**Wszystkie te licencje pozwalają na continued pre-training. Wybór zależy od:**
- Rozmiar modelu (compute)
- Język (multilingual?)
- Domena (kod? math? general?)

### "Chcę sprzedawać sam model (data product)"

**Najlepiej:**
1. **Apache 2.0 modele** — Mistral 7B, Mixtral, OLMo, Pythia, Phi-4, DeepSeek
2. **MIT modele** — Phi, niektóre custom

**Trudniejsze:**
- **Llama** — możesz sprzedawać produkty oparte na Llama, ale sprzedaż samych wag jako produktu to szara strefa. Lepiej skonsultować z prawnikiem.
- **Gemma** — podobnie

### "Chcę open source projekt z modelem"

**Wybierz Apache 2.0 model:**
- Twój kod i fine-tuned model mogą być Apache 2.0
- Jasna ścieżka prawna dla kontrybutorów

## Co to dokładnie oznacza "Continued Pre-training"?

**Continued Pre-training (CPT)** = bierzesz pretrenowany model i trenujesz go DALEJ na nowych danych (np. polskim korpusie, danych prawniczych, kodzie).

```
Llama 3 8B (pretrained)
     ↓
[Continued pre-training na 50B tokenów polskich tekstów]
     ↓
Polski-Llama-3-8B
     ↓
[SFT + DPO]
     ↓
Polski-Llama-3-8B-Instruct
```

**Wszystkie wymienione open source modele pozwalają na CPT.** Ograniczenia są tylko na:
- Skalę dystrybucji (Llama 700M MAU)
- Use case (AUP)
- Sprzedaż samego modelu

## Praktyczne zasady prawne

### Krok 1: Przeczytaj licencję
Tak, naprawdę. To 2-10 stron tekstu, ale ma znaczenie.

### Krok 2: Sprawdź AUP (Acceptable Use Policy)
Większość licencji ma AUP, który zakazuje:
- Hate speech, harassment
- Generowania CSAM
- Autonomous weapons
- Medycznych diagnoz bez wykwalifikowanego nadzoru
- Personal information mining
- Cyberattacks

### Krok 3: Atrybucja
- Apache 2.0: zachowaj copyright notice
- Llama: "Built with Llama"
- Gemma: "Built with Gemma"
- Większość: link do oryginalnej licencji

### Krok 4: MAU limits
Tylko dla Llamy (700M) i niektórych Qwen. Większość firm nigdy tego nie osiąga.

### Krok 5: Skonsultuj z prawnikiem
Jeśli budujesz produkt, który chcesz sprzedawać → skonsultuj. Mała inwestycja, duża ochrona.

## Datasety — też mają licencje!

Ważne: continued pre-training wymaga **danych z odpowiednimi licencjami**.

### Public datasety (commercial-friendly)
- **The Pile** — niejednorodne licencje
- **C4** (Common Crawl filtered) — nieoznaczone, technicznie ryzykowne
- **FineWeb-Edu** (HF) — Apache 2.0 (filtered CC)
- **Dolma** (AI2) — w pełni open
- **OpenWebText** — Apache 2.0
- **Wikipedia** — CC-BY-SA (musisz zachować share-alike!)
- **ArXiv** — różne (większość OK do research, komercja niejasna)
- **The Stack v2** — code, w większości permissive licenses

### Datasety NIE do komercji bez licencji
- **Books3** — używane w wielu modelach, ale prawnie ryzykowne (wycofane z większości publikacji)
- **News articles** — copyright (niedozwolone bez licencji)
- **Reddit data** — Reddit zmienił licencję, teraz wymaga umowy
- **Twitter / X data** — wymaga umowy

### Praktyka
1. **Zacznij od FineWeb-Edu, Dolma** — najczystsze prawnie
2. **Dodaj swoje proprietary data** — to TY masz prawa
3. **Unikaj scraping bez zgody** — coraz bardziej ryzykowne prawnie
4. **Synthetic data** — generuj sam (ale uważaj na AUP modeli, których używasz do generacji!)

## Output models — co z odpowiedziami modeli?

### Z modeli open source (Llama, Mistral, etc.):
- ✅ Wyjścia są TWOJE
- ✅ Możesz używać komercyjnie
- ✅ Możesz trenować inne modele na nich
- ⚠️ AUP nadal obowiązuje (nie generuj harmful content)

### Z API komercyjnych (Claude, GPT):
- ✅ Wyjścia są TWOJE (większość dostawców)
- ⚠️ NIE MOŻESZ trenować konkurencyjnych modeli na nich (Anthropic, OpenAI ToS)
- ✅ Możesz używać do produktów (oczywiście)
- ⚠️ Distillation do innych modeli — szara strefa, sprawdź ToS

## Najlepsze stack dla "build and sell" w 2026

### Opcja A: Pełny komfort prawny (Apache 2.0 / MIT)
```
Base model: Mistral 7B (Apache 2.0)
   lub:    Phi-4 (MIT)
   lub:    DeepSeek V3 distilled (MIT)
   lub:    OLMo 2 (Apache 2.0)
Fine-tune: Twoje dane → Twój własny adapter
Deploy:    vLLM / Ollama
Sprzedaż:  ✅ Jakkolwiek
```

### Opcja B: Najlepsza jakość z restrykcjami (Llama)
```
Base model: Llama 4 70B
Fine-tune: Twoje dane
Deploy:    vLLM
Sprzedaż:  ✅ Produkt OK (z atrybucją)
           ⚠️ MAU < 700M
           ⚠️ "Llama" w nazwie modelu
```

### Opcja C: API-based (zero distribution issues)
```
LLM:       Claude API / GPT API
RAG:       Twoja baza
Deploy:    Standardowy backend
Sprzedaż:  ✅ Aplikacja jako SaaS
           ❌ Nie sprzedajesz modelu
```

## Disclaimers

- Jestem AI, nie prawnikiem. **Nie traktuj tego jako porady prawnej.**
- Licencje ewoluują — zawsze sprawdź aktualny tekst na repo modelu.
- W razie wątpliwości → konsultacja z prawnikiem specjalizującym się w IP / open source.
- Dla aplikacji enterprise → due diligence przed deploy.

## Linki do oryginalnych licencji

- Llama: https://llama.com/license
- Mistral: github.com/mistralai (per repo)
- Apache 2.0: https://www.apache.org/licenses/LICENSE-2.0
- MIT: https://opensource.org/licenses/MIT
- Gemma: https://ai.google.dev/gemma/terms
- DeepSeek: github.com/deepseek-ai (per repo)
- Hugging Face — często link do licencji w modelu na HF Hub

## Quick decision tree

```
Czy chcesz tylko używać API?
├─ Tak → Anthropic / OpenAI / Google → ✅ Komercja OK
└─ Nie, chcę self-host
   ├─ Czy chcesz najwyższą jakość?
   │  └─ Llama 4 70B / DeepSeek V3 → ✅ ale uważaj na restrykcje
   ├─ Czy chcesz pełną swobodę prawną?
   │  └─ Apache 2.0 / MIT models (Mistral, Phi-4, OLMo, DeepSeek)
   ├─ Czy chcesz sprzedawać sam model?
   │  └─ Apache 2.0 / MIT only (nie Llama)
   └─ Czy chcesz continued pre-training?
      └─ Wszystkie open source modele OK
```
