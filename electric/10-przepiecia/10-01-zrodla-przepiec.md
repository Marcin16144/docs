# Źródła przepięć

## Czym jest przepięcie

**Przepięcie** to chwilowe podwyższenie napięcia w instalacji ponad wartość nominalną (230/400 V AC). Może być:

- **krótkotrwałe** — od mikrosekund (impuls piorunowy) do milisekund (łączeniowe),
- **długotrwałe** — sekundy (np. zerwanie przewodu N, niewłaściwy transformator),
- **wartość szczytowa** — od kilkuset V do dziesiątek kV.

Skala napięć i czasów decyduje o doborze ograniczników (SPD — *Surge Protection Device*).

## Trzy główne źródła przepięć

| Skrót | Pełna nazwa | Pochodzenie | Czas | Napięcie szczytowe |
|---|---|---|---|---|
| **LEMP** | *Lightning Electro­Magnetic Pulse* | piorun | µs | do **20 kV** |
| **SEMP** | *Switching Electro­Magnetic Pulse* | łączenia w sieci | ms | 1–6 kV |
| **ESD** | *Electro­Static Discharge* | ładunki statyczne | ns | 2–15 kV (głównie elektronika) |

## LEMP — przepięcia atmosferyczne

Najgroźniejsze. Powstają w wyniku **wyładowań atmosferycznych** (piorunów).

### Bezpośrednie uderzenie pioruna

Piorun trafia bezpośrednio w budynek, antenę, linię napowietrzną lub instalację odgromową:

| Parametr | Wartość typowa | Wartość ekstremalna |
|---|---|---|
| Prąd szczytowy | 10–30 kA | **do 200 kA** |
| Czas narastania | 1–10 µs | < 1 µs |
| Napięcie indukowane | dziesiątki kV | **miliony V** |
| Ładunek | ok. 5 C | do 300 C |
| Energia | 10⁵ J | do 10⁷ J |

Przed bezpośrednim uderzeniem chroni **wyłącznie LPS** (instalacja odgromowa) + **SPD typ 1**.

### Pośrednie (indukcyjne) uderzenie pioruna

Piorun uderza w pobliżu — na drzewo, słup, sąsiedni budynek. Pole elektromagnetyczne indukuje impuls w przewodach instalacji:

- nawet **do 2 km** od miejsca uderzenia,
- napięcia indukowane: **2–10 kV** na zaciskach,
- prądy w przewodach: **kilka kA**.

Występuje dużo częściej niż bezpośrednie uderzenie. Chroni **SPD typ 2** w rozdzielnicy głównej.

### Rozkład gęstości wyładowań w Polsce

| Region | Gęstość Ng [wyładowań/km²/rok] |
|---|---|
| Pomorze | 1,0–1,5 |
| Mazowsze, Wielkopolska | 1,5–2,0 |
| Małopolska, Podkarpacie | **2,0–3,5** (najwyższa) |
| Średnia krajowa | ~1,8 |

Dane: PAN, IMGW (sieć detekcji PERUN). W Polsce południowej ochrona SPD jest praktycznie obowiązkiem.

## SEMP — przepięcia łączeniowe

Powstają **wewnątrz instalacji** wskutek normalnych łączeń odbiorników indukcyjnych lub przełączeń w sieci dostawcy.

### Źródła SEMP w domu

| Źródło | Mechanizm | Typowe Uszczytowe |
|---|---|---|
| Wyłączenie silnika (pralka, pompa) | przerwanie indukcyjności, indukcja zwrotna | 1–3 kV |
| Stary wyłącznik świetlówki | iskrzenie styków | 2–5 kV |
| Cewka stycznika, przekaźnik | otwarcie obwodu indukcyjnego | 1–4 kV |
| Wyłączenie pieca/grzejnika | nagła zmiana prądu | < 1 kV |
| Załączanie odbiorników w sieci dostawcy | komutacja w stacji trafo | 1–6 kV |
| Zwarcie + zadziałanie zabezpieczenia | gwałtowna zmiana impedancji | 2–4 kV |

### Pole zagrożenia

SEMP są niskoenergetyczne (mała Δt → mała ΔE), ale **bardzo częste** — kilka razy dziennie. Powodują:

- starzenie kondensatorów w zasilaczach,
- uszkodzenia elektroniki sterującej (pralki, kotły, klimatyzacja),
- niewyjaśnione „samowłączenia" routerów, NAS, sterowników smart-home.

Chroni **SPD typ 2** w rozdzielnicy + **SPD typ 3** blisko czułego odbiornika.

## ESD — wyładowania elektrostatyczne

Powstają na powierzchniach izolacyjnych przy tarciu (chodzenie po wykładzinie, ubranie syntetyczne).

| Czynność | Typowe napięcie ESD |
|---|---|
| Spacer po wykładzinie syntetycznej | 5–15 kV |
| Wstanie z fotela skórzanego | 3–8 kV |
| Praca z folią styropianową | 5–20 kV |
| Praca w warunkach 20% wilgotności | dwukrotnie wyższe niż przy 60% |

W instalacjach **niskiego napięcia** ESD nie stanowi zagrożenia dla okablowania — energia jest bardzo mała. **Krytyczne dla elektroniki** (procesory, układy CMOS, gigabitowe porty Ethernet).

W warunkach domowych chronią:

- przewody PE z dobrym uziomem (rozładowują ESD bezpiecznie),
- maty antystatyczne w warsztacie,
- nawilżacze powietrza (wilgotność >40% redukuje ESD).

## Skala napięć — ujęcie ilościowe

```
Nominalne                 230 V    1×Uo
Dopuszczalne (PN)         ±10%     ~250 V max
                          ─────────────────────
Krótkotrwałe wahania      230÷300 V
SEMP łagodne              500÷1000 V
SEMP groźne               1÷3 kV
LEMP indukowane           2÷10 kV
LEMP bezpośrednie         10÷100 kV
ESD                       2÷20 kV
                          ─────────────────────
SPD Up (napięcie ochronne) <1,5 kV
Wytrzymałość zasilaczy SMPS  ~2 kV
Wytrzymałość izolacji kabla 4 kV (1 min)
```

## Rola SPD — co realnie potrafią

SPD nie eliminują przepięć — **ograniczają je do bezpiecznej wartości** (napięcie Up). Typowo:

- na wejściu impulsu **6 kV / 3 kA** (kategoria standardowa testu),
- SPD typ 2 obniża napięcie na zaciskach do **<1,5 kV**,
- SPD typ 3 dodatkowo do **<800 V**.

Wartość 1,5 kV jest bezpieczna dla większości urządzeń domowych zgodnych z **kategorią przepięciową II** (CAT II — gniazda i odbiorniki domowe wg PN-EN 60664-1).

## Kategorie przepięciowe (CAT)

Norma **PN-EN 60664-1** dzieli urządzenia ze względu na wytrzymałość izolacji:

| Kategoria | Lokalizacja | Wytrzymałość udarowa | Przykład |
|---|---|---|---|
| **CAT I** | obwody bezpieczne, SELV | 1,5 kV | elektronika sygnałowa |
| **CAT II** | urządzenia domowe podłączone do gniazd | **2,5 kV** | TV, AGD, oświetlenie |
| **CAT III** | obwody stałe, rozdzielnice | **4 kV** | wyłączniki, gniazda za rozdzielnicą |
| **CAT IV** | zasilanie z sieci, złącze ZK | **6 kV** | liczniki energii, SPD typ 1 |

Każda granica kategorii **wymaga ogranicznika** — SPD typ 1 między CAT IV i CAT III, SPD typ 2 między CAT III i CAT II, SPD typ 3 dla wrażliwych CAT I.

## Co dalej

➡ [SPD — typy 1, 2, 3](10-02-spd-typy.md)
