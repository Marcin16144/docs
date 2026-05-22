# Net-billing — rozliczenie prosumenckie od 2022

## Zmiana systemu z 1.04.2022

Od **1 kwietnia 2022** w Polsce obowiązuje system **net-billing** (rozliczenie wartościowe). Wcześniej obowiązywał **net-metering** (rozliczenie ilościowe 1:0,8 — za każdą 1 kWh oddaną odbierałeś 0,8 kWh).

| Instalacja | System |
|---|---|
| Zgłoszona do 31.03.2022 | net-metering (do 15 lat od uruchomienia) |
| Zgłoszona od 1.04.2022 | **net-billing** |

## Jak działa net-billing

1. Energia z PV wyprodukowana **w domu** = autokonsumpcja — zerowy koszt.
2. Nadwyżka **oddana do sieci** jest wyceniana po cenie **RCEm** (Rynkowa Cena Energii — miesięczna ważona) i zasila **„depozyt prosumencki"**.
3. Energia **pobrana z sieci** rozliczana po cenie taryfowej (G11/G12) ~0,80 zł/kWh brutto + opłaty dystrybucyjne.
4. Depozyt prosumencki możesz wykorzystywać przez **12 miesięcy** na pokrycie rachunków.
5. Po 12 miesiącach **nadwyżka** depozytu wraca jako **zwrot 20 % w gotówce** (na konto). Reszta przepada.

## Cena RCEm

RCEm (Rynkowa Cena Energii — *miesięczna*) jest publikowana przez PSE/TGE co miesiąc. Wahania historyczne:

| Okres | RCEm |
|---|---|
| 2022 (kryzys energetyczny) | 600-800 zł/MWh |
| 2023 średnia | 400-500 zł/MWh |
| 2024-2025 średnia | 200-400 zł/MWh |
| Lato (nadprodukcja PV) | 100-250 zł/MWh |

Od 1.07.2024 wprowadzono **godzinowy RCE** (RCEg) — wybór nowych prosumentów. Wartość godzinowa jest publikowana co godzinę, w południe latem często **bliska zera lub ujemna** (gdy wszystkie polskie PV produkują nadwyżkę).

## Wartość energii dla prosumenta

Kluczowa różnica:

| Energia | Wartość dla Ciebie |
|---|---|
| **Zużyta na bieżąco** w domu | ~0,80 zł/kWh (oszczędność na taryfie G11) |
| **Oddana do sieci** w net-billing | ~0,35 zł/kWh (cena RCEm + zwrot) |

**Wniosek:** energia w domu jest warta ponad 2× więcej niż w sieci. Dlatego **autokonsumpcja jest kluczowa** — patrz [12-02 Dobór mocy](12-02-dobor-mocy.md).

## Strategie zwiększania autokonsumpcji

- **Pralka, zmywarka, suszarka w południe** (timery)
- **Bojler elektryczny sterowany** z nadwyżek (przekaźnik sterowany przez inwerter lub Home Assistant)
- **Pompa ciepła sterowana SG-Ready** — preferuje pracę w godzinach PV
- **Klimatyzacja** w lato — chłodzi dom gdy PV produkuje
- **Ładowanie EV w domu** w godzinach 11-15
- **Magazyn energii** — pojemnik na nadwyżki

## Procedura zgłoszenia nowej PV

1. **Wniosek do OSD** (PGE, Tauron, Enea, Energa, innogy itp.) — formularz „zgłoszenie mikroinstalacji" + schemat
2. OSD ma **30 dni** na rozpatrzenie (zwykle akceptacja domyślna)
3. **Montaż** instalacji — przez firmę z uprawnieniami SEP G1 + UDT
4. **Protokół odbioru** + oświadczenie kierownika robót
5. **Zgłoszenie zakończenia** do OSD — wnioskujesz o **licznik dwukierunkowy** (zwykle mierzy energię w obu kierunkach)
6. OSD **plombuje** + uruchamia rozliczenie net-billing (do 30 dni)

Dla instalacji do **50 kWp** nie potrzeba pozwolenia na budowę — wystarczy zgłoszenie. Powyżej 50 kWp — instalacja przemysłowa z koncesją URE.

## Dotacje

**Mój Prąd** — program NFOŚ, kolejne edycje:

- **Mój Prąd 5** (zamknięty 2024): 7000 zł do PV + 16 000 zł do magazynu + 5000 zł do EMS/HEMS
- **Mój Prąd 6** (2024-2025): dofinansowanie do magazynów ciepła i energii (dla istniejących prosumentów)
- **Czyste Powietrze** — łącznie do 135 000 zł dla termomodernizacji + źródła ciepła (osoby fizyczne, próg dochodowy)

Sprawdzaj zawsze bieżące zasady na **gov.pl/web/nfosigw**.

## Co dalej

➡ [Magazyn energii](12-05-magazyn.md)
