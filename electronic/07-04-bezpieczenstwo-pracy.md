# 07-04: Bezpieczeństwo pracy

## Wstęp

Elektronika jest niebezpieczna. Można:
- Porazić się prądem
- Spalić elementy
- Zaprószyć pożar
- Uszkodzić wzrok / oparzyć
- Zniszczyć sprzęt elektrostatyką

Większości można uniknąć trzymając się prostych zasad.

## Porażenie elektryczne

### Skutki prądu na ciele człowieka

Prąd przepływający przez ciało:

| Prąd (AC, 50/60 Hz) | Efekt |
|--------------------|-------|
| < 1 mA | niezauważalny |
| 1-3 mA | mrowienie |
| 3-10 mA | bolesne, mięśnie pracują |
| 10-30 mA | "nie puszcza" — skurcz mięśni, nie można puścić przedmiotu |
| 30-100 mA | trudności z oddychaniem |
| **> 50 mA przez serce** | **migotanie komór, śmierć** |
| > 1 A | oparzenia, zniszczenie tkanek |

DC mniej groźny w niskich wartościach, ale wciąż zabija przy 200+ mA.

### Rezystancja ciała

Sucha skóra: 100 kΩ – 1 MΩ.
Wilgotna / spocona: 1-10 kΩ.
Z otwartą raną: < 1 kΩ.

Stąd przy 230 V:
- Suchy palec → 230/100000 = 2,3 mA (czujny, ale bezpieczny)
- Spocona ręka → 230/5000 = 46 mA (groźne!)
- Rana / wilgoć → 230/500 = 460 mA (śmierć)

### Droga prądu — najgorsze warianty

- **Z ręki do ręki** — przez serce → migotanie
- **Z ręki do nogi** — przez serce → groźne
- **Z nogi do nogi** — pomija serce, mniej groźne (ale uderza w nerwy)

Stąd zasada: **jedna ręka w kieszeni** podczas pracy pod napięciem.

## Sieć 230 V

### Konwencja kolorystyczna (PE/N/L)

| Przewód | Kolor | Funkcja |
|---------|-------|---------|
| L (faza) | brązowy, czarny | napięcie ~230 V względem zera |
| N (neutralny) | niebieski | "zero" — uziemione w stacji |
| PE (ochronny) | żółto-zielony | uziemienie — bezpośrednio do ziemi |

**Nigdy** nie zamieniać PE z innymi. PE chroni przed porażeniem przy awarii izolacji.

### Bezpieczeństwo instalacji

1. **Wyłącznik różnicowo-prądowy (RCD)** 30 mA — wyłącza przy upływie ≥ 30 mA do ziemi. Ratuje życie.
2. **Bezpieczniki nadprądowe** — chronią instalację, nie człowieka.
3. **Uziemienie obudowy** — przy awarii izolacji prąd płynie do ziemi, nie przez ciało.

### Praca z siecią — zasady

1. **Wyłącz zasilanie** w skrzynce + sprawdź neonem.
2. **Mata izolacyjna** pod nogami przy pracy pod napięciem.
3. **Rękawiczki gumowe** klasy elektrycznej.
4. **Narzędzia z izolowaną rączką** (klasa 1000 V).
5. **Pomieszczenie suche**, podłoga sucha.
6. **Nie sam** — ktoś w pobliżu na wypadek wypadku.

## Transformator izolacyjny

W warsztacie serwisowym **niezbędny** przy pracy z otwartym sprzętem sieciowym (radia, zasilacze, TV).

Transformator 1:1 daje 230 V "pływające" — żaden z dwóch przewodów nie jest uziemiony. Dotknięcie pojedynczego = bezpieczne.

**Uwaga:** dotknięcie obu zacisków jednocześnie = śmiertelne.

## Wyładowanie elektrostatyczne (ESD)

### Co to

Statyczny ładunek na ciele człowieka (np. od chodzenia po dywanie) może mieć **10 kV**! Niewyczuwalne, ale śmiertelne dla MOSFETów, CMOSów, niektórych dioad.

### Skutki

- Trwałe uszkodzenie elementu (niewidoczne)
- "Latent damage" — element działa, ale padnie po kilkuset godzinach
- Zmiana parametrów (np. wzmocnienie tranzystora)

### Ochrona ESD

1. **Opaska antystatyczna** na nadgarstku, połączona z uziemieniem przez rezystor 1 MΩ.
2. **Mata antystatyczna** na biurku.
3. **Buty antystatyczne** lub podłoga przewodząca.
4. **Pęsety antystatyczne**.
5. **Worki ESD** dla elementów (przezroczyste antystatyczne, srebrne / różowe).
6. **Wilgotność** powyżej 40% (dolewa się w ESD nawilżacze).

Standard EPA (ESD Protected Area) w produkcji elektroniki.

## Kondensatory — naładowane po wyłączeniu

Kondensatory w zasilaczach (zwłaszcza dużych: SMPS, wzmacniacze, mikrofalówki) trzymają **ładunek nawet godziny** po wyłączeniu.

### Niebezpieczne wartości

- Kondensator 470 μF / 450 V w zasilaczu SMPS: E = ½·C·U² = 0,5·470·10⁻⁶·450² = **47 J** — może zabić.
- Kondensator mikrofalówki (1-2 μF / 2 kV): **4 J** — bardzo niebezpieczny.
- Defibrylator: 200-400 J — w celu ratowania (lub zabijania).

### Rozładowanie

**Przed dotknięciem** rozładuj rezystorem mocy:
- 10-100 kΩ, 5-10 W
- Przyłącz przez kilka sekund

Lub żarówką 60 W (dla 230 V kondensatorów).

NIE używaj śrubokrętu (iskra, uszkodzenie kondensatora, ryzyko).

## Lutowanie — bezpieczeństwo

Patrz rozdział 07-03. Krótko:

1. Lutownica zawsze w stojaku.
2. Wentylacja oparów.
3. Okulary ochronne.
4. Po pracy myj ręce (ołów).
5. Nigdy nie zostawiaj bez nadzoru pod napięciem.

## Baterie i akumulatory

### Li-Ion

- Zwarcie → pożar
- Przeładowanie > 4,2V → pożar
- Mechaniczne uszkodzenie (przebicie) → pożar
- Wysoka temperatura > 60°C → degradacja, pożar

**Gaszenie**: piasek, gaśnica D (na metale), koc gaśniczy. **Nie woda** (na początku).

### Ołowiowe

- Elektrolit kwasowy → poparzenie chemiczne
- Gazowanie → wybuchowy wodór w pomieszczeniu
- Pracuj w wentylowanym miejscu

### NiCd / NiMH

Najmniej groźne, ale przy zwarciu też mogą wybuchnąć.

## Pożar w warsztacie elektronicznym

### Przyczyny

- Przeciążenie obwodu / zwarcie
- Bateria Li-Ion
- Lutownica zostawiona pod nadzorem
- Zasilacz wadliwy (kondensator wybuchowy)

### Gaśnica

Klasa pożaru:
- **A** — papier, drewno, tkaniny
- **B** — ciecze (benzyna)
- **C** — gazy
- **D** — metale (Li, Mg)
- **E** — urządzenia elektryczne pod napięciem (CO₂, proszkowa)
- **F** — oleje kuchenne

Dla warsztatu: **gaśnica CO₂** (E) lub **proszkowa** ABC.

### NIE gasić wodą

Sprzęt elektryczny pod napięciem. Najpierw wyłącz, potem gasić.

## Wzrok i oparzenia

### Lutowanie

Stary nawyk "dmuchania na cynę" — pryskają cząstki w oczy. **Okulary ochronne**.

### Praca z laserami

CD/DVD/Blu-Ray drives mają lasery, w niektórych można je wyciągnąć — silne, mogą uszkodzić wzrok. **Nie patrz w wiązkę**.

### Lampy UV (do oczyszczania flux)

Krótkotrwałe naświetlanie OK, dłuższe → poparzenia skóry, oczu.

### Hot air station

Strumień 350°C — łatwo poparzyć palce. Dmuchawa kierowana **z dala od siebie**.

## Substancje chemiczne w elektronice

### Topnik (flux)

Niektóre topniki są agresywne (kwasowe). Trzymaj z dala od oczu i skóry. Wentylacja!

### Aceton, IPA (alkohol izopropylowy)

Do czyszczenia. **Łatwopalne**! Z dala od lutownicy. Wentylacja.

### Rozpuszczalniki PCB

Niektóre toksyczne (THF, dichlorometan). Praca w rękawiczkach, wentylacja.

### Ołów

Dym z lutowania, kurz z PCB. Wentylacja, mycie rąk.

## Pierwsza pomoc — porażenie elektryczne

1. **Bez dotykania ofiary** — wyłącz źródło prądu (wyłącznik, korki).
2. **Jeśli nie da się wyłączyć** — odepchnij ofiarę **suchym drewnem** (nie metalem, nie ręką).
3. **Sprawdź oddech i tętno**.
4. **Resuscytacja** jeśli brak.
5. **Zawiadom pogotowie** (112).
6. **Nawet jeśli ofiara wstaje** — do szpitala (opóźnione efekty na serce).

## Pracownia / warsztat — wyposażenie

### Niezbędne

- **Apteczka** (plastry, dezynfekcja, bandaże)
- **Gaśnica CO₂ lub proszkowa**
- **Łatwy dostęp do telefonu** (112)
- **Dobra wentylacja**
- **Wyłącznik główny** zasilania pracowni

### Stoły

- Mata antystatyczna z uziemieniem
- Trzecia ręka (helping hands)
- Imadło PCB
- Lampa z lupą (lub mikroskop)

### Oświetlenie

Minimum 1000 lux (bardzo jasne). Cienia można uniknąć dwoma lampami.

### Wentylacja

- Wentylator nadstanowiskowy z filtrem węglowym
- Wymiana powietrza co 5-10 minut

### Przechowywanie

- Cyny z ołowiem **osobno** od bezołowiowej
- Elementy w pojemnikach antystatycznych
- Baterie Li-Ion w specjalnych pojemnikach ognioodpornych

## Normy i standardy

### Europa

- **PN-IEC 61010** — bezpieczeństwo sprzętu pomiarowego
- **PN-EN 50110** — eksploatacja urządzeń elektrycznych
- **PN-EN 61140** — ochrona przed porażeniem
- **RoHS** — substancje niebezpieczne
- **WEEE** — utylizacja sprzętu elektronicznego

### USA

- **NEC** (National Electrical Code)
- **NFPA 70E** — bezpieczeństwo w pracy z elektrycznością
- **UL** — certyfikacja sprzętu

## Praca z dziećmi / nowicjuszami

- **Praca pod napięciem zakazana** dla osób bez przeszkolenia
- **Niskonapięciowe projekty** (5-12 V) dla początkujących
- **Lutowanie z nadzorem** (zwłaszcza dzieci)
- **Wyjaśnienie ryzyk** przed rozpoczęciem

## Częste błędy w bezpieczeństwie

1. **"Tylko na chwilę pod napięciem"** — wszystkie wypadki tak się zaczynają.
2. **Brak rozładowania kondensatorów** przed naprawą zasilacza.
3. **Brak ESD przy MOSFETach** → tajemnicze padnięcia po godzinach pracy.
4. **Lutowanie przy włączonym układzie** — zwarcie cyną.
5. **Niewłaściwa gaśnica** — woda na sprzęt pod napięciem.
6. **Brak wentylacji** — chroniczne zatrucia oparami cyny.
7. **Praca samemu z siecią** — w razie wypadku nikt nie pomoże.
8. **Brak okularów** podczas hot air — pryskająca cyna.
9. **Akumulator Li-Ion w gorącej szufladzie** — pożar warsztatu.

## Podsumowanie

Najważniejsze zasady:

1. **Wyłącz zasilanie** przed pracą.
2. **Rozładuj kondensatory** w sprzęcie sieciowym.
3. **Mata antystatyczna + opaska** dla CMOS/MOSFET.
4. **Transformator izolacyjny** przy pracy z siecią.
5. **Wentylacja** lutowania.
6. **Gaśnica** w zasięgu ręki.
7. **Bezpieczne odległości** — szczególnie sieci 230 V.
8. **Trzeźwy umysł** — zmęczenie i alkohol nie idą z elektroniką.

Doświadczenie nie chroni — może wręcz uśpić czujność. Procedury BHP są dla wszystkich.
