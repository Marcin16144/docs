# Topologie podłączenia i schematy

Magazyn można wpiąć do instalacji z PV na dwa zasadnicze sposoby — po stronie prądu przemiennego (AC-coupled) albo po stronie prądu stałego (DC-coupled). Wybór decyduje o sprawności systemu, koszcie i tym, czy trzeba wymieniać istniejący inwerter.

## AC-coupled — magazyn po stronie AC

Magazyn ma własny inwerter bateryjny i jest podłączony do instalacji po stronie AC, równolegle z inwerterem fotowoltaicznym.

- **Zaleta** — łatwy retrofit do istniejącej instalacji PV on-grid; nie rusza się działającego inwertera PV
- **Wada** — podwójna konwersja energii: PV produkuje DC, inwerter PV zamienia na AC, inwerter bateryjny zamienia z powrotem na DC, by naładować magazyn, a przy oddawaniu znów na AC
- **Skutek** — niższa sprawność ładowania z PV (każda konwersja to straty)

### Schemat AC-coupled

```
            ┌─────────┐
   SŁOŃCE   │ Panele  │
     │      │   PV    │
     ▼      └────┬────┘
            DC   │
                 ▼
          ┌─────────────┐
          │  Inwerter   │
          │     PV      │
          └──────┬──────┘
            AC   │
                 ▼
   ┌─────────────────────────────┐
   │      SZYNA AC / rozdzielnica │
   └──┬───────────┬───────────┬──┘
      │           │           │
      ▼           ▼           ▼
 ┌─────────┐ ┌─────────┐ ┌──────────┐
 │ Inwerter│ │  SIEĆ   │ │ Obwody   │
 │bateryjny│ │  OSD    │ │ domowe   │
 └────┬────┘ │ licznik │ └──────────┘
   DC │      └─────────┘
      ▼
 ┌─────────┐
 │ MAGAZYN │  48 V DC
 │  LFP    │  + BMS
 └─────────┘

Backup: wydzielone obwody krytyczne za inwerterem
bateryjnym, zasilane przy zaniku sieci OSD.
```

## DC-coupled — magazyn po stronie DC

Magazyn jest podłączony do inwertera hybrydowego po stronie DC, na tej samej szynie co panele PV. Inwerter hybrydowy obsługuje jednocześnie PV i baterię.

- **Zaleta** — wyższa sprawność: energia z PV trafia do magazynu po stronie DC, bez konwersji na AC i z powrotem
- **Wada** — trzeba mieć (lub wymienić na) inwerter hybrydowy; przy retroficie starej instalacji oznacza to wymianę inwertera PV

### Schemat DC-coupled

```
            ┌─────────┐
   SŁOŃCE   │ Panele  │
     │      │   PV    │
     ▼      └────┬────┘
            DC   │
                 ▼
   ┌───────────────────────────┐
   │     INWERTER HYBRYDOWY    │
   │   ┌─────────┐  ┌────────┐ │
   │   │ wejście │  │ port   │ │
   │   │  PV DC  │  │ bat DC │ │
   │   └─────────┘  └───┬────┘ │
   └────────┬───────────┼──────┘
        AC  │        DC │
            │           ▼
            │      ┌─────────┐
            │      │ MAGAZYN │ 48 V / HV
            │      │  LFP    │ + BMS
            │      └─────────┘
            ▼
   ┌─────────────────────────────┐
   │      SZYNA AC / rozdzielnica │
   └──┬───────────┬───────────┬──┘
      ▼           ▼           ▼
 ┌─────────┐ ┌─────────┐ ┌──────────┐
 │  SIEĆ   │ │ Obwody  │ │ Obwody   │
 │  OSD    │ │ domowe  │ │ backup   │
 │ licznik │ └─────────┘ └──────────┘
 └─────────┘

Energia PV → magazyn bez konwersji DC→AC→DC,
stąd wyższa sprawność ładowania.
```

## Hybryda all-in-one

Część producentów oferuje urządzenia, w których inwerter hybrydowy i moduł bateryjny są w jednej obudowie. Zalety: jeden montaż, jedna gwarancja, spójna komunikacja. Wada: mniejsza elastyczność rozbudowy i uzależnienie od jednego dostawcy.

## Porównanie topologii

| Cecha | AC-coupled | DC-coupled |
|---|---|---|
| Inwerter | osobny bateryjny | wspólny hybrydowy |
| Retrofit do istniejącej PV | łatwy | wymaga wymiany inwertera |
| Sprawność ładowania z PV | niższa (podwójna konwersja) | wyższa |
| Elastyczność rozbudowy | duża | zależna od inwertera |
| Typowe zastosowanie | dokładanie magazynu do starej PV | nowa instalacja PV + magazyn |

## Zabezpieczenia DC magazynu

Strona DC magazynu wymaga własnego kompletu zabezpieczeń — niezależnie od topologii.

- **Bezpiecznik DC** — chroni przewody przed skutkami zwarcia po stronie baterii
- **Rozłącznik DC** — umożliwia bezpieczne, beznapięciowe odłączenie magazynu do serwisu
- **SPD DC** — ogranicznik przepięć dla obwodu stałoprądowego
- Bezpieczniki i rozłączniki muszą być przeznaczone do prądu stałego (DC) — aparaty AC nie gaszą łuku przy DC

## Dobór przekroju kabli magazynu

Przy niskim napięciu magazynu (48 V) ta sama moc oznacza bardzo wysoki prąd. To wymusza grube przewody.

```
Przykład — magazyn 48 V, moc 5 kW:
I = P / U = 5000 / 48 ≈ 104 A
```

Prąd 104 A wymaga przewodu miedzianego o przekroju rzędu **25–35 mm²** (zależnie od długości trasy, sposobu ułożenia i dopuszczalnego spadku napięcia). Trasa magazyn–inwerter powinna być możliwie krótka.

> **Krótkie kable, gruby przekrój.** Przy 48 V spadek napięcia na kablu jest procentowo dużo bardziej dotkliwy niż przy 230 V. Magazyn montuje się jak najbliżej inwertera, a przekrój dobiera z zapasem — niedoszacowany kabel grzeje się i obniża sprawność.

| Moc magazynu przy 48 V | Prąd ~ | Sugerowany przekrój Cu |
|---|---|---|
| 3 kW | 63 A | 16 mm² |
| 5 kW | 104 A | 25–35 mm² |
| 8 kW | 167 A | 50–70 mm² |

W systemach wysokonapięciowych (HV, 100–500 V) prądy są wielokrotnie niższe, a przekroje znacznie mniejsze — to jedna z zalet topologii HV.

## Co dalej

➡ [Instalacja i bezpieczeństwo magazynów](18-05-instalacja-bezpieczenstwo.md)
