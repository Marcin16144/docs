# Podstawy automatyki — jak to w ogóle działa

Zanim wybierzesz „na czym to zbudować", warto zrozumieć, że **każdy** system automatyki — od czujnika ruchu zapalającego światło, po sterownik nawadniający ogród — działa według tego samego, prostego schematu. Gdy go zrozumiesz, reszta to już tylko dobór klocków.

## Pętla automatyki: czujnik → sterownik → element wykonawczy

Automatyka to zamknięta pętla trzech elementów:

1. **Czujnik (wejście)** — „zmysł" systemu. Mierzy coś w świecie: temperaturę, ruch, wilgotność gleby, poziom wody, jasność. Zamienia zjawisko fizyczne na sygnał elektryczny.
2. **Sterownik (mózg)** — odbiera sygnały z czujników, podejmuje decyzję według reguł (np. „jeśli ciemno **i** wykryto ruch → włącz światło na 2 minuty") i wysyła polecenia.
3. **Element wykonawczy / aktuator (wyjście)** — „mięsień" systemu. Wykonuje decyzję: załącza lampę, otwiera elektrozawór, uruchamia pompę, obraca serwo.

```
[CZUJNIK] --sygnał--> [STEROWNIK] --polecenie--> [ELEMENT WYKONAWCZY]
 ruch, temp.,           ESP32, Shelly,             przekaźnik, lampa,
 wilgotność             Raspberry Pi               elektrozawór, pompa
```

> Cała ta dokumentacja to po prostu rozwinięcie tych trzech pudełek. Rozdział **02** to „mózgi", rozdział **04** to „zmysły i mięśnie", rozdział **03** to sposób, w jaki się komunikują, a rozdziały **05–06** to gotowe pętle dla światła i wody.

## Sygnały: cyfrowe i analogowe

Sterownik „rozmawia" z czujnikami i aktuatorami za pomocą napięć na swoich nóżkach (pinach). Są dwa podstawowe rodzaje sygnału:

| Rodzaj | Co oznacza | Przykłady |
|--------|-----------|-----------|
| **Cyfrowy (0/1)** | Tylko dwa stany: jest napięcie albo go nie ma (włącz/wyłącz, prawda/fałsz) | Czujnik ruchu (jest ruch / nie ma), kontaktron drzwi (otwarte / zamknięte), przekaźnik (zał./wył.) |
| **Analogowy** | Wartość płynna w pewnym zakresie (np. 0–3,3 V) | Czujnik wilgotności gleby, fotorezystor (jasność), potencjometr |
| **PWM** | „Udawany" sygnał analogowy — szybkie pulsowanie 0/1 o zmiennym wypełnieniu | Ściemnianie LED, regulacja obrotów silnika, sterowanie serwem |

**Wejście (input)** to pin, którym sterownik *słucha* czujnika. **Wyjście (output)** to pin, którym *steruje* aktuatorem. Te same fizyczne nóżki (GPIO) można zwykle konfigurować jako wejścia lub wyjścia programowo.

### GPIO — uniwersalne nóżki sterownika

**GPIO** (General Purpose Input/Output) to programowalne piny ogólnego przeznaczenia w mikrokontrolerach (ESP32, Arduino, Raspberry Pi). Do nich podłączasz czujniki i aktuatory. Kluczowe pojęcia:

- **Stan wysoki / niski** — pin wyjściowy daje napięcie (HIGH, np. 3,3 V) albo zwiera do masy (LOW, 0 V).
- **Rezystor podciągający (pull-up/pull-down)** — utrzymuje pin wejściowy w znanym stanie, gdy nic nie jest wciśnięte (zapobiega „pływaniu" sygnału).
- **ADC** (przetwornik analogowo-cyfrowy) — wbudowany blok zamieniający napięcie analogowe na liczbę (np. 0–4095). Niezbędny do czujników analogowych.
- **PWM** — sprzętowe generowanie sygnału do ściemniania i sterowania silnikami.

## Przekaźnik — most między elektroniką a „dużym prądem"

Mikrokontroler pracuje na 3,3 V i kilku miliamperach — nie podłączysz do niego bezpośrednio lampy 230 V ani pompy. Potrzebny jest **przekaźnik (relay)**: elektrycznie sterowany przełącznik, który *małym* sygnałem ze sterownika załącza *duży* obwód, zachowując pełną izolację galwaniczną między nimi.

- **Przekaźnik mechaniczny (elektromagnetyczny)** — fizyczne styki, słyszalny „klik". Tani, uniwersalny, ale wolniejszy i zużywa się przy częstym przełączaniu.
- **Przekaźnik półprzewodnikowy (SSR)** — bez ruchomych części, cichy, szybki, znosi miliony cykli. Droższy; do obciążeń przełączanych często (np. grzałka, oświetlenie sterowane PWM).
- **Styki NO/NC** — *NO* (normalnie otwarty) zwiera się po załączeniu; *NC* (normalnie zamknięty) rozwiera się po załączeniu. NC bywa przydatny, by urządzenie działało przy braku zasilania sterownika.

Alternatywą dla obciążeń niskonapięciowych DC (taśmy LED, silniki, elektrozawory 12 V) jest **tranzystor MOSFET** — steruje płynnie i bezgłośnie (więcej w rozdziale 04).

## Napięcia w domu i ogrodzie

Dobór napięcia to kwestia bezpieczeństwa i wygody. W amatorskiej automatyce spotkasz głównie:

| Napięcie | Typ | Gdzie używane | Bezpieczeństwo |
|----------|-----|---------------|----------------|
| **3,3 V / 5 V** | DC | Logika mikrokontrolerów, czujniki | Bezpieczne w dotyku |
| **12 V** | DC | Taśmy LED, pompy, elektrozawory, zasilanie modułów | Bezpieczne (SELV) |
| **24 V** | DC / AC | Elektrozawory ogrodowe (24 VAC), automatyka przemysłowa | Bezpieczne (SELV) |
| **230 V** | AC | Sieć domowa: lampy, gniazda, duże urządzenia | **Śmiertelnie niebezpieczne** |

**SELV** (bardzo niskie napięcie bezpieczne, ≤ 50 V AC / 120 V DC) to obszar, w którym możesz eksperymentować bez ryzyka porażenia. Dlatego początkujący powinni budować jak najwięcej na 5/12/24 V, a „dużym prądem" sterować przez gotowe, zamknięte moduły (np. Shelly) albo zlecać podłączenie elektrykowi.

> ### ⚠️ Praca przy 230 V — przeczytaj zanim cokolwiek podłączysz
> Napięcie sieciowe **zabija**. Jeśli nie masz uprawnień ani doświadczenia:
> - **Nie otwieraj** obwodów 230 V pod napięciem. Zawsze wyłącz bezpiecznik i sprawdź próbnikiem brak napięcia.
> - Do sterowania oświetleniem 230 V wybieraj **gotowe, certyfikowane moduły** (Shelly, Sonoff) montowane zgodnie z instrukcją — mają obudowę i zabezpieczenia.
> - Stałe ingerencje w instalację domową (nowe obwody, podłączenie do rozdzielnicy) w wielu przypadkach **powinien wykonać uprawniony elektryk**.
> - Mikrokontroler i obwód 230 V **muszą być odizolowane** (przekaźnik, optoizolator). Nigdy nie łącz masy elektroniki z przewodem sieci.
>
> W tej dokumentacji świadomie kładziemy nacisk na rozwiązania niskonapięciowe i modułowe — bezpieczniejsze dla amatora.

## Logika sterowania — od „klika" do reguł

Najprostsza automatyka jest *bezpośrednia*: czujnik zmierzchu sam załącza lampę, bez żadnego „mózgu". To tanie i niezawodne, ale sztywne. Gdy chcesz **warunków, harmonogramów i scen**, wchodzi sterownik programowalny:

- **Reguła (if-this-then-that)** — „jeśli wilgotność gleby < 30% **i** jest po 20:00 → podlewaj 10 minut".
- **Harmonogram** — „w dni robocze o 6:30 włącz światło w kuchni na 20%".
- **Scena** — jednym poleceniem ustaw wiele urządzeń („Dobranoc": zgaś światła, zamknij rolety, wyłącz nawadnianie).
- **Histereza** — próg z zapasem, by uniknąć „migotania" (np. grzej do 21°C, wyłącz przy 21°C, włącz dopiero poniżej 20°C).

Im więcej takich reguł, tym bardziej przyda się centralka (rozdział 07), która zbiera wszystkie urządzenia w jednym miejscu i pozwala tworzyć automatyzacje bez przepisywania kodu.

## Mały słowniczek na start

- **Aktuator / element wykonawczy** — urządzenie wykonujące akcję (przekaźnik, zawór, silnik).
- **Firmware** — oprogramowanie wgrane do mikrokontrolera (np. Tasmota, ESPHome).
- **Floating (pływający pin)** — niepodłączone wejście o nieokreślonym stanie; źródło błędów.
- **Logika 3,3 V / 5 V** — poziom napięcia, jakim operuje dany układ; mieszanie wymaga uwagi (konwerter poziomów).
- **PWM** — modulacja szerokości impulsu; ściemnianie i regulacja mocy.
- **SELV** — bardzo niskie napięcie bezpieczne; obszar bez ryzyka porażenia.

---

W następnym rozdziale przechodzimy do sedna pytania „**na czym to zbudować**" — porównujemy Arduino, ESP8266/ESP32, Raspberry Pi i gotowe moduły Shelly/Sonoff, z cenami i typowymi zastosowaniami.

➡️ Dalej: **[02 — Platformy i mikrokontrolery](02-platformy.html)**
