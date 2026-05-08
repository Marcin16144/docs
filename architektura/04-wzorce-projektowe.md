# Wzorce projektowe (Design Patterns)

## Wzorce kreacyjne (Creational)

### Singleton
Jedna instancja klasy w całej aplikacji.
**Zastosowanie:** Konfiguracja, pule połączeń, logger.
**Uwaga:** Utrudnia testowanie — używaj z rozwagą.

### Factory Method / Abstract Factory
Tworzenie obiektów bez specyfikowania dokładnej klasy.
**Zastosowanie:** Gdy typ tworzonego obiektu zależy od kontekstu.

### Builder
Krokowe konstruowanie złożonych obiektów.
**Zastosowanie:** Obiekty z wieloma opcjonalnymi parametrami.

---

## Wzorce strukturalne (Structural)

### Adapter
Konwersja interfejsu jednej klasy na interfejs oczekiwany przez klienta.
**Zastosowanie:** Integracja z zewnętrznymi bibliotekami/API.

### Facade
Uproszczony interfejs do złożonego podsystemu.
**Zastosowanie:** Ukrycie złożoności za prostym API.

### Decorator
Dynamiczne dodawanie odpowiedzialności do obiektu.
**Zastosowanie:** Middleware, logowanie, cache.

### Proxy
Obiekt zastępczy kontrolujący dostęp do innego obiektu.
**Zastosowanie:** Lazy loading, kontrola dostępu, cache.

---

## Wzorce behawioralne (Behavioral)

### Observer
Powiadamianie wielu obiektów o zmianie stanu.
**Zastosowanie:** Systemy zdarzeń, reaktywne UI.

### Strategy
Wymienne algorytmy ukryte za wspólnym interfejsem.
**Zastosowanie:** Różne strategie cenowe, sortowania, walidacji.

### Command
Enkapsulacja żądania jako obiektu.
**Zastosowanie:** Undo/redo, kolejkowanie operacji.

### Chain of Responsibility
Łańcuch handlerów przetwarzających żądanie.
**Zastosowanie:** Middleware pipeline, walidacja.

---

## Wzorce architektoniczne na poziomie kodu

### Repository Pattern
Abstrakcja dostępu do danych — oddzielenie logiki biznesowej od warstwy persystencji.

```
interface OrderRepository {
    findById(id: string): Order;
    save(order: Order): void;
    findByCustomer(customerId: string): Order[];
}

class PostgresOrderRepository implements OrderRepository { ... }
class InMemoryOrderRepository implements OrderRepository { ... }
```

### Unit of Work
Śledzenie zmian w obiektach i zapis ich jako jedna transakcja.

### Domain Events
Obiekty domenowe emitują zdarzenia przy zmianie stanu.

### Specification Pattern
Enkapsulacja reguł biznesowych jako obiekty wielokrotnego użytku.
