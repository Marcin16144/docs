# 08-03: Wzmacniacze audio

## Klasy wzmacniaczy

| Klasa | Sprawność | Zniekształcenia | Zastosowanie |
|-------|-----------|-----------------|--------------|
| A | 20-30% | bardzo niskie | hi-fi, audiofile |
| B | 70-75% | wysokie (crossover) | nieużywana sama |
| AB | 50-65% | bardzo niskie | standard audio |
| C | 70-90% | bardzo wysokie | RF, nie audio |
| D | 85-95% | umiarkowane | nowoczesne, oszczędne |
| G/H | 70-80% | niskie | premium audio |

W audio dominuje **klasa AB** (analog) lub **klasa D** (cyfrowa, PWM).

## Preamplifier z BJT (klasa A)

Najprostszy wzmacniacz sygnału mikrofonu lub gitary.

```
        +12V
         │
        [Rc] 4,7k
         │
         ●───[C2]── wyjście
         │
         C
   ●─────B  BC547
   │     │
  [R1]   E
   │     │
   ●─[C1]●
   │     │
   we   [Re] 1k
         │
        [Cb] 100μF (bypass)
         │
        GND
        
   [R2] 22k z bazy do GND
   
   C1: 1 μF (sprzężenie wejścia)
   C2: 10 μF (sprzężenie wyjścia)
```

### Punkt pracy

```
U_B = U_we_DC = +12 · R2/(R1+R2) ≈ +1,5 V (z dzielnika R1=100k, R2=22k)
U_E = U_B - 0,7 = 0,8 V
I_E = U_E/Re = 0,8/1000 = 0,8 mA = I_C
U_C = +12 - 0,8 mA · 4,7 kΩ = 8,2 V (środek zakresu)
```

### Wzmocnienie

```
A_U = -R_C / r_e
r_e ≈ 25 mV / I_C = 25/0,8 = 31 Ω
A_U = -4700 / 31 ≈ -150
```

Wzmocnienie 150× (43 dB) — wystarczy do mikrofonu dynamicznego.

### Charakterystyka pasmowa

f_dolna = 1/(2π·R_in·C1). Dla R_in = 5 kΩ (impedancja wejścia tranzystora), C1 = 1 μF:
```
f_dolna = 1/(2π · 5000 · 10⁻⁶) = 32 Hz
```

OK dla audio. Dla pełnego pasma (20 Hz) zwiększ C1 do 2,2 μF.

## Wzmacniacz mocy LM386 (głośnik 8 Ω, do 1 W)

LM386 — klasyczny scalony wzmacniacz mocy mały. Idealny do prototypów, radio, intercom, modeli.

### Schemat podstawowy (wzmocnienie 20×)

```
   sygnał ── [C1 10μF] ── 3 (input+)
                          
   GND   ──────────────── 2 (input−)
                            ┌─ 1 ─┐
                            │     │ wewnątrz: 
                            │     │ pin 1-8 to bypass C dla
                            │     │ większego wzmocnienia
                            │     │
                            └─ 8 ─┘
                          
   +V (4-12V) ───────────── 6 (Vcc)
   GND ──────────────────── 4 (GND)
                          
                            5 (out) ──[C2 220μF]── głośnik 8Ω ── GND
                          
                            7 (bypass) ── [C 10μF] ── GND
```

### Zwiększenie wzmocnienia (do 200×)

```
   pin 1 ──[R 1,2k]──[C 10μF]── pin 8
```

To "obejście" rezystora wewnętrznego — wzmocnienie rośnie z 20 do 200.

### Moc

```
P_max = V²_supply / (8 · R_głośnika) = 12² / (8 · 8) = 2,25 W
```

W praktyce LM386 daje ok. 0,5-1 W przy 9 V (ograniczenie cieplne).

### BOM LM386

| Element | Wartość |
|---------|---------|
| LM386N-1 | DIP-8 |
| C1 (wejście) | 10 μF |
| C2 (wyjście) | 220-470 μF |
| C3 (bypass pin 7) | 10 μF |
| C4 (Zobel out) | 100 nF |
| R (Zobel out) | 10 Ω |
| Potencjometr | 10 kΩ liniowy (głośność) |

### Zobel network

Rezystor szeregowo z kondensatorem do GND z wyjścia. Stabilizuje wzmacniacz przy obciążeniach indukcyjnych (głośnik to indukcyjność!).

## TDA2030 — wzmacniacz 18 W (mono)

TDA2030 i TDA2050 to klasyczne integralne wzmacniacze mocy klasy AB. Tanie, niezawodne, dobrze brzmiące.

### Schemat (single supply ±15 V)

```
                    +15V
                     │
        ─[C1]── 1 (IN+)    
                     5 ─── +Vcc
   sygnał             
        ─────── 2 (IN−)    4 ─── −Vcc
                     │
                    GND   3 (OUT) ──┬── głośnik 4 Ω
                                    │
                                   GND
                     
   Sprzężenie zwrotne:
   R1 (między OUT a pin 2): 22 kΩ
   R2 (między pin 2 a masą): 680 Ω
   Wzmocnienie = 1 + R1/R2 = 33 (30 dB)
```

### Pinout TDA2030 (TO-220)

```
1: IN+ (nieodwracające)
2: IN− (odwracające)
3: OUT
4: -Vcc
5: +Vcc
```

### Moc

| Zasilanie | Głośnik 4 Ω | Głośnik 8 Ω |
|-----------|-------------|-------------|
| ±12 V | 14 W | 9 W |
| ±15 V | 18 W | 12 W |
| ±18 V (max) | 25 W | 15 W |

### Chłodzenie

P_max ~25 W dla TDA2030, 32 W dla TDA2050. Wymagany radiator:

```
R_θ ≤ (T_J - T_amb) / P
   ≤ (150 - 50) / 12  (przy ~12 W typowych strat)
   ≤ 8 K/W
```

Aluminiowy radiator 80×80×30 mm wystarczy.

### Zabezpieczenia

TDA2030 ma wbudowane:
- Termiczne ucinanie (powyżej 145°C)
- Ograniczenie prądu (~3 A)
- Wykrywanie zwarcia

Mimo to dodaj diody Schottky na wyjściu (snubber) i bezpiecznik wtórny 2 A.

## Wzmacniacz stereo TDA2030 + tone control

```
   L_in ──[pot. wol.]──[tone net]──[TDA2030 #1]── L_out
   R_in ──[pot. wol.]──[tone net]──[TDA2030 #2]── R_out
```

Z dodatkowym dwustopniowym tone control (basy + soprany) z op-ampem TL072 jako preamp.

## Wzmacniacz klasy D — TPA3116

Klasa D = sygnał audio modulowany PWM (300-500 kHz) + filtr LC na wyjściu. Sprawność 90%+. Mało ciepła.

### Parametry TPA3116D2

- Moc: 2× 50 W (stereo) lub 1× 100 W (mono, BTL)
- Zasilanie: 4,5-24 V (24 V dla pełnej mocy)
- Sprawność: 90%
- Wbudowany filtr DC/przeciw "puknięciu"
- THD: < 0,1%

### Schemat (uproszczony)

```
   sygnał L → IN_L → TPA3116 → PWM_L → LC filter → głośnik L
   sygnał R → IN_R → TPA3116 → PWM_R → LC filter → głośnik R
```

Filtr LC na wyjściu:
- L = 10-22 μH (dławik)
- C = 470 nF / 100 V

W praktyce kupuj gotowe moduły TPA3116 z AliExpress (~30 zł), bo PCB layout krytyczny.

### Zalety klasy D

- Wysoka sprawność (90% vs 50% AB)
- Mały radiator (mało ciepła)
- Zasilanie z baterii (Bluetooth speakers, samochodowe)

### Wady

- Wymaga starannego PCB layout (EMI)
- Filtr na wyjściu obowiązkowy
- Niekiedy gorszy "feel" w audiofilskim porównaniu

## Wzmacniacz operacyjny jako preamp + bufor

Klasyczny układ — wzmacniacz nieodwracający na op-ampie + bufor.

```
       +Vcc (np. ±15V)
        │
   we ──┤+
        │ TL072
   ┌────┤−
   │    │
  [R2]  │
   │    └── out ──[C 1μF]── do wzmacniacza mocy
  GND  
   │
  [R1]
   │
  GND
   
   Wzmocnienie = 1 + R2/R1
   R1 = 1k, R2 = 9k → wzm. 10 (20 dB)
```

Z dwoma op-ampami w TL072 (DIP-8) możesz mieć stereo na jednym chipie.

## Mikser audio (sumator op-amp)

3 kanały wejściowe sumowane:

```
   in1 ──[R1 10k]──┐
   in2 ──[R2 10k]──●── −
   in3 ──[R3 10k]──┘     >── out
                   +
                  GND
   
   sprzężenie: out ──[Rf 10k]── do punktu sumującego
   
   Vout = -(Vin1 + Vin2 + Vin3)
```

Każdy kanał można osłabić niezależnie potencjometrem (10 kΩ) przed wejściem.

## Tone control — Baxandall (basy + soprany)

Klasyczny obwód z lat 50, do dzisiaj standardowy:

```
   we ──[C1 47n]──┬──[R1 10k]──┬──[C2 100p]──── wy
                  │              │
                  ●── potencjometr basy
                  │      │
                  ●──[R2]─────── do bazy obwodu
                  
                  ●── potencjometr soprany  
                  │      │
                  ●──[R3]─────── do bazy obwodu
```

Pełny układ daje regulację ±15 dB w basach (100 Hz) i sopranach (10 kHz).

## Phantom power dla mikrofonu

Mikrofony pojemnościowe wymagają zasilania ~48 V (phantom). Schemat:

```
   +48V (z zasilacza) ──┐
                         ├─[6,8k]── pin 1 (mic +)
                         │
                         ├─[6,8k]── pin 2 (mic −)
                         │
   GND ────────────────────── pin 3 (shield/GND)
```

48 V doprowadzone do obu pinów sygnałowych. Sygnał wraca jako różnica — phantom "niewidzialne".

## Wskazówki praktyczne

### Masa to święta sprawa

W audio masa = śmierć projektu, jeśli pominiesz. Zasada **single point ground**:
- Wszystkie masy łączą się **w jednym punkcie**
- Masa wejściowa, wyjściowa, zasilania — w jednym
- Brak pętli mas

### Sprzężenie kondensatorami

Każda zmiana DC (przejście między stopniami) przez kondensator. Wartość:
```
f_dolna = 1 / (2π · R · C)
```

Dla audio 20 Hz dolna: C ≥ 10 μF przy R = 10 kΩ.

### Kondensatory wyjściowe

Duże (220-1000 μF) sprzęgają wyjście ze głośnikiem. Jakość kondensatora ma znaczenie — preferuj **niskoESR**.

### Zasilanie czyste

Wzmacniacz audio MUSI mieć czyste zasilanie. SMPS daje brum (50 Hz) i piski (HF). Liniowy zasilacz lepiej. Ekstra filtry:
- Duży kondensator (10 000 μF) na wejściu
- Mniejsze (100 nF) tuż przy każdym IC
- Cewka 10-100 μH w szereg dla najczulszych preampów

### Klucz uziemienia (ground lift)

Czasem **pętla masy** powoduje brum. Rozwiązania:
- Lift switch na masie wejścia
- Optoseparator
- Transformator izolacyjny audio (drogi)

## Podsumowanie

| Cel | Wybór |
|-----|-------|
| Mikrofon → słuchawki, prosty | LM386 |
| Mały głośnik (radio, modele) | LM386 lub PAM8403 (klasa D, 3 W) |
| Średni głośnik (10-20 W) | TDA2030 / TDA2050 |
| Domowy stereo (50-100 W) | TPA3116 (klasa D) lub TDA7294 (AB) |
| Hi-fi audiofile | klasa A dyskretny lub markowy chip (LM3886) |
| Estradowy (kW) | dedykowane wzmacniacze profesjonalne |

W hobby: zacznij od LM386 → przejdź do TDA2030 → TPA3116. Mocniejsze klasy A buduj po nabyciu doświadczenia.
