# 07-02: Oscyloskop

## Czym jest oscyloskop

Przyrząd wyświetlający przebieg napięcia w czasie. Pokazuje **kształt sygnału** — nie tylko wartość. To okno na żywą elektronikę.

Multimetr powie ci "5 V DC", oscyloskop dodatkowo pokaże:
- Czy to czysty DC, czy z tętnieniami?
- Jak szybko narasta?
- Jaki kształt ma sygnał?
- Czy są spike'i, zniekształcenia?

## Typy oscyloskopów

### Analogowy (CRT)

Z lampą obrazową. Sygnał wprost odchyla wiązkę elektronów. Klasyka XX wieku.

- **+ Bezpośredni obraz** sygnału (zero opóźnień)
- **+ Bardzo szeroki dynamik**
- **− Brak pomiarów cyfrowych**
- **− Wymiary i waga**
- **− Trudna kalibracja**

### Cyfrowy (DSO — Digital Storage Oscilloscope)

Sygnał próbkowany ADC, wyświetlany cyfrowo. Standard dziś.

- **+ Pomiary automatyczne** (RMS, F, T_rise, itd.)
- **+ Pamięć** — możesz przejrzeć historię
- **+ Triggery cyfrowe** (na sekwencje bitów, itd.)
- **+ FFT, dekoder protokołów**
- **− Sample rate i pamięć ograniczone**

### MSO (Mixed Signal)

Cyfrowy + kanały logiczne (8-16 cyfrowych wejść). Stosowane do debugowania MCU + komunikacji.

### Handheld

Przenośny, na baterie. Mniej parametrów, ale do serwisu super.

## Parametry oscyloskopu

### Pasmo (Bandwidth, BW)

Najwyższa częstotliwość sygnału, którą oscyloskop może wyświetlić z amplitudą zachowaną w 70% (-3 dB).

Wybór: pasmo **co najmniej 5× wyższe** niż najszybsza częstotliwość mierzona.

| Klasa | BW |
|-------|-----|
| Hobby | 50-100 MHz |
| Average pro | 200-500 MHz |
| Premium | 1-2 GHz |
| Ekstrema | 6-100 GHz |

### Sample rate

Próbki na sekundę (SPS, samples per second). Powinien być **co najmniej 5-10× pasmo** dla dobrej rekonstrukcji.

100 MHz BW → minimum 1 GSPS. Lepiej 2-5 GSPS.

### Liczba kanałów

- 2 — standard
- 4 — wygodniejsze (sygnał + sterowanie + odpowiedź + clock)
- 8 — rzadkie, drogie

### Pamięć (memory depth)

Ile próbek pamięta. Wpływa na to, jak długi przebieg możesz przeglądać z pełną prędkością.

100 Mpts = 100 milionów próbek. Standard dziś.

### Rozdzielczość ADC

- 8 bit — większość scope hobby (256 poziomów)
- 10-12 bit — premium (1024-4096 poziomów)

Dla pomiarów precyzyjnych — wybierz wyższą rozdzielczość.

## Sondy oscyloskopu

### Pasywna 1:1

Bezpośrednia. Wysoka pojemność (100-300 pF) → wpływa na obwód, ogranicza pasmo.

### Pasywna 10:1 (standardowa)

Tłumi sygnał 10×, ale **redukuje pojemność wejściową** (12-15 pF). Standardowa sonda.

- W oscyloskopie wybierz tryb 10× (lub manualnie dodaj 10× do wartości)
- Pasmo: kilkadziesiąt – kilkaset MHz

### Pasywna 100:1

Do wysokich napięć (do 2 kV).

### Aktywna (FET probe)

Wbudowany wzmacniacz FET. Pasmo gigaherców, niska pojemność (kilka pF). Drogie.

### Sonda różnicowa

Mierzy różnicę dwóch sygnałów. Niezbędna do napięć w obwodach pływających (sieciowych, falowniki).

### Sonda prądowa

Cęgi z czujnikiem Halla — pomiar prądu bez przerywania obwodu.

## Kalibracja sondy

Każda sonda 10:1 ma śrubę kompensacji. Procedura:

1. Podłącz sondę do gniazda kalibracji oscyloskopu (sygnał prostokątny, np. 1 kHz, 5 V).
2. Wyświetl przebieg.
3. Kręć śrubę aż prostokąt jest naprawdę prostokątem — bez "narastających" lub "opadających" zboczy.

Bez tego kompensacji pomiary HF są błędne.

## Podstawowa obsługa

### Pokrętła główne

- **Volts/Div** — czułość pionowa (1 mV/działkę do 10 V/działkę)
- **Time/Div** — skala czasu (1 ns/działkę do kilku s)
- **Position Y** — pozycja przebiegu pionowo
- **Position X** — pozycja triggera

### Triggering

Najważniejsza koncepcja. Bez wyzwalania obraz "płynie" — różne fragmenty sygnału w różnych miejscach.

Tryby:
- **Auto** — wyświetla coś nawet bez triggera (uczy się znajdować)
- **Normal** — czeka na trigger, bez niego nic nie pokazuje
- **Single** — jedno wyzwolenie, zatrzymuje obraz

Źródło triggera:
- Channel 1, 2, ...
- External (zewnętrzne wejście)
- Line (sieć 50/60 Hz)

Zbocze:
- Rising / Falling
- Level (próg napięcia)

Zaawansowane triggery:
- Pulse width
- Slope (sloped trigger)
- Pattern (sekwencja bitów)
- Protocol (UART, SPI, I2C, CAN)

### Tryby akwizycji

- **Sample** — pojedyncza próbka na piksel
- **Peak detect** — najwyższy/najniższy z grupy próbek
- **Average** — uśrednianie wielu wyświetleń (dla powtarzalnych sygnałów)
- **High res** — uśrednianie próbek z większą rozdzielczością

## Pomiary

### Manualne — kursorami

Dwie linie pionowe (czas) lub poziome (napięcie). Czytasz różnicę.

### Automatyczne

Oscyloskop oblicza:
- V_pp (peak-to-peak)
- V_max, V_min
- V_avg (średnia)
- V_RMS
- Frequency
- Period
- Rise time
- Fall time
- Duty cycle
- Overshoot

### Math

Suma/różnica kanałów, mnożenie (np. obliczanie mocy: U·I), pochodna, całka.

### FFT

Transformata Fouriera — przebieg w dziedzinie częstotliwości. Pokazuje harmoniczne, zakłócenia.

## Typowe zastosowania

### 1. Pomiar tętnień zasilacza

Sonda 10:1, AC coupling (odcięcie DC), 100 mV/dz, 5 ms/dz. Pokaże RMS i amplitudę pp tętnień.

### 2. Sygnał PWM

Pomiar duty cycle. Wybierz kanał, podłącz do wyjścia. Automatyczny pomiar "Duty +".

### 3. Komunikacja UART

Sonda na linii TX/RX, trigger na zbocze opadające (start bit), dekodowanie protokołu.

### 4. Czas reakcji systemu

Trigger na wejście (np. naciśnięcie przycisku), pomiar do zmiany wyjścia. T_rise.

### 5. Ringing / oscylacje

Po skoku sygnału obserwujesz ewentualne dzwonienie. To efekt indukcyjności i pojemności pasożytniczych.

### 6. SMPS na sondzie

Sonda na drenie MOSFETa. Widzisz przebieg przełączania. Iglice, oscylacje, kształt fali.

## Podłączanie sondy

### Masa sondy

**Krytyczne!** Krokodyl masy musi być **jak najbliżej** punktu pomiarowego. Długi przewód masy = pętla indukcyjna = błędne odczyty HF, ringing.

Dla pomiarów > 100 MHz używaj "spring tip" — krótka sprężynka zamiast krokodyla.

### Polaryzacja

Sonda w wejściu Channel 1 (zwykle żółty kanał). Masa (krokodyl) do masy układu.

### Uwaga na izolację

Masa oscyloskopu jest **uziemiona przez kabel zasilający**. Jeśli mierzysz obwód sieciowy bez izolacji (np. wprost na sieci 230 V) → zwarcie przez oscyloskop.

Rozwiązanie:
- Transformator izolacyjny w sieci urządzenia (NIE oscyloskopu — nigdy odłączać uziemienia oscyloskopu!)
- Sonda różnicowa

## Pułapki i triki

### Aliasing

Częstotliwość sygnału > 1/2 sample rate → na ekranie inna częstotliwość (efekt stroboskopowy). Zwiększ sample rate albo dodaj filtr.

### Niska pamięć

Krótkie przebiegi widać dobrze, długie tracą szczegóły. Wybierz między "głębią" a "rozdzielczością".

### Auto-range

Większość scope nie ma — trzeba ręcznie ustawić Volts/Div, Time/Div, trigger.

### Maska / pass-fail

Profesjonalne scope umieją testować przebieg w okolicach maski (czy mieści się w toleracji).

### Eye diagram

Akumulacja wielu przebiegów cyfrowych — pokazuje "oko" sygnału. Standardowo w komunikacji HF (Gb Ethernet, USB).

## Stara szkoła: scope analogowy

Klasyki:
- **Hameg HM303** — proste, 50 MHz, niezawodne
- **Tektronix 2200 / 2400** — przemysłowy standard
- **HP 545xx** — wszechstronne

Wciąż użyteczne do podstaw, choć w 2026 cyfrowe scope można kupić od 800 zł.

## Polecane scope cyfrowe (2026)

### Hobby (1500-3000 zł)

- **Rigol DS1102Z-E** — 100 MHz, 2 kanały, klasyk
- **Siglent SDS1104X-E** — 100 MHz, 4 kanały, świetny
- **Owon SDS1102** — taniej, 100 MHz

### Średnia liga (4000-8000 zł)

- **Rigol DHO924S** — 250 MHz, 4 kanały, 12-bit ADC
- **Siglent SDS2104X Plus** — 100 MHz upgrade do 200/350 MHz
- **PicoScope 2208B MSO** — USB scope, świetne software

### Premium

- **Tektronix MSO5** — 1 GHz+, profesjonalny
- **Keysight DSOX3104A** — wysokiej klasy
- **R&S RTM3000** — niemiecka jakość

## Najczęstsze błędy

1. **Długi krokodyl masy** — ringing na ekranie nie jest w sygnale.
2. **Sonda 10× ale ustawiony 1×** — wartość 10× za niska.
3. **Brak kalibracji sondy** — błędne pomiary HF.
4. **Pomiar bez triggera** — wyświetla bezsensowny szum.
5. **Pomyłka coupling AC/DC** — w AC odcięcie DC daje fałszywą "0 V baseline".
6. **Mierzenie pływającego obwodu z uziemionym scope** — zwarcie, awaria.
7. **Pomiar napięcia powyżej zakresu sondy** (np. 600V na sondzie 300V) — uszkodzenie sondy, ryzyko porażenia.
8. **Brak ochrony 10:1 sondy w obwodzie 1000 V** — krótkie zwarcie, awaria.

## Podsumowanie

Oscyloskop to:
- **Najpotężniejsze narzędzie** elektronika (po multimetrze)
- **Niezbędne** do debugowania sygnałów cyfrowych i analogowych
- **Inwestycja** — kupuj raz, używaj 10+ lat
- **Wymaga praktyki** — sam zakup nie wystarcza, trzeba ćwiczyć

Bez oscyloskopu można robić proste rzeczy. Z oscyloskopem widać, **co naprawdę się dzieje**.
