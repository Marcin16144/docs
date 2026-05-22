# Integracja z instalacją domu

Najtrudniejszy etap projektu hybrydowego to wpięcie inwertera w istniejącą instalację domową. Decyzja, które obwody mają działać przy zaniku sieci, przekłada się wprost na koszt magazynu i sposób okablowania.

## Dwa warianty wpięcia

### Wariant A — backup całego domu (whole-home)

Inwerter hybrydowy zasila przez wyjście backup całą rozdzielnicę główną.

- Przy zaniku sieci działa cały dom.
- Wymaga dużej mocy backup i dużego magazynu (musi udźwignąć wszystkie odbiorniki naraz).
- Drogie; ryzyko przeciążenia, gdy w czasie awarii ktoś włączy płytę indukcyjną i czajnik.

### Wariant B — wydzielona rozdzielnica obwodów krytycznych (ZALECANE)

Część obwodów przenosi się do osobnej **rozdzielnicy backup**, zasilanej z wyjścia EPS inwertera. Reszta domu pozostaje na zwykłym zasilaniu sieciowym.

- Przy zaniku sieci działają tylko obwody krytyczne — magazyn obciążony rozsądnie.
- Mniejszy magazyn, niższy koszt, mniejsze ryzyko przeciążenia.
- Standard w polskich instalacjach hybrydowych.

## Schemat — wariant B (backup partial)

```
                     SIEĆ (OSD)
                         |
                  [licznik 2-kier.]
                         |
            ┌────────────┴─────────────┐
            |   ROZDZIELNICA GŁÓWNA    |
            |   (wyłącznik główny,     |
            |    ochronniki SPD)       |
            └──┬──────────────────┬────┘
               |                  |
        OBWODY ZWYKŁE        do inwertera
        (płyta induk.,        (wejście AC-grid)
         pralka, gniazda,           |
         klimatyzacja...)           |
        NIEzasilane            ┌────┴─────────────────┐
        przy awarii            |  INWERTER HYBRYDOWY  |
                               |  AC-grid | EPS | PV  |
                               |        | DC-bat      |
                               └──┬──────┬─────┬──────┘
                              PV  |   bat|     | EPS-out
                            ┌─────┘   ┌──┘     |
                         [panele]  [magazyn]   |
                          PV str.   LiFePO4    |
                                          ┌────┴───────────────┐
                                          | ROZDZIELNICA BACKUP |
                                          | (obwody krytyczne)  |
                                          └─┬────┬────┬────┬────┘
                                            |    |    |    |
                                        lodówka  CO  ośw. router
                                                              + 1 obw.
                                                                gniazd
```

Energia z PV i magazynu trafia na wyjście EPS, które zasila rozdzielnicę backup. Wejście AC-grid łączy inwerter z siecią poprzez rozdzielnicę główną — tędy płynie energia do/z sieci i ładowanie magazynu.

## Punkt sprzężenia i przekładniki CT

**Punkt sprzężenia** to miejsce, w którym instalacja PV/hybrydowa łączy się z instalacją domową — zwykle w rozdzielnicy głównej, tuż za wyłącznikiem głównym.

Aby inwerter wiedział, ile energii dom pobiera lub oddaje, w punkcie przyłączenia montuje się **przekładniki prądowe CT** (Current Transformer):

```
   licznik ──[CT]── rozdzielnica główna ── dom
               |
               └── sygnał pomiarowy → inwerter (EMS)
```

CT obejmuje przewody fazowe i mierzy kierunek oraz wielkość przepływu. Na tej podstawie EMS realizuje priorytet autokonsumpcji i funkcję export limit (sekcja 17-04). W instalacji 3-fazowej montuje się CT na każdej fazie.

## Zabezpieczenia AC i DC

Hybryda ma dwie strony wymagające osobnej ochrony:

| Strona | Zabezpieczenia |
|---|---|
| DC — panele PV | rozłącznik DC, bezpieczniki stringowe, ogranicznik przepięć SPD DC |
| DC — magazyn | bezpiecznik / wyłącznik DC o prądzie dobranym do magazynu, rozłącznik serwisowy |
| AC — strona sieci | wyłącznik nadprądowy, ochronnik SPD AC, wyłącznik różnicowoprądowy (RCD) |
| AC — wyjście backup | wyłącznik nadprądowy, RCD dla obwodów backup |

Strona DC jest groźna — napięcie stałe nie ma przejścia przez zero, łuk gaśnie trudniej. Rozłączniki DC muszą być przeznaczone do prądu stałego.

## Co przenieść do rozdzielnicy backup

Do obwodów krytycznych przenosi się to, co musi działać podczas awarii:

- **lodówka / zamrażarka** — ochrona żywności,
- **kocioł / piec CO i pompa obiegowa** — ogrzewanie zimą,
- **oświetlenie** części pomieszczeń,
- **router i sprzęt sieciowy** — łączność,
- **jeden obwód gniazd** ogólnego użytku (ładowanie telefonów, drobny sprzęt).

Obciążenie rozdzielnicy backup liczy się jako sumę mocy odbiorników mogących pracować jednocześnie:

```
P_backup = Σ (moc odbiorników krytycznych pracujących równocześnie)

Przykład:
lodówka 150 W + pompa CO 80 W + oświetlenie 200 W
+ router 15 W + obwód gniazd zał. 500 W
P_backup ≈ 945 W  →  z zapasem na rozruch lodówki ~1,5–2 kW
```

Tej wartości nie wolno przekroczyć — przeciążenie wyjścia EPS wyłączy backup.

> **Uwaga.** Płyty indukcyjnej, bojlera, pralki i klimatyzacji zwykle NIE przenosi się do backup — ich moc wywindowałaby wymagany magazyn i moc inwertera. Te odbiorniki zostają na zasilaniu sieciowym.

## Uziemienie i przełączanie

- Wyjście backup pracuje w trybie wyspowym jako osobne źródło — układ uziemienia (połączenie N-PE) musi być rozwiązany zgodnie z instrukcją inwertera; wiele modeli automatycznie zestawia połączenie N-PE w trybie backup.
- Przełączanie sieć ↔ backup realizuje wewnętrzny przekaźnik inwertera; nie wymaga ręcznej obsługi.

## Modernizacja on-grid → hybryda (retrofit AC-coupled)

Gdy dom ma już działającą instalację on-grid, można dołożyć magazyn bez wymiany istniejącego inwertera — to architektura **AC-coupled**:

```
istniejący inwerter PV ──AC── rozdzielnica
                                   |
                            inwerter bateryjny
                            (AC-coupled) ── magazyn
```

- Istniejący inwerter sieciowy zostaje; dokłada się osobny inwerter bateryjny po stronie AC.
- Alternatywa **DC-coupled** (wymiana na inwerter hybrydowy, panele wpięte po stronie DC) jest sprawniejsza, ale wymaga przebudowy strony DC.
- Wybór zależy od wieku i stanu istniejącej instalacji oraz budżetu.

## Co dalej

➡ [Przykłady projektowe](17-06-przyklady.md)
