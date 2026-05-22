# Integracja źródeł — systemy hybrydowe

## Po co łączyć źródła

Pojedyncze źródło odnawialne ma „dziury" w produkcji: PV nie produkuje w nocy i mało zimą; turbina stoi przy bezwietrznej pogodzie. **System hybrydowy multi-source** łączy kilka źródeł tak, by się wzajemnie uzupełniały.

Najważniejsza zaleta to **komplementarność czasowa**:

| Źródło | Produkuje najwięcej |
|---|---|
| Fotowoltaika (PV) | latem, w dzień, przy słońcu |
| Turbina wiatrowa | zimą, w nocy, przy froncie atmosferycznym |
| Agregat (backup) | na żądanie — gdy zawiodą oba |

Lato i pogodne dni należą do PV; pochmurne, wietrzne dni i zima to czas turbiny. Razem dają bardziej wyrównaną produkcję przez cały rok niż każde z osobna.

## Wspólna szyna DC

Typowe rozwiązanie to **wspólna szyna prądu stałego** (DC bus), zwykle 48 V. Do niej podłączone są wszystkie źródła przez własne regulatory oraz magazyn i inwerter.

- PV → regulator MPPT (śledzi punkt mocy maksymalnej panelu) → szyna DC.
- Turbina → regulator wiatrowy (z funkcją hamowania) → szyna DC.
- Magazyn (akumulatory) → bezpośrednio na szynie DC, bufor energii.
- Inwerter → ze szyny DC robi 230 V AC dla odbiorników.

Część producentów oferuje **wspólny regulator hybrydowy PV + wind** — jedno urządzenie obsługujące wejście słoneczne i wiatrowe oraz ładowanie magazynu.

## Schemat systemu hybrydowego off-grid

```
   +-----------+        +-----------+
   |  Panele   |        |  Turbina  |
   |   PV      |        | wiatrowa  |
   +-----+-----+        +-----+-----+
         |                    |
         | DC                 | 3-faz AC
         v                    v
   +-----------+        +-----------+
   | Regulator |        | Prostownik|
   |   MPPT    |        |     +     |
   |  (PV)     |        | regulator |
   +-----+-----+        |  wiatr.   |
         |              +-----+-----+
         |                    |
         |     +--------+      |        +------------------+
         +---->| SZYNA  |<-----+        | Dump load        |
               |  DC    |<------------->| (rezystor        |
               |  48 V  |               |  balastowy)      |
               +---+----+               +------------------+
                   |  |
        +----------+  +-----------+
        |                        |
        v                        v
  +-----------+            +-----------+
  | Magazyn   |            | Inwerter  |
  | akumulat. |            | 48 V DC / |
  | 48 V      |            | 230 V AC  |
  +-----------+            +-----+-----+
                                 |
                  +--------------+--------------+
                  |                             |
                  v                             v
          +---------------+            +-----------------+
          |  Odbiorniki   |            |  Agregat        |
          |  230 V AC     |<-----------|  (backup)       |
          +---------------+            +-----------------+
```

Logika: oba źródła odnawialne ładują wspólną szynę DC i magazyn. Inwerter zasila odbiorniki. Gdy magazyn jest rozładowany, a wiatru i słońca brak — uruchamia się agregat. Gdy magazyn jest pełny, a źródła nadal produkują — nadwyżka idzie do dump load (patrz niżej).

## Integracja kolektora termicznego

Kolektor termiczny **nie jest źródłem elektrycznym** — nie wpina się do szyny DC. Działa osobnym obiegiem hydraulicznym. Jedyny punkt styku z elektryką to sterownik solarny i pompa obiegowa zasilane z instalacji 230 V (lub z inwertera w off-grid).

```
  +-----------+      glikol      +--------------+
  | Kolektor  |  ============>   |  Zasobnik    |
  | termiczny |   gorący         |  CWU z       |
  |           |  <============   |  wężownicą   |
  +-----------+   ochłodzony     +--------------+
        ^                              ^
        |                              |
        |        +-------------+        |
        +--------| Sterownik   |--------+
                 | solarny +   |
                 | pompa       |  <-- zasilanie 230 V
                 +-------------+      (z inwertera/sieci)
```

Obieg ciepła jest całkowicie oddzielony od obiegu energii elektrycznej — łączy je tylko niewielki pobór mocy przez pompę i sterownik.

## Bilansowanie źródeł i priorytety ładowania

W systemie hybrydowym regulator hybrydowy zarządza przepływem energii według priorytetów:

1. **Zasilanie bieżących odbiorników** — pierwszeństwo ma bieżąca konsumpcja.
2. **Ładowanie magazynu** — nadwyżka po pokryciu odbiorników ładuje akumulatory.
3. **Zrzut nadwyżki** — gdy magazyn pełny, a źródła wciąż produkują, nadmiar trafia do dump load.
4. **Uruchomienie agregatu** — gdy magazyn rozładowany poniżej progu, a źródła nie nadążają.

## Dump load — hamulec turbiny (WAŻNE)

> **Turbina wiatrowa nie może pracować bez obciążenia.** Generator obciążony prądem stawia opór wirnikowi i ogranicza jego obroty. Gdy magazyn jest pełny i regulator odetnie turbinę od szyny DC, turbina traci obciążenie — wirnik **rozpędza się bez kontroli** (rozbieganie), co grozi zniszczeniem łopat i generatora.

Rozwiązaniem jest **dump load** (rezystor balastowy / obciążenie zrzutowe):

- Regulator wiatrowy, wykrywając pełny magazyn, przełącza moc turbiny na rezystor balastowy zamiast ją odcinać.
- Rezystor zamienia nadwyżkę na ciepło — turbina cały czas ma obciążenie i nie rozbiega się.
- Dump load bywa wykorzystywany pożytecznie — np. jako grzałka w zasobniku CWU lub w buforze ogrzewania.
- Niezależnie od dump load turbina powinna mieć też **hamulec mechaniczny lub aerodynamiczny** (chowanie wirnika z wiatru) na wypadek wichury i awarii regulatora.

> Panele PV można bezpiecznie odłączyć od obciążenia — rozwarte po prostu nie produkują. Turbiny nie wolno zostawić bez obciążenia, bo wirnik nie ma się czym hamować.

## Realne zastosowanie multi-source

Systemy hybrydowe multi-source sprawdzają się przede wszystkim w instalacjach **off-grid**: działki rekreacyjne, domki bez przyłącza, obiekty w terenie. Tam liczy się ciągłość zasilania, a dywersyfikacja źródeł realnie zmniejsza zależność od agregatu i ilość zużytego paliwa. W instalacji podłączonej do sieci sieć sama pełni rolę „nieskończonego magazynu" i hybryda traci dużo na atrakcyjności.

## Co dalej

➡ [Przykłady — kolektory, turbina, system hybrydowy](19-06-przyklady.md)
