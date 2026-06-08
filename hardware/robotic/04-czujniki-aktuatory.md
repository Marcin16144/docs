# Czujniki i elementy wykonawcze

To „zmysły" i „mięśnie" z rozdziału 1. Czujnik dostarcza sterownikowi informacji o świecie, a element wykonawczy realizuje decyzję. Poniżej najczęściej używane komponenty w automatyce domowej i ogrodowej — z zastosowaniem, uwagami i orientacyjnymi cenami (PLN, 2026).

## Czujniki (wejścia)

### Ruch i obecność
- **PIR (pasywna podczerwień)** — wykrywa ruch ciepłego ciała. Klasyk do automatyki światła (klatka, garaż, łazienka). Tani, niezawodny, mała czułość na „obecność bez ruchu". Moduł **HC-SR501**.
- **Radar mmWave (np. LD2410)** — wykrywa nawet **obecność bez ruchu** (np. siedzenie przy biurku). Droższy, ale eliminuje „gaśnięcie światła, gdy się nie ruszasz".
- **Ultradźwiękowy HC-SR04** — mierzy *odległość* (echo dźwięku). Do poziomu wody w zbiorniku, wykrywania obecności auta w garażu.

### Temperatura i wilgotność powietrza
- **DS18B20** — cyfrowy czujnik temperatury na magistrali **1-Wire**; wiele sztuk na jednym kablu, wodoodporna wersja w sondzie. Najlepszy do pomiaru temperatury w wielu punktach (CO, bojler, ogród).
- **DHT22 / AM2302** — temperatura + wilgotność, tani, popularny, ale wolny i mało precyzyjny.
- **BME280** — temperatura + wilgotność + ciśnienie, dokładny, na magistrali I²C; do stacji pogodowej i komfortu w pomieszczeniach.

### Ogród i woda
- **Czujnik wilgotności gleby — pojemnościowy (capacitive)** — mierzy wilgoć ziemi. **Wybieraj wersję pojemnościową**, nie rezystancyjną: rezystancyjne elektrody korodują w ziemi w kilka tygodni. Sygnał analogowy (ADC).
- **Pływakowy czujnik poziomu (float switch)** — prosty kontakt zwierany przez pływak; sygnalizuje „pełno/pusto" w zbiorniku deszczówki. Tani i niezawodny.
- **Czujnik deszczu** — wykrywa krople (płytka) lub jest częścią stacji pogodowej; pozwala wstrzymać podlewanie, gdy pada.
- **Czujnik przepływu (przepływomierz)** — zlicza litry przepływające przez rurę; do kontroli zużycia wody i wykrywania wycieków.

### Światło, otwarcie, bezpieczeństwo
- **Fotorezystor (LDR) / czujnik lux** — natężenie światła; do automatyki „o zmierzchu" i sterowania roletami. Sygnał analogowy.
- **Kontaktron (reed switch)** — magnetyczny czujnik otwarcia drzwi/okna/bramy. Grosze za sztukę, podstawa alarmu i automatyki „okno otwarte → wyłącz ogrzewanie".
- **Czujnik dymu / CO / gazu (MQ-x, czujki dedykowane)** — bezpieczeństwo. **Do ochrony życia używaj certyfikowanych czujek**, a moduły MQ traktuj jako uzupełnienie/eksperyment, nie jedyną ochronę.
- **Czujnik zalania** — dwie elektrody wykrywające wodę na podłodze (pralnia, kotłownia) — i automatyczne zamknięcie zaworu głównego.

### Ceny czujników

| Czujnik | Funkcja | Cena |
|---------|---------|------|
| PIR HC-SR501 | Ruch | 5–12 zł |
| Radar mmWave LD2410 | Obecność | 20–40 zł |
| HC-SR04 | Odległość / poziom | 5–10 zł |
| DS18B20 (sonda) | Temperatura 1-Wire | 8–20 zł |
| DHT22 | Temp + wilgotność | 15–30 zł |
| BME280 | Temp + wilg + ciśnienie | 15–35 zł |
| Wilgotność gleby (pojemnościowy) | Ogród | 8–20 zł |
| Pływak poziomu | Zbiornik | 6–15 zł |
| Fotorezystor LDR (moduł) | Jasność | 3–8 zł |
| Kontaktron | Otwarcie | 2–6 zł |
| Czujnik zalania | Wykrycie wody | 5–15 zł |

## Elementy wykonawcze (wyjścia)

### Przełączanie obciążeń
- **Moduł przekaźnikowy** — najprostszy sposób, by mikrokontroler załączył „coś dużego" (lampa, pompa 230 V). Dostępne 1-, 2-, 4-, 8-kanałowe; szukaj wersji z **optoizolacją**. Pamiętaj o ostrzeżeniach z rozdziału 1 dotyczących 230 V.
- **Przekaźnik SSR (półprzewodnikowy)** — bezgłośny, do częstego przełączania (grzałki, oświetlenie). Wymaga radiatora przy większych prądach.
- **Tranzystor MOSFET** — do **płynnego** sterowania obciążeniami DC (taśmy LED, pompki, silniki, elektrozawory 12 V) sygnałem PWM. Tani, bezgłośny, idealny do ściemniania i regulacji obrotów. Dla cewek (silnik, zawór) dodaj **diodę gaszącą (flyback)**, by impuls samoindukcji nie uszkodził tranzystora.

### Ruch, woda, światło
- **Elektrozawór** — otwiera/zamyka przepływ wody. Wersje **12 V DC** (łatwe w DIY) i **24 V AC** (standard w gotowych systemach ogrodowych). Serce automatycznego nawadniania (rozdział 06).
- **Pompa** — membranowa **12 V** do beczki/IBC i nawadniania kropelkowego; większe **230 V** do studni/hydroforu (sterowane przez przekaźnik).
- **Serwomechanizm (serwo)** — precyzyjny obrót o zadany kąt (otwarcie klapy wentylacyjnej, mały zawór, karmnik). Sterowane PWM.
- **Silnik krokowy / DC** — obrót ciągły lub precyzyjny (rolety, kurtyny, mechanizmy); wymaga sterownika mocy (np. **L298N**, **DRV8825**).
- **Ściemniacz (dimmer)** — reguluje jasność. Do LED-ów niskonapięciowych — MOSFET+PWM; do 230 V — gotowy moduł (np. **Shelly Dimmer**), bo bezpośrednie ściemnianie sieci to już „duży prąd".
- **Taśma LED** — dekoracyjne i użytkowe oświetlenie. **Jednokolorowa 12/24 V** (sterowana 1 MOSFET-em), **RGB** (3 kanały) lub **adresowalna WS2812B/SK6812** (każda dioda osobno, efekty — wymaga 1 pinu danych i dobrego zasilania).

### Ceny elementów wykonawczych

| Element | Zastosowanie | Cena |
|---------|--------------|------|
| Moduł przekaźnikowy 1-kanałowy | Załączanie obciążenia | 6–15 zł |
| Moduł przekaźnikowy 4-kanałowy | Wiele obwodów | 15–35 zł |
| Przekaźnik SSR 25 A | Grzałka, częste przełączanie | 20–45 zł |
| Moduł MOSFET (np. IRLZ44N) | PWM, LED, pompka DC | 5–15 zł |
| Elektrozawór 12 V DC | Nawadnianie DIY | 25–60 zł |
| Elektrozawór 24 V AC | Systemy ogrodowe | 30–70 zł |
| Pompa membranowa 12 V | Beczka, kropelkowe | 30–70 zł |
| Serwo SG90 / MG996R | Klapy, małe zawory | 8–35 zł |
| Sterownik silnika L298N | Silniki DC, rolety | 8–20 zł |
| Taśma LED 12 V (1 m, COB) | Oświetlenie | 15–40 zł |
| Taśma WS2812B (1 m) | Efekty adresowalne | 20–50 zł |

## Praktyczne zasady doboru i podłączania

- **Licz prąd, nie tylko napięcie.** Dobierz zasilacz z zapasem (np. taśma LED 12 V/2 A → zasilacz 12 V/3 A). Najczęstsza przyczyna „dziwnych" błędów to za słabe zasilanie.
- **Wspólna masa (GND).** Sterownik i obciążenie muszą mieć połączone masy, ale **nie** łącz masy elektroniki z siecią 230 V — od tego jest przekaźnik/optoizolacja.
- **Dioda gasząca przy cewkach.** Każdy silnik, zawór i przekaźnik to cewka — przy wyłączeniu generuje impuls. Dioda flyback (równolegle do cewki) chroni tranzystory.
- **Pojemnościowy czujnik gleby > rezystancyjny.** To jedna z najczęstszych pomyłek nowicjuszy — tani „rezystancyjny" rozpadnie się w ziemi.
- **IP w ogrodzie.** Na zewnątrz wszystko (czujniki, złącza, sterownik) musi być w obudowie **IP65+**; elektronikę trzymaj w szczelnej puszce z dławikami.

---

➡️ Dalej: **[05 — Sterowanie oświetleniem](05-oswietlenie.html)** — pierwszy kompletny scenariusz: od żarówki po automatykę „ruch + zmierzch".
