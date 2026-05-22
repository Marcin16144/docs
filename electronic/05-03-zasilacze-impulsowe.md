# 05-03: Zasilacze impulsowe (SMPS)

## Czym jest SMPS

**Switch-Mode Power Supply** — zasilacz przełączający. Tranzystor szybko włącza i wyłącza prąd (10 kHz – 2 MHz), energia jest magazynowana w cewce lub transformatorze i kontrolowanie uwalniana.

### Dlaczego SMPS

- **Wysoka sprawność** (85-97% vs 30-60% liniowych)
- **Mniejsze i lżejsze** (cewka HF zamiast transformatora 50 Hz)
- **Większa elastyczność** (step-up, step-down, izolacja)
- **Mniej ciepła**

### Wady SMPS

- Zakłócenia elektromagnetyczne (EMI)
- Więcej elementów, większa komplikacja
- Tętnienia HF na wyjściu
- Wrażliwość na obciążenie
- Większy koszt elementów (ale ogólnie tańszy w produkcji)

## Podstawowe topologie

### Buck (step-down) — obniżający

Najpopularniejszy. Obniża napięcie wejścia.

```
   +V_in ──[Q]──┬──[L]──┬── +V_out
   (MOSFET)     │       │
                ▼       │
                ▽ D     C
                │       │
   GND ─────────┴───────┴── GND
```

### Cykl pracy buck

1. **Q włączony**: prąd płynie przez L do C i obciążenia. L magnezuje się.
2. **Q wyłączony**: cewka utrzymuje prąd (samoindukcja), prąd zamyka się przez diodę D do obciążenia. L się rozmagnesowuje.

### Wzory

```
V_out = D · V_in     (D = duty cycle, 0-1)

L = V_in · (1−D) · D / (f · ΔI_L)
ΔI_L = 20-40% prądu obciążenia (typowo)

C_out = ΔI_L / (8 · f · ΔV_out)
```

### Przykład

V_in = 12 V, V_out = 5 V, I_out = 2 A, f = 100 kHz, ΔI_L = 0,4 A:

```
D = 5/12 = 0,42
L = 12 · 0,58 · 0,42 / (100 000 · 0,4) = 73 μH
ΔV_out = 50 mV (typowe), C = 0,4 / (8 · 100 000 · 0,05) = 10 μF
```

### Boost (step-up) — podwyższający

Podnosi napięcie wejścia.

```
   +V_in ──[L]──┬──▷├──┬── +V_out
                │       │
                [Q]    [C]
                │       │
   GND ─────────┴───────┴── GND
```

### Cykl boost

1. **Q ON**: prąd przez L do masy. Cewka magazynuje energię. Dioda blokuje (C utrzymuje napięcie wyjścia).
2. **Q OFF**: cewka utrzymuje prąd, napięcie L dodaje się do V_in, ładuje C przez D.

```
V_out = V_in / (1−D)

L = V_in · D / (f · ΔI_L)
```

Boost potrafi podnieść napięcie 5-10×, ale wzrastają prądy w L (energia = ½LI²).

### Buck-Boost

Może i obniżać, i podwyższać. Inwertuje polaryzację.

```
V_out = -V_in · D / (1−D)
```

Stosowane: zasilanie z baterii (Li-Ion 3-4 V → 5 V stabilne).

### SEPIC

Single-Ended Primary-Inductor Converter. Tej samej polaryzacji, może i obniżać, i podnosić. Złożony.

### Flyback

**Z izolacją galwaniczną**, mała moc (do ~200 W). Najpopularniejszy w zasilaczach 230 V → 5/12 V.

```
        ┌──UUUU──┐ trafo
   AC ──┤        ├─▷├── +V_out
        │   ||   │     │
        │   ||  ─┴─C   │
        └──UUUU──┤     │
                 [Q]   │
                 │     │
                GND   GND
```

Cykl:
1. **Q ON**: prąd w uzwojeniu pierwotnym, energia magazynowana w rdzeniu, dioda wtórna blokuje.
2. **Q OFF**: napięcie pierwotne odwraca się, indukcja w wtórnym, dioda przewodzi, C ładuje się.

Standardowy układ w ładowarkach USB, zasilaczach komputerowych do 250 W.

### Forward

Trafo "przepuszcza" energię bezpośrednio. Większa moc, bardziej skomplikowane. Stosowane > 200 W.

### Half-Bridge / Full-Bridge

Większe moce (> 500 W). Zasilacze PC, serwerowe, spawarki.

### Push-Pull

Dwa tranzystory przemiennie. Duże moce, niskie napięcia (samochodowe inwertery).

### LLC Resonant

Najwyższa sprawność (97%+). Złożony układ. Stosowane w premium SMPS, zasilaczach serwerowych.

## Sterowanie SMPS

### PWM (Pulse Width Modulation)

Kontroler mierzy V_out, porównuje z referencją, zmienia duty cycle. Stała częstotliwość, zmienna szerokość impulsu.

### PFM (Pulse Frequency Modulation)

Stała szerokość, zmienna częstotliwość. Lepsza sprawność przy bardzo małych obciążeniach.

### Hybrid (PWM + PFM)

Powyżej progu PWM, poniżej PFM. Stosowane w nowoczesnych SMPS.

### Current Mode vs Voltage Mode

- **Voltage mode**: sterowanie napięciem
- **Current mode**: sterowanie prądem przez cewkę. Szybsza reakcja, naturalna ochrona prądowa. Dominuje dziś.

## Popularne sterowniki SMPS

### Buck

- **MC34063** — klasyk, do 100 kHz, do 1,5 A
- **LM2576** — 1 A, integrated, 52 kHz
- **LM2596** — 3 A, 150 kHz, popularne moduły z AliExpress
- **TPS54331** — 3 A, 570 kHz, lepszej klasy
- **TPS56xx** — wyższe częstotliwości

### Boost

- **MT3608** — moduły boost, 2 A
- **LM2577** — 3 A, do 12 V boost

### Flyback (z izolacją AC)

- **TNY** (Power Integrations) — popularne w ładowarkach USB
- **LNK** — niskobudżetowe ładowarki
- **UC3842, UC3845** — klasyczne PWM
- **NCP1015, NCP1200** — popularne

### Synchroniczne

Zamiast diody używają drugiego MOSFETa → wyższa sprawność.

## Komponenty SMPS

### MOSFET

Wymagania:
- Niski R_DS(on) → niskie straty przewodzenia
- Niski Q_g → szybkie przełączanie
- Logic level lub odpowiedni driver
- V_DSS z zapasem 2× max V_in

Popularne: AO3400 (małe), IRFB4115 (mocne), CSD18532 (sync).

### Dioda

Schottky w niskim napięciu (V_out < 30 V). Ultra-fast Si dla wyższych.

### Cewka

- **Indukcyjność** L wg wzoru
- **Prąd nasycenia I_sat** > prąd szczytowy
- **Niska DCR** dla wysokiej sprawności
- **Rdzeń** ferrytowy lub żelazo proszkowe

### Kondensator wyjściowy

- **Niski ESR** krytyczny (lepsza filtracja, mniej grzania)
- Często MLCC + elektrolit razem
- Ceramik wystarcza dla 1-10 A; przy większych mocach polimerowe Al/Ta

### Kondensator wejściowy

Filtruje pulsujący prąd MOSFETa. Niski ESR, wysokie ripple current.

## Sprzężenie zwrotne i kompensacja

SMPS to **regulator z pętlą sprzężenia**. Stabilność zależy od:
- Wzmocnienia pętli
- Marginesu fazy
- Zerom i biegunom obwodu kompensacji

Datasheets sterowników podają wzory kompensacji. Złego projektu = oscylacje, niestabilność, hałas, dezintegracja.

## Sprzężenie zwrotne dla izolowanego SMPS (flyback)

Przez **optoseparator** + TL431. TL431 mierzy napięcie wyjścia, steruje LED w optoseparatorze, ten sygnalizuje stronie pierwotnej.

## EMI w SMPS

Szybkie przełączanie generuje zakłócenia (kHz-MHz). Trzeba:

- **Filtr EMI** na wejściu (X i Y caps, common-mode choke)
- **Layout PCB** krótkie ścieżki mocy, mała pętla prądowa
- **Snubbery** na MOSFETach i diodach
- **Ekranowanie** dla wrażliwych aplikacji
- **Spread Spectrum** modulacja (niektóre sterowniki) — rozprasza zakłócenia w paśmie

## Sprawność

Czołówka:
- Buck 12→5 V: 92-97%
- Flyback 230 AC→ 5 V: 75-88% (USB Quick Charger 85-90%)
- LLC 230 AC→ 12 V: 92-97%

Straty:
- Przewodzenia MOSFET (I²R_DS)
- Przełączania MOSFET (V·I·t·f)
- Diody (V_F·I)
- Cewki (DCR + straty rdzenia)
- Kondensatorów (ESR)
- Sterownika (prąd jałowy)

## Projekt prostego buck 12 V → 5 V

### Specyfikacja
- V_in: 12 V (8-15 V)
- V_out: 5 V
- I_out: 2 A
- f: 100 kHz

### Wybór sterownika
LM2596S-5.0 (stała wersja 5 V) — gotowy moduł.

### Cewka
- Wzór: L ≈ V_out · (V_in - V_out) / (V_in · f · ΔI)
- ΔI = 30% · 2 A = 0,6 A
- L = 5 · 7 / (12 · 100k · 0,6) ≈ 49 μH → wybór 47 μH
- I_sat > 2,6 A → wybór cewki na 3-5 A

### Dioda
SR340 (3 A, 40 V Schottky) lub MBR340.

### Kondensatory
- C_in: 100 μF / 25 V niskoESR (kilka μF MLCC w paraleli)
- C_out: 220 μF / 16 V niskoESR

### PCB
Krótkie połączenia powrotnej masy. Plaszczyzna masy. Mała pętla przełączania (Q + dioda + C_in).

### Wynik
Sprawność ~90% przy 2 A.

## Gotowe moduły

Dla DIY często łatwiej kupić gotowe:

- **LM2596 buck** ~5 zł na AliExpress — od 7 V do 35 V, daje 1,2-30 V, 3 A
- **MT3608 boost** — 2 V do 24 V wejścia, 5-28 V wyjścia, 2 A
- **MP1584** — buck do 3 A
- **DC-DC modules 5 V USB** — ładowarki samochodowe

## Niepowodzenia SMPS

Częste problemy w taniej elektronice:

1. **Wybuch elektrolitu wejściowego** — niskiej jakości lub zbyt mały prąd ripple.
2. **Padły MOSFET** — głównie przez przegrzanie lub zbyt mała moc.
3. **Wadliwy snubber** → przebicie MOSFETa od spikes.
4. **Niestabilność po latach** — wysychanie elektrolitów → pętla sprzężenia drży.
5. **Ekstremalne EMI** — sprzęt wyłącza się sąsiadowi z radia.

## Częste błędy projektowe

1. **Cewka bez zapasu nasycenia** — przy szczycie prądu L spada, prąd lawinowo rośnie, MOSFET pada.
2. **Brak snubbera** przy MOSFETach w niskonapięciowym buck — spike z indukcyjności.
3. **Zbyt długie ścieżki** w pętli przełączania → EMI, oscylacje.
4. **Wspólna masa cyfra-moc** → szum w sterowniku.
5. **Zbyt mała pojemność wejścia** → tętnienia w zasilaniu.
6. **Brak filtra wyjściowego** dla wysokich częstotliwości — ringing 100 mV-pp.
7. **Sygnał feedback przez gorące miejsce** PCB → zmieniający się offset.

## Kiedy liniowy, kiedy SMPS

| Sytuacja | Wybór |
|----------|-------|
| Mała moc (< 1 W) | liniowy (LDO) |
| Małe różnica napięć | liniowy |
| Krytyczne czyste zasilanie (audio, ADC) | liniowy lub LDO |
| Duża moc (> 5 W) | SMPS |
| Z baterii | SMPS (buck-boost) |
| Wysokie napięcia (sieć) | SMPS (flyback) |
| Komputery, ładowarki | SMPS |
| Spawarki, lampy LED | SMPS |
