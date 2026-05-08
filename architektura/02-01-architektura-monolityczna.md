# Architektura monolityczna

## Czym jest monolit?

Architektura monolityczna to podejście, w którym cała aplikacja jest budowana, wdrażana i skalowana jako **jedna, spójna jednostka**. Wszystkie funkcjonalności — od interfejsu użytkownika, przez logikę biznesową, po dostęp do danych — działają w ramach jednego procesu.

```
┌─────────────────────────────────────────────────┐
│                   MONOLIT                        │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │    UI     │  │  Zamów.  │  │  Płatn.  │      │
│  │  Layer    │  │  Moduł   │  │  Moduł   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │  Użytk.  │  │ Magazyn  │  │ Raporty  │      │
│  │  Moduł   │  │  Moduł   │  │  Moduł   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
│                                                  │
│  ┌─────────────────────────────────────────┐    │
│  │         Wspólna baza danych             │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

## Struktura typowego monolitu

### Monolit jednowarstwowy (prosty)
Cała logika w jednym projekcie bez wyraźnego podziału:
```
src/
├── controllers/
│   ├── OrderController.java
│   ├── UserController.java
│   └── PaymentController.java
├── services/
│   ├── OrderService.java
│   ├── UserService.java
│   └── PaymentService.java
├── repositories/
│   ├── OrderRepository.java
│   └── UserRepository.java
├── models/
│   ├── Order.java
│   └── User.java
└── Application.java
```

### Monolit modularny (strukturalny)
Podział na moduły z wyraźnymi granicami:
```
src/
├── modules/
│   ├── orders/
│   │   ├── api/OrderController.java
│   │   ├── domain/Order.java
│   │   ├── service/OrderService.java
│   │   └── repository/OrderRepository.java
│   ├── users/
│   │   ├── api/UserController.java
│   │   ├── domain/User.java
│   │   └── service/UserService.java
│   └── payments/
│       ├── api/PaymentController.java
│       └── service/PaymentService.java
├── shared/
│   ├── config/
│   └── utils/
└── Application.java
```

## Deployment monolitu

```
┌─────────────────────────────────────────┐
│            Pipeline CI/CD               │
│                                         │
│  Kod → Build → Test → Pakiet → Deploy   │
│                          │               │
│                    app-v2.3.war          │
│                          │               │
│              ┌───────────┴──────────┐   │
│              ▼                      ▼   │
│         Serwer 1              Serwer 2  │
│        (aktywny)             (standby)  │
└─────────────────────────────────────────┘
```

**Typowe strategie wdrożenia:**
- **Rolling deployment** — stopniowa wymiana instancji
- **Blue-Green deployment** — dwa identyczne środowiska
- **Canary release** — nowa wersja na małym % ruchu

## Strategie skalowania

### Skalowanie pionowe (Vertical Scaling)
```
Przed:                    Po:
┌────────┐               ┌────────────┐
│ 4 CPU  │               │   16 CPU   │
│ 8 GB   │  ──upgrade──► │   64 GB    │
│ 100 GB │               │   1 TB SSD │
└────────┘               └────────────┘
```
- Prosta realizacja — większy serwer
- Ograniczona skalowalność (fizyczne limity)
- Single point of failure

### Skalowanie poziome (Horizontal Scaling)
```
                  ┌──────────┐
            ┌────►│ Instancja│
            │     │    1     │
┌────────┐  │     └──────────┘
│  Load  │──┤     ┌──────────┐
│Balancer│──┼────►│ Instancja│
│        │──┤     │    2     │
└────────┘  │     └──────────┘
            │     ┌──────────┐
            └────►│ Instancja│
                  │    3     │
                  └──────────┘
```
- Wymaga aplikacji bezstanowej (stateless)
- Sesje w zewnętrznym store (Redis, DB)
- Współdzielona baza danych może być wąskim gardłem

## Modularyzacja wewnątrz monolitu

### Zasady dobrej modularyzacji
1. **Wysoka spójność** (high cohesion) — moduł realizuje jedną odpowiedzialność
2. **Luźne powiązania** (low coupling) — moduły komunikują się przez interfejsy
3. **Enkapsulacja** — wewnętrzne szczegóły modułu są ukryte
4. **Jawne zależności** — graf zależności jest czytelny

### Egzekwowanie granic modułów

```java
// Interfejs publiczny modułu zamówień
public interface OrderFacade {
    OrderDto createOrder(CreateOrderCommand cmd);
    OrderDto getOrder(OrderId id);
    List<OrderDto> getUserOrders(UserId userId);
}

// Implementacja ukryta w module
class OrderFacadeImpl implements OrderFacade {
    private final OrderRepository repository;
    private final OrderValidator validator;
    
    @Override
    public OrderDto createOrder(CreateOrderCommand cmd) {
        validator.validate(cmd);
        Order order = Order.create(cmd);
        repository.save(order);
        return OrderDto.from(order);
    }
}
```

### Narzędzia do egzekwowania granic
- **ArchUnit** (Java) — testy architektury
- **NetArchTest** (.NET) — testy zależności
- **Moduły Java 9+** (JPMS) — system modułów JVM
- **Gradle/Maven multi-module** — podział na podprojekty

```java
// ArchUnit — test architektury
@Test
void orderModuleShouldNotDependOnPaymentInternals() {
    noClasses()
        .that().resideInAPackage("..orders..")
        .should().dependOnClassesThat()
        .resideInAPackage("..payments.internal..")
        .check(classes);
}
```

## Kiedy monolit to właściwy wybór?

### Idealny dla:
- **Małych zespołów** (2-10 deweloperów) — prostsze zarządzanie kodem
- **MVP i prototypów** — szybki time-to-market
- **Domen o niskiej złożoności** — proste wymagania biznesowe
- **Projektów z ograniczonym budżetem** — mniejszy koszt infrastruktury
- **Rozpoczynania nowego projektu** — lepsze zrozumienie domeny przed podziałem

### Problematyczny dla:
- **Dużych zespołów** (50+ deweloperów) — konflikty merge, długie buildy
- **Wymagań niezależnego skalowania** — np. moduł raportów wymaga 10x więcej zasobów
- **Różnych cykli wdrożeń** — zmiana w jednym module wymusza deploy całości
- **Polyglot programming** — brak możliwości użycia różnych technologii

## Zalety i wady

### Zalety
- Prostota wdrożenia i debugowania
- Brak złożoności rozproszonej (sieć, serializacja)
- Łatwe testowanie end-to-end
- Proste transakcje ACID
- Niski próg wejścia dla nowych deweloperów
- Niższy koszt infrastruktury

### Wady
- Dłuższy czas buildu przy rosnącym kodzie
- Jeden deployment dla wszystkich zmian
- Awaria jednego modułu może zepsuć całą aplikację
- Trudność skalowania poszczególnych komponentów
- Technologiczny lock-in (jeden stack)
- "Big Ball of Mud" przy braku dyscypliny

## Ścieżki migracji z monolitu

### Strangler Fig Pattern
```
Faza 1: Monolit obsługuje 100% ruchu
┌───────────────┐
│   MONOLIT     │ ← cały ruch
└───────────────┘

Faza 2: Nowe funkcje w serwisach
┌──────────┐  ┌─────────────┐
│ Serwis A │  │   MONOLIT   │
└──────────┘  └─────────────┘
     ↑              ↑
     └──── Router ──┘

Faza 3: Stopniowa ekstrakcja
┌──────────┐ ┌──────────┐ ┌─────────┐
│ Serwis A │ │ Serwis B │ │ MONOLIT │
└──────────┘ └──────────┘ │(mniejsz)│
     ↑            ↑       └─────────┘
     └──── Router ────────────┘

Faza 4: Monolit wygaszony
┌──────────┐ ┌──────────┐ ┌──────────┐
│ Serwis A │ │ Serwis B │ │ Serwis C │
└──────────┘ └──────────┘ └──────────┘
```

### Branch by Abstraction
1. Utwórz abstrakcję (interfejs) nad fragmentem do wydzielenia
2. Zmień klientów, aby korzystali z abstrakcji
3. Utwórz nową implementację (mikroserwis)
4. Przełącz abstrakcję na nową implementację
5. Usuń starą implementację

## Anty-wzorce monolitu

### Big Ball of Mud
- Brak wyraźnej struktury
- Każdy moduł zależy od każdego
- Zmiany wywołują kaskadę nieoczekiwanych efektów

### Distributed Monolith
- Pozornie osobne serwisy, ale ściśle powiązane
- Deploy wymaga jednoczesnego wdrożenia wielu serwisów
- Najgorsze z dwóch światów: złożoność rozproszonego + sztywność monolitu

## Podsumowanie

Architektura monolityczna nie jest "przestarzała" ani "zła". To **świadomy wybór architektoniczny**, który w wielu sytuacjach jest optymalny. Kluczem jest utrzymanie wewnętrznej modularyzacji, aby w przyszłości migracja do innej architektury (jeśli zajdzie taka potrzeba) była wykonalna.
