# 08-05: Filtry aktywne

## Po co filtry aktywne

Filtry RC (pasywne) wystarczą do prostych zastosowań, ale mają wady:
- Tłumienie sygnału (są pasywne — nic nie wzmacniają)
- Wpływ obciążenia na charakterystykę
- Trudne nachylenie > 12 dB/oktawę

**Filtr aktywny** = filtr RC + op-amp. Korzyści:
- Wzmocnienie pasma
- Niska impedancja wyjściowa (nie obciąża)
- Dowolne nachylenie i kształt charakterystyki
- Bez dużych cewek (zastąpione op-ampem)

## Typy filtrów

| Typ | Charakterystyka |
|-----|----------------|
| LP (Low Pass) | przepuszcza f < f_c |
| HP (High Pass) | przepuszcza f > f_c |
| BP (Band Pass) | przepuszcza f_low – f_high |
| BS / Notch | tłumi wąskie pasmo (np. brum 50 Hz) |
| All Pass | przepuszcza wszystkie, zmienia tylko fazę |

## Rzędy filtrów

| Rząd | Nachylenie | Liczba RC |
|------|------------|-----------|
| 1 | 6 dB/oktawę | 1 |
| 2 | 12 dB/oktawę | 2 |
| 3 | 18 dB/oktawę | 3 |
| 4 | 24 dB/oktawę | 4 |
| n | 6n dB/oktawę | n |

Filtr 2. rzędu daje dobrą izolację częstotliwości za 1 op-amp.

## Aproksymacje (kształty charakterystyki)

### Butterworth

Najbardziej "płaski" w paśmie przepuszczania. Standardowy.

### Chebyshev

Większe nachylenie, ale tętnienia (ripple) w paśmie. Stosowane gdzie nachylenie krytyczne.

### Bessel

Liniowa faza (ważne w impulsach, audio). Powolniejszy spadek niż Butterworth.

### Eliptyczny (Cauer)

Najszybszy spadek, ale tętnienia w obu pasmach.

W audio: **Bessel** lub **Butterworth**. W telekomunikacji: **Chebyshev** lub eliptyczny.

## Filtr LP 1. rzędu (op-amp)

```
       ┌──[R2]──[C 100n]──┐
       │                  │
       │                  │
   we ─[R1 10k]──── −     │
                      >───●── out
                  +
                  │
                 GND
```

```
A_DC = -R2/R1     (wzmocnienie w paśmie)
f_c = 1 / (2π · R2 · C)
```

Przykład: R1 = 10k, R2 = 10k, C = 16 nF:
```
A = -1
f_c = 1 kHz
```

Nachylenie 6 dB/oktawę (lub 20 dB/dekadę).

## Filtr Sallen-Key LP 2. rzędu

```
                   ┌──[C1]── GND
                   │
   we ──[R1]──┬───[R2]──┬── + ─── 
              │         │       op-amp
              │        [C2]    
              │         │        
              │         ●─── out (sprzężenie zwrotne do C1)
              │         │
              │         ●──── −
              │         │
              │        GND (lub R3 R4 dla wzm. > 1)
```

Standardowo dla Butterwortha 2. rzędu, wzmocnienie = 1:
```
R1 = R2 = R
C1 = 2·C2

f_c = 1 / (2π · R · √(C1·C2))
```

### Tabela wartości dla różnych f_c (Butterworth, A=1)

Przykładowo R = 10 kΩ, podaj C2:

| f_c | C2 | C1 = 2·C2 |
|-----|-----|----------|
| 100 Hz | 113 nF → 100 nF | 220 nF |
| 1 kHz | 11,3 nF → 12 nF | 22 nF |
| 10 kHz | 1,13 nF → 1 nF | 2,2 nF |
| 100 kHz | 113 pF → 100 pF | 220 pF |

Można też używać programów do projektowania filtrów (TI FilterPro, online TI Webench).

## Filtr Sallen-Key HP

Symetryczne — kondensatory zamiast rezystorów i odwrotnie.

```
   we ──[C1]──┬──[C2]──┬── + ──
              │        │  
             [R1]    [R2]
              │        │
              ●        ●── out
                       │
                       ●── −
                       
            +R3/R4 dla wzm.
```

```
f_c = 1 / (2π · √(R1·R2) · C)    (gdy C1=C2=C)
```

## Filtr Band Pass (multiple feedback)

Łączenie LP i HP w jednym — lub topology MFB (Multiple Feedback).

```
         ┌──[R2]──┐
         │         │
   we ─[C1]─[C2]──● ── − ── out
                  │       
                 [R1]      
                  │        
                  ●── + ── GND
```

Filtr środkowoprzepustowy z:
```
f_0 = 1 / (2π · √(R1·R2·C1·C2))
Q = określa szerokość pasma
```

Stosowane: bramkowanie audio (chór, gitara), filtrowanie sygnałów na konkretnych częstotliwościach.

## Filtr Notch (tłumiący)

Notch 50 Hz dla likwidacji brumu sieciowego — niezbędny w pomiarach EKG i precyzyjnych ADC.

### Twin-T notch

```
                   R          R
   we ──[R/2]──[R/2]──── ── R ─── do op-ampa
              │
             [C]
              │  
              ●── (do op-ampa, drugą gałęzią)
              
         [C]──┬──[C]
              │
            [2C]
              │
             GND
```

Wzór:
```
f_notch = 1 / (2π · R · C)
```

Dla 50 Hz: R = 100 kΩ, C = 32 nF (lub R = 1 MΩ, C = 3,18 nF).

Dokładność notch zależy od dopasowania R i C — używaj 1% lub lepszych.

## Filtr audio crossover (zwrotnica)

Filtr 2-3 drożny dla zestawu głośnikowego:
- LP 200 Hz → subwoofer
- BP 200-3000 Hz → midrange
- HP 3000 Hz → tweeter

Klasycznie pasywne (cewki + kondensatory), ale aktywne z op-ampem dają precyzję i można dostroić.

## Filtr anti-aliasing dla ADC

Każdy ADC potrzebuje filtra przed sobą tłumiącego sygnały powyżej f_Nyquist (= f_sample / 2).

Bez filtru → aliasing → "duchy" sygnałów wyższych częstotliwości w paśmie podstawowym.

Typowo: filtr LP 4-8 rzędu z f_c = f_sample / 3 do f_sample / 2,5.

## Filtr aktywny vs pasywny

| | Aktywny | Pasywny |
|-|---------|---------|
| Wymaga zasilania | Tak | Nie |
| Cewki | Nie (do f ~ MHz) | Tak (problem w niskich f) |
| Wzmocnienie | Tak | Nie (zawsze tłumi) |
| Impedancja | Niska wyjściowa | Wysoka, zmienna |
| Zakres f | DC – 1 MHz typowo | DC – GHz |
| Dokładność | Bardzo dobra | Średnia |
| Hałas | Op-amp dodaje | Mało |

W audio i pomiarach DC – MHz: aktywne. W RF, mocy, AC sieciowych: pasywne.

## Praktyczne uwagi

### Wybór op-ampa

- **TL072** — standard audio, JFET, niski hałas
- **NE5532** — premium audio
- **OPA2134** — bardzo dobry audio
- **LM358** — single-supply, podstawowy

GBP musi być **co najmniej 50-100× f_c** filtru.

### Tolerancje

W filtrach przyzwoitych używaj rezystorów 1% i kondensatorów 5%. Kondensatory ceramiczne klasy C0G/NP0 są najlepsze (stałość). Y5V się nie nadaje.

### Stabilność

Filtr aktywny **musi być stabilny**. Zła kompensacja → oscylacje. Stąd zawsze sprawdź:
- Brak oscylacji na wyjściu (oscyloskop)
- Charakterystyka odpowiedzi zgodna z teorią

## Filtr 1. rzędu LP/HP "z głowy"

```
LP:  we ─[R]─┬─ wy
              │
             [C]
              │
             GND
             
HP:  we ─[C]─┬─ wy
              │
             [R]
              │
             GND
             
f_c = 1 / (2π · R · C)
```

R = 1 kΩ, C = 1 μF → f_c = 159 Hz.
R = 10 kΩ, C = 100 nF → f_c = 159 Hz.
R = 1 kΩ, C = 100 nF → f_c = 1,59 kHz.

Wartości łatwe do zapamiętania jako benchmark.

## Wzory szybkie

Dla typowego filtra 1. rzędu RC:

| R (Ω) | C | f_c (Hz) |
|-------|---|----------|
| 1k | 1 μF | 159 |
| 1k | 100 nF | 1,59k |
| 1k | 10 nF | 15,9k |
| 10k | 1 μF | 15,9 |
| 10k | 100 nF | 159 |
| 10k | 10 nF | 1,59k |
| 100k | 100 nF | 15,9 |

**Mnemonik**: f_c [Hz] = 159 000 / (R [kΩ] · C [nF])

## Częste błędy

1. **Niewłaściwy rząd filtru** — 1 rzędu nie obetnie sygnału wystarczająco.
2. **Op-amp za wolny** (niska GBP) — przy wyższych częstotliwościach charakterystyka zaburzona.
3. **Kondensator Y5V** — pojemność zmienia się z napięciem, charakterystyka pływa.
4. **Brak rezystora bias przy AC sprzężeniu** — wejście op-ampa "pływa".
5. **Niska impedancja źródła** dla aktywnego BP — Q maleje.
6. **Brak ferrytowych koraliki** przy zasilaniu op-ampa — zakłócenia wnikają do sygnału.
7. **Filtr LP zbyt blisko Nyquista** — anti-aliasing nieskuteczny.
