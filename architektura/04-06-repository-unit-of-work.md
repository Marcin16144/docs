# 04-06: Repository i Unit of Work

## Repository Pattern

Repository to wzorzec, który abstrahuje dostęp do danych za interfejsem kolekcji. Warstwa biznesowa operuje na obiektach domenowych, nie wiedząc nic o SQL, ORM czy konkretnej bazie danych. Repository udaje kolekcję obiektów w pamięci.

### Interfejs repozytorium

Dobrze zaprojektowany interfejs Repository skupia się na operacjach domenowych, nie na technicznych detalach persystencji.

```typescript
// Interfejs domenowy — żadnych szczegółów bazy danych
interface OrderRepository {
    findById(id: OrderId): Promise<Order | null>;
    findByCustomer(customerId: CustomerId): Promise<Order[]>;
    findPending(): Promise<Order[]>;
    findByDateRange(from: Date, to: Date): Promise<Order[]>;
    save(order: Order): Promise<void>;
    delete(id: OrderId): Promise<void>;
    nextId(): OrderId;
}
```

### Implementacja z bazą danych

```typescript
class PostgresOrderRepository implements OrderRepository {
    constructor(private db: DatabaseConnection) {}

    async findById(id: OrderId): Promise<Order | null> {
        const row = await this.db.queryOne(
            'SELECT * FROM orders WHERE id = $1', [id.value]
        );
        return row ? this.toDomain(row) : null;
    }

    async findByCustomer(customerId: CustomerId): Promise<Order[]> {
        const rows = await this.db.query(
            'SELECT * FROM orders WHERE customer_id = $1 ORDER BY created_at DESC',
            [customerId.value]
        );
        return rows.map(row => this.toDomain(row));
    }

    async findPending(): Promise<Order[]> {
        const rows = await this.db.query(
            "SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at"
        );
        return rows.map(row => this.toDomain(row));
    }

    async save(order: Order): Promise<void> {
        const data = this.toPersistence(order);
        await this.db.query(
            `INSERT INTO orders (id, customer_id, status, total, items, created_at)
             VALUES ($1, $2, $3, $4, $5, $6)
             ON CONFLICT (id) DO UPDATE SET
                status = $3, total = $4, items = $5`,
            [data.id, data.customerId, data.status, data.total,
             JSON.stringify(data.items), data.createdAt]
        );
    }

    async delete(id: OrderId): Promise<void> {
        await this.db.query('DELETE FROM orders WHERE id = $1', [id.value]);
    }

    nextId(): OrderId {
        return OrderId.generate();
    }

    // Mapowanie: baza danych -> obiekt domenowy
    private toDomain(row: any): Order {
        return Order.reconstitute({
            id: new OrderId(row.id),
            customerId: new CustomerId(row.customer_id),
            status: row.status as OrderStatus,
            total: Money.of(row.total, 'PLN'),
            items: JSON.parse(row.items).map(this.toOrderItem),
            createdAt: row.created_at,
        });
    }

    // Mapowanie: obiekt domenowy -> baza danych
    private toPersistence(order: Order): any {
        return {
            id: order.id.value,
            customerId: order.customerId.value,
            status: order.status,
            total: order.total.amount,
            items: order.items.map(this.toItemData),
            createdAt: order.createdAt,
        };
    }
}
```

### Implementacja in-memory do testów

Jedną z głównych zalet Repository jest łatwość testowania. Implementacja in-memory pozwala testować logikę biznesową bez bazy danych.

```typescript
class InMemoryOrderRepository implements OrderRepository {
    private orders = new Map<string, Order>();
    private idCounter = 0;

    async findById(id: OrderId): Promise<Order | null> {
        return this.orders.get(id.value) || null;
    }

    async findByCustomer(customerId: CustomerId): Promise<Order[]> {
        return Array.from(this.orders.values())
            .filter(o => o.customerId.equals(customerId))
            .sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
    }

    async findPending(): Promise<Order[]> {
        return Array.from(this.orders.values())
            .filter(o => o.status === 'pending')
            .sort((a, b) => a.createdAt.getTime() - b.createdAt.getTime());
    }

    async findByDateRange(from: Date, to: Date): Promise<Order[]> {
        return Array.from(this.orders.values())
            .filter(o => o.createdAt >= from && o.createdAt <= to);
    }

    async save(order: Order): Promise<void> {
        this.orders.set(order.id.value, order);
    }

    async delete(id: OrderId): Promise<void> {
        this.orders.delete(id.value);
    }

    nextId(): OrderId {
        return new OrderId(`order-${++this.idCounter}`);
    }

    // Metody pomocnicze dla testów
    clear(): void {
        this.orders.clear();
    }

    count(): number {
        return this.orders.size;
    }
}
```

### Testowanie z in-memory repository

```typescript
describe('OrderService', () => {
    let orderRepo: InMemoryOrderRepository;
    let service: OrderService;

    beforeEach(() => {
        orderRepo = new InMemoryOrderRepository();
        service = new OrderService(orderRepo);
    });

    test('składanie zamówienia zapisuje je w repozytorium', async () => {
        const request = {
            customerId: new CustomerId('cust-1'),
            items: [{ productId: 'prod-1', quantity: 2, price: Money.of(100, 'PLN') }],
        };

        const order = await service.placeOrder(request);

        const saved = await orderRepo.findById(order.id);
        expect(saved).not.toBeNull();
        expect(saved!.status).toBe('pending');
        expect(saved!.total.amount).toBe(200);
    });

    test('anulowanie zamówienia zmienia status', async () => {
        // Arrange — przygotowanie danych bezpośrednio w repo
        const order = Order.create({
            id: orderRepo.nextId(),
            customerId: new CustomerId('cust-1'),
            items: [{ productId: 'prod-1', quantity: 1, price: Money.of(50, 'PLN') }],
        });
        await orderRepo.save(order);

        // Act
        await service.cancelOrder(order.id);

        // Assert
        const updated = await orderRepo.findById(order.id);
        expect(updated!.status).toBe('cancelled');
    });
});
```

## Unit of Work

Unit of Work śledzi wszystkie zmiany dokonane w obiektach domenowych podczas jednej operacji biznesowej i zapisuje je jako jedną transakcję. Zapewnia atomowość — albo wszystkie zmiany się zapiszą, albo żadna.

### Problem bez Unit of Work

```typescript
// Bez Unit of Work — każde save() to osobna transakcja
async function transferMoney(fromId: string, toId: string, amount: Money) {
    const fromAccount = await accountRepo.findById(fromId);
    const toAccount = await accountRepo.findById(toId);

    fromAccount.withdraw(amount);
    toAccount.deposit(amount);

    await accountRepo.save(fromAccount); // Transakcja 1 ✓
    await accountRepo.save(toAccount);   // Transakcja 2 ✗ BŁĄD!
    // Pieniądze zniknęły z fromAccount, ale nie dotarły do toAccount!
}
```

### Implementacja Unit of Work

```typescript
interface UnitOfWork {
    orderRepository: OrderRepository;
    customerRepository: CustomerRepository;
    paymentRepository: PaymentRepository;

    begin(): Promise<void>;
    commit(): Promise<void>;
    rollback(): Promise<void>;
}

class PostgresUnitOfWork implements UnitOfWork {
    private transaction: DatabaseTransaction | null = null;

    // Repozytoria współdzielą transakcję
    readonly orderRepository: OrderRepository;
    readonly customerRepository: CustomerRepository;
    readonly paymentRepository: PaymentRepository;

    constructor(private db: DatabaseConnection) {
        this.orderRepository = new PostgresOrderRepository(this);
        this.customerRepository = new PostgresCustomerRepository(this);
        this.paymentRepository = new PostgresPaymentRepository(this);
    }

    async begin(): Promise<void> {
        this.transaction = await this.db.beginTransaction();
    }

    async commit(): Promise<void> {
        if (!this.transaction) throw new Error('Brak aktywnej transakcji');
        await this.transaction.commit();
        this.transaction = null;
    }

    async rollback(): Promise<void> {
        if (!this.transaction) return;
        await this.transaction.rollback();
        this.transaction = null;
    }

    // Repozytoria używają tej metody do wykonywania zapytań
    getTransaction(): DatabaseTransaction {
        if (!this.transaction) throw new Error('Brak aktywnej transakcji');
        return this.transaction;
    }
}
```

### Użycie Unit of Work w serwisie

```typescript
class OrderService {
    constructor(private uow: UnitOfWork) {}

    async placeOrder(request: PlaceOrderRequest): Promise<Order> {
        await this.uow.begin();
        try {
            // Wszystkie operacje w jednej transakcji
            const customer = await this.uow.customerRepository
                .findById(request.customerId);

            if (!customer) throw new Error('Klient nie znaleziony');

            const order = Order.create({
                id: this.uow.orderRepository.nextId(),
                customerId: customer.id,
                items: request.items,
            });

            // Zapisz zamówienie
            await this.uow.orderRepository.save(order);

            // Utwórz płatność
            const payment = Payment.create({
                orderId: order.id,
                amount: order.total,
                method: request.paymentMethod,
            });
            await this.uow.paymentRepository.save(payment);

            // Zaktualizuj statystyki klienta
            customer.incrementOrderCount();
            await this.uow.customerRepository.save(customer);

            // Commit — wszystko albo nic
            await this.uow.commit();
            return order;
        } catch (error) {
            await this.uow.rollback();
            throw error;
        }
    }
}
```

### Uproszczona wersja z callbackiem

Wzorzec try/catch/rollback powtarza się w każdym serwisie. Można go wyekstrahować do metody pomocniczej.

```typescript
class UnitOfWorkManager {
    constructor(private db: DatabaseConnection) {}

    async execute<T>(work: (uow: UnitOfWork) => Promise<T>): Promise<T> {
        const uow = new PostgresUnitOfWork(this.db);
        await uow.begin();
        try {
            const result = await work(uow);
            await uow.commit();
            return result;
        } catch (error) {
            await uow.rollback();
            throw error;
        }
    }
}

// Użycie — czystsze, bez boilerplate'u
class OrderService {
    constructor(private uowManager: UnitOfWorkManager) {}

    async placeOrder(request: PlaceOrderRequest): Promise<Order> {
        return this.uowManager.execute(async (uow) => {
            const customer = await uow.customerRepository
                .findById(request.customerId);
            const order = Order.create({ /* ... */ });
            await uow.orderRepository.save(order);
            await uow.customerRepository.save(customer);
            return order;
        });
    }
}
```

## Repository + Unit of Work razem

| Wzorzec | Odpowiedzialność |
|---------|-----------------|
| Repository | Dostęp do danych — CRUD jednego typu encji |
| Unit of Work | Spójność transakcyjna — koordynacja wielu repozytoriów |

### Kiedy wystarczy sam Repository?

- Proste operacje CRUD na jednej encji
- Brak wymagań transakcyjnych cross-encyjnych
- Mały system, gdzie ORM zarządza transakcjami automatycznie

### Kiedy potrzebujesz Unit of Work?

- Operacja biznesowa modyfikuje kilka encji jednocześnie
- Wymagasz atomowości — wszystko albo nic
- Masz złożone invarianty cross-agregatowe

## Typowe błędy

1. **Zbyt generyczne repozytorium** — `Repository<T>` z metodami `find(query)` wycieka abstrakcję persystencji do warstwy biznesowej
2. **Metody typu query-builder** — `orderRepo.where('status', 'pending').orderBy('date')` to nie repozytorium, to ORM
3. **Zwracanie encji persystencji** — repozytorium powinno zwracać obiekty domenowe, nie rekordy bazy danych
4. **Brak mapowania** — bezpośrednie mapowanie 1:1 między tabelą a encją oznacza, że nie potrzebujesz Repository
5. **Unit of Work jako singleton** — UoW powinien żyć tyle co jedna operacja biznesowa, nie cała aplikacja
