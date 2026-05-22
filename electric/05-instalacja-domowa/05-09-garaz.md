# Garaż, piwnica, kotłownia

Pomieszczenia gospodarcze: garaż (z autem na paliwo lub elektrykiem), piwnica (wilgoć), kotłownia (gaz, olej, węgiel) — wszystkie wymagają **specjalnego traktowania**.

## Strefy zagrożenia (paliwa)

Gdzie składowane lub używane są **paliwa palne** (benzyna, gaz LPG, butla), obowiązują dodatkowe wymagania **ATEX** (Atmosfera Wybuchowa):

| Strefa | Charakterystyka | Wymaganie sprzętu |
|---|---|---|
| **Strefa 0** | atmosfera ciągle wybuchowa | Ex tylko |
| **Strefa 1** | wybuchowa okresowo (normalna eksploatacja) | Ex |
| **Strefa 2** | wybuchowa rzadko, krótko | Ex lub odporny ognioszczelny |
| **Poza strefą** | brak zagrożenia | standardowy IP44+ |

W domowym garażu (auto na benzynę) — typowo **strefa 2** w okolicach baku (~50 cm od korka). Praktycznie: gniazda i łączniki min. **1 m od potencjalnego źródła** + IP44.

> **Garaż z autem elektrycznym** — bez paliwa nie ma strefy Ex. Ale wymaga ładowarki z odpowiednim wallboxem (poniżej).

## Standardowe wyposażenie elektryczne

| Element | Wymóg |
|---|---|
| Stopień ochrony osprzętu | **IP44 minimum** |
| Gniazda warsztatowe | B16, **RCD 30 mA**, 1,5 m wysokości |
| Gniazdo siłowe 3F | CEE 5P 16A lub 32A |
| Oświetlenie | **IP65** (LED świetlówkowe odporne na wilgoć) |
| Łączniki | przy drzwiach, IP44, podświetlone |
| Wentylacja | wentylator (powietrze świeże + grawitacyjna) |

## Gniazdo siłowe 3-fazowe (CEE)

Standard międzynarodowy CEE 17 (IEC 60309) — kolory wg napięcia, prądu:

| Kolor | Napięcie | Prąd | Zastosowanie |
|---|---|---|---|
| **Niebieski 3P (2P+E)** | 230 V 1-faz | 16 A | kempingowe, jedna faza |
| **Czerwony 5P** | 400 V 3-faz | **16 A** | spawarka, szlifierka, mała maszyna |
| **Czerwony 5P** | 400 V 3-faz | **32 A** | duża maszyna, ładowarka EV 22 kW |
| **Czerwony 5P** | 400 V 3-faz | 63 A | przemysł |
| **Czarny 3P** | 500 V | 16/32 A | rzadko, przemysł |

Schemat zacisków 5P (5-stykowy):

```
     ┌───── PE (zielony, zacisk z literą E)
     │   ┌── N (niebieski)
     │   │
     │   │  ┌── L1 ─ pole na "godzinie 4"
     │   │  │      L2 ─ "godzina 8"
     │   │  │      L3 ─ "godzina 12"
     ●   ●  ●●●
       (gniazdo CEE 5P)
```

## Ładowarka EV (Wallbox)

Sercem garażu z elektrykiem jest **wallbox** (Charging Wallbox) — stacjonarna ładowarka 3-fazowa.

| Moc | Prąd | Faza | Kabel | Zabezpieczenia |
|---|---|---|---|---|
| **3,7 kW** | 16 A | 1-faz | 3×2,5 mm² | RCBO B16/30 mA typ A |
| **7,4 kW** | 32 A | 1-faz | 3×6 mm² | MCB C32 + RCD typ A + DD lub typ B |
| **11 kW** | 16 A | **3-faz** | **5×2,5 mm²** | MCB C16 ×3 + RCD typ B (lub A+DD) |
| **22 kW** | 32 A | **3-faz** | **5×6 mm² lub 5×10 mm²** | MCB C32 ×3 + RCD typ B + SPD T2 |

### Wymagania PN-HD 60364-7-722

- **RCD typu B** lub typu **A + detektor DC (DD)** — falowniki EV generują składową DC, RCD typ A może być „oślepiony";
- ochronnik przepięciowy SPD T2 przy długich kablach;
- dedykowany obwód — bez gniazd „przy okazji";
- zalecane: licznik energii (energetyka rozliczenia EV vs domowe).

### Schemat ideowy ładowarki 11 kW

```
   Rozdzielnica:
   ─ FR ─ MCB C16 ×3 ─ RCD typ B 4P 40A/30mA ─ SPD T2 ─┬── L1 ┐
                                                       ├── L2 ├── Wallbox
                                                       ├── L3 ┤   (CEE 32A
                                                       ├── N  ┤   lub Type 2)
                                                       └── PE ┘
   kabel YDYżo 5×2,5 mm² (do 25 m) lub 5×4 mm² (do 40 m)
```

## Oświetlenie odporne na wilgoć

W garażu, piwnicy, kotłowni stosujemy oprawy klasy **IP65** typu świetlówkowego (potocznie „pyłoszczelne"):

- LED **120 cm 36 W** ≈ 4000 lm = zastępuje świetlówkę T8 2×36 W,
- temperatura barwowa **4000 K** (neutralna, dobra do pracy),
- montaż na suficie z włącznikiem przy drzwiach, podświetlonym.

Liczba opraw: ~**1 oprawa LED 36 W na 12–15 m²** dla 300 lx (poziom warsztatowy).

## Wentylacja

| Element | Wymóg |
|---|---|
| Wentylator wyciągowy (kotłownia, garaż) | IP44, zwykle 230 V |
| Czujnik CO (garaż z autem) | obowiązkowy w niektórych przepisach |
| Czujnik gazu (kotłownia gazowa) | rozłączający elektrozawór gazu |

## Kocioł c.o. — własny obwód

Kocioł gazowy / olejowy / elektryczny — **dedykowany obwód B16** z osobnym RCBO 30 mA typ A (jeśli sterownik z falownikiem — typ F lub B).

Opcjonalnie: zasilanie z **UPS** lub awaryjnego generatora — dom z piecem CO bez prądu = brak ogrzewania nawet zimą. UPS 1 kVA wystarczy do podtrzymania pompy obiegowej przez 1–2 h.

```
   schemat kotła z UPS:
   
   sieć 230 V ─── obwód kotła B16 ──┬── UPS 1 kVA ─── kocioł c.o.
                                    │                  + pompa
                                    │
                                    └── (alternatywnie bypass)
```

## Co dalej

➡ [Pomieszczenia — minimum gniazd](05-10-pomieszczenia.md)
