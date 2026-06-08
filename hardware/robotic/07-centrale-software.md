# Centrale i oprogramowanie

Pojedyncze urządzenia są przydatne, ale prawdziwa „inteligencja" rodzi się, gdy spina je **centralka** (hub): jedno miejsce, w którym widzisz wszystkie czujniki, sterujesz wszystkim i piszesz automatyzacje łączące światło, wodę, ogrzewanie i bezpieczeństwo. To „mózg domu" z rozdziału 1.

## Po co centralka

- **Jeden pulpit i jedna aplikacja** zamiast pięciu od różnych producentów.
- **Automatyzacje między ekosystemami** — czujnik Zigbee zapala żarówkę WiFi i wstrzymuje nawadnianie ESP32. Bez centralki te światy się nie znają.
- **Działanie lokalne** — reguły wykonują się w domu, natychmiast, nawet bez internetu.
- **Historia i wykresy** — temperatura, wilgotność gleby, zużycie energii w czasie.

## Lokalnie kontra w chmurze — kluczowa decyzja

| | Lokalnie (np. Home Assistant) | Chmura (np. Tuya, większość „smart") |
|---|---|---|
| **Prywatność** | Dane zostają w domu | Dane na serwerach producenta |
| **Niezawodność** | Działa bez internetu | Pada, gdy padnie serwer/łącze |
| **Szybkość reakcji** | Natychmiast | Zależna od łącza i serwera |
| **Trwałość** | Działa latami | Bywa wygaszane („koniec wsparcia") |
| **Próg wejścia** | Wyższy (konfiguracja) | Niższy (aplikacja producenta) |

> Dla automatyki, która ma być *Twoja* i działać niezawodnie przez lata, **lokalna centralka** jest wyraźnie lepsza. Chmurowe gadżety dobre są na start, ale staraj się wybierać urządzenia, które da się zintegrować lokalnie.

## Home Assistant — domyślny wybór

**Home Assistant (HA)** to najpopularniejsza, otwarta i darmowa centralka smart home. Integruje **tysiące** urządzeń i usług (Shelly, Zigbee, Tuya, Hue, ESPHome, kamery, falowniki PV…), działa **lokalnie**, ma rozbudowane automatyzacje i ładne pulpity.

- **Działa z całą resztą tej dokumentacji:** ESP32 (przez ESPHome) wpina się „samo", Shelly i Sonoff przez integracje/MQTT, czujniki Zigbee przez koordynator.
- **Add-ony** (dodatki) jednym kliknięciem: broker **Mosquitto (MQTT)**, **Zigbee2MQTT**, **Node-RED**, kopie zapasowe, **ESPHome**.
- **Automatyzacje** klikane w kreatorze lub w YAML; sceny, harmonogramy, warunki słońca, powiadomienia na telefon.

### Na czym uruchomić Home Assistant

| Wariant | Opis | Cena |
|---------|------|------|
| **Raspberry Pi 4/5 + karta/SSD** | Klasyka, własny montaż; SSD zamiast karty SD dla niezawodności | 300–650 zł |
| **Home Assistant Green** | Gotowe pudełko „włącz i działa", oficjalne | ~450–600 zł |
| **Home Assistant Yellow** | Z wbudowanym Zigbee, miejsce na dysk, PoE | ~600–900 zł |
| **Mini-PC (Intel N100) / stary laptop** | Najwydajniej i stabilnie, Docker/Proxmox, dużo integracji i kamer | 0–800 zł |
| **Maszyna wirtualna / NAS** | Jeśli masz już serwer domowy | w ramach posiadanego sprzętu |

Do tego zwykle **koordynator Zigbee** (klucz USB, np. Sonoff/ConBee, 60–200 zł), jeśli korzystasz z czujników Zigbee.

## Alternatywy dla Home Assistant

- **openHAB** — dojrzała, otwarta centralka (Java), bardzo elastyczna; nieco bardziej „techniczna" konfiguracja. Dobra dla lubiących precyzyjne reguły.
- **Domoticz** — lekka i prosta, świetna na słaby sprzęt (Pi Zero); mniej „ładna", ale stabilna i oszczędna.
- **ioBroker** — popularny zwłaszcza w DACH/Europie, mocny w integracjach i wizualizacji, oparty na Node.js.
- **Node-RED** — nie tyle centralka, co **wizualny edytor przepływów**: logikę układasz z „klocków" połączonych liniami. Często działa *obok* Home Assistant do bardziej rozbudowanych scenariuszy.

## Ekosystemy producenckie (chmurowe)

Jeśli nie chcesz utrzymywać własnej centralki, są wygodne, ale chmurowe ekosystemy. Warto je też znać, bo HA potrafi się z nimi „dogadać":

- **Apple HomeKit** — duży nacisk na prywatność (część lokalnie), świetny dla użytkowników iPhone; mniejszy wybór urządzeń.
- **Google Home** — wygodne sterowanie głosem (Google Assistant), szeroka zgodność.
- **Amazon Alexa** — największy wybór i „skille", mocne sterowanie głosem.
- **Samsung SmartThings** — własny hub i szeroka zgodność (Zigbee/Z-Wave/Matter).
- **Tuya / Smart Life** — „parasol" nad tysiącami tanich urządzeń; wygodny start, ale zależny od chmury.

**Matter** (rozdział 3) ma stopniowo łączyć te światy — urządzenie z logo Matter powinno działać w każdym z nich, co ułatwia mieszanie marek.

## Automatyzacje, pulpity, głos

- **Automatyzacje** — „wyzwalacz → warunek → akcja": *gdy* czujnik ruchu i po zmierzchu *to* zapal światło na 20% na 2 minuty. To tu spinasz rozdziały 05 i 06 w jeden organizm.
- **Pulpity (dashboardy)** — własne ekrany na telefon/tablet na ścianie: kafelki świateł, wykres wilgotności gleby, kamery, przyciski scen.
- **Powiadomienia** — „zbiornik deszczówki pusty", „wykryto zalanie", „okno otwarte, a spada temperatura".
- **Głos** — przez Google/Alexa/Siri albo **lokalnie** (HA rozwija własną asystentkę głosową działającą bez chmury).
- **Kopie zapasowe** — rób regularne backupy konfiguracji; to oszczędza godziny pracy po awarii karty/dysku.

## Ile to kosztuje (PLN, 2026)

- **Oprogramowanie** (Home Assistant, openHAB, Domoticz, Node-RED) — **darmowe**.
- **Sprzęt centralki** — od ~0 zł (stary laptop/mini-PC, który masz) przez Raspberry Pi (300–650 zł) po HA Yellow (~600–900 zł).
- **Koordynator Zigbee** (opcjonalnie) — 60–200 zł.
- **Opcjonalne wsparcie** (Home Assistant Cloud / Nabu Casa — łatwy zdalny dostęp i głos) — abonament, ale **niewymagany**: zdalny dostęp zrobisz też samodzielnie (VPN).

## Rekomendacja

Dla większości osób budujących dom i ogród „po swojemu":

1. **Centralka:** Home Assistant na **mini-PC (Intel N100)** lub **Raspberry Pi 4/5 z SSD**.
2. **Spoiwo:** dodatek **MQTT (Mosquitto)** + **ESPHome** + (jeśli Zigbee) **Zigbee2MQTT** z koordynatorem USB.
3. **Urządzenia:** Shelly (światło/230 V), ESP32 (ogród, czujniki), czujniki Zigbee (taniej, bateryjnie).
4. **Zasada:** wybieraj urządzenia działające **lokalnie** — unikniesz uzależnienia od cudzej chmury.

---

➡️ Dalej: **[08 — Projekty krok po kroku i koszty](08-projekty-koszty.html)** — składamy wszystko w gotowe mini-projekty z listą zakupów.
