# Dobór przekroju przewodu

## Trzy kryteria, które trzeba spełnić jednocześnie

Każdy przewód w instalacji musi spełniać **wszystkie trzy** warunki, bo każdy z nich opisuje inne zagrożenie.

| Kryterium | Co zabezpiecza | Norma |
|---|---|---|
| **A — obciążalność długotrwała** | przegrzanie izolacji pod normalnym obciążeniem | Iz ≥ Ib |
| **B — spadek napięcia** | poprawną pracę odbiorników | ΔU ≤ 3% / 5% / 6,5% |
| **C — wytrzymałość zwarciowa** | przewód przy zwarciu (zanim wyłączy bezpiecznik) | k²·S² ≥ I²·t |

Najczęściej decyduje kryterium **A** dla krótkich obwodów, **B** dla długich (powyżej ~25 m).

## Kryterium A — obciążalność długotrwała (Iz ≥ Ib)

Prąd dopuszczalny żyły **Iz** (czyli prąd, przy którym żyła osiągnie max dozwoloną temperaturę 70 °C dla PVC) musi być nie mniejszy niż prąd roboczy odbiornika **Ib**.

Dodatkowo dobiera się zabezpieczenie **In** w granicach:

```
Ib ≤ In ≤ Iz
```

In powinien być większy od Ib (żeby normalne obciążenie nie wybijało), ale mniejszy od Iz (żeby przy długim przeciążeniu bezpiecznik zadziałał, zanim spali się izolacja).

## Tabela szybkiego doboru — przewody Cu w PVC

| Przekrój | Iz (B1, 30 °C, miedź) | Typowy bezpiecznik | Typowy obwód |
|---|---|---|---|
| **1,5 mm²** | 14,5 A | **B10** (czasem B16) | oświetlenie 230 V, dzwonki |
| **2,5 mm²** | 19,5 A | **B16** lub C16 | gniazda 230 V, AGD |
| **4 mm²** | 26 A | **B20** / B25 | piec elektryczny, gniazda 16 A obciążone, AGD silne |
| **6 mm²** | 34 A | **B25** / B32 | ładowarka EV (1-faz 7,4 kW), kuchenka indukcyjna 3-faz |
| **10 mm²** | 46 A | **B40** | główny obwód mieszkania, podlicznik |
| **16 mm²** | 61 A | **B50 / B63** | wewnętrzna linia zasilająca (WLZ), przyłącze |
| **25 mm²** | 80 A | gG 80 A | przyłącze domu jednorodzinnego 3-faz |
| **35 mm²** | 99 A | gG 100 A | przyłącze z większą mocą |

**Uwaga:** wartości Iz odpowiadają sposobowi instalacji B1 (kabel w rurze w ścianie), temperaturze otoczenia 30 °C i braku zgrupowania. Dla innych warunków stosujemy współczynniki — patrz [Obciążalność prądowa](03-05-obciazalnosc.md).

## Kryterium B — spadek napięcia (ΔU)

Wzór 1-fazowy (między L a N):

```
ΔU [V] = 2 · L · I · cos φ · ρ / S
ΔU [%] = (ΔU / Un) · 100%
```

Wzór 3-fazowy (między fazami):

```
ΔU [V] = √3 · L · I · cos φ · ρ / S
```

Gdzie:
- **L** — długość przewodu [m]
- **I** — prąd obciążenia [A]
- **ρ** = 0,0178 Ω·mm²/m dla Cu, 0,028 dla Al
- **S** — przekrój żyły [mm²]
- **cos φ** ≈ 1 dla rezystancyjnych, 0,8 dla mieszanych
- **Un** = 230 V (1-faz) lub 400 V (3-faz)

Dopuszczalne ΔU:

| Odbiornik | Dopuszczalne ΔU |
|---|---|
| Oświetlenie | **3 %** |
| Pozostałe odbiorniki (gniazda, AGD) | **5 %** |
| Pompy, sprężarki, silniki ciężkie | **6,5 %** |

## Kryterium C — wytrzymałość zwarciowa

Przy zwarciu prąd rośnie tysiąckrotnie. Żyła musi to wytrzymać w krótkim czasie, zanim zadziała bezpiecznik:

```
S² · k² ≥ I_zw² · t
```

Gdzie **k** = 115 dla Cu w PVC, 143 dla Cu w XLPE, 76 dla Al w PVC. **t** — czas wyłączenia [s] (typowo 0,1-0,4 s dla MCB).

W praktyce, jeśli zabezpieczenie ma czas wyłączenia poniżej 0,4 s przy Ik na zaciskach odbiornika, a przewody są dobrane wg kryteriów A i B, to kryterium C jest spełnione automatycznie.

## Przykład — gniazdo 16 A w garażu, 20 m od rozdzielnicy

**Dane:** odbiornik docelowo 3 kW (Ib ≈ 13 A), bezpiecznik B16, długość 20 m, Un = 230 V, cos φ = 1.

**Krok 1 — kryterium A.** Przy B16 minimalny przekrój to 2,5 mm² (Iz = 19,5 A > In = 16 A ✓).

**Krok 2 — kryterium B.** Sprawdzamy spadek napięcia dla 2,5 mm²:

```
ΔU = 2 · 20 · 13 · 1 · 0,0178 / 2,5 = 3,70 V
ΔU% = 3,70 / 230 · 100% = 1,61%
```

1,61 % < 5 % ✓ — kryterium B spełnione.

**Krok 3 — koordynacja.** B16 + przewód 2,5 mm² Cu = standardowe dopasowanie, kryterium C spełnione.

**Decyzja:** YDYżo 3×2,5 mm², zabezpieczenie B16.

## Dlaczego 1,5 mm² do oświetlenia, 2,5 mm² do gniazd

Historycznie, ale też technicznie:

- **Oświetlenie** rzadko obciąża obwód — max kilka A. 1,5 mm²·B10 daje dużą rezerwę i taniej.
- **Gniazda** mogą być obciążone do 16 A jednocześnie (czajnik + suszarka + grzejnik). 2,5 mm²·B16 to limit gniazda.

Można położyć grubszy — nie wolno cieńszy.

## Przewody aluminiowe (Al)

W przyłączach do złącza energetycznego nadal popularne. Aluminium ma ρ = 0,028 (1,6× więcej niż Cu) — przekroje muszą być większe:

| Cu | Al ekwiwalentne |
|---|---|
| 4 mm² | 6 mm² |
| 6 mm² | 10 mm² |
| 10 mm² | 16 mm² |
| 16 mm² | 25 mm² |

Aluminium **nie powinno** być łączone z miedzią bez specjalnych zacisków (Al-Cu) — utlenia się w kontakcie, zwiększa opór.

## Co dalej

➡ [Spadek napięcia — wzory i przykłady](03-04-spadek-napiecia.md)
