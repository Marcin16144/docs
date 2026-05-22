# Pomiar rezystancji izolacji (Riso)

## Co i dlaczego mierzymy

**Rezystancja izolacji (Riso)** to miara „szczelności" izolacji przewodów wobec innych przewodów i wobec PE. Mierzymy ją napięciem stałym DC, znacznie wyższym od roboczego, aby:

- wykryć **mikropęknięcia** izolacji,
- ocenić **starzenie** izolacji (wilgoć, temperatura, UV),
- znaleźć **przebicia do PE**,
- potwierdzić poprawność montażu nowej instalacji.

Norma: **PN-HD 60364-6** (sprawdzenia w instalacjach niskiego napięcia).

## Napięcie próby Un

| Napięcie pracy obwodu | Napięcie próby Un | Minimalna Riso |
|---|---|---|
| SELV, PELV (≤50 V AC) | **250 V DC** | ≥ **0,5 MΩ** |
| Do **500 V AC** (typowo 230/400) | **500 V DC** | ≥ **1 MΩ** |
| > 500 V AC | **1000 V DC** | ≥ **1 MΩ** |

**Dla typowego domu / mieszkania → mernik na 500 V DC, minimum 1 MΩ.**

Praktyka (stare instalacje, nieobjęte normą): wartość **≥ 0,5 MΩ** jest często akceptowana w opinii „nadaje się do eksploatacji".

Wartości typowe nowej instalacji: **>1 000 MΩ** (mernik wskaże „>999" lub „∞").

## Co mierzymy — wszystkie kombinacje

Dla każdego obwodu (lub całej rozdzielnicy) mierzymy 3 kombinacje:

| Pomiar | Co testujemy |
|---|---|
| **L – N** | izolację między fazą a neutralnym |
| **L – PE** | izolację fazy do ochronnego |
| **N – PE** | izolację neutralnego do ochronnego (najczęściej tu wychodzi „zwarcie miękkie") |

W sieci 3-fazowej dodajemy L1-L2, L1-L3, L2-L3, L1-PE, L2-PE, L3-PE, każde z N-PE = razem 10 kombinacji na każdy obwód.

## Procedura krok po kroku

1. **Wyłącz instalację** głównym rozłącznikiem.
2. **Sprawdź brak napięcia** próbnikiem.
3. **Odłącz wszystkie odbiorniki** — zwłaszcza **elektronikę** (TV, router, sterowniki, zasilacze SMPS):
   - 500 V DC może uszkodzić warystory wewnętrzne, filtry przeciwprzepięciowe, kondensatory,
   - można wyciągnąć wtyczki, wyłączyć MCB osobnych obwodów, **zdjąć SPD** w rozdzielnicy.
4. **Otwórz wszystkie wyłączniki światła** (żarówki LED w obwodzie zaniżają Riso przez sterownik).
5. **Załóż mostek N i PE** (jeśli mernik chce mierzyć obwody do siebie z jednym pomiarem) — lub mierz każdy biegun osobno.
6. **Ustaw mernik** na 500 V DC, próba **60 s** lub do stabilizacji.
7. **Podłącz przewody** mernika do badanej pary punktów (np. szyna L i szyna N w rozdzielnicy).
8. **Uruchom pomiar** — naciśnij i przytrzymaj (większość MIC-ów ma blokadę bezpieczeństwa).
9. **Odczyt Riso** [MΩ lub GΩ].
10. **Rozładuj obwód** (mernik automatycznie po zwolnieniu).
11. **Zapisz wynik** — obwód, kombinacja, Un, czas, Riso.

## Czas pomiaru i wskaźnik PI

Standardowy pomiar: **60 sekund** lub stabilizacja wartości.

Dla diagnozy starszych instalacji oblicza się **wskaźnik polaryzacji** PI:

```
PI = Riso(10 min) / Riso(1 min)
```

| PI | Stan izolacji |
|---|---|
| > 4 | doskonały |
| 2 – 4 | dobry |
| 1 – 2 | zadowalający |
| < 1 | zła izolacja (wilgoć, zanieczyszczenie) |

Dla instalacji domowych zwykle wystarcza pomiar 60 s.

## Mierniki — modele typowe

| Model | Producent | Zakres Un | Cena |
|---|---|---|---|
| **MIC-2500** | Sonel | 250 / 500 / 1000 / 2500 V | ~4500 zł |
| **MIC-1000** | Sonel | 250 / 500 / 1000 V | ~2500 zł |
| **MPI-525** | Sonel | uniwersalny + Riso 500 V | ~3000 zł |
| **3125A** | Kyoritsu | 500 / 1000 V | ~2200 zł |
| **3551A** | Kyoritsu | 500 / 1000 / 2500 V | ~3500 zł |
| **MIT420/2** | Megger | 250 / 500 / 1000 V | ~4000 zł |

## Najczęstsze problemy

| Symptom | Przyczyna |
|---|---|
| Riso < 1 MΩ ale > 0,5 MΩ | „mokra" instalacja, zła pora roku, kondensacja |
| Riso N-PE niskie | sklejone N i PE w gnieździe (błąd montażu), elektronika niepodłączona od N-PE |
| Riso L-N skacze | indukcja od pobliskich obwodów (zmierz przy wyłączonych sąsiednich MCB) |
| Riso = 0 (zwarcie) | przebicie izolacji — szukaj wzdłuż obwodu, najczęściej puszka łączeniowa |
| Wartość spada w czasie 60 s | pojemność obwodu jeszcze się ładuje — poczekaj |

## Bezpieczeństwo

- **Nigdy** nie mierz Riso **pod napięciem** — uszkodzisz mernik i siebie,
- **Nigdy** nie dotykaj zacisków podczas pomiaru — 500 V DC kopnie,
- **Po pomiarze odczekaj** kilka sekund na rozładowanie pojemności kabli (zwłaszcza długich linii),
- **Wyciągnij PV** — moduły fotowoltaiczne pod światłem produkują napięcie, niezależnie od wyłącznika.

## Przykładowe wartości w protokole

```
Obwód             | Un    | t   | L-N    | L-PE   | N-PE   | Ocena
──────────────────┼───────┼─────┼────────┼────────┼────────┼──────
G1 Gniazda kuchnia| 500 V | 60s | 1850 MΩ| 2100 MΩ| 1900 MΩ| OK
G2 Gniazda salon  | 500 V | 60s | >999 MΩ| >999 MΩ| >999 MΩ| OK
O1 Oświetlenie    | 500 V | 60s |  650 MΩ|  720 MΩ|  580 MΩ| OK
P1 Piekarnik 3-f  | 500 V | 60s | wartości dla L1-N, L2-N... | OK
Łaz Oświetlenie   | 500 V | 60s |  120 MΩ|  150 MΩ|  140 MΩ| OK*

* obwód z wilgotną łazienką — niższe ale > 1 MΩ ✓
```

## Co dalej

➡ [Impedancja pętli zwarcia](11-02-petla-zwarcia.md)
