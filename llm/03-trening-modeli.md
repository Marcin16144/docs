# Trening modeli LLM

## Etapy treningu nowoczesnego LLM

```
┌──────────────────┐
│  1. Pre-training │  ← Najdroższy etap (~95% kosztu)
│   (next token    │     Trenuje na ogromnych korpusach
│    prediction)   │     Daje "base model"
└────────┬─────────┘
         │
┌────────▼─────────┐
│  2. Supervised   │  ← Uczenie odpowiadania na instrukcje
│   Fine-Tuning    │     Dataset: pary (prompt, response)
│      (SFT)       │     Daje "instruct model"
└────────┬─────────┘
         │
┌────────▼─────────┐
│  3. Preference   │  ← RLHF / DPO
│   Optimization   │     Uczy się preferencji ludzkich
│   (RLHF / DPO)   │     Daje "chat/aligned model"
└──────────────────┘
```

## 1. Pre-training

### Cel
Nauczyć model przewidywania **następnego tokenu** na podstawie poprzednich.

```
Input:  "Stolicą Polski jest"
Target: " Warszawa"

Loss: -log P("Warszawa" | "Stolicą Polski jest")
```

### Datasets

Modele trenuje się na **bilionach tokenów** z różnorodnych źródeł:

| Źródło | Rozmiar | Uwagi |
|--------|---------|-------|
| **Common Crawl** | Petabajty | Web scraping, wymaga deduplikacji i filtrowania |
| **Wikipedia** | ~30GB | Wysoka jakość, wszystkie języki |
| **Books** | Setki GB | Books3, Project Gutenberg |
| **Code** | TB+ | GitHub, StackOverflow |
| **ArXiv** | ~100GB | Papers naukowe |
| **Reddit** | TB | Dialogi, Q&A |

### Skala obliczeniowa

| Model | Parametry | Tokeny | GPU-godziny |
|-------|-----------|--------|-------------|
| GPT-3 | 175B | 300B | ~3.6M (V100) |
| Llama 2 70B | 70B | 2T | ~1.7M (A100) |
| Llama 3 70B | 70B | 15T | ~6.4M (H100) |
| Llama 3.1 405B | 405B | 15T | ~30M+ (H100) |

Koszt treningu: dziesiątki milionów do setek milionów USD.

### Compute clusters

Trening wymaga tysięcy GPU połączonych szybkim interconnectem (np. NVLink, InfiniBand):
- Meta wytrenowała Llama 3 na klastrze 24 000 GPU H100
- xAI Grok-3 trenowano na klastrze 100 000+ GPU
- OpenAI/Microsoft używają klastrów Azure

## 2. Supervised Fine-Tuning (SFT)

### Cel
Nauczyć model **odpowiadania na instrukcje**. Base model po pre-trainingu nie umie rozmawiać — kontynuuje tekst.

### Format danych

```json
{
  "messages": [
    {"role": "system", "content": "Jesteś pomocnym asystentem."},
    {"role": "user", "content": "Jakie są stolice Skandynawii?"},
    {"role": "assistant", "content": "Stolicami Skandynawii są:\n- Oslo (Norwegia)\n- Sztokholm (Szwecja)\n- Kopenhaga (Dania)\n- Helsinki (Finlandia, choć Finlandia bywa kategoryzowana osobno)\n- Reykjavik (Islandia, jeśli wliczamy)"}
  ]
}
```

### Popularne datasety SFT

| Dataset | Rozmiar | Charakterystyka |
|---------|---------|-----------------|
| **OpenAssistant** | ~160k | Multilingual, open source |
| **ShareGPT** | ~90k | Konwersacje z ChatGPT |
| **Alpaca** | 52k | Wygenerowane przez GPT-3.5 |
| **Dolly 15k** | 15k | Hand-written przez Databricks |
| **UltraChat** | 1.5M | Wielotorowe rozmowy |

### Chat templates

Każdy model ma swój format konwersacji:

**Llama 3:**
```
<|begin_of_text|><|start_header_id|>system<|end_header_id|>
You are helpful.<|eot_id|>
<|start_header_id|>user<|end_header_id|>
Hi!<|eot_id|>
<|start_header_id|>assistant<|end_header_id|>
```

**Anthropic Claude:**
Format konwersacji obsługiwany jest przez API — wiadomości jako struktura JSON.

**ChatML (OpenAI, większość modeli open):**
```
<|im_start|>system
You are helpful.<|im_end|>
<|im_start|>user
Hi!<|im_end|>
<|im_start|>assistant
```

## 3. Preference Optimization

### Po co?
SFT daje model, który odpowiada — ale niekoniecznie w sposób, który ludzie preferują. Może być:
- Zbyt zwięzły lub zbyt rozwlekły
- Niepomocny ("nie wiem")
- Niebezpieczny (instruktaż jak coś szkodliwego)
- Niezgodny z oczekiwaniami

### RLHF (Reinforcement Learning from Human Feedback)

Klasyczna metoda OpenAI:

```
1. Zbierz preferencje:
   Pokaż 2 odpowiedzi → człowiek wybiera lepszą

2. Wytrenuj reward model (RM):
   RM(prompt, response) → score (1 liczba)

3. Optymalizuj LLM:
   PPO maksymalizuje RM(prompt, LLM(prompt))
   z regularyzacją KL od bazowego modelu
```

### DPO (Direct Preference Optimization)

Nowsza, prostsza metoda — pomija osobny reward model:

```
Dataset: (prompt, chosen, rejected)

Loss bezpośrednio uczy:
- zwiększać P(chosen | prompt)
- zmniejszać P(rejected | prompt)
```

DPO jest **łatwiejszy w implementacji** i często osiąga porównywalne wyniki do RLHF.

### Inne metody
- **RLAIF** — AI zamiast człowieka oznacza preferencje (Constitutional AI od Anthropic)
- **KTO** — Kahneman-Tversky Optimization
- **IPO** — Identity Preference Optimization
- **ORPO** — łączy SFT i DPO w jeden krok

## Constitutional AI (Anthropic)

Anthropic wprowadziło **Constitutional AI** — metodę treningu, w której model uczy się samodzielnie krytykować i poprawiać swoje odpowiedzi zgodnie z zestawem zasad ("konstytucją").

```
1. Model generuje odpowiedź
2. Model krytykuje własną odpowiedź pod kątem zasad konstytucji
3. Model poprawia odpowiedź
4. Trenujemy model na poprawionych odpowiedziach
```

To pozwala uniknąć kosztownego ręcznego oznaczania preferencji.

## Reasoning models (2025+)

Najnowsza generacja modeli (OpenAI o1/o3, DeepSeek R1, Claude z extended thinking) używa **trening na rozumowaniu**:

```
1. Model generuje długi "łańcuch myśli" (chain of thought)
2. Sprawdzamy poprawność końcowej odpowiedzi
3. Wzmacniamy łańcuchy prowadzące do poprawnych odpowiedzi
```

Efekt: znacznie lepsza wydajność na zadaniach matematycznych, kodowych, naukowych.

## Distributed Training

### Strategie równoległości

**Data Parallelism** — kopia modelu na każdym GPU, różne batche:
```
GPU 0: model + batch 1
GPU 1: model + batch 2
GPU 2: model + batch 3
GPU 3: model + batch 4
→ Sumowanie gradientów (all-reduce)
```

**Tensor Parallelism** — pojedyncza warstwa rozdzielona między GPU:
```
GPU 0: pierwsza połowa W
GPU 1: druga połowa W
→ Komunikacja przy każdej warstwie
```

**Pipeline Parallelism** — różne warstwy na różnych GPU:
```
GPU 0: warstwy 1-8
GPU 1: warstwy 9-16
GPU 2: warstwy 17-24
GPU 3: warstwy 25-32
```

**3D Parallelism** — kombinacja powyższych dla największych modeli.

### Frameworks
- **DeepSpeed** (Microsoft) — ZeRO optimizer
- **Megatron-LM** (NVIDIA) — tensor + pipeline parallelism
- **FSDP** (PyTorch) — Fully Sharded Data Parallel
- **JAX** — Google, używany w PaLM, Gemini

## Mixed Precision Training

Trenowanie w **FP16** lub **BF16** zamiast FP32 — 2× szybciej, 2× mniej pamięci:
- **FP16** — szybkie, ale wymaga "loss scaling" przeciw underflow
- **BF16** — szerszy zakres, łatwiejsze w użyciu (preferowane na H100/TPU)
- **FP8** — najnowsze GPU (H100), używane w Llama 3 405B

## Optimizery

| Optimizer | Charakterystyka |
|-----------|-----------------|
| **AdamW** | Standard dla LLM, wymaga 2x pamięci modelu na stany |
| **Adafactor** | Mniej pamięci niż AdamW (stosowany w T5) |
| **Lion** | Nowszy, prostszy, czasem lepszy |
| **Sophia** | Eksperymentalny, drugiego rzędu |

## Hyperparameters

Typowe wartości dla pre-trainingu:
```
Learning rate:    1e-4 do 3e-4 (peak)
Schedule:         cosine z warmup (~2000 kroków)
Batch size:       4M tokenów (globalny)
Weight decay:     0.1
Gradient clip:    1.0
Adam beta:        (0.9, 0.95)
Sequence length:  2048 - 8192 podczas pre-trainingu
                  potem rozszerzane do 32k - 200k
```

## Koszt vs jakość

```
1B params, 20B tokens   →  ~$1k        (laptop research)
7B params, 1T tokens    →  ~$100k      (mała firma)
70B params, 15T tokens  →  ~$10M+      (duża firma)
405B params, 15T tokens →  ~$60M+      (Big Tech)
```

Koszty spadają — Llama 3.1 405B kosztował podobno mniej niż GPT-3 (175B) parę lat wcześniej.
