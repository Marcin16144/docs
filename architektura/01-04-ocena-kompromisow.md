# 01-04: Ocena kompromisów w decyzjach architektonicznych

## Architektura to sztuka kompromisów

Każda decyzja architektoniczna to kompromis. Nie istnieje rozwiązanie idealne — każdy wybór coś zyskuje i coś traci. Rolą architekta jest świadome podejmowanie tych kompromisów, a nie udawanie, że ich nie ma.

```
"There are no solutions. There are only trade-offs."
— Thomas Sowell
```

## Metoda ATAM (Architecture Tradeoff Analysis Method)

ATAM to formalna metoda oceny architektury opracowana przez Software Engineering Institute (SEI).

### Fazy ATAM

```
Faza 0: Przygotowanie
  → Zidentyfikuj interesariuszy
  → Przygotuj opis architektury
  → Ustal cele biznesowe

Faza 1: Ewaluacja (1 dzień)
  1. Prezentacja ATAM
  2. Prezentacja celów biznesowych
  3. Prezentacja architektury
  4. Identyfikacja podejść architektonicznych
  5. Generowanie drzewa użytkowego (Utility Tree)
  6. Analiza podejść architektonicznych

Faza 2: Ewaluacja z interesariuszami (2 dni)
  7. Burza mózgów — scenariusze
  8. Analiza podejść architektonicznych (cd.)
  9. Prezentacja wyników

Faza 3: Follow-up
  → Raport końcowy
  → Plan działania
```

### Utility Tree — drzewo użytkowe

Narzędzie do priorytetyzacji scenariuszy jakościowych:

```
System e-commerce
├── Wydajność
│   ├── (H,H) Strona produktu ładuje się < 1s przy 10k users
│   ├── (H,M) Wyszukiwanie zwraca wyniki < 500ms
│   └── (M,L) Raport generuje się < 30s
├── Dostępność
│   ├── (H,H) System działa 99.95% czasu
│   └── (H,M) Failover < 30s przy awarii regionu
├── Bezpieczeństwo
│   ├── (H,H) Dane płatnicze zaszyfrowane at-rest i in-transit
│   └── (M,M) Audit log dla wszystkich zmian danych
└── Modyfikowalność
    ├── (M,H) Dodanie nowej metody płatności < 2 tygodnie
    └── (L,M) Zmiana silnika rekomendacji < 1 sprint

Legenda: (Ważność biznesowa, Ryzyko techniczne)
  H = High, M = Medium, L = Low
```

## Matryca kompromisów (Trade-off Matrix)

### Jak budować matrycę

Matryca kompromisów pozwala wizualnie porównać opcje architektoniczne:

```
Opcja architektoniczna:
  A) Monolit modularny
  B) Mikroserwisy
  C) Serverless

              Wydajność  Skalowal.  Prostota  Koszt  Niezawod.  Bezpiecz.
Opcja A:        +++        +          +++      +++      ++         ++
Opcja B:         ++       +++          -        -       +++        ++
Opcja C:          +       +++         ++        ++       +         ++

+++ = doskonałe, ++ = dobre, + = ok, - = słabe, -- = bardzo słabe
```

### Przykład szczegółowej matrycy

Decyzja: Wybór bazy danych dla systemu IoT

| Kryterium | Waga | PostgreSQL | TimescaleDB | InfluxDB | Cassandra |
|-----------|------|------------|-------------|----------|-----------|
| Write throughput | 25% | 2 | 4 | 5 | 5 |
| Query flexibility | 20% | 5 | 4 | 2 | 2 |
| Time-series support | 20% | 1 | 5 | 5 | 3 |
| Operational cost | 15% | 4 | 3 | 3 | 2 |
| Team expertise | 10% | 5 | 4 | 1 | 1 |
| Community/support | 10% | 5 | 4 | 3 | 4 |
| **Wynik ważony** | | **3.2** | **4.05** | **3.45** | **3.05** |

Skala: 1 (najgorzej) — 5 (najlepiej)

## Weighted Scoring Model

### Metodologia

```
1. Zdefiniuj kryteria oceny
2. Przypisz wagi (suma = 100%)
3. Oceń każdą opcję w skali 1-5
4. Oblicz: Wynik = Σ (waga × ocena)
5. Porównaj wyniki i zweryfikuj z intuicją
```

### Przykład: Wybór strategii cache

```
Kryteria i wagi:
  Wydajność (hit ratio):     30%
  Spójność danych:           25%
  Złożoność implementacji:   20%
  Koszt operacyjny:          15%
  Skalowalność:              10%

                    Wydaj.  Spójność  Złożon.  Koszt  Skalown.  WYNIK
Write-through:        3       5        4        3       3       3.65
Write-behind:         5       2        2        3       4       3.30
Cache-aside:          4       3        5        4       3       3.80
Read-through:         4       4        3        3       3       3.60

Zwycięzca: Cache-aside (3.80)

Ale uwaga: jeśli spójność jest absolutnie krytyczna,
write-through (3.65) może być lepszym wyborem mimo niższego wyniku.
```

## Analiza ryzyka decyzji

### Risk-Benefit Analysis

```
Decyzja: Migracja z monolitu na mikroserwisy

KORZYŚCI:
  + Niezależne deployowanie zespołów         wartość: $$$
  + Lepsza skalowalność krytycznych serwisów wartość: $$
  + Izolacja awarii                          wartość: $$
  + Swoboda wyboru technologii per serwis    wartość: $

RYZYKA:
  - Złożoność operacyjna (monitoring, debug)  P: wysoki,  I: wysoki
  - Distributed transactions                  P: średni,  I: wysoki
  - Koszt infrastruktury (K8s, mesh)          P: wysoki,  I: średni
  - Krzywa uczenia zespołu                    P: wysoki,  I: średni

P = Prawdopodobieństwo, I = Wpływ
```

### Cost-Benefit Analysis

```
Scenariusz: Wdrożenie CDN dla platformy e-commerce

KOSZTY (roczne):
  Licencja CDN:                $12,000
  Konfiguracja i integracja:   $8,000 (jednorazowo)
  Utrzymanie:                  $3,000
  Szkolenie zespołu:           $2,000 (jednorazowo)
  RAZEM rok 1:                 $25,000
  RAZEM kolejne lata:          $15,000

KORZYŚCI (roczne):
  Redukcja kosztów serwera:    $18,000
  Wzrost konwersji (+0.5%):    $45,000
  Mniejsze obciążenie origin:  $6,000
  Lepsza pozycja SEO:          $10,000 (szacunek)
  RAZEM:                       $79,000

ROI rok 1: ($79,000 - $25,000) / $25,000 = 216%
Breakeven: ~4 miesiące
```

## Proof of Concept i Spike Solutions

### Kiedy potrzebny jest PoC?

```
Wykonaj PoC gdy:
  ✓ Technologia jest nowa dla zespołu
  ✓ Wymagania wydajnościowe są ekstremalnie wysokie
  ✓ Integracja z zewnętrznym systemem jest krytyczna
  ✓ Koszt błędnej decyzji jest bardzo wysoki
  ✓ Interesariusze potrzebują dowodu, nie obietnic

Pomiń PoC gdy:
  ✗ Zespół ma doświadczenie z technologią
  ✗ Istnieją wiarygodne benchmarki
  ✗ Decyzja jest łatwo odwracalna
  ✗ Koszt PoC > koszt potencjalnego błędu
```

### Struktura Spike Solution

```
Spike: Weryfikacja wydajności GraphQL vs REST

Cel:
  Zmierzyć latencję i throughput obu podejść
  dla typowych zapytań naszego systemu

Zakres:
  - 3 typowe endpointy (lista produktów, koszyk, checkout)
  - Testy obciążeniowe: 100, 500, 1000, 5000 req/s
  - Pomiar: p50, p95, p99, throughput, CPU, RAM

Timebox: 3 dni (nie więcej!)

Kryteria sukcesu:
  - GraphQL p95 < 150ms przy 1000 req/s
  - Overhead sieciowy mniejszy o min. 30%

Deliverable:
  - Raport z wynikami benchmarków
  - Rekomendacja z uzasadnieniem
  - Kod PoC (do wyrzucenia, nie do produkcji!)
```

## Analiza odwracalności decyzji

### Klasyfikacja decyzji (Jeff Bezos)

```
Type 1 — Drzwi jednokierunkowe (nieodwracalne):
  - Wybór głównej bazy danych
  - Wybór cloud providera
  - Architektura mono vs mikroserwisy
  - Język programowania głównego systemu
  → Wymagają dogłębnej analizy

Type 2 — Drzwi dwukierunkowe (odwracalne):
  - Wybór biblioteki HTTP
  - Format serializacji wewnętrznej
  - Strategia cache'owania
  - Narzędzie do CI/CD
  → Podejmuj szybko, koryguj w locie
```

### Matryca odwracalności

| Decyzja | Koszt odwrócenia | Czas odwrócenia | Typ |
|---------|------------------|-----------------|-----|
| Zmiana bazy danych | $$$$ | 6-12 mies. | Type 1 |
| Zmiana cloud provider | $$$$ | 12-18 mies. | Type 1 |
| Zmiana frameworka | $$$ | 3-6 mies. | Type 1 |
| Zmiana ORM | $$ | 2-4 tyg. | Type 2 |
| Zmiana biblioteki logowania | $ | 1-2 dni | Type 2 |
| Zmiana strategii cache | $ | 1-3 dni | Type 2 |

## Konkretne przykłady kompromisów

### 1. Spójność vs Dostępność (CAP Theorem)

```
Scenariusz: System bankowy vs Social media

System bankowy (CP — Consistency + Partition tolerance):
  "Wolę, żeby użytkownik zobaczył błąd,
   niż żeby zobaczył nieprawidłowe saldo."
  → PostgreSQL z synchroniczną replikacją
  → Silna spójność, akceptujemy chwilową niedostępność

Social media (AP — Availability + Partition tolerance):
  "Wolę, żeby użytkownik zobaczył lekko nieaktualny feed,
   niż żeby zobaczył błąd."
  → Cassandra z eventual consistency
  → Wysoka dostępność, akceptujemy opóźnioną spójność
```

### 2. Wydajność vs Bezpieczeństwo

```
Scenariusz: API z danymi wrażliwymi

Maksymalna wydajność (niski poziom bezpieczeństwa):
  - Brak szyfrowania payloadu
  - Cache'owanie agresywne
  - Brak rate limiting
  → Latencja: 5ms

Maksymalne bezpieczeństwo (niższa wydajność):
  - Szyfrowanie end-to-end + field-level encryption
  - Brak cache'owania wrażliwych danych
  - Rate limiting + WAF + OWASP checks
  - Audit logging każdego requestu
  → Latencja: 45ms

Kompromis w praktyce:
  - TLS dla transportu (standard, minimalny narzut)
  - Field-level encryption tylko dla PII
  - Cache'owanie danych nieosobowych
  - Rate limiting per endpoint (nie globalny)
  → Latencja: 15ms — akceptowalna dla obu stron
```

### 3. DX (Developer Experience) vs Wydajność produkcyjna

```
Scenariusz: Wybór języka dla nowego serwisu

Python:
  + Szybki development (2x szybciej niż Go)
  + Bogaty ekosystem ML/Data
  - Wolniejszy runtime (10-100x vs Go)
  - GIL ogranicza wielowątkowość

Go:
  + Bardzo szybki runtime
  + Natywna współbieżność
  - Dłuższy czas developmentu
  - Mniej bibliotek ML/Data

Kompromis:
  Serwisy I/O-bound → Python (asyncio)
  Serwisy CPU-bound → Go
  Serwisy ML/Data → Python
  API Gateway / proxy → Go
```

## Decision Matrix — szablon do użycia

```
Projekt: ________________
Decyzja: ________________
Data:    ________________
Autor:   ________________

Opcje:
  A) ________________
  B) ________________
  C) ________________

Kryteria (wagi):
  1. ________________ (___%)
  2. ________________ (___%)
  3. ________________ (___%)
  4. ________________ (___%)
  5. ________________ (___%)
                   Suma: 100%

Wyniki:
  Opcja A: ___ / 5.0
  Opcja B: ___ / 5.0
  Opcja C: ___ / 5.0

Rekomendacja: ________________
Uzasadnienie: ________________
Ryzyka:       ________________
Plan B:       ________________
```

## Antypatterns w ocenie kompromisów

1. **Analysis Paralysis** — zbyt długa analiza, brak decyzji
2. **Hype-Driven Development** — wybór technologii bo jest modna
3. **Resume-Driven Development** — wybór technologii bo chcę ją w CV
4. **Golden Hammer** — wszystko rozwiązuję tym samym narzędziem
5. **Premature Optimization** — optymalizacja bez danych pomiarowych
6. **Sunk Cost Fallacy** — trzymanie się złej decyzji, bo "już tyle zainwestowaliśmy"

## Kluczowe zasady

1. **Każda decyzja to kompromis** — jawnie nazywaj co zyskujesz i co tracisz
2. **Dane > opinie** — mierz, benchmarkuj, buduj PoC
3. **Dokumentuj decyzje** — przyszły Ty podziękujesz
4. **Rozróżniaj Type 1 i Type 2** — nie traktuj wszystkich decyzji jednakowo
5. **Włączaj interesariuszy** — kompromis jest lepszy gdy wszyscy go rozumieją
6. **Rewizytuj decyzje** — kontekst się zmienia, decyzje też powinny
