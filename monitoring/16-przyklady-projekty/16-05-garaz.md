# Garaż / warsztat / magazyn

**Sekcja:** 16 Przykłady projektowe · **Aktualizacja:** 2026-05

CCTV z ANPR na bramie, alarm zewnętrzny, czujki zalania i CO/gazu — projekt dla obiektu z placem.

## 1. Opis obiektu

Obiekt typu **garaż / warsztat / magazyn** z utwardzonym **placem manewrowym** i **bramą wjazdową** (przesuwna lub szlabanem). Hala o powierzchni ~200–400 m² z bramą segmentową, część warsztatowa (narzędzia, sprzęt) i magazynowa (towar na regałach, czasem nisko składowany). Teren ogrodzony. Obiekt często pusty po godzinach, wjazd pojazdów dostawczych i pracowników.

| Parametr | Wartość |
| --- | --- |
| Hala | ~200–400 m² (warsztat + magazyn) |
| Plac | utwardzony, ogrodzony, brama wjazdowa |
| Bramy | wjazdowa (przesuwna/szlaban) + segmentowa do hali |
| Zagrożenia środowiskowe | warunki zewnętrzne, mróz, zalanie (niski magazyn), spaliny/gaz (warsztat) |
| Ruch | pojazdy dostawcze, pracownicy, sprzęt |
| Zasilanie | sieć 230/400 V; plac wymaga doprowadzenia zasilania do słupów/kamer |

## 2. Analiza zagrożeń

| Zagrożenie | Miejsce | Środek zaradczy |
| --- | --- | --- |
| Kradzież narzędzi / towaru | hala, magazyn | alarm wewnętrzny, CCTV, czujki ruchu |
| Wjazd nieuprawnionych pojazdów | brama, plac | ANPR (rozpoznawanie tablic) + sterowanie bramą, CCTV placu |
| Wtargnięcie przez ogrodzenie / plac nocą | plac | bariera podczerwieni, kurtyny PIR zewnętrzne, oświetlenie z ruchem |
| Zalanie magazynu (nisko składowany towar) | magazyn | czujki zalania przy posadzce |
| Zatrucie / wybuch (spaliny, LPG, gaz) | warsztat | czujka CO + czujka gazu (LPG/metan) |
| Fałszywe alarmy od zwierząt na placu | plac | kurtyny PIR pet-immune / bariery IR (logika 2 wiązek) |
| Warunki zewnętrzne (mróz, wilgoć) | kamery, czujki zewn. | obudowy IP66/67, grzałki kamer |

Specyfika obiektu zewnętrznego: **ochrona obwodowa** (perymetryczna) ma równą wagę co ochrona wnętrza. Wykrycie intruza już na placu daje czas na reakcję, zanim dotrze do hali.

## 3. Dobór systemów

### 3.1 CCTV z ANPR/LPR (rozpoznawanie tablic)

Kamera ANPR na bramie odczytuje tablice rejestracyjne; znane pojazdy (lista biała) otwierają bramę automatycznie, pozostałe są rejestrowane.

- **Kamera ANPR/LPR na bramie** — Hikvision *iDS-2CD7A46G0/P-IZHSY* (DeepinView ANPR) lub Dahua *ITC413-PW4D-IZ3* — wbudowane rozpoznawanie tablic, lista biała/czarna, wyjście przekaźnikowe do napędu bramy
- **2× kamera placu z dużym zasięgiem IR 4 Mpx** — Hikvision *DS-2CD2T46G2-4I* (IR 80 m, IP67) na słupach/narożnikach
- **1× kamera PTZ** — Dahua *SD49225XA-HNR* (25× zoom, obrót) — obserwacja całego placu, śledzenie ruchu
- **2× kamera w hali 4 Mpx** — warsztat i magazyn (Dahua *IPC-HDBW3441E-AS*)
- **NVR 8-kanałowy PoE z obsługą ANPR** — Hikvision *DS-7608NXI-K1/8P* (AcuSense, lista tablic)
- **Dysk 4 TB** WD Purple — retencja ~30 dni

### 3.2 Alarm z ochroną obwodową

Centrala **Satel Integra 32** (lub Versa) z czujkami zewnętrznymi i środowiskowymi.

- **Bariera podczerwieni (IR) na placu/ogrodzeniu** — Optex *SL-200QFR* (2 wiązki, zasięg do 60 m) — wykrycie przekroczenia linii, odporność na zwierzęta (logika AND)
- **Kurtyny PIR zewnętrzne pet-immune** — Optex *VXI-RDAM* lub Satel *OPAL* (wersja zewnętrzna) — wzdłuż ścian hali
- **Czujki PIR wewnętrzne** — warsztat, magazyn (Satel *Bingo*)
- **Kontaktron bramy segmentowej + bramy wjazdowej**
- **Czujki zalania** — Satel *FD-1* przy posadzce magazynu (kilka punktów nisko)
- **Czujka CO (tlenek węgla)** i **czujka gazu LPG/metan** — warsztat (Satel *CGD-1* gaz, *CD-1* CO lub równoważne)
- **Syrena zewnętrzna 120 dB** + sygnalizator optyczny, klawiatura, komunikator GSM/LTE (dual-SIM)

Bariery IR Optex z logiką **2 wiązek (AND)** wyzwalają alarm tylko gdy oba promienie zostaną przerwane jednocześnie — ptak czy liść (1 wiązka) nie wywoła fałszywki. To standard ochrony obwodowej terenów zewnętrznych.

### 3.3 Sterowanie bramą i oświetlenie

- **Napęd bramy przesuwnej** — Nice/Came/FAAC, sterowany: pilotem, z aplikacji oraz **automatycznie z kamery ANPR** (lista biała tablic)
- **Moduł przekaźnikowy / sterownik GSM** bramy — otwieranie SMS-em/aplikacją (np. Satel wyjście OUT lub dedykowany sterownik GSM)
- **Oświetlenie placu z czujnikiem ruchu** — naświetlacze LED z czujnikiem PIR / sterowane z alarmu (zapal światło przy naruszeniu strefy zewnętrznej)

## 4. Lista urządzeń z cenami (2026)

| Element | Model | Ilość | Cena jedn. (zł) | Razem (zł) |
| --- | --- | --- | --- | --- |
| Kamera ANPR na bramie | Hikvision iDS-2CD7A46G0/P-IZHSY | 1 | 2900 | 2900 |
| Kamera placu bullet IR 4 Mpx | Hikvision DS-2CD2T46G2-4I | 2 | 620 | 1240 |
| Kamera PTZ 25× | Dahua SD49225XA-HNR | 1 | 2400 | 2400 |
| Kamera hala 4 Mpx | Dahua IPC-HDBW3441E-AS | 2 | 430 | 860 |
| Rejestrator NVR 8ch PoE | Hikvision DS-7608NXI-K1/8P | 1 | 1150 | 1150 |
| Dysk HDD 4 TB | WD Purple WD43PURZ | 1 | 490 | 490 |
| Centrala alarmowa | Satel Integra 32 + obudowa | 1 | 650 | 650 |
| Klawiatura LCD | Satel INT-KLCD-GR | 1 | 360 | 360 |
| Bariera podczerwieni 2-wiązkowa | Optex SL-200QFR | 1 para | 1100 | 1100 |
| Kurtyna PIR zewnętrzna pet-immune | Optex VXI-RDAM | 2 | 520 | 1040 |
| Czujka PIR wewnętrzna | Satel Bingo | 2 | 70 | 140 |
| Kontaktron bramowy (do bram) | Satel B-2G (do bram garażowych) | 2 | 40 | 80 |
| Czujka zalania | Satel FD-1 | 3 | 90 | 270 |
| Czujka CO (tlenek węgla) | Satel CD-1 / równoważna | 1 | 220 | 220 |
| Czujka gazu LPG/metan | Satel CGD-1 / równoważna | 1 | 240 | 240 |
| Syrena zewnętrzna 120 dB + optyka | Satel SPW-220 | 1 | 180 | 180 |
| Komunikator GSM/LTE dual-SIM | Satel GSM-X + GSM-X-LTE | 1 | 540 | 540 |
| Akumulator 18 Ah | MWS 18-12 | 1 | 150 | 150 |
| Sterownik GSM bramy | Satel wyjście OUT / GSM relay | 1 | 200 | 200 |
| Naświetlacz LED z czujnikiem ruchu | LED 50 W IP65 + PIR | 3 | 120 | 360 |
| Grzałki kamer / obudowy IP66 (jeśli niezintegr.) | — | 3 | 90 | 270 |
| Okablowanie zewn., słupy/uchwyty, korytka, drobnica | UTP zewn. żelowany, OMY, rury osłonowe | — | — | 1800 |
| **Razem materiały (brutto)** | | | | **~17 200 zł** |

## 5. Schemat rozmieszczenia (strefy)

| Strefa | Kamery | Czujki / detekcja | Sterowanie |
| --- | --- | --- | --- |
| **Brama wjazdowa** | kamera ANPR (odczyt tablic) | — | napęd bramy (auto z listy białej + pilot + app) |
| **Plac manewrowy** | 2× bullet IR + 1× PTZ | bariera IR na granicy, kurtyny PIR przy ścianach | oświetlenie LED z PIR / z alarmu |
| **Hala — warsztat** | 1× kamera | PIR, czujka CO, czujka gazu | — |
| **Hala — magazyn** | 1× kamera | PIR, czujki zalania (posadzka), kontaktron bramy segm. | — |
| **Obwód / ogrodzenie** | PTZ (obserwacja) | bariera podczerwieni 2-wiązkowa | syrena zewn. 120 dB + optyka |

| Strefa alarmu | Zakres | Tryb |
| --- | --- | --- |
| Z1 — Obwód/plac | bariera IR, kurtyny PIR zewn. | uzbrojenie nocne / poza godzinami |
| Z2 — Hala | PIR warsztat/magazyn, kontaktrony bram | po zamknięciu obiektu |
| 24h — środowiskowe | czujki zalania, CO, gazu | zawsze aktywne (alarm techniczny + SMS) |

## 6. Kosztorys (materiały + robocizna 2026)

| Pozycja | Zakres | Koszt (zł) |
| --- | --- | --- |
| Materiały — CCTV + ANPR | kamera ANPR, 2 bullet, PTZ, 2 hala, NVR, dysk | ~9 040 |
| Materiały — alarm + obwód | centrala, bariera IR, kurtyny PIR, PIR wewn., kontaktrony, syrena, GSM | ~5 240 |
| Materiały — czujki środowiskowe | zalanie ×3, CO, gaz | ~730 |
| Materiały — brama/oświetlenie | sterownik GSM bramy, naświetlacze LED, grzałki/obudowy | ~830 |
| Okablowanie zewn. i drobnica | UTP żelowany, OMY, rury osłonowe, słupy/uchwyty | ~1 800 |
| Robocizna — CCTV + ANPR | kamery na słupach, PTZ, ANPR, kalibracja tablic, NVR (~2,5 dnia) | ~3 200 |
| Robocizna — alarm + obwód | bariera IR, kurtyny, czujki, centrala, integracja oświetlenia (~2,5 dnia) | ~3 200 |
| Robocizna — brama + zasilanie placu | sterowanie bramą z ANPR, doprowadzenie zasilania, naświetlacze (~1 dzień) | ~1 400 |
| Programowanie, lista tablic, szkolenie | lista biała ANPR, aplikacje, dostęp zdalny | ~600 |
| **RAZEM (brutto)** | | **~26 040 zł** |

Wariant minimalny (bez PTZ i drogiej kamery ANPR DeepinView, z tańszą kamerą LPR Dahua ITC ~1500 zł i bez kamery obrotowej): całość spada do **~10–15 tys. zł**. PTZ i ANPR DeepinView to elementy podnoszące koszt, ale dające pełną automatyzację wjazdu i obserwację placu.

## 7. Uwagi wdrożeniowe

- **Warunki zewnętrzne:** wszystkie urządzenia na zewnątrz w klasie **IP66/IP67**; kamery z **grzałką** (lub funkcją Defog/odszranianie) — przy mrozie obudowa bez grzałki zaparuje i oszroni. Bariery IR i kurtyny w wersji outdoor z podgrzewaniem optyki.
- **Zasilanie placu:** kamery na słupach wymagają doprowadzenia zasilania/PoE — dla dużych odległości stosuj PoE extender lub switch zewnętrzny w obudowie hermetycznej; PTZ często wymaga PoE+ (High PoE) lub osobnego zasilacza 24 V.
- **ANPR — lista biała:** tablice pracowników/dostawców na listę białą (auto-otwarcie); pozostałe rejestrowane z odczytem numeru. Skalibruj kąt i odległość kamery do bramy (zalecane 2–4 m od linii odczytu, kąt < 30°).
- **Czujki środowiskowe 24h:** zalanie, CO i gaz działają niezależnie od uzbrojenia i wysyłają SMS/PUSH — chronią mienie i ludzi (warsztat: spaliny, butle LPG). Czujkę gazu montuj zgodnie z gęstością gazu (LPG nisko, metan wysoko).
- **Ochrona obwodowa:** bariera IR 2-wiązkowa minimalizuje fałszywe alarmy od zwierząt; sprzęgnij naruszenie obwodu z zapaleniem oświetlenia i (opcjonalnie) preset PTZ na strefę naruszenia.
- **Sterowanie bramą:** niezależne drogi otwarcia (pilot, app, ANPR) + fizyczny wyłącznik awaryjny; zadbaj o fotokomórki i listwy bezpieczeństwa napędu (BHP).
- **GSM dual-SIM:** w obiekcie bez stałego łącza komunikator LTE z dwiema kartami różnych operatorów zwiększa pewność powiadomień.
