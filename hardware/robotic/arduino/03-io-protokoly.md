# I/O i protokoły komunikacyjne

Wejścia, wyjścia i magistrale to kręgosłup każdego projektu — od najprostszego mrugającego LED-a po sterownik z dziesiątkami czujników. Ten rozdział to **schematy + kod** dla każdego typowego sposobu podłączenia.

## Cyfrowe wejście — przycisk z pull-up

Przycisk fizyczny zwykle łączy pin do **masy (GND)**, gdy wciśnięty. By pin „wisiał" wysoko, gdy przycisk nie jest wciśnięty, używamy **rezystora podciągającego (pull-up)**. Arduino ma go wbudowanego (`INPUT_PULLUP`), więc zewnętrzny zwykle nie jest potrzebny.

<svg viewBox="0 0 540 220" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Schemat - przycisk z rezystorem pull-up podłączony do pinu cyfrowego Arduino">
<!-- Arduino -->
<rect x="20" y="50" width="120" height="130" rx="8" fill="#143527" stroke="#4ade80" stroke-width="2"/>
<text x="80" y="40" text-anchor="middle" font-size="12" fill="#a78bfa" font-weight="700">ARDUINO</text>
<text x="80" y="75" text-anchor="middle" font-size="11" fill="#ece6f0">5V</text>
<text x="80" y="115" text-anchor="middle" font-size="11" fill="#ece6f0">D2</text>
<text x="80" y="155" text-anchor="middle" font-size="11" fill="#ece6f0">GND</text>
<circle cx="140" cy="75" r="3" fill="#fb923c"/>
<circle cx="140" cy="115" r="3" fill="#60a5fa"/>
<circle cx="140" cy="155" r="3" fill="#94a3b8"/>
<!-- Rezystor pull-up 10k -->
<line x1="140" y1="75" x2="260" y2="75" stroke="#fb923c" stroke-width="2"/>
<line x1="260" y1="75" x2="260" y2="115" stroke="#fb923c" stroke-width="2"/>
<rect x="240" y="83" width="40" height="14" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="295" y="93" font-size="10" fill="#fbbf24">10 kΩ</text>
<!-- Linia D2 do przycisku -->
<line x1="140" y1="115" x2="260" y2="115" stroke="#60a5fa" stroke-width="2"/>
<line x1="260" y1="115" x2="380" y2="115" stroke="#60a5fa" stroke-width="2"/>
<!-- Przycisk -->
<rect x="380" y="105" width="60" height="20" rx="3" fill="#1e293b" stroke="#a78bfa" stroke-width="1.5"/>
<text x="410" y="98" text-anchor="middle" font-size="10" fill="#a78bfa">BUTTON</text>
<line x1="410" y1="105" x2="410" y2="125" stroke="#a78bfa" stroke-width="1.5" stroke-dasharray="3 2"/>
<!-- linia do GND -->
<line x1="440" y1="115" x2="490" y2="115" stroke="#94a3b8" stroke-width="2"/>
<line x1="490" y1="115" x2="490" y2="155" stroke="#94a3b8" stroke-width="2"/>
<line x1="490" y1="155" x2="140" y2="155" stroke="#94a3b8" stroke-width="2"/>
<!-- Etykieta -->
<text x="270" y="200" text-anchor="middle" font-size="11" fill="#a394b3" font-style="italic">Wciśnięcie zwiera D2 do GND - czytasz LOW. Pull-up daje HIGH, gdy nie wciśnięty.</text>
</svg>

```cpp
const int BTN = 2;
void setup() {
    pinMode(BTN, INPUT_PULLUP);   // wbudowany pull-up - rezystor zewnętrzny niepotrzebny
    Serial.begin(9600);
}
void loop() {
    if (digitalRead(BTN) == LOW) {  // LOW = wciśnięty
        Serial.println("Wciśnięty!");
        delay(200);                 // ochrona przed wielokrotnym wyzwoleniem
    }
}
```

**Pull-down** robisz odwrotnie: rezystor 10 kΩ z pinu do GND, przycisk z pinu do 5 V — wtedy `HIGH` = wciśnięty. Działa, ale w Arduino zwykle wygodniej pull-up + `INPUT_PULLUP`.

## Cyfrowe wyjście — dioda LED

Dioda nigdy bez **rezystora ograniczającego prąd** — inaczej spalisz LED-a i prawdopodobnie pin (max 40 mA na pin, zalecane ≤ 20 mA).

<svg viewBox="0 0 480 180" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Schemat - LED z rezystorem 220 omów podłączony do pinu cyfrowego">
<rect x="20" y="40" width="120" height="100" rx="8" fill="#143527" stroke="#4ade80" stroke-width="2"/>
<text x="80" y="30" text-anchor="middle" font-size="12" fill="#a78bfa" font-weight="700">ARDUINO</text>
<text x="80" y="80" text-anchor="middle" font-size="11" fill="#ece6f0">D13</text>
<text x="80" y="130" text-anchor="middle" font-size="11" fill="#ece6f0">GND</text>
<circle cx="140" cy="80" r="3" fill="#60a5fa"/>
<circle cx="140" cy="130" r="3" fill="#94a3b8"/>
<!-- linia D13 -->
<line x1="140" y1="80" x2="220" y2="80" stroke="#60a5fa" stroke-width="2"/>
<!-- rezystor 220R -->
<rect x="220" y="73" width="50" height="14" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="245" y="65" text-anchor="middle" font-size="10" fill="#fbbf24">220 Ω</text>
<line x1="270" y1="80" x2="320" y2="80" stroke="#60a5fa" stroke-width="2"/>
<!-- LED (anoda po lewej, katoda po prawej) -->
<polygon points="320,72 320,88 340,80" fill="#f87171" stroke="#f87171"/>
<line x1="340" y1="68" x2="340" y2="92" stroke="#f87171" stroke-width="3"/>
<line x1="340" y1="80" x2="380" y2="80" stroke="#94a3b8" stroke-width="2"/>
<text x="330" y="60" text-anchor="middle" font-size="9" fill="#a394b3">A     K</text>
<!-- linia do GND -->
<line x1="380" y1="80" x2="380" y2="130" stroke="#94a3b8" stroke-width="2"/>
<line x1="380" y1="130" x2="140" y2="130" stroke="#94a3b8" stroke-width="2"/>
<text x="240" y="160" text-anchor="middle" font-size="11" fill="#a394b3" font-style="italic">A = anoda (+, dłuższa nóżka), K = katoda (-, krótsza)</text>
</svg>

Wzór na rezystor: **R = (V<sub>zasilania</sub> - V<sub>LED</sub>) / I<sub>LED</sub>**. Dla typowej czerwonej LED (V<sub>F</sub> ≈ 2 V) i 10 mA z 5 V: R = (5 - 2) / 0,01 = **300 Ω**, a najbliższy „handlowy" to **330 Ω** (220 Ω też zadziała, przy nieco większym prądzie).

```cpp
const int LED = 13;
void setup() { pinMode(LED, OUTPUT); }
void loop() {
    digitalWrite(LED, HIGH); delay(500);
    digitalWrite(LED, LOW);  delay(500);
}
```

## Analogowe wejście (ADC) — czytanie napięcia

Piny **A0–A5** (Uno) to wejścia 10-bitowego ADC: `analogRead()` zwraca **0–1023** odpowiadające napięciu **0–5 V** (Uno) lub **0–3,3 V** (płytki 3,3 V).

```cpp
int raw = analogRead(A0);
float volts = raw * (5.0 / 1023.0);
Serial.println(volts, 3);   // 3 miejsca po przecinku
```

### Dzielnik napięcia — pomiar wyższych napięć

ADC „widzi" max 5 V. Aby zmierzyć **napięcie baterii 12 V**, dzielimy je dwoma rezystorami:

```
   12V o---[R1=10k]---o---[R2=4.7k]---o GND
                       |
                       A0  (ok. 12V * 4.7/(10+4.7) = 3,84 V)
```

```cpp
const float R1 = 10000.0, R2 = 4700.0;
float vBat = analogRead(A0) * (5.0/1023.0) * (R1 + R2) / R2;
```

### Najczęstsza analogowa wpadka — czujnik LDR / NTC

Czujniki rezystancyjne (LDR, NTC, wilgotność rezystancyjna) podłączamy w **dzielnik**:

```
  5V o---[LDR]---o---[10k]---o GND
                  |
                  A0
```

Im więcej światła, tym mniejsza rezystancja LDR, tym **wyższe** napięcie na A0.

## PWM — analogowe wyjście „dla biednych"

`analogWrite(pin, 0..255)` daje sygnał o zmiennym wypełnieniu impulsu (490–980 Hz na Uno), który dla LED-a wygląda jak ściemnianie, a dla silnika jak regulacja obrotów. **Tylko piny z `~`** (D3, D5, D6, D9, D10, D11 na Uno).

```cpp
const int LED = 9;
void setup() { pinMode(LED, OUTPUT); }
void loop() {
    for (int v = 0; v <= 255; v++) { analogWrite(LED, v); delay(8); }
    for (int v = 255; v >= 0; v--) { analogWrite(LED, v); delay(8); }
}
```

Do większych obciążeń (taśma LED 12 V, silnik) PWM steruje **MOSFET-em** (rozdział 05), nie pinem wprost.

## Przerwania sprzętowe — natychmiastowa reakcja

Na Uno tylko piny **D2 i D3** obsługują `attachInterrupt`. Tryby: `RISING` (zbocze narastające), `FALLING` (opadające), `CHANGE` (każda zmiana), `LOW` (poziom niski).

```cpp
volatile unsigned long impulsy = 0;

void przepływ() {                // czujnik przepływu wody YF-S201
    impulsy++;
}

void setup() {
    pinMode(2, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(2), przepływ, FALLING);
    Serial.begin(9600);
}

void loop() {
    static unsigned long t0 = 0;
    if (millis() - t0 >= 1000) {
        t0 = millis();
        Serial.print("Hz: "); Serial.println(impulsy);
        impulsy = 0;
    }
}
```

## I²C (Wire) — wiele urządzeń, dwa przewody

Magistrala **I²C** zaprzęga **dwa przewody** (SDA, SCL) do komunikacji z **wieloma urządzeniami** — każde ma swój 7-bitowy adres. Na Uno: **SDA = A4, SCL = A5**. Na innych płytkach często osobne piny SDA/SCL.

<svg viewBox="0 0 600 200" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Schemat magistrali I2C - Arduino i trzy urządzenia podpięte do SDA i SCL">
<!-- Arduino -->
<rect x="20" y="40" width="100" height="120" rx="8" fill="#143527" stroke="#4ade80" stroke-width="2"/>
<text x="70" y="30" text-anchor="middle" font-size="12" fill="#a78bfa" font-weight="700">ARDUINO</text>
<text x="70" y="80" text-anchor="middle" font-size="10" fill="#ece6f0">SDA (A4)</text>
<text x="70" y="120" text-anchor="middle" font-size="10" fill="#ece6f0">SCL (A5)</text>
<!-- Pull-ups -->
<rect x="170" y="35" width="14" height="40" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<rect x="220" y="35" width="14" height="40" fill="#1e293b" stroke="#fbbf24" stroke-width="1.5"/>
<text x="195" y="28" text-anchor="middle" font-size="9" fill="#fbbf24">2 × 4,7 kΩ → 5V</text>
<line x1="177" y1="35" x2="177" y2="15" stroke="#fb923c" stroke-width="1.5"/>
<line x1="227" y1="35" x2="227" y2="15" stroke="#fb923c" stroke-width="1.5"/>
<line x1="177" y1="15" x2="227" y2="15" stroke="#fb923c" stroke-width="1.5"/>
<text x="245" y="18" font-size="10" fill="#fb923c">+5V</text>
<!-- Magistrale SDA i SCL -->
<line x1="120" y1="80" x2="177" y2="80" stroke="#a78bfa" stroke-width="2"/>
<line x1="177" y1="80" x2="560" y2="80" stroke="#a78bfa" stroke-width="2"/>
<line x1="120" y1="120" x2="227" y2="120" stroke="#60a5fa" stroke-width="2"/>
<line x1="227" y1="120" x2="560" y2="120" stroke="#60a5fa" stroke-width="2"/>
<text x="500" y="73" font-size="10" fill="#a78bfa">SDA</text>
<text x="500" y="113" font-size="10" fill="#60a5fa">SCL</text>
<!-- Urządzenia -->
<rect x="280" y="135" width="80" height="50" fill="#1e293b" stroke="#94a3b8"/>
<text x="320" y="155" text-anchor="middle" font-size="9" fill="#94a3b8">OLED 0x3C</text>
<line x1="320" y1="135" x2="320" y2="80" stroke="#a78bfa" stroke-width="1.5"/>
<line x1="335" y1="135" x2="335" y2="120" stroke="#60a5fa" stroke-width="1.5"/>
<rect x="390" y="135" width="80" height="50" fill="#1e293b" stroke="#94a3b8"/>
<text x="430" y="155" text-anchor="middle" font-size="9" fill="#94a3b8">BME280 0x76</text>
<line x1="430" y1="135" x2="430" y2="80" stroke="#a78bfa" stroke-width="1.5"/>
<line x1="445" y1="135" x2="445" y2="120" stroke="#60a5fa" stroke-width="1.5"/>
<rect x="500" y="135" width="80" height="50" fill="#1e293b" stroke="#94a3b8"/>
<text x="540" y="155" text-anchor="middle" font-size="9" fill="#94a3b8">RTC 0x68</text>
<line x1="540" y1="135" x2="540" y2="80" stroke="#a78bfa" stroke-width="1.5"/>
<line x1="555" y1="135" x2="555" y2="120" stroke="#60a5fa" stroke-width="1.5"/>
</svg>

**Klucz:** wszystkie urządzenia łączą SDA do SDA, SCL do SCL, GND wspólny, zasilanie wg potrzeb (3,3 V lub 5 V). Większość modułów ma **rezystory pull-up wbudowane**; jeśli żaden nie ma — daj dwa 4,7 kΩ do 5 V. Adresy są w datasheecie modułu.

```cpp
#include <Wire.h>
void setup() {
    Wire.begin();
    Serial.begin(9600);
    Serial.println("Skaner I2C - szukam urządzeń...");
    for (byte addr = 1; addr < 127; addr++) {
        Wire.beginTransmission(addr);
        if (Wire.endTransmission() == 0) {
            Serial.print("Znaleziono pod adresem 0x");
            Serial.println(addr, HEX);
        }
    }
}
void loop() {}
```

Ten skaner uruchom **przy pierwszym podłączeniu nowego modułu** — natychmiast wiesz, czy I²C działa i jaki ma adres.

## SPI — szybciej niż I²C, droższe w piny

Magistrala synchroniczna pełnoduplex, używana przez **wyświetlacze TFT, karty SD, RFID RC522, taśmy APA102**. Cztery linie:

| Linia | Funkcja | Pin Uno |
|-------|---------|---------|
| **MOSI** | Master Out, Slave In | D11 |
| **MISO** | Master In, Slave Out | D12 |
| **SCK** | zegar | D13 |
| **SS / CS** | wybór urządzenia (osobny pin na każde) | D10 (lub dowolny) |

Każde urządzenie SPI ma własny CS — to pozwala mieć **wiele urządzeń na tej samej magistrali**, „włączając" je naprzemiennie sygnałem CS.

```cpp
#include <SPI.h>
const int CS = 10;
void setup() {
    pinMode(CS, OUTPUT); digitalWrite(CS, HIGH);
    SPI.begin();
    Serial.begin(9600);
}
void loop() {
    digitalWrite(CS, LOW);             // wybieramy urządzenie
    byte odpowiedz = SPI.transfer(0xA5);
    digitalWrite(CS, HIGH);
    Serial.println(odpowiedz, HEX);
    delay(1000);
}
```

## UART / Serial — komunikacja przewodowa „prosta jak konstrukcja cepa"

Dwa przewody: **TX (nadawanie)** i **RX (odbiór)**, plus wspólny GND. Łączymy **na krzyż**: TX → RX, RX → TX. Prędkość po obu stronach taka sama (`baud`, np. 9600, 115200).

Uno ma **jeden sprzętowy UART**, wykorzystywany przez USB do programowania i Serial Monitor. By gadać z drugim Arduino albo modułem GPS/Bluetooth, **odłącz moduł podczas wgrywania** (kolizja na D0/D1) albo użyj:
- **SoftwareSerial** — UART „programowy" na dowolnych pinach (do ~57600 baud, jeden naraz),
- **Mega 2560** — ma 4 sprzętowe UART-y (`Serial1`, `Serial2`, `Serial3`),
- **AltSoftSerial / NeoSWSerial** — wydajniejsze warianty.

```cpp
#include <SoftwareSerial.h>
SoftwareSerial gps(4, 3);   // RX, TX
void setup() {
    Serial.begin(9600);
    gps.begin(9600);
}
void loop() {
    while (gps.available()) Serial.write(gps.read());
}
```

## 1-Wire — temperatura w wielu punktach

Magistrala **OneWire** używa *jednego* przewodu danych (plus GND, plus zasilanie) i pozwala podłączyć **wiele czujników DS18B20** na tym samym kablu — każdy ma fabryczny 64-bitowy adres. Klasyk pomiaru temperatury w domu/ogrodzie/CO.

```
      +5V o-------+---+---+---  (czerwony)
                  |   |   |
                 [DS18B20] [DS18B20] [DS18B20]
                  |   |   |
   D2  o---+------+---+---+---  (żółty)
           |
         [4.7k]   (pull-up jeden na całą magistralę)
           |
          +5V

      GND o-----------------+   (czarny)
```

```cpp
#include <OneWire.h>
#include <DallasTemperature.h>
const int ONE_WIRE_BUS = 2;
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

void setup() {
    Serial.begin(9600);
    sensors.begin();
}
void loop() {
    sensors.requestTemperatures();
    for (uint8_t i = 0; i < sensors.getDeviceCount(); i++) {
        Serial.print("Sensor ");
        Serial.print(i); Serial.print(": ");
        Serial.println(sensors.getTempCByIndex(i));
    }
    delay(2000);
}
```

## Konwersja poziomów 5 V ↔ 3,3 V

Mieszanie świata 5 V (Uno) i 3,3 V (Due, MKR, ESP32, wiele czujników nowej generacji) wymaga uwagi:

- **3,3 V → 5 V** na *wejściu Arduino* zwykle działa: 3,3 V to dla AVR „logiczna jedynka" (≥ 2,6 V).
- **5 V → 3,3 V** na *wejściu modułu 3,3 V* — **NIE** wpinaj wprost, spalisz pin. Rozwiązania:
  - dzielnik napięcia z dwóch rezystorów (1 kΩ + 2 kΩ — szybki, dla linii jednokierunkowych),
  - moduł konwertera poziomów (np. **TXS0108E** lub mały **BSS138**) — działa dwukierunkowo, do I²C i SPI; kosztuje 4–10 zł.

```
   5V Arduino TX o---[1k]---+---[2k]---o GND
                            |
                            o 3,3V do modułu RX
```

## Krótkie reguły, których warto przestrzegać

- **GND wspólny** dla wszystkich urządzeń — bez tego nic nie zadziała.
- **Pin to max 20 mA** (40 mA absolutne) — silników, taśm, przekaźników nie podłączaj wprost.
- **Długie kable to anteny** — przy długich liniach UART/1-Wire/I²C dodawaj kondensatory 100 nF blisko czujnika, w ostateczności użyj **RS-485** zamiast UART.
- **Resetuj świat sygnałem** — przy włączeniu wszystkie wyjścia powinny być w stanie *bezpiecznym* (silniki wyłączone, zawory zamknięte). Skonfiguruj `pinMode/digitalWrite` na samym początku `setup()`.

---

➡️ Dalej: **[04 — Czujniki — katalog modułów](04-czujniki.html)** — kilkadziesiąt gotowych „zmysłów", każdy z podłączeniem i przykładem kodu.
