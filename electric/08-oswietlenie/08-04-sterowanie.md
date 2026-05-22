# Sterowanie oświetleniem

Wyłącznik dwustanowy „on/off" to ledwie 10% możliwości. Nowoczesna instalacja domowa wykorzystuje ściemnianie, automatyzację, czujniki i sceny — z różnym stopniem skomplikowania.

## Klasyfikacja systemów sterowania

| System | Złożoność | Koszt | Zastosowanie |
|---|---|---|---|
| Łączniki klasyczne | bardzo niska | niska | każdy dom |
| Ściemniacz triakowy | niska | niska | salon, sypialnia |
| Przekaźnik impulsowy + przyciski | średnia | średnia | korytarze, schody, duże pokoje |
| Czujniki PIR / mikrofalowe | średnia | średnia-niska | korytarze, łazienki, garaż |
| 1-10 V analogowe | średnia | średnia | oświetlenie biurowe |
| **DALI** | wysoka | średnia-wysoka | biura, biblioteki, sklepy |
| **KNX** | bardzo wysoka | wysoka | dom premium, smart home |
| Wi-Fi / Zigbee (Tuya, Philips Hue) | niska | średnia | retrofit, lokatorzy |

## Łączniki klasyczne

Najprostsze przerywniki w przewodzie L:

- **1-biegunowy** — włącza/wyłącza pojedynczy obwód
- **schodowy (dwukierunkowy)** — sterowanie z dwóch miejsc
- **krzyżowy** — sterowanie z trzech i więcej miejsc (między dwoma schodowymi)
- **przycisk dzwonkowy (zwierny)** — chwilowy styk; do przekaźników impulsowych

## Ściemniacz triakowy

Tradycyjny ściemniacz oparty na triaku (półprzewodnik) — odcina część fazy sinusoidy zasilającej. Działa:

- doskonale z **żarówkami i halogenami** (obciążenie rezystancyjne)
- z **LED tylko oznaczonymi „dimmable"** (mają specjalny driver)
- minimum obciążenie zwykle **40 W** (poniżej tej wartości ściemniacz tańszy nie pracuje)

### Typy ściemniaczy

| Typ | Cięcie fazy | Z czym współpracuje |
|---|---|---|
| Triak (leading edge) | przedniego zbocza | żarówki, halogeny 230 V |
| Tranzystor (trailing edge) | tylnego zbocza | LED, halogeny niskonapięciowe z transformatorem elektronicznym |
| Uniwersalny | automatycznie | wszystko (sprawdza obciążenie) |

**Wybierz uniwersalny** — kosztuje 60-150 zł, działa z każdym typem żarówek, mniejsze ryzyko brzęczenia/migotania.

## Przekaźnik impulsowy

Jeden moduł D01 (np. Schneider iTL, Eaton Z-R230) w rozdzielnicy plus dowolna liczba przycisków zwiernych w pokoju.

Zalety:

- każdy przycisk zwierny załącza/wyłącza światło — można dorzucić nieskończenie wiele przycisków
- jeden moduł zamiast skomplikowanej sieci przewodów schodowych/krzyżowych
- centralne wyłączanie z jednego miejsca (np. przyciskiem przy wyjściu z domu)
- styk impulsowy → zerowy pobór prądu spoczynkowego

Wady:

- nieco droższy w starcie (moduł 80-150 zł + przyciski zamiast łączników)
- bez sygnalizacji stanu (nie wiadomo „on/off" patrząc na przycisk)

## DALI (Digital Addressable Lighting Interface)

Standard cyfrowej komunikacji z każdą oprawą indywidualnie — magistrala 2-żyłowa, do 64 opraw na linię, do 16 grup, 16 scen.

- każda oprawa ma swój adres
- możliwość zdalnej zmiany stanu, ściemniania, grup
- sterowniki montowane w rozdzielnicy + bramka do KNX / Modbus
- używany w biurach, hotelach, muzeach

W domu jednorodzinnym DALI bywa overkillem — chyba że właściciel projektuje pełne sceny w salonie z 20+ oprawami.

## 1-10 V (analogowe)

Starszy standard analogowy: oprawa LED ma 2 dodatkowe przewody sterujące. Napięcie 0 V = 0%, 10 V = 100%. Sterownik wytwarza to napięcie.

- prostsze niż DALI
- działa tylko na danej oprawie / grupie (brak adresowania)
- popularne w biurach średniej klasy

## KNX

Najbardziej rozbudowany system smart home dla budynków — magistrala typu bus z dziesiątkami modułów (ściemniacze, przekaźniki, czujniki, termostaty). Programowalny w środowisku ETS.

- jeden system steruje: oświetleniem, roletami, ogrzewaniem, klimatyzacją, alarmami, audio
- bardzo wysoki koszt początkowy (1000-3000 zł za pomieszczenie)
- dożywotnia żywotność (standard z 1990, kompatybilność wsteczna)

## Czujniki ruchu i obecności

### PIR (Pasywna podczerwień)

Wykrywa **różnicę temperatur** ruchomego obiektu. Klasyczny czujnik w korytarzu lub na zewnątrz.

- działa od 5 do 12 m zasięgu
- wadą: nie wykrywa siedzącego nieruchomego użytkownika
- zwykle „wyłącznik czasowy" — czas opóźnienia 10 s do 30 min

### Mikrofalowy / radarowy

Emituje fale mikrofalowe i odbiera odbite — reaguje na **każdy ruch**, nawet drobny.

- wykrywa obecność za szybą (przez drzwi)
- lepszy do toalet i pomieszczeń, gdzie użytkownik siedzi/pracuje nieruchomo
- droższy

### Ultradźwiękowy

Rzadziej spotykany — czuły, ale generuje hałas niemowląt/zwierząt.

### Zmierzchowy (fotokomórka, LDR)

Załącza światło, gdy ciemno (luksomierz wewnętrzny w czujniku). Do zewnętrznego oświetlenia, słupków ogrodowych, klatek schodowych w pochmurne dni.

### Czas (TM, time switch)

Włącza/wyłącza wg harmonogramu (np. 16:00-22:00 zimą, 18:30-23:30 latem). Mechaniczny (tarcza z zębami) lub elektroniczny (wyświetlacz LCD).

### Kombinacja sensors

W praktyce łączymy: **zmierzchowy + czas + PIR** = oświetlenie zewnętrzne tylko gdy ciemno, w godzinach aktywności i tylko gdy ktoś jest w pobliżu.

## Sceny oświetleniowe

W systemach inteligentnych (KNX, DALI, Hue) tworzymy „sceny" — zaprogramowane stany wszystkich opraw:

- **„Kino"** — salon ściemniony 20%, podświetlenie ekranu / nasze gabloty 30%, reszta 0%
- **„Kolacja"** — żyrandol 50%, kinkiety 70%, podświetlenie kuchni 0%
- **„Praca"** — sufitowe 100%, lampka biurkowa 100%, akcenty 0%
- **„Wyjście / noc"** — wszystko 0%, podświetlenie schodów 10%

Sceny przypisuje się do przycisków lub uruchamia z aplikacji.

## Praktyczne rady

1. **Łazienka**: czujnik mikrofalowy + ściemniacz na lustrze (max 100% rano, 30% w nocy).
2. **Korytarze**: PIR z opóźnieniem 60-90 s. Bez wyłącznika klasycznego (chyba że dwustopniowy: PIR + ręczny override).
3. **Salon**: ściemniacz uniwersalny + min. 2-3 obwody (sufit / strop / lampy stojące) → możliwość scen.
4. **Sypialnia**: ściemniacz + drugi łącznik przy łóżku (sterowanie centralne + lokalne).
5. **Pomieszczenia gospodarcze**: PIR (włącza się sam przy wejściu z workami z zakupami).
6. **Schody**: PIR + czujnik schodowy LED (każdy stopień podświetlony osobno).

## Co dalej

➡ [Oświetlenie zewnętrzne](08-05-zewnetrzne.md)
