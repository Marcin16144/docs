# Centrale SAP adresowalne

## Czym różni się adresowalny od konwencjonalnego

Centrala adresowalna komunikuje się z każdą czujką **indywidualnie** — wie nie tylko, że gdzieś jest alarm, ale dokładnie **która czujka** i w jakim stanie. Komunikacja odbywa się protokołem cyfrowym (właściwym dla każdego producenta) po dwużyłowej pętli.

```
Centrala adresowalna
  ├── Pętla 1 (do 126 adresów):
  │     adresy 1-30   → czujki dymu pętla   1.kondygnacja
  │     adresy 31-60  → czujki dymu pętla   2.kondygnacja
  │     adresy 61-90  → multisensory pętla  klatka
  │     adresy 91-100 → ROP-y
  │     adresy 101-126→ moduły I/O, sygnalizatory adresowalne
  └── Pętla 2 (do 126 adresów): osobny obwód
```

## Pętla — topologia i zalety

**Pętla** (loop) to obwód doprowadzony z centrali, przechodzący przez wszystkie urządzenia i wracający z powrotem do centrali. Najważniejsza cecha: **tolerancja na pojedynczą przerwę**.

Jak działa zabezpieczenie:

1. w normalnym trybie pętla jest zasilana z obu końców równocześnie,
2. na każdej czujce (lub co kilka) jest **izolator zwarciowy** (krótki segment) — odcina uszkodzony fragment,
3. przy przerwie kabla centrala przełącza zasilanie tak, by dotrzeć z obu stron do pozostałych urządzeń,
4. pojedyncza awaria **nie wyłącza całego systemu**, traci się tylko izolowany segment.

Konwencjonalna linia przy przerwie traci wszystkie czujki za miejscem przerwy → adresowalna jest istotnie bardziej niezawodna.

> **Wymóg PN-EN 54-2:** pojedyncza usterka (przerwa, zwarcie) nie może wyłączyć więcej niż 32 czujki. W praktyce realizowane przez izolatory zwarciowe na pętli co kilka urządzeń.

## Adresowanie — DIP, software, auto

| Metoda | Opis | Producenci |
|---|---|---|
| **DIP switch** | fizyczne mikroprzełączniki w gnieździe czujki (1–126) | Polon-Alfa (POLON 6000), Hochiki |
| **Programowanie elektroniczne** | adres zapisywany do czujki w czasie montażu (programator ręczny lub centrala) | Bosch, ESSER, Notifier |
| **Auto-addressing** | centrala automatycznie nadaje adresy w kolejności fizycznej | Schrack Integral, Siemens Cerberus |

## Główne marki na rynku polskim

### Polon-Alfa POLON 6000

Polski lider w obiektach państwowych (szkoły, urzędy, szpitale). Cechy:

- 1–4 pętle adresowalne, do 126 adresów na pętlę (czyli max 504 elementy),
- protokół własny POLON, kompatybilność z czujkami serii 4046, 6046,
- moduły rozszerzeń: MIO-400 (4 wejścia/4 wyjścia), MZ-400 (sterowanie syrenami),
- panel ekranowy LCD 7" + dotykowy w wersji POLON 6000T,
- obsługa do 32 obiektów drogą szeregową (rozbudowa magistralą RS-485),
- **certyfikat CNBOP-PIB**, w pełnym zgodności z PN-EN 54.

### Bosch AVENAR (dawn. Modular 5000 / 8000)

Niemiecka centrala z modułową architekturą. Cechy:

- moduły LSN (Local SecurityNetwork) — pętle do 254 adresów,
- panel dotykowy 5" / 12",
- integracja z BIS (Building Integration System) — pełen BMS,
- typowi partnerzy: czujki Bosch FAP-425 series, FAH-425, ROP-y FMC-300,
- komunikacja BACnet/IP natywnie.

### Schrack Integral EvoxX

Austriacka centrala z najmocniejszą integracją BMS. Cechy:

- do 32 pętli × 250 adresów = 8 000 urządzeń (rzadko spotykane),
- czujki Schrack USA 200/USB 200 (multikryterialne),
- protokoły: BACnet, Modbus, KNX, OPC UA,
- auto-addressing fabryczny,
- typowe instalacje: lotniska, centra handlowe, fabryki.

### ESSER FlexES Control / IQ8Control

Marka grupy Honeywell, niemiecka, popularna w przemyśle. Cechy:

- protokół essernet — kilka central w sieci redundantnej,
- czujki esserbus / IQ8 (samouczące się, kompensacja zabrudzeń),
- obsługa stałych urządzeń gaszących (gazowe FM-200, Inergen).

### Siemens Cerberus PRO FC72x

Stosowane w obiektach klasy premium. Cechy:

- protokół SynoLoop, do 252 elementów na pętlę,
- czujki ASA (Advanced Signal Analysis) — odporne na fałszywe alarmy,
- panel sterowniczy Cerberus PRO Cloud — zdalne zarządzanie.

### Inne marki

- **Notifier ID3000 / Pearl** (Honeywell) — popularne w UK i Polsce,
- **Hochiki Latitude** — wysokiej klasy japońskie czujniki,
- **Inim Previdia Max** — włoska, dobra cena/jakość,
- **Kentec Syncro AS** — UK, do specjalnych zastosowań (statki),
- **Gent by Honeywell Vigilon** — UK, bardzo niezawodne.

## Integracja z BMS / SCADA

Centrale adresowalne komunikują się z systemami zarządzania budynkiem przez:

| Protokół | Typowe zastosowanie | Centrale obsługujące |
|---|---|---|
| **BACnet/IP** (ISO 16484) | klimatyzacja, oświetlenie, BMS | Schrack, Siemens, Bosch AVENAR, ESSER |
| **Modbus TCP/RTU** | systemy przemysłowe, SCADA | większość central poprzez moduł |
| **OPC UA** | Industry 4.0, MES | Schrack, Siemens (przez serwer) |
| **SNMP v3** | monitoring IT, NMS | centrale z modułem TCP/IP |
| **KNX** | automatyka budynkowa | Schrack, Bosch (przez bramę) |

Przykłady akcji integracyjnych:

- alarm pożarowy → BMS wyłącza klimatyzację, otwiera klapy oddymiające, zjeżdża windą na poziom 0 i blokuje drzwi,
- alarm pożarowy → kontrola dostępu zwalnia wszystkie elektrozaczepy (ucieczka),
- czujka czadu w garażu → wentylacja na full + powiadomienie ochronie.

## Konfiguracja — software

Każdy producent ma własne narzędzie:

- Polon-Alfa: **POLON 6000 Designer** — graficzne plany, przypisanie adresów,
- Bosch: **FSP-5000 Programmer** + RPS (Remote Programming Software),
- Schrack: **Integral Designer** — drag-and-drop konfiguracja BMS,
- ESSER: **tools 8000**,
- Siemens: **Cerberus Engineering Tool (CET)**.

Konfigurację robi licencjonowany serwisant producenta — wymaga szkolenia i certyfikatu. Klient otrzymuje wydruk konfiguracji + plany na ścianie centrali (obowiązek PN-EN 54-14).

## Kiedy wybrać adresowalną

- obiekt powyżej **500 m²** lub powyżej 4 stref pożarowych,
- obiekty z obowiązkiem SAP (hotele >50 łóżek, szpitale, biurowce >3 kondygnacje, galerie handlowe),
- integracja z BMS / oddymianiem / kontrolą dostępu,
- obiekty z stałymi urządzeniami gaszącymi (SUG — gazowe, mgłowe) — wymagana dokładna lokalizacja,
- obiekty „klasy premium" — szpitale, lotniska, muzea, centra danych.

> **Koszty:** centrala adresowalna 1-pętlowa ~6 000–12 000 zł, czujki adresowalne 200–500 zł sztuka (vs konwencjonalne 80–150 zł). Bilans: dla obiektu 200 czujek różnica to ~30 000 zł, ale daje precyzyjną lokalizację + integrację.

## Co dalej

➡ [ROP i sygnalizatory](11-03-rop-sygnalizatory.md)
