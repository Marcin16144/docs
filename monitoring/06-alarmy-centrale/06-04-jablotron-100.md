# Jablotron 100+

**Sekcja:** 06 Centrale alarmowe · **Aktualizacja:** 2026-05

System bezprzewodowy + przewodowy (hybryda BUS / 868 MHz), chmura MyJABLOTRON, filozofia prostoty (1 przycisk + RFID). Seria JA-100+ (JA-101/103/107), model sprzedaży z usługą monitoringu.

## Kim jest Jablotron

Jablotron to czeski producent z Jablonca nad Nysą, działający od 1990 r. W Czechach i Słowacji jest **marką numer jeden** w systemach alarmowych, bardzo silną także w Polsce (dystrybucja przez **Jablotron Alarms / DPK System**). Filozofia firmy to **prostota obsługi** — system ma być tak prosty, by „każdy domownik uzbroił go jednym przyciskiem lub zbliżeniem breloka", bez wpisywania kodów na co dzień.

**Filozofia 1 przycisk + RFID** — codzienna obsługa odbywa się przez *segmenty* na klawiaturze (kolorowe przyciski sekcji) i breloki/karty RFID. Kod wpisuje się tylko, gdy wymaga tego polityka bezpieczeństwa. To celowo odróżnia Jablotron od „klasycznych" central, gdzie podstawą jest 4-cyfrowy kod.

## Seria JA-100+ — modele central

Rodzina JA-100 (i nowsza JA-100+) to centrale hybrydowe: jednocześnie obsługują magistralę przewodową BUS i czujki bezprzewodowe 868 MHz. Numer modelu wskazuje wielkość/wyposażenie.

| Model | Charakterystyka | Komunikator wbudowany |
| --- | --- | --- |
| **JA-101K** | centrala podstawowa, mniejsze instalacje | GSM (2G/LTE wg wersji) |
| **JA-103K** | centrala z LAN + GSM, popularna dom/biuro | LAN + GSM/LTE |
| **JA-107K** | centrala rozbudowana (większe obiekty, więcej BUS) | LAN + 2× GSM/LTE (dual-SIM) |

| Parametr systemu JA-100+ | Wartość |
| --- | --- |
| Maks. liczba elementów (urządzeń) | **230** (czujki, klawiatury, sygnalizatory, piloty łącznie wg modelu) |
| Sekcje (partycje) | **15** |
| Użytkownicy | do 300 (kody + RFID) |
| Wyjścia programowalne (PG) | do 128 |
| Pasmo bezprzewodowe | 868 MHz, komunikacja szyfrowana |
| Grade | 2 (typowo), wybrane konfiguracje 3 |

**Grade 2** (PN-EN 50131-3) — mieszkania i domy jedno/dwurodzinne, sklepy. Jablotron 100+ to przede wszystkim system Grade 2 dla rynku domowego i małego biznesu; wybrane konfiguracje przewodowe z odpowiednim zasilaniem i sabotażem osiągają Grade 3.

## Magistrala BUS (przewodowa)

Czujki i moduły przewodowe podłącza się **4-żyłową magistralą BUS**: **+U (zasilanie), GND (masa), A, B (linia danych)**. Wszystkie urządzenia BUS są adresowalne — centrala „widzi" każde z osobna (nie ma pętli rezystorowych jak w Satel/DSC dla urządzeń systemowych).

| Parametr BUS | Wartość |
| --- | --- |
| Liczba żył | 4 (+U, GND, A, B) |
| Topologia | dowolna: linia, gwiazda, drzewo |
| Maks. długość kabli BUS (suma) | do 500 m (z modułami zasilającymi więcej) |
| Adresowanie | każde urządzenie ma własny adres (auto-enroll przy podłączeniu) |

Zaletą BUS Jablotron jest **auto-rejestracja**: po podłączeniu nowego urządzenia do magistrali centrala automatycznie je wykrywa i proponuje dodanie w MyJABLOTRON / F-Link. Brak żmudnego adresowania zworkami.

Przy rozbudowanej magistrali BUS i wielu czujkach z poborem prądu należy dodać **moduł zasilający BUS** (np. JA-112PW), aby utrzymać napięcie i nie przeciążyć zasilacza centrali. Spadki napięcia na długiej magistrali powodują błędy komunikacji.

## Sterowanie — segmenty, RFID, kod

To serce filozofii Jablotron. Klawiatury **JA-114E / JA-154E** mają moduł **segmentów** — fizyczne, kolorowe przyciski (z diodami stanu), gdzie każdy segment odpowiada jednej sekcji (np. „Dom", „Garaż", „Noc").

- **Segment** — naciśnięcie przycisku sekcji + autoryzacja = uzbrojenie/rozbrojenie tej sekcji. Dioda pokazuje stan (zielony = rozbrojony, czerwony = uzbrojony).
- **RFID** — zbliżenie karty lub breloka do klawiatury autoryzuje użytkownika (zamiast kodu). Standard **125 kHz** oraz **13,56 MHz** wg wersji czytnika.
- **Kod** — 4-cyfrowy (rozszerzalny), wpisywany na klawiaturze, gdy polityka wymaga „coś, co wiesz".
- **Dwustopniowa autoryzacja** (RFID + kod) — dla obiektów Grade 3 / podwyższonego ryzyka.

Codzienny scenariusz: wychodząc z domu zbliżasz brelok do klawiatury i naciskasz segment „Dom" → cały dom uzbrojony jednym gestem. Szczegóły uprawnień, kodów przymusu i pilotów — patrz 09-03 Użytkownicy, kody, piloty.

## Czujki i elementy

Każde urządzenie występuje zwykle w wersji **przewodowej (BUS)** i **bezprzewodowej (868 MHz)** — na jednej centrali można je dowolnie mieszać. Bezprzewodowe są szyfrowane i dwukierunkowe (kontrola stanu i baterii).

| Model | Typ | Wersja | Cena (2026) |
| --- | --- | --- | --- |
| **JA-150P** | czujka ruchu PIR pet-immune | bezprzewodowa 868 MHz | ~330 zł |
| **JA-120P** | czujka ruchu PIR | przewodowa BUS | ~210 zł |
| **JA-150PC** | PIR z **kamerą** (fotoweryfikacja) | bezprzewodowa 868 MHz | ~620 zł |
| **JA-151M** | kontaktron drzwiowy/okienny mini | bezprzewodowa 868 MHz | ~180 zł |
| **JA-150ST** | czujka dymu i temperatury | bezprzewodowa 868 MHz | ~400 zł |
| **JA-150B** | czujka stłuczenia szkła | bezprzewodowa 868 MHz | ~340 zł |
| **JA-114E** | klawiatura z segmentami + RFID + LCD | przewodowa BUS | ~470 zł |
| **JA-154E** | klawiatura z segmentami + RFID + LCD | bezprzewodowa 868 MHz | ~620 zł |
| **JA-111A** | sygnalizator zewnętrzny (syrena + flesz) | przewodowa BUS | ~360 zł |
| **JA-151A** | sygnalizator zewnętrzny | bezprzewodowa 868 MHz | ~450 zł |
| **JA-152J** | pilot 4-przyciskowy (brelok) | bezprzewodowa 868 MHz | ~140 zł |
| **JA-112PW** | moduł zasilacza BUS (booster) | przewodowa BUS | ~290 zł |

## MyJABLOTRON — chmura i aplikacja

**MyJABLOTRON** to wyróżnik systemu — rozbudowana platforma chmurowa z aplikacją mobilną (iOS / Android) i panelem web. Działa zarówno dla **klienta końcowego**, jak i dla **instalatora** (zdalny serwis).

- Uzbrojenie / rozbrojenie sekcji z telefonu, podgląd stanu
- Push notifications i powiadomienia o zdarzeniach (alarm, sabotaż, brak zasilania, niski stan baterii)
- Historia zdarzeń z dokładnym logiem (kto, kiedy, którą sekcję)
- Sterowanie wyjściami PG (brama, oświetlenie, ogrzewanie)
- **Fotoweryfikacja** — zdjęcia z czujek JA-150PC dostępne w aplikacji po alarmie
- **Zdalna konfiguracja** — instalator może serwisować i przeprogramować system bez dojazdu (unikalne na tle konkurencji)

MyJABLOTRON pozwala instalatorowi **zdalnie zmienić konfigurację** centrali (dodać użytkownika, zmienić reakcję czujki) — u Satela/DSC zwykle wymaga to połączenia konkretnym narzędziem (DLOAD X / DLS) lub wizyty. To duża przewaga modelu serwisowego Jablotron.

## Komunikacja i fotoweryfikacja

Komunikator jest **wbudowany w centralę** (zależnie od modelu — JA-103K: LAN + GSM/LTE, JA-107K: LAN + dual-SIM). Brak konieczności dokupowania osobnej karty komunikacyjnej do podstawowej pracy w chmurze.

| Tor komunikacji | Zastosowanie |
| --- | --- |
| **LAN (Ethernet)** | tor podstawowy do MyJABLOTRON i monitoringu |
| **GSM / LTE** | tor zapasowy (backup) lub podstawowy bez LAN; SMS, dane |
| **Dual-SIM (JA-107K)** | dwie karty SIM różnych operatorów — redundancja |

**Fotoweryfikacja** — czujki z kamerą (JA-150PC) robią serię zdjęć w chwili alarmu i przesyłają je do MyJABLOTRON oraz do stacji monitoringu, co pozwala zweryfikować, czy alarm jest prawdziwy, zanim wyśle się patrol.

## Model biznesowy — instalator i usługa

Jablotron stawia na **autoryzowanych instalatorów** i sprzedaż „z usługą". System nie jest sprzedawany swobodnie do samodzielnego montażu — kupuje się go zwykle wraz z instalacją i często z abonamentem.

- **Autoryzowani instalatorzy** — przeszkoleni partnerzy z dostępem do narzędzia *F-Link* (konfiguracja PC) i panelu instalatora w MyJABLOTRON
- **„Sklepy z usługą"** — model, w którym klient płaci abonament obejmujący monitoring (PCO), serwis i chmurę MyJABLOTRON
- Zdalny serwis przez chmurę redukuje koszty dojazdów — instalator obsługuje wielu klientów z jednego panelu

Ten model przypomina abonamentowe systemy „security as a service". Zaleta dla klienta: zawsze aktualny, serwisowany system i monitoring. Wada: większe uzależnienie od konkretnego instalatora/dostawcy niż przy „otwartym" Satelu, który łatwo serwisuje wielu instalatorów.

## Konfiguracja — F-Link

Instalator programuje centralę narzędziem **F-Link** (aplikacja PC), lokalnie przez USB lub zdalnie przez MyJABLOTRON.

```
; Przykładowa struktura w F-Link
Sekcje
  Sekcja 1: "Dom"     -> segment klawiatury (zielony/czerwony LED)
  Sekcja 2: "Garaz"   -> segment
  Sekcja 3: "Noc"     -> segment (czesc czujek bypass)
Urzadzenia (auto-enroll z BUS / 868 MHz)
  01  JA-114E   Klawiatura (segmenty + RFID)   BUS
  02  JA-120P   PIR salon                       BUS    -> Sekcja 1
  10  JA-150PC  PIR + kamera, sypialnia         868    -> Sekcja 1,3
  11  JA-151M   Kontaktron drzwi               868    -> Sekcja 1 (wejscie/wyjscie)
Komunikacja
  LAN  -> MyJABLOTRON = ON,  Monitoring (PCO) = ON
  GSM  -> Backup = ON
Uzytkownicy
  Uzytk. 1: Administrator (master) + karta RFID
  Uzytk. 2: Domownik, Sekcja 1 + brelok JA-152J
```

## Porównanie z konkurencją

| Cecha | Jablotron 100+ | Satel Integra | Risco LightSYS Plus |
| --- | --- | --- | --- |
| Kraj producenta | Czechy | Polska (Gdańsk) | Izrael |
| Typ centrali | hybrydowa (BUS + 868 MHz) | hybrydowa (BUS + ABAX) | hybrydowa (RS-485 + RF) |
| Codzienna obsługa | **segmenty + RFID** (prostota) | kod / klawiatura / GUARD X | kod / proximity / iRISCO |
| BUS | 4-żyłowy, auto-enroll, bez rezystorów dla urządzeń | magistrala + rezystory EOL | RS-485 + rezystory EOL |
| System bezprzewodowy | 868 MHz, szyfrowany, 2-way | ABAX 2 (2-way, AES) | 433/868 MHz (2-way) |
| Chmura | **MyJABLOTRON** (klient + instalator, zdalna konfiguracja) | SATEL P2P (GUARD X) | Risco Cloud (iRISCO) |
| Fotoweryfikacja | JA-150PC (PIR + kamera) | zdjęcia z czujek / kamery przez integrację | VUpoint (kamery IP) + eyeWAVE |
| Komunikator | **wbudowany** (LAN + GSM/LTE) | moduł ETHM-1 Plus / GSM-X | karta IP / LTE (plug-in) |
| Konfiguracja | F-Link (instalator) + zdalnie przez chmurę | DLOAD X (darmowa) | Configuration Software |
| Model sprzedaży | **z usługą** (autoryzowany instalator, abonament) | otwarty (wielu instalatorów) | autoryzowani instalatorzy |
| Cena startowa (zestaw dom) | ~1600 zł (centrala + klawiatura + czujki) | ~1100 zł (centrala) | ~1400 zł |

## Kiedy wybrać Jablotron

- Gdy najważniejsza jest **prostota obsługi** dla mieszkańców (segmenty + brelok, bez kodów na co dzień)
- Gdy zależy na **zdalnym serwisie** i chmurze (MyJABLOTRON) z abonamentem monitoringu
- Instalacje domowe i małego biznesu w Polsce/Czechach z dostępnym autoryzowanym instalatorem
- Gdy chcesz wbudowany komunikator LAN+GSM bez dokupowania modułów
- Gdy akceptujesz model „z usługą" i preferujesz jednego, opiekuńczego dostawcę

System jest mocno związany z **autoryzowanym instalatorem** i narzędziem F-Link — zmiana firmy serwisującej bywa trudniejsza niż przy Satelu. Dla osób ceniących „otwartość" i samodzielną konfigurację to potencjalna wada.
