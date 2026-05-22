# Pomiar impedancji pętli zwarcia (Zs)

## Powiązanie z teorią

Pełna teoria pętli zwarcia, warunek samoczynnego wyłączenia oraz tabela maks. Zs są opisane w **[09-04 Pętla zwarcia](../09-uziemienie/09-04-petla-zwarcia.md)**. Tutaj — **strona pomiarowa**: jak, czym, gdzie i jak interpretować.

## Mernik MZC

Pomiar Zs wykonuje się dedykowanym **miernikiem impedancji pętli zwarcia (MZC)**.

| Model | Producent | Funkcje |
|---|---|---|
| **Sonel MZC-300** | Sonel | podstawowy, Zs L-PE, prąd 25 A |
| **Sonel MZC-320S** | Sonel | + Zs L-N, RCD bez zadziałania |
| **Sonel MZC-335** | Sonel | + duże prądy ~250 A, pomiar precyzyjny |
| **Kyoritsu 4140A** | Kyoritsu | wieloparametrowy MPI |
| **Megger LTW325** | Megger | „loop tester" z pamięcią |

Wszystkie nowoczesne mierniki MPI (Sonel MPI-540, MPI-530, MPI-525) **integrują pomiar Zs** w jednym urządzeniu.

## Jak działa mernik MZC

1. Mernik podłącza się do obwodu (L, N, PE) — czerpie napięcie z sieci 230 V.
2. Na ułamek sekundy **wymusza prąd 25 A** (lub 250 A w trybie wysokoprądowym) przez specjalną wewnętrzną rezystancję — symulując zwarcie.
3. Mierzy **spadek napięcia ΔU** podczas pomiaru.
4. Oblicza: **Zs = ΔU / I_pomiarowy**, przeliczone na rzeczywistą sieć.
5. Wyświetla **Zs [Ω]** oraz **Ik [A]** prawdopodobny prąd zwarciowy.

Pomiar trwa **30–100 ms** — wystarczająco krótko, by **nie wyłączyć RCD 30 mA** (większość MZC ma tryb „bez zadziałania RCD").

## Gdzie mierzyć

**Zasada: w najodleglejszym punkcie każdego obwodu.** Dlaczego?

- Zs rośnie z długością kabla (Zs ≈ Zs_rozdzielnicy + 2·R·L),
- najgorszy przypadek (najwyższe Zs) decyduje o przyjęciu.

| Obwód | Punkt pomiaru |
|---|---|
| Gniazda salonu | najdalsze gniazdo (najczęściej za TV) |
| Gniazda kuchni | najdalsze gniazdo (przy okapie) |
| Oświetlenie pokoju | ostatni punkt oświetleniowy (mostek pomocniczy w lampie) |
| Piekarnik / płyta | puszka przyłączeniowa |
| Łazienka | gniazdo w szafce / grzejnik elektryczny |
| Garaż | gniazda + oświetlenie osobno |
| Zewnętrzne | najdalsze gniazdo IP44 |

## Procedura pomiaru

1. **Włącz instalację pod napięcie** — Zs mierzy się w warunkach roboczych.
2. **Wstaw wtyk pomiarowy** w gniazdo (mernik z wtyczką schuko) lub podłącz krokodylki do puszki.
3. **Sprawdź sygnalizację mernika** — kontrolki napięcia (L-N OK, L-PE OK, polarność).
4. **Wybierz tryb**: Zs L-PE (dla TN-C-S), Zs L-N (dla pomiaru Zk obwodu).
5. **Naciśnij START** — pomiar trwa ułamek sekundy.
6. **Odczyt Zs** [Ω] i Ik [A].
7. **Porównaj** z tabelą Zs_max wg In i charakterystyki MCB.
8. **Wpisz w protokół**.

## Tryby pomiaru

| Tryb | Co mierzy | Zastosowanie |
|---|---|---|
| **Zs L-PE** | impedancja pętli L→PE | klasyczny pomiar po MCB+RCD |
| **Zs L-N** | impedancja Zk obwodu L→N | weryfikacja prądu zwarciowego między fazą a neutralnym |
| **Zs „bez zadziałania RCD"** | jak L-PE, ale prąd < 15 mA | nie wybije RCD 30 mA |
| **Zs „dużym prądem"** | ~250 A przez ok. 10 ms | bardzo dokładny pomiar (warianty MZC-335) |

## Korekcja 2/3

Mernik wykonuje pomiar przy **zimnym przewodzie** (temperatura otoczenia). Przy realnym zwarciu temperatura przewodu skacze do 70–90 °C, rezystancja Cu rośnie o ~20–30%.

Norma wymaga, by:

```
Zs_zmierzona ≤ (2/3) × Zs_max_tabela
```

| MCB | Zs_max tabela | Zs_max z korekcją 2/3 (zmierzona) |
|---|---|---|
| B10 | 4,57 Ω | **3,05 Ω** |
| B16 | 2,87 Ω | **1,91 Ω** |
| B20 | 2,30 Ω | **1,53 Ω** |
| C16 | 1,45 Ω | **0,97 Ω** |
| C20 | 1,15 Ω | **0,77 Ω** |
| C25 | 0,92 Ω | **0,61 Ω** |
| C32 | 0,72 Ω | **0,48 Ω** |

**Niektóre mierniki mają „auto-korekcję"** — pokazują od razu „Zs po korekcji". Sprawdź w instrukcji.

## Postępowanie przy Zs za dużym

1. **Zwiększ przekrój kabla** — z 1,5 → 2,5 mm² zmniejsza Zs o ~40%, z 2,5 → 4 mm² o kolejne 40%.
2. **Skróć obwód** — Zs ∝ długość.
3. **Zmień charakterystykę MCB** z C na B (B16 dopuszcza Zs do 2,87 Ω, C16 tylko 1,45 Ω).
4. **Polepsz uziemienie** (układ TT) — niższa Rz uziomu.
5. **Dodatkowe RCD 30 mA** — wybije w 30 ms nawet przy Zs = 100 Ω, ale to obejście — formalnie obwód nie spełnia warunku samoczynnego wyłączenia bez RCD.

## Najczęstsze błędy

| Błąd | Skutek |
|---|---|
| Pomiar przed RCD (bez aktywacji) | Zs prawidłowe, ale faktyczne wyższe (pominięto rezystancję RCD) |
| Pomiar w gnieździe blisko rozdzielnicy | nie wykrywa problemu w dalszych częściach obwodu |
| Brak korekcji 2/3 | błąd na granicy akceptacji |
| Pomiar przy luźnym zacisku | Zs wyższe (rezystancja styku) — zaciśnij i ponów |
| Brak sprawdzenia polaryzacji | mernik mierzy „L-PE", ale faktycznie L i PE są zamienione |

## Przykład — protokół pomiaru

```
Mernik: Sonel MZC-320S, S/N 12345, kal. 2024-03
Sieć: TN-C-S, 230 V / 50 Hz

Obwód        | MCB  | In | Char | Lokalizacja          | Zs zm. | Ik   | Zs_max kor. | Ocena
─────────────┼──────┼────┼──────┼──────────────────────┼────────┼──────┼─────────────┼──────
G1 kuchnia   | MCB  | 16 |  B   | gniazdo nad okapem   | 0,82 Ω | 280 A| 1,91 Ω      | OK
G2 salon     | MCB  | 16 |  B   | gniazdo TV           | 1,15 Ω | 200 A| 1,91 Ω      | OK
G3 pokój     | MCB  | 16 |  B   | gniazdo przy biurku  | 0,93 Ω | 247 A| 1,91 Ω      | OK
O1 oświetl.  | MCB  | 10 |  B   | ostatni punkt        | 1,42 Ω | 162 A| 3,05 Ω      | OK
Łaz gniazdo  | MCB  | 16 |  B   | gniazdo w szafce     | 0,78 Ω | 295 A| 1,91 Ω      | OK
Piekarnik    | MCB  | 16 |  C   | puszka               | 0,41 Ω | 561 A| 0,97 Ω      | OK
```

## Co dalej

➡ [Test wyłącznika RCD](11-03-test-rcd.md)
