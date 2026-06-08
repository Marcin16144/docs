# Projekty krok po kroku i koszty

Czas złożyć wiedzę z poprzednich rozdziałów w **konkretne, działające projekty**. Każdy ma listę części, kolejność montażu i orientacyjną sumę kosztów (PLN, 2026). Zaczynają się od najłatwiejszego.

## Projekt 1: Światło na czujnik ruchu (poziom: łatwy)

Klasyczny pierwszy projekt — światło w klatce/garażu/łazience, które samo zapala się po zmierzchu, gdy wykryje ruch, i gaśnie po 2 minutach.

**Części**
| Element | Cena |
|---------|------|
| Shelly Plus 1 (przekaźnik za włącznikiem) | 60–90 zł |
| Czujnik ruchu Zigbee (lub PIR na wejściu Shelly) | 25–70 zł |
| Drobne (przewody, kostki) | 10–20 zł |
| **Razem** | **~95–180 zł** |

**Kroki**
1. **Wyłącz bezpiecznik** obwodu światła i sprawdź brak napięcia próbnikiem.
2. Zamontuj Shelly w puszce za włącznikiem (sprawdź obecność przewodu **N**). Jeśli nie czujesz się pewnie — **elektryk**.
3. Załącz zasilanie, sparuj Shelly z WiFi i dodaj do Home Assistant.
4. Dodaj czujnik ruchu (Zigbee → koordynator albo wejście Shelly).
5. Automatyzacja: *gdy ruch i po zachodzie słońca → włącz na 2 min*. Warunek zmierzchu z pozycji słońca w HA.

**Wariant bez ingerencji w 230 V:** smart żarówka (IKEA/Hue) + bezprzewodowy czujnik ruchu Zigbee — montaż „bez śrubokręta", ale klasyczny włącznik trzeba zostawić załączony.

## Projekt 2: Automatyczne nawadnianie grządki (poziom: średni)

ESP32 podlewa warzywnik według wilgotności gleby i pomija podlewanie, gdy zapowiadany jest deszcz. To „wizytówka" DIY z rozdziału 06.

**Części**
| Element | Cena |
|---------|------|
| ESP32 (DevKit) | 20–45 zł |
| Moduł przekaźnikowy 2-kanałowy | 10–20 zł |
| 2× elektrozawór 12 V DC + dioda gasząca | 50–120 zł |
| Czujnik wilgotności gleby (pojemnościowy) | 8–20 zł |
| Zasilacz 12 V/2 A + przetwornica do 5 V | 30–55 zł |
| Obudowa IP65 + dławiki | 25–50 zł |
| Linia kropelkująca + złączki + filtr | 70–160 zł |
| **Razem** | **~215–470 zł** |

**Kroki**
1. Zmontuj na stole: ESP32 → przekaźniki → zawory (z **diodą gaszącą** na cewkach), czujnik gleby na ADC.
2. Wgraj **ESPHome** (czujnik gleby, dwa wyjścia zaworów) i dodaj do Home Assistant.
3. Reguła: *gdy wilgotność < 30% i godzina 5:00–7:00 i brak prognozy deszczu → otwórz strefę na 10 min*; histereza do 45%.
4. Zamknij elektronikę w obudowie **IP65**, czujnik w ziemi, zawory na linii wodnej z **filtrem**.
5. (Opcjonalnie) Pompa 12 V z beczki + pływak suchobiegu, jeśli korzystasz z deszczówki.

## Projekt 3: Monitoring klimatu (poziom: łatwy)

Pomiar temperatury i wilgotności w pomieszczeniach/ogrodzie z wykresami i powiadomieniami — fundament pod sterowanie ogrzewaniem i wentylacją.

**Części**
| Element | Cena |
|---------|------|
| ESP32 + czujnik BME280 (I²C) | 35–80 zł |
| lub gotowe czujniki Zigbee (np. temp/wilg) ×2–3 | 60–150 zł |
| (jeśli Zigbee) koordynator USB | 60–200 zł |
| **Razem** | **~95–430 zł** |

**Kroki**
1. ESP32 + BME280 na I²C, firmware **ESPHome** → dane lecą do HA. (Albo po prostu sparuj czujniki Zigbee z koordynatorem.)
2. Pulpit z wykresami; powiadomienie „wilgotność > 65%" (ryzyko pleśni) lub „temperatura < 5°C w garażu" (mróz).
3. Rozbudowa: czujnik **CO₂** do sterowania wentylacją, **DS18B20** na rurach CO.

## Projekt 4: Podświetlenie schodów (poziom: średni, „efektowny")

Taśma adresowalna zapala stopnie kolejno, gdy ktoś wchodzi.

**Części**
| Element | Cena |
|---------|------|
| ESP32 | 20–45 zł |
| Taśma WS2812B/SK6812 (wg liczby stopni) | 50–150 zł |
| Zasilacz 5 V/5–10 A | 40–80 zł |
| 2× czujnik ruchu (dół/góra) | 10–60 zł |
| Drobne (kondensator, rezystor danych, przewody) | 15–30 zł |
| **Razem** | **~135–365 zł** |

**Kroki:** ESP32 + ESPHome (efekt „spływania"), PIR na dole i górze wyzwalają animację w odpowiednią stronę, wygaszanie po przejściu; jasność zależna od pory dnia.

## Od czego zacząć — budżety

| Budżet | Co realnie zbudujesz |
|--------|----------------------|
| **~100 zł** | Jeden inteligentny obwód: Shelly za włącznikiem **lub** ESP32 + przekaźnik + czujnik. Pierwszy sukces. |
| **~300 zł** | Centralka na sprzęcie, który masz (stary laptop/mini-PC) + 2–3 urządzenia (światło + czujnik + nawadnianie warzywnika). |
| **~1000 zł** | Dedykowana centralka (Pi/HA Green) + koordynator Zigbee + kilka świateł (Shelly) + nawadnianie 2 stref + monitoring klimatu. |
| **2000+ zł** | Rozbudowany dom i ogród: wiele stref nawadniania, oświetlenie w całym domu, kamery, rolety, magazyn historii i kopie zapasowe. |

> **Nie kupuj wszystkiego naraz.** Zacznij od jednego działającego projektu, naucz się centralki, dopiero potem rozbudowuj. Tak unikniesz pudełka pełnego niepasujących do siebie gadżetów.

## Sugerowana kolejność rozbudowy

1. **Centralka** (Home Assistant) — fundament, do którego wszystko dołączysz.
2. **Jedno światło** na czujnik (szybki efekt, nauka automatyzacji).
3. **Czujniki klimatu** (wykresy, powiadomienia — „widzisz" dom).
4. **Nawadnianie** ogrodu (realna oszczędność czasu i wody).
5. **Bezpieczeństwo** (zalanie, otwarcie, dym) i **energia** (pomiar zużycia).
6. **Rolety, ogrzewanie, kamery** — gdy podstawy działają stabilnie.

## Gdzie kupować (Polska, 2026)

- **Botland, Kamami, Abox, TME** — moduły, ESP32, czujniki, elektronika; szybka wysyłka, polskie wsparcie.
- **Allegro** — gotowe moduły (Shelly, Sonoff), czujniki, kompletne zestawy; szeroki wybór i zwroty.
- **AliExpress** — najtaniej (zwłaszcza hurtem), ale **dłuższa dostawa** i zmienna jakość; dobre na czujniki i drobnicę.
- **Leroy Merlin, OBI, Castorama** — część ogrodowa: zawory, węże, kropelkowanie, zasilacze, puszki IP.
- **Sklepy ogrodnicze / Gardena, Hunter** — gotowe systemy nawadniania i akcesoria.

## Najczęstsze błędy początkujących

- **Za słaby zasilacz** — losowe restarty i „dziwne" zachowanie; dobieraj prąd z zapasem.
- **Czujnik gleby rezystancyjny** — skoroduje; bierz **pojemnościowy**.
- **Brak izolacji od 230 V** — śmiertelne ryzyko; używaj przekaźników/Shelly, nie kombinuj „na styk".
- **Wszystko w chmurze** — uzależniasz dom od cudzego serwera; wybieraj **lokalne** (Shelly, ESPHome, Zigbee).
- **Brak IP w ogrodzie** — wilgoć zabija elektronikę; obudowy IP65, dławiki, złącza wodoszczelne.
- **Brak kopii zapasowej centralki** — awaria karty SD = konfiguracja od zera; rób backupy i używaj SSD.
- **Za dużo naraz** — przytłoczenie i porzucony projekt; idź krok po kroku.
- **Brak diody gaszącej** przy cewkach (zawory, silniki) — uszkodzone tranzystory.

## Podsumowanie

Masz teraz pełną mapę: jak działa automatyka (01), na czym ją zbudować (02), jak elementy się komunikują (03), z jakich „zmysłów i mięśni" korzystać (04), jak zrobić światło (05) i nawadnianie (06) oraz jak spiąć to centralką (07). Zacznij od **jednego** projektu z tego rozdziału, postaw lokalną centralkę i rozbudowuj system w swoim tempie — to najtańsza i najprzyjemniejsza droga do własnego inteligentnego domu i ogrodu.
