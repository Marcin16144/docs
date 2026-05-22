# 02-03: Cewki / induktory

## Czym jest cewka

Element bierny gromadzący energię w **polu magnetycznym**. Fizycznie to nawinięty drut — pojedyncza zwojnica lub na rdzeniu (ferrytowym, żelaznym, powietrznym).

Symbol: `──UUUU──` (powietrzna), `──UUUU──` z dwiema kreskami nad/pod = rdzeń ferromagnetyczny. Oznaczenie schematowe: **L1, L2...**

## Indukcyjność

**Indukcyjność L** to zdolność cewki do tworzenia pola magnetycznego przy danym prądzie.

```
U_L = L · dI/dt        [V = H · A/s]
```

Cewka **przeciwstawia się zmianom prądu** — gdy prąd rośnie, cewka generuje napięcie wsteczne; gdy maleje, generuje napięcie wymuszające.

Jednostka: **henr (H)**.

| Wartość | Typowe zastosowanie |
|---------|--------------------|
| nH (nanohenry) | RF, drobne sygnały HF |
| μH (mikrohenry) | filtry SMPS, RF |
| mH (milihenry) | filtry audio, dławiki |
| H (henr) | sieciowe dławiki, transformatory |

## Reaktancja indukcyjna

```
X_L = 2π·f·L            [Ω]
```

- Dla DC (f=0): X_L = 0 → cewka to **zwykły drut**
- Dla wysokich częstotliwości: X_L → ∞ → cewka **blokuje AC**

Czyli odwrotnie niż kondensator! Stąd pary L-C w filtrach.

### Przykład

L = 10 mH, f = 50 Hz:
```
X_L = 2π · 50 · 0,01 = 3,14 Ω
```

Ta sama cewka przy 1 kHz:
```
X_L = 62,8 Ω
```

## Wzór na indukcyjność solenoidu

Dla cewki cylindrycznej:

```
L = (μ · N² · S) / l

μ — przenikalność magnetyczna materiału rdzenia [H/m]
N — liczba zwojów
S — pole przekroju [m²]
l — długość cewki [m]
```

Dla **rdzenia powietrznego** μ = μ₀ = 4π·10⁻⁷ H/m ≈ 1,26·10⁻⁶ H/m.

Z rdzeniem ferromagnetycznym μ jest dziesiątki do tysiące razy większe → dużo większa indukcyjność przy tej samej liczbie zwojów.

### Liczba zwojów rośnie z **kwadratem**

To kluczowe! Dwa razy więcej zwojów = cztery razy większa indukcyjność.

## Energia gromadzona w cewce

```
E = ½ · L · I²
```

Stąd ważna zasada: **prąd przez cewkę nie zmieni się skokowo**. Próba przerwania prądu w indukcyjności = ogromne napięcie (samoindukcja), iskra, przebicie izolacji.

Stąd diody zwrotne (freewheeling) przy przekaźnikach i silnikach!

## Rdzenie magnetyczne

### Powietrzny

Brak rdzenia. Pojemność wytwarzania pola: minimalna. Brak nasycenia. Stosowane w cewkach RF (radia, anteny).

### Ferrytowy

Spiek żelaza z innymi metalami. Wysoka przenikalność, mała przewodność elektryczna → małe straty wiroprądowe. Pracuje do MHz.

Rodzaje rdzeni ferrytowych:
- **Mn-Zn** — niskie/średnie częstotliwości (do 1 MHz), wysokie μ
- **Ni-Zn** — wysokie częstotliwości (do 100 MHz), niższe μ

Kształty: pierścień (toroidal), E-I, U, kubki (pot core), drum, koraliki.

### Żelazny laminowany (sheet steel)

Cienkie blaszki żelazowe izolowane od siebie. Stosowane w transformatorach sieciowych 50/60 Hz. Wysoka indukcja, ale tylko niskie częstotliwości.

### Żelazo proszkowe (iron powder)

Proszek żelaza w spoiwie. Pośrednie pomiędzy ferrytem a blachą. Dławiki w zasilaczach impulsowych.

### Amorficzny / nanokrystaliczny

Najnowsze. Bardzo niskie straty, drogie. Wysokiej klasy transformatory.

## Typy cewek

### Powietrzne (RF)

Pojedyncza warstwa drutu na karkasie. Anteny, oscylatory HF.

### Z rdzeniem ferrytowym

Najczęstsze w elektronice cyfrowej i SMPS. Małe wymiary, średnie indukcyjności.

### Dławiki

Cewka stosowana do **blokowania AC** (przy przepuszczeniu DC). W filtrach EMI, zasilaczach.

### Cewki SMD

Małe pakowane cewki na PCB. Często widoczne jako prostokątne kostki czarne lub brązowe.

### Koraliki ferrytowe

"Naciągnięte" na przewód. Tłumią zakłócenia HF, są reaktorem o rosnącej impedancji z częstotliwością. Zaczepione często na kablach USB, HDMI.

### Transformatory

Specjalny przypadek cewki — dwie cewki sprzężone wspólnym polem magnetycznym (osobny rozdział 06).

## Wzór dla cewki na rdzeniu (przybliżenie)

Dla rdzenia ferrytowego z **A_L** podanym w danych katalogowych (indukcyjność jednego zwoju):

```
L = N² · A_L
```

Przykład: rdzeń ETD29 z A_L = 100 nH/N². Chcemy L = 100 μH:
```
100 μH = N² · 100 nH
N² = 100·10⁻⁶ / 100·10⁻⁹ = 1000
N = √1000 ≈ 32 zwoje
```

Wzór jest przybliżony — w rzeczywistości materiał ma nasycenie i nieliniowość.

## Nasycenie magnetyczne

Każdy rdzeń ma maksymalną indukcję B_max. Po przekroczeniu — μ spada do wartości powietrza, cewka traci indukcyjność. Charakterystyka B-H zakrzywia się i wypłaszcza.

Kluczowe w zasilaczach impulsowych: zbyt duży prąd = nasycenie = brak indukcyjności = lawinowe rozladowanie i spalenie.

```
B_max:
- ferryt Mn-Zn: 0,3-0,5 T
- ferryt Ni-Zn: 0,2-0,3 T
- żelazo: 1,5-2,0 T
- amorficzny: 1,2-1,5 T
```

Stąd: rdzeń ferrytowy musi być większy niż żelazny dla tej samej mocy.

## Straty w cewce

### Straty miedziane (P_Cu)

Zwykłe straty na rezystancji drutu:
```
P_Cu = I² · R_drut
```

Dla AC dochodzi **efekt naskórkowy** (skin effect) — prąd płynie powierzchnią drutu. Stąd:
- Lity drut dla niskich częstotliwości
- Drut typu **litz** (wiele cienkich izolowanych żył) dla wysokich częstotliwości

### Straty w rdzeniu (P_Fe)

- **Histeretyczne** — energia rozpraszana przy odwracaniu magnetyzacji. Rośnie z częstotliwością.
- **Wiroprądowe** — prądy indukowane w rdzeniu. Stąd laminowanie blach.

Razem straty rdzenia rosną z f i B_max.

## Parametry katalogowe cewki

| Parametr | Znaczenie |
|----------|-----------|
| L | indukcyjność |
| I_rated | znamionowy prąd ciągły |
| I_sat | prąd nasycenia (przy spadku L o 10-30%) |
| DCR | rezystancja DC drutu |
| SRF | częstotliwość rezonansu własnego |
| Q | dobroć (X_L / R) |

**SRF** to bardzo ważny parametr — powyżej tej częstotliwości cewka zaczyna zachowywać się jak kondensator (przez pojemność własną).

## Łączenie cewek

### Szeregowe (bez sprzężenia)

```
L = L1 + L2 + ...
```

### Równoległe (bez sprzężenia)

```
1/L = 1/L1 + 1/L2 + ...
```

Działa to jak rezystancje, ale tylko gdy cewki **nie są sprzężone magnetycznie**. Sprzężone = trzeba uwzględnić indukcyjność wzajemną M.

## Samodzielne nawijanie cewki

### Powietrzna, cylindryczna (RF, antena, oscylator)

Wzór praktyczny (cewka jednowarstwowa, jednostki w cm):

```
L [μH] = (a · N)² / (9a + 10b)

a — średnica cewki w cm
b — długość cewki w cm
N — liczba zwojów
```

Przykład: cewka 1 μH na karkasie ⌀10 mm.
a = 1 cm, b = długość ≈ 1 cm. Szukamy N:
```
1 = N² / (9 + 10) = N² / 19
N² = 19
N ≈ 4-5 zwojów
```

### Na rdzeniu toroidalnym

Z A_L katalogu rdzenia:
```
N = √(L / A_L)
```

Przykład: rdzeń T50-2 (żółto-szary) ma A_L = 49 nH/N². Chcemy L = 10 μH:
```
N = √(10·10⁻⁶ / 49·10⁻⁹) = √204 ≈ 14 zwojów
```

### Wskazówki

- Zwoje muszą być **rozłożone równomiernie** na rdzeniu
- Drut emaliowany — sprawdź izolację po nawinięciu (multimetr między drutem a rdzeniem)
- Po nawinięciu zaimpregnować lakierem (stabilność mechaniczna)
- Dla wielu zwojów — wyznacz prosty wskazównik na cewce, by nie zgubić liczby

## Cewka jako filtr

### Dolnoprzepustowy (LP)

Cewka szeregowo + kondensator równolegle.

```
   ──UUUU──┬──→ wyjście
            │
           ─┴─ C
            ─
            │
           GND
```

Częstotliwość odcięcia:
```
f_c = 1 / (2π · √(L·C))
```

Powyżej f_c sygnał jest tłumiony.

### Górnoprzepustowy (HP)

Kondensator szeregowo + cewka równolegle. Odwrotna konfiguracja.

### Wnikowy / wycinkowy (band pass / stop)

Bardziej złożone. L i C dopasowane do f_0.

## Zastosowania cewek

### 1. Filtry zasilania

Razem z kondensatorem tworzą filtr LC.

### 2. Dławik w zasilaczu impulsowym

Magazyn energii w przetwornicy. Wartość: 10 μH – 1 mH zwykle.

### 3. Dławik w sieci 50 Hz

Tłumi zakłócenia EMI. Symetryczny (common mode choke) — dwie cewki na jednym rdzeniu.

### 4. Antena

Cewka + kondensator zmienny dostraja do żądanej częstotliwości radia.

### 5. Przekaźnik

Cewka + jarzmo żelazne + sprężyna styków. Prąd → magnesowanie → przyciąga jarzmo → przełącza styki.

### 6. Silnik

Wirujące pole magnetyczne wytwarzane cewkami stojana, oddziałuje z rotorem.

## Pasożytnicze efekty

Cewka w rzeczywistości to:
- Indukcyjność (L)
- Rezystancja DC (DCR)
- Pojemność między zwojami (Cp)
- Straty w rdzeniu

Model zastępczy: L szeregowo z DCR, Cp równolegle do całości. Powstaje obwód rezonansowy z SRF.

## Niebezpieczeństwo cewek

Przerywanie prądu w cewce → ogromne przepięcie (samoindukcja). Stąd:

### Dioda freewheel

Równolegle do przekaźnika lub silnika DC:

```
   ┌───●────────┐
   │   │        │
   │  ─┴─       
   │  ▲ ▷    cewka
   │   │        │
   └───┴────────┘
```

Dioda zwrócona katodą do plusa. Przy przerwaniu prądu indukowane napięcie zamknie się przez diodę. Bez niej tranzystor sterujący wybucha.

### Snubber RC

Dla AC i wysokich napięć — rezystor szeregowo z kondensatorem równolegle do cewki. Tłumi przepięcia.

## Wybór cewki — checklist

1. **Jaka indukcyjność**? (z wzorów filtra/SMPS)
2. **Jaki prąd znamionowy** ciągły?
3. **Jaki prąd szczytowy** (impulsowy w SMPS)?
4. **Jaka częstotliwość pracy**?
5. **Jaki SRF** wymagany?
6. **Jaka DCR** (wpływa na sprawność)?
7. **Typ rdzenia** (ferryt/proszek/powietrze)?
8. **Wymiary** i typ montażu?

## Częste błędy

1. **Brak diody freewheel** przy cewkach sterowanych tranzystorem → uszkodzenie tranzystora.
2. **Przekroczenie I_sat** → utrata indukcyjności → katastrofa w SMPS.
3. **Powietrzna cewka w polu rozproszonym** transformatora → indukowanie, zakłócenia.
4. **Litza zastąpiona litym drutem przy 100 kHz** → wzrost strat, przegrzanie.
5. **Cewka SMD lutowana profilem rozdmuchującym rdzeń** — niektóre rdzenie nie znoszą szoku termicznego.
