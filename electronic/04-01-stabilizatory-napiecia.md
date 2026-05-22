# 04-01: Stabilizatory napięcia

## Po co stabilizator

Po prostowniku i filtrze otrzymujemy "surowe DC" — pulsujące, niestabilne, zależne od obciążenia i napięcia sieci. Stabilizator daje na wyjściu **stabilne napięcie** mimo wahań wejścia i zmian obciążenia.

## Dwa typy stabilizatorów

### 1. Liniowy (Linear regulator)

Tranzystor "dławi" nadmiar napięcia, zamieniając go na ciepło. Prosty, bez zakłóceń, ale **niska sprawność**.

Sprawność: η = U_wy / U_we (przy I_wy = I_we, ignorując prąd jałowy).

Przykład: 12 V → 5 V daje sprawność 42%. Reszta to ciepło.

### 2. Impulsowy (SMPS — Switch-Mode)

Tranzystor szybko włącza i wyłącza prąd → cewka magazynuje energię → filtr LC daje stabilne wyjście. **Wysoka sprawność** (85-95%), ale generuje zakłócenia HF.

W tym rozdziale omówimy stabilizatory liniowe. SMPS — w rozdziale 05.

## Stabilizatory szeregowe stałe — seria 78xx / 79xx

### 78xx (napięcia dodatnie)

Trzykońcówkowy: wejście, masa, wyjście.

```
   IN ──┬── 78xx ──┬── OUT
        │          │
       [C1]       [C2]      Cin=100nF (lub elektrolit + ceramik)
        │          │       Cout=100nF + 10-100μF
       GND        GND
```

| Model | U_wy |
|-------|------|
| 7805 | 5 V |
| 7806 | 6 V |
| 7808 | 8 V |
| 7809 | 9 V |
| 7810 | 10 V |
| 7812 | 12 V |
| 7815 | 15 V |
| 7818 | 18 V |
| 7824 | 24 V |

Prąd wyjściowy do 1 A (TO-220), do 1,5 A (TO-3).

### 79xx (napięcia ujemne)

Komplement do 78xx — daje napięcia ujemne (−5, −12, −15 V). Pinout INNY (uwaga przy zamianie!).

### Dropout voltage

**Minimalna różnica U_we − U_wy**, przy której stabilizator działa.

| Stabilizator | Dropout |
|--------------|---------|
| 78xx | 2-3 V |
| 79xx | 2,5 V |
| LM317 | 2-3 V |
| LDO (np. AMS1117) | 1,2 V |
| Ultra-LDO (LP2985) | 0,3 V |

7805 z wejściem 6,5 V — może nie wystarczyć. Standardowo do 7805 dajemy ≥ 8 V.

### Parametry 7805

- U_we max: 35 V
- I_wy max: 1 A (TO-220 z chłodzeniem)
- Stabilizacja liniowa: <0,5% przy zmianach U_we
- Stabilizacja obciążeniowa: <0,5% przy zmianach I_wy
- Wewnętrzne zabezpieczenia: ograniczenie prądowe, termiczne, SOA

### Schemat zastosowania

```
   12V ──[C1]──┬──── IN [7805] OUT ────┬──── 5V
              │      GND                │
              │       │                 │
              │       │                 │
              ●───────●─────────────────●─── GND
                     
            C1: 330nF lub 0,33μF (zalecany na wejściu)
            C2: 100nF na wyjściu
            + elektrolit np. 10μF na każdym wejściu/wyjściu
```

### Chłodzenie

Moc tracona:
```
P = (U_we − U_wy) · I_wy
```

7805 z wejściem 12 V i wyjściem 0,5 A:
```
P = 7 · 0,5 = 3,5 W
```

TO-220 bez radiatora — max 1 W. 3,5 W wymaga radiatora o R_θ ≈ 20 K/W. W praktyce mały radiator aluminiowy.

## Stabilizator regulowany LM317

Najbardziej elastyczny stabilizator liniowy. Trzy nogi: ADJ, OUT, IN.

```
   U_we ──┬── IN [LM317] OUT ──┬── U_wy
                                │
                                ●── ADJ
                                │
                              [R1]
                                │
                                ●─── kondensator (10μF) ─ GND
                                │
                              [R2]
                                │
                              GND
```

Napięcie wyjściowe:
```
U_wy = 1,25 · (1 + R2/R1)
```

R1 = 240 Ω (zalecane przez datasheet), R2 dobierane od żądanego napięcia.

Przykład: chcemy 5 V. R1=240, R2:
```
5 = 1,25 · (1 + R2/240)
4 = 1,25 · R2/240
R2 = 768 Ω → najbliższe 750 Ω
```

### Zakres

- U_we: 3-40 V (do 60 V w LM350, LM338)
- U_wy: 1,25-37 V
- I_wy: 1,5 A (LM317), 3 A (LM350), 5 A (LM338)

### LM337

Komplement do LM317 — stabilizator ujemnego regulowanego napięcia.

## LDO (Low Drop-Out)

Stabilizator o małym dropout. Przykłady:

| Model | U_wy | I_wy | Dropout |
|-------|------|------|---------|
| AMS1117-3.3 | 3,3 V | 1 A | 1,1 V |
| LM1117-3.3 | 3,3 V | 0,8 A | 1,2 V |
| LP2950 | 5 V (stały) | 100 mA | 0,4 V |
| LP2985 | różne | 150 mA | 0,28 V |
| MIC5219 | różne | 500 mA | 0,5 V |
| TLV70033 | 3,3 V | 200 mA | 0,2 V |

LDO są niezbędne, gdy:
- Zasilanie z baterii Li-ion (3,0-4,2 V) → 3,3 V
- Mała różnica wejście-wyjście (np. 5 V USB → 3,3 V dla MCU)
- Ograniczona moc dyssypacji

### Kondensatory przy LDO

Większość LDO **wymaga konkretnych kondensatorów** dla stabilności. Datasheet podaje:
- C_in: typowo 1-10 μF
- C_out: 1-10 μF z określonym zakresem ESR

Niewłaściwy kondensator (np. ceramik z bardzo niskim ESR przy LDO, które oczekuje 100 mΩ) → oscylacje, niestabilność. AMS1117 jest tu wymagający — przejście na ceramiczny C_out czasem powoduje problemy.

## Stabilizatory zegera (Shunt regulator)

Najprostszy stabilizator. Dioda Zenera + rezystor.

### TL431

Programowalny shunt regulator. Bardzo precyzyjny (1%), tani, mały. Stosowany jako:
- Napięcie odniesienia 2,5 V
- Pętla sprzężenia w SMPS
- Stabilizator małej mocy

```
        +V
         │
        [R]
         │
         ●──── U_wy = 2,5 · (1 + R1/R2)
         │
       ┌─┴─ TL431 (3-pin)
       │
      [R1]
       │
       ●──── REF (do programowania U_wy)
       │
      [R2]
       │
      GND
```

## Stabilizator z tranzystorem (dyskretny)

Klasyczny układ — Zener + tranzystor wzmacniający prąd.

```
        +U_we
         │
        [R]
         │
         ●──── B ──┐ tranzystor NPN  (np. BD139)
         │         │
       [ZD]        │
         │         C
        GND        │
                   ●──── +U_wy
                   E
                   │
                   ●── obciążenie
                   │
                   ●─── GND
```

```
U_wy = U_Z − U_BE ≈ U_Z − 0,7 V
```

Zaleta: większy prąd niż Zenerem samym. Wada: brak stabilizacji linii i obciążenia tak dobrej jak IC.

## Projekt zasilacza liniowego — krok po kroku

### Krok 1: Wymagania

- U_wy = 5 V
- I_wy = 1 A
- Stabilność lepsza niż 1%
- Sieć 230 V AC

### Krok 2: Transformator

Wybieramy transformator z uzwojeniem wtórnym, które po prostowaniu da minimum U_wy + dropout + bufor.

U_DC ≈ U_wy + 3 V (dropout) + 2 V (tętnienia) = 10 V minimum

Po prostowniku (mostek): U_DC ≈ √2 · U_AC − 1,4 V
Czyli U_AC ≈ (10 + 1,4) / √2 ≈ 8 V AC

Wybór: transformator 9 V AC, 10-15 VA (z zapasem).

### Krok 3: Mostek prostowniczy

Dla 1 A: mostek 2 A, 100 V (B40C1500, KBPC2510). Z zapasem.

### Krok 4: Kondensator filtra

```
C ≥ I / (2·f·ΔU)
```

I = 1 A, f = 100 Hz (mostek z 50 Hz), ΔU = 1 V dopuszczalnych tętnień:

```
C ≥ 1 / (2 · 100 · 1) = 5000 μF
```

Wybór: 4700 μF / 25 V (zapas na napięcie).

### Krok 5: Stabilizator

7805 — TO-220 + radiator. Moc strat:

```
P = (12,7 − 5) · 1 = 7,7 W
```

Wymaga porządnego radiatora (R_θJA ≤ (T_max − T_amb) / P = (125-50)/7,7 ≈ 10 K/W).

### Krok 6: Kondensatory dodatkowe

- Na wejściu 7805: 330 nF + 100 nF (zapobiegają oscylacjom)
- Na wyjściu: 100 nF + 10-100 μF

### Krok 7: Zabezpieczenia

- Bezpiecznik 0,5 A T w obwodzie pierwotnym sieciowym
- Bezpiecznik 1,5 A F w obwodzie wtórnym (opcjonalnie)
- Dioda 1N4007 anodą na wyjściu, katodą na wejściu 7805 — chroni przy chwilowym U_wy > U_we (np. duży C na wyjściu)

## Schematy ważne praktycznie

### Symetryczne zasilanie ±15 V

Transformator z odczepem środkowym → mostek → ±C → 7815/7915.

```
   ~9V─┐
       ├── mostek (2-out) ──── + ──[7815]── +15V
   ~0V─┤                                     
   ~9V─┘                       − ──[7915]── -15V
                              0V ─────────── GND
```

### USB → 3,3 V

```
   USB +5V ──[AMS1117-3.3]── 3,3V
              │
            GND ──── GND
```

Z kondensatorami 10 μF na wejściu i wyjściu.

## Sprawność stabilizatorów liniowych

Krytyczna sprawa — straty.

| Konwersja | Sprawność |
|-----------|-----------|
| 12 V → 5 V | 42% |
| 12 V → 3,3 V | 27% |
| 5 V → 3,3 V | 66% |
| 9 V → 5 V | 56% |
| 4,2 V (Li-Ion) → 3,3 V (LDO) | 78% |

Dla większych prądów lub większej różnicy napięć — SMPS (rozdział 05).

## Częste błędy

1. **Bez kondensatorów blokujących** — oscylacje, niestabilność (zwłaszcza LDO).
2. **Pomylenie 78xx z 79xx** — pinout inny!
3. **Brak chłodzenia** — IC ucina prąd termicznie, wyjście "skacze".
4. **Za małe wejście** — np. 6 V do 7805 → wyjście tylko 4-4,5 V.
5. **Ceramiczny C_out przy AMS1117** — czasem oscylacje, wymagany niski ESR lub tantalowy.
6. **Pętla masy** — masa stabilizatora podpięta w innym punkcie niż masa wejścia.
7. **LM317 bez R1** — ucieczka punktu pracy.
8. **Brak diody freewheel** z OUT → IN — duża pojemność wyjściowa może uszkodzić stabilizator po wyłączeniu.
