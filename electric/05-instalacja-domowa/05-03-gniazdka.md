# Gniazdka — typy i montaż

## Standard polski/europejski: typ E (Schuko PL/DE)

W Polsce obowiązuje gniazdo z **bolcem ochronnym PE w gnieździe** (typ E, francuski/polski) lub **stykami bocznymi PE** (typ F, Schuko niemiecki). Wtyczka Schuko z bolcem na osi pasuje do obu (chociaż w typ E nie wchodzi z każdej strony).

| Parametr | Wartość |
|---|---|
| Napięcie znamionowe | **230 V AC** |
| Prąd znamionowy | **16 A** |
| Liczba biegunów | 2P + Z (faza, neutralny, PE) |
| Norma | PN-E-93201, IEC 60884 |
| Typ standardowy | E (z bolcem PE) lub F (Schuko) |

```
   gniazdo typ E (PL):
        ┌──────────┐
        │  ●       │  ← bolec PE wystaje
        │  ○    ○  │  ← otwory L i N
        └──────────┘
```

## Wysokości montażu

Standardowe wysokości od poziomu wykończonej podłogi (środek puszki):

| Lokalizacja | Wysokość |
|---|---|
| **Pokój standard** (salon, sypialnia) | **30 cm** od podłogi |
| **Nad blatem kuchennym** | **110–130 cm** (5–25 cm nad blatem) |
| **Łazienka** (poza strefami) | **120 cm** |
| **Biurowe / nad biurkiem** | 90–105 cm |
| **Pralka, lodówka (cokół)** | 30 cm — ale **z dostępem** |
| **Pralka (gdy zabudowana)** | nad drzwiczkami sąsiedniej szafki ~110 cm |
| **TV (naścienne)** | wysokość TV (typowo 120 cm) — w puszce za telewizorem |
| **Gniazdo zewnętrzne ogrodowe** | 30–60 cm (słupek) lub przy elewacji 120 cm |

> **Nie nad listwą przypodłogową!** Standardowa wysokość 30 cm dobrana jest tak, by zostawić miejsce na meble (komoda, sofa), a jednocześnie wtyczka nie pyłem podłogowym.

## Gniazda dedykowane (osobny obwód)

Następujące odbiorniki **powinny** mieć własny obwód (osobny MCB, często osobny RCD):

| Odbiornik | Obwód | MCB |
|---|---|---|
| **Lodówka** | dedykowany — nie wyłączać z resztą | B16 (lub RCBO B16/30 mA) |
| **Pralka** | dedykowany z RCD 30 mA | B16 |
| **Zmywarka** | dedykowany z RCD 30 mA | B16 |
| **Piekarnik** | dedykowany (zwykle z piec.) | B16 |
| **Mikrofalówka** | osobny lub w obwodzie blatu | B16 |
| **Bojler / podgrzewacz** | dedykowany | B16 (2 kW) / B20 (4–5 kW) |
| **Klimatyzacja** | dedykowany | B10–B16 |
| **Ładowarka EV (wallbox)** | dedykowany 3F, RCD typ B/A+DD | C16 / C32 |

Dlaczego osobno? **Lodówka** — by nie wyłączyć jej przypadkiem wybijającym RCD od pralki (jedzenie się zepsuje przy 2-tygodniowym wyjeździe). **Pralka/zmywarka** — duży prąd grzania + RCD wrażliwy na wilgoć.

## Liczba gniazd na pomieszczenie (rekomendacje)

| Pomieszczenie | Minimum gniazd | Komentarz |
|---|---|---|
| **Salon** | 8–10 (2 obwody) | TV, audio, lampy, ładowarki, odkurzacz |
| **Sypialnia** | 4–6 | po 2 obok łóżka, biurko, ogólne |
| **Biuro / gabinet** | 6–8 | komputer, monitor, drukarka, ładowarki |
| **Kuchnia nad blatem** | **8–12** | wąskie gniazda na pasie nad blatem |
| **Łazienka** | 1–2 (strefa 3) | suszarka, golarka, IP44 z RCD |
| **Korytarz** | 1–2 | odkurzacz |
| **Przedpokój** | 2 | po 1 na każdej ścianie |
| **Garderoba** | 1 | porządkowe |
| **Garaż** | 4–8 (IP44) | warsztat, ładowarki |

Szczegóły w [05-10 Pomieszczenia — minimum gniazd](05-10-pomieszczenia.md).

## Gniazda z USB

Coraz częstszy wybór do biurek i przy łóżku — gniazdo 230 V w **ramce 2-modułowej** z portami **USB-A + USB-C PD** (zwykle 18–45 W). Zaleta: bez ładowarki w gnieździe. Wada: kontroler USB ma żywotność ~10 lat, mniejszą niż samo gniazdo (30+ lat).

```
   ramka 2-modułowa:
   ┌──────┬──────┐
   │  ○○  │  USB │
   │  ○ ● │  A C │
   └──────┴──────┘
   gniazdo  ładowarka
```

## Gniazda zewnętrzne i ogrodowe

Na elewacji i w ogrodzie obowiązuje **IP44 minimum** (bryzgoszczelne), w terenie otwartym **IP55** (silne strugi). Zawsze z **klapką** zatrzaskową (sprężynową lub na zatrzask).

| Lokalizacja | Stopień IP | Dodatkowo |
|---|---|---|
| Elewacja pod okapem | IP44 | klapka |
| Słupek ogrodowy | IP54–IP55 | klapka, podłączenie od dołu |
| Taras / patio osłonięty | IP44 | klapka |
| W pełni odsłonięty | IP65 + dedykowany RCD 30 mA |

**Każde gniazdo zewnętrzne musi być zabezpieczone RCD 30 mA** (część PN-HD 60364-4-41) — najlepiej osobny obwód RCBO 16 A/30 mA dla całego ogrodu.

## Gniazda 3-fazowe (siłowe)

Gniazda **CEE (Inkra)** stosowane przy płycie indukcyjnej 3F, ładowarkach EV, urządzeniach warsztatowych:

| Kolor / typ | Napięcie | Prąd | Zastosowanie |
|---|---|---|---|
| **CEE niebieskie 3P** | 230 V | 16 A | kemping, pojedyncza faza |
| **CEE czerwone 5P 16 A** | 400 V | 16 A | warsztat, mała maszyna |
| **CEE czerwone 5P 32 A** | 400 V | 32 A | duża maszyna, ładowarka 22 kW |
| **CEE czerwone 5P 63 A** | 400 V | 63 A | przemysł |

## Co dalej

➡ [Łączniki oświetlenia](05-04-laczniki.md)
