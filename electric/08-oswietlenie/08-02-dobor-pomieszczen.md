# Dobór oświetlenia w pomieszczeniach

Norma **PN-EN 12464-1** („Światło i oświetlenie miejsc pracy") precyzuje minimalne natężenia oświetlenia dla różnych pomieszczeń i stanowisk. W domu nie ma obowiązku jej stosowania, ale wartości są dobrym punktem odniesienia.

## Tabela natężeń wg PN-EN 12464-1 (+ praktyka domowa)

| Pomieszczenie | Strefa ogólna [lx] | Strefa zadaniowa [lx] |
|---|---|---|
| Salon (pokój dzienny) | **100 - 200** | 300-500 (do czytania) |
| Sypialnia | 100 - 150 | 200 (lampka nocna) |
| Kuchnia (ogólne) | **300** | **500** (blat roboczy) |
| Łazienka (ogólne) | 200 - 300 | **500** (lustro) |
| Biuro / pracownia | **500** | 750 (precyzja) |
| Warsztat / garaż roboczy | 500 | **750 - 1000** (stół pracy) |
| Korytarz / przedpokój | **100** | — |
| Klatka schodowa | **150** | — |
| Garaż (parking) | 100 - 200 | — |
| Piwnica / strych | 100 | — |
| Pomieszczenie techniczne | 200 | 300 (przy rozdzielnicy) |
| Pralnia / suszarnia | 300 | — |
| Spiżarnia | 100 | — |
| Tarasy / wejście do domu | 50 - 100 | — |
| Ogród (alejki) | **5 - 20** | — |
| Ulica przed posesją | 10 - 50 | — |

**Strefa zadaniowa** to mniejszy obszar przy wykonywaniu konkretnej czynności (czytanie, krojenie, golenie). Tam doświetlamy dodatkowo (kinkiet, listwa LED nad blatem, lampka biurkowa).

## Wzór doboru strumienia

Podstawowy wzór projektowy:

```
ΣΦ = E · S · k / (η · MF)
```

| Symbol | Znaczenie | Typowa wartość |
|---|---|---|
| ΣΦ | sumaryczny strumień świetlny wszystkich opraw [lm] | wynik |
| E | wymagane natężenie [lx] | z tabeli |
| S | powierzchnia pomieszczenia [m²] | z rzutu |
| k | współczynnik zapasu utrzymania | **0,7 - 0,9** |
| η | sprawność oprawy | 0,5 - 0,9 |
| MF | współczynnik korekcyjny (np. wysokość) | 0,8 - 1,0 |

Współczynnik **k** uwzględnia spadek strumienia w czasie (kurz, starzenie LED). Po roku LED traci 5-15% strumienia.

## Przykład — salon 25 m²

Założenia:

- E = 200 lx (oświetlenie ogólne)
- S = 25 m²
- k = 0,8
- η · MF ≈ 1 (uproszczenie dla LED open)

Obliczenie:

```
ΣΦ = 200 · 25 · 0,8 / 1 = 4000 lm
```

Realizacja — kilka opcji:

| Opcja | Realizacja |
|---|---|
| A — plafon centralny | 1× LED 40 W (4000 lm), 3000 K, CRI 90 |
| B — 4 punkty | 4× LED 12 W (1000 lm każdy) = 4000 lm |
| C — strop LED + dodatki | strop podświetlany 2500 lm + 2 kinkiety 750 lm + lampa stojąca 750 lm |

Opcja C daje najbardziej elastyczne sterowanie scenami („pełna jasność" / „filmowa" / „rozmowa") — najbardziej zalecana w salonie.

## Przykład — kuchnia 12 m²

- E = 300 lx (ogólne)
- + dodatkowo 500 lx nad blatem

```
ΣΦ_ogólne = 300 · 12 · 0,8 = 2880 lm
```

→ 1 plafon LED 30 W (3000 lm) lub 4× downlighty 8 W (700 lm).

Dodatkowo nad blatem roboczym (długość ~2 m):

- listwa LED 60 cm × 12 W (1200 lm) → 600 lx na blat — bardzo dobre warunki krojenia

## Przykład — łazienka 6 m²

- E_ogólne = 200 lx
- E_lustro = 500 lx

```
ΣΦ_ogólne = 200 · 6 · 0,8 = 960 lm
```

→ 1 plafon LED 10 W (1000 lm), IP44, 4000 K, CRI 90.

Nad lustrem: 2 kinkiety LED IP44 7 W (~500 lm każdy) lub 1 oprawa pozioma 80 cm × 12 W.

## Przykład — biuro 10 m²

- E = 500 lx (norma)

```
ΣΦ = 500 · 10 · 0,8 = 4000 lm
```

→ panel sufitowy LED 30 cm × 60 cm × 40 W (3600 lm) + lampka biurkowa 7 W na biurko.

## Praktyczne zasady doboru

1. **Wybieraj jasność, nie watty** — zawsze patrz na lumeny na opakowaniu.
2. **Wielopoziomowe oświetlenie** — w pokoju dziennym min. 3 warstwy: górne, akcentowe (kinkiety/strop), nastrojowe (lampki).
3. **Ciepło niżej, zimno wyżej** — sypialnia 2700 K, kuchnia 3000-4000 K, garaż 4000-5000 K, biuro 4000 K.
4. **Lustro w łazience: CRI ≥ 90** — żeby kosmetyki i makijaż wyglądały realistycznie.
5. **Ściemniacze** — w salonie i sypialni; zmiana natężenia o połowę = mniejsze zużycie + komfort wieczorny.
6. **Liczba punktów ≥ S/4** — minimum 1 punkt świetlny na każde 4 m² powierzchni (równomierność).

## Pułapki

- **Sufity podwieszane** — dziurawienie ich co metr daje wprawdzie równomierne światło, ale liczba dziur > kreatywność.
- **Halogeny GU10 5,5 W** — dają tylko ~350 lm, do salonu trzeba 8-12 sztuk. LED MR16 wymaga radiatora.
- **Tanie LED z CRI 70** — w lustrze wyglądasz na trupa. **Nie kupuj.**
- **Migotanie (flicker)** — tanie LED z PWM < 200 Hz powodują zmęczenie oczu. Szukaj „flicker-free" w karcie produktu.

## Co dalej

➡ [Źródła światła](08-03-zrodla-swiatla.md)
