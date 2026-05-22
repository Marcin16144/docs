# 05-01: Prostowniki

## Cel prostowania

Sieć dostarcza napięcie zmienne (AC). Większość elektroniki potrzebuje napięcia stałego (DC). **Prostownik** to układ zamieniający AC na DC (najczęściej za pomocą diod).

Standardowo prostujemy napięcie z transformatora obniżającego — sieć 230 V AC → 9-24 V AC → DC.

## Prostownik półfalowy

### Schemat

```
        AC ──┤▷├──┬──── + DC ────► obciążenie
            dioda │
                  │
        AC ───────●──── − DC (GND)
```

Pojedyncza dioda przepuszcza tylko **jedną połówkę** sinusa.

### Wykres napięcia

```
AC wejście:     wyjście:
    /\              /\
   /  \            /  \
  /    \          /    \
─────────────  ─────────────
  \    /
   \  /
    \/         (drugiej połówki nie ma)
```

### Parametry

```
U_DC (średnie)  = U_m / π ≈ 0,318 · U_m
U_DC (po filtrze C) ≈ U_m − U_F     (przy dużym C)

I_dioda_avg = I_obc
I_dioda_szczyt = duży (ładowanie C)
U_R_dioda = U_m     (gdy nie przewodzi)

częstotliwość tętnień = f_sieci (50 Hz)
```

### Wady

- Marnujemy połowę energii sieci
- Niska częstotliwość tętnień (50 Hz) — trudniejszy filtr
- Asymetryczne obciążenie transformatora (prąd DC magnesuje rdzeń)
- Sprawność energetyczna ~40-45%

### Zalety

- Tylko jedna dioda (najtaniej)
- Stosowane: bardzo małe ładowarki, sygnalizacja, podtrzymanie pamięci

## Prostownik dwupołówkowy z odczepem środkowym

### Schemat

```
                ┌─▷├─┐
   transformator       │
   z odczepem    ●─── + DC
   środkowym (CT) │
                  ●─── obciążenie
                ┌─▷├─┘
                
   odczep CT to GND
```

Każda dioda przewodzi po połowie okresu. Wymaga **transformatora z odczepem środkowym** lub dwóch oddzielnych uzwojeń.

### Parametry

```
U_DC = 2 · U_m / π ≈ 0,636 · U_m
częstotliwość tętnień = 2 · f_sieci = 100 Hz
```

Tętnienia 100 Hz — łatwiej filtrować. Sprawność wykorzystania uzwojenia wtórnego: ~80%.

### Stosowanie

Rzadko dziś, oprócz układów z odczepem (np. symetryczne ±15 V z jednego transformatora 2× uzwojenie).

## Prostownik mostkowy (Graetza)

**Standard** w zasilaczach liniowych. Cztery diody w mostku.

### Schemat

```
              D1     D2
        ┌────▷├──┬──▷├────┐
        │        │        │
   ~AC ─┤        +        ├─ ~AC
        │      DC OUT      │
        │        −        │
        ├──▷├──┬──▷├──────┘
              D3     D4
              
   AC wchodzi po obu stronach (~)
   DC wychodzi z + i −
```

### Działanie

Dla pozytywnej połówki: D1+D4 przewodzą.
Dla negatywnej: D2+D3 przewodzą.

Obie połówki sinusa "prostowane" są w plus.

### Wykres

```
AC:        wyjście (przed filtrem):
  /\          /\  /\  /\
 /  \        /  \/  \/  \
─────  ──>  ─────────────
 \  /
  \/
```

### Parametry

```
U_DC (średnie, bez filtra) = 2·U_m/π − 2·U_F ≈ 0,636·U_m − 1,4V
U_DC (z dużym filtrem C)    ≈ U_m − 2·U_F  ≈ U_m − 1,4V

częstotliwość tętnień = 2·f_sieci = 100 Hz

I_dioda_avg = I_obc / 2    (każda dioda przewodzi pół okresu)
I_dioda_szczyt = duży, krótki impuls (ładowanie C)
U_R_dioda = U_m
```

### Spadek napięcia

Dwie diody w drodze prądu → **2 · U_F = 1,4 V** strat (Si). Schottky: ~0,5 V.

Dla niskich napięć (np. 5 V DC z 9 V AC) to spore straty → warto użyć mostka Schottky lub aktywnego prostownika (MOSFETy).

### Mostki w jednej obudowie

Wygodnie kupić gotowy mostek (4 diody w jednej kostce):

| Model | I | U_R | Obudowa |
|-------|---|------|---------|
| B40C800 | 0,8 A | 80 V | DIP-4 |
| B250C1500 | 1,5 A | 250 V | DIP |
| KBPC2510 | 25 A | 1000 V | śrubowy |
| GBU8 | 8 A | 1000 V | obudowa metal |

Wyprowadzenia: ~ ~ (AC), + − (DC).

## Prostownik mostkowy 3-fazowy

Sześć diod, dla zasilaczy przemysłowych z sieci 3-fazowej.

```
U_DC ≈ 1,35 · U_L-L = 1,35 · 400V = 540V DC
```

Tętnienia 6 razy częstotliwość (300 Hz dla 50 Hz). Mały filtr potrzebny.

Stosowane w sprzęcie dużej mocy (spawarki, falowniki przemysłowe).

## Prądy szczytowe

W prostowniku z filtrem C diody przewodzą tylko **krótko** — gdy napięcie wejścia jest wyższe niż napięcie kondensatora. Reszta czasu kondensator zasila obciążenie sam.

### Prąd szczytowy w diodzie

```
I_szczyt = π · I_obc / (1 − cos(α))

α — kąt przewodzenia (zazwyczaj 30-60°)
```

Praktycznie: prąd szczytowy może być **5-10× większy** niż średni prąd obciążenia.

Stąd diody w prostowniku musi wytrzymać krótkie impulsy znacznie wyższe niż prąd ciągły.

### Prąd ładowania transformatora (inrush current)

Po włączeniu zasilania kondensator filtra jest pusty → ogromny prąd ładowania (kilkadziesiąt A). To może:

- Przepalić bezpiecznik
- Uszkodzić diody (przekroczyć I_FSM — Surge current)
- Stuknąć "klik" w sieci

Rozwiązanie: **rezystor inrush** szeregowo w obwodzie (NTC lub stały R 1-10 Ω) lub układ soft-start z przekaźnikiem.

## Mnożniki napięcia

### Podwajacz Greinachera

```
   AC ──[C1]──┬──▷├── DC out (2·U_m)
              │
              ▽
             [C2]
              │
             GND
```

Dwa kondensatory + dwie diody → na wyjściu 2·U_m napięcia szczytowego.

### Drabinka Cockcrofta-Waltona

Wielokrotne stopnie → n·U_m. Klasyczne ekrany CRT (25 kV z 25 V uzwojenia transformatora).

## Dobór elementów — krok po kroku

### Cel

Zaprojektować mostek prostowniczy dla zasilacza 12 V DC, 1 A.

### Krok 1: Transformator

Po prostowniku z filtrem C: U_DC ≈ √2 · U_AC − 1,4 V

Dla 12 V DC + 3 V dropout stabilizatora + 2 V tętnień = 17 V DC minimum.

```
U_AC = (17 + 1,4) / √2 ≈ 13 V
```

Wybór: transformator **15 V AC**, 1,5 A (zapas).

### Krok 2: Mostek

I_AC = I_DC ≈ 1 A (rms).
Diody muszą wytrzymać:
- Średni prąd: 1 A
- Szczytowy: 5-10 A
- U_R: 1,4 · 15 ≈ 21 V → wybór 50 V z zapasem

Wybór: mostek **2 A, 100 V** (KBPC2A04, GBU2D).

### Krok 3: Kondensator filtra

```
C ≥ I_obc / (2 · f · ΔU)
   = 1 / (2 · 100 · 1)
   = 5000 μF
```

Wybór: **4700 μF / 25 V** lub **6800 μF / 25 V** z zapasem.

### Krok 4: Bezpiecznik

W obwodzie pierwotnym (sieciowym):
```
P_sieć = 12 · 1 / 0,7 (sprawność) ≈ 17 W
I_sieć = 17 / 230 ≈ 75 mA
```

Bezpiecznik T 100 mA / 250 V (zwłoczny — kondensator ładujący).

W obwodzie wtórnym (po prostowniku):
- Bezpiecznik T 1,5 A jako zabezpieczenie obciążenia (opcjonalnie).

### Krok 5: NTC inrush (opcjonalnie)

Dla większych zasilaczy (powyżej 50 W) — NTC 5-10 Ω, prąd nominalny powyżej prądu ciągłego. Np. SCK-053 (5 Ω, 3 A).

## Tętnienia DC

Po samym mostku bez filtra: napięcie pulsuje z amplitudą U_m. Z filtrem C tętnienia są małymi "zębami":

```
ΔU = I_obc / (f · C)

ΔU — peak-to-peak tętnień
f  — częstotliwość tętnień (100 Hz dla mostka 50 Hz)
```

Im większy C, tym mniejsze tętnienia.

## Sprawność prostowania

- Półfalowy: ~40%
- Pełnofalowy / mostek: ~80%
- Mostek z filtrem C: ~95% (wliczając filtr)

Pozostałe straty: U_F diód, rezystancja transformatora, prąd magnesowania.

## Aktywny prostownik (synchroniczny)

W niskich napięciach (5 V, 3,3 V) spadek 1,4 V na mostku to dużo. Stosuje się **MOSFETy zamiast diod** — sterowane synchronicznie z fazą sieci.

R_DS(on) MOSFETa = 10-50 mΩ → spadek 10-50 mV przy 1 A. Sprawność znacznie wyższa.

Komplikacja: sterownik (np. LT4320, LT4275). Stosowane w premium SMPS.

## Częste błędy

1. **Niewystarczające U_R diód** — dioda 50 V w prostowniku z transformatora 24 V AC może przebić (szczyt 24·√2 = 34 V, ale przy rozłączeniu transformatora mogą wystąpić iglice).
2. **Brak filtra C** — wyjście pulsuje 100 Hz, niestabilne dla stabilizatora.
3. **Mostek nieoznaczony** — pomyłka AC i DC = mostek na chwilę = uszkodzenie.
4. **Brak NTC w dużym zasilaczu** — wybijanie bezpiecznika przy włączaniu.
5. **C za mały** — duże tętnienia → stabilizator nie nadąża → niestabilność na wyjściu.
6. **C za duży** — ogromny prąd ładowania, uszkodzone diody.
7. **Diody wolne (1N4007) w SMPS** — przegrzewanie się przez t_rr.
