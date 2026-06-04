# Czujki dualne PIR + mikrofalowe

> Łączą dwa niezależne kanały detekcji — pasywną podczerwień (PIR) i aktywny radar Dopplera (MW). Alarm tylko gdy *oba* zareagują równocześnie.

## Po co dwa kanały? — problem fałszywych alarmów

Sama czujka PIR jest podatna na **fałszywe alarmy** w wymagających środowiskach:

- słońce przesuwające się po ścianie (zmiana rozkładu temperatury)
- nagrzewające się powierzchnie (lampy, ekrany, kominek)
- strumienie ciepłego powietrza nad grzejnikiem, w kominie wentylacyjnym
- nagłe zmiany temperatury (włączenie klimatyzacji, otwarcie pieca)
- małe gryzonie, owady na soczewce

Mikrofalowy radar Dopplera *też* ma swoje fałszywki:

- ruch za cienką ścianą (płyta GK), za szybą
- wibracje (przejeżdżający tramwaj, ciężarówka pod oknem)
- poruszające się rośliny, wentylatory
- woda płynąca w rurach

Ale **jednoczesne** wystąpienie obu zakłóceń jest skrajnie nieprawdopodobne — dlatego logika **AND** (oba kanały muszą zareagować w oknie 1–5 s) drastycznie redukuje liczbę fałszywych alarmów.

## Jak działa kanał mikrofalowy

Wbudowany nadajnik emituje falę o częstotliwości **10,525 GHz** (pasmo X) lub **24,125 GHz** (pasmo K — nowsze, krótsze fale, lepsza rozdzielczość). Fala odbita od poruszającego się obiektu zmienia częstotliwość (efekt Dopplera) — odbiornik wykrywa różnicę i interpretuje ją jako ruch.

| Pasmo | Częstotliwość | Zasięg typowy | Uwagi |
|---|---|---|---|
| X-band | 10,525 GHz | 10–20 m | najstarsze, tańsze, większy „zasięg przez ściany" |
| K-band | 24,125 GHz | 10–15 m | nowsze, węższa wiązka, mniejsza penetracja ścian |

Krótsza fala (K-band) **słabiej przenika ściany** — to plus, bo czujka zewnętrznej (np. balkon sąsiada) nie wzbudzi się od ruchu wewnątrz. W modelu X-band ten ruch może być wykryty.

## Logika łączenia AND / OR

Czujka dual może działać w dwóch trybach (DIP-switch lub jumper):

- **AND (najczęściej)** — alarm tylko gdy *oba kanały* reagują w oknie 1–5 s. Niska liczba fałszywych, ale możliwe „przegapienie" gdy intruz np. przeskoczy strefę mikrofalową (porusza się płaszczyzną nieodbijającą fali, np. bardzo wolno).
- **OR** — alarm gdy *którykolwiek* kanał reaguje. Maksymalna czułość, ale fałszywki obu kanałów się sumują. Stosowane rzadko.

Niektóre czujki mają tryb **adaptive AND** — okno czasowe między reakcjami kanałów dostosowuje się dynamicznie do tempa wzbudzania.

## Tri-Tech, Quad — więcej niż dwa kanały

Niektórzy producenci łączą więcej technologii:

- **Tri-Tech** (Bosch) — 2× PIR + 1× MW, każdy PIR osobno przetwarzany, MW jako weryfikator
- **Quad PIR** (Optex VX-402) — 4 sensory PIR w jednej obudowie + MW, większa precyzja, mniejsza martwa strefa
- **SMDA** (Selectable Multiple Detector Architecture) — Honeywell, programowalna logika

## Kiedy stosować dual PIR+MW

| Sytuacja | Rekomendacja |
|---|---|
| Salon z dużymi oknami od południa, kominkiem | **Dual** — słońce + ogień to klasyczne wyzwalacze PIR |
| Pomieszczenie ze zwierzętami (pies + kot) | **Dual z pet-immunity** — same pet-PIR nie wystarczą dla kota wchodzącego na meble |
| Garaż, warsztat z grzejnikiem promiennikowym | **Dual** — termiczne zakłócenia, drgania od bramy |
| Magazyn, hala — temperatury < 0 °C | Dual zewnętrzny IP65 z grzałką sensora |
| Standardowa sypialnia, gabinet | Wystarczy zwykły PIR — dual to przerost formy nad treścią |
| Korytarz, hol, klatka schodowa | PIR korytarzowy — geometria jest bardziej krytyczna niż technologia |

## Popularne modele

### Satel AOD-200 / AOD-210

Zewnętrzna czujka dualna IP54 z osłoną przeciwsłoneczną:

- 2× PIR cyfrowy + MW 10,525 GHz
- zasięg 15 m, kąt 85°
- grzałka sensora −35 do +55 °C
- anti-mask IR + obudowa antywandalowa
- pet-immune do 20 kg
- cena: ok. 700–900 PLN

### Optex VXI-DAM / VXI-RDAM

Klasyk czujki zewnętrznej dual, używany przez agencje ochrony:

- 2× PIR (osobne pirosensory) + MW 24 GHz
- zasięg 12 m / kąt 90° (model 90°) lub 24 m / 5° (kurtynowy)
- SMDA (Sequential Multi-Dimensional Analysis) — algorytm logiki
- obudowa IP55, anti-rotation tamper, dodatkowy poziomy mocowania
- cena: 1100–1500 PLN

### Bosch ISC-CDL1-W15G — Commercial TriTech

- 2× PIR + 1× MW 10 GHz
- zasięg 15 m, kąt 90°, anti-mask IR, FSP
- certyfikat Grade 3 (PN-EN 50131-2-4)
- cena: 600–800 PLN

### DSC BV-501

- Bravo Dual — PIR + MW, anti-mask
- zasięg 18 m, kąt 110°
- 4 poziomy czułości MW
- cena: 400–500 PLN

## Pułapki konfiguracyjne

Niektóre instalatorzy „dla pewności" wyłączają kanał MW (jumper) — w rezultacie z czujki dual robi się zwykły PIR, ale w wyższej cenie. Zawsze weryfikuj **walk-test w trybie MW-only**: jeśli kanał mikrofalowy nie reaguje, czujka nie pełni swojej funkcji.

Strefa **MW przenika przez ściany** (zwłaszcza X-band). Czujka pokoju może wzbudzać się od ruchu w łazience za płytą GK. Sprawdź to przed finalnym montażem.

## Anti-mask w dualnych

Czujki Grade 3 mają osobne mechanizmy anti-mask dla każdego kanału:

- **PIR mask** — IR aktywne na soczewce (jak w zwykłej)
- **MW mask** — pomiar mocy własnego sygnału odbitego z bardzo bliska. Folia metalizowana na czujce ekranuje MW — sygnał spada, alarm masking.

## Konfiguracja w centrali

Czujka dual zwykle ma jedno wyjście alarmowe (logika AND realizowana w czujce) i drugie wyjście *tylko PIR* dla diagnostyki:

```
Linia 1 (alarm)  ─── strefa wewnętrzna, opóźnienie 0 s
Linia 2 (PIR only) ─── strefa techniczna, „pre-alarm" (logowanie do pamięci)
Linia TMP        ─── strefa 24h sabotażowa
Linia AM (anti-mask) ─── strefa 24h techniczna (osobny komunikat)
```

W centrali Satel Integra czterolinionowa czujka dual zajmuje 4 wejścia — należy to uwzględnić przy doborze ekspandera wejść.

## Co dalej

➡ [Kontaktrony magnetyczne](07-03-kontaktrony-magnetyczne.md)
