# Biuro średnie 200-500 m²

**Sekcja:** 16 Przykłady projektowe · **Aktualizacja:** 2026-05

Pełna kontrola dostępu z biometrią, alarm Grade 2, CCTV 8-16 kamer, system sygnalizacji pożaru (SAP).

## 1. Opis obiektu

Biuro o powierzchni **200–500 m²** na jednym piętrze budynku biurowego: recepcja, open space, kilka gabinetów, sala konferencyjna, **serwerownia**, pomieszczenia socjalne i archiwum. Zatrudnienie **20–50 osób**. Wejście główne przez recepcję, wejście awaryjne/ewakuacyjne na klatkę schodową, dostęp do parkingu podziemnego.

| Parametr | Wartość |
| --- | --- |
| Powierzchnia | 200–500 m², jedno piętro |
| Pomieszczenia | recepcja, open space, 4–6 gabinetów, sala konf., serwerownia, archiwum, socjal |
| Pracownicy | 20–50 |
| Drzwi kontrolowane | wejście główne, serwerownia, archiwum, gabinety zarządu, drzwi ewakuacyjne |
| Infrastruktura IT | serwerownia z szafą RACK, sieć strukturalna, UPS |
| Wymóg ppoż. | system sygnalizacji pożaru (SAP) + integracja z KD |

## 2. Analiza zagrożeń

| Zagrożenie | Strefa | Środek zaradczy |
| --- | --- | --- |
| Nieautoryzowany dostęp osób z zewnątrz | całość | KD na wejściu głównym, recepcja, rejestr wejść |
| Dostęp do serwerowni / danych | serwerownia | KD z biometrią (2-składnikowe: karta + odcisk palca), CCTV, alarm 24h |
| Kradzież sprzętu / dokumentów | open space, archiwum | alarm po godzinach, CCTV korytarze/wejścia, KD archiwum |
| Włamanie poza godzinami | całość | alarm Grade 2 z podziałem na partycje + monitoring |
| Pożar | całość (zwł. serwerownia) | SAP — czujki dymu adresowalne, ROP, integracja z KD (zwolnienie drzwi) |
| Zablokowanie drogi ewakuacyjnej | drzwi ewakuacyjne | zwory fail-safe + integracja z SAP (KLUCZOWE) |

**Najważniejsza zasada bezpieczeństwa:** drzwi na drogach ewakuacyjnych muszą zwalniać się automatycznie przy alarmie pożarowym. Zwory elektromagnetyczne na tych drzwiach pracują w trybie **fail-safe** (zwolnienie przy zaniku napięcia), a centrala SAP odcina im zasilanie podczas alarmu ppoż.

## 3. Dobór systemów

### 3.1 Kontrola dostępu (KD) z biometrią i RCP

Rozbudowany system wielodrzwiowy **Roger** (system RACS 5) — kontrola wielu przejść, strefy czasowe, anti-passback, RCP. Alternatywa: Paxton Net2.

- **Kontrolery dostępu** Roger *MC16-PAC-x* (na grupy drzwi) + interfejsy *MCT*
- **Czytniki kart Mifare** Roger *MCT62E* — wejście główne, gabinety, archiwum (8–10 przejść)
- **Czytnik biometryczny (palec) + karta** na serwerowni — Roger *RFT1000* lub terminal biometryczny ZKTeco/Suprema (np. *Suprema BioEntry W2*) — dostęp 2-składnikowy
- **Zwory / elektrozaczepy:** zwory elektromagnetyczne *fail-safe* na drzwiach ewakuacyjnych; elektrozaczepy na gabinetach
- **Przyciski wyjścia + przyciski ewakuacyjne (awaryjne zwolnienie)** — wymóg na drogach ewakuacyjnych
- **RCP + strefy czasowe + anti-passback** w oprogramowaniu Roger *VISO* (kto, gdzie, kiedy; blokada „podania karty" drugiej osobie)

### 3.2 System alarmowy (SSWiN) Grade 2 z partycjami

Centrala **Satel Integra 64** (Grade 2/3) — duża liczba wejść, podział na partycje, natywna integracja z CCTV i KD.

- **30+ czujek dual** (PIR + MW, odporne na fałszywe alarmy) — Satel *Grapho* / *Opal Plus* — open space, korytarze, gabinety, serwerownia, archiwum
- **Kontaktrony** na wszystkich drzwiach zewnętrznych i oknach parteru
- **Czujki stłuczenia szkła** przy przeszkleniach
- **2× klawiatura dotykowa** Satel *INT-TSH2* — recepcja i wejście serwisowe
- **Komunikator dual-path** ETHM-1 Plus + GSM-X-LTE — monitoring agencji (SIA DC-09)
- **Partycje:** open space (godziny pracy), serwerownia (24h), gabinety/archiwum, recepcja
- **Integracja z KD** — wejście kartą może rozbroić swoją partycję (Roger + Integra)

### 3.3 Monitoring wizyjny (CCTV 8-16 kamer)

- **8–16 kamer IP 4 Mpx / 4K** — Hikvision/Dahua: wejście główne (twarz), recepcja, korytarze, open space, serwerownia, archiwum, wjazd na parking, drzwi ewakuacyjne
- Kamera ANPR na wjeździe parkingowym (opcja) — Dahua *ITC-* / Hikvision LPR
- **NVR z RAID** — Hikvision *DS-9616NI-I8* (8 zatok, RAID 5) lub serwer VMS
- **Dyski 4× 8 TB** WD Purple Pro w RAID 5 — retencja **30–90 dni**
- Stacja monitoringu / VMS (Hik *iVMS-4200* lub Milestone XProtect dla większych)

### 3.4 System sygnalizacji pożaru (SAP)

Adresowalny SAP — każda czujka ma adres, centrala wskazuje dokładną lokalizację pożaru. Producent np. **Polon-Alfa** (POLON 4900/6000) lub Schrack/Bosch.

- **Centrala SAP adresowalna** — Polon-Alfa *POLON 4900*
- **Czujki dymu optyczne adresowalne** — Polon-Alfa *DOR-4046* (z gniazdami G-40) — wszystkie pomieszczenia, korytarze, serwerownia
- **Czujka w serwerowni** — dodatkowo zasysająca/wczesnej detekcji (opcja: VESDA) lub czujka liniowa
- **Ręczne ostrzegacze pożarowe (ROP)** — przy wyjściach i na drogach ewakuacyjnych
- **Sygnalizatory akustyczno-optyczne** SAOP — alarmowanie ewakuacji
- **Moduły kontrolno-sterujące** — zwolnienie zwór KD na drogach ewakuacyjnych, sterowanie oddymianiem/klapami (jeśli są)

**Integracja SAP ↔ KD (krytyczna):** wyjście przekaźnikowe centrali SAP steruje zasilaniem zwór drzwi ewakuacyjnych. Alarm pożarowy → przekaźnik odcina zasilanie zwór → wszystkie drzwi na drodze ewakuacyjnej otwierają się (fail-safe). Brak tej integracji to błąd projektowy zagrażający życiu i niezgodność z przepisami ppoż.

## 4. Lista urządzeń z cenami (2026)

| Element | Model | Ilość | Cena jedn. (zł) | Razem (zł) |
| --- | --- | --- | --- | --- |
| **Kontrola dostępu (Roger RACS 5)** | | | | |
| Kontroler dostępu | Roger MC16-PAC-8 (do 8 przejść) | 1 | 1900 | 1900 |
| Czytnik Mifare | Roger MCT62E | 9 | 320 | 2880 |
| Terminal biometryczny (palec+karta) | Suprema BioEntry W2 | 1 | 1400 | 1400 |
| Zwora elektromagnetyczna fail-safe | Roger / Bira (300 kg) | 5 | 180 | 900 |
| Elektrozaczep | — | 5 | 120 | 600 |
| Przycisk wyjścia / przycisk ewakuacyjny | — | 10 | 60 | 600 |
| Karty zbliżeniowe Mifare | — | 60 | 6 | 360 |
| **Alarm (Satel Integra 64)** | | | | |
| Centrala alarmowa | Satel Integra 64 Plus + obudowa | 1 | 1100 | 1100 |
| Ekspandery wejść | Satel INT-E (8 wejść) | 4 | 180 | 720 |
| Czujka dual PIR+MW | Satel Grapho | 30 | 140 | 4200 |
| Kontaktron | Satel K-1 | 8 | 15 | 120 |
| Czujka stłuczenia szkła | Satel AGD-200 | 4 | 160 | 640 |
| Klawiatura dotykowa | Satel INT-TSH2 | 2 | 950 | 1900 |
| Komunikator IP + LTE | Satel ETHM-1 Plus + GSM-X-LTE | 1 | 830 | 830 |
| Syreny + akumulatory | Satel SPW-220/SPW-100 + 2× 17 Ah | 1 kpl | 650 | 650 |
| **CCTV** | | | | |
| Kamera IP 4 Mpx | Hikvision DS-2CD2146G2-I / Dahua 3441 | 14 | 480 | 6720 |
| Rejestrator NVR z RAID | Hikvision DS-9616NI-I8 | 1 | 3800 | 3800 |
| Dysk 8 TB (RAID 5) | WD Purple Pro WD8001PURP | 4 | 950 | 3800 |
| Switch PoE zarządzalny 24-port | Hikvision / TP-Link Omada | 1 | 1600 | 1600 |
| **SAP (Polon-Alfa)** | | | | |
| Centrala SAP adresowalna | Polon-Alfa POLON 4900 | 1 | 6500 | 6500 |
| Czujka dymu optyczna adresowalna + gniazdo | Polon-Alfa DOR-4046 + G-40 | 25 | 140 | 3500 |
| Ręczny ostrzegacz pożarowy (ROP) | Polon-Alfa ROP-4001M | 4 | 120 | 480 |
| Sygnalizator akustyczno-optyczny | Polon-Alfa SAOP | 4 | 180 | 720 |
| Moduł kontrolno-sterujący (zwory/integracja) | Polon-Alfa EKS-4001 | 2 | 320 | 640 |
| **Pozostałe** | | | | |
| Okablowanie (UTP, YnTKSY ppoż., OMY), korytka, drobnica | — | — | — | 4500 |
| **Razem materiały (brutto)** | | | | **~62 800 zł** |

## 5. Schemat rozmieszczenia (strefy)

| Strefa | KD | Alarm (partycja) | CCTV | SAP |
| --- | --- | --- | --- | --- |
| **Wejście główne / recepcja** | czytnik Mifare, rejestr wejść | P-Recepcja | kamera twarz + recepcja | czujka, ROP, SAOP |
| **Open space** | — | P-OpenSpace (godz. pracy) | 2× kamera | czujki sufitowe |
| **Gabinety / zarząd** | czytniki na drzwiach | P-Gabinety | korytarz | czujki |
| **Serwerownia** | karta + biometria (2FA) | P-Serwerownia (24h) | kamera wejścia + wnętrze | czujka + wczesna detekcja |
| **Archiwum** | czytnik Mifare | P-Archiwum | kamera | czujka |
| **Korytarze / drogi ewakuacyjne** | zwory fail-safe + przyciski ewak. | czujki ruchu | kamery korytarzy | ROP, SAOP, czujki — odcięcie zwór |
| **Wjazd / parking** | ANPR (opcja) | — | kamera ANPR/wjazd | — |

Anti-passback w open space i na wejściu głównym uniemożliwia „podanie karty" — by wejść drugi raz, trzeba najpierw zarejestrować wyjście. Kluczowe dla wiarygodności RCP i ewidencji obecności w razie ewakuacji.

## 6. Kosztorys (materiały + robocizna 2026)

| Pozycja | Zakres | Koszt (zł) |
| --- | --- | --- |
| Materiały — KD/biometria/RCP | kontroler, 9 czytników, terminal bio, zwory, karty | ~9 040 |
| Materiały — alarm | Integra 64, ekspandery, 30 czujek dual, klawiatury, komunikator, syreny | ~10 880 |
| Materiały — CCTV | 14 kamer, NVR RAID, 4× 8 TB, switch PoE | ~15 920 |
| Materiały — SAP | centrala POLON, 25 czujek, ROP, SAOP, moduły sterujące | ~12 440 |
| Okablowanie i drobnica | UTP, kable ppoż. YnTKSY, OMY, korytka | ~4 500 |
| Robocizna — KD/RCP | kontroler, czytniki, zwory, integracja, VISO (~4 dni) | ~5 000 |
| Robocizna — alarm | 30+ czujek, ekspandery, partycje, integracja KD (~5 dni) | ~6 200 |
| Robocizna — CCTV | 14 kamer, NVR/RAID, VMS, sieć (~4 dni) | ~5 000 |
| Robocizna — SAP + integracja z KD | centrala, czujki adresowalne, ROP, sterowanie zworami (~5 dni) | ~6 500 |
| Projekt, odbiory, dokumentacja powykonawcza | projekt SAP, scenariusz pożarowy, odbiór ppoż., szkolenia | ~5 000 |
| **RAZEM (brutto)** | | **~80 500 zł** |

SAP w obiekcie tej wielkości zwykle wymaga **projektu rzeczoznawcy ds. ppoż.** oraz odbioru przez PSP. Koszt projektu i odbiorów (~5 tys. zł) jest nieodłączną częścią inwestycji. Przy mniejszym budżecie SAP można ograniczyć do konwencjonalnego (tańszego), lecz adresowalny ułatwia diagnostykę i lokalizację.

## 7. Uwagi wdrożeniowe

- **Drogi ewakuacyjne fail-safe (PRIORYTET):** zwory na drzwiach ewakuacyjnych w trybie fail-safe; centrala SAP odcina im zasilanie przy alarmie. Dodatkowo przyciski awaryjnego zwolnienia (rozbicie szybki) niezależne od KD.
- **Integracja systemów:** Roger RACS 5 + Satel Integra — wejście kartą rozbraja partycję; SAP steruje zworami i może wyzwalać tryb ewakuacji w KD (otwarcie wszystkich przejść).
- **Biometria a RODO:** dane biometryczne to dane szczególnej kategorii (art. 9 RODO) — wymagana podstawa prawna, zgoda/uzasadnienie i ocena skutków (DPIA). Stosuj biometrię tylko tam, gdzie naprawdę potrzebna (serwerownia), w pozostałych miejscach karta wystarczy.
- **Strefy czasowe:** ogranicz dostęp pracowników do godzin pracy; serwerownia i archiwum z dodatkowym ograniczeniem ról.
- **Serwerownia 24h:** osobna partycja alarmu zawsze aktywna, niezależnie od reszty biura; dostęp 2-składnikowy + dedykowana kamera + wczesna detekcja dymu.
- **Zasilanie awaryjne:** SAP i KD na drogach ewakuacyjnych zasilane gwarantowanie (akumulatory zgodne z normą, autonomia wg PN-EN 54); CCTV/serwerownia na UPS budynkowym.
- **Sieć:** CCTV i KD w osobnych VLAN-ach od sieci biurowej; NVR i VMS za firewallem, bez bezpośredniego dostępu z Internetu (VPN do zdalnego podglądu).
