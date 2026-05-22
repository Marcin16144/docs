# Technologie magazynowania energii

Magazyn energii w domu to przede wszystkim akumulator elektrochemiczny, który gromadzi nadwyżkę energii z fotowoltaiki i oddaje ją wtedy, gdy słońca brakuje. Technologia ogniwa decyduje o trwałości, bezpieczeństwie, masie i cenie całego systemu.

## Akumulatory litowe

Dominująca grupa w nowoczesnych instalacjach domowych. Wysoka gęstość energii, długa żywotność i głębokie rozładowanie. Wewnątrz rodziny litowej liczą się dwa warianty chemii katody.

### LiFePO4 / LFP — litowo-żelazowo-fosforanowe

To dziś **domyślny wybór do domu**. Katoda fosforanowa jest stabilna termicznie — nawet uszkodzone ogniwo nie wpada łatwo w niekontrolowaną reakcję.

- **Bezpieczeństwo** — najwyższe wśród ogniw litowych, brak gwałtownego thermal runaway
- **Żywotność** — 6000 cykli i więcej, czyli realnie 15–20 lat pracy
- **Głębokie rozładowanie** — DoD 90–100% bez szkody dla ogniwa
- **Stabilne napięcie** — płaska charakterystyka rozładowania
- **Wada** — niższa gęstość energii niż NMC (cięższy i większy moduł o tej samej pojemności)

### NMC — litowo-niklowo-manganowo-kobaltowe

Chemia znana z aut elektrycznych i elektroniki. Gęstsza energetycznie, lżejsza, ale mniej trwała i mniej bezpieczna.

- **Gęstość energii** — wyższa, mniejszy i lżejszy moduł
- **Żywotność** — krótsza, typowo 3000–4000 cykli
- **Ryzyko** — przy uszkodzeniu, przeładowaniu lub przegrzaniu możliwy thermal runaway (samopodtrzymujący się pożar ogniwa)
- **Zawartość kobaltu** — droższy surowiec, kontrowersyjny wydobyciem

> **OSTRZEŻENIE — thermal runaway NMC.** Ogniwa NMC po przebiciu mechanicznym, zwarciu wewnętrznym lub przeładowaniu mogą wejść w niekontrolowaną reakcję egzotermiczną. Temperatura rośnie lawinowo, wydzielają się palne i toksyczne gazy, a pożar jest bardzo trudny do ugaszenia. Magazyn NMC w domu wymaga szczególnej dbałości o chłodzenie, sprawny BMS i odpowiednie miejsce montażu z dala od materiałów palnych.

## Akumulatory ołowiowo-kwasowe

Najstarsza technologia, dawniej standard w systemach off-grid i UPS. Dziś **wycofywana** z nowych instalacji domowych z PV.

- **AGM** (Absorbent Glass Mat) — elektrolit w macie szklanej, bezobsługowe, odporne na drgania
- **Żelowe** (GEL) — elektrolit w postaci żelu, dłuższa żywotność niż AGM, gorzej znoszą wysokie prądy
- **Zalety** — niski koszt zakupu, sprawdzona technologia, dostępność
- **Wady** — duża masa, mała gęstość energii, tylko 300–500 cykli, DoD ograniczone do ok. 50% (głębsze rozładowanie drastycznie skraca żywotność)

W praktyce realny koszt energii z magazynu ołowiowego, liczony przez cały cykl życia, bywa wyższy niż z LiFePO4 — mimo niższej ceny zakupu.

## Inne technologie

| Technologia | Charakterystyka | Zastosowanie domowe |
|---|---|---|
| Sodowo-jonowe (Na-ion) | Nowość rynkowa, tanie surowce, dobra praca w mrozie, brak litu i kobaltu | Rosnące — obiecująca alternatywa dla LFP |
| Przepływowe (vanadowe) | Energia w zbiornikach elektrolitu, bardzo długa żywotność, skalowalne | Głównie przemysł, rzadko w domach |
| Magazyny ciepła | Zasobnik buforowy CWU, ogrzewanie podłogowe jako magazyn | Pośrednie — magazynują energię cieplną, nie elektryczną |
| Wodorowe | Elektrolizer + ogniwo paliwowe, magazyn sezonowy | Eksperymentalne, niska sprawność round-trip, kosztowne |

## Tabela porównawcza technologii

| Parametr | LiFePO4 / LFP | NMC | Ołowiowe AGM/GEL | Sodowo-jonowe |
|---|---|---|---|---|
| Gęstość energii [Wh/kg] | 90–160 | 150–250 | 30–50 | 75–160 |
| Liczba cykli | 6000+ | 3000–4000 | 300–500 | 3000–5000 |
| Użyteczne DoD | 90–100% | 80–90% | ~50% | 90–100% |
| Cena za kWh pojemności | średnia | wyższa | niska (zakup) | niska–średnia |
| Bezpieczeństwo | bardzo wysokie | umiarkowane | wysokie | wysokie |
| Temperatura pracy | rozładowanie -20…+55 °C; ładowanie 0…+45 °C | -20…+55 °C, gorzej znosi ciepło | -15…+45 °C | -30…+45 °C |

## Dlaczego LiFePO4 wygrywa w domach

Magazyn domowy pracuje zwykle w jednym cyklu na dobę przez wiele lat. Liczy się więc nie maksymalna gęstość energii, lecz **trwałość, bezpieczeństwo i koszt energii w całym okresie eksploatacji**.

- Dom nie potrzebuje skrajnie lekkiego ogniwa — moduł stoi w pomieszczeniu technicznym, masa nie jest problemem jak w samochodzie
- 6000 cykli przy jednym cyklu dziennie to ponad 16 lat pracy — magazyn przeżyje gwarancję inwertera
- Stabilność termiczna LFP oznacza spokojny sen — brak ryzyka gwałtownego pożaru ogniwa
- Pełne DoD pozwala kupić mniejszy nominalnie magazyn przy tej samej energii użytkowej

Z tych powodów praktycznie wszystkie nowe domowe magazyny montowane od kilku lat to ogniwa LiFePO4. NMC trafia tam, gdzie krytyczna jest objętość lub masa; ołów został przy starych systemach off-grid i tanich UPS.

## Co dalej

➡ [Parametry magazynów — co czytać w karcie katalogowej](18-02-parametry.md)
