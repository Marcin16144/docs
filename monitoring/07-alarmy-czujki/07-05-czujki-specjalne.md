# Czujki specjalne — zalanie, gaz, stłuczenie szkła

> Detektory zagrożeń innych niż włamanie — zalania, ulot gazów, wstrząsy, stłuczenia szkła. Często ratują od strat większych niż kradzież.

## Czujki zalania (water leak detectors)

Składają się z **sondy wodnej** (dwa metalowe styki na płytce) i modułu elektronicznego. Woda zwierająca elektrody = sygnał alarmowy. Sonda umieszczana na podłodze w miejscu najbardziej narażonym na wyciek.

### Typowe lokalizacje sondy

- pod pralką, zmywarką — wycieki z węży doprowadzających i odprowadzających
- pod zlewem (w szafce kuchennej, łazienkowej) — odpływ syfonu
- w pomieszczeniu z kotłem CO, bojlerem, zbiornikiem ciepłej wody
- w pralni / sucharni / pomieszczeniu gospodarczym
- na podłodze piwnicy (zalanie wodą gruntową, podtopienie po nawałnicy)
- za toaletą (wyciek z spłuczki, dolnopłuk)

### Modele i parametry

| Model | Cechy | Cena |
|---|---|---|
| Satel FD-1 | sonda kablowa 3 m, wyjście NC+TMP, 12 V DC | 80 PLN |
| Satel AFD-100 (ABAX2) | bezprzewodowa, bateria 5 lat, sonda wymienna | 250 PLN |
| DSC PG9985 (PowerG) | bezprzewodowa, sonda + sensor temperatury | 300 PLN |
| Shelly Flood (Wi-Fi) | autonomiczna do Home Assistant, bateria 2× AAA | 120 PLN |
| Fibaro Flood Sensor | Z-Wave, podłoga akustyczna + temperatura | 350 PLN |

### Aktywna ochrona — zawór odcinający

Sama detekcja to dopiero połowa sukcesu. Pełna ochrona to **automatyczne odcięcie wody** po wykryciu zalania:

- **Zawór z napędem 230 V** na głównym przyłączu wody (Honeywell V8043, Watts WC-04, Tubonet AquaStop)
- Aktywacja po przekaźniku centrali alarmowej (strefa 24h zalanie → wyjście PGM → zawór zamyka się)
- Czas zamykania 5–30 s; pobór prądu 0,5–2 A (przekaźnik buforowy konieczny)
- Alternatywa: gotowy system z czujkami i zaworem (Grohe Sense, Bosch Smart Home Water Detector)

Koszt instalacji „alarm + zawór" w domu jednorodzinnym: 1500–3000 PLN. Średnia szkoda po pęknięciu rury w łazience: 30 000–80 000 PLN. ROI dramatyczne.

## Czujki gazu — CH4 (gaz ziemny) i LPG (propan-butan)

Czujka gazu zawiera sensor **katalityczny** lub **półprzewodnikowy**, który zmienia rezystancję w obecności gazu palnego. Sygnał wyzwalany na poziomie typowo **10–20% DGW** (Dolnej Granicy Wybuchowości).

| Gaz | DGW (% obj.) | Próg alarmu (10% DGW) | Gdzie montować |
|---|---|---|---|
| **Metan (CH4)** | 5,0% | 500 ppm | **pod sufitem** — gaz ziemny jest lżejszy od powietrza |
| **Propan-butan (LPG)** | 1,8% (propan) | 180 ppm | **przy podłodze** (do 30 cm) — LPG jest cięższy od powietrza |
| **CO (tlenek węgla)** | — | 30 / 50 / 100 ppm | 1,5 m od podłogi, na poziomie głowy |

**CO to nie gaz palny**, tylko trujący — sensor i działanie są zupełnie inne. Czujki CO są opisane w sekcji 10-03 (ppoż). Sama instalacja gazowa wymaga osobnej czujki gazu palnego (CH4/LPG) *oraz* osobnej czujki CO jeśli jest piec gazowy.

### Modele

| Model | Gaz | Wyjścia | Cena |
|---|---|---|---|
| Satel GD-1 (lub GD-1G dla CH4) | LPG / CH4 | NC alarm + TMP + LED | 180 PLN |
| DSC PG9933 | CO + ciepło | bezprzewodowy PowerG | 400 PLN |
| Gazex DEX/A-LPG | LPG | z certyfikatem PCA, do kotłowni | 500 PLN |
| Gazex DG-3 | CH4 + LPG + CO | 3-w-1, do kotłowni gazowej | 1200 PLN |

### Zawór odcinający gaz (MAG)

Analogicznie do wody — czujka aktywuje **elektromagnetyczny zawór odcinający gaz** (MAG-3, MAG-DN15/DN20). Montowany na rurze gazowej, normalnie otwarty, zamyka się przy impulsie 12 V. Wymóg w obiektach handlowych z gastronomią, w domach często instalowany dobrowolnie.

Standardy: PN-EN 50194-1 dla czujek gazu palnego; PN-EN 50291-1 dla czujek CO.

## Czujki sejsmiczne (wstrząsowe) — ochrona sejfów

Sejsmiczne (vibration / shock) reagują na **uderzenia, wiercenie, cięcie** próbujące otworzyć sejf, kasę pancerną lub bankomat. Sensor piezoelektryczny lub akcelerometr w obudowie przyklejanej do metalu.

- 3 poziomy progu (LOW / MED / HIGH) regulowane potencjometrem
- filtr cyfrowy odrzucający pojedyncze stuknięcia (otoczenie)
- autoadaptacja do drgań stałych (np. pracujący silnik klimatyzacji)

| Model | Cechy |
|---|---|
| GJD Pearl | akcelerometr, IP54, sieć ramek po kontroli wzbudzenia |
| Texecom Veritas Shock | filtr DSP, 3 progi czułości |
| Detec D-7 | piezo + procesor, do sejfów klasy 1-5 |
| Vanderbilt SE-IS412-A4 | klasa Grade 3, certyfikat EN 50131-2-8 |

Czujka sejsmiczna na sejfie powinna być w **strefie 24h** — sejf jest atakowany niezależnie od stanu uzbrojenia całej centrali.

## Czujki stłuczenia szkła (glass-break)

Detekują charakterystyczny **dźwięk pękania szkła**. Działają na zasadzie analizy akustycznej (mikrofon + DSP), wyzwalają się dopiero po wykryciu pełnego profilu dźwiękowego: niski impuls (uderzenie) + wysokie częstotliwości (chrzęst pękającego szkła) w określonej kolejności.

### Dwa typy

| Typ | Zasada | Zalety / wady |
|---|---|---|
| **Akustyczne** (audio glass-break) | mikrofon słucha całego pomieszczenia | + duży zasięg (do 9 m promień), montaż na suficie lub ścianie<br>− fałszywki od stłuczenia szklanki / butelki |
| **Wstrząsowo-akustyczne** (dual-tech glass break) | czujnik wstrząsu na szybie + mikrofon | + bardzo wysokie bezpieczeństwo (oba kanały)<br>− wymaga przyklejenia na każdej szybie |

### Modele

| Model | Typ | Zasięg |
|---|---|---|
| Satel INDIGO | akustyczna | 9 m |
| DSC AC-100 | akustyczna | 7,6 m (360°) |
| Bosch ISC-SK1-WA-04 | akustyczna + wstrząsowa | 9 m audio + sensor na szybie |
| Honeywell FlexGuard FG-1625 | akustyczna 4-stage | 9 m, anti-mask |

Czujka akustyczna „słyszy" wszystkie szyby w pomieszczeniu. **Test po montażu** wymaga symulatora dźwięku stłuczenia szkła (Honeywell FG-701, Satel TEST-IND) — fizyczne tłuczenie szyby ostatecznie nie jest realne.

## Czujki wstrząsowe (vibration) na okna i ściany

Małe (Ø 20–30 mm) sensory piezo lub akcelerometr przyklejane do **szyby okna** lub **ramy**. Reagują na drgania powstające przy próbie wybicia / wycięcia szyby:

- uderzenia (zbicie szyby kamieniem, młotkiem)
- cięcie diamentowym diamentem szklarskim
- wiercenie przy wzmocnionym szkle bezpiecznym

Modele: Satel DG-1; Texecom Impaq SC; Detec D-8. Cena: 80–200 PLN za sztukę.

## Inne czujki rzadko spotykane

### Czujki przechyłu (tilt)

Wykrywają zmianę pozycji obiektu (np. radia samochodowego, telewizora, obrazu na ścianie). Sensor: kulka rtęciowa lub żyroskop MEMS. Stosowane do ochrony eksponatów muzealnych, drogiego sprzętu.

### Czujki temperatury (rozszerzone, nie ppoż)

Zwykła sonda Pt100 lub termopara z modułem progu. Zastosowanie: alarm przy spadku temperatury w kotłowni (zamarznięcie instalacji) lub wzroście (przegrzanie serwerowni).

### Czujki zaniku zasilania (PSU monitor)

Wyzwalają alarm techniczny przy zaniku 230 V (poza zasilaniem awaryjnym samej centrali). Sygnalizacja na SMS/push: „prąd zniknął w obiekcie" — istotne dla zamrażarek, akwariów, terrarium.

## Konfiguracja stref dla czujek specjalnych

| Czujka | Strefa | Typ alarmu |
|---|---|---|
| Zalanie | 24h techniczna | cichy + SMS + zamknięcie zaworu |
| Gaz CH4/LPG | 24h pożarowa | syrena głośna + SMS + zamknięcie MAG |
| CO | 24h pożarowa | syrena z innym tonem + powiadomienie |
| Sejsmiczna (sejf) | 24h alarmowa | syrena głośna + monitoring |
| Glass-break | uzbrojona / pełna | jak normalny alarm włamaniowy |
| Wstrząsowa (okno) | uzbrojona / perymetr | jw., często strefa „pre-alarm" przy 1 wzbudzeniu |

## Co dalej

➡ [Spis sekcji 07](index.md)
