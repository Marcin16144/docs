# Źródła światła

Dziś w domu króluje **LED**, ale warto rozumieć dawne technologie — bo wciąż żyją w komercji i pracowniach, a tanie LED-y często powielają ich wady (np. migotanie świetlówek).

## Porównanie technologii

| Technologia | Skuteczność [lm/W] | Żywotność [h] | CRI | Dimming | Status |
|---|---|---|---|---|---|
| Żarówka klasyczna | 10-15 | 1 000 | 100 | tak | **wycofana 2012** (UE) |
| Halogen 230 V | 15-25 | 2 000 | 100 | tak | wycofywany |
| Halogen 12 V (MR16) | 15-25 | 4 000 | 100 | tak | wycofywany |
| Świetlówka liniowa T5/T8 | 60-100 | 15 000 | 70-90 | tak (specjalne) | wycofywana (rtęć) |
| Świetlówka kompaktowa CFL | 50-65 | 8 000 | 70-85 | rzadko | **wycofana 2023** (UE) |
| **LED SMD** | **80-110** | **25 000 - 50 000** | 80-95 | tak (dimm) | dominująca |
| LED COB | 90-130 | 30 000 - 50 000 | 90-95 | tak | premium |
| LED filament (vintage) | 80-100 | 25 000 | 80-90 | tak | dekoracyjna |
| Lampa wyładowcza (HID, MH, Na) | 80-150 | 12 000 - 24 000 | 25-90 | brak | przemysł / uliczne |

## Żarówka klasyczna (żarówka)

Drut wolframowy rozgrzewany przez prąd. **Wycofana w UE od września 2012** (dyrektywa EuP 244/2009). W praktyce widywana jeszcze w piekarnikach (specjalne, odporne na temperaturę) i lodówkach.

- skuteczność 12 lm/W — fatalna
- 90% energii idzie w ciepło
- CRI = 100, ciepły kolor 2700 K (zaleta dekoracyjna)

## Halogen

Lepsza wersja żarówki: drut w gazie halogenowym (jod/brom), cykl regeneracyjny przedłuża życie i pozwala na wyższą temperaturę pracy.

- skuteczność 18-25 lm/W
- ciepły kolor, CRI 100
- gorąca (uwaga na osprzęt, możliwy pożar zasłon!)
- **wycofywany etapowo** — od 2018 ogólne stosowanie

Warianty:

- **MR16** — z reflektorem 12 V (wymaga transformatora)
- **GU10** — 230 V, bezpośrednio do oprawy
- **G4, G9** — kapsułkowe do lamp dekoracyjnych

## Świetlówka liniowa

Wyładowanie w gazie (rtęć + argon) wzbudza luminofor pokrywający rurę. Wymaga **statecznika** (klasyczny dławik lub elektroniczny EVG).

- skuteczność 60-100 lm/W
- żywotność 15 000 h
- migotanie 100 Hz (klasyczny statecznik) lub bez migotania (EVG)
- **zawiera rtęć** — wycofywane przez RoHS

Świetlówki kompaktowe (CFL, „energooszczędne") — **wycofane w UE od września 2023** (rozporządzenie 2019/2020).

## LED — dominująca technologia

Dioda elektroluminescencyjna: półprzewodnik (zwykle GaN, InGaN) emituje światło pod wpływem przepływu prądu w kierunku przewodzenia. **Niebieska dioda + luminofor (YAG:Ce) = białe światło**.

### LED SMD vs COB

| Cecha | SMD (Surface Mounted Device) | COB (Chip On Board) |
|---|---|---|
| Konstrukcja | wiele małych chipów rozsianych | jeden duży obszar diod pod luminoforem |
| Światło | wieloźródłowe, czasem widać „kropki" | jednolite, jak jednoźródłowe |
| Strumień | umiarkowany do dużego | duży (oprawy ciągłe, downlighty) |
| Cena | niska-średnia | wyższa |
| Zastosowanie | listwy, panele, zwykłe żarówki | downlighty, oprawy skierunkowane |

### LED filament

Diody ułożone na cienkim pasku przypominającym drut żarówki — efekt „retro" (Edisonowski).

- piękny estetycznie, dobry CRI
- bez radiatora (chłodzenie gazem w bańce)
- niska moc (max 4-8 W)
- zazwyczaj **niedimowalny** — sprawdź na opakowaniu

### Krytyczna kwestia — driver

LED to półprzewodnik wymagający **stałego prądu** (constant current). Driver (zasilacz) konwertuje 230 V AC na np. 24 V DC stabilizowane prądowo.

| Rodzaj drivera | Wady | Zalety |
|---|---|---|
| Tani liniowy / pojemnościowy | duże straty, migotanie, krótka żywotność | super tani |
| Impulsowy SMPS bez izolacji | migotanie PWM, słaba filtracja | tani, kompaktowy |
| **Impulsowy SMPS izolowany** | wyższa cena | brak migotania, dobry współczynnik mocy |
| Wysokiej klasy „flicker-free" | drogi | zerowe migotanie, dimowanie |

**Zasada:** najtańsza żarówka LED 10 W za 7 zł = tani driver = migotanie i 3000 h zamiast deklarowanych 25 000.

## Migotanie (flicker)

Tani driver tworzy „pulsujące" światło 100 Hz (dwukrotność 50 Hz sieci) z głębokością modulacji 30-100%. Skutki:

- zmęczenie oczu, bóle głowy (efekt natychmiastowy)
- problemy z koncentracją (dzieci, biuro)
- efekt stroboskopowy (wirujące wentylatory wyglądają „zatrzymane")

### Parametry do sprawdzenia

| Parametr | Dobra wartość |
|---|---|
| Częstotliwość PWM | **≥ 25 kHz** (niedostrzegalna dla oka) |
| Głębokość modulacji | **< 8%** (najlepiej 0%) |
| „Flicker-free" / „No flicker" | obecna na karcie produktu |
| SVM (Stroboscopic Visibility Measure) | < 0,4 |

## Co kupować w domu (skrót)

| Pomieszczenie | Rekomendacja |
|---|---|
| Salon, sypialnia | LED SMD 2700-3000 K, CRI 90+, dimmable, flicker-free |
| Kuchnia | LED 3000-4000 K, CRI 90+, IP44 nad zlewem |
| Łazienka | LED 3000-4000 K, CRI 90+, IP44 ogólne / IP65 nad prysznicem |
| Garaż / piwnica | LED 4000 K, CRI 80, IP65 |
| Biuro | LED 4000 K, CRI 90+, flicker-free, dimmable |
| Korytarze | LED 3000 K + czujnik PIR |
| Oświetlenie zewnętrzne | LED IP65/IP66, 4000 K |

## Co dalej

➡ [Sterowanie oświetleniem](08-04-sterowanie.md)
