# 08-04: Generatory i oscylatory

## Po co generator

Generator wytwarza okresowy sygnał (sinus, prostokąt, trójkąt) o znanej częstotliwości i kształcie. Zastosowania:

- Sygnały testowe (audio, RF)
- Zegary (clock) dla układów cyfrowych
- Nośne radia (mod. AM/FM)
- Konwersja częstotliwości (mieszacze)
- Buzzery, alarmy
- Stroboskopy, generatory PWM

## NE555 — astabilny multivibrator (omówiony szczegółowo)

Patrz [04-03-timer-ne555.md](04-03-timer-ne555.md). Krótko:

```
f = 1,44 / ((Ra + 2·Rb) · C)
```

Idealny do 1 Hz – 100 kHz. Łatwy, tani, niezawodny.

## Oscylator Wien (sinus z op-ampem)

Generator sinusoidalny dla audio. Op-amp + sieć RC tworzy sinus o niskim THD (< 0,1%).

```
        ┌──[R3]──[R4 z lampką]──┐  ← regulacja amplitudy
        │                         │
        │            ┌─── + ─────┘
        │            │
   ┌─[R]─┬──[C]─┐    op-amp
   │     │      │    
  GND   [R]   [C]──[R]── out ── do dalej
         │      │       │
        GND     │      [R5]
                │       │
                ●───────● ── sprzężenie zwrotne (dodatnie)
                
   Element regulujący amplitudę: żarówka (NTC) lub JFET
```

### Częstotliwość

```
f = 1 / (2π·R·C)
```

Dla R = 10 kΩ, C = 16 nF → f ≈ 1 kHz.

### Wzmocnienie

Wzmocnienie op-ampa musi być **dokładnie 3** — większe powoduje saturację, mniejsze — wygaszenie. Stąd element regulujący (lampka, JFET, dioda + R).

### Generator funkcyjny

Klasyczny układ daje **3 przebiegi jednocześnie**:
- Trójkątny (z integratora op-ampa)
- Prostokątny (z komparatora Schmitta)
- Sinusoidalny (z trójkątnego przez kształtownik nieliniowy z 2 diodami)

Gotowe ICs: **ICL8038**, **XR2206** (klasyczne, dziś trudno dostać).

## Oscylator Colpittsa (LC)

Generator RF, częstotliwości od kHz do GHz. Cewka + dwa kondensatory + tranzystor.

```
        +Vcc
         │
        [Rc]
         │
         ●── C ── tranzystor BJT
         │   │
         │   B ──[Rb]── +Vcc
         │   │
         │   E ──[Re]── GND
         │   │
         │   [L]
         │   │
         ●───●── wyjście
         │
        [C1]
         │
         ●
         │
        [C2]
         │
        GND
        
   L + (C1 szeregowo C2) = obwód rezonansowy
```

### Częstotliwość

```
C = C1 · C2 / (C1 + C2)
f = 1 / (2π · √(L · C))
```

Przykład: L = 100 μH, C1 = C2 = 100 pF → C = 50 pF, f = 2,25 MHz.

### Zastosowania Colpittsa

- Lokalne oscylatory (LO) w radioodbiornikach
- Generatory CW
- Stroje wzmacniaczy RF

## Oscylator Hartley'a

Podobny do Colpittsa, ale **cewka z odczepem** zamiast dwóch kondensatorów.

```
   L1 ──── (kondensator pojemnościowy)
    │
  odczep
    │
   L2
```

Częstotliwość:
```
f = 1 / (2π · √((L1+L2) · C))
```

## Oscylator kwarcowy

**Najdokładniejszy** typ oscylatora — kwarc rezonansowy zamiast LC.

Stabilność: 10-100 ppm (część na milion). Cyfrowe zegary, BIOS, komunikacja.

### Schemat Pierce (z bramką NOT)

```
   X1 ─┬───[NOT]──── out
       │     │
       ●─────●
       │     │
      [C1]  [C2]
       │     │
      GND   GND
       
   typowo: C1 = C2 = 18-22 pF
   X1 = kwarc np. 8 MHz, 16 MHz
   
   Plus opcjonalny rezystor 1 MΩ między we a wy bramki
   (utrzymanie biasu w środku przełączania)
```

### Standardowe kwarce

| Częstotliwość | Zastosowanie |
|---------------|--------------|
| 32,768 kHz | RTC (zegary 1 Hz przez podział) |
| 4 MHz | starsze MCU |
| 8 MHz | popularny dla AVR, PIC |
| 16 MHz | Arduino UNO |
| 20 MHz | szybsze MCU |
| 25 MHz | Ethernet (PHY) |
| 27 MHz | NTSC TV, RC |
| 32 MHz | Bluetooth |

### TCXO / OCXO

- **TCXO** — kwarc kompensowany temperaturowo, ±0,5 ppm
- **OCXO** — kwarc w piecyku 60°C, ±0,01 ppm (drogi, do precyzji)

### Wymiar zegara z 32 kHz

```
32 768 = 2^15
```

Dzielnik 15 stopni daje 1 Hz. Stąd 32768 Hz dla zegarów (klasyczne, do RTC).

## Oscylator OCO (One-shot)

Patrz NE555 monostabilny. Pojedynczy impuls T = 1,1 · R · C po wyzwoleniu.

## Generator funkcyjny — gotowy projekt

### DDS (Direct Digital Synthesis)

Mikrokontroler + DAC + filtr generuje **dowolne kształty**. Tanie moduły z AD9833 (sinus, trójkąt, prostokąt, 0-12,5 MHz) za ~30 zł.

### Generator XR2206

Stary IC, ale wciąż dostępny:
- Sinus + trójkąt + prostokąt
- 0,01 Hz – 1 MHz
- THD < 0,5%
- AM i FM modulacja

Moduły z AliExpress od ~30 zł.

### MAX038

Następca XR2206, lepszy. Trudniej dostać, droższy.

## Generator zegarowy z 555

NE555 jako zegar dla MCU? **Niezalecane** — niska dokładność (5-10%). Lepiej kwarc.

Wyjątek: bardzo proste układy gdzie precyzja nieistotna (np. 4017 sterujący choinką).

## Oscylator audio testowy — 1 kHz

Najprostszy: 555 astabilny.

```
   +9V ──[10k]──●──[10k]──●──[NE555 pin 6/7]
                          │
                         [10nF]── GND
                          
                          NE555 pin 3 (out) ─── do testów
```

Wzór: f = 1,44 / (3 · 10k · 10n) = 4,8 kHz. Dla 1 kHz daj C = 47 nF.

Wyjście prostokątne. Filtr RC (LP, ~3 kHz odcięcia) zaokrągli do "sinusoidalnego" kształtu.

## Generator białego szumu

Złącze BE tranzystora w polaryzacji zaporowej. Pełen zakres szumu (DC do GHz).

```
   +12V ──[100k]── B (BC547 lub 2N3904)
                   │
                   E (FLOAT albo do GND)
                   │
                   ●── sygnał szumu ── przez kondensator do wzmacniacza
```

Wzmacniacz x100 → biały szum audio. Stosowane do testowania filtrów, EMC.

## Generator różowego szumu

Biały szum przez filtr LP 3 dB/oktawę. Brzmi "miękko", używany w audio testach.

## Sprawdzenie oscylatora

### Brak oscylacji

Najczęstsze przyczyny:
- Brak zasilania (sprawdź multimetrem)
- Brak sprzężenia zwrotnego (oscylator nie ma "pomocy" do startu)
- Zbyt mały zysk pętli
- Złe wartości R/C/L
- Zła polaryzacja kondensatorów (jeśli elektrolity)

### Drift częstotliwości

Powody:
- Wpływ temperatury (TCR rezystorów, kondensatorów)
- Stary kondensator (zmiana pojemności)
- Niedostateczne zasilanie

### Nieczystość sygnału (THD)

Powody:
- Zbyt duża amplituda → saturacja
- Brak filtru wyjścia
- Złe zasilanie (brum 50 Hz)

## Wybór oscylatora — checklist

1. **Częstotliwość** — w Hz? kHz? MHz? GHz?
2. **Stabilność** — czy 1% wystarczy, czy potrzebny kwarc (0,01%)?
3. **Kształt** — sinus, prostokąt, trójkąt, dowolny?
4. **Amplituda** — kilka V czy mV?
5. **Zasilanie** — single czy dual?
6. **Cena/komplikacja**

| Aplikacja | Wybór |
|-----------|-------|
| Migający LED | NE555 |
| Sygnał testowy audio | NE555 + filtr lub funkc. gen. |
| Sygnał audio sinusoidalny | Wien op-amp |
| Zegar MCU | kwarc Pierce |
| Lokal RF | Colpitts / Hartley |
| Generator dowolny | DDS (AD9833) lub XR2206 |
| Precyzyjny laboratoryjny | komercyjny gen. funkc. (Rigol, Siglent) |

## Częste błędy

1. **NE555 do precyzyjnego zegara** — niska dokładność.
2. **Kwarc bez kondensatorów obciążenia** — brak oscylacji.
3. **Oscylator audio z brumem** — masa, zasilanie.
4. **RF oscylator bez ekranowania** — zakłóca radia, sąsiadów.
5. **DDS bez filtra Nyquista** — alias częstotliwości.
6. **Generator szumu z brakem wzmacniacza** — sygnał ledwo zauważalny.
