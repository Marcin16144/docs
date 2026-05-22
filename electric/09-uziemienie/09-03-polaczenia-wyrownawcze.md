# Połączenia wyrównawcze

## Idea — dlaczego są potrzebne

Połączenia wyrównawcze (ang. *equipotential bonding*) łączą wszystkie metalowe elementy w budynku z jednym wspólnym potencjałem — potencjałem przewodu ochronnego PE. Bez nich:

- między rurą wodną a obudową pralki może pojawić się **napięcie dotykowe** (np. przy uszkodzeniu izolacji),
- prąd zwarciowy szuka „obejść" przez ciało użytkownika,
- prąd pioruna potrafi przeskoczyć z LPS do instalacji wodnej.

Ich zadanie: **wyrównać potencjały tak, by w żadnym momencie nie powstała różnica napięć większa niż 50 V AC** między dwoma jednocześnie dotykanymi częściami.

Norma odniesienia: **PN-HD 60364-4-41** (ochrona przed porażeniem), **PN-HD 60364-5-54** (uziemienia).

## Dwa poziomy połączeń wyrównawczych

| Rodzaj | Lokalizacja | Co łączy |
|---|---|---|
| **Główne (GSW)** | rozdzielnica główna / pomieszczenie techniczne | wszystkie metalowe instalacje wchodzące do budynku |
| **Miejscowe (MSW)** | strefa łazienki, pralni, basenu | przedmioty w zasięgu ręki w obrębie strefy |

## Główna szyna wyrównawcza (GSW)

GSW to listwa miedziana lub stalowa w rozdzielnicy głównej (lub osobnej szafce obok), do której **promienisto** doprowadza się przewody od:

- **PE** (przewód ochronny z instalacji),
- **uziomu** (z otokowego, fundamentowego — bednarka FeZn wprowadzona do GSW),
- **rur wodnych metalowych** (zimna i ciepła — zacisk za wodomierzem, ale przed pierwszą armaturą; jeśli wodociąg PE-X to pomijamy),
- **rur gazowych metalowych** (zacisk za gazomierzem, po stronie odbiorcy — uzgodnienie z gazownikiem!),
- **rur c.o. metalowych** (zasilanie i powrót),
- **konstrukcji stalowych budynku** (jeśli widoczne — schody, słupy, blachodachówka łączona),
- **ekranów koncentrycznych TV/SAT, kabli telefonicznych, światłowodów ze zbrojeniem**,
- **klimatyzacji split** (jednostka zewnętrzna),
- **PV i magazynów energii** (przez SPD),
- **windy, anteny, kominy ze stalową wkładką**.

**Schemat promieniowy:** każdy element → osobny przewód → GSW. Nigdy „szeregowo".

### Przekroje przewodów GSW

| Połączenie | Min. przekrój Cu | Min. przekrój Fe |
|---|---|---|
| GSW ↔ uziom | **16 mm²** (do otokowego FeZn — bednarka 30×4) | 50 mm² |
| GSW ↔ rury metalowe | **6 mm²** | 16 mm² |
| GSW ↔ konstrukcje budynku | **6 mm²** | 16 mm² |
| GSW ↔ ekran TV | **4 mm²** (przez SPD) | — |
| PE między rozdzielnicami | wg przekroju fazowego (tabela 54.2) | — |

Standardowy „domowy" pakiet: linka LgY 6 mm² zielono-żółta, zacisk taśmowy na rurze + opaska.

## Miejscowe połączenia wyrównawcze (MSW)

**Strefa łazienki** — najbardziej narażone miejsce. W łazience domowej łączymy:

- wannę / brodzik metalowy,
- baterie umywalkowe, wannowe, prysznicowe (jeśli metalowe i nie odizolowane plastikową rurą),
- rury wodne metalowe podchodzące do baterii,
- grzejnik metalowy (jeśli w łazience — często ręcznikowy),
- konstrukcje (rama do zabudowy WC — Geberit ma punkt EQ),
- metalowe drabinki, kabiny prysznicowe z metalową ramą.

**Przekroje miejscowe:**

| Połączenie | Min. przekrój Cu |
|---|---|
| Miejscowe (MSW) między elementami | **4 mm²** |
| MSW do PE | **2,5 mm²** (jeśli mechanicznie chroniony) lub **4 mm²** |

**Lokalizacja MSW:** najczęściej w **puszce wyrównawczej** za WC lub pod wanną, dostępna do kontroli.

## Co NIE wymaga połączeń wyrównawczych

- rury z tworzyw sztucznych (PE-X, PP, PVC) — nie przewodzą,
- baterie odłączone od instalacji metalowej (przez plastikową złączkę),
- meble metalowe niezwiązane z instalacją elektryczną,
- żaluzje, klamki — chyba że są zasilane elektrycznie.

## Pomiar ciągłości

Po wykonaniu połączeń wyrównawczych mierzymy **ciągłość** między GSW a każdym podłączonym elementem.

- mernik **niskonapięciowy** (4–24 V) z prądem ≥ 200 mA (np. Sonel MMR-650, MIE),
- przewód pomiarowy z zaciskiem krokodylkowym,
- wynik: **R ≤ 1 Ω**, typowo 0,1–0,5 Ω,
- **kompensacja** rezystancji przewodów pomiarowych (przycisk „AUTOZERO" lub procedura kompensacji).

Pomiar wykonuje się **przed włączeniem instalacji pod napięcie**.

## Przykładowy schemat domu jednorodzinnego

```
          ┌────────────── GSW (szyna w rozdzielnicy) ──────────────┐
          │      │      │      │      │      │      │     │
        [PE]  [uziom][woda][gaz][c.o.][TV ekran][PV][stalowy
               (FeZn          (za                       komin]
               30×4)          gazomierzem)
                                                 │
                              ┌──────────────────┘
                              │
                  ┌── MSW łazienka ──┐
                  │   │   │   │   │
                wanna bateria rura grzejnik PE-gniazdo
```

## Co najczęściej zostaje zapomniane

1. **Rury gazowe** — wielu elektryków pomija, bo „gazownik zabrania". Nieprawda — łączymy **po stronie odbiorcy** za gazomierzem.
2. **Konstrukcje stalowe** — np. dźwigar w garażu, słup pod zadaszeniem.
3. **PE telewizji satelitarnej** — antena na dachu = bezpośrednia droga dla pioruna do PE TV.
4. **Stelaż Geberit** — ma punkt EQ specjalnie do tego celu.
5. **Wymiana baterii na plastikowe rury** — po remoncie ciągłość może zniknąć.

## Sankcje i odbiór

Bez pomiaru ciągłości i protokołu **inspekcja odbiorowa nie przyjmie instalacji**. Dla nowo budowanego domu inspektor wymaga:

- protokołu Rz uziomu,
- protokołu ciągłości PE i połączeń wyrównawczych,
- protokołu Riso (izolacji),
- protokołu Zs (impedancji pętli),
- testu RCD.

## Co dalej

➡ [Pętla zwarcia i Zs](09-04-petla-zwarcia.md)
