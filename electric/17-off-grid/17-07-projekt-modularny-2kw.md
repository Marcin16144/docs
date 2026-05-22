# Projekt modularny 1-fazowy 2 kW z opcją rozbudowy

Praktyczny projekt taniego systemu na start: instalacja hybrydowa **1-fazowa o mocy 2 kW**, zaprojektowana tak, by dało się ją **etapami rozbudowywać** — o panele, magazyn, turbinę, aż po przejście na większą moc. Strona pokazuje, jak zaprojektować taką instalację oraz ile kosztuje każdy etap.

## Założenia

| Parametr | Wartość |
|---|---|
| Typ | hybrydowy (PV + magazyn + sieć jako backup) |
| Faza | 1-fazowa 230 V |
| Moc inwertera (start) | 2 kW |
| Cel | obniżenie rachunków + zasilanie awaryjne obwodów krytycznych |
| Filozofia | minimalny start, projekt „na wyrost" pod rozbudowę |

To rozwiązanie dla osoby, która chce zacząć małym budżetem, ale **nie chce wyrzucać sprzętu przy rozbudowie**. Klucz to dobór komponentów skalowalnych już na starcie.

## Złota zasada: projektuj na cel, kupuj na etapy

Najczęstszy błąd przy małych instalacjach to kupno najtańszego zestawu „2 kW", którego nie da się rozbudować — i przy powiększaniu trzeba wymienić inwerter, magazyn i kable. Aby tego uniknąć, **siedem decyzji projektowych** podejmij od razu pod docelowy rozmiar:

1. **Napięcie magazynu 48 V od początku** — nie 12 V ani 24 V. Przy 48 V prądy są niskie, kable cienkie, a rozbudowa mocy możliwa. System 24 V utknie na ~2–3 kW.
2. **Inwerter hybrydowy z zapasem MPPT** — wybierz model, którego wejście PV przyjmie więcej paneli niż montujesz na starcie (np. inwerter 2 kW z MPPT do 3–3,5 kWp).
3. **Inwerter z funkcją pracy równoległej** — modele, które można połączyć w parę (2+2 kW) lub wpod rozbudowę do 3-fazy (3× jednostka). Sprawdź to w karcie katalogowej.
4. **Magazyn modułowy (stackowalny)** — LiFePO4, w którym dokładasz kolejne moduły tej samej rodziny. Start 5 kWh, docelowo 10–15 kWh.
5. **Rozdzielnica z rezerwą** — od razu większa, z 25–30% wolnych modułów na przyszłe zabezpieczenia.
6. **Kable i zabezpieczenia z zapasem przekroju** — dobierz pod moc docelową, nie startową. Wymiana kabla w ścianie jest droższa niż jego grubość.
7. **Konstrukcja i miejsce z rezerwą** — konstrukcja dachowa pod docelową liczbę paneli, miejsce na ścianie pod większy magazyn, wolny przepust pod przyszłą turbinę.

## Etap 0 — instalacja startowa 2 kW

| Komponent | Specyfikacja | Cena orientacyjna |
|---|---|---|
| Inwerter hybrydowy 1-faz 2 kW | 48 V, MPPT do ~3,5 kWp, funkcja backup/EPS, łączenie równoległe | 3 000–5 000 zł |
| Panele PV | 5× ~410 Wp mono = 2,05 kWp | 2 200–3 000 zł |
| Konstrukcja montażowa | dach skośny, alu — od razu pod 10 paneli | 800–1 600 zł |
| Magazyn LiFePO4 48 V | 5 kWh, modułowy (stackowalny) | 6 000–9 000 zł |
| Zabezpieczenia DC | bezpieczniki gPV, rozłącznik DC, SPD DC | 400–800 zł |
| Zabezpieczenia AC | MCB, RCD typ A, SPD T2 | 350–700 zł |
| Kable DC (PV1-F 6 mm²) + AC + MC4 | przekrój pod rozbudowę | 500–1 000 zł |
| Rozdzielnica backup + osprzęt | z rezerwą modułów | 400–800 zł |
| **Materiały razem** | | **14 000–22 000 zł** |
| Montaż (firma) | | 3 000–6 000 zł |
| **Etap 0 razem** | | **~17 000–28 000 zł** |

Wykonanie samodzielne (DIY) obniża koszt o robociznę, ale **podłączenie do sieci i odbiór musi wykonać osoba z uprawnieniami SEP** — patrz dział 14.

Co daje etap 0: ~1 900 kWh/rok z PV, autokonsumpcja podniesiona magazynem do ~60–70%, backup obwodów krytycznych (lodówka, oświetlenie, router, piec CO) na kilka godzin.

## Schemat instalacji startowej

```
  Panele PV 2,05 kWp
   (5 × 410 Wp)
        │ DC
        ▼
  ┌──────────────────────────────────┐     ┌──────────┐
  │  Inwerter hybrydowy 1-faz 2 kW   │─────│ Licznik  │── Sieć 230 V
  │  - MPPT (zapas do 3,5 kWp)       │ AC  │ 2-kier.  │
  │  - wejście magazynu 48 V         │     └──────────┘
  │  - wyjście backup / EPS          │
  └──────┬───────────────────┬───────┘
         │ DC                │ AC backup
         ▼                   ▼
  Magazyn LiFePO4      Rozdzielnica obwodów
  48 V / 5 kWh         krytycznych
  (modułowy)           (lodówka, ośw., router, CO)
```

## Plan rozbudowy — kolejne etapy

### Etap 1 — więcej PV i większy magazyn

| Działanie | Koszt | Efekt |
|---|---|---|
| Dołożenie 5 paneli (do 4,1 kWp) — drugi string w wolny MPPT | 2 200–3 000 zł | ~2× produkcja |
| Dołożenie modułu magazynu (do 10 kWh) | 5 500–8 500 zł | autokonsumpcja 75–85%, dłuższy backup |

Ponieważ konstrukcja i MPPT były dobrane z zapasem — to tylko dołożenie komponentów, bez wymiany. Wymaga aktualizacji zgłoszenia w OSD.

### Etap 2 — turbina wiatrowa (źródło zimowe)

| Działanie | Koszt | Efekt |
|---|---|---|
| Turbina pionowa 0,5–1 kW + regulator wiatrowy z dump load + maszt | 4 000–12 000 zł | produkcja w nocy i zimą, gdy PV słabnie |

Turbina ładuje wspólną szynę DC 48 V przez własny regulator wiatrowy. Szczegóły: dział 19, strona „Turbiny pionowe (VAWT)".

### Etap 3 — zwiększenie mocy lub przejście na 3 fazy

| Działanie | Koszt | Efekt |
|---|---|---|
| Drugi inwerter równoległy (2+2 kW) | 3 000–5 000 zł | moc 4 kW 1-faz |
| Albo zestaw 3 inwerterów → układ 3-fazowy | wymiana / dokupienie | zasilanie odbiorników 3-fazowych |

To możliwe **tylko** jeśli na starcie wybrano inwerter z funkcją pracy równoległej (decyzja 3). Stąd waga doboru sprzętu na początku.

## Koszt docelowy systemu rozbudowanego

| Konfiguracja | Łączny koszt narastająco |
|---|---|
| Etap 0 — start 2 kW, 2 kWp PV, 5 kWh | ~17 000–28 000 zł |
| + Etap 1 — 4 kWp PV, 10 kWh | ~25 000–40 000 zł |
| + Etap 2 — turbina 1 kW | ~29 000–52 000 zł |
| + Etap 3 — 4 kW / 3-faza | ~33 000–58 000 zł |

Rozbudowa etapami kosztuje nieco więcej niż zakup docelowego systemu od razu (osobne dojazdy, zgłoszenia), ale **rozkłada wydatek w czasie** i pozwala uczyć się na działającym systemie.

## Jak zaprojektować taką instalację — kroki

1. **Audyt zużycia** — wypisz odbiorniki krytyczne i policz zużycie dobowe [kWh] (patrz strona 17-02). To wyznacza minimalny magazyn.
2. **Ustal cel końcowy** — jaką moc PV, magazyn i ewentualnie turbinę chcesz mieć za 3–5 lat. Projektuj pod ten cel.
3. **Dobierz inwerter** — 2 kW na start, ale z MPPT i funkcją równoległą pod cel (decyzje 2 i 3).
4. **Napięcie systemu 48 V** — bezwarunkowo (decyzja 1).
5. **Dobierz kable i zabezpieczenia pod moc docelową** — przekrój DC/AC, SPD, rozłączniki (działy 03, 04, 10).
6. **Zaprojektuj rozdzielnicę backup** — wydzielone obwody krytyczne, rezerwa modułów (dział 06, strona 17-05).
7. **Konstrukcja i miejsce z zapasem** — dach pod docelową liczbę paneli, ściana pod większy magazyn.
8. **Dokumentacja i zgłoszenie OSD** — zgłoś instalację; przy każdej rozbudowie aktualizuj dane. Odbiór i pomiary — osoba z uprawnieniami SEP (działy 11 i 14).

> **Uwaga:** moc 2 kW 1-fazowo wystarcza do obwodów krytycznych i obniżania rachunku, ale nie uruchomi jednocześnie odbiorników o dużym rozruchu (pompa ciepła, indukcja 3-faz). Jeśli docelowo planujesz takie urządzenia — od początku rozważ projekt 3-fazowy zamiast rozbudowy 1-fazy.

## Podsumowanie

- Start 2 kW 1-faz to rozsądne wejście w fotowoltaikę z magazynem małym budżetem (~17–28 tys. zł).
- O sukcesie rozbudowy decyduje **siedem decyzji projektowych podjętych na starcie** — przede wszystkim napięcie 48 V, inwerter z zapasem MPPT i funkcją równoległą oraz magazyn modułowy.
- Rozbudowa etapami (PV → magazyn → turbina → moc) nie wymaga wymiany sprzętu, jeśli projekt był od początku „na wyrost".
- Każda zmiana mocy lub źródeł = aktualizacja zgłoszenia w OSD; odbiór zawsze przez uprawnionego elektryka.
