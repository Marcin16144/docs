# Synology Surveillance Station

**Sekcja:** 05 Software VMS · **Aktualizacja:** 2026-05

NAS Synology jako pełnoprawny NVR — pakiet Surveillance Station w DSM, model licencjonowania (2 darmowe + dokup), aplikacja DS cam, Active Insight, Smart Search.

## Czym jest Synology Surveillance Station

Surveillance Station (SS) to oficjalny pakiet Synology, instalowany przez Centrum Pakietów w DSM. Zamienia każde NAS Synology w pełnoprawny VMS z funkcjami klasy enterprise: nagrywanie z timeline, detekcja ruchu, eventy, e-maile, mapa kamer, mobilna aplikacja, REST API.

| Cecha | SS na NAS DS220+ | SS na DS923+ (z RAM) | Komercyjny NVR Hikvision |
|---|---|---|---|
| Max kamer | 15 (po dokupieniu licencji) | 40+ z plug-in | 16 (NVR-DS-7616) |
| Storage | 2 × HDD CMR (np. WD Purple) | 4 × HDD + 2 × SSD | 2 × HDD do 16 TB |
| RAM | 2 GB (limit 10 kamer real-time decode) | 4 GB + slot DDR4 | ~1 GB fix |
| Wszystkie funkcje na 1 boxie | tak (Plex, NAS, kamera) | tak + Docker | nie |
| Cena (2026) | ~1700 zł + dyski | ~3500 zł + dyski | ~1900 zł |

## Licencjonowanie kamer

Każde NAS Synology ma **2 darmowe licencje kamer** wbudowane od fabryki. Dla większej liczby kupujesz pakiety:

| Pakiet licencji | Liczba kamer | Cena (2026) |
|---|---|---|
| Device License Pack 1 | +1 kamera | ~270 zł |
| Device License Pack 4 | +4 kamery | ~900 zł |
| Device License Pack 8 | +8 kamer | ~1700 zł |

Licencja jest **powiązana z numerem seryjnym NAS**. Wymiana NAS na nowszy = nowa licencja (chyba że okazjonalna promocja Synology na migrację). Z drugiej strony licencja działa wiecznie, bez subskrypcji rocznej.

## Lista kompatybilnych kamer

Synology utrzymuje listę „Camera Support List" — przed zakupem warto sprawdzić, czy konkretna kamera jest oficjalnie wspierana. Lista zawiera ~7000+ modeli (stan 2026).

- **Pełna integracja** — wszystkie funkcje (PTZ, eventy, snapshot, audio, AI events).
- **ONVIF generic** — kamera nie wymieniona, ale obsługuje ONVIF Profile S. Działa, lecz część funkcji może nie być dostępna.
- **Niewspierane** — kamera z własnym protokołem (np. tania chińska bez ONVIF). Nie zadziała.

### Polecane marki na rynku polskim

- **Reolink** (RLC-820A, 822A, 1224A) — bardzo dobra integracja, AI events, IR/ColorX.
- **Hikvision / HiLook** — pełne wsparcie, ColorVu, AcuSense AI.
- **Dahua / Lorex** — pełne wsparcie, Starlight, IVS.
- **Axis** — premium, drogie, ale ze wszystkimi feature'ami SS.
- **Foscam, Tapo (TP-Link)** — działają, ale ograniczone.

## Instalacja krok po kroku

1. **DSM 7.x** — aktualne, zaktualizuj jeśli starsze. Wymagana wersja min. 7.0.
2. **Centrum Pakietów** → kategoria *Bezpieczeństwo* → Surveillance Station → Zainstaluj.
3. Po instalacji uruchom z menu DSM. Pojawi się pulpit SS w przeglądarce.
4. **Dodaj kamerę** — IP Camera → Add → wybierz markę i model z listy, podaj IP + login.
5. Ustaw **profil nagrywania** (rozdzielczość, fps, codec). Domyślnie continuous 24/7.
6. Skonfiguruj **retencję** — np. „usuń pliki starsze niż 14 dni".

## Funkcje kluczowe

### Timeline i odtwarzanie

Surveillance Station prezentuje wszystkie nagrania na timeline z kolorowymi paskami (motion, event, alarm). Z poziomu timeline można:

- Skok do dowolnej godziny — klik na pasek czasu
- Wyeksportować klip do MP4/AVI
- Synchronizować odtwarzanie kilku kamer równolegle (multi-pane)
- Powiększyć fragment obrazu (digital zoom w nagraniu)

### Smart Search

Funkcja AI przeszukiwania nagrań po obiektach. Zaznacz strefę na obrazie → SS przebiega cały materiał i zwraca tylko klipy z ruchem w tej strefie. Bardzo przydatne do śledzenia kradzieży: „pokaz mi wszystkie momenty, gdy ktoś wszedł na taras między 22:00 a 6:00".

### Action Rules

System automatyzacji „IFTTT" w SS. Trigger → akcja. Przykłady:

| Trigger | Akcja |
|---|---|
| Motion w strefie „Brama" | Snapshot + e-mail + push do DS cam |
| Event AI „Person" | Włącz nagrywanie HD na 60 s |
| Zewnętrzny webhook (HA) | Włącz alarm dźwiękowy (PTZ z siren) |
| Wjazd auta (LPR) | Otwórz bramę (relay output) |

### Mobile — DS cam

Aplikacja na iOS i Android (darmowa). Funkcje:

- Podgląd live z wszystkich kamer (multi-cam grid)
- Odtwarzanie nagrań z timeline
- Push notifications na motion / event
- Sterowanie PTZ (touch swipe)
- Two-way audio (mikrofon + głośnik kamery)
- Dostęp przez QuickConnect (bez VPN, P2P Synology)

### Active Insight

Cloud-based monitoring stanu NAS + Surveillance Station. Powiadamia o:

- Awarii dysku (SMART)
- Wyłączeniu kamery (offline > X minut)
- Pełnym storage (do retencji)
- Próbach włamania (logi DSM)

Active Insight jest **darmowy** i bardzo wartościowy. Wystarczy konto Synology Account. Mobile alerty docierają w 1–2 minuty.

## Wymagania sprzętowe

| NAS | Kamery max | RAM | Storage | Roczne nagranie 4 kamer 4 MP H.265 |
|---|---|---|---|---|
| DS220+ | ~10 (real-time + nagrywanie) | 2 GB (rozszerz do 6 GB) | 2 × 8 TB WD Purple | ~6 TB |
| DS224+ / DS423+ | ~15 | 2 GB (do 6 GB) | 2–4 × 12 TB | ~6 TB |
| DS923+ | ~25–40 | 4 GB (do 32 GB) | 4 × 12 TB + 2 × SSD NVMe | ~6 TB / 4 kamer |
| RS1221+ (rackowe) | 40+ | 4 GB (do 32 GB) | 8 × 16 TB w RAID6 | ~12 TB / 8 kamer |

### Dyski

> Używaj dysków **CMR (Conventional Magnetic Recording)**, nie SMR. Klasa „Surveillance" (WD Purple Pro, Seagate SkyHawk, Toshiba S300) jest projektowana na 24/7 zapis sekwencyjny — typowy obciążeniowy profil CCTV. Dysk biurkowy WD Blue padnie po pół roku.

## Storage — kalkulacje

Bitrate kamery to klucz. Przy 4 MP H.265 z motion-aware codec średnio 2–4 Mbps. Przy 24/7:

```
4 Mbps × 86 400 s / dzień = 345 600 Mb / dzień = 43,2 GB / dzień / kamera
4 kamery × 43,2 GB × 30 dni = 5,2 TB / miesiąc

Dla retencji 30 dni 4 kamer 4 MP — potrzebujesz min. 6 TB użytkowych.
Z RAID1 (mirror) na 2 × 8 TB → ~7,3 TB użytkowych (po formatowaniu).
```

## Archiwum i backup

Surveillance Station oferuje kilka strategii archiwizacji:

- **Local recording** — zapis na dyskach NAS, automatyczna rotacja po retencji.
- **Archive Vault** — kopia nagrań na drugim Synology NAS (np. lokalizacja zdalna).
- **Cloud Backup** — wybrany klip do C2 Surveillance (~5 USD / kamera / m-c).
- **Manual export** — z konkretnego incydentu na pendrive (klip + zaszyfrowany raport).

## Porty i dostęp zdalny

| Port | Funkcja |
|---|---|
| 5000 / 5001 | DSM web UI (HTTP / HTTPS) |
| 9999 / 9998 | Surveillance Station (HTTP / HTTPS) |
| 5354 | Surveillance Station live streaming |
| QuickConnect | P2P bez forward portów — najwygodniej, ale relay przez Synology |

Rekomendacja 2026: nie wystawiaj 5000/5001 i 9999 na publiczny IP. Użyj **QuickConnect** (jak Hikvision Hik-Connect) albo **VPN** (Synology MR2200ac z OpenVPN, lub Tailscale jako pakiet w DSM).

## Co dalej

➡ [Frigate, BlueIris, Shinobi](05-03-frigate-blueiris.md)
