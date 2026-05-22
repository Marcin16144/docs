# Przełączanie sieć/agregat — SZR/ATS

Sam agregat to za mało. Trzeba go bezpiecznie podłączyć do instalacji tak, by nigdy nie pracował równolegle z siecią. To rozdział o bezpieczeństwie życia.

## Śmiertelne zagrożenie — backfeeding

Najgroźniejszy błąd to **podłączenie agregatu do gniazdka** przewodem z dwoma wtyczkami („suicide cord") albo wpięcie go do instalacji bez rozłączenia sieci.

Gdy agregat zasila instalację, a nie jest ona odcięta od sieci, napięcie agregatu **wraca przez przyłącze do sieci energetycznej**. Na transformatorze SN/nn podnosi się ono do kilkunastu kV. Monter, który naprawia „martwą" linię, zostaje porażony — to zjawisko nazywa się **backfeedingiem**.

> **OSTRZEŻENIE — zagrożenie życia.** NIGDY nie podłączaj agregatu do gniazdka ani do instalacji bez przełącznika fizycznie odcinającego sieć. Backfeeding zabija monterów sieci i może spowodować pożar po nagłym powrocie napięcia. Podłączenie agregatu do instalacji stałej musi wykonać uprawniony elektryk.

Zasada jest jedna: **w danej chwili instalację zasila albo sieć, albo agregat — nigdy oba naraz.** Wymusza to przełącznik z pozycją zerową i blokadą.

## Rozwiązanie A — przełącznik ręczny

Tani i niezawodny. Przełącznik trójpozycyjny **I-0-II** (lub rozłącznik krzywkowy) montowany przy rozdzielnicy:

- pozycja **I** — instalacja zasilana z sieci,
- pozycja **0** — instalacja odłączona od obu źródeł,
- pozycja **II** — instalacja zasilana z agregatu.

Konstrukcja przełącznika **mechanicznie uniemożliwia** zwarcie sieci z agregatem — nie da się ustawić obu naraz. Wadą jest konieczność obecności człowieka: przy zaniku trzeba zejść do rozdzielnicy, przełączyć na 0, uruchomić agregat, przełączyć na II.

```
   SIEĆ ──────┐
              │
        ┌─────┴─────┐
        │  I  0  II │  ← przełącznik I-0-II
        └─────┬─────┘     (pozycja 0 = bezpieczne odcięcie)
              │
   AGREGAT ───┘
              │
              ▼
        ROZDZIELNICA → obwody domu
```

## Rozwiązanie B — automatyka SZR / ATS

**SZR** (Samoczynne Załączanie Rezerwy), po angielsku **ATS** (Automatic Transfer Switch), to automat, który robi wszystko sam:

1. wykrywa zanik lub spadek napięcia sieci,
2. po krótkim opóźnieniu (kilka sekund — by odróżnić zanik od mignięcia) wysyła sygnał rozruchu agregatu,
3. czeka, aż agregat się rozkręci i ustabilizuje napięcie,
4. przełącza instalację z sieci na agregat,
5. po powrocie sieci — odczekuje (np. 1–3 min stabilnej sieci), przełącza z powrotem na sieć,
6. wychładza i zatrzymuje agregat.

Czas przełączania to typowo **kilka–kilkanaście sekund** (tyle, ile potrzebuje agregat na rozruch). To nie jest zasilanie bezprzerwowe — krótkiego zaniku nie unikniesz; jeśli to przeszkadza, łączymy ATS z UPS-em.

```
   SIEĆ ──────┐                 ┌── pomiar napięcia sieci
              │                 │
        ┌─────┴───────────┐     │
        │      ATS / SZR  │◄────┘
        │  sterownik +    │
        │  styczniki z    │──────► sygnał START / STOP agregatu
        │  blokadą        │
        └─────┬───────────┘
              │
   AGREGAT ───┘  (z elektrostartem)
              │
              ▼
        ROZDZIELNICA → obwody domu
```

## Blokada pracy równoległej

Niezależnie od rozwiązania, przełączanie musi mieć **blokadę uniemożliwiającą jednoczesne załączenie obu źródeł**:

- **blokada mechaniczna** — fizyczna zapadka między stycznikami/dźwigniami; jeden wyłączony, by drugi mógł się załączyć,
- **blokada elektryczna** — styki pomocnicze: cewka jednego stycznika jest rozłączona, gdy drugi jest załączony.

W praktyce stosuje się obie naraz. To ta blokada chroni przed backfeedingiem.

## Gdzie montować

Przełącznik lub ATS montuje się **przy rozdzielnicy głównej**, między licznikiem/przyłączem a obwodami odbiorczymi (lub przed wydzieloną rozdzielnicą obwodów awaryjnych — patrz 16-06). Sterownik ATS powinien być dostępny, a samego agregatu nie wolno stawiać w pomieszczeniu mieszkalnym (spaliny — rozdział 16-06).

> **Wskazówka.** Dla domu rozsądnym kompromisem kosztowym jest przełącznik ręczny I-0-II, jeśli ktoś jest w domu podczas blackoutów. ATS wybieramy, gdy zasilanie ma być niezawodne pod nieobecność domowników (np. zamrażarka, ogrzewanie, serwer, akwarium).

## Co dalej

➡ [Instalacja i podłączenie agregatu](16-06-instalacja-podlaczenie.md)
