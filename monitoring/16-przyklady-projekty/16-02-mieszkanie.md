# Mieszkanie 50 m²

**Sekcja:** 16 Przykłady projektowe · **Aktualizacja:** 2026-05

Mini-alarm bezprzewodowy, 1–2 kamery IP, wideodomofon IP — projekt bezinwazyjny do lokalu w bloku.

## 1. Opis obiektu

Mieszkanie **~50 m²** w bloku wielorodzinnym, 3. piętro, wykończone (po remoncie lub wynajmowane), co **wyklucza kucie ścian** i prowadzenie nowych tras kablowych. Wejście jednymi drzwiami z klatki schodowej, balkon z drzwiami balkonowymi. Istnieje domofon analogowy spółdzielni (panel przy wejściu do klatki).

| Parametr | Wartość |
| --- | --- |
| Powierzchnia | ~50 m² (2 pokoje, kuchnia, łazienka, przedpokój) |
| Piętro | 3. (balkon dostępny przez pion balkonów) |
| Wykończenie | gotowe — wymagany montaż bezinwazyjny |
| Punkty wejścia | drzwi wejściowe + drzwi balkonowe |
| Domofon istniejący | analogowy, spółdzielczy (unifon) |
| Internet | Wi-Fi router (operator) |

## 2. Analiza zagrożeń

| Zagrożenie | Prawdopodobieństwo | Środek zaradczy |
| --- | --- | --- |
| Włamanie przez drzwi wejściowe | średnie | kontaktron drzwi + PIR przedpokoju |
| Wejście przez balkon (pion, sąsiednie balkony) | średnie | kontaktron drzwi balkonowych + PIR pokoju |
| Zalanie (pralka, instalacja) | średnie | czujka zalania bezprzewodowa pod zlewem/pralką |
| Pożar/zadymienie | niskie | bezprzewodowa czujka dymu |
| Brak możliwości ingerencji w ściany | — | system w pełni bezprzewodowy, montaż na taśmę/kołki punktowe |

Kluczowe ograniczenie: **brak kucia**. Cały system musi być bezprzewodowy (czujki na baterie), a kamery na Wi-Fi. To podnosi cenę pojedynczych elementów, ale eliminuje koszt i bałagan okablowania.

## 3. Dobór systemów

### 3.1 Alarm bezprzewodowy

Dwa sensowne warianty — **Ajax** (premium, najlepsza aplikacja) lub **Satel Micra / Perfecta 16-WRL** (tańszy, polski). Poniżej wariant **Ajax Hub 2** jako wzorcowy, z alternatywą Satel w tabeli kosztów.

- **Centrala** Ajax *Hub 2 (4G)* — komunikacja Wi-Fi/Ethernet + 2× SIM LTE, fotoweryfikacja
- **2× czujka ruchu** Ajax *MotionCam* (PIR z aparatem — zdjęcie przy alarmie) — pokój dzienny i przedpokój
- **2× kontaktron** Ajax *DoorProtect* — drzwi wejściowe i balkonowe
- **1× czujka dymu** Ajax *FireProtect*
- **1× czujka zalania** Ajax *LeaksProtect* — pod zlewem/pralką
- **Klawiatura** Ajax *KeyPad* (lub uzbrajanie wyłącznie z aplikacji / brelokiem *SpaceControl*)
- **Syrena wewnętrzna** Ajax *HomeSiren*

Ajax montuje się na uchwytach *SmartBracket* — wystarczą 2 wkręty lub taśma 3M. Baterie w czujkach starczają na **5–7 lat**, więc po montażu system jest praktycznie bezobsługowy.

### 3.2 Monitoring wizyjny (1–2 kamery)

Bez NVR — zapis na karcie microSD w kamerze i/lub w chmurze. Dla 50 m² wystarczy 1 kamera obejmująca przedpokój + drzwi; druga opcjonalnie w pokoju z balkonem.

- **1–2× kamera IP Wi-Fi wewnętrzna** — Hikvision *DS-2CD2443G2-IW* (4 Mpx, Wi-Fi, mikrofon, slot microSD do 256 GB) lub Reolink *E1 Pro* (obrotowa, tańsza)
- **Karta microSD** 128 GB high-endurance (np. Samsung PRO Endurance) — zapis zdarzeniowy ~30 dni
- Opcjonalnie: subskrypcja chmury (Hik-Connect Cloud / Reolink) jako kopia zapasowa nagrań

**Prywatność:** kamera w wynajmowanym mieszkaniu — informuj najemcę, kieruj obiektyw wyłącznie na strefę wejścia/własności, nie na sypialnie. Kamera „na klatce" wymaga zgody wspólnoty/spółdzielni.

### 3.3 Wideodomofon

Dwie ścieżki w zależności od regulaminu bloku:

- **Wariant A — własny wideodomofon IP w mieszkaniu:** stacja przy drzwiach mieszkania (nie przy wejściu do klatki) + monitor, np. zestaw Hikvision *DS-KIS603-P*. Pozwala zobaczyć, kto puka do drzwi mieszkania.
- **Wariant B — adapter do domofonu blokowego:** moduł konwertujący istniejący unifon analogowy na połączenie do aplikacji w telefonie — *2N Indoor View* lub adapter *Akuvox* (gdy budynek ma cyfrowy panel). Pozwala odbierać wywołanie z panelu klatki na telefon.

W projekcie przyjęto **Wariant A** (najmniej zależny od spółdzielni): mini-zestaw wideodomofonu IP przy drzwiach mieszkania, zasilany PoE z dołączonej zasilarki, z odbiorem na telefon przez Hik-Connect.

## 4. Lista urządzeń z cenami (2026)

| Element | Model | Ilość | Cena jedn. (zł) | Razem (zł) |
| --- | --- | --- | --- | --- |
| Centrala alarmowa | Ajax Hub 2 (4G) | 1 | 950 | 950 |
| Czujka ruchu z aparatem | Ajax MotionCam | 2 | 320 | 640 |
| Kontaktron bezprzewodowy | Ajax DoorProtect | 2 | 120 | 240 |
| Czujka dymu | Ajax FireProtect | 1 | 320 | 320 |
| Czujka zalania | Ajax LeaksProtect | 1 | 140 | 140 |
| Klawiatura bezprzewodowa | Ajax KeyPad | 1 | 330 | 330 |
| Syrena wewnętrzna | Ajax HomeSiren | 1 | 180 | 180 |
| Kamera IP Wi-Fi wewn. | Hikvision DS-2CD2443G2-IW | 2 | 420 | 840 |
| Karta microSD 128 GB | Samsung PRO Endurance | 2 | 90 | 180 |
| Zestaw wideodomofonu IP | Hikvision DS-KIS603-P | 1 | 980 | 980 |
| Drobnica (taśmy 3M, kołki, listwy nawierzchniowe) | — | — | — | 150 |
| **Razem materiały — wariant Ajax (brutto)** | | | | **~4 950 zł** |
| *Wariant tańszy:* centrala Satel **Perfecta 16-WRL** (~520 zł) + 2× PIR APD-100 (~110 zł/szt) + 2× kontaktron MMD-302 (~70 zł/szt) + czujka dymu + GSM wbudowany → zestaw alarmowy ~**1 500–1 800 zł** zamiast ~2 800 zł (Ajax). | | | | |

## 5. Schemat rozmieszczenia (strefy)

Mieszkanie traktowane jako jedna strefa z trybem nocnym (wyłączenie PIR w sypialni).

| Pomieszczenie | Urządzenia |
| --- | --- |
| Przedpokój | MotionCam (PIR + foto), klawiatura KeyPad przy drzwiach, kamera IP nad wejściem, monitor domofonu |
| Pokój dzienny (z balkonem) | MotionCam, DoorProtect na drzwiach balkonowych, Hub 2 (centrala), syrena HomeSiren |
| Drzwi wejściowe | DoorProtect, stacja wideodomofonu po stronie korytarza/drzwi |
| Kuchnia | FireProtect (sufit), LeaksProtect (pod zlewem/za pralką) |
| Sypialnia | brak czujek aktywnych w trybie nocnym (komfort domowników) |

| Tryb | Aktywne czujki |
| --- | --- |
| **Pełne uzbrojenie (wyjście)** | oba PIR + oba kontaktrony |
| **Tryb nocny** | kontaktrony drzwi/balkon + PIR przedpokoju (PIR pokoju wyłączony) |
| 24h zawsze | czujka dymu i zalania (niezależne od uzbrojenia) |

## 6. Kosztorys (materiały + robocizna 2026)

| Pozycja | Zakres | Koszt (zł) |
| --- | --- | --- |
| Materiały — alarm Ajax | Hub 2, 2 PIR, 2 kontaktrony, dym, zalanie, klawiatura, syrena | ~2 800 |
| Materiały — CCTV | 2 kamery Wi-Fi + karty microSD | ~1 020 |
| Materiały — domofon | zestaw wideodomofonu IP | ~980 |
| Drobnica montażowa | taśmy, kołki, listwy | ~150 |
| Robocizna — montaż i konfiguracja | system bezprzewodowy, kamery, domofon, aplikacje (~1 dzień) | ~900 |
| Szkolenie użytkownika | obsługa aplikacji Ajax + Hik-Connect | ~150 |
| **RAZEM — wariant Ajax (brutto)** | | **~6 000 zł** |
| **RAZEM — wariant Satel Perfecta (brutto)** | | **~3 800–4 500 zł** |

Montaż bezprzewodowy jest szybki — całość zwykle **1 dzień** robocizny (brak prowadzenia kabli). Dlatego udział robocizny w cenie jest niski w porównaniu z domem przewodowym.

## 7. Uwagi wdrożeniowe

- **Bezinwazyjność:** czujki Ajax na uchwytach SmartBracket (taśma 3M lub 2 wkręty) — bez kucia, idealne do wynajmu; przy wyprowadzce można zdemontować bez śladów.
- **Abonament:** Ajax działa bez abonamentu (powiadomienia PUSH za darmo). Chmura nagrań CCTV (Hik-Connect/Reolink) jest opcjonalna — ~10–20 zł/mies. za przechowywanie poza kartą.
- **Zasięg radiowy:** w bloku z grubymi ścianami sprawdź siłę sygnału w aplikacji (test Jeweller); w razie potrzeby dodaj retranslator Ajax *ReX 2* (~430 zł).
- **Domofon blokowy:** jeśli regulamin pozwala, adapter 2N/Akuvox do istniejącego unifonu przekieruje wywołanie z panelu klatki na telefon — alternatywa Wariantu A.
- **Zasilanie:** centrala i kamery mają podtrzymanie bateryjne (Hub 2 ~16 h); router warto podtrzymać małym UPS, by powiadomienia działały przy zaniku prądu.
- **Zgody:** kamera skierowana poza mieszkanie (klatka, korytarz wspólny) wymaga zgody wspólnoty/spółdzielni — w projekcie kamery patrzą wyłącznie do wnętrza lokalu.
