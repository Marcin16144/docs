# 08-01: Stabilizatory napięcia — układy praktyczne

## Rozszerzenie 7805 — wzmocnienie prądowe tranzystorem PNP

7805 daje maksymalnie 1 A. Co zrobić, gdy potrzebujesz 3 A, 5 A, 10 A?

Dodać tranzystor "obejściowy" (pass transistor) PNP:

```
  +U_we ─┬──── E
         │     │
        [R1]   │ Q1 (PNP, np. TIP32, 2N2955)
         │     │
         ●─────B
         │     │
        [78xx] C
         │     │
        GND    ●──── +U_wy (większy prąd)
```

### Zasada działania

Małe prądy → płyną przez 7805 (do ~500 mA). Większe → spadek napięcia na R1 (= I · R1) otwiera Q1, który "obchodzi" 7805 i niesie nadmiarowy prąd.

### Wzory

```
R1 = U_BE_Q1 / I_próg
```

Dla I_próg = 100 mA, U_BE = 0,7 V:
```
R1 = 0,7 / 0,1 = 7 Ω → 6,8 Ω
```

Wybór tranzystora:
- I_max ≥ całkowity prąd obciążenia
- U_CEO ≥ U_we
- Obudowa z radiatorem (TO-220, TO-3)

### Wady

- Tracona moc na tranzystorze: P = (U_we − U_wy) · I_obc — duża strata.
- Wymagane chłodzenie.
- Brak zabezpieczeń (7805 chroni siebie, ale Q1 nie).

## LM317 — uniwersalny stabilizator regulowany

LM317 to standardowy stabilizator 1,25-37 V, do 1,5 A.

### Podstawowy układ

```
   U_we ──┬── IN [LM317] OUT ──┬── U_wy
                                │
                                ●── ADJ
                                │
                              [R1] 240Ω
                                │
                              [R2] (regulowany)
                                │
                              GND
```

Wzór:
```
U_wy = 1,25 · (1 + R2/R1)
```

### Tabela wartości

| U_wy | R1 = 240 Ω | R2 |
|------|-----------|-----|
| 3,3 V | 240 | 390 Ω |
| 5 V | 240 | 720 Ω → 750 Ω |
| 9 V | 240 | 1490 Ω → 1,5 kΩ |
| 12 V | 240 | 2060 Ω → 2 kΩ |
| 15 V | 240 | 2640 Ω → 2,7 kΩ |
| 24 V | 240 | 4360 Ω → 4,3 kΩ |

### LM317 z protekcją (pełny układ)

```
   U_we ──┬─[D1]──┬── IN [LM317] OUT ──┬─[D2]──┬── U_wy
          │       │                     │      │
         [C1]    │                    [C2]   [C3]
          │       │                     │      │
         GND     GND                   ADJ    GND
                                        │
                                      [R1]──● 
                                        │
                                      [R2]
                                        │
                                       GND
                                       
   D1: 1N4007 (ochrona przed odwrotną polaryzacją wejścia)
   D2: 1N4007 (ochrona — gdy U_wy > U_we, np. duża pojemność wyjścia)
   C1: 0,33 μF (zalecane przez datasheet)
   C2: 10 μF na ADJ (lepsza stabilność)
   C3: 1 μF / U_wy + 20% (filtr wyjścia)
```

### Zwiększenie prądu LM317

Tak samo jak z 7805 — dodaj tranzystor PNP równolegle. Wynikowo otrzymasz stabilizator regulowany do 5-10 A.

## Symetryczne zasilanie ±15 V (audio, op-ampy)

```
   ~ 15V ──┐
            ├── mostek prostowniczy ──┐
   ~ 0V ────●                          ●─ +
            │                          │
   ~ 15V ──┘                           ●─ 0V (CT)
                                       │
                                       ●─ −
                                       
   + ──[4700μF]── 0V ──[4700μF]── −
                                       
   +DC ──[7815]── +15V
   −DC ──[7915]── −15V
   0V (środek) ── GND
```

### Wymagania

- Transformator z **odczepem środkowym** (typowy 2× 15 V AC)
- LUB dwa identyczne transformatory szeregowo z masą w środku
- Mostek 4-diodowy (jeden, podzielony)
- Dwa kondensatory filtra (osobno na +DC i −DC)
- 7815 i 7915 (uwaga, **pinout** 7915 INNY!)

### Pinout — UWAGA

```
7815 (TO-220, patrząc z przodu):
   1: GND
   2: OUT
   3: IN

7915 (TO-220, patrząc z przodu):
   1: ADJ/GND
   2: IN
   3: OUT
```

Inna kolejność! Pomyłka = uszkodzenie.

## Stabilizator z TL431 (programowalny shunt)

TL431 to tani (0,5 zł), bardzo dokładny (1%) regulator. Działa jak Zener o regulowanym napięciu 2,5-36 V.

### Schemat — referencyjne 5 V

```
   +U_we
     │
    [R]
     │
     ●──── +5V (out)
     │
     A──┐
        │ TL431
     K──┤
        │
        ●── REF
        │
       [R1]
        │
       GND
       
   [R1] dobrane na: U_wy = 2,5 · (1 + R1_góra/R2_dół)
   typowo R1 = R2 → U_wy = 5V
```

Pinout TL431:
- **REF** — wejście porównawcze (2,5 V)
- **A** — anoda
- **K** — katoda (połączona z REF dla stałego 5 V)

### Zastosowania TL431

- Referencja napięciowa
- Sprzężenie zwrotne w SMPS (pętla optoizolacyjna)
- Stabilizator małej mocy

## LDO 3,3 V z baterii Li-Ion

Bateria Li-Ion daje 3,0-4,2 V. Dla MCU 3,3 V potrzeba LDO o niskim dropout:

```
   Li-Ion +
     │
   [10μF]
     │
     ●── IN [AMS1117-3.3] OUT ──┬── +3,3V
                                 │
                              [10μF + 100nF]
                                 │
                                GND
```

| Parametr | AMS1117-3.3 |
|----------|-------------|
| U_wy | 3,3 V (±2%) |
| U_we | 4,75-15 V |
| Dropout | 1,1 V przy 800 mA |
| I_max | 1 A |

**Uwaga:** AMS1117 nie zadziała przy U_we < 4,4 V! Lepsze do baterii:
- **TLV70033** (dropout 0,2 V)
- **MIC5219** (dropout 0,5 V)
- **MCP1700** (ultra-low quiescent, 1,6 μA)

## Źródło prądowe z LM317

LM317 może też pracować jako **źródło stałego prądu** (Constant Current — CC). To podstawa sterowania LED dużej mocy.

```
   +U_we ── IN [LM317] OUT ──┬── obciążenie (LED)
                              │
                              ●── ADJ
                              │
                             [R_set]
                              │
                            obciążenie (gdzie kończy się ADJ)
                              │
                             GND
```

LM317 zawsze utrzymuje **1,25 V** między OUT a ADJ. Więc prąd przez R_set:
```
I = 1,25 / R_set
```

### Przykłady

| I (mA) | R_set | Moc R_set |
|--------|-------|-----------|
| 20 (sygnalizacyjna LED) | 62 Ω | 25 mW |
| 100 | 12,4 Ω | 125 mW → 1/4 W |
| 350 (LED 1W) | 3,6 Ω | 0,44 W → 1 W |
| 700 (LED 3W) | 1,8 Ω | 0,88 W → 2 W |
| 1000 | 1,25 Ω | 1,25 W → 2 W |

### Ograniczenia

- Maksymalny prąd LM317: 1,5 A
- Dropout 2-3 V → potrzebujesz U_we ≥ U_LED + 3 V
- Sprawność niska (jak każdy liniowy)

Dla dużych prądów lepiej sterownik scalony LED (LM3914, CL2N, BCR401).

## Pełna ochrona zasilacza — checklist

Profesjonalny zasilacz powinien zawierać:

1. **Bezpiecznik** w obwodzie pierwotnym (T 100 mA, 250 V)
2. **Warystor** (MOV) na wejściu (S20K275 dla 230 V)
3. **Filtr EMI** (CM choke + X cap + Y cap)
4. **NTC inrush limiter** (5-10 Ω, 3 A)
5. **Transformator** z izolacją wzmocnioną
6. **Mostek prostowniczy** z zapasem 2× prądu
7. **Kondensator filtra** z low-ESR, 105°C, zapas napięcia 2×
8. **Stabilizator** z radiatorem
9. **Dioda freewheel** ze stabilizatora (z OUT na IN)
10. **Crowbar** — Zener + tyrystor zwierający przy przepięciu wyjścia
11. **LED sygnalizacyjna** z rezystorem (np. 2,2 kΩ na 12 V → 5 mA)
12. **Bezpiecznik wtórny** opcjonalnie (chroni odbiornik przed zbyt dużym prądem)

## Crowbar — ochrona przed przepięciem wyjścia

Gdy 7805 ulegnie wewnętrznemu zwarciu (rzadko, ale się zdarza), na wyjściu może pojawić się pełne napięcie wejścia (np. 12 V zamiast 5 V). To zniszczy podłączoną elektronikę.

```
   +U_wy ──┬─────┬─── (do obciążenia)
            │     │
           [R]   A
            │    │  SCR (tyrystor)
           ZD    G  (BT151, BT169)
           5,6V  │
            │    K
            ●────┴───
                 │
                GND
   
   Plus: bezpiecznik szeregowo na wejściu obwodu
```

Działanie: Zener 5,6 V przewodzi tylko gdy U_wy > 6 V → impuls do bramki tyrystora → tyrystor zwiera U_wy do masy → bezpiecznik przed obwodem przepala się.

Element ostatniej szansy, ale działa.

## Dobór radiatora

Moc tracona na stabilizatorze:
```
P_strat = (U_we − U_wy) · I_obc
```

Rezystancja termiczna potrzebna:
```
R_θ_total = (T_J_max − T_amb) / P_strat

R_θ_radiator = R_θ_total − R_θ_JC − R_θ_CS

R_θ_JC: junction-to-case (z datasheet, np. 5 K/W)
R_θ_CS: case-to-sink (z pastą 0,5 K/W, bez 1 K/W)
```

### Przykład

7805 z 12 V wejście, 0,5 A obciążenie:
```
P_strat = (12-5) · 0,5 = 3,5 W
T_J_max = 125°C, T_amb = 50°C
R_θ_total = (125-50) / 3,5 = 21,4 K/W
R_θ_radiator = 21,4 - 5 - 0,5 = 15,9 K/W
```

Wybór: radiator z R_θ ≤ 15 K/W. Mały aluminiowy 30×30 mm — wystarczy.

Większy zapas — większy radiator (8-12 K/W).

### Izolacja od radiatora

Niektóre układy mają **tab połączony z GND lub OUT**. Jeśli radiator jest wspólny dla kilku stabilizatorów — trzeba odizolować:
- Podkładka miki + tulejka izolacyjna na śrubie
- Lub silikon termoprzewodzący izolacyjny (Sil-Pad)

## Typowe schematy — gotowe BOM-y

### Zasilacz 5 V / 1 A z USB

- LDO AMS1117-3.3 lub buck MP1584 (lepsza sprawność)
- C_in 10 μF, C_out 22 μF
- Złącze USB-C lub micro-USB
- LED + rezystor 1 kΩ

### Zasilacz 12 V / 2 A liniowy

- Trafo 15 V AC / 30 VA (toroidalny)
- Mostek 4 A / 100 V
- C_filt 4700 μF / 25 V
- 7812 z radiatorem 5 K/W
- LED + 5 kΩ
- Bezpiecznik T 200 mA / 250 V (primary), F 2,5 A (secondary)

### ±15 V / 0,5 A symetryczny

- Trafo 2× 15 V AC / 20 VA (CT)
- Mostek 4 A
- 2× 2200 μF / 35 V
- 7815 + 7915 z radiatorami
- 2× LED + 5 kΩ

## Częste błędy

1. **Brak kondensatorów blokujących** → oscylacje na wyjściu.
2. **Pomylenie pinów 7805/7905** → uszkodzenie.
3. **Brak chłodzenia** → ucinanie termiczne, niestabilność.
4. **AMS1117 z baterii Li-Ion** → poniżej 4,4 V brak regulacji.
5. **Tantal w odwrotnej polaryzacji** → wybuch.
6. **Krótki obwód masy** (analog ≠ power ≠ chassis) → szumy.
7. **Brak diody zwrotnej z OUT na IN** w stabilizatorze z dużym C_out → uszkodzenie przy wyłączeniu.
