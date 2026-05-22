# Instalacja i bezpieczeństwo magazynów

Magazyn LiFePO4 jest bezpieczną technologią, ale to wciąż urządzenie elektryczne dużej mocy z gęsto upakowaną energią. Prawidłowe miejsce montażu, komplet zabezpieczeń i poprawne uruchomienie decydują o tym, czy będzie pracował bezawaryjnie przez kilkanaście lat.

## Miejsce montażu

- **Pomieszczenie suche** — kotłownia, pomieszczenie techniczne, garaż ogrzewany; bez ryzyka zalania i kondensacji
- **Temperatura** — optymalnie 10–25 °C; w tym zakresie magazyn pracuje z najwyższą sprawnością i żyje najdłużej
- **Wentylacja** — swobodny przepływ powietrza wokół obudowy, brak zabudowy szczelnej
- **Z dala od źródeł ciepła** — nie obok kotła, komina, nasłonecznionej ściany południowej
- **Nie w sypialni** — magazyn (zwłaszcza z wentylatorami) montuje się w pomieszczeniu, w którym nikt nie śpi

> **OSTRZEŻENIE — temperatura ujemna.** Magazynu LiFePO4 nie wolno ładować poniżej 0 °C — grozi to trwałym uszkodzeniem ogniw (lithium plating) i ryzykiem zwarcia wewnętrznego. Nieogrzewany garaż czy nieocieplona przybudówka zimą to złe miejsce. Wybieraj pomieszczenie, w którym przez cały rok utrzymuje się dodatnia temperatura, nawet jeśli BMS sam zablokuje ładowanie w mrozie.

## Mocowanie

- **Ścienne** — uchwyty fabryczne, ściana nośna o odpowiedniej wytrzymałości (moduły bywają ciężkie)
- **Stojące** — szafy bateryjne i moduły wolnostojące na stabilnym, równym podłożu
- Magazyn musi być zabezpieczony przed przewróceniem i przypadkowym uderzeniem

## Zabezpieczenia

- **Bezpiecznik DC** — w obwodzie stałoprądowym między magazynem a inwerterem, dobrany do prądu i napięcia DC
- **Rozłącznik bezpieczeństwa** — umożliwia szybkie, beznapięciowe odłączenie magazynu (serwis, pożar, ewakuacja)
- **SPD** — ochrona przepięciowa po stronie DC i AC

Aparaty muszą być przeznaczone do prądu stałego — wyłącznik AC nie gasi łuku DC i może ulec uszkodzeniu.

## Ochrona przeciwpożarowa

- **LiFePO4** — chemia stabilna termicznie, niskie ryzyko pożaru ogniwa; mimo to zaleca się czujnik dymu i czujnik temperatury w pomieszczeniu z magazynem
- **NMC** — wymaga większej ostrożności ze względu na ryzyko thermal runaway; oddzielenie od pomieszczeń mieszkalnych, dobre chłodzenie, monitoring temperatury
- Pomieszczenie z magazynem powinno mieć dostęp dla straży pożarnej i nie być zastawione

> **OSTRZEŻENIE — thermal runaway.** Ogniwa NMC po uszkodzeniu lub przeładowaniu mogą wejść w samopodtrzymującą się reakcję egzotermiczną, której nie da się szybko ugasić. Dla magazynów NMC traktuj ochronę ppoż i separację od części mieszkalnej jako wymóg, nie opcję. Magazyny LFP są pod tym względem dużo bezpieczniejsze, ale czujka dymu i tak jest tania i warta montażu.

## Uziemienie

Metalowe obudowy magazynu i inwertera bateryjnego muszą być połączone z uziemieniem ochronnym instalacji. Uziemienie odprowadza prądy upływu i jest warunkiem działania ochrony przeciwporażeniowej. Połączenie wyrównawcze wykonuje się zgodnie z instrukcją producenta i przepisami instalacyjnymi.

## Etykiety i informacja dla służb

- Etykiety ostrzegawcze na obudowie i przy rozdzielnicy: obecność magazynu energii, napięcie DC, lokalizacja rozłącznika
- Oznaczenie miejsca głównego odłącznika magazynu — czytelne dla ratowników
- Instrukcja postępowania dla straży pożarnej (typ ogniw, sposób odłączenia, zagrożenia) dostępna przy instalacji

## Pierwsze uruchomienie

1. Sprawdzenie poprawności połączeń DC i AC, biegunowości i momentów dokręcenia
2. Załączenie zgodnie z procedurą producenta (kolejność: rozłączniki, BMS, inwerter)
3. **Konfiguracja BMS** — parametry ogniw, progi napięć, limity prądu i temperatury
4. **Kalibracja SoC** — pełny cykl ładowania, by BMS poprawnie określił 100% i 0%
5. Konfiguracja trybu pracy inwertera (autokonsumpcja, backup, arbitraż taryfowy) i parametrów współpracy z siecią

## Konserwacja i monitoring

- Magazyn **LiFePO4 jest praktycznie bezobsługowy** — brak elektrolitu do uzupełniania, brak czynności okresowych poza wzrokową kontrolą
- Okresowe oględziny: czystość, brak śladów przegrzania, dokręcenie zacisków mocy
- **Monitoring przez aplikację** — SoC, SoH, temperatura, liczba cykli, alarmy BMS; warto śledzić trend pojemności
- Aktualizacje oprogramowania inwertera i BMS zgodnie z zaleceniami producenta

## Utylizacja i recykling

Akumulatory są odpadem niebezpiecznym. Zużytego magazynu nie wolno wyrzucać z odpadami komunalnymi — przekazuje się go do punktu zbiórki lub producentowi w ramach obowiązku odbioru. Ogniwa litowe podlegają recyklingowi: odzyskuje się lit, żelazo, miedź i aluminium. Część zużytych ogniw trafia do tzw. drugiego życia (second life) w mniej wymagających zastosowaniach stacjonarnych.

## Co dalej

➡ [Przykłady i ekonomia magazynów](18-06-przyklady-ekonomia.md)
