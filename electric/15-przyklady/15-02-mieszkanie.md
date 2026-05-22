# Projekt: mieszkanie 50 m² — modernizacja

## Założenia

| Parametr | Wartość |
|---|---|
| Powierzchnia | 50 m² (2 pokoje + kuchnia-salon + łazienka) |
| Mieszkańcy | 2 osoby |
| Kuchnia | gazowa (płyta + piekarnik elektr.) |
| Przyłącze | 1-fazowe 25 A (umowa z OSD) |
| Stan istniejący | aluminium 2,5 mm² z lat 70., bez RCD, bez PE |
| Układ sieci | TN-C → przebudowa do TN-C-S w mieszkaniu |

## Bilans mocy

| Odbiornik | Moc Pi [kW] |
|---|---|
| Oświetlenie LED | 0,2 |
| Gniazda ogólne | 1,5 |
| AGD (lodówka, pralka, zmywarka) | 3,0 |
| Piekarnik elektryczny | 3,5 |
| Bojler / przepływowy | 0 (gaz) |
| **Suma Pi** | **~8,2 kW** |
| **Pz przy kz 0,6** | **~4,9 kW** |

Prąd przy 230 V, cos φ = 0,95: **I = 4900 / (230 · 0,95) ≈ 22 A** — mieści się w przyłączu 25 A.

## Lista 8 obwodów

| Nr | Opis | MCB | RCD | Kabel |
|---|---|---|---|---|
| 1 | Oświetlenie cały lokal | B10 | RCBO 30 mA | YDY 3×1,5 |
| 2 | Gniazda pokoje (8 szt.) | B16 | RCBO 30 mA | YDY 3×2,5 |
| 3 | Gniazda kuchnia blat | B16 | RCBO 30 mA | YDY 3×2,5 |
| 4 | Zmywarka (dedyk.) | B16 | RCBO 30 mA | YDY 3×2,5 |
| 5 | Pralka (dedyk.) | B16 | RCBO 30 mA | YDY 3×2,5 |
| 6 | Lodówka | B16 | RCBO S 100 mA | YDY 3×2,5 |
| 7 | Piekarnik | B16 | RCBO 30 mA | YDY 3×2,5 |
| 8 | Łazienka (ośw. + gniazdo) | B10/B16 | RCBO 30 mA | YDY 3×2,5 |

## Schemat ideowy

```
   Licznik OSD 1F 25 A
        │
        ▼
   ┌───────────────────────────────────────┐
   │ Rozdzielnica RM  12 modułów p/t       │
   ├───────────────────────────────────────┤
   │ FR  2P 32 A                           │
   │ SPD T2  2P                            │
   │                                       │
   │ F1 RCBO B10 30 mA  oświetlenie        │
   │ F2..F7 RCBO B16 30 mA  gniazda        │
   │ F8 RCBO B16 30 mA  łazienka           │
   │                                       │
   │ Listwa PE                             │
   │ Listwa N                              │
   └───────────────────────────────────────┘
```

## Co zmienić względem starej instalacji

Stary stan po renowacji:

- **Aluminium → miedź** — całość przewodów wymieniona.
- **Brak PE → 3-żyłowy** — wszystkie obwody YDY 3×.
- **Brak RCD → 30 mA na każdym obwodzie** — RCBO modułowe.
- **Brak SPD → SPD T2** — ogranicznik przepięć w rozdzielnicy.
- **Stare gniazda → typ E (z bolcem)** — wymiana wszystkich.
- **Łazienka** — wyrównawcze miejscowe do baterii, rur, brodzika; gniazda min. IPx4 w strefie 2.

## Lista materiałów

| Pozycja | Ilość | Cena ~ |
|---|---|---|
| Rozdzielnica 12-mod p/t | 1 | 250 zł |
| RCBO B10/B16 30 mA typ A | 8 | 1 600 zł |
| SPD T2 2P | 1 | 350 zł |
| FR 2P 32 A | 1 | 100 zł |
| Kabel YDY 3×1,5 | 80 m | 140 zł |
| Kabel YDY 3×2,5 | 200 m | 550 zł |
| Gniazda + ramki | 25 | 750 zł |
| Łączniki | 15 | 300 zł |
| Puszki, materiały drobne | — | 400 zł |
| **Materiały razem** | | **~4 400 zł** |

Robocizna: 4–6 tys. zł.

## Co dalej

➡ [Garaż z warsztatem](15-03-garaz-warsztat.md)
