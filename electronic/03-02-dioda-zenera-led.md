# 03-02: Dioda Zenera, LED, fotodiody

## Dioda Zenera

### Czym się różni od zwykłej

Dioda Zenera celowo wykorzystuje **pracę w obszarze przebicia zaporowego**. Pracuje w **kierunku zaporowym**, utrzymując stałe napięcie niezależnie od prądu (w pewnym zakresie).

Symbol:

```
   A ──▷|── K       katoda z "haczykiem"
        └           (lub odwróconym L)
```

### Charakterystyka

```
         I
         │
przewod. │      
   ──────┼──────  zaporowe
         │U_Z
       __│__
      /  │
     /   │   ← stabilne U_Z
    /    │
─────────┘
```

W kierunku przewodzenia dioda Zenera działa jak zwykła dioda (U_F = 0,7 V).
W kierunku zaporowym powyżej U_Z (napięcie Zenera) prąd gwałtownie rośnie, ale **napięcie pozostaje stałe**.

### Parametry

| Parametr | Symbol | Wartości |
|----------|--------|----------|
| Napięcie Zenera | U_Z | 2,4 V – 200 V (typowe 3,3-15 V) |
| Tolerancja | ±5% (B) lub ±2% (C) lub ±1% (D) |
| Prąd nominalny | I_ZT | zwykle 5-20 mA |
| Moc | P_Z | 0,4 W (mała), 1 W, 5 W, 50 W |
| Rezystancja dynamiczna | R_Z | mała = lepsza stabilizacja |

### Mechanizmy przebicia

- **Efekt Zenera** — tunelowanie kwantowe (dla U_Z < 5 V). TCR ujemny.
- **Efekt lawinowy** — dla U_Z > 5 V. TCR dodatni.
- W okolicach 5-6 V oba efekty się znoszą — **najlepsza stabilność termiczna** (referencje 5,6 V, 6,2 V).

### Najprostszy stabilizator z Zenerem

```
     +U_we
       │
      [R]   rezystor ograniczający
       │
       ●──── +U_wy = U_Z
       │
      [Z]   dioda Zenera (katodą w górę)
       │
      GND
```

Wartość R:
```
R = (U_we − U_Z) / I

I = I_obc + I_Z

I_Z — prąd przez Zenera (min. 5 mA)
I_obc — prąd obciążenia
```

**Przykład:** U_we = 12 V, U_Z = 5,1 V, I_obc = 20 mA.
```
I = 20 + 5 = 25 mA
R = (12 − 5,1) / 0,025 = 276 Ω
→ E12: 270 Ω
```

Moc na rezystorze:
```
P_R = (U_we − U_Z) · I = 6,9 · 0,025 = 0,17 W
→ rezystor 1/4 W wystarczy
```

Moc na diodzie (gdy obciążenie odłączone):
```
P_Z = U_Z · I = 5,1 · 0,025 = 0,128 W
→ Zener 0,4 W wystarczy
```

### Wady prostego stabilizatora z Zenerem

- Niska sprawność (rezystor stale traci moc)
- Słaba stabilizacja przy dużej zmianie prądu obciążenia
- Nadaje się do małych prądów (< 100 mA)

Dla większych prądów łączy się z tranzystorem (wzmacniacz prądu) lub używa stabilizatorów scalonych (7805, LM317).

### Zastosowania Zenera

- **Stabilizator napięcia** (małe prądy)
- **Napięcie odniesienia** (precyzyjne TL431, REF02)
- **Ochrona przed przepięciem** — Zener równolegle do układu (TVS)
- **Klamra (clamping)** — ograniczenie napięcia sygnału
- **Detekcja napięcia** — np. monitorowanie poziomu baterii

## Dioda LED (Light Emitting Diode)

### Zasada działania

Specjalny rodzaj złącza PN z półprzewodnikiem o bezpośredniej rekombinacji nośników. Energia rekombinacji jest emitowana jako foton (światło).

Materiał półprzewodnika determinuje kolor:

| Materiał | Kolor | U_F typowe |
|----------|-------|-----------|
| GaAs (gal-arsen) | podczerwień | 1,2-1,4 V |
| GaAsP | czerwony | 1,8-2,0 V |
| GaP | żółty, zielony | 2,1-2,2 V |
| AlGaInP | super czerwony, pomarańczowy | 2,0-2,5 V |
| InGaN | niebieski, biały, zielony | 3,0-3,4 V |
| AlGaN | UV | 4,5-7 V |

**Biały LED** = niebieska LED + fosfor (przetwarza część światła na żółty), połączenie daje białe.

### Parametry

| Parametr | Symbol | Typowe |
|----------|--------|--------|
| Napięcie przewodzenia | U_F | 1,8-3,4 V |
| Prąd znamionowy | I_F | 20 mA (standard 5 mm), 100-1000 mA (mocy) |
| Maksymalny prąd impulsowy | I_FM | 2-3× I_F |
| Napięcie zaporowe | U_R | 5 V (bardzo niskie!) |
| Strumień świetlny | Φ | mlm – tysiące lm |
| Kąt świecenia | θ | 5° – 180° |

### Dobór rezystora ograniczającego

LED MUSI mieć rezystor szeregowo. Bez niego prąd lawinowo rośnie po przekroczeniu U_F i LED pada.

```
R = (U_we − U_F) / I_F
```

**Przykład:** LED czerwona U_F = 2 V, I_F = 20 mA, zasilanie 5 V.
```
R = (5 − 2) / 0,02 = 150 Ω
P_R = 3 · 0,02 = 0,06 W → 1/8 W rezystor
```

**Przykład 2:** Niebieski LED U_F = 3,2 V, I_F = 20 mA, zasilanie 12 V.
```
R = (12 − 3,2) / 0,02 = 440 Ω → 470 Ω
P_R = 8,8 · 0,02 = 0,176 W → 1/4 W
```

### Łączenie LED

**Szeregowo** — sumują się U_F, prąd ten sam. Bezpieczne, jeden rezystor wystarczy. Maksymalna liczba ograniczona napięciem zasilania.

```
12 V zasilanie, 3 białe LED po 3,2 V = 9,6 V
R = (12 − 9,6) / 0,02 = 120 Ω
```

**Równolegle** — to samo U, ale prądy nierównomiernie rozłożone (każdy LED ma trochę inne U_F). Trzeba dawać **rezystor na każdy LED osobno**:

```
+ ─[R1]─ LED1 ─ GND
+ ─[R2]─ LED2 ─ GND
+ ─[R3]─ LED3 ─ GND
```

### Sterowanie LED dużej mocy

LED 1-100 W wymaga **prądu stałego** (constant current driver), nie zasilania napięciem. Powód:
- U_F dryfuje z temperaturą (−2 mV/°C)
- Bez sterowania prądowego LED się rozgrzewa, U_F maleje, prąd rośnie — błędne sprzężenie (thermal runaway)

Sterowniki CC: LM3914, AL8805, sterowniki PWM, scalone do paskó LED.

### LED RGB

Trzy struktury w jednej obudowie. Cztery wyprowadzenia. Dwie konfiguracje:
- **Common Anode** — wspólny plus, każda LED ma swoją katodę
- **Common Cathode** — wspólny minus, każda LED ma swoją anodę

### LED adresowalne (WS2812, APA102)

Każda LED ma wbudowany kontroler. Łańcuch RGB sterowany jednym przewodem cyfrowym. "Neopixele". Wymagają precyzyjnego timingu (WS2812) lub SPI (APA102).

## Fotodioda

### Działanie

Złącze PN naświetlane fotonami → generacja par elektron-dziura → prąd w kierunku zaporowym proporcjonalny do oświetlenia.

### Tryby pracy

- **Tryb fotowoltaiczny** (PV) — bez zasilania, generuje napięcie (jak panele słoneczne, ogniwa)
- **Tryb fotoprzewodzący** (PC) — w polaryzacji zaporowej, prąd ↑ z oświetleniem

### Parametry

- Czułość spektralna (zakres długości fal)
- Czas odpowiedzi (ns – μs)
- Prąd ciemny (przy braku światła)

### Zastosowania

- Czujniki światła
- Odbiorniki podczerwieni (IR pilot)
- Optokoplery (galwaniczne odsprzężenie)
- Liniarki, enkodery
- Łącza światłowodowe

## Fototranzystor

To fotodioda + tranzystor scalone w jednym. Sygnał jest wzmocniony (h_FE) w stosunku do fotodiody. Większa czułość, wolniejsza odpowiedź.

## LDR (fotorezystor)

Nie jest typowo półprzewodnikiem PN, ale działa fotoelektrycznie. CdS lub CdSe — rezystancja maleje z oświetleniem. Wolny (sekundy). Tani. Stosowany w sterowaniach oświetlenia automatycznego.

## Optokopler (optoizolator)

Para LED + fotodetector w jednej obudowie, izolowane od siebie. Sygnał elektryczny → światło → sygnał elektryczny, ale strony są galwanicznie rozdzielone.

Typowy: 4N25, PC817, 6N137. Napięcia izolacji 2,5-7,5 kV.

Zastosowanie: bezpieczne sterowanie wysokim napięciem z mikrokontrolera, izolacja USB, izolacja w sieci automatyki przemysłowej.

## Wybór - praktyka

### Dla Zenera

1. Jakie napięcie referencyjne potrzebne?
2. Jaki prąd obciążenia (jeśli > 100 mA, użyj stabilizatora scalonego)?
3. Jaka moc dyssypacji Zenera w najgorszym przypadku?

### Dla LED

1. Kolor i jasność (mcd lub lm)
2. Prąd znamionowy
3. Napięcie zasilania → dobór R
4. Kąt świecenia
5. Obudowa (5 mm, 3 mm, SMD, mocy)

### Dla fotodetektora

1. Zakres spektralny (widzialny? IR?)
2. Czas reakcji
3. Czułość
4. Tryb pracy (PV / PC)

## Częste błędy

1. **LED bez rezystora** = ostatni raz świeci.
2. **Zener na zasilaniu, gdzie potrzebny stabilizator** — rezystor się grzeje.
3. **LED na 230 V przez kondensator** — działa, ale **niebezpieczne** (galwaniczne połączenie z siecią).
4. **Odwrotna polaryzacja LED** — U_R tylko ~5 V, dioda padnie przy szczycie 325 V sieci.
5. **Wspólny rezystor na 3 LED równolegle** — jedna LED z mniejszym U_F bierze więcej prądu, padnie pierwsza, potem reszta lawinowo.
