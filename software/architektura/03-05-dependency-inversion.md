# 03-05: Dependency Inversion Principle (DIP) — Zasada odwrócenia zależności

## Czym jest DIP?

Zasada odwrócenia zależności składa się z dwóch reguł:

1. **Moduły wysokiego poziomu nie powinny zależeć od modułów niskiego poziomu** — oba powinny zależeć od abstrakcji
2. **Abstrakcje nie powinny zależeć od szczegółów** — szczegóły powinny zależeć od abstrakcji

"Odwrócenie" polega na tym, że tradycyjnie moduły wysokiego poziomu (logika biznesowa) zależały od modułów niskiego poziomu (baza danych, sieć, system plików). DIP odwraca ten kierunek — to szczegóły implementacyjne dostosowują się do abstrakcji definiowanych przez logikę biznesową.

## Dlaczego to ważne?

- Logika biznesowa staje się niezależna od infrastruktury
- Łatwa podmiana implementacji (np. zmiana bazy danych)
- Testowalność — możliwość podstawienia mocków
- Równoległa praca zespołów — jeden pracuje nad logiką, drugi nad infrastrukturą

## Przykład 1: Serwis zamówień — złe podejście

```typescript
// ZLE — modul wysokiego poziomu zalezy bezposrednio od szczegolow

class MySQLDatabase {
    query(sql: string): any[] {
        // polaczenie z MySQL, wykonanie zapytania
    }
    execute(sql: string): void {
        // wykonanie polecenia SQL
    }
}

class SmtpEmailSender {
    send(to: string, subject: string, body: string): void {
        // polaczenie SMTP, wyslanie emaila
    }
}

class StripePaymentGateway {
    charge(cardToken: string, amount: number): PaymentResult {
        // wywolanie Stripe API
    }
}

// OrderService BEZPOSREDNIO zalezy od MySQL, SMTP, Stripe
class OrderService {
    private db = new MySQLDatabase();
    private mailer = new SmtpEmailSender();
    private payments = new StripePaymentGateway();

    placeOrder(order: Order): void {
        // logika biznesowa powiazana z infrastruktura
        this.payments.charge(order.cardToken, order.total);
        this.db.execute(`INSERT INTO orders VALUES (...)`);
        this.mailer.send(order.email, 'Zamowienie', '...');
    }
}
```

Problemy:
- Nie można przetestować `OrderService` bez MySQL, SMTP i Stripe
- Zmiana na PostgreSQL wymaga modyfikacji `OrderService`
- Zmiana z SMTP na SendGrid wymaga modyfikacji `OrderService`

## Przykład 1: Po zastosowaniu DIP

```typescript
// DOBRZE — abstrakcje definiowane przez modul wysokiego poziomu

// Abstrakcje (interfejsy) naleza do warstwy biznesowej
interface OrderRepository {
    save(order: Order): void;
    findById(id: string): Order;
}

interface PaymentGateway {
    charge(amount: Money, paymentMethod: PaymentMethod): PaymentResult;
}

interface NotificationService {
    sendOrderConfirmation(order: Order): void;
}

// Modul wysokiego poziomu zalezy TYLKO od abstrakcji
class OrderService {
    constructor(
        private orders: OrderRepository,
        private payments: PaymentGateway,
        private notifications: NotificationService
    ) {}

    placeOrder(order: Order): OrderResult {
        const paymentResult = this.payments.charge(
            order.total, order.paymentMethod
        );

        if (!paymentResult.success) {
            return OrderResult.paymentFailed(paymentResult.error);
        }

        order.markAsPaid(paymentResult.transactionId);
        this.orders.save(order);
        this.notifications.sendOrderConfirmation(order);

        return OrderResult.success(order);
    }
}

// Szczegoly implementacyjne zaleza od abstrakcji
class PostgresOrderRepository implements OrderRepository {
    constructor(private pool: Pool) {}

    save(order: Order): void {
        this.pool.query(
            'INSERT INTO orders (id, total, status) VALUES ($1, $2, $3)',
            [order.id, order.total.amount, order.status]
        );
    }

    findById(id: string): Order {
        const row = this.pool.query(
            'SELECT * FROM orders WHERE id = $1', [id]
        );
        return this.mapToOrder(row);
    }
}

class StripePaymentGateway implements PaymentGateway {
    charge(amount: Money, method: PaymentMethod): PaymentResult {
        const result = stripe.charges.create({
            amount: amount.toCents(),
            currency: amount.currency,
            source: method.token
        });
        return PaymentResult.from(result);
    }
}

class EmailNotificationService implements NotificationService {
    constructor(private mailer: Mailer) {}

    sendOrderConfirmation(order: Order): void {
        this.mailer.send({
            to: order.customerEmail,
            subject: `Zamowienie #${order.id}`,
            template: 'order-confirmation',
            data: order
        });
    }
}
```

## Dependency Injection — mechanizm dostarczania zależności

DIP to zasada projektowa, a Dependency Injection (DI) to technika jej realizacji.

### Trzy formy wstrzykiwania

```typescript
// 1. Constructor Injection (najczesciej stosowana)
class OrderService {
    constructor(
        private repo: OrderRepository,
        private payments: PaymentGateway
    ) {}
}

// 2. Method Injection (gdy zaleznosc jest potrzebna w jednej metodzie)
class ReportGenerator {
    generate(data: ReportData, formatter: ReportFormatter): string {
        return formatter.format(data);
    }
}

// 3. Property Injection (rzadko — trudne do kontrolowania)
class NotificationService {
    logger?: Logger;

    notify(message: string): void {
        this.logger?.log(`Wysylanie: ${message}`);
        // ...
    }
}
```

## Przykład 2: DI Container (Python)

```python
# Prosty kontener DI

class Container:
    def __init__(self):
        self._factories = {}
        self._singletons = {}

    def register(self, interface, factory, singleton=False):
        self._factories[interface] = (factory, singleton)

    def resolve(self, interface):
        if interface in self._singletons:
            return self._singletons[interface]

        factory, is_singleton = self._factories[interface]
        instance = factory(self)

        if is_singleton:
            self._singletons[interface] = instance

        return instance


# Rejestracja zaleznosci
container = Container()

# Infrastruktura
container.register(
    OrderRepository,
    lambda c: PostgresOrderRepository(db_pool),
    singleton=True
)

container.register(
    PaymentGateway,
    lambda c: StripePaymentGateway(stripe_api_key),
    singleton=True
)

container.register(
    NotificationService,
    lambda c: EmailNotificationService(smtp_config),
    singleton=True
)

# Serwis biznesowy
container.register(
    OrderService,
    lambda c: OrderService(
        c.resolve(OrderRepository),
        c.resolve(PaymentGateway),
        c.resolve(NotificationService)
    )
)

# Uzycie
order_service = container.resolve(OrderService)
order_service.place_order(order)
```

## Przykład 3: Architektura warstwowa z DIP

```
BEZ DIP — zaleznosci plyna w dol:
┌─────────────────────┐
│   Presentation      │ ──→ zalezy od
├─────────────────────┤
│   Business Logic    │ ──→ zalezy od
├─────────────────────┤
│   Data Access       │ ──→ zalezy od
├─────────────────────┤
│   Database          │
└─────────────────────┘

Z DIP — abstrakcje naleza do warstwy biznesowej:
┌─────────────────────┐
│   Presentation      │ ──→ zalezy od abstrakcji
├─────────────────────┤
│   Business Logic    │     definiuje abstrakcje (interfejsy)
│   (OrderRepository) │     ← abstrakcja
│   (PaymentGateway)  │     ← abstrakcja
├─────────────────────┤
│   Infrastructure    │ ──→ implementuje abstrakcje
│   (PostgresRepo)    │
│   (StripeGateway)   │
└─────────────────────┘
```

```typescript
// Struktura katalogow z DIP
src/
  domain/               // warstwa biznesowa — ZERO zaleznosci zewnetrznych
    entities/
      Order.ts
      Customer.ts
    repositories/       // INTERFEJSY repozytoriow
      OrderRepository.ts
      CustomerRepository.ts
    services/
      OrderService.ts   // zalezy od interfejsow, nie implementacji

  infrastructure/       // szczegoly implementacyjne
    persistence/
      PostgresOrderRepository.ts   // implementuje OrderRepository
      PostgresCustomerRepository.ts
    payments/
      StripePaymentGateway.ts      // implementuje PaymentGateway
    notifications/
      SendGridNotificationService.ts

  application/          // kompozycja — laczy warstwy
    config/
      container.ts      // DI container, konfiguracja zaleznosci
```

## Przykład 4: Testowanie z DIP

```typescript
// Dzieki DIP — latwe testowanie z mockami

class InMemoryOrderRepository implements OrderRepository {
    private orders: Map<string, Order> = new Map();

    save(order: Order): void {
        this.orders.set(order.id, order);
    }

    findById(id: string): Order {
        const order = this.orders.get(id);
        if (!order) throw new NotFoundError(`Order ${id}`);
        return order;
    }
}

class FakePaymentGateway implements PaymentGateway {
    public lastCharge?: { amount: Money; method: PaymentMethod };

    charge(amount: Money, method: PaymentMethod): PaymentResult {
        this.lastCharge = { amount, method };
        return PaymentResult.success('fake-tx-123');
    }
}

class SpyNotificationService implements NotificationService {
    public sentNotifications: Order[] = [];

    sendOrderConfirmation(order: Order): void {
        this.sentNotifications.push(order);
    }
}

// Testy — szybkie, izolowane, bez infrastruktury
describe('OrderService', () => {
    let repo: InMemoryOrderRepository;
    let payments: FakePaymentGateway;
    let notifications: SpyNotificationService;
    let service: OrderService;

    beforeEach(() => {
        repo = new InMemoryOrderRepository();
        payments = new FakePaymentGateway();
        notifications = new SpyNotificationService();
        service = new OrderService(repo, payments, notifications);
    });

    it('should save order after successful payment', () => {
        const order = createTestOrder({ total: Money.of(100) });

        service.placeOrder(order);

        expect(repo.findById(order.id)).toBeDefined();
        expect(payments.lastCharge?.amount).toEqual(Money.of(100));
        expect(notifications.sentNotifications).toHaveLength(1);
    });
});
```

## Abstrakcje vs konkrecje — praktyczne wskazówki

| Zależ od abstrakcji | Nie zależ od konkrecji |
|---------------------|----------------------|
| `OrderRepository` (interfejs) | `PostgresOrderRepository` (klasa) |
| `Logger` (interfejs) | `WinstonLogger` (klasa) |
| `HttpClient` (interfejs) | `AxiosHttpClient` (klasa) |
| `Clock` (interfejs) | `SystemClock` / `new Date()` |
| `FileStorage` (interfejs) | `S3Storage` (klasa) |

## Kiedy DIP jest zbędne?

- **Proste skrypty** — niepotrzebna warstwa abstrakcji
- **Stabilne zależności** — `String`, `Math`, standardowa biblioteka nie wymagają abstrakcji
- **Klasy wartości (Value Objects)** — `Money`, `Email`, `Address` mogą być używane bezpośrednio

```typescript
// NIE potrzebujesz interfejsu dla wszystkiego
class OrderService {
    // Money to Value Object — stabilna, nie potrzebuje abstrakcji
    calculateDiscount(total: Money, percentage: number): Money {
        return total.multiply(percentage / 100);
    }
}
```

## Podsumowanie

- DIP odwraca kierunek zależności — logika biznesowa definiuje abstrakcje, infrastruktura je implementuje
- Dependency Injection to mechanizm dostarczania zależności (Constructor > Method > Property)
- DI Container automatyzuje tworzenie i wiązanie zależności
- DIP umożliwia łatwe testowanie, podmianę implementacji i równoległą pracę zespołów
- Nie abstrakcjuj stabilnych zależności (standardowa biblioteka, Value Objects)
