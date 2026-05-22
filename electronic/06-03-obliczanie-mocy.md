# 06-03: Obliczanie mocy transformatora

## Wstęp

Najbardziej praktyczny rozdział tej części. Pokażemy, **jak krok po kroku** zaprojektować transformator sieciowy (50/60 Hz, blacha EI) — od mocy do gotowego rysunku zwojów i drutu.

## Podstawowe dane wyjściowe

Aby zaprojektować transformator, musisz znać:

1. Napięcie pierwotne U₁ (zwykle 230 V AC)
2. Napięcie wtórne U₂ (np. 12 V)
3. Prąd wtórny I₂ (np. 2 A)
4. Częstotliwość f (50 Hz w Europie)

Lub wprost moc P i napięcia.

## Krok 1: Obliczenie mocy

```
P_2 = U_2 · I_2

P_2 — moc wtórna [W lub VA]
```

Dla transformatora wieloraz wtórnego sumujesz wszystkie wyjścia:

```
P_2_total = U_2a · I_2a + U_2b · I_2b + ...
```

### Moc pierwotna

```
P_1 = P_2 / η

η — sprawność, dla małych trafo 0,7-0,85
            dla średnich 0,85-0,92
            dla dużych 0,93-0,97
```

### Przykład

U_2 = 12 V, I_2 = 2 A → P_2 = 24 W.
Mały transformator, η ≈ 0,8.
P_1 = 24 / 0,8 = 30 W.

## Krok 2: Wybór rdzenia (przekroju)

Empiryczny wzór dla blach EI sieciowych:

```
S [cm²] = k · √P

k = 1,0 - 1,2 (uniwersalny)
k = 0,8     (jeśli stosujesz B_max bliskie 1,5T, większe straty)
```

Dla naszego przykładu (P_1 = 30 W):
```
S = 1,1 · √30 ≈ 6 cm²
```

W tablicach blach: **EI54 ma S = 5,7 cm²** — wybieramy ten.

### Dobór rdzenia z dostępnych

| Typ blachy | S [cm²] | Max P [W] |
|------------|---------|-----------|
| EI28 | 1,4 | 5-10 |
| EI38 | 2,8 | 15-25 |
| EI42 | 3,5 | 20-40 |
| EI48 | 4,5 | 40-60 |
| EI54 | 5,7 | 60-90 |
| EI66 | 9,0 | 100-150 |
| EI78 | 12,8 | 200-300 |
| EI96 | 22 | 400-600 |
| EI114 | 35 | 800-1200 |
| EI120 | 41 | 1200-1500 |
| EI150 | 60 | 2000-3000 |

(Tablica orientacyjna. Konkretne wartości zależą od grubości pakietu i jakości blachy.)

### Wpływ grubości pakietu

Wartość S oznacza **rzeczywisty przekrój**:

```
S = a · b · k_p

a — szerokość kolumny środkowej
b — grubość pakietu
k_p — współczynnik wypełnienia (0,9-0,95 dla dobrej blachy)
```

Czyli blacha EI66 z kolumną 22 mm i pakietem 40 mm:
```
S = 2,2 · 4 · 0,93 = 8,2 cm² 
```

(W katalogach blach często można dopasować grubość pakietu pod konkretną moc.)

## Krok 3: Obliczenie zwojów na wolt

Z prawa Faradaya:

```
U/N = 4,44 · f · B_max · S

przy f=50 Hz, S w cm² i B_max=1,2 T:
U/N ≈ 26,6 · 10⁻⁴ · S 

N/U = 1 / (4,44 · 50 · 1,2 · S · 10⁻⁴) = 37,5 / S
```

Wzór praktyczny:

```
N/V ≈ 38 / S    (gdy S w cm², B_max ≈ 1,2 T)
```

Dla S = 5,7 cm²:
```
N/V = 38 / 5,7 = 6,67 zwojów/V
```

(W literaturze radioelektronicznej często N/V = 45/S; różnica wynika z innej B_max.)

## Krok 4: Obliczenie zwojów uzwojeń

```
N_1 = (N/V) · U_1 = 6,67 · 230 = 1534 zwoje
N_2 = (N/V) · U_2 = 6,67 · 12 = 80 zwojów
```

### Korekta dla wtórnego — kompensacja spadku napięcia

Transformator pod obciążeniem ma spadek napięcia 5-15% (regulacja ε). Aby pod obciążeniem dostać dokładnie U_2, dodajemy zwoje:

```
N_2_pop = N_2 · (1 + ε)
```

Dla ε = 0,1 (10%):
```
N_2_pop = 80 · 1,1 = 88 zwojów
```

W ten sposób transformator daje 13-14 V bez obciążenia, ale dokładnie 12 V przy 2 A.

### Gdy chcesz precyzyjnego napięcia — wyprowadź odczepy

Można zostawić odczepy co kilka zwojów (np. co 2-5 zwojów) na końcu uzwojenia. Po pomiarze i obciążeniu dobierasz najlepszy odczep.

## Krok 5: Dobór drutu

### Gęstość prądu (j)

Określa, jaki prąd zniesie drut bez nadmiernego grzania. W praktyce:

| Moc transformatora | j [A/mm²] |
|--------------------|-----------|
| < 50 VA | 4-5 |
| 50-200 VA | 3-3,5 |
| 200-1000 VA | 2,5-3 |
| > 1 kVA | 2-2,5 |

Wyższe gęstości = większe straty I²R, grzanie. Niższe = grubsze druty, większy koszt.

### Wzór na przekrój

```
S_drut [mm²] = I / j
```

### Średnica drutu

```
d = √(4·S/π) ≈ 1,13 · √S
```

### Przykład

Uzwojenie pierwotne. I_1 = P_1/U_1 = 30/230 ≈ 0,13 A.
j = 4 A/mm² (mały transformator):
```
S_drut = 0,13 / 4 = 0,033 mm²
d = 1,13 · √0,033 = 0,205 mm
```

→ Najbliższy standard: **drut 0,2 mm** (lub 0,21 mm).

Uzwojenie wtórne. I_2 = 2 A:
```
S_drut = 2 / 4 = 0,5 mm²
d = 1,13 · √0,5 = 0,8 mm
```

→ Drut **0,8 mm** (lub 0,85 mm).

### Standardowe średnice drutu (mm)

```
0,1  0,12 0,15 0,17 0,2  0,22 0,25 0,28 0,3  0,32
0,35 0,4  0,45 0,5  0,55 0,6  0,7  0,8  0,9  1,0
1,1  1,2  1,3  1,4  1,5  1,6  1,8  2,0  2,2  2,5
```

## Krok 6: Sprawdzenie wypełnienia okna

**Okno** to wolna przestrzeń w rdzeniu na uzwojenie:

```
A_okno = c · h

c — szerokość okna
h — wysokość okna
```

Powierzchnia drutu (z izolacją):

```
A_drut = N_1 · A_drut_pierw + N_2 · A_drut_wtór + ...
```

Współczynnik wypełnienia:

```
k_w = A_drut / A_okno

k_w typowo: 0,3 - 0,5
```

Jeśli k_w > 0,55 → nie pomieści się (zostaw zapas na izolację międzywarstwową, karkas).
Jeśli k_w < 0,2 → możesz użyć grubszego drutu lub mniejszego rdzenia.

### Powierzchnia drutu z izolacją

Drut emaliowany ma izolację dodającą ~0,02-0,04 mm do średnicy:

```
d_zewn = d_drut + 0,03
A_zewn = π · d_zewn² / 4
```

## Pełen przykład projektu — krok po kroku

### Zadanie

Transformator 230 V → 24 V, 3 A. Moc P_2 = 72 W.

### Krok 1: moc, sprawność

η ≈ 0,87 (dla 70-80 W jest to typowe).
P_1 = 72 / 0,87 = 82 W.

### Krok 2: rdzeń

S = 1,1 · √82 = 10 cm².

→ Wybór: **EI66** (S = 9 cm² z pakietem 30 mm) lub **EI78** z mniejszym pakietem.

Niech to będzie **EI66, pakiet 35 mm** dający S = 10,5 cm² (lekki zapas).

### Krok 3: zwoje na wolt

```
N/V = 38 / 10,5 ≈ 3,6
```

### Krok 4: zwoje

```
N_1 = 3,6 · 230 = 828 zwojów
N_2 = 3,6 · 24 · 1,1 (z kompensacją 10%) = 95 zwojów
```

### Krok 5: druty

```
I_1 = 82 / 230 = 0,36 A
S_drut_1 = 0,36 / 3,5 = 0,103 mm² → d = 0,36 mm → drut 0,35-0,4 mm
I_2 = 3 A
S_drut_2 = 3 / 3,5 = 0,86 mm² → d = 1,05 mm → drut 1,0 mm
```

### Krok 6: sprawdzenie

Okno EI66 (typowo): 21 mm × 12 mm = 252 mm². Z karkasem efektywnie ~200 mm².

Powierzchnia drutu:
```
A_1 = 828 · π · 0,4² / 4 ≈ 104 mm²    (z izolacją)
A_2 = 95 · π · 1,03² / 4 ≈ 79 mm²
A_total = 183 mm²

k_w = 183 / 200 = 0,92
```

UPS — okna prawie 100% pełne. Trzeba:
- Zwiększyć rdzeń (większy EI78 z większym oknem)
- Lub zmniejszyć j (cieńsze druty? niemożliwe, byłyby się grzały)
- Lub zwiększyć B_max (mniejsza ilość zwojów, ale więcej strat rdzenia)

Wybierz **EI78** z S = 12,8 cm² i większym oknem:

```
N/V = 38 / 12,8 = 2,97 zwojów/V
N_1 = 683 zwoje
N_2 = 78 (z kompensacją)
```

Powierzchnia:
```
A_1 = 683 · 0,126 ≈ 86 mm²
A_2 = 78 · 0,83 ≈ 65 mm²
A_total = 151 mm²
```

Okno EI78 ma ok. 280 mm² → k_w = 151/280 = 0,54. Tak, mieści się z zapasem.

### Krok 7: weryfikacja i dokumentacja

Spisz na kartce:
- Rdzeń: blacha EI78, pakiet 40 mm
- Uzwojenie 1: 683 zwoje drut 0,4 mm emaliowany
- Uzwojenie 2: 78 zwojów drut 1,0 mm emaliowany
- Sprawdzić indukcję B = U / (4,44·f·N·S) = 230 / (4,44·50·683·12,8·10⁻⁴) = 1,18 T ✓

## Tabela szybkich obliczeń (oświęcimska)

Dla blach EI sieciowych 50 Hz, typowe wartości:

| Moc [W] | Rdzeń | S [cm²] | N/V | I_1 [A] @ 230V |
|---------|-------|---------|-----|----------------|
| 5 | EI28 | 1,4 | 27 | 0,025 |
| 10 | EI30 | 2,0 | 19 | 0,05 |
| 20 | EI38 | 2,8 | 14 | 0,1 |
| 30 | EI42 | 3,5 | 11 | 0,15 |
| 50 | EI54 | 5,7 | 6,7 | 0,25 |
| 80 | EI66 | 9 | 4,2 | 0,4 |
| 120 | EI66x40 | 11 | 3,5 | 0,6 |
| 200 | EI78 | 14 | 2,7 | 1 |
| 300 | EI96 | 22 | 1,7 | 1,5 |
| 500 | EI114 | 35 | 1,1 | 2,5 |
| 1000 | EI120x60 | 50 | 0,8 | 5 |

## Toroidalny transformator

Dla toroidu zwykle korzysta się z gotowych rdzeni z parametrami:
- A_e — efektywne pole przekroju
- l_e — efektywna droga
- W — moc znamionowa

Producent podaje **moc nominalną**, co znacznie ułatwia projekt. Typowo wybierasz rdzeń o mocy 1,1-1,3× zaprojektowanej.

Liczba zwojów na wolt dla toroidu o S [cm²]:

```
N/V = 35-45 / S
```

(różni się dla różnych dostawców).

## Częste pułapki

### 1. Pomyłka z mocą czynną i pozorną

Transformator dobiera się na **moc pozorną S [VA]**, nie czynną P [W]. Dla obciążenia indukcyjnego (silnik z cos φ = 0,8): S = P / cos φ = P · 1,25.

### 2. Trafo zaprojektowany za blisko nasycenia

B_max = 1,5 T (blisko granicy) → straty rośną, hałas, niska sprawność. Bezpiecznie 1,1-1,3 T.

### 3. Zbyt cienki drut

Przegrzanie, spalenie izolacji, zwarcie. Lepiej dobrać z zapasem.

### 4. Pomyłka w zwojach

Zwykle błąd 10-20% napięcia. Lepiej zostawić odczepy do regulacji.

### 5. Pęcherzyki powietrza w pakiecie

Trafo "buczy". Trzeba mocno skręcić blachy, nasycić lakierem.

### 6. Niewłaściwa zwykła blacha zamiast trafo

"Czarna" blacha = wysokie straty. Trafo wymaga blachy krzemowej.

### 7. Brak izolacji między uzwojeniami

Przebicie z 230 V na 12 V → groźne. Zawsze warstwa papieru elektroizolacyjnego (Nomex, Kapton) lub folii Mylar.

## Wzór końcowy — szybka kalkulacja

Dla małego transformatora 50 Hz, blacha EI:

```
S [cm²]  ≈ √P [W]
N/V      ≈ 40/S
I        = P/U
d_drut   ≈ 0,7 · √I    [mm, dla j=3 A/mm²]
```

Da rozsądny punkt startu. Doszlifowujesz w trakcie projektowania.

## Następny krok

Mając obliczone parametry, można zacząć **przewijać transformator** — to temat kolejnego rozdziału (06-04).
