# Przykłady projektowe

Dwa kompletne projekty: domek letniskowy off-grid bez przyłącza oraz dom hybrydowy pracujący częściowo z sieci. Każdy zawiera bilans, schemat i szacunek kosztów.

## Przykład A — domek letniskowy off-grid bez przyłącza

Działka rekreacyjna bez możliwości doprowadzenia przyłącza. Użytkowanie głównie wiosna–jesień, sporadycznie zimą.

### Bilans energetyczny

| Odbiornik | Moc [W] | Czas [h/dobę] | Energia [Wh] |
|---|---|---|---|
| Oświetlenie LED | 50 | 5 | 250 |
| Lodówka (cykl ~33%) | 130 | 7 | 910 |
| Pompa wody | 500 | 0,4 | 200 |
| Laptop / TV | 90 | 4 | 360 |
| Router, ładowarki, drobne | — | — | 280 |
| **Suma + 15% zapasu** | | | **≈ 3000 Wh = 3 kWh/dobę** |

Dobór według wzorów z sekcji 17-02 (sezon wiosenny, Hsr ≈ 3 h, η ≈ 0,7, autonomia 2 dni, DoD 0,8):

```
P_PV       = 3 / (3 · 0,7) ≈ 1,4 kWp  →  przyjęto 2 kWp
C_magazyn  = (3 · 2) / 0,8 = 7,5 kWh  →  przyjęto 5 kWh (+ agregat zimą)
```

### Zestawienie komponentów

| Element | Dobór |
|---|---|
| Panele PV | 2 kWp (np. 4 × 500 W) |
| Regulator ładowania | MPPT |
| Magazyn | 5 kWh LiFePO4, system 48 V |
| Inwerter | wyspowy 3 kW, czysta sinusoida, szczyt ~6 kW |
| Agregat | 2 kVA — backup zimowy i serie dni bez słońca |

### Schemat instalacji

```
   [PANELE PV 2 kWp]
          |  DC
    ┌─────┴──────┐
    | REGULATOR  |
    |   MPPT     |
    └─────┬──────┘
          |  48 V DC
    ┌─────┴───────────────┐        ┌──────────────┐
    |  MAGAZYN LiFePO4    |        |  AGREGAT     |
    |  5 kWh / 48 V       |        |  2 kVA       |
    └─────┬───────────────┘        └──────┬───────┘
          |  48 V DC                      | AC (ładowanie)
    ┌─────┴───────────────────────────────┴──┐
    |     INWERTER WYSPOWY / ŁADUJĄCY 3 kW   |
    └─────────────────┬──────────────────────┘
                      | 230 V AC
              ┌───────┴────────┐
              | ROZDZIELNICA   |
              | DOMKU          |
              └─┬────┬────┬────┘
            ośw. lodówka pompa + gniazda
```

### Koszt orientacyjny

Panele, regulator MPPT, magazyn 5 kWh LiFePO4, inwerter wyspowy, agregat, okablowanie, zabezpieczenia i montaż — łącznie **ok. 25–35 tys. zł**. Magazyn jest najdroższym pojedynczym elementem.

> **Wskazówka.** W domku off-grid największą oszczędność daje ograniczenie zużycia: lodówka klasy A, oświetlenie wyłącznie LED i rezygnacja z elektrycznego grzania (gaz, drewno). Każdy zaoszczędzony kWh to mniejszy magazyn i mniejsze PV.

## Przykład B — dom hybrydowy częściowo z sieci

Całoroczny dom jednorodzinny z istniejącym przyłączem 3-fazowym (instalacja jak w sekcji 15-01). Cel: autokonsumpcja PV, magazyn i zasilanie awaryjne obwodów krytycznych.

### Bilans energetyczny

Zużycie domu: **ok. 15 kWh/dobę** (oświetlenie, RTV/AGD, pompa ciepła sezonowo, gotowanie).

| Element systemu | Dobór |
|---|---|
| Panele PV | 8 kWp (dach wschód + zachód, 2 stringi) |
| Inwerter hybrydowy | 10 kW, 3-fazowy, 2 trackery MPPT, wyjście backup |
| Magazyn | 10 kWh LiFePO4 |
| Rozdzielnica backup | obwody krytyczne (poniżej) |

Magazyn 10 kWh pokrywa wieczorne i nocne zużycie domu z autokonsumpcji; przy zaniku sieci zasila przez wiele godzin samą rozdzielnicę backup.

### Rozdzielnica backup — obciążenie

| Obwód krytyczny | Moc [W] |
|---|---|
| Lodówka + zamrażarka | 250 |
| Kocioł CO + pompa obiegowa | 150 |
| Oświetlenie (część domu) | 250 |
| Router + sprzęt sieciowy | 30 |
| 1 obwód gniazd ogólnych | ~3000 (założone obciążenie) |
| **Suma backup** | **≈ 3,7 kW** |

### Schemat integracji

```
                SIEĆ 3-faz (OSD)
                       |
              [licznik 2-kierunkowy]
                       |
              ┌────────┴─────────┐
              | ROZDZIELNICA     |
              | GŁÓWNA  +SPD     |
              └──┬───────────┬───┘
                 |           |
          OBWODY ZWYKŁE   AC-grid → inwerter
        (płyta induk.,        |
         pralka, klima,  ┌────┴──────────────────┐
         pompa ciepła)   | INWERTER HYBRYDOWY    |
        NIE w backup     | 10 kW 3-faz           |
                         | PV | bat | EPS-out    |
                         └─┬─────┬─────┬─────────┘
                       PV  |  bat|     | EPS
                  ┌────────┘  ┌──┘     |
              [PV 8 kWp]  [MAGAZYN     |
               2 stringi   10 kWh]     |
                                  ┌────┴────────────┐
                                  | ROZDZIELNICA    |
                                  | BACKUP ~3,7 kW  |
                                  └┬───┬───┬───┬────┘
                              lodówka CO ośw. router
                                            + obwód gniazd
```

CT w punkcie sprzężenia mierzą przepływ na każdej fazie, umożliwiając priorytet autokonsupcji i ewentualny export limit.

### Koszt i ekonomia

Inwerter hybrydowy 10 kW, panele 8 kWp, magazyn 10 kWh, rozdzielnica backup, CT, zabezpieczenia AC/DC, montaż i konfiguracja — łącznie **ok. 50–70 tys. zł**.

Ekonomia opiera się na trzech efektach:
- **autokonsumpcja** — energia z PV/magazynu zamiast droższego poboru z sieci,
- **arbitraż taryfowy** — ładowanie magazynu w taniej taryfie, rozładowanie w drogiej,
- **wartość niemierzalna** — ciągłość zasilania krytycznych obwodów przy awariach sieci.

> **Uwaga.** Sam magazyn rzadko zwraca się wyłącznie oszczędnością na rachunku w rozsądnym czasie — jego główną wartością jest niezależność i backup. Decyzję podejmuje się świadomie, traktując część kosztu jak inwestycję w niezawodność.

## Podsumowanie sekcji

Off-grid i hybryda to dwa różne cele: pełna niezależność tam, gdzie nie ma sieci, oraz autokonsumpcja z backupem tam, gdzie sieć jest, lecz bywa zawodna. W obu wypadkach projekt zaczyna się od rzetelnego bilansu energetycznego, a kończy na poprawnej integracji z instalacją i zabezpieczeniach po stronie AC i DC.
