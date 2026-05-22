# 04-05: Wzorce behawioralne — Observer, Strategy, Command

## Wzorce behawioralne

Wzorce behawioralne dotyczą algorytmów i przypisywania odpowiedzialności między obiektami. Definiują nie tylko same obiekty, ale też sposób komunikacji między nimi. Trzy najważniejsze to Observer, Strategy i Command.

## Observer — systemy zdarzeń

### Problem

Obiekt zmienia swój stan i inne obiekty muszą na to zareagować, ale nie chcesz tworzyć twardych zależności między nimi. Na przykład: złożenie zamówienia powinno wywołać wysyłkę e-maila, aktualizację stanów magazynowych i naliczenie punktów lojalnościowych — ale klasa Order nie powinna znać tych wszystkich serwisów.

### Rozwiązanie

Observer definiuje mechanizm subskrypcji, w którym obiekty (obserwatorzy) rejestrują się na powiadomienia o zdarzeniach emitowanych przez inny obiekt (subiekt).

```typescript
// Interfejs zdarzeń
interface DomainEvent {
    readonly type: string;
    readonly occurredAt: Date;
}

class OrderPlacedEvent implements DomainEvent {
    readonly type = 'order.placed';
    readonly occurredAt = new Date();
    constructor(
        readonly orderId: string,
        readonly customerId: string,
        readonly totalAmount: number,
        readonly items: OrderItem[],
    ) {}
}

// Event Emitter — centralny punkt subskrypcji
type EventHandler<T extends DomainEvent> = (event: T) => Promise<void>;

class EventBus {
    private handlers = new Map<string, EventHandler<any>[]>();

    on<T extends DomainEvent>(eventType: string, handler: EventHandler<T>): void {
        const existing = this.handlers.get(eventType) || [];
        existing.push(handler);
        this.handlers.set(eventType, existing);
    }

    off(eventType: string, handler: EventHandler<any>): void {
        const existing = this.handlers.get(eventType) || [];
        this.handlers.set(
            eventType,
            existing.filter(h => h !== handler)
        );
    }

    async emit<T extends DomainEvent>(event: T): Promise<void> {
        const handlers = this.handlers.get(event.type) || [];
        await Promise.all(handlers.map(handler => handler(event)));
    }
}
```

### Rejestracja obserwatorów

```typescript
const eventBus = new EventBus();

// Każdy handler to niezależny obserwator
eventBus.on<OrderPlacedEvent>('order.placed', async (event) => {
    await emailService.sendOrderConfirmation(
        event.customerId, event.orderId
    );
});

eventBus.on<OrderPlacedEvent>('order.placed', async (event) => {
    for (const item of event.items) {
        await inventoryService.decrementStock(item.productId, item.quantity);
    }
});

eventBus.on<OrderPlacedEvent>('order.placed', async (event) => {
    await loyaltyService.addPoints(
        event.customerId,
        Math.floor(event.totalAmount)
    );
});

// Emisja zdarzenia — Order nie wie kto nasłuchuje
class OrderService {
    constructor(private eventBus: EventBus) {}

    async placeOrder(request: PlaceOrderRequest): Promise<Order> {
        const order = Order.create(request);
        await this.orderRepository.save(order);

        await this.eventBus.emit(new OrderPlacedEvent(
            order.id,
            order.customerId,
            order.totalAmount,
            order.items,
        ));

        return order;
    }
}
```

### Typowane zdarzenia z discriminated unions

```typescript
type AppEvent =
    | { type: 'order.placed'; orderId: string; customerId: string }
    | { type: 'order.shipped'; orderId: string; trackingNumber: string }
    | { type: 'payment.received'; orderId: string; amount: number }
    | { type: 'payment.failed'; orderId: string; reason: string };

class TypedEventBus {
    private handlers = new Map<string, Function[]>();

    on<T extends AppEvent['type']>(
        type: T,
        handler: (event: Extract<AppEvent, { type: T }>) => Promise<void>
    ): void {
        const existing = this.handlers.get(type) || [];
        existing.push(handler);
        this.handlers.set(type, existing);
    }

    async emit(event: AppEvent): Promise<void> {
        const handlers = this.handlers.get(event.type) || [];
        await Promise.all(handlers.map(h => h(event)));
    }
}
```

## Strategy — wymienne algorytmy

### Problem

Masz operację, która może być realizowana na kilka sposobów, a wybór sposobu zależy od kontekstu. Na przykład: naliczanie rabatów, sortowanie danych, walidacja formularzy — różne strategie dla różnych sytuacji.

### Rozwiązanie

Strategy definiuje rodzinę algorytmów, enkapsuluje każdy z nich i czyni je wymiennymi. Klient wybiera strategię w runtime.

```typescript
// Interfejs strategii
interface PricingStrategy {
    calculateDiscount(order: Order): Money;
    description(): string;
}

// Strategia: stały procent
class PercentageDiscount implements PricingStrategy {
    constructor(private percent: number) {}

    calculateDiscount(order: Order): Money {
        return order.subtotal.multiply(this.percent / 100);
    }

    description(): string {
        return `${this.percent}% rabatu`;
    }
}

// Strategia: kwota od progu
class ThresholdDiscount implements PricingStrategy {
    constructor(
        private threshold: Money,
        private discountAmount: Money,
    ) {}

    calculateDiscount(order: Order): Money {
        if (order.subtotal.isGreaterThan(this.threshold)) {
            return this.discountAmount;
        }
        return Money.zero(order.subtotal.currency);
    }

    description(): string {
        return `${this.discountAmount} rabatu przy zamowieniu powyzej ${this.threshold}`;
    }
}

// Strategia: progresywna (im wiecej, tym taniej)
class TieredDiscount implements PricingStrategy {
    private tiers = [
        { minAmount: 500, percent: 5 },
        { minAmount: 1000, percent: 10 },
        { minAmount: 2000, percent: 15 },
    ];

    calculateDiscount(order: Order): Money {
        const applicable = this.tiers
            .filter(t => order.subtotal.amount >= t.minAmount)
            .sort((a, b) => b.percent - a.percent)[0];

        if (!applicable) return Money.zero(order.subtotal.currency);
        return order.subtotal.multiply(applicable.percent / 100);
    }

    description(): string {
        return 'Rabat progresywny';
    }
}
```

### Wybór strategii w runtime

```typescript
class PricingService {
    private strategies = new Map<string, PricingStrategy>();

    registerStrategy(name: string, strategy: PricingStrategy): void {
        this.strategies.set(name, strategy);
    }

    calculatePrice(order: Order, strategyName: string): PriceBreakdown {
        const strategy = this.strategies.get(strategyName);
        if (!strategy) throw new Error(`Nieznana strategia: ${strategyName}`);

        const discount = strategy.calculateDiscount(order);
        return {
            subtotal: order.subtotal,
            discount,
            total: order.subtotal.subtract(discount),
            appliedStrategy: strategy.description(),
        };
    }
}

// Konfiguracja
const pricingService = new PricingService();
pricingService.registerStrategy('vip', new PercentageDiscount(20));
pricingService.registerStrategy('seasonal', new PercentageDiscount(10));
pricingService.registerStrategy('bulk', new TieredDiscount());
pricingService.registerStrategy('promo50',
    new ThresholdDiscount(Money.of(200, 'PLN'), Money.of(50, 'PLN'))
);

// Użycie — strategia wybierana dynamicznie
const price = pricingService.calculatePrice(order, customer.discountTier);
```

### Strategy vs if/else

```typescript
// Anty-wzorzec: rozrastający się if/else
function calculateDiscount(order: Order, type: string): number {
    if (type === 'vip') return order.total * 0.2;
    else if (type === 'seasonal') return order.total * 0.1;
    else if (type === 'bulk' && order.total > 2000) return order.total * 0.15;
    else if (type === 'bulk' && order.total > 1000) return order.total * 0.1;
    // ... i tak dalej, rośnie z każdym nowym typem
    return 0;
}

// Ze Strategy: nowy typ = nowa klasa, zero zmian w istniejącym kodzie
pricingService.registerStrategy('employee', new PercentageDiscount(30));
```

## Command — undo/redo i kolejkowanie

### Problem

Chcesz enkapsulować operację jako obiekt, żeby móc ją kolejkować, cofać, ponawiać, logować lub wykonywać asynchronicznie. Na przykład: edytor tekstu z historią zmian, system workflow z krokami do cofnięcia.

### Rozwiązanie

Command enkapsuluje żądanie jako obiekt z metodami `execute()` i opcjonalnie `undo()`.

```typescript
// Interfejs Command
interface Command {
    execute(): Promise<void>;
    undo(): Promise<void>;
    describe(): string;
}

// Konkretne komendy
class AddItemToCartCommand implements Command {
    private previousQuantity: number = 0;

    constructor(
        private cart: ShoppingCart,
        private productId: string,
        private quantity: number,
    ) {}

    async execute(): Promise<void> {
        this.previousQuantity = this.cart.getQuantity(this.productId);
        await this.cart.addItem(this.productId, this.quantity);
    }

    async undo(): Promise<void> {
        await this.cart.setItemQuantity(this.productId, this.previousQuantity);
    }

    describe(): string {
        return `Dodaj ${this.quantity}x produkt ${this.productId}`;
    }
}

class ApplyDiscountCommand implements Command {
    private previousDiscount: string | null = null;

    constructor(
        private cart: ShoppingCart,
        private discountCode: string,
    ) {}

    async execute(): Promise<void> {
        this.previousDiscount = this.cart.getAppliedDiscount();
        await this.cart.applyDiscount(this.discountCode);
    }

    async undo(): Promise<void> {
        if (this.previousDiscount) {
            await this.cart.applyDiscount(this.previousDiscount);
        } else {
            await this.cart.removeDiscount();
        }
    }

    describe(): string {
        return `Zastosuj kod rabatowy: ${this.discountCode}`;
    }
}
```

### Historia komend z undo/redo

```typescript
class CommandHistory {
    private executed: Command[] = [];
    private undone: Command[] = [];

    async execute(command: Command): Promise<void> {
        await command.execute();
        this.executed.push(command);
        this.undone = []; // Nowa akcja czyści redo stack
    }

    async undo(): Promise<void> {
        const command = this.executed.pop();
        if (!command) throw new Error('Brak akcji do cofniecia');
        await command.undo();
        this.undone.push(command);
    }

    async redo(): Promise<void> {
        const command = this.undone.pop();
        if (!command) throw new Error('Brak akcji do powtorzenia');
        await command.execute();
        this.executed.push(command);
    }

    getHistory(): string[] {
        return this.executed.map(cmd => cmd.describe());
    }

    canUndo(): boolean { return this.executed.length > 0; }
    canRedo(): boolean { return this.undone.length > 0; }
}
```

### Kolejkowanie komend

Command doskonale nadaje się do kolejkowania operacji — komendy mogą być serializowane i wykonywane asynchronicznie.

```typescript
class CommandQueue {
    private queue: Command[] = [];
    private processing = false;

    enqueue(command: Command): void {
        this.queue.push(command);
        if (!this.processing) {
            this.processQueue();
        }
    }

    private async processQueue(): Promise<void> {
        this.processing = true;
        while (this.queue.length > 0) {
            const command = this.queue.shift()!;
            try {
                await command.execute();
                console.log(`Wykonano: ${command.describe()}`);
            } catch (error) {
                console.error(`Blad: ${command.describe()}`, error);
                // Opcjonalnie: retry, dead letter queue, etc.
            }
        }
        this.processing = false;
    }
}
```

## Porównanie trzech wzorców

| Cecha | Observer | Strategy | Command |
|-------|----------|----------|---------|
| Cel | Powiadamianie o zdarzeniach | Wymienne algorytmy | Enkapsulacja operacji |
| Kierunek | 1-do-wielu (broadcast) | 1-do-1 (wybór) | Sekwencyjny (queue/stack) |
| Coupling | Luźny (przez zdarzenia) | Luźny (przez interfejs) | Luźny (przez obiekt) |
| Typowy use case | Event bus, reaktywne UI | Polityki cenowe, walidacja | Undo/redo, task queue |
| Czas wykonania | Natychmiast po emisji | Natychmiast po wywołaniu | Odłożony (opcjonalnie) |

## Łączenie wzorców

W praktyce wzorce często się łączą. Na przykład: Command emituje zdarzenie Observer po wykonaniu, a Observer wybiera strategię Strategy na podstawie typu zdarzenia.

```typescript
// Command emituje zdarzenie po wykonaniu
class PlaceOrderCommand implements Command {
    async execute(): Promise<void> {
        const order = await this.orderService.create(this.request);
        // Command + Observer
        await this.eventBus.emit(new OrderPlacedEvent(order));
    }
}

// Observer używa Strategy do wyboru obsługi
eventBus.on<OrderPlacedEvent>('order.placed', async (event) => {
    // Observer + Strategy
    const strategy = shippingStrategies.get(event.shippingType);
    await strategy.scheduleDelivery(event.orderId);
});
```
