# 08-07: Sterowanie silnikiem DC

## Typy silników

### Silnik DC szczotkowy

Klasyczny. Wirnik z uzwojeniem, komutator + szczotki, magnesy stałe na statorze.

- Tani, niezawodny
- Łatwe sterowanie (napięcie → prędkość)
- Iskrzenie szczotek (EMI, zużycie)
- 200 W – 10 kW

### Silnik bezszczotkowy (BLDC)

Bez komutatora i szczotek. Sterowanie elektroniczne (ESC — Electronic Speed Controller).

- Wyższa sprawność
- Dłuższa żywotność
- Niewielkie EMI
- Wymaga sterowania (3 fazy)
- 50 W – 100 kW (drony, EV, hulajnogi)

### Silnik krokowy (stepper)

Wirnik obraca się "krokami" (1,8° = 200 kroków/obrót typowo). Kontrolowany precyzyjnie.

- Precyzyjna pozycja (drukarki 3D, CNC)
- Bez sprzężenia zwrotnego
- Wymaga sterownika fazowego (DRV8825, A4988)

### Silnik AC indukcyjny

Sieciowy, prosty. Sterowany falownikiem (VFD) do regulacji prędkości.

W tym rozdziale skupimy się na **DC szczotkowym** — najczęstszym w hobby.

## Podstawowe sterowanie

### Jeden kierunek, włącz/wyłącz

```
   +V (silnik) ──┬── silnik DC ──┬── D (MOSFET N)
                  │                │
                  │              G ──[R 100Ω]── sygnał
                  │                │
                  ▷│ D1            S ──── GND
                  │
                  ●── (anoda do plusa) — dioda freewheel
                  │
                  GND
```

### Dioda freewheel — OBOWIĄZKOWA

Silnik to **indukcyjność**. Przy wyłączeniu MOSFETa cewka generuje wysokie napięcie wsteczne (samoindukcja).

Bez diody → spike może osiągnąć 100-500 V → MOSFET pada.

Dioda freewheel:
- Schottky (szybsza, niższy V_F) — dla małych silników
- Ultra-fast (UF4007) — dla większych
- Anoda na D MOSFETa (lub minus silnika), katoda na +V

Niektóre MOSFETy mają wbudowaną body diode wystarczającą, ale dodanie zewnętrznej daje bezpieczeństwo.

## Regulacja prędkości — PWM

Silnik DC reaguje na **średnią moc**. PWM = szybkie włącz/wyłącz → wirnik widzi średnie napięcie.

```
0%   PWM = 0% — silnik stoi
50%  PWM = silnik na pół mocy
100% PWM = silnik pełna moc
```

### Częstotliwość PWM

| f | Charakterystyka |
|---|----------------|
| < 100 Hz | silnik "wibruje", drży |
| 200-1000 Hz | gładkie, ale słychać "świst" |
| 1-5 kHz | typowe w sterownikach DC |
| 20+ kHz | poza zakresem słuchu, ale więcej strat przełączania |

Dla małych silników (modele): 2-5 kHz. Duże silniki: 10-20 kHz.

### Wybór MOSFETa do PWM

- **R_DS(on)** niskie (niska strata przewodzenia)
- **Q_g** niskie (szybkie przełączanie)
- **V_DSS** ≥ 2× V_silnika (z zapasem na spike'i)
- **I_D** ≥ 2× prądu nominalnego silnika
- **Logic level** dla MCU 5 V / 3,3 V (np. AO3400, IRLB3034)

## H-Bridge — dwa kierunki obrotów

Aby zmieniać kierunek obrotu silnika DC, używamy **mostka H** (4 tranzystory).

```
            +V
             │
        ●────┴────●
        │         │
       Q1        Q2     (high side - PMOS lub N z bootstrap)
        ●────●────●
             │
           silnik
             │
        ●────●────●
        │         │
       Q3        Q4     (low side - NMOS, standardowe)
        ●────┬────●
             │
            GND
```

### Stany pracy

| Q1 | Q2 | Q3 | Q4 | Efekt |
|----|----|----|----|-------|
| ON | OFF | OFF | ON | obroty w prawo |
| OFF | ON | ON | OFF | obroty w lewo |
| OFF | OFF | OFF | OFF | wybieg (free running) |
| OFF | OFF | ON | ON | **hamowanie** (zwarcie) |
| ON | ON | OFF | OFF | hamowanie (z +V) |

### Krytyczne: shoot-through

**NIGDY** Q1+Q3 jednocześnie ani Q2+Q4 — to zwarcie zasilania przez tranzystory!

Stąd potrzebny **dead time** (martwy czas) między przełączaniami — czas, gdy oba tranzystory danej "strony" są wyłączone. Standardowo 100-1000 ns.

### Sterowanie z MCU

```
                      MCU
                       │
   PWM ──── ENA ─────┐
                      │
   DIR ─────────────●  driver H-bridge
                      │
                      ●
                      │
              ┌───────┴───────┐
              │ Q1  Q2  Q3 Q4 │
              └───────┬───────┘
                      │
                  silnik
```

## Gotowe sterowniki H-bridge

### L298N (klasyczny)

- **2× H-bridge** w jednej obudowie
- 2 A na kanał, 35 V max
- Duże napięcie nasycenia (ok. 1,5-2,5 V) → straty mocy
- Wymaga radiatora
- Cena: ~10 zł

```
   Vss (5V) ── do logiki
   Vs (12V) ── do silnika
   ENA, IN1, IN2 ── silnik A
   ENB, IN3, IN4 ── silnik B
   OUT1, OUT2 ── silnik A
   OUT3, OUT4 ── silnik B
```

**Wady**: niska sprawność. Dla nowoczesnych projektów lepiej DRV8833 lub TB6612.

### DRV8833 / DRV8835 (Texas Instruments)

- **2× H-bridge** lub **1× pełny H-bridge**
- 1,5 A na kanał (3 A peak)
- MOSFETy zamiast BJT → niskie straty
- 2,7-10,8 V
- Małe, SMD
- Cena: ~5 zł

Idealny do **małych robotów, modeli**.

### TB6612FNG

- 1,2 A na kanał, 3,2 A peak
- 2,5-13,5 V
- Niskie straty, MOSFETy
- DIP-ready (na breakouts)
- Cena: ~8 zł

Bardzo popularny dla Arduino, mikrokontrolerów.

### BTS7960

- **Pojedynczy H-bridge** mocny
- 43 A peak (z radiatorem)
- 5,5-27 V
- Sterowanie PWM
- Moduły z AliExpress: "BTS7960 motor driver", ~20-40 zł

Dla **dużych silników** (robotyka, modeli RC).

### IBT-2 (dual BTS7960)

Mostek H pełny z dwoma BTS7960. Do 43 A. Idealny do napędu rowerów elektrycznych, hulajnóg.

## Sterowanie PWM z Arduino — przykład

```cpp
// L298N na Arduino UNO
const int ENA = 9;   // PWM pin
const int IN1 = 7;
const int IN2 = 8;

void setup() {
    pinMode(ENA, OUTPUT);
    pinMode(IN1, OUTPUT);
    pinMode(IN2, OUTPUT);
}

void forward(int speed) {
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    analogWrite(ENA, speed);   // 0-255
}

void backward(int speed) {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    analogWrite(ENA, speed);
}

void stop() {
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
}
```

## Pomiar prądu silnika

### Rezystor pomiarowy (shunt)

Rezystor mały (0,1-0,01 Ω) szeregowo. Pomiar spadku napięcia.

```
   silnik ── shunt ── GND
              │
              ●── INA240, INA219 (current sense amplifier)
              │
              ADC MCU
```

INA240 z gain 20×, R_shunt = 0,01 Ω, max I = 5 A:
```
U = I · R = 5 · 0,01 = 50 mV
U_out_amp = 50 · 20 = 1 V (ADC-friendly)
```

### Czujnik Halla

Cęgi na przewodzie, bez przerywania. ACS712, ACS758 — 5/20/30/50/100 A wersje.

Zastosowanie: ochrona prądowa, kontrola momentu, BMS dla baterii.

## BEMF — kontrola prędkości bez enkodera

Silnik DC generuje **napięcie przeciwskuteczne (Back EMF)** proporcjonalne do prędkości obrotu. Można je zmierzyć i sterować zamkniętopętlowo.

W trybie wybiegu (PWM OFF) napięcie na zaciskach silnika = BEMF. Mierzymy je, używamy w PID.

Klasyczne sterowniki BLDC bezpodłuktorowe (sensorless ESC) używają BEMF do wykrycia położenia wirnika.

## Sterowanie servo (modele)

Servo to silnik DC + przekładnia + potencjometr + sterownik wewnętrzny.

Sterowanie: **impuls PWM 50 Hz**, szerokość 1-2 ms = pozycja 0-180°.

```
T = 20 ms (50 Hz)
1 ms impuls = 0°
1,5 ms = 90° (środek)
2 ms = 180°
```

Większość MCU (Arduino, ESP32) ma bibliotekę Servo.

## Sterowanie krokowym

Wymaga sterownika dwukierunkowego dla każdej fazy. **A4988**, **DRV8825**, **TMC2208**:

- 2 piny: STEP (impuls = jeden krok) + DIR (kierunek)
- Mikrokrok (1/8, 1/16, 1/32) → mniej hałasu, gładsza praca
- Ograniczenie prądu potencjometrem

Standard w drukarkach 3D, CNC. Sterowane MCU lub procesorem dedykowanym (Marlin, GRBL).

## Zabezpieczenia

### Hardware

1. **Bezpiecznik prądowy** — F 5A, 10A dla silnika
2. **Dioda freewheel** — zawsze
3. **TVS na zasilaniu** — pochłania spike'i
4. **Kondensator 1000 μF na +V** — bufor energii
5. **Wyłącznik bezpieczeństwa (E-stop)** — odcina zasilanie

### Software

1. **Soft start** — stopniowy wzrost PWM (uniknięcie szczytów prądu)
2. **Limit prądowy** — odcięcie przy przekroczeniu
3. **Watchdog** — restart jeśli MCU się zawiesi
4. **Termiczna ochrona** — czujnik temp drivera

## EMI i filtrowanie

Silnik szczotkowy generuje ogromnie EMI. Środki ochrony:

1. **Kondensator 100 nF / 100 V** na zaciskach silnika (z każdej strony)
2. **Kondensator między każdym zaciskiem a obudową** (1 nF)
3. **Filtr LC** w zasilaniu silnika
4. **Ekranowanie przewodów silnika**
5. **PWM z spread spectrum** (rozpraszanie częstotliwości)

Bez filtracji silnik wybija WiFi, Bluetooth, radio.

## Wybór sterownika — checklist

| Aplikacja | Sterownik |
|-----------|-----------|
| Mały silnik 5V (zabawka) | DRV8835 |
| Silnik 6-12V do 1,5A (mały robot) | DRV8833, TB6612 |
| Silnik 12-24V do 5A | L298N (basic) lub BTS7960 |
| Silnik mocy 24-40V do 20A (hulajnoga) | IBT-2 (dual BTS) |
| Silnik 48V+ do 100A (EV) | dedykowany ESC |
| Servo modelarski | gotowy (wewnętrzny driver) |
| Krokowy drukarka 3D | DRV8825, TMC2208 |
| BLDC dron | ESC z protokołem (PWM 50 Hz lub DShot) |

## Częste błędy

1. **Brak diody freewheel** — driver się pali.
2. **Niewystarczająca moc tranzystorów** — przegrzanie, awaria.
3. **Shoot-through** w H-bridge — natychmiastowa śmierć driverów.
4. **PWM zbyt niska** — silnik wibruje, hałasuje.
5. **Brak filtracji EMI** — zakłóca wszystko wokół.
6. **Bez bezpiecznika** — zwarcie wypala instalację.
7. **Silnik pod prąd bez chłodzenia drivera** — termiczne ucinanie.
8. **Pominięcie ograniczenia prądu** dla silników krokowych — uszkodzenie cewek.
9. **Soft start brak** — szczyty prądu wybijają zasilacz.
10. **Sterowanie servo zwykłym PWM** — wymagany dokładny impuls 1-2 ms.
