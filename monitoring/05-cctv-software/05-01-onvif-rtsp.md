# ONVIF i RTSP

**Sekcja:** 05 Software VMS · **Aktualizacja:** 2026-05

Standard ONVIF (Open Network Video Interface Forum), profile S/T/G/M, struktura URL RTSP, porty 80/554/8000, uwierzytelnianie Basic i Digest, testowanie ONVIF Device Manager.

## Dwa standardy, dwa poziomy abstrakcji

W świecie kamer IP są dwa kluczowe standardy, które razem składają się na interoperacyjność:

- **RTSP (Real Time Streaming Protocol)** — protokół warstwy aplikacji do *strumieniowania* wideo i audio (RFC 7826). Działa na porcie 554, transportuje strumień przez RTP/UDP lub RTP/TCP. Jest „tylko strumieniem" — żadnego sterowania PTZ, eventów, konfiguracji.
- **ONVIF** — to *warstwa zarządzania* nad RTSP. Definiuje WebService (SOAP/XML) do odkrywania kamer, pobierania ustawień, sterowania PTZ, pobierania zdarzeń. ONVIF na koniec też zwraca link RTSP, którym oglądasz wideo.

## ONVIF — profile

ONVIF zdefiniował kilka profili — każdy obejmuje określony zestaw funkcjonalności. Kamera może być zgodna z jednym lub kilkoma profilami.

| Profil | Rok | Co obejmuje | Typowe użycie |
|---|---|---|---|
| **Profile S** | 2011 | streaming wideo + audio, sterowanie PTZ, base config | kamera ↔ VMS — najczęstszy |
| **Profile G** | 2014 | nagrywanie i odtwarzanie z urządzenia (na karcie SD, w NVR) | dostęp do archiwum kamery z VMS |
| **Profile T** | 2018 | analityka video, kompresja H.265, metadata, motion alarm, IR | kamery z AI, smart analytics |
| **Profile M** | 2021 | metadata z analytics (face, plate, klasy obiektów) | integracja z systemem zewnętrznym (LPR, BI) |
| **Profile A** | 2017 | kontrola dostępu — czytniki, drzwi, użytkownicy | systemy KD, integracja z VMS |
| **Profile C** | 2014 | monitorowanie KD — eventy z czytników, status drzwi | uzupełnienie Profile A |
| **Profile D** | 2020 | peripherals (czytniki kart, klawiatury, biometria) | komponenty KD |

**Minimalna kompatybilność** dla CCTV: *Profile S*. Dla pełnej integracji z AI i analizą: *S + T + M*. Hikvision, Dahua, Axis, Bosch — wszyscy producenci wspierają S, większość T.

## Struktura URL RTSP

Każdy strumień RTSP ma znormalizowany URL. Schemat:

```
rtsp://[user:pass@]host[:port]/ścieżka_strumienia[?parametry]
```

### Przykłady realnych producentów

| Producent | URL strumienia głównego |
|---|---|
| **Hikvision** | `rtsp://admin:Pass@192.168.1.64:554/Streaming/Channels/101` |
| Hikvision sub | `rtsp://admin:Pass@192.168.1.64:554/Streaming/Channels/102` |
| **Dahua** | `rtsp://admin:Pass@192.168.1.108:554/cam/realmonitor?channel=1&subtype=0` |
| Dahua sub | `rtsp://admin:Pass@192.168.1.108:554/cam/realmonitor?channel=1&subtype=1` |
| **Axis** | `rtsp://root:Pass@192.168.1.90/axis-media/media.amp?videocodec=h264` |
| **Reolink** | `rtsp://admin:Pass@192.168.1.80:554/h264Preview_01_main` |
| Reolink sub | `rtsp://admin:Pass@192.168.1.80:554/h264Preview_01_sub` |
| **TP-Link Tapo** | `rtsp://user:Pass@192.168.1.50:554/stream1` |
| **Foscam** | `rtsp://user:Pass@192.168.1.50:88/videoMain` |
| **Bosch** | `rtsp://srv:Pass@192.168.1.10/rtsp_tunnel?h26x=4` |

### Strumień główny (main) vs pomocniczy (sub)

Większość kamer nadaje 2–3 strumienie jednocześnie z tej samej klatki sensora — z różną rozdzielczością i bitrate:

- **Main stream** — pełna rozdzielczość (4 MP, 4K), 25 fps, H.265, do nagrywania w VMS.
- **Sub stream** — niska rozdzielczość (640×360 lub D1), do podglądu na żywo (kafelki), aplikacji mobilnej. Mniejsze obciążenie sieci.
- **Third stream** (czasem) — średnia, np. 720p, dla matrix display lub thumb-cache.

## Porty sieciowe

| Port | Protokół | Funkcja |
|---|---|---|
| **80 / 443** | HTTP / HTTPS | WebUI konfiguracji, snapshot JPEG przez HTTP, ONVIF |
| **554** | RTSP/TCP | strumień wideo (control + transport) |
| 8554 | RTSP alternatywny | niektóre kamery (np. ESP32-CAM, niektóre Foscam) |
| **8000** | SDK Hikvision | natywne API Hikvision (np. iVMS-4200) |
| 37777 | SDK Dahua | natywne API Dahua (np. SmartPSS, DSS) |
| 3702 | UDP WS-Discovery | auto-odkrywanie kamer ONVIF w sieci |
| 1900 | UDP SSDP | UPnP discovery |
| 123 | NTP | synchronizacja czasu (timestamp na nagraniach) |

> **Nie wystawiaj portów na publiczny IP.** RTSP nie szyfruje hasła (chyba że SRTP — rzadko wspierane), a porty 8000/37777 są tematem regularnych ataków brute-force i exploitów. Używaj VPN (WireGuard, Tailscale), albo P2P producenta z 2FA.

## Uwierzytelnianie

- **Basic Auth** — login + hasło w nagłówku Base64. *Hasło de facto w plain text*. Tylko HTTPS.
- **Digest Auth** — challenge-response z hashem MD5 (lub SHA-256 w nowszych). Hasło nigdy nie idzie po sieci. **Standard ONVIF / RTSP**.
- **WS-Security UsernameToken** — używane przez ONVIF SOAP, hash hasła z nonce i timestamp. Wymaga zsynchronizowanego czasu (max 5 min różnicy).

Jeśli kamera „nie chce się dodać" do VMS, sprawdź zegar w obydwu urządzeniach. Po stronie ONVIF tolerancja czasu to ~5 minut — nieaktualny zegar = błąd 401 Unauthorized.

## Discovery — automatyczne odkrywanie

ONVIF używa protokołu **WS-Discovery** (UDP multicast na 239.255.255.250:3702). VMS rozsyła „Hello, kim jesteś?" — wszystkie kamery odpowiadają swoim adresem i listą wspieranych profili.

### Narzędzia do testowania

| Narzędzie | OS | Funkcjonalność |
|---|---|---|
| **ONVIF Device Manager** | Windows | discovery, podgląd RTSP, PTZ, snapshot, eventy. Darmowe. |
| **Happytimesoft ONVIF Test Tool** | Win / Linux | profesjonalne testowanie zgodności profili |
| **VLC** | Win / Mac / Linux | otworzy każdy URL RTSP — najszybszy test |
| **ffplay** / **ffmpeg** | multi | `ffplay rtsp://...` — niskoporząd. test |
| **Wireshark** | multi | capture pakietów ONVIF/RTSP — debug uwierzytelnienia |

### Test RTSP w 5 sekund (VLC)

```
Otwórz VLC → Media → Otwórz strumień sieciowy
→ wklej: rtsp://admin:Pass@192.168.1.64:554/Streaming/Channels/101
→ Odtwórz

Jeśli pojawi się obraz — RTSP działa.
Jeśli „nie udało się otworzyć" — sprawdź firewall i hasło.
```

## FFmpeg — grab snapshot lub nagraj

```bash
# Snapshot JPG co 1 sekundę:
ffmpeg -rtsp_transport tcp -i "rtsp://admin:Pass@192.168.1.64:554/Streaming/Channels/101" \
       -vf fps=1 -update 1 snapshot.jpg

# Nagraj 60 sekund do pliku:
ffmpeg -rtsp_transport tcp -i "rtsp://admin:Pass@192.168.1.64:554/Streaming/Channels/101" \
       -t 60 -c copy nagranie.mp4

# Re-transmisja RTSP w RTMP (np. na YouTube):
ffmpeg -rtsp_transport tcp -i "rtsp://..." -c copy -f flv rtmp://live.youtube.com/...
```

Parametr `-rtsp_transport tcp` wymusza TCP zamiast UDP. Lepsze przy gorszej sieci (mniej dropów), gorsze przy obciążonej sieci (powtórzenia).

## Snapshot przez HTTP — bez RTSP

Czasem szybciej (i lżej) jest pobrać pojedynczą klatkę JPG zamiast strumień:

| Producent | URL snapshot |
|---|---|
| Hikvision | `http://admin:Pass@192.168.1.64/ISAPI/Streaming/channels/101/picture` |
| Dahua | `http://admin:Pass@192.168.1.108/cgi-bin/snapshot.cgi?channel=1` |
| Axis | `http://root:Pass@192.168.1.90/axis-cgi/jpg/image.cgi?resolution=1920x1080` |
| Reolink | `http://192.168.1.80/cgi-bin/api.cgi?cmd=Snap&channel=0&user=admin&password=Pass` |
| ONVIF (uniwersalny) | wywołanie SOAP `GetSnapshotUri`, potem GET HTTP |

## Częste problemy

| Symptom | Przyczyna | Rozwiązanie |
|---|---|---|
| 401 Unauthorized | złe hasło, lub zegar > 5 min off | NTP sync, popraw hasło, sprawdź Digest vs Basic |
| 404 / „stream not found" | zły path w URL | sprawdź w dokumentacji producenta, użyj ONVIF Device Manager do pobrania URL |
| Zielony pasek / artefakty | pakiety UDP gubione | wymuś `-rtsp_transport tcp` |
| Opóźnienie 5–10 s | duży bufor VMS, GOP/keyframe za długie | zmniejsz GOP do 1 s, low-latency profil |
| „No video signal" w VMS | kodek H.265 a VMS rozumie tylko H.264 | zmień encoding w kamerze, lub uzupełnij codec pack w VMS |
| Kamera „znika" po godzinie | DHCP lease wygasł, IP się zmieniło | statyczny IP lub DHCP reservation |

## Co dalej

➡ [Synology Surveillance Station](05-02-synology-surveillance.md)
