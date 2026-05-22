# 01-02: Prawo Ohma i prawa Kirchhoffa

## Prawo Ohma

Najważniejsza zależność w elektronice. Podana przez Georga Ohma w 1827 roku.

**Napięcie na rezystorze jest wprost proporcjonalne do prądu przez niego płynącego, a stałą proporcjonalności jest rezystancja.**

```
U = I · R
```

Trzy równoważne formy:

```
U = I · R       (znamy I i R, szukamy U)
I = U / R       (znamy U i R, szukamy I)
R = U / I       (znamy U i I, szukamy R)
```

### Przykład 1 — dobór rezystora do LED

LED czerwona: spadek napięcia U_LED = 2 V, prąd roboczy I = 20 mA = 0,02 A.
Zasilanie 5 V.

Na rezystorze musi się odłożyć: U_R = 5 − 2 = 3 V.

```
R = U / I = 3 / 0,02 = 150 Ω
```

Najbliższy szereg E12: 150 Ω lub 180 Ω (bezpieczniej w stronę większego oporu).

### Przykład 2 — sprawdzenie prądu

Rezystor 1 kΩ między 12 V a masą. Jaki prąd płynie?

```
I = U / R = 12 / 1000 = 0,012 A = 12 mA
```

Moc rozpraszana na rezystorze:

```
P = U · I = 12 · 0,012 = 0,144 W = 144 mW
```

Rezystor 1/4 W (250 mW) wystarczy z zapasem.

## Łączenie rezystorów

### Szeregowo

Rezystancja zastępcza to suma:

```
R = R1 + R2 + R3 + ...
```

Prąd jest jednakowy w całym obwodzie. Napięcie dzieli się proporcjonalnie do rezystancji.

### Dzielnik napięcia (z dwóch rezystorów szeregowych)

```
U_wy = U_we · R2 / (R1 + R2)
```

Częsty układ — np. doprowadzenie napięcia do wejścia ADC mikrokontrolera.

### Równolegle

Odwrotności się sumują:

```
1/R = 1/R1 + 1/R2 + 1/R3 + ...
```

Dla dwóch rezystorów wygodniejszy wzór:

```
R = (R1 · R2) / (R1 + R2)
```

Napięcie jest jednakowe na wszystkich. Prąd dzieli się odwrotnie proporcjonalnie do rezystancji.

### Szybkie zasady

- Dwa identyczne rezystory równolegle: **R/2**
- Dwa identyczne rezystory szeregowo: **2R**
- Rezystancja równoległa jest zawsze **mniejsza** od najmniejszego z rezystorów
- Rezystancja szeregowa jest zawsze **większa** od największego z rezystorów

## Prawa Kirchhoffa

Dwa prawa fundamentalne dla obwodów. Wynikają z zasad zachowania ładunku i energii.

### Prawo węzłowe (KCL — Kirchhoff's Current Law)

**Suma prądów wpływających do węzła = suma prądów wypływających.**

```
ΣI_in = ΣI_out
```

Lub w innej formie: suma algebraiczna wszystkich prądów w węźle = 0.

Wynika z zasady zachowania ładunku — ładunek nie znika ani się nie tworzy.

### Przykład KCL

```
     I1=2A
       ↓
   ┌───●───┐
   │   ↓   │
 I2=?     I3=1A
```

W węźle: I1 = I2 + I3, czyli 2 = I2 + 1, więc I2 = 1 A.

### Prawo oczkowe (KVL — Kirchhoff's Voltage Law)

**Suma napięć w zamkniętym oczku = 0.**

```
ΣU = 0
```

To znaczy: idąc dookoła oczka, suma spadków napięć (rezystory, kondensatory) musi równać się sumie sił elektromotorycznych (źródeł).

Wynika z zasady zachowania energii.

### Przykład KVL

Obwód: bateria 9 V, rezystor R1 = 1 kΩ, rezystor R2 = 2 kΩ, oba szeregowo.

```
9 V − U_R1 − U_R2 = 0
9 = U_R1 + U_R2
```

Prąd I jest wspólny:
```
I = 9 / (1000 + 2000) = 3 mA
U_R1 = 0,003 · 1000 = 3 V
U_R2 = 0,003 · 2000 = 6 V
sprawdzenie: 3 + 6 = 9 V ✓
```

## Moc rozpraszana na rezystorze

```
P = U · I
P = I² · R       (gdy znamy prąd)
P = U² / R       (gdy znamy napięcie)
```

### Przykład — dobór rezystora po mocy

Rezystor 100 Ω, napięcie 12 V.

```
P = 12² / 100 = 144 / 100 = 1,44 W
```

Rezystor 1/4 W spali się. Trzeba minimum 2 W, najlepiej 5 W (zapas + chłodzenie).

### Zasada doboru mocy

W praktyce dobieraj rezystor o **co najmniej 2× wyższej mocy** niż obliczona. Marża na temperaturę, starzenie, tolerancję.

## Typowe szeregi rezystorów

W handlu rezystory są w szeregach E. Im wyższa cyfra, tym więcej wartości w dekadzie.

**Szereg E12 (najpopularniejszy, tolerancja 10%):**
```
1,0  1,2  1,5  1,8  2,2  2,7  3,3  3,9  4,7  5,6  6,8  8,2
```

**Szereg E24 (tolerancja 5%):**
```
1,0  1,1  1,2  1,3  1,5  1,6  1,8  2,0  2,2  2,4  2,7  3,0
3,3  3,6  3,9  4,3  4,7  5,1  5,6  6,2  6,8  7,5  8,2  9,1
```

Wartości skalują się w dekadach: 10 Ω, 100 Ω, 1 kΩ, 10 kΩ, 100 kΩ, 1 MΩ.

## Praktyczne triki obliczeniowe

### Dzielnik 1:10

Jeśli chcesz podzielić napięcie 10× (np. 50 V → 5 V do ADC), użyj R1 = 9R i R2 = R. Często praktycznie: 9 kΩ + 1 kΩ, albo 90 kΩ + 10 kΩ.

### Większe rezystancje = mniejszy prąd jałowy

W dzielniku napięcia większe wartości oporników = mniejszy prąd "leci na marne". Ale zbyt duże → wpływ rezystancji wejścia obciążenia. Typowe wartości w dzielnikach: 10 kΩ do 100 kΩ.

### Reguła kciuka — moc małego rezystora

Rezystor SMD 0603 (popularny): max 1/10 W = 100 mW. Rezystor THT typowy: 1/4 W (250 mW). Większe — 1 W, 2 W, 5 W, 10 W (z radiatorem).

## Najczęstsze błędy początkujących

1. **Zła jednostka** — pomyłka z miliamperami i amperami daje błąd 1000×.
2. **Nieuwzględnienie mocy** — rezystor 100 Ω na 230 V to bomba (P = 529 W).
3. **Brak zapasu prądowego źródła** — bateria 9 V (paluszek) nie zasili silnika 1 A.
4. **Zakładanie idealności źródła** — bateria ma rezystancję wewnętrzną; pod obciążeniem napięcie spada.
