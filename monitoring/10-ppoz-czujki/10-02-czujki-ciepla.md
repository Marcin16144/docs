# Czujki ciepła

## Kiedy czujka ciepła, a nie dymu

Czujki ciepła stosujemy tam, gdzie czujki dymu generowałyby **liczne fałszywe alarmy**:

- **garaże, parkingi podziemne** — spaliny zawierają cząstki sadzy,
- **kuchnie** profesjonalne i domowe — dym z gotowania, opary tłuszczu,
- **kotłownie** z otwartym płomieniem — popioły, sadze,
- **łazienki, sauny, pralnie** — para wodna,
- **pomieszczenia kurzowe** — magazyny mąki, lakiernie, stolarnie.

Cena za to: czujka ciepła reaguje **później** niż dymowa, bo wymaga osiągnięcia temperatury alarmu. W przypadku pożaru tlącego (długo bez płomienia) może w ogóle nie zadziałać. Dlatego w obiektach o podwyższonym ryzyku łączymy oba typy lub stosujemy **multisensor** (dym + ciepło).

Norma odniesienia: **PN-EN 54-5** (czujki ciepła punktowe) i **PN-EN 54-22** (resetowalne czujki liniowe), **PN-EN 54-28** (nieresetowalne liniowe — np. kable termoczułe w tunelach).

## Czujka nadmiarowa (statyczna)

Najprostszy typ. Element pomiarowy (termistor NTC, bimetal, eutektyczny stop topliwy) reaguje na **przekroczenie ustalonego progu temperatury**.

Przykład: czujka klasy A1 zadziała, gdy temperatura osiągnie **54–58 °C**, niezależnie od tego, jak szybko do tego dojdzie.

**Zalety:** tania, niezawodna mechanicznie, nie generuje fałszywych alarmów przy powolnym wzroście (np. nasłonecznienie hali).
**Wady:** wolna reakcja w pomieszczeniach chłodnych, bo musi się nagrzać do progu; brak detekcji pożaru tlącego.

## Czujka termodyferencjalna (różnicowa)

Reaguje na **tempo przyrostu temperatury** — typowy próg **dT/dt > 10 K/min**.

Działanie: dwa termistory — jeden w komorze otwartej (mierzy temperaturę powietrza), drugi w komorze szczelnej (wolniej reaguje). Porównanie różnicy daje gradient. Szybki wzrost (pożar płomieniowy) → alarm nawet zanim temperatura osiągnie próg statyczny.

Większość nowoczesnych czujek to **typ kombinowany** A1R / A2S — działanie różnicowe + próg statyczny (*rate of rise + fixed*).

## Klasy czujek ciepła wg PN-EN 54-5

Klasa określa **typową temperaturę zadziałania** i **maksymalną dopuszczalną temperaturę otoczenia roboczego**:

| Klasa | Temp. typowa zadziałania | Maks. temp. otoczenia | Typowe zastosowanie |
|---|---|---|---|
| **A1** | 54–65 °C | 25 °C | biura, mieszkania, korytarze klimatyzowane |
| **A2** | 54–70 °C | 35 °C | magazyny, parkingi podziemne |
| **B** | 69–85 °C | 40 °C | kuchnie nieklimatyzowane, hale |
| **C** | 84–100 °C | 55 °C | kotłownie, suszarnie |
| **D** | 99–115 °C | 70 °C | piekarnie, pralnie chemiczne |
| **E** | 114–130 °C | 85 °C | hartownie, lakiernie z piecem |
| **F** | 129–145 °C | 100 °C | procesy technologiczne wysokotemp. |
| **G** | 144–160 °C | 115 °C | specjalne — np. tunele suszące |

Dodatkowy znacznik:

- **R** (rate of rise) — czujka różnicowa, np. „A1R" = A1 + różnicowa,
- **S** (static) — czujka nadmiarowa bez funkcji różnicowej, np. „A2S".

Zasada doboru: **maksymalna temperatura otoczenia ≤ 25 K niższa od progu zadziałania**, by uniknąć fałszywych alarmów latem (nasłoneczniony strych może mieć >50 °C).

## Czujka liniowa ciepła (kabel termoczuły)

Specjalne kable wzdłuż całej długości chronionej trasy:

- **nieresetowalne** (PN-EN 54-28): dwa przewodniki w izolacji topliwej — w temperaturze alarmowej (najczęściej 68 / 88 / 105 / 138 / 180 °C) izolacja topi się, dochodzi do zwarcia → alarm. Po zadziałaniu wymiana odcinka. Marki: Protectowire, Kidde, Securiton.
- **resetowalne** (PN-EN 54-22): włókno światłowodowe z analizą rozproszenia Ramana — dokładna lokalizacja co 1 m na trasie do 8 km. Marki: Listec, AP Sensing.

**Zastosowania:** tunele drogowe i kolejowe, korytarze kablowe, taśmociągi, garaże podziemne, parkingi piętrowe, składowiska gumy/opon.

## Multisensory (czujki łączone)

Łączą sensor dymu (optyczny) z sensorem ciepła (najczęściej A1R). Logika alarmu:

- **OR** — zadziałanie któregokolwiek sensora alarm,
- **AND** — wymagane oba (mniej fałszywych alarmów, ale wolniej),
- **algorytm adaptacyjny** — wagi sensorów zmieniają się w zależności od godziny, dnia, historii.

**Przykłady:** Polon-Alfa DUR-4047 (dym opt. + ciepło), Bosch FAP-425-O-T, Hochiki ACB-EW, Apollo XP95 Multisensor. Standard w nowoczesnych obiektach o znaczeniu pożarowym (hotele, szpitale, biurowce, galerie).

## Dobór czujki — szybka tabela

| Pomieszczenie | Temp. normalna | Zalecana czujka |
|---|---|---|
| Biuro, sypialnia, korytarz | 20 °C | dymowa optyczna / multisensor A1R |
| Garaż jednostanowiskowy ogrzewany | 10–20 °C | ciepła A1R |
| Parking podziemny | 5–25 °C | ciepła A2R + CO |
| Kuchnia domowa | do 40 °C | ciepła A2S (montaż >2 m od kuchenki) |
| Kuchnia restauracyjna | 40–60 °C | ciepła B lub C |
| Kotłownia gazowa | 30–40 °C | ciepła B + czujka CO |
| Lakiernia z piecem | do 80 °C | ciepła D/E + ewentualna gazu |
| Sauna | do 110 °C | ciepła F (specjalna IP) |

## Konkretne modele polskiego rynku

- **Polon-Alfa TUN-4046** — adresowalna ciepła klasa A1R, do POLON 6000. Cena ~120 zł.
- **Polon-Alfa TUN-38** — konwencjonalna, klasa A1R, do POLON 4xxx. ~80 zł.
- **Bosch FAH-425-TR** — adresowalna, A1R, do AVENAR / Modular 5000.
- **Hochiki ATG-EW** — adresowalna, klasy A1S/A2S/CS programowane.
- **Apollo XP95 Heat Detector** — adresowalna, klasy A1R/CR.

## Montaż — zasady

Wg **PN-EN 54-14**:

1. max powierzchnia chroniona jedną czujką ciepła punktową — **~30 m²** (mniejsza niż dymowej),
2. max wysokość sufitu — **9 m dla A/B**, mniej dla wyższych klas,
3. odległość od ściany min. **0,5 m**, od kratek wentylacyjnych min. **1 m**,
4. nie montować w przeciągu nawiewu — może chłodzić sensor,
5. w garażach wielostanowiskowych — dodatkowo rozłożone czujki CO (parkingi powyżej 2 stanowisk wymagają wentylacji wymuszonej z detekcją CO).

## Co dalej

➡ [Czujki tlenku węgla](10-03-czujki-co.md)
