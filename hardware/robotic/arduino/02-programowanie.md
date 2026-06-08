# Programowanie Arduino — IDE i język

Kod Arduino piszemy w **C/C++**, ale otoczonym przyjazną warstwą bibliotek i obowiązkową strukturą dwóch funkcji: `setup()` i `loop()`. Nie musisz znać C++ od podszewki — wystarczy podstawowa składnia i kilka funkcji wbudowanych, by zacząć sterować sprzętem.

## Środowiska programistyczne

### Arduino IDE 2.x (rekomendacja na start)
Oficjalne, darmowe, dostępne na Windows/macOS/Linux z [arduino.cc](https://www.arduino.cc/en/software). IDE 2.x ma:
- autouzupełnianie, podpowiedzi błędów na żywo,
- wbudowany **Serial Monitor** i **Serial Plotter** (wykres zmiennej w czasie),
- menedżer płytek (`Boards Manager`) i bibliotek (`Library Manager`) — jedno kliknięcie i masz wsparcie dla ESP32, Mega, Nano Every,
- debuger sprzętowy (dla wybranych płytek z portem SWD).

### PlatformIO (dla bardziej zaawansowanych)
Wtyczka do VS Code: ten sam kod, ale z porządnym edytorem, Gitem, kontrolą wersji bibliotek (`platformio.ini`) i wsparciem dla **wszystkich** popularnych mikrokontrolerów (Arduino, ESP, STM32, Raspberry Pi Pico). Dla projektów wielomodułowych lub zespołowych — bezkonkurencyjne.

> Zacznij od Arduino IDE 2.x. Przejdź na PlatformIO, gdy zaczniesz mieć kilka projektów naraz albo będziesz tęsknić za normalnym edytorem.

## Pierwsze uruchomienie

1. Podłącz Arduino do USB.
2. **Tools → Board** → wybierz model (np. *Arduino Uno*).
3. **Tools → Port** → wybierz port (np. `COM3`, `/dev/ttyACM0`).
4. **File → Examples → 01.Basics → Blink** — wczyta szablonowy program mrugający diodą L na płytce.
5. Klik **Upload** (strzałka). Po kompilacji i wgraniu dioda zacznie mrugać 1 Hz.

Brak portu? → patrz uwaga o sterowniku CH340 w rozdziale 01.

## Struktura sketcha

Każdy program Arduino ma dwie obowiązkowe funkcje:

```cpp
void setup() {
    // Uruchamia się RAZ po starcie/resecie.
    // Konfigurujesz tu piny, otwierasz Serial, inicjalizujesz biblioteki.
}

void loop() {
    // Wykonuje się W KÓŁKO, dopóki płytka ma zasilanie.
    // Tu sterujesz, czytasz czujniki, podejmujesz decyzje.
}
```

Wszystko inne (zmienne globalne, funkcje pomocnicze, `#include`) zapisujesz **przed** `setup()`. Plik z kodem ma rozszerzenie `.ino` i leży w folderze o tej samej nazwie.

### Klasyczny „Blink" linijka po linijce

```cpp
const int LED_PIN = 13;   // stała — diodę L na Uno mamy na pinie 13

void setup() {
    pinMode(LED_PIN, OUTPUT);   // pin 13 jako wyjście
}

void loop() {
    digitalWrite(LED_PIN, HIGH); // zapal
    delay(500);                  // poczekaj 0,5 s
    digitalWrite(LED_PIN, LOW);  // zgaś
    delay(500);                  // poczekaj 0,5 s
}
```

## C/C++ w wersji praktycznej dla Arduino

### Typy danych — tylko te, których naprawdę używasz

| Typ | Rozmiar | Zakres / opis |
|-----|---------|---------------|
| `bool` | 1 B | `true` / `false` |
| `byte` / `uint8_t` | 1 B | 0–255 — flagi, jasność PWM, znaki |
| `int` | 2 B (AVR) / 4 B (32-bit) | -32 768 do 32 767 / ±2 mld — domyślny |
| `unsigned int` | jw. | 0 do 65 535 / 0 do 4 mld |
| `long` | 4 B | ±2 mld — milisekundy, duże liczby |
| `unsigned long` | 4 B | 0 do ~4,29 mld — wynik `millis()` |
| `float` | 4 B | liczba zmiennoprzecinkowa, ~7 cyfr precyzji |
| `String` | dynamiczny | obiekt — wygodny, ale **uważaj na pamięć** |
| `char[]` | N B | klasyczny napis C — szybszy i bardziej przewidywalny |

> Na AVR (Uno/Nano) `int` to **2 bajty** — łatwo przekroczyć zakres. Wynik `millis()` zwracaj zawsze do `unsigned long`.

### Stałe i deklaracje
```cpp
const int BUTTON_PIN = 2;          // czytelniej niż „magiczna 2" w kodzie
#define LED_COUNT 30                // dyrektywa preprocesora — bez typu
const float CALIBRATION = 1.034;
```

### Operatory najważniejsze
- arytmetyczne: `+ - * / %`
- porównania: `== != < > <= >=`
- logiczne: `&& || !`
- bitowe: `& | ^ ~ << >>`
- przypisanie: `=`, `+=`, `-=`, `<<=`

### Sterowanie przepływem
```cpp
if (temp > 25) {
    digitalWrite(FAN, HIGH);
} else if (temp > 22) {
    analogWrite(FAN, 128);   // pół mocy
} else {
    digitalWrite(FAN, LOW);
}

for (int i = 0; i < 10; i++) {
    Serial.println(i);
}

while (Serial.available()) {
    char c = Serial.read();
    // ...
}

switch (mode) {
    case 1: setRed();   break;
    case 2: setGreen(); break;
    default: setOff();
}
```

### Funkcje
```cpp
int dwaRazy(int x) {
    return x * 2;
}

void mrugnij(int pin, int ile) {
    for (int i = 0; i < ile; i++) {
        digitalWrite(pin, HIGH); delay(100);
        digitalWrite(pin, LOW);  delay(100);
    }
}
```

## Funkcje wbudowane — twoje codzienne narzędzia

### Cyfrowe I/O
```cpp
pinMode(pin, INPUT);          // wejście (Hi-Z, „pływające")
pinMode(pin, INPUT_PULLUP);   // wejście z wewnętrznym rezystorem podciągającym do 5V
pinMode(pin, OUTPUT);         // wyjście

digitalWrite(pin, HIGH);      // 5 V (lub 3,3 V na 32-bit)
digitalWrite(pin, LOW);       // 0 V

int v = digitalRead(pin);     // HIGH (1) lub LOW (0)
```

### Analogowe
```cpp
int raw = analogRead(A0);     // 0–1023 (Uno, 10-bit ADC)
float volts = raw * 5.0 / 1023.0;

analogWrite(pin, 0..255);     // PWM — tylko piny oznaczone „~"
```

### Czas
```cpp
delay(1000);             // wstrzymaj 1 s — BLOKUJE wszystko
delayMicroseconds(50);   // mikrosekundy
unsigned long t = millis();    // ms od startu
unsigned long u = micros();    // µs od startu (przepełnia się po ~70 min)
```

### Serial — komunikacja z komputerem
```cpp
void setup() {
    Serial.begin(9600);        // 9600 b/s — standard; też 115200 dla szybkości
    while (!Serial) { ; }      // (na Leonardo/Micro — czeka aż USB gotowy)
    Serial.println("Start!");
}

void loop() {
    Serial.print("Temperatura: ");
    Serial.print(temp);
    Serial.println(" *C");
    delay(1000);
}
```

W **Serial Monitor** (lupka, prawy górny róg IDE) zobaczysz wypisy. **Serial Plotter** narysuje wykres, jeśli wypisujesz liczby oddzielone spacją/tabem/przecinkiem.

### Mapowanie i ograniczanie
```cpp
int duty = map(raw, 0, 1023, 0, 255);   // przeskaluj ADC na PWM
int v = constrain(x, 0, 100);            // przytnij do zakresu
float r = random(10, 100);               // losowa 10..99
```

## Biblioteki — sekret Arduino

Większość modułów ma gotową bibliotekę: dołączasz `#include`, tworzysz obiekt, wywołujesz metody. Nie pisz od zera tego, co już zrobione.

```cpp
#include <Servo.h>      // biblioteka wbudowana
Servo myServo;

void setup() {
    myServo.attach(9);  // sygnał PWM na pinie 9
}

void loop() {
    myServo.write(0);   delay(1000);
    myServo.write(90);  delay(1000);
    myServo.write(180); delay(1000);
}
```

**Library Manager** (Sketch → Include Library → Manage Libraries) ma dziesiątki tysięcy gotowych bibliotek: `DHT sensor library`, `Adafruit SSD1306`, `PubSubClient` (MQTT), `OneWire`, `FastLED` (LED-y adresowalne), `Servo`, `Wire` (I2C), `SPI`. Wpisz nazwę modułu → zwykle pierwszy wynik to to, czego szukasz.

## `delay()` kontra `millis()` — najważniejsza lekcja

`delay(1000)` **blokuje wszystko** na sekundę — w tym czasie nie czytasz przycisków, nie odbierasz Seriala, nie aktualizujesz LCD. Dla prostego Blinka to OK, dla automatyki — katastrofa.

Wzorzec „nie blokujący" z `millis()`:

```cpp
const int LED = 13;
const unsigned long INTERWAL = 500;
unsigned long ostatniaZmiana = 0;
bool stan = false;

void setup() {
    pinMode(LED, OUTPUT);
}

void loop() {
    unsigned long teraz = millis();
    if (teraz - ostatniaZmiana >= INTERWAL) {
        ostatniaZmiana = teraz;
        stan = !stan;
        digitalWrite(LED, stan);
    }

    // Tu możesz dalej czytać przyciski, czujniki, Serial — bez przerwy.
}
```

> Naucz się tego wzorca raz. Cała sensowna automatyka opiera się na nim.

## Przerwania (interrupts)

Gdy zdarzenie *musi* być wykryte natychmiast (impuls enkodera, przycisk awaryjny), używamy przerwań sprzętowych:

```cpp
volatile int licznik = 0;   // volatile — bo zmienia ją przerwanie

void przerwanie() {
    licznik++;
}

void setup() {
    pinMode(2, INPUT_PULLUP);
    attachInterrupt(digitalPinToInterrupt(2), przerwanie, FALLING);
    Serial.begin(9600);
}

void loop() {
    Serial.println(licznik);
    delay(500);
}
```

Reguły: funkcja przerwania **musi być krótka**, nie wolno w niej używać `delay()`, `Serial.print()` ani długich obliczeń. Zmienne dzielone z `loop()` deklaruj jako `volatile`.

## Pamięć — uważaj, jest jej mało

ATmega328P na Uno ma **tylko 2 KB RAM**. Łatwo ją wyczerpać dużymi `String`-ami lub tablicami. Trzy techniki:
- **`F("napis")`** — trzyma stałe napisy we Flashu zamiast w RAM:
  ```cpp
  Serial.println(F("To nie zjada cennego RAM-u"));
  ```
- **`PROGMEM`** — duże tablice (np. mapy bitmap LED-ów) trzymaj we Flashu:
  ```cpp
  const byte logo[] PROGMEM = { /* 1 KB danych */ };
  ```
- **`EEPROM`** — 1 KB nieulotnej pamięci na kalibracje i ustawienia:
  ```cpp
  #include <EEPROM.h>
  EEPROM.write(0, 42);
  byte x = EEPROM.read(0);
  ```

## Częste pomyłki początkujących

- **Brak `pinMode(..., OUTPUT)` przed `digitalWrite`** — pin pozostaje wejściem, nic się nie dzieje.
- **`String` w pętli** — fragmentacja pamięci, restarty po godzinach. Używaj `char[]` albo F-makra.
- **`int` na milisekundy** — `millis()` zwraca `unsigned long`. Z `int` przepełni się po 32 s.
- **Wspólne piny bez analizy** — D11/D12/D13 to SPI; D0/D1 to UART używany przez USB (jeśli ich użyjesz, wgrywanie programu staje się trudne).
- **`Serial.begin(9600)` w `setup()` ale brak otwartego Monitora** — Leonardo czeka w pętli `while(!Serial)`; jeśli nie otworzysz Monitora, program nie ruszy.
- **`delay()` w funkcji przerwania** — system się zawiesi.

## Kompletny przykład: przycisk włącza i wyłącza diodę

```cpp
const int LED    = 13;
const int BUTTON = 2;

bool ledState = false;
bool lastButton = HIGH;       // INPUT_PULLUP — domyślnie HIGH
unsigned long lastDebounce = 0;
const unsigned long DEBOUNCE_MS = 50;

void setup() {
    pinMode(LED, OUTPUT);
    pinMode(BUTTON, INPUT_PULLUP);  // przycisk między pinem a GND
    Serial.begin(9600);
}

void loop() {
    bool reading = digitalRead(BUTTON);

    // debouncing — ignoruj zmiany szybsze niż 50 ms
    if (reading != lastButton) {
        lastDebounce = millis();
    }
    if (millis() - lastDebounce > DEBOUNCE_MS) {
        if (reading == LOW && lastButton == HIGH) {
            // wykryto naciśnięcie
            ledState = !ledState;
            digitalWrite(LED, ledState);
            Serial.print("LED: ");
            Serial.println(ledState ? "ON" : "OFF");
        }
    }
    lastButton = reading;
}
```

To już prawdziwa automatyka: nie blokuje, ma debouncing, wypisuje stan. Świetny szablon na początek.

---

➡️ Dalej: **[03 — I/O i protokoły komunikacyjne](03-io-protokoly.html)** — wnikamy w cyfrowe/analogowe wejścia, PWM, I2C, SPI, UART z gotowymi schematami podłączeń.
