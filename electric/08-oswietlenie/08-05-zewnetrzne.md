# Oświetlenie zewnętrzne

Oświetlenie zewnętrzne to inna liga niż wnętrza — narażone na deszcz, mróz, wandalizm, długie godziny pracy zimą. Każda decyzja musi uwzględniać klasy szczelności, materiały, sterowanie zmierzchowe i bezpieczeństwo SELV.

## Klasy szczelności IP / IK

### IP (Ingress Protection) — pyło- i wodoszczelność

Dwucyfrowy kod: **IPxy** gdzie:

- **x** (0-6) — ochrona przed wnikaniem ciał stałych (pyłu)
- **y** (0-8) — ochrona przed wnikaniem wody

| IP | Zastosowanie |
|---|---|
| IP20 | tylko wnętrza suche |
| IP44 | łazienka, blisko zlewu, daszki, ganki osłonięte |
| **IP54** | minimum dla zewnętrznych pod daszkiem |
| **IP65** | minimum dla zewnętrznych eksponowanych (oprawy ścienne, słupki) |
| **IP66** | oprawy stojące w pełnej ekspozycji, fontanny w pobliżu |
| IP67 | krótkotrwałe zanurzenie 30 min / 1 m |
| IP68 | stałe zanurzenie (oprawy basenowe, podwodne) |
| IP69K | strumień ciśnieniowy gorącej wody (gastronomia) |

### IK (Impact protection) — odporność mechaniczna

Kod **IKxx** (00-10), wartość = energia uderzenia, jaką oprawa wytrzymuje:

| IK | Energia [J] | Odpowiednik |
|---|---|---|
| IK02 | 0,2 | lekki nacisk |
| IK06 | 1,0 | piłka tenisowa |
| **IK08** | 5,0 | typowy słupek ogrodowy, klosz osłonięty |
| **IK10** | 20,0 | „antywandal" — kamień, młotek |

**Praktyka:** zewnętrzne oprawy w zasięgu człowieka → IK08 minimum. Słupki przy chodniku publicznym → IK10.

## Materiały opraw

| Materiał | Zalety | Wady | Cena |
|---|---|---|---|
| Aluminium malowane proszkowo | lekkie, odporne na korozję, sztywne | farba może odprysnąć | średnia |
| Aluminium anodowane | trwałe, klasyczny wygląd „srebrny" | droższe | średnia-wysoka |
| Stal nierdzewna AISI 316L | dożywotnie, premium | ciężkie, drogie | wysoka |
| Stal czarna malowana | tania, klasyczna | rdzewieje pod farbą | niska |
| Tworzywo / poliwęglan | tanie, lekkie | UV go starzeje (5-10 lat) | niska |
| Mosiądz, miedź | klasyczny dwór, dębieją | drogie, miękkie | wysoka |

W praktyce: **aluminium malowane proszkowo** to standard, AISI 316L — jeśli stać i zależy nam na latach bez konserwacji.

## Typy opraw zewnętrznych

### Halogeny LED zalewające (naświetlacze)

Płaskie reflektory z kątem 90-120°, moc 10-100 W LED:

- 10-30 W — taras, wjazd, garaż na zewnątrz
- 50-100 W — duża posesja, plac manewrowy
- z **PIR** (czujnik ruchu) — typowo „bezpieczeństwo + komfort"

### Słupki ogrodowe

Wysokość typowo 30-100 cm. Stosowane wzdłuż alejek, podjazdów, ogrodzeń.

| Wysokość | Zastosowanie |
|---|---|
| 30 cm | grządki, podświetlenie krzewów |
| 60 cm | brzeg alejki |
| 80-100 cm | obrzeże podjazdu, oświetlenie kierunkowe |
| 200-400 cm (latarnia) | drogi wewnętrzne |

### Linijki / listwy podziemne („inground")

LED w trawniku lub w betonowej kostce — IP67 minimum. Dobre do podświetlania **w górę** (drzewa, gabaryty domu).

### Reflektory PIR / radarowe

10-50 W, z czujnikiem ruchu. Wjazd, taras, drzwi tylne. Czas opóźnienia 30 s - 5 min.

### Iluminacja architektoniczna

Punktowe oprawy z wąskim kątem (10-30°) skierowane na elewację, drzewa, fontanny. Zwykle 3-10 W LED z dyskretnym driverem ukrytym za oprawą.

### Oświetlenie ścieżek wodnych / basenu

IP68, najczęściej zasilane SELV (12 V lub 24 V DC). Transformator umieszczony w skrzynce z dala od wody.

## Bezpieczne SELV (12-24 V) w ogrodzie

W ogrodzie często stosuje się **napięcie obniżone SELV** (Safety Extra-Low Voltage):

- **12 V DC / 24 V DC** — typowe
- transformator/zasilacz IP67 w skrzynce zabezpieczonej (np. w garażu lub w hermetycznej puszce w trawniku)
- przewody SELV mogą biec swobodnie w ziemi, bez peszli (mniejsze rygory)

Zalety:

- bezpieczne dla dzieci/zwierząt (dotknięcie nie powoduje porażenia)
- proste DIY — można samemu prowadzić kable bez SEP
- mniej formalności

Wady:

- straty na długich liniach (przy 12 V już 30 m to spadek napięcia kilkanaście procent)
- ograniczona moc (transformator zwykle do 100-300 W)

## Sterowanie

Najczęściej spotykana kombinacja:

```
Czujnik zmierzchowy + zegar tygodniowy + (opcjonalnie) PIR
```

| Element | Funkcja |
|---|---|
| Czujnik zmierzchowy | załącza tylko gdy ciemno (np. < 50 lx) |
| Zegar tygodniowy | wyłącza w godzinach nocnego spoczynku (np. 23:00 - 5:30) |
| PIR | rozjaśnia / włącza dodatkowe światła przy zbliżaniu |
| Sterownik smart (Sonoff, Shelly, KNX) | sceny, harmonogram, sterowanie z aplikacji |

## Norma PN-EN 13201 — oświetlenie ulic i dróg

Dla oświetlenia uliczki przed posesją lub w garażu hotelowym stosuje się normę **PN-EN 13201**. Wybór klasy oświetlenia (M1-M6 dla dróg ruchu samochodowego, P1-P7 dla pieszych) zależy od:

- prędkości ruchu
- intensywności pieszych
- ryzyka kolizji
- prowincjonalności (centrum miasta vs przedmieście)

| Klasa | Średnie natężenie [lx] | Zastosowanie |
|---|---|---|
| P1 | 15 | reprezentacyjna ulica miasta |
| P3 | 7,5 | ulica osiedlowa |
| P5 | 3 | osiedlowa boczna |
| P7 | 1,5 | wewnętrzna do garaży |

W osiedlu mieszkaniowym ścieżka prowadząca do bloku — klasa P5 lub P7.

## Praktyczne wskazówki

1. **Naświetlacz z PIR przy drzwiach** — minimum bezpieczeństwa, ale ustaw kąt PIR, by reagował na podjeżdżające auto, nie na każdy listek wiatrem.
2. **Słupki wzdłuż podjazdu** — co 3-5 m, na zmianę z obu stron lub szachownica.
3. **Iluminacja drzewa** — 2-3 reflektory od dołu, asymetrycznie (efekt 3D).
4. **Nie świeć w okna sąsiada** — „zanieczyszczenie świetlne" + skarga = realny problem prawny.
5. **Transformatory SELV w garażu, nie w trawniku** — łatwiejsza konserwacja, zimowa kontrola.
6. **Kable** — w ziemi typu **YKY** lub **NYY-J** w peszlu DVK, na głębokości min. 50 cm, z taśmą ostrzegawczą 20 cm wyżej.
7. **Każda oprawa zewnętrzna = osobne uziemienie PE** — przewód YKY 3×1,5 mm² z 3-żyłowym podejściem (L+N+PE) nawet do SELV (PE od strony zasilacza).
8. **Strefa wokół basenu** — IP68, SELV, dodatkowe RCD typu A 30 mA + uziemienie ekwipotencjalne.

## Co dalej

➡ [Sekcja 09 — Uziemienie i ochrona](../09-uziemienie/index.html)
