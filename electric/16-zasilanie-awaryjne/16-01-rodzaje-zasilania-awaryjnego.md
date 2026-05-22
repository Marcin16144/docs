# Rodzaje zasilania awaryjnego

Gdy znika napięcie w sieci, dom może czerpać energię z kilku różnych źródeł rezerwowych. Różnią się one czasem podtrzymania, mocą, kosztem i wygodą obsługi.

## Cztery główne klasy rozwiązań

### UPS — zasilacz bezprzerwowy

UPS (ang. *Uninterruptible Power Supply*) podtrzymuje zasilanie z akumulatora **bez przerwy** — odbiornik nie zauważa zaniku sieci. Czas podtrzymania to zwykle **minuty** (kilka–kilkadziesiąt), bo akumulator jest mały.

Trzy topologie:

- **Offline (standby)** — najtańszy; przy zaniku sieci przełącza się na baterię w 4–10 ms. Wystarcza dla komputera.
- **Line-interactive** — dodatkowo stabilizuje napięcie (AVR) bez przechodzenia na baterię przy małych wahaniach. Najpopularniejszy do domu i małego biura.
- **Online (podwójna konwersja)** — odbiornik jest zawsze zasilany z falownika; zero czasu przełączania, idealna sinusoida. Najdroższy, do serwerów i sprzętu wrażliwego.

### Agregat prądotwórczy

Agregat zamienia paliwo na prąd. Czas pracy liczony jest w **godzinach, a nawet dniach** — ogranicza go tylko zapas paliwa. Pozwala zasilić cały dom, ale generuje hałas i spaliny.

### Magazyn energii z fotowoltaiką

Akumulator (zwykle litowy) ładowany z PV lub z sieci. Czas podtrzymania to **godziny**, działa **w ciszy i bez spalin**, automatycznie. Magazyn można doładowywać ze słońca nawet podczas blackoutu (jeśli falownik to obsługuje).

### Instalacja off-grid

Dom całkowicie odcięty od sieci — własna PV, duży magazyn i często agregat jako rezerwa zimowa. Rozwiązanie dla lokalizacji bez przyłącza.

## Tabela porównawcza

| Cecha | UPS | Agregat | Magazyn + PV | Off-grid |
|---|---|---|---|---|
| Czas podtrzymania | minuty | godziny–dni | godziny | stale (sezonowo) |
| Typowa moc | 0,5–3 kVA | 2–20 kVA | 3–10 kW | 5–15 kW |
| Koszt | niski–średni | średni | wysoki | bardzo wysoki |
| Hałas | brak | duży | brak | brak/mały |
| Automatyzacja | pełna (bezprzerwowo) | ręczna lub ATS | pełna | pełna |
| Paliwo | nie | tak | nie | nie (agregat: tak) |
| Spaliny | nie | tak | nie | nie |

## Kiedy co stosować

- **Komputer, router, kocioł, alarm** — UPS line-interactive. Liczy się brak przerwy, nie długi czas.
- **Cały dom przy długim blackoucie** — agregat prądotwórczy. Jedyne źródło dające moc i czas jednocześnie.
- **Komfort i ekologia, częste krótkie zaniki** — magazyn energii z PV. Cicho, automatycznie, bez paliwa.
- **Brak przyłącza energetycznego** — instalacja off-grid (PV + magazyn + agregat rezerwowy).

Rozwiązania można łączyć: magazyn obsługuje krótkie zaniki bezgłośnie, a agregat dołącza się dopiero przy długim blackoucie.

> **Wskazówka.** UPS i agregat świetnie się uzupełniają: UPS pokrywa kilka pierwszych minut bez przerwy, zanim agregat zostanie uruchomiony i się ustabilizuje.

## Co dalej

➡ [Agregaty — budowa i typy](16-02-agregaty-budowa-typy.md)
