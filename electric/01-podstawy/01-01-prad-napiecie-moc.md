# Prąd, napięcie, moc, opór

## Cztery podstawowe wielkości elektryczne

| Wielkość | Symbol | Jednostka | Co opisuje |
|---|---|---|---|
| **Napięcie** | U (lub V) | wolt [V] | różnica potencjałów — „ciśnienie elektryczne" |
| **Prąd** | I | amper [A] | przepływ ładunku w jednostce czasu |
| **Opór (rezystancja)** | R | om [Ω] | utrudnienie przepływu prądu |
| **Moc** | P | wat [W] | tempo przekazywania energii |

## Intuicja hydrauliczna

Najprostsza analogia — instalacja wodna w domu:

| Elektryka | Hydraulika |
|---|---|
| Napięcie (U) | ciśnienie wody w rurze |
| Prąd (I) | przepływ wody przez rurę |
| Opór (R) | zwężenie rury, zawór |
| Moc (P) | energia oddana w czasie (np. moc strumienia w turbinie) |

Wyższe ciśnienie = wyższy prąd przy tym samym oporze. Mniejsza średnica rury (większy opór) = mniejszy prąd przy tym samym ciśnieniu.

## Napięcie U [V]

Napięcie elektryczne to różnica potencjałów między dwoma punktami obwodu. Mierzymy je woltomierzem **równolegle** do badanego elementu.

Spotykane wartości w domu:

- **230 V AC, 50 Hz** — sieć jednofazowa (między L a N)
- **400 V AC, 50 Hz** — sieć trójfazowa (między dwiema fazami)
- **12 V / 24 V DC** — oświetlenie LED niskonapięciowe, dzwonki
- **5 V DC** — USB, ładowarki
- **±2 kV ÷ ±20 kV** — przepięcia atmosferyczne na zaciskach domu (po zadziałaniu SPD redukcja do ~1,5 kV)

## Prąd I [A]

Prąd to uporządkowany ruch ładunków elektrycznych. Mierzymy amperomierzem **szeregowo** w obwodzie.

Typowe prądy w gospodarstwie domowym:

| Urządzenie | Prąd ~ |
|---|---|
| Żarówka LED 10 W | 0,04 A |
| Lodówka A++ | 0,4 A |
| Telewizor 55" | 0,5 A |
| Pralka (grzanie) | 9 A |
| Bojler 2 kW | 9 A |
| Płyta indukcyjna (jedno pole) | 8 A |
| Płyta indukcyjna max (3-faz) | 25 A na fazę |
| Ładowarka EV (3-faz, 11 kW) | 16 A na fazę |
| Czajnik 2 kW | 9 A |

## Opór R [Ω]

Opór charakteryzuje materiał i jego geometrię:

```
R = ρ · L / S
```

- **ρ** (rho) — rezystywność materiału [Ω·mm²/m]
- **L** — długość [m]
- **S** — przekrój [mm²]

Rezystywność typowych materiałów (w 20 °C):

| Materiał | ρ [Ω·mm²/m] |
|---|---|
| Srebro | 0,016 |
| Miedź | **0,0178** |
| Złoto | 0,022 |
| Aluminium | **0,028** |
| Żelazo | 0,098 |
| Konstantan | 0,5 |
| Węgiel | ~40 |
| Guma, szkło, suche drewno | >10⁹ (izolatory) |

**Przykład:** opór 30 m przewodu Cu o przekroju 1,5 mm²:

```
R = 0,0178 · 30 / 1,5 = 0,356 Ω
```

Przy prądzie 10 A spadek napięcia 2·R·I = 7,12 V → dlatego do gniazd używamy 2,5 mm².

## Moc P [W]

Moc to energia elektryczna oddawana w jednostce czasu:

```
P = U · I       (prąd stały i czysto rezystancyjne AC)
P = U · I · cos φ   (prąd przemienny z indukcją/pojemnością)
```

Pochodne wzory (przy obciążeniu rezystancyjnym):

```
P = U² / R
P = I² · R
```

### Skala mocy

- **1 W** — żarówka LED zegarka, dioda
- **10 W** — żarówka LED do pokoju
- **60 W** — laptop
- **300 W** — PC do gier
- **1 000 W = 1 kW** — średnio mocna suszarka
- **2 000 W** — czajnik, bojler, grzejnik
- **7 000 W = 7 kW** — typowy przydział mocy mieszkania (1-faz)
- **14 000 W = 14 kW** — przydział mocy domu (3-faz, 20 A)
- **22 000 W = 22 kW** — duży dom z PV i pompą ciepła

## Praca elektryczna W i rachunek za prąd

Praca (energia) to moc razy czas:

```
W = P · t      [Wh, kWh]
1 kWh = 3 600 000 J
```

**Przykład rachunku.** Czajnik 2 kW włączony 5 minut:

```
W = 2 · (5/60) = 0,167 kWh
Koszt przy 0,80 zł/kWh ≈ 13 gr
```

## Cztery najważniejsze wzory do zapamiętania

```
U = I · R              ← prawo Ohma
P = U · I              ← moc w obwodzie DC
W = P · t              ← energia w czasie
P = U² / R = I² · R    ← moc na rezystancji
```

## Konwersja prąd ⟷ moc dla typowej sieci 230 V

| Moc | Prąd przy 230 V (cos φ=1) |
|---|---|
| 500 W | 2,2 A |
| 1 kW | 4,3 A |
| 2 kW | 8,7 A |
| 3 kW | 13 A |
| 3,68 kW | **16 A** — limit gniazdka jednofazowego |
| 5 kW | 22 A |
| 7,36 kW | 32 A |
| 11 kW (3-faz) | 16 A na fazę |
| 22 kW (3-faz) | 32 A na fazę |

Powyżej ~3,7 kW (16 A na fazę) — wymagany obwód dedykowany lub przejście na 3-fazowy.

## Co dalej

➡ [Prawo Ohma — zastosowania praktyczne](01-02-prawo-ohma.md)
