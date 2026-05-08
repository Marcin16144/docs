# Trening LLM od zera (from scratch)

## Czy chcesz to robić?

**Pierwsza i najważniejsza rada: prawdopodobnie NIE.**

Nawet w 2026, gdy koszty spadły, trening LLM od zera oznacza:
- **Budżet**: $100k - $100M+
- **Zespół**: 5-50+ ML inżynierów
- **Czas**: 3-12 miesięcy
- **Hardware**: setki - tysiące H100/H200/B200 GPU
- **Dane**: terabajty wysokiej jakości tekstu
- **Ryzyko**: większość treningów się nie udaje przy pierwszej próbie

### Lepsze alternatywy (99% przypadków):
1. **Fine-tuning istniejącego modelu** (LoRA, QLoRA) — 1000× tańsze
2. **Continued pre-training** — adaptuj istniejący model do nowej domeny
3. **RAG** — gdy potrzebujesz wiedzy zewnętrznej
4. **Prompt engineering** — gdy potrzebujesz nowego zachowania

### Kiedy ma sens trening od zera?
- Foundation lab (Anthropic, OpenAI, Google, Meta)
- Suwerenna AI (rządowa, np. Falcon UAE, Hyperclova KR)
- Wąsko-specjalistyczna domena z masą danych (np. genomika, prawo z miliardami stron)
- Research / nauka — uczysz się jak to działa

## Mapa procesu — co trzeba zrobić

```
┌─────────────────────────────┐
│  1. PLANOWANIE               │  Tygodnie - miesiące
│   - Definicja celu           │
│   - Architektura             │
│   - Skala (params, tokens)   │
│   - Budżet hardware          │
└────────────┬────────────────┘
             ▼
┌─────────────────────────────┐
│  2. DANE                     │  Miesiące
│   - Zbieranie                │
│   - Cleaning                 │
│   - Filtering                │
│   - Tokenizacja              │
│   - Deduplication            │
└────────────┬────────────────┘
             ▼
┌─────────────────────────────┐
│  3. INFRASTRUKTURA           │  Tygodnie - miesiące
│   - GPU cluster              │
│   - Storage (PB+)            │
│   - Networking (InfiniBand)  │
│   - Monitoring               │
└────────────┬────────────────┘
             ▼
┌─────────────────────────────┐
│  4. PRE-TRAINING             │  Tygodnie - miesiące
│   - Initialization           │
│   - Training loop            │
│   - Checkpointing            │
│   - Loss debugging           │
└────────────┬────────────────┘
             ▼
┌─────────────────────────────┐
│  5. POST-TRAINING            │  Tygodnie
│   - SFT                      │
│   - DPO/RLHF                 │
│   - Safety tuning            │
└────────────┬────────────────┘
             ▼
┌─────────────────────────────┐
│  6. EWALUACJA                │  Ciągle
│   - Benchmarki               │
│   - Red teaming              │
│   - Custom evals             │
└─────────────────────────────┘
```

## 1. Planowanie

### Wybór skali

**Chinchilla scaling laws** (DeepMind, 2022) — optymalna alokacja compute:
```
Compute ∝ params × tokens
Optimal: ~20 tokenów per parameter
```

W praktyce **w 2026 trenuje się over-trained** (więcej tokenów niż Chinchilla):
- Llama 3 8B: ~1875 tokens/param (15T tokenów na 8B params)
- Llama 4: ~3000+ tokens/param

Dlaczego over-train? Bo trening to one-time cost, ale inferencja to repeat cost. Mniejszy, dłużej trenowany model jest tańszy w inferencji.

### Budżet compute (FLOPs)

```
Total FLOPs ≈ 6 × params × tokens

Przykład: 1B params × 100B tokens = 6 × 10^20 FLOPs

H100 (BF16): 989 TFLOPs = 989 × 10^12 FLOPs/s
Z efficiency 50%: 495 TFLOPs/s effective

Czas na 1 GPU: 6 × 10^20 / (495 × 10^12) = 1.2M sekund = 14 dni

Z 8 GPU (data parallel): ~1.7 dnia
Z 64 GPU: ~5 godzin
```

### Wybór architektury

W 2026 **standardowy stack** dla nowoczesnego LLM:

```python
config = {
    # Type
    "architecture": "decoder_only_transformer",  # standard
    "use_moe": False,  # True dla bardzo dużych

    # Size (przykład 1B model)
    "num_layers": 24,
    "hidden_size": 2048,
    "num_attention_heads": 32,
    "num_kv_heads": 8,           # GQA, 4× mniej niż q heads
    "intermediate_size": 8192,    # FFN dim, ~4× hidden
    "vocab_size": 128256,         # Llama 3 vocab

    # Position
    "position_encoding": "rope",
    "rope_theta": 500000,
    "max_position_embeddings": 8192,

    # Activations
    "activation": "swiglu",       # nie ReLU, nie GeLU
    "norm": "rmsnorm",            # nie LayerNorm

    # Other
    "tie_word_embeddings": False, # uncoupled embed/lm_head
    "bias": False,                # no bias terms
}
```

## 2. Przygotowanie danych

**Najważniejszy element. Lepsze dane > więcej parametrów.**

### Pipeline danych

```
┌──────────────────────────┐
│  Common Crawl (PB)       │  Web pages
│  Books, Wikipedia, ArXiv │
│  Code (GitHub)           │
│  Q&A (Reddit, SO)        │
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│  Format conversion       │  HTML→text, PDF→text
│  Encoding fixing          │
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│  Language filtering      │  fastText classifier
│  PII removal             │  emails, IDs, phones
│  NSFW filtering          │  toxic content
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│  Quality filtering       │  Heuristics + classifier
│  - perplexity            │
│  - quality scorer        │
│  - duplicate removal     │
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│  Deduplication           │  MinHash, suffix arrays
│  - exact dups            │
│  - near dups             │
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│  Decontamination         │  Remove eval data
│  - MMLU, GSM8K, ...      │
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│  Mixing                  │  Optimal data mix
│  Web: 70%                │
│  Code: 15%               │
│  Math: 8%                │
│  Books: 5%               │
│  Reasoning: 2%           │
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│  Tokenization            │  BPE/SentencePiece
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│  Sharding for training   │  N×M parquet files
└──────────────────────────┘
```

### Public datasety dla treningu od zera

| Dataset | Rozmiar | Quality | Uwagi |
|---------|---------|---------|-------|
| **FineWeb-Edu** (HF) | 1.3T tokens | ✓✓✓ | Educational, filtered Common Crawl |
| **Dolma** (AI2) | 3T tokens | ✓✓ | Open, dobrze udokumentowany |
| **RedPajama V2** | 30T tokens | ✓✓ | Quality scores included |
| **The Pile** | 825 GB | ✓ | Klasyczny, mniejszy |
| **C4** (Google) | 750 GB | ✓ | Cleaner Common Crawl |
| **The Stack v2** | 6T tokens | ✓✓ | Code dataset |
| **Proof-Pile-2** | 55B tokens | ✓✓ | Math + science |

**Dla research / małej skali**: zacznij od FineWeb-Edu lub Dolma — są dobrze sprawdzone.

### Synthetic data (2025+ trend)

W 2026 standardem jest częściowo syntetyczne dane:
- **Phi modele** (Microsoft) — głównie syntetic data, "textbooks are all you need"
- **Llama 3** — używała synthetic data dla math, code
- **Reasoning datasets** — generowane przez większe modele

```python
# Przykład: synthetic textbook generation
prompt = """
Napisz krótki podręcznik (3 strony) na temat:
{topic}

Format:
- Wprowadzenie
- Główne koncepty z przykładami
- Ćwiczenia z rozwiązaniami
"""

# Generujesz milionów takich tekstów na różnorodne tematy
```

### Tokenizer training

Trenujesz **tokenizer na własnych danych** (nie używaj cudzego, jeśli różne języki):

```python
from tokenizers import Tokenizer
from tokenizers.models import BPE
from tokenizers.trainers import BpeTrainer
from tokenizers.pre_tokenizers import ByteLevel

tokenizer = Tokenizer(BPE())
tokenizer.pre_tokenizer = ByteLevel()

trainer = BpeTrainer(
    vocab_size=128256,  # podobnie jak Llama 3
    special_tokens=[
        "<|begin_of_text|>",
        "<|end_of_text|>",
        "<|start_header_id|>",
        "<|end_header_id|>",
        # ...
    ]
)

# Trenuj na próbce 10-100B tokenów
files = ["data/sample_001.txt", "data/sample_002.txt", ...]
tokenizer.train(files, trainer)
tokenizer.save("my_tokenizer.json")
```

## 3. Infrastruktura

### GPU cluster — opcje

#### Self-built (najtaniej długoterminowo)
```
8× H100 SXM5 80GB w jednym węźle:
- GPU: ~$200-300k
- Server (CPU, RAM, dyski): ~$50k
- Sieć (InfiniBand 400Gbps): ~$30k
- Total: ~$280-380k

Skala: ten setup wystarczy dla modeli do ~7B trenowanych miesiące
Większe modele = więcej takich węzłów + InfiniBand między nimi
```

#### Cloud
```
RunPod, Lambda, CoreWeave, Together AI:
- H100 SXM ~$2-4/h per GPU
- A100 ~$1-2/h per GPU
- B200 (najnowszy 2025) ~$5-8/h per GPU

Zaleta: pay-as-you-go, łatwe skalowanie
Wada: drogie przy długim treningu
```

#### Hyperscalers
```
AWS p5 (8× H100): ~$98/h
Azure ND H100 v5: ~$98/h
GCP A3: ~$88/h

Plus: pełny stack (S3, networking, etc.)
Minus: najdroższe per GPU/h
```

### Software stack

```
Hardware: H100/H200/B200 GPU
   ↓
CUDA + cuDNN + NCCL
   ↓
PyTorch (lub JAX)
   ↓
Distributed framework:
  - PyTorch FSDP (najnowsze)
  - DeepSpeed (Microsoft, ZeRO)
  - Megatron-LM (NVIDIA)
   ↓
Trainer (z checkpointing, logging):
  - Custom training loop
  - HF Accelerate
  - Lightning AI
   ↓
Storage:
  - Distributed FS (Lustre, GPFS)
  - Object storage (S3, GCS)
   ↓
Monitoring:
  - Weights & Biases
  - TensorBoard
  - Custom dashboards
```

## 4. Pre-training

### Inicjalizacja wag

```python
def init_weights(module):
    if isinstance(module, nn.Linear):
        # Standard normal w/ small std
        nn.init.normal_(module.weight, mean=0.0, std=0.02)
        if module.bias is not None:
            nn.init.zeros_(module.bias)
    elif isinstance(module, nn.Embedding):
        nn.init.normal_(module.weight, mean=0.0, std=0.02)
    elif isinstance(module, RMSNorm):
        nn.init.ones_(module.weight)

    # Specjalna inicjalizacja dla output projection
    # (zapobiega eksplozji loss na początku)
    for name, p in module.named_parameters():
        if "out_proj" in name or "down_proj" in name:
            nn.init.normal_(p, mean=0.0, std=0.02 / math.sqrt(2 * num_layers))
```

### Training loop (uproszczony)

```python
import torch
import torch.distributed as dist
from torch.distributed.fsdp import FullyShardedDataParallel as FSDP

# 1. Init distributed
dist.init_process_group(backend="nccl")
local_rank = int(os.environ["LOCAL_RANK"])
torch.cuda.set_device(local_rank)

# 2. Model with FSDP (Fully Sharded Data Parallel)
model = LlamaForCausalLM(config)
model = FSDP(
    model,
    mixed_precision=MixedPrecision(
        param_dtype=torch.bfloat16,
        reduce_dtype=torch.float32,
        buffer_dtype=torch.bfloat16,
    ),
    device_id=local_rank,
    sharding_strategy=ShardingStrategy.HYBRID_SHARD,
)

# 3. Optimizer (AdamW with proper groups)
optimizer = torch.optim.AdamW(
    model.parameters(),
    lr=peak_lr,
    betas=(0.9, 0.95),
    eps=1e-8,
    weight_decay=0.1,
    fused=True,  # CUDA fused optimizer
)

# 4. LR Scheduler (cosine with warmup)
scheduler = get_cosine_schedule_with_warmup(
    optimizer,
    num_warmup_steps=2000,
    num_training_steps=total_steps,
)

# 5. Data loader (streaming z przygotowanych shardów)
dataset = StreamingDataset("data/shards/")
loader = DataLoader(
    dataset,
    batch_size=micro_batch,
    num_workers=4,
    pin_memory=True,
)

# 6. Training loop
model.train()
for step, batch in enumerate(loader):
    # Forward
    with torch.amp.autocast("cuda", dtype=torch.bfloat16):
        outputs = model(input_ids=batch["input_ids"], labels=batch["labels"])
        loss = outputs.loss / grad_accum_steps

    # Backward
    loss.backward()

    # Step (z gradient accumulation)
    if (step + 1) % grad_accum_steps == 0:
        # Clip gradients
        model.clip_grad_norm_(max_norm=1.0)

        optimizer.step()
        scheduler.step()
        optimizer.zero_grad()

    # Logging
    if step % 100 == 0 and dist.get_rank() == 0:
        wandb.log({
            "loss": loss.item() * grad_accum_steps,
            "lr": scheduler.get_last_lr()[0],
            "tokens_seen": step * global_batch_tokens,
            "throughput": tokens_per_sec,
        })

    # Checkpoint
    if step % checkpoint_every == 0 and dist.get_rank() == 0:
        save_checkpoint(model, optimizer, scheduler, step)

    # Eval
    if step % eval_every == 0:
        run_evaluations(model, eval_dataset)
```

### Hyperparameters — typowe wartości

```python
# Learning rate
peak_lr = 3e-4         # dla małych modeli (<10B)
peak_lr = 1.5e-4       # dla średnich (10-70B)
peak_lr = 8e-5         # dla bardzo dużych (>70B)

# Schedule: cosine with warmup
warmup_steps = 2000    # ~0.1-1% total steps
min_lr_ratio = 0.1     # min LR = 10% of peak

# Batch size (TOKENY, nie samples)
global_batch_tokens = 4_194_304  # 4M tokens — typowy
sequence_length = 8192            # podczas pre-training
# global_batch = (global_batch_tokens / seq_len) = 512 sequences
# Z 64 GPU: micro_batch_per_gpu = 8, grad_accum = 1

# Inne
weight_decay = 0.1
adam_beta1 = 0.9
adam_beta2 = 0.95      # nie 0.999! niżej dla LLM
adam_epsilon = 1e-8
gradient_clip = 1.0

# Mixed precision
dtype = "bfloat16"     # standard w 2026, lepsze niż fp16
# dla H100: można fp8 dla niektórych warstw
```

### Co monitorować

```
1. Training loss
   - Powinien spadać monotonicznie
   - Spike → spróbuj checkpoint resume
   - Plateau → sprawdź LR, dane

2. Validation loss
   - Powinien śledzić training (z gap)
   - Jeśli rośnie → overfitting (rzadko w pre-training)

3. Gradient norm
   - Stable around 0.5-2.0
   - Spike = problem (NaN coming?)

4. Tokens/second
   - Throughput wskaźnik
   - Spadek = problem z hardware/data

5. GPU utilization
   - Powinno być 70-90%
   - Niżej = bottleneck (data loading? sync?)

6. Loss curves per data source
   - Sprawdź czy każde źródło uczy się
   - Jeśli któreś nie spada — problem z danymi
```

### Recovery z awarii

Awarie są **certain** w długim treningu:
- Hardware failure (1 GPU/ tydzień przy 1000 GPU)
- Network timeout
- OOM
- Numerical instability

```python
# Save checkpoints often!
# Łatwo wracać do wcześniejszego stanu

def save_checkpoint(model, optimizer, scheduler, step):
    state = {
        "step": step,
        "model": model.state_dict(),
        "optimizer": optimizer.state_dict(),
        "scheduler": scheduler.state_dict(),
        "rng_state": torch.get_rng_state(),
    }
    torch.save(state, f"ckpt_{step}.pt")

# Cyklicznie usuwaj stare (storage!)
def cleanup_old_checkpoints(keep=5):
    ckpts = sorted(glob("ckpt_*.pt"))
    for ckpt in ckpts[:-keep]:
        os.remove(ckpt)
```

## 5. Post-training

Po pre-training masz **base model** — działa, ale nie umie rozmawiać.

### SFT (Supervised Fine-Tuning)

```python
# Dataset: pary (prompt, response) w chat format
# Trening: identyczny jak pre-training, ale na chat data
# Krótszy: 1-3 epoki na 100k-1M przykładach
# Niższy LR: 1e-5 do 5e-5
```

### DPO (Direct Preference Optimization)

```python
from trl import DPOTrainer

# Dataset: (prompt, chosen, rejected)
trainer = DPOTrainer(
    model=sft_model,
    ref_model=sft_model_copy,  # frozen
    train_dataset=preference_data,
    args=DPOConfig(
        beta=0.1,           # KL regularization
        learning_rate=5e-7, # bardzo nisko
        num_train_epochs=1,
    )
)
trainer.train()
```

### Safety tuning
- Dataset z odmowami niebezpiecznych próśb
- Constitutional AI (Anthropic style)
- Red teaming → generowanie adversarial examples → dodanie do safety dataset

## 6. Ewaluacja

Patrz rozdział 11. Dla treningu od zera:
- Run cały standardowy benchmark suite (MMLU, HumanEval, ...)
- Porównaj z modelami podobnej skali
- Custom evals dla Twoich use case
- Red teaming
- Bias evals

## Realny przykład — TinyLlama 1.1B

Zespół 3 osób, ~6 miesięcy, $100k budżet (cloud):
- **Architektura**: Llama 2 architecture (1.1B params)
- **Dane**: 3T tokens (SlimPajama + StarCoderData)
- **Hardware**: 16× A100 80GB
- **Czas treningu**: ~3 miesiące
- **Koszt**: ~$70k cloud + zespół

Wynik: model porównywalny z Pythia 1.4B i StableLM 1.3B.

## Open source playgrounds

Jeśli chcesz **nauczyć się** treningu LLM przed wydaniem milionów:

### nanoGPT (Karpathy)
- 300 linii kodu
- GPT-2 architecture
- Trenuj GPT-2 124M na Shakespeare na pojedynczym GPU
- github.com/karpathy/nanoGPT

### llm.c (Karpathy)
- GPT-2 w czystym C/CUDA
- Edukacyjne, ale szybkie
- Pokazuje co dzieje się "pod spodem"

### TinyLlama
- 1.1B model, 3T tokens
- Pełny pipeline open source
- github.com/jzhang38/TinyLlama

### OLMo (AI2)
- W pełni otwarte: dane + kod + checkpointy + logi
- 1B i 7B models
- Najlepsze dla nauki — zobaczysz cały proces
- github.com/allenai/OLMo

### MAP-Neo (2024)
- Multi-lingual, w pełni open
- 7B model

## Praktyczna ścieżka nauki

```
1. Przeczytaj "Attention is All You Need" + GPT-1/2 papers
   ↓
2. Zaimplementuj nanoGPT od zera w PyTorch
   ↓
3. Trenuj na Shakespeare → swój pierwszy model!
   ↓
4. Skaluj do GPT-2 124M na tinystories / wikipedia
   ↓
5. Zaimplementuj nowoczesne featury (RoPE, RMSNorm, SwiGLU)
   ↓
6. Studiuj OLMo / TinyLlama codebase
   ↓
7. Trenuj 100M-1B model na publicznym datasecie
   ↓
8. Zrozum distributed training (FSDP)
   ↓
9. (Opcjonalnie) Dołącz do organizacji która trenuje LLM
```

## Trendy 2026

1. **MoE jako standard** dla większych modeli
2. **Reasoning trained from scratch** — RL on chains of thought
3. **Mniejsze modele, więcej tokenów** — over-trained
4. **Synthetic data** — większość treningu generowana przez modele
5. **Multimodal from scratch** — vision/audio nie jako dodatek
6. **Long context od początku** — 128k+ podczas pre-training
7. **FP8 training** — H100/B200 native
8. **Edge models** — celowo małe (1B-3B), zoptymalizowane na phone

## Zasoby

**Książki / artykuły:**
- "Build a Large Language Model from Scratch" — Sebastian Raschka
- Karpathy: "Let's reproduce GPT-2 (124M)" YouTube
- Stanford CS336 — Language Modeling from Scratch (publicznie)

**Papers must-read:**
- "Attention is All You Need" (2017)
- GPT-3 paper (2020)
- Chinchilla scaling laws (2022)
- Llama 3 paper (2024)
- DeepSeek V3 paper (2024)
- OLMo paper (2024)
