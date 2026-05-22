# Architektura warstwowa (N-Tier)

## Czym jest architektura warstwowa?

Architektura warstwowa to jeden z najstarszych i najczęściej stosowanych wzorców architektonicznych. Polega na **podziale aplikacji na poziome warstwy**, z których każda odpowiada za określony aspekt funkcjonalności. Warstwy komunikują się ze sobą w zdefiniowanym kierunku — zazwyczaj od góry do dołu.

```
┌──────────────────────────────────────┐
│        Warstwa prezentacji           │  ← UI, API controllers
├──────────────────────────────────────┤
│        Warstwa logiki biznesowej     │  ← Reguły, walidacja, procesy
├──────────────────────────────────────┤
│        Warstwa dostępu do danych     │  ← Repozytoria, ORM
├──────────────────────────────────────┤
│        Baza danych                   │  ← SQL, NoSQL
└──────────────────────────────────────┘
```

## Rodzaje warstwowania

### Strict Layering (ścisłe)
Warstwa może komunikować się **tylko z warstwą bezpośrednio pod nią**:

```
Prezentacja ──→ Logika biznesowa ──→ Dostęp do danych ──→ BD
     ✗ (nie może pominąć warstwy)
```

**Zalety:** silna enkapsulacja, łatwość wymiany warstw
**Wady:** overhead — czasem proste operacje CRUD przechodzą przez wszystkie warstwy

### Relaxed Layering (luźne)
Warstwa może komunikować się z **dowolną warstwą poniżej**:

```
Prezentacja ──→ Logika biznesowa ──→ Dostęp do danych ──→ BD
     │                                       ↑
     └───────────────────────────────────────┘
         (dozwolone pominięcie warstwy)
```

**Zalety:** wydajniejsze — unika niepotrzebnych pośredników
**Wady:** silniejsze powiązania, trudniejsza wymiana warstw

## Typowe warstwy w aplikacji webowej

### 4-warstwowy model klasyczny

```
┌─────────────────────────────────────────────┐
│  PRESENTATION LAYER                         │
│  - Controllery HTTP (REST/GraphQL)          │
│  - Walidacja wejścia (request DTO)          │
│  - Serializacja/deserializacja              │
│  - Obsługa błędów HTTP                      │
├─────────────────────────────────────────────┤
│  APPLICATION LAYER (Service Layer)          │
│  - Orkiestracja procesów biznesowych        │
│  - Koordynacja między serwisami domenowymi  │
│  - Transakcje                               │
│  - Autoryzacja                              │
├─────────────────────────────────────────────┤
│  DOMAIN LAYER                               │
│  - Encje biznesowe i Value Objects          │
│  - Reguły biznesowe                         │
│  - Interfejsy repozytoriów                  │
│  - Zdarzenia domenowe                       │
├─────────────────────────────────────────────┤
│  INFRASTRUCTURE LAYER                       │
│  - Implementacje repozytoriów               │
│  - ORM / klient bazy danych                 │
│  - Integracje zewnętrzne (HTTP, SMTP)       │
│  - Konfiguracja, logowanie                  │
└─────────────────────────────────────────────┘
```

### Przykład implementacji w .NET

```csharp
// === PRESENTATION LAYER ===
[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly IOrderService _orderService;

    [HttpPost]
    public async Task<ActionResult<OrderDto>> Create(
        CreateOrderRequest request)
    {
        var command = request.ToCommand();
        var result = await _orderService.CreateOrder(command);
        return CreatedAtAction(nameof(GetById),
            new { id = result.Id }, result);
    }
}

// === APPLICATION LAYER ===
public class OrderService : IOrderService
{
    private readonly IOrderRepository _orders;
    private readonly IPaymentGateway _payments;
    private readonly IUnitOfWork _unitOfWork;

    public async Task<OrderDto> CreateOrder(CreateOrderCommand cmd)
    {
        var order = Order.Create(cmd.CustomerId, cmd.Items);
        await _payments.AuthorizePayment(order.Total);
        _orders.Add(order);
        await _unitOfWork.SaveChanges();
        return OrderDto.From(order);
    }
}

// === DOMAIN LAYER ===
public class Order
{
    public OrderId Id { get; private set; }
    public CustomerId CustomerId { get; private set; }
    public Money Total { get; private set; }
    public OrderStatus Status { get; private set; }

    public static Order Create(CustomerId customerId,
        List<OrderItem> items)
    {
        if (!items.Any())
            throw new DomainException("Order must have items");
        return new Order(customerId, items);
    }
}

// === INFRASTRUCTURE LAYER ===
public class OrderRepository : IOrderRepository
{
    private readonly AppDbContext _context;

    public async Task<Order?> GetById(OrderId id) =>
        await _context.Orders
            .Include(o => o.Items)
            .FirstOrDefaultAsync(o => o.Id == id);
}
```

## Reguły zależności

### Zasada odwrócenia zależności (DIP)

```
Klasyczne zależności:          Z DIP:

Prezentacja                   Prezentacja
    │                             │
    ▼                             ▼
Logika biz.                   Logika biz. (definiuje interfejsy)
    │                             ↑
    ▼                             │
Infrastruktura                Infrastruktura (implementuje interfejsy)
```

**Kluczowa zasada:** warstwy wyższe definiują interfejsy (porty), warstwy niższe je implementują. Dzięki temu warstwa domenowa nie zależy od infrastruktury.

```csharp
// Domain Layer — definiuje interfejs
public interface IOrderRepository
{
    Task<Order?> GetById(OrderId id);
    void Add(Order order);
}

// Infrastructure Layer — implementuje
public class SqlOrderRepository : IOrderRepository
{
    // implementacja z Entity Framework
}
```

## Fizyczny deployment — warianty N-Tier

### 2-Tier (klient-serwer)
```
┌───────────┐        ┌──────────────┐
│  Klient   │──TCP──→│   Serwer BD  │
│  (gruby)  │        │              │
└───────────┘        └──────────────┘
```

### 3-Tier (klasyczny web)
```
┌──────────┐     ┌──────────────┐     ┌──────────┐
│ Przeglą- │HTTP │  Serwer      │ SQL │  Baza    │
│ darka    │────→│  aplikacji   │────→│  danych  │
└──────────┘     └──────────────┘     └──────────┘
```

### 4-Tier (z reverse proxy)
```
┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────┐
│ Przeglą- │──→│  Nginx/  │──→│ App      │──→│  BD  │
│ darka    │   │  CDN     │   │ Server   │   │      │
└──────────┘   └──────────┘   └──────────┘   └──────┘
```

## Anty-wzorce architektury warstwowej

### 1. Sinkhole Anti-Pattern
Żądanie przechodzi przez wszystkie warstwy bez żadnej logiki:
```
Controller → Service → Repository → DB
   (pass)    (pass)    (pass)
   
// Złe — service layer nic nie robi
public OrderDto GetOrder(int id) {
    return _repository.GetById(id).ToDto();
}
```

**Rozwiązanie:** jeśli 80%+ metod to "pass-through", rozważ relaxed layering lub CQRS.

### 2. Leaking Abstractions
Szczegóły warstwy niższej "wyciekają" do wyższej:
```csharp
// ZLE — controller zna szczegoly SQL
[HttpGet]
public async Task<IActionResult> Search(string query) {
    var sql = $"SELECT * FROM orders WHERE name LIKE '%{query}%'";
    var results = await _dbContext.Orders.FromSqlRaw(sql);
    return Ok(results);
}
```

### 3. Circular Dependencies
Warstwy zależą od siebie nawzajem — naruszenie hierarchii:
```
Service A → Repository B → Service A   ← cykl!
```

### 4. God Layer
Jedna warstwa (zwykle Service Layer) staje się "boska" — zawiera zbyt wiele logiki i odpowiedzialności.

## Porównanie z innymi podejściami

| Aspekt | Warstwowa | Heksagonalna | Mikroserwisy |
|--------|-----------|-------------|--------------|
| Złożoność | Niska | Średnia | Wysoka |
| Testowalność | Średnia | Wysoka | Wysoka |
| Elastyczność | Niska | Wysoka | Bardzo wysoka |
| Krzywa uczenia | Łagodna | Średnia | Stroma |
| Deployment | Jeden artefakt | Jeden artefakt | Wiele artefaktów |

## Kiedy stosować?

### Idealna dla:
- Aplikacji CRUD z prostą logiką biznesową
- Małych i średnich zespołów
- Projektów z ograniczonym czasem na architekturę
- Systemów, które nie wymagają niezależnego skalowania warstw

### Nieodpowiednia dla:
- Złożonej logiki domenowej (lepiej: heksagonalna / DDD)
- Systemów wymagających niezależnego deploymentu komponentów (lepiej: mikroserwisy)
- Aplikacji event-driven z asynchronicznym przetwarzaniem

## Podsumowanie

Architektura warstwowa to doskonały **punkt wyjścia** dla wielu projektów. Jest prosta, dobrze zrozumiana i sprawdza się w aplikacjach o umiarkowanej złożoności. Kluczowe jest przestrzeganie zasad zależności (DIP) i unikanie anty-wzorców, które z czasem mogą przekształcić czytelną strukturę w spaghetti code.
