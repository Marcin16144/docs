# Sklep / mała firma

**Sekcja:** 16 Przykłady projektowe · **Aktualizacja:** 2026-05

CCTV anty-kradzieżowe, alarm z monitoringiem agencji ochrony, kontrola dostępu zaplecza.

## 1. Opis obiektu

Lokal handlowo-usługowy o powierzchni **~80–150 m²**: sala sprzedaży, strefa kasowa (1–2 stanowiska), zaplecze socjalne i magazyn z wejściem od tyłu (rampa/drzwi towarowe). Czynny w godzinach handlowych, 2–4 pracowników na zmianie. Wejście główne od ulicy (witryna), wejście towarowe od zaplecza.

| Parametr | Wartość |
| --- | --- |
| Powierzchnia | ~80–150 m² |
| Strefy | sala sprzedaży, kasa, magazyn, zaplecze socjalne |
| Wejścia | główne (witryna), towarowe (tył) |
| Personel | 2–4 osoby na zmianie + właściciel |
| Godziny pracy | handlowe; po godzinach lokal pusty |
| Internet | łącze stałe (NVR + komunikator dual-path) |

## 2. Analiza zagrożeń

| Zagrożenie | Kiedy | Środek zaradczy |
| --- | --- | --- |
| Kradzież sklepowa (klienci) | godziny pracy | CCTV sala sprzedaży + nad regałami, widoczne monitory |
| Defraudacja na kasie / sweethearting | godziny pracy | kamera nad kasą (twarz + ręce + szuflada), integracja POS-overlay |
| Napad (rabunek kasy) | godziny pracy | przycisk napadowy (panic) pod kasą → agencja |
| Włamanie po godzinach | noc | alarm Grade 2 z PIR + kontaktrony + monitoring agencji + interwencja |
| Kradzież z magazynu przez personel | godziny pracy | kamera magazynu + KD na drzwiach towarowych + RCP |
| Sabotaż instalacji | noc | pętle 2EOL, dual-path (IP+LTE), antysabotaż obudów |

Dla obiektu handlowego z towarem i gotówką standardem jest **Grade 2** z **monitoringiem agencji ochrony** (sygnał do stacji monitorowania PCO + interwencja patrolu). Dla ubezpieczyciela często warunek wypłaty odszkodowania.

## 3. Dobór systemów

### 3.1 Monitoring wizyjny (CCTV)

Priorytet: **identyfikacja twarzy** przy wejściu i **kontrola kasy**. Rozdzielczość 4 Mpx; kamera kasowa może być 4 Mpx z trybem korytarzowym.

- **2× kamera kasowa dome 4 Mpx** — Hikvision *DS-2CD2146G2-I* (kadr na ręce kasjera, szufladę i twarz klienta)
- **1× kamera wejście (identyfikacja) 4 Mpx** — Hikvision *DS-2CD2T46G2-2I* na wysokości twarzy, naprzeciw drzwi
- **3–4× kamera sala sprzedaży dome 4 Mpx** — Dahua *IPC-HDBW3441E-AS* (alejki, regały, narożniki)
- **1× kamera magazyn 4 Mpx** — Dahua *IPC-HFW3441T-ZAS* (motozoom, szeroki kadr)
- **1× kamera wejście towarowe bullet 4 Mpx z IR** — Hikvision *DS-2CD2T46G2-4I*
- **NVR 16-kanałowy PoE** — Hikvision *DS-7616NXI-K2/16P* (2 zatoki, 16× PoE, AcuSense)
- **2× dysk 6 TB** WD Purple — retencja **30+ dni** z ~10 kamer 4 Mpx (H.265+)
- **Monitor podglądu** 24" przy kasie/zapleczu (efekt prewencyjny)

### 3.2 System alarmowy z monitoringiem agencji

Centrala **DSC PowerSeries Neo HS2032** (Grade 2) — popularna w obiektach komercyjnych monitorowanych przez agencje, lub równoważnie Satel Integra 32.

- **6× czujka PIR** — sala sprzedaży, kasa, magazyn, zaplecze (Satel *Bingo* / DSC *LC-100PI*)
- **3× kontaktron** — drzwi główne, towarowe, okno zaplecza
- **2× czujka stłuczenia szkła** — witryna (Satel *AGD-200*)
- **Przycisk napadowy (panic)** — pod blatem kasy, dyskretny (Satel *NAPAD* / DSC) — wyzwala cichy alarm do agencji
- **Klawiatura LCD** w zapleczu (uzbrajanie/rozbrajanie kodem)
- **Komunikator dual-path IP + LTE** — DSC *TL2803GR* lub Satel *GSM-X-LTE + ETHM-1 Plus* — sygnał do PCO w formacie *SIA DC-09* / Contact ID
- **Syrena zewnętrzna** + sygnalizator optyczny, syrena wewnętrzna

Cichy alarm napadowy **nie uruchamia syren** — informuje wyłącznie stację monitorowania, by nie eskalować zagrożenia podczas rabunku. Syreny rezerwujemy dla włamania po godzinach.

### 3.3 Kontrola dostępu i RCP

Ograniczenie dostępu do zaplecza/magazynu i rejestracja czasu pracy personelu.

- **Czytnik kart na drzwiach zaplecza/magazynu** — Roger *PRT62MF* (Mifare) + kontroler Roger *MC16-PAC*
- **Elektrozaczep/zwora** na drzwiach zaplecza + przycisk wyjścia
- **RCP** (rejestracja czasu pracy) na czytnikach — oprogramowanie Roger *VISO* (raporty obecności pracowników)
- **Karty zbliżeniowe** dla pracowników (Mifare)

## 4. Lista urządzeń z cenami (2026)

| Element | Model | Ilość | Cena jedn. (zł) | Razem (zł) |
| --- | --- | --- | --- | --- |
| Kamera kasowa dome 4 Mpx | Hikvision DS-2CD2146G2-I | 2 | 480 | 960 |
| Kamera wejście (twarz) 4 Mpx | Hikvision DS-2CD2T46G2-2I | 1 | 560 | 560 |
| Kamera sala sprzedaży dome 4 Mpx | Dahua IPC-HDBW3441E-AS | 4 | 430 | 1720 |
| Kamera magazyn motozoom 4 Mpx | Dahua IPC-HFW3441T-ZAS | 1 | 620 | 620 |
| Kamera wejście towarowe bullet | Hikvision DS-2CD2T46G2-4I | 1 | 620 | 620 |
| Rejestrator NVR 16ch PoE | Hikvision DS-7616NXI-K2/16P | 1 | 1850 | 1850 |
| Dysk HDD 6 TB | WD Purple WD64PURZ | 2 | 720 | 1440 |
| Monitor podglądu 24" | iiyama ProLite | 1 | 650 | 650 |
| Centrala alarmowa | DSC PowerSeries Neo HS2032 + obudowa | 1 | 780 | 780 |
| Klawiatura LCD | DSC HS2LCD | 1 | 340 | 340 |
| Czujka PIR | Satel Bingo | 6 | 70 | 420 |
| Kontaktron | Satel K-1 | 3 | 15 | 45 |
| Czujka stłuczenia szkła | Satel AGD-200 | 2 | 160 | 320 |
| Przycisk napadowy | Satel NAPAD | 1 | 60 | 60 |
| Komunikator dual-path | DSC TL2803GR (IP+LTE) | 1 | 1100 | 1100 |
| Syrena zewn. + wewn. | Satel SPW-220 + SPW-100 | 1 kpl | 250 | 250 |
| Akumulator 17 Ah | MWS 17-12 | 1 | 140 | 140 |
| Kontroler KD | Roger MC16-PAC + zasilacz | 1 | 650 | 650 |
| Czytnik Mifare | Roger PRT62MF | 1 | 320 | 320 |
| Elektrozaczep + przycisk wyjścia | — | 1 kpl | 200 | 200 |
| Karty zbliżeniowe Mifare | — | 10 | 6 | 60 |
| Okablowanie, korytka, drobnica | UTP, OMY, YTDY | — | — | 1200 |
| **Razem materiały (brutto)** | | | | **~14 800 zł** |

## 5. Schemat rozmieszczenia (strefy)

| Strefa | Kamery CCTV | Alarm / KD |
| --- | --- | --- |
| **Wejście główne / witryna** | K-wejście (twarz), 1× sala przy drzwiach | kontaktron drzwi, czujki stłuczenia szkła witryny |
| **Strefa kasowa** | 2× kamera kasowa (twarz+ręce+szuflada) | przycisk napadowy pod blatem, PIR |
| **Sala sprzedaży** | 3–4× dome (alejki, regały) | 2–3× PIR (po godzinach) |
| **Magazyn** | 1× motozoom (cały magazyn) | PIR, kontaktron, kamera |
| **Wejście towarowe (tył)** | 1× bullet IR | kontaktron, czytnik KD + RCP, PIR |
| **Zaplecze socjalne** | — | klawiatura LCD, kontroler KD, NVR, centrala |

| Partycja alarmu | Zakres | Uzbrajanie |
| --- | --- | --- |
| P1 — Sklep | sala, kasa, witryna, wejście główne | po zamknięciu lokalu |
| P2 — Magazyn/zaplecze | magazyn, drzwi towarowe, zaplecze | niezależnie (dostawy poza godzinami) |
| 24h — napad | przycisk panic przy kasie | cały czas, cichy → agencja |

## 6. Kosztorys (materiały + robocizna 2026)

| Pozycja | Zakres | Koszt (zł) |
| --- | --- | --- |
| Materiały — CCTV | 9 kamer, NVR 16ch, 2× 6 TB, monitor | ~8 420 |
| Materiały — alarm | centrala, czujki, panic, komunikator dual-path, syreny | ~3 980 |
| Materiały — KD/RCP | kontroler, czytnik, elektrozaczep, karty | ~1 230 |
| Okablowanie i drobnica | UTP, OMY, YTDY, korytka | ~1 200 |
| Robocizna — CCTV | 9 kamer, NVR, kable, konfiguracja, strefy prywatności (~2,5 dnia) | ~3 200 |
| Robocizna — alarm | czujki, centrala, komunikator, integracja z agencją (~2 dni) | ~2 500 |
| Robocizna — KD/RCP | kontroler, czytnik, oprogramowanie VISO, karty (~1 dzień) | ~1 200 |
| Programowanie, dokumentacja, szkolenie | raporty RCP, instrukcje, dostęp zdalny | ~800 |
| **RAZEM (brutto)** | | **~22 530 zł** |

**Koszt eksploatacji:** abonament monitoringu agencji ochrony to **~80–200 zł/mies.** (stacja monitorowania) + opcjonalnie interwencja patrolu (~50–100 zł za wyjazd lub w ryczałcie). Karta SIM do komunikatora LTE ~10–20 zł/mies.

## 7. Uwagi wdrożeniowe

- **RODO / monitoring:** obowiązkowe **tablice informacyjne** „Obiekt monitorowany" przy każdym wejściu, klauzula informacyjna i rejestr czynności przetwarzania. Monitoring stanowisk pracy (kasa, zaplecze) wymaga poinformowania pracowników i zapisu w regulaminie pracy (art. 22² Kodeksu pracy).
- **Kamera kasowa:** ustaw tryb korytarzowy / kadr pionowy, by objąć szufladę, ręce kasjera i twarz klienta; rozważ overlay danych z POS (numer paragonu nałożony na obraz) dla dochodzeń o defraudacje.
- **Monitoring agencji:** podpisz umowę z licencjonowaną agencją; komunikator **dual-path (IP + LTE)** jest wymagany dla Grade 2 — sabotaż jednej drogi nie odcina sygnału.
- **Test napadu:** uzgodnij z agencją hasło/procedurę testu przycisku napadowego, by uniknąć fałszywej interwencji policji.
- **Retencja:** domyślnie **do 3 miesięcy** nagrań (RODO — nie dłużej niż potrzeba); ustaw nadpisywanie cykliczne ~30–60 dni i zabezpiecz NVR hasłem oraz osobnym VLAN.
- **RCP:** raporty z VISO eksportuj do listy płac; karta = identyfikacja pracownika przy drzwiach towarowych ogranicza nieautoryzowane wynoszenie towaru.
