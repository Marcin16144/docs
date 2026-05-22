# Wybór karty GeForce do LLM (inferencja i fine-tuning)

## Zasada nr 1: VRAM > wszystko

Jakość modelu, który możesz uruchomić, ogranicza VRAM. Karta z 24 GB uruchomi model, który nie wejdzie w 16 GB — i żadna ilość CUDA cores tego nie zmieni.

## Wymagania VRAM vs model (Q4_K_M, najpopularniejsza kwantyzacja)

| Model | VRAM (Q4) | VRAM (Q8/FP8) | VRAM (FP16) | Polecana karta |
|-------|-----------|---------------|-------------|----------------|
| Llama 3.2 3B | 2 GB | 3 GB | 6 GB | każda |
| Llama 3.1 8B | 5 GB | 9 GB | 16 GB | RTX 5060 Ti 16GB |
| Mistral Nemo 12B | 7 GB | 13 GB | 24 GB | RTX 5060 Ti 16GB |
| Qwen 2.5 14B | 9 GB | 15 GB | 28 GB | RTX 5070 Ti 16GB |
| Gemma 2 27B | 16 GB | 28 GB | 54 GB | RTX 5090 / 2× 5070 Ti |
| Qwen 2.5 32B | 19 GB | 33 GB | 64 GB | RTX 5090 |
| Llama 3.3 70B | 40 GB | 70 GB | 140 GB | 2× RTX 5090 / RTX 6000 |
| DeepSeek-V3 671B | 380 GB+ | — | — | klaster |

> **Zapas na kontekst**: dodaj 1–4 GB na cache (KV cache) przy dłuższych kontekstach (32k–128k tokenów).

## Rekomendacje budżetowe (2026)

### Budżet do 1500 PLN — zacznij eksperymentować
- **RTX 3060 12 GB** (używana, ~800 PLN) — modele 7B–8B w Q4 bez problemu, 13B w Q3
- **RTX 4060 Ti 16 GB** (używana, ~1400 PLN) — 13B w Q4 komfortowo
- 32 GB RAM, dowolny CPU 6+ rdzeni

### Budżet 2500–3500 PLN — sweet spot hobbystyczny
- **RTX 5060 Ti 16 GB** (~2000 PLN) — najtańsza nowa karta z 16 GB
- **RTX 4070 Ti Super 16 GB** (używana ~2500 PLN) — szybsza w surowej wydajności
- 64 GB RAM DDR5

### Budżet 4000–6000 PLN — poważnie
- **RTX 5070 Ti 16 GB** (~3500 PLN) — bardzo szybka, Blackwell + FP4/FP8
- **RTX 4090 24 GB** (używana ~5500 PLN) — przewaga 24 GB nad 5070 Ti
- 64 GB RAM, dobry zasilacz 850 W

### Budżet 8000+ PLN — profesjonalnie
- **RTX 5090 32 GB** (~9000–13000 PLN) — jedyna konsumencka, która unika 70B Q4 z 2× kartą
- 128 GB RAM, zasilacz 1200 W, dobra wentylacja
- Modele 32B w FP8 (jakość niemal FP16), 70B w Q4 z offloadem

### Stacja AI ($5000+)
- **2× RTX 5090** lub **2× RTX 4090** (48–64 GB łącznie z NVLink/tensor parallel)
- 128–256 GB RAM
- Threadripper / EPYC, płyta z 2× PCIe 5.0 x16

## Multi-GPU — kiedy ma sens

Dwie karty pozwalają uruchomić większe modele (tensor parallelism lub layer offload). Ale:

- Wymaga płyty z 2× PCIe x8 (lub x16+x8)
- Zasilacz 1500 W+ dla 2× 5090
- Wentylacja obudowy musi sobie radzić z 1100 W+ ciepła
- Nie wszystkie frameworki dobrze skalują się 2 → 4 → 8 GPU

Często **tańsze i prostsze**: pojedyncza RTX 5090 niż 2× RTX 5080.

## Co z Apple Silicon / AMD?

- **Apple M3/M4 Max/Ultra** — unified memory do 192 GB. Wolniejsze od NVIDIA, ale jedyna realna alternatywa dla modeli 70B+ w domu bez stacji. Idealne do inferencji 24/7 (cicho, mało prądu).
- **AMD Radeon (RX 7900/9070 XT)** — ROCm dojrzewa, ale **wciąż NVIDIA dominuje ekosystem** (CUDA, cuDNN, większość bibliotek). Wybierz tylko gdy świadomie chcesz alternatywy.

## Praktyczne wskazówki konfiguracji

1. **Zainstaluj najnowsze sterowniki Studio** (nie Game Ready) — stabilniejsze pod AI.
2. **CUDA 12.6+** dla RTX 50 (Blackwell).
3. **Wyłącz Resizable BAR** jeśli widzisz dziwne crashe w llama.cpp (rzadkie, ale bywa).
4. **Power limit** — ograniczenie 80% TDP daje ~95% wydajności i znacząco tańszy prąd / mniej ciepła.
5. **Monitor**: `nvidia-smi` na Linux, GPU-Z na Windows.
6. **Trening / fine-tuning** wymaga 2–3× więcej VRAM niż inferencja. LoRA radykalnie obniża wymagania.

## Co dają RTX 50 ponad RTX 40 w LLM

- **FP4** — natywnie 2× szybciej niż FP8 → modele Q4 idą bardzo szybko
- **FP8** — model 32B mieści się w 5090 w pełnej niemal jakości
- **Większy bandwidth** — token generation skaluje liniowo z bandwidth
- **Lepszy `nvidia-cuda-mps`** — multi-process sharing

Praktyczne dane: **RTX 5090 = 25–70% więcej tok/s niż RTX 4090** zależnie od modelu i kwantyzacji.

## Co WYBRAĆ — krótkie rekomendacje

| Profil | Karta |
|--------|-------|
| „Chcę spróbować lokalnego LLM" | RTX 3060 12 GB używana |
| „Chcę używać codziennie 7B–13B" | RTX 5060 Ti 16 GB |
| „Chcę 30B w komforcie" | RTX 5090 |
| „Mam budżet ograniczony, ale chcę 24 GB" | RTX 3090 24 GB używana (~2500 PLN) |
| „Chcę najszybciej, koszt nieistotny" | RTX 5090 (lub 2×) |
| „Cicho i 24/7" | Mac Studio M3 Ultra |

## Sources

- [RTX 5090 vs RTX 4090 for AI: 2026 Benchmark Comparison](https://localaimaster.com/blog/rtx-5090-vs-4090-ai-benchmark)
- [RTX 5090 vs 4090 vs Used 3090: Power GPU for Local LLM Guide](https://www.hostrunway.com/blog/rtx-5090-vs-rtx-4090-used-3090-in-2026-is-the-upgrade-worth-it-for-local-llms/)
- [Best GPU for local LLM Inference and Training – 2026 [Updated] | BIZON](https://bizon-tech.com/blog/best-gpu-llm-training-inference)
- [RTX 5090 for AI Inference: Blackwell, fp8 Performance, and Cloud Rental](https://www.runpod.io/articles/guides/nvidia-rtx-5090)
