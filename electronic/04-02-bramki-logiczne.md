# 04-02: Bramki logiczne

## Czym są bramki logiczne

Najprostsze cyfrowe układy scalone. Realizują operacje logiki Boole'a — AND, OR, NOT, NAND, NOR, XOR. Z nich można zbudować dowolny układ cyfrowy, w tym procesor.

W cyfrowej elektronice operujemy dwoma stanami logicznymi:

- **0 (LOW, L)** — niskie napięcie (zwykle 0 V)
- **1 (HIGH, H)** — wysokie napięcie (zwykle V_CC)

## Podstawowe bramki

### NOT (inwerter)

Jedno wejście, wyjście odwrócone.

```
A | Y
──┼──
0 | 1
1 | 0
```

Symbol: trójkąt z kółkiem.

### AND

Wyjście HIGH gdy oba wejścia HIGH.

```
A B | Y
────┼──
0 0 | 0
0 1 | 0
1 0 | 0
1 1 | 1
```

### OR

Wyjście HIGH gdy choć jedno wejście HIGH.

```
A B | Y
────┼──
0 0 | 0
0 1 | 1
1 0 | 1
1 1 | 1
```

### NAND (Not AND)

Negacja AND.

```
A B | Y
────┼──
0 0 | 1
0 1 | 1
1 0 | 1
1 1 | 0
```

NAND jest **uniwersalna** — z samych NAND można zbudować każdą inną bramkę.

### NOR (Not OR)

Negacja OR. Też uniwersalna.

```
A B | Y
────┼──
0 0 | 1
0 1 | 0
1 0 | 0
1 1 | 0
```

### XOR (eXclusive OR)

Wyjście HIGH gdy wejścia **różne**.

```
A B | Y
────┼──
0 0 | 0
0 1 | 1
1 0 | 1
1 1 | 0
```

Stosowane: sumatory, kontrola parzystości, generatory pseudolosowe.

### XNOR

Negacja XOR. Wyjście HIGH gdy wejścia **równe**.

## Rodziny układów logicznych

### TTL (Transistor-Transistor Logic)

Stara, oparta na BJT. Szybka, ale prądożerna.

| Seria | Rok | Zasilanie | Prąd jałowy |
|-------|-----|-----------|-------------|
| 74 | 1966 | 5 V | 10 mA / bramkę |
| 74L | (Low Power) | 5 V | 1 mA |
| 74S | (Schottky) | 5 V | 20 mA, szybka |
| 74LS | Low-Power Schottky | 5 V | 2 mA |
| 74ALS | Advanced LS | 5 V | mniej |
| 74F | Fast | 5 V | szybka, prądożerna |

Poziomy TTL:
- LOW: 0-0,8 V
- HIGH: 2,0-5 V
- VOL max: 0,4 V (wyjście)
- VOH min: 2,4 V (wyjście)

### CMOS (Complementary MOS)

Współczesna, MOSFETy. Niskie zużycie, szeroki zakres zasilania.

| Seria | Zasilanie | Cechy |
|-------|-----------|-------|
| 4000 | 3-15 V | wolna, ale niskoenergetyczna |
| 74HC | 2-6 V | szybka, kompatybilna z TTL na wyjściu |
| 74HCT | 4,5-5,5 V | wejścia kompatybilne z TTL |
| 74AHC/AHCT | 2-5,5 V | szybsza |
| 74LVC | 1,65-3,6 V | low voltage |
| 74AUC | 0,8-2,7 V | ultra low |

Poziomy CMOS (5 V):
- LOW: 0-1,5 V
- HIGH: 3,5-5 V

CMOS zużywa prąd **głównie przy przełączaniu** (ładowanie pojemności bramek). Stąd statycznie pobiera nA, dynamicznie więcej.

### Inne rodziny

- **ECL** — ultra szybka, prądożerna (rzadko poza specjalnymi)
- **LVDS** — sygnały różnicowe niskonapięciowe (HDMI, USB 3)
- **GTL/HSTL** — pamięci, magistrale

## Popularne układy 74xx

| Numer | Funkcja |
|-------|---------|
| 7400 | 4× NAND (2 wejścia) |
| 7402 | 4× NOR |
| 7404 | 6× NOT (inwertery) |
| 7408 | 4× AND |
| 7432 | 4× OR |
| 7486 | 4× XOR |
| 7474 | 2× D-FlipFlop |
| 7476 | 2× JK-FlipFlop |
| 7490 | dekada licząca |
| 74138 | dekoder 3→8 |
| 74148 | enkoder 8→3 |
| 74151 | mux 8:1 |
| 74157 | mux 2:1, 4-bit |
| 74164 | rejestr przesuwny SIPO |
| 74165 | rejestr przesuwny PISO |
| 74181 | ALU 4-bit |
| 74244 | bufor 3-state, 8-bit |
| 74245 | transceiver 8-bit |
| 74373 | latch 8-bit |
| 74595 | rejestr 8-bit z wyjściem szeregowym (popularny!) |

## Podstawowe układy z bramek

### Flip-Flop SR z dwóch NAND

Najprostszy element pamięci.

```
   S ──[NAND]──Q──┐
        ▲         │
        │         │
        └─────────┘
              ▲
              │
   R ──[NAND]──Q̄──┘
```

### Sumator półbit (half adder)

XOR daje sumę, AND daje przeniesienie.

### Sumator pełnobit (full adder)

3 wejścia: A, B, C_in. Dwa wyjścia: Sum, C_out.

### Licznik

Łańcuch flip-flopów. Każdy dzieli częstotliwość przez 2.

### Multiplekser

Wybiera jeden z N sygnałów na wyjście, sterowany binarnym selektorem.

## Poziomy logiczne — pułapki

### TTL → CMOS 5V

TTL wyjście HIGH min. 2,4 V. CMOS 5V wymaga ≥3,5 V dla pewnego H. **Niezgodne!**

Rozwiązanie: 74HCT (CMOS z wejściami TTL-kompatybilnymi).

### 3,3 V → 5 V (i odwrotnie)

Mikrokontrolery dzisiaj często 3,3 V, peryferia 5 V. Problemy:

- 3,3 V → 5 V wejście: większość 5 V CMOS akceptuje 2,2 V jako HIGH → OK. Sprawdź datasheet.
- 5 V → 3,3 V wejście: 5 V na wejście 3,3 V → uszkodzenie! Trzeba **konwertera poziomów** (level shifter) — np. tranzystor BSS138 lub gotowy układ 74LVC8T245.

### Pułapka MOSFET z 3,3 V

Standardowy MOSFET sterowany 3,3 V → nie do końca otwarty → grzanie. Tylko logic-level MOSFET (np. AO3400, IRLB3034).

## Rezystory podciągające (pull-up / pull-down)

Wejście CMOS w stanie nieokreślonym → losowe wartości. Trzeba "ustalić" stan rezystorem.

```
   +V
    │
   [R]    pull-up: gdy nic nie podłączone, wejście = HIGH
    │
    ●── wejście
    │
   nic lub przycisk do GND
```

```
   +V
    │
   przycisk
    │
    ●── wejście
    │
   [R]   pull-down: gdy nic, wejście = LOW
    │
   GND
```

Typowo R = 10 kΩ. Zbyt niski = duży prąd. Zbyt wysoki = wrażliwość na szumy.

W mikrokontrolerach pull-up często **wewnętrzny** — wystarczy włączyć go w rejestrze portów.

## Open-collector / Open-drain

Niektóre wyjścia (np. komparator LM393, magistrale I2C, OC bramki 7406) nie mają górnego tranzystora — wyjście może tylko ściągać do masy. Dla stanu HIGH trzeba **zewnętrznego pull-up**.

Pozwala to:
- Wired-OR (kilka wyjść równolegle, każde może ściągnąć do masy)
- Konwersja poziomów (pull-up do dowolnego napięcia)
- Magistrale (I2C, SMBus)

## Bufor 3-state

Trzy stany: 0, 1, **wysoka impedancja (Hi-Z)**. Pozwala odłączyć wyjście od magistrali.

Typowe: 74244, 74245. Stosowane w pamięciach, magistralach.

## Szybkość bramek

| Rodzina | Czas propagacji |
|---------|----------------|
| 7400 (TTL) | 10 ns |
| 74LS | 9 ns |
| 74HC | 8 ns |
| 74HCT | 9 ns |
| 74F | 3 ns |
| 74LVC | 2-3 ns |

W praktyce ograniczeniem są pojemności PCB i routing.

## Zasady projektowe

### 1. Niewłaściwe użycie nieużywanych bramek

Wolne wejścia CMOS muszą być **podłączone** (do V_CC lub GND). Otwarte = łapanie szumów + zwiększony pobór prądu.

```
       +V
        │
   [R 10kΩ]
        │
        ●── nieużywane wejście NAND
        
   (najlepiej: wprost do GND lub Vcc)
```

### 2. Kondensator blokujący

100 nF dla każdej obudowy logiki, tuż przy nóżce VCC.

### 3. Szybkie tranzycje

Bramki CMOS przełączają się szybko (ns). To powoduje:
- Pikowe prądy z linii zasilania
- Indukcja sygnału w sąsiednich ścieżkach
- Promieniowanie EMI

Rozwiązanie: tłumiki RC, dobry routing, niskoindukcyjne kondensatory blokujące.

### 4. Race conditions

Sygnały docierają w różnym czasie. Może powstawać krótka iglica (glitch). Stąd flip-flopy zegarowe (synchroniczne) zamiast asynchronicznej logiki kombinacyjnej.

## FPGA / CPLD

Współczesne projekty cyfrowe rzadko korzystają z dyskretnych bramek 74xx. Zamiast tego:

- **CPLD** (Complex Programmable Logic Device) — prosty, do logiki kombinacyjnej
- **FPGA** (Field-Programmable Gate Array) — duże, do CPU, DSP, kontrolerów

Programowane w HDL (VHDL, Verilog). Bramki 74xx są używane głównie:
- W glue logic (sklejenie peryferiów)
- W szkolnictwie
- Tam, gdzie nie ma sensu FPGA dla 1-2 bramek

## Częste błędy

1. **Otwarte wejścia CMOS** — szumy, niestabilne działanie.
2. **Pomyłka rodziny** — 7400 (TTL) z 4000 (CMOS) — różne zasilanie i poziomy.
3. **Brak pull-up na open-collector** — wyjście nie idzie nigdy do HIGH.
4. **5 V → 3,3 V bezpośrednio** — uszkodzenie MCU.
5. **Brak kondensatorów blokujących** — losowe błędy logiczne.
6. **Łączenie wyjść totem-pole bezpośrednio** (z wyjątkiem open-collector) — zwarcie, uszkodzenie.
7. **Przeciążanie wyjść** — wyjście 74HC dostarcza ~25 mA, nie zasilaj LED bezpośrednio bez rezystora.
