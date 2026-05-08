# 01-05: Zarządzanie ryzykiem technicznym

## Czym jest ryzyko techniczne?

Ryzyko techniczne to potencjalne zdarzenie, które może negatywnie wpłynąć na projekt, system lub organizację. Nie chodzi o eliminowanie ryzyka — to niemożliwe — ale o świadome zarządzanie nim.

```
Ryzyko = Prawdopodobieństwo × Wpływ

Wysokie prawdopodobieństwo + Wysoki wpływ = Krytyczne ryzyko
Niskie prawdopodobieństwo + Wysoki wpływ = Wymaga planu awaryjnego
Wysokie prawdopodobieństwo + Niski wpływ = Wymaga monitorowania
Niskie prawdopodobieństwo + Niski wpływ = Akceptowalne
```

## Identyfikacja ryzyk

### Analiza SWOT (kontekst techniczny)

```
STRENGTHS (Silne strony):          WEAKNESSES (Słabości):
+ Doświadczony zespół backend     - Brak kompetencji frontend
+ Dojrzała infrastruktura CI/CD   - Legacy monolith PHP
+ Dobry monitoring (Grafana)      - Brak testów integracyjnych
+ Kultura code review             - Dokumentacja nieaktualna

OPPORTUNITIES (Szanse):            THREATS (Zagrożenia):
+ Migracja do chmury (elastycz.)  - Kluczowy dev odchodzi
+ Nowe API partnera               - Zmiana regulacji GDPR
+ Konsolidacja mikroserwisów      - Rosnący dług techniczny
+ Adopcja AI/ML                   - Vendor lock-in AWS
```

### Burza mózgów strukturalna

Przejdź przez każdą kategorię i zadaj pytania:

```
LUDZIE:
  - Czy mamy bus factor = 1 w jakimś obszarze?
  - Czy zespół ma wymagane kompetencje?
  - Czy kluczowe osoby planują odejście?
  - Czy zespół jest przeciążony?

TECHNOLOGIA:
  - Czy używamy technologii bliskich EOL?
  - Czy zależymy od unmaintained libraries?
  - Czy mamy single points of failure?
  - Czy architektura się skaluje?

PROCES:
  - Czy mamy testy automatyczne?
  - Czy deployment jest zautomatyzowany?
  - Czy mamy procedury disaster recovery?
  - Czy robimy regularne security audyty?

ZEWNĘTRZNE:
  - Czy zależymy od jednego dostawcy?
  - Czy nadchodzą zmiany regulacyjne?
  - Czy kontrakty SLA są odpowiednie?
  - Czy mamy plany na awarie dostawców?
```

### Pre-mortem

Technika "wyobraź sobie, że projekt się nie udał":

```
Scenariusz: Jest 6 miesięcy po wdrożeniu. Projekt okazał się katastrofą.

Każdy członek zespołu (niezależnie!) pisze:
  "Projekt się nie udał, ponieważ..."

Typowe odpowiedzi:
  - "...nie przetestowaliśmy pod obciążeniem i system padł w Black Friday"
  - "...integracja z systemem płatności zajęła 3x dłużej niż zakładaliśmy"
  - "...nie uwzględniliśmy migracji danych ze starego systemu"
  - "...kluczowy programista odszedł po 2 miesiącach"
  - "...nie zdefiniowaliśmy jasnych kryteriów akceptacji"

Następnie: każde ryzyko trafia do rejestru ryzyk
```

## Ocena ryzyk

### Matryca prawdopodobieństwa i wpływu

```
                        WPŁYW
                 Niski    Średni    Wysoki    Krytyczny
              ┌─────────┬─────────┬─────────┬──────────┐
  Bardzo      │ ŚREDNI  │ WYSOKI  │ KRYTYCZ.│ KRYTYCZ. │
  wysokie     │         │         │         │          │
P             ├─────────┼─────────┼─────────┼──────────┤
R  Wysokie    │ NISKI   │ ŚREDNI  │ WYSOKI  │ KRYTYCZ. │
A             │         │         │         │          │
W             ├─────────┼─────────┼─────────┼──────────┤
D.  Średnie   │ NISKI   │ NISKI   │ ŚREDNI  │ WYSOKI   │
              │         │         │         │          │
              ├─────────┼─────────┼─────────┼──────────┤
   Niskie     │ NISKI   │ NISKI   │ NISKI   │ ŚREDNI   │
              │         │         │         │          │
              └─────────┴─────────┴─────────┴──────────┘
```

### Ocena liczbowa

```
Prawdopodobieństwo (1-5):
  1 = Bardzo niskie (< 10%)
  2 = Niskie (10-25%)
  3 = Średnie (25-50%)
  4 = Wysokie (50-75%)
  5 = Bardzo wysokie (> 75%)

Wpływ (1-5):
  1 = Pomijalny (< 1 dzień opóźnienia)
  2 = Niski (1-5 dni opóźnienia)
  3 = Średni (1-4 tygodnie opóźnienia)
  4 = Wysoki (1-3 miesiące opóźnienia)
  5 = Krytyczny (projekt zagrożony)

Risk Score = P × I

Krytyczne: 15-25 → Natychmiastowe działanie
Wysokie:   10-14 → Plan mitygacji wymagany
Średnie:    5-9  → Monitorowanie i plan awaryjny
Niskie:     1-4  → Akceptacja z monitorowaniem
```

### Przykład rejestru ryzyk

| ID | Ryzyko | P | I | Score | Strategia | Właściciel | Status |
|----|--------|---|---|-------|-----------|------------|--------|
| R1 | Awaria głównej bazy danych | 2 | 5 | 10 | Mitigate | DevOps Lead | Aktywny |
| R2 | Odejście kluczowego deva | 4 | 4 | 16 | Mitigate | Tech Lead | Aktywny |
| R3 | Vendor lock-in AWS | 3 | 3 | 9 | Accept | Architekt | Monitorowany |
| R4 | Przekroczenie budżetu chmury | 3 | 2 | 6 | Mitigate | DevOps Lead | Aktywny |
| R5 | Niezgodność z GDPR | 2 | 5 | 10 | Avoid | Security Lead | Aktywny |
| R6 | Opóźnienie integracji API | 4 | 3 | 12 | Transfer | PM | Aktywny |

## Strategie zarządzania ryzykiem

### Cztery strategie (4T)

```
1. TERMINATE (Unikaj / Avoid)
   → Eliminuj ryzyko zmieniając podejście
   Przykład: Zamiast budować własny system auth,
   użyj Auth0/Keycloak

2. TRANSFER (Przenieś)
   → Przenieś ryzyko na kogoś innego
   Przykład: SLA od cloud providera,
   ubezpieczenie, outsourcing specjalistyczny

3. TREAT (Mityguj / Mitigate)
   → Zmniejsz prawdopodobieństwo lub wpływ
   Przykład: Regularne backupy, testy obciążeniowe,
   redundancja, monitoring

4. TOLERATE (Akceptuj / Accept)
   → Świadomie zaakceptuj ryzyko
   Przykład: Ryzyko przestoju < 5 min/rok
   przy koszcie eliminacji $100K
```

### Przykłady strategii dla typowych ryzyk

```
RYZYKO: Bus factor = 1 (jeden programista zna krytyczny moduł)
  Avoid:    Przepisanie modułu w prostszej technologii
  Transfer: Outsource wiedzy do zewnętrznego konsultanta
  Mitigate: Pair programming, dokumentacja, code review
  Accept:   Ryzyko niskie, moduł się nie zmienia

RYZYKO: Awaria bazy danych
  Avoid:    Multi-master setup (brak single point of failure)
  Transfer: Managed database (AWS RDS, Cloud SQL) — SLA 99.95%
  Mitigate: Automatyczny failover, replikacja, backupy co godzinę
  Accept:   Dla systemu dev/staging — akceptowalne

RYZYKO: Zmiana regulacji (np. nowe wymagania GDPR)
  Avoid:    Nie zbieraj danych osobowych (rzadko możliwe)
  Transfer: Konsultant prawny + DPO
  Mitigate: Privacy by design, audyty kwartalne, elastyczna architektura
  Accept:   Monitoruj zmiany, reaguj gdy się pojawią
```

## Zarządzanie długiem technicznym

### Czym jest dług techniczny?

```
Typy długu technicznego:

1. Celowy (Deliberate):
   "Wiemy, że to hack, ale musimy zdążyć na deadline.
    Naprawimy w następnym sprincie."
   → Akceptowalny jeśli udokumentowany i zaplanowany

2. Niecelowy (Inadvertent):
   "Nie wiedzieliśmy, że to jest złe podejście."
   → Wynik braku wiedzy, wymaga edukacji

3. Bit rot:
   "Kiedyś to było OK, ale technologia poszła do przodu."
   → Naturalny proces, wymaga regularnego refactoringu
```

### Kwantyfikacja długu technicznego

```
Technika: Debt Register

| Dług | Koszt utrzymania/mies. | Koszt naprawy | ROI naprawy |
|------|----------------------|---------------|-------------|
| Legacy auth module | $2,000 (czas dev) | $15,000 | 7.5 mies. |
| Brak testów modułu X | $3,000 (bugi) | $10,000 | 3.3 mies. |
| Outdated dependencies | $500 (security risk) | $5,000 | 10 mies. |
| Monolityczna baza | $4,000 (czas dev) | $50,000 | 12.5 mies. |

Priorytet naprawy: najkrótszy ROI (breakeven) najpierw
```

### Reguła "15%"

```
Przeznacz 15-20% capacity zespołu na spłatę długu technicznego.

Sprint capacity: 100 story points
  → 80 SP na features
  → 15 SP na dług techniczny
  → 5 SP na spike/research

Bez tej reguły dług rośnie eksponencjalnie:
  Kwartał 1: "mamy trochę długu, ale damy radę"
  Kwartał 2: "development trwa dłużej niż powinien"
  Kwartał 3: "połowa czasu idzie na obchodzenie problemów"
  Kwartał 4: "musimy przepisać system od nowa" (Big Rewrite)
```

## Spike Solutions i Prototypowanie

### Spike Solution

Timeboxowane badanie mające na celu redukcję ryzyka technicznego:

```
Spike: Weryfikacja wydajności Elasticsearch dla full-text search

Kontekst:
  - 50M dokumentów, średnio 5KB każdy
  - Wymaganie: search < 200ms at p99
  - Aktualnie: PostgreSQL full-text, 2s przy 50k docs

Timebox: 2 dni

Plan:
  Dzień 1:
    - Setup klastra ES (3 węzły)
    - Import sample danych (5M dokumentów)
    - Konfiguracja analizerów i mapowań
  Dzień 2:
    - Benchmark z realistycznymi zapytaniami
    - Test przy 50M dokumentów
    - Dokumentacja wyników

Rezultat:
  ✓ ES: 45ms at p99 dla 50M docs
  ✓ Spełnia wymaganie z dużym zapasem
  ✗ Wymaga 3x więcej RAM niż zakładaliśmy
  → Rekomendacja: TAK, ale z budżetem na infra
```

### Prototyp vs MVP vs PoC

```
Prototyp:
  Cel: Walidacja UX/interakcji
  Zakres: Frontend only, fake data
  Czas: 1-2 tygodnie
  Przeznaczenie: Do wyrzucenia

PoC (Proof of Concept):
  Cel: Walidacja technicznej wykonalności
  Zakres: Krytyczna ścieżka, brak UI
  Czas: 3-5 dni
  Przeznaczenie: Do wyrzucenia

MVP (Minimum Viable Product):
  Cel: Walidacja wartości biznesowej
  Zakres: Minimalna działająca funkcjonalność
  Czas: 4-8 tygodni
  Przeznaczenie: Baza do dalszego rozwoju
```

## Architecture Runway

Architecture Runway to istniejąca infrastruktura techniczna i architektoniczna, która umożliwia dostarczanie features bez dużych zmian architektonicznych.

### Budowanie Runway

```
Runway wystarczający:
  ✓ Zespół może dostarczać features bez zmian w architekturze
  ✓ Infrastruktura wspiera planowany wzrost przez 6+ miesięcy
  ✓ Narzędzia i procesy nie blokują developmentu

Runway wyczerpany:
  ✗ Każda nowa feature wymaga zmian w infrastrukturze
  ✗ Wydajność degraduje przy rosnącym ruchu
  ✗ Deployment trwa godziny zamiast minut
  ✗ Testy przechodzą tylko "na szczęście"
```

### Planowanie Runway

```
Kwartał Q1 (Runway Building):
  - Migracja CI/CD na GitHub Actions
  - Setup Kubernetes z auto-scaling
  - Implementacja distributed tracing
  - Standaryzacja API contracts (OpenAPI)

Kwartał Q2-Q3 (Feature Delivery):
  - Zespoły mogą dostarczać features bez blokad
  - Runway wspiera nowe serwisy bez dodatkowej pracy infra
  - Monitoring i alerting działają automatycznie

Kwartał Q4 (Runway Refresh):
  - Przegląd i aktualizacja runway
  - Nowe wymagania (np. multi-region)
  - Spłata długu technicznego
```

## Failure Modes Analysis (FMEA)

Systematyczna analiza możliwych awarii:

```
Format FMEA:

| Komponent | Tryb awarii | Skutek | Sev | Occ | Det | RPN | Akcja |
|-----------|------------|--------|-----|-----|-----|-----|-------|
| DB Primary | Crash | Brak zapisu | 9 | 3 | 2 | 54 | Auto-failover |
| API Gateway | Timeout | 503 error | 7 | 4 | 3 | 84 | Circuit breaker |
| Cache | Eviction | Wolne query | 4 | 7 | 5 | 140 | Cache warming |
| Auth Service | Token exp. | Wylogowanie | 6 | 2 | 2 | 24 | Token refresh |
| Queue | Full | Utrata msg | 8 | 2 | 4 | 64 | Dead letter queue |

Sev = Severity (1-10)
Occ = Occurrence (1-10)
Det = Detection difficulty (1-10)
RPN = Risk Priority Number (Sev × Occ × Det)

Priorytet: najwyższy RPN naprawiamy najpierw
```

## Chaos Engineering

Proaktywne testowanie odporności systemu:

```
Zasady Chaos Engineering:

1. Zdefiniuj "steady state" (normalne zachowanie)
   → p99 < 200ms, error rate < 0.1%, CPU < 60%

2. Sformułuj hipotezę
   → "System obsłuży awarię jednego węzła bazy danych
      bez widocznego wpływu na użytkowników"

3. Wprowadź zmienną (eksperyment)
   → Wyłącz primary database node

4. Obserwuj różnicę między steady state a eksperymentem
   → Zmierz: latency, error rate, recovery time

5. Wyciągnij wnioski
   → Failover zadziałał w 15s (cel: < 30s) ✓
   → 3 requesty zwróciły 500 w trakcie failover ✗
   → Action: retry logic na kliencie
```

### Eksperymenty Chaos

```
Poziom 1 (bezpieczne):
  - Kill random pod w Kubernetes
  - Zwiększ latencję sieciową o 100ms
  - Zablokuj połączenie do cache

Poziom 2 (średnie ryzyko):
  - Wyłącz cały serwis
  - Symuluj wyczerpanie dysku
  - Zablokuj DNS

Poziom 3 (produkcja, ostrożnie):
  - Kill losowy node w klastrze
  - Symuluj awarię AZ (Availability Zone)
  - Ogranicz bandwidth między serwisami
```

## Praktyczny szablon rejestru ryzyk

```
REJESTR RYZYK PROJEKTU
Projekt: ________________
Data:    ________________
Wersja:  ________________

ID:           R-XXX
Nazwa:        ________________
Opis:         ________________
Kategoria:    [ ] Ludzie  [ ] Technologia  [ ] Proces  [ ] Zewnętrzne
P (1-5):      ___
I (1-5):      ___
Score:        ___
Strategia:    [ ] Avoid  [ ] Transfer  [ ] Mitigate  [ ] Accept
Plan:         ________________
Właściciel:   ________________
Termin:       ________________
Status:       [ ] Nowy  [ ] Aktywny  [ ] Monitorowany  [ ] Zamknięty
Data review:  ________________
```

## Kluczowe zasady zarządzania ryzykiem

1. **Ryzyko to nie problem** — problem już wystąpił, ryzyko to potencjalne zdarzenie
2. **Identyfikuj wcześnie** — koszt reakcji rośnie wykładniczo z czasem
3. **Kwantyfikuj** — "duże ryzyko" to za mało, potrzebujesz liczb
4. **Przypisuj właścicieli** — ryzyko bez właściciela to ryzyko nieskutecznie zarządzane
5. **Regularnie przeglądaj** — ryzyka się zmieniają, rejestr musi być żywy
6. **Akceptacja to też strategia** — nie każde ryzyko wymaga działania
7. **Komunikuj** — interesariusze muszą znać ryzyka i ich status
8. **Ucz się z porażek** — post-mortem po incydencie to najlepsza lekcja
