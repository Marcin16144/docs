# Dyski HDD Surveillance

**Sekcja:** 03 Rejestratory CCTV · **Aktualizacja:** 2026-05

WD Purple, Seagate SkyHawk, Toshiba S300 — dyski projektowane pod ciągły zapis 24/7. Dlaczego nie wolno wkładać dysku desktopowego do rejestratora, jak policzyć potrzebną pojemność i czym jest workload rating oraz MTBF.

## Dlaczego dysk „surveillance"

System CCTV zapisuje obraz **bez przerwy, 24 godziny na dobę, 365 dni w roku**. To zupełnie inny profil pracy niż komputer biurowy, który leży bezczynnie nocą. Dyski monitoringowe (WD Purple, Seagate SkyHawk, Toshiba S300) projektowane są właśnie pod ten ciągły, sekwencyjny strumień zapisu. Kluczowe cechy:

- **Workload 24/7** — przystosowane do nieprzerwanej pracy, w przeciwieństwie do dysków desktop liczonych na ~2400 h/rok.
- **Firmware ATA Streaming** — priorytet dla płynnego strumienia wideo zamiast bezbłędnego odczytu pojedynczego sektora; dysk nie „zawiesza się" na długiej korekcji błędu, by nie gubić klatek.
- **Obsługa wielu strumieni** — WD Purple do **64 kamer** (technologia AllFrame), SkyHawk do 64 kamer (ImagePerfect) — wiele jednoczesnych zapisów to losowy, nie czysto sekwencyjny dostęp.
- **Tolerancja ciepła** — rejestratory bywają w ciasnych szafkach bez wentylacji; dyski surveillance znoszą wyższe temperatury otoczenia.
- **Niska wibracja / czujniki RV** — modele PRO mają czujniki rotational vibration do pracy w macierzach wielodyskowych, gdzie drgania sąsiednich talerzy zaburzają pozycjonowanie głowic.

Dyski monitoringowe są zoptymalizowane pod **zapis** (write-heavy ~90%). Odczyt zdarza się tylko przy odtwarzaniu archiwum. To odwrotnie niż w NAS-ie czy serwerze plików.

## Dyski monitoringowe — modele i ceny 2026

| Model | Pojemności | Workload (TB/rok) | RPM / cache | Maks. kamer | Cena (2026) |
| --- | --- | --- | --- | --- | --- |
| **WD Purple** | 1–8 TB | 180 TB/rok | 5400 / 64–256 MB | do 64 | 2 TB ~290 zł · 4 TB ~440 zł · 8 TB ~820 zł |
| **WD Purple Pro** | 8–22 TB | 550 TB/rok | 7200 / 256–512 MB | do 64 + AI/deep learning | 8 TB ~990 zł · 12 TB ~1450 zł · 18 TB ~2100 zł · 22 TB ~2650 zł |
| **Seagate SkyHawk** | 1–8 TB | 180 TB/rok | 5400–7200 / 64–256 MB | do 64 | 2 TB ~280 zł · 4 TB ~430 zł · 8 TB ~810 zł |
| **Seagate SkyHawk AI** | 8–24 TB | 550 TB/rok | 7200 / 256–512 MB | 32 HD + 32 AI stream | 10 TB ~1250 zł · 16 TB ~1950 zł · 24 TB ~2950 zł |
| **Toshiba S300** | 1–6 TB | 180 TB/rok | 5400–5700 / 64–128 MB | do 64 | 2 TB ~270 zł · 4 TB ~420 zł · 6 TB ~620 zł |
| **Toshiba S300 Pro** | 4–10 TB | 180–300 TB/rok | 7200 / 256 MB | do 64 | 8 TB ~880 zł · 10 TB ~1150 zł |

Linie **„Pro" / „AI"** (Purple Pro, SkyHawk AI) różnią się nie tylko pojemnością — mają wyższy workload (550 vs 180 TB/rok), 7200 RPM, czujniki wibracji RV i obsługę dodatkowych strumieni AI z kamer. Wybierz je dla macierzy ≥ 8 dysków lub gdy NVR prowadzi analizę deep-learning.

## MTBF i workload rating

Dwa parametry niezawodności, których nie wolno mylić:

- **MTBF (Mean Time Between Failures)** — statystyczny średni czas między awariami, np. **1 000 000 h** (Purple) lub **2 000 000 h** (Purple Pro / SkyHawk AI). To wartość populacyjna, NIE gwarancja, że dany egzemplarz przeżyje 114 lat — oznacza, że w dużej populacji dysków taki jest średni odstęp awarii.
- **Workload rating (TB/rok)** — ile danych dysk może bezpiecznie zapisać/odczytać rocznie w ramach gwarancji. Przekroczenie skraca żywotność i bywa podstawą odrzucenia reklamacji.

| Klasa | Workload | MTBF | Gwarancja |
| --- | --- | --- | --- |
| WD Purple | 180 TB/rok | 1,0 mln h | 3 lata |
| WD Purple Pro | 550 TB/rok | 2,5 mln h | 5 lat |
| Seagate SkyHawk | 180 TB/rok | 1,0 mln h | 3 lata |
| Seagate SkyHawk AI | 550 TB/rok | 2,0 mln h | 5 lat (+ Rescue 3 lata) |
| Toshiba S300 (Pro) | 180 / 300 TB/rok | 1,0 / 1,2 mln h | 3 lata |

**Czy 180 TB/rok wystarczy?** 8 kamer 4MP @ 4 Mbps zapisywanych ciągle = ok. 126 TB zapisu rocznie na cały system. Rozłożone na 1 dysk to mieści się w 180 TB/rok. Ale przy dużych systemach i ciągłym nadpisywaniu szybko zbliżasz się do limitu — wtedy klasa Pro (550 TB/rok) jest bezpieczniejsza.

## Dlaczego NIE dysk desktop ani NAS

| Klasa dysku | Przykład | Profil pracy | Dlaczego nie do CCTV |
| --- | --- | --- | --- |
| **Desktop** | WD Blue, Seagate BarraCuda | ~2400 h/rok, biuro | brak firmware streaming, niski workload (~55 TB/rok), nieprzystosowany do 24/7 — szybka awaria |
| **NAS** | WD Red (Plus/Pro), Seagate IronWolf | 24/7, ale read-heavy, RAID, błędy korygowane dokładnie (TLER/ERC) | zoptymalizowany pod *odczyt* i integralność danych, nie pod ciągły strumień zapisu wielu kamer; działa, ale to nie jego profil |
| **Surveillance** | WD Purple, SkyHawk, S300 | 24/7 write-heavy, wiele strumieni, ATA streaming | — właściwy wybór — |

**WD Blue do rejestratora to najczęstszy błąd taniego montażu.** Dysk desktopowy w pracy 24/7 zużywa się wielokrotnie szybciej, a jego firmware przy próbie korekcji błędu potrafi „zamrozić" zapis na sekundy — w tym czasie giną klatki, a rejestrator może oznaczyć dysk jako uszkodzony. Dysk NAS (WD Red) zadziała, ale płacisz za funkcje (TLER, integralność RAID), których CCTV nie potrzebuje, a brakuje optymalizacji write-streaming.

## Kalkulator retencji

Pojemność potrzebna na założoną liczbę dni zapisu. Wzór bazowy (zapis ciągły 24/7):

```
Storage [GB] = (bitrate[Mbps] × liczba_kamer × 3600 × 24 × dni) / (8 × 1024 × 1024)

  bitrate  — średni bitrate jednej kamery w megabitach/s (Mbps)
  3600×24  — sekundy w dobie (86 400 s)
  / 8      — bity → bajty
  /1024/1024 — bajty → GB (megabity → gigabajty)
```

Wersja praktyczna w TB dla całego systemu:

```
Storage [TB] ≈ (bitrate[Mbps] × kamery × dni × 0,0108) / 1000

  współczynnik 0,0108 TB to dzienny zapis 1 kamery na 1 Mbps
  (1 Mbps × 86400 s / 8 / 1000 / 1000 ≈ 0,0108 TB/dobę)
```

### Przykład: 8 kamer 4MP H.265 @ 4 Mbps, 30 dni

```
Dzienny zapis 1 kamery: 4 Mbps × 86400 s / 8 = 172 800 Mb = 21 600 MB ≈ 21,1 GB/dobę
8 kamer × 21,1 GB     = 168,8 GB/dobę
× 30 dni              = 5 064 GB ≈ 4,95 TB

+ rezerwa systemowa ~10% (system plików, fragmentacja) → ~5,5 TB
Dobór dysku: 6 TB (WD Purple / SkyHawk)
```

| Scenariusz | Bitrate/kam. | Kamery | Dni | Potrzeba | Sugerowany dysk |
| --- | --- | --- | --- | --- | --- |
| Dom — 4 kam. 4MP H.265+ | 2 Mbps | 4 | 30 | ~2,5 TB | 4 TB Purple |
| Dom rozbudowany — 8 kam. 4MP H.265 | 4 Mbps | 8 | 30 | ~5,0 TB | 6 TB Purple / SkyHawk |
| Sklep — 8 kam. 8MP H.265 | 8 Mbps | 8 | 30 | ~10,1 TB | 12 TB Purple Pro |
| Firma — 16 kam. 4MP H.265 | 4 Mbps | 16 | 30 | ~10,1 TB | 12 TB Purple Pro |
| Magazyn — 32 kam. 4MP H.265 | 4 Mbps | 32 | 30 | ~20,3 TB | 2× 12 TB lub 24 TB SkyHawk AI |
| Obiekt — 16 kam. 8MP H.265 | 8 Mbps | 16 | 30 | ~20,3 TB | 2× 12 TB Purple Pro |

**Jak realnie zmniejszyć pojemność:** włącz **H.265+ / Smart codec** (bitrate spada nawet o 60–70%), ustaw **nagrywanie na detekcji ruchu** zamiast ciągłego dla scen statycznych, albo obniż FPS strumienia głównego do 15–20 kl./s. Każdy z tych zabiegów potrafi podwoić liczbę dni przy tym samym dysku.

Producenci podają pojemność w **TB dziesiętnych** (1 TB = 1000 GB), a system operacyjny liczy w **TiB binarnych** (1 TiB = 1024 GiB). Dysk „4 TB" to realnie ~3,64 TiB użytecznych. Dlatego zawsze dolicz rezerwę i nie planuj na 100% nominalnej pojemności.

## SMART, hot-swap, recykling nagrań

### Monitoring S.M.A.R.T.

Rejestratory NVR/DVR czytają atrybuty **S.M.A.R.T.** dysku i ostrzegają przed awarią. Kluczowe atrybuty do obserwacji:

| Atrybut | Znaczenie | Sygnał alarmowy |
| --- | --- | --- |
| **05 — Reallocated Sectors** | realokowane uszkodzone sektory | wartość rośnie → dysk się sypie |
| **C5 — Current Pending Sectors** | sektory czekające na realokację | > 0 → ryzyko utraty danych |
| **C6 — Uncorrectable** | błędy nieusuwalne | > 0 → pilna wymiana |
| **C2 — Temperature** | temperatura dysku | > 55–60 °C → wentylacja |
| **09 — Power-On Hours** | godziny pracy | kontekst zużycia |

Włącz w NVR **cykliczny test SMART** (zwykle co tydzień) i powiadomienia e-mail/push przy błędzie HDD. Dysk najczęściej daje sygnały (rosnące C5/05) na tygodnie przed całkowitą awarią — to czas, by zrobić kopię i wymienić.

### Hot-swap

W rejestratorach i NAS-ach z kieszeniami (caddy) dysk można wymienić **bez wyłączania urządzenia** — hot-swap. Przy macierzy RAID system odbuduje dane na nowym dysku w tle. Dotyczy modeli z zatokami wyciąganymi od frontu (Hikvision DS-96xxx, Dahua 8-bay, Synology/QNAP). Tańsze NVR z dyskiem montowanym wewnątrz wymagają odkręcenia obudowy i wyłączenia.

### Recykling nagrań (overwrite oldest)

Domyślny tryb pracy CCTV: gdy dysk się zapełni, rejestrator **nadpisuje najstarsze nagrania** (FIFO — first in, first out), tworząc ciągłe „przesuwane okno" retencji. Dzięki temu zawsze masz ostatnie N dni, a system nie staje przy pełnym dysku. Alternatywa „overwrite off" zatrzymuje zapis przy zapełnieniu — używana tylko, gdy archiwum musi być zewnętrznie wyeksportowane przed nadpisaniem (dowody, monitoring objęty przepisami).

Tryb nadpisywania oznacza, że **nagranie sprzed retencji znika bezpowrotnie**. Materiał, który może być dowodem (włamanie, kolizja), wyeksportuj na pendrive/dysk zaraz po zdarzeniu — zanim cykl FIFO go skasuje. Przy 30-dniowej retencji masz na to maksymalnie miesiąc.
