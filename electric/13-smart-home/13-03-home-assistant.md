# Home Assistant — centrum sterowania

## Czym jest Home Assistant

**Home Assistant** (HA) to open-source platforma do zarządzania domem inteligentnym. Działa **lokalnie**, ma ~3000 integracji z urządzeniami i usługami, jest darmowy.

Projekt rozwija fundacja Open Home Foundation + komercyjna firma Nabu Casa (subskrypcja chmurowa zdalnego dostępu, ~6,5 €/mies. — opcjonalna).

## Filozofia

- **Lokalność i prywatność** — wszystko działa we własnej sieci LAN, bez chmur producentów
- **Otwartość** — kod GPLv2, własność użytkownika, możliwość modyfikacji
- **Elastyczność** — automatyzacje od najprostszych po skomplikowane skrypty Python
- **Integracje** — Zigbee, Z-Wave, Matter, WiFi, MQTT, KNX, BLE, RS-485, Modbus, dziesiątki API

## Hardware

Najczęstsze wybory platformy sprzętowej:

| Platforma | Cena | Wydajność | Dla kogo |
|---|---|---|---|
| **Raspberry Pi 4 / 5** + SSD | 400-700 zł | dobra | start, średnie instalacje |
| **Home Assistant Green** | ~450 zł | dobra | plug-and-play, początkujący |
| **Home Assistant Yellow** | ~1000-1500 zł | dobra + slot M.2 + PoE + Zigbee/Thread | bardziej zaawansowani |
| **Mini PC x86** (NUC, Beelink) | 800-2500 zł | bardzo dobra | duże instalacje, dodatki, VM-y |

Dla ~50 urządzeń wystarczy Raspberry Pi 4 + SSD via USB3. Powyżej 100 urządzeń, kamery, ML — mini PC x86.

## Warianty instalacji

| Wariant | Co to | Plusy | Minusy |
|---|---|---|---|
| **HAOS** (Home Assistant Operating System) | OS dedykowany — Buildroot + Supervisor | najprostsze, Add-ons, snapshoty | dedykowany hardware |
| **HA Container** | Docker container | szybkie, można obok innego | brak Add-ons |
| **HA Supervised** | Linux + Supervisor | Add-ons + własny OS | wymagania, ryzyko niezgodności |
| **HA Core** | venv Pythona | ręczna kontrola | bez Supervisora, ręczne wszystko |

**Rekomendacja:** dla większości użytkowników **HAOS** — to oficjalnie zalecane.

## Interfejs Lovelace

Interfejs HA nazywa się **Lovelace** — modularny dashboard z kart (cards).

- **Cards** wbudowane: encje, wykresy, mapy, kamery, przyciski, scenariusze
- **Custom cards** ze społeczności (HACS — Home Assistant Community Store) — setki dodatkowych
- **Dashboard mobilne i desktopowe** — responsywne
- **Aplikacja mobilna** iOS/Android — powiadomienia push, lokalizacja

## Konfiguracja

Można konfigurować na dwa sposoby (najczęściej **mieszane**):

### Przez UI

Większość integracji to dziś **Integration → Add Integration → wybierz z listy**. Konfigurujesz wszystko przez formularze.

### Przez YAML

Niskopoziomowa konfiguracja w plikach (`configuration.yaml`, `automations.yaml`, `scripts.yaml`):

```yaml
automation:
  - alias: "Światło w garażu po otwarciu bramy"
    trigger:
      - platform: state
        entity_id: cover.brama_garazu
        to: "open"
    condition:
      - condition: sun
        after: sunset
    action:
      - service: light.turn_on
        target:
          entity_id: light.garaz
      - delay: "00:05:00"
      - service: light.turn_off
        target:
          entity_id: light.garaz
```

## Automatyzacje — struktura

Każda automatyzacja składa się z trzech elementów:

- **Trigger** (wyzwalacz) — co rozpoczyna: zmiana stanu, godzina, geolokalizacja, MQTT, webhook
- **Condition** (warunek) — opcjonalne sprawdzenia: pora dnia, obecność, stan innej encji
- **Action** (akcja) — co wykonać: usługa, scenariusz, opóźnienie, powiadomienie

## NodeRED jako alternatywa

**NodeRED** — graficzny edytor automatyzacji (flow-based). Add-on do HA. Lepszy do skomplikowanych przepływów, gorszy do prostych. Wybór indywidualny.

## Integracje kluczowe

- **ZHA** (Zigbee Home Automation) — natywna integracja Zigbee
- **Zigbee2MQTT** — alternatywa, większy katalog wspieranych urządzeń, wymaga brokera MQTT
- **MQTT** (Mosquitto Add-on) — szyna komunikacyjna dla DIY (ESPHome, Tasmota, Shelly, OpenMQTTGateway)
- **ESPHome** — firmware dla ESP8266/ESP32, automatyczna integracja z HA, własne czujniki DIY
- **Z-Wave JS** — integracja Z-Wave
- **HACS** — sklep z społecznościowymi integracjami i kartami Lovelace

## Voice — sterowanie głosem

| Opcja | Chmura | Komentarz |
|---|---|---|
| **Alexa** | tak | Skill Home Assistant Cloud (Nabu Casa) |
| **Google Assistant** | tak | jw. |
| **Apple HomeKit** | nie | bridge HomeKit Add-on, sterowanie z iPhone/HomePod |
| **Lokalny: Whisper + Piper + Wyoming** | nie | Voice Assistant w HA + Atom Echo / ESP32-S3-Box / Voice PE — pełnia lokalności |

Rok 2024-2025 to przełom: HA Voice PE — gotowy lokalny asystent głosowy.

## Backupy

HAOS wspiera natywne **snapshoty** (lokalnie + Google Drive / Nabu Casa). Konfiguracja jako kod — łatwe odtworzenie.

Zaleca się tygodniowy backup automatyczny + przed każdą większą zmianą.

## Zalety

- **Lokalność i prywatność**
- **Brak abonamentów** (Nabu Casa opcjonalna)
- **Niezależność od producentów** — gdy jeden producent zniknie, HA dalej działa
- **Ogromna społeczność** + dokumentacja
- **Aktualizacje co miesiąc** — szybki rozwój

## Wady

- **Krzywa uczenia** — YAML, automatyzacje, edge cases
- **Aktualizacje breaking** — czasem trzeba poprawiać konfigurację
- **Wymaga technicznego zaangażowania** — to nie jest „kup i zapomnij"

## Co dalej

➡ [Scenariusze i automatyzacje — przykłady](13-04-scenariusze.md)
