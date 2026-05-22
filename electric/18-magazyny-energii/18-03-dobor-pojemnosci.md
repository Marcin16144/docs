# Dobór pojemności magazynu

Pojemność magazynu nie wynika z metrażu domu ani z mocy fotowoltaiki. Wynika z **celu**, jakiemu magazyn ma służyć. Inny rozmiar potrzebny jest do zwiększenia autokonsumpcji PV, inny do podtrzymania domu przy zaniku sieci, a jeszcze inny do gry na taryfach. Najpierw określ cel, potem licz.

## Cel determinuje pojemność

### a) Zwiększenie autokonsumpcji PV

Najczęstszy scenariusz. Magazyn gromadzi dzienną nadwyżkę produkcji PV i oddaje ją wieczorem oraz w nocy, gdy panele już nie pracują. Reguła praktyczna:

```
magazyn ≈ 1,0 – 1,5 × dobowa nadwyżka PV
```

Nadwyżka to ta część produkcji, która nie jest zużywana na bieżąco — głównie energia z południowych godzin, gdy dom mało konsumuje.

### b) Backup przy zaniku sieci

Magazyn zasila wydzielone obwody krytyczne (lodówka, oświetlenie, router, pompa CO, ewentualnie kocioł) przez założony czas podtrzymania.

```
C = (P_krytyczne × t_podtrzymania) / DoD
```

### c) Arbitraż taryfowy G12

W taryfie dwustrefowej magazyn ładuje się z sieci w nocy po cenie tańszej strefy, a rozładowuje w drogiej strefie dziennej. Pojemność dobiera się do energii zużywanej w drogiej strefie.

## Wzór ogólny

```
C = E_dobowe × dni_autonomii / (DoD × η)

C            — pojemność nominalna magazynu [kWh]
E_dobowe     — energia do pokrycia z magazynu na dobę [kWh]
dni_autonomii— liczba dób pracy bez doładowania (zwykle 1)
DoD          — dopuszczalna głębokość rozładowania (LFP ≈ 0,9–0,95)
η            — sprawność round-trip (≈ 0,92)
```

## Przykład 1 — autokonsumpcja

Dom zużywa 15 kWh na dobę. Instalacja PV produkuje latem ok. 20 kWh dziennie. Część produkcji jest konsumowana na bieżąco; nadwyżka popołudniowo-wieczorna do zmagazynowania to ok. 8 kWh.

```
E_dobowe = 8 kWh        (nadwyżka do zmagazynowania)
dni_autonomii = 1
DoD = 0,9
η   = 0,92

C = 8 × 1 / (0,9 × 0,92)
C = 8 / 0,828
C ≈ 9,7 kWh   →  magazyn 10 kWh
```

Magazyn 10 kWh LFP w pełni obsłuży dzienną nadwyżkę i odda ją wieczorem.

## Przykład 2 — backup

Wydzielone obwody krytyczne pobierają średnio 1,5 kW. Czas podtrzymania zakładany na 6 godzin.

```
P_krytyczne = 1,5 kW
t_podtrzymania = 6 h
E = 1,5 × 6 = 9 kWh
DoD = 0,9

C = 9 / 0,9 = 10 kWh   →  magazyn 10 kWh
```

> **Uwaga przy backupie.** Sprawdź też C-rate magazynu i tryb pracy inwertera. Magazyn musi udźwignąć szczytową moc obwodów krytycznych, a inwerter musi mieć funkcję pracy wyspowej (backup / EPS), inaczej przy zaniku sieci magazyn nie zasili domu.

## Zasada: nie przewymiarowywać

Większy magazyn to wyższy koszt, a magazyn, który rzadko bywa w pełni wykorzystany, to **zamrożone pieniądze**.

- Magazyn dobrany na letnią nadwyżkę zimą będzie wykorzystany w niewielkim stopniu — produkcja PV spada
- Każda kWh pojemności kosztuje 2,5–4 zł/Wh; nieużywane kWh nigdy się nie zwracają
- Lepiej dobrać magazyn do realnej, uśrednionej rocznie nadwyżki niż do szczytu z czerwca
- Wiele systemów pozwala rozbudować magazyn modułowo — bezpieczniej zacząć od mniejszego

## Tabela doboru wg zużycia

| Dobowe zużycie domu | Moc PV | Typowa nadwyżka do magazynu | Sugerowana pojemność |
|---|---|---|---|
| 6–8 kWh | 3–4 kWp | 3–5 kWh | 5 kWh |
| 10–14 kWh | 5–6 kWp | 6–9 kWh | 10 kWh |
| 15–20 kWh | 7–9 kWp | 9–13 kWh | 13–15 kWh |
| 20–30 kWh (pompa ciepła, EV) | 10–12 kWp | 13–18 kWh | 15–20 kWh |

Wartości orientacyjne — zawsze weryfikuj rzeczywistym profilem zużycia z licznika lub aplikacji inwertera.

## Co dalej

➡ [Topologie podłączenia i schematy](18-04-topologie-schematy.md)
