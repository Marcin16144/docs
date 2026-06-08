# Platformy — na czym to zbudować

To najważniejszy rozdział, jeśli zastanawiasz się „**od czego zacząć**". Są dwie filozofie i nie trzeba wybierać tylko jednej — większość domowych instalacji to mieszanka obu.

## Dwie drogi: gotowe moduły kontra własna elektronika

| | Gotowe moduły (Shelly, Sonoff, Tuya) | Własna elektronika (ESP32, Arduino, Pi) |
|---|---|---|
| **Próg wejścia** | Bardzo niski — montaż i aplikacja | Wymaga nauki: schematy, kod, lutowanie |
| **Czas wdrożenia** | Minuty | Godziny–dni |
| **Elastyczność** | Ograniczona do funkcji producenta | Praktycznie nieograniczona |
| **Koszt na funkcję** | Wyższy za sztukę | Niższy, zwłaszcza przy wielu czujnikach |
| **Certyfikacja 230 V** | Tak (CE, gotowe do instalacji) | Twoja odpowiedzialność |
| **Dla kogo** | Chcesz efektu szybko i bezpiecznie | Lubisz majsterkować, masz nietypowe potrzeby |

> **Rekomendacja dla początkującego:** światło i gniazda 230 V rób na gotowych modułach (Shelly), a własne ESP32 wykorzystaj tam, gdzie pracujesz na niskim napięciu i potrzebujesz nietypowych czujników (ogród, nawadnianie, monitoring). Tak łączysz bezpieczeństwo z elastycznością.

## Mikrokontroler kontra mikrokomputer

- **Mikrokontroler (MCU)** — pojedynczy układ uruchamiający *jeden* program „na surowo" (bez systemu operacyjnego). Startuje natychmiast, pobiera ułamek wata, kosztuje grosze. Idealny do zadania „czytaj czujnik, steruj wyjściem". Przykłady: **ESP32, ESP8266, Arduino, Pico**.
- **Mikrokomputer / SBC** (Single Board Computer) — mały komputer z systemem (zwykle Linux). Uruchamia bazy danych, serwery, panele, kamery. Pobiera kilka watów, potrzebuje karty/dysku. Przykład: **Raspberry Pi**.

Reguła kciuka: **„zmysły i mięśnie" buduj na mikrokontrolerach, a „mózg całego domu" (centralka) na mikrokomputerze**.

## ESP32 — domyślny wybór do automatyki DIY

Jeśli masz poznać tylko jedną platformę, niech to będzie **ESP32**. To mikrokontroler z **wbudowanym WiFi i Bluetooth**, dwoma rdzeniami, mnóstwem GPIO, przetwornikami ADC i obsługą PWM — a kosztuje kilkanaście złotych. Dzięki WiFi od razu „gada" z siecią i centralką, bez dokupowania modułów.

- **Zalety:** WiFi+BT na pokładzie, dużo pinów, ogromna społeczność, gotowe firmware (ESPHome/Tasmota), bardzo tani.
- **Wady:** zasilanie sieciowe lub solidna bateria (WiFi „je" prąd), nie do zadań wymagających pełnego Linuksa.
- **Warianty:** klasyczny **ESP32**, energooszczędny **ESP32-C3** (RISC-V, tani), mocniejszy **ESP32-S3** (AI, więcej pamięci).

**ESP8266** to starszy, tańszy „dziadek" ESP32 — tylko WiFi, mniej pinów, jeden rdzeń. Nadal świetny do prostych zadań (jeden przekaźnik, jeden czujnik), np. w popularnych płytkach **Wemos D1 mini** czy **NodeMCU**.

## Arduino — nauka i niezawodne sterowanie

**Arduino** (np. **Uno**, **Nano**) to klasyka edukacyjna: prosty mikrokontroler bez sieci, za to z czytelnym środowiskiem i niezliczonymi poradnikami. Świetny do nauki podstaw i do zadań, gdzie sieć jest zbędna (np. lokalny sterownik z wyświetlaczem). Aby dodać łączność, dokłada się moduły (WiFi, Ethernet, radio) — dlatego do projektów „sieciowych" ESP32 jest wygodniejszy i tańszy.

> Pogłębione potraktowanie Arduino — pełna rodzina płytek, ponad sto modułów, schematy podłączeń (I²C/SPI/UART), shieldy i gotowe projekty z kodem — znajdziesz w osobnym sub-dziale: **[Arduino — kompletny przewodnik](arduino/index.html)**.

**Raspberry Pi Pico / Pico W** (układ RP2040) to nowoczesna, bardzo tania płytka MCU; wersja **Pico W** ma WiFi. Programuje się ją w MicroPythonie lub C — dobra alternatywa dla Arduino Nano.

## Raspberry Pi — serce inteligentnego domu

**Raspberry Pi** to mały komputer z Linuksem — naturalny „gospodarz" dla centralki **Home Assistant** (rozdział 07), serwera **MQTT**, **Node-RED** czy nagrywania z kamer. Nie używaj go do machania pojedynczym przekaźnikiem (szkoda mocy i czasu startu systemu) — użyj do koordynowania całości.

- **Raspberry Pi 5** — wydajny, do rozbudowanej centralki z wieloma integracjami i kamerami.
- **Raspberry Pi 4 / Pi 3** — w zupełności wystarczą do typowego Home Assistant.
- **Raspberry Pi Zero 2 W** — malutki i tani, do lekkich zadań.
- Alternatywa: używany **mini-PC** (np. Intel N100) bywa tańszy i szybszy od Pi, a do tego stabilniejszy (dysk SSD zamiast karty SD).

## Gotowe moduły: Shelly, Sonoff, Tuya

To „automatyka bez lutownicy". Małe urządzenia, które wpina się w obwód albo w gniazdo i konfiguruje w aplikacji.

- **Shelly** — czołowy wybór entuzjastów. Działają **lokalnie** (bez chmury), mają otwarte API i REST, integrują się z Home Assistant. Modele do puszki podtynkowej (np. *Shelly Plus 1*, *Plus 1PM* z pomiarem mocy, *Plus 2PM* do rolet/2 obwodów, *Dimmer* do ściemniania). Najlepszy kompromis bezpieczeństwo/elastyczność dla 230 V.
- **Sonoff** — bardzo tanie przekaźniki i przełączniki WiFi/Zigbee. Fabrycznie chodzą w chmurze (eWeLink), ale wiele modeli można „uwolnić", wgrywając **Tasmota** lub **ESPHome** (bo w środku to… ESP). Modele: *BASIC R4*, *MINI*, *ZBMINI* (Zigbee).
- **Tuya / Smart Life** — nie marka, lecz *platforma* pod setkami chińskich brandów (żarówki, gniazdka, czujniki). Tanie i wszechobecne, ale domyślnie **zależne od chmury**. Część da się zintegrować lokalnie (LocalTuya, przewgranie firmware), część nie — kupuj świadomie.

## Porównanie i orientacyjne ceny (PLN, 2026)

| Platforma | Typ | Sieć | Typowe zastosowanie | Cena |
|-----------|-----|------|--------------------|------|
| **ESP8266** (Wemos D1 mini) | MCU | WiFi | 1 czujnik / 1 przekaźnik | 12–25 zł |
| **ESP32** (DevKit) | MCU | WiFi+BT | Uniwersalny sterownik DIY | 20–45 zł |
| **ESP32-C3 / S3** | MCU | WiFi+BT | Energooszczędny / mocniejszy | 18–60 zł |
| **Arduino Nano** (klon) | MCU | — | Nauka, sterowanie lokalne | 15–30 zł |
| **Arduino Uno** (klon) | MCU | — | Nauka, prototypy | 30–60 zł |
| **Raspberry Pi Pico W** | MCU | WiFi | Tani sterownik, MicroPython | 30–45 zł |
| **Raspberry Pi Zero 2 W** | SBC | WiFi | Lekka centralka, kamerka | 90–150 zł |
| **Raspberry Pi 4 (4 GB)** | SBC | WiFi+LAN | Home Assistant | 250–400 zł |
| **Raspberry Pi 5 (8 GB)** | SBC | WiFi+LAN | Rozbudowana centralka | 400–600 zł |
| **Mini-PC (Intel N100)** | SBC | LAN | Stabilna centralka + Docker | 500–800 zł |
| **Shelly Plus 1 / 1PM** | Moduł | WiFi | Sterowanie obwodem 230 V | 60–110 zł |
| **Shelly Dimmer / 2PM** | Moduł | WiFi | Ściemnianie / rolety | 110–180 zł |
| **Sonoff BASIC / MINI** | Moduł | WiFi | Tani przekaźnik 230 V | 25–55 zł |
| **Sonoff ZBMINI** | Moduł | Zigbee | Przekaźnik w sieci Zigbee | 35–60 zł |

*Ceny orientacyjne (Botland, Kamami, Allegro, AliExpress). Klony i zakup z Azji bywają tańsze, ale z dłuższym czasem dostawy.*

## Jak wgrać „mózg" do mikrokontrolera (firmware)

Sam ESP32 to czysta kartka — trzeba dać mu oprogramowanie. Najpopularniejsze ścieżki:

- **ESPHome** — opisujesz urządzenie w prostym pliku YAML, a ono kompiluje firmware i **bezproblemowo wpina się w Home Assistant**. Najwygodniejsze dla automatyki domowej. Bez pisania kodu w C.
- **Tasmota** — gotowe firmware wgrywane do modułów (Sonoff, przekaźniki); konfiguracja przez stronę WWW, integracja przez MQTT. Świetne do „uwalniania" gotowych urządzeń z chmury.
- **Arduino IDE / PlatformIO** — klasyczne programowanie w C/C++. Pełna kontrola, ale więcej pracy.
- **MicroPython** — Python na mikrokontrolerze; przyjazny do nauki i prototypów.

> Dla osoby zaczynającej: **ESP32 + ESPHome + Home Assistant** to dziś najkrótsza droga od pomysłu do działającego, lokalnego (bez chmury) urządzenia.

## Co wybrać — szybki przewodnik

- **Chcę sterować światłem/gniazdkiem 230 V, bez lutowania** → moduł **Shelly**.
- **Chcę tani czujnik/sterownik do ogrodu lub nietypowy projekt** → **ESP32 + ESPHome**.
- **Uczę się elektroniki od zera** → **Arduino Uno/Nano** (mnóstwo kursów).
- **Buduję centralę całego domu** → **Raspberry Pi 4/5** lub mini-PC z Home Assistant.
- **Potrzebuję kilkunastu tanich czujników bezprzewodowych** → urządzenia **Zigbee** + koordynator (rozdział 03).

---

➡️ Dalej: **[03 — Komunikacja i protokoły](03-komunikacja.html)** — jak te wszystkie elementy mają się ze sobą porozumiewać (WiFi, Zigbee, Matter, MQTT…).
