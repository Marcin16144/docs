# 06-05: Saga Pattern — transakcje rozproszone

## Problem transakcji rozproszonych

W monolicie transakcja bazodanowa obejmuje wszystkie operacje atomowo — albo wszystkie się udają, albo wszystkie są wycofywane (ACID). W mikroserwisach każdy serwis ma własną bazę danych. Nie ma jednej transakcji, która obejmuje wiele serwisów.

### Klasyczny problem

```
Zamówienie online — 3 serwisy, każdy z własną bazą:

1. Serwis zamówień  → Utwórz zamówienie (DB zamówień)
2. Serwis płatności → Pobierz płatność  (DB płatności)
3. Serwis magazynu  → Zarezerwuj towar  (DB magazynu)

Co jeśli krok 3 się nie powiedzie?
→ Zamówienie zostało utworzone ✓
→ Płatność została pobrana ✓
→ Brak towaru na magazynie ✗
→ System jest w niespójnym stanie!
```

### Dlaczego nie 2PC (Two-Phase Commit)?

Distributed 2PC (Two-Phase Commit) to klasyczne rozwiązanie transakcji rozproszonych, ale ma poważne wady w mikroserwisach:

- **Blokujący** — uczestnicy trzymają locki do czasu decyzji koordynatora
- **Single point of failure** — awaria koordynatora blokuje wszystkich
- **Ogranicza autonomię** — serwisy muszą uczestniczyć w protokole
- **Nie skaluje się** — rosnąca liczba uczestników dramatycznie obniża wydajność
- **Niedostępność** — wymaga, by wszyscy uczestnicy byli online

## Saga Pattern — rozwiązanie

Saga to sekwencja lokalnych transakcji, gdzie każda transakcja aktualizuje dane w jednym serwisie i publikuje zdarzenie lub wywołuje następny krok. Jeśli któryś krok się nie powiedzie, wykonywane są transakcje kompensujące w odwrotnej kolejności.

```
Saga "Złóż zamówienie":

Krok 1: Utwórz zamówienie (PENDING)
  ↓ sukces
Krok 2: Zarezerwuj środki
  ↓ sukces
Krok 3: Zarezerwuj towar
  ↓ BŁĄD!

Kompensacja (odwrotna kolejność):
  ← Krok 2: Zwolnij zarezerwowane środki
  ← Krok 1: Anuluj zamówienie (CANCELLED)
```

## Choreografia (Choreography Saga)

Każdy serwis reaguje na zdarzenia i publikuje nowe. Brak centralnego koordynatora — serwisy "tańczą" samodzielnie.

### Przepływ

```
[Serwis zamówień]
  → publikuje: OrderCreated
       ↓
[Serwis płatności]
  słucha: OrderCreated
  → rezerwuje środki
  → publikuje: PaymentReserved
       ↓
[Serwis magazynu]
  słucha: PaymentReserved
  → rezerwuje towar
  → publikuje: StockReserved
       ↓
[Serwis zamówień]
  słucha: StockReserved
  → potwierdza zamówienie (CONFIRMED)
  → publikuje: OrderConfirmed
```

### Przepływ kompensacji

```
[Serwis magazynu]
  słucha: PaymentReserved
  → brak towaru!
  → publikuje: StockReservationFailed
       ↓
[Serwis płatności]
  słucha: StockReservationFailed
  → zwolnij zarezerwowane środki
  → publikuje: PaymentReleased
       ↓
[Serwis zamówień]
  słucha: PaymentReleased
  → anuluj zamówienie (CANCELLED)
  → publikuje: OrderCancelled
```

### Implementacja (zdarzenia + handlery)

```python
# Serwis zamówień
class OrderService:
    def create_order(self, order_data):
        order = Order.create(status="PENDING", **order_data)
        event_bus.publish("OrderCreated", {
            "orderId": order.id,
            "userId": order.user_id,
            "total": order.total,
            "items": order.items
        })
        return order

    @event_handler("StockReserved")
    def on_stock_reserved(self, event):
        order = Order.find(event["orderId"])
        order.update(status="CONFIRMED")
        event_bus.publish("OrderConfirmed", {"orderId": order.id})

    @event_handler("PaymentReleased")
    def on_payment_released(self, event):
        order = Order.find(event["orderId"])
        order.update(status="CANCELLED")

# Serwis płatności
class PaymentService:
    @event_handler("OrderCreated")
    def on_order_created(self, event):
        try:
            payment = Payment.reserve(
                userId=event["userId"],
                amount=event["total"]
            )
            event_bus.publish("PaymentReserved", {
                "orderId": event["orderId"],
                "paymentId": payment.id
            })
        except InsufficientFundsError:
            event_bus.publish("PaymentFailed", {
                "orderId": event["orderId"],
                "reason": "insufficient_funds"
            })

    @event_handler("StockReservationFailed")
    def on_stock_failed(self, event):
        payment = Payment.find_by_order(event["orderId"])
        payment.release()
        event_bus.publish("PaymentReleased", {
            "orderId": event["orderId"]
        })
```

### Zalety choreografii

- Proste serwisy (reagują na zdarzenia)
- Brak single point of failure
- Luźne powiązanie — serwisy nie znają się nawzajem
- Łatwe dodawanie nowych kroków

### Wady choreografii

- Trudne śledzenie przepływu (logika rozproszona)
- Ryzyko cyklicznych zależności
- Brak centralnego widoku stanu sagi
- Testowanie integracyjne jest skomplikowane

## Orkiestracja (Orchestration Saga)

Centralny koordynator (orchestrator) zarządza przepływem — mówi każdemu serwisowi, co ma zrobić i reaguje na odpowiedzi.

### Przepływ

```
                [Orchestrator (Saga Manager)]
                    |           |           |
              (1) Create    (2) Reserve   (3) Reserve
              Order         Payment       Stock
                    |           |           |
           [Serwis zam.]  [Serwis płat.] [Serwis mag.]

Orchestrator utrzymuje stan sagi:
  Step 1: CREATE_ORDER  → SUCCESS
  Step 2: RESERVE_PAY   → SUCCESS
  Step 3: RESERVE_STOCK → SUCCESS / FAILED → kompensacja
```

### Implementacja orchestratora

```python
class OrderSagaOrchestrator:
    def __init__(self):
        self.steps = [
            SagaStep(
                name="create_order",
                action=self.create_order,
                compensation=self.cancel_order
            ),
            SagaStep(
                name="reserve_payment",
                action=self.reserve_payment,
                compensation=self.release_payment
            ),
            SagaStep(
                name="reserve_stock",
                action=self.reserve_stock,
                compensation=self.release_stock
            ),
            SagaStep(
                name="confirm_order",
                action=self.confirm_order,
                compensation=None  # ostatni krok, brak kompensacji
            )
        ]

    def execute(self, order_data):
        saga_state = SagaState(data=order_data)
        completed_steps = []

        for step in self.steps:
            try:
                result = step.action(saga_state)
                saga_state.update(step.name, result)
                completed_steps.append(step)
            except Exception as e:
                # Kompensacja w odwrotnej kolejności
                self.compensate(completed_steps, saga_state)
                raise SagaFailedError(
                    f"Saga failed at {step.name}: {e}")

        return saga_state

    def compensate(self, completed_steps, saga_state):
        for step in reversed(completed_steps):
            if step.compensation:
                try:
                    step.compensation(saga_state)
                except Exception as e:
                    # Log i retry — kompensacja MUSI się udać
                    log.error(f"Compensation failed: {step.name}: {e}")
                    self.schedule_retry(step, saga_state)

    # Akcje
    def create_order(self, state):
        return order_service.create(state.data)

    def reserve_payment(self, state):
        return payment_service.reserve(
            state.data["userId"], state.results["create_order"]["total"])

    def reserve_stock(self, state):
        return stock_service.reserve(state.data["items"])

    def confirm_order(self, state):
        return order_service.confirm(state.results["create_order"]["id"])

    # Kompensacje
    def cancel_order(self, state):
        order_service.cancel(state.results["create_order"]["id"])

    def release_payment(self, state):
        payment_service.release(state.results["reserve_payment"]["id"])

    def release_stock(self, state):
        stock_service.release(state.results["reserve_stock"]["reservationId"])
```

### Zalety orkiestracji

- Czytelny przepływ (cała logika w jednym miejscu)
- Łatwe testowanie (orchestrator jako jednostka)
- Centralny widok stanu sagi
- Prostsza obsługa błędów

### Wady orkiestracji

- Orchestrator to single point of failure
- Ryzyko "god service" (zbyt dużo logiki)
- Większe powiązanie (orchestrator zna wszystkie serwisy)

## Choreografia vs Orkiestracja

| Aspekt | Choreografia | Orkiestracja |
|--------|-------------|-------------|
| Koordynacja | Rozproszona (zdarzenia) | Centralna (orchestrator) |
| Powiązanie | Luźne | Tighter (orchestrator → serwisy) |
| Czytelność | Trudna (rozproszona logika) | Łatwa (jeden punkt) |
| Single point of failure | Brak | Orchestrator |
| Testowanie | Trudne | Łatwiejsze |
| Złożoność | Rośnie z liczbą kroków | Stała (w orchestratorze) |
| Idealne dla | 2-4 kroki, proste przepływy | 5+ kroków, złożone przepływy |

## Transakcje kompensujące

Kompensacja to **logiczne cofnięcie** efektu transakcji. Nie jest to rollback — dane mogły się zmienić od czasu oryginalnej operacji.

### Zasady projektowania kompensacji

```
Oryginalna transakcja         Kompensacja
─────────────────────         ────────────────────
Utwórz zamówienie           → Anuluj zamówienie (nie DELETE!)
Pobierz płatność            → Zwróć płatność (refund)
Zarezerwuj towar            → Zwolnij rezerwację
Wyślij email z potwierdzeniem → Wyślij email z anulowaniem
Dodaj punkty lojalnościowe  → Odejmij punkty
```

### Ważne zasady

1. **Kompensacja musi być idempotentna** — wielokrotne wywołanie daje ten sam efekt
2. **Kompensacja musi się w końcu udać** — retry do skutku
3. **Kolejność kompensacji** — odwrotna do kolejności wykonania
4. **Nie wszystko da się skompensować** — np. wysłany SMS, wydrukowany dokument
5. **Semantic undo, nie technical rollback** — stan świata mógł się zmienić

## Idempotentność w sagach

Saga może ponowić dowolny krok (po awarii, timeout, itp.). Każda operacja MUSI być idempotentna.

```python
# ŹLE — nie idempotentne
def reserve_payment(order_id, amount):
    payment = Payment.create(order_id=order_id, amount=amount)
    return payment
    # Ponowne wywołanie → druga płatność!

# DOBRZE — idempotentne
def reserve_payment(order_id, amount):
    existing = Payment.find_by_order(order_id)
    if existing:
        return existing  # już zarezerwowana
    payment = Payment.create(order_id=order_id, amount=amount)
    return payment
    # Ponowne wywołanie → zwraca istniejącą
```

### Techniki zapewnienia idempotentności

- **Idempotency key** — unikalny identyfikator operacji
- **Deduplication** — sprawdzenie czy operacja już wykonana
- **Conditional update** — UPDATE WHERE status = expected_status
- **Version/ETag** — optymistyczne blokowanie

## Frameworki do sag

### Temporal

Platforma do orkiestracji workflow, obsługująca długotrwałe procesy, retry, compensations.

```go
// Temporal — definicja workflow
func OrderSagaWorkflow(ctx workflow.Context, order OrderData) error {
    // Krok 1: Utwórz zamówienie
    var orderResult OrderResult
    err := workflow.ExecuteActivity(ctx,
        CreateOrderActivity, order).Get(ctx, &orderResult)
    if err != nil {
        return err
    }

    // Krok 2: Zarezerwuj płatność
    var paymentResult PaymentResult
    err = workflow.ExecuteActivity(ctx,
        ReservePaymentActivity, orderResult).Get(ctx, &paymentResult)
    if err != nil {
        // Kompensacja kroku 1
        workflow.ExecuteActivity(ctx, CancelOrderActivity, orderResult)
        return err
    }

    // Krok 3: Zarezerwuj stock
    err = workflow.ExecuteActivity(ctx,
        ReserveStockActivity, order.Items).Get(ctx, nil)
    if err != nil {
        // Kompensacja kroków 2 i 1
        workflow.ExecuteActivity(ctx, ReleasePaymentActivity, paymentResult)
        workflow.ExecuteActivity(ctx, CancelOrderActivity, orderResult)
        return err
    }

    return nil
}
```

### MassTransit (.NET)

Framework do komunikacji asynchronicznej z wbudowaną obsługą sag.

```csharp
// MassTransit — State Machine Saga
public class OrderSagaStateMachine :
    MassTransitStateMachine<OrderSagaState>
{
    public State OrderCreated { get; private set; }
    public State PaymentReserved { get; private set; }
    public State StockReserved { get; private set; }
    public State Completed { get; private set; }
    public State Failed { get; private set; }

    public OrderSagaStateMachine()
    {
        InstanceState(x => x.CurrentState);

        Event(() => OrderSubmitted, x => x.CorrelateById(
            ctx => ctx.Message.OrderId));

        Initially(
            When(OrderSubmitted)
                .Then(ctx => ctx.Saga.OrderId = ctx.Message.OrderId)
                .TransitionTo(OrderCreated)
                .Publish(ctx => new ReservePayment(ctx.Saga.OrderId))
        );

        During(OrderCreated,
            When(PaymentReservedEvent)
                .TransitionTo(PaymentReserved)
                .Publish(ctx => new ReserveStock(ctx.Saga.OrderId)),
            When(PaymentFailedEvent)
                .TransitionTo(Failed)
                .Publish(ctx => new CancelOrder(ctx.Saga.OrderId))
        );

        During(PaymentReserved,
            When(StockReservedEvent)
                .TransitionTo(Completed)
                .Publish(ctx => new ConfirmOrder(ctx.Saga.OrderId)),
            When(StockFailedEvent)
                .TransitionTo(Failed)
                .Publish(ctx => new ReleasePayment(ctx.Saga.OrderId))
        );
    }
}
```

## Dobre praktyki

1. **Zacznij od choreografii** — prostsze przypadki (2-4 kroki), migruj do orkiestracji gdy się komplikuje
2. **Każdy krok idempotentny** — saga MUSI bezpiecznie ponawiać dowolny krok
3. **Kompensacja musi się udać** — retry z backoff, alertowanie, ręczna interwencja jako ostateczność
4. **Monitoruj stan sag** — dashboard ze statusem każdej sagi
5. **Timeout na każdym kroku** — nie czekaj w nieskończoność
6. **Correlation ID** — propaguj przez wszystkie kroki dla debugowania
7. **Testuj scenariusze awarii** — nie tylko happy path, ale każdą możliwą kombinację błędów
8. **Unikaj sag w sagach** — zagnieżdżone sagi to koszmar
