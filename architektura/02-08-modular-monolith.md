# Modular Monolith

## Czym jest Modular Monolith?

Modular Monolith to architektura, która łączy **prostotę deploymentu monolitu** z **klarownością granic modułów znaną z mikroserwisów**. System jest wdrażany jako jedna jednostka, ale wewnętrznie podzielony na autonomiczne moduły z jasno zdefiniowanymi granicami, interfejsami i zasadami komunikacji.

```
┌─────────────────────────────────────────────────────────┐
│                    MODULAR MONOLITH                      │
│                    (jeden deployment)                     │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │  Moduł:     │  │  Moduł:     │  │  Moduł:     │     │
│  │  Zamówienia │  │  Płatności  │  │  Wysyłka    │     │
│  │             │  │             │  │             │     │
│  │  ┌───────┐  │  │  ┌───────┐  │  │  ┌───────┐  │     │
│  │  │ API   │  │  │  │ API   │  │  │  │ API   │  │     │
│  │  │publicz│  │  │  │publicz│  │  │  │publicz│  │     │
│  │  ├───────┤  │  │  ├───────┤  │  │  ├───────┤  │     │
│  │  │Domena │  │  │  │Domena │  │  │  │Domena │  │     │
│  │  ├───────┤  │  │  ├───────┤  │  │  ├───────┤  │     │
│  │  │Infra  │  │  │  │Infra  │  │  │  │Infra  │  │     │
│  │  └───────┘  │  │  └───────┘  │  │  └───────┘  │     │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘     │
│         │                │                │              │
│  ┌──────┴────────────────┴────────────────┴──────┐      │
│  │           Współdzielona baza danych            │      │
│  │    (ale osobne schematy per moduł!)            │      │
│  └────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

## Dlaczego Modular Monolith?

### Problem z klasycznym monolitem
```
Klasyczny monolit (Big Ball of Mud):

  OrderService → UserService → PaymentService
       ↑              │              │
       └──────────────┘              │
              ↑                      │
              └──────────────────────┘
              
  Wszystko zależy od wszystkiego.
  Zmiana w jednym miejscu = niespodzianki wszędzie.
```

### Problem z przedwczesnymi mikroserwisami
```
Mikroserwisy za wcześnie:

  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐
  │Svc A│  │Svc B│  │Svc C│  │Svc D│  │Svc E│
  └──┬──┘  └──┬──┘  └──┬──┘  └──┬──┘  └──┬──┘
     │        │        │        │        │
  Docker, Kubernetes, Service Mesh, Distributed Tracing,
  Message Broker, API Gateway, Circuit Breaker...
  
  Ogromny overhead infrastrukturalny dla 5-osobowego zespołu.
```

### Modular Monolith — złoty środek
```
Modular Monolith:

  ┌───────────────────────────────────────────┐
  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
  │  │ Moduł A │  │ Moduł B │  │ Moduł C │  │
  │  │ (jasne  │  │ (jasne  │  │ (jasne  │  │
  │  │granice) │  │granice) │  │granice) │  │
  │  └─────────┘  └─────────┘  └─────────┘  │
  │                                           │
  │  Jeden deployment + proste operacje       │
  │  Gotowość do przyszłej dekompozycji       │
  └───────────────────────────────────────────┘
```

## Granice modułów

### Zasady definiowania granic

1. **Bounded Context z DDD** — moduł = bounded context
2. **Wysoka kohezja** — elementy w module są silnie powiązane
3. **Luźne powiązania** — moduły komunikują się tylko przez publiczne API
4. **Enkapsulacja** — wewnętrzne klasy modułu są niedostępne z zewnątrz

### Struktura modułu

```
modules/
├── orders/                          # Moduł zamówień
│   ├── api/                         # PUBLICZNE API modułu
│   │   ├── OrderFacade.java         # Fasada — jedyny punkt wejścia
│   │   ├── OrderDto.java            # DTO dla klientów
│   │   ├── CreateOrderCommand.java  # Komendy
│   │   └── OrderEvents.java         # Zdarzenia domenowe
│   │
│   ├── internal/                    # WEWNĘTRZNE — niedostępne z zewnątrz
│   │   ├── domain/
│   │   │   ├── Order.java
│   │   │   ├── OrderItem.java
│   │   │   └── OrderPolicy.java
│   │   ├── infrastructure/
│   │   │   ├── JpaOrderRepository.java
│   │   │   └── OrderEntity.java
│   │   └── application/
│   │       ├── OrderService.java
│   │       └── OrderEventHandler.java
│   │
│   └── OrderModuleConfig.java       # Konfiguracja Spring
│
├── payments/                        # Moduł płatności
│   ├── api/
│   │   ├── PaymentFacade.java
│   │   └── PaymentDto.java
│   └── internal/
│       └── ...
│
└── shipping/                        # Moduł wysyłki
    ├── api/
    │   ├── ShippingFacade.java
    │   └── ShippingDto.java
    └── internal/
        └── ...
```

### Fasada modułu — publiczny kontrakt

```java
// Jedyny punkt wejścia do modułu zamówień
public interface OrderFacade {
    // Komendy
    OrderId createOrder(CreateOrderCommand command);
    void cancelOrder(CancelOrderCommand command);
    void addItem(AddItemCommand command);
    
    // Zapytania
    OrderDto getOrder(OrderId orderId);
    List<OrderDto> getOrdersByCustomer(CustomerId customerId);
    OrderSummaryDto getOrderSummary(OrderId orderId);
}

// Implementacja — deleguje do wewnętrznych serwisów
class OrderFacadeImpl implements OrderFacade {
    private final OrderService orderService;
    private final OrderQueryService queryService;
    
    @Override
    public OrderId createOrder(CreateOrderCommand command) {
        return orderService.create(command);
    }
    
    @Override
    public OrderDto getOrder(OrderId orderId) {
        return queryService.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
    }
}
```

## Komunikacja między modułami

### 1. Wywołania synchroniczne (przez fasady)

```java
// Moduł zamówień wywołuje moduł płatności
class OrderService {
    private final PaymentFacade paymentFacade;  // fasada innego modułu
    
    public OrderId create(CreateOrderCommand cmd) {
        Order order = Order.create(cmd);
        orderRepo.save(order);
        
        // Wywołanie innego modułu przez jego publiczne API
        PaymentResult result = paymentFacade.processPayment(
            new ProcessPaymentCommand(order.getId(), order.getTotal())
        );
        
        if (result.isSuccess()) {
            order.markAsPaid();
            orderRepo.save(order);
        }
        
        return order.getId();
    }
}
```

### 2. Zdarzenia domenowe (asynchroniczne, in-process)

```java
// Moduł zamówień publikuje zdarzenie
class OrderService {
    private final EventPublisher eventPublisher;
    
    public OrderId create(CreateOrderCommand cmd) {
        Order order = Order.create(cmd);
        orderRepo.save(order);
        
        // Publikacja zdarzenia — moduł zamówień nie wie kto nasłuchuje
        eventPublisher.publish(new OrderCreatedEvent(
            order.getId(),
            order.getCustomerId(),
            order.getTotal()
        ));
        
        return order.getId();
    }
}

// Moduł płatności nasłuchuje zdarzenia
class PaymentEventHandler {
    private final PaymentService paymentService;
    
    @EventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        paymentService.initiatePayment(
            event.orderId(),
            event.total()
        );
    }
}

// Moduł powiadomień — też nasłuchuje tego samego zdarzenia
class NotificationEventHandler {
    @EventListener
    public void onOrderCreated(OrderCreatedEvent event) {
        emailService.sendOrderConfirmation(event.customerId());
    }
}
```

### 3. Porównanie podejść

| Aspekt | Synchroniczne (fasady) | Asynchroniczne (eventy) |
|--------|----------------------|------------------------|
| Powiązanie | Bezpośrednie (zna fasadę) | Luźne (nie zna konsumenta) |
| Transakcja | Może być w jednej TX | Eventual consistency |
| Debugowanie | Proste (call stack) | Trudniejsze (śledzenie eventów) |
| Rozszerzalność | Wymaga zmian w callerze | Nowy listener bez zmian |
| Gotowość na mikroserwisy | Średnia | Wysoka |

### Rekomendacja
- **Fasady** — dla zapytań (queries) i synchronicznych komend krytycznych
- **Eventy** — dla powiadomień, efektów ubocznych, rozszerzalności

## Schematy bazodanowe

### Osobne schematy per moduł

```sql
-- Moduł zamówień — własny schemat
CREATE SCHEMA orders;

CREATE TABLE orders.order (
    id UUID PRIMARY KEY,
    customer_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders.order_item (
    id UUID PRIMARY KEY,
    order_id UUID REFERENCES orders.order(id),
    product_id UUID NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Moduł płatności — własny schemat
CREATE SCHEMA payments;

CREATE TABLE payments.payment (
    id UUID PRIMARY KEY,
    order_id UUID NOT NULL,  -- referencja po ID, nie FK!
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    provider VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);
-- BRAK FOREIGN KEY do orders.order — izolacja modułów!
```

### Zasady izolacji danych

```
REGUŁY:
1. Moduł A NIE czyta tabel modułu B bezpośrednio (brak JOIN)
2. Moduł A NIE pisze do tabel modułu B
3. Referencje między modułami — tylko po ID (nie FK)
4. Dane potrzebne z innego modułu — przez fasadę lub event

✗ ZŁE:
SELECT o.*, p.status as payment_status
FROM orders.order o
JOIN payments.payment p ON o.id = p.order_id;

✓ DOBRE:
// W module zamówień:
OrderDto order = orderFacade.getOrder(orderId);
// W module płatności:
PaymentDto payment = paymentFacade.getPaymentForOrder(orderId);
// Kompozycja w warstwie prezentacji:
OrderWithPaymentView view = new OrderWithPaymentView(order, payment);
```

## Egzekwowanie granic

### ArchUnit (Java)

```java
@AnalyzeClasses(packages = "com.example")
class ModuleBoundaryTest {
    
    @ArchTest
    static final ArchRule ordersInternalNotAccessible =
        noClasses()
            .that().resideOutsideOfPackage("..orders..")
            .should().accessClassesThat()
            .resideInAPackage("..orders.internal..")
            .because("Modul orders udostepnia tylko pakiet api/");
    
    @ArchTest
    static final ArchRule modulesCommunicateViaFacades =
        noClasses()
            .that().resideInAPackage("..orders.internal..")
            .should().accessClassesThat()
            .resideInAPackage("..payments.internal..")
            .because("Moduly komunikuja sie tylko przez fasady");
    
    @ArchTest
    static final ArchRule noDirectDbAccessBetweenModules =
        noClasses()
            .that().resideInAPackage("..orders..")
            .should().accessClassesThat()
            .resideInAPackage("..payments..infrastructure..")
            .because("Brak bezposredniego dostepu do BD innego modulu");
}
```

### Java Modules (JPMS)

```java
// module-info.java modułu zamówień
module orders {
    // Eksportuje TYLKO publiczne API
    exports com.example.orders.api;
    
    // Wewnętrzne pakiety NIE SĄ eksportowane
    // com.example.orders.internal — niedostępny z zewnątrz
    
    // Zależności od innych modułów
    requires payments;  // potrzebuje PaymentFacade
    requires shared;    // współdzielone DTO, eventy
}
```

### Gradle Multi-Module

```groovy
// settings.gradle
include 'shared'
include 'orders'
include 'payments'
include 'shipping'
include 'app'  // łączy wszystko

// orders/build.gradle
dependencies {
    implementation project(':shared')
    implementation project(':payments')  // zależy od fasady
    // NIE: implementation project(':shipping')
}
```

## Migracja do mikroserwisów

### Kiedy się rozdzielać?

```
Sygnały do dekompozycji:

1. Moduł wymaga niezależnego skalowania
   Zamówienia: 100 req/s
   Raporty:    2 req/s ale każdy trwa 30 sekund
   → Wydziel moduł raportów do osobnego serwisu

2. Różne cykle wdrożeń
   Płatności: deploy 1x/tydzień (wymaga audytu)
   Katalog:   deploy 5x/dzień
   → Wydziel moduł płatności

3. Różne wymagania technologiczne
   Wyszukiwarka: Elasticsearch
   Zamówienia:   PostgreSQL
   → Wydziel moduł wyszukiwarki

4. Zespoły się blokują
   → Boundary jest gotowy do wydzielenia
```

### Ścieżka migracji

```
Faza 1: Modular Monolith (dobrze zdefiniowane granice)
┌─────────────────────────────────────┐
│  [Zamówienia] [Płatności] [Wysyłka] │
│            Jeden proces              │
└─────────────────────────────────────┘

Faza 2: Wydzielenie pierwszego modułu
┌─────────────────────────┐  ┌──────────┐
│  [Zamówienia] [Wysyłka] │  │Płatności │
│       Monolit           │  │(osobny   │
│                         │←→│ serwis)  │
└─────────────────────────┘  └──────────┘

Faza 3: Kolejne wydzielenia (jeśli potrzebne)
┌─────────────┐  ┌──────────┐  ┌──────────┐
│ Zamówienia  │  │Płatności │  │ Wysyłka  │
│             │←→│          │←→│          │
└─────────────┘  └──────────┘  └──────────┘
```

### Co ułatwia przyszłą dekompozycję?
1. **Komunikacja przez fasady** — zamień na HTTP/gRPC call
2. **Zdarzenia domenowe** — zamień na message broker (Kafka/RabbitMQ)
3. **Osobne schematy DB** — przenieś schemat do osobnej bazy
4. **Brak współdzielonych tabel** — czysta izolacja danych
5. **Testy architektury** — weryfikacja granic przed i po

## Praktyczna implementacja (Spring Boot)

### Konfiguracja modułu

```java
@Configuration
@ComponentScan(basePackages = "com.example.orders.internal")
public class OrderModuleConfig {
    
    @Bean
    public OrderFacade orderFacade(
            OrderRepository orderRepo,
            EventPublisher eventPublisher) {
        return new OrderFacadeImpl(
            new OrderService(orderRepo, eventPublisher),
            new OrderQueryService(orderRepo)
        );
    }
}
```

### Event Publisher (in-process)

```java
@Component
public class SpringEventPublisher implements EventPublisher {
    private final ApplicationEventPublisher spring;
    
    @Override
    public void publish(DomainEvent event) {
        spring.publishEvent(event);
    }
}

// Przy migracji do mikroserwisów — zamień na:
@Component
public class KafkaEventPublisher implements EventPublisher {
    private final KafkaTemplate<String, DomainEvent> kafka;
    
    @Override
    public void publish(DomainEvent event) {
        kafka.send("domain-events", event.aggregateId(), event);
    }
}
```

## Zalety i wady

### Zalety
- Prostota deploymentu (jeden artefakt)
- Jasne granice modułów (jak w mikroserwisach)
- Proste transakcje w ramach procesu
- Łatwe debugowanie (jeden proces, jeden stack trace)
- Niski koszt infrastruktury
- Gotowość do dekompozycji na mikroserwisy

### Wady
- Wymaga dyscypliny (łatwo złamać granice bez narzędzi)
- Jeden deployment dla wszystkich zmian
- Brak niezależnego skalowania modułów
- Technologiczny lock-in (jeden język/framework)
- Ryzyko powrotu do "Big Ball of Mud" bez testów architektury

## Kiedy stosować?

### Idealny dla:
- Nowych projektów (zamiast startowania od mikroserwisów)
- Średnich zespołów (5-30 deweloperów)
- Systemów ze złożoną logiką biznesową
- Sytuacji, gdy nie wiesz jeszcze jakie będą granice modułów
- Migracji z chaotycznego monolitu

### Nieodpowiedni gdy:
- Wymagasz niezależnego skalowania modułów już teraz
- Potrzebujesz polyglot (różne języki per moduł)
- Masz 100+ deweloperów blokujących się na jednym repo
- Moduły mają fundamentalnie różne wymagania wydajnościowe

## Podsumowanie

Modular Monolith to **najlepszy punkt startowy** dla większości nowych projektów. Daje klarowność granic bez overhead'u systemów rozproszonych. Kluczem jest **dyscyplina w utrzymaniu granic** (ArchUnit, JPMS, multi-module) i projektowanie modułów tak, by mogły zostać wydzielone do osobnych serwisów gdy zajdzie realna potrzeba. To nie kompromis — to świadoma strategia.
