# DSC PowerSeries Neo

**Sekcja:** 06 Centrale alarmowe · **Aktualizacja:** 2026-05

Kanadyjska firma DSC (Digital Security Controls), część Johnson Controls / Tyco. Seria PowerSeries Neo HS2016/2032/2064/2128, magistrala Corbus, klawiatury PK5500/HS2LCD, ekspandery HSM2108/HSM2208, radio HSM2HOST + PG9904P PIR.

## Kim jest DSC

DSC powstał w Toronto w 1979 r., dziś jest własnością **Johnson Controls** (przez Tyco). Międzynarodowa marka obecna w 160 krajach. W Polsce wciąż ustępuje popularnością Satelowi, ale jest preferowana przez większe firmy ochrony i sieciowe instalacje (markety, banki).

## Seria PowerSeries Neo — modele

Numer w nazwie odpowiada maksymalnej liczbie stref (zone). Wszystkie modele rozszerzane przez ekspandery HSM.

| Model | Wejścia na płycie | Max wejść | Wyjścia na płycie | Max wyjść | Partycje | Użytkownicy | Grade |
|---|---|---|---|---|---|---|---|
| **HS2016** | 6 | 16 | 2 | 4 | 2 | 48 | 2 |
| **HS2032** | 8 | 32 | 2 | 4 | 4 | 72 | 2 |
| **HS2064** | 8 | 64 | 2 | 16 | 8 | 95 | 3 |
| **HS2128** | 8 | 128 | 2 | 16 | 8 | 95 | 3 |

## Magistrala Corbus

Komunikacja między centralą a modułami odbywa się przez 4-żyłową magistralę Corbus: **RED (+12 V), BLK (GND), YEL (CLK), GRN (DAT)**. Maksymalna długość zależy od liczby modułów:

| Długość Corbus | Maks. modułów (klawiatury, ekspandery) |
|---|---|
| 300 m (1000 ft) | do 8 urządzeń |
| 600 m (2000 ft) | do 4 urządzeń |
| 1500 m | z modułem HSM2208 (Corbus Repeater) lub typu Power Supply |

> **Spadek napięcia** na +12 V — czujki PIR potrzebują min. 10,5 V do pracy. Dlatego dla długich linii dodajemy **HSM2204 / HSM2300** — dodatkowy zasilacz na końcu magistrali.

### Pętle z rezystorami EOL

DSC obsługuje 3 konfiguracje pętli wejściowej:

| Konfiguracja | Rezystor | Co wykrywa |
|---|---|---|
| NC (no resistor) | brak | tylko otwarcie/zamknięcie |
| SEOL (Single End of Line) | 1 × 5,6 kΩ na końcu | otwarcie + zwarcie |
| **DEOL (Double End of Line)** | 2 × 5,6 kΩ (jeden w czujce, drugi szereg.) | otwarcie + zwarcie + sabotaż |

DSC używa **5,6 kΩ** jako standard (Satel — 2,2 kΩ). Nie używaj rezystorów Satela w DSC bez przeprogramowania, bo centrala zgłosi „resistance fault".

## Klawiatury

| Model | Wyświetlacz | Funkcje | Cena (2026) |
|---|---|---|---|
| **PK5500** (PowerSeries klasyczna) | 2 × 16 znaków LCD | klasyczna, kompatybilna z PowerSeries i Neo | ~250 zł |
| **HS2LCD** | 2 × 16 znaków LCD biały | Neo natywna, alfanumeryczna | ~340 zł |
| **HS2LCDRF** | 2 × 16 znaków LCD + transceiver radiowy 433 MHz | klawiatura + odbiornik bezprzewodowy w 1 | ~580 zł |
| **HS2LCDWF** | jak wyżej + Wi-Fi (mobile programming) | najbardziej zaawansowana | ~720 zł |
| **HS2ICON** | ikonowa LCD (uproszczona) | tania alternatywa | ~190 zł |
| **HS2TCHP** | 7" dotykowy kolorowy | premium, wizualne mapy posesji | ~1850 zł |

## Moduły rozszerzeń

| Model | Funkcja |
|---|---|
| **HSM2108** | ekspander 8 wejść przewodowych (z 1 stykiem sabotażu) |
| **HSM2208** | ekspander 8 wyjść przekaźnikowych + repeater Corbus |
| **HSM2204** | 4 wyjścia przekaźnikowe + zasilacz 1,5 A (booster) |
| **HSM2300** | zasilacz 3 A + obudowa, do długich Corbus |
| **HSM2HOST** | transceiver bezprzewodowy 433 / 868 MHz dla czujek PowerG (2-way) |
| **HSM3408** | moduł audio (mikrofony, weryfikacja głosowa) |
| **HSM2955** | 4G/LTE komunikator do central monitoringu |
| **TL280R / TL2803GR** | Ethernet + GSM dual-path communicator |

## PowerG — system bezprzewodowy (2-way)

DSC PowerG to flagowy system bezprzewodowy DSC, działa w paśmie 433/868 MHz. Cechy:

- **Dwukierunkowa komunikacja** — centrala wie, że czujka żyje (heartbeat)
- **FHSS** (frequency hopping) — odporność na zakłócenia
- **128-bit AES encryption**
- **Zasięg do 2 km** w przestrzeni otwartej, ~200 m przez ściany
- **Bateria 8 lat** w PIR PG9904P (8 × dłużej niż konkurencja)

### Popularne czujki PowerG

| Model | Typ | Cena (2026) |
|---|---|---|
| **PG9904P** | PIR pet-immune (do 38 kg) | ~480 zł |
| **PG9914** | PIR z aparatem zdjęciowym (visual verification) | ~1300 zł |
| **PG9303** | kontaktron drzwiowy | ~270 zł |
| **PG9926** | czujka dymu | ~580 zł |
| **PG9985** | czujka wody / zalania | ~390 zł |
| **PG9905** | czujka stłuczenia szkła | ~520 zł |
| **PG9929** | kurtyna PIR zewnętrzna | ~890 zł |

## Oprogramowanie

### DLS V (DSC Downloading Software)

Aplikacja PC do programowania centrali. Połączenie przez:

- Kabel PCLINK USB
- Modem PSTN (legacy, rzadko już używane)
- Sieć IP (przez TL280R komunikator)
- Connect24 cloud (zdalna konfiguracja)

### ConnectAlarm — aplikacja mobilna

Oficjalna aplikacja iOS/Android. Wymaga komunikatora TL2803GR z modułem Cellular. Funkcje:

- Uzbrojenie/rozbrojenie partycji
- Push notifications
- Historia eventów (last 100)
- Sterowanie wyjściami (np. brama, oświetlenie)
- Integracja z PowerG video verification (PG9914 — zdjęcie z PIR podczas alarmu)

### AlarmInstall — narzędzie instalatora

App na tablet/telefon dla instalatora — diagnostyka magistrali, programowanie ekspresowe, lista urządzeń, sygnały RF.

## Monitoring profesjonalny

DSC od początku tworzony pod kątem profesjonalnych central monitoringu (PCO). Wspiera wszystkie standardowe formaty:

- **SIA DC-09** (TCP/IP) — preferowany przez agencje ochrony
- **Contact ID** (DTMF na linii PSTN, ale też GSM-CSD)
- **SIA Level 1-3**
- **Sur-Gard 4-2**

DSC HSM2955 (LTE) wysyła komunikaty **w < 30 s od zdarzenia** z potwierdzeniem dostarczenia. Dla Grade 3 (banki) komunikator musi mieć backup — np. TL280R (Ethernet) + HSM2955 (LTE) — kombo „dual-path".

## Integracja z Home Assistant

Integracja HACS *envisalink* (przez moduł EVL4 / EVL3 firmy Eyez-On). Wymaga sprzętu EVL ~500 zł.

```yaml
envisalink:
  host: 192.168.1.50
  panel_type: HONEYWELL  # or DSC
  user_name: user
  password: user
  code: !secret alarm_code
  port: 4025
  evl_version: 4
  
  zones:
    1:
      name: Drzwi front
      type: opening
    2:
      name: PIR salon
      type: motion
    # ...
  partitions:
    1:
      name: Parter
```

## Porównanie z konkurencją (Satel)

| Cecha | DSC Neo | Satel Integra |
|---|---|---|
| Polskie wsparcie | średnie (Aplica, dystrybutorzy) | bardzo dobre (producent, instalatorzy) |
| Rezystory EOL | 5,6 kΩ | 2,2 kΩ + 1,1 kΩ |
| System bezprzewodowy | PowerG 2-way, AES, 2 km | ABAX 2 (też 2-way, AES) |
| Aplikacja mobilna | ConnectAlarm | GUARD X |
| Konfiguracja | DLS V (płatna licencja) | DLOAD X (darmowa) |
| HA integracja | przez Envisalink (extra hw) | natywna (ETHM-1 Plus) |
| Komunikator LTE | HSM2955 (~1500 zł) | GSM-X-LTE (~780 zł) |
| Cena startowa (8 wejść) | ~1500 zł | ~1100 zł |

## Kiedy wybrać DSC zamiast Satela

- Międzynarodowy obiekt (sieci handlowe — preferują 1 producenta we wszystkich krajach)
- System monitoringu integruje się z platformą Tyco/JCI
- Wymagasz **PowerG video verification** (Satel ma podobne, ale mniej rozwinięte)
- Klient ma już infrastrukturę DSC
- Bardzo długie magistrale (Corbus do 1500 m z HSM2208)

## Co dalej

➡ [Risco LightSYS Plus](06-03-risco-lightsys.md)
