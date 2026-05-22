# 01-01: Wielkości elektryczne

## Podstawowe pojęcia

W elektronice operujemy kilkoma fundamentalnymi wielkościami. Wszystkie inne wzory, prawa i obliczenia z nich wynikają.

| Wielkość | Symbol | Jednostka | Symbol jednostki |
|----------|--------|-----------|------------------|
| Ładunek elektryczny | Q | kulomb | C |
| Napięcie | U (lub V) | wolt | V |
| Prąd | I | amper | A |
| Rezystancja | R | om | Ω |
| Pojemność | C | farad | F |
| Indukcyjność | L | henr | H |
| Moc | P | wat | W |
| Energia | W (lub E) | dżul | J |
| Częstotliwość | f | herc | Hz |
| Czas | t | sekunda | s |

## Ładunek elektryczny (Q)

Najbardziej elementarna wielkość. Elektron niesie ładunek **−1,602·10⁻¹⁹ C**. Jeden kulomb to ładunek ok. 6,24·10¹⁸ elektronów.

W praktyce ładunkiem operujemy rzadko bezpośrednio — częściej przez prąd, który jest jego natężeniem w czasie.

## Prąd elektryczny (I)

**Prąd to ilość ładunku przepływająca przez przekrój przewodnika w jednostce czasu:**

```
I = Q / t        [A = C/s]
```

1 amper = 1 kulomb na sekundę.

W przewodzie prąd to uporządkowany ruch elektronów. Umownie prąd płynie od plusa do minusa (kierunek przeciwny do ruchu elektronów — pamiątka po Franklinie).

### Typowe wartości prądu

| Urządzenie | Prąd |
|-----------|------|
| LED sygnalizacyjna | 10-20 mA |
| Mikrokontroler (Arduino) | 20-50 mA |
| Telefon (ładowanie) | 1-3 A |
| Lodówka | 1-2 A |
| Czajnik elektryczny | 8-10 A |
| Spawarka | 100-200 A |

## Napięcie (U lub V)

**Napięcie to różnica potencjałów elektrycznych między dwoma punktami.** To "siła", która "popycha" elektrony.

```
U = W / Q        [V = J/C]
```

1 wolt to taka różnica potencjałów, że 1 dżul energii potrzebny jest do przeniesienia 1 kulomba ładunku.

### Skąd się bierze napięcie

- **Bateria/akumulator** — reakcja chemiczna
- **Prądnica** — indukcja elektromagnetyczna (generator obrotowy)
- **Ogniwo fotowoltaiczne** — efekt fotoelektryczny
- **Termopara** — efekt Seebecka (różnica temperatur)
- **Piezo** — ściskanie kryształów

### Typowe napięcia

| Źródło | Napięcie |
|--------|----------|
| Bateria AA | 1,5 V |
| USB | 5 V |
| Akumulator Li-ion | 3,7 V (nominalne) |
| Akumulator samochodowy | 12 V |
| Sieć domowa (Europa) | 230 V AC |
| Sieć domowa (USA) | 110-120 V AC |
| Sieć trójfazowa | 400 V AC |
| Linia średniego napięcia | 15 kV |
| Linia wysokiego napięcia | 110-400 kV |

## Rezystancja (R)

**Rezystancja to opór, jaki materiał stawia przepływowi prądu.** Im wyższa, tym trudniej przepłynąć prądowi.

```
R = U / I        [Ω = V/A]
```

To jest właśnie prawo Ohma w formie definicji rezystancji.

### Rezystywność (ρ)

Każdy materiał ma swoją rezystywność — opór właściwy. Rezystancja kawałka materiału:

```
R = ρ · L / S

L — długość przewodnika [m]
S — pole przekroju [mm²]
ρ — rezystywność [Ω·mm²/m]
```

| Materiał | ρ [Ω·mm²/m] |
|----------|-------------|
| Srebro | 0,016 |
| Miedź | 0,0175 |
| Aluminium | 0,028 |
| Wolfram | 0,055 |
| Żelazo | 0,1 |
| Nikielina (oporowy) | 0,42 |
| Konstantan | 0,5 |
| Krzem czysty | ~640 |

Miedź jest najczęściej używana — dobry kompromis między ceną a rezystywnością. Stąd przewody miedziane.

### Przykład praktyczny

Drut miedziany 1 mm², długość 10 m:

```
R = 0,0175 · 10 / 1 = 0,175 Ω
```

Przy prądzie 10 A spadek napięcia:
```
U = I · R = 10 · 0,175 = 1,75 V
```

Czyli 1,75 V "tracimy" na samym przewodzie. Stąd grube przewody przy dużych prądach.

## Moc (P)

**Moc to energia rozpraszana lub dostarczana w jednostce czasu:**

```
P = U · I        [W = V·A]
```

Z prawa Ohma wynikają dwie pochodne formy:

```
P = U² / R       (gdy znamy napięcie i rezystancję)
P = I² · R       (gdy znamy prąd i rezystancję)
```

### Typowe moce

| Urządzenie | Moc |
|-----------|-----|
| LED | 0,02-1 W |
| Słuchawki | 0,01-0,1 W |
| Telefon (ładowanie) | 5-25 W |
| Laptop | 30-100 W |
| Monitor | 20-150 W |
| Lodówka | 100-300 W |
| Czajnik | 1500-3000 W |
| Kuchenka indukcyjna | 2000-3500 W |
| Spawarka inwerterowa | 3000-6000 W |

## Energia (W)

**Energia to moc razy czas:**

```
W = P · t        [J = W·s]
```

W praktyce używamy **kilowatogodziny** (kWh), bo dżule są nieporęczne:

```
1 kWh = 1000 W · 3600 s = 3 600 000 J = 3,6 MJ
```

Rachunek za prąd to opłata za kWh. Czajnik 2 kW pracujący 30 minut zużywa:
```
W = 2 · 0,5 = 1 kWh
```

## Częstotliwość (f) i okres (T)

W prądzie przemiennym wielkości zmieniają się okresowo.

```
T = 1 / f        [s]
f = 1 / T        [Hz]
```

| Sygnał | Częstotliwość |
|--------|--------------|
| Sieć domowa (Europa) | 50 Hz |
| Sieć domowa (USA) | 60 Hz |
| Audio | 20 Hz - 20 kHz |
| Radio AM | 0,5-1,7 MHz |
| Radio FM | 88-108 MHz |
| WiFi 2,4 GHz | 2,4 GHz |
| Procesor PC | 2-5 GHz |

## Przedrostki jednostek

Bez nich zapis byłby nieczytelny.

| Przedrostek | Symbol | Mnożnik |
|------------|--------|---------|
| tera | T | 10¹² |
| giga | G | 10⁹ |
| mega | M | 10⁶ |
| kilo | k | 10³ |
| (bez) | — | 10⁰ |
| mili | m | 10⁻³ |
| mikro | μ | 10⁻⁶ |
| nano | n | 10⁻⁹ |
| piko | p | 10⁻¹² |

### Przykłady

```
2,2 kΩ  = 2200 Ω
10 μF   = 0,00001 F = 10·10⁻⁶ F
100 nF  = 0,0000001 F = 100·10⁻⁹ F
470 pF  = 470·10⁻¹² F
2,4 GHz = 2 400 000 000 Hz
```

## Pomocnicze: trójkąt mocy

Łatwy sposób na zapamiętanie wzorów:

```
       P
      ─┼─
     U │ I
```

Zakrywasz palcem, czego szukasz:
- Zakryj P → U · I
- Zakryj U → P / I
- Zakryj I → P / U

To samo dla prawa Ohma:

```
       U
      ─┼─
     I │ R
```

## Konwencje zapisu w schematach

- **U** używamy do napięć stałych
- **u(t)** — napięcie zmienne w czasie
- **U_RMS** — wartość skuteczna
- **U_pp** — wartość międzyszczytowa (peak-to-peak)
- **I_AVG** — wartość średnia prądu

W literaturze anglosaskiej napięcie to **V** zamiast **U**. W Polsce częściej **U**, ale oba są poprawne.
