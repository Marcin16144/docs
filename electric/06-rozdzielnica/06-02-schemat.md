# Schemat ideowy rozdzielnicy

Schemat ideowy (jednokreskowy) pokazuje **logikę** rozdzielnicy — od przyłącza energetycznego do ostatniego odbiornika. Każdy element ma oznaczenie literowo-cyfrowe (F1, R1, K1, FR) zgodne z **PN-EN 81346**.

## Hierarchia od źródła do odbiornika

```
   ┌─── ZK (złącze kablowe) — przyłącze ZE
   │      (TAURON, PGE, ENERGA, ENEA)
   │
   ▼
   ┌─── licznik energii elektronicznej
   │      (własność dystrybutora)
   │      [poza rozdzielnicą domową — na elewacji]
   │
   ▼
   ┌─── PLI / ogranicznik mocy (jeśli wymagany)
   │      [w skrzynce licznikowej ZL]
   │
   ▼
   ╔══════════════════════════════════════╗
   ║   ROZDZIELNICA DOMOWA (TS lub R)     ║
   ║                                       ║
   ║   FR — wyłącznik główny rozłącznik    ║
   ║   ▼                                   ║
   ║   SPD T1+T2 (lub T2) → uziemienie    ║
   ║   ▼                                   ║
   ║   RCD główny S 100 mA (opcjonalnie)   ║
   ║   ▼                                   ║
   ║   szyna L (lub L1/L2/L3 dla 3F)       ║
   ║   ▼                                   ║
   ║   ┌─── grupa RCD 30 mA ──┬── MCB B16 → obwód 1 (gniazda)
   ║   │                      ├── MCB B16 → obwód 2 (gniazda)
   ║   │                      └── MCB B10 → obwód 3 (oświetlenie)
   ║   │
   ║   ├─── RCBO B16/30 mA  ──── obwód 4 (lodówka)
   ║   ├─── RCBO B16/30 mA  ──── obwód 5 (pralka)
   ║   ├─── MCB B16 3P ────────── obwód 6 (płyta indukcyjna)
   ║   └─── MCB C16 3P ────────── obwód 7 (ładowarka EV)
   ║                              + RCD typ B 30 mA
   ╚══════════════════════════════════════╝
```

## Złącze kablowe (ZK) i licznik

**ZK** to skrzynka na elewacji domu (lub w pasie drogowym), własność dystrybutora. Zawiera:

- **bezpieczniki przedlicznikowe** (PLI) typu DIII 25–63 A (lub WT-1 dla większych mocy),
- **plomby** dystrybutora,
- doprowadzenie z sieci kablowej / napowietrznej.

**Licznik energii** (od 2024 zwykle elektroniczny LZQJ-XC, ZE-310 itp.) jest w skrzynce licznikowej **ZL** lub w ZK. Licznik mierzy:

- energię pobraną (kWh) wg taryfy G11/G12/G12W,
- moc maksymalną (kW),
- przy fotowoltaice — energię oddaną do sieci (Wh).

## Ogranicznik mocy (PLI)

Mała aparatura w skrzynce licznikowej (np. **F&F PLI** lub **Hager EC1**) odcinająca instalację przy przekroczeniu zadeklarowanej mocy przyłączeniowej. Przykład: dla mocy umownej 11 kW (3F × 16 A) — PLI ustawiony na 16 A na fazę.

Przekroczenie → szybkie wyłączenie (kilka sekund) z automatycznym ponowieniem po 5 minutach.

## Wyłącznik główny FR

**FR** (rozłącznik główny) to:

- **wyłącznik izolacyjny modułowy** 3P+N (3F+N) — np. Hager SBN463, Schneider iSW 63A 4P, ABB E203 63A,
- znamionowy prąd 40–100 A (typowo 63 A dla domu),
- **bez** charakterystyki wyzwalania (nie chroni przed zwarciem),
- służy do **manualnego** odcięcia całej rozdzielnicy (np. na czas remontu).

> **FR** to nie to samo co MCB! FR rozłącza, ale **nie zabezpiecza** przed przeciążeniem. Funkcję zabezpieczenia pełnią bezpieczniki przedlicznikowe w ZK.

## Ochronnik przepięciowy SPD

Po FR, **przed** rozdzielaniem na obwody, wpinamy **SPD** (Surge Protective Device). Schemat ASCII:

```
   FR (L1 L2 L3 N) ────┬─── szyna L1 ──── do MCB
                       ├─── szyna L2 ──── do MCB
                       ├─── szyna L3 ──── do MCB
                       └─── szyna N ───── do listwy N
                       
                       ▼   (każdy z L → SPD → PE)
                       
   ┌─── SPD L1 ─┐
   ├─── SPD L2 ─┼──→ szyna PE ──→ uziom
   ├─── SPD L3 ─┤
   └─── SPD N  ─┘
```

Typy SPD:

| Typ | Test | Stosowanie |
|---|---|---|
| **T1** (Klasa I) | 10/350 µs | przy uderzeniu bezpośrednim, instalacja odgromowa |
| **T2** (Klasa II) | 8/20 µs | po SPD T1 lub samodzielnie, gdy brak odgromówki |
| **T3** (Klasa III) | 1,2/50 µs | przy odbiorniku, dodatkowo |
| **T1+T2 kombinowany** | obie próby | typowe w domach z LPS |

W domu bez instalacji odgromowej (LPS): **SPD T2** (Citel DS50, Hager SPN615R, ABB OVR).  
W domu z LPS: **SPD T1+T2** (Citel DS150, Hager SPN940R, Phoenix Contact Valvetrab).

## RCD główny (S 100 mA) — opcjonalny

Niektóre projekty stosują **RCD główny selektywny S** o IΔn = 100 mA, czas zwłoki 40 ms, **przed** indywidualnymi RCD 30 mA. Daje to:

- **selektywność** (przy zwarciu doziemnym wybija lokalny 30 mA, nie cały dom),
- ochronę przeciwpożarową (300 mA też używane).

W projektach domowych częściej rezygnuje się z RCD głównego na rzecz **RCBO indywidualnych** dla każdego obwodu (bardziej kosztowne, ale lepsza selektywność).

## Grupy RCD 30 mA

Tradycyjne podejście: **jeden RCD 30 mA na 4–6 obwodów** (4-modułowy 4P 40A/30 mA dla grupy 3-fazowej, 2-modułowy 2P 25A/30 mA dla jedno-fazowej).

Wady: wybicie RCD wyłącza wiele obwodów naraz.  
Plus: tańsze niż RCBO indywidualne.

Współczesny trend: **RCBO indywidualne** (1 lub 2 moduły, MCB+RCD w jednym).

## Przykład schematu kompletnej rozdzielnicy 3F dla domu 100 m²

```
                     ┌─ ZK ──── L1 L2 L3 N PE (TN-C-S)
                     ▼
                     ┌─ licznik ────────────┐
                     │                       │
                     ▼                       ▼ (PE → szyna PE)
                                             
              FR 4P 63A ─┬─ SPD T2 ─┬─→ PE uziom
                          │ (L1,L2, │
                          │  L3,N)  │
                          ▼          
              ┌── szyna L1 L2 L3 N ──────────────────┐
              │                                       │
   F1: MCB B16   1F  → gniazda salon
   F2: MCB B16   1F  → gniazda sypialnia
   F3: MCB B10   1F  → oświetlenie salon
   F4: MCB B10   1F  → oświetlenie sypialnia
   
   K1: RCBO B16/30mA → lodówka (dedykowany RCD)
   K2: RCBO B16/30mA → pralka
   K3: RCBO B16/30mA → zmywarka
   K4: RCBO B16/30mA → łazienka
   
   F5+F6+F7: MCB B16 3P → płyta indukcyjna (3F)
   
   F8+F9+F10: MCB C16 3P + RCD typ B 30 mA → ładowarka EV
   
   F11: MCB B6 → dzwonek
   F12: MCB B16 → kocioł c.o.
   
   + lampki sygnalizacyjne L1, L2, L3
   + zegar astronomiczny
   + przekaźniki bistabilne (oświetlenie wybrane)
```

## Oznaczenia literowe (PN-EN 81346)

| Litera | Znaczenie | Przykład |
|---|---|---|
| **F** | bezpiecznik, wyłącznik nadprądowy | F1, F2, F10 |
| **FR** | rozłącznik izolacyjny | FR1 |
| **Q** | wyłącznik dużej mocy | Q1 (główny) |
| **K** | przekaźnik, RCD, RCBO | K1, K2 |
| **L** | lampka sygnalizacyjna | L1 (faza), Lx |
| **T** | transformator | T1 (dzwonek) |
| **R** | rezystor / RCD | R1 |
| **X** | zacisk, listwa | X1 (listwa N) |
| **S** | łącznik / czujnik | S1 (zmierzchowy) |

## Co dalej

➡ [Układy sieci TN/TT/IT](06-03-uklady-sieci.md)
