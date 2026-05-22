# Dobór i montaż SPD

## Strefy ochrony LPZ

Norma **PN-EN 62305-4** dzieli budynek na strefy ochrony przed wyładowaniami atmosferycznymi (LPZ — *Lightning Protection Zone*):

| Strefa | Lokalizacja | Wymagany SPD |
|---|---|---|
| **LPZ 0A** | na zewnątrz, eksponowane na bezpośrednie uderzenie pioruna | — (LPS) |
| **LPZ 0B** | na zewnątrz, niewielkie ryzyko uderzenia (pod LPS) | — |
| **LPZ 1** | wewnątrz budynku, za rozdzielnicą główną | **T1 lub T1+T2** na granicy LPZ 0/1 |
| **LPZ 2** | wewnątrz, za rozdzielnicą oddziałową | **T2** na granicy LPZ 1/2 |
| **LPZ 3** | bezpośrednio przy odbiorniku | **T3** na granicy LPZ 2/3 |

W typowym domu wystarczają **strefy 0–2** (T1+T2 lub T2+T3).

## Lokalizacja SPD w domu

```
[linia napowietrzna] ─── [ZK ze złączem] ─── [rozdzielnica główna RG] ─── [rozdzielnica pod] ─── [odbiornik]
                              │                       │                          │                    │
                            [T1]                    [T2]                       [T2]                 [T3]
                          (jeśli LPS)         (zawsze)               (jeśli >10 m od RG)       (czuły odb.)
```

### Schemat 1 — dom bez LPS, zasilanie kablowe podziemne

- **T2** w rozdzielnicy głównej (na początku, za głównym wyłącznikiem) — standard,
- **T3** w listwach przy TV, PC, NAS.

### Schemat 2 — dom bez LPS, zasilanie napowietrzne

- **T1+T2 combo** (lub osobno T1+T2) w rozdzielnicy głównej,
- **T3** przy czułych odbiornikach.

### Schemat 3 — dom z LPS, zasilanie dowolne

- **T1** w złączu ZK (na granicy LPZ 0/1) — wymóg PN-EN 62305-4,
- **T2** w rozdzielnicy głównej,
- **T3** opcjonalnie przy odbiornikach.

## Reguła „50 cm" — najważniejsza zasada montażu

**Łączna długość przewodów łączeniowych SPD nie może przekroczyć 50 cm.**

```
        sznya L
        ──┬─────
          │ ← przewód L do SPD (a)
        ┌─┴─┐
        │SPD│
        └─┬─┘
          │ ← przewód do szyny PE (b)
        ──┴────
        szyna PE

        a + b ≤ 50 cm (najlepiej < 30 cm)
```

**Dlaczego?** Każdy przewód ma indukcyjność ~1 µH/m. Przy szybkim impulsie (di/dt) powstaje spadek napięcia:

```
U_L = L · di/dt
    = 1 µH/m × 0,5 m × (10 kA / 8 µs)
    = 625 V
```

Przy długości 1 m napięcie indukcyjne na zaciskach urządzenia wzrasta o 1 kV — całe Up jest zniweczone.

## Schematy montażu V i U

### Schemat V (równoległy) — preferowany

```
              ──L──┬────────────► do obwodu
                   │
              ──N──┼─┬──────────► do obwodu
                   │ │
                ┌──┴─┴──┐
                │  SPD  │
                └───┬───┘
                    │
                    ▼ PE
```

SPD podłączone **równolegle** do toru zasilania. **Brak wpływu na prąd roboczy** odbiornika. Najczęstsze.

### Schemat U (szeregowy) — tylko gdy duży prąd musi przejść przez SPD

```
              ──L─►┌────►──── do obwodu
                   │SPD│
                   └─┬─┘
                     ▼ PE
```

Cały prąd obwodu przepływa przez SPD. Stosowany w niektórych T3 dla ograniczonego prądu. Dla T1/T2 — nie stosować.

## Pre-fuse — zabezpieczenie SPD

SPD musi być zabezpieczony **przed nim** dedykowanym bezpiecznikiem:

| Typ SPD | Typowy pre-fuse |
|---|---|
| T1 25 kA | gG 125 A |
| T1 50 kA | gG 160 A |
| T2 40 kA | gG 63 A |
| T2 20 kA | gG 32 A |
| T3 | zwykle wbudowany (MCB lub bezpiecznik szklany) |

**Cel pre-fuse:** odciąć SPD od sieci, jeśli warystor zwarł się na stałe (po wyczerpaniu). Bez pre-fuse warystor może spowodować pożar.

**Producenci często mają „pre-fuse zintegrowany"** — np. Dehn V20-1+NPE-280, OBO V20.

Jeśli główne zabezpieczenie instalacji już spełnia warunki (np. wkładka WT 63 A w ZK), można pre-fuse pominąć.

## Stopniowanie ochrony — kaskada SPD

Aby T1, T2, T3 współpracowały, muszą być **rozdzielone przewodem o długości min. 10 m** lub **dławikiem rozsprzęgającym** (jeśli krótsza odległość).

```
[T1] ───── 10 m kabla ───── [T2] ───── 10 m kabla ───── [T3]
                            (LUB dławik 15 µH między T1 i T2)
```

Bez tego najszybszy ogranicznik (T3) zadziała pierwszy i przepali się.

**Producenci podają „odległość koordynowaną"** w karcie katalogowej — np. „T1 + T2 bez dławika: 10 m, z dławikiem: bez ograniczeń".

## Krok po kroku: montaż T2 w rozdzielnicy domowej

1. **Odłącz zasilanie** instalacji (wyłącz główny rozłącznik za licznikiem).
2. **Sprawdź brak napięcia** próbnikiem (test L-N, L-PE).
3. **Wybierz miejsce** — najlepiej na **początku rozdzielnicy**, tuż za głównym wyłącznikiem.
4. **Załóż pre-fuse** (jeśli producent wymaga).
5. **Wyprowadź 3 przewody** LgY 6 mm² (lub wg karty):
   - **L** ze szyny L → góra SPD,
   - **N** ze szyny N → drugi zacisk SPD,
   - **PE** ze szyny PE → dolny zacisk SPD.
6. **Łączna długość ≤ 50 cm** — przewody krótkie, proste.
7. **Dokręć momentem** wg karty (typowo 2,5–3,5 Nm).
8. **Wpisz w dokumentację** — typ SPD, parametry, data montażu.
9. **Załącz zasilanie** — sprawdź okienko stanu (zielone).

## Kiedy wymieniać SPD

| Sytuacja | Działanie |
|---|---|
| Czerwone okienko stanu | wymiana modułu (niektóre mają wymienne wkładki) |
| Po bezpośrednim uderzeniu pioruna | wymiana całego T1, kontrola T2 |
| Po silnej burzy bez uderzenia | przegląd okienek — często T2 czerwone |
| T2 — co kilka lat | przegląd okienek przy okresowych pomiarach |
| T1 — co 5 lat | przegląd okienek, pomiar Up (laboratorium) |

**Dobrym standardem** jest wymiana T2 co **10 lat** profilaktycznie.

## Przykład doboru dla domu 14 kW, TN-C-S, bez LPS

```
Złącze ZK:
   WT-NH 00 gG 63 A (główne)
   → kabel 5×16 mm² → 8 m → rozdzielnica

Rozdzielnica RG:
   ┌─ Główny rozłącznik 63 A
   │
   ├─ SPD T2: Dehn DG M TNC 275 (Up=1,3 kV, In=20 kA)
   │   pre-fuse: gG 63 A (już w ZK)
   │   przewody LgY 6 mm² zielono-żółty, łącznie 30 cm
   │
   ├─ Bezpieczniki rozdziału
   ├─ RCD główne 63 A 30 mA
   ├─ MCB obwodów
   └─ ...

Listwa SPD T3 przy stanowisku PC + TV.
```

## Co dalej

➡ [Instalacja odgromowa (LPS)](10-04-odgromowa.md)
