# Łączniki oświetlenia

Łącznik (potocznie „włącznik") to mechaniczny lub elektroniczny element zwierający/rozwierający obwód oświetleniowy. Po polsku „wyłącznik" to nadrzędna nazwa rodzajowa; w branży osprzętu mówimy **łącznik**.

## Typy łączników mechanicznych

| Typ | Polski symbol | Liczba zacisków | Zastosowanie |
|---|---|---|---|
| **Jednobiegunowy** | Σ1 (W1) | 2 (L wej, L wyj) | sterowanie 1 lampą z 1 miejsca |
| **Dwubiegunowy** | Σ2 (W2) | 4 | jednoczesne wyłączanie L i N (np. kotłownia) |
| **Świecznikowy** (dwugrupowy) | Σ5 (W5) | 3 (L wej, 2 wyj) | sterowanie 2 obwodami niezależnie |
| **Schodowy** | Σ6 (W6) | 3 | sterowanie z 2 miejsc |
| **Krzyżowy** | Σ7 (W7) | 4 | sterowanie z 3+ miejsc (w środku) |
| **Impulsowy** (dzwonkowy) | Σ1z | 2 (chwilowe zwarcie) | wyzwala przekaźnik bistabilny |

### Schematy zacisków

```
   jednobiegunowy:        świecznikowy:
       L─┐ ┌─L'              L─┐ ┌─L1
         X                     X
                               └─L2

   schodowy:              krzyżowy (środkowy):
       L─┐ ┌─A              A─┐ ┌─C
         X                    X X
         └─B                  B─┴─D
```

## Wysokość montażu

| Lokalizacja | Wysokość |
|---|---|
| **Standard** | **105–115 cm** od podłogi (środek puszki) |
| **Przy klamce drzwi** | na wysokości klamki (~105 cm) |
| **Pokój dziecka** | obniżona do 90 cm |
| **Garaż / warsztat** | 115–130 cm |

> Wysokość 105–115 cm to historyczna wysokość ramienia opuszczonego z lekko zgiętym łokciem — naturalne położenie ręki.

## Łącznik z kontrolką (podświetleniem)

LED w łączniku świeci, gdy **lampa jest wyłączona** — pomaga znaleźć łącznik po ciemku. Dwa warianty:

- **z N** (4 zaciski) — kontrolka między L a N, świeci niezależnie od stanu lampy;
- **bez N** (2 zaciski) — prąd kontrolki przepływa przez wyłączoną żarówkę, **nie działa** z większością LED (LED świeci słabo, pulsuje lub kontrolka nie zapala się).

## Ściemniacze (dimmery)

Regulują strumień świetlny przez modulację fazy (faza początek lub faza koniec). Dwa typy:

| Typ | Mechanizm | Z którymi LED |
|---|---|---|
| **Obrotowy** (potencjometr) | przycinanie fazy R/L (front-edge) | tylko LED z napisem **dimmable** |
| **Dotykowy / impulsowy** | trailing-edge, łagodniejsze | większość LED dimmable |
| **DALI / 0-10 V** | sygnał sterujący osobny | profesjonalne oprawy LED |

> **Nie każdy LED jest ściemnialny!** Sprawdź opakowanie — symbol z napisem „dimmable" lub piktogram trzykrotnie zmniejszającej się ikony. Niedimmowalne LED-y mrugają, brzęczą i mogą się przegrzać.

## Łącznik impulsowy + przekaźnik bistabilny

Zamiast bezpośredniego łącznika — **chwilowy impuls** (przycisk dzwonkowy) wyzwala **przekaźnik bistabilny** w rozdzielnicy (zmienia stan przy każdym impulsie).

**Zalety:**
- nieograniczona liczba punktów sterowania (bez schodowych/krzyżowych),
- możliwość rozbudowy o automatyzację (Wi-Fi, KNX),
- łatwe sterowanie centralne („wszystko-wył" przy wyjściu).

**Wady:** wymaga miejsca w rozdzielnicy (przekaźnik typu Finder 26.01 lub modułowy F&F BIS-411), bardziej skomplikowane okablowanie do rozdzielnicy zamiast lokalnie.

Patrz [05-05 Układy schodowe](05-05-uklady-schodowe.md).

## Czujniki ruchu (PIR)

Łączniki z **pasywnym czujnikiem podczerwieni** (PIR) automatycznie zapalają światło przy wykryciu ruchu. Typowe parametry:

| Parametr | Zakres |
|---|---|
| Zasięg | 6–12 m |
| Kąt detekcji | 110–180° |
| Czas opóźnienia | 5 s – 30 min (regulowane) |
| Próg zmierzchowy | 3–2000 lx |
| Moc obciążenia | typowo 600–1200 W żarówka / 200 W LED |

Stosowane w: przedpokojach, korytarzach, schodach, garażach, łazienkach (wentylator + światło).

## Łączniki z funkcją żaluzjową

Dwuklawiszowe sterowanie roletą/żaluzją (góra/dół) z elektrycznym zazębieniem (jednoczesne wciśnięcie obu — neutralnie). Wysokość: zwykle 120–140 cm (przy ościeżnicy okna).

## Symbole na schematach

Symbole graficzne wg PN-EN 60617:

```
   ⊗     żarówka
   ⊘     łącznik 1-biegunowy
   ⊘⊘    łącznik świecznikowy
   ⊕     łącznik schodowy
   ⊞     łącznik krzyżowy
   ☼     czujnik ruchu PIR
   ▭     puszka rozgałęźna
```

## Co dalej

➡ [Układy schodowe i krzyżowe](05-05-uklady-schodowe.md)
