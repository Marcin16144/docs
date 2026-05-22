# Pomiar ciągłości PE i połączeń wyrównawczych

## Co i dlaczego

**Ciągłość przewodu ochronnego** (continuity of protective conductor) potwierdza, że:

- przewód PE nie jest przerwany,
- nigdzie nie ma luźnego zacisku, urwanej żyły, zerwanego skręcenia,
- rezystancja całej drogi PE jest **wystarczająco niska**, by prąd zwarciowy mógł przepłynąć,
- połączenia wyrównawcze (GSW + MSW) realnie wyrównują potencjały.

Norma: **PN-HD 60364-6**, pkt 6.4.3 (pomiary po wykonaniu).

## Wymagana wartość

| Pomiar | Maks. R |
|---|---|
| Ciągłość PE w obwodzie | **≤ 1 Ω** (typowo 0,1–0,5 Ω) |
| Główne połączenie wyrównawcze (GSW) | **≤ 0,1 Ω** (między uziomem a szyną) |
| Miejscowe połączenia wyrównawcze (MSW) | **≤ 1 Ω** |
| Każdy zacisk wyrównawczy do GSW | **≤ 1 Ω** |

Wartości > 1 Ω wskazują na:

- luźne zaciski,
- skorodowane kontakty,
- urwaną żyłę PE w kablu,
- niepołączoną żyłę PE w puszce.

## Mernik niskonapięciowy

Pomiar wykonujemy **prądem ≥ 200 mA przy napięciu 4–24 V DC lub AC**.

| Model | Producent | Wymuszany prąd | Cena |
|---|---|---|---|
| **Sonel MMR-650** | Sonel | 200 mA, 4 V | ~3000 zł |
| **Sonel MIE-500** | Sonel | 200 mA / 10 A | ~5500 zł |
| **Sonel MPI-540** | Sonel | 200 mA + zakres |~7000 zł |
| **Megger DLRO10** | Megger | 10 A DLRO | ~6000 zł |
| **Fluke 1664 FC** | Fluke | 200 mA + MPI | ~6500 zł |

Dlaczego ≥ 200 mA? Mały prąd nie wykryje rezystancji styku **utleniowego** (np. zacisku skorodowanego), który przy małych prądach „przewodzi", a przy zwarciu już nie.

## Kompensacja przewodów pomiarowych

Przed serią pomiarów **wykonaj zerowanie** (auto-zero, REL, kompensacja):

1. zewrzyj przewody pomiarowe końcami,
2. naciśnij przycisk **REL / ZERO / AUTOZERO**,
3. mernik zapamięta R przewodów (np. 0,18 Ω),
4. od tego momentu odejmuje tę wartość od każdego pomiaru.

Bez kompensacji wszystkie wyniki są o 0,1–0,3 Ω zawyżone.

## Procedura — pomiar ciągłości PE w obwodzie

1. **Wyłącz instalację** (odłącz MCB obwodu).
2. **Sprawdź brak napięcia**.
3. **Zewrzyj L i N** w gnieździe — żeby zlikwidować pętlę pomiarową przez zasilacze (opcjonalnie).
4. **Skompensuj mernik** (zerowanie).
5. **Pomiar A**: zacisk PE w rozdzielnicy ↔ kontakt PE w gnieździe.
6. **Pomiar B**: ten sam zacisk PE w rozdzielnicy ↔ metalowa obudowa odbiornika (np. obudowa pralki, piekarnika).
7. **Odczyt R** [Ω].
8. **Zapisz wynik** — obwód, długość kabla, R, ocena.

## Procedura — pomiar połączeń wyrównawczych

### Główne (GSW)

1. **Uziom ↔ GSW**:
   - jeden zacisk do uziomu (FeZn w studzience kontrolnej),
   - drugi do szyny PE/GSW w rozdzielnicy,
   - R ≤ 0,1 Ω.

2. **Każda rura / element ↔ GSW**:
   - rura wody zimnej,
   - rura wody ciepłej,
   - rura gazowa (za gazomierzem!),
   - rura c.o.,
   - ekran TV,
   - konstrukcje stalowe,
   - R ≤ 1 Ω dla każdego.

### Miejscowe (MSW łazienki)

Pomiar między elementami w łazience:

| Pomiar | R |
|---|---|
| Wanna ↔ MSW puszka | ≤ 1 Ω |
| Bateria ↔ MSW | ≤ 1 Ω |
| Grzejnik metalowy ↔ MSW | ≤ 1 Ω |
| Stelaż Geberit ↔ MSW | ≤ 1 Ω |
| MSW ↔ PE gniazda | ≤ 1 Ω |
| MSW ↔ GSW (długa droga) | ≤ 1 Ω (zwykle 0,3–0,5 Ω) |

## Co najczęściej zostaje przerwane

| Element | Częsta przyczyna |
|---|---|
| PE w przedłużaczu | wtyczka bez bolca lub wadliwa |
| PE w puszce łączeniowej | nieskręcona żyła ZŻ |
| PE w gnieździe | poluzowany boczny styk |
| MSW w łazience | po remoncie zerwany przewód za zabudową |
| GSW ↔ rura | utleniony zacisk taśmowy (Cu na Fe!) |
| GSW ↔ uziom | utleniony zacisk krzyżowy w studzience |
| PE w starym kablu YDY | przerwana żyła wewnątrz izolacji |

## Praktyczna lista pomiarów ciągłości w domu

```
Lista do protokołu (przykład dom jednorodzinny):

[A] Ciągłość PE w obwodach
   - G1 gniazda kuchnia          ≤ 1 Ω
   - G2 gniazda salon            ≤ 1 Ω
   - G3 gniazda sypialnie        ≤ 1 Ω
   - G4 gniazda łazienka         ≤ 1 Ω
   - G5 gniazda zewnętrzne       ≤ 1 Ω
   - O1 oświetlenie salon        ≤ 1 Ω
   - O2 oświetlenie sypialnie    ≤ 1 Ω
   - O3 oświetlenie łazienka     ≤ 1 Ω
   - P1 piekarnik 3-faz         ≤ 1 Ω
   - P2 płyta indukcyjna        ≤ 1 Ω
   - K1 kocioł / pompa ciepła    ≤ 1 Ω
   - W1 wentylacja               ≤ 1 Ω

[B] Główna szyna wyrównawcza (GSW)
   - GSW ↔ uziom otokowy         ≤ 0,1 Ω
   - GSW ↔ rura wody zimnej      ≤ 1 Ω
   - GSW ↔ rura wody ciepłej     ≤ 1 Ω
   - GSW ↔ rura gazowa           ≤ 1 Ω
   - GSW ↔ rura c.o.             ≤ 1 Ω
   - GSW ↔ ekran TV/SAT          ≤ 1 Ω
   - GSW ↔ klimatyzacja zewn.    ≤ 1 Ω

[C] Miejscowe (MSW łazienka)
   - MSW ↔ wanna / brodzik       ≤ 1 Ω
   - MSW ↔ bateria umywalkowa    ≤ 1 Ω
   - MSW ↔ grzejnik              ≤ 1 Ω
   - MSW ↔ stelaż Geberit        ≤ 1 Ω
   - MSW ↔ PE gniazda            ≤ 1 Ω
```

## Najczęstsze problemy

| Symptom | Przyczyna |
|---|---|
| R = 0,5–1,5 Ω niestabilne | luźny zacisk — dokręć moment 2,5 Nm |
| R = 2–5 Ω | utleniona miedź na żelazo — wyczyść papierem ściernym, użyj pasty antykorozyjnej |
| R = ∞ (brak ciągłości) | przerwana żyła w kablu — szukaj wzdłuż obwodu, zwykle w puszce łączeniowej |
| R prawidłowe na kablu, brak na PE gniazda | bolec PE w gnieździe niewłaściwie zakuty (Schuko) |
| MSW ↔ wanna „∞" | wanna ma odprowadzenie z PE-X (plastik) — nie wymaga MSW, ale w protokole zaznacz |

## Co dalej

➡ [Protokół pomiarowy](11-06-protokol.md)
