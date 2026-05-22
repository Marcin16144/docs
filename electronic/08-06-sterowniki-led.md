# 08-06: Sterowniki LED

## Po co sterownik

LED to **dioda**. Charakterystyka U-I jest stroma — niewielki wzrost napięcia powyżej U_F daje **gwałtowny wzrost prądu**. Bez ograniczenia prądu LED spali się natychmiast.

Stąd LED **musi** mieć element ograniczający prąd:
- Rezystor (prosty, mało wydajny)
- Tranzystor jako źródło prądowe (lepiej)
- Sterownik scalony (najlepiej dla LED dużej mocy)

## Sposób 1: Rezystor szeregowy

Najprostszy. Klasyczny dla LED sygnalizacyjnych.

```
   +V ──[R]──▷│── GND
              LED
              U_F, I_F
```

### Wzór

```
R = (V_zasilanie − U_F) / I_F
P_R = (V − U_F) · I_F
```

### Tabela szybkich wartości

LED 2 V (czerwona, żółta) / 20 mA:

| V zasilanie | R | P_R |
|-------------|---|-----|
| 5 V | 150 Ω | 60 mW (1/8 W) |
| 9 V | 330 Ω | 140 mW (1/4 W) |
| 12 V | 470 Ω | 200 mW (1/4 W) |
| 24 V | 1,1 kΩ | 440 mW (1/2 W) |

LED 3,2 V (niebieska, biała) / 20 mA:

| V zasilanie | R | P_R |
|-------------|---|-----|
| 5 V | 100 Ω | 36 mW |
| 9 V | 290 Ω → 330 Ω | 120 mW |
| 12 V | 440 Ω → 470 Ω | 180 mW |
| 24 V | 1,04 kΩ → 1 kΩ | 420 mW |

### Wady rezystora

- **Niska sprawność** — moc tracona w rezystorze (do 60% mocy całkowitej)
- **Prąd zależy od V** — jeśli zasilanie pływa (np. bateria), prąd też
- Dla LED mocy (1-100 W) rezystor wymagałby ogromnej rocy

### Kiedy używać

- LED sygnalizacyjne (Power-on, status)
- Małe latarki na baterię
- Wskaźniki na panelu

## Sposób 2: Sterownik z BJT (źródło prądowe)

Tani sterownik dla LED do ~1 W. Niezależny od napięcia zasilania.

```
   +V ──[Rb]──┬─── E
               │    │
               B ──[Q1 BJT PNP]
               │    │
              [R_sense]    
               │    
               C ──── do LED
                       │
                       ▷│ LED
                       │
                      GND
```

Lub klasyczna konfiguracja z dwoma tranzystorami:

```
   +V ────────●─── E (Q1)
              │
             [R_set]
              │
              C ── Q1
              │
              ●── LED 1
              │
              ●── LED 2 (szeregowo)
              │
              ●── B (Q2)
              │
              ▷│ (B-E Q2)
              │
              E (Q2) ── GND
              
   Q1, Q2: BC557 (PNP) np.
```

### Wzór

Q2 włącza się gdy U_BE ≈ 0,7 V → I_LED · R_set = 0,7 V → 
```
I_LED = 0,7 / R_set
```

### Tabela R_set

| I_LED | R_set |
|-------|-------|
| 20 mA | 35 Ω → 33 Ω |
| 50 mA | 14 Ω → 15 Ω |
| 100 mA | 7 Ω → 6,8 Ω |
| 350 mA | 2 Ω |

### Zalety

- Prąd stały niezależny od V_zasilania
- Niezależny od ilości LED w szeregu (do limitu V)
- Tani

### Wady

- Wymagana V_zasilania > V_LED + 1-2 V
- Tracona moc na Q1: P = (V_zasilania − V_LED_total) · I

## Sposób 3: LM317 jako źródło prądowe

Patrz [08-01](08-01-stabilizatory-uklady.md). LM317 utrzymuje 1,25 V między OUT a ADJ.

```
   +V ── IN [LM317] OUT ── R_set ──┬── LED ──┬── ADJ
                                    │         │
                                    │         GND
```

```
I = 1,25 / R_set
```

R_set = 3,6 Ω → I = 350 mA (LED 1 W).
R_set = 1,8 Ω → I = 700 mA (LED 3 W).

Sprawność liniowa, max 1,5 A. Dla LED 3-5 W z radiatorem.

## Sposób 4: Sterowniki scalone (CC)

Dla LED dużej mocy (1-50 W) używaj dedykowanych sterowników.

### Liniowe (linear regulator dla LED)

#### CL2N3 (ON Semiconductor)

- 2-pinowy, bez dodatkowych elementów
- I_LED stały (np. 20, 30 mA wersje)
- Wystarczy podłączyć do zasilania
- Cena: ~1 zł
- Idealne dla pasków LED, sygnalizacji

```
   +V (10-90V) ──[CL2N3 20mA]── ▷│ LED ── GND
```

#### BCR401U (Infineon)

- SOIC, regulowany prąd 10-350 mA przez R_set
- Bardzo wydajny dla pasków LED
- Cena: ~3 zł

### Impulsowe (buck driver)

Dla większych mocy — sterownik buck dający stały prąd.

#### MP1584, MP4565

- 1-3 A, do 36 V wejścia
- Wymaga zewnętrznej cewki + dioda Schottky
- Sprawność > 90%

#### LM3414 (TI)

- Dedykowany LED driver, do 1 A
- Niska liczba elementów
- Sprawność > 90%

#### Gotowe moduły CC

AliExpress: "LED driver buck constant current" — moduły 350 mA / 700 mA / 1 A / 3 A za ~10-30 zł. Wejście 7-40 V, regulowany prąd.

## LED z PWM — sterowanie jasnością

LED nie da się "regulować analogowo" — zmiana prądu zmienia kolor (zwłaszcza niebieskie i białe). Standardowo używamy **PWM**.

### Częstotliwość PWM

- Zbyt niska (< 100 Hz) — migotanie widoczne
- 200-1000 Hz — niewidoczne dla oka, ale kamera złapie
- > 5 kHz — bezpieczne dla wszystkich

Mikrokontrolery zwykle dają PWM 500 Hz - 50 kHz.

### Schemat z MOSFETem (logic-level)

```
   +12V ──┬── LED 1
          │
          ●── LED 2
          │
          ●── LED 3 (szeregowo)
          │
          ●─── R_sense (źródło prądowe)
          │
          D
          │
         [Q MOSFET, np. AO3400]
          │
          G ── PWM z MCU (przez R 100 Ω)
          │
          S
          │
         GND
```

### Sterownik PWM z 555

NE555 astabilny + duty cycle regulowany potencjometrem (z diodą jak w 04-03). Tani regulator jasności bez MCU.

## Paski LED (LED strips)

### 12 V (zwykłe)

Pasek RGB 5050 / 2835. Trzy diody w segmentach + rezystor 150-200 Ω → segment 3-LED. Sterowane PWM z drivera ULN2003 (transistor array).

```
   +12V ── pasek LED ── do drivera
   GND ── pasek LED
   R, G, B ── kanały (PWM z MCU)
```

### 24 V (przemysłowe)

Większa moc na metr, lepsze do oświetlenia akwaria / pokoju.

### Adresowalne WS2812 (Neopixele)

Każda LED RGB z wbudowanym kontrolerem. Sterowane pojedynczym pinem cyfrowym, dowolny kolor każdej LED.

```
   +5V ── do każdej LED
   GND
   DI (data in) ── z MCU (np. Arduino, ESP32)
```

Wymaga **precyzyjnego timingu** (0,4 μs / 0,85 μs impulsy). Stąd FastLED, NeoPixel libraries.

### Adresowalne APA102 (DotStar)

Jak WS2812, ale **SPI** (data + clock). Łatwiejsze timing, większa szybkość, droższe.

## LED dużej mocy (1-100 W)

### LED 1 W

- Napięcie U_F ~3,2 V (biała, niebieska)
- Prąd nominalny 350 mA
- Wymaga radiatora (mały aluminiowy)

### LED 3 W

- U_F ~3,4 V
- I = 700 mA
- Radiator średni

### LED 10 W

- "COB" (Chip-on-Board) — wiele chipów w jednej obudowie
- U_F = 9-12 V (3 chipy szeregowo)
- I = 900 mA – 1 A
- Duży radiator + opcjonalnie wentylator

### LED 50-100 W

- COB lub matryca diod
- U_F = 30-36 V
- I = 1,5-3 A
- Wymagane chłodzenie aktywne (wentylator)

### Sterowniki dla LED dużej mocy

Gotowe sterowniki impulsowe AC→DC stałego prądu:
- "Driver 30W 900mA" — z AC 230 V, ~30 zł
- Mean Well LPC, LDD, HLG (profesjonalne, droższe)
- Sprawność 85-90%

## Termiczna ochrona LED

LED dużej mocy musi mieć:

1. **Radiator** o R_θ < (T_J_max − T_amb) / P_LED
2. **Pasta termoprzewodząca** lub silikonowa podkładka
3. **Czujnik temperatury** (NTC) z odcięciem sterownikiem przy > 60-70°C

LED **bez chłodzenia** spali się w 30 sekund.

## Częstotliwość PWM a charakter światła

- Niska PWM (< 1 kHz) — migotanie widoczne na nagraniu
- Wysoka PWM (> 20 kHz) — możliwy hałas elektromagnetyczny (cewki w sterowniku świszczą)
- Stałoprądowe (CC bez PWM) — bez migotania, ale nie regulowane

W audiowizualnym / fotografii wybieraj CC lub wysoką PWM.

## Pomiary i debug

### Pomiar prądu LED

Multimetr szeregowo (przerywając obwód). LUB **rezystor pomiarowy** + woltomierz:
```
I_LED = U_R / R_sense
```

### Pomiar U_F

Multimetr w trybie diody. Wyświetli spadek napięcia.

### Termowizja

Po godzinie pracy: T_LED powinno być < 60°C. Jeśli wyżej — niedostateczne chłodzenie.

## Częste błędy

1. **LED bez rezystora** — pali się natychmiast.
2. **Niewystarczająca moc rezystora** — rezystor się grzeje, w skrajnym przypadku zapala.
3. **Łączenie LED równolegle bez rezystorów** — jedna z mniejszym U_F bierze cały prąd.
4. **LED dużej mocy bez radiatora** — śmierć w 30 sek.
5. **Brak diody freewheel** przy paskach z drugą stroną indukcyjną.
6. **PWM zbyt niska** — migotanie, męczy oczy.
7. **Sterownik CC dla LED z PWM modulowany** — może powodować pulsowanie z f_PWM.
8. **Zła polaryzacja** — LED zaporowo, U_R LED zwykle tylko 5 V → przebicie przy szczycie zasilania.
9. **Sterownik buck bez kondensatorów wejściowych** — niestabilność, oscylacje.
10. **Mieszanie LED różnych producentów szeregowo** — różne U_F, jasność, kolor.

## Podsumowanie wyboru

| Aplikacja | Sterownik |
|-----------|-----------|
| Sygnalizacja, status | rezystor szeregowy |
| Pasek LED 12 V | rezystor lub gotowy zasilacz 12 V |
| LED 1 W (latarka) | LM317 CC lub buck driver |
| LED 10 W (oświetlenie) | dedykowany buck driver |
| LED COB 50 W+ | sterownik AC→CC (Mean Well) |
| Adresowalne (efekty) | WS2812 + ESP32 / Arduino |
| Wielokolorowe RGB | sterownik z 3× PWM (z MCU) |
