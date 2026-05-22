# Kolektory słoneczne — zasada działania i typy

## Kolektor termiczny to nie panel fotowoltaiczny

To najczęstsze nieporozumienie. **Kolektor słoneczny termiczny grzeje wodę — nie produkuje prądu.** Panel fotowoltaiczny (PV) zamienia światło na energię elektryczną; kolektor zamienia promieniowanie słoneczne na ciepło.

| Cecha | Kolektor termiczny | Panel PV |
|---|---|---|
| Produkt | ciepło (gorąca woda) | energia elektryczna |
| Sprawność konwersji | 50–80% | 18–22% |
| Zastosowanie | CWU, wspomaganie CO | dowolne odbiorniki, magazyn |
| Czynnik roboczy | glikol w obiegu zamkniętym | brak (elektronika) |
| Magazynowanie | zasobnik ciepłej wody | akumulator / sieć |

Kolektor ma wyższą sprawność, ale produkuje tylko ciepło. Panel PV jest uniwersalny — i to przesądza o trendzie rynkowym (patrz koniec strony).

## Zasada działania

Sekwencja przemian energii w kolektorze:

```
promieniowanie słoneczne
   ↓
absorber (czarna powłoka selektywna) pochłania promieniowanie
   ↓
ciepło przekazywane do czynnika (roztwór glikolu)
   ↓
pompa obiegowa tłoczy gorący glikol do zasobnika
   ↓
wężownica w zasobniku oddaje ciepło wodzie użytkowej
   ↓
ochłodzony glikol wraca do kolektora
```

**Absorber** to serce kolektora — metalowa płyta lub pasek pokryty powłoką selektywną (pochłania dużo promieniowania, mało wypromieniowuje z powrotem). Do absorbera przylutowane są rurki, w których płynie czynnik.

**Czynnik grzewczy** to wodny roztwór glikolu propylenowego — nie zamarza zimą (do około −30 °C) i ma podwyższoną temperaturę wrzenia. Krąży w obiegu zamkniętym, nigdy nie miesza się z wodą pitną.

## Typy kolektorów

### Kolektory płaskie

Płaska, oszklona skrzynia z absorberem. Tańsze, prostsze, popularne.

- Sprawność latem ~70%, dobre przy silnym, bezpośrednim słońcu.
- Zimą i przy świetle rozproszonym sprawność wyraźnie spada — duże straty ciepła przez szybę.
- Wytrzymałe mechanicznie, łatwe w montażu, niższa cena za m².

### Kolektory próżniowe (rurowe)

Zbudowane z rzędu szklanych rur próżniowych. Próżnia jest doskonałym izolatorem — minimalizuje straty ciepła.

- Najczęściej w technologii **heat-pipe**: w każdej rurze zamknięta jest niewielka ilość cieczy, która paruje pod wpływem ciepła i skrapla się w głowicy oddającej ciepło do kolektora zbiorczego.
- Lepiej radzą sobie zimą, rano, wieczorem i przy świetle rozproszonym (pochmurno).
- Droższe, bardziej wrażliwe na uszkodzenie szkła, wymagają odśnieżania (gładka rura słabo zsuwa śnieg).

| Kryterium | Płaskie | Próżniowe |
|---|---|---|
| Cena za m² | niższa | wyższa |
| Sprawność latem | dobra (~70%) | dobra |
| Sprawność zimą | słaba | lepsza |
| Światło rozproszone | słabo | dobrze |
| Odporność mechaniczna | wysoka | niższa |
| Samoczynne usuwanie śniegu | dobre | słabe |

## Elementy systemu kolektorowego

| Element | Funkcja |
|---|---|
| Kolektory | pochłaniają promieniowanie, podgrzewają glikol |
| Zasobnik CWU z wężownicą | magazynuje ciepło w wodzie użytkowej (zwykle 2 wężownice — solarna i z kotła) |
| Grupa pompowa | pompa obiegowa, zawory, manometr, odpowietrznik |
| Naczynie wzbiorcze | przejmuje rozszerzalność czynnika, chroni przed nadciśnieniem |
| Sterownik solarny | porównuje temperaturę kolektora i zasobnika, załącza pompę |
| Czynnik glikolowy | nośnik ciepła w obiegu zamkniętym |

Sterownik załącza pompę dopiero, gdy kolektor jest cieplejszy od zasobnika o zadaną różnicę (typowo 6–8 K) — inaczej pompowanie schładzałoby wodę.

## Zastosowanie

- **CWU (ciepła woda użytkowa)** — podstawowe i najsensowniejsze zastosowanie. Zapotrzebowanie na CWU jest w miarę stałe przez cały rok.
- **Wspomaganie CO (centralnego ogrzewania)** — możliwe, ale mało efektywne: zapotrzebowanie na ogrzewanie jest największe zimą, gdy słońca najmniej. Latem kolektor produkuje nadwyżkę, której nie ma jak wykorzystać.

## Kolektor termiczny czy PV plus pompa ciepła?

> **Trend rynkowy:** fotowoltaika coraz częściej wypiera kolektory termiczne. Zamiast instalacji solarnej do CWU coraz częściej montuje się panele PV i podgrzewa wodę grzałką sterowaną nadwyżkami albo pompą ciepła do CWU.

Dlaczego PV wygrywa:

- Energia z PV jest uniwersalna — zasila dowolne odbiorniki, nie tylko bojler.
- Latem nadwyżkę PV można skierować do bojlera grzałką lub do pompy ciepła; zimą do innych potrzeb.
- Jeden system PV obsługuje prąd i ciepło; kolektory robią tylko CWU.
- Spadek cen paneli PV sprawił, że koszt „kilowata ciepła" z PV bywa porównywalny.

Kolektor termiczny wciąż ma sens, gdy: dach jest mały i trzeba maksymalnej sprawności na m², jest duże i stałe zapotrzebowanie na CWU (rodzina wieloosobowa, pensjonat), a nie planuje się rozbudowy o magazyn energii.

## Co dalej

➡ [Dobór instalacji kolektorów — obliczenia](19-02-dobor-kolektorow.md)
