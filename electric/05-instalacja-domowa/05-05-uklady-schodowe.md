# Układy schodowe i krzyżowe

Sterowanie jedną lampą z **kilku miejsc** w pomieszczeniu (klatka schodowa, korytarz, sypialnia) — klasyczne zadanie elektryczne. Tradycyjne rozwiązanie używa łączników schodowych i krzyżowych.

## Łącznik schodowy — sterowanie z 2 miejsc

Łącznik **schodowy** (W6) ma 3 zaciski: 1 wspólny + 2 przełączane (A/B). Dwa łączniki schodowe + 1 lampa + 1 obwód = klasyczny układ.

### Schemat ideowy

```
   sieć L ────┬─── faza
              │
            ┌─┴─┐  schodowy 1
            │ × │  (1 wspólny → 2 wyj)
            └┬┬─┘
             ││
             ││  (2 przewody między łącznikami)
            ┌┴┴─┐  schodowy 2
            │ × │
            └─┬─┘
              │
              ▼
             ⊗   lampa
              │
   sieć N ────┴─── neutralny do lampy
```

**Zasada:** faza wchodzi do łącznika 1 (wspólny), wychodzi przez jeden z dwóch przewodów do łącznika 2, a stamtąd wspólny → lampa → N. Każdy łącznik niezależnie odwraca stan oświetlenia.

## Łącznik krzyżowy — sterowanie z 3+ miejsc

Łącznik **krzyżowy** (W7) ma 4 zaciski (A B C D) i działa jak przerzutnik między dwoma parami przewodów.

**Zasada:** wstawiamy 1 lub więcej krzyżowych **między** dwoma schodowymi.

- 2 punkty: 2 schodowe.
- 3 punkty: 2 schodowe + **1 krzyżowy** w środku.
- 4 punkty: 2 schodowe + **2 krzyżowe**.
- N punktów: 2 schodowe + (N-2) krzyżowych.

### Schemat dla 3 miejsc

```
   L ──● schodowy 1 ●═══● krzyżowy ●═══● schodowy 2 ●── ⊗ ──── N
        (W6)            (W7)            (W6)        lampa
        zacisk          4 zaciski        zacisk
        wspólny+2       (A,B → C,D)     wspólny+2
```

## Kolory żył w klasycznym układzie schodowym (kabel YDYp 4×1,5)

| Żyła | Funkcja |
|---|---|
| **Brązowa** | faza do łącznika 1 (wspólny) |
| **Czarna** | linia robocza A (między łącznikami) |
| **Szara** | linia robocza B (między łącznikami) |
| **Niebieska** | N (przewodzona prostą drogą do lampy) |
| **Żółto-zielona** | PE — przy oprawach klasy I |

> **Uwaga:** w układzie schodowym **nie przerywamy N** — zawsze prostą drogą do lampy.

## Wady tradycyjnego układu schodowego

- nieprzewidywalny stan łączników (czasem zaświeci „w górę", czasem „w dół" — denerwuje),
- trudna rozbudowa o kolejny punkt sterowania (wymóg krzyżowych),
- dużo żył w bruzdach (4-żyłowy kabel zamiast 3-żyłowego),
- nie da się sterować centralnie / smart-home bez przebudowy.

## Alternatywa: przekaźnik impulsowy (bistabilny)

Każdy punkt sterowania to **przycisk dzwonkowy** (chwilowe zwarcie). W rozdzielnicy modułowy **przekaźnik bistabilny** (np. F&F BIS-411, Finder 26.01, Eaton Z-S) zmienia stan przy każdym impulsie.

### Schemat

```
   L ───┬───── przekaźnik bistabilny ─── ⊗ ─── N
        │                K1
        │
   ┌────┼────┬────┬────┐
   │    │    │    │    │
   ●    ●    ●    ●    ●     ← przyciski (chwilowe)
  T1   T2   T3   T4   T5      podłączone równolegle do cewki
                               (między L a wejście cewki)
```

### Zalety

- **dowolna** liczba punktów sterowania (po prostu dokładasz przycisk równolegle do cewki),
- jednoznaczny stan łącznika (po cichu — łącznik nie pokazuje stanu, ale czuć kliknięcie),
- łatwa rozbudowa o smart-home (równolegle do cewki podłączamy wyjście Sonoff/Shelly),
- centralne wyłączanie („goodbye switch" przy drzwiach głównych — jeden impuls resetuje wszystkie bistabilne).

### Wady

- moduł w rozdzielnicy zajmuje 1–2 moduły,
- każda lampa potrzebuje pary kabli z rozdzielnicy do oprawy + osobnego sterowania,
- przy zaniku zasilania niektóre modele wracają do stanu „wył" (default), inne pamiętają — sprawdź specyfikację.

## Sterowanie czujnikiem ruchu

W korytarzach i klatkach schodowych: **czujnik ruchu PIR** zamiast łącznika. Parametry typowe — patrz [05-04](05-04-laczniki.md). Można łączyć z układem schodowym: jeden łącznik mechaniczny + jeden czujnik ruchu (połączone równolegle).

## Automaty schodowe (czas opóźnienia)

W klatkach schodowych wspólnych (bloki, kamienice) stosuje się **automat schodowy** modułowy w rozdzielnicy (Finder 14.01, Hager EMN001):

- przycisk włącza światło,
- po ustawionym czasie (1–10 minut) automat **sam wyłącza**,
- niektóre modele migają 30 s przed wyłączeniem (ostrzeżenie),
- wbudowana opcja „ciągły" (manualne włączenie na stałe, np. dla sprzątaczki).

Pojemność: typowo 16 A, wsadzane na szynę TH35, 1–2 moduły.

```
   schemat automatu schodowego:

   L ─── automat ─── ⊗ żarówki klatki ─── N
          ▲
          │
    ●─●─●─●  przyciski piętro 1, 2, 3, 4
```

## Co dalej

➡ [Łazienka — strefy 0/1/2/3](05-06-lazienka.md)
