# Agregaty — budowa i typy

Agregat prądotwórczy to zespół silnika spalinowego i prądnicy. Zrozumienie jego budowy pozwala świadomie dobrać typ paliwa i konstrukcję.

## Budowa agregatu

Każdy agregat składa się z pięciu zasadniczych podzespołów:

| Podzespół | Funkcja |
|---|---|
| **Silnik spalinowy** | napęd — zamienia energię paliwa na ruch obrotowy (zwykle 3000 obr/min dla 50 Hz) |
| **Prądnica (alternator)** | zamienia ruch obrotowy na prąd przemienny |
| **AVR** — regulator napięcia | utrzymuje stałe napięcie wyjściowe niezależnie od obciążenia |
| **Układ sterowania** | rozruch, pomiary, zabezpieczenia, panel; w wersjach z ATS — automatyka |
| **Zbiornik paliwa** | zapas paliwa; jego pojemność wyznacza czas pracy bez tankowania |

AVR (ang. *Automatic Voltage Regulator*) reaguje na zmiany obciążenia — gdy włączasz odbiornik, napięcie spadłoby, ale AVR podbija wzbudzenie prądnicy i przywraca 230 V.

## Typy według paliwa

| Paliwo | Moc typowa | Zalety | Wady |
|---|---|---|---|
| **Benzyna** | do ~5 kW | tani zakup, lekki, łatwy rozruch | głośny, droga eksploatacja, krótka żywotność |
| **Diesel (ON)** | 5–20 kW | trwały, ekonomiczny, do pracy ciągłej | drogi zakup, cięższy, głośniejszy zapłon |
| **Gaz LPG/CNG** | 2–15 kW | czysty, cichy, paliwo długo się przechowuje | mniejsza moc, instalacja gazowa |
| **Dual-fuel** | 2–10 kW | praca na benzynie lub gazie do wyboru | wyższa cena, bardziej złożony |

Diesel jest standardem tam, gdzie agregat ma pracować długo i często; benzyna — do sporadycznego użytku domowego; gaz — gdy zależy nam na ciszy i czystości spalin.

## Typy według konstrukcji prądnicy

To rozróżnienie jest **kluczowe** dla zasilania elektroniki.

### Agregat klasyczny (z AVR)

Prądnica wytwarza napięcie bezpośrednio. Kształt napięcia odbiega od idealnej sinusoidy — współczynnik zniekształceń **THD do 10–15 %**. Częstotliwość zależy od obrotów silnika i waha się przy zmianie obciążenia.

Nadaje się do odbiorników rezystancyjnych i silnikowych: grzałki, oświetlenie, pompy, elektronarzędzia.

### Agregat inwerterowy

Prąd z prądnicy jest najpierw prostowany, a następnie odtwarzany przez falownik (inwerter) jako **czysta sinusoida — THD poniżej 3 %**, ze stabilną częstotliwością 50 Hz. Silnik dostosowuje obroty do obciążenia (ekonomiczny tryb eco), więc agregat jest cichszy i mniej pali.

> **Wskazówka.** Do zasilania komputerów, telewizorów, kotłów z elektroniką, sterowników pompy ciepła i innych odbiorników wrażliwych wybieraj agregat **inwerterowy**. Klasyczny może uszkodzić zasilacze lub zakłócać pracę sterowników.

## Agregaty z ATS

ATS (ang. *Automatic Transfer Switch*) to automatyka, która sama wykrywa zanik sieci, uruchamia agregat i przełącza na niego instalację, a po powrocie sieci wraca i wyłącza agregat. Agregat z fabrycznym ATS jest droższy, ale działa bez obecności człowieka. Szerzej w rozdziale 16-05.

## Chłodzenie

- **Powietrzem** — prostsze, tańsze, lżejsze; standard w agregatach do kilkunastu kW. Wymaga dobrego przewiewu.
- **Cieczą** — jak w samochodzie; cichsze, lepiej znosi pracę ciągłą i wysokie moce. Stosowane w agregatach przemysłowych.

## Parametry, na które patrzymy

- **Moc znamionowa (ciągła)** — moc, jaką agregat utrzyma bez końca.
- **Moc maksymalna (szczytowa)** — wyższa, dostępna tylko krótko (np. do rozruchu silników).
- **COP / PRP / LTP** — klasy mocy wg ISO 8528:
  - *COP* (Continuous Operating Power) — praca ciągła przy stałym obciążeniu, bez ograniczenia godzin.
  - *PRP* (Prime Power) — praca ciągła przy obciążeniu zmiennym, nieograniczona liczba godzin.
  - *LTP* (Limited Time Power) — moc awaryjna, ograniczona do ok. 500 h/rok.
- **Klasa jakości napięcia G1–G4** — im wyżej, tym bardziej stabilne napięcie i częstotliwość:

| Klasa | Zastosowanie |
|---|---|
| G1 | odbiorniki niewymagające — oświetlenie, grzałki |
| G2 | odbiorniki ogólnego przeznaczenia, oświetlenie, silniki |
| G3 | elektronika, sprzęt telekomunikacyjny |
| G4 | sprzęt szczególnie wrażliwy (uzgadniane z producentem) |

## Co dalej

➡ [Agregat 1- i 3-fazowy](16-03-jedno-trojfazowy.md)
