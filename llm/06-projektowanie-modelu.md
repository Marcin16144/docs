# Projektowanie modelu LLM

## Kiedy projektować własny model?

**99% przypadków: NIE projektuj własnego LLM.** Zamiast tego użyj:
- Komercyjnego API (Claude, GPT, Gemini)
- Open source modelu z fine-tuningiem (Llama, Mistral, Qwen)
- RAG zamiast trenowania na własnych danych

**Projektowanie własnego LLM ma sens gdy:**
- Masz unikalne wymagania niespełnione przez istniejące modele
- Pracujesz w specjalistycznej domenie (genomika, prawo, finanse) z dużymi specjalistycznymi danymi
- Masz budżet $1M+ i zespół 5+ ML engineers
- Wymagana jest pełna kontrola nad modelem (regulacje, IP)

W praktyce: większość firm projektuje **adaptery** lub **fine-tuningi** istniejących modeli, nie modele od zera.

## Proces projektowania (od zera)

### Krok 1: Definicja problemu

Pytania do odpowiedzenia:
- **Co model ma robić?** (chat, code, klasyfikacja, embeddings)
- **Jakie języki?** (mono- czy multilingual)
- **Jaki kontekst?** (4k, 32k, 200k, 1M tokenów)
- **Jakie ograniczenia?** (latency, cost, hardware)
- **Modalności?** (text-only, vision, audio, video)
- **Czy reasoning?** (standardowy vs reasoning model)

### Krok 2: Wybór architektury

| Wybór | Opcje | Domyślny w 2026 |
|-------|-------|-----------------|
| Typ | Decoder-only / Encoder-Decoder / MoE | Decoder-only lub MoE |
| Attention | MHA / GQA / MQA | GQA (Grouped-Query) |
| Position | RoPE / ALiBi / NoPE | RoPE z YARN |
| Normalization | LayerNorm / RMSNorm | RMSNorm |
| Activation | ReLU / GeLU / SwiGLU | SwiGLU |
| MoE? | Tak / Nie | Tak dla >70B params |

### Krok 3: Określenie skali

Chinchilla-optimal: **~20 tokenów na parametr**.

W 2026 trenuje się "over-trained" — znacznie więcej tokenów per parameter dla lepszej inferencji:

```
Llama 3 8B:    15T tokenów (1875 tokens/param)
Llama 3 70B:   15T tokenów (214 tokens/param)
Llama 4 (MoE): ~30T tokenów

Trade-off:
- Więcej tokenów = lepszy model, ale droższy trening
- Sweet spot: 100-500 tokens/param dla małych modeli
```

### Krok 4: Dane

**Najważniejszy element. Lepsze dane > więcej parametrów.**

Pipeline danych:
```
Surowe dane (PB)
    │
    ▼
Filtrowanie języka, NSFW, deduplikacja
    │
    ▼
Quality filtering (klasyfikator jakości)
    │
    ▼
Decontamination (usunięcie eval data)
    │
    ▼
Mix (web 70%, code 15%, math 8%, books 5%, reasoning 2%)
    │
    ▼
Tokenizacja
    │
    ▼
Dataset gotowy do treningu
```

**Co ważne:**
- **Jakość > Ilość** — model na 1T high-quality tokens > 10T low-quality
- **Diversity** — różne źródła, języki, domeny
- **Decontamination** — eval datasets nie mogą być w trainie
- **Synthetic data** — w 2025+ większość datasetów jest częściowo syntetyczna

### Krok 5: Hyperparameters

Typowe dla nowoczesnych LLM:

```python
config = {
    # Architektura
    "num_layers": 32,           # liczba bloków transformer
    "hidden_size": 4096,        # wymiar embedding
    "num_heads": 32,            # głowy attention
    "num_kv_heads": 8,          # GQA — mniej KV heads
    "intermediate_size": 14336,  # FFN dim (~3.5x hidden)
    "vocab_size": 128256,
    "max_position_embeddings": 131072,  # 128k context
    "rope_theta": 500000,
    "tie_word_embeddings": False,

    # Trening
    "learning_rate": 3e-4,
    "lr_schedule": "cosine_with_warmup",
    "warmup_steps": 2000,
    "weight_decay": 0.1,
    "gradient_clip": 1.0,
    "adam_beta1": 0.9,
    "adam_beta2": 0.95,
    "adam_epsilon": 1e-8,

    # Batch
    "global_batch_size": 4_194_304,  # 4M tokenów (typowe)
    "sequence_length": 8192,          # podczas pre-trainingu

    # Precision
    "dtype": "bfloat16",      # lub "float8" dla H100
    "use_flash_attention": True,
}
```

### Krok 6: Pipeline treningowy

```python
# Pseudo-kod treningu LLM
import torch
from torch.distributed import init_process_group
from torch.nn.parallel import DistributedDataParallel

# 1. Init distributed
init_process_group(backend="nccl")

# 2. Model + tokenizer
model = LlamaForCausalLM(config)
model = DistributedDataParallel(model)
model = model.to(dtype=torch.bfloat16)

# 3. Dataset (streaming dla dużych)
dataset = load_streaming_dataset("c4")
dataloader = DataLoader(dataset, batch_size=...)

# 4. Optimizer + scheduler
optimizer = torch.optim.AdamW(
    model.parameters(),
    lr=config["learning_rate"],
    betas=(0.9, 0.95),
    weight_decay=0.1
)
scheduler = get_cosine_schedule_with_warmup(
    optimizer,
    num_warmup_steps=2000,
    num_training_steps=total_steps
)

# 5. Training loop
for step, batch in enumerate(dataloader):
    with torch.amp.autocast("cuda", dtype=torch.bfloat16):
        outputs = model(input_ids=batch["input_ids"])
        loss = outputs.loss

    loss.backward()
    torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
    optimizer.step()
    scheduler.step()
    optimizer.zero_grad()

    # Checkpointing co N kroków
    if step % 1000 == 0:
        save_checkpoint(model, optimizer, step)

    # Eval
    if step % 5000 == 0:
        run_evaluations(model)
```

## Mixture of Experts (MoE)

W 2025/2026 większość dużych modeli (Llama 4, DeepSeek V3, GPT-5) używa MoE.

### Idea
Zamiast jednego dużego FFN — wiele "ekspertów", router wybiera 1-2 dla każdego tokenu:

```
Input token
    │
    ▼
[Router Network] → wybierz top-2 ekspertów
    │
    ├─→ Expert 1 ─┐
    └─→ Expert 7 ─┴─→ Output (ważona suma)

Inni eksperci (2-6, 8-N) pozostają nieaktywni!
```

### Zalety
- **Więcej parametrów** bez zwiększenia kosztu inferencji
- Mixtral 8x7B: 47B total, ale tylko 13B aktywnych per token
- DeepSeek V3: 671B total, 37B aktywnych

### Wyzwania
- **Load balancing** — eksperci muszą być równomiernie używane
- **Komunikacja** w distributed training (all-to-all)
- **Pamięć VRAM** — wszystkie eksperci muszą być załadowane

## Reasoning models — projekt 2025+

Modele typu o1, o3, DeepSeek R1, Claude z extended thinking są trenowane inaczej:

```
1. Pre-training (jak zwykle)
2. SFT na rozwiązaniach krok-po-kroku (chain of thought)
3. RL na poprawnych rozwiązaniach
   - Model generuje długi CoT
   - Verifier sprawdza końcową odpowiedź
   - Wzmacniamy łańcuchy prowadzące do poprawnej odpowiedzi
4. Distillation (opcjonalnie) — przekaż rozumowanie do mniejszego modelu
```

Efekt: model "myśli" znacznie dłużej (10s-10min), generuje setki/tysiące tokenów rozumowania, osiąga znacznie lepsze wyniki na matematyce, nauce, kodzie.

## Adaptery zamiast pełnego treningu

Jeśli chcesz "swój model" — najczęściej wystarczy adaptacja istniejącego:

| Metoda | Koszt | Kiedy |
|--------|-------|-------|
| **Prompt engineering** | $ | Zacznij od tego |
| **RAG** | $$ | Gdy potrzebujesz wiedzy domenowej |
| **Few-shot prompting** | $ | Małe dostosowania zachowania |
| **LoRA fine-tuning** | $$$ | Specyficzny styl, format, język |
| **Full fine-tuning** | $$$$ | Bardzo specyficzna domena |
| **Continued pre-training** | $$$$$ | Nowy język/domena na masową skalę |
| **Trening od zera** | $$$$$$$$ | Tylko z ogromnym budżetem |

Szczegóły fine-tuningu — patrz rozdział 07.

## Przykład: jak Anthropic projektuje Claude (publiczne info)

Anthropic publicznie nie ujawnia szczegółów, ale wiadomo:
- Architektura: Decoder-only Transformer (prawdopodobnie z MoE w największych)
- Trening: Pre-training + SFT + Constitutional AI (RLAIF)
- Specjalność: bezpieczeństwo, długi kontekst (200k+), agentic capabilities
- Reasoning: Claude może "myśleć" przed odpowiedzią (extended thinking)

## Open-source playgrounds do nauki

Jeśli chcesz **nauczyć się** projektowania LLM:

1. **nanoGPT** (Andrej Karpathy) — minimalny GPT w 300 linijkach
2. **MinGPT** — edukacyjna implementacja
3. **llm.c** (Karpathy) — GPT-2 w czystym C/CUDA
4. **TinyLlama** — wytrenuj 1.1B model na 3T tokenach
5. **OLMo** (AI2) — w pełni open: dane, kod, model, training logs

## Praktyczna rada

**Nie zaczynaj od zera.** Zaczerpnij z TinyLlama, OLMo, Pythia. Zrozum architekturę przez modyfikacje istniejących, działających modeli. Dopiero potem (po latach doświadczenia) zaprojektuj własny.

**Co warto poznać dogłębnie:**
1. Tokenizację (BPE, SentencePiece, tiktoken)
2. Attention (zwłaszcza Flash Attention)
3. Distributed training (FSDP, DeepSpeed)
4. Mixed precision i gradient accumulation
5. LR scheduling i warmup
6. Data quality i filtering pipelines

To konkretna wiedza, która zarabia.
