# Obciążalność prądowa Iz

## Co to jest Iz

**Iz** (current carrying capacity) — długotrwały dopuszczalny prąd żyły, przy którym żyła osiąga maksymalną dopuszczalną temperaturę pracy (zwykle 70 °C dla PVC, 90 °C dla XLPE).

Iz zależy od:
1. **Materiału żyły** (Cu vs Al)
2. **Materiału izolacji** (PVC vs XLPE)
3. **Sposobu instalacji** (w rurze, na ścianie, w ziemi…)
4. **Temperatury otoczenia**
5. **Liczby równolegle ułożonych obwodów**
6. **Liczby żył obciążonych w kablu**

Wartości tablicowe Iz są podawane dla **warunków odniesienia**: temperatura 30 °C (kable napowietrzne) lub 20 °C (ziemne), pojedynczy obwód.

## Sposoby instalacji wg PN-HD 60364-5-52

| Kod | Opis | Przykład |
|---|---|---|
| **A1** | przewody jednożyłowe w rurze w izolowanej ścianie | przewód w peszlu w ścianie z wełną |
| **A2** | przewody wielożyłowe w rurze w izolowanej ścianie | YDY w peszlu w ścianie ocieplonej |
| **B1** | przewody jednożyłowe w rurze na lub w nieizolowanej ścianie | LgY w listwie elektroinstalacyjnej |
| **B2** | **przewody wielożyłowe w rurze na lub w nieizolowanej ścianie** | **YDY w bruździe w tynku — najczęstsze** |
| **C** | przewody wielożyłowe na ścianie lub w niej (bez rury) | YDY mocowany uchwytami do ściany |
| **D1** | przewody / kable w rurze w ziemi | YKY w rurze osłonowej |
| **D2** | kable bezpośrednio w ziemi | NKT pod ziemią |
| **E** | kable wielożyłowe w powietrzu (drabinka kablowa) | rozdzielnia przemysłowa |
| **F** | kable jednożyłowe w wiązce w powietrzu | szyny rozdzielcze |
| **G** | kable jednożyłowe rozstawione w powietrzu | przyłącza napowietrzne |

W mieszkaniu/domu prawie zawsze stosuje się **B1, B2 lub C**.

## Tabela Iz — Cu w PVC, sposób B1, 30 °C (typowe wartości)

| Przekrój [mm²] | Iz [A] — 2 żyły obciążone | Iz [A] — 3 żyły obciążone |
|---|---|---|
| 1,5 | 17,5 | **14,5** |
| 2,5 | 24 | **19,5** |
| 4 | 32 | **26** |
| 6 | 41 | **34** |
| 10 | 57 | **46** |
| 16 | 76 | **61** |
| 25 | 101 | 80 |
| 35 | 125 | 99 |
| 50 | 151 | 119 |
| 70 | 192 | 151 |
| 95 | 232 | 182 |
| 120 | 269 | 210 |

**„3 żyły obciążone"** = obwód 3-fazowy lub 1-fazowy gdzie pracują równocześnie L, N i PE (rzadko PE). Dla obwodu 1-faz (L+N), PE nie liczy się jako obciążony — bierzemy kolumnę „3 żyły obciążone" jeśli kabel jest 3-żyłowy.

## Współczynniki korekcyjne

Tablicowe Iz to warunki idealne. W rzeczywistości trzeba je przemnożyć:

```
Iz' = Iz · kt · ki · kx
```

### Współczynnik temperatury kt

| T otoczenia | kt (PVC) | kt (XLPE) |
|---|---|---|
| 10 °C | 1,22 | 1,15 |
| 20 °C | 1,12 | 1,08 |
| **30 °C** | **1,00** | **1,00** |
| 35 °C | 0,94 | 0,96 |
| 40 °C | **0,87** | 0,91 |
| 45 °C | 0,79 | 0,87 |
| **50 °C** | **0,71** | 0,82 |
| 55 °C | 0,61 | 0,76 |
| 60 °C | 0,50 | 0,71 |

Przykład: kabel YDY w bruździe za grzejnikiem (40 °C) ma Iz pomnożone przez 0,87.

### Współczynnik zgrupowania ki

Gdy kilka obwodów leży obok siebie, każdy się grzeje od sąsiadów:

| Liczba sąsiadujących obwodów | ki (kable w wiązce) |
|---|---|
| 1 | **1,00** |
| 2 | **0,80** |
| 3 | **0,70** |
| 4 | 0,65 |
| 5 | **0,57** |
| 6 | 0,55 |
| 7 | 0,52 |
| 8 | 0,50 |
| 9 | 0,48 |
| 12 | 0,43 |
| 16+ | 0,38 |

Przykład: 5 obwodów YDY ułożonych w bruździe tuż obok siebie — ki = 0,57.

### Współczynnik głębokości kx (kable w ziemi)

Dla D1/D2 dochodzą jeszcze: kx (głębokość ułożenia) i kp (rezystywność termiczna gruntu). Standardowo zakłada się 0,7 m i grunt ρt = 2,5 K·m/W.

## Przykład — kabel za grzejnikiem, w wiązce z 3 innymi

**Sytuacja:** YDY 3×2,5 mm² do gniazda za grzejnikiem konwektorowym (otoczenie 40 °C), w jednej bruździe z 3 innymi obwodami.

**Iz tablicowe** (B1, Cu, PVC, 3 żyły, 30 °C) = **19,5 A**.

```
Iz' = 19,5 · kt · ki
    = 19,5 · 0,87 · 0,70
    = 11,9 A
```

Po korekcji żyła wytrzymuje tylko 11,9 A — **przekrój nie nadaje się pod B16**, trzeba dać B10 albo zmienić na 4 mm² (Iz=26 · 0,87 · 0,70 = 15,8 A — wystarcza pod B16).

## Kable ułożone w izolacji termicznej

Norma: jeśli kabel jest zakryty wełną mineralną lub styropianem, obowiązują tabele dla sposobu **A1/A2** (gorsze chłodzenie). Typowo Iz spada o 10-15 % w stosunku do B1.

Współczynnik tłumacząc na praktykę: w domu pasywnym z 30 cm wełny — układaj przewody **pod warstwą wełny od strony pomieszczenia** (od strony zewnętrznej grozi rosieniem) i traktuj jak A2.

## Iz dla kabli aluminiowych

Al ma gorszą przewodność — Iz spada o ~22 % przy tym samym przekroju:

| Przekrój [mm²] | Iz Cu (B2) | Iz Al (B2) |
|---|---|---|
| 4 | 26 | 20 |
| 6 | 34 | 26 |
| 10 | 46 | 36 |
| 16 | 61 | 47 |
| 25 | 80 | 62 |
| 35 | 99 | 76 |
| 50 | 119 | 92 |

## Zasada bezpieczeństwa — zawsze sprawdzaj

W projektach poważnych korzystaj z programów typu **DiaLux**, **OliComp**, **iProject** — uwzględniają wszystkie współczynniki automatycznie. Ręczne obliczenia służą do weryfikacji wyników i intuicji.

## Co dalej

Sekcja przewodów zakończona. Następna sekcja — [04 Bezpieczniki i wyłączniki](../04-bezpieczniki/index.html).
