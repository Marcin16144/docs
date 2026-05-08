# Architektura heksagonalna (Ports & Adapters)

## Czym jest architektura heksagonalna?

Architektura heksagonalna (zwana też Ports & Adapters) to wzorzec zaproponowany przez Alistaira Cockburna, w którym **domena aplikacji jest izolowana od świata zewnętrznego** za pomocą portów (interfejsów) i adapterów (implementacji). Rdzeń aplikacji nie wie nic o bazach danych, frameworkach czy protokołach komunikacji.

```
                    ┌──────────────────────┐
                    │    REST Adapter      │
                    │   (Spring MVC)       │
                    └──────────┬───────────┘
                               │
                    ┌──────────▼───────────┐
    ┌───────────┐   │      INPUT PORT      │   ┌────────────┐
    │  CLI      │──►│    (interfejs)       │   │  Message   │
    │  Adapter  │   │                      │   │  Adapter   │
    └───────────┘   │  ┌────────────────┐  │   └─────┬──────┘
                    │  │                │  │         │
                    │  │    DOMAIN      │  │◄────────┘
                    │  │    CORE        │  │
                    │  │  (logika biz.) │  │
                    │  │                │  │
                    │  └────────────────┘  │
                    │                      │
                    │    OUTPUT PORT        │
                    │    (interfejs)       │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                │                │
    ┌─────────▼──┐   ┌────────▼───┐   ┌───────▼────┐
    │ PostgreSQL │   │  Redis     │   │  External  │
    │  Adapter   │   │  Adapter   │   │  API       │
    │            │   │            │   │  Adapter   │
    └────────────┘   └────────────┘   └────────────┘
```

## Kluczowe koncepcje

### Domena (Core)
Serce aplikacji — zawiera **logikę biznesową, encje, Value Objects, reguły**. Nie zależy od żadnej infrastruktury.

### Porty (Ports)
Interfejsy definiujące **kontrakty komunikacji** między domeną a światem zewnętrznym:

- **Input Ports** (Driving/Primary) — jak świat zewnętrzny wywołuje domenę
- **Output Ports** (Driven/Secondary) — jak domena komunikuje się ze światem zewnętrznym

### Adaptery (Adapters)
Implementacje portów — **mosty między technologią a domeną**:

- **Input Adapters** (Driving) — REST controller, CLI, GUI, Message listener
- **Output Adapters** (Driven) — Repozytorium SQL, klient HTTP, adapter email

## Struktura projektu

```
src/
├── domain/                          # RDZEŃ — zero zależności zewnętrznych
│   ├── model/
│   │   ├── Order.java               # Encja domenowa
│   │   ├── OrderId.java             # Value Object
│   │   ├── Money.java               # Value Object
│   │   └── OrderStatus.java         # Enum
│   ├── port/
│   │   ├── input/                   # Input Ports (use cases)
│   │   │   ├── CreateOrderUseCase.java
│   │   │   ├── GetOrderUseCase.java
│   │   │   └── CancelOrderUseCase.java
│   │   └── output/                  # Output Ports
│   │       ├── OrderRepository.java
│   │       ├── PaymentGateway.java
│   │       └── NotificationSender.java
│   └── service/
│       └── OrderService.java        # Implementacja use case'ów
│
├── adapter/
│   ├── input/                       # Input Adapters (driving)
│   │   ├── rest/
│   │   │   ├── OrderController.java
│   │   │   ├── OrderRequest.java
│   │   │   └── OrderResponse.java
│   │   ├── cli/
│   │   │   └── OrderCli.java
│   │   └── messaging/
│   │       └── OrderEventListener.java
│   └── output/                      # Output Adapters (driven)
│       ├── persistence/
│       │   ├── JpaOrderRepository.java
│       │   ├── OrderEntity.java
│       │   └── OrderMapper.java
│       ├── payment/
│       │   └── StripePaymentAdapter.java
│       └── notification/
│           └── EmailNotificationAdapter.java
│
└── config/
    └── BeanConfiguration.java       # Wiring — łączenie portów z adapterami
```

## Porty — szczegóły

### Input Ports (Use Cases)

```java
// Port wejściowy — definiuje co aplikacja potrafi zrobić
public interface CreateOrderUseCase {
    OrderId execute(CreateOrderCommand command);
}

public interface GetOrderUseCase {
    OrderView execute(GetOrderQuery query);
}

public interface CancelOrderUseCase {
    void execute(CancelOrderCommand command);
}

// Komenda (dane wejściowe)
public record CreateOrderCommand(
    String customerId,
    List<OrderItemDto> items,
    String shippingAddress
) {}
```

### Output Ports (SPI — Service Provider Interface)

```java
// Port wyjściowy — czego domena potrzebuje od infrastruktury
public interface OrderRepository {
    void save(Order order);
    Optional<Order> findById(OrderId id);
    List<Order> findByCustomerId(String customerId);
}

public interface PaymentGateway {
    PaymentResult charge(Money amount, PaymentMethod method);
    void refund(PaymentId paymentId);
}

public interface NotificationSender {
    void sendOrderConfirmation(Order order);
    void sendShipmentNotification(Order order, TrackingInfo info);
}
```

## Adaptery — implementacje

### Input Adapter — REST Controller

```java
@RestController
@RequestMapping("/api/orders")
public class OrderController {
    // Kontroler zależy od PORTU, nie od implementacji
    private final CreateOrderUseCase createOrder;
    private final GetOrderUseCase getOrder;

    @PostMapping
    public ResponseEntity<OrderResponse> create(
            @RequestBody OrderRequest request) {
        // Mapowanie: HTTP request → Command domenowy
        var command = new CreateOrderCommand(
            request.customerId(),
            request.items(),
            request.shippingAddress()
        );

        OrderId id = createOrder.execute(command);

        return ResponseEntity
            .created(URI.create("/api/orders/" + id.value()))
            .body(new OrderResponse(id.value()));
    }

    @GetMapping("/{id}")
    public OrderResponse get(@PathVariable String id) {
        return getOrder.execute(new GetOrderQuery(id));
    }
}
```

### Output Adapter — Repozytorium JPA

```java
@Repository
public class JpaOrderRepository implements OrderRepository {
    private final JpaOrderEntityRepository jpaRepo;
    private final OrderMapper mapper;

    @Override
    public void save(Order order) {
        // Mapowanie: Encja domenowa → Encja JPA
        OrderEntity entity = mapper.toEntity(order);
        jpaRepo.save(entity);
    }

    @Override
    public Optional<Order> findById(OrderId id) {
        return jpaRepo.findById(id.value())
            .map(mapper::toDomain);
    }
}

// Mapper — izolacja modelu domenowego od modelu bazy
public class OrderMapper {
    public OrderEntity toEntity(Order order) {
        return new OrderEntity(
            order.getId().value(),
            order.getCustomerId(),
            order.getTotal().amount(),
            order.getStatus().name()
        );
    }

    public Order toDomain(OrderEntity entity) {
        return Order.reconstitute(
            new OrderId(entity.getId()),
            entity.getCustomerId(),
            Money.of(entity.getTotal()),
            OrderStatus.valueOf(entity.getStatus())
        );
    }
}
```

### Output Adapter — External API

```java
@Component
public class StripePaymentAdapter implements PaymentGateway {
    private final StripeClient stripeClient;

    @Override
    public PaymentResult charge(Money amount, PaymentMethod method) {
        try {
            var charge = stripeClient.charges().create(
                ChargeCreateParams.builder()
                    .setAmount(amount.toCents())
                    .setCurrency("pln")
                    .setSource(method.token())
                    .build()
            );
            return PaymentResult.success(
                new PaymentId(charge.getId()));
        } catch (StripeException e) {
            return PaymentResult.failure(e.getMessage());
        }
    }
}
```

## Implementacja domeny (Service)

```java
// Implementacja use case'a — czysta logika biznesowa
public class OrderService implements CreateOrderUseCase,
                                     CancelOrderUseCase {
    private final OrderRepository orderRepo;      // output port
    private final PaymentGateway paymentGateway;   // output port
    private final NotificationSender notifications; // output port

    @Override
    public OrderId execute(CreateOrderCommand cmd) {
        // Czysta logika biznesowa — zero infrastruktury
        Order order = Order.create(
            cmd.customerId(),
            cmd.items(),
            cmd.shippingAddress()
        );

        PaymentResult payment = paymentGateway.charge(
            order.getTotal(),
            cmd.paymentMethod()
        );

        if (payment.isFailure()) {
            throw new PaymentFailedException(payment.errorMessage());
        }

        order.markAsPaid(payment.paymentId());
        orderRepo.save(order);
        notifications.sendOrderConfirmation(order);

        return order.getId();
    }

    @Override
    public void execute(CancelOrderCommand cmd) {
        Order order = orderRepo.findById(new OrderId(cmd.orderId()))
            .orElseThrow(() -> new OrderNotFoundException(cmd.orderId()));

        order.cancel();  // reguła biznesowa wewnątrz encji
        orderRepo.save(order);
    }
}
```

## Wiring — łączenie portów z adapterami

```java
@Configuration
public class BeanConfiguration {
    @Bean
    public CreateOrderUseCase createOrderUseCase(
            OrderRepository orderRepo,
            PaymentGateway paymentGateway,
            NotificationSender notifications) {
        return new OrderService(orderRepo, paymentGateway, notifications);
    }

    // Spring automatycznie wstrzykuje adaptery implementujące porty:
    // OrderRepository     → JpaOrderRepository
    // PaymentGateway      → StripePaymentAdapter
    // NotificationSender  → EmailNotificationAdapter
}
```

## Korzyści z testowania

```
┌─────────────────────────────────────────────────────────┐
│              TESTOWANIE HEKSAGONALNE                     │
│                                                         │
│  Unit testy domeny:        Testy integracyjne:          │
│  ┌─────────────────┐      ┌─────────────────┐          │
│  │ Domain + Mocki   │      │ Adapter + Real  │          │
│  │ (InMemory repo)  │      │ (Testcontainers)│          │
│  │                  │      │                 │          │
│  │ SZYBKIE          │      │ WOLNIEJSZE      │          │
│  │ Bez infrastrukt. │      │ Z infrastrukt.  │          │
│  └─────────────────┘      └─────────────────┘          │
│                                                         │
│  Testy akceptacyjne (E2E):                              │
│  ┌─────────────────────────────────────┐                │
│  │ Input Adapter → Domain → Output Adapter │             │
│  │ (HTTP request → logika → baza danych)    │            │
│  └─────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────┘
```

### Testy domeny z InMemory Adapter

```java
class OrderServiceTest {
    // InMemory adapter — test bez bazy danych
    private InMemoryOrderRepository orderRepo =
        new InMemoryOrderRepository();
    private FakePaymentGateway paymentGateway =
        new FakePaymentGateway();
    private SpyNotificationSender notifications =
        new SpyNotificationSender();

    private CreateOrderUseCase useCase =
        new OrderService(orderRepo, paymentGateway, notifications);

    @Test
    void shouldCreateOrder() {
        var command = new CreateOrderCommand(
            "cust-1",
            List.of(new OrderItemDto("prod-1", 2)),
            "Warszawa"
        );

        OrderId id = useCase.execute(command);

        assertThat(orderRepo.findById(id)).isPresent();
        assertThat(notifications.sentConfirmations()).hasSize(1);
    }

    @Test
    void shouldRejectWhenPaymentFails() {
        paymentGateway.willFail("Insufficient funds");

        assertThatThrownBy(() -> useCase.execute(command))
            .isInstanceOf(PaymentFailedException.class);
    }
}
```

## Porównanie z Clean Architecture

```
Architektura heksagonalna:      Clean Architecture (Uncle Bob):

  ┌─────────────────────┐       ┌─────────────────────────┐
  │ Adaptery zewnętrzne │       │ Frameworks & Drivers     │
  │  ┌───────────────┐  │       │  ┌─────────────────────┐│
  │  │    Porty      │  │       │  │  Interface Adapters  ││
  │  │ ┌───────────┐ │  │       │  │  ┌───────────────┐  ││
  │  │ │  Domain   │ │  │       │  │  │  Use Cases    │  ││
  │  │ │  Core     │ │  │       │  │  │ ┌───────────┐ │  ││
  │  │ └───────────┘ │  │       │  │  │ │ Entities  │ │  ││
  │  └───────────────┘  │       │  │  │ └───────────┘ │  ││
  └─────────────────────┘       │  │  └───────────────┘  ││
                                │  └─────────────────────┘│
  2 warstwy logiczne            └─────────────────────────┘
  (inside/outside)              4 warstwy koncentryczne
```

| Aspekt | Heksagonalna | Clean Architecture |
|--------|-------------|-------------------|
| Autor | Alistair Cockburn | Robert C. Martin |
| Warstwy | 2 (inside/outside) | 4 koncentryczne |
| Terminologia | Ports & Adapters | Entities, Use Cases, Adapters, Frameworks |
| Kierunek zależności | Ku centrum | Ku centrum (Dependency Rule) |
| Nacisk | Izolacja domeny od I/O | Pełna separacja warstw |

**W praktyce:** oba podejścia prowadzą do bardzo podobnej struktury kodu. Clean Architecture jest bardziej formalna z czterema warstwami, heksagonalna jest prostsza koncepcyjnie.

## Kierunek zależności

```
ZASADA: Zależności zawsze wskazują DO ŚRODKA (ku domenie)

Adaptery ──────► Porty ──────► Domena

✓ Controller → CreateOrderUseCase → Order
✓ JpaOrderRepo → OrderRepository (implementuje interfejs domeny)

✗ Order → JpaOrderRepository (NIGDY — domena nie zna infrastruktury)
✗ OrderService → HttpClient (NIGDY — użyj output portu)
```

## Kiedy stosować?

### Idealny dla:
- Złożonej logiki biznesowej (DDD)
- Systemów wymagających łatwej wymiany technologii
- Projektów z wieloma interfejsami wejściowymi (REST, CLI, events)
- Aplikacji z wymaganiem wysokiej testowalności
- Długowiecznych systemów (5+ lat utrzymania)

### Nadmiarowy dla:
- Prostych aplikacji CRUD
- Prototypów i MVP
- Bardzo małych projektów (1-2 deweloperów)
- Skryptów i narzędzi jednorazowych

## Zalety i wady

### Zalety
- Domena wolna od zależności infrastrukturalnych
- Łatwa wymiana adapterów (zmiana bazy danych, providera)
- Doskonała testowalność (unit testy bez infrastruktury)
- Jasne granice i kontrakty (porty)
- Naturalnie wspiera DDD

### Wady
- Więcej kodu boilerplate (mapowania, interfejsy)
- Krzywa uczenia się dla zespołu
- Overhead dla prostych operacji CRUD
- Ryzyko over-engineering w małych projektach

## Podsumowanie

Architektura heksagonalna to **fundament dla systemów z bogatą logiką biznesową**. Izolacja domeny przez porty i adaptery daje niezrównaną testowalność i elastyczność technologiczną. Kluczowe jest utrzymanie zasady, że **zależności zawsze wskazują ku centrum** — domena nigdy nie wie o infrastrukturze.
