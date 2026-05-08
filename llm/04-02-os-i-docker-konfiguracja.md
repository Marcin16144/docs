# Konfiguracja lokalnych LLM — Mac vs Windows vs Linux + Docker

## TL;DR — szybka rekomendacja

| System | Najlepszy stack | Docker? | Komentarz |
|--------|-----------------|---------|-----------|
| **Mac (Apple Silicon M1-M4)** | **Ollama** + LM Studio + MLX | ❌ NIE dla LLM | Natywnie 2-5× szybciej niż Docker |
| **Windows + NVIDIA** | **Ollama** + WSL2 (opcjonalnie) | ⚠️ Tylko z WSL2 | Natywne CUDA jest najszybsze |
| **Linux + NVIDIA** | **Ollama** lub vLLM | ✅ TAK, szczególnie dla produkcji | Najlepszy dla developerów ML |
| **Mac (Intel)** | Ollama (CPU) | Można | GPU już niewspierane przez Apple |
| **Linux + AMD GPU** | Ollama z ROCm | ⚠️ Skomplikowane | Wymaga konfiguracji ROCm |

## Porównanie narzędzi (stan na 2026)

### Ollama ⭐ (rekomendowany dla większości)

**Co to:** Najprostszy serwer LLM. CLI + API + biblioteka modeli.

**Plusy:**
- Zero konfiguracji — `ollama run llama3.3` i działa
- Auto-download modeli z biblioteki
- API kompatybilne z OpenAI
- Działa na wszystkich OS (Mac, Win, Linux)
- Auto GPU detection (CUDA, Metal, ROCm)
- Mała pamięć — modele są ładowane tylko gdy potrzebne
- Aktywny rozwój, ogromna społeczność (2026: 100k+ gwiazdek na GitHub)

**Minusy:**
- Mniej kontroli niż llama.cpp
- Mniej parametrów konfiguracji niż vLLM (ale wystarczające dla 95% użytkowników)
- Nie wspiera tensor parallelism (multi-GPU dla jednego dużego modelu)

**Instalacja:**
```bash
# Mac
brew install ollama
# lub: pobierz z ollama.com

# Windows
# Pobierz instalator z ollama.com (natywny exe)

# Linux
curl -fsSL https://ollama.com/install.sh | sh
```

**Użycie:**
```bash
ollama pull llama3.3:70b      # download
ollama run llama3.3:70b       # interactive chat
ollama serve                  # API on localhost:11434
ollama list                   # list installed
ollama ps                     # running models
ollama rm llama3.3:70b        # delete
```

### LM Studio ⭐ (najlepszy GUI)

**Co to:** Desktop GUI z chatem, biblioteką modeli, lokalnym serwerem API.

**Plusy:**
- Najlepsze GUI dla niezaawansowanych
- Wbudowane wyszukiwanie i pobieranie modeli z HuggingFace
- Visual chat interface (jak ChatGPT)
- API kompatybilny z OpenAI
- Profile inferencji (kontekst, temp, GPU offload)
- Wsparcie multi-modal (vision)
- Działa Mac (Apple Silicon i Intel), Win, Linux

**Minusy:**
- Closed-source (free, ale nie open)
- Cięższy niż Ollama (~500MB vs ~100MB)
- Mniej elastyczny dla automatyzacji

**Najlepszy dla:** Osób które chcą "kliknąć i działa"

### llama.cpp (najwięcej kontroli)

**Co to:** Niskopoziomowy serwer w C++. Ollama używa llama.cpp pod spodem.

**Plusy:**
- Najszybszy CPU inference (porównywalnie do GPU dla małych modeli)
- Pełna kontrola: każdy parametr eksponowany
- Najmniejsze zużycie pamięci
- Wsparcie wszystkich architektur (Vulkan, Metal, CUDA, ROCm, CPU AVX)
- Plikowy format GGUF — modele można łatwo przenosić

**Minusy:**
- Wymaga kompilacji (trochę ops)
- Steeper learning curve
- Trzeba ręcznie pobierać modele (HuggingFace)

**Kompilacja (Linux/Mac):**
```bash
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
cmake -B build -DGGML_CUDA=ON   # NVIDIA
# lub: -DGGML_METAL=ON           # Mac
# lub: -DGGML_VULKAN=ON          # AMD/Intel via Vulkan
cmake --build build --config Release -j
```

### vLLM ⭐ (produkcja)

**Co to:** Wysokowydajny serwer LLM od UC Berkeley.

**Plusy:**
- **Najwyższy throughput** (2-10× szybszy niż Ollama dla wielu requestów naraz)
- PagedAttention, continuous batching
- OpenAI-compatible API
- Wsparcie tensor parallelism (multi-GPU)
- Speculative decoding, prefix caching
- Wybór dla produkcji

**Minusy:**
- Tylko Linux (oficjalnie)
- Tylko NVIDIA (CUDA) — brak Metal, oficjalnie też brak ROCm production
- Wymaga Pythona, więcej setupu
- Cięższy w pamięci

**Instalacja:**
```bash
pip install vllm
vllm serve meta-llama/Llama-3.3-70B-Instruct \
    --gpu-memory-utilization 0.9 \
    --quantization awq
```

### Text Generation WebUI (oobabooga)

**Co to:** Web GUI z bardzo wieloma funkcjami (LoRA, fine-tuning, character cards).

**Plusy:**
- Najwięcej funkcji w GUI
- Wsparcie wielu backends (llama.cpp, ExLlamaV2, transformers)
- Built-in extensions (TTS, STT, image gen)
- LoRA training w GUI
- Character / persona cards (chat z postaciami)

**Minusy:**
- Bardziej skomplikowany setup niż Ollama
- Heavy (Python + wiele zależności)
- Mniej polished UI niż LM Studio

**Najlepszy dla:** Power users, fine-tuning, eksperymenty

### Jan ⭐ (open-source alternatywa LM Studio)

**Co to:** Open source desktop app, podobne do LM Studio.

**Plusy:**
- W pełni open source
- Privacy-first (brak telemetrii)
- Cross-platform (Mac, Win, Linux)
- Built-in model hub
- Local API server

**Minusy:**
- Mniej dojrzały niż LM Studio
- Mniejsza społeczność

**Instalacja:** jan.ai

### GPT4All

**Co to:** Lokalne LLM z chat GUI od Nomic AI.

**Plusy:**
- Bardzo prosty
- Dobry dla początkujących
- Cross-platform
- Wsparcie dokumentów (lokalne RAG)

**Minusy:**
- Wolniejszy niż Ollama/llama.cpp
- Mniej modeli
- Mniejsza elastyczność

### Inne narzędzia

| Narzędzie | Use case |
|-----------|----------|
| **MLX (Apple)** | Trening na Mac — natywny framework Apple |
| **MLC LLM** | Multi-platform: phone, browser, desktop (WebGPU) |
| **ExLlamaV2** | Najszybsza inference NVIDIA (kosztem trudnego setupu) |
| **TGI (HuggingFace)** | Alternatywa vLLM, dobra integracja z HF Hub |
| **NVIDIA NIM** | Production-grade serving NVIDIA |
| **OpenWebUI** | Web GUI łączący się z Ollama (chat jak ChatGPT) |

## Porównanie systemów operacyjnych

### macOS (Apple Silicon M1-M4)

**Plusy:**
- **Unified memory** — całe RAM dostępne dla GPU bez transferu
- 24-192 GB "VRAM" (zależnie od modelu Maca)
- Natywny Metal backend → świetna wydajność per Watt
- MLX framework — najszybszy na Apple Silicon
- Cichy, niski pobór energii (~30W idle)
- Excellent dev experience

**Minusy:**
- Brak CUDA — niektóre biblioteki (np. bitsandbytes) nie działają natywnie
- Wolniejsze pure throughput vs RTX 4090/5090
- Większość poradników zakłada NVIDIA
- Trening dużych modeli (>13B) wolny

**Realna wydajność (Llama 3.1 8B, Q4_K_M):**
| Hardware | Tokens/s |
|----------|----------|
| M1 (16GB) | ~20 t/s |
| M2 Pro (32GB) | ~30 t/s |
| M3 Max (32GB) | ~40 t/s |
| M3 Max (64GB) | ~45 t/s |
| M4 Max (128GB) | ~55 t/s |
| M4 Ultra (256GB) Studio | ~70 t/s |

**Co zainstalować na Mac:**
```bash
# Ollama (najprostsze)
brew install ollama

# Lub pobierz z ollama.com (natywny .app)

# Test
ollama run llama3.2:3b
```

**Hint:** Mac Studio z M-series Ultra to najlepszy "tańszy alternatyw" dla GPU clustera dla małych zespołów.

### Windows

**Plusy:**
- Natywne CUDA, najszybsze inferencja na NVIDIA
- Najlepszy hardware-to-price ratio (RTX 4090 24GB ~$1500)
- Większość gier-tier sprzętu działa
- Dobry support narzędzi

**Minusy:**
- Niektóre narzędzia ML zakładają Linux (vLLM nie ma natywnego support)
- Path issues, Python issues
- Docker Desktop wymagany dla niektórych workflowów
- Antywirus może spowalniać

**Konfiguracja na Windows:**

#### Opcja 1: Natywnie (rekomendowane dla Ollama, LM Studio)
```powershell
# Ollama
# Pobierz instalator z ollama.com
# Auto-detection CUDA, działa od razu

# LM Studio
# Pobierz z lmstudio.ai
```

#### Opcja 2: WSL2 (rekomendowane dla vLLM, Linux-only tools)
```powershell
# Włącz WSL2
wsl --install -d Ubuntu

# W Ubuntu (WSL2):
sudo apt update && sudo apt install -y python3-pip
curl -fsSL https://ollama.com/install.sh | sh

# WSL2 ma dostęp do GPU NVIDIA via WSL CUDA
nvidia-smi   # powinno działać
```

**WSL2 tipy:**
- Sprawdź WSL CUDA: `nvidia-smi` w Ubuntu pokaże GPU
- Pliki: trzymaj w WSL filesystem (`/home/user/`), nie `/mnt/c/...` — znacznie szybsze
- Pamięć: domyślnie WSL2 może użyć 50% RAM hosta. Dla LLM zwiększ w `~/.wslconfig`:
```ini
[wsl2]
memory=64GB
processors=12
```

### Linux

**Plusy:**
- **Najlepsze wsparcie ML** — wszystkie tools działają natywnie
- vLLM, Triton, TensorRT-LLM tylko tu
- Pełna kontrola nad systemem
- Najszybszy Docker (kontenery natywnie)
- Najtaniej dla cloud GPU (Lambda, RunPod używają Linuxa)

**Minusy:**
- Wymaga doświadczenia z Linuxem
- Driver issues (NVIDIA drivers, CUDA versions)
- Setup zajmuje więcej czasu

**Rekomendowane distro:** Ubuntu 24.04 LTS (najszerzej wspierane) lub Pop!_OS (świetne NVIDIA drivers out-of-the-box).

**Setup Linux + NVIDIA:**
```bash
# 1. NVIDIA drivers
sudo ubuntu-drivers autoinstall
sudo reboot

# 2. CUDA toolkit
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update && sudo apt install -y cuda-toolkit-12-6

# 3. Test
nvidia-smi

# 4. Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama serve  # automatycznie używa CUDA
```

## Docker dla LLM — kiedy używać?

### TL;DR
- **Mac**: ❌ NIE dla inferencji (~30-50% spowolnienie)
- **Windows + WSL2**: ⚠️ Można w WSL2 (bezpośredni dostęp do GPU), ale natywnie szybciej
- **Linux + NVIDIA**: ✅ TAK, marginalna utrata wydajności (~5%) lub brak

### Dlaczego Docker na Mac to ZŁY pomysł dla LLM?

```
┌────────────────────────────────────┐
│  Mac (Apple Silicon)                │
│                                     │
│  Docker Desktop:                    │
│  ┌──────────────────────────────┐  │
│  │  Linux VM (x86_64 emulation) │  │  ← Tu jest problem
│  │  ┌────────────────────────┐  │  │
│  │  │  Container             │  │  │  ← LLM tutaj
│  │  └────────────────────────┘  │  │
│  └──────────────────────────────┘  │
│        ↑                            │
│  Brak dostępu do Apple GPU/Metal!  │
│  Brak unified memory!               │
└────────────────────────────────────┘
```

**Konsekwencje:**
- Brak akceleracji Metal (GPU) — wszystko na CPU
- Emulacja x86 (jeśli kontenery są x86) → kolejna degradacja
- Brak access do unified memory
- 2-5× wolniej niż natywnie

**Wyjątek:** Docker na Mac OK dla:
- Vector DB (Qdrant, Postgres) — lekki workload
- API serwery (twoja aplikacja, nie LLM)
- Web UI (Open WebUI łączące się z natywnym Ollama)

**Praktyka na Mac:**
```bash
# LLM natywnie:
brew install ollama
ollama serve  # natywny proces

# Aplikacja w Docker:
docker run -d -p 3000:3000 \
  -e OLLAMA_HOST=http://host.docker.internal:11434 \
  open-webui/open-webui

# host.docker.internal pozwala kontenerowi łączyć się z natywnym Ollama
```

### Docker na Windows

**Docker Desktop na Windows** uruchamia się w WSL2 pod spodem. Zatem:
- Bez WSL2 → wolno (Hyper-V VM)
- Z WSL2 + NVIDIA Container Toolkit → szybko, blisko native

```powershell
# Windows + WSL2 + Docker
wsl --install
# Restart, potem:

# Docker Desktop -> Settings -> Use WSL2 backend
# Settings -> Resources -> WSL Integration: enable Ubuntu

# W WSL2 Ubuntu:
docker run --gpus all -v ollama:/root/.ollama -p 11434:11434 \
    --name ollama ollama/ollama
```

**Werdykt Windows:** Docker w WSL2 działa, ale natywne Ollama jest prostsze i równie szybkie.

### Docker na Linux ⭐

**Tu Docker SHINES.** Marginalny overhead (kernel jest ten sam), pełny dostęp do GPU.

**Setup:**
```bash
# 1. NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo apt update && sudo apt install -y nvidia-container-toolkit
sudo systemctl restart docker

# 2. Test
docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu24.04 nvidia-smi

# 3. Ollama w Docker
docker run -d --gpus=all -v ollama:/root/.ollama \
    -p 11434:11434 --name ollama ollama/ollama

# 4. vLLM w Docker
docker run --gpus all \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -p 8000:8000 \
    --ipc=host \
    vllm/vllm-openai:latest \
    --model meta-llama/Llama-3.3-70B-Instruct
```

### Docker Compose dla pełnego stacka

```yaml
# docker-compose.yml — Linux z GPU
version: '3.8'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama:/root/.ollama
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]

  open-webui:
    image: ghcr.io/open-webui/open-webui:main
    container_name: open-webui
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_BASE_URL=http://ollama:11434
    volumes:
      - open-webui:/app/backend/data
    depends_on:
      - ollama

  qdrant:
    image: qdrant/qdrant:latest
    container_name: qdrant
    ports:
      - "6333:6333"
    volumes:
      - qdrant:/qdrant/storage

volumes:
  ollama:
  open-webui:
  qdrant:
```

## Praktyczne setupy — krok po kroku

### Setup #1: Mac dla developera (M2/M3/M4)

```bash
# 1. Ollama natywnie
brew install ollama

# 2. Open WebUI (chat GUI) - opcjonalnie via Docker
brew install --cask docker
docker run -d -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  --name open-webui ghcr.io/open-webui/open-webui:main

# 3. Modele
ollama pull llama3.3:70b      # ~40GB, działa na 64GB+ Mac
ollama pull qwen2.5-coder:7b  # do kodu
ollama pull deepseek-r1:8b    # reasoning

# 4. Use:
open http://localhost:3000   # Open WebUI
# lub:
ollama run llama3.3:70b
```

### Setup #2: Windows + RTX 4090 dla developera

```powershell
# Opcja A: Tylko Ollama (najszybciej zacząć)
# 1. Pobierz instalator z ollama.com
# 2. Run installer
# 3. Test:
ollama pull llama3.1:8b
ollama run llama3.1:8b

# Opcja B: WSL2 dla pełnego stacka Linux-style
wsl --install -d Ubuntu
# Restart
# W Ubuntu:
curl -fsSL https://ollama.com/install.sh | sh
ollama serve

# Sprawdź GPU:
nvidia-smi  # powinno działać w WSL2
```

### Setup #3: Linux serwer produkcyjny (vLLM)

```bash
# Bazowy Ubuntu 24.04 z NVIDIA driver

# 1. Docker + NVIDIA Container Toolkit
sudo apt install -y docker.io nvidia-container-toolkit
sudo systemctl restart docker

# 2. vLLM serwer
docker run -d --gpus all \
    -v ~/.cache/huggingface:/root/.cache/huggingface \
    -p 8000:8000 \
    --ipc=host \
    --name vllm \
    --restart unless-stopped \
    -e HUGGING_FACE_HUB_TOKEN=$HF_TOKEN \
    vllm/vllm-openai:latest \
    --model meta-llama/Llama-3.3-70B-Instruct-AWQ \
    --quantization awq \
    --max-model-len 8192 \
    --gpu-memory-utilization 0.9

# 3. nginx reverse proxy + SSL (Let's Encrypt)
sudo apt install nginx certbot python3-certbot-nginx
sudo certbot --nginx -d llm.mydomain.com

# 4. Monitoring (Langfuse self-hosted)
# Patrz docker-compose w docs Langfuse
```

### Setup #4: Mac dla rodzinnego użycia (M2/M3 16GB)

```bash
# Ograniczona pamięć — używaj małych modeli
brew install ollama
ollama pull llama3.2:3b       # ~2GB, działa szybko
ollama pull phi-4-mini        # ~2.5GB, świetny mały model
ollama pull qwen2.5:7b-q4    # ~4GB, na granicy

# GUI:
brew install --cask lmstudio  # lub LM Studio z lmstudio.ai
```

## Optymalizacje

### Mac (Apple Silicon)
```bash
# Maksymalizuj GPU layers w llama.cpp
./llama-cli -m model.gguf -ngl 999

# MLX dla najlepszej wydajności
pip install mlx-lm
python -m mlx_lm.generate --model mlx-community/Llama-3.3-70B-Instruct-4bit \
    --prompt "Hello"

# Wyłącz Spotlight indexing dla folderu modeli
sudo mdutil -i off ~/Models
```

### Windows
```powershell
# Ustaw priorytet procesu Ollama
$ollamaProcess = Get-Process ollama
$ollamaProcess.PriorityClass = "High"

# Wyłącz Defender skanowanie modeli
Add-MpPreference -ExclusionPath "C:\Users\$env:USERNAME\.ollama"

# Zwiększ rozmiar pliku swap dla dużych modeli
# System Properties -> Advanced -> Performance -> Settings -> Advanced -> Virtual Memory
```

### Linux
```bash
# Pin Ollama do konkretnych GPU
CUDA_VISIBLE_DEVICES=0,1 ollama serve

# Większy context cache
OLLAMA_KV_CACHE_TYPE=q8_0 ollama serve  # KV cache w int8

# Network tuning dla wielu requestów
sysctl -w net.core.somaxconn=4096
sysctl -w net.ipv4.tcp_max_syn_backlog=4096

# Monitor GPU w czasie rzeczywistym
nvtop  # apt install nvtop
```

## Ile RAM/VRAM potrzebujesz?

```
Quick reference (modele Q4_K_M):

Llama 3.2 1B:    ~1 GB    → laptop, smartphone
Llama 3.2 3B:    ~2 GB    → laptop, mini PC
Llama 3.1 8B:    ~5 GB    → 8GB GPU, M1 8GB
Mistral 7B:      ~5 GB    → tak samo
Llama 13B:       ~8 GB    → 12GB GPU, M2 16GB
Mixtral 8x7B:    ~26 GB   → 32GB GPU lub M3 Pro 36GB
Llama 70B:       ~40 GB   → 2× RTX 4090 lub M3 Max 64GB
Qwen 72B:        ~40 GB   → tak samo
Llama 405B:      ~230 GB  → wymaga klastra (lub Mac Studio Ultra 256GB)
DeepSeek R1:     ~400 GB  → klaster (multi-host)
```

## Rozwiązywanie problemów

### "ollama: command not found"
```bash
# Mac/Linux: dodaj do PATH
export PATH=$PATH:/usr/local/bin
# lub: brew link ollama

# Windows: restart terminala (nowe PATH)
```

### "out of memory" na Mac
- Zamknij niepotrzebne aplikacje (Chrome ma 50 zakładek? 8GB poszło)
- Użyj mniejszej kwantyzacji: Q4_K_M zamiast Q8
- Mniejszy `num_ctx` (kontekst): `OLLAMA_NUM_CTX=2048`

### "CUDA out of memory" na Windows/Linux
```bash
# Zmniejsz GPU memory utilization (vLLM):
--gpu-memory-utilization 0.85  # zamiast 0.9

# Mniejszy kontekst:
OLLAMA_NUM_CTX=4096

# Quantization:
ollama pull llama3.1:70b-q4_K_M  # zamiast q8
```

### Wolna inferencja
```bash
# Sprawdź czy GPU jest używane:
# Mac: 
sudo powermetrics --samplers gpu_power -i 1000
# Linux/Win:
nvidia-smi -l 1

# Jeśli GPU usage = 0% → coś nie działa
# Sprawdź logi Ollama: ollama serve (tail logów)
```

### Docker wolny na Mac
- **Nie używaj Docker do LLM na Mac.** Użyj natywnie.
- Dla aplikacji web tak (Postgres, Redis itp.) — wtedy OK.

## Stack rekomendacje 2026

### "Solo developer, M3 Max 64GB"
```
- Ollama (natywnie) jako serwer LLM
- Open WebUI (Docker) jako GUI 
- Qdrant (Docker) dla RAG
- Continue.dev w VS Code (łączy się z Ollama)
```

### "Solo developer, RTX 4090 24GB Windows"
```
- Ollama (natywnie) lub LM Studio
- Continue.dev / Cursor / Claude Code
- WSL2 + vLLM jeśli potrzebujesz tensor parallelism
```

### "Małe biuro, dedykowany Linux serwer"
```
- vLLM w Docker z Llama 3.3 70B AWQ
- Open WebUI dla zespołu
- Qdrant dla RAG
- nginx + Authentik (SSO)
- Langfuse (observability)
```

### "Privacy-first, no internet"
```
- Mac Studio M4 Ultra 256GB lub Linux + RTX 6000 Ada 48GB
- Ollama z Llama 3.3 70B i Qwen 2.5 72B
- Lokalny RAG: LlamaIndex + Chroma
- Wszystko offline
```

## Częste błędy konfiguracji

❌ **Docker dla LLM na Macu** — 2-5× wolniej, brak GPU
❌ **WSL1 zamiast WSL2** — brak GPU access
❌ **Modele w `/mnt/c/` w WSL2** — wolny disk I/O, używaj `~/`
❌ **Brak NVIDIA drivers** przed instalacją Docker
❌ **Antywirus skanujący modele** — wyłącz exclusion dla folderu `~/.ollama`
❌ **CPU model na laptop dla 70B** — będzie 0.5 t/s, nieużywalne
❌ **Mac Mini 16GB dla 70B** — OOM, użyj Studio z większą pamięcią
❌ **Cudnn/CUDA mismatch** na Linux — używaj nvidia-docker zamiast manual install

## Linki i zasoby

- **Ollama**: ollama.com — biblioteka modeli, instrukcje
- **LM Studio**: lmstudio.ai
- **Jan**: jan.ai (open source LM Studio)
- **Open WebUI**: github.com/open-webui/open-webui
- **vLLM docs**: docs.vllm.ai
- **llama.cpp**: github.com/ggml-org/llama.cpp
- **MLX**: github.com/ml-explore/mlx (Apple)
- **Hugging Face**: huggingface.co/models — pobieranie modeli
- **r/LocalLLaMA**: reddit.com/r/LocalLLaMA — najlepsza społeczność
