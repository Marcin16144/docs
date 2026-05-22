# GeForce w laptopach — RTX 50 Mobile i wybór notebooka

## Złota zasada laptopów: ten sam numer ≠ ta sama karta

**Mobile GPU to NIE to samo co desktop.** RTX 5090 Laptop to inny chip (GB203) niż RTX 5090 desktop (GB202), z mniej rdzeniami, mniej VRAM i znacząco niższym TGP.

Realny stosunek wydajności **mobile vs desktop o tej samej nazwie**: 50–65%.

## Specyfikacje RTX 50 Mobile (Blackwell, premiera marzec 2025)

| Model | CUDA | VRAM | Bus | TGP (min–max) | AI TOPS |
|-------|------|------|-----|---------------|---------|
| **RTX 5090 Laptop** | 10 496 | 24 GB GDDR7 | 256-bit | 95 – 150 W | 1 824 |
| **RTX 5080 Laptop** | 7 680 | 16 GB GDDR7 | 256-bit | 80 – 150 W | 1 334 |
| **RTX 5070 Ti Laptop** | 5 888 | 12 GB GDDR7 | 192-bit | 60 – 115 W | 992 |
| **RTX 5070 Laptop** | 4 608 | 8 GB / 12 GB* GDDR7 | 128-bit | 50 – 115 W | 798 |
| **RTX 5060 Laptop** | 3 328 | 8 GB GDDR7 | 128-bit | 45 – 100 W (+25 W Dynamic Boost = 125 W) | 614 |
| **RTX 5050 Laptop** | 2 560 | 8 GB GDDR6 | 128-bit | 35 – 100 W | — |

\* Wariant 12 GB ogłoszony później, w 2026 (RAMpocalypse — odpowiedź na rosnące wymagania VRAM).

## Co to TGP i czemu jest kluczowy

**TGP (Total Graphics Power)** — moc, jaką producent laptopa zdecydował się dać karcie. Ta sama RTX 5080 Laptop @ 150 W jest o **30–50% szybsza** niż RTX 5080 Laptop @ 80 W w cienkim ultrabooku.

**Zawsze sprawdzaj TGP w specyfikacji konkretnego modelu laptopa** — często ukryte w przypisach albo w testach NotebookCheck.

## RTX 5060 Laptop — szczegółowo (najpopularniejszy wybór budżet/mid-range)

Premiera: maj 2025. Pozycjonowany jako mainstream — najczęściej spotykany w laptopach 6000–8500 PLN. To **najlepszy wybór dla większości studentów i osób szukających balansu cena/wydajność**.

**Specyfikacja**:
- Chip: **GB206** (Blackwell)
- CUDA cores: **3 328** (104 SM × 32)
- Tensor cores: 104 (5 generacja, FP4/FP8)
- RT cores: 26 (4 generacja)
- VRAM: **8 GB GDDR7** @ 28 Gbps
- Bus: 128-bit
- Bandwidth: ~448 GB/s
- TGP: **45–100 W** (+ do 25 W Dynamic Boost = realnie nawet 125 W)
- AI TOPS: ~614
- Proces: TSMC 4NP

**Wydajność**:
- Gaming 1080p Ultra: 60+ FPS w większości tytułów AAA
- Gaming 1440p High z DLSS 4: 60+ FPS z Multi Frame Gen
- Stable Diffusion SDXL: działa (8 GB to minimum), generacja 5–8 s/obraz
- LLM: tylko modele 7B–8B w Q4, 13B w Q3 z trudem — **8 GB to wąskie gardło**
- Wydajność rasteryzacji: zbliżona do desktopowej RTX 4060

**Plusy**:
- ✅ Świetna efektywność energetyczna — wybór do cienkich i lekkich laptopów
- ✅ Niewielkie nagrzewanie nawet w cieńszych obudowach
- ✅ DLSS 4 + Multi Frame Generation
- ✅ Cena laptopa — najtańsze RTX 50 z sensowną wydajnością
- ✅ Dobry czas pracy na baterii (gdy dGPU śpi)

**Minusy**:
- ❌ **Tylko 8 GB VRAM** — w 2026 to za mało dla nowoczesnych gier 4K i AI
- ❌ Wąski bus 128-bit ogranicza w high-res
- ❌ Wariant 50–60 W TGP w cienkich ultrabookach jest wyraźnie wolniejszy niż 100+ W w gaming laptopach
- ❌ Brak realnej przewagi nad RTX 4060 Laptop poza FP4/FP8 i DLSS 4

**Polecane laptopy z RTX 5060** (2026):

| Model | TGP | Cena PLN | Uwaga |
|-------|-----|----------|-------|
| **Lenovo Legion 5 16** | 100–115 W | ~6500 | Best value, dobre chłodzenie |
| **ASUS TUF Gaming A16/F16** | 100–115 W | ~6000–7000 | Trwały, mocne chłodzenie |
| **Acer Nitro V 16** | 100 W | ~5800 | Najtańszy sensowny wybór |
| **HP Omen 16** | 100 W | ~6500 | Solidny, klasyczny design |
| **MSI Katana 17** | 100 W | ~6200 | 17" ekran, dobry układ klawiatury |
| **ASUS ROG Zephyrus G14** | 65–80 W | ~8000 | Cienki, premium, OLED |
| **Razer Blade 14** | 65–80 W | ~9500 | Aluminium, premium ultrabook |

**Kiedy wybrać RTX 5060 Laptop**:
- Gaming 1080p / 1440p z DLSS
- Lekka praca z AI (modele do 7B)
- Budżet do 8000 PLN, potrzeba mobilności
- Studia (informatyka, grafika) — wystarczy do nauki, ML w chmurze

**Kiedy NIE wybierać**:
- Gaming 4K na poważnie → RTX 5080/5090 Laptop
- LLM / Stable Diffusion FLUX → minimum RTX 5070 Ti 12 GB lub 5080 16 GB
- Renderowanie 3D, video 4K → potrzeba więcej VRAM

## Sources

- [Nvidia introduces RTX 5090, RTX 5080, and RTX 5070 laptop GPUs | Tom's Hardware](https://www.tomshardware.com/pc-components/gpus/nvidia-introduces-rtx-5090-rtx-5080-and-rtx-5070-laptop-gpus-rtx-50-blackwell-goes-mobile-with-up-to-24gb-of-gddr7-memory)
- [Nvidia GeForce RTX 5090 Laptop - Benchmarks and Specs | Notebookcheck](https://www.notebookcheck.net/Nvidia-GeForce-RTX-5090-Laptop-Benchmarks-and-Specs.934947.0.html)
- [NVIDIA GeForce RTX 5060 Laptop - Benchmarks and Specs | Notebookcheck](https://www.notebookcheck.net/Nvidia-GeForce-RTX-5060-Laptop-Benchmarks-and-Specs.934941.0.html)
- [GeForce RTX 50 Series Gaming Laptops | NVIDIA](https://www.nvidia.com/en-us/geforce/laptops/50-series/)

## RTX 5090 Mobile vs Desktop — porównanie

| Cecha | RTX 5090 Desktop | RTX 5090 Laptop |
|-------|------------------|-----------------|
| Chip | GB202 | GB203 (taki sam jak 5080 desktop) |
| CUDA cores | 21 760 | 10 496 |
| VRAM | 32 GB | 24 GB |
| Bus | 512-bit | 256-bit |
| Bandwidth | 1792 GB/s | 896 GB/s |
| TDP/TGP | 575 W | 95–150 W |

**Wniosek**: RTX 5090 Laptop = wydajnościowo bliżej desktopowej RTX 5080, choć ma więcej VRAM (24 GB!).

## Co wybrać do…

### Gamingu mobilnego (1440p / 4K external)
- **RTX 5080 Laptop @ 150 W** w mocnej obudowie (Razer Blade 16, ASUS ROG Strix Scar, MSI Raider) — najlepszy balans
- **RTX 5090 Laptop** — kosztowo nieefektywny dla samego gamingu

### Pracy + lekkiego gamingu (ultra/cienki laptop)
- **RTX 5070 Laptop @ 80–100 W** w 14"–16" mobile workstation
- ASUS ProArt P16, Razer Blade 14, Lenovo Legion Slim

### LLM / AI mobilnie
- **RTX 5090 Laptop 24 GB** — jedyna opcja z 24 GB w laptopie. Modele do 32B w Q4
- **RTX 5080 Laptop 16 GB** — 13B–14B w Q4 komfortowo
- Lenovo Legion Pro 7i, ASUS ROG Strix Scar 18

### Stable Diffusion / FLUX mobilnie
- **RTX 5080 Laptop 16 GB** lub wyższa — SDXL bez problemu, FLUX z optymalizacją

## Praktyczne pułapki notebooków z GPU

1. **Hałas i temperatura** — gaming laptop z TGP 150 W to wentylatory 45–55 dB pod obciążeniem
2. **Bateria** — dGPU przy zasilaniu z baterii działa na obniżonym taktowaniu. Nie planuj ML poza zasilaniem
3. **Throttling termiczny** — tańsze obudowy nie utrzymują pełnego TGP długo. Sprawdzaj testy długie (30+ min)
4. **MUX switch** — pozwala omijać iGPU i podłączać monitor bezpośrednio do dGPU. **Wymagany dla maksymalnej wydajności** — sprawdzaj w specyfikacji
5. **Pamięć RAM lutowana czy SO-DIMM?** — wiele 14"–16" ma RAM zlutowany na stałe
6. **Klawiatura, ekran, głośniki** — laptopa kupuje się raz na 4–5 lat, GPU to nie wszystko

## Polecane modele laptopów (2026)

### Premium AI/gaming 16"–18"
- **Razer Blade 16** (RTX 5090, 64 GB RAM) — aluminium, świetna obudowa, $4000+
- **ASUS ROG Strix Scar 18** (RTX 5090, 64 GB) — chłodzenie ciekłym metalem
- **Lenovo Legion Pro 7i Gen 10** (RTX 5090, 32 GB) — najlepsze chłodzenie/PLN
- **MSI Raider 18 HX** (RTX 5090) — top performance, ciężki

### Mobile workstation 16"
- **ASUS ProArt P16** (RTX 5070, ekran OLED) — kreatywni, kolory
- **Dell XPS 16 / Precision 5680** (RTX 5070/Ada) — biznes

### Kompakt 14"–15"
- **Razer Blade 14** (RTX 5070) — najlepszy mały gaming
- **ASUS ROG Zephyrus G14** (RTX 5070/5080) — lekki, dobry ekran
- **Lenovo Legion Slim 5/7** (RTX 5060/5070) — wartość

### Budżet / mainstream (RTX 5060)
- **Acer Nitro V 16** (RTX 5060, 100 W) — najtaniej z sensowną wydajnością, ~5800 PLN
- **Lenovo Legion 5 16** (RTX 5060, 115 W) — best value, ~6500 PLN
- **ASUS TUF Gaming A16** (RTX 5060) — wytrzymały, dobre chłodzenie
- **HP Omen 16** (RTX 5060/5070) — solidny
- **MSI Katana 17** (RTX 5060) — duży ekran taniej

## Mobile vs desktop — co wybrać?

**Wybierz laptop, jeśli**:
- Potrzebujesz mobilności (uczelnia, biuro, podróże)
- Pracujesz okazjonalnie z AI/grami
- Masz ograniczone miejsce

**Wybierz desktop, jeśli**:
- AI / LLM / mining / video to twój główny use case
- Liczy się stosunek PLN/wydajność (desktop ~2× tańszy za tę samą moc)
- Nie ruszasz komputera

**Hybryda**: lekki laptop biznesowy + desktop AI w domu (zdalny SSH/RDP) bywa najlepsza.
