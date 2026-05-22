# Prawo Ohma

## Treść prawa

Niemiecki fizyk Georg Ohm w 1827 roku sformułował zależność wiążącą trzy podstawowe wielkości elektryczne:

```
U = I · R
```

Napięcie na odbiorniku jest **wprost proporcjonalne** do prądu, który przez niego płynie, a współczynnikiem proporcjonalności jest opór.

## Trzy formy wzoru — „trójkąt Ohma"

| Szukana | Wzór | Kiedy używamy |
|---|---|---|
| **U** [V] | U = I · R | znamy prąd i opór, liczymy spadek napięcia |
| **I** [A] | I = U / R | znamy napięcie i opór, liczymy prąd |
| **R** [Ω] | R = U / I | znamy napięcie i prąd, liczymy rezystancję |

Pamięciowo: zasłoń palcem szukaną wielkość, dwie pozostałe pokażą działanie (mnożenie obok siebie, dzielenie nad sobą):

```
    U
  -----
  I · R
```

## Przykład 1 — dobór rezystora do diody LED

Dioda LED czerwona ma napięcie pracy ok. 2 V i prąd nominalny 20 mA. Zasilamy ją z 12 V DC. Jaki rezystor szeregowy zastosować?

```
U_R = U_zasilania − U_LED = 12 V − 2 V = 10 V
R   = U_R / I = 10 / 0,02 = 500 Ω
```

Wybieramy standardową wartość 510 Ω lub 470 Ω (najbliższy szereg E12). Sprawdzamy moc rezystora:

```
P = U · I = 10 · 0,02 = 0,2 W → wystarczy rezystor 0,25 W
```

## Przykład 2 — prąd grzałki bojlera

Grzałka rezystancyjna bojlera ma oporność R = 26,5 Ω. Bojler zasilany jest z sieci 230 V AC. Jaki prąd płynie?

```
I = U / R = 230 / 26,5 ≈ 8,7 A
P = U · I = 230 · 8,7 ≈ 2 000 W = 2 kW
```

Wynika z tego dobór zabezpieczenia: B10 lub B16, przewód 1,5 mm² na osobnym obwodzie.

## Przykład 3 — opór żarnika

Czajnik 2 kW przy 230 V — jaki opór ma jego grzałka w stanie ustalonym?

```
I = P / U = 2000 / 230 ≈ 8,7 A
R = U / I = 230 / 8,7 ≈ 26,5 Ω
```

## Zależność rezystancji od temperatury

Dla metali rezystancja rośnie z temperaturą:

```
R(T) = R₀ · [1 + α · (T − T₀)]
```

gdzie α — współczynnik temperaturowy [1/K].

| Materiał | α [1/K] |
|---|---|
| Miedź | 0,0039 |
| Aluminium | 0,0042 |
| Wolfram (żarnik) | 0,0045 |
| Konstantan | ~0,00001 (prawie zero) |

**Skutek praktyczny:** żarnik żarówki ma w stanie zimnym opór ~10× mniejszy niż gorący. Dlatego przy włączeniu prąd rozruchowy jest 10× większy od nominalnego — stąd żarówki „przepalają się" zwykle przy włączeniu.

## Kiedy prawo Ohma nie działa

Prawo Ohma obowiązuje dla **elementów liniowych** (rezystancyjnych). Nie stosuje się do:

- **diody półprzewodnikowej** — charakterystyka wykładnicza, próg ~0,6 V (Si) / 0,3 V (Ge) / 2-3,5 V (LED)
- **żarówki** — opór zależny od temperatury, prąd ≠ liniowy wobec napięcia
- **gazów (świetlówki, neonówki)** — opór ujemny w pewnym zakresie
- **tranzystorów, tyrystorów** — sterowane elementy nieliniowe
- **termistorów NTC/PTC** — opór zależny silnie od temperatury

W takich przypadkach posługujemy się charakterystyką prądowo-napięciową U(I) lub modelem zastępczym.

## Typowe oporności w domu

| Element | Opór ~ |
|---|---|
| Żyła Cu 1,5 mm² × 10 m | 0,12 Ω |
| Żyła Cu 2,5 mm² × 10 m | 0,07 Ω |
| Żarówka LED 10 W (cała oprawa) | ~5 000 Ω (zasilacz nieliniowy) |
| Żarówka żarowa 60 W (zimna) | ~70 Ω |
| Żarówka żarowa 60 W (gorąca) | ~880 Ω |
| Grzałka czajnika 2 kW | 26,5 Ω |
| Grzałka bojlera 2 kW | 26,5 Ω |
| Silnik AGD (uzwojenie 100 W) | ~50 Ω + indukcyjność |
| Ciało człowieka (sucha skóra) | 10-100 kΩ |
| Ciało człowieka (mokra skóra) | 1-5 kΩ |
| Uziom dobry | <10 Ω |
| Izolacja przewodu (nowa) | >10⁹ Ω |

## Łączenie prawa Ohma z mocą

Z połączenia P = U·I i U = I·R wynikają wzory pochodne — szczególnie przydatne, gdy znamy moc i napięcie i chcemy oszacować opór odbiornika:

```
P = U · I        →  I = P / U
P = I² · R       →  R = P / I²
P = U² / R       →  R = U² / P
```

**Szybkie przeliczenie dla 230 V:** opór odbiornika rezystancyjnego o mocy P:

```
R = 230² / P = 52 900 / P
```

| Odbiornik | P | R |
|---|---|---|
| Suszarka 1 kW | 1 000 W | 53 Ω |
| Czajnik 2 kW | 2 000 W | 26,5 Ω |
| Bojler 3 kW | 3 000 W | 17,6 Ω |
| Grzejnik 2,5 kW | 2 500 W | 21 Ω |

## Co dalej

➡ [Prawa Kirchhoffa — analiza obwodów rozgałęzionych](01-03-prawa-kirchhoffa.md)
