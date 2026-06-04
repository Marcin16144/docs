# Przewody — UTP, koax, światłowód

**Sekcja:** 04 Instalacja CCTV · **Aktualizacja:** 2026-05

Dobór medium transmisyjnego dla CCTV: Cat5e/6/6A dla IP, koncentryk RG-59/RG-6 dla analog HD, światłowód dla dystansów ponad 100 m. Klasy kabli zewnętrznych.

## Trzy światy okablowania CCTV

| Medium | Technologia kamery | Max zasięg | Sygnał + zasilanie | Koszt/m (2026) |
|---|---|---|---|---|
| **UTP/FTP Cat5e/6/6A** | IP (ONVIF), PoE | **100 m** (Ethernet) | tak (PoE 1 kabel) | 2–6 zł |
| **Koncentryk RG-59 / RG-6** | HD-CVI / HD-TVI / AHD, CVBS | **300–500 m** (HD) | nie (osobny zasilacz) | 3–8 zł |
| **Światłowód SM 9/125** | IP (przez konwerter) | **do 10 km** (1 Gb/s) | nie (zasilanie osobno) | 4–12 zł + media converter |
| **Światłowód MM OM3/OM4** | IP (przez konwerter) | **300–550 m** (1 Gb/s) | nie | 5–10 zł |

## UTP/FTP — standard dla kamer IP

Skrętka kategorii 5e lub wyżej jest dziś dominującym wyborem. Niesie sygnał Ethernet + zasilanie PoE w jednym kablu, co radykalnie upraszcza instalację.

| Kategoria | Pasmo | Max prędkość | Zastosowanie w CCTV |
|---|---|---|---|
| **Cat5e** | 100 MHz | 1 Gb/s do 100 m | kamery 2–4 MP, większość instalacji domowych |
| **Cat6** | 250 MHz | 1 Gb/s do 100 m (10 Gb/s do 55 m) | 4–8 MP, mniej przesłuchów, lepsza odporność na PoE+ |
| **Cat6A** | 500 MHz | 10 Gb/s do 100 m | kamery 12 MP+, agregacja na switchu, multicast |
| **Cat7 / Cat8** | 600 MHz / 2 GHz | 10 / 40 Gb/s | rzadko stosowane w CCTV — overkill |

### UTP vs FTP/STP — kiedy ekran

- **UTP** (bez ekranu) — większość instalacji wewnętrznych, taniej, łatwiej zarabiać.
- **FTP / F/UTP** (ekran z folii wokół skrętek) — kable w korytach z silnoprądowymi, w pobliżu falowników, lamp LED z PWM.
- **S/FTP** (folia wokół + oplot wokół całości) — środowiska przemysłowe, EMC.

> **Ekran trzeba uziemić** — najlepiej z jednej strony, w szafie rozdzielczej. Nieuziemiony ekran działa jak antena i zbiera zakłócenia zamiast je odprowadzać.

### Limit 100 m — skąd się bierze

To limit standardu Ethernet (IEEE 802.3) wynikający z propagacji sygnału i okna kolizyjnego. Obejmuje pełną długość kanału — od portu switcha do portu kamery — łącznie z patchcordami w szafie i kostką RJ45 przy kamerze.

Praktycznie: kabel poziomy 90 m + 2×5 m patchcord = 100 m. Powyżej tej odległości stosujemy ekstendery PoE (przedłużacze 200 m), kaskadowe switche, albo światłowód.

## Kable koncentryczne (koax) — analog HD i CVBS

Koncentryki to weteran CCTV. W instalacjach analogowych HD (HD-CVI, HD-TVI, AHD) wciąż mają sens — w jednym kablu przeniesiesz sygnał 4K@30 fps na 300–500 m bez aktywnej elektroniki.

| Typ | Impedancja | Średnica żyły Cu | Tłumienie / 100 m | Max długość HD-CVI 4K |
|---|---|---|---|---|
| **RG-59 75 Ω** | 75 Ω | 0,8 mm CCS lub Cu | ~17 dB @ 100 MHz | ~300 m |
| **RG-6 75 Ω** | 75 Ω | 1,02 mm Cu | ~11 dB @ 100 MHz | ~500 m |
| **RG-11 75 Ω** | 75 Ω | 1,63 mm Cu | ~6 dB @ 100 MHz | ~800 m |

**CCS (Copper Clad Steel) to nie miedź.** Żyła stalowa pokryta miedzią jest tańsza, ale ma 3–4× większą rezystancję DC. Nie nadaje się do długiego dystansu ani do zasilania kamery wzdłuż kabla (Power Over Coax).

### RG-59 + zasilanie (kabel 2w1, „siamese")

Bardzo popularny w starszych instalacjach analogowych — koncentryk + 2-żyłowy przewód zasilający 12 V DC w jednej osłonie. Pozwala doprowadzić sygnał i zasilanie jednym ciągiem.

```
[ koax 75Ω BNC ] + [ 2×0,75 mm² 12 V DC ] -> YR-2 + YDY w osłonie LSZH
```

Spadek napięcia na żyłach 0,75 mm² jest istotny. Przy kamerze 12 V/500 mA i kablu 100 m masz ~1,8 V straty — kamera dostanie ~10 V i może resetować się w trybie IR.

## Światłowód — dystans i izolacja galwaniczna

Powyżej 100 m UTP i 500 m koncentryka jedynym sensownym wyborem jest światłowód. Dodatkowy bonus: galwaniczna izolacja kamery od reszty systemu — pioruny i przepięcia nie wchodzą do rejestratora.

| Typ | Średnica rdzenia/płaszcza | Max dystans 1 Gb/s | Źródło światła | Zastosowanie |
|---|---|---|---|---|
| **SM 9/125 (G.652)** | 9/125 µm | **10 km** (1310 nm) / 40 km (1550 nm) | laser DFB | łącza między budynkami, parkingi, kampusy |
| **MM OM3** | 50/125 µm | 300 m (1 Gb/s) / 100 m (10 Gb/s) | VCSEL 850 nm | backbone biurowca, między piętrami |
| **MM OM4** | 50/125 µm | 400 m / 150 m | VCSEL 850 nm | jak OM3, większy zapas |

### Media konwerter i SFP

Kamera IP nie ma natywnego portu SFP — potrzebny jest konwerter UTP↔światłowód po obu stronach łącza:

- **Po stronie kamery** — media konwerter z PoE injectorem (TP-Link MC220L + injector, lub Planet GST-806A60S z PoE++).
- **Po stronie switcha** — port SFP w switchu (Mikrotik CRS, Cisco SG350) z modułem 1G SFP LC.

Para żył jednomodowych w jednym kablu duplex LC (lub jedna żyła + WDM BiDi). WDM oszczędza pół ceny kabla — sygnał 1310 nm w jedną stronę, 1490 nm w drugą.

## Kable zewnętrzne — klasy ochrony

Kabel kładziony na zewnątrz (rynna, elewacja, ziemia) musi mieć osłonę odporną na konkretne czynniki. Pomyłka kończy się sztywnym, popękanym płaszczem po 2 latach.

| Oznaczenie / dopisek | Co dodaje | Środowisko |
|---|---|---|
| **UV** (PE czarny, stabilizowany) | odporność na promieniowanie słoneczne | elewacja, rynna, w słońcu |
| **żelowany (gel-filled)** | żel hydrofobowy między żyłami | kanalizacja, studnia, wilgoć stała |
| **pancerz stalowy (STA, SWA)** | oplot lub taśma stalowa | w ziemi bez rury, narażenie na gryzonie |
| **LSZH / LSOH** | bezhalogenowy, mało dymu | drogi ewakuacyjne, klatki, garaże |
| **FRNC / B2ca / Eca** | klasy reakcji na ogień (PN-EN 13501-6) | obowiązek w obiektach użyteczności publicznej |

### Co zastosować gdzie

| Lokalizacja | Rekomendowany kabel |
|---|---|
| poddasze, peszel po elewacji w cieniu | UTP Cat5e/6 zwykły szary |
| elewacja na słońcu, rynna | UTP **żelowany + UV**, czarny |
| w ziemi, w rurze | UTP outdoor **żelowany** 8×0,5 |
| w ziemi bezpośrednio | UTP **z pancerzem stalowym** + żel |
| klatka schodowa, biurowiec, garaż | UTP **LSZH Cca/B2ca** |
| łącze pomiędzy budynkami | światłowód SM z pancerzem stalowym, żel |

## Złącza — RJ45, BNC, LC

- **RJ45** (UTP) — wtyki w wykonaniu pass-through są szybsze w zarabianiu, ale wymagają zaciskarki obcinającej żyły. Sekwencja TIA/EIA-568B (najczęstsza).
- **BNC** (koax) — wtyki skręcane (jakość!) lub zaciskane szczypcami hex. Wtyki F-male (Ø9,5 mm) i F-female są spotykane głównie w SAT, w CCTV używamy BNC.
- **LC** (światłowód) — duplex w obudowie zatrzaskowej. Konektor wymaga spawania światłowodu (spawarka 5–15 tys. zł) albo szybkozłączek mechanicznych (5–8 zł, słabsza jakość).

**RJ45 do PoE++** (60–90 W) — używaj wtyków oznaczonych „PoE++ ready" lub Cat6A FTP z metalowym ekranem. Tanie wtyki Cat5e topią się przy 60+ W.

## Czego unikać

- **CCA (Copper Clad Aluminium)** — UTP z żyłą aluminiową pokrytą miedzią. Działa do 30–50 m, potem masz drop pakietów. Zwykle sprzedawany na Allegro „Cat6 100 m za 89 zł" — czytaj specyfikację.
- **Patchcordy zamiast okablowania poziomego** — żyła linkowa szybciej się zużywa w stałym położeniu i ma większe tłumienie (6×). Patchcord max 5 m.
- **Krzyżowanie z silnoprądowym** — przebieg równoległy zachowuj odstęp 30 cm (do 5 kW) lub 50 cm (powyżej). Krzyżowania pod kątem 90°.

## Co dalej

➡ [PoE pasywne vs aktywne](04-02-poe-pasywne-aktywne.md)
