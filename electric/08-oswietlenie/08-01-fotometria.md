# Fotometria

Fotometria to dział nauki o pomiarach światła widzialnego (uwzględniający czułość oka). Bez znajomości czterech podstawowych wielkości — strumienia, natężenia, światłości i luminancji — projektowanie oświetlenia jest zgadywanką.

## Cztery podstawowe wielkości

| Wielkość | Symbol | Jednostka | Co opisuje |
|---|---|---|---|
| **Strumień świetlny** | Φ (fi) | lumen [lm] | całkowita „moc świetlna" emitowana przez źródło |
| **Natężenie oświetlenia** | E | luks [lx = lm/m²] | ile światła pada na powierzchnię |
| **Światłość** | I | kandela [cd] | ilość światła w danym kierunku (np. w stożku) |
| **Luminancja** | L | [cd/m²] | jasność powierzchni, jaką postrzega oko |

## Strumień świetlny Φ [lm]

To „ile światła w sumie" emituje źródło, niezależnie od kierunku. Wartość podawana na opakowaniu żarówki LED:

| Źródło | Strumień |
|---|---|
| Świeczka | 12 lm |
| Żarówka zwykła 40 W | 415 lm |
| Żarówka LED 6 W | 600 lm |
| Żarówka LED 10 W | 1000 lm |
| Żarówka LED 15 W | 1500 lm |
| Plafon kuchenny 30 W LED | 3000 lm |
| Latarnia uliczna 100 W LED | 12000 lm |
| Słońce w południe na powierzchnię 1 m² | ~100 000 lx (czyli 100 000 lm/m²) |

## Natężenie oświetlenia E [lx]

Najważniejsza wielkość dla projektanta — **ile lumenów pada na metr kwadratowy** powierzchni roboczej.

```
E = Φ / S    [lx = lm / m²]
```

Norma PN-EN 12464-1 podaje, jakie E powinno panować na blacie biurka, podłodze, lustrze itd. Mierzy się **luksomierzem** trzymanym poziomo na poziomie powierzchni roboczej.

Skala porównawcza:

| Sytuacja | Natężenie [lx] |
|---|---|
| Noc bezksiężycowa | 0,001 |
| Pełnia księżyca | 0,3 |
| Ulica nocą | 10-50 |
| Klatka schodowa | 100-150 |
| Pokój dzienny | 100-300 |
| Biuro | 500 |
| Sklep, stół do precyzyjnej pracy | 750-1000 |
| Sala operacyjna | 10 000 |
| Dzień pochmurny | 1 000 - 10 000 |
| Słoneczny dzień | 50 000 - 100 000 |

## Światłość I [cd]

Określa, ile światła idzie w **wybranym kierunku**. Ważna dla reflektorów, halogenów punktowych, samochodowych świateł. Wzór:

```
I = Φ / Ω    [cd = lm / steradian]
```

Ω = kąt bryłowy (steradian). Pełna kula = 4π sr ≈ 12,57 sr.

Żarówka „izotropowa" 1000 lm: I = 1000 / 12,57 ≈ 80 cd we wszystkie strony. Reflektor 30° z tym samym strumieniem da kilkaset cd w wybranym stożku (bo ten sam strumień jest skupiony w mniejszym kącie).

## Luminancja L [cd/m²]

Najbardziej „subiektywna" wielkość — to, **co widzi oko**. Określa jasność powierzchni, na którą patrzymy.

| Powierzchnia | Luminancja [cd/m²] |
|---|---|
| Niebo pochmurne | 1 000 - 5 000 |
| Niebo słoneczne | 8 000 |
| Słońce (tarcza) | ~1 600 000 000 |
| Świeca | ~7 500 |
| Ekran LCD typowo | 250-350 |
| Świetlówka biurowa (oprawa) | 2 000 - 5 000 |
| Białe biurko w dobrze oświetlonym biurze | 100-200 |

**Luminancja zależy od materiału (odbicia)**. Czarna powierzchnia mimo silnego oświetlenia ma niską luminancję. Stąd ciemne pomieszczenia mimo dużej liczby lamp wydają się „mroczne".

## Temperatura barwowa Tc [K]

Temperatura barwowa to **kolor światła**. Mierzy się ją w kelwinach. Niska temperatura = ciepłe światło (żółte/pomarańczowe), wysoka = zimne (niebieskawe, jak południowe słońce).

| Tc [K] | Wrażenie | Zastosowanie |
|---|---|---|
| 1 800 | świeca, ognisko | nastrojowo |
| **2 700 - 3 000** | „ciepła biel" | salon, sypialnia, restauracja |
| 3 500 - 4 000 | „neutralna biel" | kuchnia, łazienka, korytarz |
| 4 500 - 5 000 | biel dzienna | biuro, warsztat |
| **5 500 - 6 500** | „zimna biel" / dzienne | przemysł, sale operacyjne, sklepy elektroniczne |
| 7 000 - 10 000 | niebieskawe | rzadko stosowane |

Zasada: **w domu max 4000 K**. Powyżej tej wartości światło zaburza rytm dobowy (tłumi melatoninę).

## Wskaźnik oddawania barw CRI / Ra

CRI (Colour Rendering Index, też zwany Ra) opisuje, **jak wiernie źródło oddaje kolory** względem światła słonecznego (CRI = 100 jest ideałem).

| CRI / Ra | Ocena |
|---|---|
| < 70 | słaby — kolory wyglądają sztucznie (latarnia sodowa) |
| 70 - 79 | przeciętny |
| **80 - 89** | dobry — typowe LED w domu |
| **90 - 95** | bardzo dobry — sklepy odzieżowe, studio, łazienka (lustro) |
| 96 - 99 | excellent — fotografia, dermatologia |

**Praktyka:** w pokoju dziennym, kuchni i łazience celuj w **CRI ≥ 90**. Tanie LED-y z CRI 75 sprawiają, że jedzenie wygląda nieapetycznie, a skóra szaro.

## Skuteczność świetlna [lm/W]

Pokazuje, ile lumenów źródło wyciska z jednego wata mocy elektrycznej.

| Źródło | Skuteczność [lm/W] |
|---|---|
| Świeczka | 0,3 |
| Żarówka zwykła 60 W | 12 |
| Halogen 50 W | 18 |
| Świetlówka kompaktowa CFL | 50-65 |
| **LED dom (typowo)** | **80-110** |
| LED wysokiej jakości | 120-150 |
| LED przemysłowy (high-bay) | 160-200 |
| Lampa sodowa wysokoprężna | 100-150 |

Z roku na rok skuteczność LED rośnie ~5% — w 2025 r. „dobre" LED-y biurowe mają już 150 lm/W.

## Praktyczne porównanie

Klasyczna „żarówka 60 W" = strumień ~700 lm. By uzyskać taki strumień z LED:

- żarówka: **60 W**
- halogen: **40 W**
- LED: **6-7 W**

Oszczędność energetyczna LED vs żarówka = **~90%**.

## Co dalej

➡ [Dobór oświetlenia w pomieszczeniach](08-02-dobor-pomieszczen.md)
