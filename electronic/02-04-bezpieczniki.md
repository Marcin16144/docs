# 02-04: Bezpieczniki i zabezpieczenia

## Cel zabezpieczeń

Każdy obwód powinien być zabezpieczony przed:
- **Przeciążeniem prądowym** (zbyt duży prąd przez dłuższy czas)
- **Zwarciem** (gwałtowny prąd, awaria)
- **Przepięciem** (chwilowe wzrosty napięcia z sieci, ESD, indukcja)

Brak zabezpieczeń = ryzyko pożaru, porażenia, uszkodzenia urządzeń. W produktach komercyjnych są wymagane przez normy bezpieczeństwa.

## Bezpieczniki topikowe

### Zasada działania

Drucik o cienkim przekroju wewnątrz szklanej (lub ceramicznej) rurki. Gdy prąd przekroczy wartość znamionową na zbyt długo, drut się topi i przerywa obwód.

```
   wyprowadzenie ═══━━─drucik─━━═══ wyprowadzenie
                  szkło z napisem
```

### Parametry

**Prąd znamionowy (I_n)** — prąd, który bezpiecznik wytrzymuje **w nieskończoność**. NIE jest to prąd, który go zerwie. Bezpiecznik 1 A wytrzyma 1 A bezterminowo.

**Prąd zerwania** zwykle 1,5-2× I_n po określonym czasie.

**Charakterystyka czasowa:**

| Typ | Oznaczenie | Czas zadziałania przy 4·I_n |
|-----|-----------|----------------------------|
| FF | super szybki | < 0,001 s |
| F | szybki | < 0,01 s |
| M | średni | 0,01 – 0,1 s |
| T | zwłoczny | 0,1 – 1 s |
| TT | super zwłoczny | > 1 s |

- **F (Fast)** — do elektroniki, czułych układów, półprzewodników
- **T (Time-lag / Slow)** — do silników, transformatorów (wytrzymują rozruch)

**Napięcie znamionowe (U_n)** — maksymalne napięcie, przy którym bezpiecznik bezpiecznie przerwie zwarcie. Najczęściej 250 V dla domowych, 500 V dla przemysłowych. NIE wolno przekraczać.

**Zdolność zwarciowa (I_zw)** — maksymalny prąd zwarciowy, jaki bezpiecznik przerwie bez eksplozji. Typowo kilkaset A do 10 kA.

### Wymiary szklanych bezpieczników

| Oznaczenie | Wymiary |
|-----------|---------|
| 3AG | 6,3 × 32 mm |
| 5AG | 10 × 38 mm |
| 5×20 (Euro) | 5 × 20 mm |
| 2AG | 5 × 15 mm |
| Mikro (SMD) | różne |

### Oznaczenia na bezpieczniku

```
T 1A 250V    →  zwłoczny 1 A, 250 V
F 500mA      →  szybki 500 mA
```

## Bezpieczniki ceramiczne

Wnętrze wypełnione piaskiem kwarcowym. Gasi łuk, większa zdolność zwarciowa. Stosowane w sprzęcie wyższej klasy i w obwodach o wysokim prądzie zwarciowym (np. zasilacze SMPS).

## Bezpieczniki samochodowe

Standardy:
- **ATO/ATC (standard)** — kolory wg prądu (3A różowy, 5A pomarańczowy, 10A czerwony, 15A niebieski, 20A żółty, 30A zielony)
- **Mini** — mniejsze
- **Maxi** — duże prądy (do 100 A)

## Bezpieczniki polimerowe (PolyFuse, PTC)

**Element resetujący się sam.** Polimer ze sproszkowanym węglem. W spoczynku rezystancja niska. Gdy płynie zbyt duży prąd → ogrzewa się → polimer pęcznieje, rozsuwa cząstki węgla → rezystancja gwałtownie rośnie (kilka MΩ).

Po wyłączeniu i ostudzeniu → ostygnie i wraca do niskiej rezystancji.

### Zalety

- Reset automatyczny
- Trwałość (tysiące zadziałań)
- Niewielkie wymiary

### Wady

- Wolne (sekundy do reakcji)
- Niedokładne (próg zadziałania ma duży rozrzut)
- Nie nadaje się jako jedyne zabezpieczenie przeciwpożarowe

### Zastosowanie

USB (ochrona +5 V), porty audio, ładowarki, akumulatory.

## Wyłączniki nadprądowe (do tablic)

W instalacjach domowych:
- **Klasa B** — zadziałanie przy 3-5·I_n (oświetlenie, gniazdka)
- **Klasa C** — 5-10·I_n (silniki, większe odbiorniki)
- **Klasa D** — 10-20·I_n (transformatory, wysokie prądy rozruchowe)

Plus **różnicówka (RCD)** — wykrywa upływ prądu do ziemi (porażenie). Standardowo 30 mA, czas zadziałania < 30 ms.

## Warystory (MOV — Metal Oxide Varistor)

Element nieliniowy. **Rezystancja maleje gwałtownie powyżej napięcia progowego.**

### Zasada

Przy normalnym napięciu sieci varystor jest praktycznie izolatorem. Gdy nagłe przepięcie (uderzenie pioruna w pobliżu, łączenie indukcyjnego odbiornika), varystor staje się "zwarciem", odprowadza energię do ziemi.

### Charakterystyka

```
U_var = K · I^α

α — bardzo mała (0,02-0,05), więc napięcie prawie nie rośnie ze wzrostem prądu
```

### Typowe oznaczenia

Warystor S20K275:
- S = scheibe (krążek)
- 20 = średnica 20 mm
- K = tolerancja ±10%
- 275 = napięcie zadziałania AC RMS

### Zastosowanie

- Listwy przeciwprzepięciowe (z trzema MOV: L-N, L-PE, N-PE)
- Wejścia zasilaczy sieciowych
- Ochrona styków przekaźników
- Ochrona układów na płycie

### Ważne

MOV się **zużywa**! Każde zadziałanie skraca żywotność. Po dużym przepięciu trzeba wymienić.

Spalony MOV często ma czarny ślad lub przebicie — trzeba sprawdzać wizualnie po burzy.

## Diody supresyjne (TVS — Transient Voltage Suppressor)

Specjalne diody Zenera bardzo szybkie. Zadziałanie w nanosekundach. Pochłaniają impulsy ESD i piorunowe.

**TVS unidirectional** — w jednym kierunku (jak Zener).
**TVS bidirectional** — w obu (dwa Zenery anodami).

Stosowane: linie sygnałowe USB, RS-485, anteny, wejścia mikrokontrolerów. Małe (SMD), tanie.

## Gazoodporne (GDT — Gas Discharge Tubes)

Rurka szklana wypełniona gazem. Przy przepięciu gaz jonizuje się i przewodzi. Zdolność do bardzo dużych prądów (kA), ale wolne (μs).

Stosowane w ochronie linii telekomunikacyjnych, anten, linii zasilających.

## Bezpiecznik termiczny (Thermal cutoff)

Stop bimetaliczny lub łaźnia woskowa wewnątrz obudowy. Przerywa obwód gdy temperatura przekroczy wartość znamionową (typowo 70-200°C).

Stosowane: transformatory, silniki, grzałki. Nie do resetu (jednorazowy) lub z resetem (przycisk).

## Bezpieczniki SMD

### Mikrobezpieczniki

Typowe rozmiary 0603, 1206, 2410. Prąd do kilku A. Stosowane na PCB.

### "Zero-ohm jumper" jako bezpiecznik

Niektóre projekty używają rezystorów 0 Ω jako bezpieczników "topikowych" — przy zwarciu się spalają. Złe rozwiązanie z punktu widzenia bezpieczeństwa, ale używane.

## Kategorie pomiarowe (CAT)

W multimetrach i sprzęcie pomiarowym:

| Kategoria | Zastosowanie |
|-----------|--------------|
| CAT I | obwody niskonapięciowe niepodłączone do sieci |
| CAT II | gniazdka, odbiorniki domowe |
| CAT III | rozdzielnice w budynku |
| CAT IV | linie zasilające budynek, liczniki |

Bezpiecznik w multimetrze musi mieć odpowiednią kategorię (np. CAT III 600V). Tanie multimetry są CAT I — nie wkładaj sond do gniazdka.

## Praktyczne dobieranie bezpiecznika

### Krok 1: zmierz lub oszacuj prąd ustalony

```
I_typ = P_obc / U
```

### Krok 2: dodaj zapas 25-50%

```
I_bezp = I_typ · 1,25 (do 1,5)
```

### Krok 3: wybierz najbliższą wartość w górę

Wartości typowe: 0,1; 0,16; 0,2; 0,25; 0,315; 0,4; 0,5; 0,63; 0,8; 1; 1,25; 1,6; 2; 2,5; 3,15; 4; 5; 6,3; 8; 10 A.

### Krok 4: wybierz charakterystykę

- Silniki, transformatory → T (zwłoczny)
- Elektronika, półprzewodniki → F (szybki)

### Krok 5: napięcie

U_n musi być ≥ napięcia w obwodzie. Często 250 V wystarczy do sieci 230 V.

### Przykład

Zasilacz 12 V, 30 W:
```
I_typ = 30 / 12 = 2,5 A
I_bezp = 2,5 · 1,3 = 3,25 A
→ wybieramy 3,15 A T (zwłoczny — kondensator rozruchowy)
```

W obwodzie pierwotnym sieciowym tego samego zasilacza (sprawność 85%):
```
P_AC = 30 / 0,85 = 35,3 W
I_AC = 35,3 / 230 = 0,154 A
I_bezp ≈ 0,2 A T 250 V
```

## Co zrobić, gdy bezpiecznik się przepala

1. **Nie zwiększaj wartości!** To znaczy, że masz awarię.
2. **Nie zwieraj** ("naprawa" drutem) — ryzyko pożaru.
3. **Znajdź przyczynę**: zwarcie, uszkodzony element, przeciążenie.
4. **Wymień na ten sam typ** (I, U, charakterystyka).

## Częste błędy

1. **Niedobór zdolności zwarciowej** — bezpiecznik wybucha przy zwarciu zamiast bezpiecznie przerwać obwód.
2. **Szybki tam, gdzie powinien być zwłoczny** — bezpiecznik przepala się przy rozruchu transformatora.
3. **Wymiana T na F** — niby ten sam prąd, ale charakterystyka inna → fałszywe zadziałania.
4. **Bezpiecznik tylko w plusie zasilania DC** — przy zwarciu masy też potrzebny (lub dobre uziemienie).
5. **Bezpiecznik na linii N (zerowej)** w sieci AC — niedopuszczalne w nowoczesnych instalacjach.
