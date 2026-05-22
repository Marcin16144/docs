# SPD — typy 1, 2, 3

## Co to jest SPD

**SPD** (*Surge Protection Device*, ogranicznik przepięć) to element instalacji, który:

- normalnie pracuje jako **otwarty obwód** (izolator),
- po przekroczeniu napięcia progowego **zwarcie do PE** (na czas mikrosekund),
- ogranicza napięcie szczytowe do bezpiecznej wartości **Up**,
- po przepłynięciu impulsu wraca do stanu izolatora.

Norma: **PN-EN 61643-11** (SPD do sieci niskiego napięcia).

## Trzy typy SPD wg PN-EN 61643-11

| Typ wg PN | Stara klasa | Test | Kształt impulsu | Lokalizacja |
|---|---|---|---|---|
| **Typ 1 (T1)** | klasa B | I (Iimp) | **10/350 µs** | złącze ZK, rozdzielnica budynków z LPS |
| **Typ 2 (T2)** | klasa C | II (In) | **8/20 µs** | rozdzielnica główna |
| **Typ 3 (T3)** | klasa D | III (Uoc) | 8/20 µs (małe energie) | blisko odbiornika, gniazdo |

### Co oznaczają kształty impulsów

- **10/350 µs** — czas narastania 10 µs, opadanie do 50% w 350 µs. **Symuluje bezpośrednie uderzenie pioruna**. Duża energia, duży ładunek.
- **8/20 µs** — narastanie 8 µs, opadanie 20 µs. Symuluje **przepięcie indukowane** lub łączeniowe. Mniejsza energia.

```
napięcie/prąd
   ▲
   │  ╱╲                        impuls 10/350
   │ ╱  ╲___                    (piorun bezpośredni)
   │╱       \___
   │            \__________
   └─────────────────────────► czas [µs]
   0  10        100      350

napięcie/prąd
   ▲
   │ ╱╲                         impuls 8/20
   │╱  \_                       (indukowany / łączeniowy)
   │     \__
   │        \____
   └─────────────────────────► czas [µs]
   0  8  20    40
```

## Typ 1 — ogranicznik odgromowy

**Stosowany gdy:**

- budynek ma **instalację odgromową (LPS)**,
- linia zasilająca jest napowietrzna w terenie otwartym,
- budynek bardzo wysoki / odsłonięty.

**Parametry typowe:**

| Parametr | Wartość |
|---|---|
| Iimp (10/350 µs) | **12,5 / 25 / 50 / 100 kA** na biegun |
| Up | < 2,5 kV (typowo 1,5 kV) |
| Uc (napięcie pracy ciągłej) | 255 V AC (sieć 230 V) |
| Czas reakcji | < 100 ns |

**Technologia:**

- **iskiernikowe** (gas discharge tube + iskiernik) — najczęstsze T1, wytrzymują duże ładunki, długo żyją; mają „prąd następczy" (po impulsie sieć podaje prąd zwarcia — wymaga pre-fuse),
- **warystorowe** (MOV — *Metal Oxide Varistor*) — szybsza reakcja, ale mniejsza energia; rzadziej w T1.

**Producenci:** Dehn (DSH, DBM), OBO Bettermann (V-50, V-25), Phoenix, Schneider (iQuick PRD), Hager (SPN).

## Typ 2 — ogranicznik przeciwprzepięciowy

**Standardowe rozwiązanie dla domu jednorodzinnego bez LPS.**

**Parametry typowe:**

| Parametr | Wartość |
|---|---|
| In (8/20 µs, prąd nominalny) | **5 / 20 / 40 kA** na biegun |
| Imax (8/20 µs, prąd maks.) | **15 / 40 / 70 kA** |
| Up | < 1,5 kV (typowo 1,2 kV) |
| Uc | 275 V AC |
| Czas reakcji | < 25 ns |

**Technologia:** **warystorowa (MOV)** — niemal zawsze.

Warystor to półprzewodnik z **nieliniową charakterystyką U-I**:

- przy U < Uc → prawie nie przewodzi (Imax ~ µA),
- przy U > Up → przewodzi gwałtownie, „obcinając" napięcie.

**Producenci typowi:** Dehn DG, OBO V20, Hager SP, Schneider iPRD40r, Eaton SPDT2, Citel DUO.

## Typ 3 — fine protection

**Lokalna ochrona „ostatniej szansy"** blisko czułego odbiornika.

**Parametry typowe:**

| Parametr | Wartość |
|---|---|
| Uoc (napięcie próby otwartego obwodu) | 6 kV |
| Isc (prąd próby zwarcia) | 3 kA |
| Up | < 1,2 kV (typowo 0,8 kV) |
| Czas reakcji | < 25 ns |

**Formy występowania:**

- listwy przeciwprzepięciowe (Acar, APC, Eaton),
- gniazda z wbudowanym SPD,
- moduły do puszki pod gniazdem,
- moduły w UPS-ach.

**Kiedy stosować T3:**

- TV, sprzęt audio, kino domowe,
- komputery, NAS, serwery domowe,
- centrale alarmowe i smart-home,
- sterowniki kotłów, pomp ciepła, pompowni.

## Kombinowane T1+T2 (CombiArrester)

Łączą funkcję T1 i T2 w jednym module — często wybór dla domu z LPS, kiedy w rozdzielnicy mało miejsca.

| Parametr | T1+T2 typowy |
|---|---|
| Iimp (10/350) | 12,5–25 kA na biegun |
| In (8/20) | 25–50 kA |
| Up | < 1,5 kV |

Wadą jest **wyższa cena** i często **gorsze Up** niż osobne T2.

## Napięcie ochronne Up — kluczowy parametr

**Up** to napięcie szczątkowe na zaciskach SPD przy znamionowym impulsie. Im niższe Up, tym lepsza ochrona.

| Up | Ocena dla domu (CAT II = 2,5 kV) |
|---|---|
| < 0,9 kV | doskonała (T3 lub T2 premium) |
| 1,2 kV | bardzo dobra (T2 dobry) |
| 1,5 kV | wystarczająca (T2 standardowy) |
| 2,0 kV | minimum (T1 lub stary T2) |
| > 2,5 kV | **nie spełnia** — wymiana |

W rozdzielnicy domowej **stawiaj T2 z Up ≤ 1,5 kV**.

## Klasyfikacja IT i N-PE

SPD są dostępne w wersjach do różnych układów sieci:

- **L-N** — między fazą a neutralnym (TN-S, TT z N-PE),
- **L-PE** — między fazą a PE (układ wspólny),
- **N-PE** — iskiernik między N i PE (dla TT, gdzie N ≠ PE blisko),
- **3+1** — 3 warystory L-N, 1 iskiernik N-PE (standardowe rozwiązanie dla TT),
- **4+0** — 4 warystory L-PE i N-PE (dla TN-C-S).

Dla typowego domu z TN-C-S: **4+0** w wersji 1-fazowej (1+0) lub 3-fazowej (3+0).

## Wskaźnik wymiany

Każdy SPD typu 2/3 ma **okienko stanu**:

- **zielone** → moduł sprawny,
- **czerwone** → moduł uszkodzony (po dużym przepięciu lub starości),
- niektóre mają **styk pomocniczy 1NC/1NO** — można podłączyć do sterownika smart-home i mieć alarm.

## Co dalej

➡ [Dobór i montaż SPD](10-03-dobor-montaz.md)
