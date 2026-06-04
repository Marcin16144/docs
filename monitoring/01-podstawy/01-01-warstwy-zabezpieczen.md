# Warstwy zabezpieczeń (defense in depth)

> Trójwarstwowa ochrona obiektu: mechaniczna, elektroniczna, organizacyjna. Strefy 1–4 i zasada redundancji.
>
> Aktualizacja: 2026

## Idea ochrony warstwowej

**Defense in depth** (DiD) — przeniesione z wojskowości i z dziedziny cyberbezpieczeństwa pojęcie zakłada, że żaden pojedynczy środek nie jest w stanie zatrzymać zdeterminowanego przeciwnika. Skuteczna ochrona to *nawarstwianie* kolejnych przeszkód — każda kupuje czas reakcji służb.

Trzy podstawowe warstwy:

| Warstwa | Cel | Przykłady |
|---|---|---|
| **Mechaniczna** | opóźnić sprawcę (delay) | ogrodzenia, kraty, drzwi RC, zamki, szyby P4A |
| **Elektroniczna** | wykryć i powiadomić (detect) | alarm, CCTV, KD, SAP |
| **Organizacyjna** | zareagować (respond) | procedury, służby, monitoring agencji, polityka kluczy |

Klasyczna formuła branżowa: **D + D + R + C** — Deter (odstraszyć) + Detect (wykryć) + Delay (opóźnić) + Respond (zareagować).

## Warstwa 1 — mechaniczna (fizyczna)

Najstarsza i nadal najważniejsza. Jej zadaniem jest fizyczne **opóźnienie** sprawcy na tyle, by służby zdążyły dotrzeć.

### Drzwi antywłamaniowe — klasy RC wg PN-EN 1627

| Klasa | Czas odporności | Sprawca | Typowe zastosowanie |
|---|---|---|---|
| RC1 N | brak narzędzi | okazjonalny, przemoc fizyczna | drzwi wewnętrzne, piwnice |
| RC2 | 3 minuty | kopanie, śrubokręt, klucz | mieszkanie, dom jednorodzinny |
| RC3 | 5 minut | łom, wkrętak udarowy | dom z wyposażeniem, sklep |
| RC4 | 10 minut | elektronarzędzia (młot, piła) | kasy, magazyny wartościowe |
| RC5 | 15 minut | elektronarzędzia o większej mocy | banki, jubilerzy |
| RC6 | 20 minut | narzędzia profesjonalne, palniki | skarbce, obiekty wojskowe |

### Szyby antywłamaniowe — klasy P wg PN-EN 356

| Klasa | Test | Odporność |
|---|---|---|
| P1A–P5A | uderzenie kuli 4,11 kg z 1,5/3/6/9 m | rzut kamieniem, wandalizm |
| P6B–P8B | uderzenia siekierą (30/50/70 razy) | siekiera, łom — minuty |
| BR1–BR7 | strzał (PN-EN 1063) | kuloodporne |

### Zamki — klasy A/B/C wg PN-EN 12209

- **Klasa A** — podstawowa, otwarcie wytrychem <3 min
- **Klasa B** — minimum do drzwi zewnętrznych mieszkania, >10 min
- **Klasa C** — zalecane do domów jednorodzinnych, >15 min, anti-bumping (EVVA MCS, ABUS Bravus)

**Praktyka.** Standardowe drzwi z marketu z wkładką klasy A można otworzyć wytrychem w 30 sekund. Wymiana wkładki na klasę C i nakładka magnetyczna (Disec) podnosi czas do kilkunastu minut.

## Warstwa 2 — elektroniczna

Cztery podsystemy:

| Podsystem | Funkcja | Norma bazowa |
|---|---|---|
| **SSWiN** — sygnalizacja włamania i napadu | detekcja wtargnięcia | PN-EN 50131 |
| **CCTV** — telewizja dozorowa | obserwacja, rejestracja, weryfikacja | PN-EN 62676 |
| **SKD** — system kontroli dostępu | autoryzacja przejść | PN-EN 60839-11 |
| **SAP/SSP** — sygnalizacja pożarowa | wykrycie dymu/ciepła/płomienia | PN-EN 54 |

W nowoczesnym obiekcie są zintegrowane — na poziomie centrali alarmowej (Satel Integra, Risco, Galaxy) lub BMS.

## Warstwa 3 — organizacyjna

Najlepsza technika nie pomoże, jeśli nie ma kto na nią zareagować:

- **Procedury** — co robić w razie alarmu, kto rozbraja, gdzie kopie kluczy
- **Polityka kluczy i kart** — rejestr wydanych nośników, procedura przy zwolnieniu pracownika
- **Stała Ochrona** (SUFO) — pracownicy ochrony fizycznej 24/7
- **Grupa interwencyjna** — agencja reagująca (Solid, Konsalnet, Securitas, Seris, Impel)
- **Stacja monitorowania alarmów** (SMA/CMA) — operator 24/7 odbierający Contact ID / SIA
- **Szkolenia personelu** — co robić przy napadzie, kody „pod przymusem"

**Czas reakcji grupy interwencyjnej** w PL: do **15 minut** w miastach, do **30 minut** poza nimi. Stąd minimalna odporność mechaniczna powinna wynosić >15 min (RC3 + zamek klasy C).

## Strefy ochrony 1–4

| Strefa | Lokalizacja | Typowe środki |
|---|---|---|
| **Strefa 1 — perymetryczna** | ogrodzenie, brama | ogrodzenie 2 m + drut, bariery IR, ANPR, oświetlenie z PIR |
| **Strefa 2 — zewnętrzna** | elewacja, podjazd | kamery IP66, kurtyny PIR, kontaktrony okien, wibracyjne |
| **Strefa 3 — wewnętrzna** | hol, korytarze | PIR sufitowe, KD RFID, kamery wewnętrzne, kontaktrony |
| **Strefa 4 — krytyczna** | serwer, kasa, sejf | biometria, KD karta+PIN, CCTV z analityką, wibracje, sejf w sejfie |

**Zasada:** sprawca musi pokonać każdą strefę osobno. Wejście do strefy 4 oznacza wcześniejsze wykrycie w strefach 1–3.

## Zasada redundancji (N+1)

Pojedyncza droga wykrycia/komunikacji to **pojedynczy punkt awarii** (SPOF):

- **Detekcja** — dwa różne typy czujek na tę samą strefę (PIR + kontaktron). Jamer mikrofalowy nie zablokuje obu naraz.
- **Komunikacja (ATS)** — dual-path: IP + GSM/LTE. PN-EN 50136 grade 3: detekcja awarii toru max 25 h; grade 4: 3 min.
- **Zasilanie** — sieć + akumulator 12 V/7–17 Ah + UPS dla rejestratora. PN-EN 50131-6: min. 12 h (grade 2), 60 h (grade 4).
- **Nośnik nagrań** — RAID 1/5/6 na rejestratorze + replikacja off-site / chmura.

## Triada CIA w zabezpieczeniach fizycznych

| Atrybut | W cyber | W fizycznych |
|---|---|---|
| **Confidentiality** | kto może czytać dane | kto może wejść (KD, kody, biometria) |
| **Integrity** | dane bez zmian | zapis CCTV bez podmiany (hash, znak czasu) |
| **Availability** | system dostępny | działa po zaniku zasilania, jamerze, sabotażu |

## Najczęstsze błędy projektowe

- **Tylko CCTV bez alarmu** — kamera rejestruje, ale nie powiadamia w czasie rzeczywistym
- **Alarm bez monitoringu agencji** — syrena jest tylko irytacją dla sąsiadów
- **Słabe drzwi pod silnym alarmem** — sprawca wyłamie w 30 s i ucieknie przed dojazdem agencji
- **Brak redundancji komunikacji** — jamer GSM blokuje powiadomienie
- **Kamera w polu detekcji własnego PIR** — IR kamery wywołuje fałszywe alarmy
- **Centralka w widocznym miejscu przy wejściu** — sprawca wyrwie ją w pierwszych sekundach

## Co dalej

➡ [Klasy ryzyka SA1–SA4 i grade 1–4](01-02-klasy-ryzyka-sa.md)
