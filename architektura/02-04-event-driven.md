# Architektura Event-Driven (EDA)

## Czym jest architektura zdarzeniowa?

Architektura Event-Driven (EDA) to wzorzec, w którym **zdarzenia (events) są głównym mechanizmem komunikacji** między komponentami systemu. Zamiast bezpośrednich wywołań, komponenty publikują zdarzenia i reagują na zdarzenia innych komponentów.

```
┌──────────┐  event   ┌──────────────┐  event   ┌──────────┐
│ Producent │────────►│ Event Broker  │────────►│ Konsument │
│           │         │ (Kafka/RMQ)   │────────►│ B         │
└──────────┘         └──────────────┘  event   └──────────┘
                                       ────────►┌──────────┐
                                                │ Konsument │
                                                │ C         │
                                                └──────────┘
```

## Rodzaje zdarzeń

### 1. Event Notification
Informacja, że coś się stało — minimalny payload:
```json
{
  "type": "OrderCreated",
  "orderId": "abc-123",
  "timestamp": "2024-01-15T10:30:00Z"
}
```
Konsument musi pobrać szczegóły z serwisu źródłowego.

### 2. Event-Carried State Transfer
Zdarzenie zawiera pełne dane potrzebne konsumentowi:
```json
{
  "type": "OrderCreated",
  "orderId": "abc-123",
  "customerId": "cust-456",
  "items": [
    { "productId": "prod-1", "quantity": 2, "price": 29.99 },
    { "productId": "prod-2", "quantity": 1, "price": 49.99 }
  ],
  "totalAmount": 109.97,
  "timestamp": "2024-01-15T10:30:00Z"
}
```
Konsument jest samowystarczalny — nie musi odpytywać innych serwisów.

### 3. Domain Event
Zdarzenie z kontekstu domenowego (DDD):
```json
{
  "type": "PaymentFailed",
  "aggregateId": "order-abc-123",
  "reason": "INSUFFICIENT_FUNDS",
  "attemptNumber": 3,
  "occurredAt": "2024-01-15T10:35:00Z"
}
```

## Event Sourcing

Zamiast przechowywać bieżący stan, zapisujemy **sekwencję wszystkich zdarzeń**:

```
Tradycyjne podejście (CRUD):
┌─────────────────────────────────────┐
│ Order #123                          │
│ status: shipped                     │
│ total: 109.97                       │
│ updated_at: 2024-01-16              │
└─────────────────────────────────────┘

Event Sourcing:
┌─────────────────────────────────────┐
│ 1. OrderCreated    { total: 109.97 }│
│ 2. PaymentReceived { amount: 109.97}│
│ 3. OrderApproved   { approver: "A" }│
│ 4. ItemShipped     { tracking: "X" }│
└─────────────────────────────────────┘
Stan = replay wszystkich zdarzeń
```

### Implementacja Event Store

```python
class EventStore:
    def __init__(self):
        self.events = []  # w produkcji: baza danych
    
    def append(self, aggregate_id: str, event: dict):
        self.events.append({
            "aggregate_id": aggregate_id,
            "event_type": event["type"],
            "data": event,
            "version": self._next_version(aggregate_id),
            "timestamp": datetime.utcnow()
        })
    
    def get_events(self, aggregate_id: str) -> list:
        return [e for e in self.events 
                if e["aggregate_id"] == aggregate_id]

class Order:
    def __init__(self):
        self.status = None
        self.items = []
        self.total = 0
    
    @staticmethod
    def rebuild(events: list) -> "Order":
        """Odbuduj stan z sekwencji zdarzen"""
        order = Order()
        for event in events:
            order.apply(event)
        return order
    
    def apply(self, event: dict):
        match event["type"]:
            case "OrderCreated":
                self.status = "created"
                self.items = event["data"]["items"]
                self.total = event["data"]["total"]
            case "PaymentReceived":
                self.status = "paid"
            case "OrderShipped":
                self.status = "shipped"
```

### Zalety Event Sourcing
- **Pełna historia** — audit log z natury
- **Debugowanie** — odtworzenie stanu w dowolnym momencie
- **Temporal queries** — zapytania o stan historyczny
- **Odporność** — replay zdarzeń po awarii

### Wady Event Sourcing
- **Złożoność** — wymaga zmiany paradygmatu myślenia
- **Eventual consistency** — projekcje mogą być nieaktualne
- **Schema evolution** — zmiany formatu zdarzeń wymagają migracji
- **Storage** — rosnąca ilość zdarzeń (snapshoty pomagają)

## CQRS + Event Sourcing

```
Komendy (zapisy):              Zapytania (odczyty):

┌──────────┐                   ┌──────────┐
│ Command  │                   │  Query   │
│ Handler  │                   │ Handler  │
└────┬─────┘                   └────┬─────┘
     │                              │
     ▼                              ▼
┌──────────┐   projekcja    ┌──────────────┐
│  Event   │──────────────►│  Read Model   │
│  Store   │               │ (zoptymalizow.)│
└──────────┘               └──────────────┘
```

Szczegóły CQRS — patrz osobny rozdział (02-05).

## Eventual Consistency

W systemach event-driven dane mogą być **przejściowo niespójne**:

```
Czas ──────────────────────────────────────────►

Serwis A:  [Zamówienie złożone]
                    │
                    ▼ (event)
Serwis B:          ···[Płatność zainicjowana]
                              │
                              ▼ (event)
Serwis C:                    ···[Magazyn zaktualizowany]

Okno niespójności: │◄────────►│
(ms do sekund)
```

### Strategie radzenia sobie z eventual consistency
1. **UI Optimistic Updates** — pokaż użytkownikowi oczekiwany stan
2. **Polling / WebSocket** — odśwież widok po potwierdzeniu
3. **Saga Pattern** — koordynacja i kompensacja
4. **Idempotencja** — bezpieczne ponowne przetworzenie eventu

## Event Storming

Event Storming to technika **warsztatowa** służąca odkrywaniu procesów biznesowych w formie zdarzeń:

```
Tablicza Event Storming:

┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ Klient   │  │ Zamówie. │  │ Płatność │  │Zamówienie│
│ złożył   │→ │ utworzone │→ │ otrzymana│→ │ wysłane  │
│zamówienie│  │          │  │          │  │          │
│(pomarańcz)│ │(pomarańcz)│ │(pomarańcz)│ │(pomarańcz)│
└──────────┘  └──────────┘  └──────────┘  └──────────┘
     ↑              ↑             ↑             ↑
┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
│ Złóż     │  │ Utwórz   │  │ Przyjmij │  │ Wyślij   │
│zamówienie│  │zamówienie│  │ płatność │  │zamówienie│
│(niebieski)│ │(niebieski)│ │(niebieski)│ │(niebieski)│
└──────────┘  └──────────┘  └──────────┘  └──────────┘
  Komendy        Komendy       Komendy       Komendy

Kolory kartek:
- Pomarańczowy = Domain Event (co się stało)
- Niebieski    = Command (polecenie)
- Żółty        = Aggregate / Actor
- Różowy       = Hotspot / Problem
- Zielony      = Read Model / View
```

### Kroki Event Storming
1. **Big Picture** — zbierz wszystkie zdarzenia na osi czasu
2. **Odkryj komendy** — co powoduje każde zdarzenie?
3. **Zidentyfikuj aggregaty** — kto przetwarza komendy?
4. **Oznacz bounded contexts** — granice mikroserwisów
5. **Znajdź hotspoty** — problemy, pytania, konflikty

## Choreografia vs Orkiestracja

### Choreografia
Serwisy samodzielnie reagują na zdarzenia — brak centralnego koordynatora:

```
OrderCreated ──► PaymentService (przetwarza płatność)
PaymentCompleted ──► InventoryService (rezerwuje towar)
InventoryReserved ──► ShippingService (planuje wysyłkę)
ShipmentPlanned ──► NotificationService (informuje klienta)
```

**Zalety:** luźne powiązanie, łatwe dodawanie nowych konsumentów
**Wady:** trudne śledzenie procesu, brak widoku całości

### Orkiestracja
Centralny koordynator (Saga) zarządza procesem:

```
┌──────────────────────┐
│   Order Saga         │
│                      │
│  1. ReserveInventory │──► InventoryService
│  2. ProcessPayment   │──► PaymentService
│  3. ArrangeShipping  │──► ShippingService
│  4. SendConfirmation │──► NotificationService
│                      │
│  OnFailure:          │
│  - CompensatePayment │
│  - ReleaseInventory  │
└──────────────────────┘
```

**Zalety:** jasny przepływ, łatwe debugowanie i monitoring
**Wady:** centralny punkt, silniejsze powiązania

### Kiedy co wybrać?

| Aspekt | Choreografia | Orkiestracja |
|--------|-------------|-------------|
| Złożoność procesu | Prosta | Złożona |
| Widoczność | Rozproszona | Centralna |
| Coupling | Niski | Średni |
| Kompensacja | Trudniejsza | Łatwiejsza |
| Nowe kroki | Łatwo dodać | Wymaga zmian w Sadze |

## Narzędzia i technologie

| Narzędzie | Typ | Kiedy stosować |
|-----------|-----|---------------|
| Apache Kafka | Event streaming | Duże wolumeny, replay, log |
| RabbitMQ | Message broker | Routing, priorytetyzacja |
| AWS EventBridge | Serverless events | Chmura AWS, integracje |
| NATS | Lightweight messaging | Niska latencja, IoT |
| EventStoreDB | Event store | Event sourcing natywne |

## Zalety i wady EDA

### Zalety
- Luźne powiązania między komponentami
- Wysoka skalowalność i odporność
- Naturalny audit trail (historia zdarzeń)
- Łatwe dodawanie nowych konsumentów
- Asynchroniczność — lepsze wykorzystanie zasobów

### Wady
- Eventual consistency (brak natychmiastowej spójności)
- Trudniejsze debugowanie i testowanie
- Złożoność infrastruktury (broker, monitoring)
- Ryzyko "event spaghetti" bez dobrych konwencji
- Duplikacja zdarzeń wymaga idempotencji

## Podsumowanie

Architektura zdarzeniowa to potężny wzorzec dla systemów wymagających **luźnych powiązań, skalowalności i asynchronicznego przetwarzania**. Wymaga jednak dojrzałego zespołu, dobrego monitoringu i świadomego podejścia do eventual consistency. Event Storming jest świetnym narzędziem do odkrywania zdarzeń i granic kontekstów domenowych.
