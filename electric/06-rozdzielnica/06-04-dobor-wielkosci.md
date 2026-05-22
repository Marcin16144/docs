# Dobór wielkości rozdzielnicy

Wybór rozmiaru rozdzielnicy (liczby modułów) to **kluczowa decyzja projektowa** — za mała wymaga przebudowy po kilku latach, za duża niepotrzebnie kosztuje i zajmuje ścianę.

## Reguła obliczeniowa

```
   Moduły = (Liczba obwodów × 1)              ← każdy MCB 1 moduł
          + (Liczba RCD × 2)                  ← każdy RCD 2 moduły
          + (Liczba RCBO × 1 do 2)            ← każdy RCBO 1–2 moduły
          + (SPD × 2 do 4)                    ← ochronnik T2 lub T1+T2
          + (FR × 3)                          ← rozłącznik 4P
          + Sterowanie (przekaźniki, styczniki, zegary)
          + (Lampki sygn. × 1)                ← L1, L2, L3
          + 25–30% rezerwa
```

## Przykład 1 — mieszkanie 50 m², 1-fazowe

| Element | Moduły |
|---|---|
| FR 2P 40A | 2 |
| SPD T2 1+N | 2 |
| RCD 30 mA 2P (grupa 1) | 2 |
| 4 obwody (gniazda 2, oświetlenie 1, łazienka 1) | 4 |
| Lampka L | 1 |
| **Razem** | **11** |
| + 25% rezerwy (~3) | 3 |
| **Wynik** | **14 modułów → rozdzielnica 14–18 modułów** |

→ obudowa **2 × 12 = 24 modułów** (z luzem na przyszłość) lub **1 × 18**.

## Przykład 2 — dom 100 m², 3-fazowy z EV

| Element | Moduły |
|---|---|
| FR 4P 63A | 4 |
| SPD T2 3+N | 4 |
| 12 obwodów MCB 1P (gniazda, oświetlenie) | 12 |
| 6 obwodów RCBO 1P (lodówka, pralka, zmywarka, łazienka, kuchnia, ogród) | 6×2 = 12 |
| 1 obwód 3-faz MCB (płyta indukcyjna) | 3 |
| 1 obwód 3-faz MCB + RCD typ B (EV) | 3 + 4 = 7 |
| 3 lampki L1 L2 L3 | 3 |
| 2 przekaźniki bistabilne (oświetlenie zewn.) | 2 |
| Zegar astronomiczny | 1 |
| **Razem** | **48** |
| + 25% rezerwy (~12) | 12 |
| **Wynik** | **60 modułów → rozdzielnica 72 modułów (4 × 18)** lub 3 × 24 |

## Tabela szybkiego doboru

| Rodzaj obiektu | Obwody | Min. modułów | Zalecane | Obudowa |
|---|---|---|---|---|
| Garaż / piwnica oddzielna | 3–5 | 8 | 12 | 12 (1×12) |
| Kawalerka 30 m² | 4–6 | 10 | 14 | 18 |
| Mieszkanie 50 m² | 6–8 | 14 | 18 | 24 (2×12) |
| Mieszkanie 80 m² | 8–12 | 22 | 28 | 36 (3×12) |
| **Dom 100 m² (1-faz)** | 12–16 | 28 | 36 | **36–54** |
| **Dom 100–150 m² (3-faz)** | 18–24 | 42 | 54 | **54–72** |
| Dom 200+ m² z EV i PV | 25–35 | 60 | 72+ | 72 (4×18) lub 2 szafki |

## Wymiary fizyczne typowych rozdzielnic n/p

| Modułów | Rzędy | Szerokość | Wysokość | Głębokość |
|---|---|---|---|---|
| **12** | 1 × 12 | ~290 mm | ~210 mm | ~95 mm |
| **24** | 2 × 12 | ~290 mm | ~360 mm | ~95 mm |
| **36** | 3 × 12 | ~290 mm | ~510 mm | ~95 mm |
| **54** | 3 × 18 | ~410 mm | ~510 mm | ~110 mm |
| **72** | 4 × 18 | ~410 mm | ~660 mm | ~110 mm |

(wartości orientacyjne, np. seria Hager Volta VEU, Schneider Resi9, Eaton xEnergy)

## Wysokość montażu

| Parametr | Wartość |
|---|---|
| **Dolna krawędź drzwiczek** | minimum 0,8 m |
| **Górna krawędź** | maksimum 2,0 m |
| **Optymalne położenie** | **1,6–1,9 m od podłogi** (środek rozdzielnicy) |
| **W mieszkaniu / przedpokoju** | często 1,6 m (osoby siedzące widzą) |
| **W kotłowni / garażu** | 1,6–1,8 m |

> Ten zakres pozwala obsłudze (przełączenie MCB) bez schody i bez schylania się. W praktyce — **na wysokości oczu**.

## Montaż n/p czy p/t?

| Cecha | Natynkowa (n/p) | Podtynkowa (p/t) |
|---|---|---|
| Dom jednorodzinny w trakcie budowy | dopuszczalne | **najlepsze** (wnęka w gładzi) |
| Dom istniejący — remont | **najlepsze** | wymaga kucia 100 mm w ścianie |
| Mieszkanie nowe | dopuszczalne | **standard developerski** |
| Kotłownia, garaż | **najlepsze** (łatwy dostęp) | rzadko |
| Estetyka | gorsze | lepsze (lico ze ścianą) |
| Rozbudowa | łatwa | wymaga kucia |
| Wentylacja | lepsza | gorsza (zamknięte w ścianie) |

> **Dla rozdzielnicy 54–72 modułowej** w domu jednorodzinnym typowo wybiera się **n/p w kotłowni / pomieszczeniu gospodarczym** — wygoda rozbudowy ważniejsza od estetyki.

## Wentylacja rozdzielnicy

| Rodzaj | Zalecenie |
|---|---|
| **Wentylacja grawitacyjna** | otwory w obudowie (kominkowe) |
| **Wymuszona z termostatem** | wentylator 12 V, włączany powyżej 45 °C |
| **Klimatyzacja modułowa** | tylko w bardzo dużych szafach (5+ kW strat) |

## Powierzchnia ściany potrzebna

```
   ──────────────────── 2,0 m górna granica
   ┌──────────────────┐
   │                  │
   │   rozdzielnica   │  ── 1,6–1,9 m środek
   │   54 modułowa    │
   │                  │
   └──────────────────┘
   ──────────────────── 0,8 m dolna granica
   
   + min. 60 cm wolnej przestrzeni przed rozdzielnicą
     (z normami BHP — pole pracy z aparaturą pod napięciem)
```

## Co dalej

➡ [Opisy i etykietowanie obwodów](06-05-opisy.md)
