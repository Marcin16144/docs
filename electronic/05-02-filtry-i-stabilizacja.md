# 05-02: Filtry i wygładzanie

## Po co filtr

Po prostowniku napięcie jest pulsujące (półsinusy). Filtr wygładza je do prawie czystego DC. Im lepszy filtr, tym mniejsze tętnienia.

## Tętnienia (ripple)

**Tętnienie** to składowa AC nałożona na DC. Mierzymy ją:
- Peak-to-peak (ΔU_pp)
- RMS (U_ripple_rms)

Wzór RMS dla sinusa: U_RMS = ΔU_pp / (2√2).

Stosunek tętnień do DC: **współczynnik tętnień (ripple factor)**:

```
γ = U_ripple_rms / U_DC
```

Im niższy, tym lepiej. Dla 5% (typowe wymaganie liniowego stabilizatora): γ = 0,05.

## Filtr C (pojemnościowy)

### Schemat

```
   z mostka ──┬─── + DC
              │
              │
             [C]   filtr (elektrolit)
              │
              │
   GND ───────┴─── − DC
```

Najprostszy i najczęściej spotykany filtr.

### Działanie

Kondensator ładuje się do szczytu prostowanej fali. Gdy fala spada, kondensator zasila obciążenie. W rezultacie napięcie ledwo zauważalnie spada między kolejnymi szczytami.

### Wzór na pojemność

```
C ≥ I_obc / (f · ΔU_pp)

I_obc — prąd obciążenia [A]
f     — częstotliwość tętnień (100 Hz dla mostka 50 Hz)
ΔU_pp — dopuszczalne tętnienia [V]
C     — pojemność [F]
```

### Przykład

I_obc = 2 A, dopuszczalne tętnienia ΔU = 1 V, f = 100 Hz:

```
C = 2 / (100 · 1) = 0,02 F = 20 000 μF
```

W praktyce wybieramy 22 000 μF lub 2× 10 000 μF równolegle.

### Dobór napięcia kondensatora

```
U_C ≥ √2 · U_AC + zapas (np. 25-50%)
```

Dla 12 V AC: szczyt ~17 V → C 25 V, 35 V, lub 50 V.

### Wady filtra C

- Duży prąd szczytowy diód (ładowanie kondensatora w krótkim czasie)
- Niska sprawność transformatora (cos φ pogarsza się)
- Duże fizyczne wymiary kondensatora

## Filtr LC

### Schemat

```
   z mostka ──[L]──┬── + DC
                   │
                  [C]
                   │
   GND ────────────┴── − DC
```

Cewka indukcyjna L szeregowo, kondensator C równolegle.

### Działanie

Cewka opiera się zmianom prądu → wygładza prąd. Kondensator wygładza napięcie. Razem dają mniejsze tętnienia niż samo C.

### Częstotliwość odcięcia

```
f_c = 1 / (2π · √(L · C))
```

Tętnienia powyżej f_c są tłumione 40 dB/dekada.

Przykład: L = 10 mH, C = 1000 μF → f_c = 50 Hz. Dla tętnień 100 Hz (mostek) tłumienie ~12 dB (4×).

### Zalety

- Bardzo małe tętnienia
- Lepsza dla transformatora (ciągły prąd)
- Mniejszy prąd szczytowy diód

### Wady

- Cewka duża i ciężka (50/100 Hz)
- Droga
- Stosowane głównie w zasilaczach lampowych (audio HF), spawarkach, dużych zasilaczach

## Filtr π (pi)

### Schemat

```
   z mostka ──┬──[L]──┬── + DC
              │       │
             [C1]    [C2]
              │       │
   GND ───────┴───────┴── − DC
```

Dwa kondensatory + cewka.

### Zalety

- Lepsze niż samo C
- Mniejsza cewka niż LC (C1 odbiera większość tętnień)

## Filtr RC

Stosowany dla małych prądów:

```
   z mostka ──[R]──┬── + DC
                   │
                  [C2]
                   │
   GND ────────────┴── − DC
```

R rzędu 1-100 Ω. Rezystor ogranicza prąd ładowania C2 i tłumi tętnienia, ale **rozprasza moc** = P = I²·R.

Stosowane gdy nie ma sensu używać cewki (małe prądy, mała pojemność).

## Dobór dużego kondensatora — praktyka

### Reguły kciuka

- Małe zasilacze (mA do kilkudziesięciu mA) → 100-1000 μF
- Średnie (do 1 A) → 2200-4700 μF
- Duże (1-5 A) → 4700-10 000 μF
- Bardzo duże (>5 A) → 10 000+ μF (często kilka równolegle)

### Wartość napięcia kondensatora

Zawsze z **zapasem 1,5-2×** względem szczytu napięcia.

Sieć 230 V po mostku: 325 V szczytu → kondensator 400-450 V.

### ESR — krytyczny w prostownikach

Wysoki ESR daje wyższe tętnienia i grzanie kondensatora. Wybieraj **niskoomowe** (low-ESR), **wysoko-temperaturowe** (105°C).

Przykład: w zasilaczach komputerowych masowo padają zwykłe elektrolity. Zamień na 105°C low-ESR, mostek wytrzyma dekady.

### Tętnienie prądowe (ripple current)

Datasheet podaje maksymalny prąd AC, który kondensator zniesie bez przegrzania. Przekroczenie → grzanie i krótsza żywotność.

Dla mostka prostowniczego prąd szczytowy diód:
```
I_szczyt ≈ I_obc · (5-10)
I_RMS przez C ≈ I_obc · (1,5-2)
```

Kondensator musi to wytrzymać.

## Wpływ filtra na napięcie DC

Bez filtra: U_DC = 0,636 · U_m (mostek)
Z filtrem C: U_DC ≈ U_m − 1,4V (Si diody, lekko mniej z prądem)

**Z filtrem napięcie DC jest WYŻSZE** niż bez filtra. To częste źródło pomyłek:

- Sieć 230 V → trafo 12 V AC → mostek → C 4700 μF
- Spodziewane: 12 V DC
- Faktyczne: ~16 V DC bez obciążenia
- Pod obciążeniem 1 A: ~14 V DC

## Aktywne tłumienie tętnień

Capacitance multiplier — tranzystor + kondensator + R działa jak ogromny kondensator (efektywnie 100-1000×):

```
   in ──[R]──┬──── B─── tranzystor NPN
             │       │
            [C]      C ── obciążenie
             │       │
            GND     wyjście
                     E
                     │
                     out (z mniejszymi tętnieniami)
```

Tania metoda na "czyste" napięcie przed wzmacniaczem audio bez wielkich kondensatorów.

## Sprzężenie — czyste vs nieczyste zasilanie

W jednym układzie często są obwody "czyste" (analogowe, ADC) i "brudne" (cyfrowe, silniki). Powinny mieć **oddzielne ścieżki zasilania i masy**, łączone w jednym punkcie.

### Filtr LC dla analogowej części

Mały koralik ferrytowy + kondensator między ogólnym +5 V a +5 V analogowym:

```
   +5V ─[koralik]─ +5V_A
                   │
                  [C 10μF]
                   │
                  GND_A ── tylko w jednym punkcie do GND
```

## Filtr EMI na wejściu sieciowym

Klasa C, klasa Y, koraliki — chronią sieć przed zakłóceniami z SMPS i odwrotnie.

```
   L ──[L1 cm choke]──┬── 
                       ●─[X cap]─ ●  zasilacz
   N ──[L1 cm choke]──┘
                       
   PE ── do obu linii przez Y caps
```

- **X cap** (klasa X, między L a N) — 100 nF – 470 nF, blokowanie zakłóceń różnicowych
- **Y cap** (klasa Y, do PE) — 2,2-4,7 nF, blokowanie wspólnych (common-mode)
- **Common-mode choke** (CM choke) — dwie cewki na wspólnym rdzeniu

Bez tego: SMPS zaśmieca sieć, urządzenie nie przejdzie EMC.

## Przykład: pełny zasilacz liniowy 12 V / 2 A

### Schemat

```
   sieć 230V ──[F 250mA T]──[CM choke]──[trafo 18V/3A]──
                                                        │
                                                  ──[mostek 6A]──
                                                                 │
                                            ┌── + ──┬─[7812]──┬── +12V
                                                    │         │
                                                 [4700μF]  [100nF]
                                                    │         │
                                            └── − ──┴─────────┴── GND
```

### Spadek napięcia

```
sieć 230 V → trafo 18 V → mostek (1,4 V drop) → C → 16,9 V DC
   z trafo (under load 16 V) → mostek → ~21 V szczyt → 18 V DC
   po 7812: stabilne 12 V
```

Margines dropout 7812: 21 V − 12 V = 9 V dropout. Większy niż potrzebny, ale ok.

### Moc strat na 7812

```
P = (18 − 12) · 2 = 12 W → wymagany duży radiator
```

W rzeczywistych zasilaczach z takimi mocami częściej SMPS — patrz następny rozdział.

## Częste błędy

1. **Zbyt mały C** — tętnienia większe niż obliczenia → stabilizator pływa.
2. **Zbyt mały U_C** — kondensator wybuchowy (literalnie).
3. **Kondensator wysoko-ESR** — grzanie, krótka żywotność, słaba filtracja.
4. **Elektrolit "do góry nogami"** — wybuch.
5. **Brak diody chroniącej** stabilizator przed cofnięciem ładunku z C_out.
6. **Filtr LC z cewką o zbyt małej indukcyjności** dla 100 Hz → nieefektywny.
7. **Filtr w niewłaściwym miejscu** — przed mostkiem (po stronie AC) nie pomoże w DC.
