# PoE switche

**Sekcja:** 03 Rejestratory CCTV · **Aktualizacja:** 2026-05

Power over Ethernet w monitoringu IP — standardy 802.3af/at/bt, klasy mocy 0–8, budżet mocy switcha, spadek napięcia na kablu i dobór switcha z zapasem. Jeden kabel = dane + zasilanie kamery.

## Po co PoE w CCTV

**PoE (Power over Ethernet)** dostarcza kamerze IP dane *i* zasilanie jednym kablem skrętki — bez osobnego zasilacza 12 V przy każdej kamerze. To fundament nowoczesnej instalacji IP: jeden RJ45 do kamery, prąd z centralnego switcha lub NVR. Switch (lub NVR z PoE) pełni rolę **PSE** (Power Sourcing Equipment), kamera jest **PD** (Powered Device).

Korzyści: jedno okablowanie, centralne zasilanie podtrzymywane jednym UPS-em (cały system na zasilaniu awaryjnym), łatwy restart kamery zdalnie (PoE off/on), brak gniazdek 230 V przy kamerach na zewnątrz.

## Standardy PoE i klasy mocy

Trzy generacje standardu IEEE, różniące się mocą na porcie. Pamiętaj o rozróżnieniu: moc **PSE** (na porcie switcha) jest wyższa niż moc **PD** (dostępna dla kamery), bo część ginie na kablu.

| Standard | Nazwa | Moc PSE / port | Moc dla PD | Pary | Klasy |
| --- | --- | --- | --- | --- | --- |
| **802.3af** | PoE | 15,4 W | 12,95 W | 2 pary | 0–3 |
| **802.3at** | PoE+ | 30 W | 25,5 W | 2 pary | 4 |
| **802.3bt Type 3** | PoE++ / 4PPoE | 60 W | 51 W | 4 pary | 5–6 |
| **802.3bt Type 4** | PoE++ / 4PPoE | 100 W | 71,3 W | 4 pary | 7–8 |

### Klasy PoE 0–8

| Klasa | Max moc PD | Standard | Typowe urządzenie CCTV |
| --- | --- | --- | --- |
| 0 | 0,44–12,95 W | af | domyślna, kamera bullet/dome bez grzałki |
| 1 | 0,44–3,84 W | af | mała kamera, czujnik |
| 2 | 3,84–6,49 W | af | kamera dome 2–4 MP |
| 3 | 6,49–12,95 W | af | kamera 4–8 MP, IR, grzałka mała |
| 4 | 12,95–25,5 W | at (PoE+) | kamera z grzałką, mały PTZ, IR dużego zasięgu |
| 5 | do 40 W | bt Type 3 | PTZ, kamera z mocnym IR/oświetlaczem |
| 6 | do 51 W | bt Type 3 | PTZ z grzałką i wycieraczką |
| 7 | do 62 W | bt Type 4 | duży PTZ, kamera multisensor |
| 8 | do 71,3 W | bt Type 4 | PTZ premium, oświetlacz dużej mocy |

**Pasywne PoE to NIE standard 802.3.** Tanie „PoE" 24 V/passive (część Ubiquiti, no-name) podaje stałe napięcie bez negocjacji klasy. Podłączenie standardowej kamery 802.3af/at do pasywnego 24 V może ją **uszkodzić**. Zawsze sprawdzaj, czy switch i kamera mówią tym samym językiem (active 802.3af/at/bt vs passive).

## Budżet mocy switcha (power budget)

Najważniejszy parametr switcha PoE. **Power budget** to łączna moc, jaką switch może rozdzielić na wszystkie porty PoE razem — zwykle *mniej* niż liczba portów × maks. moc portu. Przykład: switch 8-portowy PoE+ może mieć budżet 65 W, choć 8 × 30 W = 240 W — czyli nie zasili 8 kamer po 30 W jednocześnie.

### Przykład doboru

```
Instalacja:
  8× kamera dome 4MP   = 8 × 8 W   = 64 W
  1× kamera PTZ z IR   = 1 × 25 W  = 25 W
  ──────────────────────────────────
  Suma poboru kamer              = 89 W

+ zapas 30% (szczyty, grzałki zimą, rozbudowa):
  89 W × 1,30 ≈ 116 W

Dobór switcha:
  → switch z power budget ≥ 120 W
    (np. 8-port PoE+ 802.3at z budżetem 120–150 W + 2 porty uplink)
  → dla portu PTZ konieczne PoE+ (30 W), reszta af (15,4 W) wystarczy
```

**Zasada 30% zapasu.** Nigdy nie planuj na 100% budżetu mocy. Zimą grzałki kamer dobierają moc, kamery z IR pobierają więcej nocą, a system zwykle się rozbudowuje. Switch pracujący „na styk" przy zimnym starcie (wszystkie kamery + grzałki naraz) potrafi odciąć porty z najniższym priorytetem.

## Spadek mocy na kablu

Skrętka miedziana ma rezystancję — część mocy zamienia się w ciepło po drodze. Dlatego moc **dostarczona do kamery (PD) jest mniejsza niż moc wysłana przez switch (PSE)**. Im dłuższy kabel i cieńsza żyła, tym większa strata.

| Parametr | Wartość | Uwagi |
| --- | --- | --- |
| Maks. długość UTP | **100 m** | limit Ethernet + PoE (cat5e/cat6); dane i moc |
| Strata 802.3af na 100 m | ~2,45 W | 15,4 W PSE → 12,95 W PD |
| Strata 802.3at na 100 m | ~4,5 W | 30 W PSE → 25,5 W PD |
| Przekrój żyły | AWG 24 (lepiej AWG 23) | cieńsza CCA (aluminium miedziowane) = większe straty, unikać |

**Unikaj kabli CCA** (Copper Clad Aluminum — aluminium pokryte miedzią). Mają znacznie wyższą rezystancję niż pełna miedź (Cu), co przy PoE oznacza duże straty mocy i nagrzewanie — kamera na końcu długiego kabla CCA może się nie uruchomić lub resetować. Do PoE używaj **kabla pełnomiedzianego (100% Cu), min. cat5e, najlepiej cat6 AWG 23**.

## Switche zarządzalne vs niezarządzalne

| Cecha | Niezarządzalny (unmanaged) | Zarządzalny (managed / smart) |
| --- | --- | --- |
| Konfiguracja | plug-and-play, brak ustawień | WWW/CLI, VLAN, QoS, monitoring |
| VLAN | nie | tak — izolacja kamer od LAN |
| PoE watchdog | zwykle brak | tak — auto-restart zawieszonej kamery |
| Monitoring poboru | nie | tak — moc per port, diagnostyka |
| Cena | niska | wyższa |
| Zastosowanie | dom, mała instalacja | firmy, izolacja sieci, większe systemy |

### VLAN dla CCTV

Switch zarządzalny pozwala wydzielić **osobny VLAN dla kamer** — odseparowany od sieci biurowej/domowej. Korzyści: kamery nie widzą komputerów (i odwrotnie), ograniczenie domeny rozgłoszeniowej (broadcast), kontrola dostępu do internetu (kamery często nie powinny mieć dostępu do sieci zewnętrznej — ryzyko botnetów, wycieku strumieni).

### PoE watchdog

Funkcja switchy zarządzalnych: switch **pinguje kamerę**, a gdy ta przestaje odpowiadać (zawieszenie firmware), automatycznie **wyłącza i włącza zasilanie portu PoE** — wymusza restart kamery bez wizyty technika. Bezcenne przy kamerach na masztach i wysokich elewacjach.

PoE watchdog rozwiązuje 90% „zawieszonych" kamer zdalnie. Zamiast podjazdu drabiną, switch sam zrestartuje punkt, gdy ten przestanie odpowiadać. Włącz go na wszystkich portach kamerowych w switchu zarządzalnym.

## Marki i przykładowe modele (ceny 2026)

| Model | Porty PoE | Budżet / standard | Typ | Cena (2026) |
| --- | --- | --- | --- | --- |
| **TP-Link TL-SG1008P** | 4× PoE+ (z 8) | 64 W / af-at | niezarządzalny | ~250 zł |
| **TP-Link TL-SG1016PE** | 16× PoE+ | 110 W / at, smart | easy-smart | ~720 zł |
| **TP-Link TL-SG3210XHP-M2** | 8× PoE+ | 240 W / at, L2+ | zarządzalny + SFP+ | ~1850 zł |
| **Ubiquiti USW-Lite-16-PoE** | 8× PoE+ (z 16) | 45 W / af-at | zarządzalny (UniFi) | ~1100 zł |
| **Ubiquiti USW-Pro-Max-24-PoE** | 24× PoE++ | 400 W / af-at-bt | zarządzalny (UniFi) | ~3200 zł |
| **Hikvision DS-3E1318P-EI** | 16× PoE | 225 W / af-at | smart managed | ~980 zł |
| **Dahua PFS3010-8ET-96** | 8× PoE | 96 W / af-at | niezarządzalny | ~520 zł |
| **Cisco CBS350-8P-2G** | 8× PoE+ | 67 W / at, L3 | zarządzalny + 2× SFP | ~1750 zł |

Marki kamer (Hikvision, Dahua) oferują własne switche „dopasowane" do kamer — zwykle z trybem *extend* (transmisja do 250 m kosztem prędkości 10 Mbps) i jednoprzyciskową konfiguracją VLAN dla CCTV. Wygodne, gdy cały system jest jednego producenta.

## PoE injector, extender i uplink

### PoE injector (zasilacz dośrodkowy)

Gdy switch *nie* ma PoE, a kamera go wymaga — **injector** „dostrzykuje" zasilanie do linii Ethernet między switchem a kamerą. Pojedynczy port, jedna kamera. Tani sposób, by zasilić jedną-dwie kamery IP bez wymiany całego switcha na PoE.

### PoE extender (powyżej 100 m)

Limit 100 m UTP to twarda granica Ethernetu. **Extender PoE** wpina się w połowie trasy — regeneruje sygnał i przekazuje zasilanie dalej, pozwalając wydłużyć linię o kolejne ~100 m na każdy extender (sam jest zasilany z PoE wejściowego).

| Rozwiązanie | Maks. dystans | Kiedy stosować |
| --- | --- | --- |
| Zwykły UTP cat6 + PoE | 100 m | standardowa instalacja |
| Tryb extend switcha (Hik/Dahua) | ~250 m | 1 kamera daleko, akceptujesz 10 Mbps |
| PoE extender (kaskada) | +100 m / sztukę | kilka kamer w ciągu, długi korytarz |
| Konwerter światłowodowy + media converter PoE | kilometry | budynki rozproszone, maszt, kampus |

### Uplink SFP / światłowód

Porty **SFP / SFP+** (1/10 Gbps) służą do łączenia switchy między sobą (kaskada, gwiazda) oraz do **światłowodu** na duże odległości. Gdy switch dostępowy zbiera 16–24 kamery, jego ruch do NVR-a powinien iść uplinkiem ≥ 1 Gbps (a najlepiej SFP+ 10 Gbps przy dużym bitrate), żeby nie tworzyć wąskiego gardła. Światłowód po SFP łączy budynki bez ograniczenia 100 m i z izolacją galwaniczną (brak problemów z różnicą potencjałów / piorunami).

**Wąskie gardło uplinku:** 24 kamery 8MP @ 10 Mbps = 240 Mbps ruchu do NVR. Uplink 1 Gbps to obsłuży, ale przy większej liczbie switchy zbieranych w jeden punkt łatwo przekroczyć gigabit — wtedy konieczny **uplink SFP+ 10 Gbps**. Policz sumaryczny bitrate wszystkich kamer za switchem i porównaj z przepustowością uplinku.
