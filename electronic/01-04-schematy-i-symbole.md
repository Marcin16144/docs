# 01-04: Schematy i symbole

## Czym jest schemat elektryczny

Graficzny zapis połączeń elementów elektronicznych. Każdy element ma standardowy symbol, każde połączenie jest linią. Schemat to instrukcja dla każdego, kto chce układ zbudować, naprawić lub zrozumieć.

Schemat nie pokazuje **fizycznego rozmieszczenia** elementów — to robi rysunek montażowy lub PCB layout. Pokazuje **logikę połączeń**.

## Dwa standardy symboli

### IEC 60617 (Europa, Polska)

Rezystor: prostokąt.

```
   ──[ ]──
```

### ANSI Y32.2 (USA)

Rezystor: zygzak.

```
   ──/\/\/\──
```

Oba są równoważne. Schematy z USA używają zygzaków, z Europy — prostokątów. W tej dokumentacji używamy symboli IEC (europejskich), ale warto znać oba.

## Symbole najpopularniejszych elementów

### Rezystor
```
   ──[ ]──        ──/\/\/\──
   IEC            ANSI
   
Oznaczenie: R1, R2... 
Wartość: 1k, 10k, 100R itp.
```

### Potencjometr (rezystor regulowany)
```
       │
       ↓
   ──[─┴─]──     trzy wyprowadzenia: dwa końce + suwak
```

### Kondensator
```
Niespolaryzowany:        Spolaryzowany (elektrolit):
                         
   ──││──                ──┤├──   lub   ──┤│──
   równoległe płytki      jedna płytka oznaczona +/−
                         + jest po stronie zakrzywionej
```

### Cewka (induktor)
```
   ──UUUU──              z rdzeniem ferromagnetycznym:
                         ──UUUU──
                              ───   (dwie kreski = rdzeń)
```

### Transformator
```
   ┌──UUUU──┐
            ║
            ║   (║ — rdzeń wspólny)
            ║
   └──UUUU──┘
   pierwotne / wtórne
```

### Dioda
```
   ──▷│──          Anoda (A) lewa, katoda (K) prawa
   A    K          Strzałka pokazuje kierunek prądu
```

### Dioda Zenera
```
   ──▷|──          katoda z "haczykiem"
       └          
```

### LED
```
   ──▷│──↑↑       strzałki = emisja światła
       ↑
```

### Tranzystor NPN
```
        C (kolektor)
        │
    B ──┤
        │
        E ↓ (emiter, strzałka na zewnątrz)
```

### Tranzystor PNP
```
        C
        │
    B ──┤
        │
        E ↑ (strzałka do środka)
```

### MOSFET kanał N (wzbogacony)
```
        D (drain)
        │
    G ──┤  (gate izolowany)
        │
        S (source)
```

### Bezpiecznik
```
   ──[FU]──    lub    ──◯══◯──
```

### Przełącznik
```
   ──/ ──     SPST (single pole, single throw)
```

### Bateria / źródło DC
```
   ──┤├──    krótka kreska = minus, długa = plus
   −  +
```

### Źródło AC
```
   ──(~)──
```

### Masa (GND)
```
       │              │             │
       ─              ▽             ▼
      ─             ─┴─           
      ─            chassis         earth
     analogowa
```

## Linie i połączenia

### Połączenie (krzyżujące się przewody)
```
  połączone:           NIE połączone:
   ─┬─                  ─│─
    │                    │
   ─┴─                  ─│─
   z kropką             bez kropki (lub łuk)
```

Konwencja: **kropka = połączenie**. Brak kropki na skrzyżowaniu = przewody się tylko mijają.

### Linie zbiorcze (bus)
```
   ────────────  ←  pojedyncza linia
   ════════════  ←  bus, grupa przewodów
```

## Oznaczenia elementów

Każdy element na schemacie ma **referencję**:

| Litera | Element |
|--------|---------|
| R | rezystor |
| C | kondensator |
| L | cewka |
| D | dioda (czasem LED) |
| Q lub T | tranzystor |
| U lub IC | układ scalony |
| J | złącze, gniazdo |
| SW | przełącznik |
| F lub FU | bezpiecznik |
| TR | transformator |
| X | rezonator/kwarc |
| BAT | bateria |
| TP | test point (punkt pomiarowy) |

Numeracja: R1, R2, R3..., C1, C2..., U1, U2... Numerujemy zwykle od lewego górnego rogu.

## Oznaczanie wartości

### Rezystory

```
220R   = 220 Ω
4k7    = 4,7 kΩ
1M     = 1 MΩ
2M2    = 2,2 MΩ
```

W europejskim zapisie litera zastępuje przecinek dziesiętny i jednostkę.

### Kondensatory

```
100p   = 100 pF
4n7    = 4,7 nF
10u    = 10 μF
470μ   = 470 μF
```

### Indukcyjność

```
10μH, 100mH, 1H
```

## Masa, plus, GND, V+

### Masa (GND, common, "minus")

Punkt odniesienia napięć. Wszystkie napięcia w obwodzie mierzy się względem masy.

Rodzaje mas:
- **GND** — analogowa masa sygnałów
- **AGND** — masa analogowa (precyzyjny pomiar)
- **DGND** — masa cyfrowa
- **PGND** — masa mocy (zasilacze)
- **PE** — ochronne uziemienie (żółto-zielony przewód!)

W dobrym projekcie różne masy łączy się **w jednym punkcie**, żeby zakłócenia z mocy nie wchodziły w sygnały.

### Plus zasilania

Oznaczany: VCC, VDD, V+, +5V, +3V3, +12V itp.

- **VCC** — zwykle bipolarne (TTL), historycznie 5 V
- **VDD** — układy CMOS i MOSFET
- **VEE** — minus zasilania bipolarnego
- **VSS** — masa w CMOS

## Czytanie schematu — algorytm

1. **Znajdź zasilanie** — gdzie wchodzi prąd, ile woltów, jak jest stabilizowane.
2. **Prześledź ścieżkę sygnału** — od wejścia do wyjścia (lewa → prawa).
3. **Zidentyfikuj bloki funkcjonalne** — zasilacz, filtr, wzmacniacz, mikrokontroler.
4. **Sprawdź sprzężenia** — kondensatory blokujące przy każdym układzie scalonym.
5. **Zobacz, gdzie są przerzucone elementy regulujące** — potencjometry, jumpery.

## Typowy układ na schemacie

Konwencje rozplanowania:

```
┌─────────────────────────────────────────────┐
│  +V (góra)                                  │
│   │                                         │
│   ▼                                         │
│  zasilanie    →  rdzeń układu  → wyjście    │
│   ▲              ▲                          │
│   │              │                          │
│   │              │                          │
│   ▼              ▼                          │
│  GND (dół) ───────────────────────────       │
└─────────────────────────────────────────────┘
```

- **Zasilanie u góry, masa u dołu** (umownie)
- **Sygnał płynie z lewej na prawo**
- **Bloki funkcjonalne pogrupowane**

## Schemat vs PCB layout

| Schemat | PCB layout |
|---------|-----------|
| Pokazuje **co** się łączy | Pokazuje **jak fizycznie** się łączy |
| Brak skali, dowolne rozplanowanie | Wymiary, fizyczne pozycje |
| Symbole | Footprinty (pady, otwory) |
| Linie | Ścieżki (tracks) |

Schemat tworzymy najpierw, potem PCB. Programy: KiCad (darmowy), Altium, Eagle, EasyEDA.

## Symbole obwiązkowe na schemacie produkcyjnym

Profesjonalny schemat zawiera:

1. **Tytuł** — co to jest
2. **Numer rewizji** — wersja
3. **Datę**
4. **Projektanta**
5. **Numer strony** (jeśli wieloarkuszowy)
6. **Listę zmian** (changelog)
7. **BOM** (Bill of Materials) — listę elementów

## Częste błędy w schematach

1. **Brak kondensatorów blokujących** przy układach scalonych (100 nF tuż przy nóżce VCC).
2. **Pętle masy** — masa rozprowadzona w wielu punktach, prądy płyną przez "nie te" miejsca.
3. **Przeciążone wyjścia** — sterowanie LED bezpośrednio z portu MCU bez rezystora.
4. **Brak rezystorów pull-up/down** na wejściach cyfrowych.
5. **Nieoznaczone polaryzacje** — kondensator elektrolityczny włożony na odwrót = bum.

## Przykładowy schemat — najprostszy zasilacz

```
   AC 230V ──┤├── (transformator) ──┐
                     ┌───────────────┤
                     │               │
                    [D]             [D]   prostownik
                     │               │      mostkowy
                     └─────┬─────────┘
                           │
                          ─┴─ C 4700μF
                           ─
                           │
                         ─────  IC 7812
                           │
                           │
                          ─┴─ C 100nF
                           ─
                           │
                          GND
                           
                 wyjście +12 V DC
```

Czytanie: AC z sieci → transformator obniża napięcie → prostownik (4 diody w mostku) → kondensator wygładza → stabilizator 7812 → kondensator filtrujący wyjście.

## Co dalej

Mając opanowane symbole i schematy, w kolejnych rozdziałach przejdziemy do konkretnych elementów: rezystorów, kondensatorów, cewek, diod, tranzystorów. Każdy z nich ma swoje zachowanie, parametry i sposoby zastosowania w układach.
