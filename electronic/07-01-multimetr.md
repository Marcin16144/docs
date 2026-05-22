# 07-01: Multimetr

## Czym jest multimetr

Najważniejsze narzędzie elektronika. Pozwala mierzyć **co najmniej trzy** wielkości:
- Napięcie (V)
- Prąd (A)
- Rezystancja (Ω)

Współczesne dodają: pojemność, częstotliwość, temperaturę, test diód, ciągłość, hFE tranzystorów.

## Typy multimetrów

### Analogowy

Z igłą wskazówkową. Klasycznie, dziś rzadko (poza specyficznymi zastosowaniami).

Zalety:
- Pokazuje **kierunek zmian** (dynamika)
- Brak baterii dla pomiaru napięcia (we wniektórych)

Wady:
- Mała dokładność (3-5%)
- Czytanie skali wymaga uwagi
- Wrażliwy mechanicznie

### Cyfrowy (DMM)

Z wyświetlaczem. Standard współczesny. Dokładność 0,5-2%, czasem lepsza.

### True RMS vs przeciętny

- **Average responding** (tańsze) — mierzy wartość średnią, mnoży przez 1,11 (zakłada sinusoidalny przebieg). Błędne dla zniekształconych sygnałów.
- **True RMS** — mierzy rzeczywistą wartość skuteczną. Konieczne dla SMPS, falowników, regulatorów fazowych.

## Klasy dokładności i CAT

### Klasa dokładności

Wyrażana jako: ±(0,5% rdg + 2 dgt)
- "rdg" — od wartości odczytu
- "dgt" — od najmniejszej cyfry wyświetlacza

Przykład: pomiar 100 V, ±(0,5% + 2 dgt) → ±(0,5 V + 0,2 V) = ±0,7 V.

### Klasy CAT (kategorii pomiarowych)

| CAT | Zastosowanie | Wytrzymałość |
|-----|--------------|---------------|
| CAT I | obwody bez sieci | brak ochrony |
| CAT II | gniazdka domowe | 1500 V tranzient |
| CAT III | tablice rozdzielcze, instalacje | 4000-8000 V tranzient |
| CAT IV | linie przy liczniku, na zewnątrz | 6000-12000 V tranzient |

**Tani multimetr za 20 zł = CAT I**. NIE wkładaj sond do gniazdka 230 V.

## Pomiar napięcia (V)

### Tryb DC (V=)

Multimetr **równolegle** do mierzonego elementu.

```
   +12V ──┬───
          │
        DUT (obciążenie)
          │
   GND ───┘
   
   sonda + multimetru → +12V
   sonda − multimetru → GND
```

### Tryb AC (V~)

Tak samo równolegle, ale przebieg AC. Większość multimetrów odcina DC w trybie AC.

### Zakres

Zwykle: 200 mV, 2 V, 20 V, 200 V, 1000 V. Autorange = automatyczny wybór.

### Zasada

Multimetr w trybie napięcia ma **wysoką impedancję** (typowo 10 MΩ) — minimalnie wpływa na obwód.

## Pomiar prądu (A)

### Sposób

Multimetr **szeregowo** w obwodzie — musisz **przerwać obwód** i wpiąć multimetr.

```
   +V ── multimetr ── obciążenie ── GND
              (+)              (−)
```

### Zakres

Typowo: 200 μA, 2 mA, 200 mA, 10 A. Bezpiecznik chroni przed przeciążeniem.

### Ważne gniazdo

Większość multimetrów ma **dwa gniazda dla prądu**:
- **mA / μA** (małe prądy)
- **10 A** lub **20 A** (duże, nieprzepuszczone przez bezpiecznik)

Pomyłka = przepalenie bezpiecznika lub uszkodzenie multimetru.

### Cęgi prądowe

Alternatywa — pomiar **bez przerywania obwodu**. Cęgi obejmują przewód, czujnik Halla lub trafo prądowe mierzy pole magnetyczne.

Dla DC potrzebne cęgi z czujnikiem Halla. Dla AC wystarczą tańsze (z CT).

## Pomiar rezystancji (Ω)

### Sposób

Multimetr przyłożony do **odłączonego** elementu! Jeśli rezystor jest w obwodzie, pomiar może być błędny (inne rezystory równolegle).

```
   ── multimetr ──
       R do zmierzenia
```

Multimetr przepuszcza mały prąd przez DUT i mierzy spadek napięcia.

### Zakres

200 Ω, 2 kΩ, 20 kΩ, 200 kΩ, 2 MΩ, 20 MΩ. Tanie multimetry mają błąd ~2-5% w niskich zakresach.

### Test ciągłości

Specjalny tryb — multimetr piszczy, gdy R < ~50 Ω. Bardzo użyteczne do sprawdzania połączeń, lutowania, kabli.

### Pomiar bardzo niskich oporów

Multimetry standardowe nie potrafią poniżej 0,1 Ω. Do pomiaru bocznika, drutu — potrzeba mikroomomierza (4-przewodowego Kelvina) lub mostka pomiarowego.

## Pomiar pojemności (C)

Multimetr przeładowuje kondensator stałym prądem i mierzy czas. Daje pojemność.

Zakres: 2 nF do 200 μF (typowo). Mniejszych — pojemność przewodów multimetru zaburza pomiar.

Wskazówka: **rozładuj kondensator przed pomiarem** (zwarcie nogami przez rezystor 1-10 kΩ).

## Pomiar diod

Tryb "dioda" przepuszcza prąd i wyświetla **spadek napięcia U_F**.

| Element | U_F |
|---------|-----|
| Dioda Si | 0,5-0,7 V |
| Dioda Ge | 0,2-0,3 V |
| Dioda Schottky | 0,15-0,4 V |
| LED czerwona | 1,8-2,0 V |
| LED niebieska | 3,0-3,4 V |

Brak wskazania (OL) w obie strony = przerwa. Niskie obie strony = zwarcie.

## Pomiar tranzystorów (hFE)

Niektóre multimetry mierzą wzmocnienie BJT. Wkładasz E-B-C w gniazda, odczytujesz β.

Mało dokładne (typowo ±20%), ale wystarczy do orientacyjnego sprawdzenia.

## Pomiar częstotliwości

Wyspecjalizowany pomiar. Dokładność typowo 0,01% — wystarcza do wszystkiego poniżej GHz.

Wskazówka: amplituda sygnału musi być wystarczająca (zwykle ≥ 200 mV pp).

## Pomiar temperatury

Z termoparą K (-200°C do +1000°C). Wystarczy do diagnostyki grzania elementów.

## Wybór multimetru — checklist

### Hobby (50-150 zł)

- Auto-range
- DC/AC do 600 V
- Prąd do 10 A
- R do 20 MΩ
- Pomiar C, dioda, ciągłość
- Test hFE (opcjonalnie)
- CAT II 600 V

Modele: Aneng AN8009, Uni-T UT139C, Mastech MS8268.

### Półprofesjonalny (200-600 zł)

- True RMS
- Wyższa dokładność (0,5%)
- Większy ekran
- Min/Max, Hold
- CAT III 600V lub CAT IV 300V

Modele: Brymen BM235, Uni-T UT181A, Aneng AN999S.

### Profesjonalny (Fluke, Keysight, 1500+ zł)

- True RMS, dokładność 0,1%
- Pełna ochrona CAT IV 1000V
- Filtry, oczyszczanie sygnału
- Komputer/PC interface
- Wieloletnia gwarancja

Modele: Fluke 87V, Fluke 289, Keysight U1242C.

## Triki praktyczne

### Pomiar prądu rozruchowego

Trudny — krótki impuls. Funkcja "Min/Max" lub "Peak hold" pomaga zarejestrować szczyt.

### Pomiar ESR kondensatora

Standardowy multimetr **nie zmierzy** ESR (zbyt mała wartość). Trzeba dedykowanego testera ESR (np. Mega ESR Meter).

### Pomiar napięcia w działającym obwodzie cyfrowym

Sygnał logiczny migocze, multimetr daje średnią (lub miga). Lepiej: oscyloskop lub analizator stanów logicznych.

### Pomiar tętnień (ripple)

W trybie AC multimetr odetnie DC i pokaże RMS tętnień. Ale wynik dla zniekształconych pulsów nieoptymalny — potrzebne True RMS.

### Pomiar baterii

**Pod obciążeniem!** Bateria pokaże 1,5 V, ale pod 100 mA spadnie do 1,2 V → "zużyta". Bez obciążenia nie zweryfikujesz.

Wsadź rezystor 100 Ω równolegle do pomiaru. Lub kup tester baterii.

## Bezpieczne pomiary 230 V

### Procedura

1. **Wyłącz zasilanie** (jeśli możliwe).
2. **Sprawdź sondy** — bez izolacji = porażenie. Wymień jeśli wątpliwe.
3. **Wybierz zakres** > 600 V AC.
4. **Sprawdź gniazdo** — nie w gnieździe "mA"!
5. **Trzymaj sondy** za izolowane uchwyty.
6. **Najpierw multimetr** podłącz, potem włącz zasilanie.
7. **Po pomiarze** wyłącz zasilanie, odłącz sondy.

### Nigdy

- Nie zmieniaj zakresu pod napięciem (chyba że auto-range)
- Nie używaj uszkodzonych sond
- Nie mierzyć prądu w trybie napięcia
- Nie używać CAT I w sieci 230 V

## Częste błędy

1. **Pomyłka V i A** — wtyczki w gnieździe "mA" przy pomiarze 230 V = wybuch, popalony multimetr, ryzyko porażenia.
2. **Pomiar R w działającym obwodzie** — błędne wyniki, czasem uszkodzenie multimetru.
3. **Pomiar prądu w obwodzie 230 V bez bezpiecznika** — bezpiecznik multimetru natychmiast się przepala.
4. **Pomiar napięcia DC w trybie AC i odwrotnie** — błędne odczyty.
5. **Niewłaściwy zakres** — przegrzanie, błędne odczyty.
6. **Pomyłka polaryzacji w analogowym** — igła "leci w drugą stronę", można uszkodzić.
7. **Pomiar ESR kondensatora w obwodzie** — różne rezystory równolegle, błąd.

## Codzienne pomiary — szybkie tipy

- **Czy zasilanie OK?** — voltmeter na zasilaniu
- **Czy LED świeci?** — voltmeter na nóżkach LED. Powinno być U_F.
- **Czy bezpiecznik OK?** — ciągłość. Brzęczy = OK, cisza = przepalony.
- **Czy przewód ma przerwę?** — ciągłość obu końców.
- **Czy kondensator OK?** — pomiar C. Lub w trybie R: rosnące R od 0 do OL.
- **Czy ESR za wysoki?** — dedykowany tester. Lub miganie zasilacza.
