# On-grid, off-grid, hybryda

Trzy podstawowe koncepcje zasilania z udziałem fotowoltaiki (PV). Wybór architektury decyduje o niezawodności, koszcie i tym, czy dom ma prąd w czasie awarii sieci.

## On-grid — instalacja współpracująca z siecią

Klasyczna fotowoltaika podłączona do sieci elektroenergetycznej, **bez magazynu energii**.

- PV produkuje energię, dom zużywa ją na bieżąco (autokonsumpcja).
- Nadwyżki trafiają do sieci, niedobory pobierane są z sieci.
- Sieć pełni rolę „nieskończonego magazynu" (rozliczenie net-billing / net-metering).

**Kluczowa cecha:** przy zaniku napięcia w sieci instalacja on-grid **przestaje działać** — nawet w słoneczny dzień dom jest bez prądu. Wynika to z funkcji **anti-islanding** (zabezpieczenie przed pracą wyspową): inwerter sieciowy musi się wyłączyć, gdy zniknie napięcie sieci, aby nie zasilać uszkodzonego odcinka i nie zagrażać ekipom naprawczym.

## Off-grid — instalacja całkowicie niezależna

System wyspowy, **bez żadnego połączenia z siecią** publiczną.

- Składa się z PV + magazynu energii + ewentualnie agregatu prądotwórczego.
- Cała energia musi pochodzić z własnych źródeł — nie ma awaryjnego poboru z sieci.
- Stosowany tam, gdzie przyłącze jest niemożliwe lub nieopłacalne: działki rekreacyjne, domki w górach, schroniska, obiekty oddalone od linii energetycznych.

**Konsekwencja:** system off-grid trzeba **przewymiarować** — PV i magazyn muszą pokryć zużycie nawet w pochmurne dni. W warunkach polskich zimą produkcja PV jest dramatycznie niska, dlatego niemal zawsze potrzebny jest agregat jako źródło rezerwowe.

## Hybryda — PV + magazyn + sieć jako backup

Rozwiązanie łączące zalety obu podejść.

- PV + magazyn energii + przyłącze do sieci.
- Magazyn ładowany jest z PV, a w razie potrzeby także z sieci (np. w taniej taryfie nocnej).
- W normalnej pracy dom zasila się z PV i magazynu, a sieć dopełnia niedobory.
- Nadwyżki mogą być oddawane do sieci.
- **Przy zaniku sieci system działa dalej** — magazyn i PV zasilają wydzielone obwody (funkcja backup / EPS).

Pojęcie **„częściowo z sieci"** oznacza właśnie hybrydę pracującą z priorytetem autokonsumpcji: dom korzysta przede wszystkim z własnej energii, a sieć traktuje jako uzupełnienie i zabezpieczenie.

## Tabela porównawcza

| Cecha | On-grid | Off-grid | Hybryda |
|---|---|---|---|
| Przyłącze do sieci | tak | nie | tak |
| Magazyn energii | nie | tak (duży) | tak |
| Praca przy zaniku sieci | **nie** | tak (zawsze) | tak (backup) |
| Niezależność energetyczna | niska | pełna | wysoka |
| Koszt początkowy | najniższy | wysoki | wysoki |
| Niezawodność zasilania | zależna od sieci | zależna od pogody | najwyższa |
| Potrzeba agregatu | nie | często (zima) | opcjonalnie |
| Kiedy stosować | jest stabilna sieć, cel — obniżenie rachunku | brak możliwości przyłącza | częste awarie sieci, dążenie do niezależności |

## Jak wybrać

- **On-grid** — gdy sieć jest stabilna, a celem jest wyłącznie obniżenie rachunków za prąd. Najtańsze wejście w PV.
- **Off-grid** — gdy doprowadzenie przyłącza jest niemożliwe lub kosztuje dziesiątki tysięcy złotych. Wymaga akceptacji ograniczeń (oszczędne gospodarowanie energią, agregat zimą).
- **Hybryda** — gdy zależy nam na zasilaniu krytycznych odbiorników podczas awarii, a jednocześnie chcemy korzystać z sieci. Najbardziej uniwersalny, ale najdroższy wariant.

> **Uwaga.** Sama instalacja on-grid nie zapewnia zasilania awaryjnego — to częste nieporozumienie. Aby mieć prąd przy zaniku sieci, potrzebny jest magazyn i inwerter z funkcją backup, czyli architektura hybrydowa lub off-grid.

## Co dalej

➡ [Bilans energetyczny off-grid](17-02-bilans-energetyczny.md)
