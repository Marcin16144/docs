# Zasady projektowania oprogramowania

## SOLID

### S — Single Responsibility Principle (Zasada pojedynczej odpowiedzialności)
Klasa powinna mieć tylko jeden powód do zmiany.

```
// Źle — klasa odpowiada za logikę i zapis
class OrderService {
    calculateTotal() { ... }
    saveToDatabase() { ... }
    sendEmailConfirmation() { ... }
}

// Dobrze — rozdzielone odpowiedzialności
class OrderCalculator { calculateTotal() { ... } }
class OrderRepository { save(order) { ... } }
class OrderNotifier { sendConfirmation(order) { ... } }
```

### O — Open/Closed Principle (Zasada otwarte/zamknięte)
Klasy powinny być otwarte na rozszerzanie, zamknięte na modyfikację.

### L — Liskov Substitution Principle (Zasada podstawienia Liskov)
Obiekty klasy bazowej powinny być zastępowalne obiektami klas pochodnych.

### I — Interface Segregation Principle (Zasada segregacji interfejsów)
Wiele małych, specyficznych interfejsów jest lepsze niż jeden duży.

### D — Dependency Inversion Principle (Zasada odwrócenia zależności)
Moduły wysokiego poziomu nie powinny zależeć od modułów niskiego poziomu — oba powinny zależeć od abstrakcji.

---

## DRY, KISS, YAGNI

| Zasada | Znaczenie | Praktyka |
|--------|-----------|----------|
| **DRY** | Don't Repeat Yourself | Unikaj duplikacji wiedzy (nie kodu!) |
| **KISS** | Keep It Simple, Stupid | Wybieraj najprostsze rozwiązanie |
| **YAGNI** | You Aren't Gonna Need It | Nie implementuj na zapas |

**Uwaga o DRY:** Nie każda duplikacja kodu jest zła. Dwa fragmenty mogą wyglądać identycznie, ale zmieniać się z różnych powodów — wtedy DRY nie ma zastosowania.

---

## Prawo Demeter (Law of Demeter)

Obiekt powinien rozmawiać tylko z bezpośrednimi sąsiadami.

```
// Źle — łańcuch wywołań
order.getCustomer().getAddress().getCity()

// Dobrze — zapytaj bezpośrednio
order.getDeliveryCity()
```

---

## Composition over Inheritance (Kompozycja ponad dziedziczenie)

Preferuj składanie obiektów z mniejszych komponentów zamiast głębokich hierarchii dziedziczenia.

---

## Separation of Concerns (Rozdzielenie odpowiedzialności)

Każdy moduł/warstwa odpowiada za jedną, dobrze zdefiniowaną część problemu.

---

## Coupling i Cohesion

- **Loose Coupling (luźne powiązanie)** — moduły zależą od siebie jak najmniej
- **High Cohesion (wysoka spójność)** — elementy wewnątrz modułu są silnie powiązane tematycznie

Dąż do: **luźnego powiązania** między modułami i **wysokiej spójności** wewnątrz modułów.

---

## Fail Fast

System powinien zgłaszać błąd jak najwcześniej, zamiast propagować niepoprawne dane.

```
function processOrder(order) {
    if (!order) throw new Error("Order is required");
    if (!order.items.length) throw new Error("Order must have items");
    // dopiero teraz przetwarzaj
}
```
