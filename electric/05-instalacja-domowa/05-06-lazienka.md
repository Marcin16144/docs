# Instalacja w łazience

Łazienka to **najbardziej rygorystycznie regulowane** pomieszczenie elektryczne w domu. Norma **PN-HD 60364-7-701** (część szczegółowa dla pomieszczeń wyposażonych w wannę lub natrysk) dzieli przestrzeń na 4 strefy.

## Strefy 0/1/2/3

```
                      ┌──── strefa 1 (nad wanną, 2,25 m wysokości)
                      │
   ┌──────────────────┼──────────────────┐
   │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
   │  ░ strefa 2 (60 cm od wanny) ░░░░░  │
   │  ░  ┌──── strefa 1 ──────┐  ░░░░░░  │
   │  ░  │ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ │  ░░░░░░  │
   │  ░  │ ▒ strefa 0 (wanna) │  ░░░░░░  │
   │  ░  │ ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ │  ░░░░░░  │
   │  ░  └─────────────────────┘  ░░░░░░  │
   │  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
   │           ◄── strefa 3 ──►          │
   │       (poza 60 cm od wanny)         │
   └──────────────────────────────────────┘
```

| Strefa | Definicja | Dopuszczalne |
|---|---|---|
| **0** | wnętrze wanny / brodzika | **tylko SELV 12 V**, IPX7 |
| **1** | nad wanną do wysokości 2,25 m | IPX4, oprawy klasy II, opcjonalnie SELV |
| **2** | poziomy obszar 60 cm od wanny / w pionie do 2,25 m | IPX4, oprawy klasy I/II z RCD, gniazda zabronione (poza SELV / golenia z transformatorem) |
| **3** | poza strefą 2, w obrębie łazienki | gniazda OK z RCD 30 mA, IP21 wystarcza, IPX4 zalecane |

## Strefa 0 — wnętrze wanny/brodzika

- tylko **SELV 12 V** (transformator separacyjny IPX5+),
- stopień ochrony **IPX7** (zanurzenie do 1 m),
- praktycznie: oświetlenie wewnętrzne brodzika / hydromasaż z zasilaczem poza łazienką lub w strefie 3.

## Strefa 1 — bezpośrednio nad wanną (do 2,25 m)

- klasa ochronności **II** (podwójna izolacja, symbol kwadrat w kwadracie),
- **IPX4** minimum (bryzgoodporne),
- bez gniazd,
- dopuszczalny: ogrzewacz przepływowy, oprawa LED IPX4-X5, czujnik ruchu (w klasie II).

## Strefa 2 — 60 cm od wanny

- **IPX4** minimum,
- **gniazda zabronione**, jedyny wyjątek: gniazdo do golarki z transformatorem separacyjnym (SELV/PELV),
- oprawy oświetleniowe klasy II,
- łączniki — najlepiej **poza strefą** (np. przy drzwiach).

## Strefa 3 — reszta łazienki

- gniazda **dozwolone** — obowiązkowo z **RCD 30 mA** (zwykle RCBO B16/30 mA),
- minimum **IP21** (na praktyce IPX4 — pryskająca woda),
- łączniki najlepiej **przy drzwiach** od strony zewnętrznej.

## Połączenia wyrównawcze miejscowe (CPC)

W łazience wszystkie metalowe części dotykalne **muszą być** połączone miejscową szyną wyrównawczą (PEC — Protective Equipotential Bonding):

```
   ┌── wanna metalowa (jeśli)
   ├── brodzik metalowy
   ├── baterie kranowe (przy braku metalowych rur — opcja)
   ├── metalowe rury wody zimnej / ciepłej
   ├── rura c.o. (grzejnik)
   ├── kratka ściekowa metalowa
   │
   └──── szyna wyrównawcza miejscowa LSW ──── PE rozdzielnicy
                                              (przewód min. 4 mm² Cu)
```

| Parametr | Wymóg |
|---|---|
| Przekrój przewodu wyrównawczego | **4 mm² Cu** (linka LgY zielono-żółta) |
| Połączenie z PE rozdzielnicy | bezpośrednie, jednoznaczne |
| Zaciski na rurach | szybkozłączki rurowe z trzpieniem (Bender, OBO) |

> **Po co?** Aby w razie awarii nie powstała różnica potencjałów między wanną a baterią (typowo 30–80 V przy uszkodzeniu PE). Wyrównanie sprowadza wszystkie metalowe części do tego samego potencjału — porażenie staje się niemożliwe nawet przy uszkodzeniu izolacji.

## Obowiązkowy RCD 30 mA

**Każdy obwód** w łazience (gniazda, ogrzewacz, podgrzewacz wody, pralka — jeśli w łazience) **musi** mieć RCD 30 mA. Najlepiej:

- **dedykowany RCBO B16 / 30 mA typ A** dla każdego obwodu,
- ewentualnie RCD F (lub B) jeśli jest urządzenie z falownikiem (pralka, suszarka inwerterowa, bojler PV).

## Oświetlenie

| Lokalizacja | Klasa | IP |
|---|---|---|
| Sufit (główne) | I lub II | IP44 |
| Nad lustrem | II | IPX4 |
| W kabinie prysznicowej (str. 1) | II | IPX5 |
| W brodziku (str. 0) | SELV 12 V | IPX7 |
| Halogen punktowy w stropie podwieszanym | I | IP44 (mimo że „nad strefą") |

## Wentylator z opóźnieniem czasowym

Standard: wentylator łazienkowy zsynchronizowany z **łącznikiem światła** — włącza się razem ze światłem, wyłącza z opóźnieniem **5–15 minut** po wyłączeniu lampy. Wymaga 3-żyłowego zasilania (L, N, Lp — linia za łącznikiem).

```
   ┌── L stałe ── wentylator (zasilanie + opóźnienie)
   ├── N
   ├── Lp (sygnał z łącznika — wł/wył)
   └── PE
```

Modele z higrostatem: automatyczne uruchamianie przy ↑ wilgotności (> 60%).

## Co dalej

➡ [Instalacja w kuchni](05-07-kuchnia.md)
