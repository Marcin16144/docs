# Plan instalacji (rzut)

Plan instalacji to rysunek architektoniczny rzutu kondygnacji z naniesionymi elementami elektrycznymi. Schemat ideowy mówi „**co** jest połączone z czym", rzut mówi „**gdzie** to fizycznie wisi".

## Co umieszczamy na rzucie

| Element | Symbol | Uwagi |
|---|---|---|
| Rozdzielnica | **R** lub prostokąt | z numerem (RG, RP1, RP2 dla podrozdzielnic) |
| Gniazdo 230 V | **○** (kółko z 2 kreskami) | dopisać wysokość, jeśli inna niż standard |
| Gniazdo specjalne (siła 400 V) | **○s** lub **○3F** | osobny symbol, opis odbiornika |
| Gniazdo IP44 (zewnętrzne / łazienka) | **○IP** | strefa narażona na wilgoć |
| Punkt świetlny (oprawa) | **X** lub kółko z X | typ oprawy w opisie |
| Łącznik 1-bieg. | linia z kółkiem | numer obwodu |
| Łącznik schodowy | dwa łączniki z opisem „s" | |
| Czujnik ruchu PIR | trójkąt z literą P | |
| Sygnalizator (dzwonek, alarm) | kółko z B / A | |
| Czujnik dymu / CO | koło z D / CO | |
| Gniazdo RJ45 / SAT / RTV | osobne symbole | infrastruktura niskoprądowa |

## Trasy przewodów

Linie ciągłe — przewody pod tynkiem. Konwencja:

- **Poziome** — wzdłuż ścian, równolegle do podłogi i sufitu
- **Pionowe** — od podłogi do gniazda lub od sufitu do oprawy
- **Po skosie nigdy** — uniemożliwia bezpieczne wiercenie ścian w przyszłości

### Strefy instalacyjne (wg PN-IEC 60364)

Aby kable były „przewidywalne" przy wierceniu:

| Strefa | Lokalizacja |
|---|---|
| Pozioma górna | 15 cm pod sufitem |
| Pozioma dolna | 15 cm nad podłogą |
| Pozioma środkowa | 100 cm nad podłogą (poziom gniazd 30 cm + biegnie do łączników) |
| Pionowa | 10 cm od ościeżnicy drzwi/okna |

Wszystko poza tymi strefami = ryzyko wierceniem trafić w przewód.

## Standardowe wysokości — opisy w legendzie

| Element | Wysokość od podłogi |
|---|---|
| Gniazdo standardowe | 30 cm |
| Gniazdo nad blatem kuchennym | **120-130 cm** (15 cm nad blatem) |
| Gniazdo nad biurkiem | 90-110 cm |
| Gniazdo TV / nad komodą | 80 cm |
| Łącznik światła | 110 cm (klamka — 105) |
| Łącznik łazienkowy (na zewnątrz) | 110 cm |
| Termostat | 150 cm |
| Domofon | 150 cm |
| Dzwonek (przycisk przy drzwiach) | 140 cm |
| Czujnik dymu (sufit) | 30 cm od najbliższej ściany, w środku pomieszczenia |
| Oprawa sufitowa | sufit |
| Kinkiet | 180-200 cm |
| Oprawa nad lustrem (łazienka) | 180-190 cm |

## Skala rysunku

- **1:50** — większe pomieszczenia, dom jednorodzinny — wygodna dla detali
- **1:100** — całe kondygnacje, duże domy — czyściej, ale gorsza precyzja

Drukowanie na A3 lub A2 — A4 z rzutem domu jest nieczytelne.

## Numeracja na rzucie

Przy każdym punkcie (gniazdo, oprawa) wpisujemy **numer obwodu**, z którego jest zasilany. Np.:

- `○ G3` — gniazdo na obwodzie G3
- `X L2` — oprawa na obwodzie oświetlenia L2

Dzięki temu rzut + schemat ideowy = pełna informacja: gdzie i z czego.

## Co powinno być w legendzie

Każdy plan instalacji musi mieć **legendę** w prawym dolnym rogu, zawierającą:

- każdy użyty symbol + jego znaczenie
- domyślne wysokości montażu
- domyślne przekroje przewodów (np. „obwody gniazd — 3×2,5 mm² YDYp")
- skalę
- autora, datę, numer arkusza

## Programy do rzutów

| Program | Charakter | Cena |
|---|---|---|
| **AutoCAD** + AutoCAD Electrical | branżowy standard | wysoka |
| **Revit** | BIM, dla większych projektów | wysoka |
| **ArchiCAD** + moduł MEP | architektoniczne | wysoka |
| **FluidSIM** | symulacje hydrauliczne i pneumatyczne (ma też elektrykę) | średnia |
| **LibreCAD** | klon AutoCAD 2D | 0 zł |
| **Inkscape** | wektorowy edytor — ręczne rzuty | 0 zł |
| **Sweet Home 3D** | architektoniczny dla amatorów | 0 zł |
| **QCAD** | tani LibreCAD-podobny | niska |

W praktyce **rzut architekta + dorysowane symbole w Inkscape** wystarczy dla domu jednorodzinnego. Wykonawca tak czy inaczej musi zinterpretować — żaden symbol nie powie mu, że ma uważać na rurę CO za ścianą.

## Przykładowy fragment opisu pokoju na rzucie

> Salon 22 m², na obwodzie G3 (B16, 3×2,5 mm²):
> - 6 gniazd (ściana N: 4 gniazda; ściana E: 1 podwójne)
> - 1 gniazdo TV/RTV/SAT (ściana E, h=80 cm)
> - 1 gniazdo IP44 na tarasie (przyłącze przez ścianę W)
>
> Oświetlenie na obwodzie L1 (B10, 3×1,5 mm²):
> - 1 oprawa sufitowa centralna (LED 30 W, 3000 lm, 3000 K)
> - 2 kinkiety (LED 6 W, każdy)
> - łączenie schodowe (2 łączniki — przy drzwiach + przy kanapie)

## Co dalej

➡ [Dokumentacja powykonawcza](07-06-dokumentacja.md)
