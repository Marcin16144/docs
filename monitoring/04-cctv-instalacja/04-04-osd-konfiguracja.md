# OSD i konfiguracja kamery

**Sekcja:** 04 Instalacja CCTV · **Aktualizacja:** 2026-05

Menu OSD/web kamery, ustawienia ekspozycji, balansu bieli, BLC/HLC/WDR, redukcji szumów 3D-DNR, maskowania prywatności (RODO), stref detekcji ruchu i harmonogramów.

## Dwie metody konfiguracji

| Metoda | Dostęp | Kiedy |
|---|---|---|
| **OSD analog** (joystick na kablu) | menu nakładane na obraz, mini-joystick na 5-żyłce | kamery analogowe AHD/CVI/TVI, brak interfejsu web |
| **WebUI HTTP/S** | przeglądarka, port 80/443, login admin | wszystkie kamery IP — pełen dostęp do ustawień |
| **OSD przez NVR** | menu rejestratora — „Camera Settings" | kamery podpięte do rejestratora producenta (np. Hikvision do Hik-Connect) |
| **Aplikacja mobilna** | Hik-Connect, Dahua DMSS, Reolink App | podstawowa konfiguracja, brak zaawansowanych opcji |
| **ONVIF** (np. SmartPSS, ONVIF Device Manager) | standard, działa z wieloma markami | tylko podstawowe parametry, nie zaawansowane |

## Ekspozycja — zarządzanie światłem

Ekspozycja to kombinacja trzech parametrów: **czas migawki**, **przysłona** (jeśli kamera ma motor IRIS), **czułość ISO/gain**. W trybie auto kamera sama dobiera, ale ręczna kontrola jest niezbędna w trudnych scenach.

| Parametr | Zakres | Praktyczne ustawienie |
|---|---|---|
| **Migawka (Shutter)** | 1/3 s – 1/100 000 s | Auto 1/25 – 1/1000 (Europa 50 Hz), max 1/100 dla zachowania kolorów w nocy |
| **Gain (wzmocnienie)** | 0–100 (lub 0–60 dB) | Max 30–40 dB — wyżej dużo szumu |
| **Iris** (DC/P-Iris) | F1.0 – F16 | Auto, P-Iris precyzyjniej steruje na podstawie sceny |
| **Anti-flicker** | 50 Hz / 60 Hz / off | **50 Hz w Polsce** — eliminuje migotanie świetlówek |
| **BLC / HLC / WDR** | off / on / poziom 1–5 | WDR dla kontrastu, BLC dla okna w tle, HLC dla świateł aut |

### Wybór trybu kontrastu — BLC vs HLC vs WDR

- **BLC (Backlight Compensation)** — kompensacja jasnego tła. Klasyczny przypadek: drzwi wejściowe, ktoś staje pod oknem. Bez BLC widzisz tylko sylwetkę, BLC „rozjaśnia" twarz. Mechanizm: kamera ignoruje jasne piksele i ekspozycję ustawia na ciemne.
- **HLC (Highlight Compensation)** — odwrotność: tłumi punktowe źródła światła (np. reflektory aut w nocy, latarnia w kadrze). Pixele białe ścina, dzięki temu widać tablice rejestracyjne aut.
- **WDR (Wide Dynamic Range)** — najpotężniejszy: kamera robi 2 ekspozycje (krótka dla świateł, długa dla cieni) i łączy je w jeden obraz. Real-WDR (sprzętowy) działa lepiej niż „digital WDR" (programowy). Jednostka: **dB** (np. 120 dB to świetnie).

## Balans bieli (WB)

Sceny pod różnym oświetleniem mają różną „temperaturę barwową" wyrażaną w kelwinach (K). Bez kompensacji obraz jest zażółcony lub zaniebieszczony.

| Źródło światła | Temperatura (K) | Tryb WB |
|---|---|---|
| Świeca | ~1800 | Manual / Indoor |
| Żarówka 60 W | 2700 | Indoor (tungsten) |
| Halogen | 3000 | Indoor |
| Świetlówka biała neutralna | 4000 | Fluorescent |
| Światło dzienne południe | 5500 | Outdoor / Daylight |
| Pochmurno | 6500 | Cloudy |
| Cień / niebieskie niebo | 10000 | Shade |

**ATW (Auto Tracking White Balance)** — uniwersalny tryb dla zmiennych warunków (kamera zewnętrzna). Dla kamery wewnątrz pod stałym oświetleniem ustaw **ręcznie**, by uniknąć „pływania" kolorów.

## Redukcja szumów — DNR i 3D-DNR

W nocy lub w słabym świetle kamera „kręci" gain. Wyższy gain = więcej szumu. Algorytmy DNR (Digital Noise Reduction) usuwają szum, ale za cenę rozmycia szybkich obiektów.

- **2D-DNR** — analizuje pojedynczą klatkę, usuwa szumy przestrzenne. Mniej obciąża procesor, łatwiej zaimplementować, słabiej redukuje.
- **3D-DNR** — porównuje wiele klatek czasowo, wykrywa stałe szumy losowe i usuwa je. Dużo lepszy efekt, ale przy szybkim ruchu może powodować artefakty „smużenia".

| Poziom 3D-DNR | Efekt | Stosowanie |
|---|---|---|
| Off | obraz surowy, szum widać | jasna scena, obiekty szybkie |
| Low (1–3) | lekka redukcja, brak smużenia | scena z ruchem (parking, brama) |
| Mid (4–6) | balans szum/smużenie | typowa scena ogrodu, podjazdu nocą |
| High (7–9) | czysty obraz, smużenie obiektów | scena statyczna, magazyn pusty |

## Maskowanie prywatności — wymóg RODO

> **Obowiązek prawny:** jeśli kamera obejmuje fragment cudzej działki, ulicy, okno sąsiada — musisz nałożyć maskę prywatności. Bez maski instalacja narusza RODO i prawo do prywatności, a właściciel kamery może zostać ukarany karą administracyjną lub pozwany cywilnie.

### Konfiguracja maski

1. Wejdź w WebUI kamery: *Configuration → Image → Privacy Mask*.
2. Włącz „Enable" i wybierz typ — solid color (czarna, biała, szara), mozaika, blur.
3. Narysuj poligon na obrazie (typowo do 4 stref). Większość kamer pozwala na 4–8 niezależnych masek.
4. Zapisz, sprawdź czy maska pojawia się **również na nagraniu** (nie tylko w podglądzie!).
5. Zrób screenshot zmaskowanego widoku do dokumentacji wewnętrznej (potwierdzenie zgodności RODO).

**Cienie maski:** niektóre kamery (zwłaszcza tańsze) maskują tylko podgląd „live", ale nagranie idzie bez maski. Sprawdź to wcześniej — odtwarzając archiwum z tej samej kamery na inną sesję.

## Strefy detekcji ruchu

Nagrywanie 24/7 z analizą całego obrazu produkuje setki false-positive (drzewa, ptaki, chmury, samochody na ulicy). Sensowne nagrywanie używa **masek detekcji** i **klas obiektów**.

| Typ detekcji | Mechanizm | False positive |
|---|---|---|
| **Motion Detection** (pikselowa) | różnica między klatkami | bardzo wiele (cienie, drzewa, deszcz) |
| **Line Crossing / Intrusion** | obiekt przekracza linię/wchodzi w obszar | średnio |
| **Object Detection (AI)** | klasyfikacja YOLO: human, vehicle, animal | mało, jeśli AI jakościowe |
| **Smart IR Detection** | ruch + wykrycie sylwetki | średnio |
| **Face Detection** | tylko twarz w kadrze wywołuje alarm | mało, ale tylko twarz frontalna |

### Mapa stref

```
Kamera bullet patrząca na podjazd:
+---------------------+
| niebo (ignoruj)     |  ← cała górna 1/3 obrazu — chmury, ptaki
|---------------------|
| ulica (ignoruj/AI)  |  ← obce auta = false positive, RODO
|---------------------|
| podjazd (DETEKCJA)  |  ← strefa zainteresowania
| ↓ AI: vehicle/human |
|---------------------|
| ścieżka (DETEKCJA)  |  ← pieszy do drzwi
+---------------------+
```

## Harmonogramy nagrywania

Tryb 24/7 jest najprostszy ale generuje gigabajty bezużytecznych danych. Lepiej skomponować harmonogram:

| Tryb | Co | Storage / dzień (4 MP, H.265) |
|---|---|---|
| **24/7 continuous** | nagrywa zawsze, na pełnym fps | ~30 GB |
| **Motion only** | nagrywa po wykryciu ruchu + pre/post buffer 5–30 s | 3–10 GB |
| **Scheduled + Motion** | dzień: motion, noc: continuous (lub odwrotnie) | 10–20 GB |
| **Smart codec H.265+ (Hikvision) / H.265 Pro+ (Dahua)** | continuous, ale niska klatka w bez-ruchu | 5–15 GB |

Dla domowego CCTV optymalny tryb: **Continuous 24/7 + H.265+ z niską klatką w bezruchu**. Zawsze jest nagranie (ważne przy incydentach „nikt nic nie widział"), a storage jest 3× mniejszy niż klasyczne 24/7.

## Twardnienie konta admin — bezpieczeństwo

1. **Zmień domyślne hasło** przy pierwszym logowaniu. Default Hikvision = 12345, Dahua = admin/admin.
2. **Wyłącz UPnP** i otwieranie portów na publiczny IP. Używaj VPN albo P2P producenta z 2FA.
3. **Wyłącz Telnet**, SSH, FTP — chyba że świadomie używasz.
4. **Firmware aktualny** — producenci kamer regularnie łatają luki (np. Hikvision CVE-2021-36260 — RCE na kilkadziesiąt modeli).
5. **Izolacja VLAN** — kamery w osobnym VLAN bez dostępu do internetu (NVR jako proxy do podglądu zewnętrznego).
6. **Lista IP whitelist** — dostęp do WebUI tylko z konkretnych adresów (np. tylko LAN).
7. **Logi** — włącz logowanie wszystkich logowań i błędów uwierzytelnienia.

## Co dalej

➡ [Sekcja 05 — ONVIF i RTSP](../05-cctv-software/05-01-onvif-rtsp.md)
