# 08-02: Zasilacz sieciowy 230 V → 12 V — kompletny projekt

## Wymagania projektu

- Napięcie wejściowe: 230 V AC, 50 Hz
- Napięcie wyjściowe: 12 V DC stabilizowane
- Prąd wyjściowy: do 2 A ciągle
- Tętnienia: < 50 mV
- Sprawność: nieistotna (liniowy, ~50%)
- Galwaniczna izolacja: tak
- Zabezpieczenia: bezpiecznik, MOV, LED sygnalizacyjna

## Pełny schemat ideowy

```
                   F1                         TR1
   L ──[bezpiecznik]──┬────────●───── prim ────║
                       │       │                ║              D1-D4
                      MOV    NTC                ║   sek ──┬──[mostek]──┬── + ──┬──┬─[7812]─┬── +12V OUT
                       │       │                ║         │            │       │  │        │
   N ────────────────●───────●──── prim ────║         │            │      [C1] [C2]   [C4]
                                                  ║         │            │       │  │        │
                                                  ║         └────────────●       ●──●────────┴── GND OUT
   PE ── chassis                                                                    │
                                                                                    [C3]
                                                                                    │
                                                                                   GND

   C1: 4700 μF / 25 V (filtr główny)
   C2: 100 nF (filtr HF wejście stabilizatora)
   C3: 100 nF (filtr HF wyjście stabilizatora)
   C4: 100 μF / 25 V (filtr wyjścia)
   F1: bezpiecznik T 200 mA / 250 V (zwłoczny)
   MOV: S14K275 lub S20K275
   NTC: SCK-053 (5 Ω, 3 A) — inrush limiter
   TR1: transformator 230 V / 15 V / 30 VA toroidalny lub EI78
   D1-D4: mostek 4 A / 200 V (B40C5000 lub KBPC1004)
   7812: stabilizator + radiator (R_θ ≤ 8 K/W)
```

## Krok 1: dobór transformatora

Wymagane napięcie po prostowniku:
```
U_DC_min = U_wy + U_dropout + ΔU_tętnień
         = 12 + 3 + 2 = 17 V
```

Wymagane napięcie AC z trafo (przy obciążeniu, uwzględnia spadek ε ~10%):
```
U_AC = (U_DC + 1,4 V mostka) / (√2 · (1-ε))
     = (17 + 1,4) / (1,414 · 0,9)
     = 14,5 V
```

Wybór: **transformator 15 V AC**.

Moc transformatora (S = moc pozorna):
```
S = U_AC · I_DC · 1,8 (faktor wykorzystania trafo)
  = 15 · 2 · 1,8 = 54 VA
```

Wybór: **transformator 50-60 VA**. Toroidalny lepszy (mniejszy, mniej EMI, większa sprawność).

## Krok 2: dobór mostka prostowniczego

Diody muszą wytrzymać:
- Prąd średni: 1 A (każda dioda po pół okresu)
- Prąd szczytowy: 5-10 A (ładowanie kondensatora)
- Napięcie zaporowe: U_AC · √2 + zapas = 21 V → wybierz 100 V (z dużym zapasem)

Wybór: **mostek 4 A / 100 V** (np. KBPC2A04, B40C5000) z możliwością przykręcenia do radiatora.

## Krok 3: dobór kondensatora filtra

```
C ≥ I_obc / (f · ΔU)
  = 2 / (100 · 1)
  = 20 000 μF
```

W praktyce wybieramy mniejszy z większym akceptowalnym ΔU (stabilizator dalej wygładzi):

ΔU = 2 V → C = 10 000 μF
ΔU = 4 V → C = 5000 μF → **4700 μF** wystarczy

Wybór: **4700 μF / 25 V**, low-ESR, 105°C.

Napięcie znamionowe z zapasem 1,5× szczyt:
```
U_szczyt = 15 · √2 = 21,2 V → kondensator 25 V minimum, lepiej 35 V
```

## Krok 4: dobór stabilizatora

**7812** w obudowie TO-220.

Parametry:
- I_max = 1 A standardowo, 1,5 A z dobrym chłodzeniem
- Dropout = 2 V
- Stabilizacja liniowa: < 0,5%
- U_we max = 35 V

Dla 2 A potrzebujesz:
- Mocniejszą wersję (LM78T12, 3 A)
- Lub **7812 + tranzystor obejściowy** (jak w 08-01)
- Lub **stabilizator z LM317** (1,5 A) i ograniczeniem prądu

Dla uproszczenia projektu **zmniejszamy I_max do 1,5 A** i używamy standardowego 7812 z radiatorem.

## Krok 5: obliczenie strat i radiatora

Moc tracona na 7812:
```
P_strat = (U_DC_we − U_wy) · I_obc
        = (17 − 12) · 1,5 = 7,5 W
```

(U_DC_we ≈ 17 V pod obciążeniem)

Rezystancja termiczna radiatora:
```
T_J_max = 125°C, T_amb = 50°C, R_θJC = 5 K/W

R_θ_total = (125 − 50) / 7,5 = 10 K/W
R_θ_radiator ≤ 10 − 5 − 0,5 = 4,5 K/W
```

Wybór: **radiator aluminiowy ~50×50 mm**, lub mniejszy z wentylacją.

## Krok 6: zabezpieczenia

### Bezpiecznik pierwotny

Prąd pierwotny przy 1,5 A wyjścia:
```
P_we = U_wy · I_wy / η = 12 · 1,5 / 0,55 = 32 W (sprawność ~55%)
I_AC = 32 / 230 = 0,14 A
```

Wybór: **bezpiecznik T 200 mA / 250 V** (zwłoczny — kondensator ładujący).

### Bezpiecznik wtórny (opcjonalnie)

T 2 A / 32 V na wyjściu mostka — chroni stabilizator i odbiornik.

### MOV (warystor)

Klasa **S14K275** (14 mm, 275 V AC) lub **S20K275** (20 mm, większa zdolność).

Zadanie: pochłonąć przepięcia z sieci (do 8 kV w impulsie 1,2/50 μs).

### NTC inrush limiter

Bez NTC prąd włączania może wynosić 50-100 A (ładowanie kondensatora). To:
- Wybija bezpieczniki domowe
- Niszczy diody mostka
- Stuka "klik" w sieci

**SCK-053** (5 Ω zimny, 0,2 Ω gorący, 3 A). Zimny ogranicza prąd. Gorący nie marnuje energii.

### Dioda freewheel stabilizatora

D5: **1N4007** anodą na OUT 7812, katodą na IN 7812. Chroni przed przepływem prądu z C4 → C1 przy wyłączeniu.

## Krok 7: filtr EMI (opcjonalny, ale zalecany)

W praktyce zasilacz liniowy nie generuje wiele EMI, ale do CE zgodności:

```
   L ──[F1]──┬── CM choke ──● ── do dalej
              │              │
             [X cap]        [Y cap]
              │              │
   N ────────●── CM choke ──● ── do dalej
                             │
   PE ──────────────────────●── (Y cap)
```

- **X cap**: 100-470 nF klasy X2 (między L a N)
- **Y cap**: 2,2-4,7 nF klasy Y2 (do PE)
- **CM choke**: dwie cewki na wspólnym rdzeniu, 1-10 mH

Dla zasilacza < 50 W można zostawić tylko **X cap 220 nF/X2** — wystarczy.

## Krok 8: LED sygnalizacyjna

LED czerwona na panelu, U_F = 2 V, I = 5 mA (oszczędność):
```
R = (12 − 2) / 0,005 = 2 kΩ → 2,2 kΩ standardowy
```

LED z rezystorem podłączony do wyjścia 12 V.

## Lista elementów (BOM)

| # | Element | Wartość | Typ / model | Ilość |
|---|---------|---------|-------------|-------|
| F1 | Bezpiecznik | 200 mA T | 5×20 mm szklany | 1 |
| MOV1 | Warystor | 275 V AC | S14K275 | 1 |
| NTC1 | Termistor inrush | 5 Ω / 3 A | SCK-053 | 1 |
| TR1 | Transformator | 230/15V 50VA | toroidalny | 1 |
| BR1 | Mostek prostowniczy | 4A/100V | KBPC2A04 | 1 |
| C1 | Kondensator filtra | 4700μF/35V | low-ESR | 1 |
| C2 | Kondensator | 330 nF | foliowy | 1 |
| C3 | Kondensator | 100 nF | ceramik | 1 |
| C4 | Kondensator wyjścia | 100μF/25V | elektrolit | 1 |
| U1 | Stabilizator | 7812 | TO-220 | 1 |
| D5 | Dioda ochronna | 1N4007 | 1A/1000V | 1 |
| LED1 | Sygnalizacja | czerwona 5mm | dowolna | 1 |
| R1 | Rezystor LED | 2,2 kΩ | 1/4 W | 1 |
| C5 | X-cap (filtr EMI) | 220 nF X2 | klasy X2 | 1 |
| HS1 | Radiator | R_θ ≤ 4 K/W | aluminiowy | 1 |

**Razem:** ok. 50-80 zł elementów.

## Wzór na PCB (uproszczony)

```
┌───────────────────────────────────────┐
│   L  N  PE   (zaciski sieciowe)       │
│   ●  ●  ●                              │
│   │  │  │                              │
│  [F1] [MOV][NTC] [X cap]              │
│   │  │                                 │
│   ●──●─────────────── (prim trafo)    │
│                    ║                   │
│                   ║║  TR1 toroid       │
│                    ║                   │
│   ●──●─────────────── (sek trafo)     │
│   │  │                                 │
│  [mostek]                              │
│   │  │                                 │
│   +  −                                 │
│   │  │                                 │
│  [C1]                                  │
│   │  │                                 │
│   ●──●─[7812]─●                       │
│   │     ║     │                        │
│   │   radiator│                        │
│   │           │                        │
│  [C2]      [C3 C4]                    │
│   │           │                        │
│  GND        +12V LED                   │
│              │   ●                     │
│              │  [R1]                   │
│              │   ●                     │
│              │  LED                    │
│              │                         │
│   +12V OUT ●─●                        │
│   GND OUT  ●                          │
└───────────────────────────────────────┘
```

### Zasady layoutu PCB

1. **Sekcja sieciowa (230 V) odseparowana** od strony niskonapięciowej — minimum 6-8 mm odstępu.
2. **Ścieżki sieciowe grube** (1-2 mm).
3. **PE bezpośrednio do metalowej obudowy** (gwint, śruba).
4. **Masa wspólna w jednym punkcie** (star ground) — wyjście GND blisko C4.
5. **Stabilizator z radiatorem mocno przykręcony** do PCB lub do obudowy.
6. **Lakier ochronny PCB** (komercyjny zasilacz).

## Test po montażu

### Krok 1: bez transformatora

Sprawdź wszystkie połączenia multimetrem (ciągłość, brak zwarcia L-N, izolacja).

### Krok 2: pierwsze włączenie

1. **Lampa żarowa 60 W szeregowo** z bezpiecznikiem F1 (soft start).
2. Włącz na chwilę.
3. Jeśli lampa świeci JASNO → zwarcie. WYŁĄCZ natychmiast.
4. Jeśli ciemnieje po chwili → OK.

### Krok 3: pomiar bez obciążenia

Wyjmij lampę, podłącz bezpośrednio do sieci. Mierz:
- U na wyjściu: ~12 V (może być 12,1-12,3 V)
- Temperatura 7812 po 5 min: < 50°C

### Krok 4: pomiar pod obciążeniem

Podłącz rezystor 10 Ω / 20 W (= 1,2 A obciążenia):
- U na wyjściu: 12 V ±0,1 V
- Temperatura 7812 po 10 min: < 80°C
- Temperatura transformatora po 30 min: < 60°C

### Krok 5: tętnienia

Oscyloskop na wyjściu (AC coupling, 10 mV/dz):
- Bez obciążenia: < 5 mV pp
- Pod 1,5 A: < 50 mV pp

Jeśli więcej — wadliwy kondensator C1.

## Modyfikacje

### Wersja regulowana

Zastąp 7812 układem **LM317** z potencjometrem (R2 = 5 kΩ z osi). Wyjście regulowane od 1,25 V do ~25 V.

### Wersja symetryczna ±12 V

Trafo z odczepem środkowym (2× 15 V CT), mostek (lub 4 osobne diody), dwa kondensatory, 7812 + 7912.

### Wersja z amperomierzem i woltomierzem

Cyfrowy moduł V-A z AliExpress (5-10 zł) bezpośrednio na panelu. Mierzy wyjście.

### Wersja chronionym (current limit)

Dodaj **rezystor pomiarowy** (shunt) na wyjściu + komparator (LM358) + tranzystor odcinający.

## Częste błędy projektowe

1. **Brak NTC** — wybijanie bezpieczników przy każdym włączeniu.
2. **Mały C1** — duże tętnienia, niestabilność.
3. **Brak radiatora 7812** — uciacie termiczne po 30 sekundach.
4. **Pomylone wejście/wyjście stabilizatora** — uszkodzenie.
5. **Brak izolacji galwanicznej** (np. autotransformator) — śmiertelne.
6. **Bezpiecznik za duży** — nie zadziała przy zwarciu, pożar.
7. **PE niepodłączone** — porażenie przy uszkodzeniu izolacji.
8. **Aluminium 7812 bez podkładki izolacyjnej** dotykające radiatora z innym potencjałem → zwarcie.

## Podsumowanie

Klasyczny zasilacz liniowy 12 V / 1,5 A jest **prostym, niezawodnym** projektem. Nie konkuruje sprawnością z SMPS, ale:

- Bardzo niskie tętnienia
- Brak zakłóceń EMI
- Bardzo proste do diagnozy
- Długa żywotność (jeśli kondensatory są dobre)

Dla audio, ADC, czułych pomiarów — liniowy zasilacz jest często **lepszy** niż SMPS.
