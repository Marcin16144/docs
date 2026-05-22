# Instalacja i podłączenie agregatu

Poprawne podłączenie agregatu to nie tylko kabel do rozdzielnicy. Decydują uziemienie, punkt zerowy, wentylacja spalin i zabezpieczenia.

## Sposób przyłączenia

- **Gniazdo agregatowe** — w ścianie budynku montuje się gniazdo (np. CEE 16/32 A), do którego podłącza się agregat przewodem. Wygodne, gdy agregat jest przenośny.
- **Przyłącze stałe** — agregat stacjonarny połączony na stałe z instalacją przez ATS. Standard dla agregatów z automatyką.

W obu przypadkach między agregatem a instalacją musi być przełącznik z blokadą (rozdział 16-05).

## Uziemienie agregatu

Agregat ma kołek/zacisk uziemiający na obudowie. Sposób uziemienia zależy od konstrukcji agregatu:

- **Agregat z rozdzielonym PE i N** (zaciski wyprowadzone osobno) — jego przewód PE łączy się z przewodem ochronnym PE instalacji domowej. Korzysta z istniejącego uziomu domu.
- **Agregat z połączonym N-PE wewnątrz** (typowe w przenośnych) — tworzy własny układ; uziemienie wykonuje się szpilką uziemiającą wbitą w grunt i połączoną z zaciskiem agregatu.

Nigdy nie pozostawiaj obudowy agregatu nieuziemionej — w razie zwarcia doziemnego obudowa znajdzie się pod napięciem.

## Punkt zerowy — układ TN vs IT

To zagadnienie często mylone. Agregat może pracować jako:

- **Układ TN (z uziemionym punktem zerowym)** — punkt N agregatu jest połączony z PE/uziomem. Wtedy zwarcie L-PE powoduje przepływ prądu zwarciowego i zadziałanie wyłącznika nadprądowego oraz RCD. Tak musi być, jeśli ochronę realizują MCB i RCD jak w instalacji domowej.
- **Układ IT (separowany, punkt zerowy izolowany)** — punkt N nieuziemiony; pierwsze zwarcie nie powoduje rozpływu prądu. Stosowane w małych agregatach przenośnych z gniazdami; ochrona przez separację. RCD w takim układzie nie zadziała przy pierwszym doziemieniu.

Przy podłączaniu agregatu do instalacji domowej z RCD trzeba zapewnić, by układ był **TN** — czyli punkt zerowy agregatu uziemiony, aby zabezpieczenia różnicowoprądowe miały warunki do zadziałania. Tę decyzję podejmuje elektryk, dobierając ją do konstrukcji agregatu i instalacji.

## Wentylacja i spaliny — zagrożenie życia

Agregat spala paliwo i wydziela **tlenek węgla (CO)** — gaz bezwonny, bezbarwny i śmiertelnie trujący.

> **OSTRZEŻENIE — zagrożenie życia.** NIGDY nie uruchamiaj agregatu w zamkniętym pomieszczeniu, garażu, piwnicy, na zamkniętym tarasie ani przy otwartym oknie domu. Tlenek węgla z agregatu zabija w kilka minut, bez ostrzeżenia. Agregat musi pracować na zewnątrz, z dala od okien i wlotów wentylacji, a spaliny muszą swobodnie odpływać.

Jeśli agregat jest w wydzielonym budynku/wiacie, konieczne są: nawiew świeżego powietrza, wywiew oraz **odprowadzenie spalin rurą na zewnątrz**. Czujnik CO w pobliżu jest zalecany.

## Zabezpieczenia na wyjściu

- **MCB (wyłącznik nadprądowy)** na wyjściu agregatu — chroni przed przeciążeniem i zwarciem; dobrany do mocy agregatu.
- **RCD (wyłącznik różnicowoprądowy)** — ochrona przeciwporażeniowa; działa tylko w układzie TN (uziemiony punkt zerowy — patrz wyżej).
- Zabezpieczenia instalacji domowej (MCB w rozdzielnicy obwodów) działają normalnie, gdy agregat pracuje jako źródło TN.

## Schemat pełnego podłączenia

```
   ┌──────────┐
   │ AGREGAT  │  praca NA ZEWNĄTRZ, odprowadzenie spalin!
   │  MCB+RCD │
   └────┬─────┘
        │  przewód zasilający (gniazdo CEE / przyłącze stałe)
        │
   ┌────┴───────────┐        ┌─────────────┐
   │  ATS / SZR     │◄───────┤  SIEĆ (OSD) │
   │  blokada       │        └─────────────┘
   │  pracy równol. │
   └────┬───────────┘
        │
   ┌────┴───────────────────────┐
   │ ROZDZIELNICA OBWODÓW        │
   │ AWARYJNYCH (wydzielona)     │
   │  ├─ MCB → lodówka/zamrażarka│
   │  ├─ MCB → pompa CO + kocioł │
   │  ├─ MCB → oświetlenie       │
   │  └─ MCB → gniazda krytyczne │
   └─────────────────────────────┘
                │
          uziom / PE instalacji
```

## Wydzielona rozdzielnica obwodów awaryjnych

Zamiast zasilać z agregatu cały dom, opłaca się **wydzielić rozdzielnicę obwodów krytycznych**. Podczas blackoutu agregat zasila tylko ją: lodówkę, ogrzewanie, oświetlenie, kilka gniazd. Pozwala to:

- dobrać mniejszy, tańszy i oszczędniejszy agregat (priorytetyzacja odbiorników),
- uniknąć przypadkowego włączenia odbiornika dużej mocy, który przeciąży agregat.

## Akustyka, posadowienie, eksploatacja zimą

- **Posadowienie** — agregat na stabilnym, równym podłożu; podkładki/maty antywibracyjne ograniczają hałas i przenoszenie drgań.
- **Akustyka** — agregat ustawić z dala od okien sypialni; wersje wyciszone (w obudowie) są znacznie cichsze.
- **Mróz** — zimą rozruch jest trudniejszy: stosuj odpowiedni olej zimowy, naładowany akumulator rozruchowy, ewentualnie podgrzewacz. Paliwo zimowe (ON zimowy).

## Co dalej

➡ [Koszty i eksploatacja](16-07-koszty-eksploatacja.md)
