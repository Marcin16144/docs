# Przykłady i ekonomia

Dwa kompletne projekty pokazują, jak teoria z poprzednich rozdziałów wygląda w praktyce — od doboru po koszt. Druga część rozdziału to twarda kalkulacja: ile magazyn realnie zarabia i kiedy się zwraca.

## Przykład A — magazyn 10 kWh do istniejącej PV

Dom z działającą instalacją PV 6 kWp i klasycznym inwerterem on-grid. Właściciel chce zwiększyć autokonsumpcję bez wymiany inwertera — wybór pada na **retrofit AC-coupled**.

```
SCHEMAT — retrofit AC-coupled

 Panele PV 6 kWp
        │ DC
        ▼
 Inwerter PV (istniejący)
        │ AC
        ▼
 ┌───────────────────────────┐
 │   ROZDZIELNICA / szyna AC │
 └──┬───────────┬────────────┘
    ▼           ▼
 Inwerter    Sieć OSD
 bateryjny   + licznik
    │ DC
    ▼
 MAGAZYN 10 kWh LFP, 48 V, BMS
```

- **Dobór** — dzienna nadwyżka ok. 8 kWh → magazyn 10 kWh (zgodnie z rozdziałem 18-03)
- **Topologia** — AC-coupled, bo nie rusza się sprawnego inwertera PV
- **Koszt orientacyjny** — magazyn 10 kWh + inwerter bateryjny + montaż i osprzęt: **20–30 tys. zł**

## Przykład B — nowy system DC-coupled

Budowa nowego domu, instalacja PV i magazyn planowane od razu. Brak inwertera do zachowania, więc opłaca się **DC-coupled** z inwerterem hybrydowym — wyższa sprawność ładowania.

```
SCHEMAT — system DC-coupled

 Panele PV
        │ DC
        ▼
 INWERTER HYBRYDOWY 8 kW
   PV DC ──┐      ┌── bat DC
           │      ▼
           │   MAGAZYN 15 kWh LFP
        AC │
           ▼
 ┌───────────────────────────┐
 │   ROZDZIELNICA / szyna AC │
 └──┬──────────┬─────────────┘
    ▼          ▼
 Sieć OSD   Obwody domowe
            + obwody backup
```

- **Inwerter** — hybrydowy 8 kW, obsługuje PV i baterię, ma funkcję backup
- **Magazyn** — 15 kWh LFP, dobrany pod większe zużycie (pompa ciepła)
- **Koszt orientacyjny** — inwerter hybrydowy + magazyn 15 kWh + montaż: **35–50 tys. zł**

## Ekonomia magazynu

### Koszt zakupu

Koszt magazynu liczy się zwykle w przeliczeniu na pojemność:

```
Koszt jednostkowy: 2,5 – 4,0 zł/Wh
Magazyn 10 kWh = 10 000 Wh × ~3 zł = ~30 000 zł
```

### Skąd bierze się oszczędność

Magazyn zarabia na **różnicy między ceną kupna energii a wartością jej oddania do sieci** w net-billingu.

```
Cena kupna energii z sieci:        ~0,90 zł/kWh
Wartość oddania (net-billing):     ~0,35 zł/kWh
Zysk z 1 kWh przepuszczonej
przez magazyn:        0,90 - 0,35 = ~0,55 zł/kWh
```

Bez magazynu nadwyżka PV jest sprzedawana tanio i odkupowana drogo. Magazyn pozwala zużyć własną energię zamiast tej drogiej rotacji.

### Roczny zysk

```
Cykl dzienny:        8 kWh
Zysk jednostkowy:    0,55 zł/kWh
Dni pełnej pracy:    ~300 (zima ogranicza produkcję)

Zysk roczny = 8 × 0,55 × 300 ≈ 1 320 zł/rok
```

### Czas zwrotu

```
Koszt magazynu:   ~30 000 zł
Zysk roczny:      ~1 320 zł
Zwrot ≈ 30 000 / 1 320 ≈ 23 lata
```

| Scenariusz | Koszt | Zysk roczny | Zwrot |
|---|---|---|---|
| Magazyn 10 kWh, ceny standardowe | 30 000 zł | 1 300 zł | ~23 lata |
| Magazyn 10 kWh z dotacją 16 000 zł | 14 000 zł | 1 300 zł | ~11 lat |
| Magazyn 10 kWh, droga taryfa + arbitraż | 30 000 zł | 2 000 zł | ~15 lat |

> **Na granicy opłacalności.** Przy obecnych cenach magazyn bez dotacji zwraca się w 15–25 lat — często blisko końca jego żywotności. Czysto finansowo to inwestycja graniczna; dotacja, droga taryfa lub potrzeba backupu przesuwają rachunek na plus.

## Dotacje

Program **Mój Prąd** w kolejnych edycjach dofinansowuje magazyny energii (obok PV, pomp ciepła i systemów zarządzania energią). Dotacja potrafi pokryć znaczną część kosztu magazynu i to ona najczęściej decyduje o sensowności inwestycji. Warunki i kwoty zmieniają się między naborami — zawsze sprawdzaj aktualny regulamin programu.

## Kiedy magazyn się opłaca

- **Niekorzystny net-billing** — gdy różnica cena kupna minus wartość oddania jest duża, magazyn zarabia więcej
- **Drogie taryfy** — wysokie ceny energii skracają zwrot; arbitraż w taryfie strefowej dokłada zysk
- **Potrzeba backupu** — jeśli zależy Ci na zasilaniu przy zaniku sieci, magazyn ma wartość niewyrażalną w samym zwrocie
- **Off-grid** — w instalacji bez przyłącza magazyn nie jest opcją, lecz koniecznością
- **Dostępna dotacja** — dofinansowanie potrafi skrócić zwrot o połowę

## Prognozy

Ceny ogniw litowych od lat spadają wraz ze skalą produkcji i rozwojem chemii (LFP, sodowo-jonowe). W kolejnych latach spodziewany jest dalszy spadek kosztu za kWh pojemności, co skróci czas zwrotu i przesunie magazyny domowe z inwestycji granicznej w stronę standardowego elementu instalacji z fotowoltaiką.

## Podsumowanie sekcji

Magazyn energii to dziś dojrzała technologia — przede wszystkim LiFePO4 — która zwiększa autokonsumpcję PV i daje niezależność od sieci. Klucz to trafny dobór pojemności do celu, właściwa topologia podłączenia, bezpieczna instalacja i trzeźwa kalkulacja ekonomiczna z uwzględnieniem dotacji.
