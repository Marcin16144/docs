# Prawa Kirchhoffa

## Dwa prawa, na których stoi analiza obwodów

Gustav Kirchhoff w 1845 roku sformułował dwie reguły bilansowe, które obowiązują w każdym obwodzie elektrycznym — niezależnie od jego złożoności:

| Prawo | Czego dotyczy | Treść |
|---|---|---|
| **I prawo (KCL)** | węzła obwodu | suma prądów wpływających = suma prądów wypływających |
| **II prawo (KVL)** | oczka (pętli) | suma SEM = suma spadków napięć |

Razem z prawem Ohma wystarczają do rozwiązania dowolnej sieci liniowej DC.

## Pierwsze prawo Kirchhoffa — prawo węzła

W każdym węźle obwodu algebraiczna suma prądów jest równa zeru:

```
Σ I = 0
```

Prądy wpływające liczymy ze znakiem „+", wypływające ze znakiem „−" (lub odwrotnie — byle konsekwentnie).

**Przykład.** W węźle spotykają się trzy gałęzie: I₁ = 5 A wpływa, I₂ = 2 A wypływa. Jaki jest prąd w trzeciej gałęzi?

```
I₁ − I₂ − I₃ = 0
5 − 2 − I₃ = 0
I₃ = 3 A   (wypływa)
```

**Intuicja:** ładunek się nie gromadzi w przewodach — wszystko, co wpłynęło, musi wypłynąć.

## Drugie prawo Kirchhoffa — prawo oczka

W każdym zamkniętym oczku obwodu suma napięć źródłowych (SEM) równa się sumie spadków napięć na odbiornikach:

```
Σ E = Σ (I · R)
```

Innymi słowy: idąc dookoła pętli i wracając do punktu wyjścia, algebraiczna suma wszystkich napięć = 0.

**Przykład.** Obwód: bateria 12 V, dwa rezystory szeregowo R₁ = 100 Ω, R₂ = 200 Ω. Wszystkie napięcia liczymy w jednym kierunku obiegu:

```
12 − I·100 − I·200 = 0
I = 12 / 300 = 0,04 A = 40 mA
U_R1 = 4 V,  U_R2 = 8 V   (razem 12 V — bilans się zgadza)
```

## Obwód szeregowy

Łączenie elementów jeden za drugim — przez wszystkie płynie **ten sam prąd**, napięcia się sumują.

```
R_całk = R₁ + R₂ + R₃ + ...
U_całk = U₁ + U₂ + U₃ + ...
I = I₁ = I₂ = I₃ = ...
```

**Przykład.** Trzy rezystory 100 Ω, 200 Ω, 300 Ω połączone szeregowo, zasilane z 12 V:

```
R = 100 + 200 + 300 = 600 Ω
I = 12 / 600 = 0,02 A
U₁ = 2 V,  U₂ = 4 V,  U₃ = 6 V
```

## Obwód równoległy

Łączenie elementów „obok siebie" — wszystkie mają **to samo napięcie**, prądy się sumują.

```
1/R_całk = 1/R₁ + 1/R₂ + 1/R₃ + ...
I_całk = I₁ + I₂ + I₃ + ...
U = U₁ = U₂ = U₃ = ...
```

Dla **dwóch** rezystorów wzór skrócony:

```
R = (R₁ · R₂) / (R₁ + R₂)
```

Dla **n jednakowych** rezystorów R:

```
R_całk = R / n
```

**Przykład.** Dwa rezystory 100 Ω i 200 Ω równolegle:

```
R = (100 · 200) / (100 + 200) = 20 000 / 300 ≈ 66,7 Ω
```

Opór wypadkowy zawsze **mniejszy** od najmniejszego z rezystorów wchodzących w skład.

## Obwód mieszany

W praktyce większość obwodów to mieszanka połączeń. Analizujemy je krok po kroku — od „środka" do „zewnątrz":

1. Znajdź najmniejsze grupy połączeń czysto szeregowych lub czysto równoległych.
2. Zastąp je oporem zastępczym.
3. Powtarzaj, aż zostanie jeden opór.

**Przykład.** R₁ = 10 Ω szeregowo z parą (R₂ = 20 Ω || R₃ = 30 Ω):

```
R₂₃ = (20·30)/(20+30) = 12 Ω
R_całk = R₁ + R₂₃ = 10 + 12 = 22 Ω
```

## Dzielnik napięcia

Najczęściej wykorzystywany schemat — dwa rezystory szeregowo dzielą napięcie wejściowe proporcjonalnie do oporów:

```
U_wy = U_we · R₂ / (R₁ + R₂)
```

**Przykład.** U_we = 12 V, R₁ = 10 kΩ, R₂ = 5 kΩ:

```
U_wy = 12 · 5 / (10 + 5) = 4 V
```

Stosowany m.in. w:

- pomiarach napięcia w mikrokontrolerach (ADC 0-3,3 V z napięcia 0-12 V)
- regulatorach napięcia LDO i przetwornicach (ustawianie U_wy)
- czujnikach (termistor + rezystor odniesienia)

## Dzielnik prądu

Dwa rezystory równolegle dzielą prąd całkowity w stosunku **odwrotnym** do oporów (większy opór → mniejszy prąd):

```
I₁ = I · R₂ / (R₁ + R₂)
I₂ = I · R₁ / (R₁ + R₂)
```

**Przykład.** I = 1 A wpływa do węzła z dwiema gałęziami R₁ = 10 Ω, R₂ = 30 Ω:

```
I₁ = 1 · 30 / (10 + 30) = 0,75 A
I₂ = 1 · 10 / (10 + 30) = 0,25 A
```

## Praktyczny przykład domowy — gniazda na obwodzie

Trzy gniazda w salonie podłączone równolegle do jednej linii 230 V, zabezpieczenie B16. Z każdego pobieramy:

| Urządzenie | P [W] | I [A] |
|---|---|---|
| Telewizor | 150 | 0,65 |
| Konsola | 200 | 0,87 |
| Lampa LED 12 W | 12 | 0,05 |
| **Razem** | **362 W** | **1,57 A** |

Z I prawa Kirchhoffa: prąd w przewodzie wspólnym = suma prądów odbiorników = 1,57 A. To znacznie poniżej 16 A — wszystko OK.

## Bilans mocy

Z II prawa Kirchhoffa wynika bezpośrednio bilans mocy:

```
P_źródła = Σ P_odbiorników
```

Energia nie znika — całość mocy oddanej przez źródło zostaje rozproszona na odbiornikach (i ewentualnie stratach na przewodach).

## Co dalej

➡ [Prąd stały i przemienny — DC vs AC](01-04-ac-dc.md)
