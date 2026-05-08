# Mikroserwisy

## Czym są mikroserwisy?

Architektura mikroserwisowa to podejście, w którym system jest budowany jako **zbiór małych, niezależnych serwisów**, z których każdy realizuje jedną, dobrze zdefiniowaną funkcję biznesową. Każdy mikroserwis jest wdrażany, skalowany i rozwijany niezależnie.

```
┌──────────────────────────────────────────────────────────┐
│                      API Gateway                         │
└──────┬──────────┬──────────┬──────────┬─────────────────┘
       │          │          │          │
  ┌────▼───┐ ┌───▼────┐ ┌───▼────┐ ┌──▼──────┐
  │Użytkow.│ │Zamówie.│ │Płatnoś.│ │Powiadomi│
  │ Serwis │ │ Serwis │ │ Serwis │ │  Serwis │
  └───┬────┘ └───┬────┘ └───┬────┘ └────┬────┘
      │          │          │            │
  ┌───▼──┐  ┌───▼──┐  ┌───▼──┐    ┌───▼──┐
  │ BD 1 │  │ BD 2 │  │ BD 3 │    │ BD 4 │
  └──────┘  └──────┘  └──────┘    └──────┘
```

## Kluczowe cechy

1. **Niezależny deployment** — każdy serwis ma własny pipeline CI/CD
2. **Własna baza danych** — Database per Service (brak współdzielonej BD)
3. **Autonomia zespołu** — zespół odpowiada za serwis od A do Z
4. **Polyglot** — każdy serwis może używać innej technologii
5. **Odporność na awarie** — awaria jednego serwisu nie zatrzymuje systemu
6. **Niezależne skalowanie** — każdy serwis skaluje się osobno

## Strategie dekompozycji

### Dekompozycja według funkcji biznesowych

```
E-commerce:
┌─────────────┐ ┌─────────────┐ ┌──────────────┐
│  Katalog    │ │  Koszyk     │ │  Zamówienia  │
│  produktów  │ │  zakupowy   │ │              │
└─────────────┘ └─────────────┘ └──────────────┘
┌─────────────┐ ┌─────────────┐ ┌──────────────┐
│  Płatności  │ │  Wysyłka    │ │  Rekomendacje│
│             │ │             │ │              │
└─────────────┘ └─────────────┘ └──────────────┘
```

### Dekompozycja według Bounded Contexts (DDD)

```
┌─────────────────────────────────────────┐
│           Kontekst: Sprzedaż            │
│  ┌─────────┐  ┌─────────┐              │
│  │ Zamówie. │  │ Klient  │              │
│  │(aggregate)│ │(aggregate)│             │
│  └─────────┘  └─────────┘              │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│           Kontekst: Logistyka           │
│  ┌─────────┐  ┌──────────┐             │
│  │ Przesyłka│  │ Magazyn  │             │
│  │(aggregate)│ │(aggregate)│             │
│  └─────────┘  └──────────┘             │
└─────────────────────────────────────────┘
```

**Zasada:** jeden Bounded Context = jeden (lub kilka powiązanych) mikroserwis.

### Wzorzec dekompozycji — Strangler Fig
Stopniowe wydzielanie mikroserwisów z monolitu:
1. Zidentyfikuj wyraźną granicę biznesową
2. Utwórz nowy mikroserwis obok monolitu
3. Przekieruj ruch do nowego serwisu (przez proxy/router)
4. Powtarzaj aż monolit zostanie zastąpiony

## Wzorce komunikacji

### Synchroniczna (Request-Response)

```
Serwis A ──HTTP/gRPC──► Serwis B
           │
           ◄── odpowiedź ──┘

Zalety: prosty model mentalny, natychmiastowy wynik
Wady:   temporal coupling, kaskadowe awarie
```

### Asynchroniczna (Event-Driven)

```
Serwis A ──event──► [Message Broker] ──event──► Serwis B
                    (Kafka/RabbitMQ)  ──event──► Serwis C

Zalety: luźne powiązanie, odporność na awarie
Wady:   eventual consistency, trudniejsze debugowanie
```

### Porównanie protokołów

| Protokół | Kiedy używać | Wydajność | Złożoność |
|----------|-------------|-----------|-----------|
| REST/HTTP | CRUD API, publiczne API | Średnia | Niska |
| gRPC | Komunikacja wewnętrzna, streaming | Wysoka | Średnia |
| GraphQL | API z elastycznym schematem | Średnia | Średnia |
| Message Queue | Async, decoupling, eventy | Zależna | Wyższa |

### API Gateway Pattern

```
Klienci:     Mobile      Web       Partner
               │          │          │
               ▼          ▼          ▼
          ┌─────────────────────────────┐
          │        API Gateway          │
          │  - Routing                  │
          │  - Rate limiting            │
          │  - Autentykacja             │
          │  - Agregacja odpowiedzi     │
          │  - Transformacja            │
          └──────┬──────┬──────┬───────┘
                 │      │      │
            Serwis A  Serwis B  Serwis C
```

## Zarządzanie danymi

### Database per Service

```
Serwis A        Serwis B        Serwis C
    │               │               │
    ▼               ▼               ▼
┌────────┐     ┌────────┐     ┌────────┐
│PostgreSQL│    │MongoDB │    │ Redis  │
└────────┘     └────────┘     └────────┘

Każdy serwis ma własną bazę — brak współdzielenia!
```

### Saga Pattern (transakcje rozproszone)

```
Zamówienie → [Saga Orchestrator]
                  │
        ┌────────┴─────────────────────┐
        ▼         ▼           ▼        ▼
   Rezerwacja  Płatność   Wysyłka  Powiadomienie
   (step 1)   (step 2)   (step 3)   (step 4)
   
Jeśli step 3 się nie uda:
   Kompensacja: anuluj płatność, zwolnij rezerwację
```

**Choreography Saga** — serwisy reagują na eventy sąsiadów
**Orchestration Saga** — centralny koordynator zarządza krokami

### Event Sourcing dla spójności
Zamiast przechowywać stan, zapisujemy zdarzenia:
```
OrderCreated → ItemAdded → PaymentReceived → OrderShipped
```
Stan odtwarzamy z sekwencji zdarzeń.

## Deployment i infrastruktura

### Konteneryzacja (Docker + Kubernetes)

```yaml
# docker-compose.yml (dev environment)
services:
  user-service:
    build: ./user-service
    ports: ["3001:3000"]
    environment:
      DB_HOST: user-db
    depends_on: [user-db]
    
  order-service:
    build: ./order-service
    ports: ["3002:3000"]
    environment:
      DB_HOST: order-db
      USER_SERVICE_URL: http://user-service:3000
    depends_on: [order-db]

  user-db:
    image: postgres:16
  order-db:
    image: postgres:16
```

### Service Mesh (Istio/Linkerd)

```
┌───────────────────────────────────────────────┐
│                 Service Mesh                   │
│                                                │
│  ┌──────┐ proxy ◄──► proxy ┌──────┐          │
│  │Svc A │──────────────────│Svc B │          │
│  └──────┘                   └──────┘          │
│                                                │
│  Control Plane:                                │
│  - mTLS (szyfrowanie)                         │
│  - Circuit breaker                             │
│  - Retry / timeout                             │
│  - Load balancing                              │
│  - Observability                               │
└───────────────────────────────────────────────┘
```

## Monitoring i obserwowalność

### Trzy filary obserwowalności

```
1. LOGS (Logi)
   ┌──────────────────────────────────────────────────┐
   │ [2024-01-15 10:23:45] [order-svc] [trace-abc123] │
   │ INFO: Order #456 created for customer #789       │
   └──────────────────────────────────────────────────┘
   Narzędzia: ELK Stack, Loki, Datadog

2. METRICS (Metryki)
   ┌──────────────────────────────────┐
   │  Request rate:   1200 req/s     │
   │  Error rate:     0.3%           │
   │  Latency p99:    250ms          │
   └──────────────────────────────────┘
   Narzędzia: Prometheus + Grafana, Datadog

3. TRACES (Ślady rozproszone)
   Request → [Gateway 12ms] → [Order-svc 45ms] → [Payment-svc 120ms]
                                    └→ [Inventory-svc 30ms]
   Narzędzia: Jaeger, Zipkin, OpenTelemetry
```

### Wzorce odporności

```
Circuit Breaker:
Zamknięty ──(awarie)──► Otwarty ──(timeout)──► Pół-otwarty
    ↑                                              │
    └────────── (sukces) ──────────────────────────┘

- Zamknięty: normalne wywołania
- Otwarty: natychmiastowy błąd (nie wywołuje serwisu)
- Pół-otwarty: próbne wywołanie, reset jeśli sukces
```

## Organizacja zespołów — prawo Conwaya

> "Organizacje projektujące systemy będą produkować projekty, 
>  które są kopią struktury komunikacyjnej tych organizacji."

```
Tradycyjne zespoły:         Zespoły mikroserwisowe:
┌──────────┐                ┌──────────────────────┐
│ Frontend  │               │ Zespół: Zamówienia    │
├──────────┤                │ - Frontend            │
│ Backend   │               │ - Backend             │
├──────────┤                │ - DB / DevOps         │
│ DBA       │               │ - QA                  │
├──────────┤                └──────────────────────┘
│ DevOps    │               ┌──────────────────────┐
└──────────┘                │ Zespół: Płatności     │
                            │ - Frontend            │
(silosy technologiczne)     │ - Backend             │
                            │ - DB / DevOps         │
                            └──────────────────────┘
                            (cross-functional teams)
```

**Inverse Conway Maneuver:** celowe kształtowanie struktury zespołów, aby wymuszić pożądaną architekturę systemu.

## Zalety i wady

### Zalety
- Niezależny deployment i skalowanie
- Izolacja awarii (fault isolation)
- Swoboda technologiczna (polyglot)
- Małe, zrozumiałe bazy kodu
- Łatwiejsze skalowanie zespołów

### Wady
- Złożoność operacyjna (networking, monitoring)
- Rozproszone transakcje i spójność danych
- Trudniejsze testowanie end-to-end
- Overhead komunikacji sieciowej
- Wymagane zaawansowane DevOps / platforma

## Kiedy stosować mikroserwisy?

### Wymagane warunki wstępne
1. **Dojrzałe DevOps** — automatyzacja CI/CD, IaC
2. **Konteneryzacja** — Docker, Kubernetes
3. **Monitoring** — centralne logowanie, tracing
4. **Wystarczająco duży zespół** — minimum 20-30 deweloperów
5. **Zrozumienie domeny** — dobrze poznane granice kontekstów

### Sygnały, że potrzebujesz mikroserwisów
- Różne moduły wymagają różnych cykli wdrożeń
- Jeden moduł wymaga 100x więcej zasobów niż inne
- Zespoły blokują się nawzajem przy deploymencie
- Potrzebujesz różnych technologii dla różnych problemów
- Chcesz niezależne skalowanie poszczególnych funkcji

## Podsumowanie

Mikroserwisy to potężny wzorzec, ale nie darmowy. Rozwiązują problemy skali organizacyjnej i technicznej, ale wprowadzają złożoność operacyjną. Zasada: **zacznij od monolitu** (najlepiej modularnego) i rozdzielaj na mikroserwisy dopiero gdy masz ku temu uzasadnione powody i wystarczającą infrastrukturę.
