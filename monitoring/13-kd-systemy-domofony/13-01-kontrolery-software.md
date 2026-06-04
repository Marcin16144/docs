# Kontrolery i software KD

**Sekcja:** 13 Kontrola dostępu i domofony · **Aktualizacja:** 2026-05

Systemy kontroli dostępu (KD/ACS): kontroler, czytnik, zamek i software zarządzający. Polski Roger (RACS 5, MC16), Satel ACCO (ACCO-NET, ACCO-KP), brytyjski Paxton (Net2, Paxton10), HID, ZKTeco. Magistrala RS-485, Wiegand vs OSDP, integracja z alarmem (ACCO + Integra) i CCTV.

## Czym jest kontrola dostępu (KD / ACS)

Kontrola dostępu (pol. **KD**, ang. **Access Control System – ACS**) to system, który decyduje *kto*, *kiedy* i *którędy* może przejść przez chronione przejście. Zastępuje klucz mechaniczny identyfikatorem elektronicznym (karta, PIN, odcisk palca) i prowadzi rejestr każdego zdarzenia. W odróżnieniu od zwykłego domofonu KD to system **uprawnień i logów**, a nie tylko otwierania drzwi.

Każde przejście KD składa się z czterech podstawowych elementów:

| Element | Rola | Przykład |
| --- | --- | --- |
| **Kontroler** | „mózg" — przechowuje uprawnienia, podejmuje decyzję otwarcia, steruje zamkiem, prowadzi bufor zdarzeń (działa też offline) | Roger MC16, Satel ACCO-KP, Paxton Net2 plus |
| **Czytnik** | odczytuje identyfikator (kartę, PIN, palec) i przesyła go do kontrolera | Roger MCT, czytnik Mifare, biometryczny |
| **Element wykonawczy (zamek)** | fizycznie blokuje/zwalnia drzwi na sygnał kontrolera | elektrozaczep, zwora elektromagnetyczna |
| **Software** | zarządza użytkownikami, harmonogramami, strefami, generuje raporty | RACS 5, ACCO-NET, Net2 |

Dodatkowo na drzwiach montuje się: **przycisk wyjścia** (EXIT, po stronie wewnętrznej), **kontaktron** (czujnik położenia drzwi — wykrywa wyważenie/zbyt długie otwarcie „door-forced / door-held") oraz **zasilacz buforowy** z akumulatorem.

## Topologie systemu

### Kontroler 1-drzwiowy vs wielodrzwiowy

To podstawowy wybór architektoniczny wpływający na koszt i niezawodność:

| Cecha | Kontroler 1-drzwiowy | Kontroler wielodrzwiowy |
| --- | --- | --- |
| Liczba przejść | 1 (czasem 1 dwustronne) | 2 / 4 / 8 drzwi z jednej płyty |
| Awaria | uszkodzenie blokuje tylko 1 drzwi | uszkodzenie może zablokować wszystkie podpięte drzwi |
| Okablowanie | więcej jednostek, krótsze trasy | jedna szafka, dłuższe trasy do drzwi |
| Koszt / drzwi | wyższy | niższy (współdzielona elektronika) |
| Przykład | Roger MC16 (1–2 przejścia) | Paxton Net2 plus, ZKTeco C3-400 (4 drzwi) |

W praktyce dla biur stosuje się kontrolery 2-drzwiowe (1 jednostka = 1 wejście dwustronne lub 2 jednostronne), a dla dużych obiektów (hotele, magazyny) wielodrzwiowe na piętro/strefę z magistralą RS-485 do nadrzędnego serwera.

### Magistrala komunikacyjna RS-485

Kontrolery łączą się z serwerem/sąsiednimi modułami magistralą **RS-485** (2 żyły danych A/B, topologia łańcuchowa „daisy chain", do **1200 m**, prędkości 9600–115200 bps). RS-485 jest odporny na zakłócenia i pozwala spiąć dziesiątki urządzeń na jednej linii. W nowszych systemach (Paxton10, RACS 5 z MC16) magistralą szkieletową bywa też **Ethernet/PoE**, a RS-485 zostaje tylko lokalnie do czytników i ekspanderów.

Magistralę RS-485 należy **terminować rezystorem 120 Ω** na obu końcach linii i prowadzić skrętką (np. żyła z ekranem). Topologia gwiazdy (rozgałęzienia) powoduje odbicia sygnału i błędy komunikacji.

### Wiegand vs OSDP — łącze czytnik ↔ kontroler

To kluczowa decyzja bezpieczeństwa. Sposób, w jaki czytnik przekazuje numer karty do kontrolera:

| Cecha | Wiegand (26/34-bit) | OSDP (SIA OSDP v2 / Secure Channel) |
| --- | --- | --- |
| Rok / status | lata 80., przestarzały, wciąż masowy | nowoczesny standard SIA, zalecany |
| Okablowanie | min. 2 żyły danych (D0/D1) + zasilanie, do ~100 m | 2 żyły RS-485 (A/B), do 1200 m, wiele czytników na 1 linii |
| Kierunek | jednokierunkowy (czytnik → kontroler) | dwukierunkowy (sterowanie LED, dźwiękiem, status) |
| Szyfrowanie | **brak** — łatwy do podsłuchu/wstrzyknięcia (atak „ESPKey") | **AES-128 Secure Channel (SCBK)** |
| Wykrycie sabotażu kabla | nie | tak (utrata komunikacji) |

**Wiegand jest niezabezpieczony.** Przewody D0/D1 prowadzone na zewnątrz (przy czytniku po stronie „brudnej") można podsłuchać urządzeniem typu ESPKey i sklonować przejście. Dla obiektów o podwyższonym bezpieczeństwie wybieraj czytniki i kontrolery z **OSDP Secure Channel** (Roger seria MCT z OSDP, HID Signo, Paxton).

## Marki i kontrolery — przegląd

### Roger (Polska) — RACS 5

Polski producent z Gościcina. System **RACS 5** oparty na uniwersalnym kontrolerze **MC16** (programowalny: KD, RCP, rejestracja czasu pracy, automatyka). Czytniki serii **MCT** (Mifare + OSDP/Wiegand), ekspandery MCX. Bardzo dobre wsparcie i dokumentacja w języku polskim.

| Model | Opis | Cena (2026) |
| --- | --- | --- |
| **MC16-PAC-2** | kontroler dostępu na 2 przejścia (licencja PAC) | ~950 zł |
| **MC16-PAC-4** | kontroler na 4 przejścia | ~1250 zł |
| **MCT80M-IO** | czytnik Mifare z klawiaturą + we/wy, OSDP | ~520 zł |
| **MCT12M** | czytnik zbliżeniowy Mifare, smukły | ~330 zł |
| **MCX2D / MCX4D** | ekspander I/O na 2 / 4 przejścia do MC16 | ~480–720 zł |

### Satel ACCO (Polska)

Linia KD polskiego Satela, idealna gdy obiekt ma już alarm *Integra*. Dwa warianty: autonomiczne kontrolery **ACCO-KP / ACCO-KP-PS** (z zasilaczem) zarządzane lokalnie oraz sieciowy system **ACCO-NET** (serwer + moduły ACCO-NT na Ethernet) dla wielu przejść i wielu lokalizacji.

| Model | Opis | Cena (2026) |
| --- | --- | --- |
| **ACCO-KP** | kontroler 1 przejścia (bez zasilacza) | ~390 zł |
| **ACCO-KP-PS** | kontroler 1 przejścia z zasilaczem buforowym | ~560 zł |
| **ACCO-NT** | kontroler sieciowy (Ethernet) do systemu ACCO-NET | ~720 zł |
| **CZ-EMM / CZ-EMM2** | czytnik zbliżeniowy 125 kHz (EM) / Mifare | ~150–230 zł |
| **ACCO-SOFT-LT** | oprogramowanie zarządzające (darmowe dla małych instalacji) | 0 zł |

### Paxton (Wielka Brytania)

Brytyjski lider rynku biurowego. **Net2** — sprawdzony system PC/serwer (kontrolery Net2 plus, ACU na Ethernet/RS-485). **Paxton10** — nowsza platforma łącząca KD i CCTV w jednym interfejsie webowym, kontrolery PoE. Licencja oprogramowania Net2 jest darmowa.

| Model | Opis | Cena (2026) |
| --- | --- | --- |
| **Net2 plus 1-door** | kontroler 1 drzwi, TCP/IP + RS-485 | ~1100 zł |
| **Net2 nano** | kontroler PoE w obudowie czytnika | ~900 zł |
| **Paxton10 Door Controller (PoE)** | kontroler 1 drzwi platformy Paxton10 | ~1350 zł |
| **Paxton KeyReader / czytnik P50** | czytnik zbliżeniowy/Bluetooth | ~430 zł |

### HID Global i ZKTeco

- **HID** — światowy standard w korporacjach. Czytniki **HID Signo** (OSDP, mobilny dostęp), karty **iCLASS SE / SEOS** (szyfrowane), kontrolery **VertX / Aero**. Premium cenowo (czytnik Signo ~700–900 zł).
- **ZKTeco** — chiński producent, bardzo dobry stosunek ceny do funkcji, mocny w biometrii. Kontrolery **InBio / C3** (2–4 drzwi, ~600–1100 zł), terminale biometryczne twarz+palec **SpeedFace**, software **ZKBioSecurity / BioTime** (RCP).

## Czytniki i identyfikatory

| Technologia | Częstotliwość / nośnik | Bezpieczeństwo | Uwagi |
| --- | --- | --- | --- |
| Zbliżeniowa **Unique / EM** | 125 kHz | niskie — karta łatwa do skopiowania | tania, masowa, do prostych instalacji |
| Zbliżeniowa **Mifare** | 13,56 MHz (DESFire EV2/EV3) | wysokie — szyfrowanie AES na karcie | zalecana, obsługa płatności/wielofunkcyjna |
| **Biometria — linie papilarne** | czytnik optyczny/pojemnościowy | wysokie — identyfikator „przy sobie" | problem przy brudnych/uszkodzonych palcach |
| **Biometria — twarz** | kamera 2D/3D (np. SpeedFace) | wysokie, bezdotykowa | popularna po pandemii, czuła na oświetlenie |
| **PIN / klawiatura** | kod cyfrowy | średnie — kod można podejrzeć/przekazać | często jako 2. składnik (karta + PIN) |
| **Mobilny — BLE / NFC** | smartfon (Bluetooth/NFC) | wysokie — szyfrowany token | HID Mobile Access, Roger, Paxton — wygoda |

**Uwierzytelnianie dwuskładnikowe (MFA):** dla serwerowni i stref krytycznych łączy się dwa czynniki, np. *karta Mifare + PIN* lub *karta + odcisk palca*. Harmonogram może wymuszać PIN tylko poza godzinami pracy.

## Software — funkcje zarządzające

Oprogramowanie (RACS 5, ACCO-NET, Net2, ZKBioSecurity) jest sercem zarządzania całym systemem:

- **Zarządzanie użytkownikami** — baza osób, przypisanie kart/PIN/biometrii, grupy uprawnień, zdjęcia, ważność identyfikatora (data od–do dla gości/pracowników czasowych).
- **Harmonogramy i strefy czasowe** — kto może wejść w danym oknie czasowym (np. sprzątanie 18:00–20:00, biuro pon–pt 7–19), kalendarze świąt.
- **Strefy dostępu** — przypisanie przejść do stref (parking, biuro, serwerownia) i nadawanie uprawnień grupowo.
- **Anti-passback (APB)** — blokada ponownego użycia karty na wejściu bez wcześniejszego wyjścia (zapobiega „podawaniu" karty drugiej osobie); odmiany: twardy/miękki, czasowy.
- **Raporty RCP (Rejestracja Czasu Pracy)** — naliczanie czasu pracy z odbić wejście/wyjście, nadgodziny, spóźnienia, eksport do kadr/płac (Roger RCP, ZKTeco BioTime).
- **Lockdown / tryb awaryjny** — natychmiastowe zablokowanie lub odblokowanie wszystkich drzwi z jednego przycisku (np. zagrożenie, ewakuacja).

## Integracja z systemem alarmowym i CCTV

### KD + alarm (Satel ACCO + Integra)

Największą zaletą wyboru jednego producenta (Satel) jest natywna integracja. Przykładowe scenariusze:

- **Autorozbrojenie strefy** — wejście autoryzowaną kartą przez ACCO automatycznie rozbraja powiązaną partycję Integry (pracownik nie wpisuje już kodu na klawiaturze alarmu).
- **Auto-uzbrojenie** — ostatnie wyjście z biura + zamknięcie drzwi uzbraja strefę.
- **Blokada wejścia przy uzbrojonej strefie** — KD nie otworzy drzwi do strefy, która jest uzbrojona, dopóki uprawniona osoba jej nie rozbroi.

W rozwiązaniach od różnych producentów integrację KD↔alarm realizuje się **stykowo**: wyjście przekaźnikowe alarmu (status uzbrojenia) → wejście kontrolera KD, oraz wyjście KD (autoryzacja) → wejście „klucz/strefa" w centrali alarmowej.

### KD + CCTV (zdarzenie → nagranie)

Powiązanie zdarzeń KD z systemem CCTV (VMS/NVR) pozwala wizualnie weryfikować przejścia:

- **Zdarzenie KD → bookmark/nagranie** — odbicie karty lub alarm „drzwi wyważone" wyzwala znacznik na osi czasu rejestratora i nagranie z kamery przy drzwiach.
- **Weryfikacja foto** — w software KD przy odbiciu wyświetla się zdjęcie z bazy *obok* klatki z kamery na żywo — ochrona widzi, czy karty użyła właściwa osoba.
- **Platformy zintegrowane** — Paxton10 łączy KD i CCTV w jednym interfejsie; Hikvision i Dahua integrują własne KD z NVR w ramach jednego ekosystemu.

## Zasilanie awaryjne i tryb przy zaniku napięcia

Kontroler KD zasilany jest z **zasilacza buforowego** (np. 12 V / 13,8 V) z akumulatorem żelowym, zapewniającym działanie 1–8 h po zaniku sieci 230 V. Kluczowe jest jednak zachowanie *zamka* po utracie zasilania:

| Tryb | Przy zaniku zasilania | Typowy element | Zastosowanie |
| --- | --- | --- | --- |
| **Fail-safe** (NC, „rewersyjny") | drzwi się **ODBLOKOWUJĄ** (zasilanie trzyma zamek) | zwora elektromagnetyczna, elektrozaczep rewersyjny | **drogi ewakuacyjne / PPOŻ**, wyjścia awaryjne |
| **Fail-secure** (NO) | drzwi pozostają **ZAMKNIĘTE** (zasilanie zwalnia zamek) | elektrozaczep zwykły (standardowy) | serwerownie, magazyny, kasy — gdzie liczy się ochrona mienia |

**PPOŻ — drzwi ewakuacyjne!** Na drogach ewakuacji prawo wymaga, by przy zaniku zasilania *oraz* przy alarmie pożarowym drzwi dały się otworzyć bez klucza/karty. Dlatego stosuje się **fail-safe** + przycisk awaryjny (ręczny zwalniacz, ang. *emergency break-glass*) zwierający zasilanie zwory, oraz powiązanie z centralą SSP (pożar → zwolnienie zwór). Nigdy nie montuj fail-secure na jedynej drodze ewakuacyjnej.

### Przykładowy schemat logiczny zwory na drodze ewakuacyjnej

```
230V ─► Zasilacz buforowy 12V/13,8V ─┬─► Akumulator (backup)
                                    │
                                    ├─► Zwora elektromagnetyczna (fail-safe, trzymana napięciem)
                                    │        ▲
              Przycisk EXIT ────────┘        │ przerwanie obwodu = otwarcie
              Przycisk awaryjny (break-glass)┘
              Wyjście NC centrali SSP (pożar) ┘  → zanik napięcia → drzwi otwarte
```
