# 03-06: DRY, KISS, YAGNI — Zasady prostoty i pragmatyzmu

## DRY — Don't Repeat Yourself

### Definicja

Zasada DRY, sformułowana przez Andy'ego Hunta i Dave'a Thomasa w "The Pragmatic Programmer", mówi: **każda porcja wiedzy powinna mieć jedną, jednoznaczną, autorytatywną reprezentację w systemie**.

Uwaga: DRY dotyczy **duplikacji wiedzy**, nie duplikacji kodu. Dwa identyczne fragmenty kodu mogą reprezentować różną wiedzę i zmieniać się z różnych powodów.

### Prawdziwa duplikacja vs przypadkowa zbieżność

```typescript
// PRZYPADKOWA ZBIEZNOSC — wyglada identycznie, ale to ROZNA wiedza

// Walidacja adresu dostawy — zmienia sie gdy zmienia sie logistyka
function validateShippingAddress(address: Address): boolean {
    return address.street.length > 0
        && address.city.length > 0
        && address.zip.length === 5;
}

// Walidacja adresu rozliczeniowego — zmienia sie gdy zmienia sie prawo podatkowe
function validateBillingAddress(address: Address): boolean {
    return address.street.length > 0
        && address.city.length > 0
        && address.zip.length === 5;
}

// Te dwie funkcje WYGLADAJA identycznie, ale zmienia sie z ROZNYCH powodow.
// Polaczenie ich w jedna byleby zle zastosowanym DRY.
// Za miesiac billing moze wymagac NIP, a shipping — kodu kraju.
```

```typescript
// PRAWDZIWA DUPLIKACJA — ta sama wiedza powtorzona w wielu miejscach

// ZLE — logika obliczania podatku powtorzona
class CartService {
    calculateTax(amount: number): number {
        return amount * 0.23; // 23% VAT
    }
}

class InvoiceService {
    calculateTax(amount: number): number {
        return amount * 0.23; // 23% VAT — ta sama wiedza!
    }
}

class ReportService {
    calculateTax(amount: number): number {
        return amount * 0.23; // 23% VAT — i tu tez!
    }
}

// DOBRZE — jedna reprezentacja wiedzy o podatku
class TaxCalculator {
    private static readonly VAT_RATE = 0.23;

    static calculate(amount: number): number {
        return amount * TaxCalculator.VAT_RATE;
    }
}
```

### Kiedy DRY jest szkodliwe — Wrong Abstraction

```python
# ZLE — wymuszona abstrakcja dla przypadkowej zbieznosci

def process_entity(entity, entity_type):
    """Uniwersalna funkcja do przetwarzania roznych encji."""
    if entity_type == 'user':
        validate_email(entity.email)
        # ... 20 linii specyficznych dla usera
    elif entity_type == 'product':
        validate_sku(entity.sku)
        # ... 20 linii specyficznych dla produktu
    elif entity_type == 'order':
        validate_items(entity.items)
        # ... 20 linii specyficznych dla zamowienia
    
    # Wspolna czesc: 3 linie
    entity.updated_at = datetime.now()
    entity.version += 1
    db.save(entity)

# DOBRZE — oddzielne funkcje, nawet jesli koncowka sie powtarza
def process_user(user: User):
    validate_email(user.email)
    # logika specyficzna dla usera
    user.updated_at = datetime.now()
    user.version += 1
    db.save(user)

def process_product(product: Product):
    validate_sku(product.sku)
    # logika specyficzna dla produktu
    product.updated_at = datetime.now()
    product.version += 1
    db.save(product)
```

### Rule of Three

Nie abstrahuj przy pierwszym powtórzeniu. Czekaj do trzeciego:

1. **Pierwsze użycie** — napisz kod
2. **Drugie użycie** — skopiuj (tak, skopiuj!) i zanotuj
3. **Trzecie użycie** — teraz refaktoryzuj, bo widzisz wzorzec

## KISS — Keep It Simple, Stupid

### Definicja

KISS mówi: **systemy działają najlepiej, gdy są proste**. Prostota powinna być kluczowym celem projektowania, a niepotrzebna złożoność powinna być unikana.

### Accidental Complexity vs Essential Complexity

```typescript
// ESSENTIAL COMPLEXITY — zlozone, bo problem jest zlozony
// System rezerwacji lotow MUSI obslugiwac strefy czasowe,
// rozne waluty, limity bagazu, przesiadki, itp.

// ACCIDENTAL COMPLEXITY — zlozone, bo programista przesadzil

// ZLE — niepotrzebna abstrakcja dla prostego problemu
interface IStringFormatterStrategy {
    format(input: string): string;
}

class UpperCaseFormatterStrategy implements IStringFormatterStrategy {
    format(input: string): string {
        return input.toUpperCase();
    }
}

class StringFormatterContext {
    constructor(private strategy: IStringFormatterStrategy) {}
    
    execute(input: string): string {
        return this.strategy.format(input);
    }
}

// Uzycie:
const formatter = new StringFormatterContext(
    new UpperCaseFormatterStrategy()
);
const result = formatter.execute("hello");

// DOBRZE — proste rozwiazanie prostego problemu
const result = "hello".toUpperCase();
```

### Przykłady zbędnej złożoności

```python
# ZLE — overcomplicated
class NumberProcessor:
    def __init__(self, numbers):
        self.numbers = numbers
    
    def get_sum(self):
        return functools.reduce(
            lambda acc, x: acc + x,
            self.numbers,
            0
        )
    
    def get_even_numbers(self):
        return list(
            filter(
                lambda x: x % 2 == 0,
                self.numbers
            )
        )

processor = NumberProcessor([1, 2, 3, 4, 5])
total = processor.get_sum()
evens = processor.get_even_numbers()

# DOBRZE — proste i czytelne
numbers = [1, 2, 3, 4, 5]
total = sum(numbers)
evens = [n for n in numbers if n % 2 == 0]
```

```typescript
// ZLE — generyczny builder dla prostej konfiguracji
const config = new ConfigBuilder()
    .withDatabase(
        new DatabaseConfigBuilder()
            .withHost('localhost')
            .withPort(5432)
            .withName('mydb')
            .build()
    )
    .withLogging(
        new LoggingConfigBuilder()
            .withLevel('info')
            .build()
    )
    .build();

// DOBRZE — prosty obiekt
const config = {
    database: { host: 'localhost', port: 5432, name: 'mydb' },
    logging: { level: 'info' }
};
```

## YAGNI — You Aren't Gonna Need It

### Definicja

YAGNI mówi: **nie implementuj funkcjonalności, dopóki nie jest faktycznie potrzebna**. Pochodzi z Extreme Programming (XP) i walczy z tendencją programistów do przewidywania przyszłych potrzeb.

### Koszt implementacji "na zapas"

```typescript
// ZLE — YAGNI violation: system pluginow "na wyrost"

// Projekt: prosty blog z 3 typami postow
// Programista zbudowal:
interface Plugin {
    name: string;
    version: string;
    initialize(context: PluginContext): void;
    destroy(): void;
}

interface PluginContext {
    registerHook(event: string, handler: Function): void;
    getConfig(): PluginConfig;
    getDatabase(): DatabaseConnection;
    getLogger(): Logger;
    getEventBus(): EventBus;
}

class PluginManager {
    private plugins: Map<string, Plugin> = new Map();
    private hooks: Map<string, Function[]> = new Map();
    
    load(plugin: Plugin): void { /* ... */ }
    unload(pluginName: string): void { /* ... */ }
    executeHook(event: string, data: any): void { /* ... */ }
    // ... 200 linii kodu systemu pluginow
}

// Nigdy nie uzyto wiecej niz 3 wbudowanych typow postow.
// System pluginow to 200 linii kodu do utrzymania,
// testowania i dokumentowania — bez zadnego uzytkownika.
```

```typescript
// DOBRZE — prostsze rozwiazanie dla 3 typow postow

type PostType = 'article' | 'gallery' | 'video';

interface Post {
    type: PostType;
    title: string;
    content: string;
    mediaUrls?: string[];
}

function renderPost(post: Post): string {
    switch (post.type) {
        case 'article':  return renderArticle(post);
        case 'gallery':  return renderGallery(post);
        case 'video':    return renderVideo(post);
    }
}

// Gdy faktycznie pojawi sie potrzeba pluginow — WTEDY je zbuduj.
// Bedziesz miec realne wymagania, a nie wyobrazone.
```

### Premature Optimization — podtyp YAGNI

```python
# ZLE — przedwczesna optymalizacja
class UserCache:
    """Cache z LRU, TTL, shardingiem i replikacja.
    Aktualnie mamy 50 uzytkownikow."""
    
    def __init__(self, shards=16, ttl=300, max_size=10000,
                 replication_factor=3):
        self.shards = [OrderedDict() for _ in range(shards)]
        self.ttl = ttl
        self.max_size = max_size
        self.replication_factor = replication_factor
        self.stats = CacheStats()
    
    def get(self, key):
        shard = self._get_shard(key)
        entry = shard.get(key)
        if entry and not self._is_expired(entry):
            self.stats.record_hit()
            return entry.value
        self.stats.record_miss()
        return None
    
    # ... 150 linii kodu cache'a dla 50 uzytkownikow

# DOBRZE — proste rozwiazanie adekwatne do skali
users = {}  # dict wystarczy dla 50 uzytkownikow

def get_user(user_id):
    if user_id not in users:
        users[user_id] = db.find_user(user_id)
    return users[user_id]

# Gdy urosnie do 100k uzytkownikow — WTEDY dodaj Redis.
```

## Napięcia między zasadami

### DRY vs KISS

```typescript
// DRY moze prowadzic do zbytniej zlozonosci

// Sztywne przestrzeganie DRY — skomplikowane
function formatEntity<T extends Record<string, any>>(
    entity: T,
    fields: (keyof T)[],
    formatters: Partial<Record<keyof T, (v: any) => string>>
): string {
    return fields
        .map(f => (formatters[f] || String)(entity[f]))
        .join(', ');
}

// KISS — proste i czytelne, nawet jezeli jest lekka powtarzalnosc
function formatUser(user: User): string {
    return `${user.name} (${user.email})`;
}

function formatProduct(product: Product): string {
    return `${product.name} — ${product.price} PLN`;
}
```

### YAGNI vs OCP

YAGNI mówi "nie buduj na zapas", a OCP mówi "zamknij na modyfikacje". Rozwiązanie: stosuj OCP **reaktywnie** — po trzeciej zmianie w tym samym miejscu, nie profilaktycznie.

## Praktyczne wskazówki

| Zasada | Stosuj gdy... | Nie stosuj gdy... |
|--------|-------------|-----------------|
| **DRY** | Ta sama wiedza powtarza się 3+ razy | Zbieżność jest przypadkowa |
| **KISS** | Istnieje prostsze rozwiązanie | Prostsze nie spełnia wymagań |
| **YAGNI** | Funkcja nie ma realnego użytkownika | Koszt późniejszego dodania jest wysoki |

## Podsumowanie

- DRY dotyczy duplikacji wiedzy, nie kodu — nie abstrahuj przypadkowych zbieżności
- Rule of Three: czekaj na trzecie powtórzenie przed refaktoryzacją
- KISS: wybieraj najprostsze rozwiązanie, które spełnia wymagania
- Rozróżniaj złożoność istotną (essential) od przypadkowej (accidental)
- YAGNI: nie implementuj "na zapas" — będziesz mieć lepsze wymagania gdy potrzeba się pojawi
- Te zasady mogą ze sobą kolidować — stosuj pragmatycznie, nie dogmatycznie
