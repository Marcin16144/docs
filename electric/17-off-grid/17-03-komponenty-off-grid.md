# Dobór komponentów off-grid

Mając gotowy bilans energetyczny (sekcja 17-02), dobieramy poszczególne urządzenia. System off-grid to łańcuch: panele → regulator ładowania → magazyn → inwerter → odbiorniki, plus agregat jako rezerwa.

## Panele PV

W off-grid panele projektuje się **z przewymiarowaniem** względem zapotrzebowania letniego — ma zostać zapas na ładowanie magazynu i straty. Liczy się też orientacja: dla pracy całorocznej korzystne jest stromsze ustawienie (60–70°), które poprawia uzysk zimowy kosztem letniego.

## Regulator ładowania — PWM kontra MPPT

Regulator pośredniczy między panelami a magazynem, sterując ładowaniem. Dwie technologie:

| Cecha | PWM | MPPT |
|---|---|---|
| Zasada działania | łączy panel z magazynem, „obcina" napięcie | śledzi punkt mocy maksymalnej, przetwarza napięcie |
| Sprawność wykorzystania PV | niższa | wyższa o **20–30 %** |
| Napięcie paneli vs magazyn | musi być zbliżone | panele mogą mieć wyższe napięcie |
| Cena | tani, prosty | droższy |
| Zastosowanie | małe systemy, identyczne napięcie | każdy poważniejszy system |

**PWM** (Pulse Width Modulation) sprawdza się w bardzo małych instalacjach, gdzie napięcie panelu jest dopasowane do napięcia magazynu. **MPPT** (Maximum Power Point Tracking) wyciąga z paneli maksymalną moc niezależnie od warunków — szczególnie zyskuje przy słabym świetle i niskich temperaturach, dlatego w off-grid PL jest praktycznie standardem.

## Magazyn energii

Współczesne systemy off-grid budowane są na ogniwach **LiFePO4** (litowo-żelazowo-fosforanowych): wysoka liczba cykli, duże DoD (0,8–0,9), stabilność termiczna. Szczegóły technologii magazynów — sekcja 18.

## Inwerter off-grid (wyspowy)

Inwerter wyspowy zamienia napięcie stałe magazynu na 230 V AC dla odbiorników. Wymagania:

- **czysta sinusoida** (pure sine wave) — konieczna dla silników, lodówek, zasilaczy impulsowych; tańsza sinusoida modyfikowana psuje pracę wielu urządzeń,
- **moc szczytowa ok. 2× moc ciągła** — silniki (pompy, sprężarki lodówek) przy rozruchu pobierają wielokrotność mocy nominalnej; inwerter musi udźwignąć ten chwilowy skok.

Moc ciągłą dobiera się do sumy mocy odbiorników mogących pracować jednocześnie, a moc szczytową — do prądu rozruchowego najtrudniejszego odbiornika.

## Inwerter ładujący (inverter-charger)

Rozszerzona wersja inwertera wyspowego z wbudowaną **funkcją ładowania magazynu z zewnętrznego źródła AC** — najczęściej z agregatu. Pozwala:

- automatycznie uruchomić ładowanie magazynu, gdy stan naładowania spadnie,
- przełączać zasilanie odbiorników między magazynem a agregatem,
- traktować agregat jako pełnoprawne źródło rezerwowe bez ręcznych przepięć.

To rozwiązanie zalecane wszędzie tam, gdzie w systemie przewidziano agregat.

## Agregat wspomagający

Agregat domyka bilans zimą i podczas długich okresów bez słońca. Dobór mocy — patrz sekcja 17-02. Ważne, by jego moc i jakość napięcia pozwalały na stabilne ładowanie magazynu przez inwerter-charger.

## Napięcie systemu DC

Strona stałoprądowa (panele, magazyn, regulator, wejście inwertera) pracuje przy jednym z napięć nominalnych: 12 V, 24 V lub 48 V. Im wyższe napięcie, tym mniejszy prąd przy tej samej mocy, a więc mniejsze straty i cieńsze przewody (P = U · I).

| Napięcie systemu DC | Zalecany zakres mocy | Uwagi |
|---|---|---|
| **12 V** | do ~1 kW | małe systemy, kempingi, prądy duże nawet przy małej mocy |
| **24 V** | ~1–3 kW | średnie domki, kompromis cena/straty |
| **48 V** | powyżej 3 kW | **zalecane** dla domów — najmniejsze prądy i straty, najszerszy wybór sprzętu |

> **Wskazówka.** Przy 12 V system 2 kW oznacza prąd ponad 160 A — wymaga grubych przewodów i generuje duże straty. Ten sam system na 48 V to ok. 40 A. Dlatego dla każdej poważniejszej instalacji wybiera się 48 V.

> **Uwaga.** Napięcie DC trzeba ustalić na początku projektu — determinuje ono dobór magazynu, regulatora i inwertera. Zmiana napięcia później oznacza wymianę większości komponentów.

## Co dalej

➡ [System hybrydowy](17-04-system-hybrydowy.md)
