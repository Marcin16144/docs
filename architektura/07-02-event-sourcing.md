# Event Sourcing

## Czym jest Event Sourcing?

Event Sourcing to wzorzec architektoniczny, w ktorym stan aplikacji jest przechowywany jako sekwencja zdarzen (eventow), a nie jako aktualny stan w bazie danych. Zamiast nadpisywac dane, zapisujemy kazda zmiane jako nowe zdarzenie. Aktualny stan odtwarzamy przez odtworzenie (replay) wszystkich zdarzen.

## Tradycyjne podejscie vs Event Sourcing

### Tradycyjne (CRUD)

```
Operacja: Zmien status zamowienia na "wyslane"

UPDATE orders SET status = 'shipped' WHERE id = 'ord-123';

Problem: Stracilismy informacje o poprzednich stanach.
Kiedy zamowienie bylo utworzone? Kiedy oplacone?
```

### Event Sourcing

```
Event 1: OrderCreated     { orderId: "ord-123", items: [...], total: 299.99 }
Event 2: PaymentReceived  { orderId: "ord-123", amount: 299.99 }
Event 3: OrderShipped     { orderId: "ord-123", trackingNo: "DHL-456" }
Event 4: OrderDelivered   { orderId: "ord-123", deliveredAt: "2025-03-15" }

Stan aktualny = replay wszystkich eventow
→ { status: "delivered", total: 299.99, tracking: "DHL-456", ... }
```

## Event Store

Event Store to specjalizowana baza danych do przechowywania zdarzen. Kazde zdarzenie jest niezmienne (immutable) — raz zapisane, nigdy nie jest modyfikowane ani usuwane.

### Struktura zdarzenia

```json
{
  "eventId": "evt-789",
  "streamId": "order-123",
  "eventType": "OrderShipped",
  "version": 3,
  "timestamp": "2025-03-14T10:30:00Z",
  "data": {
    "orderId": "order-123",
    "trackingNumber": "DHL-456",
    "carrier": "DHL"
  },
  "metadata": {
    "userId": "user-456",
    "correlationId": "req-abc",
    "causationId": "evt-788"
  }
}
```

### Schemat Event Store

```sql
CREATE TABLE events (
  event_id UUID PRIMARY KEY,
  stream_id VARCHAR(255) NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  version INT NOT NULL,
  data JSONB NOT NULL,
  metadata JSONB,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  UNIQUE(stream_id, version)  -- optymistyczna kontrola wspolbieznosci
);

CREATE INDEX idx_events_stream ON events(stream_id, version);
```

### Zapis z kontrola wspolbieznosci

```javascript
async function appendEvent(streamId, event, expectedVersion) {
  try {
    await db.query(
      `INSERT INTO events (event_id, stream_id, event_type, version, data, metadata)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [uuid(), streamId, event.type, expectedVersion + 1, event.data, event.metadata]
    );
  } catch (err) {
    if (err.constraint === 'events_stream_id_version_key') {
      throw new ConcurrencyError(
        `Stream ${streamId} zmodyfikowany — oczekiwano wersji ${expectedVersion}`
      );
    }
    throw err;
  }
}
```

## Odtwarzanie stanu (Replay)

Stan agregatu odtwarzamy przez sekwencyjne aplikowanie eventow:

```javascript
class Order {
  constructor() {
    this.status = null;
    this.items = [];
    this.total = 0;
  }

  // Odtworzenie stanu z eventow
  static fromEvents(events) {
    const order = new Order();
    for (const event of events) {
      order.apply(event);
    }
    return order;
  }

  apply(event) {
    switch (event.eventType) {
      case 'OrderCreated':
        this.id = event.data.orderId;
        this.items = event.data.items;
        this.total = event.data.total;
        this.status = 'created';
        break;
      case 'PaymentReceived':
        this.status = 'paid';
        this.paidAt = event.timestamp;
        break;
      case 'OrderShipped':
        this.status = 'shipped';
        this.trackingNumber = event.data.trackingNumber;
        break;
      case 'OrderDelivered':
        this.status = 'delivered';
        this.deliveredAt = event.data.deliveredAt;
        break;
      case 'OrderCancelled':
        this.status = 'cancelled';
        this.cancelReason = event.data.reason;
        break;
    }
    this.version = event.version;
  }
}

// Uzycie
const events = await eventStore.getStream('order-123');
const order = Order.fromEvents(events);
```

## Snapshoty

Gdy strumien ma tysiace eventow, odtwarzanie stanu od zera jest wolne. Snapshot to zapisany stan agregatu w danym momencie — pozwala pominac wczesniejsze eventy.

```javascript
// Snapshot co N eventow
async function getAggregate(streamId) {
  // 1. Sprobuj zaladowac ostatni snapshot
  const snapshot = await snapshotStore.getLatest(streamId);

  // 2. Zaladuj eventy od momentu snapshotu
  const fromVersion = snapshot ? snapshot.version + 1 : 0;
  const events = await eventStore.getStream(streamId, fromVersion);

  // 3. Odtworz stan
  const aggregate = snapshot
    ? Order.fromSnapshot(snapshot.state)
    : new Order();

  for (const event of events) {
    aggregate.apply(event);
  }

  // 4. Zapisz nowy snapshot jesli potrzeba
  if (events.length > SNAPSHOT_THRESHOLD) {
    await snapshotStore.save(streamId, aggregate.version, aggregate.toSnapshot());
  }

  return aggregate;
}
```

### Kiedy robic snapshoty?

| Strategia | Opis | Kiedy stosowac |
|-----------|------|----------------|
| Co N eventow | Snapshot co 100/500/1000 eventow | Najczesciej stosowana |
| Czasowa | Snapshot co X minut/godzin | Regularne obciazenie |
| Na zadanie | Snapshot przy konkretnym evencie | Wazne punkty kontrolne |
| Hybrydowa | Polaczenie powyzszych | Zlozone systemy |

## Projekcje (Read Models)

Projekcje to widoki danych zbudowane z eventow, zoptymalizowane pod konkretne zapytania. To klucz do wydajnego odczytu w systemie opartym na Event Sourcing.

```
Strumien eventow
  │
  ├──→ Projekcja 1: Lista zamowien (SQL tabela)
  │      OrderCreated → INSERT INTO orders_list ...
  │      OrderShipped → UPDATE orders_list SET status = 'shipped' ...
  │
  ├──→ Projekcja 2: Dashboard sprzedazy (agregacje)
  │      OrderCreated → UPDATE daily_sales SET total = total + amount ...
  │
  └──→ Projekcja 3: Wyszukiwarka (Elasticsearch)
         OrderCreated → Index do Elasticsearch
         OrderShipped → Update dokumentu w ES
```

### Implementacja projekcji

```javascript
class OrderListProjection {
  async handle(event) {
    switch (event.eventType) {
      case 'OrderCreated':
        await db.query(
          `INSERT INTO orders_view (id, customer_id, total, status, created_at)
           VALUES ($1, $2, $3, 'created', $4)`,
          [event.data.orderId, event.data.customerId,
           event.data.total, event.timestamp]
        );
        break;

      case 'OrderShipped':
        await db.query(
          `UPDATE orders_view SET status = 'shipped',
           tracking_number = $1 WHERE id = $2`,
          [event.data.trackingNumber, event.data.orderId]
        );
        break;

      case 'OrderCancelled':
        await db.query(
          `UPDATE orders_view SET status = 'cancelled' WHERE id = $1`,
          [event.data.orderId]
        );
        break;
    }
  }
}
```

### Przebudowa projekcji

Jedna z najwiekszych zalet Event Sourcing — mozliwosc przebudowy (rebuild) projekcji od zera:

```javascript
async function rebuildProjection(projection) {
  // 1. Wyczysc docelowa tabele/indeks
  await projection.reset();

  // 2. Odczytaj wszystkie eventy od poczatku
  const allEvents = eventStore.readAll({ fromPosition: 0 });

  // 3. Przetworz kazdy event
  let count = 0;
  for await (const event of allEvents) {
    await projection.handle(event);
    count++;
    if (count % 10000 === 0) {
      console.log(`Przetworzono ${count} eventow...`);
    }
  }

  console.log(`Rebuild zakonczony: ${count} eventow`);
}
```

## Wersjonowanie eventow

Eventy sa niezmienne, ale wymagania biznesowe sie zmieniaja. Potrzebujemy strategii na ewolucje schematu eventow.

### Strategia 1: Upcasting

Transformacja starego formatu do nowego podczas odczytu:

```javascript
const upcasters = {
  'OrderCreated_v1': (event) => ({
    ...event,
    eventType: 'OrderCreated_v2',
    data: {
      ...event.data,
      currency: event.data.currency || 'PLN',  // nowe pole z domyslna wartoscia
      source: event.data.source || 'web'        // nowe pole
    }
  })
};

function upcastEvent(event) {
  const upcaster = upcasters[`${event.eventType}_v${event.schemaVersion}`];
  return upcaster ? upcaster(event) : event;
}
```

### Strategia 2: Weak schema

Nowe pola sa opcjonalne, stare eventy nie musza ich miec:

```javascript
apply(event) {
  if (event.eventType === 'OrderCreated') {
    this.id = event.data.orderId;
    this.total = event.data.total;
    this.currency = event.data.currency ?? 'PLN';  // domyslna wartosc
    this.source = event.data.source ?? 'unknown';
  }
}
```

### Strategia 3: Event migration

Jednorazowa migracja — przepisanie eventow do nowego formatu (kontrowersyjne, bo lamie niemiennosc eventow):

```javascript
// Tylko w wyjatkowych sytuacjach (np. RODO — usuwanie danych osobowych)
async function migrateEvents(streamId) {
  const events = await eventStore.getStream(streamId);
  const migrated = events.map(transformToV2);
  await eventStore.replaceStream(streamId, migrated);
}
```

## Integracja z CQRS

Event Sourcing naturalnie laczy sie z CQRS (Command Query Responsibility Segregation):

```
┌──────────────────────────────────────────────────┐
│                    CQRS + ES                      │
│                                                   │
│  Command Side          │   Query Side             │
│  (Write Model)         │   (Read Model)           │
│                        │                          │
│  Command               │                          │
│    ↓                   │                          │
│  Command Handler       │                          │
│    ↓                   │                          │
│  Aggregate             │                          │
│    ↓                   │                          │
│  Event Store ──────────┼──→ Event Handler         │
│  (zrodlo prawdy)       │      ↓                   │
│                        │    Projekcja              │
│                        │      ↓                   │
│                        │    Read DB ──→ Query API  │
└──────────────────────────────────────────────────┘
```

### Przeplyw Command → Event → Projection

```javascript
// 1. Command
class CreateOrderCommand {
  constructor(customerId, items) {
    this.customerId = customerId;
    this.items = items;
  }
}

// 2. Command Handler
async function handleCreateOrder(command) {
  const order = new Order();
  const event = order.create(command.customerId, command.items);
  await eventStore.append('order-' + order.id, event);
  await eventBus.publish(event);
}

// 3. Event Handler (aktualizuje projekcje)
eventBus.on('OrderCreated', async (event) => {
  await orderListProjection.handle(event);
  await salesDashboardProjection.handle(event);
  await searchIndexProjection.handle(event);
});

// 4. Query (czyta z projekcji)
async function getOrders(customerId) {
  return db.query(
    'SELECT * FROM orders_view WHERE customer_id = $1',
    [customerId]
  );
}
```

## Narzedzia i technologie

| Narzedzie | Opis |
|-----------|------|
| EventStoreDB | Dedykowana baza do Event Sourcing |
| Marten (.NET) | Event Store na PostgreSQL |
| Axon Framework | Framework CQRS/ES dla Java |
| Eventuous (.NET) | Lekki framework ES dla .NET |
| PostgreSQL + JSONB | DIY Event Store |

## Kiedy stosowac Event Sourcing?

### Stosuj gdy:
- Potrzebujesz pelnego audytu zmian (finanse, medycyna, prawo)
- Wymagasz mozliwosci odtworzenia stanu z przeszlosci
- Domena ma zlozony cykl zycia obiektow
- Potrzebujesz wielu widokow tych samych danych (projekcje)
- System wymaga temporal queries (zapytania o stan w danym momencie)

### Nie stosuj gdy:
- Proste CRUD bez potrzeby historii
- Maly projekt z prostym modelem danych
- Zespol nie ma doswiadczenia z ES (krzywa uczenia jest stroma)
- Wymagania dotyczace usuwania danych (RODO) sa kluczowe

## Kluczowe wnioski

1. **Event Store to zrodlo prawdy** — eventy sa niezmienne i trwale
2. **Snapshoty** rozwiazuja problem wydajnosci odtwarzania dlugich strumieni
3. **Projekcje** umozliwiaja wydajny odczyt zoptymalizowany pod konkretne zapytania
4. **Wersjonowanie eventow** jest nieuniknione — planuj je od poczatku
5. **CQRS + ES** to naturalne polaczenie — write model oparty na eventach, read model na projekcjach
6. **Rebuild projekcji** to supermocy — mozesz stworzyc nowy widok danych w kazdej chwili
