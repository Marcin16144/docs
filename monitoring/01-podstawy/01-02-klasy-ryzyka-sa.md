# Klasy ryzyka SA1–SA4 i grade 1–4

> Klasyfikacja systemów alarmowych wg PN-EN 50131-1. Dobór klasy do obiektu, dopuszczalne urządzenia, wymagania dla poszczególnych grade.
>
> Aktualizacja: 2026

## Dwa równoległe systemy oznaczeń

W polskiej branży funkcjonują dwa systemy klasyfikacji:

| System | Skala | Co opisuje | Źródło |
|---|---|---|---|
| **SA1–SA4** | Stopień Aktywności sprawcy | jakiego sprawcę zakładamy | opracowania krajowe |
| **Grade 1–4** | klasa systemu alarmowego | jakimi środkami system się broni | PN-EN 50131-1 |

W praktyce używa się łącznie — SA opisuje zagrożenie (input), grade opisuje odpowiedź systemu (output).

## Klasy SA — profile sprawcy

| Klasa | Sprawca | Wiedza i narzędzia | Determinacja |
|---|---|---|---|
| **SA1** | okazjonalny | minimalna wiedza, śrubokręt, kamień | niska |
| **SA2** | zorientowany | typowe systemy, łom, narzędzia ogólne | średnia |
| **SA3** | wyszkolony | wiedza techniczna, jamer, sprzęt do pikowania | wysoka, planuje |
| **SA4** | profesjonalny | palniki, MW, narzędzia hydrauliczne | bardzo wysoka, plan ewakuacji |

## Grade 1–4 wg PN-EN 50131-1

### Grade 1 — niskie ryzyko

- **Sprawca SA1** — okazjonalny intruz bez wiedzy o systemach
- **Obiekty**: mieszkania w blokach, drobne biura, garaże, domki letniskowe
- **Wymagania**: jeden tor sygnalizacji, czujki proste PIR, brak wymagania sabotażu w rozbrojonym
- **ATS**: SP1 (tylko sygnał, bez SMA)

### Grade 2 — niskie do średniego

- **Sprawca SA2** — orientujący się, narzędzia ogólnie dostępne
- **Obiekty**: domy jednorodzinne, sklepy, biura, gabinety, mała gastronomia
- **Wymagania**: anti-mask zalecane, sabotaż obudowy wszystkich elementów, kody min. 10 000 kombinacji
- **ATS**: SP2/SP3 (komunikacja do SMA, czas detekcji awarii do 25 h)
- **Akumulator**: 12 h

**To najczęściej spotykany grade w PL dla obiektów prywatnych i drobnego biznesu.**

### Grade 3 — średnie do wysokiego

- **Sprawca SA3** — wyszkolony, z jamerem
- **Obiekty**: jubilerzy, lombardy, apteki, kantor, magazyny logistyczne, salony aut
- **Wymagania**: anti-mask **obowiązkowe**, czujki dual/triple, szyfrowana BUS, klawiatury 2FA
- **ATS**: SP4/DP3 — dual-path (IP+GSM), detekcja awarii <30 min
- **Akumulator**: 60 h
- **Sygnalizatory**: zewnętrzny z akumulatorem, sabotaż otwarcia + zerwania

### Grade 4 — wysokie ryzyko

- **Sprawca SA4** — profesjonalny
- **Obiekty**: banki (skarbce), obiekty wojskowe, ambasady, muzea klasy A, elektrownie
- **Wymagania**: redundancja dwóch technologii na każdą strefę, AES-128, czujki wibroakustyczne
- **ATS**: DP4 — dual-path z detekcją awarii <3 min
- **Akumulator**: 60 h + drugi tor zasilania (UPS/agregat)
- **SMA**: kategorii A — operatorzy z koncesją MSWiA, redundancja stacji

## Tabela porównawcza

| Parametr | Grade 1 | Grade 2 | Grade 3 | Grade 4 |
|---|---|---|---|---|
| Klasa sprawcy | SA1 | SA2 | SA3 | SA4 |
| Czujki anti-mask | nie | opcjonalnie | **tak** | **tak, dual** |
| Sabotaż obudowy | opcj. | tak | otw.+zerw. | otw.+zerw.+wibracje |
| Min. kombinacji kodu | 1 000 | 10 000 | 100 000 | 1 000 000 |
| Tory komunikacji (ATS) | 1 (SP1) | 1 (SP2/3) | 2 (SP4/DP3) | 2 (DP4) |
| Detekcja awarii toru | — | ≤25 h | ≤30 min | ≤3 min |
| Podtrzymanie akumulatora | 12 h | 12 h | 60 h | 60 h + tor 2 |
| Szyfrowanie BUS | — | opcj. | tak | AES-128 |
| Klasa środowiska | I | I lub II | II lub III | III lub IV |

## Dobór klasy do typu obiektu

| Obiekt | Grade | Uzasadnienie |
|---|---|---|
| Mieszkanie w bloku, 1–2 pokoje | 1–2 | niska wartość, niskie ryzyko |
| Mieszkanie premium / apartament | 2 | standard rynkowy |
| Dom jednorodzinny do 200 m² | 2 | standard z monitoringiem agencji |
| Rezydencja, dom >300 m² | 2 / 3 | 2 z elementami 3 |
| Sklep ogólny, biuro 100–500 m² | 2 | wymóg ubezpieczyciela |
| Apteka, gabinet stomatologiczny | 2 / 3 | 3 z lekami narkotycznymi |
| Jubiler, lombard, kantor | 3 | obowiązkowo wymóg KNF |
| Salon samochodowy | 3 | wysokie wartości |
| Magazyn farmaceutyczny | 3 / 4 | wymogi GIF |
| Bank — sala operacyjna | 3 | wymogi KNF |
| Bank — skarbiec, ATM | 4 | wymóg PN-EN 1143 |
| Muzeum klasy A | 3 / 4 | zależnie od wartości |
| Obiekty wojskowe, energetyka jądrowa | 4 | regulacje ustawowe |

**Ubezpieczyciel.** Wiele polis dla obiektów komercyjnych wymaga konkretnego grade jako warunku odszkodowania. Niewłaściwy grade = brak wypłaty po włamaniu.

## Klasy środowiskowe I–IV

| Klasa | Środowisko | Temperatura | Zastosowanie |
|---|---|---|---|
| I | wewnątrz, ogrzewane | +5 ÷ +40 °C | mieszkania, biura |
| II | wewnątrz, nieogrzewane | −10 ÷ +40 °C | garaże, magazyny |
| III | zewnątrz osłonięte | −25 ÷ +50 °C | pod zadaszeniem |
| IV | zewnątrz nieosłonięte | −40 ÷ +60 °C | słupy, dachy |

## Praktyczne implikacje grade 3 dla instalatora

Przejście z grade 2 na grade 3 to inna filozofia montażu:

- Każdy element musi mieć certyfikat grade 3 (nie wystarczy „pasuje technicznie")
- Cała linia BUS musi być szyfrowana (Satel ABAX 2, Integra z modułem szyfrującym)
- Centrala w obudowie z sabotażem wszystkich ścian + wibracje + zerwanie
- Dwa niezależne tory komunikacji do SMA + test PING co 3 minuty
- Dokumentacja techniczna obowiązkowa: rzuty, schematy, certyfikaty CNBOP/IBL
- Instalator z uprawnieniami montażysty PISA

## Co dalej

➡ [Analiza zagrożeń i macierz ryzyka](01-03-analiza-zagrozen.md)
