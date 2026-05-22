# Parametry magazynów energii

Karta katalogowa magazynu to gąszcz skrótów: kWh, DoD, SoC, C-rate, SoH. Bez ich rozumienia łatwo kupić urządzenie, które na papierze wygląda dobrze, a w praktyce oddaje mniej energii i krócej żyje, niż się spodziewano. Ten rozdział tłumaczy każdy parametr i pokazuje, jak je ze sobą wiązać.

## Pojemność nominalna a użytkowa

To dwie różne liczby i to właśnie tutaj rodzi się większość nieporozumień.

- **Pojemność nominalna** [kWh] — całkowita energia zmagazynowana w ogniwach, podawana w nazwie produktu
- **Pojemność użytkowa** [kWh] — energia, którą realnie można pobrać; iloczyn pojemności nominalnej i dopuszczalnego DoD

```
C_uzytkowa = C_nominalna × DoD
```

Magazyn LFP 10 kWh przy DoD 95% daje 9,5 kWh użytkowej energii. Magazyn ołowiowy 10 kWh przy DoD 50% — tylko 5 kWh. Przy zakupie zawsze porównuj **pojemność użytkową**, nie nominalną.

## DoD — głębokość rozładowania

DoD (Depth of Discharge) to procent pojemności nominalnej, jaki wolno wykorzystać w jednym cyklu, bez przyspieszonego zużycia ogniwa.

| Technologia | Typowe DoD |
|---|---|
| LiFePO4 / LFP | 90–100% |
| NMC | 80–90% |
| Ołowiowo-kwasowe | ~50% |

Im wyższe dopuszczalne DoD, tym mniej pojemności nominalnej trzeba kupić, by uzyskać daną energię użytkową — i tu LFP ma dużą przewagę.

## SoC — stan naładowania

SoC (State of Charge) to bieżący poziom naładowania, wyrażony w procentach pojemności. 100% — pełny magazyn, 0% — rozładowany do dolnej granicy ustawionej przez BMS. SoC widać w aplikacji monitorującej i to on steruje pracą inwertera (kiedy ładować, kiedy oddawać energię).

> **Nie myl DoD i SoC.** DoD to projektowy zakres pracy (parametr stały), SoC to chwilowy odczyt (zmienna). Magazyn rozładowany do SoC 10% przy zaprojektowanym DoD 90% wykorzystał właśnie cały swój zakres.

## Cykle życia

Cykl to jedno pełne naładowanie i rozładowanie. Producent podaje liczbę cykli **przy określonym DoD** — i to zastrzeżenie jest kluczowe, bo płytsze cykle zużywają ogniwo wolniej.

```
Przykład trwałości LFP:
6000 cykli @ DoD 80%, 1 cykl dziennie
6000 / 365 ≈ 16,4 lat pracy
```

Po wyczerpaniu deklarowanej liczby cykli magazyn nie przestaje działać — po prostu jego pojemność spada do wartości końcowej (np. 70–80% nominału, parametr SoH).

## C-rate — szybkość ładowania i rozładowania

C-rate określa, jak szybko magazyn można ładować lub rozładowywać, w odniesieniu do jego pojemności.

```
0,5C → pełny cykl w 2 godziny
1C   → pełny cykl w 1 godzinę
0,25C → pełny cykl w 4 godziny

Moc magazynu = pojemność × C-rate
```

Magazyn 10 kWh o dopuszczalnym 0,5C oddaje maksymalnie 5 kW mocy. Jeśli dom potrzebuje 7 kW szczytowo, sam magazyn nie udźwignie obciążenia — różnicę musi dopłacić sieć lub PV. C-rate to dlatego parametr równie ważny co pojemność.

## Napięcie magazynu

| Klasa | Napięcie | Charakterystyka |
|---|---|---|
| Niskonapięciowe (LV) | ~48 V DC | Typowe w domach, bezpieczne w obsłudze, duże prądy |
| Wysokonapięciowe (HV) | 100–500 V DC | Niższe prądy, cieńsze kable, częste w systemach DC-coupled |

Przy 48 V moc 5 kW oznacza prąd ponad 100 A — stąd grube kable magazynu. Systemy HV redukują prąd, ale wymagają większej ostrożności i odpowiednich zabezpieczeń.

## Sprawność round-trip

Sprawność round-trip (η) to stosunek energii oddanej do energii włożonej w pełnym cyklu ładowanie–rozładowanie. Straty powstają w ogniwach i w elektronice mocy.

```
LFP, magazyn domowy: η = 90–95%
Ołowiowe:            η = 75–85%
```

Z każdej zmagazynowanej kWh odzyskuje się więc 0,90–0,95 kWh. Straty round-trip trzeba uwzględnić przy doborze pojemności i w kalkulacji ekonomicznej.

## BMS — Battery Management System

BMS to elektroniczny układ nadzorujący ogniwa. **Najważniejszy element bezpieczeństwa magazynu.**

- **Balansowanie cel** — wyrównuje napięcia poszczególnych ogniw, by żadne nie było przeładowane ani głęboko rozładowane
- **Ochrona przed przeładowaniem** — odcina ładowanie po osiągnięciu górnego napięcia
- **Ochrona przed nadmiernym rozładowaniem** — odcina pobór przy dolnym progu
- **Ochrona zwarciowa i nadprądowa** — natychmiastowe odłączenie przy zwarciu
- **Nadzór temperatury** — blokuje ładowanie poza dopuszczalnym zakresem

> **OSTRZEŻENIE — ładowanie LFP poniżej 0 °C.** Ogniw LiFePO4 nie wolno ładować w temperaturze poniżej 0 °C. Powoduje to osadzanie metalicznego litu na anodzie (lithium plating), trwałą utratę pojemności i ryzyko zwarcia wewnętrznego. Sprawny BMS blokuje ładowanie w mrozie automatycznie — ale magazyn i tak należy montować w pomieszczeniu o dodatniej temperaturze. Rozładowanie poniżej 0 °C jest dozwolone, ładowanie nie.

## Gwarancja

Gwarancja magazynu nie jest podawana tylko w latach. Producent zwykle określa kilka warunków równolegle, a obowiązuje ten, który skończy się pierwszy.

- **Czas** — np. 10 lat kalendarzowych
- **Przepustowość energii** — łączna energia, jaką magazyn może przepuścić, np. 30 MWh
- **Liczba cykli** — np. 6000 cykli
- **Końcowe SoH** — gwarantowane minimum, np. zachowanie 70% pojemności nominalnej na koniec okresu

SoH (State of Health) to procent obecnej pojemności względem fabrycznej. Czytając gwarancję, sprawdź wszystkie cztery warunki, a nie tylko liczbę lat.

## Co dalej

➡ [Dobór pojemności magazynu — obliczenia](18-03-dobor-pojemnosci.md)
