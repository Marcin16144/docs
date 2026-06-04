# Parametry kamer

> Rozdzielczość (1/2/4/5/8 Mpx, 4K), sensor CMOS, WDR True/Digital, HDR, dynamic range, frame rate, kompresja H.264/H.265/H.265+.
>
> Aktualizacja: 2026

## Rozdzielczość — co znaczą megapiksele

| Nazwa | Mpx | Px | Aspect | Zastosowanie |
|---|---|---|---|---|
| HD (720p) | 0,9 | 1280 × 720 | 16:9 | tylko najtańsze, brak nowych |
| Full HD (1080p) | 2,1 | 1920 × 1080 | 16:9 | budżet, baza TVI/AHD |
| 3 MP | 3,0 | 2048 × 1536 | 4:3 | nisza |
| 4 MP / 2K | 4,0 | 2560 × 1440 | 16:9 | **standard 2026 dla IP** |
| 5 MP | 5,0 | 2592 × 1944 | 4:3 | standard TVI/AHD/CVI |
| 6 MP | 6,0 | 3072 × 2048 | 3:2 | fisheye, panoramy |
| 4K (8 MP) | 8,3 | 3840 × 2160 | 16:9 | premium, ANPR, długie zasięgi |
| 12 MP | 12 | 4000 × 3000 | 4:3 | fisheye 360° |
| 32 MP | 32 | 8000 × 4000 | 2:1 | multi-sensor, miasta |

**Mit „im więcej Mpx tym lepiej".** 8 MP na sensorze 1/2.8" daje gorszą jakość niż 4 MP na 1/1.8" — piksele mniejsze, zbierają mniej światła. *Sensor > rozdzielczość*.

## Sensor CMOS — fizyczny rozmiar

| Format | Wymiary | Powierzchnia | Typ |
|---|---|---|---|
| 1/4" | 3,6 × 2,7 mm | 9,7 mm² | najtańsze 1080p |
| 1/3" | 4,8 × 3,6 mm | 17,3 mm² | budżet 2–4 MP |
| 1/2.8" | 5,4 × 3,0 mm | 16,2 mm² | Sony IMX335 — 4 MP standard |
| **1/2.7"** | 5,6 × 3,1 mm | 17,4 mm² | standard 4–5 MP |
| **1/1.8"** | 7,2 × 5,4 mm | 38,9 mm² | premium (Sony IMX415, IMX678) |
| 1/1.2" | 9,6 × 7,2 mm | 69,1 mm² | flagship, ColorVu Pro |
| 2/3" | 9,6 × 5,4 mm | 51,8 mm² | przemysłowe, low-light |

**Dobra zasada.** Dla 4 MP IP outdoor szukaj **1/1.8"** (Sony IMX415/IMX678). Dla 8 MP — minimum 1/2". Tanie 4 MP na 1/3" w nocy ledwo widzą.

### Pixel pitch

```
pixel pitch [µm] = szerokość sensora [mm] · 1000 / px

Sensor 1/1.8" (7,2 mm) × 4 MP (2560 px) = 2,81 µm/piksel
Sensor 1/2.8" (5,4 mm) × 4 MP (2560 px) = 2,11 µm/piksel
```

Różnica 33% w ilości światła per piksel — drastyczna w nocy.

## Frame rate (fps)

| Frame rate | Zastosowanie | Bitrate H.265 (4 MP) |
|---|---|---|
| 5 fps | magazyny puste | ~1 Mbit/s |
| 12 fps | ekonomia, storage 2× mniej | ~2 Mbit/s |
| **25 fps** (PAL) | **standard PL/EU** | ~4 Mbit/s |
| 30 fps (NTSC) | US, część chińskich | ~4,5 Mbit/s |
| 50/60 fps | transport, sport, kasy | ~7–8 Mbit/s |
| 120 fps | kasyna, slow-motion | ~15 Mbit/s |

Typowy kompromis CCTV: **15–25 fps**. 50 fps tylko gdzie potrzeba detalu w ruchu (kasy z liczeniem pieniędzy, ANPR).

## WDR (Wide Dynamic Range)

| Technologia | Działanie | Skuteczność |
|---|---|---|
| **DWDR** Digital | korekcja gamma po przechwyceniu | kosmetyczna, 1–2 EV |
| **True WDR** (do 120 dB) | 2 ekspozycje łączone | ~12 EV |
| **Hi-Light Compensation** | maskowanie jasnych źródeł | punktowe |
| **BLC** Backlight | doświetlenie cienia | sceny kontrażowe |
| **HDR** (premium) | 3+ ekspozycje, łączenie pikselowe | do 140 dB |

**Pułapka.** „WDR 120 dB" w taniej kamerze to zwykle DWDR. Real WDR poznasz po menu „WDR Level: 1–100" i wyraźnym efekcie na scenie kontrażowej.

## Dynamic Range — dB w kamerze

```
DR [dB] = 20 · log10(Vmax / Vmin)

60 dB  ≈ 10 EV — typowy 1/3"
70 dB  ≈ 12 EV — standard 1/2.8"
80 dB  ≈ 13 EV — z DWDR
120 dB ≈ 20 EV — True WDR
140 dB ≈ 23 EV — flagship HDR
```

## Kompresja — H.264, H.265, H.265+

| Kodek | Bitrate (4 MP/25 fps) | Storage 30 dni | Kompatybilność |
|---|---|---|---|
| MJPEG | ~30 Mbit/s | ~10 TB | uniwersalna, ogromna |
| H.264 / AVC | ~8 Mbit/s | ~2,5 TB | uniwersalna, <2010 |
| H.265 / HEVC | ~4 Mbit/s | ~1,3 TB | większość 2014+ |
| H.265+ Smart (Hik) | ~1,5 Mbit/s | ~0,5 TB | tylko Hikvision NVR |
| H.265+ Smart (Dahua) | ~1,5 Mbit/s | ~0,5 TB | tylko Dahua NVR |
| H.266 / VVC | ~2 Mbit/s | ~0,6 TB | nowość 2023+ |

**H.265+ "Smart"** wykrywa obszary zainteresowania (ruchome obiekty) i utrzymuje dla nich pełen bitrate. Efekt: 3–4× mniej miejsca. Wymaga, by NVR też wspierał.

## VBR vs CBR

- **CBR** (Constant) — stały bitrate. Łatwa kalkulacja dysku, gorszy stosunek jakości/wielkości.
- **VBR** (Variable) — bitrate dopasowany do sceny. Lepsza efektywność, trudniejsza kalkulacja.
- **CVBR** (Constrained) — VBR z górnym limitem. Optymalny kompromis CCTV.

## Dual stream / Tri-stream

Większość kamer IP koduje równolegle w 2–3 rozdzielczościach:

- **Main** — 4 MP/25 fps H.265 — zapis na NVR
- **Sub** — 640×360/15 fps H.264 — aplikacja mobilna
- **Third** — opcjonalny, dla AI lub drugiego klienta

## ROI (Region of Interest)

Obszar o wyższej jakości kompresji (więcej bitów). Reszta kadru kodowana mniej. Typowe:

- Twarz przy drzwiach
- Strefa kasy
- Linia przekroczenia

## Analityka wbudowana 2026

| Funkcja | Opis | Producent |
|---|---|---|
| Human/Vehicle classification | filtr alarmów — tylko człowiek/auto | AcuSense, WizSense, Axis Object |
| Line crossing | alarm na linię | wszyscy |
| Intrusion detection | alarm na obszar | wszyscy |
| Loitering | alarm po N sekund w obszarze | wszyscy |
| Face detection | wykrycie + crop | średnia klasa |
| Face recognition | identyfikacja z bazy | premium (Hik DeepInView) |
| People counting | wejścia/wyjścia | standard 2026 |
| Heatmap | mapa cieplna ruchu | premium retail |
| ANPR / LPR | tablice rejestracyjne | dedykowane modele |

## Checklist przy zakupie kamery

1. **Sensor** — min 1/2.8", optymalnie 1/1.8" (Sony Starvis)
2. **Rozdzielczość** — 4 MP IP / 5 MP TVI — sweet spot 2026
3. **Min. iluminacja** — kolor <0,01 lux dla Starlight
4. **Kompresja** — H.265+ (jeśli kompatybilny NVR)
5. **WDR** — True 120 dB lub HDR
6. **Smart IR** — anti-overexposure (zamiast prześwietlenia)
7. **IP/IK** — IP66 + IK10 dla zewn.
8. **Frame rate** — 25 fps default
9. **Analityka** — AcuSense/WizSense filtruje 90% fałszywych
10. **ONVIF Profile S+T** — kompatybilność z VMS

## Co dalej

➡ [Optyka kamer](02-04-optyka.md)
