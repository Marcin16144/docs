# 05-04: Baterie i akumulatory

## Definicje

**Bateria** — ogniwo galwaniczne **jednokrotnego użytku**. Po wyczerpaniu wyrzucamy.
**Akumulator** — ogniwo **wielokrotnego ładowania**.

Razem nazywane "ogniwami" lub "źródłami chemicznymi". Energia powstaje z reakcji chemicznych w elektrodach.

## Parametry ogniwa

| Parametr | Symbol | Znaczenie |
|----------|--------|-----------|
| Napięcie nominalne | U_nom | typowe napięcie w spoczynku |
| Napięcie odcięcia | U_cut | minimalne dopuszczalne (głębokie rozładowanie) |
| Pojemność | Q lub C | ilość energii [Ah lub mAh] |
| Energia | E | [Wh] = U · Q |
| Gęstość energii | E_d | [Wh/kg] lub [Wh/L] |
| Prąd maks. ciągły | I_max | jaki prąd zniesie |
| Prąd impulsowy | I_pulse | krótkie szczyty |
| Liczba cykli | N | dla akumulatora |
| Samorozładowanie | %/miesiąc | jak szybko traci ładunek |

## Pojemność i czas pracy

```
t = Q / I

t — czas pracy [h]
Q — pojemność [Ah]
I — prąd obciążenia [A]
```

**Przykład:** Akumulator 2000 mAh, prąd 200 mA: t = 2000/200 = 10 h.

Ostrzeżenie: pojemność jest podawana w określonych warunkach (np. C/10 = rozładowanie 1/10 C przez 10 h). Przy większych prądach efektywna pojemność spada.

## Łączenie

### Szeregowo

Sumują się napięcia, pojemność (Ah) **bez zmiany**.

4× ogniwo Li-Ion 3,7 V / 2 Ah szeregowo = 14,8 V / 2 Ah.

### Równolegle

Pojemność się sumuje, napięcie **bez zmiany**.

4× ogniwo Li-Ion 3,7 V / 2 Ah równolegle = 3,7 V / 8 Ah.

### Pakiet S × P

3S4P = 3 szeregowo × 4 równolegle = 12 ogniw, 3·3,7 V = 11,1 V, 4·2 Ah = 8 Ah.

W łączeniu **różnych ogniw** nie używaj — pojedyncze ogniwo może być przeciążone, słabsze.

## Typy baterii i akumulatorów

### Alkaliczne (cynkowo-manganowe)

| Parametr | Wartość |
|----------|---------|
| Napięcie | 1,5 V |
| Pojemność (AA) | 1800-3000 mAh |
| Samorozładowanie | 2-3% rok |
| Cykle | nieładowalna |
| Cena | tania |

Najpopularniejsze. Wytrzymują długie przechowywanie. Małe prądy.

### Cynkowo-węglowe

Słabsze, tańsze. Wyparte przez alkaliczne. Obecnie tylko w prostych aplikacjach (zegary, piloty).

### Litowe pierwotne (CR123, CR2032)

| Parametr | Wartość |
|----------|---------|
| Napięcie | 3 V |
| Pojemność (CR2032) | 230 mAh |
| Samorozładowanie | < 1% / rok |
| Trwałość | 10+ lat |

Pastylki — zegary, BIOS, breloki. CR123 — aparaty, lampy taktyczne.

### NiCd (niklowo-kadmowe)

Stary akumulator. Wytrzymały, dobra praca w niskich temperaturach. Niskie napięcie (1,2 V/cell). **Toksyczny kadm** — wycofywany w UE. "Efekt pamięci" — ładowanie z niepełnego stanu zmniejsza pojemność.

### NiMH (niklowo-wodorkowe)

Następca NiCd. 1,2 V/cell, większa pojemność niż NiCd, brak kadmu. Słabszy w niskich temperaturach, samorozładowanie szybsze.

Eneloop (Sanyo/Panasonic) — niska samorozładowność, do długiego przechowywania.

### Ołowiowy (kwasowo-ołowiowy, akumulator samochodowy)

| Parametr | Wartość |
|----------|---------|
| Napięcie nominalne (ogniwa) | 2 V |
| Typowy pakiet | 12 V (6 ogniw szeregowo) |
| Pojemność | 1-200 Ah |
| Cykle | 200-1000 |
| Gęstość energii | 30-40 Wh/kg |

Najtańszy w przeliczeniu na Wh. Cieżki, ale niezawodny. Stosowane: samochody, UPS, fotowoltaika hobby.

Warianty:
- **SLA (Sealed Lead-Acid)** — zamknięty, bezobsługowy
- **AGM (Absorbent Glass Mat)** — bezbsługowy, lepsze parametry
- **Gel** — żelowy elektrolit
- **Klasyczny** — z elektrolitem ciekłym (dolewa się wodę)

Wymagane prawidłowe ładowanie: **nigdy nie rozładowuj poniżej 50%**, bo trwale traci pojemność.

### Li-Ion (lit-jonowe)

**Najpopularniejsze** dziś w elektronice.

| Parametr | Wartość |
|----------|---------|
| Napięcie nominalne | 3,7 V |
| Max naładowanie | 4,2 V |
| Min rozładowanie | 2,5-3,0 V |
| Pojemność (18650) | 1500-3500 mAh |
| Cykle | 300-1000 |
| Gęstość energii | 150-260 Wh/kg |

Formaty:
- **18650** — cylindryczne 18×65 mm, klasyczne (laptopy, hulajnogi, latarki)
- **21700** — 21×70 mm, nowsze, większe pojemności (Tesla)
- **14500** — wymiar baterii AA, ale 3,7 V (uwaga, nie zamiennik!)
- **Pouch (LiPo)** — płaskie, miękkie (telefony, drony)
- **Prismatic** — twarde kostki (samochody, ESS)

#### Krzywa rozładowania Li-Ion

```
U [V]
4,2 ─┐
     │\
4,0 ─│ \____
3,8 ─│      \____
3,6 ─│           \___
3,4 ─│               \__
3,2 ─│                  \_
3,0 ─│                    \____ koniec
2,8 ─                          \____
     └──────────────────────────────── Q
       0%                          100%
```

Większość pojemności jest między 4,2-3,4 V (płaska część).

### LiFePO4 (lit-żelazowo-fosforanowe)

Wariant Li-Ion bezpieczniejszy.

| Parametr | Wartość |
|----------|---------|
| Napięcie nominalne | 3,2 V |
| Max | 3,65 V |
| Min | 2,0-2,5 V |
| Cykle | 2000-5000 |
| Bezpieczeństwo | dobre |
| Gęstość energii | 90-160 Wh/kg |

Stosowane: ESS (Energy Storage System), pojazdy elektryczne (BYD), zasilanie domowe.

### Li-Polymer (LiPo)

Technologicznie podobne do Li-Ion, ale w obudowie miękkiej (pouch). Cieńsze, lżejsze, ale bardziej wrażliwe na uszkodzenia mechaniczne.

Stosowane: telefony, tablety, drony.

## Ładowanie Li-Ion (CV-CC)

Standardowa procedura:

1. **CC (Constant Current)** — ładowanie stałym prądem do osiągnięcia 4,2 V (typowo 0,5C, czyli pojemność/2 h).
2. **CV (Constant Voltage)** — utrzymanie 4,2 V, prąd maleje.
3. **Termination** — przy I < 0,05C (5% nominalnej) → koniec.

**Nigdy** nie przeładowuj ponad 4,2 V! Powyżej 4,3 V → ryzyko pożaru.

### Ładowarki

- **TP4056** — popularny chip dla 1S (jedna celka), do 1 A
- **MCP73831** — Microchip
- **BQ24074** (TI) — z power path, do paneli słonecznych
- **CN3791, CN3722** — z MPPT do paneli

## BMS (Battery Management System)

Pakiet wielocelek (np. 4S, 7S) wymaga **BMS** — układ chroniący przed:

- Przeładowaniem (> 4,2 V/cell)
- Głębokim rozładowaniem (< 2,5 V/cell)
- Zwarciem
- Przegrzaniem
- **Balansowaniem** — wyrównywaniem napięć cel

Bez balansowania pakiet "puchnie": jedna celka rozładowuje się szybciej, inne nadal pełne. BMS pasywnie (rezystorami rozprasza nadmiar) lub aktywnie (transfer energii) wyrównuje.

## Bezpieczeństwo Li-Ion

Li-Ion przy uszkodzeniu lub złym ładowaniu może:
- Spuchnąć (pęcznieć)
- Wybuchnąć
- Zapalić się (samozapłon)

### Zasady

1. **Nie przeładowuj** > 4,2 V.
2. **Nie rozładowuj** < 2,5 V (poniżej kładzie się).
3. **Nie spinaj zwarciem**.
4. **Nie uszkadzaj mechanicznie** (przebicie, dziurkowanie).
5. **Nie nagrzewaj** > 60°C.
6. **Nie ładuj w niskiej temperaturze** < 0°C (tworzenie się dendrytów).
7. **Nie używaj uszkodzonych** (spuchniętych, zdeformowanych).
8. Stosuj **gniazda z bezpiecznikami** (PTC, fuse).

### Przy pożarze

Li-Ion nie da się ugasić wodą tradycyjnie. Stosuje się piasek, koc gasniczy, dedykowane gaśnice (lithium-specific). Najlepiej **odsunąć ognik** od palnych materiałów.

## Akumulator samochodowy

12 V (6 cel po 2 V) lub 24 V (12 cel) dla ciężarówek.

### Parametry

- **CCA (Cold Cranking Amps)** — prąd rozruchowy w niskiej temperaturze
- **Ah** — pojemność w 20-godz. rozładowaniu
- **RC (Reserve Capacity)** — czas przy stałym prądzie 25 A

### Ładowanie

- Sieciowe ładowarki — 2-10 A
- W samochodzie — alternator (12,5-14,5 V)
- **Nie przeładuj** > 14,4 V → gazowanie, ubytek elektrolitu

### Stan naładowania (SOC)

| U_spoczynek | SOC |
|-------------|-----|
| 12,7 V | 100% |
| 12,5 V | 75% |
| 12,4 V | 50% |
| 12,2 V | 25% |
| 12,0 V | 0% — głębokie rozładowanie |

## Akumulatory dla zasilania awaryjnego

### UPS

12-48 V SLA / AGM, pojemność 7-100 Ah. Inverter zamienia DC na 230 V AC.

### Backup serwerowy

Stojaki z AGM 12 V × wiele cel szeregowo.

## Magazyny domowe (PowerWall etc.)

LiFePO4 — 10-30 kWh. Współpracują z fotowoltaiką i siecią.

## Pomiar i diagnostyka

### Multimetr

Mierzy napięcie ogniwa **w spoczynku** (bez obciążenia).

Pod obciążeniem napięcie spada zależnie od rezystancji wewnętrznej:
```
U_load = U_open − I · R_int
```

Wzrastająca R_int sygnalizuje zużycie.

### Tester pojemności

Rozładowuje akumulator stałym prądem do U_cut, mierzy ilość energii. Realny test pojemności.

### Analizator (LCR, EIS)

Mierzy impedancję elektrochemiczną. Wykrywa zużycie wcześniej. Profesjonalne.

## Wybór ogniwa — checklist

1. **Napięcie potrzebne** (cel + ilość celek)
2. **Pojemność** (na ile godzin pracy)
3. **Prąd ciągły max** (czy ogniwo udźwignie)
4. **Prąd impulsowy** (np. silnik startujący)
5. **Środowisko** (temperatura)
6. **Bezpieczeństwo** (Li-Ion vs LiFePO4 vs Ołów)
7. **Cykle** (jednorazowe? wielokrotne?)
8. **Format fizyczny**
9. **Koszt** (Wh na zł)
10. **Ładowanie** (gdzie, jak, czas)

## Częste błędy

1. **Zwarcie ogniwa Li-Ion** — pożar.
2. **Ładowanie alkaliny** — wybuch.
3. **Pakiet bez BMS** — jedna celka padnie, pakiet pójdzie w nią z ognikiem.
4. **Łączenie nowych i starych ogniw** — słabsze ciągną pakiet w dół.
5. **Przechowywanie naładowanego Li-Ion** — degradacja, optymalnie 50% naładowane, chłodno.
6. **Brak ochrony niskonapięciowej** — głębokie rozładowanie Li-Ion → "smarowanie" anody → uszkodzenie.
7. **Mierzenie tylko napięcia** w spoczynku — ogniwo z dużą rezystancją wewnętrzną może mieć "OK" U w spoczynku, ale opadać dramatycznie pod obciążeniem.
