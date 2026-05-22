# Rodzaje zabezpieczeń

## Trzy podstawowe funkcje zabezpieczeń

Każde urządzenie zabezpieczające reaguje na jedno lub więcej z poniższych zagrożeń:

| Zagrożenie | Czego pilnuje | Typ urządzenia |
|---|---|---|
| **Przeciążenie** | prądu większego od In, ale nie zwarciowego | bezpiecznik topikowy, MCB |
| **Zwarcie** | nagły prąd setki/tysiące × In | MCB (część zwarciowa), bezpiecznik topikowy |
| **Prąd różnicowy (upływ)** | różnica prądów L-N (prąd uciekający np. do PE lub przez ciało) | RCD, RCBO |
| **Przepięcie** | napięcie wyższe niż dopuszczalne | SPD (ogranicznik przepięć) |

## 1. Bezpieczniki topikowe — najstarsza i najpewniejsza technologia

Wkładka topikowa to drut o kalibrowanym przekroju, który **stapia się** pod wpływem nadmiernego prądu. Działanie nieodwracalne — po zadziałaniu wymiana wkładki.

### D01 / D02 (E14/E27) — domowe wkładki bezpiecznikowe

Stosowane głównie w **starszych instalacjach** (sprzed ery MCB) i w niektórych nowoczesnych rozdzielniach jako zabezpieczenie przedlicznikowe.

| Typ | Wkładka | Prąd | Charakter |
|---|---|---|---|
| **D01** | E14 (mała) | 2-16 A | wkręcana ze szkiełkiem-kolorem |
| **D02** | E27 (większa) | 20-63 A | jw., większy zakres |
| **NH00 - NH4** | wkładki nożowe | 6 A - 1250 A | przemysłowe, na łapy nożowe |

**Charakterystyki wkładek topikowych:**
- **gG** — ogólnego przeznaczenia (przewody, odbiorniki rezystancyjne)
- **aM** — tylko zwarciowe (do silników, gdzie przeciążenie zabezpiecza inne urządzenie)
- **gR** / **aR** — szybkie, do półprzewodników, falowników

Kolor szkiełka w D01/D02 jednoznacznie identyfikuje prąd: różowy=2 A, brązowy=4 A, zielony=6 A, czerwony=10 A, szary=16 A, niebieski=20 A, żółty=25 A, czarny=35 A, biały=50 A, miedziany=63 A.

## 2. Wyłączniki nadprądowe MCB (S301, S303)

**MCB** (Miniature Circuit Breaker) — wyłącznik nadprądowy modułowy, instalowany na szynie TH35. Wyzwala bimetal (przeciążenie) lub elektromagnes (zwarcie). Po zadziałaniu — wymaga **ręcznego załączenia**.

| Symbol | Typ | Zastosowanie |
|---|---|---|
| **S301 1P** | 1-biegunowy | obwody 1-faz, przerywa tylko L |
| **S301 1P+N** | 1-biegunowy + N | jw., ale przerywa też N (lepsze do RCD) |
| **S303 3P** | 3-biegunowy | obwody 3-faz, przerywa L1+L2+L3 |
| **S304 3P+N (4P)** | 3-biegunowy + N | obwody 3-faz z neutralnym |

Nazwa **S30x** to konwencja ABB; podobne to: Hager MBN, Schneider iC60, Eaton PLHT, Legrand DX³.

Symbol **C16** oznacza: charakterystyka C, prąd znamionowy 16 A. Zdolność zwarciowa zwykle 6 kA dla domowych, 10 kA dla przemysłowych.

## 3. Wyłączniki różnicowoprądowe RCD (RCCB)

**RCD** (Residual Current Device) — reaguje na **różnicę** prądu między L a N (w 3-faz: suma I L1+L2+L3+N ≠ 0). Różnica oznacza prąd uciekający (do PE, do ziemi, przez ciało człowieka).

Wartości czułości IΔn:
- **10 mA** — najczulsze (sale operacyjne, łazienki specjalne)
- **30 mA** — ochrona ludzi (wymóg dla gniazd, łazienek)
- **100 mA** — selektywne, ogólne (S)
- **300 mA** — ochrona p-pożarowa
- **500 mA** — ochrona instalacji przemysłowych

RCD **nie zabezpiecza przed przeciążeniem ani zwarciem** — to robi MCB. RCD chroni tylko przed porażeniem.

## 4. RCBO — RCD + MCB w jednym module

**RCBO** (Residual Current Breaker with Overcurrent protection) łączy w jednej obudowie:
- zabezpieczenie nadprądowe (MCB)
- zabezpieczenie różnicowoprądowe (RCD)

Korzyści:
- **selektywność po obwodach** — wyłączy się tylko jeden obwód, a nie wszystkie pod jednym RCD
- **diagnostyka** — wiadomo, czy zadziałał z powodu zwarcia/przeciążenia czy upływu
- **mniej miejsca** w rozdzielnicy (1 moduł zamiast 2-3)

Nowoczesny standard: w nowych instalacjach **każdy obwód ma własne RCBO 30 mA**. To droższe niż wspólne RCD, ale dużo wygodniejsze w eksploatacji.

## 5. Bezpieczniki selektywne (S)

Bezpiecznik z literką **S** na obudowie ma **opóźnione zadziałanie** — pozwala bezpiecznikom dolnym zadziałać pierwsze, zachowując zasilanie pozostałych obwodów.

Typowe zastosowania:
- **MCB S** — jako zabezpieczenie główne przed grupą zwykłych MCB
- **RCD S** (selektywne 100/300 mA) — przed grupą RCD 30 mA

Bez selektywności: zwarcie w jednym gniazdku potrafi wyłączyć cały dom.

## 6. Wyłączniki rozłączniki (FR-S, FR-N)

To **niezabezpieczone wyłączniki** (jak duże łączniki dwustronne) — służą do ręcznego rozłączenia bez funkcji ochronnej. Stosowane jako:
- główny rozłącznik mieszkania (32-63 A)
- przed grupą zabezpieczeń
- jako wyłącznik p-poż (z cewką wyzwalającą)

## 7. Wyłączniki SPD-T1/T2/T3 (ograniczniki przepięć)

Te nie zabezpieczają przed prądem stałego obciążenia — tylko chwilowymi **przepięciami** (uderzenia pioruna, łączeniowe).

Szczegóły w sekcji [10 — Ochrona przepięciowa](../10-przepiecia/index.html).

## Podsumowanie — co w typowej rozdzielnicy

Rozdzielnica domu jednorodzinnego (3-faz 16 A):

```
Główny rozłącznik 63 A
     ↓
SPD T1+T2 (ograniczniki)
     ↓
RCBO 30 mA / B16 — gniazda salonu
RCBO 30 mA / B16 — gniazda kuchnia
RCBO 30 mA / B10 — oświetlenie parter
RCBO 30 mA / C16 — pralka, AGD
RCBO 30 mA / C25 — kuchenka indukcyjna 3-faz
RCD typ B 30 mA / B16 — ładowarka EV
```

## Co dalej

➡ [Charakterystyki wyzwalania B/C/D/K/Z](04-02-charakterystyki.md)
