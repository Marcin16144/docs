# Dobór instalacji kolektorów — obliczenia

Dobór sprowadza się do trzech liczb: ile energii potrzebujemy na CWU, jaką powierzchnię kolektora to wymaga i jak duży powinien być zasobnik.

## Zapotrzebowanie na ciepłą wodę

Przyjmuje się około **50 litrów ciepłej wody na osobę na dobę** (umiarkowane zużycie — prysznice, mycie). Wodę podgrzewamy z temperatury wodociągowej (~10 °C) do użytkowej (~50 °C), czyli o ΔT = 40 K.

## Wzór na energię podgrzewania

Energia potrzebna do podgrzania wody:

```
Q = m · c · ΔT

Q   — energia [kJ]
m   — masa wody [kg]   (1 litr wody ≈ 1 kg)
c   — ciepło właściwe wody = 4,19 kJ/(kg·K)
ΔT  — przyrost temperatury [K]
```

### Przykład — rodzina 4-osobowa

```
m  = 4 osoby × 50 l = 200 l = 200 kg
ΔT = 50 °C − 10 °C = 40 K
c  = 4,19 kJ/(kg·K)

Q = 200 · 4,19 · 40 = 33 520 kJ

Przeliczenie na kWh:  33 520 kJ / 3 600 = 9,3 kWh/dobę
```

Rodzina 4-osobowa potrzebuje więc około **9,3 kWh dziennie** na samo podgrzanie wody — to dobowe zapotrzebowanie, które ma pokryć instalacja solarna.

## Reguły doboru powierzchni kolektora

| Typ kolektora | Reguła praktyczna |
|---|---|
| Kolektor płaski | ~1–1,5 m² powierzchni absorbera / osobę |
| Kolektor próżniowy | ~1 rura próżniowa / 10–15 l zapotrzebowania CWU |

Dla rodziny 4-osobowej: około **4–6 m² kolektora płaskiego** albo **15–20 rur próżniowych**.

## Dobór zasobnika CWU

Zasobnik musi zmagazynować ciepło wyprodukowane w słoneczny dzień, by starczyło na wieczór i pochmurny dzień. Reguła:

```
pojemność zasobnika ≈ 80–100 l / osobę
```

Dla 4 osób: zasobnik **300–400 litrów**. Zbyt mały zasobnik szybko się „przegrzewa" i marnuje nadwyżkę; zbyt duży trudniej rozgrzać do użytecznej temperatury.

## Tabela doboru wg liczby osób

| Liczba osób | Zapotrzebowanie CWU | Kolektory płaskie | Rury próżniowe | Zasobnik |
|---|---|---|---|---|
| 2 osoby | ~4,7 kWh/dobę | 2–3 m² | 8–12 | 200–250 l |
| 3 osoby | ~7,0 kWh/dobę | 3–4,5 m² | 12–16 | 250–300 l |
| 4 osoby | ~9,3 kWh/dobę | 4–6 m² | 15–20 | 300–400 l |
| 5 osób | ~11,6 kWh/dobę | 5–7,5 m² | 20–25 | 400–500 l |
| 6 osób | ~14,0 kWh/dobę | 6–9 m² | 24–30 | 500–600 l |

## Ustawienie kolektorów

- **Kąt nachylenia 30–45°** — kompromis na całoroczną pracę. Bliżej 45° lepiej dla pracy zimowej.
- **Azymut — kierunek południowy (S)**. Odchylenie do ±30° na wschód/zachód powoduje niewielkie straty.
- Unikać zacienienia (drzewa, kominy, sąsiednie budynki) — cień obniża wydajność nieproporcjonalnie do swojej powierzchni.

## Pokrycie roczne zapotrzebowania CWU

Instalacja kolektorowa **nie pokrywa CWU w 100% przez cały rok** — to ważne, by mieć realne oczekiwania.

| Okres | Pokrycie CWU przez kolektory |
|---|---|
| Lato (czerwiec–sierpień) | ~100% — nadwyżki, ryzyko przegrzania |
| Wiosna / jesień | 40–70% |
| Zima (grudzień–luty) | 15–25% |
| **Średnio w roku** | **50–65%** |

Resztę pokrywa drugie źródło — kocioł, pompa ciepła lub grzałka. Kolektory są źródłem wspomagającym, nie jedynym.

## Sterownik i ochrona przed przegrzaniem

Latem, gdy zasobnik jest już w pełni nagrzany, a kolektor wciąż pochłania słońce, dochodzi do **stagnacji** — czynnik w kolektorze przestaje krążyć i mocno się nagrzewa (płaski kolektor potrafi osiągnąć 150–200 °C, próżniowy jeszcze więcej).

> **Ochrona przed przegrzaniem.** Stagnacja przyspiesza starzenie glikolu i obciąża instalację. Sposoby ochrony:
> - sterownik z funkcją chłodzenia nocnego (zrzut ciepła przez kolektor po zachodzie),
> - prawidłowo dobrane naczynie wzbiorcze przejmujące parę,
> - zrzut nadmiaru ciepła do dodatkowego odbiornika (np. wymiennik basenowy),
> - dobór wielkości instalacji tak, by nie była przewymiarowana względem letniego zużycia.

> **Nie przewymiarowuj instalacji.** Kuszące „więcej kolektorów = więcej ciepła" prowadzi latem do chronicznej stagnacji i szybkiego zużycia glikolu. Lepiej dobrać instalację na pokrycie ~60% w skali roku niż na 100% latem.

## Co dalej

➡ [Turbiny wiatrowe — zasada i typy](19-03-turbiny-zasada-typy.md)
