# Zigbee, Z-Wave, Matter — standardy bezprzewodowe

## Krajobraz standardów

Świat bezprzewodowego smart home jest podzielony na konkurencyjne standardy. W praktyce w domu spotykasz 2-3 jednocześnie.

| Standard | Częstotliwość | Topologia | Konsorcjum |
|---|---|---|---|
| **Zigbee** | 2,4 GHz | mesh | Connectivity Standards Alliance (CSA, dawniej Zigbee Alliance) |
| **Z-Wave** | 868 MHz (EU) | mesh | Z-Wave Alliance / Silicon Labs |
| **Matter** | IP / Thread / WiFi | mesh + IP | CSA (Apple/Google/Amazon/Samsung) |
| **Thread** | 2,4 GHz IPv6 | mesh | Thread Group |
| **Wi-Fi** | 2,4 / 5 GHz | gwiazda do AP | Wi-Fi Alliance |
| **Bluetooth Mesh** | 2,4 GHz | mesh | Bluetooth SIG |

## Zigbee

Bardzo popularny, najwięcej urządzeń na rynku.

- **2,4 GHz** — ten sam zakres co WiFi i Bluetooth (interferencje możliwe — kanały Zigbee 11-26)
- **Mesh** — urządzenia zasilane sieciowo (np. żarówki, gniazda) działają jako routery i przekazują pakiety. Bateryjne (czujniki) są tylko końcówkami.
- **Niewielkie zużycie energii** — czujniki bateryjne 2-3 lata
- **Zakres** ~10-30 m między urządzeniami, mesh wydłuża

### Marki Zigbee

- **Philips Hue** — premium, własny bridge, ekosystem oświetlenia
- **IKEA Tradfri** — budżet, bridge Dirigera, dobra jakość
- **Aqara** (Xiaomi) — czujniki, przyciski, najszerszy katalog akcesoriów, gateway M2/M3
- **Sonoff Zigbee** (ITEAD) — budżet, dobre na DIY
- **Innr, Müller Licht, Osram** — oświetlenie kompatybilne z Hue Bridge
- **Tuya Zigbee** — ekosystem białej etykiety (uważać na lokalność)

## Z-Wave

Mniej urządzeń, ale dłuższy zasięg i lepsza separacja od WiFi.

- **868 MHz w EU** (908 MHz US) — nie koliduje z WiFi, dłuższe fale lepiej przenikają ściany
- **Mesh** — podobnie jak Zigbee, do 4 hopów
- **Limit ~232 urządzenia** na sieć
- **Certyfikacja Z-Wave Alliance** — gwarancja kompatybilności (lepsza niż w Zigbee)
- **Z-Wave Plus / 700/800** — kolejne generacje, lepsza wydajność i bateria

### Marki Z-Wave

- **Fibaro** (Polska) — premium, najszerszy katalog (czujniki ruchu, gniazda, dymu, zalania)
- **Aeotec** — dobre czujniki i moduły, sticki USB
- **Heatit, Qubino, Shelly Wave** — moduły ścienne

## Matter

Nowy standard od 2022 — odpowiedź branży na fragmentację.

- **Wspólny standard** Apple Home, Google Home, Amazon Alexa, Samsung SmartThings
- **Warstwa aplikacyjna** — działa nad Thread, Wi-Fi, Ethernet
- **Lokalne API** — bez chmury producenta
- **Wymaga Border Routera** (np. Apple TV 4K, HomePod, Google Nest Hub, Amazon Echo, SkyConnect z Home Assistant)
- W 2025 r. wsparcie jeszcze niepełne — głównie żarówki, gniazda, czujniki

## Thread

- **Warstwa fizyczna / sieciowa** IPv6 — nie aplikacja
- **Mesh, niskie zużycie energii**, 2,4 GHz
- **Border Router** łączy Thread z WiFi/Ethernet (jak gateway Zigbee, tylko że bezpośrednio IP)
- Wykorzystywany przez Matter, ale możliwy też samodzielnie (Nanoleaf, Eve)

## WiFi (Tuya, Shelly, Sonoff)

Proste, ale problematyczne na większą skalę.

- **Plusy:** bez gateway'a, sterowanie ze smartfona out-of-box, niska cena
- **Minusy:** każde urządzenie zajmuje slot w routerze, większe zużycie energii (brak baterii), zależność od chmury (Tuya), brak mesh

**Shelly** wyróżnia się — lokalne API HTTP, MQTT, integracja z Home Assistant bez chmury, montaż w puszce ściennej za istniejącym wyłącznikiem.

**Sonoff** — budżetowe moduły, większość WiFi (zwykle Tuya/eWeLink), część Zigbee.

## Gateway / hub

Bezprzewodowe smart home wymaga **hub'a** — bramki łączącej radio (Zigbee/Z-Wave/Thread) z IP.

| Hub | Standardy | Lokalność | Cena |
|---|---|---|---|
| **ConBee II / III** (Phoscon) | Zigbee | tak | 200-300 zł |
| **Sonoff ZBDongle-E** | Zigbee | tak | 100-150 zł |
| **Aeotec Z-Stick 7** | Z-Wave | tak | 350-450 zł |
| **SkyConnect / HA Yellow Multiprotocol** | Zigbee + Thread | tak | 200-1500 zł |
| **Philips Hue Bridge** | Zigbee (tylko Hue/kompatybilne) | częściowo (chmura dla zdalnego) | 200 zł |
| **Aqara M2/M3** | Zigbee | częściowo (chmura) | 250-400 zł |
| **SmartThings Hub** | Z-Wave + Zigbee + Matter | chmura | 500-700 zł |

W połączeniu z **Home Assistant** + sticki USB uzyskujemy w pełni lokalny system.

## Porównanie do KNX

| Cecha | KNX | Zigbee/Z-Wave |
|---|---|---|
| Cena za punkt | 200-500 zł | 30-150 zł |
| Niezawodność | bardzo wysoka | średnia (kolizje, baterie) |
| Modernizacja | wymaga kabli | łatwa, bez kucia |
| Czas instalacji | tygodnie | godziny |
| Żywotność systemu | 30+ lat | 5-10 lat (technologie się zmieniają) |

## Co dalej

➡ [Home Assistant — centrum sterowania](13-03-home-assistant.md)
