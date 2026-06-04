# NVR, DVR, HVR — różnice

**Sekcja:** 03 Rejestratory CCTV · **Aktualizacja:** 2026-05

Network / Digital / Hybrid Video Recorder — serce systemu CCTV. Który rejestrator do jakich kamer, ile kanałów, jaka kompresja i przepustowość zapisu. Kiedy IP po PoE, a kiedy zostać przy koaksjalu.

## Trzy rodzaje rejestratorów

Wybór rejestratora wynika wprost z typu kamer i istniejącego okablowania. To pierwsza decyzja przy projektowaniu systemu — od niej zależy reszta (dyski, switche, zasilanie).

### DVR — Digital Video Recorder

Rejestrator do kamer **analogowych** i nowoczesnych standardów HD-over-coax: *AHD* (Analog High Definition), *HD-TVI* (Transport Video Interface, Hikvision/Techwin), *HD-CVI* (Composite Video Interface, Dahua) oraz klasyczny CVBS (PAL). Sygnał wideo idzie po kablu **koncentrycznym (koaksjalu) RG-59 / RG-6** z gniazdami BNC, zasilanie osobno (12 V DC lub centralny zasilacz). Współczesne DVR są zwykle *pentabrydowe* — jeden tor BNC automatycznie rozpoznaje AHD/TVI/CVI/CVBS, a część kanałów można przełączyć na IP.

### NVR — Network Video Recorder

Rejestrator do kamer **IP**. Kamera sama koduje strumień (H.264/H.265) i wysyła go po sieci **Ethernet (skrętka UTP/FTP)**, najczęściej z zasilaniem *PoE* jednym kablem. NVR przyjmuje gotowy strumień RTSP/ONVIF i zapisuje go na dysku — sam nie koduje obrazu (poza ewentualnym transkodowaniem substreamu). Daje najwyższe rozdzielczości (4K/8MP, 12MP, a w macierzowych nawet wyżej) i najlepszą analizę po stronie kamery.

### HVR — Hybrid Video Recorder

Hybryda obsługująca **jednocześnie** kamery analogowe/HDCVI po BNC *i* kamery IP po sieci. Idealny przy **modernizacji** istniejącej instalacji koaksjalnej — stare kamery analogowe zostają, a nowe punkty dokłada się jako IP, bez przeciągania nowego okablowania do wszystkich kamer. W praktyce większość „DVR" Dahua/Hikvision to dziś właśnie HVR (XVR / Turbo HD), bo dokładają wolne kanały IP ponad liczbę torów BNC.

W nomenklaturze Dahua hybryda nazywa się **XVR** (np. XVR5216A-4KL-I3), u Hikvision to seria **Turbo HD iDS-72xx HQHI / DS-72xx HGHI**. „Czysty" analog bez kanałów IP to dziś rzadkość.

## DVR vs NVR vs HVR — porównanie

| Cecha | DVR | NVR | HVR / XVR |
| --- | --- | --- | --- |
| Typ kamer | analog / AHD / TVI / CVI (BNC) | tylko IP (ONVIF/RTSP) | analog/HDCVI *+* IP |
| Okablowanie wideo | koncentryk RG-59/RG-6 + zasilanie osobno | skrętka UTP cat5e/cat6, PoE 1 kablem | koncentryk + skrętka (mieszane) |
| Maks. rozdzielczość | do 8MP (4K) po koaksjalu (TVI/CVI 4K) | do 12MP / 4K i wyżej | analog do 8MP, IP do 12MP |
| Zasilanie kamer | oddzielny tor 12 V DC | PoE z NVR lub switcha | analog osobno, IP po PoE |
| Maks. długość kabla | koaksjal 300–500 m | UTP 100 m (dalej switch/światłowód) | zależnie od toru |
| Analiza (VCA/AI) | ograniczona, po stronie DVR | zaawansowana, po stronie kamery | mieszana |
| Koszt punktu | niski (kamera analog tania) | wyższy (kamera IP + PoE) | średni |
| Skalowalność | słaba (1 BNC = 1 kamera) | bardzo dobra (switche, kaskady) | dobra |
| Zastosowanie | budżet, retrofit analogu | nowe instalacje, duże systemy | migracja analog → IP |

**Reguła kciuka:** nowa instalacja od zera → **NVR + kamery IP PoE**. Masz działający koaksjal i chcesz dołożyć kilka punktów → **HVR/XVR**. Czysty budżet, dużo kamer, jakość HD wystarczy → **DVR z kamerami AHD/TVI**.

## Liczba kanałów

Rejestratory produkowane są w stałych rozmiarach: **4, 8, 16, 32, 64** kanały (większe macierzowe 128/256). Kanał = jeden strumień kamery. Zasada: *kupuj rejestrator z zapasem 1 rozmiaru* — przy 6 planowanych kamerach bierz 8-kanałowy, przy 12 → 16-kanałowy. Dokładanie kamer później jest pewne, a wymiana rejestratora droga.

- **4 kanały** — dom jednorodzinny, mały sklep
- **8 kanałów** — dom z działką, mały magazyn, biuro
- **16 kanałów** — średni obiekt, parking, hala
- **32 / 64 kanały** — duże obiekty, kilka budynków, monitoring miejski

Uwaga na **liczbę zatok dyskowych (HDD bays)**, nie tylko kanałów. NVR 16-kanałowy z 1 zatoką pomieści tylko 1 dysk (np. 12 TB) — przy 16 kamerach 4K to często za mało na 30 dni. Większe systemy wymagają 2, 4 lub 8 zatok.

## Rozdzielczość per kanał i bandwidth

Każdy NVR ma dwa kluczowe limity, niezależne od liczby kanałów:

- **Maksymalna rozdzielczość na kanał** — np. „do 8MP per channel" (4K) albo „do 12MP".
- **Incoming bandwidth** (przepustowość zapisu) — sumaryczny bitrate wszystkich kamer wpadających do NVR, w **Mbps**. To realny limit systemu.

Przykładowe wartości incoming bandwidth: budżetowy NVR 8-kan. ~80 Mbps, średni 16-kan. ~160–256 Mbps, wydajny 32-kan. ~320–384 Mbps. Jeśli zsumowany bitrate kamer przekroczy ten limit, NVR będzie gubił klatki albo odrzuci część strumieni.

| Rozdzielczość | Piksele | Typowy bitrate H.265 (główny strumień) |
| --- | --- | --- |
| 2MP / 1080p | 1920×1080 | 2–4 Mbps |
| 4MP | 2560×1440 | 4–6 Mbps |
| 5MP | 2592×1944 | 5–8 Mbps |
| 8MP / 4K | 3840×2160 | 8–12 Mbps |
| 12MP | 4000×3000 | 12–16 Mbps |

**Przykład przekroczenia:** 16 kamer 8MP @ 10 Mbps = 160 Mbps. NVR z limitem 160 Mbps jest „na styk" — bez zapasu na szczyty ruchu (więcej detail = wyższy bitrate VBR). Bierz model z incoming bandwidth ≥ 256 Mbps albo zejdź na 4MP.

## Kompresja: H.264 vs H.265 vs H.265+

Kompresja decyduje, ile miejsca zajmie nagranie i jaki bandwidth obciąży NVR. To największa dźwignia oszczędności na dyskach.

| Kodek | Opis | Oszczędność vs H.264 |
| --- | --- | --- |
| **H.264 / AVC** | standard od lat, uniwersalna kompatybilność | — |
| **H.265 / HEVC** | następca H.264, lepsza predykcja, większe bloki CTU | ~40–50% mniej |
| **H.265+ (Smart codec)** | H.265 + ROI + dynamiczny GOP + redukcja szumu w tle | do ~70–80% mniej |

Mechanizm *Smart codec* (Hikvision H.265+, Dahua Smart H.265+) wykrywa statyczne tło i obniża dla niego bitrate, a pełną jakość trzyma tylko tam, gdzie jest ruch (ROI — region of interest). Dynamiczny GOP wydłuża odstęp między klatkami kluczowymi (I-frame) w spokojnych scenach.

Dla typowej sceny statycznej (parking nocą, korytarz) H.265+ potrafi zejść z 8 Mbps na 1,5–2 Mbps. To różnica między 12 TB a 24 TB dysku przy tej samej retencji. **Zawsze włącz H.265+ jeśli kamera i NVR go wspierają.**

H.265+ jest **niestandardowym rozszerzeniem producenta** — strumień zwykle nie odtworzy się w obcym VMS czy przeglądarce. Do integracji z systemem firm trzecich zostaw czysty H.265 albo dodatkowy substream H.264.

## Marki i przykładowe modele (ceny 2026)

### Hikvision (seria DS-7xxx NVR / DVR)

| Model | Typ | Kanały / zatoki | Bandwidth / uwagi | Cena (2026) |
| --- | --- | --- | --- | --- |
| **DS-7104NI-Q1/4P** | NVR | 4 kan. / 1 HDD / 4× PoE | 40 Mbps, do 6MP | ~520 zł |
| **DS-7608NXI-K2/8P** | NVR AcuSense | 8 kan. / 2 HDD / 8× PoE | 80 Mbps, 4K, AI | ~1450 zł |
| **DS-7616NXI-K2/16P** | NVR AcuSense | 16 kan. / 2 HDD / 16× PoE | 160 Mbps, 4K, AI | ~2200 zł |
| **DS-7732NI-M4** | NVR | 32 kan. / 4 HDD | 256 Mbps, 12MP | ~3100 zł |
| **iDS-7208HQHI-M1/S** | HVR Turbo HD | 8 kan. analog + 2 IP / 1 HDD | AcuSense, 4MP TVI | ~780 zł |

### Dahua (seria NVR4xxx / XVR)

| Model | Typ | Kanały / zatoki | Bandwidth / uwagi | Cena (2026) |
| --- | --- | --- | --- | --- |
| **NVR4104HS-P-4KS3** | NVR | 4 kan. / 1 HDD / 4× PoE | 80 Mbps, 4K, SMD Plus | ~640 zł |
| **NVR4208-8P-4KS3** | NVR | 8 kan. / 2 HDD / 8× PoE | 200 Mbps, AI | ~1550 zł |
| **NVR4216-16P-4KS3** | NVR | 16 kan. / 2 HDD / 16× PoE | 200 Mbps, 16MP decode | ~2350 zł |
| **NVR5432-4KS2** | NVR Pro | 32 kan. / 4 HDD | 384 Mbps, faces/ANPR | ~3400 zł |
| **XVR5216A-4KL-I3** | HVR / XVR | 16 kan. penta + IP / 2 HDD | 4K, WizSense AI | ~1380 zł |

### Pozostałe marki

| Marka | Przykładowy model | Charakterystyka | Cena (2026) |
| --- | --- | --- | --- |
| **Reolink** | RLN16-410 (16 kan.) | tanie NVR pod własne kamery, prosta apka, 2 HDD | ~950 zł |
| **Uniview (UNV)** | NVR302-08E2-P8 | dobry stosunek cena/AI (LightHunter), 8× PoE | ~1250 zł |
| **Annke** | NVR N48PCK (8 kan.) | konsumencki, PoE, kompatybilny z TVI/IP | ~1100 zł |
| **TP-Link VIGI** | VIGI NVR1016H | 16 kan., bez PoE (osobny switch), tania platforma | ~880 zł |

## PoE wbudowane w NVR vs osobny switch

Wiele NVR ma wbudowane porty PoE (oznaczenie w nazwie: `/8P` = 8 portów PoE). To wygodne plug-and-play — kamera w port, NVR ją zasila i automatycznie dodaje. Ale są ograniczenia:

| Kryterium | NVR z wbudowanym PoE | NVR + osobny switch PoE |
| --- | --- | --- |
| Instalacja | plug-and-play, auto-dodawanie | ręczna konfiguracja IP |
| Budżet PoE | ograniczony (np. 8 portów × ~25 W, łączny limit) | dowolny — dobierasz switch |
| Topologia | gwiazda od NVR, max ~100 m do kamery | switche kaskadowo, światłowód, dalej |
| Sieć | kamery w izolowanej podsieci NVR (zwykle 10.x) | kamery w sieci LAN, dostęp z innych urządzeń |
| Rozbudowa | limit liczby portów na płycie | dowolnie dużo kamer |

Wbudowane porty PoE tworzą zwykle **osobną podsieć** (np. 10.1.1.x) niewidoczną z LAN. To plus dla bezpieczeństwa (kamery odcięte od internetu), ale minus, jeśli chcesz oglądać kamerę z innego serwera VMS — wtedy lepszy jest osobny switch w sieci LAN. Łączny budżet PoE bywa niższy niż suma portów — np. „8× PoE, max 110 W" to ~13,7 W na port, za mało dla PTZ.

## Kluczowe funkcje rejestratora

### ANR — Automatic Network Replenishment

Mechanizm odporności na awarię sieci. Gdy łącze NVR↔kamera padnie, kamera **zapisuje nagranie na własnej karcie microSD**. Po przywróceniu sieci NVR automatycznie *dociąga* brakujący materiał z karty i uzupełnia lukę w archiwum. Wymaga kamery z slotem SD i wsparciem ANR (Hikvision ANR, Dahua ANR). Krytyczne dla łączy radiowych i obiektów rozproszonych.

### VCA — Video Content Analysis

Analiza obrazu: detekcja przekroczenia linii (line crossing), wtargnięcia w strefę (intrusion), pozostawionego/zabranego przedmiotu, zliczanie ludzi, ANPR (tablice rejestracyjne), rozpoznawanie twarzy. W nowoczesnych systemach (Hikvision *AcuSense*, Dahua *WizSense*) AI rozróżnia **człowieka od pojazdu** i odrzuca fałszywe alarmy od zwierząt, deszczu czy ruchu liści.

### Wyjścia HDMI / VGA

NVR podłącza się bezpośrednio do monitora przez **HDMI** (zwykle do 4K) i/lub **VGA**. Modele wyższej klasy mają *dwa niezależne wyjścia HDMI* (spot monitor) — np. ściana z podglądem live na jednym ekranie i menu/odtwarzanie na drugim. Wyjście nie wymaga komputera — rejestrator jest samodzielny.

### P2P i dostęp chmurowy

Funkcja P2P (peer-to-peer) pozwala połączyć się z NVR z aplikacji mobilnej **bez publicznego IP ani przekierowań portów** — przez serwer pośredniczący producenta (Hikvision *Hik-Connect*, Dahua *DMSS / gDMSS*). Skanujesz QR z numerem seryjnym i masz podgląd zdalny.

**Bezpieczeństwo P2P:** chmura producenta to wygoda kosztem prywatności — strumień przechodzi przez serwery zewnętrzne. Dla obiektów wrażliwych preferuj **VPN do lokalnej sieci** zamiast P2P i koniecznie **zmień domyślne hasło admina** oraz wyłącz UPnP. Rejestratory CCTV są częstym celem botnetów.
