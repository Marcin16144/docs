# 06-02: Rdzenie magnetyczne

## Rola rdzenia

Rdzeń koncentruje pole magnetyczne, **wzmacniając sprzężenie** między uzwojeniami. Bez rdzenia większość pola "ucieka" w powietrze. Z rdzeniem ferromagnetycznym sprzężenie sięga 95-99%.

Wybór rdzenia decyduje o:
- Mocy transformatora
- Wymiarach fizycznych
- Częstotliwości pracy
- Stratach
- Cenie

## Parametry magnetyczne

### Przenikalność magnetyczna μ

```
μ = μ_0 · μ_r

μ_0 = 4π · 10⁻⁷ ≈ 1,26·10⁻⁶ H/m  (próżnia)
μ_r — przenikalność względna materiału
```

| Materiał | μ_r |
|----------|-----|
| Próżnia, powietrze | 1 |
| Aluminium | 1,000022 |
| Żelazo czyste | 5000-200 000 |
| Żelazo krzemowe (trafo) | 7000-10 000 |
| Permaloy (Ni-Fe) | 100 000 |
| Ferryt Mn-Zn | 2000-15 000 |
| Ferryt Ni-Zn | 100-1500 |
| Nanokrystaliczny | 30 000-200 000 |

Wysokie μ_r oznacza:
- Większą indukcyjność dla danej liczby zwojów
- Niższy prąd magnesujący
- Lepsze sprzężenie

### Indukcja magnetyczna B

```
B [T] = μ · H
```

Maksymalna indukcja B_max przed nasyceniem:

| Materiał | B_max [T] |
|----------|-----------|
| Blacha trafo (Si-Fe) | 1,5 - 1,8 |
| Permaloy | 0,8 |
| Ferryt Mn-Zn | 0,3 - 0,5 |
| Ferryt Ni-Zn | 0,2 - 0,3 |
| Żelazo amorficzne | 1,2 - 1,5 |
| Nanokrystaliczny | 1,2 |

W projektowaniu zwykle pracujemy przy 60-80% B_max dla zapasu.

### Nasycenie

Po przekroczeniu B_max przenikalność spada do wartości powietrza. Transformator "wysiada" — duża strata mocy, zniekształcenia, grzanie. W SMPS = palone tranzystory.

### Histereza

Materiał ferromagnetyczny "pamięta" stan magnesowania. Charakterystyka B-H tworzy pętlę:

```
B
↑
│   ┌──────
│  /
│ /
│/
●─────────── H
│
│
│  ────┘
│      /
│     /
└────/
```

Powierzchnia pętli = energia tracona na cykl. P_h = f · powierzchnia.

Stąd straty histerezowe rosną z częstotliwością.

### Straty wiroprądowe

W rdzeniu indukowane są prądy wirowe (eddy currents). Aby je zminimalizować:

- **Blacha laminowana** — cienkie izolowane warstwy zamiast bloku
- **Ferryt** — wysokoomowy materiał, naturalnie niskie straty wiroprądowe

```
P_wir = k · f² · B_max² · d² / ρ

d — grubość blaszki
ρ — rezystywność
```

## Typy rdzeni — szczegółowo

### Blacha EI

Najpopularniejszy rdzeń transformatorów sieciowych. Pakiet blaszek "E" i "I" składanych przemiennie.

```
   ┌──────┐
   │  ┌─┐ │
   │  │ │ │
   │  │U│ │   karkas + uzwojenie w środkowej kolumnie
   │  │ │ │
   │  └─┘ │
   └──────┘
   blacha "E"     +"I" do zamknięcia obwodu
```

Materiał: stal krzemowa (grain-oriented = GO, lub non-oriented = NGO). Grubość 0,3-0,5 mm.

Zalety:
- Tanie, łatwo dostępne
- Sprawdzone
- Duże B_max

Wady:
- Wyższe straty niż toroidalne (szczeliny)
- Większe pole rozproszenia (zakłócenia)
- Cięższe i większe

### Toroidalny (pierścień)

Drut nawinięty na rdzeniu w kształcie pierścienia. Zwoje pokrywają cały rdzeń.

Zalety:
- **Najwyższa sprawność** (95-97% dla 100 VA)
- Małe pole rozproszenia (mniej EMI)
- Mała hałaśliwość (brak luźnych blaszek)
- Lżejszy i mniejszy niż EI tej samej mocy

Wady:
- Trudne nawijanie (specjalna maszyna lub ręcznie z pomocą "челнока")
- Większy prąd inrush (do 100× I_nominalnego!)
- Droższy

### Rdzeń C (cut core)

Rdzeń z taśmy żelaza zwijany i przecinany na dwie połowy. Łatwiejszy w nawijaniu niż toroidalny, lepsze parametry niż EI.

### Rdzeń U / UI

Otwarty, dwie połowy, dwie kolumny z uzwojeniami. Większe pole rozproszenia, prostszy w produkcji.

### Rdzenie ferrytowe — dla SMPS

#### Typy obudów

| Typ | Wygląd | Zastosowanie |
|-----|--------|--------------|
| EE / EI / ETD | E-kształtne | uniwersalne, średnie moce |
| EFD | płaskie EE | LCD, slim |
| RM | "rectangular modular" | precyzyjne, SMPS |
| PQ | optymalizowany | niskoprofilowe SMPS |
| Pot core (kubek) | pełna obudowa | wysoka jakość, niski EMI |
| ETD | ekonomiczny | uniwersalny SMPS |
| Planar | płaski w PCB | wysokomocowy, SMPS |
| Toroid | pierścień | dławiki, common-mode |
| Drum | "szpulka" | małe induktory SMD |
| Bead (koralik) | koralik na drucie | filtry EMI |

#### Materiały ferrytów

| Materiał | f | Zastosowanie |
|---------|---|--------------|
| 3C90, N87, PC44 | do 200 kHz | SMPS, transformatory |
| 3F3, N97 | do 500 kHz | szybsze SMPS |
| 3F45, 4F1 | do 1-2 MHz | RF, drobne SMPS |
| 4C65, F | RF | dławiki, balun |

#### Producenci

- **TDK / EPCOS**
- **Ferroxcube** (Philips)
- **Magnetics**
- **Fair-Rite** (USA, niedrogie)
- **Sumida**

### Rdzeń żelaza proszkowego

Cząstki żelaza w spoiwie, sprasowane. Cechy pośrednie ferryt-żelazo:
- Wyższe B_max niż ferryt
- Niższa μ niż ferryt
- "Rozproszone" pole — niskie straty

Toroidy żelaza proszkowego są popularne w dławikach SMPS (filtry, PFC).

Kolory rdzeni Micrometals (USA):
- T50-26 (żółty/biały) — μ=75, do 0,5 MHz
- T50-2 (czerwony) — μ=10, do 30 MHz, RF
- T106-26 — duży dławik

### Amorficzny / nanokrystaliczny

Najnowsze. **Bardzo niskie straty**, wysoka μ.

Stosowane:
- Wysokiej klasy SMPS
- Common-mode choke dla PFC
- Inwertery solarne premium

Drogie, dostępne w postaci taśm.

## Wybór rdzenia dla zastosowania

### Sieciowy 50 Hz, do 1 kVA

→ **Blacha EI** lub **toroidalny żelaznoorientowany**

### SMPS 50-200 kHz, do 200 W

→ **Ferryt EE / ETD / RM / PQ** materiał 3C90 / N87

### SMPS 200 kHz – 1 MHz, do 100 W

→ **Ferryt** materiał N97 / 3F3 lub planar

### RF, 1-100 MHz

→ **Ferryt Ni-Zn** materiały 4C65, K, M lub powietrze

### Filtr EMI 50 Hz

→ **Nanokrystaliczny** lub ferryt Mn-Zn (common-mode choke)

## Obliczanie mocy z rdzenia EI

Empiryczny wzór dla blach EI sieciowych 50 Hz:

```
P [W] ≈ S² · k  (gdzie k = 0,7 - 1,2)

lub bardziej praktycznie:
S [cm²] ≈ √P
```

Przykład: chcę 100 W → S ≈ 10 cm² = blacha o przekroju 10 cm² (np. EI66 z odpowiednim pakietem).

Realne tablice katalogowe transformatorów blach EI:

| Typ blachy | Powierzchnia [cm²] | Moc [VA] |
|------------|--------------------|----------|
| EI28 | 1,4 | 5-10 |
| EI42 | 3,5 | 20-30 |
| EI54 | 5,7 | 50-70 |
| EI66 | 9,0 | 100-150 |
| EI78 | 12,8 | 200-300 |
| EI96 | 22 | 400-600 |
| EI114 | 35 | 800-1200 |
| EI150 | 60 | 2000-3000 |

## Obliczanie z rdzenia toroidalnego

Mniej szczeliny → wyższe wykorzystanie. Te same wymiary geometryczne dają wyższą moc.

Typowy toroid 100 VA: rdzeń ok. 65×30 mm, masa ok. 1,2 kg.
Toroid 500 VA: ok. 110×50 mm, ok. 4 kg.

## Obliczanie z rdzenia ferrytowego (SMPS)

Stosuje się parametr **A_L** [nH/zwój²] z katalogu:

```
L = N² · A_L

N = √(L / A_L)
```

Dla mocy SMPS:
```
P ≈ B_max · A_e · f · k · I_max · √2

A_e — efektywne pole przekroju [cm²]
f   — częstotliwość [Hz]
k   — współczynnik wypełnienia okna (0,3-0,5)
```

W praktyce używa się **tablic katalogowych** lub **softów** (PI Expert, Coilcraft toolkit, Ferroxcube SoftFerrite).

## Szczelina powietrzna (air gap)

Celowe wprowadzenie szczeliny w rdzeniu:
- W flyback: konieczne (magnesowanie jednostronne)
- W dławikach mocy: zapobiega nasyceniu
- Powoduje spadek μ → potrzeba więcej zwojów dla danej L
- Zwiększa B_sat w użytecznym zakresie

Dla rdzenia EI: można podsunąć papier między "E" i "I".
Dla ferrytów EE: jedna połowa szlifowana.
Dla toroidów żelaza proszkowego: szczelina rozproszona w całym objętości.

## Hałas transformatora

Magnetostriction — rdzeń się "kurczy" pod polem magnetycznym. To powoduje wibracje 100 Hz (50 Hz × 2). Stąd "buczenie" transformatorów.

Zmniejszenie hałasu:
- Toroidalne (pakiet zwarty)
- Impregnacja lakierem
- Mocowanie elastyczne
- Mniejsze B_max

## Materiały izolacyjne i nasączanie

Po zwinięciu rdzenia warto:
- Nasączyć lakierem izolacyjnym (klasa H — 180°C)
- Zalać żywicą (transformator w obudowie)
- Owinąć folią termokurczliwą

Klasy temperaturowe izolacji:

| Klasa | T max |
|-------|-------|
| A | 105°C |
| E | 120°C |
| B | 130°C |
| F | 155°C |
| H | 180°C |
| C | >180°C |

## Częste błędy w wyborze rdzenia

1. **Za mały rdzeń** — nasycenie, grzanie, dym.
2. **Ferryt w 50 Hz** — nie ma sensu (za małe B_max przy małej f).
3. **Blacha trafo w 100 kHz** — masywne straty wiroprądowe.
4. **Brak szczeliny w flyback** — natychmiastowe nasycenie.
5. **Za duże B_max** — straty rdzenia rosną sześciennie, grzanie.
6. **Pomylenie μ_r 2000 a 5000** — kilkukrotny błąd w obliczeniach L.
7. **Zła orientacja blach EI** — pakiet musi być przemienny (E z jednej strony, E z drugiej + I), nie wszystkie tak samo.
