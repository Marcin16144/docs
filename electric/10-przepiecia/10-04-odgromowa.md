# Instalacja odgromowa (LPS)

## Co to jest LPS

**LPS** (*Lightning Protection System*, instalacja odgromowa) to system mający:

- **przechwycić piorun** w wyznaczonym miejscu (zwody),
- **bezpiecznie odprowadzić** prąd do uziomu (przewody odprowadzające),
- **rozproszyć ładunek** w gruncie (uziom).

Pojęciowo LPS dzieli się na:

- **zewnętrzne LPS** (ELPS) — zwody + przewody + uziom,
- **wewnętrzne LPS** (ILPS) — wyrównanie potencjałów + SPD.

Norma odniesienia: **PN-EN 62305** (4 części):

- 62305-1 — zasady ogólne,
- 62305-2 — analiza ryzyka R,
- 62305-3 — ochrona obiektu (LPS zewnętrzne i wewnętrzne),
- 62305-4 — ochrona urządzeń elektrycznych (SPD).

## Klasy LPS

| Klasa | Skuteczność przechwytu | Iimp (maks. prąd pioruna do uziomu) | Zastosowanie |
|---|---|---|---|
| **LPS I** | 98% | 200 kA / 10 C | obiekty zagrożone wybuchem, paliwa, amunicja, szpitale |
| **LPS II** | 95% | 150 kA / 7,5 C | obiekty użyteczności publicznej, biurowce |
| **LPS III** | 88% | 100 kA / 5 C | **typowe budynki mieszkalne, biurowe** |
| **LPS IV** | 81% | 100 kA / 5 C | obiekty mniej istotne, magazyny |

Dla **domu jednorodzinnego** najczęściej dobierany jest **LPS III**.

## Kiedy LPS jest obowiązkowy

Polskie warunki techniczne (rozporządzenie WT) oraz norma PN-EN 62305-2 (analiza ryzyka R) wskazują na obowiązek LPS gdy:

- **budynek wolnostojący** w terenie otwartym (pola, łąki),
- **wysokość >25 m**,
- **dach pokryty materiałem łatwopalnym** (strzecha, drewno, gont bitumiczny),
- **obiekty z ludźmi** powyżej określonej liczebności,
- **obiekty zabytkowe** (nawet niskie),
- **stacje paliw, magazyny gazu, drewna**,
- **wynik analizy ryzyka R > Rt** (Rt = 10⁻⁵ /rok dla ludzi).

Dla zwykłego domu w zabudowie zwartej, niskiego (<10 m), z dachem z dachówki — LPS często **nie jest wymagany**, ale **zalecany** w terenach o gęstości wyładowań Ng > 2.

## Elementy LPS zewnętrznego

### 1. Zwody

Pierwsza linia obrony — element, w który piorun „chce" uderzyć.

**Rodzaje:**

- **zwody pionowe (iglice)** — pojedyncze pręty Cu lub stal, wysokość 0,3–1,5 m, np. dla komina, anteny, świetlika; metoda toczącej się kuli o promieniu r (r = 20 m dla LPS I, 30 m dla LPS II, 45 m dla LPS III),
- **zwody poziome (siatka na dachu)** — drut FeZn Ø 8 mm lub bednarka 30×4 mm tworzący siatkę o oczkach:
  - LPS I: 5×5 m,
  - LPS II: 10×10 m,
  - LPS III: **15×15 m**,
  - LPS IV: 20×20 m,
- **zwody naturalne** — metalowy dach (blachodachówka, blacha) o grubości ≥ 0,5 mm, jeśli zapewniona ciągłość elektryczna.

### 2. Przewody odprowadzające

Łączą zwody z uziomem.

| Parametr | Wymóg |
|---|---|
| Liczba | **min. 2** (równomiernie po obwodzie budynku) |
| Materiał | FeZn Ø 8 mm okrągły lub bednarka 30×4 mm |
| Trasa | po zewnętrznej ścianie, w prostej linii (najkrótsza droga) |
| Odstęp od okien, drzwi | ≥ 0,5 m |
| Mocowanie | uchwyty co 1 m, izolatorki dystansowe (PCV) jeśli ściana łatwopalna |
| Połączenia | spawane lub zaciski certyfikowane PN-EN 62561 |

**Odstępy między przewodami odprowadzającymi:**

- LPS I: 10 m,
- LPS II: 10 m,
- LPS III: **15 m**,
- LPS IV: 20 m.

### 3. Złącze kontrolne

Na każdym przewodzie odprowadzającym, ~1 m nad gruntem, **rozłączalne** złącze umożliwiające:

- pomiar Rz uziomu (odłączenie od instalacji budynku),
- konserwację bez wykopu.

Typowo: złącze krzyżowe FeZn 30×4 ze śrubą M10.

### 4. Uziom LPS

Najczęściej **uziom otokowy** (zob. 09-01) — bednarka FeZn 30×4 wokół budynku, lub uziom **fundamentowy**.

**Wymaganie Rz: ≤ 10 Ω** (dla każdej klasy LPS).

Powinien być **połączony z uziomem ochronnym** (instalacji elektrycznej) — wspólny uziom dla LPS i NN.

## Strefy LPZ a LPS

Z LPS związane są **strefy LPZ**:

- **LPZ 0A** — bezpośrednia ekspozycja (zwód, antena),
- **LPZ 0B** — pod ochroną LPS, ale na zewnątrz (ściana budynku pod zwodem),
- **LPZ 1** — wewnątrz budynku, za SPD T1,
- **LPZ 2**, **LPZ 3** — głębiej w instalacji.

Na każdej granicy LPZ wymagane są **SPD** (zob. 10-03).

## Odstępy izolacyjne s

Aby uniknąć **przeskoku iskrowego** z LPS do metalowych elementów instalacji wewnętrznej (rury, kable, konstrukcje), zachowuje się **odstęp izolacyjny s**:

```
s = ki · kc · kl / km   [m]
```

| Symbol | Znaczenie | Wartość typowa |
|---|---|---|
| **ki** | współczynnik klasy LPS | LPS III = 0,04 |
| **kc** | współczynnik podziału prądu | 0,33 (4 przewody odprowadzające) — 1,0 |
| **kl** | długość drogi od zwodu do najbliższego punktu uziemienia | [m] |
| **km** | współczynnik materiału | powietrze = 1, beton/cegła = 2 |

**Przykład.** LPS III, 4 przewody odprowadzające (kc=0,33), długość kl = 10 m, materiał powietrze (km=1):

```
s = 0,04 · 0,33 · 10 / 1 = 0,13 m = 13 cm
```

Dla domu jednorodzinnego s wypada zwykle **10–50 cm**.

Jeśli odstęp s nie da się zachować — łączymy element wprost z LPS (np. metalowy komin → bezpośrednie spawanie z zwodem).

## Materiały i komponenty

Norma PN-EN 62561 definiuje 4 grupy komponentów LPS:

| Część | Co zawiera |
|---|---|
| 62561-1 | wymagania dla łączników (zaciski, krzyżaki, śruby) |
| 62561-2 | przewody i zwody |
| 62561-3 | iskierniki separacyjne |
| 62561-4 | uchwyty przewodów |

Każdy komponent powinien mieć **certyfikat** producenta — bez tego LPS nie zostanie przyjęty.

**Typowe materiały i wymiary:**

| Element | Materiał i wymiar |
|---|---|
| Drut zwodu / odprowadzający | FeZn Ø 8 mm, Cu Ø 8 mm, AlMgSi Ø 10 mm |
| Bednarka | FeZn 30×4 mm, Cu 30×4 mm (rzadko) |
| Iglica | Cu pełna lub FeZn, 0,5–2 m |
| Uchwyt dachowy | PCV + zacisk metalowy |
| Zacisk krzyżowy | FeZn 30×4 / Ø 8, M10, ucho |
| Złącze kontrolne | krzyżowe rozkręcane, M10 |

## Pomiar i kontrola LPS

| Czynność | Częstość |
|---|---|
| Wzrokowy przegląd | co 1 rok |
| Pomiar Rz uziomu | co 5 lat (LPS III/IV), co 1 rok (LPS I/II) |
| Po każdej burzy z bezpośrednim uderzeniem | wzrokowo + pomiar |
| Po pracach budowlanych na dachu | pełna kontrola |

## Przykład: dom 10×12 m, LPS III

```
Klasa: LPS III (mieszkalny w terenie podmiejskim)
Dach: dachówka, dwuspadowy 9°, kalenica 8 m

Zwody:
  - siatka FeZn 8 mm, oczka 15×15 m (1 oczko na dach)
  - iglica 1 m na kominie
  - krawędzie dachu obwiedzione bednarką 30×4

Przewody odprowadzające:
  - 4 sztuki w narożnikach budynku
  - odstępy ~11 m (mniej niż 15 m ✓)
  - FeZn Ø 8 mm w izolatorkach co 1 m
  - złącze kontrolne 1 m nad gruntem

Uziom:
  - otokowy FeZn 30×4 mm, ~48 m obwodu, 1 m od ściany, głębokość 0,8 m
  - Rz = 7,2 Ω ✓ (<10 Ω dla LPS)

SPD:
  - T1+T2 w rozdzielnicy głównej (Dehn DSH M TT 255)
  - T3 przy stanowisku PC i TV

Odstęp s (do rur metalowych w pobliżu rynny):
  s = 0,04 · 0,33 · 6 / 1 = 0,08 m → 8 cm wystarczy
```

## Co dalej

➡ [Sekcja 11 — Pomiary i odbiory](../11-pomiary/index.html)
