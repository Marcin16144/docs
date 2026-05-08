# 05-04: Domain Events i Domain Services

## Domain Events — zdarzenia domenowe

Domain Event to obiekt reprezentujący fakt, który wydarzył się w domenie biznesowej. Jest zapisany w czasie przeszłym, bo opisuje coś, co już się stało — nie żądanie, nie komendę, lecz nieodwracalny fakt.

### Cechy Domain Events

- **Czas przeszły** — OrderPlaced, PaymentReceived, ShipmentDispatched
- **Niemutowalne** — po utworzeniu nie można zmienić (fakt się nie zmienia)
- **Samowystarczalne** — zawierają wszystkie dane potrzebne handlerowi
- **Domenowe** — opisują zdarzenia biznesowe, nie techniczne

### Anatomia Domain Event

```typescript
// Bazowy interfejs
interface DomainEvent {
    readonly eventId: string;
    readonly occurredAt: Date;
    readonly aggregateId: string;
    readonly eventType: string;
}

// Konkretne zdarzenie
class OrderPlacedEvent implements DomainEvent {
    readonly eventType = 'Order.Placed';
    readonly eventId: string;
    readonly occurredAt: Date;

    constructor(
        readonly aggregateId: string,    // OrderId
        readonly customerId: string,
        readonly items: ReadonlyArray<{
            productId: string;
            quantity: number;
            unitPrice: number;
        }>,
        readonly totalAmount: number,
        readonly currency: string,
        readonly shippingAddress: {
            street: string;
            city: string;
            postalCode: string;
        },
    ) {
        this.eventId = crypto.randomUUID();
        this.occurredAt = new Date();
    }
}

class OrderCancelledEvent implements DomainEvent {
    readonly eventType = 'Order.Cancelled';
    readonly eventId = crypto.randomUUID();
    readonly occurredAt = new Date();

    constructor(
        readonly aggregateId: string,
        readonly reason: string,
        readonly cancelledBy: string, // 'customer' | 'system' | 'admin'
        readonly refundAmount: number,
    ) {}
}
```

### Emitowanie zdarzeń z agregatu

Agregat zbiera zdarzenia wewnętrznie, a infrastruktura je publikuje po zapisaniu agregatu do bazy.

```typescript
abstract class AggregateRoot {
    private _domainEvents: DomainEvent[] = [];

    protected addDomainEvent(event: DomainEvent): void {
        this._domainEvents.push(event);
    }

    pullDomainEvents(): DomainEvent[] {
        const events = [...this._domainEvents];
        this._domainEvents = [];
        return events;
    }
}

class Order extends AggregateRoot {
    private _id: OrderId;
    private _status: OrderStatus;
    private _items: OrderItem[];

    place(): void {
        if (this._items.length === 0) {
            throw new EmptyOrderError(this._id);
        }
        this._status = OrderStatus.Placed;

        // Zdarzenie dodane do kolekcji — jeszcze nie opublikowane
        this.addDomainEvent(new OrderPlacedEvent(
            this._id.value,
            this._customerId.value,
            this._items.map(i => ({
                productId: i.productId.value,
                quantity: i.quantity.value,
                unitPrice: i.unitPrice.amount,
            })),
            this.totalAmount.amount,
            this.totalAmount.currency,
            this._shippingAddress.toPlain(),
        ));
    }

    cancel(reason: CancellationReason): void {
        if (this._status === OrderStatus.Shipped) {
            throw new CannotCancelShippedOrderError(this._id);
        }
        this._status = OrderStatus.Cancelled;

        this.addDomainEvent(new OrderCancelledEvent(
            this._id.value,
            reason.description,
            reason.initiator,
            this.totalAmount.amount,
        ));
    }
}
```

### Publikowanie po zapisie

```typescript
class OrderApplicationService {
    constructor(
        private orderRepo: OrderRepository,
        private eventPublisher: DomainEventPublisher,
    ) {}

    async placeOrder(command: PlaceOrderCommand): Promise<OrderId> {
        const order = Order.create(command);
        order.place();

        // 1. Zapisz agregat
        await this.orderRepo.save(order);

        // 2. Opublikuj zebrane zdarzenia
        const events = order.pullDomainEvents();
        for (const event of events) {
            await this.eventPublisher.publish(event);
        }

        return order.id;
    }
}
```

## Event Handlers — reagowanie na zdarzenia

Handlery to niezależne komponenty, które reagują na zdarzenia. Każdy handler ma jedną odpowiedzialność.

```typescript
interface DomainEventHandler<T extends DomainEvent> {
    handle(event: T): Promise<void>;
}

// Handler: wyślij e-mail z potwierdzeniem
class SendOrderConfirmationEmail
    implements DomainEventHandler<OrderPlacedEvent> {

    constructor(private emailService: EmailService) {}

    async handle(event: OrderPlacedEvent): Promise<void> {
        await this.emailService.send({
            to: event.customerId,
            template: 'order-confirmation',
            data: {
                orderId: event.aggregateId,
                items: event.items,
                total: `${event.totalAmount} ${event.currency}`,
            },
        });
    }
}

// Handler: zarezerwuj produkty w magazynie
class ReserveInventoryOnOrderPlaced
    implements DomainEventHandler<OrderPlacedEvent> {

    constructor(private inventoryService: InventoryService) {}

    async handle(event: OrderPlacedEvent): Promise<void> {
        for (const item of event.items) {
            await this.inventoryService.reserve(
                item.productId,
                item.quantity,
                event.aggregateId, // reservationReference
            );
        }
    }
}

// Handler: nalicz punkty lojalnościowe
class AwardLoyaltyPointsOnOrderPlaced
    implements DomainEventHandler<OrderPlacedEvent> {

    constructor(private loyaltyService: LoyaltyService) {}

    async handle(event: OrderPlacedEvent): Promise<void> {
        const points = Math.floor(event.totalAmount);
        await this.loyaltyService.awardPoints(
            event.customerId, points, `Order ${event.aggregateId}`
        );
    }
}

// Handler: zwolnij rezerwację po anulowaniu
class ReleaseInventoryOnOrderCancelled
    implements DomainEventHandler<OrderCancelledEvent> {

    constructor(private inventoryService: InventoryService) {}

    async handle(event: OrderCancelledEvent): Promise<void> {
        await this.inventoryService.releaseReservation(
            event.aggregateId
        );
    }
}
```

### Rejestracja handlerów

```typescript
class DomainEventPublisher {
    private handlers = new Map<string, DomainEventHandler<any>[]>();

    register<T extends DomainEvent>(
        eventType: string,
        handler: DomainEventHandler<T>,
    ): void {
        const existing = this.handlers.get(eventType) || [];
        existing.push(handler);
        this.handlers.set(eventType, existing);
    }

    async publish(event: DomainEvent): Promise<void> {
        const handlers = this.handlers.get(event.eventType) || [];
        for (const handler of handlers) {
            try {
                await handler.handle(event);
            } catch (error) {
                // Loguj błąd, ale nie blokuj pozostałych handlerów
                console.error(
                    `Handler error for ${event.eventType}:`, error
                );
            }
        }
    }
}

// Konfiguracja
const publisher = new DomainEventPublisher();
publisher.register('Order.Placed', new SendOrderConfirmationEmail(emailService));
publisher.register('Order.Placed', new ReserveInventoryOnOrderPlaced(inventory));
publisher.register('Order.Placed', new AwardLoyaltyPointsOnOrderPlaced(loyalty));
publisher.register('Order.Cancelled', new ReleaseInventoryOnOrderCancelled(inventory));
```

## Saga — koordynacja procesów

Saga koordynuje proces biznesowy rozciągnięty na wiele agregatów, reagując na zdarzenia i wydając komendy. Zarządza też kompensacją w razie błędu.

```typescript
class OrderFulfillmentSaga {
    private state: SagaState = 'started';

    async onOrderPlaced(event: OrderPlacedEvent): Promise<void> {
        this.state = 'awaiting_payment';
        await this.paymentService.requestPayment(
            event.aggregateId,
            event.totalAmount,
            event.currency,
        );
    }

    async onPaymentReceived(event: PaymentReceivedEvent): Promise<void> {
        this.state = 'awaiting_shipment';
        await this.warehouseService.prepareShipment(
            event.orderId,
        );
    }

    async onPaymentFailed(event: PaymentFailedEvent): Promise<void> {
        this.state = 'compensating';
        // Kompensacja: zwolnij rezerwację, anuluj zamówienie
        await this.inventoryService.releaseReservation(event.orderId);
        await this.orderService.cancelOrder(
            event.orderId,
            CancellationReason.paymentFailed(event.reason),
        );
        this.state = 'compensated';
    }

    async onShipmentDispatched(event: ShipmentDispatchedEvent): Promise<void> {
        this.state = 'completed';
        await this.orderService.markAsShipped(
            event.orderId,
            event.trackingNumber,
        );
    }

    async onShipmentFailed(event: ShipmentFailedEvent): Promise<void> {
        this.state = 'compensating';
        // Kompensacja: zwróć pieniądze
        await this.paymentService.refund(event.orderId);
        await this.orderService.cancelOrder(
            event.orderId,
            CancellationReason.shipmentFailed(event.reason),
        );
        this.state = 'compensated';
    }
}
```

## Domain Services — operacje bez naturalnego domu

Domain Service to operacja domenowa, która nie należy naturalnie do żadnej encji ani Value Objectu. Jest bezstanowa i operuje na wielu obiektach domenowych.

### Kiedy potrzebujesz Domain Service?

- Operacja wymaga danych z wielu agregatów
- Logika nie pasuje do żadnego konkretnego agregatu
- Operacja implementuje regułę biznesową, która przekracza granice jednego agregatu

### Kiedy NIE tworzyć Domain Service?

- Logika pasuje do istniejącej encji — umieść ją tam
- To operacja techniczna (wysyłka e-maila, zapis do bazy) — to infrastructure service
- To orkiestracja/koordynacja — to application service

```typescript
// Domain Service: kalkulacja ceny z wieloma regułami
class OrderPricingService {
    calculateFinalPrice(
        items: OrderItem[],
        customer: Customer,
        promotions: Promotion[],
        shippingOption: ShippingOption,
    ): PriceBreakdown {
        // Suma pozycji
        const subtotal = items.reduce(
            (sum, item) => sum.add(item.lineTotal()),
            Money.zero('PLN'),
        );

        // Rabat klienta (zależy od segmentu klienta)
        const customerDiscount = customer.tier.calculateDiscount(subtotal);

        // Promocje (zależą od produktów i aktywnych kampanii)
        const promoDiscount = promotions.reduce(
            (total, promo) => total.add(promo.calculateDiscount(items)),
            Money.zero('PLN'),
        );

        // Najwyższy rabat wygrywa (reguła biznesowa)
        const discount = customerDiscount.isGreaterThan(promoDiscount)
            ? customerDiscount
            : promoDiscount;

        // Koszt wysyłki (darmowa powyżej progu)
        const shipping = subtotal.isGreaterThan(Money.of(200, 'PLN'))
            ? Money.zero('PLN')
            : shippingOption.cost;

        // Podatek
        const taxableAmount = subtotal.subtract(discount).add(shipping);
        const tax = taxableAmount.multiply(0.23);

        return new PriceBreakdown({
            subtotal,
            discount,
            shipping,
            tax,
            total: taxableAmount.add(tax),
        });
    }
}
```

### Domain Service: transfer między kontami

```typescript
// Transfer wymaga dwóch agregatów — nie pasuje do żadnego z nich
class FundsTransferService {
    transfer(
        source: BankAccount,
        destination: BankAccount,
        amount: Money,
        purpose: TransferPurpose,
    ): TransferResult {
        // Reguła biznesowa: limit dzienny
        if (source.wouldExceedDailyLimit(amount)) {
            throw new DailyTransferLimitExceededError(
                source.id, source.dailyLimit
            );
        }

        // Reguła biznesowa: waluta
        if (!source.supportsCurrency(amount.currency)) {
            throw new UnsupportedCurrencyError(source.id, amount.currency);
        }

        // Operacja na dwóch agregatach
        source.debit(amount, purpose);
        destination.credit(amount, purpose);

        return TransferResult.successful(
            source.id, destination.id, amount, purpose
        );
    }
}
```

### Domain Service vs Application Service vs Infrastructure Service

| Typ serwisu | Odpowiedzialność | Zna domenę? | Przykłady |
|-------------|-----------------|------------|-----------|
| Domain Service | Reguły biznesowe cross-agregatowe | Tak | FundsTransferService, PricingService |
| Application Service | Orkiestracja, transakcje, uprawnienia | Częściowo | PlaceOrderUseCase, RegisterUserUseCase |
| Infrastructure Service | Komunikacja z zewnętrznym światem | Nie | EmailSender, FileStorage, PaymentGateway |

```typescript
// Application Service — orkiestracja, NIE logika biznesowa
class PlaceOrderUseCase {
    constructor(
        private orderRepo: OrderRepository,
        private customerRepo: CustomerRepository,
        private pricingService: OrderPricingService,  // Domain Service
        private eventPublisher: DomainEventPublisher,
    ) {}

    async execute(command: PlaceOrderCommand): Promise<OrderId> {
        // 1. Pobierz dane
        const customer = await this.customerRepo.findById(command.customerId);
        if (!customer) throw new CustomerNotFoundError(command.customerId);

        // 2. Deleguj logikę biznesową do domeny
        const pricing = this.pricingService.calculateFinalPrice(
            command.items, customer, command.promotions, command.shipping,
        );

        // 3. Utwórz agregat
        const order = Order.create({
            id: this.orderRepo.nextId(),
            customerId: customer.id,
            items: command.items,
            pricing,
        });
        order.place();

        // 4. Zapisz i opublikuj zdarzenia
        await this.orderRepo.save(order);
        for (const event of order.pullDomainEvents()) {
            await this.eventPublisher.publish(event);
        }

        return order.id;
    }
}
```

## Kiedy używać Domain Events vs bezpośrednich wywołań?

| Kryterium | Bezpośrednie wywołanie | Domain Event |
|-----------|----------------------|-------------|
| Spójność | Natychmiastowa (strong consistency) | Ostateczna (eventual consistency) |
| Coupling | Wyższy (bezpośrednia zależność) | Niższy (przez zdarzenia) |
| Debugowanie | Łatwiejsze (call stack) | Trudniejsze (asynchroniczność) |
| Skalowalność | Ograniczona | Wysoka (niezależne handlery) |
| Stosuj gdy | Logika w ramach jednego agregatu | Reakcje cross-agregatowe, powiadomienia |

## Praktyczne wskazówki

- Domain Events powinny być samowystarczalne — handler nie powinien musieć odpytywać o dodatkowe dane
- Nie nadużywaj Domain Services — jeśli logika pasuje do encji, umieść ją tam
- Application Service nie powinien zawierać reguł biznesowych — deleguj do domeny
- Saga potrzebuje persystencji stanu — zapisuj stan sagi w bazie, żeby przetrwała restart
- Zdarzenia powinny być wersjonowane — zmiany w strukturze zdarzenia mogą złamać istniejące handlery
- Rozważ Event Store zamiast zwykłej bazy — pełna historia zdarzeń jako źródło prawdy
