# Moduły komunikacji GSM, IP, dual-path

> Tory transmisji alarmów do stacji monitorowania (SMA) i powiadomienia użytkownika. Redundancja torów jest wymogiem normy w klasach Grade 2+.

## Po co dodatkowy tor — modem GSM/IP

Sama centrala alarmowa zamknięta w obudowie wewnątrz obiektu jest niewidoczna dla świata zewnętrznego — bez modemu nie wyśle alarmu do agencji ochrony, nie powiadomi właściciela SMS-em / push-em, nie zaloguje zdarzenia na serwerze producenta.

Klasyczne tory:

- **PSTN (linia telefoniczna)** — dziś już praktycznie wymarłe (likwidacja sieci miedzianej Orange w 2024–2026), z reguły niezalecane jako jedyny tor
- **GSM 2G/3G/4G LTE** — moduł z slotem SIM, transmisja SMS lub pakietowa (GPRS/LTE)
- **Ethernet/IP** — przewodowy LAN/Wi-Fi przez router internetowy
- **Dual-path** — IP jako tor podstawowy + GSM jako backup (lub odwrotnie)
- **NB-IoT / LTE-M** — nowsze, energooszczędne pasma IoT operatorów GSM

## Tory GSM — moduły dla central

### Satel — rodzina GSM-X / GSM-LT / SHX

| Model | Pasmo | Funkcje | Cena |
|---|---|---|---|
| **GSM-X** | 2G/3G/4G LTE | uniwersalny, dwa SIM, ethernet add-on, Contact ID/SIA | 700 PLN |
| **GSM-LT-2** | 2G | podstawowy, SMS i CLIP, do starszych central | 250 PLN |
| **GSM-4D** | 2G | 4 wejścia + 4 wyjścia, autonomiczny power-station | 400 PLN |
| **SHX-21** | LTE Cat-M1 | nowoczesny, niska transmisja, do Integra | 800 PLN |

### DSC — TL/GS/3G/LE

| Model | Pasmo | Funkcje |
|---|---|---|
| **GS3125-PL** | 3G/4G | do PowerSeries Neo, AlarmNet, SIA DC-09 |
| **LE9080-PL** | LTE 4G | nowsza generacja, transmisja PowerNET |
| **3G2080** | 3G | standardowy, monitoring AlarmNet |

### Jablotron, Risco

| Model | Pasmo | Cechy |
|---|---|---|
| Jablotron JA-194Y | LTE | do JA-100+, MyJABLOTRON cloud |
| Risco LightSYS GSM/3G | 3G | iRISCO app, dual-path z LAN |

## Tory IP — moduły ethernet

Modemy IP komunikują się z SMA poprzez serwer producenta lub bezpośrednio (SIA over IP).

### Satel ETHM-1 Plus

- Ethernet 10/100 Mbps, RJ45
- obsługa Integra od INT-24 do INT-256
- protokoły: SATEL (proprietarny), Contact ID over IP, SIA DC-09
- integracja z GUARDX, INTEGRA Control, INT-GSM
- cena: 350 PLN

### DSC TL280-PL / TL280R

- Ethernet, integracja z PowerSeries Neo / HS2128
- współpraca z AlarmNet i ConnectAlarm app
- cena: 450 PLN

### Inne moduły IP

| Model | Centrala | Cena |
|---|---|---|
| Jablotron JA-191Y | JA-100+ | 400 PLN |
| Risco IP Module | LightSYS Plus | 500 PLN |
| Pyronix DIGI-LAN | Enforcer, Matrix | 350 PLN |

## Dual-path — tor pierwotny + backup

Wymóg Grade 3 (PN-EN 50136-1) — system musi mieć **dwa niezależne tory transmisji**. Jeśli jeden zawiedzie (np. cięcie kabla, awaria modemu), drugi przejmuje rolę. Centrale wysyłają na oba lub przełączają fallback.

| Konfiguracja | Tor 1 | Tor 2 | Klasa zgodności |
|---|---|---|---|
| **IP + GSM** | Ethernet (broadband) | 4G LTE SIM | Grade 2/3, najpopularniejsza |
| **GSM dual-SIM** | SIM operatora A | SIM operatora B (np. T-Mobile + Plus) | Grade 2 (jeden tor, ale dwie sieci) |
| **IP + PSTN** | Ethernet | linia analogowa | przestarzałe |
| **2× IP** | LAN przewodowy | LTE backup | nowoczesne, popularne w korporacjach |

### Test poll — utrzymanie żywego łącza

System okresowo wysyła komunikat **„żyję"** (test poll, heartbeat) do SMA. Częstotliwość zależy od klasy:

- **Grade 1** — test 1× / 24 h
- **Grade 2** — test 1× / 25 min (single path) lub 1× / 3 h (dual path)
- **Grade 3** — test 1× / 90 s (jeden tor) lub 1× / 25 min (dual)
- **Grade 4** — test 1× / 10 s (banki, infrastruktura krytyczna)

Brak ramki test poll w okienku czasowym = SMA generuje „brak komunikacji" — patrol jedzie sprawdzić obiekt nawet bez „prawdziwego" alarmu.

## Protokoły transmisji

### Contact ID (DTMF) — klasyk PSTN

Format opracowany przez Ademco. Centrala wysyła „tony telefoniczne" DTMF kodujące zdarzenie:

```
SSSS QXYZ CC#
SSSS — numer abonenta (4 cyfry)
Q    — kwalifikator (1=nowy alarm, 3=restore)
XYZ  — kod zdarzenia (130=Burglary, 110=Fire, 120=Panic, 301=AC Loss, 302=Low Battery)
CC   — strefa lub user
#    — separator
```

Przykład: `1234 1130 05#` = abonent 1234, nowy alarm Burglary w strefie 05.

### SIA DC-09 / DC-05 — standard nowoczesny

Format ASCII over IP/GSM, z szyfrowaniem AES-128 i podpisem cyfrowym. Zalecany dla Grade 2+. Obsługiwany przez wszystkie nowsze centrale i SMA.

```
"SIA-DCS"0001L0#1234[#1234|Nri1BA01]_22:45:30,03-15-2026
        ↑    ↑   ↑     ↑   ↑       ↑
        seq  L   abon  receiver event timestamp
```

### SMS — backup dla użytkownika

Niezalecany jako jedyny tor do SMA (brak potwierdzeń, opóźnienia operatorskie). Dobrze działa jako **powiadomienie właściciela** równolegle do transmisji do agencji.

Polski operator SMS A2P (Application-to-Person) ma opóźnienia 5–60 s, w godzinach szczytu nawet kilka minut. Push do aplikacji jest szybszy i tańszy.

### MQTT / push — nowoczesne dla smart home

Coraz więcej central wspiera natywnie MQTT broker (Mosquitto, EMQX) lub push do aplikacji producenta (Integra Control, MyJABLOTRON, ConnectAlarm). Dla integracji z Home Assistant / smart home — niezastąpione.

## Wybór operatora i karty SIM

| Czynnik | Rekomendacja |
|---|---|
| Pasmo / pokrycie | sprawdź lokalne zasięg 4G LTE (mapy operatorów) |
| Abonament M2M | dedykowana taryfa: Orange Things, Plus M2M (10–25 PLN/mc, 1 GB) |
| PIN | wyłącz w SIM (centrala nie wpisze PIN) |
| SMS-y | upewnij się, że pakiet zawiera 100+ SMS/mc |
| Dual-SIM | dwóch różnych operatorów (np. T-Mobile + Plus) — odporność na awarię BTS |
| APN | poprawnie skonfigurowany w centrali (internet, m2m.plus, lte-m.orange.pl) |

## Praktyczne komendy SMS (Satel GSM-X)

```
STATUS#1234         — odczyt stanu obiektu
ARM#1234            — uzbrojenie
DISARM#1234         — rozbrojenie
USTAW STREFA 2#1234 — uzbrojenie strefy 2
WYJ 5#1234          — aktywacja wyjścia 5 (np. roleta, brama)
TEMP#1234           — odczyt temperatury
```

## Bezpieczeństwo transmisji

Atak na tor transmisji = klasyczny GSM jammer (zagłuszacz pasma 900/1800 MHz, do kupienia na chińskich portalach za 200–500 PLN). Dlatego **tor radiowy nie wystarczy** w obiektach o wyższej klasie. Dual-path IP+GSM lub LAN+LTE jest minimum dla Grade 3.

- Stosuj **szyfrowanie AES** (SIA DC-09 obsługuje natywnie)
- Wyłącz **SMS commands** jeśli nie używasz — ograniczasz wektor ataku
- Centrala powinna sygnalizować **jammer detection** (utrata sygnału przez >30 s)
- Tor IP — zalecane **VPN** do SMA lub serwera producenta

## Co dalej

➡ [Monitoring agencji ochrony](08-03-monitoring-agencji.md)
