# Projekty — kompletne przykłady realizacji

Sześć gotowych projektów łączących wszystko z poprzednich rozdziałów. Każdy ma **listę części z cenami**, **schemat podłączenia** i **pełen kod** do wklejenia w Arduino IDE. Ceny orientacyjne (PLN, 2026).

---

## Projekt 1: Stacja pogodowa z OLED

Mierzy temperaturę, wilgotność, ciśnienie i natężenie światła — wyniki pokazuje na małym OLED-zie. Idealny pierwszy „prawdziwy" projekt: I²C, biblioteki, formatowanie.

### Części
| Element | Cena |
|---------|------|
| Arduino Uno R3 (lub klon Nano) | 20–60 zł |
| BME280 (I²C) | 15–35 zł |
| BH1750 (I²C luksomierz) | 10–25 zł |
| OLED 0,96" 128×64 SSD1306 (I²C) | 10–25 zł |
| Płytka stykowa + przewody | 10–20 zł |
| **Razem** | **~65–165 zł** |

### Podłączenie

```
Wszystkie 3 moduły na wspólnej magistrali I²C:

  Arduino       BME280     BH1750     OLED
  --------      ------     ------     ----
  5V       o--- VCC -------- VCC ------- VCC
  GND      o--- GND -------- GND ------- GND
  A4 (SDA) o--- SDA -------- SDA ------- SDA
  A5 (SCL) o--- SCL -------- SCL ------- SCL
```

Adresy I²C: BME280 = `0x76`, BH1750 = `0x23`, OLED = `0x3C`. Skanerem (rozdział 03) sprawdź własne.

### Kod
```cpp
#include <Wire.h>
#include <Adafruit_BME280.h>
#include <BH1750.h>
#include <Adafruit_SSD1306.h>

Adafruit_BME280 bme;
BH1750           lux;
Adafruit_SSD1306 oled(128, 64, &Wire, -1);

void setup() {
    Serial.begin(9600);
    Wire.begin();
    bme.begin(0x76);
    lux.begin();
    oled.begin(SSD1306_SWITCHCAPVCC, 0x3C);
    oled.clearDisplay();
}

void loop() {
    float t = bme.readTemperature();
    float h = bme.readHumidity();
    float p = bme.readPressure() / 100.0;       // hPa
    float l = lux.readLightLevel();

    oled.clearDisplay();
    oled.setTextColor(WHITE);
    oled.setTextSize(2);
    oled.setCursor(0, 0);
    oled.print(t, 1); oled.print((char)247); oled.println("C");
    oled.setTextSize(1);
    oled.setCursor(0, 22); oled.print("Wilg:  "); oled.print(h, 0); oled.println(" %");
    oled.setCursor(0, 34); oled.print("Cisn:  "); oled.print(p, 0); oled.println(" hPa");
    oled.setCursor(0, 46); oled.print("Swiatlo: "); oled.print(l, 0); oled.println(" lx");
    oled.display();
    delay(2000);
}
```

### Rozszerzenia
- Dodaj **Data Logger Shield** (rozdział 06) — masz **rejestrator dobowy**.
- Wymień Uno na **Uno R4 WiFi** — wyślij dane do Home Assistant przez MQTT.
- Dodaj **DS18B20** w sondzie wodoodpornej do pomiaru temperatury na zewnątrz.

---

## Projekt 2: Alarm ruchu z powiadomieniem SMS

Czujnik PIR wykrywa intruza, Arduino wysyła SMS przez moduł GSM. Z buzzerem do efektu lokalnego.

### Części
| Element | Cena |
|---------|------|
| Arduino Uno | 20–60 zł |
| PIR HC-SR501 | 5–12 zł |
| Moduł SIM800L + antena + karta SIM (prepaid) | 35–70 zł |
| Buzzer aktywny | 2–6 zł |
| Zasilacz 5 V / 2 A (SIM800L ciągnie impulsowo) | 25–50 zł |
| **Razem** | **~90–200 zł** |

### Podłączenie
```
PIR HC-SR501          SIM800L                   Buzzer
   VCC --- 5V Arduino  VCC --- 4.0V (osobny!)   + --- D8
   OUT --- D2          GND --- GND wspólny      - --- GND
   GND --- GND         RXD --- D7
                       TXD --- D8 (uwaga konflikt z buzzerem - zmień)
                       (SoftwareSerial)
```

> SIM800L wymaga **3,7–4,2 V** (NIE 5 V!) i potrafi pociągnąć 2 A impulsowo. Najczęściej daje się 1× 18650 (3,7 V) z dużym kondensatorem (1000 µF).

### Kod
```cpp
#include <SoftwareSerial.h>
SoftwareSerial sim(7, 6);             // RX, TX do SIM800L
const int PIR = 2;
const int BUZ = 8;
const char NUMER[] = "+48555123456";  // wstaw swój
unsigned long ostatniSMS = 0;
const unsigned long COOLDOWN = 60000; // min 60 s między SMS-ami

void wyslijSMS(const char* tekst) {
    sim.println("AT+CMGF=1");                   delay(200);
    sim.print("AT+CMGS=\""); sim.print(NUMER); sim.println("\"");
    delay(200);
    sim.print(tekst);
    sim.write(26);                              // Ctrl+Z
    delay(2000);
}

void setup() {
    pinMode(PIR, INPUT);
    pinMode(BUZ, OUTPUT);
    Serial.begin(9600);
    sim.begin(9600);
    delay(3000);                                // czas na zalogowanie do sieci
    Serial.println("Alarm gotowy.");
}

void loop() {
    if (digitalRead(PIR) == HIGH) {
        digitalWrite(BUZ, HIGH);
        Serial.println("Ruch wykryty!");
        if (millis() - ostatniSMS > COOLDOWN) {
            wyslijSMS("ALARM: ruch wykryty!");
            ostatniSMS = millis();
        }
        delay(2000);
        digitalWrite(BUZ, LOW);
    }
}
```

### Rozszerzenia
- Dodaj **kontaktron na drzwi** (rozdział 04) i wyślij osobny SMS „drzwi otwarte".
- Wymień GSM na **Uno R4 WiFi + Telegram Bot** — taniej długoterminowo (bez prepaida).
- Dodaj **klawiaturę membranową + RFID** do uzbrajania/rozbrajania.

---

## Projekt 3: Sterownik nawadniania ogrodu

Sercem rozdziału 06 robotic: Arduino mierzy wilgotność gleby, otwiera elektrozawór, jeśli sucha. LCD pokazuje status. Wystarcza do warzywnika lub 2–3 grządek.

### Części
| Element | Cena |
|---------|------|
| Arduino Nano (klon) | 15–30 zł |
| Pojemnościowy czujnik wilgotności gleby | 8–18 zł |
| Elektrozawór 12 V DC, 1/2" | 25–60 zł |
| Moduł przekaźnikowy 1-kanałowy lub MOSFET IRLZ44N | 6–15 zł |
| LCD 16×2 z I²C | 10–25 zł |
| Zasilacz 12 V / 1 A + przetwornica 5 V | 30–55 zł |
| Dioda gasząca 1N4007 | 1 zł |
| Obudowa IP65 + dławiki | 25–50 zł |
| **Razem** | **~120–255 zł** |

### Podłączenie
```
                     +12V o-----+--------------------+
                                |                    |
                              [PRZEKAŹNIK]         [MOSFET alternatywa]
                              IN  - D3 Arduino    G - D3
                              COM o                 D - +12V
                              NO  - elektrozawór    S - elektrozawór
                                                    + dioda 1N4007
                                                       równolegle
                                                       do cewki!
   GND ----------- wspólny --- GND Arduino, GND zasilacza, GND zaworu

   Czujnik gleby (pojemnościowy):
       VCC --- 5V Arduino
       GND --- GND
       A0  --- A0 Arduino
   LCD I2C (16x2):
       VCC --- 5V
       GND --- GND
       SDA --- A4
       SCL --- A5
```

### Kod
```cpp
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
LiquidCrystal_I2C lcd(0x27, 16, 2);

const int CZUJNIK    = A0;
const int ZAWOR      = 3;
const int SUCHO      = 600;            // raw value w SUCHEJ ziemi (kalibruj!)
const int MOKRO      = 240;            // raw value w MOKREJ ziemi
const int PROG_PODLEW = 35;             // poniżej 35% wilg → podlewaj
const int PROG_STOP   = 60;             // przestań przy 60% (histereza)
const unsigned long MAX_PODLEW = 5UL*60UL*1000UL;  // max 5 min ciągłego polewania

bool zawor_otwarty = false;
unsigned long start_podlewania = 0;

int wilgPercent() {
    int raw = analogRead(CZUJNIK);
    int w = map(raw, SUCHO, MOKRO, 0, 100);
    return constrain(w, 0, 100);
}

void setup() {
    pinMode(ZAWOR, OUTPUT);
    digitalWrite(ZAWOR, LOW);          // zamknięty
    lcd.init(); lcd.backlight();
    Serial.begin(9600);
}

void loop() {
    int w = wilgPercent();
    lcd.setCursor(0, 0); lcd.print("Wilg: "); lcd.print(w); lcd.print("%   ");
    lcd.setCursor(0, 1); lcd.print(zawor_otwarty ? "PODLEWAM    " : "Czekam      ");

    if (!zawor_otwarty && w < PROG_PODLEW) {
        digitalWrite(ZAWOR, HIGH);
        zawor_otwarty = true;
        start_podlewania = millis();
        Serial.println("Otwieram zawór.");
    }
    if (zawor_otwarty) {
        bool nasycone = (w >= PROG_STOP);
        bool za_dlugo = (millis() - start_podlewania > MAX_PODLEW);
        if (nasycone || za_dlugo) {
            digitalWrite(ZAWOR, LOW);
            zawor_otwarty = false;
            Serial.println(nasycone ? "Wilgoć OK, stop." : "Limit czasu, stop.");
        }
    }
    delay(2000);
}
```

### Rozszerzenia
- Dodaj **moduł RTC (DS1307)** — podlewaj tylko między 5:00 a 7:00.
- Dodaj **drugi czujnik gleby + drugi zawór** = dwie strefy.
- Wymień Nano na **ESP32** i wciągnij do **Home Assistant** (rozdział 07 robotic).
- Dołącz **przepływomierz YF-S201** — alarm przy wycieku.

---

## Projekt 4: Podświetlenie schodów z czujnikiem ruchu

Taśma WS2812B (NeoPixel) zapala stopnie kolejno, gdy ktoś wchodzi na schody. „Wow"-efekt domowy.

### Części
| Element | Cena |
|---------|------|
| Arduino Nano | 15–30 zł |
| Taśma WS2812B 5 V (60 LED/m, ~3 m na 15 schodów) | 90–180 zł |
| Zasilacz 5 V / 10 A (taśma!) | 60–100 zł |
| 2× PIR HC-SR501 (dół i góra schodów) | 10–25 zł |
| Kondensator 1000 µF, rezystor 470 Ω | 3 zł |
| Drobne (przewody, koryto kablowe) | 30–80 zł |
| **Razem** | **~210–420 zł** |

### Podłączenie
```
                   +5V (10A) o----+----o (+) początek taśmy
                                  |
                                [C 1000uF]
                                  |
                   GND o-----+---+---o (-) GND taśmy
                             |
   Arduino Nano:            wspólny GND
       D6 ---[470Ω]---o (D) data taśmy (pierwsza dioda)
       D2 ----- PIR dolny OUT
       D3 ----- PIR górny OUT
       5V ----- PIR VCC
       GND --- PIR GND
```

> Zasil **Nano osobno** z USB lub z przetwornicy 5 V (max ~500 mA z zasilacza taśmy nie wystarczy podczas pełnej bieli).

### Kod
```cpp
#include <FastLED.h>
#define LED_PIN     6
#define NUM_LEDS    180          // 15 stopni × 12 LED
#define LED_PER_STEP 12
const int PIR_DOL  = 2;
const int PIR_GORA = 3;

CRGB leds[NUM_LEDS];
enum Stan { IDLE, GORA_DO_DOLU, DOL_DO_GORY };
Stan stan = IDLE;
unsigned long start_anim = 0;
const unsigned long ANIM_KROK_MS = 200;          // odstęp zapalania stopnia
const unsigned long PRZEDZIAL_OFF = 30000;       // zgaś po 30 s

void zapalStopien(int n, CRGB kolor) {
    for (int i = n*LED_PER_STEP; i < (n+1)*LED_PER_STEP; i++) leds[i] = kolor;
    FastLED.show();
}

void zgas() {
    fill_solid(leds, NUM_LEDS, CRGB::Black);
    FastLED.show();
}

void setup() {
    FastLED.addLeds<WS2812B, LED_PIN, GRB>(leds, NUM_LEDS);
    FastLED.setBrightness(80);                   // ~30% — schody nie potrzebują pełnej mocy
    pinMode(PIR_DOL, INPUT);
    pinMode(PIR_GORA, INPUT);
    zgas();
}

void loop() {
    static int stopien = 0;
    static unsigned long ostatni_ruch = 0;

    if (stan == IDLE) {
        if (digitalRead(PIR_DOL) == HIGH) { stan = DOL_DO_GORY; stopien = 0; start_anim = millis(); }
        else if (digitalRead(PIR_GORA) == HIGH) { stan = GORA_DO_DOLU; stopien = NUM_LEDS/LED_PER_STEP - 1; start_anim = millis(); }
    }

    if (stan != IDLE) {
        if (millis() - start_anim >= ANIM_KROK_MS) {
            start_anim = millis();
            CRGB kolor = CRGB(255, 180, 60);     // ciepła biel
            zapalStopien(stopien, kolor);
            if (stan == DOL_DO_GORY) stopien++;
            else                     stopien--;
            int max_step = NUM_LEDS/LED_PER_STEP;
            if (stopien < 0 || stopien >= max_step) {
                ostatni_ruch = millis();
                stan = IDLE;
            }
        }
    }

    if (ostatni_ruch > 0 && millis() - ostatni_ruch > PRZEDZIAL_OFF) {
        zgas();
        ostatni_ruch = 0;
    }
}
```

### Rozszerzenia
- Dodaj **fotorezystor LDR** — działaj tylko po zmierzchu.
- W aktywne weekendy włącz **efekt tęczy** zamiast ciepłej bieli.
- Zsynchronizuj z **Home Assistant** (jeśli Uno R4 WiFi) — sceny „nocna trasa do kuchni".

---

## Projekt 5: Cyfrowy zamek RFID z elektrozaczepem

Zbliż kartę/brelok → drzwi się otwierają. Klasyk kontroli dostępu.

### Części
| Element | Cena |
|---------|------|
| Arduino Uno (lub Nano) | 20–60 zł |
| Czytnik RFID RC522 + 2 karty/breloki | 8–20 zł |
| Elektrozaczep 12 V DC (rewersyjny lub normalny) | 60–180 zł |
| Moduł przekaźnikowy 1-kanałowy | 6–15 zł |
| Buzzer aktywny | 2–6 zł |
| 2× LED (zielony, czerwony) + 2× 330 Ω | 3 zł |
| Zasilacz 12 V / 1 A | 20–40 zł |
| **Razem** | **~120–325 zł** |

### Podłączenie
```
RC522 → Arduino Uno
   SDA(SS) → D10
   SCK     → D13
   MOSI    → D11
   MISO    → D12
   IRQ     → -
   GND     → GND
   RST     → D9
   3.3V    → 3.3V (UWAGA: NIE 5V!)

Przekaźnik → D7 (active LOW)
Buzzer → D8
LED zielony → D5 (+330Ω → GND)
LED czerwony → D6 (+330Ω → GND)

Strona 12V:
   Zasilacz +12V → COM przekaźnika
   NO przekaźnika → + elektrozaczepu
   - elektrozaczepu → GND zasilacza
   DIODA 1N4007 równolegle do cewki elektrozaczepu (gasząca!)
```

### Kod
```cpp
#include <SPI.h>
#include <MFRC522.h>
MFRC522 rfid(10, 9);

const int RELAY   = 7;
const int BUZ     = 8;
const int LED_OK  = 5;
const int LED_NO  = 6;

// Wpisz tu UID-y dozwolonych kart (4 bajty każde)
const byte DOZWOLONE[][4] = {
    {0xAB, 0xCD, 0x12, 0x34},
    {0x11, 0x22, 0x33, 0x44}
};
const int LICZBA_KART = sizeof(DOZWOLONE)/4;

bool czyDozwolona(byte uid[]) {
    for (int i = 0; i < LICZBA_KART; i++) {
        if (memcmp(uid, DOZWOLONE[i], 4) == 0) return true;
    }
    return false;
}

void otworz() {
    digitalWrite(RELAY, LOW);          // active LOW
    digitalWrite(LED_OK, HIGH);
    tone(BUZ, 1500, 100);
    delay(3000);                       // drzwi otwarte 3 s
    digitalWrite(RELAY, HIGH);
    digitalWrite(LED_OK, LOW);
}

void odrzuc() {
    digitalWrite(LED_NO, HIGH);
    for (int i = 0; i < 3; i++) {
        tone(BUZ, 400, 200);
        delay(300);
    }
    digitalWrite(LED_NO, LOW);
}

void setup() {
    pinMode(RELAY, OUTPUT); digitalWrite(RELAY, HIGH);  // zamknięte
    pinMode(BUZ, OUTPUT);
    pinMode(LED_OK, OUTPUT); pinMode(LED_NO, OUTPUT);
    SPI.begin();
    rfid.PCD_Init();
    Serial.begin(9600);
    Serial.println("Czekam na kartę...");
}

void loop() {
    if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) return;

    Serial.print("UID: ");
    for (byte i = 0; i < rfid.uid.size; i++) {
        Serial.print(rfid.uid.uidByte[i] < 0x10 ? " 0" : " ");
        Serial.print(rfid.uid.uidByte[i], HEX);
    }
    Serial.println();

    if (czyDozwolona(rfid.uid.uidByte)) {
        Serial.println("OK - otwieram.");
        otworz();
    } else {
        Serial.println("ODRZUCONO.");
        odrzuc();
    }
    rfid.PICC_HaltA();
}
```

### Rozszerzenia
- Dodaj **klawiaturę membranową** (kod + karta = dwuskładnikowe).
- Dodaj **EEPROM** — dodawaj/odbieraj karty bez zmiany kodu (tryb „master").
- Dodaj **DS3231 RTC** — log dostępów z datą.

---

## Projekt 6: Inteligentny ekspres / parkomat (parkometr)

Bardziej zabawowy: zliczanie czasu z monetami (lub przyciskiem).

### Części
| Element | Cena |
|---------|------|
| Arduino Uno | 20–60 zł |
| Wyświetlacz TM1637 (4 cyfry 7-seg) | 6–18 zł |
| Buzzer | 2–6 zł |
| Przycisk + rezystor | 1 zł |
| Czujnik monet / kontaktron lub PIR | 3–15 zł |
| **Razem** | **~32–100 zł** |

### Kod (skrót — TM1637 z DOLICZANIEM czasu)
```cpp
#include <TM1637Display.h>
TM1637Display d(2, 3);
const int PRZYCISK = 4;
const int BUZ = 8;
unsigned long czasKonca = 0;

void setup() {
    pinMode(PRZYCISK, INPUT_PULLUP);
    pinMode(BUZ, OUTPUT);
    d.setBrightness(7);
}

void loop() {
    if (digitalRead(PRZYCISK) == LOW) {
        czasKonca = millis() + 60UL*1000UL;     // +60 s za naciśnięcie
        tone(BUZ, 1500, 80);
        delay(300);
    }
    long pozostalo = (long)(czasKonca - millis()) / 1000;
    if (pozostalo < 0) pozostalo = 0;
    int min = pozostalo / 60, sec = pozostalo % 60;
    d.showNumberDecEx(min*100 + sec, 0b01000000, true);    // MM:SS z dwukropkiem
    if (pozostalo == 0) {
        tone(BUZ, 600, 100);
        delay(200);
    }
    delay(200);
}
```

---

## Co dalej?

Te projekty są **fundamentami** — możesz je swobodnie łączyć. Stacja pogodowa + sterownik nawadniania to inteligentny ogród. Alarm + zamek RFID to mała kontrola dostępu. WS2812 + stacja pogodowa to **dashboard nastrojowy** salonu.

Najwięcej nauczysz się, gdy:
1. **Zbudujesz jeden projekt do końca** — z obudową, na stałym zasilaniu, montowany w docelowym miejscu.
2. **Po każdym projekcie wyciągniesz wniosek** — czego brakowało, co zrobić lepiej.
3. **Przejdziesz na ESP32** (rozdział 02 robotic), gdy poczujesz, że Arduino ogranicza cię na WiFi/MQTT.

> Pamiętaj o trzech filarach: **wspólne masy**, **dioda gasząca przy cewkach**, **osobne zasilanie dla silników i taśm LED**. To 80% problemów początkujących.

---

➡️ Wróć do: **[spisu treści sub-działu Arduino](index.html)** lub **[Automatyki DIY i smart home](../index.html)**.
