# Bilans energetyczny off-grid

Projekt systemu off-grid zaczyna się od liczb, nie od katalogu sprzętu. Zła ocena zużycia kończy się systemem, który zimą gaśnie. Poniżej pięć kroków doprowadzających do doboru PV, magazynu i agregatu.

## Krok 1 — audyt zużycia energii

Wypisujemy każdy odbiornik, jego moc i czas pracy na dobę. Energia dobowa odbiornika:

```
E = P · t        [Wh/dobę]
```

gdzie P — moc [W], t — czas pracy na dobę [h].

Przykładowy bilans małego domku letniskowego:

| Odbiornik | Moc [W] | Czas [h/dobę] | Energia [Wh/dobę] |
|---|---|---|---|
| Oświetlenie LED | 60 | 5 | 300 |
| Lodówka (cykl pracy ~33%) | 150 | 8 | 1200 |
| Pompa wody (hydrofor) | 600 | 0,5 | 300 |
| Telewizor | 80 | 4 | 320 |
| Laptop | 60 | 4 | 240 |
| Router + sprzęt sieciowy | 15 | 24 | 360 |
| Drobne (ładowarki, RTV stand-by) | — | — | 280 |
| **Suma dobowa** | | | **≈ 3000 Wh = 3 kWh** |

W praktyce dla domku off-grid wychodzi typowo **3–6 kWh/dobę**. Lodówka liczona jest po cyklu pracy (sprężarka nie chodzi cały czas) — podaje się czas efektywnej pracy, nie czas wpięcia do gniazda.

> **Wskazówka.** Do sumy doliczamy zapas 15–20 % na straty inwertera, regulatora i samorozładowanie magazynu, a także na odbiorniki pominięte w audycie.

## Krok 2 — rezerwa na dni bez słońca (autonomia)

Off-grid musi przetrwać serię pochmurnych dni bez doładowania z PV. Przyjmuje się **autonomię 2–3 dni** — magazyn ma pokryć zużycie przez tyle dni bez produkcji.

```
Autonomia A — liczba dni pracy z samego magazynu (typowo 2–3)
```

Im większa autonomia, tym większy (i droższy) magazyn. Zamiast pompować magazyn w nieskończoność, dla dni bez słońca przewiduje się agregat (krok 5).

## Krok 3 — dobór mocy PV

Moc paneli dobiera się tak, aby w sezonie produkcja pokryła zużycie z zapasem na ładowanie magazynu. Uproszczony wzór:

```
P_PV = E_dobowe / (Hsr · η)

E_dobowe — zużycie dobowe [kWh]
Hsr      — uśrednione nasłonecznienie [h pełnego słońca / dobę]
η        — sprawność systemu (PV + regulator + straty) ≈ 0,7
```

Kluczowy problem: **sezonowość produkcji w Polsce**.

| Miesiąc | Względna produkcja PV |
|---|---|
| Czerwiec–lipiec | 100 % (odniesienie) |
| Marzec / wrzesień | 50–60 % |
| Październik / luty | 25–35 % |
| **Grudzień** | **10–15 %** |

W grudniu instalacja PL produkuje tylko ok. 1/8 mocy letniej. Zwymiarowanie PV pod grudzień daje absurdalne przewymiarowanie (latem ogromne nadwyżki nie do wykorzystania). Dlatego off-grid PL projektuje się na sezon wiosna–jesień, a zimę zabezpiecza agregatem.

```
Przykład: E_dobowe = 3 kWh, sezon wiosenny Hsr ≈ 3 h
P_PV = 3 / (3 · 0,7) ≈ 1,4 kWp  → dobieramy 2 kWp z zapasem
Zimą ta sama instalacja da ledwie 0,3–0,5 kWh/dobę.
```

## Krok 4 — dobór pojemności magazynu

Magazyn musi pokryć zużycie przez założoną liczbę dni autonomii, z uwzględnieniem dopuszczalnej głębokości rozładowania (DoD — Depth of Discharge):

```
C_magazyn = (E_dobowe · A) / DoD

E_dobowe — zużycie dobowe [kWh]
A        — dni autonomii
DoD      — dopuszczalna głębokość rozładowania (LiFePO4 ≈ 0,8–0,9)
```

```
Przykład: E_dobowe = 3 kWh, A = 2 dni, DoD = 0,8 dla LiFePO4
C_magazyn = (3 · 2) / 0,8 = 7,5 kWh
W praktyce dobieramy 5–7,5 kWh zależnie od budżetu i obecności agregatu.
```

Dla ogniw kwasowo-ołowiowych DoD wynosi tylko 0,5 — magazyn musiałby być dwa razy większy, dlatego w nowych systemach stosuje się LiFePO4 (patrz sekcja 18).

## Krok 5 — agregat jako backup zimowy

Agregat prądotwórczy domyka bilans w okresie, gdy PV nie nadąża:

- doładowuje magazyn przez inwerter ładujący (inverter-charger),
- zasila bezpośrednio odbiorniki przy bardzo niskim stanie magazynu,
- pozwala uniknąć przewymiarowania PV i magazynu pod warunki grudniowe.

Moc agregatu dobiera się do mocy szczytowej odbiorników i prądu ładowania magazynu — typowo 2–3 kVA dla małego domku.

## Strategia: overdimensioning kontra agregat

W polskich warunkach pełna autonomia całoroczna z samego PV wymaga przewymiarowania mocy paneli o czynnik **×3–4** względem zapotrzebowania letniego — i tak generuje zimą deficyt. Dlatego standardem jest:

- PV i magazyn zwymiarowane na sezon wiosna–jesień,
- agregat jako uzupełnienie na grudzień–luty,
- świadome ograniczanie zużycia zimą.

> **Uwaga.** Najczęstszy błąd projektowy off-grid to zaniżony audyt zużycia. Realne zużycie po wprowadzeniu się jest zwykle wyższe od szacowanego — warto zostawić 20–30 % marginesu w magazynie i mocy PV.

## Co dalej

➡ [Dobór komponentów off-grid](17-03-komponenty-off-grid.md)
