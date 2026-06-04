# Satel Integra

**Sekcja:** 06 Centrale alarmowe · **Aktualizacja:** 2026-05

Polski producent z Gdańska. Najpopularniejsza centrala alarmowa SSWiN w Polsce. Serie INTEGRA 24/32/64/128/Plus, magistrala z rezystorami końcowymi, programowanie DLOAD X, klient mobilny GUARD X.

## Kim jest Satel

Satel powstał w 1990 r. w Gdańsku, dziś jest największym europejskim producentem central alarmowych. Polska seria **INTEGRA** stała się de facto standardem w polskich instalacjach SSWiN — zarówno domowych, jak i komercyjnych. Wsparcie po polsku, części dostępne wszędzie, integratorzy w każdym powiecie.

## Modele centrali INTEGRA

| Model | Wejścia wbud. | Max wejść (z ekspanderami) | Wyjścia wbud. | Max wyjść | Partycje | Użytkownicy | Grade |
|---|---|---|---|---|---|---|---|
| **INTEGRA 24** | 8 | 24 | 4 | 20 | 4 | 16 | 2 |
| **INTEGRA 32** | 16 | 32 | 8 | 32 | 16 | 64 | 2 |
| **INTEGRA 64 Plus** | 16 | 64 | 16 | 64 | 32 | 192 | 3 |
| **INTEGRA 128 Plus** | 16 | 128 | 16 | 128 | 32 | 240 | 3 |
| **INTEGRA 256 Plus** | 16 | 256 | 16 | 256 | 32 | 240 | 3 |

**Grade 2** (PN-EN 50131-3) — mieszkania, domy jedno- i dwurodzinne, sklepy. **Grade 3** — banki, jubilerzy, obiekty z większym ryzykiem włamania (ubezpieczyciel wymaga).

## Architektura systemu

```
     [ CENTRALA INTEGRA ]
              ║  4-żyłowa magistrala (BUS) - COM, +12V, CLK, DAT
              ║  max 1200 m, do 64 modułów
     ╔════════╩══════════╦═════════════╦══════════════╗
[ Klawiatura ]  [ Ekspander INT-E ] [ INT-O ]   [ ETHM-1 Plus ]
   INT-KSG       8 wejść NC/NO/EOL  8 wyjść     (TCP/IP, P2P SATEL)
   INT-TSG       (rezystory PAR)    przekaźniki  IP, monitoring, GUARD X
                                                
     [ wejścia / czujki ]      [ wyjścia / odbiorniki ]
     PIR, kontaktron, MW       Syrena, lampa, sterowanie
```

### Magistrala z rezystorami końcowymi (EOL)

Każde wejście (zone) jest podłączone przez parę żył z rezystorem końcowym (zazwyczaj 2,2 kΩ + 1,1 kΩ) — pozwala to centrali rozróżnić 4 stany:

| Stan | Rezystancja | Znaczenie |
|---|---|---|
| **Normalny** | ~2,2 kΩ | czujka spoczywa |
| **Naruszenie** | ~3,3 kΩ (po zwarciu rezystora w PIR) | PIR wykrył ruch |
| **Sabotaż otwarcie** | ∞ (przerwa) | ktoś przeciął kabel |
| **Sabotaż zwarcie** | 0 Ω (zwarcie) | ktoś zwarł kabel by ukryć alarm |

Bez rezystorów EOL (typ wejścia „NC" lub „NO") nie ma wykrycia sabotażu. Dla Grade 2/3 **rezystory są obowiązkowe**.

## Moduły rozszerzeń (ekspandery)

| Model | Funkcja | Wejścia / wyjścia | Cena (2026) |
|---|---|---|---|
| **INT-E** | ekspander wejść (zwykły) | 8 × wejście | ~170 zł |
| **INT-EH-H** | ekspander wejść z hermetyczną puszką IP65 | 8 × wejście | ~280 zł |
| **INT-O** | ekspander wyjść (open-collector) | 8 × wyjście OC, max 100 mA | ~150 zł |
| **INT-OR** | ekspander wyjść przekaźnikowych | 8 × przekaźnik, max 1,5 A | ~280 zł |
| **INT-CR** | czytnik kart Mifare | 1 × czytnik + drzwi | ~290 zł |
| **INT-AV** | moduł audio-verification (mikrofony) | 4 × strefa | ~390 zł |
| **INT-IT** | moduł sterujący temp. (czujnik termistor) | 4 × wejście temp. | ~190 zł |

## Klawiatury

| Model | Wyświetlacz | Funkcje | Cena (2026) |
|---|---|---|---|
| **INT-KLCD-GR** | 2 × 16 znaków LCD | klasyczna, niezawodna | ~290 zł |
| **INT-KSG** | 2,8" graficzny mono | partycje, makra, harmonogram | ~620 zł |
| **INT-TSG** | 4,3" dotykowy kolorowy | graficzny UI, makro-skróty | ~970 zł |
| **INT-TSG2** | 4,3" dotykowy, ulepszony | 2026 nowość, kompatybilny z Vision Plus | ~1100 zł |
| **INT-S** | klucz strefowy | uzbrojenie/rozbrojenie 1 strefy | ~130 zł |
| **INT-SCR** | czytnik zbliżeniowy + dioda | karta zamiast PIN | ~250 zł |

## Komunikatory (monitoring, app, e-mail)

| Model | Łącze | Funkcje |
|---|---|---|
| **ETHM-1 Plus** | Ethernet 100Base-T | monitoring TCP/IP, GUARD X, integracja IP, SATEL P2P |
| **GSM-X** | GSM 4G | SMS, CLIP, monitoring GPRS, backup transmisji |
| **GSM-X-LTE** | LTE Cat M1 | nowsza wersja, niższe zużycie energii |
| **INT-GSM LTE** | Cat M1 + Cat NB2 | monitoring na 2 łączach IoT (do 2026 standard) |
| **STAM-2** | oprogramowanie agencji ochrony | odbiór monitoringu w PCO (Centrum Odbioru) |

## Oprogramowanie

### DLOAD X — programowanie

Aplikacja PC do konfiguracji wszystkich parametrów centrali. Połączenie przez RS-232 (kabel programatorski USB-RS), Ethernet (ETHM-1 Plus) lub przez chmurę SATEL.

- Programowanie wejść (typ, czas reakcji, partycja)
- Programowanie wyjść (funkcja, czas, polaryzacja)
- Konfiguracja użytkowników, uprawnień, harmonogramów
- Definiowanie partycji (np. parter, piętro, garaż)
- Konfiguracja monitoringu (SIA, Contact ID, GPRS)
- Backup całej konfiguracji do pliku

### GUARD X — klient mobilny i desktopowy

Aplikacja mobilna na iOS/Android i desktop. Pozwala użytkownikowi:

- Uzbroić/rozbroić poszczególne partycje
- Podgląd statusu wszystkich wejść (otwarte drzwi/okna)
- Historia zdarzeń
- Sterowanie wyjściami (np. otwarcie bramy garażowej, włączenie świateł)
- Push notifications na alarmy
- Integracja z kamerami (jeśli ETHM-1 Plus + JABLOCAM)

Połączenie GUARD X z centralą idzie przez chmurę **SATEL P2P** — bez konfiguracji portów, bez VPN, z 2FA. Centrala loguje się do chmury, app łączy się do tej samej chmury — relay between.

## Partycje, użytkownicy, harmonogramy

### Partycje (strefy)

Centrala pozwala podzielić obiekt na niezależne strefy ochronne — np. parter osobno od piętra, garaż osobno. Każda partycja ma własny stan uzbrojenia, własną klawiaturę i własnych uprawnionych użytkowników.

```
Typowy układ domu jednorodzinnego:
  Partycja 1 — Parter (PIR salon, kuchnia, hol)
  Partycja 2 — Piętro (PIR korytarz, sypialnie — często stay-mode w nocy)
  Partycja 3 — Garaż (PIR + kontaktron drzwi garażowych)
  Partycja 4 — Posesja (bariery IR, czujki zewnętrzne)
```

### Tryby uzbrojenia

| Tryb | Co aktywne | Kiedy używać |
|---|---|---|
| **Pełne uzbrojenie** | wszystkie czujki, bariery, sabotaż | wyjście z domu |
| **Stay mode (noc)** | obwodowe (kontaktrony, bariery), bez PIR wewnątrz | noc, ktoś śpi w domu |
| **Stay+ (gabinet)** | obwodowe + część PIR | noc + pracujący w gabinecie |
| **Rozbrojony** | tylko sabotaż i 24h zone (panic, pożar, zalanie) | obecność domowników |

### Użytkownicy

Każdy użytkownik ma:

- **Kod PIN** (4–8 cyfr)
- Opcjonalnie **kartę zbliżeniową** Mifare
- Opcjonalnie **klucz pilota APT-100** (433 MHz, 2-kierunkowy)
- Listę partycji do których ma dostęp
- Harmonogram dostępu (np. sprzątaczka tylko wt/czw 9:00–11:00)
- Uprawnienia (uzbroić, rozbroić, programować, wyłączyć alarm, etc.)

## Integracja zewnętrzna

### Home Assistant

Integracja przez HACS — *Satel Integra*. Wymaga ETHM-1 Plus. Tworzy entities:

- `alarm_control_panel.satel_partition_1`
- `binary_sensor.satel_zone_X` — każde wejście
- `switch.satel_output_X` — każde wyjście
- Eventy: `alarm`, `arm`, `disarm`, `fault`, `tamper`

### KNX / Modbus

Przez moduł INT-KNX (wymaga osobnej licencji) Satel można połączyć z magistralą KNX budynku — synchronizacja stanów alarmu z oświetleniem, klimatyzacją.

## Wycena typowego systemu domu 150 m²

| Komponent | Liczba | Cena jedn. | Razem |
|---|---|---|---|
| INTEGRA 32 + obudowa OPU-3 + akumulator 18 Ah + zasilacz | 1 | ~1450 zł | 1450 |
| INT-TSG klawiatura dotykowa | 1 | 970 zł | 970 |
| INT-KLCD klawiatura zapasowa (przy drzwiach garażowych) | 1 | 290 zł | 290 |
| ETHM-1 Plus | 1 | 620 zł | 620 |
| GSM-X-LTE backup | 1 | 780 zł | 780 |
| Czujki PIR Satel Aqua Plus | 6 | 140 zł | 840 |
| Czujki kontaktronowe drzwi/okna | 10 | 30 zł | 300 |
| Sygnalizator zewnętrzny SPL-5010 | 1 | 370 zł | 370 |
| Sygnalizator wewnętrzny SPW-220 | 1 | 150 zł | 150 |
| Okablowanie YTKSY 6×0,5 + YDY 2×0,75 | 200 m | ~3 zł/m | 600 |
| Montaż i programowanie (instalator certyfikowany) | — | — | ~2500 |
| **Razem:** | | | **~8870 zł** |

## Co dalej

➡ [DSC PowerSeries Neo](06-02-dsc-power-neo.md)
