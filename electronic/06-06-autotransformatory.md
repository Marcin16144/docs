# 06-06: Autotransformatory i izolacyjne

## Autotransformator — co to

Transformator, w którym **uzwojenie pierwotne i wtórne dzielą część zwojów**. Jedno uzwojenie z odczepem zamiast dwóch oddzielnych.

```
   ────┬──── U_we (pełna szpula)
        │
       [N₁]
        │
        ●── odczep ── U_wy (mniejsze)
        │
       [N₂]
        │
   ────┴────
```

Przekładnia:
```
U_we / U_wy = N_całk / N_2
```

## Zalety i wady

### Zalety

- **Mniej miedzi** (oszczędność do 50% dla małej przekładni)
- **Wyższa sprawność** (mniej zwojów ogółem)
- **Lżejszy, tańszy**

### Wady

- **Brak galwanicznej separacji** — strona wyjściowa jest elektrycznie połączona z wejściową
- Niebezpieczny przy zasilaniu sieciowym (nie izoluje od fazy)
- Awaria odczepu (zwarcie do N) → pełne napięcie pierwotne na wyjściu

## Zastosowania

- **Transformatory regulacyjne** (Variac) — odczep ruchomy
- **Dopasowanie napięcia** (np. 230 V → 220 V, 240 V → 230 V)
- **Stabilizatory napięcia** (z przełączanymi odczepami)
- **Rozruch silników indukcyjnych** (obniżone napięcie startowe)

## Variac (transformator regulowany)

Toroidalny autotransformator z **ruchomą szczotką węglową** na uzwojeniu. Pokręcasz pokrętłem → zmienia się odczep → zmienia napięcie wyjściowe od 0 do ~250 V.

Typowo: zakres 0-250 V z wejściem 230 V, prądy 1-20 A.

### Zastosowanie Variaca w warsztacie

- **Testowanie urządzeń** — wolne uruchamianie zasilacza
- **Renowacja sprzętu** — stopniowe nakładanie napięcia po latach przerwy
- **Pomiary i kalibracja**
- **Sterowanie grzałkami i oświetleniem**

**UWAGA:** Variac NIE izoluje galwanicznie! Do bezpiecznej pracy z otwartą obudową — stosuj **transformator izolacyjny** w szeregu (omówiony niżej).

## Transformator izolacyjny

To zwykły transformator 1:1 (lub 1:1,1) — daje na wyjściu **tę samą napięcie**, ale **galwanicznie izolowane** od sieci.

```
   sieć 230V ─UUUU─ ║ ─UUUU─ 230V "izolowana"
                    ║
                    ║ (rdzeń)
```

### Po co

Na sieci 230 V w domu masa (N) jest **uziemiona** w stacji. Dotknięcie fazy = porażenie przez ziemię.

Z transformatorem izolacyjnym: dwie linie wyjściowe są "**latające**" — żadna nie ma kontaktu z ziemią. Dotknięcie jednej nie powoduje porażenia (bo nie ma zamkniętego obwodu przez ciało).

### Zastosowania

- **Praca w naprawach sprzętu sieciowego** (radia, TV, zasilaczy)
- **Łazienki, baseny** — transformatory bezpieczeństwa
- **Sale operacyjne** — separacja medyczna
- **Pomiar zakresem oscyloskopowym** sieciowych obwodów (bo masa oscyloskopu jest uziemiona!)

### Klasy

- **Class I** — z uziemieniem
- **Class II** — bez uziemienia (double insulated)

Norma izolacji: 3-4 kV próby napięciowej.

## Transformatory bezpieczeństwa (SELV)

**SELV (Safety Extra-Low Voltage)** — bardzo niskie napięcie bezpieczne. Wyjście maks. 50 V AC lub 120 V DC z **podwójną izolacją** od sieci.

Stosowane:
- Trafo do dzwonków (8 V, 12 V)
- Trafo halogenowe (12 V)
- Trafo do golarek w łazience
- Trafo modelarskich

Bezpieczeństwo: nawet dotknięcie obu zacisków wyjścia nie powoduje porażenia.

## Transformatory dopasowujące

### W audio

Transformator między wzmacniaczem lampowym a głośnikiem. Lampy mają wysoką impedancję wyjścia (kilkadziesiąt kΩ), głośnik 4-8 Ω.

```
Z₁/Z₂ = n²
n = √(Z_anoda / Z_głośnika) = √(5000/8) = 25
```

Lampowy transformator wyjściowy to **element krytyczny** — wpływa na pasmo, zniekształcenia, charakter dźwięku. Drogie!

### W RF

Baluny i transformatory dopasowujące do anten. Toroidalne ferrytowe, kilka zwojów.

### W liniach przesyłowych

Trafo dopasowujące impedancję linii 50 Ω/75 Ω lub 600 Ω.

## Transformatory pomiarowe

### CT (Current Transformer)

Pierwotne to **przewód z prądem** (czasem jeden zwój), wtórne ma N zwojów i mierzymy mały prąd.

```
I_2 = I_1 / N
```

Mierniki cęgowe — zamykasz cęgi wokół przewodu, w cęgach jest CT.

Klasyczne CT mają stosunek np. 100:5 (100 A na 5 A) lub 1000:1.

### Wymóg: nigdy nie zwieraj CT z otwartym wtórnym!

Otwarte wtórne CT z prądem w pierwotnym → bardzo wysokie napięcie na wtórnym (kilkaset – kilka tysięcy V) → przebicie izolacji, śmiertelne dla człowieka.

CT zawsze podłączone do amperomierza, bocznika lub zwartego.

### PT / VT (Potential / Voltage Transformer)

Pomiarowy transformator napięciowy — od wysokich napięć (15 kV, 110 kV) do bezpiecznych pomiarowych (100 V).

## Transformatory spawalnicze

Specjalna konstrukcja:
- Niskie napięcie wyjściowe (20-80 V)
- Duże prądy (100-500 A)
- Wysoka regulacja prądu (cewka regulowana)

Spawanie elektryczne wymaga prądu DC lub AC dużego natężenia. Tradycyjne trafa spawalnicze są bardzo ciężkie (50-100 kg).

Współcześnie wyparte przez **inwertery spawalnicze** — SMPS o dużej mocy, lekkie (5-10 kg).

## Transformatory mocy w energetyce

### Dystrybucyjne

- **15 kV → 400/230 V** — stacje miejskie i wiejskie
- 100 kVA – 2,5 MVA
- Olejowe (wypełnione olejem transformatorowym), suche (żywiczne)

### Wysokiego napięcia

- **110 kV / 220 kV / 400 kV / 750 kV** — sieci przesyłowe
- Setki MVA do GVA
- Olejowe, w obudowach metalowych
- Chłodzone wymuszony (pompy oleju, wentylatory)

### Specjalne

- **Trakcyjne** — kolejowe, tramwajowe
- **Piecowe** — do pieców łukowych (krótki, gruby kabel wtórny)
- **Próbne** — generatory wysokiego napięcia w laboratoriach

## Konwertery DC/DC z transformatorem izolowanym

Mała wersja transformatora dla DC:
- DC → invertujemy na AC HF (np. 100 kHz)
- Transformator HF (ferryt)
- Prostujemy ponownie na DC

Izolacja galwaniczna pełna, np. moduły DC-DC do automatyki przemysłowej (5 V wejście, 12 V wyjście izolowane).

## Klasy izolacji transformatorów

| Klasa | T_max | Izolacja |
|-------|-------|----------|
| Y | 90°C | bawełna, papier, jedwab |
| A | 105°C | namoczone w oleju, lakier |
| E | 120°C | polietylen, lakier |
| B | 130°C | epoksyd, mika |
| F | 155°C | szkło, epoksyd lepszy |
| H | 180°C | krzemoorganiczne |
| C | >180°C | mika, ceramika |

Dla sieciowych zwykle B lub F. Dla SMPS często H.

## Test transformatora izolacyjnego

### Próba napięciowa (Hipot)

Przyłożyć **3-5 kV AC RMS** między pierwotne i wtórne na 1 minutę. Brak przebicia = OK.

(Niebezpieczna procedura — wykonać tylko z odpowiednim sprzętem!)

### Pomiar rezystancji izolacji

Megerem 500 V DC: rezystancja > 100 MΩ.

### Pomiar prądu jałowego

Pod nominalnym U₁ bez obciążenia: I₀ < 5-15% I_nominal.

## Wybór typu transformatora

| Zastosowanie | Typ |
|--------------|-----|
| Zasilanie elektroniki z sieci 230 V | Transformator izolacyjny (sieciowy, EI lub toroidalny) |
| Regulacja napięcia AC | Variac (autotransformator) |
| Naprawa sprzętu sieciowego | Transformator izolacyjny + Variac w szeregu |
| Niewielkie obniżenie napięcia (np. 240 V → 230 V) | Autotransformator |
| Wysokie napięcie / pomiar | PT, CT |
| Audio lampowe | Wyjściowy transformator dopasowujący |
| Spawanie ekonomicznie | Inwerter (zamiast trafo spawalniczego) |
| RF i anteny | Balun, transformator HF |
| SMPS | Flyback / Forward HF |

## Bezpieczeństwo

### Z autotransformatorem

- Nigdy bez bezpieczników
- Pamiętaj o braku izolacji od sieci
- Dotykanie wyjścia bez ochrony = porażenie

### Z Variakem

- Nawet "na zerowym" napięciu wyjściowym możesz mieć fazę na metalowej obudowie urządzenia
- Stosuj zawsze różnicówkę

### Z transformatorem izolacyjnym

- Wyjście **izolowane**, ale nadal może zabić przy dotknięciu obu linii równocześnie
- Maks. moc trafo limit prądu zwarciowego
- Krótkotrwałe zwarcie spowoduje upalenie się drutu (mniej groźne niż w sieci)

## Częste błędy

1. **Variac użyty jako transformator izolacyjny** — Variac NIE izoluje! Nadal masa = ziemia.
2. **Otwarte CT z prądem w obwodzie** — bardzo wysokie napięcie, przebicie.
3. **Trafo audio podłączone do zasilania** — projektowane dla małych prądów AC, spali się.
4. **Variac bez bezpiecznika** — zwarcie po stronie wtórnej cyrkuluje cały prąd pierwotnego.
5. **Transformator izolacyjny niemierzony przed użyciem** — może być wadliwy, przebijający.
6. **Mylenie SELV z autotrasformatorem** — SELV daje izolację, autotrafo nie.
