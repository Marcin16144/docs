# 03-04: Tranzystor polowy (FET, MOSFET, JFET)

## Czym jest FET

**Field Effect Transistor** — tranzystor polowy. Sterowany **napięciem**, a nie prądem (jak BJT). Pobiera praktycznie zero prądu z wejścia (idealny dla MCU).

Trzy końcówki:

- **Drain (D)** — odpływ
- **Gate (G)** — bramka (sterowanie)
- **Source (S)** — źródło

Dwa główne typy:

- **MOSFET** (Metal-Oxide-Semiconductor FET) — najpopularniejszy
- **JFET** (Junction FET) — starszy, w sygnałowych aplikacjach

## MOSFET

### Struktura

Bramka jest **izolowana** od kanału cienką warstwą dwutlenku krzemu (SiO₂). Nie ma fizycznego połączenia! Stąd:

- Impedancja wejścia gigantyczna (10¹²-10¹⁴ Ω)
- Pobór prądu sterowania = 0 (statycznie)
- Bramka działa jak okładka kondensatora

```
         D
         │
         │ (kanał)
   G ──[│]
         │
         │
         S
   bramka izolowana
```

### Cztery odmiany

1. **N-MOS kanał wzbogacony (N-channel enhancement)** — najpopularniejszy
2. **N-MOS kanał zubożony (N-channel depletion)** — rzadko
3. **P-MOS kanał wzbogacony (P-channel enhancement)**
4. **P-MOS kanał zubożony (P-channel depletion)** — rzadko

"Wzbogacony" (enhancement) = włącza się gdy U_GS > próg. Domyślnie zatkany.
"Zubożony" (depletion) = włączony domyślnie, wyłącza się przy odpowiednim napięciu.

W praktyce ENHANCEMENT — standard.

## N-MOS (kanał N, wzbogacony)

### Symbol

```
        D
        │
   G ──┤
        │
        S (strzałka w stronę GATE)
```

### Działanie

Napięcie U_GS > U_GS(th) — bramka przyciąga elektrony → tworzy się kanał między D a S → przewodzenie.

```
U_GS = 0        →  brak kanału, zatkany
U_GS = U_th     →  kanał zaczyna się tworzyć
U_GS > U_th     →  pełne przewodzenie
```

### Charakterystyki

- **Liniowa (triode)** — przy małym U_DS, R_DS(on) stały
- **Nasycenie (saturation)** — przy U_DS > U_GS - U_th, I_D zależy głównie od U_GS

```
I_D
 │
 │       U_GS=10V ──────  saturation
 │      /
 │     / U_GS=8V ──────
 │    / /
 │   / / U_GS=6V ──────
 │  / / /
 │ / / / U_GS=4V ──
 │/// /
 │////
 ──────────────────── U_DS
  triode  | saturation
```

### Parametry kluczowe

| Parametr | Symbol | Typowe |
|----------|--------|--------|
| Napięcie progowe | U_GS(th) | 1-4 V (logic level), 2-4 V (standard) |
| Max prąd dren | I_D | 1 A – 200 A |
| Max U_DS | V_DSS | 20 V – 1500 V |
| Rezystancja włącz. | R_DS(on) | mΩ – Ω |
| Max U_GS | V_GS | ±20 V (uwaga!) |
| Pojemność wejściowa | C_iss | nF |
| Czas włączania | t_on | ns |
| Moc | P_D | W – setki W |

## Popularne MOSFET-y

| Model | Typ | V_DSS | I_D | R_DS(on) | Obudowa |
|-------|-----|-------|-----|----------|---------|
| 2N7000 | N | 60 V | 200 mA | 5 Ω | TO-92 |
| IRF540N | N | 100 V | 33 A | 44 mΩ | TO-220 |
| IRF3205 | N | 55 V | 110 A | 8 mΩ | TO-220 |
| IRFZ44N | N | 55 V | 49 A | 17,5 mΩ | TO-220 |
| AO3400 | N (logic) | 30 V | 5 A | 26 mΩ | SOT-23 |
| IRF9540 | P | -100 V | -23 A | 117 mΩ | TO-220 |

## "Logic level MOSFET"

Klasyczny MOSFET ma V_GS(th) około 4 V — z portu 3,3 V się nie włączy w pełni.

**Logic level MOSFET** — V_GS(th) około 1-2 V, pełne włączenie przy 3-5 V. Sterowanie bezpośrednio z MCU.

Modele: AO3400, IRLB3034, IRL540, RFP30N06LE, FQP30N06L (z literką L = "Logic").

## P-MOS

Działa odwrotnie. Włącza się przy U_GS < -U_th (ujemne napięcie bramki względem source). Stosowany **w plusie zasilania** (high-side switch):

```
     +12V
      │
      S
   P ─┤
      D
      │
   obciążenie
      │
     GND
```

Sterowanie: gdy bramka jest blisko +12V — wyłączony, gdy znacznie niższa (np. 0V) — włączony.

## MOSFET jako przełącznik

### N-MOS (low-side)

```
   +12V
    │
   obciążenie
    │
    D
   ─┤
    G ──── sterowanie (3,3 V / 5 V z MCU)
    S
    │
   GND
```

Włączanie: U_GS = 5 V → MOSFET przewodzi → obciążenie zasilane.

### Sterowanie z MCU

- Logic level MOSFET → bezpośrednio z portu
- Standard MOSFET → potrzebny driver lub tranzystor BJT do podniesienia napięcia

### Rezystor podciągający bramkę

**Zawsze** dodaj 10-100 kΩ z bramki do source. Bramka jest jak kondensator — bez podciągnięcia "lata" w nieokreślonym stanie. Tranzystor może się otwierać szumami, EMI, dotykiem.

### Rezystor szeregowo z bramką

10-100 Ω chroni przed oscylacjami i ogranicza dV/dt. W zasilaczach impulsowych krytyczne.

```
       Vcc
        │
       obciąż.
        │
        D
   ─[R_g]─G─┤
   10-100Ω  │
        S   │
        │  [R_pd] 10-100 kΩ
        │   │
       GND─GND
```

## Pojemność bramki — szybkie przełączanie

C_iss = 1-10 nF. Przy szybkich zmianach napięcia potrzebny duży prąd chwilowy:

```
I_G_peak = C_iss · dV/dt
```

Dla C_iss = 2 nF, dV = 10 V, dt = 50 ns:
```
I_G = 2·10⁻⁹ · 10 / 50·10⁻⁹ = 0,4 A
```

Stąd specjalne **drivery MOSFET** (np. IR2104, TC4427) — zapewniają duży prąd chwilowy bramki.

## Moc i straty

### Straty przewodzenia

```
P_cond = I² · R_DS(on)
```

MOSFET niskoomowy (mΩ) → małe straty przy dużych prądach.

### Straty przełączania

```
P_sw = ½ · U_DS · I · (t_on + t_off) · f
```

Rosną proporcjonalnie do częstotliwości. Stąd "rezystor szeregowo z bramką" jest kompromisem — wolniejsze przełączanie = mniej EMI, ale więcej strat.

### Total

```
P_total = P_cond + P_sw + P_gate
```

W praktycznym SMPS 100 kHz przełączania > 1 kW: każdy MOSFET około 1-5 W → wymagane chłodzenie.

## Dioda body (intrinsic / body diode)

Każdy MOSFET ma "wbudowaną" diodę między D a S (D-S, anoda na S dla N-MOS). Może działać jako freewheel diode w niektórych konfiguracjach. Ale wolna! W SMPS często dodaje się szybką diodę Schottky równolegle.

## ESD i ochrona bramki

MOSFET jest bardzo wrażliwy na ESD. Statyczny ładunek z palca może przebić cienką warstwę SiO₂.

**Zasady BHP:**
- Opaski antystatyczne
- Powierzchnie przewodzące
- Przewody zwierające piny w transporcie
- Lutować po wszystkim innym, ostatnie

**Ochrona w układzie:**
- TVS lub Zener między G a S (16-18 V)
- ESD diody przy wejściach

## JFET (Junction FET)

Starszy typ, bramka jest złączem PN (nie izolowana). 

Dwa typy:
- **N-channel JFET** (2N3819, J310, BF245)
- **P-channel JFET** (rzadko)

Pracuje w trybie zubożonym — domyślnie przewodzi, **U_GS < 0** wyłącza go.

Zastosowanie: wzmacniacze sygnałów, układy preamp, źródła prądowe. Niska szum, ale małe prądy.

```
       D
       │
   G ──┤
       │
       S    strzałka na bramce w stronę kanału N
```

## MOSFET vs BJT

| Cecha | BJT | MOSFET |
|-------|-----|--------|
| Sterowanie | prądem | napięciem |
| I_in (stałe) | mA | ~0 (pA) |
| U_włączony | 0,2-1 V | I·R_DS(on) → mV |
| Częstotliwość | wolniejszy | szybszy |
| ESD | mniej wrażliwy | wrażliwy |
| Mocne strony | wysoka stabilność | wydajność, sterowanie z MCU |
| Cena | tańszy | nieco droższy |

W nowoczesnej elektronice **MOSFET dominuje**, BJT pozostają w specyficznych aplikacjach (precyzyjne audio, biasing op-ampów).

## H-Bridge — sterowanie silnikiem DC

Czterotranzystorowy układ pozwalający odwracać kierunek silnika.

```
       Vcc
        │
   ●────┴────●
   │         │
   Q1        Q2     (high side)
   ●────●────●
        │
       silnik
        │
   ●────●────●
   │         │
   Q3        Q4     (low side)
   ●────┬────●
        │
       GND
```

Tryby:
- Q1 + Q4 ON, Q2 + Q3 OFF → silnik w jedną stronę
- Q2 + Q3 ON, Q1 + Q4 OFF → w drugą
- Wszystkie OFF → wybieg
- Q3 + Q4 ON → hamowanie (zwarcie)

**Nigdy** Q1+Q3 ani Q2+Q4 (shoot-through) — zwarcie zasilania!

## Wybór MOSFET — checklist

1. **N czy P-channel** (low-side / high-side)?
2. **V_DS max** z zapasem 2×
3. **I_D max** z zapasem
4. **V_GS(th)** — czy logic level?
5. **R_DS(on)** — przy maksymalnym I_D obliczyć straty
6. **C_iss / Q_g** — jak szybko ma przełączać
7. **Moc i chłodzenie**
8. **Obudowa** (TO-220, TO-247, SOT-23, D2PAK)

## Częste błędy

1. **Brak rezystora pull-down na bramce** — losowe włączanie.
2. **Niewystarczające U_GS** — MOSFET nie wchodzi w pełne nasycenie → grzanie.
3. **Wybór nie-logic-level** sterowanego z 3,3 V.
4. **Bramka bezpośrednio podłączona** — drgania, oscylacje, EMI.
5. **Pomyłka G/D/S** — TO-220 IRF: G-D-S patrząc od frontu, ale spojrzenie na schemat zależy od układu.
6. **Brak chłodzenia** w SMPS.
7. **Pomyłka N i P-MOS** — N-MOS na high side wymaga bootstrap driver, P-MOS jest prostszy.
