# Dobór bezpiecznika

## Pięć kroków doboru

Każdy bezpiecznik (MCB lub wkładka topikowa) musi spełniać pięć warunków:

| Krok | Pytanie | Co sprawdzasz |
|---|---|---|
| **1** | Jaki prąd pobiera obciążenie? | Ib z mocy odbiornika |
| **2** | Jaki prąd znamionowy In dać? | Ib ≤ In ≤ Iz (przewodu) |
| **3** | Jaka charakterystyka? | B / C / D zależnie od rozruchu |
| **4** | Czy zachowana selektywność? | In(górne) ≥ 1,6 × In(dolne) |
| **5** | Czy zdolność zwarciowa wystarcza? | Icn ≥ Ik na zaciskach |

## Krok 1 — prąd obciążenia Ib

Z mocy znamionowej odbiornika P i napięcia Un:

```
Ib = P / Un          (DC i AC rezystancyjne)
Ib = P / (Un · cos φ)        (AC z indukcją, cos φ < 1)
Ib = P / (√3 · Un · cos φ)   (3-fazowe)
```

Dla mieszanych obciążeń sumuj prądy z uwzględnieniem **współczynnika równoczesności** (typowo 0,6-0,8 dla mieszkania).

## Krok 2 — koordynacja z przewodem

Warunek:

```
Ib ≤ In ≤ Iz
```

Gdzie Iz to obciążalność długotrwała przewodu po wszystkich współczynnikach korekcyjnych ([sekcja 03-05](../03-przewody/03-05-obciazalnosc.md)).

W praktyce dla typowych przewodów Cu w PVC, sposób B1:

| Przewód Cu | Iz | Max In bezpiecznika |
|---|---|---|
| 1,5 mm² | 14,5 A | **B10** (bezpiecznie), B16 (z rezerwą) |
| 2,5 mm² | 19,5 A | **B16** |
| 4 mm² | 26 A | **B20 / B25** |
| 6 mm² | 34 A | **B25 / B32** |
| 10 mm² | 46 A | **B40** |

## Krok 3 — charakterystyka

Wybór wg [tabeli charakterystyk](04-02-charakterystyki.md):

| Odbiornik | Charakter. |
|---|---|
| Oświetlenie, gniazda elektronika | **B** |
| Lodówka, klimatyzator, AGD z silnikiem | **C** |
| Pompa ciepła, sprężarka, zgrzewarka | **C/D** |
| Indukcja, piekarnik | **B/C** |

## Krok 4 — selektywność

In(nadrzędne) ≥ 1,6 × In(podrzędne). Patrz [sekcja 04-03](04-03-selektywnosc.md).

## Krok 5 — zdolność zwarciowa Icn

Bezpiecznik musi mieć Icn ≥ prądowi zwarciowemu na jego zaciskach:

- **6 kA** — wystarcza w mieszkaniu w bloku (typowy Ik ~ 1-3 kA)
- **10 kA** — dom jednorodzinny blisko stacji trafo
- **25 kA** — przemysł / przyłącza dużej mocy

Domowe MCB typu **S301-B16** mają Icn = 6 kA. Wyższej klasy (Schneider iC60H, Hager NDN) — 10 kA.

## Przykład — bojler 2 kW w łazience

**Dane:** bojler ciśnieniowy 2 kW, 230 V, kabel YDY 3×2,5 mm², długość 10 m.

**Krok 1.** Ib = 2000 / 230 = **8,7 A**.

**Krok 2.** Iz dla 2,5 mm² (B1) = 19,5 A. Wybieramy In = **16 A** (8,7 ≤ 16 ≤ 19,5 ✓).

**Krok 3.** Bojler to grzałka rezystancyjna — brak rozruchu. Charakterystyka **B**.

**Krok 4.** Selektywność z głównym C40 → 40/16 = 2,5 ✓.

**Krok 5.** Mieszkanie w bloku, Ik = ~2 kA → 6 kA wystarczy ✓.

**Decyzja:** **B16, 6 kA, RCBO 30 mA** (bo łazienka → wymóg RCD).

## Tabela „typowy obwód → bezpiecznik"

| Obwód | Moc / prąd | Przewód | Bezpiecznik |
|---|---|---|---|
| Oświetlenie pokój | < 1 kW | 1,5 mm² | **B10** |
| Oświetlenie ciąg kuchnia-jadalnia | < 1,5 kW | 1,5 mm² | **B10 / B16** |
| Gniazda salon (rezerwa) | < 3,6 kW | 2,5 mm² | **B16** |
| Gniazda kuchnia (kawa, czajnik, mikrofalówka) | często 3,6 kW | 2,5 mm² | **B16 / C16** |
| Lodówka (dedykowane) | 0,2-0,5 kW | 2,5 mm² | **C13 / C16** |
| Pralka | 2-2,5 kW | 2,5 mm² | **B16 / C16** |
| Zmywarka | 2 kW | 2,5 mm² | **B16 / C16** |
| Piekarnik | 2,5-3,5 kW | 2,5 mm² | **B16 / C16** |
| Płyta indukcyjna 1-faz | 3,5 kW | 2,5 mm² | **B16 / C16** |
| **Płyta indukcyjna 3-faz** | 7,4 kW | 5×2,5 mm² | **C16 / C20 (3P)** |
| Kuchenka elektryczna 3-faz | 10 kW | 5×4 mm² | **C20 / C25 (3P)** |
| Bojler 2 kW | 2 kW | 2,5 mm² | **B16** |
| Ogrzewanie podłogowe (mata 1,5 kW) | 1,5 kW | 2,5 mm² | **B16** |
| Klimatyzator (split 3,5 kW chłodzenia) | 1 kW | 2,5 mm² | **C16** |
| Pompa ciepła 4 kW (3-faz) | 4 kW | 5×2,5 mm² | **C16 (3P)** |
| Ładowarka EV (1-faz 7,4 kW) | 7,4 kW | 6 mm² | **B32 / C32** |
| Ładowarka EV (3-faz 11 kW) | 11 kW | 5×2,5 mm² | **C16 (3P)** |
| Ładowarka EV (3-faz 22 kW) | 22 kW | 5×6 mm² | **C32 (3P)** |
| Główny obwód mieszkania (WLZ) | — | 10 mm² | **B40 / B50** |
| Przyłącze domu (3-faz) | — | 5×16 mm² | **gG 63 / B63 (3P)** |

## Reguła kciuka — szybki dobór

Dla typowej rozdzielnicy mieszkania:

- **Oświetlenie** → 1,5 mm² + **B10**
- **Gniazda** → 2,5 mm² + **B16** (C16 jeśli AGD z silnikiem)
- **Łazienka** → 2,5 mm² + **B16** + RCBO 30 mA
- **Indukcja 3-faz** → 5×2,5 mm² + **C16 3P**

Główny przed grupą: **B40 lub C40**, w przedlicznikowej części: **gG 50-63 A**.

## Zabezpieczenie odbiornika vs zabezpieczenie przewodu

Pamiętaj: MCB chroni przede wszystkim **przewód**, a nie odbiornik. Odbiornik powinien mieć własne wewnętrzne bezpieczniki (zwykle ma — np. termik w silniku, mikrobezpiecznik w zasilaczu).

Wyjątki, gdy MCB jest też zabezpieczeniem odbiornika:
- silniki (potrzeba MCB lub odrębnego zabezpieczenia silnikowego — wyłącznik motorowy z relayem termicznym)
- ładowarki EV (specjalne wymogi — RCD typ B/A+RDC-DD)

## Co dalej

➡ [Wyłączniki różnicowoprądowe RCD](04-05-rcd.md)
