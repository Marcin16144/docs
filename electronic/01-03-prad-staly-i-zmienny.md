# 01-03: Prąd stały i zmienny (DC / AC)

## Czym się różnią

**Prąd stały (DC — Direct Current):** kierunek przepływu i wartość są stałe w czasie. Bateria, akumulator, zasilacz po prostowaniu.

**Prąd zmienny (AC — Alternating Current):** kierunek i wartość zmieniają się okresowo. Sieć energetyczna, sygnały audio, radio.

```
DC (bateria):              AC (sieć 50 Hz):
                                    ___          ___
   ────────────              ___  /   \    ___  /   \
                            /   \/     \  /   \/     \
                           /            \/            \
   napięcie stałe         sinusoida
   w czasie               20 ms okresu
```

## Prąd stały (DC)

### Źródła DC

- Bateria, akumulator
- Zasilacz po prostowniku i filtracji
- Ogniwo fotowoltaiczne
- Termopara
- Prądnica DC (rzadko)

### Zalety DC

- Łatwy do magazynowania (baterie)
- Łatwy do regulacji (PWM, stabilizator)
- Bezpieczniejszy przy małych napięciach
- Nie powoduje zaburzeń EMI w taki sposób jak AC

### Wady DC

- Trudny do transformacji napięcia (bez przetwornicy)
- Straty w długich liniach
- W historii — przegrał z AC w "wojnie prądów" (Edison vs Tesla/Westinghouse)

## Prąd zmienny (AC)

### Dlaczego sieć jest AC

- **Łatwa transformacja napięcia** — transformator zmienia napięcie bez ruchomych części, z wysoką sprawnością
- **Mniejsze straty na liniach** — wysokie napięcia = małe prądy = mniejsze straty I²R
- **Łatwe wyłączanie** — łuk elektryczny gaśnie sam, gdy prąd przechodzi przez zero (100× na sekundę dla 50 Hz)
- **Silniki indukcyjne** — proste, niezawodne, bez szczotek

### Parametry sygnału sinusoidalnego

```
u(t) = U_m · sin(2π·f·t + φ)

U_m   — wartość maksymalna (amplituda)
f     — częstotliwość [Hz]
φ     — faza początkowa [rad]
t     — czas [s]
```

#### Wartości charakterystyczne

| Wielkość | Symbol | Wzór dla sinusoidy |
|----------|--------|-------------------|
| Wartość szczytowa | U_m, U_peak | amplituda |
| Wartość międzyszczytowa | U_pp | 2·U_m |
| Wartość średnia (półokres) | U_avg | (2/π)·U_m ≈ 0,637·U_m |
| Wartość skuteczna (RMS) | U_RMS | U_m / √2 ≈ 0,707·U_m |

#### Przykład — sieć 230 V

Gdy mówimy "sieć 230 V", to wartość **skuteczna**.

```
U_RMS = 230 V
U_m   = 230 · √2 ≈ 325 V
U_pp  = 2 · 325 = 650 V
```

Czyli izolacja w urządzeniach musi wytrzymać 650 V szczytowe (a w praktyce więcej — przepięcia).

### Częstotliwość sieci

| Region | Częstotliwość | Napięcie |
|--------|--------------|----------|
| Europa, Afryka, Australia | 50 Hz | 230 V |
| USA, Kanada, Brazylia | 60 Hz | 110-120 V |
| Japonia (wschód) | 50 Hz | 100 V |
| Japonia (zachód) | 60 Hz | 100 V |

50 Hz oznacza, że jeden okres trwa T = 1/50 = 20 ms.

### Wartość skuteczna — co to znaczy

**RMS (Root Mean Square)** to taka wartość prądu stałego, która rozprasza taką samą moc na rezystorze.

Innymi słowy: 230 V AC RMS grzeje rezystor tak samo jak 230 V DC.

Wzór ogólny:
```
U_RMS = √(1/T · ∫ u²(t) dt)
```

Dla różnych przebiegów:

| Przebieg | RMS w funkcji U_m |
|---------|-------------------|
| Sinusoida | U_m / √2 ≈ 0,707·U_m |
| Prostokątny (50%) | U_m |
| Trójkątny | U_m / √3 ≈ 0,577·U_m |
| Piłokształtny | U_m / √3 ≈ 0,577·U_m |

## Faza i przesunięcie fazowe

Dwa sygnały o tej samej częstotliwości mogą być przesunięte w czasie. Mierzymy to kątem fazowym φ (radianach lub stopniach).

```
u1(t) = U_m · sin(ωt)
u2(t) = U_m · sin(ωt − π/2)    ← opóźnione o 90°
```

Przesunięcie fazowe jest kluczowe w analizie obwodów AC z cewkami i kondensatorami.

### Reaktancja

W obwodach AC kondensatory i cewki stawiają opór nazywany **reaktancją** (X). Zależy od częstotliwości.

#### Reaktancja kondensatora (X_C)

```
X_C = 1 / (2π·f·C)        [Ω]
```

- Im wyższa częstotliwość — tym mniejsza reaktancja
- Dla DC (f=0): X_C = ∞ (kondensator nie przewodzi DC)
- Prąd wyprzedza napięcie o 90°

#### Reaktancja cewki (X_L)

```
X_L = 2π·f·L              [Ω]
```

- Im wyższa częstotliwość — tym większa reaktancja
- Dla DC (f=0): X_L = 0 (cewka to zwykły drut dla DC)
- Napięcie wyprzedza prąd o 90°

### Impedancja (Z)

Wypadkowy opór w AC z uwzględnieniem rezystancji i reaktancji:

```
Z = √(R² + (X_L − X_C)²)
```

W zapisie zespolonym:
```
Z = R + j(X_L − X_C)
```

## Moc w obwodzie AC

W AC trzeba odróżniać trzy moce:

### Moc czynna (P)

Realnie zamieniana na ciepło, ruch, światło. Mierzona w **watach (W)**.

```
P = U_RMS · I_RMS · cos(φ)
```

### Moc bierna (Q)

"Latająca" między źródłem a obciążeniem (cewki, kondensatory). Nie wykonuje pracy. Mierzona w **warach (var)**.

```
Q = U_RMS · I_RMS · sin(φ)
```

### Moc pozorna (S)

Wektorowa suma czynnej i biernej. Mierzona w **woltoamperach (VA)**.

```
S = U_RMS · I_RMS
S² = P² + Q²
```

### Współczynnik mocy (cos φ)

```
cos(φ) = P / S
```

Idealny: 1 (czysto rezystancyjne obciążenie).
Silnik indukcyjny: 0,7-0,9.
Stara świetlówka: 0,4-0,5.

Niski cos φ = nieefektywne wykorzystanie sieci. Energetyka karze za niski cos φ przy dużych odbiorach.

## Sieć trójfazowa

W przemyśle (i większych zasilaniach) stosuje się **sieć trójfazową** — trzy napięcia przesunięte o 120°.

```
L1: U·sin(ωt)
L2: U·sin(ωt − 120°)
L3: U·sin(ωt − 240°)
N : neutralny (zero)
PE: uziemienie ochronne
```

### Napięcia

- **Fazowe** (L-N): 230 V (Europa)
- **Międzyfazowe** (L-L): 400 V = 230 · √3

### Zalety

- Mniejsze przewody przy tej samej mocy
- Stałe pole wirujące (silniki 3-fazowe)
- Lepsza symetria obciążenia

## DC vs AC — kiedy co

| Zastosowanie | Stosowany prąd |
|-------------|----------------|
| Sieć energetyczna (przesył) | AC (50/60 Hz) |
| Linie wysokiego napięcia (HVDC, na duże odległości) | DC! |
| Elektronika cyfrowa | DC |
| Audio, radio | AC (sygnały) |
| Baterie | DC |
| Ładowanie pojazdów elektrycznych | DC (szybkie ładowanie) |
| Silniki przemysłowe | AC (indukcyjne) |
| Spawanie | DC lub AC zależnie od metody |

## Wnioski praktyczne

1. **Sieć 230 V** = 230 V RMS, ale szczyt to 325 V. Pamiętaj przy doborze kondensatorów filtrujących.
2. **Wartość średnia sinusa = 0** w pełnym okresie — pomiar woltomierzem AC daje RMS.
3. **Multimetr w trybie AC** mierzy RMS (jeśli "True RMS") lub uśrednia przy założeniu sinusa (tańsze multimetry).
4. **DC mierzony multimetrem AC** = 0 (multimetr odcina DC i mierzy tylko składową zmienną).
5. **AC mierzony multimetrem DC** = wartość średnia (≈ 0 dla czystej sinusoidy).
