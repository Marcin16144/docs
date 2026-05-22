# Projekt: garaż z warsztatem

## Założenia

| Parametr | Wartość |
|---|---|
| Powierzchnia | 40 m² (garaż wolnostojący 4×10 m) |
| Przeznaczenie | parkowanie auta + warsztat hobbystyczny |
| Wyposażenie | spawarka 5 kW, kompresor 2,2 kW, szlifierka, ładowarka EV 11 kW |
| Ogrzewanie | nagrzewnica elektryczna 3 kW (sezonowo) |
| Przyłącze | 3-fazowe 16 A (z domu głównego, kabel YKY 5×6 mm² 20 m) |
| Układ sieci | TN-S (z domu) |

## Bilans mocy

| Odbiornik | Moc [kW] |
|---|---|
| Oświetlenie LED IP65 (10× 80 W) | 0,8 |
| Gniazda 230 V (6 szt., warsztat) | 2,0 |
| Spawarka 3-faz | 5,0 |
| Kompresor | 2,2 |
| Ładowarka EV wallbox 3F | 11,0 |
| Nagrzewnica | 3,0 |
| Brama (siłownik) | 0,3 |
| **Suma Pi** | **~24 kW** |
| **Pz, kz 0,4** | **~10 kW** (silniki nie pracują równocześnie z EV) |

Prąd na fazę: I = 10 000 / (1,732 · 400 · 0,9) ≈ **16 A** → przyłącze 3F 16 A wystarczy z uwagą na **selektywność** ładowarki i innych obwodów.

## Lista 6 obwodów

| Nr | Opis | MCB | RCD | Kabel |
|---|---|---|---|---|
| 1 | Oświetlenie (10× panel LED IP65) | B10 | RCBO 30 mA | YDY 3×1,5 |
| 2 | Gniazda warsztat 1 (3 szt.) | B16 | RCBO 30 mA | YDY 3×2,5 |
| 3 | Gniazda warsztat 2 (3 szt.) | B16 | RCBO 30 mA | YDY 3×2,5 |
| 4 | Gniazdo siłowe 3F 16 A CEE | C16/3P | RCD 4P 30 mA typ A | YDY 5×2,5 |
| 5 | Ładowarka EV 3F (wallbox) | C16/3P | RCD 4P 30 mA **typ B** ¹ | YDY 5×6 |
| 6 | Brama + nagrzewnica | B16 | RCBO 30 mA | YDY 3×2,5 |

¹ Wallbox z wbudowanym RDC-DD (DC residual detection 6 mA) dopuszcza RCD typu A; bez RDC-DD wymagany typ B.

## Schemat ideowy podrozdzielnicy

```
   Z domu: YKY 5×6 mm², 20 m, MCB w domu C25 3P
        │
        ▼
   ┌─────────────────────────────────────────┐
   │ Rozdzielnica RG  24 modułów IP54 n/t    │
   ├─────────────────────────────────────────┤
   │ FR 3P+N 20 A                            │
   │ SPD T2 4P                               │
   │                                         │
   │ F1 RCBO B10        oświetlenie          │
   │ F2 RCBO B16        gniazda 1            │
   │ F3 RCBO B16        gniazda 2            │
   │ F4 RCD typ A 30 mA + C16 3P  CEE        │
   │ F5 RCD typ B 30 mA + C16 3P  EV         │
   │ F6 RCBO B16        brama + grzanie      │
   │                                         │
   │ Listwa PE  (do uziomu lokalnego ≤ 30 Ω) │
   │ Listwa N                                │
   └─────────────────────────────────────────┘
```

## Bezpieczeństwo p-poż

- **Gaśnica proszkowa ABC 6 kg** przy drzwiach.
- **Czujnik dymu** + sygnalizacja akustyczna.
- **Wentylacja grawitacyjna lub mechaniczna** (auta z LPG, opary spawania).
- **Wyłącznik p-poż** przy drzwiach wejściowych (FR z aparatem napięciowym lub stycznik z przyciskiem grzybkowym).
- Materiały EI60 wokół przepustów kablowych.

## Wallbox EV — szczegóły

- Model przykładowy: **Wallbox Pulsar Plus 11 kW**, RFID, OCPP.
- Mocowanie: ściana, wysokość 110–140 cm.
- Kabel YDY 5×6 mm² — spadek napięcia przy 16 A, 20 m: ΔU ≈ 1,1% (OK).
- Wymagane: MCB C16 3P, RCD 30 mA typ A z RDC-DD (lub typ B), SPD T2.
- Pomiar pętli zwarcia na wallbox — Zs ≤ 1,15 Ω (dla C16).

## Lista materiałów

| Pozycja | Ilość | Cena ~ |
|---|---|---|
| Rozdzielnica 24-mod IP54 n/t | 1 | 350 zł |
| RCBO B10/B16 30 mA | 4 | 800 zł |
| RCD 4P 30 mA typ A | 1 | 350 zł |
| RCD 4P 30 mA typ B | 1 | 1 200 zł |
| MCB C16 3P | 2 | 200 zł |
| SPD T2 4P | 1 | 400 zł |
| Wallbox 11 kW | 1 | 4 500 zł |
| Gniazdo CEE 16 A 3F | 1 | 80 zł |
| Kabel YKY 5×6 (z domu) | 25 m | 500 zł |
| Kabel YDY 3×2,5 | 60 m | 165 zł |
| Kabel YDY 5×6 (do EV) | 8 m | 160 zł |
| Panele LED 80 W IP65 | 10 | 1 000 zł |
| Gniazda IP44 + ramki | 6 | 240 zł |
| **Materiały razem** | | **~9 950 zł** |

## Co dalej

➡ [Fotowoltaika 5 kWp](15-04-pv-5kwp.md)
