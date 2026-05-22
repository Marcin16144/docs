# Uziemienie przy przełączeniu na zasilanie off-grid

Przy przejściu z sieci publicznej na zasilanie wyspowe (agregat, inwerter off-grid, tryb backup inwertera hybrydowego) zmienia się **punkt odniesienia uziemienia**. Niepoprawne uwzględnienie tego sprawia, że wyłączniki różnicowoprądowe (RCD) przestają chronić, a obudowy urządzeń mogą znaleźć się pod napięciem. Strona wyjaśnia, na czym polega problem i jak go rozwiązać.

## Na czym polega problem

W zasilaniu z sieci publicznej (układ TN-C-S — typowy w polskich domach) punkt neutralny jest **uziemiony po stronie dostawcy** — w stacji transformatorowej oraz na przyłączu. To uziemienie neutralnego daje:

- punkt odniesienia potencjału (przewód N ma potencjał ≈ 0 V względem ziemi),
- drogę powrotu prądu zwarciowego L-PE,
- warunek działania RCD i samoczynnego wyłączenia (patrz strona 09-04).

Gdy odłączysz dom od sieci i zasilisz go z **własnego źródła**, znika uziemienie neutralnego od strony dostawcy. Źródło wyspowe — agregat lub inwerter — zwykle ma **uzwojenie wyjściowe odizolowane od ziemi (układ IT)**. Wtedy:

```
Brak połączenia N-PE  →  punkt neutralny "pływa" względem ziemi
                      →  pierwsze zwarcie L-PE NIE domyka pętli
                      →  RCD nie zadziała, MCB nie zadziała
                      →  obudowa pod napięciem, a instalacja działa dalej
```

To stan pozornie bezpieczny (jedno zwarcie nie powoduje porażenia), ale w praktyce **groźny**: usterka jest niewidoczna, a **drugie zwarcie** na innej fazie tworzy zwarcie międzyfazowe przez przewody ochronne.

> **Sedno problemu:** RCD wykrywa różnicę prądów L i N. Aby prąd uszkodzeniowy popłynął do ziemi i wytworzył tę różnicę, układ musi mieć **jeden** punkt połączenia neutralnego z uziemieniem (N-PE). Sieć dostarcza go z zewnątrz; źródło wyspowe — nie. Trzeba go odtworzyć lokalnie.

## Zasada: dokładnie jeden punkt N-PE

W każdym momencie pracy instalacja musi mieć **dokładnie jedno** połączenie przewodu neutralnego z ochronnym (N-PE bond):

| Stan | Liczba połączeń N-PE | Skutek |
|---|---|---|
| Brak (układ "pływający") | 0 | RCD nie działa, niewidoczne zwarcia |
| **Poprawny** | **1** | RCD i SWZ działają prawidłowo |
| Podwójny (sieć + lokalny jednocześnie) | 2 | prądy błądzące w PE, fałszywe zadziałania RCD, przegrzewanie |

Z tego wynika reguła przełączania:

- **Zasilanie z sieci** → połączenie N-PE zapewnia sieć (na przyłączu). Lokalnego bondu **nie wolno** zwierać.
- **Zasilanie wyspowe** → sieć odłączona, więc trzeba **zewrzeć lokalny bond N-PE** przy źródle.
- **Przełączanie** musi zsynchronizować rozłączenie sieci z załączeniem lokalnego bondu — i odwrotnie.

## Rozwiązanie 1 — przełącznik z rozłączanym przewodem N (switched neutral)

Najczystsze rozwiązanie sprzętowe. Przełącznik sieć/źródło (ATS lub ręczny) rozłącza również przewód neutralny:

- 1-fazowo → przełącznik **2-biegunowy** (L + N),
- 3-fazowo → przełącznik **4-biegunowy** (L1, L2, L3 + N).

Dzięki temu w pozycji „źródło" neutralny instalacji jest odcięty od neutralnego sieci. Lokalny bond N-PE wykonuje się **przy źródle wyspowym** (w agregacie lub na wyjściu inwertera), a źródło ma własny uziom.

```
   Sieć  L,N ──┐
               │  przełącznik
               │  2-/4-biegunowy        Rozdzielnica
   Źródło L,N ─┤  (rozłącza też N) ──── domu (L,N,PE)
               │
   Bond N-PE ──┘  zwarte tylko po stronie źródła;
                  PE ciągłe, nie przełączane
```

Przewód **PE nigdy nie jest przełączany ani rozłączany** — pozostaje ciągły od uziomu przez całą instalację. Przełącza się tylko L i N.

## Rozwiązanie 2 — automatyczny bond N-PE w inwerterze (tryb wyspowy)

Większość inwerterów hybrydowych z funkcją backup (EPS) robi to automatycznie:

- gdy sieć jest obecna → inwerter **nie** zwiera N-PE (bond zapewnia sieć),
- gdy sieć zanika i inwerter przechodzi na pracę wyspową → wewnętrzny przekaźnik **zwiera N-PE** na wyjściu backup,
- gdy sieć wraca → przekaźnik rozwiera bond, zanim inwerter zsynchronizuje się z siecią.

To rozwiązanie wymaga, by:

- backup zasilał **wydzieloną rozdzielnicę** obwodów krytycznych (patrz strona 17-05),
- przewód N tej rozdzielnicy nie był połączony z N reszty instalacji w sposób tworzący drugi bond,
- inwerter był prawidłowo uziemiony, a obwody backup miały ciągłe PE.

Sprawdź w karcie katalogowej inwertera funkcję „neutral-earth relay" / „N-PE bonding in island mode" — nie wszystkie modele ją mają.

## Rozwiązanie 3 — agregat z neutralnym uziemianym lokalnie

Agregaty prądotwórcze występują w dwóch wykonaniach:

| Wykonanie | Opis | Wymaga |
|---|---|---|
| Floating neutral (neutralny pływający) | uzwojenie odizolowane od ramy | dodania lokalnego bondu N-PE i uziomu |
| Bonded neutral (neutralny zmostkowany) | N połączony z ramą w agregacie | tylko uziemienia ramy agregatu |

Przy zasilaniu całej instalacji domowej i stosowaniu przełącznika ze switched neutral wybiera się zwykle agregat z **bonded neutral** i wykonuje uziom roboczy agregatu. Gdy przełącznik **nie** rozłącza N — trzeba użyć agregatu z floating neutral, by nie powstał drugi bond. Dobór agregatu i przełącznika musi być spójny.

## Uziom lokalny — zawsze potrzebny

Niezależnie od rozwiązania, przy pracy wyspowej instalacja potrzebuje **własnego uziomu** (jeśli go nie ma — np. dotąd polegała tylko na PEN sieci):

- uziom otokowy lub pręty pionowe — patrz strona 09-01,
- rezystancja uziemienia dobrana tak, by przy lokalnym bondzie N-PE zadziałały zabezpieczenia; dla układu pracującego jak TT obowiązuje warunek `R_A · IΔn ≤ 50 V` (przy RCD 30 mA daje to teoretycznie nawet kΩ, ale praktycznie dąży się do **≤ 30 Ω**),
- uziom źródła (agregatu/inwertera) i uziom instalacji domowej powinny być **połączone** w jeden układ, by uniknąć różnicy potencjałów.

> **Ostrzeżenie:** nie wolno polegać wyłącznie na przewodzie PEN sieci jako uziemieniu, gdy planujesz pracę off-grid. Po odłączeniu sieci znika też to uziemienie. Wykonaj uziom lokalny przed pierwszym uruchomieniem wyspowym.

## Częste błędy

- **Przełącznik 1-biegunowy (tylko L)** przy źródle z bonded neutral i sieci TN-C-S → dwa bondy N-PE jednocześnie, prądy błądzące, fałszywe wyzwalanie RCD.
- **Brak jakiegokolwiek bondu** przy źródle z floating neutral i przełączniku rozłączającym N → układ pływający, RCD martwy.
- **Przełączanie przewodu PE** → chwilowa utrata uziemienia obudów. PE musi być ciągłe.
- **Podłączenie agregatu do gniazdka** („na waryjkę") → pomija przełącznik i uziemienie, zagraża monterom sieci (backfeeding) — patrz strona 16-05.
- **Brak uziomu lokalnego** → po odłączeniu sieci instalacja traci odniesienie do ziemi.

## Procedura projektowa — krok po kroku

1. Ustal układ sieci instalacji (zwykle TN-C-S) i sprawdź, gdzie jest obecny bond N-PE.
2. Wykonaj **uziom lokalny** i zmierz jego rezystancję (strona 09-02).
3. Dobierz **przełącznik rozłączający neutralny** (2-bieg. dla 1-fazy, 4-bieg. dla 3-faz) lub potwierdź w karcie inwertera funkcję automatycznego bondu N-PE w trybie wyspowym.
4. Dobierz wykonanie źródła (bonded vs floating neutral) spójnie z przełącznikiem.
5. Zapewnij **jeden** bond N-PE przy źródle, czynny tylko podczas pracy wyspowej.
6. Pozostaw przewód **PE ciągły i nieprzełączany** w całej instalacji.
7. Połącz uziom źródła z uziomem instalacji.
8. Po montażu wykonaj pomiary w **obu** trybach zasilania: rezystancja uziemienia, ciągłość PE, test RCD i pętla zwarcia przy pracy wyspowej (działy 09 i 11).

## Podsumowanie

- Sieć dostarcza uziemienie neutralnego z zewnątrz; źródło wyspowe — nie. Po przełączeniu trzeba je odtworzyć lokalnie.
- W każdym momencie ma istnieć **dokładnie jeden** bond N-PE — przełączanie musi go przenosić między siecią a źródłem.
- Najczystsze rozwiązanie to **przełącznik rozłączający przewód N** + lokalny bond przy źródle; inwertery hybrydowe często robią to automatycznie w trybie backup.
- Przewód **PE pozostaje ciągły** i nieprzełączany.
- Praca off-grid wymaga **własnego uziomu lokalnego** — nie polegaj na PEN sieci.
- Po wykonaniu instalacji sprawdź pomiarami ochronę w obu trybach zasilania.
