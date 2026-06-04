# PoE pasywne vs aktywne

**Sekcja:** 04 Instalacja CCTV · **Aktualizacja:** 2026-05

Standardy 802.3af/at/bt z negocjacją mocy, pasywne PoE bez negocjacji (tylko przekierowanie napięcia), injektory, splittery, midspan. Maksymalna długość i pułapki spalenia kamery.

## Dwie filozofie zasilania po kablu Ethernet

PoE (Power over Ethernet) to ogólne pojęcie dostarczania zasilania razem z sygnałem przez kabel UTP. Występuje w dwóch wariantach, które na pozór wyglądają tak samo, a różnią się radykalnie w środku.

| Cecha | PoE aktywne (802.3) | PoE pasywne |
|---|---|---|
| **Negocjacja** | tak — handshake LLDP/sygnaturowy | nie — napięcie jest zawsze |
| **Standard** | IEEE 802.3af/at/bt | brak — własność producenta (Ubiquiti, Mikrotik, OpenMesh) |
| **Napięcie** | 44–57 V DC (regulowane) | 12, 18, 24 lub 48 V DC stałe |
| **Wykrycie odbiornika** | tak (rezystor 25 kΩ) | nie — port zawsze pod napięciem |
| **Ochrona przed spaleniem** | tak (klasa zasilacza, ograniczenie prądu) | nie — pomyłka = śmierć urządzenia |
| **Cena switcha** | 500–3000 zł (8 portów) | 50–150 zł (1 injektor) |

## Standardy 802.3af / at / bt — porównanie

To są klasy mocy aktywnego PoE definiowane przez IEEE. Switch zarządzany sam określa, ile mocy dać każdemu portowi, na podstawie sygnałów wymienianych z urządzeniem.

| Standard | Rok | Nazwa | Moc na PSE (switch) | Moc na PD (urządzenie) | Pary |
|---|---|---|---|---|---|
| **802.3af** | 2003 | PoE | 15,4 W | 12,95 W | 2 pary (1-2, 3-6) |
| **802.3at** | 2009 | PoE+ | 30 W | 25,5 W | 2 pary |
| **802.3bt typ 3** | 2018 | PoE++ / 4PPoE | 60 W | 51 W | 4 pary |
| **802.3bt typ 4** | 2018 | PoE++ / Hi-PoE | 90 W | 71,3 W | 4 pary |

### Klasy mocy (Power Classes)

W trakcie handshake urządzenie deklaruje, ile mocy potrzebuje. Switch rezerwuje tylko tyle, ile trzeba.

| Klasa | Min P | Max P (na PD) | Typowe urządzenie |
|---|---|---|---|
| 0 (default) | 0,44 W | 12,95 W | brak deklaracji |
| 1 | 0,44 W | 3,84 W | VoIP, kamera mini |
| 2 | 3,84 W | 6,49 W | kamera bullet bez IR |
| 3 | 6,49 W | 12,95 W | kamera bullet z IR, dome |
| 4 | 12,95 W | 25,5 W | PTZ, IR mocny, grzałka |
| 5–6 | 30–60 W | 40–51 W | PTZ outdoor z grzałką |
| 7–8 | 60–90 W | 62–71,3 W | kamery 4K PTZ z wiper, AP Wi-Fi 6E |

## PoE pasywne — proste, tanie, niebezpieczne

Pasywne PoE to dosłownie „wpięcie zasilacza między pinki nieużywane przez 100Base-TX". Brak inteligencji, brak negocjacji — po prostu para żył przewodzi napięcie cały czas.

```
Pin 1, 2, 3, 6 -> sygnał Ethernet 100Base-TX
Pin 4, 5      -> + zasilanie (np. +24 V)
Pin 7, 8      -> - zasilanie (GND)
```

W standardzie 1000Base-T (Gigabit) wszystkie 4 pary niosą dane, więc pasywne PoE współistnieje z tym przez technikę „phantom power" (zasilanie nakładane na pary danych) — tak robi Ubiquiti i Mikrotik.

### Spalenie kamery — typowy scenariusz

> **Pułapka pasywnego PoE 24 V:** jeśli wepniesz w port pasywny PoE 24 V kamerę zaprojektowaną na 802.3af (44–57 V), prawdopodobnie nic się nie stanie — kamera nie zacznie pracować, bo widzi za niskie napięcie. Ale jeśli wepniesz kamerę 12 V w pasywne PoE 48 V, lub kamerę PoE+ w pasywny injector 24 V z błędną polaryzacją, scalak PoE w kamerze zostanie zniszczony. Producent nie uznaje gwarancji.

### Polaryzacja pinów

| Standard | Pin + V | Pin - V | Para danych |
|---|---|---|---|
| **802.3af mode A (alternative A)** | 1, 2 | 3, 6 | 1-2, 3-6 |
| **802.3af mode B (alternative B)** | 4, 5 | 7, 8 | nie używa zasilanych par |
| **802.3bt 4PPoE** | 1, 2 i 4, 5 | 3, 6 i 7, 8 | wszystkie 4 pary |
| **Ubiquiti passive 24 V** | 4, 5 | 7, 8 | mode B-like |
| **Mikrotik passive 18/24/48 V** | 4, 5 | 7, 8 | mode B-like |

## Składniki systemu PoE

### PSE — Power Sourcing Equipment

To urządzenie dostarczające energię. Dwa warianty:

- **Endspan** — switch PoE (np. TP-Link TL-SG1008P, Mikrotik CRS354-48P-4S+2Q). Najczęstsze rozwiązanie.
- **Midspan** — osobne urządzenie wpięte między zwykły switch a urządzenie końcowe (np. Microsemi PD-9001G-30). Stosowane gdy mamy istniejący switch bez PoE.

### PD — Powered Device

Urządzenie końcowe pobierające zasilanie: kamera IP, AP Wi-Fi, telefon VoIP, sensor IoT.

### Injector

Pojedynczy adapter wpinający zasilanie do jednej linii UTP. Ma 2 porty RJ45 — „IN" (do switcha, tylko dane) i „OUT" (do kamery, dane + zasilanie). Może być pasywny (50–100 zł) lub aktywny 802.3at (150–400 zł).

### Splitter

Odwrotność injektora — rozdziela kabel UTP+PoE na osobny kabel sieciowy i osobne wyjście zasilania (np. DC 5,5/2,1 mm na 12 V). Używane do kamer, które nie mają natywnego PoE.

**Splitter PoE 802.3at → 12 V DC** kosztuje 60–120 zł i pozwala zasilać starą kamerę 12 V po kablu UTP, jeśli switch ma PoE+.

## Budżet mocy switcha — najczęstszy błąd

Switch 8-portowy z naklejką „PoE 802.3at" nie znaczy, że każdy z 8 portów daje 30 W. Liczy się sumaryczny **PoE budget** — np. 65 W całkowicie. Przy 8 kamerach po 10 W jeszcze starczy, ale 4 PTZ po 25 W = 100 W i system się wyłączy.

| Model | Porty | Standard | PoE Budget | Średnio / port |
|---|---|---|---|---|
| TP-Link TL-SG1008P | 8 (4 PoE) | 802.3af/at | 64 W | 16 W |
| TP-Link TL-SG1218MP | 16 PoE + 2 SFP | 802.3af/at | 250 W | 15,6 W |
| Mikrotik CRS328-24P-4S+RM | 24 PoE + 4 SFP+ | 802.3af/at/bt | 500 W | 20 W |
| Cisco CBS350-24FP | 24 PoE + 4 SFP | 802.3at | 370 W | 15 W |
| Unifi USW-Pro-48-PoE | 48 PoE + 4 SFP+ | 802.3af/at/bt | 600 W | 12,5 W |

## Maksymalna długość a spadek napięcia

Standard mówi 100 m, ale w praktyce kabel CCA, słabe wtyki i niska temperatura potrafią ten dystans skrócić. Spadek napięcia na linii 100 m UTP 0,5 mm² jest istotny.

```
Rezystancja UTP Cat5e 0,5 mm² (24 AWG): ~9,4 Ω / 100 m / żyła
Para (tam i z powrotem): ~18,8 Ω / 100 m

Przy 802.3at 30 W (~600 mA przy 48 V):
Spadek = 0,6 A × 18,8 Ω = 11,3 V
Z 48 V dochodzi 36,7 V — nadal w specyfikacji (min 42 V na PD).
```

Dlatego standardy PoE pracują na 48 V — wyższe napięcie znacznie zmniejsza prąd przy tej samej mocy, a tym samym straty i spadek.

### PoE Extender

Dla dystansów powyżej 100 m używa się ekstenderów PoE — to malutkie aktywne urządzenie wpinane w środku trasy, wzmacniające sygnał i przekazujące zasilanie. Typowy ekstender daje +100 m (łącznie 200 m). Można kaskadować maks. 3 sztuki (300 m).

- TP-Link TL-POE160S — 802.3at extender, 30 W, ~200 zł
- Planet POE-E202 — kaskadowanie do 3×, ~350 zł
- Ubiquiti UFP-Extender — 1 Gb/s, 60 W passthrough, ~250 zł

## Praktyczne wskazówki

1. **Zawsze sprawdzaj klasę PoE kamery** przed dopięciem do switcha. Karta katalogowa: „PoE Class 3 (802.3af)" = max 12,95 W.
2. **Nie mieszaj pasywnego i aktywnego PoE** w jednym systemie. Etykietuj injektory.
3. **Switch z PoE Budget > 1,3× suma kamer** — zapas na klasę 4 grzałki w zimie.
4. **Dla PoE++ używaj Cat6 (FTP)** — kable Cat5e są na granicy specyfikacji 4-parowej.
5. **UPS na switchu PoE** — przy zaniku 230 V switch padnie i wyłączy wszystkie kamery, włącznie z domowymi.
6. **Surge protector RJ45** — przed wejściem kabla z zewnątrz do switcha (np. APC PNET1GB, Ubiquiti ETH-SP-G2). Pioruny indukują napięcia w długich kablach.

## Co dalej

➡ [Montaż i pozycjonowanie kamer](04-03-montaz-pozycjonowanie.md)
