# 03-08: Coupling i Cohesion — Sprzężenie i spójność

## Czym są coupling i cohesion?

**Coupling (sprzężenie)** to stopień, w jakim moduły zależą od siebie. Im wyższe sprzężenie, tym trudniejsza zmiana jednego modułu bez wpływu na inne.

**Cohesion (spójność)** to stopień, w jakim elementy wewnątrz modułu są ze sobą powiązane. Im wyższa spójność, tym bardziej moduł skupia się na jednym zadaniu.

Cel: **niskie sprzężenie między modułami, wysoka spójność wewnątrz modułów**.

## Typy sprzężenia (od najgorszego)

### 1. Content Coupling (sprzężenie treściowe) — najgorsze

Moduł bezpośrednio odwołuje się do wewnętrznych danych lub kodu innego modułu.

```typescript
// ZLE — Content Coupling: bezposredni dostep do wnetrza
class OrderProcessor {
    process(cart: ShoppingCart): void {
        // Siega bezposrednio do wewnetrznej struktury
        for (let i = 0; i < cart._items.length; i++) {
            cart._items[i]._price = cart._items[i]._price * 0.9;
        }
        // Modyfikuje prywatny stan
        cart._totalCalculated = false;
    }
}

// DOBRZE — uzywaj publicznego API
class OrderProcessor {
    process(cart: ShoppingCart): void {
        cart.applyDiscount(0.1);
    }
}
```

### 2. Common Coupling (sprzężenie wspólne)

Moduły dzielą globalny stan (zmienne globalne, singletony z mutowalnym stanem).

```python
# ZLE — Common Coupling: globalny stan dzielony
_current_user = None
_current_locale = None

class AuthService:
    def login(self, username, password):
        global _current_user
        _current_user = self.db.find(username)

class OrderService:
    def create_order(self, items):
        global _current_user
        # Zalezy od globalnego stanu ustawionego przez inny modul
        order = Order(customer=_current_user, items=items)
        return order

class TranslationService:
    def translate(self, key):
        global _current_locale
        # Inny globalny stan — kto i kiedy go ustawia?
        return self.translations[_current_locale][key]
```

```python
# DOBRZE — jawne przekazywanie zaleznosci
class OrderService:
    def create_order(self, customer: Customer, items: list[Item]) -> Order:
        return Order(customer=customer, items=items)

class TranslationService:
    def translate(self, key: str, locale: str) -> str:
        return self.translations[locale][key]
```

### 3. Control Coupling (sprzężenie sterujące)

Moduł przekazuje flagę kontrolującą logikę innego modułu.

```typescript
// ZLE — Control Coupling: flaga steruje logika
class UserService {
    getUser(id: string, includeOrders: boolean,
            includeAddress: boolean,
            formatForAPI: boolean): any {
        const user = this.repo.find(id);

        if (includeOrders) {
            user.orders = this.orderRepo.findByUser(id);
        }
        if (includeAddress) {
            user.address = this.addressRepo.findByUser(id);
        }
        if (formatForAPI) {
            return this.formatForAPI(user);
        }
        return user;
    }
}

// DOBRZE — oddzielne metody, kazda robi jedno
class UserService {
    getUser(id: string): User {
        return this.repo.find(id);
    }

    getUserWithOrders(id: string): UserWithOrders {
        const user = this.repo.find(id);
        const orders = this.orderRepo.findByUser(id);
        return { ...user, orders };
    }

    getUserForAPI(id: string): UserDTO {
        const user = this.repo.find(id);
        return UserDTO.from(user);
    }
}
```

### 4. Stamp Coupling (sprzężenie stemplowe)

Moduł otrzymuje więcej danych niż potrzebuje.

```typescript
// ZLE — Stamp Coupling: funkcja otrzymuje caly obiekt,
// ale uzywa tylko 2 pol
function sendWelcomeEmail(user: User): void {
    // User ma 20 pol, ale potrzebujemy tylko email i name
    mailer.send(user.email, `Witaj ${user.name}!`);
}

// DOBRZE — przekaz dokladnie to, co potrzebne
function sendWelcomeEmail(email: string, name: string): void {
    mailer.send(email, `Witaj ${name}!`);
}

// lub dedykowany typ
interface EmailRecipient {
    email: string;
    name: string;
}

function sendWelcomeEmail(recipient: EmailRecipient): void {
    mailer.send(recipient.email, `Witaj ${recipient.name}!`);
}
```

### 5. Data Coupling (sprzężenie danych) — najlepsze

Moduły komunikują się wyłącznie przez przekazywanie prostych, konkretnych danych.

```typescript
// DOBRZE — Data Coupling: proste parametry
function calculateTax(amount: number, taxRate: number): number {
    return amount * taxRate;
}

function formatCurrency(amount: number, currency: string): string {
    return `${amount.toFixed(2)} ${currency}`;
}
```

### Podsumowanie typów sprzężenia

| Typ | Opis | Poziom |
|-----|------|--------|
| **Content** | Dostęp do wnętrza innego modułu | Najgorsze |
| **Common** | Współdzielony globalny stan | Złe |
| **Control** | Flagi sterujące logiką | Problematyczne |
| **Stamp** | Przekazywanie zbyt wielu danych | Akceptowalne |
| **Data** | Komunikacja prostymi danymi | Najlepsze |

## Typy spójności (od najgorszej)

### 1. Coincidental Cohesion — najgorsza

Elementy w module nie mają ze sobą żadnego logicznego związku.

```typescript
// ZLE — Coincidental Cohesion: "utils" to worek na wszystko
class Utils {
    static formatDate(date: Date): string { /* ... */ }
    static calculateDistance(a: Point, b: Point): number { /* ... */ }
    static compressImage(img: Buffer): Buffer { /* ... */ }
    static validateEmail(email: string): boolean { /* ... */ }
    static generatePDF(data: any): Buffer { /* ... */ }
    static parseCSV(content: string): string[][] { /* ... */ }
}
```

### 2. Logical Cohesion

Elementy są pogrupowane, bo robią rzeczy "podobne", ale niepowiązane.

```python
# ZLE — Logical Cohesion: "all handlers" w jednej klasie
class DataHandler:
    def handle_json(self, data: str) -> dict: ...
    def handle_xml(self, data: str) -> dict: ...
    def handle_csv(self, data: str) -> list: ...
    def handle_yaml(self, data: str) -> dict: ...

    # Logicznie powiazane (parsowanie), ale kazda metoda
    # jest niezalezna i zmienia sie z innego powodu.
```

### 3. Temporal Cohesion

Elementy pogrupowane, bo wykonują się w tym samym czasie.

```typescript
// ZLE — Temporal Cohesion: "startup" robiony w jednej klasie
class ApplicationStartup {
    initialize(): void {
        this.connectToDatabase();
        this.loadConfiguration();
        this.initializeCache();
        this.startMessageBroker();
        this.warmUpMLModels();
        this.registerMetrics();
        this.startHealthCheck();
    }
}

// DOBRZE — osobne moduly, orkiestrator je laczy
class Application {
    constructor(
        private db: DatabaseConnection,
        private config: ConfigLoader,
        private cache: CacheManager,
        private broker: MessageBroker,
        private health: HealthCheck
    ) {}

    async start(): Promise<void> {
        await this.config.load();
        await this.db.connect();
        await this.cache.initialize();
        await this.broker.start();
        this.health.start();
    }
}
```

### 4. Sequential Cohesion

Elementy tworzą pipeline — wyjście jednego jest wejściem kolejnego.

```python
# Srednia spojnosc — pipeline przetwarzania
class DataPipeline:
    def process(self, raw_data: str) -> Report:
        parsed = self.parse(raw_data)
        validated = self.validate(parsed)
        transformed = self.transform(validated)
        return self.generate_report(transformed)
```

### 5. Functional Cohesion — najlepsza

Wszystkie elementy współpracują, by realizować jedną, dobrze zdefiniowaną funkcję.

```typescript
// DOBRZE — Functional Cohesion: wszystko sluzy jednemu celowi

class ShoppingCart {
    private items: CartItem[] = [];

    addItem(product: Product, quantity: number): void {
        const existing = this.findItem(product.id);
        if (existing) {
            existing.increaseQuantity(quantity);
        } else {
            this.items.push(new CartItem(product, quantity));
        }
    }

    removeItem(productId: string): void {
        this.items = this.items.filter(i => i.productId !== productId);
    }

    calculateTotal(): Money {
        return this.items.reduce(
            (sum, item) => sum.add(item.getSubtotal()),
            Money.zero()
        );
    }

    getItemCount(): number {
        return this.items.reduce((sum, item) => sum + item.quantity, 0);
    }

    isEmpty(): boolean {
        return this.items.length === 0;
    }

    private findItem(productId: string): CartItem | undefined {
        return this.items.find(i => i.productId === productId);
    }
}
```

### Podsumowanie typów spójności

| Typ | Opis | Poziom |
|-----|------|--------|
| **Coincidental** | Brak logicznego związku | Najgorsza |
| **Logical** | Podobne operacje, ale niezależne | Słaba |
| **Temporal** | Wykonują się w tym samym czasie | Słaba |
| **Procedural** | Kroki procedury | Średnia |
| **Sequential** | Pipeline: wyjście → wejście | Dobra |
| **Functional** | Jedna dobrze zdefiniowana funkcja | Najlepsza |

## Praktyczna refaktoryzacja: od złego do dobrego

### Przypadek: Monolit e-commerce

```python
# PRZED — niska spojnosc, wysokie sprzezenie

class ECommerceService:
    def __init__(self):
        self.db = MySQLConnection()
        self.mailer = SmtpClient()
        self.stripe = StripeAPI()
        self.redis = RedisClient()

    def place_order(self, user_id, cart_items):
        # Walidacja (odpowiedzialnosc 1)
        user = self.db.query("SELECT * FROM users WHERE id=%s", user_id)
        if not user:
            raise ValueError("Nieznany uzytkownik")
        for item in cart_items:
            stock = self.db.query("SELECT stock FROM products WHERE id=%s",
                                  item['product_id'])
            if stock[0]['stock'] < item['quantity']:
                raise ValueError(f"Brak towaru: {item['product_id']}")

        # Obliczenia (odpowiedzialnosc 2)
        total = 0
        for item in cart_items:
            product = self.db.query("SELECT * FROM products WHERE id=%s",
                                     item['product_id'])
            total += product[0]['price'] * item['quantity']
        tax = total * 0.23

        # Platnosc (odpowiedzialnosc 3)
        payment = self.stripe.charge(user['card_token'], total + tax)

        # Zapis (odpowiedzialnosc 4)
        order_id = self.db.execute(
            "INSERT INTO orders (user_id, total) VALUES (%s, %s)",
            user_id, total + tax
        )

        # Cache (odpowiedzialnosc 5)
        self.redis.delete(f"cart:{user_id}")

        # Powiadomienie (odpowiedzialnosc 6)
        self.mailer.send(user['email'], "Zamowienie", f"ID: {order_id}")

        return order_id
```

### Po refaktoryzacji

```python
# PO — wysoka spojnosc, niskie sprzezenie

class OrderService:
    """Wysoka spojnosc: tylko orkiestracja zamowienia."""
    def __init__(self, validator: OrderValidator,
                 calculator: PriceCalculator,
                 payments: PaymentGateway,
                 repo: OrderRepository,
                 notifier: OrderNotifier):
        self.validator = validator
        self.calculator = calculator
        self.payments = payments
        self.repo = repo
        self.notifier = notifier

    def place_order(self, customer: Customer,
                    items: list[OrderItem]) -> Order:
        self.validator.validate(customer, items)
        pricing = self.calculator.calculate(items)
        payment = self.payments.charge(customer, pricing.total)
        order = Order.create(customer, items, pricing, payment)
        self.repo.save(order)
        self.notifier.order_placed(order)
        return order


class PriceCalculator:
    """Wysoka spojnosc: tylko obliczenia cenowe."""
    def __init__(self, tax_service: TaxService,
                 discount_service: DiscountService):
        self.tax_service = tax_service
        self.discount_service = discount_service

    def calculate(self, items: list[OrderItem]) -> Pricing:
        subtotal = sum(item.price * item.quantity for item in items)
        discount = self.discount_service.calculate(items)
        tax = self.tax_service.calculate(subtotal - discount)
        return Pricing(subtotal=subtotal, discount=discount,
                       tax=tax, total=subtotal - discount + tax)


class OrderValidator:
    """Wysoka spojnosc: tylko walidacja zamowienia."""
    def __init__(self, customer_repo: CustomerRepository,
                 inventory: InventoryService):
        self.customer_repo = customer_repo
        self.inventory = inventory

    def validate(self, customer: Customer,
                 items: list[OrderItem]) -> None:
        if not self.customer_repo.exists(customer.id):
            raise CustomerNotFoundError(customer.id)
        for item in items:
            if not self.inventory.is_available(item.product_id, item.quantity):
                raise OutOfStockError(item.product_id)
```

## Metryki coupling i cohesion

### Afferent Coupling (Ca) — kto zależy ode mnie?

Ile modułów **zależy od** tego modułu. Wysoki Ca oznacza, że moduł jest szeroko używany — zmiana w nim jest ryzykowna.

### Efferent Coupling (Ce) — od kogo ja zależę?

Ile modułów **jest potrzebnych** przez ten moduł. Wysoki Ce oznacza wiele zależności — moduł jest kruchy.

### Instability (I) = Ce / (Ca + Ce)

- **I = 0** — całkowicie stabilny (wiele modułów od niego zależy, sam nie zależy)
- **I = 1** — całkowicie niestabilny (od nikogo nie zależy, ale zależy od wielu)

```
Przyklad:
  OrderService:  Ca=5 (5 kontrolerow go uzywa), Ce=3 (zalezy od 3 interfejsow)
  Instability = 3 / (5+3) = 0.375 — umiarkowanie stabilny

  Utils:  Ca=20, Ce=0
  Instability = 0 / (20+0) = 0 — bardzo stabilny (duzo modulow zalezy)
```

### Praktyczne narzędzia

| Język | Narzędzie | Co mierzy |
|-------|-----------|-----------|
| Java | JDepend, SonarQube | Ca, Ce, Instability, Abstractness |
| .NET | NDepend | Coupling, cohesion, dependency graphs |
| JavaScript | dependency-cruiser | Circular dependencies, coupling |
| Python | radon, pylint | Complexity, module dependencies |
| Ogólne | Code Climate, SonarQube | Maintainability, coupling metrics |

## Wskazówki na co dzień

1. **Klasa "Utils" to sygnał alarmowy** — podziel na moduły tematyczne
2. **Jeśli zmiana w module A wymaga zmian w B, C, D** — za wysokie sprzężenie
3. **Jeśli nie wiesz, jak nazwać klasę bez "Manager", "Handler", "Utils"** — za niska spójność
4. **Cykliczne zależności (A → B → C → A)** — najgorszy rodzaj sprzężenia, eliminuj natychmiast
5. **Interfejsy redukują coupling** — zależ od abstrakcji, nie konkrecji
6. **Eventy/wiadomości** — luźniejsze sprzężenie niż bezpośrednie wywołania

## Podsumowanie

- Dąż do **niskiego sprzężenia** między modułami i **wysokiej spójności** wewnątrz
- Najgorsze sprzężenie: Content (dostęp do wnętrza) i Common (globalny stan)
- Najlepsze sprzężenie: Data (proste parametry)
- Najgorsza spójność: Coincidental (worek "utils") i Logical (podobne, ale niepowiązane)
- Najlepsza spójność: Functional (jedna dobrze zdefiniowana funkcja)
- Mierz coupling i cohesion narzędziami — nie polegaj na intuicji przy dużym kodzie
- Refaktoryzuj stopniowo — wydzielaj klasy o wysokiej spójności, minimalizuj ich wzajemne zależności
