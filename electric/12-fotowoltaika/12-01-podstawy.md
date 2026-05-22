# Podstawy fotowoltaiki

## Czym jest panel PV

Panel fotowoltaiczny (PV — *photovoltaic*) zamienia energię promieniowania słonecznego w energię elektryczną prądu stałego (DC) na zasadzie zjawiska fotowoltaicznego w półprzewodniku krzemowym.

Pojedyncze ogniwo daje ~0,5 V. Panel składa się z 60-72 (lub 120-144 połówkowych) ogniw szeregowo → ~30-45 V w punkcie pracy.

## Rodzaje paneli

| Technologia | Sprawność | Cechy | Status |
|---|---|---|---|
| **Monokrystaliczny (mono)** | 20-22 % | jednolicie czarne, lepsze przy słabym świetle, długa żywotność | dominują rynek |
| **Polikrystaliczny (poli)** | 16-18 % | charakterystyczny niebieski, tańsze, gorsze przy rozproszonym świetle | wycofywane |
| **Cienkowarstwowe CIGS / CdTe** | 10-14 % | elastyczne, lekkie, dobrze radzą sobie w cieniu i wysokich temperaturach | nisza, przemysł |

W domach jednorodzinnych dziś praktycznie wyłącznie **mono PERC / TOPCon / HJT** — sprawność 21-22 %, moc panela 400-450 Wp przy wymiarze ~1,75 × 1,1 m.

## Moc Wp i warunki STC

**Wp** (*watt peak*) — moc szczytowa panela w warunkach **STC** (*Standard Test Conditions*):

- nasłonecznienie 1000 W/m²
- temperatura ogniwa 25 °C
- AM1,5 (*Air Mass* — widmo światła po przejściu przez atmosferę)

**kWp** = 1000 Wp = jednostka mocy całej instalacji.

W rzeczywistości panel rzadko osiąga moc STC — częściej mierzymy przez **NOCT** (*Nominal Operating Cell Temperature*) — ok. 45 °C przy 800 W/m² i 20 °C otoczenia.

## Krzywa I-V i MPP

Charakterystyka prądowo-napięciowa panela:

```
   I [A]
   |
Isc|━━━━━━╲
   |       ╲
   |     MPP●
   |        ╲
   |         ╲
   +──────────● Voc → U [V]
```

- **Voc** — *open circuit voltage* — napięcie przy braku obciążenia (~45-50 V dla typowego panela)
- **Isc** — *short circuit current* — prąd zwarciowy (~11-14 A)
- **MPP** — *Maximum Power Point* — punkt maksymalnej mocy (Vmpp ~35-40 V, Impp ~10-12 A)

Inwerter z **MPPT** (śledzenie MPP) ciągle dopasowuje obciążenie tak, by panel pracował w MPP.

## Wpływ temperatury

Krzem ma ujemny współczynnik temperaturowy mocy: **-0,3 do -0,4 %/K** powyżej 25 °C.

Latem na czarnym dachu panel osiąga 60-70 °C — strata ~12-15 % mocy względem STC. Mróz natomiast zwiększa moc (panel zaśnieżony to inna historia — zacienienie).

## Sprawność roczna

Sprawność roczna w Polsce: **12-16 %** mocy STC w rocznej produkcji energii.

| Lokalizacja | Produkcja roczna |
|---|---|
| Niemcy / Polska północna | 900-980 kWh/kWp |
| Polska centralna | 1000-1050 kWh/kWp |
| Polska południowa | 1050-1150 kWh/kWp |
| Hiszpania | 1500-1700 kWh/kWp |

Reguła kciuka dla PL: **1 kWp ≈ 950-1100 kWh/rok**.

## Wpływ kąta i azymutu

Optymalnie: nachylenie **30-35°**, azymut **południe (S, 0°)**. Odchylenie:

| Odchylenie azymutu | Strata roczna |
|---|---|
| 0° (S) | 0 % |
| ±30° (SE/SW) | -2-4 % |
| ±45° | -5-8 % |
| ±90° (E/W) | -10-15 % |
| 180° (N) | -45 % |

## Zacienienie i bypass diody

Panele w stringu są połączone **szeregowo** — zacienienie jednego ogniwa ogranicza prąd całego stringu. Bez zabezpieczenia: zacieniony panel z prądem 0 A → cały string przestaje pracować.

Rozwiązanie:

- **Bypass diody** — wbudowane w panel (zwykle 3 sztuki na panel) — zwarcie zacienionej części, reszta panela pracuje dalej, ale ze stratą napięcia
- **Optymalizatory mocy** (Solaredge, Tigo) — każdy panel ma osobny moduł MPPT
- **Mikroinwertery** (Enphase, APsystems) — każdy panel ma swój inwerter AC

W praktyce: jeśli na dachu jest komin lub drzewo rzucające cień — warto rozważyć optymalizatory.

## Co dalej

➡ [Dobór mocy instalacji](12-02-dobor-mocy.md)
