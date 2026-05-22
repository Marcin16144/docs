# Instalacja zewnętrzna i ogród

Instalacja **na zewnątrz** budynku — kable w gruncie, oświetlenie ogrodowe, gniazda elewacyjne, sterowanie bramą i furtką. Wszystko musi być odporne na wilgoć, UV, niskie temperatury i obciążenia mechaniczne.

## Kable układane w gruncie

| Typ kabla | Charakterystyka | Zastosowanie |
|---|---|---|
| **NKT** (NA2XS(F)2Y, NKT, NYY) | opancerzony (pancerz stalowy / FeZn), 4–5-żyłowy | przyłącze, magistrale, pod podjazd |
| **YKY** (YKYżo) | bez pancerza, PVC z PE, 4–5 żył | typowe ogrodowe, w peszlu pod podjazd |
| **YKXS / N2XH** | bez halogenowy, ognioodporny | przejścia przez budynki |

### Sposób układania

```
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  poziom gruntu
                                    
   ─────────── ░ ─ taśma ostrzegawcza ─ 30 cm nad kablem
                                       (niebieska, „Uwaga kabel")
                                    
   ─────────── piasek 10 cm nad kablem ───
                                    
   ━━━━━━━━━━━ KABEL YKY/NKT ─── głębokość ≥ 70 cm pod chodnikiem
                                  ≥ 70 cm pod trawnikiem
                                  ≥ 100 cm pod drogą / parkingiem
                                    
   ─────────── piasek 10 cm pod kablem ───
                                    
   ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  grunt rodzimy
```

| Element | Wymiar |
|---|---|
| Głębokość ułożenia | ≥ **70 cm** (chodnik, trawnik) / ≥ **100 cm** (jezdnia) |
| Podsypka piaskowa | 10 cm pod kablem + 10 cm nad |
| Taśma ostrzegawcza | 30 cm nad kablem, niebieska |
| Promień gięcia | ≥ 12× Ø kabla (większy niż w powietrzu) |
| Pod podjazdem | dodatkowo w peszlu RHDPE 50–63 mm |

> **Studzienki kablowe:** w długich trasach (>30 m) lub na rozgałęzieniach zaleca się studzienki rewizyjne (Hauff-Technik, OBO) — możliwość pomiaru izolacji i wymiany odcinka.

## Gniazda zewnętrzne

| Lokalizacja | Min. IP | Dodatkowo |
|---|---|---|
| Elewacja pod okapem | IP44 | klapka |
| Słupek ogrodowy | IP54–IP55 | wprowadzenie od dołu |
| Taras / patio osłonięty | IP44 | klapka |
| W pełni odsłonięty | **IP65** | RCD 30 mA dedykowany |
| Słupek z 4 gniazdami (sprzęt ogrodowy) | IP55 | osobny obwód z RCBO |

**Każdy obwód zewnętrzny musi mieć RCD 30 mA** — typowo RCBO B16/30 mA typ A dla każdego punktu lub jeden wspólny RCD F dla wszystkich gniazd zewnętrznych.

## Oprawy elewacyjne

- IP44 — pod okapem, balkon zadaszony;
- IP54 — elewacja częściowo osłonięta;
- IP65 — pełne narażenie (deszcz, śnieg, kurz).

Materiały: aluminium malowane proszkowo, stal nierdzewna, ABS UV-stabilny. **Unikaj** opraw z plastikiem nie-UV — kruszeją po 2 sezonach.

## Oświetlenie ogrodowe LED 12 V / 24 V

Bezpieczne **SELV** (Safety Extra Low Voltage):

| Napięcie | Bezpieczeństwo | Spadek napięcia |
|---|---|---|
| **12 V DC** | bezpieczne nawet w wodzie | duży spadek — krótkie odcinki |
| **24 V DC** | bezpieczne | mniejszy spadek — dłuższe trasy |
| 230 V AC | wymaga IP65, RCD 30 mA | bez ograniczeń trasy |

Schemat 12 V:

```
   sieć 230 V ─── transformator/zasilacz 12 V DC ──┬── lampka 1
                  IP65, 50–200 W                   ├── lampka 2
                                                   └── lampka N
                  (kabel YKY 2-żyłowy lub          
                   profesjonalny 2×4 mm² do ogrodu)
```

> **Spadek napięcia** w 12 V jest poważny: 30 m kabla 2×1,5 mm² przy 5 A daje już ~3 V spadku (25% strat). W ogrodzie używaj 2×4 mm² lub gęstej sieci zasilaczy lokalnych.

## Sterowanie zmierzchowe i czasowe

### Czujnik zmierzchowy

Modułowy do rozdzielnicy (Finder 11.41, F&F CZF) lub w oprawie (lampy LED z fotokomórką). Próg: 5–100 lx (regulacja). Histereza ~30 lx.

### Programator czasowy (timer)

Modułowy zegar astronomiczny (Finder 12.21, ABB AT2) — automatycznie liczy wschód/zachód słońca na podstawie współrzędnych geograficznych. Bez konieczności sezonowej regulacji.

```
   schemat oświetlenia ogrodu:

   L ─── MCB B10 ─── RCBO 30 mA ─── czujnik zmierzchu ─── stycznik ─── ⊗⊗⊗
                                                              │
                                          zegar astronomiczny ┘
```

## Brama i furtka

| Element | Zasilanie | Uwagi |
|---|---|---|
| **Siłownik bramy 230 V** | YDYp 3×1,5 do skrzynki, IP65 | sterowanie zewnętrzne |
| **Siłownik bramy 24 V DC** | bezpieczne, łatwiejsze sterowanie | często z fotowoltaiką |
| **Furtka elektrozaczep** | YDYp 3×1,5 + sterowanie 12V | przycisk wewnątrz + interkom |
| **Domofon / wideodomofon** | UTP Cat 5e lub dedykowany | osobny obwód |
| **Domofon bezprzewodowy** | bateria + WiFi | bez kabla na zewnątrz |

> **Trasy do bramy:** zaplanuj rury (peszle RHDPE 50 mm) z budynku do bramy/furtki **przed wykończeniem podjazdu**. Trzy rury: zasilanie, sterowanie, rezerwa (LAN/intercom). Bez tego — kucie kostki za kilka lat.

## Co dalej

➡ [Garaż, piwnica, kotłownia](05-09-garaz.md)
