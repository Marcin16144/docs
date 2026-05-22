# 06-05: Transformatory impulsowe

## Czym różni się od sieciowego

Transformator impulsowy pracuje z **wysoką częstotliwością** (10 kHz – 2 MHz) zamiast 50 Hz. To zmienia wszystko:

| Cecha | Sieciowy 50 Hz | Impulsowy 100 kHz |
|-------|----------------|---------------------|
| Rdzeń | blacha żelazna | ferryt |
| Wielkość | duży | mały (1/10 do 1/100) |
| B_max | 1,2-1,5 T | 0,2-0,3 T |
| Zwojów na wolt | dużo | mało |
| Straty w rdzeniu | duże w sumie (ale jeden cykl/20ms) | szybkie, ale rdzeń mały |
| Wymaganie | brak DC | często z DC bias |

Kluczowy wzór: **U = 4,44·f·N·B·S** — zwiększenie f pozwala zmniejszyć S albo N (lub B).

## Materiały rdzeni

### Ferryt Mn-Zn

Standard dla SMPS. Materiały:
- **3C90, N87, PC44, F44** — uniwersalne, do 200 kHz
- **3F3, N97** — do 500 kHz
- **3F45, 4F1** — > 1 MHz

### Żelazo proszkowe (Iron powder)

Stosowane w dławikach SMPS, PFC. Wyższe B_max, naturalna szczelina rozproszona.

### Nanokrystaliczny

Premium SMPS, najnowsza technologia.

## Kształty rdzeni

### EE, EI, EFD

E-kształtne. Najpopularniejsze w SMPS.

```
   ┌──────┐
   │ ┌──┐ │
   │ │  │ │   bobina w środkowej kolumnie
   │ │  │ │
   │ └──┘ │
   └──────┘
   dwie blachy E zwarte
```

### RM (Rectangular Modular)

Kompaktowe, ze szczegółowymi rozmiarami: RM4, RM6, RM8, RM10, RM12, RM14. Z włókną.

### PQ

Optymalizowany pod niskoprofilowe SMPS.

### ETD

Niskoprofilowy, dobry dla zasilaczy LED.

### Pot core

Pełna obudowa magnetyczna. Najlepsze ekranowanie, ale gorszy odprowadz ciepła.

### Planar

Cały transformator w PCB (cewki jako miedź na warstwach). Niskoprofilowy, drogi, profesjonalny.

### Toroid ferrytowy

Common-mode choke, transformatory pulsowe (do drukarek, monitorów CRT).

## Konfiguracje SMPS i ich transformatory

### Flyback (do ~200 W)

Najpopularniejszy. Pracuje "z gromadzeniem energii w rdzeniu".

```
   pierwotne 1:N wtórne
        ┌──────┐
        │UUUUUU│
   +V_in┤      ├──▷│── +V_out
        │      │       │
        └──────┘       C
        Q (MOSFET)     │
         │            GND
        GND
```

**Cykle:**
1. Q ON → prąd w pierwotnym → energia w rdzeniu
2. Q OFF → energia uwalniana w wtórnym przez diodę

Transformator flyback **wymaga szczeliny** (gap) — bo prąd ma stałą składową DC magnesującą rdzeń.

### Forward (200-500 W)

Energia idzie "na bieżąco" — gdy Q ON, dioda na wtórnym przewodzi. Rdzeń bez szczeliny.

### Push-Pull

Dwa MOSFETy przemiennie. Transformator z odczepem środkowym pierwotnego.

### Half-Bridge / Full-Bridge

Większe moce (kW). Skomplikowane. Czerwone i czarne fragmenty rdzenia.

### LLC Resonant

Wykorzystuje rezonans transformatora. Najwyższa sprawność.

## Projektowanie flyback (najczęstszy)

### Założenia

- V_in: 200-380 V DC (po prostowniku 230 V AC)
- V_out: 12 V, 2 A (24 W)
- f: 100 kHz
- η: 0,85

### Krok 1: Moc i prądy

```
P_in = P_out / η = 24 / 0,85 = 28 W
```

### Krok 2: Wybór rdzenia

Empirycznie:

```
P [W] = k · A_p · f · ΔB · J

A_p — iloczyn powierzchni (A_e · A_w)
A_e — efektywne pole rdzenia
A_w — powierzchnia okna
```

Dla ferrytu EE/EFD, k ≈ 0,7-1, ΔB ≈ 0,2 T, J ≈ 4-6 A/mm² (HF, krótki czas):

```
A_p [cm⁴] ≈ P · 100 / (k · f · ΔB · J)
        ≈ 28 · 100 / (1 · 100 · 0,2 · 5) ≈ 28 cm⁴
```

Z tablic ferrytów: **rdzeń EFD25 lub ETD29** daje A_p ≈ 0,8-1,5 cm⁴ → potrzebny **EFD30 lub ETD34**.

(Wzory są przybliżone — w praktyce użyj softu producenta jak PI Expert, Ferroxcube SoftFerrite lub Coilcraft inductor calculator).

### Krok 3: Liczba zwojów pierwotnego

Dla flyback z ograniczonym duty cycle (typowo D_max = 0,5):

```
V_in_min · D_max · T = N₁ · A_e · ΔB
N₁ = V_in_min · D_max / (f · A_e · ΔB)
```

Dla V_in_min = 80 V (po prostowniku przy 230 V AC pod obciążeniem), A_e = 0,84 cm² (ETD29), ΔB = 0,2 T:

```
N₁ = 80 · 0,5 / (100 000 · 0,84·10⁻⁴ · 0,2)
   = 40 / 1,68
   = 24 zwoje
```

### Krok 4: Przekładnia

W flyback przekładnia wybierana też na podstawie napięcia na MOSFEcie:

```
V_DSS = V_in_max + (V_out + V_F) · n + spike

n = N₁/N₂
```

Dla MOSFETa 600 V z V_in_max = 380 V, V_out = 12 V, spike ~100 V:

```
600 - 380 - 100 = 120 V dostępne dla odbicia
120 = (12 + 1) · n
n = 9,2
```

### Krok 5: Liczba zwojów wtórnego

```
N₂ = N₁ / n = 24 / 9,2 ≈ 2,6 → 3 zwoje
```

(Korekta: n = 24/3 = 8, sprawdzić — ostatecznie n=8).

### Krok 6: Auxiliary winding (zasilanie sterownika)

Trzecia cewka dla startu sterownika SMPS (np. UC3842). N_aux dobrane na napięcie ~15 V po prostowniku:

```
N_aux = N_2 · (V_aux + V_F) / (V_out + V_F)
     = 3 · 16 / 13 ≈ 4 zwoje
```

### Krok 7: Drut

Pierwotne, prąd RMS (przy duty 0,5 i prądzie szczytowym 1,5 A):

```
I_pri_RMS = I_szczyt · √(D/3) ≈ 0,6 A
S_drut = 0,6 / 5 = 0,12 mm² → drut 0,4 mm
```

Wtórne, prąd RMS:
```
I_sec_RMS = I_out · √((1-D)/3) ≈ 1,6 A
S_drut = 1,6 / 5 = 0,32 mm² → drut 0,65 mm
```

W HF używaj **drutu litz** dla mniejszego efektu naskórkowego!

### Krok 8: Szczelina (gap)

Szczelina chroni rdzeń przed nasyceniem. Wzór:

```
L = N² · A_L
A_L = μ_0 · A_e / (l_g / μ_0 + l_e/μ_r)
```

W praktyce szczelina g = 0,1-1 mm, ustawiana **eksperymentalnie** lub wg datasheet.

Producent często sprzedaje rdzenie z **szlifowaną szczeliną** (np. EFD20-3F3-A100 oznacza A_L=100 nH/N²).

### Krok 9: Sprawdzenie B_max

```
B_max = (N · I_szczyt) · μ_0 / (l_g + l_e/μ_r) ≈ (N · I) · μ_0 / l_g    (dla dominującej szczeliny)
```

Powinno być < 0,3 T (zapas).

## Transformator dwuwyjściowy (np. dla zasilacza komputerowego)

Wiele uzwojeń wtórnych dla różnych napięć (+12 V, +5 V, +3,3 V, ...).

Każde uzwojenie ma swoją liczbę zwojów:
```
N_x = N_2_ref · (V_x + V_F) / (V_2_ref + V_F)
```

W praktyce dokładność niedostateczna — używa się **regulatorów liniowych lub osobnych SMPS** dla precyzyjnych napięć.

## Pomiary transformatora HF

### Indukcyjność pierwotnego

Przy odpiętym wtórnym, mierzysz L_pri **z istniejącą szczeliną**. Typowo:
- Flyback: setki μH – kilka mH
- Forward: kilka mH – setki mH

### Indukcyjność wzajemna

Wzbudź pierwotne i mierz napięcie wtórnego (np. AC generatorem 10 kHz). Stosunek = N₂/N₁.

### Prąd nasycenia

Zwiększaj prąd pierwotnego (z mocnym sterownikiem) i obserwuj — gdy L gwałtownie spadnie = nasycenie.

## Izolacja

Transformator flyback w zasilaczu 230 V musi mieć:
- **Reinforced insulation** (wzmocniona) lub **Double insulation** — między pierwotnym i wtórnym
- Co najmniej 6-7 mm odstępu **creepage and clearance**
- 3 warstwy izolacji (lub Triple Insulated Wire — TIW)
- Wytrzymałość 3-5 kV AC

To **wymóg bezpieczeństwa** — bez tego nie przejdzie certyfikacji CE/UL.

## Snubbery

Pasożytnicze indukcyjności i pojemności wywołują **iglice napięciowe** przy wyłączaniu MOSFETa. Trzeba je tłumić:

### RCD snubber (pierwotne)

```
       D ── ▷│── 
   ●───┘     │
   │       [R]   szlifuje energię
   │         │
   │        [C]
   │         │
   ●─────────●
```

Rezystor 22-100 kΩ, kondensator 1-10 nF.

### Wtórny snubber

RC równolegle do diody Schottky tłumi ringing.

## Krzykające trafo

Czasem słychać "świst" z transformatora SMPS. Przyczyny:
- Tryb pracy poniżej 20 kHz (audio)
- Rezonans mechaniczny rdzenia
- Brak nasączenia / luzy w pakiecie

Rozwiązanie: **kropla kleju** (epoxy, hot glue) między rdzeniem a karkasem. Lub zmiana częstotliwości pracy.

## Trudność i polecane podejście

Projektowanie transformatorów HF dla flyback jest **trudniejsze** niż dla zasilaczy liniowych. Polecane:

1. **Użyj softu** — PI Expert, Ferroxcube SoftFerrite, Würth REDEXPERT
2. **Skopiuj sprawdzony projekt** — datasheets podają konkretne transformatory
3. **Zamów gotowy** — Würth, Coilcraft, Trideltal — wiele standardowych
4. **Konsultuj z producentami rdzenia**

## Typowy transformator flyback w USB charger

- Rdzeń: EE13 / EE19 / EFD15 (ferryt 3F3 lub PC44)
- Pierwotne: 100-200 zwojów drutu 0,1-0,2 mm
- Wtórne: 8-15 zwojów drutu 0,3-0,5 mm (z TIW)
- Auxiliary: 5-8 zwojów
- Szczelina: 0,1-0,3 mm
- Częstotliwość: 65-100 kHz
- Moc: 5-20 W

## Częste błędy

1. **Brak szczeliny w flyback** — natychmiastowe nasycenie, palony MOSFET.
2. **Za dużo zwojów pierwotnego** — nie wchodzi w okno, lub straty miedziane za duże.
3. **Drut lity zamiast litz w HF** — straty efektem naskórkowym, grzanie.
4. **Niewłaściwa orientacja zwojów** — fazy odwrotne, sygnał wtórny w zerowej polaryzacji.
5. **Słaba izolacja pierwotny-wtórny** — przebicie, śmierć użytkownika urządzenia.
6. **Brak snubbera** — MOSFET trzeszczy od spikes 1000 V.
7. **Niedostateczne nasączenie lakierem** — krzykające transformatory.
8. **Pomyłka materiału ferrytu** — N87 zamiast N97 → straty 2× większe przy 200 kHz.
