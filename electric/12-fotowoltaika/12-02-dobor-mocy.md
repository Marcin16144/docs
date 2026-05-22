# Dobór mocy instalacji PV

## Zacznij od zużycia

Punktem wyjścia jest **roczne zużycie energii elektrycznej** domu (z faktury — najlepiej za pełne 12 miesięcy).

| Typ gospodarstwa | Zużycie roczne |
|---|---|
| Mieszkanie 2 osoby, ogrz. centralne | 1500-2500 kWh |
| Mieszkanie 4 osoby, kuchnia elektr. | 2500-4000 kWh |
| Dom 100 m², 4 osoby, gaz | 3000-4500 kWh |
| Dom 150 m², 4 osoby, pompa ciepła | 6000-9000 kWh |
| Dom z pompą ciepła + EV | 9000-14 000 kWh |

## Reguła doboru mocy

Wartość pomocnicza:

```
1 kWp ≈ 950-1100 kWh/rok
1 kWp ≈ 2,5 panela 410 W
1 kWp ≈ 6,5 m² powierzchni dachu
```

**Bez magazynu** (autokonsumpcja ~25-35 %): warto pokryć 80-100 % zużycia.
**Z magazynem** (autokonsumpcja 60-80 %): warto pokryć 100-120 % zużycia.

## Tabela doboru

| Zużycie roczne | Moc PV | Liczba paneli 410 W | Powierzchnia |
|---|---|---|---|
| 2 000 kWh | 2 kWp | 5 | 13 m² |
| 3 000 kWh | 3 kWp | 8 | 20 m² |
| 4 000 kWh | 4 kWp | 10 | 26 m² |
| 5 000 kWh | 5 kWp | 13 | 33 m² |
| 6 000 kWh | 6 kWp | 15 | 39 m² |
| 8 000 kWh | 8 kWp | 20 | 52 m² |
| 10 000 kWh | 10 kWp | 25 | 65 m² |

Limit prosumencki: do **50 kWp** (powyżej — instalacja przemysłowa, koncesja URE).

## Kąt nachylenia i azymut

Optymalne ustawienie w Polsce:

- **kąt 30-35°** (lato preferuje 20°, zima 50° — kompromis 30-35°)
- **azymut S (0°)** — najlepiej
- **azymut E/W (±90°)** — strata 10-15 %, ale bardziej równomierna produkcja w ciągu dnia

W układzie **east-west** (panele na dwóch połaciach) produkcja jest bardziej spłaszczona — często **lepsza autokonsumpcja** niż przy ostrym piku południowym.

## Autokonsumpcja

**Autokonsumpcja** = % wyprodukowanej energii zużytej na bieżąco w domu.

| Konfiguracja | Autokonsumpcja typowa |
|---|---|
| PV bez magazynu, dom 8-17 (nikogo) | 20-25 % |
| PV bez magazynu, ktoś w domu | 25-35 % |
| PV bez magazynu + pompa ciepła + bojler sterowany | 35-45 % |
| PV + magazyn 5 kWh | 55-65 % |
| PV + magazyn 10 kWh | 70-80 % |

W systemie net-billing autokonsumpcja jest **kluczowa** — patrz [12-04 Net-billing](12-04-net-billing.md).

## Profil dobowy

Produkcja w letnim dniu w PL (5 kWp, S, 30°):

```
godz: 6  8  10 12 14 16 18 20
moc:  0  1  3  4  4  3  2  0  [kW]
```

Suma dzienna ~22 kWh w czerwcu, ~3 kWh w grudniu.

Roczna produkcja 5 kWp ≈ 5000 kWh. Rozkład miesięczny:

| Miesiąc | % produkcji rocznej |
|---|---|
| I | 2 % |
| II | 4 % |
| III | 8 % |
| IV | 12 % |
| V | 14 % |
| VI | 15 % |
| VII | 14 % |
| VIII | 13 % |
| IX | 9 % |
| X | 5 % |
| XI | 2 % |
| XII | 2 % |

**Wniosek:** od listopada do lutego PV daje 10-12 % produkcji rocznej — zimą nadal pobieramy energię z sieci.

## Praktyczna reguła

> Dom 5000 kWh/rok → **5-6 kWp** + magazyn 5-10 kWh = bilans roczny w okolicach zera + duża autokonsumpcja.

## Co dalej

➡ [Inwerter (falownik)](12-03-inwerter.md)
