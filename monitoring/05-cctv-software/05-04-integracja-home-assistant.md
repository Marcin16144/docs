# Integracja kamer z Home Assistant

**Sekcja:** 05 Software VMS · **Aktualizacja:** 2026-05

Karta picture-glance, generic_camera, integracja MQTT z Frigate, automatyzacje (snapshot na ruch, push notification, włącz światło), TTS na intercom.

## Trzy sposoby dodania kamery do HA

| Metoda | Trudność | Funkcjonalność |
|---|---|---|
| **generic_camera** | łatwa | snapshot JPG + RTSP stream URL |
| **ONVIF integration** | średnia | pełne ONVIF — PTZ, eventy, sensory |
| **Frigate integration (HACS)** | średnia | AI events, klasy obiektów, automatyczne tworzenie sensorów |
| **Producent (Reolink, Tapo, UniFi)** | łatwa | oficjalna integracja, wszystkie features producenta |

## Konfiguracja generic_camera

Najprostszy sposób na dowolną kamerę z RTSP — wystarczy URL strumienia. Konfiguracja w `configuration.yaml` lub przez UI (Settings → Devices → Add Integration → Generic Camera).

```yaml
camera:
  - platform: generic
    name: Brama wjazdowa
    still_image_url: http://admin:Pass@192.168.1.64/ISAPI/Streaming/channels/101/picture
    stream_source: rtsp://admin:Pass@192.168.1.64:554/Streaming/Channels/101
    verify_ssl: false
    framerate: 5
    content_type: image/jpeg

  - platform: generic
    name: Garaz
    stream_source: rtsp://admin:Pass@192.168.1.65:554/Streaming/Channels/101
    still_image_url: http://192.168.1.65/cgi-bin/snapshot.cgi?channel=1
```

> **Hasło w plain text** w configuration.yaml — używaj `!secret` i pliku `secrets.yaml` dla wrażliwych danych.

## Integracja ONVIF

UI-driven: Settings → Devices → Add Integration → ONVIF. HA znajdzie kamerę przez WS-Discovery, poprosi o login/hasło, zaimportuje:

- `camera.brama_wjazdowa` — strumień wideo (multiple profiles)
- `binary_sensor.brama_wjazdowa_motion` — detekcja ruchu z ONVIF events
- `binary_sensor.brama_wjazdowa_tamper` — alarm sabotażu (jeśli kamera ma)
- Sterowanie PTZ przez serwis `onvif.ptz`

## Frigate — pełna integracja AI

Po instalacji integracji Frigate przez HACS, HA automatycznie tworzy dla każdej kamery zestaw bytów:

| Entity | Co |
|---|---|
| `camera.<name>` | live stream (sub stream) |
| `camera.<name>_person` | snapshot ostatniej osoby wykrytej AI |
| `binary_sensor.<name>_person_occupancy` | ON gdy osoba w kadrze |
| `sensor.<name>_person_count` | liczba osób w polu widzenia |
| `switch.<name>_recordings` | włącz/wyłącz nagrywanie |
| `switch.<name>_motion_detection` | włącz/wyłącz detekcję |
| `switch.<name>_snapshots` | włącz/wyłącz snapshoty |

## Karta picture-glance — dashboard

Najpopularniejsza karta do podglądu kamer w Lovelace. Pokazuje obraz (snapshot z auto-odświeżeniem co X sekund) + szybkie kontrolki / status sensorów.

```yaml
type: picture-glance
title: Brama wjazdowa
camera_image: camera.brama_wjazdowa
camera_view: live
entities:
  - entity: binary_sensor.brama_wjazdowa_motion
    icon: mdi:run-fast
  - entity: light.brama_lampa
    icon: mdi:lightbulb
  - entity: switch.brama_syrena
    icon: mdi:bell-alert
tap_action:
  action: navigate
  navigation_path: /dashboard-cctv/brama-pelna
```

### Karta picture-elements (zaawansowana)

Pozwala nakładać ikony, etykiety, suwaki na obraz kamery — np. PTZ controls overlay na live stream.

```yaml
type: picture-elements
camera_image: camera.brama_ptz
camera_view: live
elements:
  - type: icon
    icon: mdi:arrow-up-bold-circle
    tap_action:
      action: call-service
      service: onvif.ptz
      service_data:
        entity_id: camera.brama_ptz
        tilt: UP
    style:
      top: 10%
      left: 50%
```

## Automatyzacje — przykłady realne

### 1. Snapshot + push, gdy ktoś podejdzie do drzwi (Frigate AI)

```yaml
alias: Snapshot drzwi gdy osoba
trigger:
  - platform: mqtt
    topic: frigate/events
condition:
  - condition: template
    value_template: "{{ trigger.payload_json['after']['camera'] == 'drzwi_front' }}"
  - condition: template
    value_template: "{{ trigger.payload_json['after']['label'] == 'person' }}"
  - condition: template
    value_template: "{{ trigger.payload_json['type'] == 'new' }}"
action:
  - service: camera.snapshot
    target:
      entity_id: camera.drzwi_front
    data:
      filename: /config/www/snapshots/drzwi_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg
  - service: notify.mobile_app_marcin
    data:
      title: "Osoba przy drzwiach"
      message: "Wykryto osobę przed drzwiami wejściowymi"
      data:
        image: /local/snapshots/drzwi_{{ now().strftime('%Y%m%d_%H%M%S') }}.jpg
        actions:
          - action: SPEAK_INTERCOM
            title: "Powiedz coś"
```

### 2. Włącz światło na podjeździe wieczorem, gdy ktoś wchodzi

```yaml
alias: Auto światło podjazd
trigger:
  - platform: state
    entity_id: binary_sensor.podjazd_person_occupancy
    to: "on"
condition:
  - condition: sun
    after: sunset
    before: sunrise
  - condition: state
    entity_id: light.podjazd_lampa
    state: "off"
action:
  - service: light.turn_on
    target:
      entity_id: light.podjazd_lampa
    data:
      brightness_pct: 100
  - delay: "00:05:00"
  - service: light.turn_off
    target:
      entity_id: light.podjazd_lampa
```

### 3. Telegram alert z nagraniem klipu (BlueIris)

```yaml
alias: Telegram alarm intruz noc
trigger:
  - platform: webhook
    webhook_id: blueiris_alert
condition:
  - condition: time
    after: "22:00:00"
    before: "06:00:00"
action:
  - service: notify.telegram_bot
    data:
      title: "ALARM nocny"
      message: "Wykryto ruch w strefie {{ trigger.json.zone }}"
  - service: rest_command.blueiris_get_clip
    data:
      camera: "{{ trigger.json.camera }}"
      duration: 30
  - delay: "00:00:35"
  - service: notify.telegram_bot
    data:
      message: "Klip:"
      data:
        video: "/config/www/clips/{{ trigger.json.camera }}_latest.mp4"
```

### 4. TTS przez intercom kamery (Reolink z głośnikiem)

```yaml
alias: TTS przez intercom
trigger:
  - platform: state
    entity_id: binary_sensor.kurier_dzwonek
    to: "on"
action:
  - service: tts.cloud_say
    target:
      entity_id: media_player.reolink_intercom
    data:
      message: "Dzień dobry, paczkę proszę zostawić w skrzynce po prawej. Dziękujemy."
      language: pl-PL
```

## Notification z obrazem (mobile app)

Krytyczne dla użyteczności — push z miniaturą obrazu pozwala szybko zweryfikować, czy alarm prawdziwy bez otwierania aplikacji.

```yaml
notify:
  - platform: mobile_app_marcin
  data:
    title: "Brama wjazdowa"
    message: "Wykryto auto"
    data:
      image: "{{ states.camera.brama_wjazdowa.attributes.entity_picture }}"
      actions:
        - action: OTWORZ_BRAME
          title: "Otwórz bramę"
        - action: ALARM
          title: "Włącz alarm"
```

## Optymalizacja wydajności

- **Sub-stream do podglądu** — w karcie picture-glance użyj sub-streama (640×360), nie main-streama. CPU spadnie 10×.
- **Limit snapshot refresh** — `still_image_refresh: 30` zamiast domyślnych 10 s.
- **Recording dziej się w Frigate/SS**, HA tylko podgląd live i automatyzacje.
- **HA stream** używa HLS — działa wszędzie, ale daje 5–10 s opóźnienia. Dla low-latency użyj WebRTC (custom card go2rtc).
- **go2rtc** jako proxy (od HA 2023.x wbudowany w core) zmniejsza opóźnienie do < 1 s i pozwala dzielić strumień między HA, Frigate, mobile.

## Storage i nagrania w HA

Home Assistant **nie jest VMS** — nie nagrywa 24/7. Do tego są dedykowane systemy (Frigate, BlueIris, Synology SS). HA może zapisywać **snapshoty na eventy** i krótkie klipy (do 30 s) przez serwis `camera.record`.

```yaml
service: camera.record
target:
  entity_id: camera.brama_wjazdowa
data:
  filename: /config/www/clips/brama_{{ now().strftime('%Y%m%d_%H%M%S') }}.mp4
  duration: 30
  lookback: 5
```

## Bezpieczeństwo

- **HTTPS** w HA (Let's Encrypt + reverse proxy NGINX) — nie HTTP w sieci lokalnej, nigdy w internecie.
- **Kamery w osobnym VLAN** — HA jako proxy z dwoma interfejsami (VLAN cam + VLAN home).
- **Nie udostępniaj Lovelace card z kamerą publicznie** — używaj Nabu Casa lub VPN.
- **2FA na koncie HA** — niezbędne przy dostępie z zewnątrz.

## Co dalej

➡ [Sekcja 06 — Centrale alarmowe: Satel Integra](../06-alarmy-centrale/06-01-satel-integra.md)
