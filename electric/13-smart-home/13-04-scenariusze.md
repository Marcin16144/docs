# Scenariusze i automatyzacje smart home

## Reguła 90/10

Doświadczenie pokazuje: **90 % praktycznych scenariuszy zajmuje 10 % czasu programisty**. Najpiękniejsze i najbardziej skomplikowane automatyzacje przeważnie są używane rzadko — najprostsze codziennie.

Skup się na codziennych, użytecznych scenariuszach. Dopiero potem dodawaj egzotykę.

## 1. „Wszystko wyłącz" przy wyjściu

Jeden przycisk przy drzwiach wejściowych:

- gasi wszystkie światła w domu
- wyłącza nieesencjalne gniazda (TV, audio, ładowarki w salonie/pokojach)
- pozostawia: lodówkę, router, alarm, oświetlenie zewnętrzne
- opcjonalnie: ustawia ogrzewanie na tryb nieobecności (-2 °C)

**Hardware:** przycisk Zigbee Aqara / IKEA / Shelly na ścianie + skrypt w HA.

## 2. Symulacja obecności

Tryb urlop / podczas pracy późno:

- losowe włączanie świateł w godzinach 18-23 (różne pomieszczenia, różne minuty)
- losowe TV (jeśli WiFi włącznik) na 30-90 min
- aktywacja tylko gdy: jesteś poza domem (geolokalizacja) + zapada zmrok

Skuteczna prewencja włamań — opinie potwierdzają.

## 3. Czujnik ruchu + zmierzch

Najprostsza, najbardziej satysfakcjonująca automatyzacja:

```
Trigger: czujnik ruchu w korytarzu = wykryty
Condition: 
  - słońce poniżej horyzontu (po zmierzchu)
  - obecność: ktoś w domu
Action:
  - włącz światło 30 %
  - po 3 minutach bez ruchu → wyłącz
```

W łazience: pełna jasność po 22:00 = nieprzyjemnie. **Adaptive Lighting** lub niższy procent + ciepła barwa.

## 4. Garaż — światło po otwarciu bramy

```
Trigger: brama garażu = otwarta
Condition: po zachodzie
Action:
  - włącz światło garażu na 100 %
  - delay 5 minut
  - wyłącz światło
```

Czujnik kontaktronowy + przekaźnik Shelly to wystarczy.

## 5. Termostat + okno otwarte

```
Trigger: czujnik kontaktronowy okna = otwarte
Action:
  - zapamiętaj poprzedni setpoint termostatu
  - ustaw termostat na 5 °C (off)
Po zamknięciu:
  - przywróć setpoint
```

Realne oszczędności w zimie — bez tego termostat grzeje na okno otwarte.

## 6. Pralka — powiadomienie po zakończeniu

Czujnik mocy (Shelly Plug / gniazdko Zigbee) na linii pralki:

```
Trigger: moc pralki była > 5 W w ciągu ostatnich 30 min
        → potem spadła < 2 W przez 5 min
Action:
  - push do telefonu: "Pralka skończyła pranie"
  - opcjonalnie: TTS do głośnika w salonie
```

Bardzo doceniana automatyzacja — pranie nie zostaje w bębnie.

## 7. Smoke detector → tryb alarmowy

```
Trigger: jakikolwiek czujnik dymu = ALARM
Action:
  - wszystkie światła = 100 %, biały zimny
  - odblokuj zamki (jeśli smart locks)
  - powiadomienie push, SMS, telefon
  - opcjonalnie: zapis 60 s z wszystkich kamer
  - syrena (jeśli zintegrowana)
```

Wszystkie światła na 100 % białe = łatwiej znaleźć drogę w dymie, dzieci się budzą.

## 8. Tryb urlop

Po aktywacji (np. z aplikacji HA / NFC tag przy wyjściu):

- ogrzewanie -2 °C
- bojler off
- symulacja obecności włączona
- powiadomienia o ruchu w domu → push
- wszystkie nieesencjalne gniazda off
- monitoring kamer aktywny

Przy powrocie (geofence ~2 km): rozgrzej dom, włącz bojler.

## 9. Pora snu

Przycisk lub komenda głosowa „dobranoc":

- wszystkie światła off (oprócz nocnego światła w korytarzu / WC, 5 %)
- TV off
- termostat: temperatura nocna -1 °C
- alarm uzbrojony w trybie „dom"
- powiadomienie: czy okno na parterze otwarte? czy garaż zamknięty?

## 10. Adaptive Lighting

Add-on `basnijholt/adaptive-lighting` w HA:

- rano: jasne, zimne (5500 K)
- po południu: neutralne (4000 K)
- wieczór: ciepłe (2700 K)
- noc: bardzo ciepłe + bardzo ciemne (2000 K, 10 %)

Działa automatycznie na wszystkich światłach RGB/CCT. Lepsze samopoczucie, lepszy sen.

## 11. EV — ładowanie z nadwyżki PV

Wallbox z Modbus/API + integracja w HA:

```
Trigger: nadwyżka PV > 3 kW przez 5 min
Action: rozpocznij ładowanie EV mocą = nadwyżka
Trigger: nadwyżka PV < 1 kW przez 5 min
Action: zatrzymaj ładowanie
```

W praktyce wykorzystuje się gotowca **EVCC** (open-source).

## 12. Powiadomienia warto-uważne

- temperatura w garażu < 0 °C (zmarznięte rury?)
- wilgotność w łazience > 80 % przez 2 h (problem z wentylacją)
- czujnik zalania w pralce / pod zmywarką = ALARM (zawór dopływu wody)
- napięcie sieci poza 207-253 V (potencjalna awaria)
- bateria czujnika < 20 %

## Strategie organizacji konfiguracji

W miarę dorastania instalacji warto:

- **Podzielić `automations.yaml` na pliki** per kategorii (lights, climate, security)
- **Używać `script` jako bloków** wielokrotnego użytku
- **`input_boolean`** dla trybów (tryb_urlop, tryb_noc, tryb_party)
- **Etykiety i tagi encji**
- **Wersjonowanie konfiguracji w Git** (HA ma Add-on z GitHub)

## Co dalej

➡ [Normy i przepisy — sekcja 14](../14-normy/index.html)
