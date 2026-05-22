# RTX 50 Series (Blackwell) — pełna seria desktop

Premiera: styczeń 2025. Architektura **Blackwell** (TSMC 4NP), pamięci **GDDR7**, 5 gen Tensor Cores z natywnym **FP4** i **FP8** (kluczowe dla AI), DLSS 4 z Multi Frame Generation, 4 gen RT Cores.

## Tabela porównawcza — desktop

| Model | CUDA | VRAM | Bus | Bandwidth | TDP | MSRP USD | Zasilacz |
|-------|------|------|-----|-----------|-----|----------|----------|
| **RTX 5090** | 21 760 | 32 GB GDDR7 | 512-bit | 1792 GB/s | 575 W | $1999 | 1000 W |
| **RTX 5080** | 10 752 | 16 GB GDDR7 | 256-bit | 960 GB/s | 360 W | $999 | 850 W |
| **RTX 5070 Ti** | 8 960 | 16 GB GDDR7 | 256-bit | 896 GB/s | 300 W | $749 | 750 W |
| **RTX 5070** | 6 144 | 12 GB GDDR7 | 192-bit | 672 GB/s | 250 W | $549 | 650 W |
| **RTX 5060 Ti** | 4 608 | 8/16 GB GDDR7 | 128-bit | 448 GB/s | 180 W | $379 / $429 | 550 W |
| **RTX 5060** | 3 840 | 8 GB GDDR7 | 128-bit | 448 GB/s | 150 W | $299 | 550 W |
| **RTX 5050** | 2 560 | 8 GB **GDDR6** | 128-bit | 320 GB/s | 130 W | $249 | 500 W |

## Co nowego w Blackwell vs Ada Lovelace

1. **FP4 i FP8 natywnie** — wykonują operacje AI w 4-bit/8-bit z pełną wydajnością. Inferencja LLM przyspiesza **2–3× per dolar VRAM** vs RTX 40.
2. **GDDR7** — wzrost bandwidth o 50–80% względem GDDR6X.
3. **DLSS 4** — Multi Frame Generation (do 3 dodatkowych klatek na 1 renderowaną).
4. **AI Management Processor (AMP)** — dedykowany koprocesor do schedulingu zadań AI.
5. **PCIe 5.0**, **DisplayPort 2.1**.
6. **Neural Shaders / Neural Texture Compression** — kompresja tekstur AI redukująca zużycie VRAM o ~7×.

## Pozycjonowanie segmentów

- **RTX 5090** — flagowiec absolutny. Jedyna konsumencka 32 GB, jedyna karta dla LLM 30B+ na jednym GPU. Cena ulicy $2500–3500.
- **RTX 5080** — najlepsza karta gamingowa 4K. Tylko 16 GB to słabość względem AI. Konkuruje z używaną RTX 4090.
- **RTX 5070 Ti** — sweet spot performance/value. 16 GB to komfort dla 1440p/4K i SDXL.
- **RTX 5070** — niefortunne 12 GB ogranicza w AI i 4K. OK dla 1440p.
- **RTX 5060 Ti 16 GB** — najtańsza karta z 16 GB. Świetna do AI on budget.
- **RTX 5060 / 5050** — wyłącznie gaming 1080p. Nie polecam do AI w 2026.

## Status Super refresh (2026)

NVIDIA ogłosiła odświeżenie RTX 5070/5080 Super z większym VRAM (18 GB / 24 GB) — premiery rozłożone w 2026. Jeśli właśnie wybierasz kartę i nie spieszy ci się do AI/LLM, **warto poczekać na warianty Super**.

## Co wybrać pod konkretny scenariusz

| Scenariusz | Polecana karta |
|------------|----------------|
| Gaming 1080p budżetowo | RTX 5060 8 GB |
| Gaming 1440p | RTX 5070 / 5070 Ti |
| Gaming 4K bez kompromisu | RTX 5080 / 5090 |
| AI/LLM hobbystycznie | RTX 5060 Ti 16 GB |
| AI/LLM poważnie | RTX 5070 Ti / 5080 |
| AI/LLM profesjonalnie | RTX 5090 |
| Stable Diffusion / FLUX | RTX 5080 / 5090 |
| Streaming + gaming | RTX 5070 Ti |

## Używane RTX 40 — czy warto w 2026?

- **RTX 4090 24 GB** — używane $1200–1500. Wolniejsza od 5090 o ~25–30% w AI, ale ma 24 GB i jest tańsza. Świetna inwestycja.
- **RTX 4080 Super 16 GB** — używane $700–850. Konkurencyjna z 5070 Ti.
- **RTX 4070 Ti Super 16 GB** — używane $550–650.

Sprawdź czy karta nie była w koparce: termopady, gwarancja AIB, slot, fani.

## Sources

- [GeForce RTX 50 series - Wikipedia](https://en.wikipedia.org/wiki/GeForce_RTX_50_series)
- [NVIDIA GeForce RTX 5090 & 5080 AI Review | Puget Systems](https://www.pugetsystems.com/labs/articles/nvidia-geforce-rtx-5090-amp-5080-ai-review/)
- [GeForce RTX 50 Series Graphics Cards | NVIDIA](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/)
