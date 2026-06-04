# Czujki PIR (pasywne podczerwieni)

> Najpopularniejsze czujki ruchu w systemach alarmowych. Wykrywają zmianę promieniowania podczerwonego (ciała ludzkiego) w polu widzenia.

## Jak działa PIR — zasada pasywnej detekcji

**PIR** (Passive InfraRed) zawiera pirosensor — element piezoelektryczny reagujący na **zmianę** długości fali ok. 8–14 µm (zakres promieniowania ciała o temperaturze 37 °C). Sensor jest podzielony na dwa lub cztery segmenty, a sygnał alarmowy generuje **różnica** między nimi — dlatego statyczny obiekt (nawet bardzo ciepły) nie wyzwala alarmu, ale poruszający się człowiek tak.

Czujka jest „pasywna" bo sama niczego nie emituje (w odróżnieniu od MW lub bariery IR aktywnej). Pobór prądu typowo 10–25 mA z linii 12 V DC.

## Soczewka Fresnela — kreowanie wiązek

Sensor sam w sobie ma jeden szeroki obszar widzenia. To soczewka Fresnela rozdziela go na **wiązki** (zones, segments) — typowo 10–80 stref wykrywania ułożonych w wachlarz.

| Typ soczewki | Charakterystyka | Zastosowanie |
|---|---|---|
| **Szerokokątna** | 90°/110° poziomo, 3 piętra wiązek | standardowe pomieszczenie 4–6 m |
| **Korytarzowa** | wąska 5°–15°, długa 20–30 m | korytarze, magazyny, długie pasaże |
| **Kurtyna** | wąska pionowa wiązka wzdłuż ściany/okna | ochrona okien, witryn, ścian |
| **Pet-immune** | brak dolnych wiązek (poniżej 1 m) | domy ze zwierzęciem do 25 kg |
| **Lustrzana 360°** | sufitowa, pełen obrót | otwarte przestrzenie, open-space |

Soczewka jest **wymienna** w lepszych modelach (np. Satel SLIM-DUAL/PRO, Optex VX) — jedna podstawa, kilka rodzajów soczewek do różnych zastosowań.

## Kluczowe parametry techniczne

| Parametr | Typowe wartości | Co znaczy |
|---|---|---|
| **Zasięg** | 10 / 12 / 15 / 18 m | maks. odległość detekcji „dorosłego" przechodzącego prostopadle do osi |
| **Kąt detekcji** | 90° / 110° (standard), 360° (sufit) | poziomy zasięg wiązki |
| **Liczba wiązek** | 11 / 35 / 78 | im więcej, tym czulsza i odporniejsza na fałszywe alarmy |
| **Pet-immunity** | do 15 / 20 / 25 / 35 kg | masa zwierzęcia ignorowana |
| **Wysokość montażu** | 1,8–2,4 m (standard), 2,4–3,6 m (long-range) | nieprawidłowa wysokość = błędna charakterystyka |
| **Temperatura pracy** | −10 do +55 °C (wewn.), −35 do +55 °C (zewn.) | w zimnym garażu wybierz model rozszerzony |
| **Cyfrowy filtr** | DSP, AGC | analiza sygnału — odrzucenie pojedynczych zakłóceń |
| **Anti-mask** | IR aktywne, sygnalizacja zasłonięcia | wymóg w Grade 3+ |

## Anti-mask — wykrywanie zasłonięcia

Włamywacz, który zna lokalizację czujki, może **zakleić jej okienko** (folia, sprej, naklejka) zanim uzbroi alarm. Funkcja anti-mask emituje dyskretną wiązkę IR i mierzy odbicie z bardzo bliskiej odległości — jeśli na soczewce pojawia się przeszkoda, generowany jest osobny sygnał (zwykle na strefie technicznej, nie alarmowej).

Wymóg normy **PN-EN 50131-2-2** dla Grade 3 i wyższych. W Grade 2 — opcjonalnie. W domach jednorodzinnych zwykle pomijane (Grade 2).

Anti-mask działa tylko przy czujce **uzbrojonej**. Maskowanie przy rozbrojeniu (np. w dzień, gdy domownicy są w domu) nie zostanie wykryte. Stąd zasada: **okresowa wzrokowa kontrola** czujek przez właściciela.

## Pet-immunity — odporność na zwierzęta

Soczewka pet-immune ma **wycięte dolne wiązki** (do ok. 1 m wysokości). Pies do 25 kg poruszający się po podłodze nie wzbudza detekcji, ale człowiek (głowa/tors na 1,5+ m) — tak.

| Limit masy | Typowe zastosowanie | Uwagi |
|---|---|---|
| **15 kg** | kot, mały pies | cocker spaniel, jamnik |
| **25 kg** | średni pies | border collie, labrador (młody) |
| **35 kg** | duży pies | labrador dorosły, owczarek |

Pet-immunity **nie działa** jeśli zwierzę wchodzi na mebel (kanapa, schody, stół) — jego sylwetka pojawia się w „strefie człowieka". Koty notorycznie obchodzą tę ochronę. Rozwiązanie: czujka *dualna* PIR+MW (sekcja 07-02).

## Popularne modele — Satel, DSC, Bosch

### Satel — polska szkoła

| Model | Zasięg / kąt | Funkcje | Klasa |
|---|---|---|---|
| **SLIM-PIR** | 11 m / 90° | cyfrowy, podstawowy | Grade 2 |
| **GRAPHITE** | 15 m / 90° | pet-immune 25 kg, cyfrowy | Grade 2 |
| **OPAL Pro** | 15 m / 90° | anti-mask IR, autotest | Grade 3 |
| **AOD-200** | 15 m / 85° | dual PIR+MW, zewnętrzna IP54 | Grade 2 |
| **SLIM-DUAL** | 11 m / 90° | 2 sensory PIR (anty-przesłonięcie sensora) | Grade 2 |

### DSC (Tyco/Johnson Controls)

| Model | Zasięg / kąt | Funkcje |
|---|---|---|
| **LC-100PI** | 15 m / 90° | pet-immune 25 kg, cyfrowy DSP |
| **LC-104PIMSK** | 15 m / 90° | + anti-mask IR |
| **BV-501** | 18 m / 110° | Bravo dual PIR+MW, Grade 3 |
| **PG8924** | 12 m / 90° | bezprzewodowy 433/868 MHz (PowerG) |

### Bosch — Blue Line, Professional

| Model | Zasięg / kąt | Funkcje |
|---|---|---|
| **ISC-BPR2-W12** | 12 m / 90° | Blue Line Gen2, pet 20 kg |
| **ISC-PPR1-W16** | 16 m / 90° | Professional, FSP (First Step Processing) |
| **ISC-CDL1-W15G** | 15 m / 90° | Commercial Dual TriTech, anti-mask |

Bosch **FSP** wyzwala alarm już na pierwszym kroku intruza — ważne w szybkim przejściu obok czujki. Klasyczny PIR potrzebuje min. 2 segmentów aktywnych = ok. 3 kroków.

## Zasady montażu — gdzie i jak

- **Wysokość 2,1–2,4 m** dla soczewki standardowej. Niżej — zwierzęta strzelą; wyżej — wiązki padają zbyt daleko, „pod nogi" jest martwa strefa.
- **W rogu pokoju** — maksymalizacja pokrycia (kąt 90° przeciwprostokątny do bryły pomieszczenia).
- **Prostopadle do typowego kierunku ruchu** — intruz przecina wiązki, nie idzie wzdłuż nich. Czujka źle reaguje na ruch „prosto na siebie".
- **Z dala od źródeł ciepła**: grzejników, kominka, AGD, parownic, promienników. Słońce wpadające przez okno na ścianę naprzeciw — fałszywy alarm.
- **Z dala od przeciągów** — ciepłe powietrze nad kaloryferem porusza się i może być wzięte za ruch.
- **Z dala od ruchomych elementów**: firanki na wietrze, kołyszące się rośliny, wentylatory sufitowe.

## Kalibracja czułości

Czujka zwykle ma 2–4 jumpery/DIP-switche lub potencjometr „pulse count":

- **1 puls** — najwyższa czułość, szybka reakcja (ale więcej fałszywych)
- **2 pulsy** — standard (dwa kolejne wzbudzenia w oknie czasu)
- **4 pulsy** — najwyższa odporność na fałszywe (ale wolniejsza reakcja)

Diodowy **walk-test** (chodzenie po pomieszczeniu z włączoną sygnalizacją LED) pozwala sprawdzić pokrycie po montażu. Po teście — wyłączyć LED, bo świeci jak latarnia dla intruza.

## Strefy i wyjścia czujki

Klasyczna czujka PIR przewodowa ma 4 lub 6 zacisków:

```
+12V  ─── zasilanie z centrali (czerwony)
GND   ─── masa (czarny)
NC    ─── strefa alarmowa (zielony) — para z COM
COM   ─── wspólny (żółty)
TMP   ─── sabotaż (niebieski) — para z COM-TMP
COM-TMP ─── wspólny sabotażu (biały)
```

Strefa **NC** rozwiera się przy alarmie. Strefa **TMP** rozwiera się przy otwarciu obudowy (sabotaż). Na linii alarmowej często stosuje się *rezystory końcowe (EOL)* 2k2 lub 5k6 — pozwalają centrali odróżnić zwarcie linii (sabotaż) od alarmu i normalnego stanu.

## Co dalej

➡ [Czujki dualne PIR + mikrofalowe](07-02-dual-pir-mw.md)
