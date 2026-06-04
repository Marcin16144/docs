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
- **Claude Code** — natywnie, bez proxy (nowsze Ollamy wystawiają API w formacie Anthropic); szczegóły w sekcji „Claude Code z lokalnym modelem (Ollama)" niżej
- **Cursor** — można skonfigurować na lokalny endpoint
- **Continue.dev** (VS Code extension) — natywne wsparcie Ollama
- **OpenWebUI** — GUI webowy z funkcjami ChatGPT
- Własna aplikacja Python — używaj OpenAI SDK z `base_url="http://localhost:11434/v1"`

## Claude Code z lokalnym modelem (Ollama)

Nowsze wersje Ollamy (zweryfikowano na **0.24**) wystawiają serwer w formacie **Anthropic Messages API** (obok kompatybilnego z OpenAI), więc Claude Code podpinasz **bez żadnego proxy** — dawniej trzeba było stawiać tłumacz (LiteLLM albo claude-code-router). Claude Code steruje się trzema zmiennymi środowiskowymi:

| Zmienna | Wartość | Rola |
|---|---|---|
| `ANTHROPIC_BASE_URL` | `http://localhost:11434` | przekierowanie na Ollamę |
| `ANTHROPIC_AUTH_TOKEN` | `ollama` (dowolny niepusty) | Ollama nie sprawdza, ale CLI wymaga ustawionego |
| `ANTHROPIC_MODEL` | np. `qwen3-coder:30b` | model główny (silnik agenta) |
| `ANTHROPIC_SMALL_FAST_MODEL` | np. `llama3.1:8b` | model zadań tła (tytuły, podsumowania) |

### Launcher opt-in (PowerShell)

> **Nie** wstawiaj tych zmiennych do globalnego `~/.claude/settings.json` — przekierowałbyś **wszystkie** sesje Claude Code (również chmurowe) na lokalny model. Lepszy jest osobny launcher i świadomy wybór, kiedy używasz lokalnego modelu.

Funkcja do profilu PowerShell (`$PROFILE`) — wspólny helper + osobna komenda na każdy serwer Ollama:

```powershell
function Start-ClaudeOllama {
    param([string]$BaseUrl, [string]$Model, [string]$FastModel, [string[]]$Rest)
    $base = "$env:APPDATA\Claude\claude-code"
    $exe = Get-ChildItem $base -Directory -ErrorAction SilentlyContinue |
           Sort-Object LastWriteTime -Descending |
           ForEach-Object { Join-Path $_.FullName 'claude.exe' } |
           Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) { Write-Error "Nie znaleziono claude.exe w $base"; return }
    $env:ANTHROPIC_BASE_URL         = $BaseUrl
    $env:ANTHROPIC_AUTH_TOKEN       = 'ollama'
    $env:ANTHROPIC_MODEL            = $Model
    $env:ANTHROPIC_SMALL_FAST_MODEL = $FastModel
    & $exe @Rest
}

# Lokalna Ollama (ten laptop)
function claude-local  { Start-ClaudeOllama -BaseUrl 'http://localhost:11434'     -Model 'qwen3-coder:30b' -FastModel 'llama3.1:8b' -Rest $args }

# Zdalna Ollama na innej maszynie w sieci
function claude-remote { Start-ClaudeOllama -BaseUrl 'http://192.168.43.55:11434' -Model 'qwen3-coder:30b' -FastModel 'llama3.1:8b' -Rest $args }
```

Uruchomienie: w **nowym** terminalu wpisz `claude-local` (lokalnie) albo `claude-remote` (serwer w sieci). Kolejne serwery dodasz, dopisując następny wrapper. Zwykłe (chmurowe) Claude Code z aplikacji desktop działa dalej bez zmian.

> Aplikacja desktop instaluje `claude.exe` pod wersjonowaną ścieżką (`...\Claude\claude-code\<wersja>\`), której nie ma na PATH — dlatego funkcja sama wybiera najnowszą wersję i przetrwa aktualizacje.

### VS Code (wtyczka `anthropic.claude-code`)

Wtyczka ma wbudowane ustawienie `claudeCode.environmentVariables`, więc endpoint Ollamy podajesz wprost w ustawieniach VS Code — per-workspace (`.vscode/settings.json` w projekcie) albo globalnie (User settings):

```json
{
  "claudeCode.disableLoginPrompt": true,
  "claudeCode.environmentVariables": [
    { "name": "ANTHROPIC_BASE_URL", "value": "http://192.168.43.55:11434" },
    { "name": "ANTHROPIC_AUTH_TOKEN", "value": "ollama" },
    { "name": "ANTHROPIC_DEFAULT_OPUS_MODEL",   "value": "qwen2.5-coder:32b" },
    { "name": "ANTHROPIC_DEFAULT_SONNET_MODEL", "value": "qwen3-coder:30b" },
    { "name": "ANTHROPIC_DEFAULT_HAIKU_MODEL",  "value": "llama3.1:8b" }
  ]
}
```

- `disableLoginPrompt: true` — pomija logowanie chmurowe (auth zewnętrzny = token `ollama`); rozwiązuje konflikt z OAuth.
- Trzy `ANTHROPIC_DEFAULT_*_MODEL` mapują picker Opus/Sonnet/Haiku na realne modele Ollamy.
- `ANTHROPIC_BASE_URL` podajesz **bez** `/v1` (SDK sam dokłada `/v1/messages`).
- Po zmianie: **Reload Window** (Ctrl+Shift+P → „Developer: Reload Window") i zaufaj workspace, gdy VS Code zapyta (Workspace Trust). Jeśli wtyczka dalej trzyma chmurę — `/logout` w panelu Claude.

### Pułapki

- **Kontekst** — Claude Code używa endpointu Anthropic, gdzie **nie podasz `num_ctx`**, więc liczy się domyślny kontekst serwera. Sprawdź go: `ollama ps` (kolumna CONTEXT). Prompt systemowy Claude Code (instrukcje + definicje narzędzi) jest duży, więc domyślne ~16K bywa ciasne — zostaje mało miejsca na pliki i rozmowę. Podnieś domyślny kontekst zmienną i **zrestartuj Ollamę**:
  ```powershell
  setx OLLAMA_CONTEXT_LENGTH 32768
  ```
  > Uwaga (Windows): zmienna zadziała dopiero, gdy **serwer** Ollama wystartuje na nowo z tą zmienną w środowisku. Jeśli Ollama chodzi z podwyższonymi uprawnieniami (proces serwera nie daje się zatrzymać ze zwykłej powłoki), restart też musi być z uprawnieniami admina — albo po prostu zrób reboot. Większy kontekst = większy KV-cache: na 8 GB VRAM część zrzuci się na CPU/RAM i zwolni.
- **`count_tokens`** — Ollama **nie** implementuje endpointu `/v1/messages/count_tokens` (zwraca 404). Claude Code działa mimo to, ale wskaźnik zużycia kontekstu i auto-kompaktowanie liczą „na oko".
- **Tool-use wymagany** — Claude Code to agent; model musi umieć wywoływać narzędzia. Sprawdzone, że poprawne bloki `tool_use` zwracają `llama3.1:8b` i `qwen3-coder:30b`. Modele reasoning (`deepseek-r1`) i vision (`llava`, `qwen3-vl`) słabo nadają się jako główny silnik.
- **Sprzęt** — model główny musi zmieścić się w VRAM, żeby działał szybko. Na 8 GB realny jest `llama3.1:8b`; modele 30B (np. `qwen3-coder:30b`, ~18 GB) zrzucają warstwy na CPU/RAM i chodzą wolno (architektura MoE trochę ratuje, bo aktywne jest tylko ~3B parametrów). Mocniejszą maszynę w sieci podepniesz przez `claude-remote` — wtedy duże modele liczą się tam, a laptop jest tylko klientem.
- **Zdalny serwer** — żeby Ollama była widoczna w sieci, na maszynie serwera ustaw `OLLAMA_HOST=0.0.0.0:11434` i otwórz port 11434 w firewallu. Dostępność sprawdzisz: `curl http://IP:11434/api/version`. Uwaga: ruch w LAN idzie **nieszyfrowany** — nie wystawiaj tego do internetu bez tunelu/VPN.

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
- **Llama 3.2 Vision 11B** — multimodalny model Meta (tekst + obraz), darmowy, Llama Community License. W Ollamie: `ollama pull llama3.2-vision` (~7.9 GB, Q4). Wymaga ~8 GB VRAM (RTX 3060/4060+) lub działa na CPU z 16+ GB RAM (wolno). Kontekst 128K. Dobry do OCR, opisów zdjęć, alt-textów, analizy paragonów/faktur, klasyfikacji obrazów.
- **Llama 3.2 Vision 90B** — wersja flagowa, znacznie dokładniejsza przy złożonych scenach i drobnych szczegółach. W Ollamie: `ollama pull llama3.2-vision:90b` (~55 GB, Q4). Wymaga ~64 GB VRAM — praktycznie tylko karty serwerowe albo Mac Studio M2/M3 Ultra z dużą unified memory.
- **Qwen 2.5 VL** — multimodalny Alibaba, wersje 3B / 7B / 72B, Apache 2.0. Mocny w analizie wykresów, tabel i UI.
- **Pixtral** (Mistral) — 12B, Apache 2.0, dobry w językach europejskich (w tym polski).
- **LLaVA** (Large Language and Vision Assistant) — otwarty model wizyjno-językowy z 2023 (aktualna wersja: LLaVA 1.6 / LLaVA-NeXT, 2024), kod Apache 2.0, wagi dziedziczą licencję bazowego LLM. Architektura: enkoder CLIP ViT-L/14 + projekcja + LLM. Lżejsza, starsza alternatywa dla Llama 3.2 Vision — dobra na słabszy sprzęt. Słabszy OCR i głównie angielski (polski słaby). Warianty w Ollamie:
  - `llava` — Vicuna 7B, ~4.7 GB, ~6 GB VRAM (`ollama pull llava`)
  - `llava:13b` — Vicuna 13B, ~8 GB, ~10 GB VRAM (`ollama pull llava:13b`)
  - `llava:34b` — Yi 34B, ~20 GB, ~24 GB VRAM (`ollama pull llava:34b`)
  - `llava-llama3` — Llama 3 8B, ~5.5 GB, ~8 GB VRAM (`ollama pull llava-llama3`)
  - `llava-phi3` — Phi-3 mini, ~2.9 GB, ~4 GB VRAM — najlżejszy, działa na laptopie bez mocnego GPU (`ollama pull llava-phi3`)

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
