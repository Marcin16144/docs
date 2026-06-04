# Elektrozaczepy

## Czym jest elektrozaczep

Elektrozaczep to **mechaniczny element ryglujący** osadzony w futrynie drzwi, sterowany elektromagnetycznie. Współpracuje z istniejącym zamkiem (zamek mechaniczny zostaje — elektrozaczep tylko zwalnia rygiel).

```
           ┌──────────────┐
DRZWI      │              │   FUTRYNA
────╮      │   ┌────┐     │
    │      │   │    │     │ ← obudowa elektrozaczepu
[zamek]──→[KLAPKA]──→     │    (cewka + sprężyna + klapka)
    │      │   │    │     │
────╯      │   └────┘     │
           │  zwora       │
           └──────────────┘
```

Po przyłożeniu napięcia do cewki, klapka traci sztywność i można ją **odepchnąć drzwiami** (zamek mechaniczny ma już cofnięty rygiel — wcześniej kluczem lub klamką).

## Standardowy (fail-safe) vs rewersyjny (fail-secure)

### Standardowy / „pod napięciem otwarty" (fail-safe)

| Stan zasilania | Klapka | Drzwi |
|---|---|---|
| brak napięcia (normalne) | zablokowana | zamknięte (nie da się otworzyć) |
| napięcie 12 V (impuls) | odblokowana | otwarte (pchnij) |

Najpopularniejszy w Polsce w domofonach. Po awarii zasilania **drzwi pozostają zamknięte**. Wadą jest ryzyko uwięzienia w pomieszczeniu przy braku prądu — nieakceptowalne na drogach ewakuacji.

### Rewersyjny / „bez napięcia otwarty" (fail-secure)

| Stan zasilania | Klapka | Drzwi |
|---|---|---|
| napięcie 12 V (normalne) | zablokowana | zamknięte |
| brak napięcia (awaria / pożar) | odblokowana | otwarte (pchnij) |

Po awarii zasilania **drzwi automatycznie się odblokowują** — bezpieczne ewakuacyjnie. Wymagany na drogach ewakuacyjnych w obiektach z obowiązkiem ewakuacji.

> Uwaga na nazewnictwo — w żargonie różnie:
>
> - **fail-safe** = „bezpieczny przy awarii" = rewersyjny = bez prądu otwarty,
> - **fail-secure** = „zabezpieczony przy awarii" = standardowy = bez prądu zamknięty.
>
> W polskich katalogach często skróty „R" (rewersyjny), „S" (standardowy), „NC/NO" lub „X" (rewers).

## Zasilanie

| Napięcie | Typowy pobór | Zastosowanie |
|---|---|---|
| 12 V AC | ~400 mA impuls (5 W) | najczęstsze w domofonach (transformator dzwonkowy) |
| 12 V DC | ~250 mA stały (rewersyjny) | systemy KD profesjonalne |
| 24 V DC | ~150 mA stały | BMS, instalacje przemysłowe |

Rewersyjny pracuje **cały czas pod napięciem** (250 mA × 24 h = 6 Ah/dobę). Wymaga akumulatora wsparcia o odpowiedniej pojemności (typowo 7–17 Ah przy 24 h pracy + 30 min alarmu).

> Niektóre tańsze elektrozaczepy **nie mogą pracować w trybie ciągłym** pod napięciem — przegrzewają się. Sprawdzić w karcie katalogowej parametr **„intermittent / continuous duty"** przed zakupem rewersyjnego.

## Wymiary i mocowanie

Standardowy elektrozaczep ma wymiary:

- szerokość obudowy: **17–22 mm** (mieści się w stalowej futrynie),
- długość: **60–90 mm**,
- głębokość w futrynie: **28–32 mm**,
- otwór klapki: dostosowany do rygla zamka (15 × 15 mm, 20 × 20 mm).

Wymaga frezowania wybrania w futrynie (najczęściej futryna stalowa ma już otwór + listwę montażową). Drzwi drewniane wymagają dodatkowych blachownic ochronnych.

## Funkcje dodatkowe

| Funkcja | Skrót | Opis |
|---|---|---|
| Pamięć rewersu | R/M | jednokrotny impuls — drzwi otwarte do momentu otwarcia i zamknięcia |
| Sygnalizacja stanu drzwi | BS / DS | mikrowyłącznik w klapce — kontroler wie, czy drzwi otwarte/zamknięte |
| Blokada mechaniczna | BL | tymczasowe wyłączenie elektrozaczepu suwakiem (np. przy sprzątaniu) |
| Symetryczny | — | można montować na lewą i prawą stronę drzwi |
| Krótka / długa klapka | L/S | dostosowanie do typu rygla zamka |

## Marki na rynku polskim

### BIRA (Polska)

- najpopularniejsza polska marka,
- modele: 1410S (standard 12 V AC), 1410R (rewersyjny), 1411 z pamięcią,
- cena 60–180 zł,
- jakość średnia, do domofonów i lekkich zastosowań.

### FAS / Lockpol (Polska)

- seria EFF50, EFF60, EFF70 — z pamięcią, mocniejsze,
- certyfikat CE, klasa wandaloodporna,
- cena 100–250 zł.

### Effeff (Niemcy — ASSA ABLOY)

- premium, w przedziale 250–600 zł,
- seria 17, 18, 116, 142, 351,
- opcjonalne sterowanie napięciowe 6–24 V (uniwersalne),
- dłuższa żywotność (200 000 cykli vs 50 000 u taniej konkurencji),
- klasy odporności na włamanie wg **EN 14846**.

### GEZE, DORMA, ABLOY

Premium europejskie, do drzwi ewakuacyjnych i drzwi p-poż (z certyfikatem CE jako element drzwi ewakuacyjnych).

## Klasy odporności wg EN 14846

Norma **EN 14846** klasyfikuje elektrozaczepy na 10 klas (cyfra po cyfrze, 10-znakowy kod):

- **1 cyfra** — kategoria użytkowania (1 — niska, 3 — wysoka),
- **2 cyfra** — trwałość (cykli × 10⁴): 10/15/25/50/100,
- **3 cyfra** — masa drzwi (kg do których podpada),
- **4 cyfra** — odporność ogniowa,
- **5 cyfra** — bezpieczeństwo w użyciu,
- **6 cyfra** — korozja i temperatura,
- (itd. — szczegóły w normie).

## Montaż — schemat typowy z domofonem

```
     [Kaseta zewnętrzna domofonu]
         │ 2 żyły (audio + zasilanie)
         ▼
     [Zasilacz 12 V AC]
         │ 2 żyły
         ▼   ┌──────[Unifon w mieszkaniu]
     [Elektrozaczep]──[przycisk wyjścia wewnątrz]
         │
     [DRZWI]
```

W systemie z kontrolerem KD:

```
[Czytnik RFID]──RS-485/Wiegand──[Kontroler]
                                  │
                                  ├── 12 V → [Elektrozaczep]
                                  ├── BS ←── [stan drzwi]
                                  └── PWE ←── [przycisk wyjścia]
```

## Czego nie wolno na drogach ewakuacyjnych

> **Elektrozaczep STANDARDOWY (fail-safe) jest ZAKAZANY** na drogach ewakuacyjnych w obiektach z obowiązkiem ewakuacji (biurowce, hotele, szkoły, galerie). Po awarii zasilania ludzie nie mogliby się wydostać.
>
> Zamiast tego stosujemy:
>
> - elektrozaczep **rewersyjny** (fail-secure) — po zaniku zasilania automatycznie otwarte,
> - zworę magnetyczną (zawsze fail-safe — bez prądu otwarta),
> - klamkę z funkcją *anti-panic* (otwiera mechanicznie z każdej strony, niezależnie od KD).

## Współpraca z alarmem ppoż

W obiektach z systemem SAP elektrozaczepy są integrowane z centralą pożarową:

- alarm pożarowy → przekaźnik w centrali SAP → odcięcie zasilania elektrozaczepów rewersyjnych,
- wszystkie drzwi z elektrozaczepami automatycznie się otwierają,
- dotyczy też zwór magnetycznych (te i tak są fail-safe).

## Konserwacja i typowe awarie

- **brzęczenie cewki** przy zasilaniu AC — normalne, jeśli głośne — wymiana,
- **klapka nie wraca po zwolnieniu** — zatarte ułożysko (smarowanie suchym smarem grafitowym),
- **elektrozaczep nie zwalnia** — sprawdzić napięcie (powinno być stabilne, bez zaników na kablu),
- **uszkodzenie cewki** (po latach pracy AC) — wymiana całości,
- orientacyjna żywotność: 100 000–500 000 cykli (tańsze 50 000).

## Co dalej

➡ [Zamki magnetyczne (zwory)](12-04-zamki-magnetyczne.md)
