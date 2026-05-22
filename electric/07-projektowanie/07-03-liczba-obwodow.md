# Liczba i rodzaje obwodów

Podział instalacji na obwody nie jest arbitralny. Zbyt mała liczba obwodów = brak selektywności (cały dom ciemny przy zwarciu w jednej lampie). Zbyt duża = przesadny koszt rozdzielnicy i kabli.

## Reguły podstawowe

| Reguła | Wartość |
|---|---|
| Maks. punktów oświetleniowych na jeden obwód B10 | **16 - 20** |
| Maks. gniazd na jeden obwód B16 | **8 - 10** |
| Obwód kuchenny (z lodówką, czajnikiem itp.) | gniazda osobno od reszty |
| Łazienka | własne RCD 30 mA |
| Garaż / piwnica / zewnątrz | własne RCD 30 mA |
| Rezerwa modułów w rozdzielnicy | min. **25%** |

## Obwody dedykowane (osobne dla pojedynczego odbiornika)

Każdy z poniższych odbiorników powinien mieć osobny obwód i zabezpieczenie:

| Odbiornik | Zabezpieczenie | Przekrój |
|---|---|---|
| Lodówka / zamrażarka | B10 lub C10 | 3×1,5 mm² |
| Pralka | B16 | 3×2,5 mm² |
| Zmywarka | B16 | 3×2,5 mm² |
| Piekarnik | B16 | 3×2,5 mm² |
| Płyta indukcyjna 3F | B16 (3-bieg.) | 5×2,5 mm² |
| Bojler 2 kW | B16 | 3×2,5 mm² |
| Pompa ciepła | B/C wg DTR (np. C20) | 5×4 mm² |
| Klimatyzacja split | B16 | 3×2,5 mm² |
| Kotłownia (sterowanie + pompy) | B10 | 3×1,5 mm² |
| Brama garażowa | B10 | 3×1,5 mm² |
| Furtka / domofon | B10 | 3×1,5 mm² |
| Alarm / monitoring | B6 lub B10 | 3×1,5 mm² |
| Szafa serwerowa / IT | B16 | 3×2,5 mm² |
| Ładowarka EV 11 kW | C16 (3-bieg.) + RCD typu B | 5×2,5 mm² |
| Ładowarka EV 22 kW | C32 (3-bieg.) + RCD typu B | 5×6 mm² |
| Sauna | B16 lub B25 (3F) | wg mocy |

## Strategie podziału

### 1. Według pomieszczeń

Każdy pokój = obwód oświetlenia + obwód gniazd. Najprostsza koncepcja, łatwa w obsłudze, ale wzrasta liczba obwodów.

### 2. Według funkcji

Cały dom z grupowaniem: „oświetlenie parter", „gniazda parter pokój dzienny", „gniazda salon TV". Mniej obwodów, ale awaria jednego dotyka większego obszaru.

### 3. Według kondygnacji

W większych domach — dodatkowo podział na poziomy. W praktyce: rozdzielnica główna + podrozdzielnice piętrowe.

### 4. Mieszana (zalecana)

- oświetlenie: 1 obwód na grupę pokoi (3-4 pokoje na obwód)
- gniazda: 1 obwód na 1-2 pokoje
- pomieszczenia mokre: osobno z RCD
- każdy duży odbiornik: osobno

## Wzorzec — dom 130 m²

| Lp. | Obwód | Zabezp. |
|---|---|---|
| 1 | Oświetlenie parter — strefa dzienna | B10 |
| 2 | Oświetlenie parter — kuchnia + przedpokój | B10 |
| 3 | Oświetlenie piętro — sypialnie | B10 |
| 4 | Oświetlenie piętro — łazienka + korytarz | B10 |
| 5 | Oświetlenie zewnętrzne | B10 |
| 6 | Gniazda salon + jadalnia | B16 |
| 7 | Gniazda kuchnia (blat, AGD drobne) | B16 |
| 8 | Gniazda sypialnia główna | B16 |
| 9 | Gniazda sypialnie dziecięce | B16 |
| 10 | Gniazda biuro + IT | B16 |
| 11 | Gniazda łazienka (golarka, suszarka) | B16 |
| 12 | Gniazda garaż + warsztat | B16 |
| 13 | Gniazda taras / zewnętrzne | B16 |
| 14 | Lodówka | B10 |
| 15 | Pralka + suszarka | B16 |
| 16 | Zmywarka | B16 |
| 17 | Piekarnik | B16 |
| 18 | Płyta indukcyjna 3F | B16 (3P) |
| 19 | Bojler | B16 |
| 20 | Pompa ciepła 3F | C20 (3P) |
| 21 | Brama + furtka | B10 |
| 22 | Alarm / monitoring | B10 |
| 23 | Wallbox EV 11 kW 3F | C16 (3P) |
| 24 | Rezerwa | B16 |

**24 obwody** + miejsce na rezerwy. Rozdzielnica ~48-72 modułów (2-3 rzędy po 24).

## Wzorzec — mieszkanie 50 m²

| Lp. | Obwód | Zabezp. |
|---|---|---|
| 1 | Oświetlenie całe mieszkanie | B10 |
| 2 | Gniazda pokój dzienny + sypialnia | B16 |
| 3 | Gniazda kuchnia | B16 |
| 4 | Lodówka | B10 |
| 5 | Pralka | B16 |
| 6 | Łazienka (gniazda + ogrzewanie) | B16 + RCD |
| 7 | Bojler / piekarnik (jeśli elektryczny) | B16 |
| 8 | Rezerwa | B16 |

**6-8 obwodów**. Rozdzielnica 18-24 moduły.

## Rezerwa — dlaczego 25%?

Po 5-10 latach typowa instalacja zostaje rozbudowana o:

- klimatyzację
- ładowarkę EV
- moduły smart home (przekaźniki impulsowe, KNX)
- dodatkowe oświetlenie tarasu, podświetlenie schodów

Bez rezerwy modułów = wymiana rozdzielnicy. **Lepiej kupić skrzynkę 3-rzędową niż 2-rzędową** — różnica cenowa to ~150-200 zł, oszczędność czasu — bezcenna.

## Co dalej

➡ [Schemat ideowy](07-04-schemat-ideowy.md)
