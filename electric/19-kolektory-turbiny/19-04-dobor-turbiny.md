# Dobór turbiny wiatrowej — obliczenia

## Klucz: zasoby wiatru w lokalizacji

Najważniejszą liczbą przy doborze turbiny jest **średnia roczna prędkość wiatru [m/s]** na wysokości masztu. To ona — przez zależność sześcienną — decyduje o produkcji. Bez znajomości tej liczby dobór turbiny jest zgadywaniem.

Średnią prędkość wiatru można odczytać z map wietrzności lub zmierzyć anemometrem na docelowej wysokości przez kilka miesięcy.

## Mapa wietrzności Polski

| Region | Średni wiatr (10 m n.p.t.) | Ocena dla turbiny przydomowej |
|---|---|---|
| Wybrzeże Bałtyku | 4,5–6,0 m/s | dobry — turbina ma sens |
| Suwalszczyzna, Pojezierze | 4,0–5,0 m/s | dobry / przyzwoity |
| Polska północna i pas pojezierzy | 3,5–4,5 m/s | przeciętny |
| Centrum kraju (niziny) | 3,0–4,0 m/s | słaby — rzadko opłacalny |
| Doliny górskie, kotliny | 2,5–3,5 m/s | bardzo słaby |

> Większość kraju to tereny o słabym wietrze przy gruncie. To główny powód, dla którego turbiny przydomowe rzadko są w Polsce opłacalne (patrz tabela opłacalności na końcu).

## Wzór na moc wiatru

Moc, jaką turbina może odebrać ze strumienia wiatru:

```
P = 0,5 · ρ · A · v³ · Cp

P  — moc elektryczna [W]
ρ  — gęstość powietrza = 1,225 kg/m³ (na poziomie morza, 15 °C)
A  — powierzchnia zatoczona przez wirnik [m²]
v  — prędkość wiatru [m/s]
Cp — współczynnik wykorzystania energii wiatru
```

Powierzchnia wirnika o średnicy D:

```
A = π · (D/2)²
```

### Limit Betza i realny Cp

Teoria mówi, że żadna turbina nie odbierze więcej niż **59,3%** energii strumienia wiatru — to **limit Betza** (Cp max = 0,593). W praktyce, po uwzględnieniu strat aerodynamicznych, mechanicznych i generatora:

| Typ turbiny | Realny Cp |
|---|---|
| Limit teoretyczny (Betz) | 0,593 |
| Dobra turbina HAWT przydomowa | 0,35–0,45 |
| Turbina VAWT | 0,15–0,30 |
| Do obliczeń przyjmij | **0,30–0,40** |

## Przykład obliczeniowy

Turbina HAWT, średnica wirnika 3 m, wiatr 6 m/s, Cp = 0,35.

```
A  = π · (3/2)² = π · 2,25 ≈ 7 m²
v³ = 6³ = 216
ρ  = 1,225 kg/m³
Cp = 0,35

P = 0,5 · 1,225 · 7 · 216 · 0,35
P = 0,5 · 1,225 · 7 · 216 · 0,35 ≈ 324 W
```

Przy wietrze 6 m/s ta turbina daje około **324 W** — i to tylko w chwili, gdy wiatr faktycznie wieje 6 m/s.

> **Uwaga na moc znamionową.** Producent może oznaczyć tę samą turbinę jako „1 kW" — bo przy 11 m/s da rzeczywiście ~1 kW. Ale wiatr 11 m/s w typowej lokalizacji występuje rzadko. Liczy się produkcja przy wietrze, który WYSTĘPUJE, a nie przy znamionowym.

## Produkcja roczna

Turbina nie pracuje cały czas z mocą maksymalną. Roczną produkcję szacuje się przez **współczynnik wykorzystania mocy** (capacity factor):

```
E_rok = P_znamionowa · 8760 h · CF

8760 — liczba godzin w roku
CF   — współczynnik wykorzystania
```

| Jakość lokalizacji | Współczynnik wykorzystania CF |
|---|---|
| Słaby wiatr (centrum PL) | 5–10% |
| Przeciętny wiatr | 10–15% |
| Dobry wiatr (wybrzeże) | 15–25% |
| Bardzo dobry wiatr | 25–30% |

Przykład: turbina 1 kW na wybrzeżu, CF = 18%:

```
E_rok = 1 kW · 8760 h · 0,18 ≈ 1577 kWh/rok
```

Ta sama turbina w centrum Polski (CF = 8%) da tylko ~700 kWh/rok — ponad dwukrotnie mniej.

## Dobór masztu

- Maszt **minimum 10–12 m**, a w terenie z przeszkodami wyżej.
- Wirnik musi pracować ponad strefą turbulencji od budynków i drzew.
- Wyższy maszt to wyższy koszt i wymóg solidnego fundamentu oraz odciągów — ale przez zależność sześcienną często zwraca się lepiej niż większa turbina na niskim maszcie.

## Pozwolenia i zgłoszenia

- Małe turbiny na maszcie do określonej wysokości zwykle wymagają tylko **zgłoszenia** w urzędzie; wyższe konstrukcje — pozwolenia na budowę.
- Przepisy lokalne (plan zagospodarowania) mogą ograniczać wysokość masztu.
- Instalację przyłączaną do sieci trzeba zgłosić do operatora sieci (OSD), podobnie jak mikroinstalację PV.
- Należy uwzględnić hałas i odległość od granicy działki oraz sąsiadów.

## Tabela: prędkość wiatru a opłacalność

| Średni wiatr na maszcie | Ocena | Opłacalność turbiny przydomowej |
|---|---|---|
| poniżej 3,5 m/s | bardzo słaby | praktycznie nieopłacalna |
| 3,5–4,5 m/s | słaby / przeciętny | zwykle nieopłacalna, bardzo długi zwrot |
| 4,5–5,5 m/s | dobry | na granicy opłacalności, sens w off-grid |
| 5,5–7,0 m/s | bardzo dobry | turbina może się opłacać |
| powyżej 7,0 m/s | doskonały | turbina opłacalna (rzadkość w PL) |

> **Wniosek.** Zanim kupisz turbinę, zmierz lub rzetelnie oszacuj średni wiatr w swojej lokalizacji na wysokości masztu. Jeśli wynosi poniżej ~4,5 m/s, turbina niemal na pewno się nie zwróci — te same pieniądze włożone w PV dadzą wielokrotnie więcej energii.

## Co dalej

➡ [Integracja źródeł — systemy hybrydowe](19-05-integracja-hybryda.md)
