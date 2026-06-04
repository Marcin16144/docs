# Strefy i partycje

> Pojęcia fundamentalne dla konfiguracji systemu alarmowego. Strefa to linia czujki, partycja to grupa stref uzbrajana niezależnie od reszty.

## Strefa (zone) — pojedyncza linia detekcji

**Strefa** (zone, sektor) to elementarna jednostka logiczna w centrali — odpowiada jednemu wejściu na płycie centrali (lub ekspandera), do którego podłączona jest czujka. Każda strefa ma:

- numer (1, 2, 3... do limitu centrali — Integra 24 ma 24, Integra 256 ma 256)
- typ (np. opóźniona, 24h, natychmiastowa, techniczna)
- nazwę (np. „Drzwi wejściowe", „PIR salon", „Kontaktron garaż")
- przypisanie do partycji (jeśli system ma podział)
- parametry: czułość, opóźnienie, liczba pulsów, opcja bypass

## Typy stref — czas reakcji i kontekst

### 1. Opóźniona (delayed / entry-exit)

Czujka generuje alarm **po upływie czasu opóźnienia** (typowo 10–60 s). Pozwala wejść do obiektu i rozbroić centralę zanim ona wzbudzi syrenę.

| Parametr | Typowa wartość | Uwagi |
|---|---|---|
| Entry delay (czas na wejście) | 30 s | od otwarcia drzwi do wpisania kodu |
| Exit delay (czas na wyjście) | 30–60 s | od uzbrojenia do opuszczenia obiektu |
| Final door | opcja | centrala sama uzbroi się po zamknięciu drzwi |

Zastosowanie: **drzwi wejściowe**, kontaktron głównego wejścia, PIR w korytarzu wejściowym (jeśli klawiatura jest dalej).

### 2. Natychmiastowa (instant)

Alarm **od razu** po wzbudzeniu (0 s opóźnienia). Standard dla większości czujek wnętrza i okien.

Zastosowanie: **PIR w pomieszczeniach**, kontaktrony okien, kurtyny perymetru.

### 3. 24-godzinna (24h)

Aktywna **zawsze** — niezależnie od uzbrojenia centrali. Alarm wystąpi nawet gdy domownicy są w domu z rozbrojonym alarmem.

| Sub-typ | Zastosowanie |
|---|---|
| **24h sabotażowa** | tampery obudów czujek, syren, klawiatur, centrali |
| **24h pożarowa** | czujki dymowe, CO, gazu — alarm głośny, inny ton, powiadomienie |
| **24h napadowa (panic)** | przycisk napadowy pod biurkiem, kombinacja klawiszy na klawiaturze |
| **24h techniczna** | zalanie, awaria PSU, brak komunikacji — alarm cichy, tylko SMS/push |
| **24h medyczna** | przycisk dla osób starszych — wezwanie pomocy |

### 4. Wewnętrzna (interior)

Aktywna **tylko gdy centrala uzbrojona pełnym uzbrojeniem** (Full Arm). W trybie Stay/Home — automatycznie wykluczona.

Zastosowanie: **PIR-y w pokojach**, w których przebywa się przy rozbrojonej części obiektu (sypialnie, salon przy obecności).

### 5. Cicha (silent / hold-up)

Alarm **bez syreny**, tylko transmisja do agencji ochrony i powiadomienie. Stosowany np. dla przycisku napadowego — żeby napastnik nie wiedział, że został zgłoszony.

### 6. Nocna (night / interior delay)

Strefa aktywna w trybie Night Arm, wykluczona w Stay. Typowo: PIR w korytarzach poza sypialniami — domownik mogą wstać do sypialni, ale ruch w salonie / kuchni wzbudza alarm.

### 7. Strefa zlicznika (chime)

Generuje krótki dźwięk klawiatury („dingdong") przy wzbudzeniu, ale **bez alarmu**. Funkcja sygnalizacji wejścia gościa (drzwi sklepu, recepcja).

## Typy linii — jak czujka jest podłączona elektrycznie

Strefa to także konkretna konfiguracja elektryczna z punktu widzenia centrali:

| Typ linii | Konfiguracja | Co wykrywa |
|---|---|---|
| **NC** | styk normalnie zwarty | tylko alarm (przerwa) — brak detekcji sabotażu |
| **NO** | styk normalnie otwarty | jw., rzadziej stosowany |
| **EOL** (1 rezystor) | R szeregowo z czujką (2k2 lub 5k6) | alarm (przerwa) + zwarcie (sabotaż linii) |
| **2EOL** (DEOL) | 2 rezystory (alarm + tamper) | alarm + sabotaż na tych samych 2 żyłach |
| **NC+TMP** | 4 żyły, osobne pary alarm + sabotaż | jak 2EOL, ale przez 4 żyły |

Dla nowych instalacji standard to **2EOL z rezystorami 1k1+1k1** (Satel) lub 5k6+5k6 (DSC). Daje 4 stany na 2 żyłach: normalny, alarm, sabotaż, zwarcie.

## Partycja (partition / subsystem) — niezależnie uzbrajana grupa stref

**Partycja** to wirtualny podział obiektu — każda partycja ma własne kody, własny stan (uzbrojona / rozbrojona), własne strefy. Pozwala na:

- Uzbrojenie **tylko garażu** w nocy gdy domownicy są w głównej części domu
- Uzbrojenie **tylko piwnicy / pomieszczeń biurowych**, gdy reszta jest w użyciu
- Osobne uzbrojenie **parteru i piętra** (dwie rodziny w jednym domu)
- Wynajem części obiektu — najemca uzbraja **tylko swoją partycję**, nie ma dostępu do reszty

## Przykład podziału partycji — dom jednorodzinny

```
PARTYCJA 1 — DOM (parter + piętro)
  ├─ Strefa 1: Drzwi wejściowe (opóźniona, 30s)
  ├─ Strefa 2: Drzwi tarasu (natychmiastowa)
  ├─ Strefa 3: PIR salon (wewnętrzna)
  ├─ Strefa 4: PIR kuchnia (wewnętrzna)
  ├─ Strefa 5: PIR korytarz parter (nocna)
  ├─ Strefa 6: Kontaktrony okien parter (natychmiastowa)
  ├─ Strefa 7: PIR sypialnia (wewnętrzna, wyklucz w stay)
  └─ Strefa 8: PIR pokój dzieci (wewnętrzna, wyklucz w stay)

PARTYCJA 2 — GARAŻ + KOTŁOWNIA
  ├─ Strefa 9: Kontaktron brama garażowa (opóźniona 60s)
  ├─ Strefa 10: PIR garaż dual (natychmiastowa)
  ├─ Strefa 11: Czujka zalania kotłownia (24h tech.)
  └─ Strefa 12: Czujka gazu CH4 (24h pożarowa)

PARTYCJA 3 — BIURO/GABINET (osobne wejście)
  ├─ Strefa 13: Drzwi biura (opóźniona)
  ├─ Strefa 14: PIR biuro (wewnętrzna)
  └─ Strefa 15: Kontaktron sejf (24h alarmowa)

STREFA WSPÓLNA (24h, na wszystkie partycje)
  ├─ Strefa 16: Tampers wszystkich obudów
  ├─ Strefa 17: Czujka pożarowa parter (24h ppoż)
  └─ Strefa 18: Przycisk napadowy (24h cicha)
```

## Pula stref vs partycji w typowych centralach

| Centrala | Strefy | Partycje | Klawiatury |
|---|---|---|---|
| Satel INTEGRA 24 | 24 | 4 | 4 |
| Satel INTEGRA 32 | 32 | 16 | 8 |
| Satel INTEGRA 64 | 64 | 32 | 8 |
| Satel INTEGRA 128 | 128 | 32 | 8 |
| Satel INTEGRA 256 Plus | 256 | 32 | 16 |
| DSC PowerSeries Neo HS2016 | 16 (do 128) | 4 | 8 |
| DSC PowerSeries Neo HS2128 | 128 | 8 | 16 |
| Risco LightSYS Plus | 512 | 32 | 32 |
| Jablotron JA-101K | 50 | 4 | 4 |
| Jablotron JA-103K | 120 | 15 | 10 |

## Bypass — wykluczanie strefy

**Bypass** = chwilowe wyłączenie strefy z uzbrojenia bez dezaktywacji całej centrali. Stosowane gdy:

- czujka jest uszkodzona (czeka na serwis) — żeby nie blokować uzbrojenia całej partycji
- w nocy ktoś musi swobodnie przemieszczać się po pomieszczeniu z PIR
- chwilowo szczeniak (zwierzę) nie ma „pet-immune" pokrycia

Bypass robi się z klawiatury (przed uzbrojeniem). Po rozbrojeniu — bypass automatycznie się kasuje.

Nie należy stosować bypassu jako **długoterminowego rozwiązania**. Awaria czujki = napraw lub wymień, a nie „omijaj na stałe". W historii zdarzeń bypass jest widoczny — ślad dla SMA i audytu.

## Strefy wspólne i przypisanie do wielu partycji

Niektóre strefy logicznie należą do **wszystkich partycji**:

- czujki sabotażu obudów (wszędzie i zawsze 24h)
- czujki dymowe (pożar — całe obiekt)
- czujki gazu, zalania (techniczne — całe obiekt)
- kontaktrony drzwi pomieszczeń wspólnych (np. hala) w obiektach wieloskośnych

W centrali Integra strefa może być przypisana do wielu partycji jednocześnie. W DSC PowerSeries — pojedyncza strefa do max 8 partycji.

## Strefy bezprzewodowe vs przewodowe

| Typ | Plus | Minus |
|---|---|---|
| Przewodowa | brak baterii, niezawodność, brak fałszywek radiowych | okablowanie inwazyjne, koszt montażu |
| Bezprzewodowa | łatwy montaż w gotowym budynku, estetyczna | baterie do wymiany 2–5 lat, ryzyko jammingu |

Większość central nowoczesnych jest hybrydowa — można mieszać czujki przewodowe i bezprzewodowe. Satel ABAX2, DSC PowerG, Risco WiComm.

## Co dalej

➡ [Scenariusze uzbrojenia](09-02-scenariusze-uzbrojenia.md)
