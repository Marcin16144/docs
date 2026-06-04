# Kurtyny i czujki zewnętrzne

> Ochrona perymetru działki, elewacji, witryn i okien — zanim intruz wejdzie do obiektu. Detekcja na zewnątrz to inny świat niż wnętrze: pogoda, zwierzęta, oświetlenie.

## Specyfika środowiska zewnętrznego

Czujka zewnętrzna musi sobie radzić ze zjawiskami, których czujka wewnętrzna nigdy nie doświadczy:

- **Temperatura**: −35 do +60 °C — wymagana grzałka sensora poniżej 0 °C
- **Wilgoć i woda**: deszcz, śnieg, mgła — wymagana obudowa IP55–IP67
- **Słońce**: bezpośrednie promieniowanie zaburza pirosensor — daszki, soczewki zaślepione od góry
- **Wiatr**: kołyszące się gałęzie, krzewy, śmieci unoszone w powietrzu — fałszywe alarmy
- **Zwierzęta**: ptaki, koty, lisy, sarny, dziki — większe niż w domu, częstsze
- **Owady**: pajęczyny na soczewce, ćmy lecące do lampy IR
- **Wandalizm**: ostentacyjny atak na czujkę (kij, kamień, sprej) — wymagana obudowa antywandalowa

Próba zastosowania czujki wewnętrznej na zewnątrz (np. pod zadaszeniem tarasu) skończy się fałszywymi alarmami i awarią w pierwszej zimie. Tańsza alternatywa nie istnieje.

## PIR zewnętrzne — adaptacja PIR do trudnych warunków

Konstrukcja podobna do wewnętrznych PIR, ale z istotnymi modyfikacjami:

- obudowa IP55+ z uszczelkami silikonowymi
- grzałka sensora 12 V (dodatkowy pobór 50–100 mA przy < 0 °C)
- daszek przeciwsłoneczny i przeciwdeszczowy
- algorytmy DSP filtrujące krótkie wzbudzenia (ptaki, liście)
- najczęściej w wersji **dual PIR+MW** — bo same PIR są w trakcie deszczu/mgły zawodne

| Model | Zasięg / kąt | Funkcje | Cena |
|---|---|---|---|
| **Satel AOD-200** | 15 m / 85° | dual PIR+MW, IP54, anti-mask | 700–900 PLN |
| **Optex VXI-DAM** | 12 m / 90° | dual, SMDA, IP55, kontroler antyrotacyjny | 1100–1500 PLN |
| **Optex HX-80NAM** | 24 m × 4 m | kurtyna boczna do elewacji, IP54 | 1500 PLN |
| **Pyronix XDH10TT** | 10 m / 90° | tri-tech (3× sensor), pet 35 kg | 800 PLN |
| **Bosch ISC-PDL1-WAC30G** | 30 m / 90° | long-range, Grade 3 outdoor | 1300 PLN |

## Kurtyny PIR — wąska wiązka wzdłuż ściany

Specjalna soczewka skupia detekcję w **wąską, pionową płaszczyznę** (typowo 5–10° szerokości, kilkanaście stopni wysokości) — tzw. „kurtyna" lub „barrier curtain". Idealna do:

- ochrony elewacji budynku (intruz wspinający się po ścianie wzbudza kurtynę)
- ochrony okien (kurtyna nad oknem na całej szerokości)
- balkonów, tarasów
- witryn sklepowych (od wewnątrz, wzdłuż szyby)

Wąska wiązka oznacza minimalny obszar martwej strefy poza linią ochrony — kot przechodzący 50 cm od ściany nie wzbudzi kurtyny.

### Modele kurtyn zewnętrznych

| Model | Wymiary kurtyny | Uwagi |
|---|---|---|
| Optex HX-80NAM | 24 × 4 m | dual + anti-mask, kurtyna boczna |
| Optex SL-650QDP | 60 × 2 m | kurtyna pionowa, 4 wiązki PIR + MW |
| Satel COBALT Pro Pet | 10 × 2 m | kurtyna wewnętrzna nad oknem, pet 25 kg |
| Hikvision DS-PD2-D15AME-EX | 15 × 4 m | kurtyna zewnętrzna, integracja z Hikvision Hub |

## Bariery podczerwone (active IR beam) — najszczelniejszy perymetr

Aktywna bariera IR składa się z dwóch jednostek ustawionych naprzeciwko siebie: **nadajnik** (transmitter) i **odbiornik** (receiver). Między nimi emitowane są niewidzialne wiązki IR — przerwanie którejkolwiek = alarm.

### Liczba wiązek — niezawodność detekcji

| Liczba wiązek | Logika | Charakter ochrony |
|---|---|---|
| **2 wiązki** | obie muszą być przerwane jednocześnie | tania, dla małych obiektów; ptak ją przejdzie |
| **4 wiązki** | min. 2 sąsiadujące jednocześnie | standard, ignoruje małe zwierzęta |
| **6–8 wiązek** | wybór logiki — 2/3/4 sąsiednie | bariera „wysokiej trawy" do 2 m wysokości |

### Zasięg i odporność na warunki

Producenci podają **dwa zasięgi**:

- **Outdoor** — w warunkach atmosferycznych (mgła, deszcz, śnieg) zasięg spada 3–5×
- **Indoor** — bez tłumienia, maks. zasięg producenta

| Model | Outdoor / Indoor | Wiązki | Cena |
|---|---|---|---|
| Optex SL-200QFR | 60 / 200 m | 4-beam | 2000 PLN / para |
| Optex SL-650QFR | 200 / 650 m | 4-beam, Quad | 5000 PLN / para |
| Redwall RLS-3060L | 30 / 60 m (LiDAR) | laser, do 30 m wysokości | 15 000 PLN |
| Takex PB-IN-100HF | 30 / 100 m | 2-beam, IP65 | 1200 PLN / para |
| Pulnix SAB-100 | 30 / 100 m | 4-beam, anty-sabotaż | 1800 PLN / para |

Dla mgły gęstej (widoczność < 50 m) zasięg każdej bariery IR drastycznie spada. Dlatego dla obiektów w terenie nadmorskim / górskim stosuje się **bariery mikrofalowe** (Doppler) zamiast IR — fale MW przenikają mgłę.

## Tory ochrony perymetru — układy

### Pojedyncza linia bariery

```
TX ────────────────────── RX
   ← wiązki IR/MW przerwane przez intruza →
```

Najprostszy układ — bariera wzdłuż ogrodzenia. Wada: brak weryfikacji kierunku (czy intruz wchodzi czy wychodzi).

### Dwie linie bariery (in/out)

```
TX1 ────────────────── RX1   (linia zewnętrzna)
       \    ↓ kolejność    /
        TX2 ──────── RX2    (linia wewnętrzna)
```

Sekwencja przerwań TX1→TX2 = intruz wchodzi. TX2→TX1 = ktoś wychodzi (np. fałszywy alarm z wnętrza obiektu).

### Pełen perymetr 4 boki

Cztery zestawy TX/RX okalające działkę. Centrale dedykowane (Optex Redwall Manager) lub Satel/DSC z 8+ wejściami strefowymi.

## Bariery mikrofalowe (Doppler perimeter)

Zamiast wiązki IR — szeroka „chmura" pola mikrofalowego między TX a RX. Ruch w polu = zmiana Dopplera = alarm.

- brak czystej „linii" przerwania — chmura jest objętościowa
- zasięg 50–250 m
- odporność na mgłę, deszcz, śnieg
- wymagany ścisły pas ochrony (brak roślinności wyższej niż 0,5 m)
- cena 8000–25 000 PLN za parę

Modele: Politec MICROTREND, Senstar UltraWave, CIAS Manta.

## Detekcja na ogrodzeniu (fence sensor)

Alternatywą do barier po linii ogrodzenia jest **sensor wibracyjny zamocowany na siatce/płocie**:

- kabel sensoryczny biegnący wzdłuż całego ogrodzenia (Senstar OmniTrax, Southwest Microwave)
- pojedyncze czujki wibracyjne co kilka metrów (Detection Systems FG-1625F)
- wykrywa próby przecinania siatki, wspinania się, podkopu
- brak fałszywek od ptaków / zwierząt do określonej masy

To rozwiązanie głównie dla obiektów strategicznych (infrastruktura krytyczna, więzienia, obiekty wojskowe) — koszty rzędu kilkuset PLN za metr ogrodzenia.

## Praktyczny dobór dla domu jednorodzinnego

| Obszar | Rekomendacja |
|---|---|
| Brama wjazdowa | 1× bariera IR 2-beam (na całą szerokość bramy) |
| Furtka | kontaktron + PIR zewnętrzny dual nad furtką |
| Elewacja od ulicy / boku | 2–3× kurtyna pionowa nad oknami parteru |
| Taras / patio | kurtyna PIR + osobna czujka stłuczenia szyby balkonowej |
| Garaż wolnostojący | PIR zewnętrzny dual przed bramą + kontaktron na bramie |
| Ogrodzenie 50 m | budżet skromny: PIR zewnętrzne na słupkach co 15 m; pro: bariera IR 4-beam |

Częsta zasada projektowa: **perymetr aktywuje się jako pierwszy** (cisza, powiadomienie SMS/push, brak syreny), a dopiero wejście do obiektu = alarm głośny + interwencja agencji. Daje to przewagę — wiesz o intruzie zanim wejdzie.

## Co dalej

➡ [Czujki specjalne — zalanie, gaz, stłuczenie](07-05-czujki-specjalne.md)
