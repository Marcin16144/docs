# Pomiar rezystancji uziemienia (Rz)

## Powiązanie z 09-02

Pełna teoria oraz dopuszczalne wartości Rz są w **[09-02 Pomiar rezystancji uziemienia](../09-uziemienie/09-02-pomiar-rezystancji.md)**. Tutaj — **strona pomiarowa od strony protokołu odbiorowego**: trzy metody, kiedy która, jak interpretować.

## Trzy metody pomiaru

| Metoda | Mernik | Dokładność | Wymaga sond? | Zastosowanie |
|---|---|---|---|---|
| **4-pin Wennera** | MRU-105/200 | najlepsza | tak (4 sondy) | rezystywność gruntu ρ, projekt uziomu |
| **3-pin spadek napięcia 62%** | MRU-105/120 | dobra | tak (2 sondy) | standardowy pomiar gotowego uziomu |
| **Cęgi pętlowe / iClamp** | MRU-120/200, Fluke 1630 | wystarczająca | NIE | szybki pomiar w TN bez odłączania |

## Metoda 1 — 4-pinowa (Wenner)

Stosujemy do pomiaru **rezystywności gruntu ρ [Ω·m]** — niezbędna przy **projektowaniu uziomu**.

```
[C1] ─── a ─── [P1] ─── a ─── [P2] ─── a ─── [C2]

ρ = 2π · a · R
```

- 4 sondy w jednej linii z równymi odstępami **a** (2 m, 4 m, 8 m, 16 m — dla różnych głębokości),
- prąd pomiarowy między C1 i C2, napięcie między P1 i P2,
- mernik liczy R, dalej ρ wg wzoru.

Wynikiem jest **wykres ρ(a)** — pokazuje strukturę warstw gruntu.

## Metoda 2 — 3-pinowa (62%)

**Standardowa metoda pomiaru istniejącego uziomu** w odbiorze instalacji.

```
[Uziom E] ─── 15,5 m ─── [P] ─── 9,5 m ─── [H]
                                          (sonda prądowa)
            (sonda potencjałowa, 62% od E do H)
```

- sonda prądowa H w odległości **min. 25–30 m** od uziomu,
- sonda potencjałowa P na **62% odległości E→H**,
- mernik wymusza prąd I (E→H), mierzy U (E→P),
- **Rz = U / I**.

**Kontrola błędu metody:** przesuń P o ±2 m. Różnice powinny być < 5%. Jeśli więcej — H za blisko, oddal.

### Procedura krok po kroku

1. **Odłącz uziom od instalacji** (rozkręć zacisk w studzience lub na ścianie).
2. **Rozłóż przewody pomiarowe**:
   - czerwony 5–10 m (do badanego uziomu),
   - żółty 15,5 m (do sondy P),
   - zielony/niebieski 25 m (do sondy H),
   - sondy w jednej linii, najlepiej **prostopadle do osi uziomu**, w odległości od konstrukcji metalowych.
3. **Wbij sondy** na min. 30 cm głębokości, polej wodą jeśli grunt suchy.
4. **Podłącz mernik** zgodnie z opisem na obudowie (E / P / H lub rE / P / H).
5. **Sprawdź napięcie zakłócające** (mernik zwykle pokazuje przed pomiarem) — powinno być < 10 V, optymalnie < 3 V.
6. **Wykonaj pomiar** — odczyt Rz [Ω].
7. **Przesuń P o ±2 m** — pomiar kontrolny.
8. **Zapisz wynik** + warunki: pogoda, wilgotność gruntu, odległości sond.
9. **Podłącz uziom z powrotem** do instalacji.

## Metoda 3 — cęgi (iClamp)

**Szybka metoda bez odłączania** uziomu — kiedy mamy układ z **pętlą zerową** (TN z połączeniem do PEN, multi-grounded).

Mernik MRU-120/200 lub Fluke 1630 ma **dwie cęgi**:

- jedna wymusza napięcie indukowane,
- druga mierzy prąd w pętli.

```
Rz = U / I
```

**Ograniczenie:** mierzy uziom w obecności równoległej pętli. Dla pojedynczego uziomu domu w TT — metoda **niemożliwa** (brak pętli zwarcia).

Stosowane w:

- stacjach trafo z wieloma uziomami,
- liniach napowietrznych z multi-grounding,
- LPS z kilkoma przewodami odprowadzającymi (mierzymy poszczególne pretręby).

## Mierniki — typowe modele

| Model | Producent | Metody | Cena |
|---|---|---|---|
| **MRU-105** | Sonel | 3-pin, 4-pin Wenner | ~3500 zł |
| **MRU-120** | Sonel | + cęgi | ~5500 zł |
| **MRU-200** | Sonel | + Bluetooth, pamięć | ~7000 zł |
| **Fluke 1625-2** | Fluke | wszystkie metody, IP56 | ~10 000 zł |
| **Fluke 1630-2 FC** | Fluke | cęgi z FC | ~6000 zł |
| **Kyoritsu 4140A** | Kyoritsu | 3-pin podstawowy | ~2500 zł |

**Wzorcowanie**: co 13 miesięcy w akredytowanym laboratorium.

## Dopuszczalne wartości

| Zastosowanie | Maks. Rz |
|---|---|
| Układ TT (domowy z RCD 30 mA) | **<30 Ω** (praktyka <10 Ω) |
| LPS — instalacja odgromowa | **<10 Ω** |
| Centralka p.poż | <10 Ω |
| Stacja transformatorowa | <5 Ω |

## Korekcja sezonowa

Rezystancja uziomu silnie zależy od wilgotności i temperatury gruntu:

| Pora roku | Mnożnik wartości suchej (latem) |
|---|---|
| Lato (suche) | ×1,0 |
| Wiosna / jesień (wilgotna) | ×0,7–0,9 |
| Zima (zamarznięty grunt) | **×3–5** |
| Po pomiarze w deszczowy dzień | mnoż przez ×1,5 do oceny |

**Najlepsza pora pomiaru:** **lato suche** (warunek najgorszy w cyklu rocznym) lub **jesień** (warunki średnie).

## Pomiar napięcia zakłócającego

Przed pomiarem mernik mierzy **napięcie zewnętrzne** na sondach:

| U_zakł | Działanie |
|---|---|
| < 3 V | OK, pomiar dokładny |
| 3 – 10 V | dopuszczalne, niektóre mierniki kompensują |
| > 10 V | **NIE mierz** — wynik nieważny |

Przyczyny wysokiego U_zakł:

- prądy błądzące w gruncie (linie 110/220 kV w pobliżu),
- elektrolitka w gruncie (rolnictwo),
- pomiar zbyt blisko stacji trafo.

Rozwiązanie: przesuń sondy, mierz w innej porze dnia (mniejsze obciążenie sieci).

## Najczęstsze błędy

| Błąd | Skutek |
|---|---|
| Nie odłączono uziomu od instalacji | mierzymy „uziom + cała pętla sieci" — wynik zaniżony |
| Sondy za blisko uziomu | zakres pomiarowy w „strefie wpływu" uziomu — wynik niedokładny |
| Sondy w jednej linii z uziomem | trzeba prostopadle lub min. 90° od osi uziomu |
| Sondy w bardzo suchym piasku | wysokie R sondy, mernik nie wymusi prądu — polej wodą |
| Mernik źle skalibrowany | wynik fałszywy o stały błąd — wzorcuj co 13 mies. |

## Przykład — protokół

```
Mernik: Sonel MRU-105, S/N 56789, kal. 2024-09
Metoda: 3-pin (62%)
Pogoda: 18 °C, słonecznie, grunt suchy
Lokalizacja: dom jednorodzinny, uziom otokowy FeZn 30×4

Konfiguracja:
  uziom E: studzienka kontrolna SW od budynku
  sonda P: 15,5 m od E (prostopadle do ściany)
  sonda H: 25 m od E

Pomiary:
  Pomiar 1: Rz = 18,2 Ω
  Pomiar 2 (P +2 m): Rz = 17,9 Ω      (różnica 1,6%, <5% ✓)
  Pomiar 3 (P -2 m): Rz = 18,6 Ω      (różnica 2,2%, <5% ✓)

Wartość średnia: Rz = 18,2 Ω
Wymóg (TT z RCD 30 mA, bez LPS): < 30 Ω → OK ✓
```

## Co dalej

➡ [Ciągłość PE i połączeń wyrównawczych](11-05-ciaglosc.md)
