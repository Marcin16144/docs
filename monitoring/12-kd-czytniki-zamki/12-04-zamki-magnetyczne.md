# Zamki magnetyczne (zwory)

## Zasada działania

Zamek magnetyczny (**elektromagnes**, „zwora", w żargonie *maglock*) to elektromagnes (cewka w obudowie aluminiowej) montowany na futrynie + płyta stalowa (**kotwica**, *armature*) zamontowana na drzwiach.

```
             FUTRYNA (góra)
             ┌──────────────────┐
             │   ZWORA          │ ← cewka 12/24 V DC
             │   (elektromagnes) │
             └─────╥────────────┘
                   ║ ← siła magnetyczna (przy zasilaniu)
                ┌──╨──┐
                │KOTWICA│ ← płyta stalowa
                └──────┘
                   ║
                DRZWI
```

Pod napięciem elektromagnes generuje silne pole, które trzyma kotwicę → drzwi zablokowane. Bez napięcia — pole znika, drzwi swobodnie się otwierają.

## Cechy charakterystyczne

- **brak ruchomych części** w korpusie zamka → bardzo długa żywotność (10–20 lat),
- **zawsze fail-safe** — z definicji konstrukcji: brak prądu = brak pola = drzwi otwarte,
- łatwy montaż „nad zamkiem" — nie wymaga frezowania w futrynie ani drzwiach,
- cicha praca (brak kliknięć jak w elektrozaczepie),
- łatwo dobrać siłę do wagi i sposobu wykorzystania drzwi.

## Klasy siły trzymania

Siła trzymania mierzona w funtach (lbs — pound-force) lub kilogramach. Standard branżowy podaje obie. Im większa, tym mocniejsze drzwi można zabezpieczyć i tym trudniej wyłamać.

| Klasa | Siła trzymania | Pobór prądu (typ.) | Zastosowanie |
|---|---|---|---|
| **180 lbs** | ~80 kg | 200 mA @ 12 V (2,4 W) | szafki, drzwi szklane, schowki |
| **280 lbs** | ~130 kg | 300 mA @ 12 V (3,6 W) | drzwi wewnętrzne biurowe, lekkie ścianki |
| **600 lbs** | ~270 kg | 500 mA @ 12 V (6 W) | standard — drzwi wejściowe biurowe, mieszkania |
| **1200 lbs** | ~550 kg | 500 mA @ 24 V (12 W) | drzwi zewnętrzne, klatki schodowe, bramy techniczne |
| **1800 lbs / podwójne** | ~820 kg | ~1000 mA @ 24 V | bramy dwuskrzydłowe, drzwi ciężkie pancerne |

> Dla drzwi wejściowych do biura standardem jest **600 lbs** (270 kg) — wytrzymuje silne pchnięcie ramieniem dorosłego. Przy poważniejszych wymaganiach (instytucje finansowe, serwerownie) — **1200 lbs**.

## Wymagania normowe

Normy odniesienia:

- **EN 14846** — zamki budowlane elektromechaniczne,
- **UL 1034** — Burglar-Resistant Electric Locks (standard amerykański),
- **UL 294** — Access Control System Units.

## Wymagania dla dróg ewakuacyjnych

> **WYMÓG KRYTYCZNY:** zamek magnetyczny na drodze ewakuacyjnej MUSI być fail-safe (zawsze taki jest z natury) ORAZ musi mieć alternatywne sposoby zwolnienia, na wypadek awarii systemu zasilania awaryjnego.

### Obowiązkowe wyposażenie

1. **Przycisk wyjścia awaryjnego** — czerwony „break-glass" — bezpośrednio przecina zasilanie zwory (równolegle do KD). Wymóg PN-EN 13637.
2. **Integracja z SAP** — alarm pożarowy w centrali SAP → przerywa zasilanie wszystkich zwór na drodze ewakuacji.
3. **Awaryjne odłączenie** — w razie potrzeby personel ochrony może wyłączyć wszystkie zwory z pulpitu.
4. **Sygnalizacja stanu** — w wielu systemach: zielona LED świeci, kiedy można wyjść.

## Przycisk wyjścia — typy

| Typ | Działanie | Reset |
|---|---|---|
| **Zielony „PUSH TO EXIT"** | NC styk — naciśnięcie przerywa obwód | automatyczny (sprężyna) |
| **PIR (czujka ruchu)** | na ścianie/suficie — wykrycie ruchu zwalnia zworę | automatyczny |
| **Break-glass awaryjny** | czerwony — stłuczenie szyby przerywa obwód | wymiana szybki |
| **Mikroprzełącznik na klamce** | obniżenie klamki = zwolnienie zwory + impuls | automatyczny |

Przycisk PIR jest najwygodniejszy dla użytkownika (bezdotykowy, automatyczny), ale w obiektach o podwyższonym bezpieczeństwie używa się zielonego przycisku „PUSH TO EXIT" — wymaga świadomego działania.

## Czujnik stanu drzwi (door status / position)

Większość zwór ma wbudowany **kontaktron** lub czujnik Halla w kotwicy:

- informuje kontroler o stanie: *drzwi zamknięte / otwarte*,
- pozwala na detekcję:
  - **door forced** — drzwi otwarte bez autoryzacji (włamanie),
  - **door held open** — drzwi otwarte za długo (np. przytrzymane klinem),
- logi w systemie KD: kto, kiedy, jak długo.

## Montaż — typowe konfiguracje

### Zwora pojedyncza nadrzwiowa

Najpopularniejsza. Zwora w górnym narożniku ramy drzwi (po stronie zawiasów lub na boku — zależnie od konstrukcji). Kotwica na drzwiach.

### Zwora dwustronna

Dla drzwi dwuskrzydłowych — dwie zwory w jednej obudowie (mocowana na suficie nad miejscem styku skrzydeł).

### Zwora wpuszczana (mortise mag-lock)

Wpuszczana w drzwi i futrynę — niewidoczna. Bardziej estetyczna, ale wymaga frezowania. Stosowana w salonach klasy premium.

### Zwora do drzwi szklanych

Specjalna konstrukcja z uchwytem do mocowania na szkle (bez wiercenia, na przyssawki silikonowe lub klej UV). Marka: Magnabolt, AlfaStar GLS-280.

## Marki na rynku polskim

| Marka | Model przykładowy | Siła | Cena |
|---|---|---|---|
| AlfaStar / Roger | EL-600 | 600 lbs | 180 zł |
| YLI | YM-280D | 280 lbs | 120 zł |
| YLI | YM-600D | 600 lbs | 200 zł |
| Roger | ZL-1200 | 1200 lbs | 450 zł |
| Securitron / ASSA ABLOY | M62, M82 | 600/1200 lbs | 800–1500 zł |
| Dorma | Dorma EM2200 | 1200 lbs | 1200 zł |
| RCI | 0162 / 0862 | 600/1200 lbs | 700–1400 zł |

## Wskazówki praktyczne

- **powierzchnia kotwicy musi szczelnie przylegać do zwory** — szczelina 0,5 mm zmniejsza siłę o połowę!
- powierzchnia ma być czysta — kurz, smar, brud → zmniejszony chwyt,
- zworę zasilamy **z osobnego zasilacza buforowego** (np. PSAC-7) z akumulatorem 12 V/7 Ah — pewne 24 h pracy w razie awarii sieci,
- zwora generuje impuls indukcyjny przy rozłączeniu — wymaga **diody gaszącej** równolegle do cewki (Schottky 1N5408 lub MOV),
- w drzwiach z samozamykaczem — sprawdzić, czy domyka się przed włączeniem zwory (timing kontrolera).

## Sprawdzanie skuteczności

Po montażu należy zweryfikować:

1. siłę trzymania — próba siłowa (dynamometr ręczny lub waga sprężynowa, do 50 kg na drzwiach biurowych — powinno wytrzymać),
2. działanie przycisku awaryjnego — naciśnięcie → drzwi otwierają się natychmiast,
3. działanie integracji z SAP — symulacja alarmu pożarowego → zwora odłącza się w <2 s,
4. działanie czujnika stanu drzwi — otwarcie ręczne → logi pokazują „door forced",
5. czas pracy na akumulatorze (test BackupTime).

> **Najczęstsze błędy:**
>
> - brak przycisku awaryjnego (lub schowany pod biurkiem — bez chronionego oznaczenia),
> - brak diody gaszącej → uszkodzenie tranzystorów w kontrolerze KD,
> - zbyt słaba zwora do ciężkich drzwi pancernych — można wyłamać kopnięciem,
> - brak integracji z SAP — w pożarze zwory dalej trzymają drzwi.

## Co dalej

➡ [Spis sekcji 12](index.md)
