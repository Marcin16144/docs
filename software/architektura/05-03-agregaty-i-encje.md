# 05-03: Agregaty, Encje i Value Objects

## Trzy taktyczne building blocks DDD

Na poziomie taktycznym DDD wyróżnia trzy główne rodzaje obiektów domenowych:

- **Entity (Encja)** — obiekt z unikalną tożsamością, śledzony w czasie
- **Value Object (Obiekt wartości)** — obiekt bez tożsamości, definiowany przez swoje atrybuty
- **Aggregate (Agregat)** — klaster encji i value objects traktowanych jako jednostka spójności

## Entity — tożsamość ma znaczenie

Encja to obiekt, który jest identyfikowany przez swoją tożsamość, nie przez atrybuty. Dwie encje z identycznymi atrybutami, ale różnymi identyfikatorami, to dwa różne obiekty.

### Kiedy obiekt jest encją?

- Ma cykl życia (jest tworzony, modyfikowany, usuwany)
- Musi być jednoznacznie identyfikowalny
- Zmiana atrybutów nie zmienia tego, "czym" obiekt jest
- Potrzebujesz śledzić jego historię zmian

```typescript
class Order {
    private _id: OrderId;
    private _status: OrderStatus;
    private _items: OrderItem[];
    private _placedAt: Date;
    private _domainEvents: DomainEvent[] = [];

    // Tożsamość — nawet jeśli wszystko inne się zmieni, to wciąż to samo zamówienie
    get id(): OrderId { return this._id; }

    // Encja ma zachowania biznesowe, nie tylko dane
    addItem(product: ProductId, quantity: number, price: Money): void {
        if (this._status !== OrderStatus.Draft) {
            throw new OrderAlreadyPlacedError(this._id);
        }
        const item = new OrderItem(product, quantity, price);
        this._items.push(item);
    }

    place(): void {
        if (this._items.length === 0) {
            throw new EmptyOrderError(this._id);
        }
        this._status = OrderStatus.Placed;
        this._placedAt = new Date();
        this._domainEvents.push(
            new OrderPlacedEvent(this._id, this.totalAmount())
        );
    }

    cancel(reason: CancellationReason): void {
        if (this._status === OrderStatus.Shipped) {
            throw new CannotCancelShippedOrderError(this._id);
        }
        this._status = OrderStatus.Cancelled;
        this._domainEvents.push(
            new OrderCancelledEvent(this._id, reason)
        );
    }

    // Równość encji — porównujemy TYLKO tożsamość
    equals(other: Order): boolean {
        return this._id.equals(other._id);
    }
}
```

## Value Object — atrybuty mają znaczenie

Value Object to obiekt bez tożsamości, definiowany wyłącznie przez swoje atrybuty. Dwa Value Objects z identycznymi atrybutami są uważane za identyczne — jak dwie banknoty 100 zł.

### Kluczowe cechy Value Objects

1. **Niemutowalność** — po utworzeniu nie można zmienić żadnego atrybutu
2. **Równość strukturalna** — porównywane przez wartości atrybutów, nie referencję
3. **Samowalidacja** — Value Object jest zawsze w poprawnym stanie
4. **Brak efektów ubocznych** — operacje zwracają nowe instancje

```typescript
class Money {
    private constructor(
        readonly amount: number,
        readonly currency: Currency,
    ) {
        // Samowalidacja — niemożliwe do stworzenia w złym stanie
        if (amount < 0) throw new NegativeAmountError(amount);
        if (!currency) throw new MissingCurrencyError();
    }

    static of(amount: number, currency: Currency): Money {
        return new Money(amount, currency);
    }

    static zero(currency: Currency): Money {
        return new Money(0, currency);
    }

    // Operacje zwracają NOWE instancje (niemutowalność)
    add(other: Money): Money {
        this.ensureSameCurrency(other);
        return new Money(this.amount + other.amount, this.currency);
    }

    subtract(other: Money): Money {
        this.ensureSameCurrency(other);
        return new Money(this.amount - other.amount, this.currency);
    }

    multiply(factor: number): Money {
        return new Money(
            Math.round(this.amount * factor * 100) / 100,
            this.currency,
        );
    }

    isGreaterThan(other: Money): boolean {
        this.ensureSameCurrency(other);
        return this.amount > other.amount;
    }

    // Równość strukturalna — porównujemy atrybuty, nie referencje
    equals(other: Money): boolean {
        return this.amount === other.amount
            && this.currency === other.currency;
    }

    private ensureSameCurrency(other: Money): void {
        if (this.currency !== other.currency) {
            throw new CurrencyMismatchError(this.currency, other.currency);
        }
    }

    toString(): string {
        return `${this.amount.toFixed(2)} ${this.currency}`;
    }
}
```

### Więcej przykładów Value Objects

```typescript
class EmailAddress {
    readonly value: string;

    constructor(email: string) {
        const normalized = email.trim().toLowerCase();
        if (!this.isValid(normalized)) {
            throw new InvalidEmailError(email);
        }
        this.value = normalized;
    }

    private isValid(email: string): boolean {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }

    get domain(): string {
        return this.value.split('@')[1];
    }

    equals(other: EmailAddress): boolean {
        return this.value === other.value;
    }
}

class DateRange {
    constructor(
        readonly from: Date,
        readonly to: Date,
    ) {
        if (from >= to) {
            throw new InvalidDateRangeError(from, to);
        }
    }

    contains(date: Date): boolean {
        return date >= this.from && date <= this.to;
    }

    overlaps(other: DateRange): boolean {
        return this.from < other.to && this.to > other.from;
    }

    get durationInDays(): number {
        const ms = this.to.getTime() - this.from.getTime();
        return Math.ceil(ms / (1000 * 60 * 60 * 24));
    }

    equals(other: DateRange): boolean {
        return this.from.getTime() === other.from.getTime()
            && this.to.getTime() === other.to.getTime();
    }
}

class Quantity {
    constructor(readonly value: number) {
        if (!Number.isInteger(value) || value < 0) {
            throw new InvalidQuantityError(value);
        }
    }

    add(other: Quantity): Quantity {
        return new Quantity(this.value + other.value);
    }

    subtract(other: Quantity): Quantity {
        return new Quantity(this.value - other.value);
    }

    equals(other: Quantity): boolean {
        return this.value === other.value;
    }
}
```

### Entity vs Value Object

| Cecha | Entity | Value Object |
|-------|--------|-------------|
| Tożsamość | Ma unikalny identyfikator | Brak — definiowany przez atrybuty |
| Równość | Porównanie po ID | Porównanie po wszystkich atrybutach |
| Mutowalność | Może się zmieniać (cykl życia) | Niemutowalny (nowa instancja) |
| Przykłady | Order, Customer, Account | Money, Address, EmailAddress |
| Persystencja | Własna tabela z kluczem głównym | Osadzone w encji lub osobna tabela |

## Aggregate — granica spójności

Agregat to klaster powiązanych encji i value objects, traktowanych jako jednostka do celów zmian danych. Ma korzeń agregatu (Aggregate Root), przez który odbywa się cała komunikacja zewnętrzna.

### Reguły projektowania agregatów

1. **Zewnętrzne obiekty odwołują się tylko do korzenia** — nie bezpośrednio do wewnętrznych encji
2. **Korzeń odpowiada za spójność** — wszystkie reguły biznesowe (invarianty) są wymuszane przez korzeń
3. **Agregaty odwołują się do siebie przez ID** — nie przez referencje obiektowe
4. **Jedna transakcja = jeden agregat** — nie modyfikuj wielu agregatów w jednej transakcji

```typescript
// Aggregate Root
class Order {
    private _id: OrderId;
    private _customerId: CustomerId; // Referencja przez ID, nie obiekt Customer
    private _items: OrderItem[] = [];
    private _status: OrderStatus = OrderStatus.Draft;
    private _shippingAddress: Address; // Value Object
    private _totalLimit: Money;

    // Korzeń kontroluje dodawanie elementów (invariant: max 50 pozycji)
    addItem(productId: ProductId, quantity: Quantity, unitPrice: Money): void {
        if (this._items.length >= 50) {
            throw new OrderItemLimitExceededError(this._id);
        }

        const existing = this._items.find(i => i.productId.equals(productId));
        if (existing) {
            // Modyfikacja wewnętrznej encji przez korzeń
            existing.increaseQuantity(quantity);
        } else {
            this._items.push(new OrderItem(productId, quantity, unitPrice));
        }

        this.validateTotalLimit();
    }

    removeItem(productId: ProductId): void {
        const index = this._items.findIndex(
            i => i.productId.equals(productId)
        );
        if (index === -1) {
            throw new ItemNotInOrderError(productId);
        }
        this._items.splice(index, 1);
    }

    // Invariant wymuszany przez korzeń
    private validateTotalLimit(): void {
        const total = this._items.reduce(
            (sum, item) => sum.add(item.lineTotal()),
            Money.zero('PLN'),
        );
        if (total.isGreaterThan(this._totalLimit)) {
            throw new OrderTotalExceededError(this._id, total, this._totalLimit);
        }
    }

    get totalAmount(): Money {
        return this._items.reduce(
            (sum, item) => sum.add(item.lineTotal()),
            Money.zero('PLN'),
        );
    }
}

// Wewnętrzna encja — niedostępna bezpośrednio z zewnątrz
class OrderItem {
    constructor(
        readonly productId: ProductId,
        private _quantity: Quantity,
        private _unitPrice: Money,
    ) {}

    increaseQuantity(additional: Quantity): void {
        this._quantity = this._quantity.add(additional);
    }

    lineTotal(): Money {
        return this._unitPrice.multiply(this._quantity.value);
    }
}
```

### Zasada małych agregatów

Duże agregaty tworzą problemy z wydajnością i współbieżnością. Preferuj małe agregaty z jedną encją jako korzeniem.

```typescript
// ŹLE: za duży agregat — Customer zawiera wszystko
class Customer {
    orders: Order[];           // Setki zamówień
    addresses: Address[];      // Wiele adresów
    paymentMethods: Payment[]; // Metody płatności
    loyaltyPoints: Points;     // Punkty lojalnościowe
    preferences: Preferences;  // Preferencje
    // Każda zmiana blokuje cały agregat!
}

// DOBRZE: małe, niezależne agregaty
class Customer {              // Agregat 1: dane podstawowe
    id: CustomerId;
    name: CustomerName;
    email: EmailAddress;
    tier: CustomerTier;
}

class ShippingProfile {       // Agregat 2: adresy
    id: ShippingProfileId;
    customerId: CustomerId;   // Referencja przez ID
    addresses: Address[];
    defaultAddress: Address;
}

class LoyaltyAccount {        // Agregat 3: punkty
    id: LoyaltyAccountId;
    customerId: CustomerId;   // Referencja przez ID
    points: Points;
    transactions: PointTransaction[];
}
```

### Referencje między agregatami — przez ID

```typescript
// ŹLE: bezpośrednia referencja obiektowa
class Order {
    customer: Customer;       // Cały obiekt Customer załadowany
    payment: Payment;         // Cały obiekt Payment załadowany
}

// DOBRZE: referencja przez ID (tania, luźno powiązana)
class Order {
    customerId: CustomerId;   // Tylko identyfikator
    paymentId: PaymentId;     // Tylko identyfikator
}

// Gdy potrzebujesz danych z innego agregatu — użyj serwisu
class OrderService {
    async getOrderDetails(orderId: OrderId): Promise<OrderDetails> {
        const order = await this.orderRepo.findById(orderId);
        const customer = await this.customerRepo.findById(order.customerId);
        return OrderDetails.from(order, customer);
    }
}
```

## Praktyczne wskazówki

- **Domyślnie twórz Value Object** — encja tylko gdy naprawdę potrzebujesz tożsamości
- **Value Objects eliminują prymitywną obsesję** — zamiast `string` dla emaila, użyj `EmailAddress`
- **Agregat = granica transakcji** — jedna operacja biznesowa modyfikuje jeden agregat
- **Między agregatami: eventual consistency** — komunikacja przez zdarzenia domenowe
- **Jeśli agregat rośnie, rozważ rozbicie** — duży agregat to sygnał problemu projektowego
- **Testuj invarianty agregatu** — to kluczowa logika biznesowa wymagająca pokrycia testami
