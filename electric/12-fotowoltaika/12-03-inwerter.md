# Inwerter (falownik) PV

## Rola inwertera

Panele PV produkują **prąd stały (DC)** o napięciu 200-600 V. Inwerter (*falownik*, ang. *inverter*) zamienia go na **prąd przemienny (AC) 230/400 V 50 Hz** kompatybilny z siecią domową i energetyczną.

Drugie zadanie inwertera — śledzenie punktu maksymalnej mocy paneli (**MPPT**).

## Rodzaje inwerterów

### Inwerter stringowy

Jeden inwerter obsługuje cały string (8-20 paneli połączonych szeregowo). Najpopularniejszy typ w domach jednorodzinnych.

- **Plusy:** najtańsze, prosty montaż, wysoka sprawność (97-98 %), łatwa diagnostyka
- **Minusy:** jedno zacienienie ogranicza cały string

### Mikroinwerter

Małe inwertery (200-400 W) montowane bezpośrednio pod każdym panelem. Każdy panel pracuje niezależnie.

- **Plusy:** maksymalna produkcja w warunkach częściowego zacienienia, modułowa rozbudowa, bezpieczeństwo (brak DC w domu)
- **Minusy:** drogie (2-3 × cena stringowego), montaż na dachu = serwis trudniejszy, więcej punktów awarii

### Inwerter hybrydowy

Łączy funkcje inwertera PV, ładowarki magazynu i interfejsu z siecią. Pozwala podłączyć akumulator DC.

- **Plusy:** integracja PV + magazyn, lepsza sprawność (~94-96 % round-trip), gotowość do trybu *backup* (zasilanie awaryjne)
- **Minusy:** droższy o 30-50 % vs zwykły stringowy

## MPPT — śledzenie punktu mocy

**MPPT** (*Maximum Power Point Tracking*) — algorytm szukający optymalnego napięcia pracy panela, w którym P = U·I jest największe.

Typowy domowy inwerter ma **2 MPPT** = 2 niezależne wejścia stringowe. Pozwala podłączyć dwa stringi o różnej orientacji (np. dach E + dach W) z osobnym śledzeniem.

Większe inwertery (8-15 kW) mają 3-4 MPPT.

## Sprawność

- **Sprawność szczytowa** — 97-99 % w idealnym punkcie pracy
- **Sprawność euro / CEC** — ważona różnymi obciążeniami (5/10/20/30/50/100 %) — **96-98 %** dla dobrych modeli

Sprawność spada przy bardzo niskim obciążeniu (<5 % mocy znamionowej) — dlatego nie przewymiarowuje się inwertera.

## Dobór mocy

Reguła: **moc inwertera = 80-110 % mocy paneli**.

- **80-90 %** — *overoozing* — panele produkują nominalnie więcej niż inwerter (np. 6 kWp paneli + 5 kW inwertera). Strata szczytowa w południe w VI 1-3 % rocznie, ale w PL panele rzadko osiągają STC → najczęściej brak straty
- **100 %** — klasyczny dobór 1:1
- **110 %** — inwerter z zapasem (rezerwa pod rozbudowę)

| Moc paneli | Moc inwertera |
|---|---|
| 3 kWp | 2,5-3 kW |
| 5 kWp | 4-5 kW |
| 7 kWp | 6-7 kW |
| 10 kWp | 8-10 kW |

## Marki

Najczęściej spotykane na polskim rynku:

| Marka | Pochodzenie | Pozycjonowanie |
|---|---|---|
| **Sungrow** | Chiny | dobra jakość, popularny, hybrydy SH |
| **Huawei** | Chiny | premium, AI, integracja z magazynem LUNA |
| **Solis (Ginlong)** | Chiny | budżet-premium, dobry stosunek ceny |
| **Fronius** | Austria | premium, niezawodne, drogie |
| **Solaredge** | Izrael | optymalizatory mocy, premium |
| **Growatt** | Chiny | budżet, popularne |
| **GoodWe** | Chiny | dobra hybrydyzacja, popularny |
| **SMA** | Niemcy | premium, klasyk rynku |

## Funkcje ochronne

Wymagane / typowe:

- **Klasa II ochrony** (podwójna izolacja, bez PE wymaganego)
- **AFCI** (*Arc Fault Circuit Interrupter*) — wykrywa łuk DC w panelu lub okablowaniu — wymagane w nowych instalacjach
- **RCD wbudowany** (*RCD-DD* — typ B równoważny) — wykrywa prąd różnicowy DC + AC
- **Anti-islanding** — odłącza inwerter od sieci przy zaniku napięcia (bezpieczeństwo energetyków)
- **SPD typ 2** często wbudowany na wejściu DC i AC

## Monitoring

Wszystkie współczesne inwertery mają **Wi-Fi / Ethernet** + chmurę producenta:

- bieżąca moc
- produkcja dzienna/miesięczna/roczna
- alerty awarii
- API do Home Assistant (Modbus TCP, MQTT, integracje)

## Lokalizacja montażu

- **Suche pomieszczenie** (garaż, kotłownia, poddasze użytkowe), IP minimum 65 dla zewnątrz
- Z dala od bezpośredniego nasłonecznienia (ciepło skraca żywotność elektroniki)
- Dobre chłodzenie — odstęp 30 cm od ścian, sufit, podłogi
- Krótka droga DC z dachu (< 30 m) — przekrój 4-6 mm²
- Bliska AC do rozdzielnicy głównej

## Co dalej

➡ [Net-billing](12-04-net-billing.md)
