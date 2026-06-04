# Risco LightSYS Plus

**Sekcja:** 06 Centrale alarmowe · **Aktualizacja:** 2026-05

Hybrydowa magistrala (przewodowa BUS + bezprzewodowa), smartphone app iRISCO, Risco Cloud, magistrala RS-485. Modele LightSYS Plus / LightSYS 2, do 512 stref, 32 partycje, Grade 3.

## Kim jest Risco

Risco Group to izraelski producent systemów zabezpieczeń założony w 1980 r. (dawniej *Rokonet*), z siedzibą w Tel Awiwie i fabrykami także we Włoszech. Marka bardzo popularna w Europie Zachodniej (Wielka Brytania, Francja, Włochy, Hiszpania), w Polsce dystrybuowana m.in. przez **Risco Polska / Volta**. Risco specjalizuje się w rozwiązaniach **hybrydowych** (jednoczesna obsługa czujek przewodowych i bezprzewodowych na jednej centrali) oraz w **weryfikacji wizyjnej** alarmu (VUpoint).

**Grade 3** wg PN-EN 50131-3 — obiekty o podwyższonym ryzyku (banki, jubilerzy, obiekty wymagane przez ubezpieczyciela). LightSYS Plus z odpowiednią konfiguracją (komunikator dual-path, sabotaż, zasilanie awaryjne) spełnia Grade 3, a w wariancie podstawowym Grade 2 — jak większość central domowych.

## Seria LightSYS — modele

LightSYS to rodzina hybrydowych central modułowych. Aktualnie sprzedawany jest **LightSYS Plus** (następca LightSYS 2). Różnice w pojemności wynikają z zastosowanych ekspanderów magistrali.

| Cecha | LightSYS 2 | LightSYS Plus |
| --- | --- | --- |
| Wejścia na płycie | 8 (rozbudowa do 50) | 8 (rozbudowa do 512) |
| Max wejść (stref) | 50 | **512** |
| Partycje | 4 | **32** |
| Grupy (podstrefy) | 4 na partycję | 4 na partycję |
| Wyjścia max | 32 | 196 |
| Użytkownicy (kody) | 32 | 500 |
| Magistrale BUS | 1 × RS-485 | **3 × RS-485** (rozdzielone) |
| Grade | 2 / 3 | 2 / 3 |

LightSYS Plus jest „przeskalowalny" — ta sama centrala obsłuży mały dom (8 czujek bezprzewodowych) i duży obiekt (512 stref przewodowych na trzech niezależnych magistralach). To główna przewaga Risco nad konkurencją z wyraźnie podzielonymi seriami.

## Magistrala RS-485 BUS

W odróżnieniu od 4-żyłowego Corbus (DSC) czy magistrali Satel, Risco używa przemysłowego standardu **RS-485**. Magistrala 4-żyłowa: **RED (+13,8 V), BLACK (GND), YEL (BUS A), GRN (BUS B)** — para danych A/B jest różnicowa (mniejsza podatność na zakłócenia).

| Parametr magistrali | Wartość |
| --- | --- |
| Maks. długość jednej magistrali | 300 m (przewód alarmowy) |
| Topologia | liniowa (daisy-chain) lub gwiazda |
| Urządzeń na magistrali | do 32 modułów BUS |
| Magistrale w LightSYS Plus | 3 niezależne (BUS 1/2/3) |

**Rezystory terminujące BUS** — przy długich magistralach (powyżej ~150 m) lub problemach z komunikacją należy załączyć zworkę/rezystor terminacji **120 Ω** na ostatnim module w linii (typowe dla RS-485). Risco udostępnia tę zworkę na ekspanderach BUS.

### Rezystory końcowe wejść (EOL)

Wejścia przewodowe Risco obsługują pętle z rezystorami końcowymi. Domyślny rezystor Risco to **2 × 2,2 kΩ** (konfiguracja podwójna — wykrywa otwarcie, zwarcie i sabotaż). Konfigurowalne także jako 1 × 4,7 kΩ lub NC.

| Konfiguracja | Rezystor | Co wykrywa |
| --- | --- | --- |
| N/C | brak | tylko otwarcie obwodu |
| 1 × EOL | 1 × 2,2 kΩ (lub 4,7 kΩ) | otwarcie + zwarcie |
| **2 × EOL (DEOL)** | 2 × 2,2 kΩ | otwarcie + zwarcie + sabotaż (2 czujki na 1 wejściu) |

### Ekspandery wejść / wyjść

| Model | Funkcja |
| --- | --- |
| **RP432EZ8** | ekspander 8 wejść przewodowych (BUS Zone Expander) |
| **RP432EO** | ekspander 4 wyjść przekaźnikowych |
| **RP432PS** | ekspander zasilacza 1,5 A (booster) do długich magistral |
| **RP512B** | moduł rozszerzenia magistrali (BUS splitter / izolator) |
| **RP432EZ** | moduł I/O — wejścia/wyjścia mieszane |

## System bezprzewodowy 2-way

Risco oferuje dwa systemy bezprzewodowe, oba **dwukierunkowe (2-way)** — centrala potwierdza stan czujki i jej baterii (heartbeat). Pasma: **433 MHz** (starszy) oraz **868 MHz** (zalecany, mniej zakłóceń).

- **iWISE** — flagowe czujki PIR / dual-tech (PIR + mikrofala), 2-way, antymasking
- **eyeWAVE** — czujki PIR z wbudowaną **kamerą** (zdjęcie sceny w momencie alarmu — visual verification)
- **WatchOUT** — zewnętrzne czujki dual-tech (PIR + MW) odporne na zwierzęta i warunki atmosferyczne

Odbiornik bezprzewodowy podpina się do magistrali BUS jako moduł **WM (Wireless Module)**.

| Model bezprzewodowy | Typ | Pasmo | Cena (2026) |
| --- | --- | --- | --- |
| **iWISE BWare 2-way** | PIR dual-tech (PIR+MW) pet-immune | 868 MHz | ~390 zł |
| **eyeWAVE PIR Camera** | PIR + kamera (visual verification) | 868 MHz | ~950 zł |
| **WatchOUT 2-way** | zewnętrzna dual-tech | 868 MHz | ~780 zł |
| **Magnetic Contact 2-way** | kontaktron drzwiowy/okienny | 868 MHz | ~210 zł |
| **Smoke Detector 2-way** | czujka dymu optyczna | 868 MHz | ~430 zł |
| **Panda 2-way Keypad** | klawiatura bezprzewodowa | 868 MHz | ~520 zł |
| **Panic Button 2-way** | pilot napadowy / brelok | 868 MHz | ~150 zł |

Na jednej centrali LightSYS Plus można mieszać czujki przewodowe (BUS / wejścia analogowe) i bezprzewodowe 868 MHz — to definicja **centrali hybrydowej**. Czujki bezprzewodowe zajmują „strefy" w tej samej puli co przewodowe.

## Komunikacja

LightSYS Plus ma slot na karty komunikacyjne (plug-in). Dla Grade 3 stosuje się tor dual-path (IP + LTE).

| Moduł | Funkcja |
| --- | --- |
| **IP Module** | Ethernet — Risco Cloud, monitoring TCP/IP (SIA IP DC-09) |
| **GSM / GPRS Module** | 2G/3G — SMS, CSD, GPRS do chmury |
| **LTE Module (Cat-M / 4G)** | szybki tor komórkowy, zalecany do nowych instalacji |
| **Risco Cloud** | chmura producenta — relay między centralą a aplikacją iRISCO |

Risco Cloud działa jak SATEL P2P u Satela — centrala loguje się do chmury, aplikacja iRISCO łączy się do tej samej chmury, ruch jest „przekazywany" (relay). Nie trzeba przekierowywać portów ani konfigurować VPN. Połączenie szyfrowane.

## Aplikacja iRISCO i Risco Cloud

**iRISCO** to oficjalna aplikacja mobilna (iOS / Android). Wymaga aktywnego konta w Risco Cloud i modułu IP lub GSM/LTE w centrali. Funkcje:

- Uzbrojenie / rozbrojenie partycji i grup
- Podgląd stanu stref, pominięcia (bypass)
- Push notifications (alarm, sabotaż, awaria zasilania)
- Historia zdarzeń
- Sterowanie wyjściami (brama, oświetlenie, rolety)
- **Video on demand** i **visual verification** — podgląd z kamer VUpoint oraz zdjęć z czujek eyeWAVE

Dostęp z poziomu przeglądarki przez **Risco Cloud Web** (panel właściciela) oraz panel instalatora do zdalnego serwisu.

## Konfiguracja — Configuration Software (CS)

Centralę programuje się przez **Risco Configuration Software (CS)** — darmowa aplikacja PC. Połączenie przez:

- USB (kabel CP-USB na płycie centrali)
- Sieć IP / Risco Cloud (zdalna konfiguracja przez instalatora)
- Klawiatura LCD (programowanie lokalne menu instalatora)

```
; Przykładowa struktura programowania (Configuration Software)
System > Partitions
  Partition 1: "Parter"
  Partition 2: "Pietro"
Zones
  Zone 001: Wired,  DEOL 2.2k, Entry/Exit,  Part.1   "Drzwi front"
  Zone 002: Wired,  EOL 2.2k,  Instant,     Part.1   "PIR salon"
  Zone 017: Wireless 868, iWISE, Interior,  Part.2   "PIR pietro"
Communication
  IP Module:   Risco Cloud = ON,  Monitoring SIA-IP = ON
  LTE Module:  Backup path  = ON  (Grade 3 dual-path)
Users
  User 01: Master,  code 6 digits
  User 02: Standard, Part.1 only
```

### Klawiatury

| Model | Typ | Cena (2026) |
| --- | --- | --- |
| **Elegant LCD** | klawiatura LCD przewodowa (BUS), elegancka obudowa | ~420 zł |
| **Elegant LCD + Proximity** | LCD + wbudowany czytnik zbliżeniowy (breloki / karty) | ~520 zł |
| **Panda LCD (przewodowa)** | ekonomiczna klawiatura BUS | ~310 zł |
| **Panda 2-way (bezprzewodowa)** | klawiatura radiowa 868 MHz | ~520 zł |
| **Czytnik proximity (zewnętrzny)** | moduł BUS do breloków RFID | ~260 zł |

**Proxy / breloki zbliżeniowe** — klawiatury Risco z czytnikiem proximity pozwalają uzbrajać/rozbrajać przez zbliżenie breloka, bez wpisywania kodu. Wygodne dla większej liczby użytkowników. Szczegóły kart i breloków — patrz 09-03 Użytkownicy, kody, piloty.

## Video verification — VUpoint

**VUpoint** to system kamer IP Risco zintegrowanych bezpośrednio z centralą i chmurą. To wyróżnik Risco — pełne kamery IP (a nie tylko zdjęcia z PIR) są częścią systemu alarmowego.

- Kamery IP (kopułkowe, bullet, wewnętrzne) podpinane do Risco Cloud
- Powiązanie kamery ze strefą — alarm w strefie automatycznie pokazuje live z kamery w aplikacji iRISCO
- **Live view** i nagrania na żądanie z dowolnego miejsca
- Weryfikacja zdarzenia przed wysłaniem patrolu (redukcja fałszywych alarmów dla agencji ochrony)

Uzupełnieniem jest **eyeWAVE** — czujka PIR z kamerą, która robi zdjęcie sceny dokładnie w chwili wzbudzenia (działa też bezprzewodowo, gdzie nie ma kamery IP).

## Monitoring profesjonalny

LightSYS Plus współpracuje ze stacjami monitoringu (PCO) w standardowych formatach:

- **SIA IP DC-09** (TCP/IP przez IP Module) — preferowany przez agencje
- **Contact ID** (przez GSM/LTE lub PSTN)
- **SIA** (Level 1-3)
- Powiadomienia follow-me (SMS / push) równolegle do monitoringu

Dla **Grade 3** stosuje się tor **dual-path**: IP Module (Ethernet) jako tor podstawowy + LTE Module jako backup — analogicznie do kombinacji DSC TL280R + HSM2955.

## Porównanie z konkurencją

| Cecha | Risco LightSYS Plus | Satel Integra | DSC PowerSeries Neo |
| --- | --- | --- | --- |
| Kraj producenta | Izrael | Polska (Gdańsk) | Kanada (Johnson Controls) |
| Typ centrali | hybrydowa (BUS + RF) | hybrydowa (BUS + ABAX) | hybrydowa (Corbus + PowerG) |
| Magistrala | RS-485 (3 niezależne) | magistrala Satel (ekspandery) | Corbus 4-żyłowy |
| Rezystory EOL | 2 × 2,2 kΩ | 2,2 kΩ + 1,1 kΩ | 5,6 kΩ |
| System bezprzewodowy | 2-way 433/868 MHz (iWISE, eyeWAVE) | ABAX 2 (2-way, AES) | PowerG 2-way (AES, 2 km) |
| Chmura | **Risco Cloud** (relay) | SATEL P2P (relay) | Connect24 |
| Aplikacja mobilna | iRISCO | GUARD X | ConnectAlarm |
| Weryfikacja wizyjna | **VUpoint (kamery IP) + eyeWAVE** | zdjęcia z czujek, kamery przez integrację | PowerG visual (PG9914 — zdjęcia z PIR) |
| Konfiguracja | Configuration Software (darmowa) | DLOAD X (darmowa) | DLS V (płatna licencja) |
| Max stref / partycje | 512 / 32 | 256 / 32 (Integra 256 Plus) | 128 / 8 |
| Cena startowa (8 wejść) | ~1400 zł | ~1100 zł | ~1500 zł |

## Kiedy wybrać Risco

- Gdy chcesz jedną centralę „na wyrost" — od małego domu po duży obiekt (512 stref, 3 magistrale)
- Gdy kluczowa jest **weryfikacja wizyjna** wbudowana w system (VUpoint kamery IP + eyeWAVE) — Risco ma to najlepiej dopracowane
- Mocno rozproszone instalacje bezprzewodowe 868 MHz 2-way
- Obiekt europejski, gdzie obecny jest serwis Risco i instalator zna ekosystem iRISCO
- Gdy zależy na chmurze bez konfiguracji portów (Risco Cloud relay)

W Polsce baza instalatorów i serwisu Risco jest **mniejsza niż Satela**. Przed wyborem warto sprawdzić dostępność lokalnego autoryzowanego instalatora oraz części zamiennych — Satel pozostaje „bezpiecznym" wyborem dla typowego domu w PL.
