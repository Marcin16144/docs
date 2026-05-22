# Rodzaje przewodów

## System oznaczeń literowych

Każdy przewód ma znormalizowany kod literowy opisujący jego konstrukcję. Czytanie tych oznaczeń pozwala od razu wiedzieć, czy przewód nadaje się do danego zastosowania.

| Pozycja w kodzie | Co oznacza | Przykłady |
|---|---|---|
| **1. litera** | norma / system | **Y** — krajowy (PVC), **H** — harmonizowany europejski, **N** — kabel ziemny |
| **2. litera** | materiał izolacji | **D** — PVC zwykły, **G** — guma, **K** — kabel (powłoka PVC) |
| **3. litera** | typ żyły | **D** — drut sztywny (jednodrutowa), **L** — linka (wielodrutowa giętka) |
| **dopisek p** | przewód płaski | YDYp |
| **dopisek żo** | z żyłą ochronną żółto-zieloną | YDYżo |

## Najczęściej spotykane przewody

| Symbol | Pełna nazwa | Zastosowanie | U znamionowe | T max żyły |
|---|---|---|---|---|
| **YDY** | jednodrutowy, izolacja i powłoka PVC | instalacje podtynkowe, w bruździe, w rurkach | 450/750 V | 70 °C |
| **YDYp** | YDY płaski | instalacje podtynkowe pod tynkiem | 450/750 V | 70 °C |
| **YDYżo** | YDY z żyłą ochronną PE (żółto-zielona) | jak YDY, w obwodach z PE | 450/750 V | 70 °C |
| **YKY (YKYżo)** | kabel ziemny PVC | przyłącza, układanie w ziemi w rurze ochronnej | 0,6/1 kV | 70 °C |
| **NKT (NKBA, NYY)** | kabel ziemny opancerzony / wzmocniony | przyłącza w terenie, miejsca narażone mechanicznie | 0,6/1 kV | 70 °C |
| **OWY / OMY** | przewód oponowy (gumowy / polwinitowy) | przedłużacze, podłączenia ruchome, pralki | 300/500 V | 70 °C |
| **H07V-K (LgY)** | żyła linkowa, izolacja PVC, harmonizowany | montaż w rozdzielnicach, mostki, podłączenia aparatów | 450/750 V | 70 °C |
| **H05V-K** | jak wyżej, niższe napięcie | wewnętrzne mostki sprzętu | 300/500 V | 70 °C |
| **LIYCY** | giętki sterowniczy ekranowany | sterowanie, automatyka, sygnały analogowe | 250 V | 70 °C |
| **HDGs** | bezhalogenowy, ognioodporny | oświetlenie awaryjne, oddymianie (PH90, PH120) | 300/500 V | 90 °C |

## YDY — koń pociągowy polskiej instalacji

YDY 3×1,5 lub 3×2,5 to przewód, który widać w 90% mieszkań w Polsce. Konstrukcja:

```
[ żyła Cu jednodrutowa ] — [ izolacja PVC ] — [ wypełnienie ] — [ powłoka PVC ]
```

- **3×1,5 mm²** — do obwodów oświetleniowych (L, N, PE)
- **3×2,5 mm²** — do gniazd 1-fazowych (L, N, PE)
- **5×2,5 mm²** lub **5×4 mm²** — do obwodów 3-fazowych (L1, L2, L3, N, PE)

YDY jest sztywny (drut), co utrudnia montaż w ciasnych miejscach, ale doskonale trzyma się w zaciskach śrubowych i sprężynowych (WAGO).

## H07V-K (LgY) — linka do rozdzielnicy

H07V-K (krajowo zwany **LgY**) to żyła pojedyncza w izolacji PVC, wielodrutowa (linka). Stosowana do:

- mostkowania szyn w rozdzielnicy
- doprowadzeń do aparatów (jeśli przewód YDY jest za sztywny)
- przewodów ochronnych PE w rozdzielnicach (16-25 mm²)

Linkę przed włożeniem do zacisku śrubowego **należy zarobić tulejką** (końcówka tulejkowa), żeby żyły nie rozpierały się i nie tworzyły fałszywych zacisków.

## Kable ziemne (YKY, NKT)

Różnica między **przewodem** a **kablem**: kabel ma dodatkową powłokę zewnętrzną odporną na warunki zewnętrzne, wilgoć i uszkodzenia mechaniczne.

- **YKY** — najprostszy kabel ziemny, w rurze ochronnej w ziemi, na głębokości min. 70 cm pod żółtą folią ostrzegawczą
- **NKT / NYY-J** — z dodatkowym pancerzem stalowym, miejsca narażone na uszkodzenia (przejazdy)
- **YnKXS** — kable do energetyki (15 kV i wyżej)

## Przewody oponowe (OWY, OMY)

Stosowane wszędzie tam, gdzie kabel musi być **ruchomy i giętki**:

- przedłużacze (OWY 3×1,5)
- podłączenia pralek, kuchenek, narzędzi (OWY 3×2,5)
- klatka schodowa do dzwonka (OMY 3×1)

OWY ma powłokę gumową — odporną na zginanie i temperaturę. OMY ma powłokę PVC — tańszą, ale mniej giętką w niskich temperaturach.

## Przewody specjalne

| Typ | Cecha | Gdzie |
|---|---|---|
| **HDGs / NHXH FE180** | ognioodporne PH90 / PH120 | oświetlenie awaryjne, oddymianie, SAP |
| **LIYCY** | ekranowany sterowniczy | sygnały 4-20 mA, automatyka |
| **YTKSY** | telekomunikacyjny | domofony, dzwonki |
| **UTP / FTP kat. 5e/6** | sieciowy ekranowany | LAN, KNX |
| **YnTKSYekw** | telekomunikacyjny ekranowany przeciwwodny | przyłącza światłowodowe, alarmy |

## Co dalej

➡ [Kolory żył wg PN-EN 60446](03-02-kolory-zyl.md)
