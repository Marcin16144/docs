# Trenowanie LLM na Apple M2 Max 32GB

## Twoja konfiguracja — co masz do dyspozycji

**Apple M2 Max** (rok 2023):
- **CPU**: 12-rdzeniowy (8 wydajnych + 4 oszczędnych)
- **GPU**: 30 lub 38 rdzeni (model M2 Max)
- **Neural Engine**: 16 rdzeni, 15.8 TOPS
- **Memory bandwidth**: ~400 GB/s (unified memory!)
- **RAM**: 32 GB ujednolicone (dzielone CPU/GPU)
- **Realna VRAM dla ML**: ~24 GB (system zostawia ~8 GB)

### Co to znaczy dla LLM?

```
Plus (vs PC z RTX 4070 12GB):
✓ Więcej "VRAM" (24 GB vs 12 GB) → większe modele
✓ Unified memory → brak transferu CPU↔GPU
✓ Cichy, niski pobór energii (~30W idle)
✓ Świetny do inferencji modeli 7B-13B w pełnej precyzji
✓ Modele 30B w Q4 działają komfortowo

Minus (vs RTX 4090):
✗ Wolniejszy w treningu (~3-5× wolniejszy niż RTX 4090)
✗ Brak CUDA — nie wszystkie biblioteki działają
✗ Większość poradników jest pod NVIDIA
✗ Trening dużych modeli (>13B) bardzo wolny
```

## Realny zasięg — co możesz zrobić?

### ✅ Inferencja (uruchamianie modeli)

| Model | Format | Działa? | Tokens/s |
|-------|--------|---------|----------|
| Llama 3.2 1B | FP16 | ✓ Tak | ~80 t/s |
| Llama 3.2 3B | FP16 | ✓ Tak | ~50 t/s |
| Llama 3.1 8B | FP16 | ✓ Tak | ~25 t/s |
| Llama 3.1 8B | Q4_K_M | ✓ Tak | ~45 t/s |
| Mistral 7B | Q4_K_M | ✓ Tak | ~50 t/s |
| Llama 3 70B | Q4_K_M | ⚠ Tak ale wolno | ~3-5 t/s |
| Llama 3 70B | Q5_K_M | ✗ Brak pamięci | - |

### ⚠ Fine-tuning (z LoRA/QLoRA)

| Model | Metoda | Działa? | Czas (10k examples, 3 epoki) |
|-------|--------|---------|-------------------------------|
| Llama 3.2 1B | LoRA | ✓ | ~2-3h |
| Llama 3.2 3B | LoRA | ✓ | ~6-8h |
| Llama 3.1 8B | QLoRA | ✓ | ~12-20h |
| Llama 3.1 8B | LoRA | ⚠ Ledwo | ~24h+ |
| Mistral 7B | QLoRA | ✓ | ~10-15h |
| Llama 13B | QLoRA | ⚠ Ledwo | 30h+ |

### ❌ Czego NIE zrobisz

- Trening modeli od zera (>1B parametrów) — za mało mocy
- Fine-tuning modeli 70B — zbyt wolne (tygodnie)
- Trening RLHF na dużych modelach
- Trening reasoning models (R1-style RL)

## Stack technologiczny dla M2 Max

### MLX — kluczowy framework (Apple-native)

**MLX** to natywny framework od Apple, zaprojektowany dla Apple Silicon. **Najszybsza opcja** treningu i inferencji na M2/M3/M4.

```bash
pip install mlx mlx-lm
```

**Inferencja:**
```python
from mlx_lm import load, generate

model, tokenizer = load("mlx-community/Llama-3.1-8B-Instruct-4bit")
response = generate(
    model, tokenizer,
    prompt="Wyjaśnij CAP theorem",
    max_tokens=512,
    temp=0.7
)
print(response)
```

**Fine-tuning z LoRA w MLX:**
```bash
# 1. Pobierz model w formacie MLX
huggingface-cli download mlx-community/Llama-3.2-3B-Instruct-4bit

# 2. Przygotuj dane (JSONL z polami: messages)
# train.jsonl, valid.jsonl

# 3. Trenuj LoRA
python -m mlx_lm.lora \
    --model mlx-community/Llama-3.2-3B-Instruct-4bit \
    --train \
    --data ./my_data \
    --iters 1000 \
    --batch-size 4 \
    --lora-layers 16 \
    --learning-rate 1e-5

# 4. Merge i konwertuj
python -m mlx_lm.fuse \
    --model mlx-community/Llama-3.2-3B-Instruct-4bit \
    --adapter-path adapters \
    --save-path my_finetuned_model
```

**Plus MLX:**
- Zoptymalizowane pod Apple Silicon (50-100% szybsze niż PyTorch MPS)
- Lazy evaluation, automatyczna optymalizacja
- Unified memory bezpośrednio
- Łatwa konwersja modeli z HF
- mlx-community na HF z setkami modeli

### PyTorch z MPS backend — alternatywa

PyTorch wspiera Apple GPU przez **MPS** (Metal Performance Shaders), ale jest wolniejszy niż MLX i czasem niestabilny.

```python
import torch

device = "mps" if torch.backends.mps.is_available() else "cpu"
model.to(device)
```

**Problemy z MPS:**
- Niektóre operacje brakują (fallback na CPU = wolno)
- Niektóre featery (np. flash-attention) niedostępne
- bitsandbytes (quantization) nie działa natywnie
- Czasami crash na dużych modelach

**Workaround**: użyj `PYTORCH_ENABLE_MPS_FALLBACK=1` dla brakujących operacji.

### llama.cpp — najszybszy do inferencji GGUF

```bash
# Build z Metal
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -B build -DGGML_METAL=ON
cmake --build build --config Release

# Inferencja
./build/bin/llama-cli \
    -m models/llama-3.1-8b-instruct-q4_k_m.gguf \
    -p "Hello" -n 200 -ngl 999  # ngl=999 → wszystko na GPU
```

### Ollama — najprostsze użycie

```bash
brew install ollama
ollama pull llama3.2:3b
ollama run llama3.2:3b
```

Ollama używa llama.cpp pod spodem z optymalizacjami Metal. Zero konfiguracji.

## Krok po kroku: fine-tuning Llama 3.2 3B

Najbardziej praktyczny scenariusz dla M2 Max 32GB.

### Krok 1: Setup środowiska

```bash
# Python 3.11+ (lepiej z conda/mamba)
brew install miniconda
conda create -n llm python=3.11
conda activate llm

# Zainstaluj MLX
pip install mlx mlx-lm

# Zainstaluj HF CLI
pip install huggingface_hub
huggingface-cli login  # token z huggingface.co
```

### Krok 2: Przygotuj dataset

```python
# prepare_data.py
import json
import random

# Twoje dane — przykład: pary instrukcja-odpowiedź
data = [
    {
        "messages": [
            {"role": "user", "content": "Co to jest mikroserwis?"},
            {"role": "assistant", "content": "Mikroserwis to..."}
        ]
    },
    # ... więcej przykładów (min. 500-1000)
]

random.shuffle(data)
split = int(0.95 * len(data))
train, valid = data[:split], data[split:]

import os
os.makedirs("my_data", exist_ok=True)

with open("my_data/train.jsonl", "w") as f:
    for ex in train:
        f.write(json.dumps(ex, ensure_ascii=False) + "\n")

with open("my_data/valid.jsonl", "w") as f:
    for ex in valid:
        f.write(json.dumps(ex, ensure_ascii=False) + "\n")
```

### Krok 3: Pobierz model

```bash
# Llama 3.2 3B w 4-bit (~2 GB)
huggingface-cli download mlx-community/Llama-3.2-3B-Instruct-4bit \
    --local-dir models/llama-3.2-3b-mlx
```

### Krok 4: Konfiguracja treningu

```yaml
# lora_config.yaml
model: "models/llama-3.2-3b-mlx"
data: "my_data"
train: true
iters: 1000
batch_size: 4
val_batches: 25
learning_rate: 1.0e-5
lora_layers: 16
adapter_path: "adapters/my_lora"
save_every: 100
test: false
```

### Krok 5: Trenowanie

```bash
python -m mlx_lm.lora --config lora_config.yaml
```

Co zobaczysz:
```
Iter 1: Train loss 2.456, Iter time 2.341s
Iter 10: Train loss 1.987, Iter time 2.298s
Iter 100: Val loss 1.654, Val time 12.1s
...
```

**Czas dla 1000 iteracji: ~2-3 godziny** dla 3B modelu z batch 4.

### Krok 6: Test inferencji z adapterem

```python
from mlx_lm import load, generate

model, tokenizer = load(
    "models/llama-3.2-3b-mlx",
    adapter_path="adapters/my_lora"
)

response = generate(
    model, tokenizer,
    prompt="Co to jest mikroserwis?",
    max_tokens=200,
    verbose=True
)
```

### Krok 7: Merge adaptera (opcjonalnie)

```bash
python -m mlx_lm.fuse \
    --model models/llama-3.2-3b-mlx \
    --adapter-path adapters/my_lora \
    --save-path models/my-finetuned-llama-3b \
    --de-quantize  # opcjonalnie - de-quantize do FP16
```

### Krok 8: Konwertuj do GGUF dla Ollama

```bash
# llama.cpp ma skrypt convert_hf_to_gguf.py
python llama.cpp/convert_hf_to_gguf.py \
    models/my-finetuned-llama-3b \
    --outfile my-model.gguf \
    --outtype q4_k_m

# Zaimportuj do Ollama
echo "FROM ./my-model.gguf" > Modelfile
ollama create my-model -f Modelfile
ollama run my-model
```

## Optymalizacje wydajności na M2 Max

### 1. Batch size — kluczowe dla unified memory

```python
# Dla M2 Max 32GB
# Llama 3B LoRA: batch_size=4-8
# Llama 8B QLoRA: batch_size=1-2
# Większy batch = lepsze gradient signal, ale więcej RAM
```

### 2. Gradient accumulation

Zamiast większego batcha — symuluj:
```python
# Effective batch = batch_size * grad_accum_steps
batch_size = 2
grad_accum_steps = 4
# Effective batch = 8, ale RAM jak dla 2
```

### 3. Sequence length

Krótsze sekwencje = mniej RAM:
```python
max_seq_len = 1024  # zamiast 4096 dla małych zadań
```

### 4. Frequency monitoring

```bash
# Monitor w innym oknie
sudo powermetrics --samplers gpu_power -i 1000

# RAM
top -o MEM
# lub Activity Monitor
```

### 5. Wyłącz inne aplikacje

Chrome z 50 zakładkami zjada 8GB. Wyłącz wszystko podczas treningu.

### 6. Termal throttling

M2 Max może throttlować się przy długim obciążeniu. Monitoruj `pmset -g thermlog`.

**Tip**: Ustaw laptop na podstawce z dobrą wentylacją. MacBook Pro vs Studio: Studio ma lepsze chłodzenie.

## Co możesz zrobić — realistyczne scenariusze

### Scenariusz 1: Asystent dla własnej dokumentacji

```
Cel: Fine-tune Llama 3.2 3B na 500 przykładach Q&A
     z dokumentacją Twojej firmy

Czas: 4-6 godzin treningu
Koszt: prąd (~$1)
Efekt: Model który zna Twoją dokumentację

Alternatywa: RAG zamiast fine-tuningu (szybsze, łatwiej aktualizować)
```

### Scenariusz 2: Specyficzny styl/format odpowiedzi

```
Cel: Model odpowiadający w specyficznym stylu marki
     (np. krótko, profesjonalnie, bez emoji)

Dane: 300-1000 przykładów
Czas: 2-4 godziny
Model: Llama 3.2 3B + LoRA
```

### Scenariusz 3: Klasyfikator tekstu

```
Cel: Klasyfikuj tickety supportowe na 10 kategorii

Dane: 1000-5000 przykładów
Czas: 3-6 godzin
Model: Llama 3.2 1B + LoRA

Alternatywa: BERT-based encoder (DistilBERT, RoBERTa)
            — mniejszy, szybszy, lepszy do klasyfikacji
```

### Scenariusz 4: Tłumacz domeny (np. medycyna)

```
Cel: Tłumaczenie EN-PL specjalistycznych tekstów medycznych

Dane: 5000-20000 par
Czas: 12-24 godziny
Model: Mistral 7B + QLoRA lub Llama 3 8B + QLoRA

Alternatywa: użyj Claude/GPT przez API — często tańsze
```

### Scenariusz 5: Coding assistant dla swojego frameworka

```
Cel: Asystent generujący kod w Twoim wewnętrznym frameworku

Dane: 2000-10000 przykładów (issue + PR + kod)
Czas: 8-15 godzin
Model: Qwen 2.5 Coder 7B + QLoRA
```

## Czego unikać

❌ **Nie próbuj trenować modeli >13B** — za wolno, niestabilne
❌ **Nie używaj bitsandbytes** — nie działa natywnie na MPS
❌ **Nie ładuj kilku dużych modeli naraz** — OOM
❌ **Nie zostawiaj treningu bez monitoringu na laptopie** — overheating

## Tools cheatsheet

```bash
# Inferencja
brew install ollama         # najprostsze
pip install mlx-lm          # najszybsze (Apple-native)
pip install transformers    # uniwersalne (przez MPS, wolniejsze)

# Fine-tuning
pip install mlx-lm          # główny wybór dla M-series
pip install transformers peft trl    # alternatywa (PyTorch + MPS)

# GUI
# LM Studio (lmstudio.ai) — desktop app
# Ollama + Open WebUI

# Monitoring
sudo powermetrics --samplers gpu_power
top
htop  # brew install htop
```

## Realny benchmark: Llama 3 8B inferencja

```
M2 Max 32GB (38-core GPU):
  llama.cpp + Q4_K_M: ~28 t/s
  MLX + 4-bit:        ~32 t/s
  PyTorch + MPS FP16: ~14 t/s

vs:

RTX 4090 24GB:
  llama.cpp + Q4_K_M: ~120 t/s
  ExLlamaV2:          ~150 t/s

RTX 4070 12GB:
  llama.cpp + Q4_K_M: ~60 t/s
```

M2 Max jest ~3-5× wolniejszy od RTX 4090, ale ~2× szybszy od RTX 3060.

## Kiedy M2 Max NIE wystarczy

Jeśli potrzebujesz:
- Szybszego treningu → cloud GPU (RunPod, Vast.ai, Lambda)
- Większych modeli (70B+) → cloud z H100/A100
- Trening RLHF/GRPO → dedykowane GPU farm

**Cloud alternatywy ($$):**
- **RunPod** — RTX 4090 ~$0.4/h, A100 ~$1.2/h, H100 ~$2.5/h
- **Vast.ai** — często taniej, mniej stabilne
- **Lambda Labs** — $1.2-3/h, łatwy interfejs
- **Modal** — pay-per-second, świetne do okazjonalnych zadań

**Hybrid workflow:**
1. Eksperymentuj lokalnie na M2 Max (małe modele, walidacja kodu)
2. Skaluj na cloud GPU dla finalnych runów
3. Hostuj final model lokalnie na M2 Max do inferencji
