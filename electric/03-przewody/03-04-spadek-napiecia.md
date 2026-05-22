# Spadek napięcia

## Skąd się bierze ΔU

Każdy przewód ma niezerowy opór R. Gdy płynie przez niego prąd I, na końcach przewodu napięcie maleje o:

```
ΔU = 2 · I · R    (1-faz, prąd wraca przez N)
ΔU = √3 · I · R   (3-faz, w układzie symetrycznym)
```

Stąd końcowy odbiornik dostaje nie 230 V, tylko 230 V minus straty na drodze.

## Wzory pełne

**Obwód 1-fazowy** (L + N, droga w obie strony = 2·L):

```
ΔU = 2 · L · I · cos φ · ρ / S
```

**Obwód 3-fazowy** (między fazami, symetryczne obciążenie):

```
ΔU = √3 · L · I · cos φ · ρ / S
```

Stałe:
- **ρ** (Cu) = 0,0178 Ω·mm²/m (w 20 °C) lub 0,0225 w 70 °C
- **ρ** (Al) = 0,028 Ω·mm²/m

Procent:

```
ΔU% = ΔU / Un · 100%
```

## Dopuszczalne wartości spadku napięcia

Norma PN-IEC 60364-5-52 (i polskie wytyczne PSE):

| Rodzaj instalacji / odbiornik | ΔU dopuszczalne |
|---|---|
| Oświetlenie wnętrz | **3 %** |
| Pozostałe odbiorniki (gniazda, AGD) | **5 %** |
| Pompy, klimatyzacja, sprężarki | **6,5 %** |
| Instalacje rozruchowe silników | dopuszczalne 10 % chwilowo |

Te wartości liczy się **od źródła zasilania (rozdzielnica licznikowa) do odbiornika końcowego**.

## Tabela spadku ΔU dla typowych obwodów Cu, 1-faz, 230 V

ΔU w woltach / w procencie dla kabla Cu, cos φ = 1, w jedną stronę L.

| L \ S | 1,5 mm² | 2,5 mm² | 4 mm² | 6 mm² |
|---|---|---|---|---|
| **10 m, 16 A** | 3,80 V / 1,65% | 2,28 V / 0,99% | 1,42 V / 0,62% | 0,95 V / 0,41% |
| **20 m, 16 A** | 7,60 V / 3,30% | 4,56 V / 1,98% | 2,85 V / 1,24% | 1,90 V / 0,83% |
| **30 m, 16 A** | 11,4 V / 4,96% | 6,84 V / 2,97% | 4,27 V / 1,86% | 2,85 V / 1,24% |
| **10 m, 20 A** | 4,75 V / 2,07% | 2,85 V / 1,24% | 1,78 V / 0,77% | 1,19 V / 0,52% |
| **20 m, 20 A** | 9,49 V / 4,13% | 5,70 V / 2,48% | 3,56 V / 1,55% | 2,37 V / 1,03% |
| **30 m, 20 A** | 14,2 V / 6,19% | 8,54 V / 3,71% | 5,34 V / 2,32% | 3,56 V / 1,55% |
| **30 m, 25 A** | 17,8 V / 7,74% | 10,7 V / 4,64% | 6,68 V / 2,90% | 4,45 V / 1,93% |
| **30 m, 32 A** | (zbyt cienki) | 13,7 V / 5,94% | 8,54 V / 3,71% | 5,70 V / 2,48% |

Widać wyraźnie:
- **1,5 mm²** dla gniazd > 20 m to już problem
- **30 m / 16 A / 1,5 mm²** ≈ 5 % — na granicy dla gniazd, dyskwalifikacja dla oświetlenia
- Dlatego do **dalekich obwodów** sięga się po 4 lub 6 mm²

## Wpływ ΔU na pracę odbiorników

### Silniki elektryczne
Moment silnika asynchronicznego jest proporcjonalny do **U²**. Spadek napięcia o 10 % → spadek momentu o 19 %. Silnik się przegrzewa i może nie wystartować pod obciążeniem.

### Oświetlenie LED
Większość LED ma stabilizator (driver), więc obniżenie napięcia do ~10 % nie wpływa na jasność. Ale przy ΔU > 10 % driver może przestać działać — LED migocze lub gaśnie.

### Oświetlenie żarowe (rzadziej)
Strumień świetlny ~ U³,⁴. Spadek o 5 % → spadek jasności o 16 %.

### Grzejniki, czajniki
Moc spadnie kwadratowo: P = U²/R. Spadek 5 % → spadek mocy 9,75 %. Bojler dłużej grzeje, ale nie ulega uszkodzeniu.

### Elektronika (komputery, ładowarki)
Zasilacze impulsowe z PFC zwykle pracują w zakresie 100-264 V — nawet znaczny ΔU nie szkodzi, ale zwiększa się pobór prądu.

## Przykład — obliczenie dla pompy ciepła

**Dane:** PC 3-fazowa o mocy 4 kW (Ib = 7 A na fazę), odległość od rozdzielnicy 35 m, kabel YKY 5×4.

```
ΔU = √3 · 35 · 7 · 1 · 0,0178 / 4
   = 1,732 · 35 · 7 · 0,00445
   = 1,89 V
ΔU% = 1,89 / 400 · 100% = 0,47%
```

Bardzo daleko od limitu 6,5 % — można nawet zejść z przekroju do 2,5 mm² (przy zachowaniu kryterium A: Iz dla 2,5 mm² = 19,5 A > 7 A ✓).

## Przykład — czemu LED migają na końcu długiego korytarza

**Sytuacja:** 50 m taśmy LED 12 V DC, 30 W/m, zasilacz 12 V w garażu.

Prąd przy końcu taśmy może spaść do 8-9 V, bo:
- prąd całkowity I = (50 · 30) / 12 = 125 A
- na 50 m miedzianej taśmy 1,5 mm² spadek byłby olbrzymi

**Rozwiązanie:** zasilanie z obu końców (lub co 5 m), albo użycie taśmy 24 V (mniejszy prąd przy tej samej mocy), albo lokalne zasilacze co kilka metrów.

## Wzór odwrotny — minimalny przekrój

Jeśli ustaliliśmy dopuszczalne ΔU%, możemy wyznaczyć min. S:

```
S_min = 2 · L · I · cos φ · ρ · 100 / (ΔU% · Un)      [1-faz]
S_min = √3 · L · I · cos φ · ρ · 100 / (ΔU% · Un)     [3-faz]
```

**Przykład:** 16 A, 30 m, Un = 230 V, ΔU% = 3 %, cos φ = 1:

```
S_min = 2 · 30 · 16 · 1 · 0,0178 · 100 / (3 · 230)
      = 1,710 / 690
      = 2,48 mm²
```

Więc minimum 2,5 mm² (najbliższy szereg).

## Co dalej

➡ [Obciążalność prądowa — sposoby instalacji i współczynniki](03-05-obciazalnosc.md)
