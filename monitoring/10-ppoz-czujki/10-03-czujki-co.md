# Czujki tlenku węgla (CO)

## Czym jest tlenek węgla i dlaczego zabija

**CO (tlenek węgla, „czad")** to bezbarwny, bezwonny gaz powstający przy **niezupełnym spalaniu paliw węglowodorowych** (gaz ziemny, propan-butan, węgiel, drewno, benzyna). Powstaje przy:

- niesprawnej, zarośniętej sadzą wentylacji grawitacyjnej kotłowni,
- uszkodzonych lub źle ustawionych palnikach gazowych,
- zatkanym kominie / przewodzie spalinowym,
- pracującym silniku samochodu w zamkniętym garażu,
- nieszczelnym piecu kaflowym, kominku.

Mechanizm działania na organizm: CO wiąże się z **hemoglobiną ~240× silniej niż tlen** (powstaje karboksyhemoglobina HbCO), blokując transport tlenu. Skutki:

| HbCO we krwi | Objawy |
|---|---|
| 10 % | ból głowy, lekkie zawroty |
| 20 % | silny ból głowy, mdłości |
| 30 % | splątanie, zaburzenia widzenia |
| 40–50 % | omdlenie, drgawki |
| >60 % | śpiączka, zgon w <1 h |

> W Polsce każdego sezonu grzewczego (X–IV) **kilkadziesiąt osób umiera**, a kilka tysięcy trafia do szpitali z zatruciem CO. Czujka czadu za ~80 zł rozwiązuje 95 % przypadków.

## Sensor elektrochemiczny — zasada działania

Najpopularniejszy i najdokładniejszy typ. Komora zawiera dwie elektrody (anoda, katoda) zanurzone w elektrolicie (najczęściej kwas siarkowy). Membrana selektywna przepuszcza tylko CO.

Reakcja: `CO + H₂O → CO₂ + 2H⁺ + 2e⁻` — przepływ elektronów daje mierzalny prąd proporcjonalny do stężenia CO. Typowy zakres pomiaru **0–500 ppm**, rozdzielczość 1 ppm.

Inne sensory (mniej dokładne, używane w tańszych czujkach): półprzewodnikowe SnO₂, kataliczne (palne, dla zakresów %LEL nie ppm).

**Żywotność sensora elektrochemicznego: 5–10 lat** — po tym czasie elektrolit wysycha, dokładność spada. Czujka ma datę produkcji i tzw. *end-of-life* sygnalizację (specjalny sygnał dźwiękowy lub LED).

## Progi alarmowe wg PN-EN 50291 (czujki domowe)

Norma **PN-EN 50291-1:2018** definiuje czas, po jakim czujka MUSI wywołać alarm w zależności od stężenia:

| Stężenie CO | Czas alarmu — max | Czas alarmu — min |
|---|---|---|
| **30 ppm** | brak alarmu (możliwy ale niewymagany) | 120 min |
| **50 ppm** | 60–90 min | 60 min (alarm między 60 a 90 min) |
| **100 ppm** | 10–40 min | 10 min |
| **300 ppm** | 3 min | — |

Konstrukcja celowa: **czujka NIE alarmuje od razu** przy 50 ppm, bo takie stężenia mogą się pojawiać krótko (np. spawanie, palacze) i były niekoniecznie niebezpieczne. Ostrzega dopiero, gdy stężenie utrzymuje się dłużej — wtedy organizm zaczyna kumulować HbCO.

### Próg referencyjny — niebezpieczne dla zdrowia

- **50 ppm** — dopuszczalne narażenie zawodowe 8h (NDS),
- **200 ppm** — silny ból głowy po 2–3 h,
- **400 ppm** — niebezpieczne dla życia po 1–2 h, śmierć po 3 h,
- **800 ppm** — utrata przytomności w 45 min, śmierć w 2 h,
- **1600 ppm** — śmierć w 1 h.

## Czujki domowe (PN-EN 50291)

Autonomiczne urządzenia z zasilaniem bateryjnym lub sieciowym.

### Zasilanie

- **baterie wymienne** (3× AA / 9V) — żywotność 1–2 lata, sygnalizacja niskiego stanu,
- **baterie litowe zapieczętowane** — żywotność **7–10 lat** (równa żywotności sensora), po końcu wymiana całej czujki,
- **230 V z podtrzymaniem bateryjnym** — najbezpieczniejsze, brak ryzyka rozładowanej baterii.

### Funkcje

- wyświetlacz LCD z aktualnym stężeniem CO i temperaturą,
- pamięć szczytowego stężenia (peak memory) — pozwala stwierdzić poziom zagrożenia po fakcie,
- alarm głośny (~85 dB @ 1 m) z odróżnialnym wzorem ICAO T3 (4 piski + przerwa),
- łączenie radiowe wielu czujek (np. Nest Protect, X-Sense XC04-WR) — alarm w piwnicy wybudza całą rodzinę,
- integracja smart home (Z-Wave, Zigbee, WiFi) — powiadomienia push, sterowanie wentylacją.

### Modele rekomendowane (Polska, 2026)

| Model | Zasilanie | Cena | Uwagi |
|---|---|---|---|
| Kidde 10LLCO | litowa 10 lat | 110 zł | certyfikat EN 50291, prosty |
| FireAngel CO-9X-10 | litowa 10 lat | 140 zł | czujnik Wisesafe, LCD |
| X-Sense XC04-WX | 3× AA | 120 zł | WiFi, push (X-Sense Home) |
| Bosch Ferion 4000 O CO | 2× AA, sieć | 250 zł | integracja smart home |
| Nest Protect 2 | 6× AA / 230 V | 650 zł | dym + CO + Google Home, mowa |

## Czujki profesjonalne (PN-EN 54-26)

Stosowane w systemach SAP — adresowalne, podłączone do pętli centrali. Charakteryzują się:

- zasilanie z pętli (~24 V DC z centrali) + zasilanie awaryjne z akumulatorów centrali,
- dokładniejszy sensor (kalibracja fabryczna + co 1 rok),
- protokoły komunikacji właściwe producentowi (np. POLON, Avenar, ESSER IQ8),
- integracja z innymi czujkami (CO + dym + ciepło — wspólny multisensor),
- sterowanie urządzeniami: **auto-uruchamianie wentylacji** garażu, zamknięcie zaworu gazu (MAG-3), powiadomienie SOK / monitoringu.

**Przykłady:** Polon-Alfa DGW-6046 (multisensor dym + CO), Bosch FCG-410, ESSER 9100, Hochiki ACD-EW.

## Czujki CO w garażach i parkingach

W Polsce **obowiązek wentylacji wymuszonej** dotyczy:

- garaży zamkniętych powyżej **3 stanowisk** (Rozp. Min. Infr. ws. warunków technicznych),
- parkingów podziemnych, niezależnie od liczby stanowisk.

Sterowanie wentylacji opiera się na **detekcji CO**:

- pierwszy próg uruchomienia wentylacji: **50 ppm**,
- drugi próg (max wydajność): **100 ppm**,
- alarm + sygnał ewakuacji: **300 ppm**.

System: kilka czujek liniowych lub punktowych (jedna na 400 m² garażu) + sterownik wentylacji (przekaźniki na falowniku wentylatora). Często komorą jonową lub elektrochemiczną w obudowie IP65.

## Montaż — gdzie i jak

CO ma **gęstość zbliżoną do powietrza** (0,97), więc rozprzestrzenia się równomiernie. W przeciwieństwie do dymu nie unosi się aż tak intensywnie.

| Miejsce | Wysokość montażu |
|---|---|
| Sypialnia, salon | na ścianie 1,5–1,8 m, lub na suficie |
| Kotłownia | ~1,5 m od podłogi, 1–3 m od kotła |
| Garaż | 1,5 m, w pobliżu wyjścia, nie nad samochodem |
| Korytarz przy sypialniach | na ścianie 1,5–1,8 m, by spać blisko |

**Czego unikać:**

- bezpośrednio nad kuchenką / piecem (fałszywe alarmy),
- w łazience (wilgoć skraca żywotność sensora),
- w przeciągu (mała wymiana powietrza w pomieszczeniu nie daje reprezentatywnej próbki),
- w garażu w temperaturze < -10 °C lub > +40 °C (poza zakresem roboczym).

Najczęstszy błąd: kupno tylko czujki dymu „bo wystarczy". CO jest osobnym zagrożeniem (nie ma dymu z gazu ziemnego) — czujka dymu NIE wykryje czadu.

## Co dalej

➡ [Spis sekcji 10](index.md)
