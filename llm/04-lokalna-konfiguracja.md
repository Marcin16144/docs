# Lokalna konfiguracja LLM

## Wymagania sprzętowe

### Pamięć VRAM (GPU) — kluczowy parametr

Dla **inferencji** w pełnej precyzji (FP16):
```
Rozmiar modelu × 2 bajty/param = wymagane VRAM
```

| Model | FP16 (oryginalne) | INT8 (Q8) | INT4 (Q4) | Hardware |
|-------|------------------|-----------|-----------|----------|
| 1B | 2 GB | 1 GB | 0.5 GB | CPU/iGPU |
| 3B | 6 GB | 3 GB | 1.5 GB | RTX 3060 |
| 7B | 14 GB | 7 GB | 4 GB | RTX 3060 (Q4) |
| 8B | 16 GB | 8 GB | 5 GB | RTX 3060 (Q4) |
| 13B | 26 GB | 13 GB | 7 GB | RTX 4090 (Q8) |
| 30B | 60 GB | 30 GB | 17 GB | RTX 4090 (Q4) |
| 70B | 140 GB | 70 GB | 40 GB | 2× RTX 4090 (Q4) |
| 405B | 810 GB | 405 GB | 230 GB | klaster GPU |

### Polecane konfiguracje

**Budżet (do $1500):**
- RTX 4060 Ti 16GB lub używana RTX 3090 24GB
- 32GB RAM
- Modele do 13B w Q4, 7B w Q8

**Średni segment ($2000-3000):**
- RTX 4090 24GB
- 64GB RAM
- Modele do 30B w Q4, 13B w Q8

**Profesjonalny ($5000+):**
- 2× RTX 4090 lub RTX 6000 Ada (48GB)
- 128GB RAM
- Modele 70B w Q4

**Apple Silicon (alternatywa):**
- Mac Studio M2/M3 Ultra z 192GB unified memory
- Modele do 70B+ działają natywnie
- Wolniejsze niż NVIDIA, ale prostsze i cichsze

### CPU-only (bez GPU)

Z dobrymi narzędziami (llama.cpp) i RAM 32-64GB można uruchamiać modele 7B-13B na samym CPU. Wolne (~5-15 tokens/s), ale działa. Idealne do eksperymentów.

## Kwantyzacja — czyli jak zmieścić więcej

Kwantyzacja zmniejsza precyzję wag z FP16 (16 bitów) do mniejszych formatów:

| Format | Bity | Jakość | Rozmiar vs FP16 |
|--------|------|--------|-----------------|
| FP16 | 16 | 100% (oryginał) | 100% |
| INT8 (Q8) | 8 | ~99% | 50% |
| Q6_K | 6 | ~98% | 37% |
| Q5_K_M | 5 | ~95% | 31% |
| **Q4_K_M** | 4 | ~93% | **25%** ← sweet spot |
| Q3_K_M | 3 | ~85% | 19% |
| Q2_K | 2 | ~70% | 12% |

**Q4_K_M** to najczęstszy wybór — duża redukcja rozmiaru przy minimalnej utracie jakości.

### Formaty kwantyzacji

| Format | Narzędzie | Zastosowanie |
|--------|-----------|--------------|
| **GGUF** | llama.cpp, Ollama, LM Studio | CPU + GPU, najpopularniejszy lokalnie |
| **GPTQ** | Transformers, vLLM | GPU-only, dobry do produkcji |
| **AWQ** | vLLM, TGI | GPU-only, lepsza jakość niż GPTQ |
| **EXL2** | ExLlamaV2 | GPU-only, NVIDIA, bardzo szybki |
| **bitsandbytes** | Transformers (load_in_4bit) | Łatwy w użyciu, dobry do fine-tuningu |

## Narzędzia — od najprostszych do zaawansowanych

### 1. Ollama — najszybszy start

Najprostszy sposób na uruchomienie LLM lokalnie. CLI + serwer HTTP.

**Instalacja (Windows/Linux/Mac):**
```bash
# https://ollama.com
curl -fsSL https://ollama.com/install.sh | sh
```

**Użycie:**
```bash
# Pobierz i uruchom model
ollama run llama3.2

# W tle (jako serwer)
ollama serve

# Lista zainstalowanych
ollama list

# Usuń
ollama rm llama3.2
```

**API (kompatybilne z OpenAI):**
```python
import openai

client = openai.OpenAI(
    base_url="http://localhost:11434/v1",
    api_key="ollama"  # nie sprawdzane
)

response = client.chat.completions.create(
    model="llama3.2",
    messages=[{"role": "user", "content": "Cześć!"}]
)
```

**Modele dostępne:** llama3.3, mistral, qwen2.5, phi3, gemma2, deepseek-r1, codellama i wiele innych.

### 2. LM Studio — GUI dla początkujących

GUI desktop app z chatem, biblioteką modeli, serwerem API.

- Pobierz z **lmstudio.ai**
- Wbudowane wyszukiwanie modeli z Hugging Face
- Chat interface
- Lokalny serwer (kompatybilny z OpenAI API)
- Profile inferencji (kontekst, temperatura, GPU offload)

Idealny dla osób, które chcą wszystko w jednym miejscu bez terminala.

### 3. llama.cpp — niskopoziomowe, najszybsze CPU

Napisane w C++, twórca: Georgi Gerganov. Standard dla GGUF.

**Kompilacja:**
```bash
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -B build -DGGML_CUDA=ON  # CUDA
cmake --build build --config Release
```

**Inferencja:**
```bash
# Pobierz model GGUF z Hugging Face
./llama-cli -m models/llama-3.2-3b-q4_k_m.gguf \
    -p "Stolicą Polski jest" \
    -n 100 \
    --gpu-layers 32
```

**Server (kompatybilny z OpenAI):**
```bash
./llama-server -m models/llama-3.2-3b-q4_k_m.gguf \
    --port 8080 \
    --gpu-layers 32 \
    --ctx-size 4096
```

### 4. vLLM — produkcyjny serving

Wysokowydajny serwer LLM od UC Berkeley. Najlepszy wybór dla produkcji.

**Instalacja:**
```bash
pip install vllm
```

**Użycie:**
```bash
# Server kompatybilny z OpenAI API
vllm serve meta-llama/Llama-3.1-8B-Instruct \
    --gpu-memory-utilization 0.9 \
    --max-model-len 8192 \
    --quantization awq  # opcjonalnie
```

**Zalety:**
- **PagedAttention** — efektywne zarządzanie pamięcią KV cache
- **Continuous batching** — dynamiczne batchowanie requestów
- 2-10× szybszy niż naive serving
- Wsparcie tensor parallelism

### 5. Text Generation WebUI (oobabooga)

GUI webowe + zaawansowane funkcje (LoRA, fine-tuning, character cards):
```bash
git clone https://github.com/oobabooga/text-generation-webui
cd text-generation-webui
./start_windows.bat  # lub start_linux.sh
```

Idealne dla power users i fine-tuningu.

### 6. Inne narzędzia
- **Text Generation Inference (TGI)** — Hugging Face, produkcyjny serving
- **MLC LLM** — uniwersalny (mobile, web, desktop)
- **ExLlamaV2** — najszybsza inferencja na NVIDIA GPU
- **MLX** — Apple Silicon, natywny framework

## Pełna konfiguracja krok po kroku (Windows + RTX 3060/4060+)

### Krok 1: Sprawdź swoje zasoby
```powershell
# GPU
nvidia-smi

# RAM
systeminfo | findstr "Memory"
```

### Krok 2: Zainstaluj Ollama
1. Pobierz instalator z **ollama.com**
2. Uruchom — instaluje się jako usługa systemowa
3. Sprawdź:
```bash
ollama --version
```

### Krok 3: Pobierz pierwszy model
```bash
# Mały i szybki na początek
ollama pull llama3.2:3b

# Średni — uniwersalny
ollama pull llama3.1:8b

# Coding-specific
ollama pull qwen2.5-coder:7b

# Reasoning
ollama pull deepseek-r1:8b
```

### Krok 4: Test
```bash
ollama run llama3.2:3b
```

### Krok 5: Integracja z aplikacjami
- **Claude Code / Cursor** — można skonfigurować na lokalny endpoint
- **Continue.dev** (VS Code extension) — natywne wsparcie Ollama
- **OpenWebUI** — GUI webowy z funkcjami ChatGPT
- Własna aplikacja Python — używaj OpenAI SDK z `base_url="http://localhost:11434/v1"`

## Wybór modelu

### Do czatu i ogólnych zadań
- **Llama 3.3 70B** (Q4) — najlepszy open source overall
- **Llama 3.1 8B** — szybki, wystarczający do większości zadań
- **Mistral 7B / Mixtral 8x7B** — dobre do języków innych niż angielski
- **Qwen 2.5 72B** — najnowszy state of the art open source

### Do kodu
- **Qwen 2.5 Coder** (7B / 32B) — obecnie najlepszy open source coder
- **DeepSeek Coder V2** — dobry, multilingual coding
- **Codestral** (Mistral) — komercyjny, ale dostępny

### Do reasoning (matematyka, logika)
- **DeepSeek R1** (różne rozmiary) — open source o1-like reasoning
- **Qwen 2.5 Math**

### Małe i szybkie
- **Llama 3.2 1B/3B** — działają nawet na laptopie
- **Phi-3.5 mini** — Microsoft, mała ale skuteczna
- **Gemma 2 2B** — Google, dobra jakość

### Multimodalne (vision)
- **Llama 3.2 Vision 11B/90B**
- **Qwen 2.5 VL**
- **Pixtral** (Mistral)

## Optymalizacja wydajności

### Ile tokenów/s możesz oczekiwać?

| GPU | Model | Q4 | FP16 |
|-----|-------|----|----|
| RTX 3060 12GB | 7B | 30 t/s | OOM |
| RTX 4070 12GB | 7B | 50 t/s | OOM |
| RTX 4090 24GB | 7B | 100+ t/s | 60 t/s |
| RTX 4090 24GB | 70B | 8-12 t/s | OOM |
| 2× RTX 4090 | 70B | 25-35 t/s | OOM |
| Mac M3 Max | 70B | 8-10 t/s | OOM |

### Tipy
1. **Używaj kwantyzacji** — Q4_K_M to 99% przypadków
2. **Maksymalizuj GPU offload** — `--gpu-layers 999` w llama.cpp
3. **Włącz Flash Attention** — szybsze i mniej VRAM
4. **Continuous batching** dla wielu użytkowników (vLLM)
5. **Speculative decoding** — mały model "podpowiada", duży weryfikuje
6. **KV cache quantization** — dla bardzo długich kontekstów

## Bezpieczeństwo i prywatność

Lokalne LLM oferują:
- **Pełna prywatność** — żadne dane nie wychodzą z komputera
- **Brak cenzury polityk dostawcy** — odpowiada na więcej tematów (uważaj na uncensored modele!)
- **Pracuj offline** — działają bez internetu (po pobraniu)
- **Brak limitów rate** — generuj ile chcesz
- **Pełna kontrola** — możesz fine-tunować, modyfikować

Idealne dla:
- Wrażliwych danych firmowych
- Dokumentów osobistych
- Pracy w środowiskach bez internetu
- Nauki i eksperymentowania
