# Akumulatory żelowe (GEL) i AGM

> Technologie kwasowe szczelne (VRLA) — różnice GEL vs AGM, typowe pojemności 12 V / 2,2–17 Ah, dobór do czasu autonomii, żywotność, marki. Aktualizacja 2026.

## Technologia VRLA — wspólny mianownik

Wszystkie akumulatory używane w systemach zabezpieczeń to **VRLA** (*Valve Regulated Lead Acid*) — kwasowo-ołowiowe, szczelne, z zaworem nadciśnieniowym. Brak otwartego elektrolitu (nie wymagają dolewania), montaż w dowolnej pozycji (poza dnem do góry), brak emisji wodoru przy normalnej pracy.

Dwie podgrupy różnią się sposobem unieruchomienia elektrolitu:

| Cecha | AGM | GEL |
|---|---|---|
| Elektrolit | wsiąknięty w matę z włókna szklanego (*Absorbent Glass Mat*) | związany w żel z dodatkiem SiO₂ |
| Rezystancja wewnętrzna | niska — wysokie prądy rozruchu | wyższa — gorsze prądy szczytowe |
| Liczba cykli (50 % DoD) | ~ 500 | ~ 700 |
| Praca głębokimi cyklami | średnia — preferuje płytkie rozładowanie | dobra — toleruje głębsze cykle |
| Wrażliwość na przeładowanie | wyższa | niższa (żel termicznie stabilniejszy) |
| Praca w niskich temp. | lepsza (–20 °C OK) | słabsza (gęstnienie żelu) |
| Cena za Ah | niższa o 20–40 % | wyższa |
| Typowe zastosowanie | centrale alarmowe, UPS, zasilacze buforowe | łodzie, kampery, instalacje PV off-grid |

W systemach zabezpieczeń budynkowych **standardem są AGM**. Pracują one w trybie *float* (ciągłe doładowywanie z zasilacza buforowego), rzadko rozładowywane głęboko — wystarczająca żywotność, niższy koszt. GEL stosuje się tam, gdzie spodziewane są częste i głębokie cykle (off-grid).

## Standardowe pojemności i wymiary

| Pojemność | Wymiary L × W × H [mm] | Masa | Typowe zastosowanie |
|---|---|---|---|
| 12 V / 1,2 Ah | 97 × 43 × 52 | 0,57 kg | centralka radio, miniaturowe panele |
| 12 V / 2,2 Ah | 178 × 35 × 67 | 0,93 kg | panel ROP, sygnalizator |
| 12 V / 4 Ah | 90 × 70 × 102 | 1,55 kg | klawiatura, ekspander |
| 12 V / 7 Ah | 151 × 65 × 94 | 2,1 kg | **najpopularniejszy** — centrala alarmowa do 8–16 stref |
| 12 V / 9 Ah | 151 × 65 × 94 | 2,7 kg | centrala alarmowa z większą liczbą czujek |
| 12 V / 12 Ah | 151 × 98 × 95 | 3,8 kg | centrala SAP, monitoring CCTV (NVR) |
| 12 V / 17 Ah | 181 × 76 × 167 | 5,4 kg | SAP, duże zasilacze buforowe Pulsar 5–7 A |
| 12 V / 26 Ah | 166 × 175 × 125 | 9,0 kg | SAP klasy II, długie czasy podtrzymania |
| 12 V / 40 Ah | 197 × 165 × 170 | 14 kg | UPS, instalacje przemysłowe |

Standardowa **centrala alarmowa** typu Satel Integra 32 z 8 czujkami PIR mieści się komfortowo z akumulatorem 12 V / 7 Ah w obudowie OPU-3 P. **Centrala SAP** wymaga przynajmniej 17 Ah ze względu na obowiązkowe 24 h zasilania rezerwowego + 30 min alarmowania (PN-EN 54-4).

## Wzór na dobór pojemności

Podstawowy bilans energetyczny dla okresu autonomii:

```
Q [Ah] = (P [W] · t [h]) / (U [V] · η)

gdzie:
  P  = sumaryczna moc systemu w czuwaniu (W)
  t  = wymagany czas podtrzymania (h)
  U  = napięcie nominalne (12 V dla większości systemów)
  η  = sprawność uwzględniająca rozładowanie do 80 % DoD i sprawność konwersji (~ 0,8)
```

### Przykład 1 — alarm domowy Satel Integra 32

Pobór prądu w spoczynku (płyta + klawiatura LCD + 6 PIR + GSM-X):

```
I_centrala  = 150 mA
I_klawiatura = 40 mA
I_PIR × 6    = 6 × 18 mA = 108 mA
I_GSM-X      = 80 mA
─────────────────────────────
I_suma       = 378 mA  →  P = 0,378 × 12 = 4,5 W
```

Dla wymagania PN-EN 50131-6 grade 2 (12 h podtrzymania):

```
Q = (4,5 · 12) / (12 · 0,8) = 5,6 Ah  →  dobierz 7 Ah (zapas 25 %)
```

### Przykład 2 — CCTV (NVR + 4 kamery PoE)

Dla rejestratora i 4 kamer IP zasilanych z PoE switch z UPS-em 12 V:

```
I_NVR        = 2,5 A  (30 W)
I_kamera × 4 = 4 × 0,5 A = 2 A  (24 W)
─────────────────────────────
I_suma       = 4,5 A  →  P = 54 W

Czas autonomii t = 1 h (standardowa rezerwa do zakończenia incydentu)
Q = (54 · 1) / (12 · 0,8) = 5,6 Ah  →  7 Ah
```

Dla CCTV liczy się autonomię raczej w godzinach niż dobach — pobór prądu jest 5–10 × większy niż dla alarmu, więc realne podtrzymanie 24 h wymagałoby akumulatora 100–200 Ah (i potężnego UPS-a). Praktyka: 30–60 minut UPS na samym rejestratorze, w tym czasie operator dojeżdża lub kończy zdarzenie.

### Przykład 3 — SAP konwencjonalny 16 czujek

Centrala SAP, 16 czujek dymu, 2 sygnalizatory, ROP-y:

```
I_dozór    = 120 mA   (centrala + czujki w stanie spoczynku)
I_alarm    = 1500 mA  (centrala + sygnalizatory aktywne, 30 min)

Wymaganie PN-EN 54-4:
  Q ≥ I_dozór × 24 h + I_alarm × 0,5 h
  Q = 0,12 · 24 + 1,5 · 0,5 = 2,88 + 0,75 = 3,63 Ah

Z zapasem (współczynnik 1,25): 4,5 Ah  →  dobierz 7 Ah lub 12 Ah
```

## Żywotność i kalendarz wymiany

Dla pracy buforowej (*float*, ciągłe doładowywanie) producenci podają tzw. **design life** — kalendarzowy czas eksploatacji do utraty 80 % pojemności:

| Klasa akumulatora | Design life | Przykład |
|---|---|---|
| Standard (5 lat) | 3–5 lat | MWPower MWS, OEM |
| Long life (10 lat) | 8–10 lat | Yuasa NPL, Fiamm FGL, EnerSys DataSafe |
| Front terminal (12 lat) | 10–12 lat | Yuasa SWL, EnerSys PowerSafe |

**W praktyce** akumulator klasy „5 lat" wymienia się **co 3–4 lata** przy domowych alarmach (gorsze warunki termiczne — szafki w garażu/piwnicy, wahania temperatur), a klasy „10 lat" w SAP — **co 5–7 lat**. Po tym czasie pojemność spada poniżej deklarowanej (zwykle < 70 %), co przekłada się na nieosiągnięcie wymaganej autonomii.

### Co skraca żywotność

- **Temperatura** — każde 10 °C powyżej 20 °C skraca żywotność o połowę (reguła Arrheniusa). Akumulator w 30 °C wytrzyma ~ 2,5 roku zamiast 5
- **Głębokie rozładowania** — DoD 80 % zmniejsza liczbę cykli z ~ 1200 (DoD 30 %) do ~ 200
- **Przeładowywanie** — napięcie ładowania > 13,8 V przy 20 °C powoduje gazowanie i wysychanie elektrolitu
- **Brak doładowywania** — pozostawienie na półce > 6 miesięcy bez ładowania prowadzi do siarczanowania ołowiu
- **Tętno** — niskiej jakości zasilacze z dużym ripple AC potrafią zniszczyć akumulator w ciągu roku

## Pomiar stanu akumulatora

Akumulatora **nie sprawdza się woltomierzem** — bez obciążenia nawet zużyty pokaże 13 V. Dwa właściwe pomiary:

### Test pojemności (rozładowanie kontrolowane)

Rozładowanie znanym prądem do napięcia końcowego (10,5 V dla VRLA 12 V przy I₂₀) i pomiar czasu:

```
C_zmierzone = I_rozład × t_do_10,5V

Dla akumulatora 12 V / 7 Ah przy prądzie 0,35 A (C/20):
  jeśli rozładuje się w 18 h → pojemność = 6,3 Ah (90 %) — OK
  jeśli rozładuje się w 13 h → pojemność = 4,55 Ah (65 %) — wymiana
```

### Test wewnętrznej rezystancji (testery impulsowe)

Tester typu Midtronics MDX-650, Hioki BT3554 podaje rezystancję wewnętrzną — porównanie z wartością katalogową:

| Stan | R_int dla 12 V / 7 Ah |
|---|---|
| Nowy | ~ 30 mΩ |
| Sprawny | 30–45 mΩ |
| Pogorszony | 45–80 mΩ |
| Wymagający wymiany | > 80 mΩ |

Centrale alarmowe Satel mają wbudowaną funkcję **okresowego testu akumulatora** (DLOAD X — opcja w globalnych ustawieniach). Co 4 h centrala wymusza chwilowe obciążenie i mierzy napięcie pod obciążeniem — jeśli spadnie poniżej 12 V, generowana jest awaria *BAT LOW*.

## Producenci i modele 2026

| Marka | Seria | Klasa | Cena 12 V / 7 Ah |
|---|---|---|---|
| **MWPower** (Polska/CN) | MWS, MWLG | 5 lat, standard | 50–70 zł |
| **Yuasa** (UK/JP) | NP, NPL, SWL | 5/10/12 lat | NP 80–100 zł, NPL 130–170 zł |
| **Fiamm** (Włochy) | FG, FGL, FGH | 5/10 lat | FG 90 zł, FGL 160 zł |
| **Sonnenschein** (Niemcy) | Dryfit A500, A600 | GEL, 10 lat | 200–250 zł (premium SAP) |
| **EnerSys / Hawker** | Genesis, DataSafe | 10–12 lat | 200–300 zł (data center) |
| **CSB** (Tajwan) | GP, HR, HRL | 5/8/12 lat | 70–140 zł |
| **Panasonic** | LC-R, LC-P | 5/10 lat | 80–130 zł |

**Wybór praktyczny:** dla alarmu domowego — MWPower lub CSB klasy 5-letniej (50–70 zł, wymiana co 3 lata = 17 zł/rok). Dla SAP i obiektów krytycznych — Yuasa NPL lub Fiamm FGL klasy 10-letniej (130–170 zł, wymiana co 6 lat = 25 zł/rok).

## Utylizacja

Akumulatory VRLA zawierają ~65 % ołowiu i kwas siarkowy. Obowiązkowo oddawane do PSZOK lub sklepu (zasada „kupujesz nowy, oddajesz stary"). Wyrzucenie do śmieci komunalnych podlega karze do 5000 zł (Ustawa o bateriach i akumulatorach z 24.04.2009 r., znowelizowana 2022).

## Symbole i opisy na akumulatorze

```
12V 7Ah/20HR — pojemność 7 Ah przy rozładowaniu 20-godzinnym (0,35 A)
F1 / F2       — typ wyprowadzenia (faston 4,8 mm / 6,3 mm)
Date code     — kod daty produkcji (czytaj jako YYWW lub MM-YY)
Cyclic use    — 14,4–15,0 V (głębokie cykle)
Standby use   — 13,5–13,8 V (praca buforowa, float)
```

## Co dalej

➡ [Zasilacze buforowe — PSAC, PSBOC, EN54-4](14-02-zasilacze-buforowe.md)
