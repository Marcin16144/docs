# Fine-tuning i adaptacja modeli

## Kiedy fine-tunować?

**Fine-tuning to NIE pierwsza rzecz, którą powinieneś spróbować.** Hierarchia:

```
1. Prompt engineering          → spróbuj najpierw
2. Few-shot prompting          → daj przykłady w prompcie
3. RAG                         → gdy brakuje wiedzy
4. Fine-tuning (LoRA/QLoRA)    → gdy pierwsze 3 nie wystarczą
5. Full fine-tuning            → bardzo rzadko potrzebny
6. Trening od zera             → nigdy (chyba że jesteś OpenAI)
```

### Fine-tuning ma sens gdy:
- Potrzebujesz **specyficznego stylu** (głos marki, format)
- Pracujesz w **wąskiej domenie** (medycyna, prawo, finanse)
- Masz **nietypowy format** wyjścia (specjalna składnia, struktury)
- Chcesz **mniejszy/szybszy model** osiągający wyniki większego
- Potrzebujesz **prywatności** (nie chcesz wysyłać danych do API)

### Fine-tuning NIE pomoże gdy:
- Potrzebujesz aktualnych informacji → RAG
- Model nie wie czegoś jednorazowego → włóż w prompt
- Model "halucynuje" → lepszy prompting + RAG
- Chcesz nauczyć modelu nowych faktów → continued pre-training, nie SFT

## Pełny fine-tuning vs PEFT

### Full fine-tuning (FFT)
Trenujemy **wszystkie parametry** modelu.

**Wymagania VRAM:**
```
Llama 8B FFT:  ~80 GB VRAM   (parametry + gradienty + Adam)
Llama 70B FFT: ~700 GB VRAM  (klaster GPU)
```

Wymaga ogromnych zasobów. Stosowany rzadko, głównie dla foundation models.

### PEFT — Parameter Efficient Fine-Tuning

Zamiast trenować wszystkie parametry, trenujemy **małą część** (1-5%).

| Metoda | % trenowanych | Jakość | Pamięć |
|--------|---------------|--------|--------|
| **LoRA** | ~1% | ~95% FFT | 25% FFT |
| **QLoRA** | ~1% | ~93% FFT | 10% FFT |
| **Adapters** | ~3% | ~95% FFT | 30% FFT |
| **Prompt tuning** | <0.1% | ~85% FFT | 5% FFT |
| **DoRA** | ~1% | ~97% FFT | 25% FFT |

**LoRA i QLoRA** to obecnie standard.

## LoRA (Low-Rank Adaptation)

### Idea matematyczna

Zamiast trenować całą macierz wag W (np. 4096×4096), dodajemy niewielką "delta" rozłożoną na dwie małe macierze:

```
W_new = W_oryginalne + B · A

gdzie:
- W: 4096 × 4096 = 16M params (zamrożone)
- A: 4096 × r (np. r=8)
- B: r × 4096
- Trenujemy tylko A i B → 65k params (250× mniej!)

r (rank): 8, 16, 32, 64 — większy = bardziej "pojemny"
```

### Zalety LoRA
- **Mała pamięć** — adapter to ~50-200 MB zamiast GB
- **Szybki trening** — 5-10× szybszy niż FFT
- **Wiele adapterów** — przełączasz między nimi runtime
- **Można łączyć** — adapter A + adapter B
- **Mergowalny** — możesz wmergować w bazowy model

### Konfiguracja LoRA

```python
from peft import LoraConfig, get_peft_model

config = LoraConfig(
    r=16,                    # rank
    lora_alpha=32,           # skalowanie (zwykle 2*r)
    target_modules=[         # które warstwy adaptować
        "q_proj", "k_proj", "v_proj", "o_proj",  # attention
        "gate_proj", "up_proj", "down_proj"       # FFN
    ],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(base_model, config)
model.print_trainable_parameters()
# trainable: 41,943,040 || all: 8,072,204,288 || trainable%: 0.52
```

## QLoRA — LoRA z kwantyzacją

QLoRA = Quantized LoRA. Bazowy model w 4-bit, adapter w pełnej precyzji.

```
Pamięć:
- Llama 8B FFT:    ~80 GB VRAM
- Llama 8B LoRA:   ~20 GB VRAM
- Llama 8B QLoRA:  ~6 GB VRAM   ← na konsumenckim GPU!
- Llama 70B QLoRA: ~48 GB VRAM  ← jedna RTX 6000 Ada
```

QLoRA pozwala fine-tunować 70B model na pojedynczej dużej karcie.

```python
from transformers import BitsAndBytesConfig

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",          # NormalFloat4
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True
)

model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-3.1-8B-Instruct",
    quantization_config=bnb_config,
    device_map="auto"
)

# Następnie LoRA jak wcześniej
```

## Pipeline fine-tuningu (krok po kroku)

### 1. Przygotuj dataset

Format **chat template** dla SFT:

```json
{
  "messages": [
    {"role": "system", "content": "Jesteś prawnikiem."},
    {"role": "user", "content": "Czy mogę odstąpić od umowy?"},
    {"role": "assistant", "content": "W przypadku umów konsumenckich..."}
  ]
}
```

**Reguły dobrego datasetu:**
- **Quality > Quantity** — 1000 świetnych przykładów > 100k mediocre
- **Diversity** — różne typy zapytań/odpowiedzi
- **Format spójny** — wszystkie przykłady w tym samym stylu
- **No data leakage** — eval set ≠ train set
- **Decontamination** — usuń przykłady z public benchmarków

**Ile danych?**
- LoRA dla małych zmian: 100-1000 przykładów
- LoRA dla nowego stylu/domeny: 1k-10k
- LoRA dla nowej umiejętności: 10k-100k
- Full fine-tuning: 100k+

### 2. Wybierz model bazowy

| Cel | Polecane bazowe modele (2026) |
|-----|--------------------------------|
| Ogólny chat | Llama 4 Instruct, Qwen 3 Chat |
| Coding | Qwen 2.5 Coder, DeepSeek Coder |
| Reasoning | DeepSeek R1, Qwen QwQ |
| Multilingual | Qwen, Mistral Large |
| Mały i szybki | Llama 3.2 3B, Phi-4 |
| Vision | Llama 3.2 Vision, Qwen 2.5 VL |

**Zawsze wybieraj wersję `Instruct`/`Chat`** jako bazę dla fine-tuningu, nie base model — chyba że robisz continued pre-training.

### 3. Trening — przykład z Unsloth

**Unsloth** to najszybsze narzędzie do LoRA/QLoRA — 2-5× szybszy niż HF:

```python
from unsloth import FastLanguageModel
import torch

# Załaduj model w 4-bit
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/Meta-Llama-3.1-8B-Instruct-bnb-4bit",
    max_seq_length=4096,
    dtype=None,
    load_in_4bit=True,
)

# Dodaj LoRA
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    lora_alpha=32,
    lora_dropout=0,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj",
                     "gate_proj", "up_proj", "down_proj"],
    use_gradient_checkpointing="unsloth",
)

# Dataset (chat format)
from datasets import load_dataset
dataset = load_dataset("json", data_files="train.jsonl")

def format_chat(example):
    return {"text": tokenizer.apply_chat_template(
        example["messages"],
        tokenize=False,
        add_generation_prompt=False
    )}

dataset = dataset.map(format_chat)

# Trening
from trl import SFTTrainer
from transformers import TrainingArguments

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset["train"],
    dataset_text_field="text",
    max_seq_length=4096,
    args=TrainingArguments(
        per_device_train_batch_size=2,
        gradient_accumulation_steps=4,
        warmup_steps=100,
        num_train_epochs=3,
        learning_rate=2e-4,
        bf16=True,
        logging_steps=10,
        optim="adamw_8bit",
        weight_decay=0.01,
        lr_scheduler_type="cosine",
        seed=42,
        output_dir="./outputs",
    ),
)

trainer.train()

# Zapisz adapter
model.save_pretrained("my_lora_adapter")

# Lub merge z bazowym modelem dla łatwiejszej inferencji
model.save_pretrained_merged("my_merged_model", tokenizer, save_method="merged_16bit")
```

### 4. Hyperparameters — typowe wartości

```python
# LoRA hyperparameters
r = 16                # 8-64, większy = bardziej pojemny
lora_alpha = 32       # zwykle 2*r
lora_dropout = 0.05   # 0-0.1

# Training
learning_rate = 2e-4  # LoRA może mieć wyższy LR niż FFT
                      # FFT: 1e-5 do 5e-5
batch_size = 4        # globalny
epochs = 3            # 1-5 typowo
warmup_steps = 100    # 100-500
```

### 5. Merge i deploy

```python
# Merge LoRA z bazowym modelem
from peft import PeftModel

base = AutoModelForCausalLM.from_pretrained("base_model")
model = PeftModel.from_pretrained(base, "my_lora_adapter")
merged = model.merge_and_unload()
merged.save_pretrained("merged_model")

# Konwersja do GGUF dla Ollama/llama.cpp
# (zewnętrzne narzędzia: llama.cpp convert.py)
```

## DPO i preference fine-tuning

Po SFT można dodać **preference optimization** — uczy model preferować lepsze odpowiedzi.

### Dataset DPO

```json
{
  "prompt": "Wyjaśnij rekurencję",
  "chosen": "Rekurencja to technika...(dobra odpowiedź)",
  "rejected": "Rekurencja jest...(słaba odpowiedź)"
}
```

```python
from trl import DPOTrainer, DPOConfig

trainer = DPOTrainer(
    model=model,
    ref_model=None,  # automatyczne dla LoRA
    args=DPOConfig(
        beta=0.1,                # KL regularization
        learning_rate=5e-7,      # niższy niż SFT!
        num_train_epochs=1,
        per_device_train_batch_size=2,
        ...
    ),
    train_dataset=dpo_dataset,
    tokenizer=tokenizer,
)
trainer.train()
```

### Inne preference methods (2026)
- **DPO** — najpopularniejsza, prosta
- **KTO** — działa z pojedynczymi przykładami (good/bad)
- **ORPO** — łączy SFT i DPO w jeden krok
- **GRPO** — Group Relative Policy Optimization (DeepSeek R1)
- **SimPO** — uproszczona DPO bez ref model

## Narzędzia do fine-tuningu

### Open source

**Unsloth** ⭐ — najszybsze
- 2-5× szybszy niż HF Transformers
- Mniej VRAM
- Łatwy w użyciu
- github.com/unslothai/unsloth

**Axolotl** — najpopularniejsze
- Konfiguracja YAML
- Wsparcie wielu metod (LoRA, QLoRA, FFT, DPO, ORPO)
- Cloud-friendly
- github.com/axolotl-ai-cloud/axolotl

**LLaMA Factory** — z GUI
- WebUI do fine-tuningu
- Wsparcie 100+ modeli
- Łatwe dla początkujących

**TRL** (Hugging Face) — bibliotek niskopoziomowa
- SFTTrainer, DPOTrainer, GRPOTrainer
- Bardziej kontroli, więcej kodu

**Torchtune** (Meta) — natywny PyTorch
- Bez warstw abstrakcji
- Distributed training

### Komercyjne / Cloud

**Anthropic Fine-tuning** (via AWS Bedrock)
- Fine-tune Claude Haiku
- Custom modele dla enterprise

**OpenAI Fine-tuning**
- GPT-4o, GPT-4o-mini
- Łatwe via API: `client.fine_tuning.jobs.create(...)`

**Together AI**
- Fine-tune Llama, Mistral, Qwen w chmurze
- Łatwiejsze niż własna infrastruktura

**Predibase / Modal / Replicate**
- Cloud platforms do fine-tuningu
- GPU on-demand

**Vertex AI** (Google) — fine-tune Gemini
**Azure AI Foundry** — fine-tune wielu modeli

## Pułapki i typowe błędy

1. **Catastrophic forgetting** — model zapomina jak rozmawiać. Mituj przez:
   - Mieszanie z generic SFT data
   - Niski learning rate
   - LoRA zamiast FFT

2. **Overfitting** — model uczy się dosłownie. Mituj przez:
   - Walidację na hold-out set
   - Early stopping
   - Mniej epok (1-3)
   - Augmentacja danych

3. **Format leakage** — model dodaje artefakty z trainingu (np. dziwne tokeny).
   - Sprawdź template!
   - Inferencja w tym samym formacie co trening

4. **Złe dane** — garbage in, garbage out.
   - Manualnie przejrzyj 100 losowych przykładów
   - Usuń duplikaty
   - Sprawdź jakość odpowiedzi

5. **Brak ewaluacji** — fine-tunujesz w ciemno.
   - Ustaw eval dataset PRZED treningiem
   - Mierz: jakość + brak regresji w ogólnych zadaniach

## Koszty (2026)

```
LoRA fine-tuning Llama 8B (lokalnie):
  - 1 epoch na 10k przykładach
  - RTX 4090 24GB
  - ~2-4 godziny
  - Koszt: prąd (~$0.50)

QLoRA fine-tuning Llama 70B (cloud):
  - 1 epoch na 50k przykładach
  - 1× H100 80GB
  - ~24 godziny
  - Koszt: ~$50-100 (np. RunPod, Lambda)

Anthropic / OpenAI fine-tuning:
  - Per token: $5-25 / 1M tokenów (training)
  - Per inference: 2-5× droższy niż base model
```

## Workflow w 2026

```
1. Walidacja: czy fine-tuning to right tool?
   ↓ TAK
2. Zbierz 1k high-quality examples (manual labeling)
   ↓
3. Quick LoRA na małym modelu (Llama 3B)
   ↓
4. Eval — czy działa? Iteruj na danych.
   ↓
5. Skaluj — większy model + więcej danych
   ↓
6. DPO/ORPO — preference tuning
   ↓
7. Eval (benchmarks + human eval)
   ↓
8. Deploy (vLLM, Ollama, lub managed serving)
```
