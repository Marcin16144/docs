# Kamery IP vs analogowe

> HD-TVI Hikvision, AHD, HD-CVI Dahua, CVBS vs Ethernet/PoE — różnice, jakość, koszt, długość kabla, kiedy co wybrać.
>
> Aktualizacja: 2026

## Dwa światy CCTV

| Cecha | Analog (HD-over-coax) | IP (Ethernet) |
|---|---|---|
| Sygnał | analogowy, modulowany na koaksu | cyfrowy RTSP/ONVIF |
| Kabel | RG-59, RG-6 (75 Ω) lub UTP z balun | UTP cat5e/6 (PoE) lub światłowód |
| Zasilanie | osobne 12 V DC | PoE 802.3af/at |
| Rejestrator | DVR (lub HVR) | NVR lub serwer/NAS |
| Max długość | 500 m (RG-6) | 100 m UTP, dalej światłowód |
| Max rozdzielczość | 8 Mpx (4K) | 32+ Mpx |
| Opóźnienie | ~0 ms | 100–500 ms |
| Konfiguracja | plug & play | IP, hasła, ONVIF |
| Cyberbezpieczeństwo | brak ataków sieciowych | wymaga VLAN, haseł |
| Koszt na kanał (2026) | 200–400 zł | 350–700 zł |

## Standardy HD-over-coax

### HD-TVI (Hikvision)

- Twórca: Techpoint, propagowany przez Hikvision (~70% rynku TVI w PL)
- Rozdzielczość: 720p / 1080p / 3 MP / 5 MP / 4K
- UTC (Up-the-Coax) — sterowanie OSD/PTZ tym samym kablem
- Audio-over-coax (TVI 4.0)
- Marki: Hikvision, BCS, Hilook, Safire

### AHD (Analog HD)

- Twórca: Nextchip (Korea)
- Rozdzielczość: 720p / 1080p / 3 MP / 5 MP / 4K
- Najprostszy do wdrożenia, dobre wsparcie audio
- W tanich kamerach OEM, „no-name" DVR

### HD-CVI (Dahua)

- Twórca: Dahua
- Rozdzielczość: do 8 MP
- Najdłuższy zasięg (do 800 m), PoC (Power-over-Coax)
- Marki: Dahua, Imou, Lorex

### CVBS (analog klasyczny)

- PAL/NTSC, sygnał 1 V p-p, 75 Ω
- Tylko D1 (704×576) — 0.4 Mpx
- Dziś używany tylko do retrofitów

**Penta-brid / Hexa-brid DVR** — większość rejestratorów od 2019 r. obsługuje wszystkie standardy automatycznie (TVI+AHD+CVI+CVBS+IP).

## Maksymalne długości kabla

| Standard | RG-59 | RG-6 | UTP cat5e + balun |
|---|---|---|---|
| CVBS | 300 m | 500 m | 200 m (aktywny) |
| HD-TVI 1080p | 400 m | 500 m | 250 m |
| HD-TVI 5 MP | 250 m | 400 m | 150 m |
| HD-TVI 4K | 200 m | 300 m | 100 m |
| HD-CVI 1080p | 500 m | 800 m | 300 m |
| HD-CVI 4K | 200 m | 300 m | 100 m |
| AHD 1080p | 400 m | 500 m | 250 m |
| IP PoE 802.3af/at | — | — | **100 m UTP cat5e** |
| IP + PoE extender | — | — | 200–300 m |
| IP światłowód SM | — | — | 10–40 km |

**Pułapka:** kable koax CCA (Copper Clad Aluminum) z marketów obniżają długości o 30–50%. Do profesjonalnych instalacji tylko 100% miedź.

## PoE — skrót

| Standard | Moc na port | Typowe kamery |
|---|---|---|
| 802.3af | 15,4 W (12,95 W) | standardowa kamera bez grzałki |
| 802.3at | 30 W (25,5 W) | PTZ mały, grzałka, IR >30 m |
| 802.3bt typ 3 | 60 W (51 W) | Speed Dome, 4K z IR |
| 802.3bt typ 4 | 100 W (71 W) | PTZ duży, biały LED |

## Koszty — system 8-kanałowy (2026)

| Element | Analog (TVI 5 Mpx) | IP (4 Mpx PoE) |
|---|---|---|
| 8× kamera | 2 240 zł | 3 600 zł |
| Rejestrator | 850 zł | 1 400 zł |
| Kabel + zasilanie | 600 zł | 350 zł |
| Akcesoria | 400 zł | 200 zł |
| Dysk 4 TB | 550 zł | 550 zł |
| **SUMA SPRZĘT** | **~4 640 zł** | **~6 100 zł** |
| Robocizna 8 kamer | 2 500–3 500 zł | 1 800–2 800 zł |
| **RAZEM** | **~7 500 zł** | **~8 500 zł** |

## Kiedy wybrać analog

- Retrofit starej instalacji (już położony koax)
- Bardzo długie trasy (200–500 m) bez światłowodu
- Brak zaufanej LAN — system izolowany
- Klient nieobeznany z IT — plug-and-play
- Wymagana niska latencja (sterowanie PTZ)
- Małe obiekty 4–16 kamer bez analityki

## Kiedy wybrać IP

- Nowe instalacje — przyszłościowy standard
- Wysokie rozdzielczości 8–12 Mpx
- Analityka AI w kamerze (line crossing, face, ANPR)
- Integracja z VMS (Milestone, Synology, Frigate)
- Mobilność — RTSP do telefonu/HA bez DVR
- Wieloma lokalizacjami (chmura, VPN, multi-site)
- Duże obiekty >16 kamer

## Hybryda HVR

Rejestrator z wejściami BNC + portami IP/PoE. Pozwala na stopniową migrację:

1. Stara instalacja 8× CVBS — wymiana DVR na HVR (Hikvision iDS-7208HUHI-M2 + 2 IP)
2. Dokładanie kamer IP do tego rejestratora (bez przekładania kabli)
3. Stopniowa wymiana CVBS → TVI 5 MP w tej samej infrastrukturze

## Kompatybilność producentów

**Uwaga.** Każdy z trzech standardów HD-over-coax jest częściowo kompatybilny tylko między modelami tego samego producenta. Bezpieczna zasada: jedna marka rejestratora + kamer.

## Cyberbezpieczeństwo kamer IP — checklist

- Zmień **domyślne hasło** przy pierwszym uruchomieniu
- Wyłącz **UPnP** na routerze
- Wydziel **VLAN dla CCTV** bez dostępu do internetu
- Aktualizuj **firmware** (Hikvision CVE-2021-36260 — RCE)
- Wyłącz nieużywane usługi (ONVIF, SADP discovery)
- HTTPS z certyfikatem (lepiej VPN)

## Co dalej

➡ [Typy obudów kamer](02-02-typy-obudow.md)
