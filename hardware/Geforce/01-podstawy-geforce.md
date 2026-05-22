# Podstawy kart GeForce — parametry i na co zwracać uwagę

GeForce to konsumencka linia kart graficznych NVIDIA. Choć z definicji „do gier", od kilku lat są kluczowym narzędziem także w AI/LLM, renderingu, video i (w mniejszym zakresie) miningu.

## Kluczowe parametry — co znaczą i czemu są ważne

### VRAM (pamięć karty) — najważniejszy parametr dla AI
Ilość dedykowanej pamięci GDDR. Decyduje o tym, jak duży model/scena/tekstura zmieści się w karcie.

- **8 GB** — minimum do gier 1080p, za mało do nowoczesnego AI
- **12 GB** — sweet spot dla gier 1440p, modele LLM do 7B w Q4
- **16 GB** — komfort dla gier 4K, modele 13B–14B w Q4
- **24 GB** — granica „prosumerska" (RTX 3090, 4090), modele 30B w Q4
- **32 GB** — RTX 5090, granica konsumencka 2026, modele 32B w FP8 lub 70B w Q4

**Złota zasada AI: VRAM > wszystko inne.** Lepsza wolniejsza karta z 24 GB niż szybsza z 12 GB.

### Typ pamięci
- **GDDR6** — RTX 30, RTX 40, RTX 5050 (entry)
- **GDDR6X** — RTX 3080/3090, RTX 4070 Ti/4080/4090
- **GDDR7** — RTX 50 series (oprócz 5050) — większa przepustowość, lepsza efektywność energetyczna

### Przepustowość pamięci (memory bandwidth)
Mierzona w GB/s. Dla inferencji LLM **liczy się bardziej niż surowa moc obliczeniowa** — generowanie tokenów jest memory-bound.

| Karta | Bandwidth |
|-------|-----------|
| RTX 3060 12GB | 360 GB/s |
| RTX 4070 | 504 GB/s |
| RTX 4090 | 1008 GB/s (~1 TB/s) |
| RTX 5090 | 1792 GB/s (~1.79 TB/s) |

### CUDA cores
Liczba uniwersalnych rdzeni obliczeniowych. Im więcej, tym szybciej liczy. Ale nie porównuj bezpośrednio między generacjami — rdzeń Blackwell jest mocniejszy od Ampere.

### Tensor Cores
Wyspecjalizowane jednostki do mnożenia macierzy — używane przez DLSS, ray tracing AI i wszystkie obciążenia ML. Pokolenia:
- 3 gen — RTX 30 (Ampere)
- 4 gen — RTX 40 (Ada Lovelace)
- **5 gen** — RTX 50 (Blackwell) — natywne FP4, FP8, ogromny skok w AI

### RT Cores
Rdzenie do ray tracingu. 4. generacja w RTX 50.

### TDP / TGP (pobór mocy)
Ile karta zużywa pod obciążeniem. Wpływa na:
- wymagany zasilacz
- wydzielane ciepło → wentylacja obudowy
- rachunek za prąd (istotne przy LLM 24/7 lub miningu)

| Karta | TDP |
|-------|-----|
| RTX 4060 | 115 W |
| RTX 4070 | 200 W |
| RTX 4090 | 450 W |
| **RTX 5090** | **575 W** |

### Złącze zasilania
- **8-pin** — starsze karty, do ~300 W
- **12VHPWR / 12V-2x6** — nowe karty RTX 40/50 wysokiego segmentu. Wymaga zasilacza ATX 3.0 lub adaptera. Uważać na poprawne wpięcie (przegrzewanie się złącza było problemem 4090).

### Interfejs PCIe
- **PCIe 4.0 x16** — RTX 30, 40
- **PCIe 5.0 x16** — RTX 50

Praktycznie różnica niewielka w grach. Karty z mniejszą liczbą linii (x8) tracą wydajność na starszych płytach głównych.

### Złącza wyjściowe
- **DisplayPort 2.1** — RTX 50 (8K @ 165 Hz, 4K @ 480 Hz)
- **DisplayPort 1.4a** — RTX 30/40
- **HDMI 2.1** — wszystkie nowe karty

## Generacje i architektury

| Generacja | Architektura | Rok | Proces |
|-----------|--------------|-----|--------|
| RTX 20 | Turing | 2018 | 12 nm |
| RTX 30 | Ampere | 2020 | Samsung 8 nm |
| RTX 40 | Ada Lovelace | 2022 | TSMC 4N (5 nm) |
| **RTX 50** | **Blackwell** | **2025** | **TSMC 4NP** |

## Na co zwracać uwagę przy zakupie (2026)

1. **VRAM** — kup z zapasem. 12 GB to absolutne minimum, 16 GB rozsądny środek.
2. **Generacja** — RTX 50 ma natywne FP4/FP8, co daje **dwucyfrowe przyspieszenia w AI** względem RTX 40.
3. **Zasilacz** — RTX 5090 wymaga 1000 W+. RTX 5080 ~850 W. Sprawdź czy masz odpowiednie złącze.
4. **Rozmiar karty** — flagowce mają 3–4 sloty i 32–35 cm długości. Mierz obudowę.
5. **Chłodzenie** — droższe wersje AIB (Strix, Suprim, Aorus Master) są cichsze i chłodniejsze niż Founders Edition.
6. **Gwarancja** — ASUS i MSI zwykle 3 lata, ZOTAC 5 lat (po rejestracji), Gigabyte 4 lata.
7. **Używane RTX 30/40** — RTX 3090 24GB nadal świetna do LLM. RTX 4090 24GB to nadal król value/wydajność. Sprawdź czy karta nie była w koparce (kontrole termo, slot, wentylatory).
8. **Stock / dostępność** — w 2026 RTX 5090 nadal ma napięty stock. MSRP $1999, w rzeczywistości $2500–3500.

## VRAM vs zadania

| Zadanie | Wymagane VRAM (min – komfort) |
|---------|-------------------------------|
| Gaming 1080p | 8 – 12 GB |
| Gaming 1440p | 12 – 16 GB |
| Gaming 4K + RT | 16 – 24 GB |
| Stable Diffusion (SDXL) | 12 – 16 GB |
| Stable Diffusion (FLUX) | 16 – 24 GB |
| LLM 7B–8B (Q4) | 6 – 12 GB |
| LLM 13B–14B (Q4) | 10 – 16 GB |
| LLM 30B–32B (Q4) | 20 – 24 GB |
| LLM 70B (Q4) | 40 – 48 GB (2× karta) |
| Trening / fine-tuning LoRA 7B | 16 – 24 GB |
| Video editing 4K | 12 – 24 GB |
| Rendering 3D (Blender, Octane) | 16 – 32 GB |

## Sources

- [GeForce RTX 50 series - Wikipedia](https://en.wikipedia.org/wiki/GeForce_RTX_50_series)
- [GeForce Graphics Cards | NVIDIA](https://www.nvidia.com/en-us/geforce/graphics-cards/50-series/)
