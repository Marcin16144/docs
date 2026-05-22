# Opisy i etykietowanie obwodów

Obowiązek opisania rozdzielnicy wynika z **PN-EN 61439** oraz Rozporządzenia w sprawie warunków technicznych. Bez opisów nie można rzetelnie diagnozować i serwisować instalacji — a w razie pożaru utrudniają pracę straży.

## Co musi być opisane

| Element | Wymóg |
|---|---|
| **Tabliczka znamionowa** rozdzielnicy | producent, prąd znamionowy, IP, IK, data |
| **Każdy aparat modułowy** (MCB, RCD, RCBO) | numer + opis obwodu |
| **Listwy PE i N** | oznaczenia kolorystyczne i opisowe |
| **Wyłącznik główny FR** | duża czerwona naklejka „GŁÓWNY WYŁĄCZNIK" |
| **Schemat ideowy** | w kieszeni rozdzielnicy (laminowany) |
| **Plan obwodów** (tabela) | na wewnętrznej stronie drzwiczek lub w kieszeni |
| **Przewody w listwach** | etykiety termokurczliwe na obu końcach |

## Numeracja obwodów

Standardowy schemat: **F1, F2, F3...** (od lewej, od góry).

```
   rząd 1:
   [FR] [SPD] [SPD] [L1][L2][L3] [F1][F2][F3][F4][F5][F6]
                                                          
   rząd 2:
   [F7][F8][F9][F10][F11][F12] [RCD1] [F13][F14][F15][F16]
                                                          
   rząd 3:
   [RCBO1] [RCBO2] [RCBO3] [RCBO4] ...
```

| Prefiks | Znaczenie |
|---|---|
| **F** | bezpieczniki / MCB |
| **FR** | rozłącznik główny |
| **K** | przekaźniki, RCD, RCBO |
| **R** | rezystory, opcjonalnie RCD |
| **L** | lampki sygnalizacyjne (L1, L2, L3 = fazy) |
| **T** | transformatory (np. dzwonek 230/8 V) |
| **S** | łączniki, czujniki |
| **U** | gniazda serwisowe w rozdzielnicy |
| **X** | listwy zaciskowe (X1=N, X2=PE) |

## Tabela na drzwiczkach — wzór

Tabela laminowana lub na trwałej naklejce, jasno czytelna z odległości 50 cm:

| Nr | Opis obwodu | In | Char. | RCD | Kabel | Lokalizacja |
|---|---|---|---|---|---|---|
| F1 | Gniazda salon ściana 1 | 16 A | B | RCD1 30 mA | YDYp 3×2,5 | salon |
| F2 | Gniazda salon ściana 2 | 16 A | B | RCD1 30 mA | YDYp 3×2,5 | salon |
| F3 | Oświetlenie salon | 10 A | B | RCD1 30 mA | YDYp 3×1,5 | salon |
| F4 | Oświetlenie sypialnia + przedpok. | 10 A | B | RCD2 30 mA | YDYp 3×1,5 | sypialnia |
| F5 | Gniazda sypialnia | 16 A | B | RCD2 30 mA | YDYp 3×2,5 | sypialnia |
| K1 | Lodówka (RCBO) | 16 A | B | wbud. 30 mA A | YDYp 3×2,5 | kuchnia |
| K2 | Pralka (RCBO) | 16 A | B | wbud. 30 mA A | YDYp 3×2,5 | łazienka |
| K3 | Zmywarka (RCBO) | 16 A | B | wbud. 30 mA A | YDYp 3×2,5 | kuchnia |
| F6-F8 | Płyta indukcyjna 3F | 3×16 A | B | RCD3 30 mA F | YDYżo 5×2,5 | kuchnia |
| F9-F11 | Ładowarka EV 11 kW | 3×16 A | C | RCD typ B | YDYżo 5×4 | garaż |
| F12 | Kocioł c.o. | 16 A | B | RCD4 30 mA | YDYp 3×2,5 | kotłownia |
| F13 | Gniazda zewnętrzne IP65 | 16 A | B | RCD5 30 mA | YKY 3×2,5 | taras |
| F14 | Brama wjazdowa | 10 A | B | RCD5 30 mA | YKY 3×1,5 | brama |
| F15 | Oświetlenie zewn. | 10 A | B | RCD5 30 mA | YKY 3×1,5 | ogród |
| **Rezerwa F16-F20** | wolne | — | — | — | — | — |

## Oznaczenia przewodów (rurki termokurczliwe)

Każdy przewód w rozdzielnicy oznaczony **rurką termokurczliwą z numerem obwodu** — na obu końcach (przy aparacie i przy odbiorniku):

```
   rurka żółta z czarnym numerem:
   ┌────────┐
   │  F  3  │   ← oznaczenie "F3" termokurczliwa
   └────────┘
   
   na przewodzie:
   ════════════████████  F3   ████████════════════
                ▲                       ▲
                 koniec przy MCB         koniec w puszce
```

Producent: **HellermannTyton HelaTube**, **Brady**, **Phoenix Contact** — drukarka termo-transferowa lub gotowe rurki numerowane.

## Naklejka „Główny Wyłącznik"

Na drzwiczkach lub bezpośrednio nad FR — **czerwona naklejka z białym napisem**:

```
   ┌──────────────────────────┐
   │ █████████████████████████ │   ← czerwony pasek
   │ █                       █ │
   │ █  GŁÓWNY WYŁĄCZNIK    █ │
   │ █  PRĄDU              ↓ █ │   ← strzałka w dół do FR
   │ █                       █ │
   │ █████████████████████████ │
   └──────────────────────────┘
```

Norma: **PN-EN ISO 7010 W12** — symbol „Uwaga — niebezpieczeństwo porażenia". Naklejka wymagana też przy zewnętrznym wyłączniku p-poż.

## Schemat ideowy w kieszeni

W każdej rozdzielnicy (zwłaszcza dużej) musi znajdować się **schemat ideowy w trwałej, laminowanej formie** w kieszeni na wewnętrznej stronie drzwiczek:

- układ aparatów modułowych (rzut),
- schemat jednokreskowy z oznaczeniami F1, K1, …
- daty montażu, dane elektryka (uprawnienia SEP),
- daty kolejnych pomiarów okresowych.

Dla projektów >100 m² zaleca się dodatkowo: schemat **strukturalny** (drzewo obwodów) wraz z planem instalacji.

## Plan obwodów — wzór tabelaryczny

Plan obwodów to nieco rozszerzona tabela — z **lokalizacją odbiorników**:

| Obwód | Pomieszczenie | Odbiorniki | Liczba punktów | Moc szczyt. | Współ. równ. | Iz przewodu |
|---|---|---|---|---|---|---|
| F1 | Salon — ściana zach. | 5 gniazd uniwersalnych | 5 | 3,5 kW | 0,4 | 21 A (YDYp 2,5 w ścianie) |
| F2 | Salon — ściana wsch. | 5 gniazd + TV | 5 | 2,0 kW | 0,5 | 21 A |
| F3 | Salon | 2 punkty świetlne | 2 | 0,3 kW | 1,0 | 16 A (YDYp 1,5) |
| ... | ... | ... | ... | ... | ... | ... |

## Numeracja faz (lampki sygnalizacyjne)

Trzy lampki w jednym rzędzie:

```
   [L1 brązowa]  [L2 czarna]  [L3 szara]
        ▲             ▲             ▲
        świeci jeśli każda faza obecna
        (kontrola asymetrii i braku fazy)
```

Każda lampka 230 V, prądu znikomego, podłączona między swoją fazą a N.

## Aktualizacja po każdej zmianie

Każda **rozbudowa instalacji** wymaga aktualizacji:

- tabeli na drzwiczkach,
- schematu ideowego,
- planu obwodów,
- wpisu w **paszporcie rozdzielnicy** (kto, kiedy, co zmienił).

Bez aktualizacji — następny elektryk traci czas na inwentaryzację, a w razie awarii nie wiadomo, co wyłącza dany MCB.

## Podsumowanie wymagań formalnych

| Element | Obowiązek prawny | Norma |
|---|---|---|
| Tabliczka znamionowa | TAK | PN-EN 61439 |
| Opis obwodów | TAK | PN-IEC 60364-5-51 |
| Schemat | TAK (dla rozdzielnic >5 obwodów) | PN-EN 61439 |
| Naklejka „Główny Wyłącznik" | TAK | rozporządzenie BHP |
| Oznaczenia przewodów | TAK | PN-EN 81346 |
| Pomiary okresowe (i wpis) | TAK (co 5 lat dom, co 1 rok firma) | PN-IEC 60364-6 |

## Co dalej

➡ Wracaj do [Spisu sekcji 06](index.html) lub przejdź do [Sekcja 07 — Projektowanie](../07-projektowanie/index.html)
