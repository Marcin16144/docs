# System hybrydowy

System hybrydowy łączy PV, magazyn i sieć — działa „częściowo z sieci", maksymalizując autokonsumpcję i zapewniając zasilanie awaryjne. Sercem układu jest inwerter hybrydowy.

## Inwerter hybrydowy

Jedno urządzenie integrujące wszystkie strony systemu:

- **wejścia PV** — zwykle 2–4 niezależne trackery MPPT (osobne stringi paneli, np. dach wschód i zachód),
- **wejście sieci (AC grid)** — połączenie z instalacją domową i siecią,
- **port magazynu** — przyłącze akumulatora (DC, najczęściej 48 V lub wysokonapięciowy w nowych modelach),
- **wyjście backup (EPS / UPS)** — wydzielone wyjście zasilane przy zaniku sieci.

Inwerter zarządza przepływem energii między tymi portami zgodnie z wybranym trybem pracy.

## Tryby pracy

| Tryb | Działanie | Kiedy stosować |
|---|---|---|
| Priorytet autokonsumpcji (self-use) | nadwyżka PV → dom, potem → magazyn, dopiero potem → sieć | domyślny, przy rozliczeniu net-billing |
| Priorytet ładowania magazynu | magazyn ładowany w pierwszej kolejności, dom z sieci | gdy zależy na pełnym magazynie przed wieczorem |
| Tryb backup (rezerwa) | magazyn utrzymywany naładowany jako rezerwa na zanik sieci | tam, gdzie częste awarie sieci |
| Tryb ekonomiczny | magazyn doładowywany z sieci w taniej taryfie (np. G12 nocą) | przy taryfie strefowej, energia tania nocą |

**Priorytet autokonsumpcji** — najczęstszy: dom zużywa najpierw własną energię z PV, nadwyżkę kieruje do magazynu, a dopiero realne nadwyżki oddaje do sieci. Minimalizuje pobór z sieci i sprzedaż taniej energii.

**Tryb ekonomiczny** wykorzystuje różnicę cen w taryfie strefowej — magazyn ładowany jest energią z sieci w godzinach taniej taryfy i rozładowywany w drogiej.

## Funkcja EPS / backup

EPS (Emergency Power Supply) to wydzielone gniazda lub obwody zasilane z magazynu i PV, gdy zniknie napięcie sieci.

- **Czas przełączania** decyduje o klasie funkcji:
  - **< 20 ms** — praca jak UPS, odbiorniki (komputer, router, kocioł CO) nie zauważają przerwy,
  - **do kilku sekund** — tańsze rozwiązanie, akceptowalne dla oświetlenia i lodówki, ale zresetuje komputer.
- Moc wyjścia backup jest zwykle niższa od mocy w pracy normalnej — backup zasila tylko obwody krytyczne, nie cały dom.
- W trybie wyspowym inwerter sam tworzy napięcie 230 V (jest źródłem napięcia, nie tylko prądu).

## Zarządzanie energią (EMS)

EMS (Energy Management System) to logika sterująca przepływem energii. Decyduje w czasie rzeczywistym:

- ile energii z PV idzie do domu, magazynu i sieci,
- kiedy ładować magazyn z sieci (taryfa, prognoza pogody),
- jak utrzymać rezerwę na backup.

Nowoczesne EMS korzystają z prognoz pogody i profilu zużycia, aby optymalizować rozdział energii.

## Ograniczenie oddawania do sieci (export limit)

Gdy umowa z operatorem przewiduje **zerowy eksport** (zakaz oddawania energii) lub limit mocy, inwerter musi ograniczyć wprowadzanie energii do sieci.

- Funkcja **export limit** mierzy przepływ w punkcie przyłączenia (przekładniki CT — sekcja 17-05) i zmniejsza moc oddawaną do zera lub do ustalonego progu.
- Nadwyżka, której nie wolno oddać, kierowana jest do magazynu lub — gdy magazyn pełny — moc PV jest redukowana (curtailment).

## Współpraca z agregatem

Większość inwerterów hybrydowych ma wejście AC pozwalające podłączyć agregat zamiast lub obok sieci. W razie długiej awarii sieci agregat doładowuje magazyn i zasila odbiorniki backup — łącząc zalety hybrydy i off-grid.

> **Wskazówka.** Wybierając inwerter hybrydowy, sprawdź: liczbę trackerów MPPT, moc i czas przełączania wyjścia backup, obsługę export limit oraz zgodność z planowanym typem magazynu (napięcie, protokół komunikacji BMS).

## Co dalej

➡ [Integracja z instalacją domu](17-05-integracja-instalacja.md)
