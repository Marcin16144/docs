# 03-03: Tranzystor bipolarny (BJT)

## Czym jest BJT

**Bipolar Junction Transistor** — tranzystor złączowy bipolarny. Element trójkońcówkowy, wynaleziony w 1947 w Bell Labs przez Shockleya, Bardeena i Brattaina (Nagroda Nobla 1956).

Składa się z **trzech warstw** półprzewodnika: N-P-N lub P-N-P. Stąd dwie odmiany:

- **NPN** — częstsza
- **PNP** — odwrotna polaryzacja

## Końcówki

```
NPN:                    PNP:

        C (collector)           C
        │                       │
    B ──┤ (base)            B ──┤
        │                       │
        E ↓ (emitter)           E ↑
       strzałka                strzałka
       na zewnątrz             do środka
```

- **Baza (B)** — sterowanie (mały prąd)
- **Kolektor (C)** — wyjście (duży prąd)
- **Emiter (E)** — wspólna noga, masa lub plus

## Zasada działania

Niewielki prąd bazy I_B steruje znacznie większym prądem kolektora I_C:

```
I_C = β · I_B

β (lub h_FE) — wzmocnienie prądowe (50 – 1000, typowo 100-300)
```

I_E = I_C + I_B (z prawa węzłowego).

Złącze baza-emiter zachowuje się jak dioda. Spadek U_BE = 0,6-0,7 V (Si) w stanie aktywnym.

## Stany pracy tranzystora

### 1. Zatkanie (cut-off)

I_B ≈ 0, I_C ≈ 0. Tranzystor jak otwarty wyłącznik.
Warunek: U_BE < 0,5 V dla NPN.

### 2. Aktywny (active)

I_C = β · I_B. Tranzystor jak wzmacniacz prądowy.
Warunek: U_BE = 0,7 V, U_CE > U_CE_sat (typowo > 0,3 V).

### 3. Nasycenie (saturation)

I_C nie rośnie więcej z I_B (limit obciążenia). Tranzystor jak zamknięty wyłącznik.
Warunek: U_BE = 0,7 V, U_CE = U_CE_sat ≈ 0,1-0,3 V.

W trybie cyfrowym używamy tylko zatkania i nasycenia. W trybie analogowym — aktywnego.

## Charakterystyki

### Wejściowa (U_BE — I_B)

Typowa charakterystyka diody. Próg ~0,6 V.

### Wyjściowa (U_CE — I_C dla różnych I_B)

```
I_C
 │
 │    I_B=100μA  ────────
 │   /
 │  /  I_B=50μA  ────────
 │ /  /
 │//  /         I_B=20μA ────
 │/ //  /
 │////                    nasycenie│aktywny
 ──────────────────────────── U_CE
```

W aktywnym I_C prawie nie zależy od U_CE — to dobre źródło prądu.

## Parametry kluczowe

| Parametr | Symbol | Opis |
|----------|--------|------|
| Wzmocnienie prądowe | h_FE, β | I_C / I_B, typowo 100-300 |
| Max prąd kolektora | I_C max | 100 mA – 30 A |
| Max napięcie U_CE | U_CEO | 20 V – 1500 V |
| Napięcie nasycenia | U_CE_sat | 0,1-0,3 V |
| Częstotliwość graniczna | f_T | MHz – GHz |
| Moc dyssypacji | P_C max | 0,3 W – 200 W |

## Popularne modele BJT

### NPN

| Model | I_C | U_CEO | Obudowa | Zastosowanie |
|-------|-----|-------|---------|--------------|
| BC547 | 100 mA | 45 V | TO-92 | sygnałowy |
| 2N2222 | 800 mA | 30 V | TO-92/TO-18 | klucz/sygnał |
| BD139 | 1,5 A | 80 V | TO-126 | sterowanie |
| TIP31C | 3 A | 100 V | TO-220 | mocy |
| 2N3055 | 15 A | 60 V | TO-3 | mocy, audio |

### PNP

| Model | Komplement do |
|-------|---------------|
| BC557 | BC547 |
| 2N2907 | 2N2222 |
| BD140 | BD139 |
| TIP32C | TIP31C |
| MJ2955 | 2N3055 |

## Konfiguracje pracy

### Wspólny emiter (CE — Common Emitter)

```
       Vcc
        │
       [Rc]
        │
        ●─── wyjście (U_out)
        │
   ●────C
   │    │
[Rb]    │
   │    B
 we──[C]┤  ↓E
              │
              GND
```

Cechy:
- Wzmocnienie napięciowe **odwrócone** (180°)
- Wzmocnienie prądowe duże (β)
- Wzmocnienie napięciowe: A_U ≈ −R_C / R_E (z emiterem przez rezystor)
- Najczęstsza konfiguracja

### Wspólny kolektor (CC — emitter follower)

```
       Vcc
        │
        C
   ●────┤
   │    B
   │    │
   we───┤
        E
        │
       [Re]
        │
       wyjście (kopia we, mniejsza o 0,7 V)
```

Cechy:
- Wzmocnienie napięciowe ≈ 1 (wtórnik)
- Wzmocnienie prądowe = β
- Wysoka impedancja wejścia, niska wyjścia
- Buforowanie sygnału

### Wspólna baza (CB)

Rzadko stosowana w obwodach jednodynamicznych. Bardzo wysoka częstotliwość, dopasowanie impedancyjne.

## Tranzystor jako przełącznik

Najpopularniejsze zastosowanie w cyfrowej elektronice. Sterowanie obciążeniem (przekaźnikiem, silnikiem, LED) z portu mikrokontrolera.

### Schemat

```
   Vcc (12 V np.)
    │
   ─┴─ obciążenie (przekaźnik)
   ⊃ ⊂
    │
    ●── C
        │
   ●────B (NPN)
   │    │
  [Rb]  E ───── GND
   │
  Vbe (np. z MCU)
```

### Dobór R_B

Dla nasycenia trzeba zapewnić dostateczny I_B. **Reguła**: I_B ≥ I_C / β · margines (3-10×).

**Przykład:** Sterujemy przekaźnik 50 mA przy 12 V z portu MCU 3,3 V. Tranzystor BC547 (β = 100).

```
I_C = 50 mA (prąd cewki przekaźnika)
I_B_min = 50/100 = 0,5 mA
I_B (z 5× zapasem) = 2,5 mA
U_R = 3,3 − 0,7 = 2,6 V
R_B = 2,6 / 0,0025 = 1040 Ω → 1 kΩ
```

### Dioda freewheel

PRZY CEWCE OBOWIĄZKOWA. Dioda 1N4148 lub 1N4007 równolegle do przekaźnika, katodą do plusa.

Bez niej napięcie indukowane przy wyłączaniu zniszczy tranzystor.

## Tranzystor jako wzmacniacz

### Punkt pracy (bias)

Aby wzmacniać sygnał symetrycznie, tranzystor musi pracować w środku obszaru aktywnego. To zadanie polaryzacji (bias).

**Polaryzacja przez dzielnik bazy + emiterowa stabilizacja:**

```
   Vcc
   │
   ●─────[R1]
   │       │
   │       ●─── Baza
   │     ┌─┘
   │   [R2]
   │     │
   ●     GND     (równocześnie)
   │
  [Rc]
   │
   ●── wyjście (przez kondensator)
   │
   C
NPN┤
   E
   │
  [Re]
   │
   ●── kondensator bypass do GND
   │
  GND
```

Typowy projekt punktu pracy:
1. Wybierz Vcc i I_C (typowo 1-10 mA)
2. R_C tak, aby U_C ≈ Vcc/2 (środek zakresu)
3. R_E ≈ R_C/10 (stabilizacja termiczna)
4. R1, R2 tak, aby U_B = U_E + 0,7 V; I_R ≈ 10× I_B

### Wzmocnienie napięciowe

Dla CE z R_E i kondensatorem bypassującym:

```
A_U = −g_m · R_C ≈ −R_C / r_e

r_e ≈ 25 mV / I_C [Ω]
```

Przy I_C = 1 mA: r_e = 25 Ω, A_U = −R_C/25.

Dla R_C = 5 kΩ → A_U = −200.

## Ważne wzory zastępcze

```
I_E = I_C + I_B
I_C = β · I_B = α · I_E
α = β / (β+1) ≈ 0,99

g_m = I_C / V_T ≈ I_C / 25mV    (przewodność)
```

## Termiczne aspekty

### Współczynnik temperaturowy

- U_BE maleje −2 mV/°C → przy rosnącej T, ten sam V_B daje więcej I_C
- β rośnie z T
- Bez stabilizacji punkt pracy "ucieka" — **thermal runaway**

### Stabilizacja

- Rezystor w emiterze (R_E) — sprzężenie zwrotne ujemne
- Para Sziklai / Darlington z R_E
- Termistor PTC w obwodzie polaryzacji

### Moc i radiator

```
P_C = U_CE · I_C
```

Tranzystor mocy z radiatorem może oddać 50-200 W. Bez radiatora TO-220 → max 2 W ciągle.

Rezystancja termiczna: junction-to-case → case-to-heatsink → heatsink-to-ambient. Sumarycznie:

```
T_J = T_A + P · R_θJA
```

Pilnuj T_J < 125-150°C zależnie od typu.

## Konfiguracje wielotranzystorowe

### Darlington

Dwa tranzystory NPN. Wzmocnienie β1·β2 = 10000+. Sterowanie dużych prądów z małych. Wady: U_BE_total = 1,4 V, U_CE_sat wyższe (0,8-1 V).

```
   ●── C (wspólny)
   │
   ├─C──B────●
   │  │  Q1  │
   ├─E──     │
   │        C─Q2
   B
   │
   E (wspólny)
```

### Para różnicowa (long-tailed pair)

Dwa tranzystory z wspólnym emiterem (przez źródło prądowe). Podstawa wzmacniaczy operacyjnych, komparatorów.

### Lustro prądowe (current mirror)

Dwa identyczne tranzystory — jeden "diodowo" połączony jako referencja, drugi powiela ten sam prąd. Powszechne w op-ampach.

## Wybór tranzystora — checklist

1. **Polaryzacja** — NPN czy PNP?
2. **I_C max** z zapasem 2×
3. **U_CEO max** z zapasem 2×
4. **β** — wystarczające do sterowania
5. **f_T** — czy ma pracować w wysokich częstotliwościach
6. **Moc i radiator**
7. **Obudowa** (TO-92, SOT-23, TO-220, TO-3)
8. **U_CE_sat** — kluczowe dla przełącznika

## Częste błędy

1. **Brak R_B** — tranzystor pali się po podłączeniu sygnału.
2. **Brak diody freewheel** przy cewce.
3. **Pomylone NPN z PNP** — emiter NPN powinien być uziemiony, PNP — pod plusem.
4. **Niski I_B** — tranzystor nie wchodzi w nasycenie, U_CE_sat za wysokie, grzanie.
5. **Sterowanie tranzystorem przez kondensator + brak polaryzacji** — działa kilka chwil.
6. **Brak chłodzenia mocy** — TIP31C bez radiatora przy 1 A = dym.
