# ROP i sygnalizatory

## ROP — ręczny ostrzegacz pożarowy

Czerwona puszka z napisem „POŻAR" / „Pull / Strike" — pozwala każdej osobie wzbudzić alarm pożarowy ręcznie. Norma odniesienia: **PN-EN 54-11**.

Konstrukcja typowa:

- obudowa z czerwonego tworzywa ABS lub stali malowanej,
- **szybka osłonowa** (rezystorowa, ABS lub szkło) — chroni przed przypadkowym wyzwoleniem,
- przycisk (typ A — szyba do stłuczenia, typ B — drzwiczki otwierane) z resetem kluczem,
- kontrolka LED (zwykle bursztynowa) — przy dozorze migocze, przy alarmie świeci stale,
- złącza śrubowe do magistrali (konwencjonalne 2 żyły, adresowalne 2 żyły pętli + ewent. izolator).

### Typy ROP wg PN-EN 54-11

| Typ | Działanie | Reset |
|---|---|---|
| **Typ A** (direct) | natychmiastowe wzbudzenie po stłuczeniu szyby | wymiana szybki (+ klucz) |
| **Typ B** (indirect) | wymaga dwóch akcji: podniesienie klapki + naciśnięcie przycisku | klucz serwisowy |

Typ A jest standardem polskim — szyba pęka po uderzeniu pięścią / młotkiem (specjalna szyba „break-glass" pęka łatwo, ale nie skaleczy).

### Wymagania montażowe

- **wysokość montażu: 1,2–1,6 m** (środek przycisku ~1,4 m nad podłogą),
- w widocznych miejscach: **przy każdym wyjściu ewakuacyjnym**, w klatkach schodowych, korytarzach,
- maksymalna odległość do najbliższego ROP-a — **30 m** z każdego miejsca obiektu (PN-EN 54-14),
- ROP zewnętrzny (np. na placu, parkingu) — w obudowie IP65 z daszkiem,
- nad ROP-em piktogram „ROP" o min. wymiarach 100 × 100 mm (PN-N-01256),
- oświetlenie nocne — w korytarzach z oświetleniem awaryjnym widoczność z dystansu.

### Modele konwencjonalne / adresowalne

| Model | Typ | Komunikacja |
|---|---|---|
| Polon-Alfa ROP-100 | typ A, konwencjonalny | 2-żyłowa linia |
| Polon-Alfa ROP-4001M | typ A, adresowalny | pętla POLON |
| Bosch FMC-300RW-GSGRD | typ A IP54 | LSN/konwencjonalny |
| Hochiki HCP-E | typ A, adresowalny | Hochiki LXP/Latitude |
| Schrack MCP010 | typ A, adresowalny | Integral |
| KAC MCP1A-R470SG | typ A, konwencjonalny EOL 470Ω | uniwersalny |

Po stłuczeniu szyby ROP zostaje w stanie alarmu do momentu wymiany szybki — serwisant montuje nową (komplet ~5–10 zł), wykonuje reset z centrali.

## Sygnalizatory akustyczne (syreny)

Norma odniesienia: **PN-EN 54-3**. Funkcja: generacja sygnału dźwiękowego o poziomie wystarczającym do obudzenia śpiących i alarmowania w hałaśliwym otoczeniu.

### Parametry akustyczne

| Parametr | Typowa wartość |
|---|---|
| Poziom SPL @ 1 m | 90–110 dB (typowo 100 dB) |
| Częstotliwość tonu | 500–1000 Hz (max czułość ucha) |
| Typ sygnału | ciągły, slow-whoop, DIN, ISO 8201 |
| Pobór prądu | 20–80 mA @ 24 V DC |
| Klasa obudowy | IP21 (wewnętrzny), IP65/66 (zewnętrzny) |
| Temperatura pracy | -10 do +55 °C (zewn. -25 do +70 °C) |

### Tłumienie w pomieszczeniu

Poziom dźwięku spada z odległością. Reguła kciuka:

- **spadek o 6 dB** z każdym podwojeniem odległości (przestrzeń otwarta),
- w zamkniętym pomieszczeniu mniej (echo) — typowo 3–4 dB,
- drzwi i ściany — dodatkowe tłumienie 20–30 dB (przegroda jednorzędowa).

Wymóg **PN-EN 54-14**: poziom alarmu w każdym punkcie chronionego obiektu min. **65 dB(A)** ogółem lub **75 dB(A)** w sypialniach (tam musimy obudzić ludzi).

Przykład: sygnalizator 100 dB @ 1 m → na 8 m: 100 - 6·log₂(8) = 100 - 18 = 82 dB. Po dwóch drzwiach: 82 - 25 - 25 = 32 dB → potrzebny dodatkowy sygnalizator w sąsiednim pomieszczeniu.

### Typy sygnałów

- **Ton ciągły 1 kHz** — najprostszy, polskie tradycyjne,
- **Slow-whoop** — narastający i opadający ton 0,5–1,5 kHz w cyklu 5 s, szczególnie dobrze budzi,
- **DIN 33404** — niemiecki standard, sygnał trójtonowy,
- **ISO 8201 / temporal-3** — wzór 0,5 s ton / 0,5 s przerwa × 3 / 1,5 s przerwa (standard amerykański, też w UE),
- **Voice alarm** — komunikaty głosowe (DSO/PA) zamiast tonów (galerie, lotniska).

### Modele

| Model | SPL | Wykonanie | Cena |
|---|---|---|---|
| Polon-Alfa SAW-6001 | 100 dB | wewnętrzny / IP21 | 150 zł |
| Polon-Alfa SAZ-Ex | 105 dB | strefa zagrożenia wybuchem (Ex) | 900 zł |
| Klaxon Sonos | 100 dB | IP65, do strefy zewn. | 250 zł |
| Cooper Fulleon Roshni | 97 dB | wewn., 31 tonów, niski pobór | 180 zł |
| Hochiki Banshee | 106 dB | IP65, wzmocniona | 340 zł |

## Sygnalizatory optyczne (VAD — Visual Alarm Device)

Norma odniesienia: **PN-EN 54-23:2010**. Funkcja: alarm wzrokowy dla osób z uszkodzeniem słuchu, w hałaśliwym otoczeniu, albo przy zatkanych uszach (np. słuchawkach).

### Technologie

- **Xenon flash** — błysk dużej intensywności, czas ~1 ms, 1 Hz częstotliwość, czerwony lub bezbarwny,
- **LED stroboskopowy** — dłuższa żywotność (50 000 h vs 5 000 h xenon), niższy pobór (50 mA vs 200 mA),
- **LED ciągły migający** — w niektórych typach.

### Klasy pokrycia VAD wg PN-EN 54-23

| Klasa | Pokrycie | Przykład |
|---|---|---|
| **C-3-15** | sufit, sufit 3 m, średnica 15 m | biura, korytarze |
| **W-2.4-12** | ścienny, wysokość 2,4 m, kostka 12 × 12 m | klasy szkolne |
| **O-...** | otwartej przestrzeni, pole programowane | hale, magazyny |

Wymóg: **0,4 cd/m²** intensywności światła w każdym punkcie chronionym (PN-EN 54-23).

## Sygnalizatory kombinowane akustyczno-optyczne (S/V)

Połączenie syreny i flasher'a w jednej obudowie — wygodne, jeden punkt montażu zamiast dwóch. Spełniają jednocześnie PN-EN 54-3 i PN-EN 54-23.

**Przykłady:**

- Klaxon Sonos Pulse — 100 dB + LED 0,4 cd/m², IP66,
- Hochiki Banshee Excel + Beacon — 106 dB + xenon,
- Apollo XP95 Open-Area Sounder Beacon — adresowalny w pętli,
- Bosch FNS-420 — adresowalny LSN, kombinowany,
- Polon-Alfa SAOW — akustyczno-optyczny, 100 dB + LED.

## Sygnalizatory zewnętrzne

Na elewacji budynku, montowane wysoko (3–5 m), w obudowie IP54/IP65/IP66. Cechy:

- SPL min. **100 dB** @ 1 m,
- akumulator wsparcia (sabotaż przy odcięciu kabla — własne zasilanie 30 min),
- blokada styków antysabotażowych (otwarcie obudowy = alarm),
- lampa stroboskopowa pomarańczowa lub czerwona widoczna z 100 m,
- częste w połączeniu z systemem alarmowym (włamaniowym), nie tylko SAP.

## Linie sygnalizacyjne — okablowanie

Sygnalizatory pożarowe muszą działać **w czasie pożaru** — kable muszą zachować ciągłość:

- **HDGs PH30/E30** — kabel ognioodporny, zachowuje funkcjonalność 30 min w temperaturze 842 °C,
- **HDGs PH90/E90** — 90 min, dla obiektów wysokich i z długimi drogami ewakuacji,
- mocowanie również ognioodporne (klipsy stalowe, opaski stalowe — nie plastikowe trytytki!).

> **Najczęstszy błąd:** użycie zwykłego kabla YDY/YnTKSY do sygnalizatorów — w pożarze topi się w 5 minut i syrena milknie. Wymóg PN-EN 54-14 i polskich przepisów: **kabel ognioodporny PH30 lub PH90** w zależności od kategorii obiektu.

## Konserwacja sygnalizatorów

Wg PN-EN 54-14 i polskich przepisów ppoż:

1. przegląd kwartalny: wizualnie + test funkcjonalny (chwilowe uruchomienie sygnałów),
2. przegląd roczny: pomiar poziomu SPL miernikiem klasy 2 w wybranych pomieszczeniach,
3. test ROP-ów: **wszystkich ROP-ów raz w roku** (klucz testowy bez stłuczenia szyby — większość ma tryb test),
4. wpis do dziennika konserwacji.

## Co dalej

➡ [Spis sekcji 11](index.md)
