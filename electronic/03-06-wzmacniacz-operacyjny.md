# 03-06: Wzmacniacz operacyjny (op-amp)

## Czym jest op-amp

**Wzmacniacz różnicowy** o bardzo dużym wzmocnieniu napięciowym (10⁵-10⁶), wysokiej impedancji wejścia i niskiej wyjścia. Podstawowy "klocek" elektroniki analogowej.

Nazwa "operacyjny" — bo pierwotnie służył do realizacji operacji matematycznych w komputerach analogowych (dodawanie, całkowanie, różniczkowanie).

### Symbol

```
         +V (zasilanie +)
            │
    + ───┐  │
         │\ │
         │ \│
         │  >─── wyjście (Vout)
         │ /
         │/
    − ───┘
            │
         -V (lub GND)
```

- **+** (wejście nieodwracające, non-inverting)
- **−** (wejście odwracające, inverting)
- **Vout** wyjście
- **+V, -V** zasilanie (jednonapięciowe lub symetryczne)

### Podstawowa zasada

```
Vout = A · (V+ − V−)

A — wzmocnienie open-loop (typowo 100 000+)
```

Czyli wyjście to wzmocniona różnica napięć wejść. Praktycznie zawsze stosujemy ze sprzężeniem zwrotnym — wtedy wzór upraszcza się dramatycznie.

## "Złote zasady" op-ampa (z ujemnym sprzężeniem zwrotnym)

1. **Wejścia mają takie samo napięcie** — V+ = V- (op-amp dąży do tego stanu)
2. **Wejścia nie pobierają prądu** — I_in ≈ 0

To dwa założenia idealizacji. W praktyce trzymane są z dużą dokładnością.

## Parametry rzeczywistego op-ampa

| Parametr | Symbol | Idealnie | Typowo |
|----------|--------|----------|--------|
| Wzmocnienie open-loop | A_OL | ∞ | 100 000 – 10 000 000 |
| Impedancja wejścia | Z_in | ∞ | 10⁶-10¹² Ω |
| Impedancja wyjścia | Z_out | 0 | 10-100 Ω |
| Pasmo (GBP) | f_T | ∞ | 1 MHz – 100 MHz |
| Prąd polaryzacji wej. | I_B | 0 | nA – pA |
| Offset napięciowy | V_OS | 0 | μV – mV |
| Slew rate | SR | ∞ | 0,5-100 V/μs |
| Zakres CMRR | CMRR | ∞ | 70-120 dB |

### Slew Rate

Maksymalna szybkość zmiany napięcia wyjścia. Ogranicza pasmo dla dużych amplitud.

LM741: SR = 0,5 V/μs → niemożliwe wyjście 10 V/100 kHz (potrzebuje 6,28 V/μs).

### GBP — Gain-Bandwidth Product

Iloczyn wzmocnienia i pasma jest stały. Stąd:

- Wzmocnienie 1 → pasmo = GBP
- Wzmocnienie 100 → pasmo = GBP / 100

LM358 ma GBP ≈ 1 MHz. Przy wzmocnieniu 10 → maks. f = 100 kHz.

## Popularne op-ampy

| Model | Typ | Zasilanie | GBP | SR | Cena |
|-------|-----|-----------|-----|-----|------|
| LM741 | klasyk | ±5 do ±18 V | 1 MHz | 0,5 V/μs | grosze |
| LM358 / LM324 | single-supply | 3-32 V | 1 MHz | 0,5 V/μs | grosze |
| TL072 / TL082 | JFET, audio | ±5 do ±18 V | 3 MHz | 13 V/μs | tanie |
| TL081 | JFET single | jw | jw | jw | tani |
| NE5532 | audio premium | ±5 do ±18 V | 10 MHz | 9 V/μs | nieco droższy |
| OPA2134 | premium audio | ±5 do ±15 V | 8 MHz | 20 V/μs | drogi |
| LM4562 | very low noise | jw | 55 MHz | 20 V/μs | drogi |
| MCP6002 | rail-to-rail | 1,8-6 V | 1 MHz | 0,6 V/μs | tani |
| LM393 | komparator | jw | — | — | tani |

## Konfiguracje podstawowe

### 1. Wtórnik napięciowy (voltage follower / buffer)

```
   in ──┬─── + 
        │    >─── out (Vout = Vin)
        │   −
        │   │
        └───┴
```

Wzmocnienie = 1. Stosowany jako bufor — wysoka impedancja wejścia, niska wyjścia. **Najczęstsze użycie op-ampa.**

### 2. Wzmacniacz nieodwracający

```
   in ──── + 
            >─── out
       ┌── −
       │   │
      [R2] │
       │   │
      GND  │
       │   │
      [R1] │
       │   │
       ●───┘
```

Wzmocnienie:
```
A = 1 + R1/R2
```

Wejście wysokoimpedancyjne, sygnał w fazie.

### 3. Wzmacniacz odwracający

```
        ┌──[R_f]──┐
        │         │
  in ──[R_in]──── ─       
              │   >─── out
              + 
              │   
             GND
```

Wzmocnienie:
```
A = − R_f / R_in
```

Sygnał odwrócony (180°). Impedancja wejściowa = R_in.

### 4. Sumator (mixer)

Wiele wejść równolegle z osobnymi rezystorami:

```
   in1 ──[R1]──┐
   in2 ──[R2]──●──── ─
   in3 ──[R3]──┘     >── out
                +
               GND
   
   sprzężenie zwrotne: out ─[Rf]─ punkt sumujący
```

```
Vout = −(Vin1·Rf/R1 + Vin2·Rf/R2 + Vin3·Rf/R3)
```

Stosowane w mikserach audio.

### 5. Wzmacniacz różnicowy (instrumentation)

Z dwoma wejściami, wzmacnia ich różnicę, tłumi sygnał wspólny (common mode).

```
Vout = (R2/R1) · (V2 - V1)
```

Klasyczna konfiguracja używa **trzech op-ampów** lub gotowych ICs (INA126, AD623).

### 6. Komparator

Bez sprzężenia zwrotnego. Wyjście = +V_sat lub -V_sat zależnie od relacji V+ i V-.

```
V+ > V-  →  Vout = +V_sat
V+ < V-  →  Vout = -V_sat
```

LM393 jest dedykowanym komparatorem (z otwartym kolektorem).

### 7. Komparator z histerezą (Schmitt trigger)

Dodatkowe sprzężenie zwrotne dodatnie. Daje histerezę — odporność na szumy.

```
V_TH_high = V_ref · (1 + R1/R2) + Vout_min · R1/R2
V_TH_low  = V_ref · (1 + R1/R2) + Vout_max · R1/R2
```

### 8. Integrator

```
       ┌──[C]──┐
       │       │
  in ─[R]──────●── ─
                  >─── out (całka po sygnale)
              +
             GND
```

```
Vout = −(1/RC) · ∫ Vin dt
```

Wyjście jest **całką** napięcia wejściowego. Stosowane w filtrach, generatorach przebiegów piłowych, regulatorach PID.

### 9. Różniczkator

```
        ┌──[R]──┐
        │       │
  in ─[C]──────●── ─
                   >─── out (pochodna)
              +
             GND
```

```
Vout = −RC · dVin/dt
```

Wzmacnia szumy HF — w praktyce dodaje się ograniczenia.

### 10. Filtr aktywny

Op-amp + RC daje filtr o znanej charakterystyce (Butterworth, Chebyshev, Bessel). Pozwala robić aktywne filtry górno-, dolno- i pasmowoprzepustowe bez dużych cewek.

## Zasilanie op-ampa

### Symetryczne (dual supply)

±5 V, ±12 V, ±15 V. Pozwala sygnałowi przejść przez 0 V. Standard w audio i pomiarze.

### Pojedyncze (single supply)

Tylko +V i GND. Trzeba sygnał "przesunąć" w połowę V (virtual ground). Dodatkowy dzielnik i kondensator. LM358 i LM324 są zaprojektowane do single-supply.

### Rail-to-rail

Op-amp, którego wyjście dochodzi praktycznie do +V i 0 V. Typowo "zwykły" op-amp daje wyjście maks. V+ − 1,5 V i nie dochodzi do GND. Rail-to-rail (np. MCP6002) — ważne przy niskich napięciach (3,3 V).

## Praktyczne wskazówki

### 1. Kondensatory blokujące

**Każdy** op-amp musi mieć 100 nF między +V a GND (i -V a GND) **tuż przy nóżkach**. Bez tego oscylacje, zakłócenia.

### 2. Sprzężenie zwrotne zawsze

Op-amp bez ujemnego sprzężenia zwrotnego = komparator (lub oscylator). Z dodatnim — oscylator.

### 3. Ograniczenia wejścia (input common-mode range)

Nie każdy op-amp lubi wejście blisko +V lub GND. Sprawdź w datasheet — niektóre wymagają sygnału w zakresie V+1V do V--1V.

### 4. Obciążenie wyjścia

Op-amp może dać 5-50 mA wyjścia. Jeśli potrzeba więcej — buforuj tranzystorem.

### 5. Wirtualna masa (single supply)

```
   +V
    │
   [R]
    │
    ●── virtual GND (V/2)
    │
   [R]
    │
   GND
   
   plus kondensator 10 μF do GND
```

Sygnał pracujący wokół V/2.

## Pomiary z op-ampem

### Wzmacniacz pomiarowy (instrumentation amp)

Wzmacnia różnicę dwóch sygnałów, tłumi sygnał wspólny. Stosowane: tensometry, EKG, czujniki różnicowe.

### Konwerter prąd-napięcie (transimpedance)

Klasyczne dla fotodiod, czujników z wyjściem prądowym.

```
       ┌──[R_f]──┐
       │         │
       ────────── ─
                  >─── Vout = -I · R_f
              + 
             GND
```

I (prąd z fotodiody) → V proporcjonalne.

## Niestabilność i oscylacje

Op-amp z ujemnym sprzężeniem zwrotnym **musi być stabilny**. Przyczyny oscylacji:
- Sprzężenie zwrotne przez pojemność na PCB
- Duża pojemność na wyjściu (kabel) — opóźnienie w pętli sprzężenia
- Brak kondensatorów blokujących

Rozwiązania:
- Mały kondensator (10-50 pF) równolegle do R_f
- Rezystor szeregowo z wyjściem (isolation R)
- Lepsze projektowanie PCB

## Wybór op-ampa — checklist

1. **Napięcie zasilania** — single czy dual? Jakie?
2. **Pasmo (GBP)** — wystarczające dla zamierzonego wzmocnienia
3. **Slew Rate** — dla pełnej amplitudy
4. **Szum** — krytyczny w audio i precyzyjnych pomiarach
5. **Prąd polaryzacji** (I_B) — krytyczny dla wysokoimpedancyjnych źródeł
6. **Offset napięciowy** — w precyzyjnym DC
7. **Rail-to-rail** — niskie napięcia
8. **Liczba w obudowie** (single, dual, quad)

## Częste błędy

1. **Brak kondensatorów blokujących** — niestabilność, oscylacje.
2. **Sprzężenie zwrotne dodatnie** zamiast ujemnego — generator zamiast wzmacniacza.
3. **Wzmocnienie 1000 z LM358** — przekroczone GBP, pasmo szczątkowe.
4. **Op-amp na granicy zakresu wejść** — wyjście "klikuje", nieliniowe.
5. **Op-amp obciążony pojemnościowo (długi kabel)** — oscylacje.
6. **Niedopasowane wzmocnienia komparatora** — chaotyczne przełączanie. Dodaj histerezę.
7. **Naruszenie maks. napięcia wejściowego** (single supply, sygnał ujemny) — zatrzaśnięcie op-ampa, czasem trwałe uszkodzenie.
