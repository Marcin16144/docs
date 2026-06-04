# Wideodomofony IP i 2-wire

**Sekcja:** 13 Kontrola dostępu i domofony · **Aktualizacja:** 2026-05

Wideodomofon 2-żyłowy cyfrowy vs IP (LAN/PoE). Integracja ze smartfonem (Hik-Connect, DMSS Dahua), protokół SIP i serwery SIP. Marki: Hikvision (DS-KD/KH/KV), Dahua (VTO/VTH), Vidos Duo, Akuvox, Fanvil, BAS-IP. Nagrywanie gości, integracja z CCTV i KD, otwieranie bramy + furtki.

## 2-wire vs IP — dwie filozofie

Współczesne wideodomofony budowane są w dwóch architekturach. **2-wire** (2-żyłowy cyfrowy) to magistrala dwuprzewodowa niosąca zasilanie, wideo, audio i dane — bezpośrednia ewolucja domofonów analogowych, idealna do modernizacji. **IP** to urządzenia sieciowe komunikujące się po LAN (zwykle **PoE**), traktowane jak kamery i monitory w sieci komputerowej.

| Cecha | 2-wire (2-żyłowy cyfrowy) | IP (LAN / PoE) |
| --- | --- | --- |
| Medium | 2 żyły (magistrala firmowa) | skrętka Cat5e/6, switch PoE |
| Zasilanie | z magistrali / zasilacza systemu | PoE (802.3af/at) lub zasilacz |
| Skalowalność | ograniczona (system jednego producenta) | bardzo wysoka (adresacja IP, sieć) |
| Integracja z CCTV/KD | w obrębie ekosystemu | natywna (ONVIF, SIP, NVR, VMS) |
| Modernizacja istniejących żył | łatwa (reużycie 2 żył) | wymaga doprowadzenia skrętki |
| Koszt wejścia | niższy | wyższy (switch PoE, infrastruktura) |
| Najlepsze do | dom, mała wielorodzinka, remont | biura, osiedla, integracja z monitoringiem |

Producenci tacy jak Hikvision i Dahua oferują **oba warianty** i konwertery 2-wire↔IP, więc można zacząć od 2-wire, a później wpiąć system w sieć IP bez wymiany całości.

## Wideodomofony IP — parametry panelu

Panel IP (zewnętrzny) to w praktyce kamera sieciowa z interkomem. Najważniejsze parametry:

- **Zasilanie PoE** — jeden kabel Cat5e/6 niesie zasilanie i dane; klasa *802.3af* (do 15,4 W) lub *802.3at/PoE+* (do 30 W, dla paneli z podgrzewaniem/dużym IR).
- **Rozdzielczość kamery** — minimum **2 MP (1080p)**, w lepszych modelach 4 MP; szeroki zakres dynamiki *WDR* przy ostrym świetle za plecami gościa.
- **Praca nocna (IR)** — diody podczerwieni do kilku metrów, by rozpoznać twarz po zmroku.
- **Kąt widzenia** — szeroki (np. 120–180°, czasem „rybie oko"), by objąć całą sylwetkę gościa z bliska.
- **Wandaloodporność IK** — klasa **IK08–IK10** dla paneli narażonych na uderzenia (klatki, ulica) oraz szczelność **IP65/IP66** na zewnątrz.

## Integracja ze smartfonem

Kluczowa zaleta wideodomofonów IP/2-wire nowej generacji — odbiór wizyty na telefonie z dowolnego miejsca. Każdy ekosystem ma własną aplikację:

| Producent | Aplikacja | Funkcje |
| --- | --- | --- |
| Hikvision | **Hik-Connect** | powiadomienie push o wywołaniu, rozmowa audio/wideo na żywo, zdalne otwarcie zamka, podgląd kamery panelu, historia wizyt |
| Dahua | **DMSS** | j.w. + integracja z urządzeniami Dahua (NVR, alarm), wiele paneli/monitorów |
| Akuvox | **Akuvox SmartPlus** (chmura SIP) | SIP w chmurze, zarządzanie wielomieszkaniowe, czasowe kody/QR dla gości |
| BAS-IP | **BAS-IP Intercom / Link** | chmura SIP, zarządzanie osiedlem, integracja z systemami zarządzania budynkiem |

Typowy scenariusz: gość naciska przycisk → panel dzwoni jednocześnie na monitory wewnętrzne **i** na smartfony domowników (push) → odbierasz rozmowę z telefonu, widzisz gościa i naciskasz „otwórz" niezależnie czy jesteś w domu, czy w pracy.

Powiadomienia push wymagają działającego internetu i konta w chmurze producenta (Hik-Connect/DMSS są darmowe). Dla niezawodności łącza warto mieć UPS na routerze/switchu PoE — przy zaniku prądu panel i sieć przestaną działać.

## Protokół SIP

**SIP** (Session Initiation Protocol) to otwarty standard telefonii VoIP wykorzystywany w profesjonalnych wideodomofonach IP. Pozwala uniezależnić się od chmury jednego producenta i zbudować rozproszony system z wieloma monitorami, centralami i telefonami.

- **Wiele monitorów / urządzeń** — jedno wywołanie z panelu dzwoni równolegle na wszystkie zarejestrowane „rozszerzenia" SIP (monitory, telefony VoIP, softphone na PC).
- **Serwer SIP (PBX)** — np. *Asterisk*, *FreePBX*, *3CX* lub wbudowany w panel/monitor mini-SIP; zarządza rejestracją i zestawianiem połączeń.
- **Integracja z centralami** — wideodomofon staje się jednym z numerów wewnętrznych firmowej centrali telefonicznej; recepcja odbiera wizytę na telefonie biurkowym.
- **Interoperacyjność** — panele Akuvox, Fanvil, BAS-IP są w pełni SIP-owe, więc mogą współpracować z urządzeniami różnych producentów (w przeciwieństwie do zamkniętych systemów 2-wire).

```
# Przykład rejestracji panelu IP jako klienta SIP (FreePBX/Asterisk)
Extension / numer:   201
Hasło SIP:           ********
Serwer (PBX):        192.168.1.10
Transport:           UDP 5060 (lub TLS 5061 dla szyfrowania)
Wywołanie panelu →   dzwoni 201 -> grupa: 301 (monitor), 302 (telefon), softphone
```

## Marki — modele i ceny 2026

| Marka / linia | Przykładowy model | Opis | Cena (2026) |
| --- | --- | --- | --- |
| **Hikvision** DS-KD (panel) | DS-KD8003-IME1 | panel IP modułowy 2 MP, PoE, czytnik Mifare, wandaloodporny | ~950 zł |
| Hikvision DS-KH (monitor) | DS-KH6320-WTE1 | monitor IP 7", dotykowy, Wi-Fi, Hik-Connect | ~780 zł |
| Hikvision DS-KV (panel kompakt.) | DS-KV6113-WPE1(C) | panel IP jednorodzinny 2 MP, natynkowy, PoE | ~620 zł |
| **Dahua** VTO (panel) | VTO2211G-P | panel IP 2 MP, PoE, czytnik kart, IK08 | ~700 zł |
| Dahua VTH (monitor) | VTH2622GW-P | monitor IP 7" dotykowy, PoE, DMSS | ~720 zł |
| **Vidos Duo** (2-wire) | Vidos Duo zestaw S1102D-2 + M1023 | polski system 2-żyłowy, panel + monitor 7" | ~1300 zł (zestaw) |
| **Akuvox** | R29C / R20B | panel SIP z czytnikiem (R29) / kompaktowy SIP (R20B) | ~1200–2400 zł |
| **Fanvil** | i30 / i64 | panele SIP wideo, dobra integracja z PBX | ~900–1600 zł |
| **BAS-IP** | AV-08FB / AQ-07 | panel SIP + monitor 7" Android, systemy osiedlowe | ~1500–3000 zł |

## Funkcje zaawansowane

### Nagrywanie gości

- **Snapshot przy wywołaniu** — automatyczne zdjęcie gościa, gdy nikt nie odbierze (zapisane na karcie microSD monitora lub na NVR).
- **Wideo na żądanie** — nagranie rozmowy/podglądu na karcie w monitorze lub strumień do rejestratora.
- **Zapis na NVR** — panel IP traktowany jak kamera ONVIF i nagrywany 24/7 na rejestratorze sieciowym (ślad zdarzeń przy furtce).

### Integracja z CCTV i KD

- **Podgląd kamer CCTV na monitorze domofonu** — monitory Hikvision/Dahua wyświetlają obraz z kamer IP w sieci (np. brama, podwórko) obok obrazu z panelu.
- **Wspólny ekosystem KD** — panel z wbudowanym czytnikiem Mifare pełni rolę przejścia kontroli dostępu; zdarzenia trafiają do platformy producenta.
- **Zdarzenie → nagranie** — wywołanie/otwarcie wyzwala znacznik na NVR (jak w rozdz. 13-01).

### Otwieranie bramy i furtki — 2 przekaźniki

Większość paneli IP/2-wire ma **dwa wyjścia przekaźnikowe (relay)**, co pozwala niezależnie sterować dwoma elementami: *relay 1 → furtka (elektrozaczep)*, *relay 2 → brama wjazdowa (sterownik napędu)*. Na monitorze i w aplikacji pojawiają się wtedy dwa osobne przyciski otwarcia.

Wyjścia przekaźnikowe są zwykle **beznapięciowe (suchy styk)** — nie zasilają zaczepu bezpośrednio. Zaczep/zworę zasil z osobnego zasilacza, a przekaźnik użyj tylko do zwarcia obwodu. Sprawdź obciążalność styku (np. 30 V / 2 A) i dobierz odpowiednie napięcie elementu wykonawczego.

## Okablowanie i monitor wewnętrzny

- **Kabel:** dla IP — **skrętka Cat5e/Cat6** (PoE), prowadzenie jak w sieci LAN; dla 2-wire — przewód zalecany przez producenta (często skrętka lub dedykowany 2-żyłowy).
- **Switch PoE** — zasila panel i monitory PoE; dla kilku urządzeń wybierz switch z zapasem mocy (budżet PoE) i ewentualnie zarządzalny (VLAN dla domofonu).
- **Monitor wewnętrzny** — dotykowy ekran **7"–10"**, montaż natynkowy; funkcje: rozmowa głośnomówiąca, otwieranie 2 wyjść, podgląd kamer, interkom między monitorami, ustawienia push.
- **Zasięg:** standard Ethernet to **100 m** na segment skrętki; dla dłuższych tras stosuj switche pośrednie / ekstendery PoE.

Dla systemu IP warto wydzielić domofon w osobnym **VLAN-ie** i podać statyczne adresy IP panelom/monitorom — ułatwia to diagnostykę i izoluje ruch od reszty sieci domowej/firmowej.
