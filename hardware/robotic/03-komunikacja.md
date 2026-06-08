# Komunikacja i protokoły

Urządzenia muszą się jakoś porozumiewać ze sterownikiem i centralką. Wybór sposobu komunikacji wpływa na **zasięg, niezawodność, zużycie energii i koszt** całej instalacji — bardziej niż marka pojedynczego gadżetu. Najpierw decyzja fundamentalna: kabel czy radio.

## Przewodowo czy bezprzewodowo?

| | Przewodowo | Bezprzewodowo |
|---|---|---|
| **Niezawodność** | Najwyższa — nie ma zakłóceń radiowych | Zależna od zasięgu i otoczenia |
| **Zasilanie** | Często po tym samym kablu | Bateria lub osobne zasilanie |
| **Montaż** | Trudny w gotowym domu (kucie, kable) | Łatwy — przykręć i sparuj |
| **Koszt instalacji** | Wyższy (robocizna, okablowanie) | Niższy |
| **Najlepsze do** | Nowy dom/remont, instalacje krytyczne | Modernizacja, ogród, czujniki bateryjne |

W praktyce w istniejącym domu **dominuje radio**, a kabel ciągnie się tam, gdzie i tak są ściany otwarte albo gdzie niezawodność jest krytyczna (np. magistrala do rozdzielnicy).

## Protokoły bezprzewodowe

### WiFi
Sieć, którą już masz. **Zalety:** duża przepustowość, bez dodatkowego koncentratora, łatwo wpiąć ESP32/Shelly. **Wady:** prądożerne (słabe do urządzeń bateryjnych), router ma limit klientów, brak „mesh" między czujnikami. Dobre do urządzeń **zasilanych z sieci**: przekaźniki, kamery, sterowniki.

### Zigbee
Najpopularniejszy standard dla **tanich, bateryjnych czujników**. Tworzy **sieć kratową (mesh)**: urządzenia zasilane (żarówki, gniazdka) przekazują dane dalej, więc zasięg rośnie wraz z liczbą urządzeń. Niskie zużycie energii — czujnik chodzi na baterii **rok i dłużej**. Wymaga **koordynatora** (np. klucz USB Sonoff/ConBee przy Home Assistant albo bramka producenta). Świetny stosunek ceny do możliwości.

### Z-Wave
Filozofia jak Zigbee (mesh, niski pobór), ale pracuje na paśmie **868 MHz** (w Europie) — mniej zatłoczonym niż 2,4 GHz, więc bywa stabilniejszy i ma lepszy zasięg przez ściany. Urządzenia są **droższe** i jest ich mniej, za to bardziej „dopięte" certyfikacją. Również wymaga kontrolera.

### Thread + Matter
**Thread** to nowoczesna sieć mesh o niskim poborze (jak Zigbee, ale oparta na IP). **Matter** to nadrzędny **standard zgodności**, wspierany przez Apple, Google, Amazon i Samsung, który ma ujednolicić smart home — urządzenie „Matter" ma działać w każdym ekosystemie. Thread wymaga **Border Routera** (np. Apple HomePod, Google Nest Hub, niektóre bramki). To kierunek na przyszłość; w 2026 dojrzewa, ale nie zastąpił jeszcze w pełni Zigbee w tanich czujnikach.

### Bluetooth / BLE
Krótki zasięg, bardzo niski pobór. Dobre do urządzeń „przy telefonie" i tanich czujników (np. termometry **Xiaomi**), które przez bramkę BLE→WiFi trafiają do centralki. Słabe jako szkielet całego domu.

### LoRa / LoRaWAN
**Bardzo duży zasięg** (kilometry) przy minimalnej energii i małej przepustowości. Idealny do **odległych punktów**: czujnik w głębi działki, poziom wody w studni, stacja pogodowa na końcu ogrodu. Nie nadaje się do strumieni danych (kamery), świetny do rzadkich, krótkich pomiarów.

### RF 433 MHz
Najtańsze radio „włącz/wyłącz" — piloty, stare czujniki, gniazdka sterowane. Jednokierunkowe i bez szyfrowania (mała pewność, łatwe zakłócenia), ale grosze za sztukę. Z odbiornikiem RF (np. w bramce RFLink/Sonoff) można je wciągnąć do systemu.

## Protokoły przewodowe

- **1-Wire** — magistrala dwu/trójżyłowa do czujników, sztandarowy **DS18B20** (temperatura). Wiele czujników na jednym kablu, prosty, tani, niezawodny — idealny do pomiaru temperatury w wielu punktach.
- **I²C i SPI** — krótkie magistrale *wewnątrz* urządzenia: łączą mikrokontroler z czujnikami i wyświetlaczami na płytce (kilkadziesiąt cm). Nie do ciągnięcia po domu.
- **Modbus (RS-485)** — przemysłowy standard na skręconej parze; zasięg do ~1 km, bardzo odporny na zakłócenia. Spotykany w licznikach energii, falownikach PV, sterownikach grzewczych. Świetny do integracji „poważnych" urządzeń.
- **KNX** — profesjonalny standard instalacji budynkowych (magistrala). Niezawodny i rozbudowany, ale **drogi** i projektowany raczej przez instalatorów — wymieniamy dla porządku, nie jako wybór DIY.

## MQTT — wspólny język automatyki

Powyższe to „drogi", którymi płyną dane. **MQTT** to natomiast lekki **protokół wiadomości**, w którym urządzenia *publikują* odczyty i *subskrybują* polecenia za pośrednictwem **brokera** (np. Mosquitto). Model „publikuj/subskrybuj" znakomicie pasuje do automatyki:

```
ESP32 (czujnik gleby) --publikuje--> [ Broker MQTT ] --subskrybuje--> Home Assistant
   temat: ogrod/grzadka/wilgotnosc = 28%        \--> ESP32 (zawór): ogrod/grzadka/zawor = ON
```

MQTT jest niezależny od „radia": Tasmota, ESPHome, Zigbee2MQTT — wszystko może gadać przez jednego brokera, co spina różne technologie w jeden system. To de facto **lingua franca** domowej automatyki DIY.

## Porównanie — co wybrać

| Protokół | Zasięg | Pobór energii | Mesh | Koncentrator | Najlepsze do |
|----------|--------|---------------|------|--------------|--------------|
| **WiFi** | Średni (dom) | Wysoki | Nie | Router (masz) | Przekaźniki, kamery, ESP zasilane z sieci |
| **Zigbee** | Średni (mesh) | Bardzo niski | Tak | Koordynator | Tanie czujniki bateryjne, żarówki |
| **Z-Wave** | Dobry (868 MHz) | Bardzo niski | Tak | Kontroler | Stabilne czujniki premium |
| **Thread/Matter** | Średni (mesh) | Niski | Tak | Border Router | Przyszłościowa zgodność ekosystemów |
| **BLE** | Krótki | Bardzo niski | Częściowo | Bramka BLE | Czujniki „przy telefonie" |
| **LoRa** | Bardzo duży (km) | Bardzo niski | Nie | Brama LoRa | Odległe punkty, studnia, działka |
| **RF 433** | Krótki/średni | Niski | Nie | Odbiornik RF | Najtańsze piloty i gniazdka |
| **1-Wire** | Kabel (~kilka–kilkadziesiąt m) | — | — | — | Pomiar temperatury w wielu miejscach |
| **Modbus/RS-485** | Kabel (~1 km) | — | — | — | Liczniki, falowniki PV, przemysł |

## Praktyczne wskazówki

- **Pasmo 2,4 GHz bywa zatłoczone** (WiFi, Zigbee, BLE, mikrofalówka). Jeśli Zigbee „gubi" urządzenia, zmień kanał Zigbee tak, by nie pokrywał się z kanałem WiFi.
- **Buduj mesh świadomie** — kilka stale zasilanych urządzeń Zigbee (żarówki, gniazdka) tworzy szkielet, po którym „skaczą" czujniki bateryjne.
- **Nie mieszaj bez potrzeby** — im mniej różnych technologii, tym mniej koncentratorów i punktów awarii. Typowy zdrowy zestaw: **WiFi (urządzenia sieciowe) + Zigbee (czujniki) + MQTT (spoiwo)**.
- **Ogród i odległe punkty** to naturalne miejsce na **LoRa** albo dobrze ulokowany ESP32 z anteną zewnętrzną.

---

➡️ Dalej: **[04 — Czujniki i elementy wykonawcze](04-czujniki-aktuatory.html)** — konkretne „zmysły i mięśnie" z cenami.
