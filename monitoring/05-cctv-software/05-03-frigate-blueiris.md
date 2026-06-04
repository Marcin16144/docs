# Frigate, BlueIris, Shinobi, iSpy

**Sekcja:** 05 Software VMS · **Aktualizacja:** 2026-05

Open-source i komercyjne VMS — Frigate (Coral TPU / Hailo, MQTT, HA), BlueIris (Windows, CodeProject AI), Shinobi (NodeJS), iSpy. Porównanie wymagań, AI i kosztów.

## Szybkie porównanie

| VMS | OS / platforma | Licencja | AI | HA integracja | Cena |
|---|---|---|---|---|---|
| **Frigate** | Docker (Linux, RPi, Win z WSL2) | MIT open-source | YOLOv8 + Coral TPU / Hailo-8 / OpenVINO | natywna (MQTT) | 0 zł (+ Coral ~330 zł) |
| **BlueIris** | Windows 10/11/Server | komercyjna 1× zakup | CodeProject.AI, DeepStack | przez MQTT / web | ~290 zł (BI Pro) |
| **Shinobi** | NodeJS (Linux, Win, Mac) | MIT open-source | OpenALPR, Tensorflow | HTTP API, MQTT | 0 zł (Pro = $50/m-c) |
| **iSpy / Agent DVR** | Windows / Linux / Docker | open-source / freemium | DeepStack, Plate Recognizer | HTTP API, MQTT | 0 zł (sub Agent +) |
| **Surveillance Station** | Synology DSM | Free (2 cam) + licencje | People + Deep Video Analytics | HACS plugin | ~270 zł / kamera |
| **Zoneminder** | Linux (Debian/Ubuntu) | GPL | brak natywnego AI | HACS, MQTT | 0 zł |

## Frigate — lider open-source z AI

Frigate to projekt Blake'a Blackshear napisany w Pythonie. Cała architektura skupiona wokół jednego pomysłu: niska latencja AI obiektowej z akceleratorem sprzętowym (Coral TPU), zdarzenia publikowane przez MQTT.

### Architektura

```
Kamera RTSP → Frigate (Docker) → ffmpeg dekodowanie sprzętowe (VAAPI/QuickSync)
                                ↓
                            sample frames → AI (Coral/CPU/GPU)
                                ↓                  ↓
                       Storage (nagrania)      MQTT events
                                                   ↓
                                              Home Assistant
```

### Wymagania sprzętowe

| Kamer | CPU | RAM | Akcelerator AI | Storage |
|---|---|---|---|---|
| 1–2 kamery 1080p | RPi 4 / N5095 (2 GHz) | 4 GB | Coral USB ($30) | SSD 256 GB |
| 4–6 kamery 4 MP | Intel N100 / i3-8100 | 8 GB | Coral M.2 / Hailo-8 | HDD 2 TB CMR |
| 8–16 kamery 4 MP/4K | i5/i7 z iGPU lub Xeon | 16 GB | 2 × Coral lub Hailo-8L | HDD 8 TB + SSD cache |

**Google Coral USB Edge TPU** (~330 zł, w 2026 dostępność znów dobra po dwóch trudnych latach) wykonuje 4 TOPS w 2 W i odbarcza CPU o 80–95% przy inferencji YOLO. **Hailo-8L M.2** (~600 zł) daje 13 TOPS i jest godnym następcą.

### Konfiguracja YAML

```yaml
mqtt:
  host: 192.168.1.10
  user: frigate
  password: !secret mqtt_pass

detectors:
  coral:
    type: edgetpu
    device: usb

cameras:
  brama_wjazd:
    ffmpeg:
      inputs:
        - path: rtsp://admin:Pass@192.168.1.64:554/Streaming/Channels/101
          roles: [record]
        - path: rtsp://admin:Pass@192.168.1.64:554/Streaming/Channels/102
          roles: [detect]
    detect:
      width: 640
      height: 360
      fps: 5
    objects:
      track: [person, car, dog]
      filters:
        person:
          min_area: 5000
          threshold: 0.7
    record:
      enabled: true
      retain:
        days: 14
      events:
        retain:
          default: 30
          objects:
            person: 60
```

### MQTT events

Frigate publikuje 3 topic na każdy event:

- `frigate/events` — JSON z metadanymi (typ obiektu, snapshot, bounding box)
- `frigate/<camera>/<label>` — np. `frigate/brama_wjazd/person` = ON podczas detekcji
- `frigate/<camera>/<label>/snapshot` — JPEG snapshot eventu

## BlueIris — gold standard Windows

BlueIris od Perspective Software (~280–320 zł jednorazowo) to weteran rynku — działa na Windows 10/11, obsługuje 64 kamery, ma najlepszy interface do przeglądania archiwum w branży.

### Cechy szczególne

- **Substream support** — dekoduje sub-stream do detekcji, main do nagrywania (oszczędność CPU 70%+).
- **Hardware accelerated decoding** — Intel QuickSync, NVIDIA CUDA, AMD VCN.
- **CodeProject.AI** (następca DeepStack) — modele klasyfikacji „Person/Vehicle/Animal/Face", LPR.
- **UI3 web app** — przeglądanie nagrań z każdej przeglądarki, mobile-friendly.
- **iOS / Android app** (~$10) — push, podgląd, sterowanie PTZ.
- **NVR features** — RAID, automatic archive, sync z OneDrive/Dropbox.

### Wymagania

| Kamer | CPU (z QuickSync) | RAM |
|---|---|---|
| 4 × 1080p | i3 lub Pentium G7400 | 8 GB |
| 8 × 4 MP | i5-12400 lub Ryzen 5 | 16 GB |
| 16 × 4 MP | i7-13700 z QuickSync | 32 GB |
| 32+ × 4 MP | Xeon E-2400, RTX 4060 dla AI | 64 GB |

**Intel QuickSync** w iGPU obsługuje dekodowanie H.265 sprzętowo — pojedynczy strumień 4K zajmuje 1–2% CPU zamiast 30–50%. Stąd BlueIris świetnie skaluje się na konsumenckich Core i3/i5 z grafiką Iris/UHD.

## Shinobi — NodeJS, dla deweloperów

Shinobi to VMS w NodeJS (Express + ffmpeg + MongoDB). Lekki, ale ekosystem mniejszy niż Frigate. Wersja CE (Community Edition) jest darmowa, Pro za subskrypcję $50/m-c (premium features, support).

### Plusy

- Bardzo niskie wymagania (działa na RPi z 1 GB RAM dla 2 kamer)
- Plugin system — można pisać własne moduły
- Integracja z Telegram, Discord, Slack out-of-the-box
- OpenALPR integracja (LPR)

### Minusy

- Mniejsze community niż Frigate (mniej tutoriali, plug-inów)
- UI mniej dopracowane
- AI integracja słabsza (tylko Tensorflow przez API)

## iSpy / Agent DVR — open-source dla Windows

iSpy to klasyczny VMS dla Windows; jego nowsza wersja **Agent DVR** jest cross-platform (Windows, Linux, Docker, macOS).

### Agent DVR — kluczowe cechy

- Free, ale niektóre featury (cloud, advanced AI) wymagają subskrypcji Agent+ ($8/m-c)
- DeepStack i Plate Recognizer integracja
- Web UI bardzo nowoczesne (oparte na React)
- Up to 100 kamer per instance
- Native MQTT, WebSocket events

## Porównanie AI

| VMS | Modele AI | Akceleratory | Klasy obiektów | LPR (tablice) |
|---|---|---|---|---|
| **Frigate** | YOLOv8 / SSD MobileNet (TFLite) | Coral TPU, Hailo-8, OpenVINO (iGPU), NVIDIA | 90+ (COCO) | plug-in (frigate-plus) |
| **BlueIris + CP.AI** | YOLOv5, FaceProcessing, LicensePlate | CPU, CUDA, Intel iGPU | person, vehicle, animal, face, plate | natywnie |
| **Synology SS** | People + DVA (płatne plug-in) | CPU | person, vehicle, face | brak |
| **Agent DVR + DeepStack** | DeepStack object | CPU, CUDA | 80+ (COCO) | z Plate Recognizer API ($) |

## Porównanie kosztów (instalacja 6 kamer 4 MP)

| Konfiguracja | Sprzęt | Software | Razem (2026) |
|---|---|---|---|
| Frigate na N100 mini-PC + Coral USB | ~1500 zł (Beelink S12) + 330 zł Coral + 2 TB HDD ~330 zł | 0 zł | ~2160 zł |
| BlueIris na używanym i5-10400 PC | ~1200 zł używana stacja + 2 TB HDD ~330 zł | ~290 zł (BI Pro) | ~1820 zł |
| Synology DS224+ + 6 licencji | ~1700 zł DS224+ + 2×8 TB ~1200 zł | 4 × ~270 zł licencje | ~3980 zł |
| Komercyjny NVR Hikvision 8-ch + HDD | ~1900 zł NVR + 4 TB ~580 zł | w cenie | ~2480 zł |

## Wybór — kiedy co

- **Frigate** — Linux/Docker/HA fanatycy, AI z Coral, OSS, automatyzacje. Wymaga ogarniętości technicznej.
- **BlueIris** — chcesz natychmiast działający VMS na Windows, bez gimnastyki. Ekosystem dojrzały, dokumentacja po angielsku.
- **Synology SS** — masz już NAS Synology, chcesz wszystko w jednym pudełku, łatwe.
- **Shinobi / Agent DVR** — alternatywa OSS dla mniejszych instalacji, lub developer chce wbudować w własną aplikację.
- **Komercyjny NVR** — najprostszy, plug-and-play, ale bez AI i bez integracji z HA.

## Co dalej

➡ [Integracja z Home Assistant](05-04-integracja-home-assistant.md)
