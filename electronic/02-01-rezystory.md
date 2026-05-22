# 02-01: Rezystory

## Czym jest rezystor

Element bierny, którego głównym parametrem jest **rezystancja R** (opór elektryczny). Rezystor "ogranicza" prąd, dzieli napięcie i zamienia energię elektryczną na ciepło.

Symbol: `──[ ]──` (IEC) lub `──/\/\/\──` (ANSI). Oznaczenie schematowe: **R1, R2...**

## Główne parametry

| Parametr | Symbol | Typowe wartości |
|----------|--------|----------------|
| Rezystancja | R | 0,1 Ω – 100 MΩ |
| Tolerancja | ±% | 0,1% – 20% |
| Moc znamionowa | P | 1/8 W – 100 W |
| Maksymalne napięcie | U_max | 200 V – 5 kV |
| Współczynnik temperaturowy | TCR | ±5 ppm/°C – ±2000 ppm/°C |
| Szum | μV/V | bardzo mały dla precyzyjnych |

## Rodzaje konstrukcyjne

### Rezystory węglowe (carbon composition)

Najstarszy typ. Mieszanka węgla i spoiwa. Tolerancja ±5-20%, szumowe. Dziś rzadko, używane w lampowych konstrukcjach audio.

### Warstwowe węglowe (carbon film)

Cienka warstwa węgla naparowana na ceramicznym walcu. Tolerancja ±5%. Tanie, popularne THT (przewlekane). Brązowy/beżowy korpus.

### Metalowarstwowe (metal film)

Warstwa metalu. Tolerancja ±1%, niski szum, stabilne. Niebieski lub zielony korpus. Standard dziś.

### Drutowe (wirewound)

Drut oporowy nawinięty na ceramice. Duże moce (do 100 W). Cewka pasożytnicza (indukcyjność) — nie nadają się do wysokich częstotliwości.

### Foliowe (foil)

Cienka warstwa stopu Cr-Ni na podłożu. Najwyższa precyzja (±0,005%), bardzo stabilne. Drogie, do przyrządów pomiarowych.

### SMD (chip)

Powierzchniowy montaż. Standardowe rozmiary:

| Rozmiar | Wymiar [mm] | Max moc |
|---------|------------|---------|
| 0402 | 1,0 × 0,5 | 1/16 W |
| 0603 | 1,6 × 0,8 | 1/10 W |
| 0805 | 2,0 × 1,25 | 1/8 W |
| 1206 | 3,2 × 1,6 | 1/4 W |
| 2010 | 5,0 × 2,5 | 1/2 W |
| 2512 | 6,4 × 3,2 | 1 W |

## Kod kolorów (rezystory THT)

Standardowy rezystor warstwowy ma 4 lub 5 pasków.

### Cztery paski (tolerancja 5%)

```
[paski 1-2] = cyfry znaczące
[pasek 3]   = mnożnik (potęga 10)
[pasek 4]   = tolerancja
```

### Pięć pasków (tolerancja 1% lub mniej)

```
[paski 1-3] = cyfry znaczące
[pasek 4]   = mnożnik
[pasek 5]   = tolerancja
```

### Tabela kolorów

| Kolor | Cyfra | Mnożnik | Tolerancja |
|-------|-------|---------|------------|
| Czarny | 0 | ×1 | — |
| Brązowy | 1 | ×10 | ±1% |
| Czerwony | 2 | ×100 | ±2% |
| Pomarańczowy | 3 | ×1k | — |
| Żółty | 4 | ×10k | — |
| Zielony | 5 | ×100k | ±0,5% |
| Niebieski | 6 | ×1M | ±0,25% |
| Fioletowy | 7 | ×10M | ±0,1% |
| Szary | 8 | — | ±0,05% |
| Biały | 9 | — | — |
| Złoty | — | ×0,1 | ±5% |
| Srebrny | — | ×0,01 | ±10% |

### Przykład odczytu

Paski: **żółty, fioletowy, czerwony, złoty** (4 paski)

```
4   7   ×100   ±5%   →  4700 Ω = 4,7 kΩ ±5%
```

Paski: **brązowy, czarny, czarny, czerwony, brązowy** (5 pasków)

```
1   0   0   ×100   ±1%   →  10 000 Ω = 10 kΩ ±1%
```

### Triki przy odczycie

- Czytanie od strony, gdzie paski są bliżej krawędzi
- Pasek tolerancji często stoi sam (większy odstęp)
- Złoty i srebrny pasek to **zawsze tolerancja** (lub mnożnik 0,1 / 0,01)
- Kiedy nie wiesz — sprawdź multimetrem

## Oznaczenia SMD

### Trzycyfrowe

```
473  →  47 × 10³ Ω = 47 000 Ω = 47 kΩ
221  →  22 × 10¹ Ω = 220 Ω
1R5  →  1,5 Ω (R = przecinek)
000  →  zworka (0 Ω)
```

### Czterocyfrowe (większa precyzja)

```
4702  →  470 × 10² = 47 000 Ω = 47 kΩ
2200  →  220 × 10⁰ = 220 Ω
```

### EIA-96 (trzyznakowe, dla 1%)

Dwie cyfry = pozycja w tabeli + litera = mnożnik. Niespotykane dla początkujących.

## Szeregi wartości (E-series)

Wartości produkowane fabrycznie są zestandaryzowane w **szeregach E**.

### E12 (12 wartości w dekadzie, tolerancja 10%)

```
1,0  1,2  1,5  1,8  2,2  2,7  3,3  3,9  4,7  5,6  6,8  8,2
```

### E24 (24 wartości, tolerancja 5%)

```
1,0  1,1  1,2  1,3  1,5  1,6  1,8  2,0  2,2  2,4  2,7  3,0
3,3  3,6  3,9  4,3  4,7  5,1  5,6  6,2  6,8  7,5  8,2  9,1
```

### E48 i E96 — dla rezystorów ±1% i ±2%

E96 ma 96 wartości w dekadzie. Tu nie trzeba pamiętać, sprawdza się w tabelach.

Mnożniki dekadowe: ×1, ×10, ×100, ×1k, ×10k, ×100k, ×1M.

Czyli z E12: 10R, 12R, 15R... 1k, 1k2, 1k5... 10k, 12k, 15k...

## Dobór mocy rezystora

### Wzory

```
P = U · I
P = I² · R
P = U² / R
```

### Reguła kciuka

Wybierz rezystor o **dwukrotnie większej** mocy niż obliczona. Dlaczego:

- Wzrost temperatury otoczenia
- Starzenie (drift)
- Niedokładność obliczeń
- Skrajne warunki pracy

### Typowe moce komercyjne

| Moc | Typowy rozmiar THT |
|-----|-------------------|
| 1/8 W (125 mW) | mini, 1,8 × 3,5 mm |
| 1/4 W (250 mW) | standard, 2 × 6 mm |
| 1/2 W (500 mW) | 3 × 9 mm |
| 1 W | 5 × 12 mm |
| 2 W | 6 × 17 mm |
| 5 W | 8 × 24 mm (drutowy, ceramika) |
| 10 W i więcej | radiatorowe |

### Przykład doboru

LED zasilana z 12 V przez rezystor ograniczający. LED 2 V, 20 mA.

```
U_R = 12 − 2 = 10 V
R = 10 / 0,02 = 500 Ω  →  najbliższy E12: 470 Ω
P = 10 · 0,02 = 0,2 W = 200 mW
```

Wybieramy 1/4 W (250 mW) — z zapasem.

## Rezystory specjalne

### Potencjometr

Rezystor regulowany. Trzy wyprowadzenia: dwa końce + suwak. Charakterystyka:
- **Liniowa (B)** — opór proporcjonalny do kąta obrotu
- **Logarytmiczna (A)** — używana w audio (głośność)
- **Antylogarytmiczna (C)** — rzadziej

Typowy potencjometr: 1 kΩ – 1 MΩ.

### Trimer

Mały potencjometr do regulacji wewnątrz urządzenia, obracany wkrętakiem.

### Termistor NTC (Negative Temperature Coefficient)

Rezystancja maleje wraz ze wzrostem temperatury. Czujnik temperatury, ograniczenie prądu rozruchowego.

### Termistor PTC (Positive Temperature Coefficient)

Rezystancja rośnie z temperaturą. Zabezpieczenie samoresetujące (Polyfuse), grzałki.

### Fotorezystor (LDR)

Rezystancja zależy od oświetlenia. W ciemności kilka MΩ, w jasnym świetle 100 Ω. Czujniki światła, układy automatyczne.

### Warystor (MOV)

Rezystancja maleje gwałtownie powyżej napięcia progowego. Ochrona przeciwprzepięciowa.

### Tensometr

Rezystancja zmienia się przy odkształceniu mechanicznym. Wagi, czujniki siły.

### Rezystor bocznikowy (shunt)

Bardzo małej rezystancji (mΩ), do pomiaru dużych prądów przez pomiar spadku napięcia.

## Łączenie rezystorów

### Szeregowe

```
R = R1 + R2 + R3 + ...
```

Suma rezystancji. Prąd wspólny, napięcie się dzieli.

### Równoległe

```
1/R = 1/R1 + 1/R2 + ...
```

Lub dla dwóch:
```
R = (R1 · R2) / (R1 + R2)
```

Napięcie wspólne, prąd się dzieli.

### Praktyczne wskazówki

- Dwa identyczne równolegle: R/2, moc 2P (2× większy)
- Trzy identyczne równolegle: R/3, moc 3P
- Często **3 rezystory 1 W równolegle** zastępują 1 rezystor 3 W (bo trudniej dostać)

## Pasożytnicze parametry

W idealnym świecie rezystor to czysta R. W rzeczywistości ma:

- **Indukcyjność** (LI) — drutowe szczególnie. Dla AC zmienia impedancję.
- **Pojemność** (Cp) — między wyprowadzeniami. Istotna przy GHz.
- **Szum termiczny** — fluktuacje napięcia rosną z R i T.
- **Współczynnik temperaturowy (TCR)** — zmiana rezystancji z temperaturą.
- **Współczynnik napięciowy (VCR)** — drobne, ale ważne w precyzji.

## Wybór rezystora — podsumowanie

Pytania, które trzeba zadać:

1. **Jaką wartość** musi mieć? (oblicz)
2. **Jaką tolerancję**? (1% w precyzji, 5% w typowej elektronice)
3. **Jaką moc** musi przyjąć? (z zapasem 2×)
4. **W jakiej temperaturze** pracuje?
5. **Czy to AC czy DC**? (jeśli AC HF — bez drutowych)
6. **Czy ważny szum**? (jeśli tak, metal film)
7. **THT czy SMD**? (zależnie od PCB)
8. **Cena vs precyzja** — pragmatycznie

## Najczęstsze błędy

1. **Zła moc** — zbyt mały rezystor się przegrzewa, zmienia wartość, w skrajnym przypadku pali się.
2. **Zła tolerancja** — w dzielniku napięcia 5% rezystora daje 10% błąd.
3. **Ignorowanie temperatury** — TCR ±500 ppm/°C przy 50°C wzroście to 2,5% zmiana.
4. **Drutowy w AC HF** — indukcyjność powoduje, że rezystor staje się cewką.
5. **Brak dewskumentacji** — nie wiesz, jakie typy zamówić → kupuj rezystory metal film 1%, są uniwersalne.
