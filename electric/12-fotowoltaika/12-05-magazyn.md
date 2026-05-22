# Magazyn energii

## Po co magazyn

W systemie **net-billing** każda kWh oddana do sieci jest warta 0,30-0,40 zł, a kupiona — 0,80 zł. Magazyn pozwala **przechowywać własną nadwyżkę** i wykorzystywać ją wieczorem zamiast oddawać do sieci.

Drugie zastosowanie — **zasilanie awaryjne** (gdy zniknie napięcie z sieci, magazyn + inwerter hybrydowy może podtrzymać kluczowe obwody w trybie *backup*).

## Chemia akumulatora

| Typ | Cykli | DoD | Bezpieczeństwo | Cena |
|---|---|---|---|---|
| **LiFePO4 (LFP)** | 6000-8000 | 100 % | wysokie (nieaktywna chemia, niska temperatura) | średnia |
| **NMC (lit-jon)** | 3000-5000 | 90 % | średnie (ryzyko thermal runaway) | wyższa |
| Kwasowo-ołowiowe AGM | 500-1500 | 50 % | wysokie | niska, ale niski TCO |

**LiFePO4 jest standardem** dla magazynów domowych w 2024-2025. Bezpieczne (chemia praktycznie niepalna w warunkach domowych), wytrzymują 100 % rozładowania, długa żywotność ~15-20 lat.

**DoD** (*Depth of Discharge*) — głębokość rozładowania. LFP 100 % = wykorzystujesz całą pojemność.

## Dobór pojemności

Reguła kciuka: **50-100 % zużycia dobowego**.

| Zużycie dobowe domu | Magazyn |
|---|---|
| 8-10 kWh (małe mieszkanie) | 5 kWh |
| 12-15 kWh (typowy dom) | 5-10 kWh |
| 20-30 kWh (dom + pompa ciepła + EV) | 10-15 kWh |

Magazyn większy niż dobowe zużycie ma marginalny zysk — zostaje niewykorzystany latem (gdy produkcja >> zużycie) i nie pomaga zimą (gdy produkcja << zużycie).

## Topologia AC vs DC

### Magazyn DC (DC-coupled)

Akumulator podłączony do **inwertera hybrydowego** przez magistralę DC.

```
PV ─DC─→ inwerter hybrydowy ─AC─→ sieć/dom
              ↓ DC
           magazyn
```

- Sprawność round-trip 92-95 % (jedna konwersja)
- Wymaga inwertera hybrydowego od początku lub wymiany
- Łatwiejszy backup (inwerter steruje wszystkim)

### Magazyn AC (AC-coupled)

Akumulator z własnym inwerterem ładująco-rozładowującym podłączony do sieci AC domu.

```
PV ─DC─→ inwerter PV ─AC─→ sieć/dom
                              ↑
                          inwerter magazynu ↔ akumulator
```

- Sprawność round-trip 85-90 % (dwie konwersje DC-AC-DC-AC)
- **Modernizacja istniejącej instalacji** PV bez wymiany inwertera
- Drożej (dodatkowy inwerter magazynu)
- Tesla Powerwall, Sonnen, Huawei LUNA AC

## Ekonomia

Aktualne ceny (PL, 2024-2025):

| Pojemność | Cena pakietu (akumulator + BMS) | Cena z montażem |
|---|---|---|
| 5 kWh LFP | 8-12 tys. zł | 12-18 tys. zł |
| 10 kWh LFP | 14-22 tys. zł | 20-32 tys. zł |
| 15 kWh LFP | 22-32 tys. zł | 30-45 tys. zł |

**~3-5 zł/Wh** = 3000-5000 zł/kWh — taki jest aktualny zakres cen. Ceny spadają ~10 %/rok.

### Roczny zysk z magazynu 10 kWh

```
Cykli rocznie ~280 (latem 1 cykl, zimą 0)
Energia "uratowana" rocznie: 280 × 10 × 0,9 = 2520 kWh
Wartość: 2520 × (0,80 - 0,35) = ~1100 zł/rok
```

Czas zwrotu: **15-25 lat** bez dotacji, **8-12 lat** z dotacją Mój Prąd 16 000 zł.

Magazyn ekonomicznie sensowny dziś **tylko z dotacją** lub w roli backupu (gdy ważne jest podtrzymanie zasilania).

## Funkcje EMS i HEMS

**EMS** (*Energy Management System*) — wbudowany w inwerter hybrydowy algorytm:

- ładuje magazyn z nadwyżki PV
- rozładowuje wieczorem
- czasem ładuje z sieci w taryfie nocnej G12 (dla taryf dynamicznych z tanim okresem)

**HEMS** (*Home Energy Management System*) — szerszy system zarządzający też pompą ciepła, EV, AGD na podstawie produkcji PV i cen energii. Realizowany przez Home Assistant, EVCC, OpenWB, dedykowane systemy producentów (Solaredge, Huawei).

## Bezpieczeństwo i montaż

- **Pomieszczenie**: garaż / kotłownia / piwnica, temp. 5-35 °C, dobra wentylacja
- **PE i uziemienie** obowiązkowe
- **Czujnik dymu** zalecany w pobliżu
- **Klasa palności** ścian wokół magazynu — większe (>20 kWh) wymagają wydzielonej strefy p-poż
- **Zgłoszenie OSD** dla instalacji magazynu z PV — analogicznie do PV

## Co dalej

➡ [Wstęp do smart home — sekcja 13](../13-smart-home/index.html)
