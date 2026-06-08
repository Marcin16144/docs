# Sterowanie oświetleniem

Światło to najczęstszy pierwszy projekt — efekt widać od razu, a próg wejścia jest niski. Są **trzy drogi**, różniące się kosztem, ingerencją w instalację i elastycznością. Można je mieszać w jednym domu.

## Trzy sposoby na inteligentne światło

| Sposób | Na czym polega | Zalety | Wady |
|--------|----------------|--------|------|
| **Inteligentne żarówki** | Wymieniasz żarówkę na „smart" | Zero ingerencji w instalację, kolor i ściemnianie | Drogie przy wielu punktach; klasyczny włącznik odcina prąd |
| **Przekaźnik za włącznikiem** | Moduł (Shelly) w puszce pod istniejącym włącznikiem | Tani na punkt, **zwykły włącznik nadal działa**, sterujesz całym obwodem | Montaż w obwodzie 230 V |
| **Pełne DIY** | ESP32 + przekaźnik/MOSFET, taśmy LED | Maksymalna elastyczność, najtaniej masowo | Najwięcej pracy i wiedzy |

> **Złota zasada:** jeśli w pomieszczeniu jest **dużo punktów** (żyrandol z 5 żarówkami), taniej i wygodniej steruje się **całym obwodem** modułem za włącznikiem niż pięcioma „smart" żarówkami.

## Droga 1: inteligentne żarówki

Najprostsze wejście — wkręcasz i parujesz w aplikacji. Trzy główne ekosystemy:

- **Philips Hue (Zigbee)** — wzorzec jakości: stabilne, świetne kolory, bogata automatyka. Wymaga **mostka Hue** (Bridge) lub dowolnego koordynatora Zigbee. Najdroższe.
- **IKEA (Zigbee, dawniej Trådfri / dziś seria smart)** — bardzo dobry stosunek ceny do jakości, te same zalety Zigbee, integracja z Home Assistant.
- **Tuya / Smart Life (WiFi lub Zigbee)** — najtańsze, ogromny wybór, ale WiFi-owe wersje **domyślnie zależą od chmury**. Dobre na start, jeśli akceptujesz aplikację producenta.

**Uwaga praktyczna:** smart żarówka działa, tylko gdy ma prąd — jeśli ktoś zgasi klasycznym włącznikiem, stracisz nad nią kontrolę. Rozwiązania: zostawiać włącznik stale załączony i sterować aplikacją/przyciskiem bezprzewodowym, albo użyć modułu za włącznikiem (droga 2).

## Droga 2: przekaźnik za włącznikiem (rekomendowana)

Najlepszy kompromis dla większości domów. W puszce podtynkowej za istniejącym włącznikiem montujesz mały moduł, który steruje całym obwodem światła. **Tradycyjny włącznik nadal działa** (moduł czyta jego stan), a dodatkowo sterujesz z aplikacji, głosem i automatyką.

- **Shelly Plus 1** — bezpotencjałowy przekaźnik (zał./wył.) do dowolnego obwodu.
- **Shelly Plus 1PM** — jw. + **pomiar mocy** (wiesz, ile pali oświetlenie).
- **Shelly Plus 2PM** — dwa obwody lub roleta.
- **Shelly Dimmer** — **ściemnianie** 230 V (dla ściemnialnych źródeł).
- **Sonoff MINI / ZBMINI** — tańsza alternatywa (WiFi / Zigbee).

Działają **lokalnie** (Shelly bez chmury), integrują się z Home Assistant. Wymaga to pracy w obwodzie 230 V — patrz ostrzeżenie poniżej. Sprawdź, czy w puszce jest **przewód neutralny (N)**; część modułów go wymaga (starsze instalacje miewają tylko fazę w puszce włącznika).

> ### ⚠️ Bezpieczeństwo 230 V
> Montaż modułu w obwodzie sieciowym oznacza pracę z napięciem śmiertelnym. **Wyłącz bezpiecznik**, sprawdź brak napięcia próbnikiem, pracuj zgodnie z instrukcją modułu. Jeśli nie masz doświadczenia z instalacją elektryczną — **zleć montaż elektrykowi** (sam moduł i tak skonfigurujesz w aplikacji). Stałe zmiany w instalacji bywają objęte wymogami formalnymi.

## Droga 3: pełne DIY i taśmy LED

Tam, gdzie nie ma „żarówki" do wymiany — podświetlenie schodów, blatu, szafy, ogrodu:

- **Taśma jednokolorowa 12/24 V** — sterowana jednym **MOSFET-em** z ESP32 (PWM = płynne ściemnianie). Najtańsze i najłatwiejsze.
- **Taśma RGB / RGBW** — kolor; 3–4 kanały MOSFET lub gotowy kontroler (np. **Shelly RGBW2**, **Sonoff**).
- **Taśma adresowalna WS2812B/SK6812** — każda dioda osobno (efekty, „spływające" schody). Jeden pin danych z ESP32 + porządne zasilanie 5 V.
- **Schody krok po kroku** — czujnik ruchu/PIR na dole i górze + ESP32 + taśma adresowalna = efekt kolejno zapalających się stopni. Klasyczny „wow"-projekt.

## Automatyzacje, które warto włączyć

- **Ruch + zmierzch** — światło w klatce/garażu/łazience zapala się, **tylko gdy jest ciemno i wykryto ruch**, i gaśnie po zadanym czasie. Czujnik zmierzchu (LDR) blokuje działanie w dzień.
- **Obecność (mmWave)** — w gabinecie/salonie radar utrzymuje światło, dopóki ktoś tam jest (nawet bez ruchu) — koniec z gaśnięciem „bo siedzę nieruchomo".
- **Harmonogram / wschód–zachód słońca** — oświetlenie zewnętrzne i elewacja wg kalendarza słońca (centralka zna godziny wschodu/zachodu dla Twojej lokalizacji).
- **Symulacja obecności** — podczas wakacji światła zapalają się „jak gdyby ktoś był", odstraszając.
- **Sceny** — „Film" (przygaszenie), „Dobranoc" (gaszenie wszystkiego), „Poranek" (delikatne rozjaśnianie).
- **Sterowanie głosem** — przez Google/Alexa/Siri albo lokalnie (rozdział 07).

## Przykładowe zestawy i koszty (PLN, 2026)

**A. Budżetowo — jeden obwód, jeden pokój**
| Element | Cena |
|---------|------|
| Shelly Plus 1 (lub Sonoff MINI) | 60–90 zł |
| Robocizna (jeśli elektryk) | 50–120 zł |
| **Razem** | **~110–210 zł** |

**B. Klimatyczne podświetlenie (taśma LED, DIY)**
| Element | Cena |
|---------|------|
| ESP32 + moduł MOSFET | 30–55 zł |
| Taśma LED 12 V (3 m, COB) | 45–90 zł |
| Zasilacz 12 V / 3 A | 30–50 zł |
| Drobne (przewody, puszka) | 20–40 zł |
| **Razem** | **~125–235 zł** |

**C. Automatyczne światło „ruch + zmierzch" (klatka/garaż)**
| Element | Cena |
|---------|------|
| Shelly Plus 1 | 60–90 zł |
| Czujnik ruchu (PIR Zigbee lub wejście do Shelly) | 25–70 zł |
| **Razem** | **~85–160 zł** |

**D. Premium kolorowe (salon, ekosystem Hue)**
| Element | Cena |
|---------|------|
| Mostek/koordynator Zigbee | 60–200 zł |
| 3× żarówka kolorowa Hue/IKEA | 150–450 zł |
| Przycisk/pilot bezprzewodowy | 40–120 zł |
| **Razem** | **~250–770 zł** |

## Co wybrać — szybki przewodnik

- **Wynajmujesz / zero ingerencji** → inteligentne żarówki (IKEA = najlepsza cena, Hue = jakość).
- **Własny dom, chcesz zachować zwykłe włączniki** → **Shelly za włącznikiem** (droga 2).
- **Podświetlenie schodów/blatu/ogrodu** → **ESP32 + taśma LED** (droga 3).
- **Dużo punktów w jednym obwodzie** → steruj całym obwodem modułem, nie pojedynczymi żarówkami.

---

➡️ Dalej: **[06 — Nawadnianie i woda w ogrodzie](06-woda-ogrod.html)** — drugi kompletny scenariusz, od elektrozaworu po integrację z prognozą pogody.
