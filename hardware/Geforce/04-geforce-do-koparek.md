# GeForce do koparek kryptowalut — stan na 2026

## TL;DR — czy warto zaczynać w 2026?

**Krótko: w większości przypadków NIE.** Mining GPU w 2026 to nisza dla osób z:
- bardzo tanim prądem (< 0.30 PLN/kWh, idealnie < 0.20 PLN/kWh)
- używanymi kartami za pół ceny
- chłodnym klimatem (ciepło to koszt latem)
- alternatywnym wykorzystaniem GPU (gaming/AI gdy mining nieopłacalny)

Kupowanie nowej RTX 5090 do miningu **nigdy się nie zwróci** — typowy ROI 2–5+ lat, a karta starzeje się i traci wartość.

## Co zmieniło się od 2022

- **Ethereum przeszedł na PoS we wrześniu 2022** — koniec największej fali GPU mining.
- Hashrate przeniósł się na **Ethereum Classic (ETC)** i pomniejsze monety.
- ASIC-i przejęły algorytmy SHA-256, Scrypt, X11. **GPU pozostały sensowne tylko dla algorytmów ASIC-resistant** (KawPow, KHeavyHash, Autolykos, Etchash).
- Difficulty rośnie, nagrody spadają.

## Najpopularniejsze monety GPU w 2026

| Moneta | Algorytm | Status |
|--------|----------|--------|
| **Ethereum Classic (ETC)** | Etchash | Najbardziej płynna, łatwy obrót |
| **Ravencoin (RVN)** | KawPow | ASIC-resistant, klasyk dla GPU |
| **Ergo (ERG)** | Autolykos v2 | Dobra dla NVIDIA |
| **Kaspa (KAS)** | kHeavyHash | Wysoki bandwidth memory, dobrze idzie na nowych kartach |
| **Flux (FLUX)** | ZelHash | Średnia popularność |
| **Conflux (CFX)** | Octopus | Niszowy |

## Dochodowość — realistyczne dane (maj 2026)

Przy cenie prądu **0.30 PLN/kWh** (typowy dom w PL):

| Karta | Algo | Hashrate | Pobór | Dzienny zysk brutto | Po prądzie | ROI (cena nowa) |
|-------|------|----------|-------|---------------------|------------|-----------------|
| RTX 3060 12GB | KawPow | 23 MH/s | 115 W | ~3 PLN | ~+2 PLN | nieopłacalny |
| RTX 3070 | Etchash | 60 MH/s | 130 W | ~5 PLN | ~+4 PLN | nieopłacalny |
| RTX 3080 10GB | KawPow | 45 MH/s | 220 W | ~9 PLN | ~+7 PLN | 3+ lata |
| RTX 3090 24GB (używana) | Etchash | 120 MH/s | 290 W | ~14 PLN | ~+12 PLN | 2 lata |
| RTX 4090 | KawPow | 75 MH/s | 320 W | ~16 PLN | ~+14 PLN | 5+ lat |
| RTX 5090 | kHeavyHash | bardzo wysoki | 575 W | ~22 PLN | ~+18 PLN | nigdy |

> **Uwaga**: liczby zmieniają się dziennie. Sprawdzaj na bieżąco: [whattomine.com](https://whattomine.com), [minerstat.com](https://minerstat.com), [2cryptocalc.com](https://2cryptocalc.com).

## Najlepsze karty GeForce do miningu

Mining preferuje **efektywność (MH/s na W)** nad surową wydajnością:

| Karta | Najlepszy algo | Efektywność | Uwagi |
|-------|---------------|-------------|-------|
| **RTX 3060 Ti** | Etchash, KawPow | ★★★★★ | Najlepszy stosunek hash/wat w segmencie |
| **RTX 3070** | Etchash, KawPow | ★★★★★ | Klasyk, łatwo dostępna używana |
| **RTX 3080 10GB** | KawPow | ★★★★ | Mocny hash, większy pobór |
| **RTX 3090** | Etchash | ★★★★ | 24 GB, ale gorące pamięci GDDR6X |
| **RTX 4070 Ti** | kHeavyHash | ★★★★ | Bardzo dobre perf/wat |
| **RTX 4090** | kHeavyHash | ★★★ | Drogie, słabo wraca |
| **RTX 5070 Ti** | różne | ★★★★ | Sweet spot z nowych |
| **RTX 5090** | wszystko | ★★★ | Wysoki hashrate, ale gigantyczny pobór |

**Najlepszy wybór ekonomiczny**: używana **RTX 3070** lub **RTX 3060 Ti** za 800–1200 PLN.

## Kluczowe ustawienia / optymalizacja

1. **Undervolting** — kluczowy. Daje 10–30% mniej prądu przy 95% wydajności.
   - Narzędzie: **MSI Afterburner** + krzywa Voltage/Frequency.
   - Przykład RTX 3070: 0.750 V @ 1700 MHz, +1100 MHz na pamięci.
2. **Power limit** — ustaw 60–75%. Mniej ciepła, niemal pełny hash.
3. **Memory overclock** — algorytmy memory-bound (Etchash, KawPow) korzystają. Uważać na temperatury VRAM (zwłaszcza GDDR6X w RTX 3080/3090).
4. **Temperatury** — pamięci poniżej 90°C, GPU poniżej 70°C. W rig'ach wymieniaj termopady na lepsze (np. Thermalright Odyssey).
5. **Software**:
   - **NBMiner** — uniwersalny
   - **lolMiner** — dobry dla Etchash, Autolykos
   - **T-Rex** — KawPow
   - **SRBMiner** — kHeavyHash (Kaspa)
6. **Pula** — Hiveon (ETC), 2Miners, F2Pool, Flexpool.

## Ekonomia — krytyczne pytania

1. **Ile płacę za kWh?** Powyżej 0.50 PLN/kWh nie ma sensu zaczynać.
2. **Czy mogę odprowadzić ciepło?** 1000 W rig'a = 1 kW grzejnik 24/7.
3. **Czy karty są używane?** Nowe karty się nie spłacą. Używane RTX 3000 to baseline.
4. **Czy karty mają wartość rezydualną?** RTX 3070/3080 sprzedasz w każdej chwili. Specjalistyczne ASIC-i — nie.
5. **Co z gwarancją i serwisem?** 24/7 zużywa wentylatory i pamięci. Lutowanie BGA to ostateczność.

## Rig — typowa konfiguracja 6 GPU

- Płyta główna z 6+ PCIe (np. BTC-251, B250 Mining Expert)
- Risery PCIe x1 → x16 (z osobnym zasilaniem)
- 2 zasilacze platinum 1000–1500 W (Add2PSU)
- 8 GB RAM, tani CPU Pentium / Celeron
- SSD 120 GB, Linux HiveOS / RaveOS
- Stelaż otwarty, dodatkowe wentylatory 140 mm

## Ostrzeżenie

- **Mining = ekstremalne zużycie karty**. Karty z koparek bywają sprzedawane jako „gamingowe". Sprawdzaj termopady, slot, wentylatory, parametry temperatury hot-spot.
- **Prawo** — w Polsce mining nie jest zakazany, ale **dochody trzeba opodatkować** (PIT od sprzedaży krypto, 19%).
- **Bezpieczeństwo** — przeciążone gniazdka i kable to realne zagrożenie pożarowe. Profesjonalna instalacja, czujnik dymu.
- **Wydajne karty AI typu 5090** = lepiej je wynająć innym do AI (Vast.ai, Salad) niż minować.

## Alternatywa: wynajem mocy AI

Zamiast minować, **wynajmij GPU pod inferencję AI** przez:
- [Vast.ai](https://vast.ai) — peer-to-peer
- [Salad.com](https://salad.com) — głównie konsumenckie GPU
- [RunPod](https://runpod.io)

Stawki dla RTX 4090: **$0.30–0.60 / h** = 25–50 PLN dziennie czystego netto. **Często 3–10× więcej niż mining**, bez zużywania pamięci do śmierci.

## Sources

- [Best GPUs for Mining in 2026 | Zipmex](https://zipmex.com/blog/best-gpus-for-mining-2026-complete-guide-roi-calculator/)
- [Best Cryptocurrencies to Mine in 2026 | DEXTools News](https://www.dextools.io/tutorials/best-cryptocurrencies-to-mine-profitability-guide-2026)
- [Best GPU for Mining in 2026 | RedSwitches](https://www.redswitches.com/blog/best-gpus-for-mining-in-2026/)
- [10 Best Cryptos to Mine May 2026 | Koinly](https://koinly.io/blog/best-crypto-to-mine/)
