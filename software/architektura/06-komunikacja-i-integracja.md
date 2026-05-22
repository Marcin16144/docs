# Komunikacja i integracja między serwisami

> **Aktualizacja: 2026** — uwzględnia gRPC, GraphQL Federation v2, tRPC, Server-Sent Events, WebTransport, OpenTelemetry jako standard observability.

## Komunikacja synchroniczna

### REST API
- Najpopularniejszy styl komunikacji
- Zasoby identyfikowane przez URL
- Metody HTTP: GET, POST, PUT, PATCH, DELETE
- Bezstanowy (stateless)

**Dobre praktyki:**
- Wersjonowanie API (np. /api/v1/orders)
- Spójne nazewnictwo zasobów (rzeczowniki, liczba mnoga)
- Właściwe kody HTTP (201 Created, 404 Not Found, 409 Conflict)
- Paginacja dla kolekcji
- Idempotentność operacji

### gRPC
- Wydajny protokół binarny (Protocol Buffers)
- Silne typowanie i generowanie kodu
- Obsługa streamingu (unary, server streaming, client streaming, bidirectional)
- Dobry do komunikacji wewnętrznej między serwisami
- Pozostaje silnym wyborem w 2026 dla wewnętrznej komunikacji w mikroserwisach (niskie opóźnienia, mniejszy payload)
- gRPC-Web umożliwia użycie z poziomu przeglądarki

### GraphQL
- Klient definiuje kształt odpowiedzi
- Jeden endpoint dla wielu zapytań
- Unika problemu over/under-fetching
- Dobry dla złożonych frontendów
- **GraphQL Federation v2** dojrzała — pozwala komponować wiele subgrafów (mikroserwisów) w jeden, spójny supergraph (Apollo Router, Hot Chocolate, GraphQL Yoga)
- Wzorce: persisted queries, automatic persisted queries (APQ), defer/stream

### tRPC (TypeScript-first APIs)
- Kontrakty typowane end-to-end bez generowania kodu (jeden monorepo z TS)
- Idealny dla projektów full-stack TypeScript (np. Next.js + serwer Node)
- Zerowy boilerplate, doskonały DX — popularny w 2026 w ekosystemie TS

### Server-Sent Events (SSE)
- Jednokierunkowy streaming z serwera do klienta po HTTP
- Prostsze niż WebSockets — automatyczny reconnect, działa przez HTTP/2
- Dobry wybór dla powiadomień, live update'ów, streamingu LLM (np. token po tokenie)

### WebTransport
- Nowoczesny następca WebSocket oparty o HTTP/3 i QUIC
- Obsługa wielu strumieni, datagramów (unreliable), niskie opóźnienia
- Dojrzały do produkcji w 2026 w głównych przeglądarkach — dobry dla gier, real-time collaboration, low-latency streaming

---

## Komunikacja asynchroniczna

### Message Queue (Kolejka wiadomości)
Wiadomość dostarczana do jednego konsumenta.
**Narzędzia:** RabbitMQ, Amazon SQS, Azure Service Bus

### Publish/Subscribe (Pub/Sub)
Wiadomość dostarczana do wielu subskrybentów.
**Narzędzia:** Apache Kafka, Google Pub/Sub, Redis Streams

### Porównanie

| Cecha | Synchroniczna | Asynchroniczna |
|-------|--------------|----------------|
| Czas odpowiedzi | Natychmiastowy | Opóźniony |
| Coupling | Czasowy (oba muszą działać) | Luźny |
| Niezawodność | Zależy od dostępności | Wiadomości buforowane |
| Debugowanie | Prostsze | Trudniejsze |
| Kolejność | Gwarantowana | Zależy od implementacji |

---

## Wzorce integracji

### API Gateway
Pojedynczy punkt wejścia dla klientów zewnętrznych. Obsługuje:
- Routing
- Rate limiting
- Uwierzytelnianie
- Agregację odpowiedzi

### Service Mesh
Warstwa infrastruktury obsługująca komunikację między serwisami.
**Narzędzia (2026):** Istio (lider), Linkerd, **Cilium Service Mesh** (rośnie — oparty o eBPF, brak sidecara), Kuma, Consul Connect.

### Saga Pattern
Zarządzanie transakcjami rozproszonymi jako sekwencja lokalnych transakcji z kompensacjami.

```
1. Serwis zamówień → Utwórz zamówienie
2. Serwis płatności → Pobierz płatność
   (jeśli błąd → Kompensacja: Anuluj zamówienie)
3. Serwis magazynu → Zarezerwuj towar
   (jeśli błąd → Kompensacja: Zwróć płatność, Anuluj zamówienie)
```

**Typy:**
- **Choreografia** — serwisy reagują na zdarzenia
- **Orkiestracja** — centralny koordynator zarządza krokami

### Circuit Breaker
Ochrona przed kaskadowymi awariami — po serii błędów zaprzestaje prób połączenia.

Stany: Closed → Open → Half-Open

### Retry z Exponential Backoff
Ponowne próby z rosnącym opóźnieniem: 1s → 2s → 4s → 8s

### Bulkhead Pattern
Izolacja zasobów — awaria jednego komponentu nie wpływa na resztę (jak grodzie na statku).

---

## Observability komunikacji

W 2026 **OpenTelemetry (OTel)** to de facto standard dla telemetrii (traces, metrics, logs) — zastępuje fragmentaryczne API poszczególnych vendorów.

- Kontekst tracingu propaguje się przez nagłówki HTTP (W3C Trace Context: `traceparent`, `tracestate`)
- Dla gRPC kontekst przenoszony jest w metadanych
- Dla wiadomości asynchronicznych (Kafka, SQS) — w nagłówkach wiadomości
- Backendy: Datadog, Honeycomb, Grafana Tempo, Jaeger, AWS X-Ray, New Relic
- OpenTelemetry Collector jako uniwersalny przekaźnik telemetrii (eliminuje vendor lock-in)
