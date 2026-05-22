# 02-02: Kondensatory

## Czym jest kondensator

Element bierny gromadzący energię w **polu elektrycznym** między dwiema okładkami rozdzielonymi dielektrykiem (izolatorem).

Symbol: `──││──` (niespolaryzowany), `──┤├──` (spolaryzowany — elektrolityczny). Oznaczenie schematowe: **C1, C2...**

## Pojemność

**Pojemność C** to zdolność gromadzenia ładunku przy danym napięciu.

```
C = Q / U        [F = C/V]
```

Jednostka: **farad (F)**. Farad to ogromna jednostka — w praktyce używamy:

- **pF** (pikofarad) — 10⁻¹² F (HF, oscylatory)
- **nF** (nanofarad) — 10⁻⁹ F (filtry, blokowanie)
- **μF** (mikrofarad) — 10⁻⁶ F (filtry zasilania)
- **mF** (milifarad) — 10⁻³ F (duże filtry, audio)
- **F** (farad) — superkondensatory (ultracaps), energia

## Wzór na pojemność płaskiego kondensatora

```
C = ε · S / d

ε — przenikalność elektryczna dielektryka [F/m]
S — pole okładek [m²]
d — odległość między okładkami [m]
```

Większe pole = większa pojemność. Cieńszy dielektryk = większa pojemność, ale niższe napięcie pracy.

## Ładowanie i rozładowanie

Kondensator ładuje się przez rezystor wykładniczo:

```
u(t) = U · (1 − e^(−t/RC))     — ładowanie
u(t) = U · e^(−t/RC)           — rozładowanie

τ = R · C      — stała czasowa [s]
```

Po czasie **τ**: napięcie ≈ 63% wartości końcowej.
Po **5τ**: ≈ 99% — przyjmuje się za "naładowany".

### Przykład

R = 10 kΩ, C = 100 μF
```
τ = 10 000 · 0,0001 = 1 s
```

Po 5 sekundach kondensator naładowany praktycznie do końca.

## Reaktancja kondensatora w AC

```
X_C = 1 / (2π·f·C)        [Ω]
```

- Dla DC (f = 0): X_C = ∞ → kondensator **blokuje DC**
- Dla wysokich częstotliwości: X_C → 0 → kondensator **przewodzi AC**

Stąd zastosowanie: blokowanie DC, sprzęganie sygnału AC.

### Przykład

C = 100 nF, f = 1 kHz:
```
X_C = 1 / (2π · 1000 · 100·10⁻⁹) = 1592 Ω
```

Ten sam kondensator przy 1 MHz:
```
X_C = 1,6 Ω
```

## Typy kondensatorów

### Ceramiczne

Dielektryk ceramiczny. Małe pojemności (pF – μF), wysokie napięcia, taniutkie. Klasy:

- **NP0 / C0G** — najdokładniejsze, stabilne z temperaturą, do oscylatorów
- **X7R, X5R** — większe pojemności, mniej stabilne, "uniwersalne"
- **Y5V, Z5U** — bardzo duże pojemności w małej obudowie, ale spadek pojemności z napięciem i temperaturą do 80%!

W praktyce ceramik **traci pojemność z napięciem DC** — przy 50% U_max może mieć tylko 50% nominalnej C. To nazywamy **DC bias effect**.

### Foliowe (film capacitors)

Dielektryk z folii polimerowej. Bardzo dobre parametry, niskie straty.

- **MKT (PET)** — uniwersalne
- **MKP (PP)** — audio, snubbery
- **MKS** — sieciowe (klasa X, Y)

Niespolaryzowane, długa żywotność, większe od ceramicznych. Pojemności nF do kilku μF.

### Elektrolityczne aluminiowe

Dielektryk to cienka warstwa tlenku Al₂O₃ na folii aluminiowej. **Spolaryzowane** — błędne podłączenie = uszkodzenie (czasem eksplozja).

- Duże pojemności (1 μF – 100 mF)
- Niewielkie wymiary jak na pojemność
- Krótka żywotność (1000–10000 h w 105°C)
- Wysoki ESR (rezystancja zastępcza)
- Wysychanie z czasem
- Najgorsze parametry w wysokich częstotliwościach

### Tantalowe

Spolaryzowane, mniejsze i bardziej stabilne niż aluminium. Droższe. Wrażliwe na przepięcia (wybuchają). Stosowane w sprzęcie wojskowym i precyzyjnym.

### Superkondensatory

Pojemność farady i więcej. Niskie napięcia (2,5–5 V). Zastosowanie: zasilanie awaryjne RAM, podtrzymywanie zegara RTC, hybrydy z bateriami.

### Zmienne (trymer)

Małe kondensatory regulowane mechanicznie, do dostrojenia oscylatorów.

## Oznaczenia kondensatorów

### Bezpośredni opis

```
4,7μF / 50V
100nF
22pF
```

### Kod cyfrowy (małe ceramiczne SMD i THT)

Trzy cyfry, w pF:

```
104  →  10 × 10⁴ pF = 100 000 pF = 100 nF = 0,1 μF
473  →  47 × 10³ pF = 47 000 pF = 47 nF
220  →  22 × 10⁰ pF = 22 pF
2R2  →  2,2 pF
```

### Litera za cyframi = tolerancja

```
J = ±5%
K = ±10%
M = ±20%
Z = +80% / −20%   (Y5V, Z5U)
```

### Kondensatory MLCC SMD często nie mają oznaczeń

Trzeba je trzymać w pudełkach z opisami albo mierzyć multimetrem (większość ma tryb pomiaru C).

## Łączenie kondensatorów

### Szeregowo

```
1/C = 1/C1 + 1/C2 + ...
```

Dla dwóch:
```
C = (C1 · C2) / (C1 + C2)
```

Pojemność **maleje**, ale napięcie pracy się sumuje. Stosowane do uzyskania wyższego napięcia pracy.

### Równolegle

```
C = C1 + C2 + ...
```

Pojemność **rośnie**, napięcie pracy = najmniejsze z indywidualnych.

### Praktyka

Dwa kondensatory 100 μF / 25 V równolegle = 200 μF / 25 V.
Dwa kondensatory 100 μF / 25 V szeregowo = 50 μF / 50 V.

## Parametry kondensatora

### ESR (Equivalent Series Resistance)

Zastępcza rezystancja szeregowa. Reprezentuje straty.

- Ceramiczne: bardzo niskie (mΩ)
- Foliowe: niskie (10-100 mΩ)
- Elektrolityczne: wysokie (0,1-2 Ω) — gorsze z wiekiem

W zasilaczach niski ESR jest kluczowy — wysokie ESR powoduje grzanie i niestabilność.

### ESL (Equivalent Series Inductance)

Indukcyjność pasożytnicza. Ogranicza pracę w HF. SMD ma niższy ESL niż THT (krótsze wyprowadzenia).

### Współczynnik strat tan δ

Stosunek mocy traconej do mocy reaktywnej. Im niższy, tym lepszy.

### Współczynnik temperaturowy

Jak pojemność zmienia się z temperaturą. NP0 prawie nic. Y5V — drastycznie.

### Napięcie znamionowe

Maksymalne napięcie pracy. Zawsze stosować zapas 2×. Dla AC podaje się napięcie AC RMS lub szczytowe DC.

### Prąd tętnień (ripple current)

Dla elektrolitów — ile prądu AC kondensator zniesie bez przegrzania.

## Zastosowania

### 1. Filtrowanie zasilania

Po prostowniku kondensator wygładza tętnienia. Wzór na pojemność:

```
C ≥ I_obc / (2·f·ΔU)

I_obc — prąd obciążenia
f     — częstotliwość tętnień (100 Hz dla mostka z 50 Hz)
ΔU    — dopuszczalne tętnienia [V]
```

Przykład: I = 1 A, dopuszczamy 0,5 V tętnień, 50 Hz sieci → 100 Hz po mostku:
```
C = 1 / (2 · 100 · 0,5) = 0,01 F = 10 000 μF
```

### 2. Sprzęganie sygnału (DC blocking)

Kondensator między stopniami wzmacniacza — przepuszcza AC (sygnał), blokuje DC (punkt pracy).

```
f_dolna = 1 / (2π · R · C)
```

Dla audio (20 Hz dolna granica), R = 10 kΩ:
```
C ≥ 1 / (2π · 20 · 10 000) = 0,8 μF
```

Stosujemy 1 μF z zapasem.

### 3. Blokowanie / decoupling

Kondensator 100 nF tuż przy nóżce VCC każdego układu scalonego. Bocznikuje szybkie tętnienia, dostarcza chwilowych szczytów prądu.

**Reguła:** każdy IC = jeden kondensator 100 nF na każdym Vcc.

### 4. Tank circuit (oscylatory)

Kondensator + cewka tworzą obwód rezonansowy:

```
f = 1 / (2π · √(L·C))
```

Filtruje wybraną częstotliwość lub generuje ją.

### 5. Snubber (tłumik łuku)

Kondensator + rezystor równolegle do styku przekaźnika lub do tranzystora. Tłumi przepięcia indukcyjne i iskrzenie.

### 6. Magazynowanie energii

Bateria zasilania awaryjnego, fotoflesze, defibrylatory. Energia:

```
E = ½ · C · U²
```

## Polaryzacja elektrolitów

Kondensator elektrolityczny **MA POLARYZACJĘ**. Wewnętrznie:

```
   + ──┤ Al ── Al₂O₃ ── elektrolit ── Al ── ─
        anoda             katoda
```

Oznaczenie:
- **Plus**: dłuższe wyprowadzenie (przed odcięciem)
- **Minus**: kreska/pasek na obudowie
- Tantalowe: **plus** = znak "+" na obudowie (uwaga, inaczej!)

Podłączenie odwrotne → kondensator pęcznieje, eksploduje, kropla siarczanu na PCB.

## Awaria kondensatorów

### Wysychanie elektrolitów

Elektrolit odparowuje przez uszczelkę. Pojemność maleje, ESR rośnie. Objaw: pęczniejące "czapeczki" na górze, czarno-brązowe wycieki. Najczęstsza awaria zasilaczy komputerowych, monitorów, telewizorów.

### Przebicie dielektryka

Przepięcie powyżej U_max → zwarcie. Ceramiczne często pękają mechanicznie pod naprężeniem.

### "Capacitor plague" 2000-2005

Wadliwe elektrolity z chińskich fabryk masowo padały. Do dziś temat wymiany kondensatorów w starszym sprzęcie.

## Pomiar pojemności

### Multimetr z funkcją pomiaru C

Wystarczy do 90% przypadków. Dokładność ~2%.

### Tester kondensatorów / LCR meter

Mierzy C, ESR, tan δ. Pozwala wykryć kondensator "z wyglądu OK", ale rozsuszony.

### Tester ESR

Specjalizowany, mierzy ESR bez wylutowywania kondensatora. Bardzo przydatne w serwisie.

## Wybór kondensatora — checklist

1. **Jaka pojemność**? (oblicz z czasu/filtra/funkcji)
2. **Jakie napięcie znamionowe**? (zapas 2×)
3. **AC czy DC**? (jeśli AC — kondensator klasy X/Y do sieci)
4. **Spolaryzowany czy niespolaryzowany**? (elektrolit tylko DC w jedną stronę)
5. **Jaka częstotliwość pracy**? (HF → ceramika lub film, nie elektrolit)
6. **Jaki ESR**? (zasilacze → niskoESR; audio → film)
7. **Stabilność z temperaturą**? (oscylatory → NP0; bypassing → X7R)
8. **Rozmiar i typ obudowy**?

## Częste błędy

1. **Podłączenie elektrolitu na odwrót** = wybuch. Sprawdź dwa razy.
2. **Brak kondensatorów blokujących** przy IC — dziwne błędy, niestabilność.
3. **Niskie napięcie znamionowe** — Y5V 16 V w obwodzie 12 V pulsującym = pęknięcie.
4. **Spolaryzowany w AC** — elektrolit między fazą a zerem = bardzo zła pomysł.
5. **Kondensator klasy Y nie zastąpi X** (i odwrotnie) w filtrach sieciowych — różne wymagania bezpieczeństwa.
