# 06-01: Budowa i zasada działania transformatora

## Czym jest transformator

Urządzenie elektromagnetyczne, które za pomocą indukcji elektromagnetycznej przekazuje energię z jednego obwodu do drugiego, **zmieniając napięcie i prąd** w określonym stosunku.

Transformator NIE działa na DC — wymaga prądu zmiennego lub pulsującego.

## Konstrukcja

Trzy podstawowe elementy:

1. **Rdzeń magnetyczny** — koncentruje pole magnetyczne (żelazo, ferryt)
2. **Uzwojenie pierwotne** (N₁) — podłączone do źródła
3. **Uzwojenie wtórne** (N₂) — odbiorca energii

Może być więcej uzwojeń wtórnych (multi-tap).

```
        ┌─────┐ rdzeń
        │     │
    ────┤UUUUU│─────
    we  │     │  wy
    ────┤UUUUU│─────
        │     │
        └─────┘
   pierwotne   wtórne
   N1 zwojów   N2 zwojów
```

## Zasada działania (krok po kroku)

1. **Napięcie AC na pierwotnym** powoduje przepływ prądu magnesującego I_μ.
2. Prąd wytwarza **zmienne pole magnetyczne** Φ w rdzeniu.
3. Pole przenika **uzwojenie wtórne**.
4. Zmienne pole indukuje **napięcie indukowane** w wtórnym (prawo Faradaya).
5. Po podłączeniu obciążenia płynie prąd I₂, który wytwarza pole przeciwne (prawo Lenza).
6. Pole z pierwotnego się zwiększa, aby kompensować — pobierany jest większy prąd I₁.

W efekcie energia "przepływa" z pierwotnego do wtórnego, **bez bezpośredniego połączenia elektrycznego** (galwaniczna separacja).

## Prawo Faradaya

Napięcie indukowane w uzwojeniu:

```
U = N · dΦ/dt
```

Dla sinusoidalnego pola: U_RMS = 4,44 · f · N · Φ_m = 4,44 · f · N · B_max · S

Gdzie:
- f — częstotliwość [Hz]
- N — liczba zwojów
- Φ_m = B_max · S — strumień maksymalny [Wb]
- B_max — maksymalna indukcja magnetyczna [T]
- S — przekrój rdzenia [m²]

**To kluczowy wzór** — z niego wynika ilość zwojów potrzebnych przy danym rdzeniu.

### Przykład: zwoje na wolt

Dla 50 Hz i typowego rdzenia (B_max = 1,2 T):

```
U/N = 4,44 · 50 · 1,2 · S = 266 · S    [V/zwój, jeśli S w m²]
```

Dla S = 4 cm² = 4·10⁻⁴ m²:
```
U/N ≈ 0,107 V/zwój
N/V ≈ 9,4 zwojów/V
```

Czyli dla 230 V pierwotne: ~2160 zwojów.

## Przekładnia transformatora

### Przekładnia napięciowa

```
U₁/U₂ = N₁/N₂ = n  (przekładnia)
```

Jeśli N₂ < N₁ → transformator obniżający.
Jeśli N₂ > N₁ → transformator podwyższający.

### Przekładnia prądowa

Z zachowania energii (transformator idealny):
```
U₁·I₁ = U₂·I₂
I₂/I₁ = N₁/N₂ = n
```

Czyli **prądy w odwrotnej proporcji** do napięć.

### Przykład

Transformator 230 V / 12 V, obciążenie 12 V × 5 A = 60 W:
```
n = 230/12 ≈ 19,2
I₁ = I₂/n = 5/19,2 ≈ 0,26 A  (po stronie pierwotnej)
```

W praktyce I₁ jest większy (ok. 0,30-0,35 A) ze względu na straty.

### Przekładnia impedancji

```
Z₁/Z₂ = (N₁/N₂)² = n²
```

Impedancja widziana z pierwotnego jest **n² razy większa** niż obciążenie po wtórnym. Stąd transformatory dopasowujące w audio (np. lampowy wzmacniacz 5 kΩ → 8 Ω wymaga n=√(5000/8)=25).

## Transformator idealny

W idealizacji:
- Brak strat
- Sprzężenie magnetyczne 100%
- Brak indukcyjności rozproszenia
- μ_rdzenia = ∞
- Bez nasycenia

W rzeczywistości:
- Sprawność 80-99% zależnie od mocy
- Sprzężenie 95-99%
- Indukcyjność rozproszenia (sygnały HF źle przechodzą)
- μ skończone, rdzeń się nasyca

## Model zastępczy

Realny transformator można modelować jako:

```
   pierwotne                wtórne
   R₁ (rezyst. drutu)  R₂'
   ─┤└─wwwwwww─┬─wwwwwww─┤└─
                │
                ●─ Z_m (impedancja magnesowania)
                │  (R_Fe // X_μ)
                │
               GND
```

- R₁, R₂ — rezystancje drutu (straty miedziane I²R)
- X_σ — indukcyjność rozproszenia
- R_Fe — straty w rdzeniu (histereza + wiroprądy)
- X_μ — indukcyjność magnesowania (prąd jałowy)

## Sprawność transformatora

```
η = P_wy / P_we = P_wy / (P_wy + P_strat)
```

Straty:
- **Miedziane** P_Cu = I²·R (rosną z kwadratem prądu obciążenia)
- **Żelaza** P_Fe = stałe, zależne od B_max i f

```
P_strat = P_Cu + P_Fe
```

Maksymalna sprawność jest osiągana gdy P_Cu = P_Fe. Stąd:
- Małe transformatory: max η przy 50-70% obciążenia
- Duże transformatory: max η przy 80-90% obciążenia

### Typowe sprawności

| Moc | Sprawność |
|-----|-----------|
| 1 VA | 50-65% |
| 10 VA | 70-80% |
| 100 VA | 85-90% |
| 1 kVA | 93-95% |
| 10 kVA | 97% |
| MVA | 99% |

## Prąd jałowy (I₀)

Prąd pobierany przy braku obciążenia. Składa się z:
- Prądu magnesującego (reaktywny, magnesujący rdzeń)
- Prądu strat w żelazie (czynny, grzeje rdzeń)

Typowo I₀ = 5-15% prądu znamionowego.

## Prąd zwarciowy

Z próby zwarcia (krótkie zwarcie wtórnego przy obniżonym U₁):

```
u_z = U_zwarcia / U_nominalne · 100%  [%]
```

u_z = 3-8% w typowych transformatorach sieciowych. Im niższe, tym lepsza regulacja napięcia, ale większy prąd zwarciowy (szczyt).

## Regulacja napięcia (load regulation)

Spadek napięcia na wtórnym przy obciążeniu:

```
ΔU = U_jałowo − U_obciąż
ε = ΔU / U_jałowo · 100%
```

Typowe ε = 5-15%. Stąd transformator 12 V "bez obciążenia" daje 13-14 V, pod znamionowym obciążeniem 12 V.

To trzeba uwzględnić projektując zasilacz!

## Typy transformatorów

### Sieciowe (50/60 Hz)

Standard. Rdzeń z blachy trafo (transformatorowej). Stosowane od głośników po duże stacje rozdzielcze.

### Impulsowe (HF)

Pracują 10 kHz – 2 MHz. Rdzeń ferrytowy. Małe, lekkie. Standard w SMPS.

### Wysokoczęstotliwościowe RF

10 MHz+. Małe rdzenie ferrytowe, czasem powietrzne. Anteny, balun, dopasowanie.

### Pomiarowe

Wysokiej dokładności do mierników. Transformatory napięciowe (VT) i prądowe (CT).

### Specjalne

- Spawalnicze (duży prąd zwarciowy, regulacja)
- Lampowe (audio, wyjściowe)
- Izolacyjne (1:1, separacja galwaniczna)

## Kierunek nawijania i fazy

Dwa uzwojenia mogą być **w fazie** lub **przesunięte o 180°** w zależności od kierunku nawijania. Oznaczamy kropkami na schemacie:

```
   ●──UUUU──        ●──UUUU──
              ║                ║
              ║                ║
   ●──UUUU──        ──UUUU──●
   w fazie           odwrócone
```

Kropki = początek uzwojenia. Sygnał na początku jednego = sygnał na początku drugiego (w fazie).

Ważne w:
- Łączeniu równoległym (źle = zwarcie)
- Sumowaniu (np. push-pull)
- Falownikach trójfazowych

## Tabliczka znamionowa

Na realnym transformatorze:

- **U₁, U₂** — napięcia nominalne
- **S** — moc pozorna [VA] (uwaga: NIE waty!)
- **f** — częstotliwość pracy
- **u_z** — napięcie zwarcia [%]
- **I_jał** — prąd jałowy
- **Klasa izolacji** (np. F = 155°C)
- **IP** — stopień ochrony

## Najprostszy schemat zasilacza

```
                        +V
                        │
   ~ 230V ─── prim ║ sek ─── mostek ─── filtr C ─── stab. ─── obciąż.
                   ║
   ~ N    ─── prim ║      
                   ║
                        │
                        GND
```

Transformator to "serce" zasilacza liniowego.

## Dlaczego transformator jest tak ważny

Bez transformatora:
- Nie byłoby przesyłu energii na duże odległości (HV → LV)
- Nie byłoby zasilaczy izolowanych
- Nie byłoby zasilaczy impulsowych (bo i tam pracuje transformator HF)
- Nie byłoby silników indukcyjnych (te same zasady)

To **jedno z najważniejszych** odkryć elektrotechniki XIX wieku.

## Historia

- **1831** — Michael Faraday odkrywa indukcję
- **1836** — Nicholas Callan buduje pierwszy "indukcyjny" transformator
- **1880-1890** — Westinghouse i Stanley komercjalizują transformator AC
- **1890** — "wojna prądów" (AC vs DC) wygrana przez AC, dzięki transformatorom
- **1950+** — pojawiają się ferryty → wysokie częstotliwości → SMPS
- **2000+** — amorficzne i nanokrystaliczne rdzenie do najwyższej sprawności

W kolejnych rozdziałach: jak różne rdzenie wpływają na konstrukcję, jak obliczać moc, jak samodzielnie nawijać transformator.
