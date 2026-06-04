# ANPR — odczyt tablic rejestracyjnych

> Kamery LPR (License Plate Recognition), dobór parametrów (rozdzielczość, zoom, IR), software (Milesight, Hikvision iVMS, Frigate), integracja z bramą/szlabanem.
>
> Aktualizacja: 2026

## ANPR vs LPR — synonimy

- **ANPR** — Automatic Number Plate Recognition (UK/EU)
- **LPR** — License Plate Recognition (US)
- To samo: rozpoznawanie tablic z obrazu wideo

## Zastosowania

| Zastosowanie | Opis |
|---|---|
| **Brama posesji** | auto-otwarcie dla domowników, log gości |
| **Parking firmowy** | kontrola wjazdu pracowników |
| **Parking płatny** | liczenie czasu, automatyczne faktury |
| **Stacja paliw** | powiązanie tankowania z autem |
| **Hotel** | powiadomienie recepcji o przyjeździe |
| **Drive-thru** | powitanie po imieniu klienta z konta |
| **Magazyn** | kontrola TIR-ów, integracja WMS |
| **Bramy SPA, osiedla** | auto-otwarcie dla mieszkańców |
| **ZTL/SCT** | kontrola wjazdu (Kraków, Warszawa) |
| **Policja, ITD** | poszukiwanie pojazdów, floty |

## Wymagania techniczne kamery ANPR

### Rozdzielczość tablicy

Tablica polska: **520 × 114 mm** (jednorzędowa). Dla OCR:

- **Minimum 120 px** — odczyt 80–90%
- **150–200 px** — odczyt >95% (zalecane)
- **250+ px** — odczyt >99% (premium)

**Wzór.** Aby uzyskać X px na szerokości tablicy 0,52 m kamerą 4 MP (2560 px) i HFOV 30°:

```
szerokość_kadru = 2560 / X · 0,52
Dla X = 150 → kadr 8,87 m → odległość kamery ≈ 16,5 m (HFOV 30°)
```

### Frame rate i shutter

- **Frame rate** — min 25 fps, lepiej 50 fps dla aut >30 km/h
- **Shutter** — krytyczny! Auto przy 50 km/h = 14 m/s:
  - 30 km/h → shutter max 1/250 s
  - 50 km/h → shutter max 1/500 s
  - 100 km/h → shutter max 1/1000 s

### Oświetlenie i odbicie tablicy

Polskie tablice są **retroreflective** — odbijają światło. Kamera z IR LED daje na tablicy bardzo jasny obraz (tablica „świeci"). Przy odpowiedniej ekspozycji tablica czytelna nawet w nocy.

### Dedykowane ANPR vs uniwersalne

| Cecha | Zwykła IP cam | Dedykowana ANPR |
|---|---|---|
| Sensor | 1/2.8" Sony Starvis | 1/1.8" lub większy |
| Obiektyw | fixed lub motozoom 2,7–13,5 mm | motozoom 8–50 mm dedykowany |
| Filtr IR | standard IR-cut | wzmocniony dla tablic |
| Auto-ekspozycja | cała scena | tylko strefa tablicy |
| Shutter | auto 1/25–1/1000 | z kontrolą min/max |
| Algorytm OCR | brak lub w VMS | wbudowany |
| Cena (2026) | 500–900 zł | 2 500–6 000 zł |

## Modele dedykowane ANPR 2026

| Model | Sensor | f | Cena | Cechy |
|---|---|---|---|---|
| Hikvision iDS-2CD7A26G0/P-IZHSY | 1/1.8" 2 MP | 8–32 mm | ~5 500 zł | DeepInView, 10 000 tablic |
| Hikvision iDS-TCM403-AI | 1/1.8" 4 MP | 10–50 mm | ~6 500 zł | highway do 150 km/h |
| Dahua ITC215-PW6M-IRLZF | 1/2.8" 2 MP | 2,7–12 mm | ~3 200 zł | ANPR + AI klasyfikacja |
| Dahua ITC415-PW6M-IZ | 1/2.7" 4 MP | 8–32 mm | ~4 800 zł | ITS |
| Milesight MS-C5365-PD | 1/2.7" 5 MP | 2,7–13,5 mm | ~3 800 zł | LPR-list + REST API |
| BCS-V-DIP55VSR3-Ai2 | 1/2.8" 5 MP | 2,7–13,5 mm | ~2 100 zł | budget pl, parking |
| Uniview IPC2128SR3 | 1/2.8" 8 MP | 2,8–12 mm | ~3 400 zł | ANPR + people/vehicle |

## Software / silniki ANPR

### Wbudowane w kamerze

- **Hikvision DeepInView** — listy tablic, biała/czarna lista do 10 000
- **Dahua AI (DSS/Express)** — kategoria + ANPR, sterownik DH-ARC
- **Milesight LPR** — REST API
- **Axis License Plate Verifier** — aplikacja ACAP

### Serwerowe

| Produkt | Licencja | Charakterystyka |
|---|---|---|
| **OpenALPR / OpenLPR** | open-source + komercyjny | Linux, REST, GPU |
| **PlateRecognizer** | SaaS + on-prem | 500/mies darmo, 99% |
| **Vaxtor VaxALPR** | komercyjny per kamera | parkingi |
| **Frigate** + LPR plugin | open-source | Home Assistant, CodeProject.AI |
| **Genetec AutoVu** | enterprise | miasta |
| **Milestone Husky LPR** | enterprise | XProtect VMS |

### Frigate — open-source dla HA

```yaml
cameras:
  brama:
    ffmpeg:
      inputs:
        - path: rtsp://user:pass@192.168.1.10:554/Streaming/Channels/101
    detect:
      width: 1920
      height: 1080
    objects:
      track:
        - car
        - motorcycle
        - truck
    snapshots:
      enabled: true
      retain:
        default: 30
```

+ plugin CodeProject.AI LPR — wyciąganie tekstu w HA, integracja z bramą (Shelly Plus 1 jako relay).

## Pozycjonowanie kamery ANPR

### Kąty

- **Kąt poziomy** (od osi pojazdu) — max **30°**, optymalnie 15–20°
- **Kąt pionowy** — max **30°**, optymalnie 10–15°
- **Wysokość** — 2,5–3,5 m nad nawierzchnią

### Odległość od linii detekcji

| Prędkość | Odległość | f (sensor 1/1.8") |
|---|---|---|
| do 30 km/h (parking) | 4–8 m | 4–8 mm |
| do 60 km/h (brama firmy) | 10–15 m | 8–16 mm |
| do 90 km/h (droga) | 15–25 m | 12–25 mm |
| do 130 km/h (autostrada) | 20–40 m | 25–50 mm |

**Pozycjonowanie nad pasem.** Najlepiej kamera nad osią pasa (nad bramą), nie z boku. Kąt poziomy 0–10° = idealne OCR.

## Integracja z bramą / szlabanem

### Topologia

```
[Kamera ANPR] → RTSP → [Server / NVR / HA]
                              ↓
                         silnik OCR
                              ↓
                    porównanie z whitelist
                              ↓
                  [Relay / Shelly / kontroler]
                              ↓
                  [Sterownik bramy / szlaban]
```

### Implementacje

- **Hikvision DS-K1T642DWX** + LPR + DS-K2602T — end-to-end
- **BCS LPR + relay** — wyjście relay w kamerze
- **Frigate + HA + Shelly Plus 1** — DIY ~600 zł
- **Milesight ANPR + REST API → Tailwind / Nice / Faac** — popularne napędy

## Wyzwania i ograniczenia

- **Brudne tablice** — błoto, śnieg, naklejki → OCR <50%
- **Tablice nieczytelne** (zniszczone, zardzewiałe)
- **Reflexive halo w deszczu** — soczewki polaryzacyjne (rzadko w CCTV)
- **Tablice zagraniczne** — konfiguracja silnika (UE, UK, US)
- **Tablice tymczasowe / próbne** — często nie wykrywane (zielone)
- **Motocykle** — 180 × 130 mm, pionowa, osobny profil

## RODO i ANPR

Numer rejestracyjny = **dane osobowe** (identyfikacja przez CEPiK). Stąd:

- Wymagana **podstawa prawna** (uzasadniony interes — bezpieczeństwo, KD)
- Obowiązek **informowania** (tablica RODO przed wjazdem)
- Retencja jak CCTV — **30 dni**, max 3 miesiące bez uzasadnienia
- Zakaz **profilowania** bez dodatkowej podstawy
- W komercyjnych — wpis w RCPD

## Koszt typowej instalacji ANPR (2026)

| Element | Domowa brama | Parking firmowy 1 wjazd |
|---|---|---|
| Kamera ANPR | BCS-V-DIP55 (~2 100 zł) | Milesight MS-C5365 (~3 800 zł) |
| Server / OCR | HA + Frigate na N100 (~1 500 zł) | Milesight NVR (~2 000 zł) |
| Sterownik / relay | Shelly Plus 1 (~75 zł) | kontroler dostępu (~600 zł) |
| Instalacja, kabel | 500 zł | 1 200 zł |
| Robocizna | 800 zł | 1 500 zł |
| **RAZEM** | **~5 000 zł** | **~9 000 zł** |

## Co dalej

➡ [Sekcja 03 — Rejestratory CCTV](../03-cctv-rejestratory/index.md)
