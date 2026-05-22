# 03-01: Dioda — podstawy

## Czym jest dioda

Element półprzewodnikowy, który **przewodzi prąd tylko w jednym kierunku**. Najprostszy element aktywny.

Symbol: `──▷│──` Strzałka pokazuje kierunek przewodzenia (od anody A do katody K).

```
   A ──▷│── K
   anoda    katoda
```

Polaryzacja:
- **Przewodzenie (forward)** — plus na anodzie, minus na katodzie. Prąd płynie.
- **Zaporowa (reverse)** — odwrotnie. Prąd praktycznie 0.

## Złącze PN — zasada działania

Dioda to **złącze PN** w krzemie (lub germanie):

- **P** — półprzewodnik z domieszkami akceptorowymi → nadmiar "dziur" (nośników dodatnich)
- **N** — z domieszkami donorowymi → nadmiar elektronów

Na granicy P-N powstaje **obszar zubożony** (depletion region) — bariera potencjału, którą trzeba pokonać.

## Charakterystyka U-I

```
I [mA]
  │
  │      ┌──────  przewodzenie (mocno rośnie po U_F)
  │     /│
  │    / │
  │   /  │
──┼──/───┼──── 0
  │ /    │
  │/     │
  │      │
  │U_BR  │U_F  U
  ──┼────┼──
  zaporowe
   │
   ▼ przebicie
```

### Parametry kluczowe

| Parametr | Symbol | Typowe wartości |
|----------|--------|----------------|
| Napięcie przewodzenia | U_F | 0,2-0,3 V (Schottky), 0,6-0,7 V (Si), 0,3 V (Ge), 2-4 V (LED) |
| Maksymalne napięcie zaporowe | U_R, U_BR | 50 V – 1000 V (i więcej) |
| Maksymalny prąd przewodzenia | I_F | 100 mA – 100 A |
| Prąd zaporowy | I_R | nA – μA |
| Czas wyłączania | t_rr | ns – μs |

## Typy diod

### Prostownicza krzemowa (1N4001-1N4007)

Standard. 1 A, 50-1000 V. Do prostowania sieci 50 Hz, ogólnego zastosowania.

| Model | U_R |
|-------|-----|
| 1N4001 | 50 V |
| 1N4002 | 100 V |
| 1N4003 | 200 V |
| 1N4004 | 400 V |
| 1N4005 | 600 V |
| 1N4006 | 800 V |
| 1N4007 | 1000 V |

Wolna (t_rr ≈ 30 μs). NIE nadaje się do SMPS.

### Mostek prostowniczy

Cztery diody w jednej obudowie. Oznaczenia: ~ (AC), + (DC plus), − (DC minus).

Modele: B40, B80, KBPC, GBPC. Prądy: 1-50 A.

### Szybka prostownicza (UF4007, BYV)

Czas wyłączania < 100 ns. Do SMPS, falowników.

### Schottky

Złącze metal-półprzewodnik (zwykle krzem-aluminium lub krzem-tytan). 

**Zalety:**
- Niskie U_F (0,2-0,4 V)
- Bardzo szybkie (ps – ns)
- Brak ładunku gromadzonego

**Wady:**
- Niskie napięcia zaporowe (zwykle do 100 V)
- Wyższy prąd upływu I_R
- Wrażliwa na temperaturę

Przykłady: 1N5817 (1A/20V), 1N5822 (3A/40V), MBR1045 (10A/45V).

Stosowane: SMPS niskonapięciowe, ochrona ujemnego napięcia, sterowanie MOSFET.

### Sygnałowe (1N4148, 1N914)

Mała, szybka, niski prąd (do 200 mA). Do układów logicznych, detektorów, kluczy. Charakterystyka logarytmiczna — używana w obwodach analogowych.

### Mocy (np. 1N5408)

Do 3 A, prosta. Ogólnego użytku w zasilaczach.

### Lawinowa (avalanche-rated)

Może bezpiecznie pracować w obszarze przebicia lawinowego — pochłania energię indukcyjnych przepięć (zamiast Zenera + zwykłej diody).

## Tor wzór diody (Shockleya)

W idealnym modelu:

```
I = I_S · (e^(U/nV_T) − 1)

I_S — prąd nasycenia (~10⁻¹²-10⁻⁸ A)
n   — współczynnik idealności (1-2)
V_T — napięcie termiczne (≈ 25 mV w 25°C)
```

W praktyce diodę modeluje się jako:
- Idealny przełącznik włączony przy U > U_F
- Stałe napięcie U_F (0,7 V dla Si)
- Lub szeregowo R_F + U_F (lepiej, ale rzadko potrzebne)

## Najważniejsze zastosowania

### 1. Prostownik półfalowy

Pojedyncza dioda. Tylko dodatnia połówka sinusa przechodzi.

```
   AC ──┤▷├── + ────► obciążenie
         │            │
         │            │
   AC ──────────────► − (masa)
```

Sprawność ~40%. Wykorzystywany tylko w małych mocach (sygnalizacja LED, ładowanie pamięci).

### 2. Prostownik dwupołówkowy (Graetz / mostek)

Cztery diody, obie połówki sinusa są prostowane.

```
        ─▷│─┬─▷│─
              │
   AC ──┐    + DC
        │    │
        │    │
   AC ──┘    
              │
        ─▷│─┴─▷│─
              − DC
```

Sprawność ~95%. Standard.

### 3. Prostownik z dzielonym uzwojeniem (full-wave center-tap)

Transformator z odczepem środkowym + 2 diody. Standardowo używany do +/− symetrycznych zasilaczy.

### 4. Dioda freewheel (zwrotna)

Równolegle do cewki (przekaźnik, silnik) z polaryzacją zaporową. Gdy prąd przez cewkę zostaje przerwany — dioda krótko spina cewkę, energia rozproszuje się.

Bez niej napięcie indukowane uszkodzi tranzystor sterujący.

### 5. Ochrona przed odwrotną polaryzacją

Dioda szeregowo w zasilaniu. Gdy podłączysz baterię na odwrót — dioda zablokuje. Wada: spadek 0,7 V (lub mniej Schottky).

Alternatywa: MOSFET z lustrzanym body diodem (P-MOS w plusie zasilania) — minimalne straty.

### 6. Klamra (clamp)

Dioda na wejściu cyfrowym zwierająca do plusa zasilania i masy. Ogranicza napięcie do bezpiecznego zakresu (chroni przed ESD i przepięciem).

### 7. Multiplikator napięcia (Cockcroft-Walton)

Drabinki kondensatorów i diod podnoszą napięcie krotnie. CRT TV używały tego do anodowego 25 kV.

### 8. Detektor sygnału AM

Dioda Ge (niskie U_F) + filtr RC — wydobywa obwiednię sygnału radiowego.

## Łączenie diod

### Szeregowo

Sumują się U_F, ale prąd ten sam. Stosowane do podniesienia napięcia zaporowego (z rezystorami wyrównującymi).

### Równolegle

Ten sam U na każdej, prąd się dzieli. **Niebezpieczne** — dioda z niższym U_F bierze cały prąd. Stosuje się rezystory wyrównujące.

## Parametry praktyczne

### Spadek napięcia U_F

Niezależny od prądu? Nie do końca. Rośnie logarytmicznie:

```
ΔU_F ≈ 0,1 V przy 10× wzroście prądu
```

Przy 1 A: 0,7 V. Przy 10 A: ~0,9 V. Stąd straty mocy 9 W przy 10 A.

### Prąd zaporowy I_R

Rośnie z temperaturą — podwaja się co ~10°C. Schottky ma 100× większy niż Si pn.

### Czas wyłączania t_rr

Czas potrzebny do "odzyskania" stanu blokady po wyłączeniu prądu. Krytyczny w SMPS.

```
Standard 1N4007:  ~30 μs
UF4007:           ~75 ns  
Schottky:         < 10 ns
```

## Moc i chłodzenie

```
P = U_F · I_F
```

Dla 1N4007 przy 1 A: P ≈ 1 W. Obudowa DO-41 ledwo radzi sobie z 0,5 W bez chłodzenia.

Mostki większych prądów (KBPC, GBPC) mają śrubę do radiatora.

## Wybór diody — checklist

1. **Jaki kierunek prądu** i polaryzacja?
2. **Jaki średni prąd przewodzenia** I_F_AVG?
3. **Jaki prąd szczytowy** I_F_SM (rozruch)?
4. **Jakie napięcie zaporowe** U_R z zapasem 2×?
5. **Jaka częstotliwość pracy**? (do 1 kHz Si; do 50 kHz UF; powyżej Schottky)
6. **Jaki spadek U_F** ma znaczenie? (np. zasilacz 3,3 V)
7. **Jaka temperatura otoczenia**?
8. **Obudowa i montaż**?

## Częste błędy

1. **Zła polaryzacja** — dioda dymi. Katoda zwykle ma pasek na obudowie!
2. **Niewystarczające U_R** — pojedyncza dioda 50 V na sieci 230 V = przebicie.
3. **Brak diody freewheel** przy cewce — uszkodzony tranzystor.
4. **Wolna dioda w SMPS** — przegrzewa się, traci sprawność.
5. **Zbyt mała moc** — dioda dymi przy szczytach prądu (chwilowych).
6. **Schottky z wysokim I_R** w gorącym otoczeniu → znaczne straty na zaporowym.
