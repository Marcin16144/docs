# Zasilacze buforowe — PSAC, PSBOC, EN54-4

> Klasyfikacja PN-EN 50131-6 i PN-EN 54-4, dobór prądu znamionowego, monitoring akumulatora, sygnalizacja awarii. Marki: Pulsar, Satel APS, Schrack. Aktualizacja 2026.

## Czym jest zasilacz buforowy

Zasilacz buforowy (ang. *battery backup PSU*) to dedykowane urządzenie łączące w jednej obudowie trzy funkcje:

- **Przekształtnik AC/DC** — zasilanie odbiorników 12 V (czasem 24 V) z sieci 230 V
- **Ładowarka akumulatora** — utrzymanie akumulatora rezerwowego w stanie pełnej gotowości (*float charging*)
- **Przełącznik awaryjny** — automatyczne przejście na zasilanie z akumulatora po zaniku 230 V (bezprzerwowo, czas < 10 ms)

W odróżnieniu od UPS-a (zasilanie 230 V dla komputerów), zasilacz buforowy podaje stałe 12/24 V DC, jest dedykowany dla systemów niskonapięciowych (alarm, KD, SAP, CCTV PoE z konwerterem).

Wszystkie centrale alarmowe mają **wbudowany zasilacz buforowy** (Satel Integra 32 — 2 A, Integra 128 — 3 A). Osobny moduł buforowy (Pulsar, APS) stosujemy gdy: pobór przekracza możliwości centrali (np. zewnętrzny sygnalizator z lampą), system jest rozproszony (ekspandery oddalone), lub zasilamy urządzenia spoza systemu alarmu (kamery PoE, kontrolery KD).

## Klasyfikacja PN-EN 50131-6 (systemy alarmowe)

Norma wprowadza trzy klasy zasilaczy:

| Klasa | Charakterystyka | Wymóg na akumulator | Zastosowanie |
|---|---|---|---|
| **Typ A** | zasilacz sieciowy + akumulator (zasilanie z sieci, akumulator jako rezerwa) | tak — autonomia min. wg grade | standardowy alarm |
| **Typ B** | zasilacz sieciowy + alternatywne źródło (np. agregat) | opcjonalnie | obiekty z gen. spalinowym |
| **Typ C** | tylko bateria nie odnawialna lub samodzielna | — | rzadko, urządzenia mobilne |

### Czas autonomii wg grade (PN-EN 50131-1)

| Grade | Czas podtrzymania T_a [h] | Czas pracy alarmowej T_b | Typowy obiekt |
|---|---|---|---|
| **Grade 1** | 12 h | 15 min | małe ryzyko — dom, mieszkanie |
| **Grade 2** | 12 h | 15 min | średnie ryzyko — sklep, biuro |
| **Grade 3** | 30 h (lub 12 h przy monitorowaniu zasilania) | 30 min | znaczne — bank, jubiler, kantor |
| **Grade 4** | 60 h (lub 12 h przy monitorowaniu) | 30 min | krytyczne — obiekty wojskowe |

**„Monitorowanie zasilania"** oznacza, że stan zasilania (awaria 230 V, awaria akumulatora) jest przekazywany do stacji monitorowania alarmu w czasie nie dłuższym niż 25 h (grade 3) lub 3 min (grade 4). Wtedy norma pozwala skrócić czas autonomii do 12 h, bo operator może zorganizować serwis przed wyczerpaniem akumulatora.

## Klasyfikacja PN-EN 54-4 (SAP)

Dla systemów sygnalizacji pożarowej norma jest bardziej restrykcyjna:

- **Czas dozoru** T_dozór = 24 h (standard) lub 72 h (obiekty bez stałej obsługi technicznej)
- **Czas alarmowania** T_alarm = 30 min — wszystkie sygnalizatory aktywne
- **Monitorowanie ładowania** — kontrola obwodu ładowania i przewodów akumulatora (kabel zerwany, akumulator odłączony → sygnalizacja awarii w < 30 min)
- **Certyfikat CNBOP-PIB** obowiązkowy dla zasilaczy SAP w obiektach objętych instrukcją bezpieczeństwa pożarowego

```
Q_aku [Ah] = I_dozór × 24 + I_alarm × 0,5

Przykład SAP konwencjonalny:
  I_dozór = 200 mA, I_alarm = 1800 mA
  Q = 0,2 × 24 + 1,8 × 0,5 = 4,8 + 0,9 = 5,7 Ah  →  7 Ah

Z zapasem starzenia (1,25) i temperaturowym (1,2):
  Q_min = 5,7 × 1,25 × 1,2 = 8,5 Ah  →  dobierz 12 Ah
```

## Klasy PSAC / PSBOC — co to jest

Polscy producenci (głównie Pulsar) wprowadzili wewnętrzną nomenklaturę kompatybilną z normami europejskimi:

| Klasa | Pełna nazwa | Standard | Zastosowanie |
|---|---|---|---|
| **PSAC** | Power Supply Alarm Compliant | PN-EN 50131-6 | alarmy włamaniowe |
| **PSBOC** | Power Supply Battery Open Circuit | PN-EN 50131-6 + monitoring | alarmy z pełną sygnalizacją błędów |
| **EN54** | Power Supply for Fire Detection | PN-EN 54-4 | sygnalizacja pożarowa (SAP) |
| **EN54-AUX** | Auxiliary Power Supply | PN-EN 54-4 + wyjścia dodatkowe | SAP z urządzeniami zewn. |

## Sygnały awaryjne (technical outputs)

Profesjonalny zasilacz buforowy generuje kilka sygnałów technicznych, które centrala alarmu/SAP powinna monitorować:

| Sygnał | Akronim | Wyzwolenie |
|---|---|---|
| Awaria sieci 230 V | AC FAIL / APS | brak napięcia AC > 30 s |
| Awaria akumulatora | BAT FAIL / BAT LOW | U_bat < 11,0 V pod obciążeniem lub R_int > 0,3 Ω |
| Otwarty obwód akumulatora | BAT DISC / OPEN | kabel akumulatora zerwany / faston odłączony |
| Zwarcie wyjścia DC | OVL / SHORT | I_out > I_max przez > 5 s — odcięcie |
| Przekroczenie temperatury | TEMP | t_wnętrza > 60 °C |
| Sabotaż obudowy | TAMPER | otwarcie pokrywy (mikroprzełącznik NC) |

Sygnały są zwykle wyjściami typu **OC** (open collector — zwarcie do masy) lub **NC** (normalnie zwarte, rozwarcie przy alarmie). Centrala podpina je do swoich wejść *technical zones*.

## Marka 1 — Pulsar HPSB / EN54

Polski producent, dominuje na rynku PL, świetna dokumentacja, certyfikaty CNBOP. Linia **HPSB** dla alarmów, **EN54** dla SAP, **HPSG** z LCD do dużych obiektów.

| Model | Wyjście | Aku | Cena ~ | Typowe zastosowanie |
|---|---|---|---|---|
| HPSB 2,5A-B | 12 V / 2,5 A | 7–17 Ah | 280 zł | mały alarm, KD jedne drzwi |
| HPSB 5A-B | 12 V / 5 A | 7–17 Ah | 390 zł | alarm + KD 2–4 czytniki |
| HPSB 11A12 | 12 V / 11 A | 17–40 Ah | 1100 zł | magazyn z PoE, KD wielopunktowe |
| HPSBOC 5A12C | 12 V / 5 A + OC | 17 Ah | 520 zł | PSBOC, alarm Grade 3 |
| EN54-3A17LCD | 27,6 V / 3 A | 2× 17 Ah | 1450 zł | SAP centralka konwencj. |
| EN54-7A28 | 27,6 V / 7 A | 2× 28 Ah | 2800 zł | SAP średnie obiekty |

## Marka 2 — Satel APS

Mniejsze, kompaktowe, kompatybilne z centralami Satel Integra (sygnały na magistralę). Standard w polskich instalacjach Satel.

| Model | Wyjście | Aku | Cena ~ | Cecha |
|---|---|---|---|---|
| APS-15 | 13,8 V / 1,5 A | 7 Ah | 200 zł | najtańszy, do klawiatur/ekspanderów |
| APS-30 | 13,8 V / 3 A | 17 Ah | 320 zł | standardowy do alarmu |
| APS-412 | 13,8 V / 4 A | 17 Ah | 420 zł | z magistralą Satel (raportuje do INT) |
| APS-612 | 13,8 V / 6 A | 17 Ah | 550 zł | duże instalacje rozproszone |

## Marka 3 — Schrack / inni

| Marka | Linia | Specjalizacja |
|---|---|---|
| Schrack-Seconet (AT) | USB52, USB57 | SAP premium, integracja z Integral B6 / B5 |
| Bosch | FPP-5000 | SAP modułowy, IP65 |
| Mean Well | AD-55, AD-155A | OEM, do projektów własnych (tanio, bez certyfikatów alarmowych) |
| Roger | PS-30/PS-50 | dedykowane do systemów KD Roger |
| Aritech (Carrier) | RPSU | SAP do central Aritech FP1216 |

## Dobór prądu znamionowego

Prąd zasilacza musi pokrywać **jednocześnie**:

1. Pobór odbiorników w stanie ustalonym (czuwanie)
2. Prąd ładowania akumulatora (typowo 0,1 × Q, czyli dla 7 Ah → 0,7 A; dla 17 Ah → 1,7 A)
3. Krótkotrwałe szczyty (uzbrojenie syren, otwarcie wszystkich elektrozaczepów w KD)

```
I_zas ≥ I_odb_max + I_lad + I_szczyt_chwilowy

Przykład — alarm Satel Integra 32 + 8 PIR + 2 syreny:
  I_odb_czuwanie = 500 mA
  I_odb_alarm    = 2500 mA (syreny aktywne)
  I_lad (7 Ah)   = 700 mA
  
  Wymagany prąd = 2500 + 700 = 3200 mA  →  APS-30 (3 A) zbyt mały
                                      →  APS-412 (4 A) lub HPSB 5A-B  OK
```

Częsty błąd: dobór zasilacza tylko do prądu czuwania. Gdy w alarmie odpalają się syreny + lampa stroboskopowa, pobór skacze 5× — niedoszacowany zasilacz odetnie napięcie, akumulator weźmie obciążenie i wyładuje się w 30 min zamiast deklarowanych 12 h.

## Pomiar i konserwacja

Procedura raz na 6 miesięcy (zalecana dla instalacji komercyjnych):

1. **Pomiar napięcia float** — bez obciążenia akumulatora powinno być 13,5–13,8 V @ 20 °C. Spadek < 13,2 V = ładowarka zepsuta lub akumulator wykończony
2. **Test obciążeniowy** — wyłącz 230 V, sprawdź czy zasilacz przeszedł na akumulator. Po 5 min napięcie na wyjściu powinno być > 11,5 V (przy nominalnym obciążeniu)
3. **Pomiar tętna AC na wyjściu DC** — oscyloskopem lub multimetrem TrueRMS w trybie AC. Ripple > 100 mV pp = ładowarka uszkodzona (kondensator)
4. **Wizualnie** — sprawdź czy akumulator nie spęczniał (sulfatacja → utlenienie ołowiu → wzrost objętości). Jeśli pokrywa nie domyka się płasko, akumulator do wymiany niezwłocznie
5. **Sygnały awaryjne** — wymuś sztucznie (odepnij faston akumulatora) i sprawdź, czy centrala/agencja widzi awarię

## Schemat typowego zasilacza buforowego

```
      230 V AC                          12 V DC
         │                                  │
         ▼                                  ▼
  ┌──────────────┐    ┌──────────┐    ┌─────────────┐
  │ Filtr EMI    │───▶│ AC/DC    │───▶│ Stabilizator│───▶ Wyjście DC (odbiorniki)
  │ + bezp. T1A  │    │ (SMPS)   │    │ + zabezpiecz│
  └──────────────┘    └──────────┘    └─────────────┘
                            │                ▲
                            │  13,8 V        │
                            ▼                │
                      ┌─────────────┐        │
                      │ Ładowarka   │────────┤  (przełącznik
                      │ akumulatora │        │   diodowy lub
                      └─────────────┘        │   MOSFET)
                            │                │
                            ▼                │
                      ┌─────────────┐        │
                      │ Akumulator  │────────┘
                      │ 12 V VRLA   │
                      └─────────────┘

Sygnały wyjściowe:
  ─AC FAIL (NC, rozwarcie gdy zanik 230 V)
  ─BAT FAIL (OC, masa gdy U_bat < 11 V)
  ─TAMPER (mikroswitch obudowy)
```

## Najczęstsze problemy

- **„Akumulator nowy, a centrala pokazuje BAT LOW"** — sprawdź napięcie ładowania. Jeśli < 13,2 V, wymień zasilacz (degradacja kondensatora SMPS)
- **Po wymianie akumulatora dalej awaria** — zasilacz nie wykrył nowego, wymuś reset (wyłącz 230 V na 30 s, potem odepnij i podepnij akumulator)
- **Spalanie się bezpiecznika F1 na wyjściu** — najczęściej zwarcie w okablowaniu sygnalizatora zewnętrznego (woda w obudowie). Sprawdź megaomierzem każdy odcinek
- **Akumulator gorący w dotyku** — przeładowywanie (napięcie float > 14 V), wymień zasilacz. Akumulator do oceny — jeśli spuchnięty, wymień
- **Zasilacz głośno bzyczy** — uszkodzony transformator lub dławik filtru. Wymiana modułu

## Powiązane

- [14-01 Akumulatory żelowe i AGM](14-01-akumulatory.md)
- [06 Centrale alarmowe](../06-alarmy-centrale/index.html) — wbudowane zasilacze
- [15-03 PN-EN 54](../15-normy-przepisy/15-03-pn-en-54.md) — wymagania dla SAP
