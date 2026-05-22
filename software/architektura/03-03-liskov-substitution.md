# 03-03: Liskov Substitution Principle (LSP) — Zasada podstawienia Liskov

## Czym jest LSP?

Zasada podstawienia Liskov, sformułowana przez Barbarę Liskov w 1987 roku, mówi: **jeżeli S jest podtypem T, to obiekty typu T mogą być zastąpione obiektami typu S bez zmiany pożądanych właściwości programu** (poprawność, wykonywane zadanie).

Innymi słowy: klasa pochodna musi być w pełni zastępowalna za klasę bazową. Kod kliencki nie powinien wiedzieć ani dbać o to, czy pracuje z obiektem bazowym czy pochodnym.

## Formalna definicja — Design by Contract

LSP opiera się na koncepcji Design by Contract (Bertrand Meyer):

- **Warunki wstępne (preconditions)** — klasa pochodna nie może ich zaostrzać
- **Warunki końcowe (postconditions)** — klasa pochodna nie może ich osłabiać
- **Niezmienniki (invariants)** — klasa pochodna musi je zachowywać

## Klasyczny problem: Prostokąt i Kwadrat

```typescript
// Klasyczny przyklad naruszenia LSP

class Rectangle {
    constructor(
        protected width: number,
        protected height: number
    ) {}

    setWidth(w: number): void {
        this.width = w;
    }

    setHeight(h: number): void {
        this.height = h;
    }

    getArea(): number {
        return this.width * this.height;
    }
}

// Kwadrat JEST prostokatem matematycznie,
// ale NIE w sensie LSP
class Square extends Rectangle {
    setWidth(w: number): void {
        this.width = w;
        this.height = w; // wymusza kwadrat
    }

    setHeight(h: number): void {
        this.width = h;  // wymusza kwadrat
        this.height = h;
    }
}

// Kod kliencki zaklada zachowanie prostokata
function resizeAndCheck(rect: Rectangle): void {
    rect.setWidth(5);
    rect.setHeight(4);
    // Oczekiwanie: 5 * 4 = 20
    console.assert(rect.getArea() === 20);
    // Dla Square: 4 * 4 = 16 — NARUSZENIE LSP!
}

const rect = new Rectangle(0, 0);
resizeAndCheck(rect); // OK: 20

const square = new Square(0, 0);
resizeAndCheck(square); // FAIL: 16, nie 20
```

### Rozwiązanie: Osobne typy lub niemutowalne kształty

```typescript
// Rozwiazanie 1: Niemutowalne ksztalty
class Rectangle {
    constructor(
        readonly width: number,
        readonly height: number
    ) {}

    getArea(): number {
        return this.width * this.height;
    }

    withWidth(w: number): Rectangle {
        return new Rectangle(w, this.height);
    }

    withHeight(h: number): Rectangle {
        return new Rectangle(this.width, h);
    }
}

class Square {
    constructor(readonly side: number) {}

    getArea(): number {
        return this.side * this.side;
    }

    withSide(s: number): Square {
        return new Square(s);
    }
}

// Rozwiazanie 2: Wspolny interfejs tylko dla odczytu
interface Shape {
    getArea(): number;
}

class Rectangle implements Shape {
    constructor(private width: number, private height: number) {}
    getArea(): number { return this.width * this.height; }
}

class Square implements Shape {
    constructor(private side: number) {}
    getArea(): number { return this.side * this.side; }
}

// Kod kliencki operuje na Shape — nie zaklada mozliwosci zmiany wymiarow
function printArea(shape: Shape): void {
    console.log(`Pole: ${shape.getArea()}`);
}
```

## Przykład 2: Kolekcje tylko do odczytu

```python
# ZLE — naruszenie LSP przez ograniczenie operacji

class FileStorage:
    def read(self, path: str) -> bytes:
        with open(path, 'rb') as f:
            return f.read()

    def write(self, path: str, data: bytes) -> None:
        with open(path, 'wb') as f:
            f.write(data)

    def delete(self, path: str) -> None:
        os.remove(path)


class ReadOnlyStorage(FileStorage):
    def write(self, path: str, data: bytes) -> None:
        raise PermissionError("Zapis niedozwolony")

    def delete(self, path: str) -> None:
        raise PermissionError("Usuwanie niedozwolone")


def backup_files(storage: FileStorage, files: list):
    for f in files:
        data = storage.read(f)
        storage.write(f + '.bak', data)  # BOOM dla ReadOnlyStorage!
```

### Rozwiązanie: Segregacja interfejsów

```python
# DOBRZE — oddzielne interfejsy dla odczytu i zapisu

from abc import ABC, abstractmethod

class ReadableStorage(ABC):
    @abstractmethod
    def read(self, path: str) -> bytes:
        pass

class WritableStorage(ABC):
    @abstractmethod
    def write(self, path: str, data: bytes) -> None:
        pass

class DeletableStorage(ABC):
    @abstractmethod
    def delete(self, path: str) -> None:
        pass


class FileStorage(ReadableStorage, WritableStorage, DeletableStorage):
    def read(self, path: str) -> bytes:
        with open(path, 'rb') as f:
            return f.read()

    def write(self, path: str, data: bytes) -> None:
        with open(path, 'wb') as f:
            f.write(data)

    def delete(self, path: str) -> None:
        os.remove(path)


class ReadOnlyFileStorage(ReadableStorage):
    def read(self, path: str) -> bytes:
        with open(path, 'rb') as f:
            return f.read()


# Funkcja wymaga tylko tego, czego potrzebuje
def backup_files(source: ReadableStorage, target: WritableStorage, files: list):
    for f in files:
        data = source.read(f)
        target.write(f + '.bak', data)
```

## Przykład 3: Wyjątki i kontrakty

```typescript
// ZLE — klasa pochodna zaostrza warunek wstepny

class PaymentProcessor {
    process(amount: number): Receipt {
        if (amount <= 0) throw new Error("Kwota musi byc dodatnia");
        // przetwarzanie...
        return new Receipt(amount);
    }
}

class LimitedPaymentProcessor extends PaymentProcessor {
    process(amount: number): Receipt {
        if (amount <= 0) throw new Error("Kwota musi byc dodatnia");
        if (amount > 1000) throw new Error("Limit przekroczony"); // ZAOSTRZENIE!
        return super.process(amount);
    }
}

// Kod kliencki nie spodziewa sie bledu dla kwoty 5000
function chargeCustomer(processor: PaymentProcessor, amount: number) {
    const receipt = processor.process(amount); // BOOM dla Limited!
}
```

### Rozwiązanie

```typescript
// DOBRZE — limit jest czescia kontraktu

interface PaymentProcessor {
    process(amount: number): Receipt;
    getLimit(): number | null;  // kontrakt mowi o limicie
}

class StandardProcessor implements PaymentProcessor {
    process(amount: number): Receipt {
        if (amount <= 0) throw new Error("Kwota musi byc dodatnia");
        return new Receipt(amount);
    }
    getLimit(): number | null { return null; }
}

class LimitedProcessor implements PaymentProcessor {
    constructor(private limit: number) {}

    process(amount: number): Receipt {
        if (amount <= 0) throw new Error("Kwota musi byc dodatnia");
        if (amount > this.limit) {
            throw new LimitExceededError(amount, this.limit);
        }
        return new Receipt(amount);
    }
    getLimit(): number { return this.limit; }
}

// Kod kliencki moze sprawdzic limit przed wywolaniem
function chargeCustomer(processor: PaymentProcessor, amount: number) {
    const limit = processor.getLimit();
    if (limit !== null && amount > limit) {
        // obsluz sytuacje swiadomie
        return splitPayment(processor, amount, limit);
    }
    return processor.process(amount);
}
```

## Kowariancja i kontrawariancja

```typescript
// Kowariancja typow zwracanych (dozwolona)
class AnimalShelter {
    adopt(): Animal { return new Animal(); }
}

class CatShelter extends AnimalShelter {
    adopt(): Cat { return new Cat(); } // OK — Cat jest Animal
}

// Kontrawariancja parametrow (dozwolona)
class Handler {
    handle(cat: Cat): void { /* ... */ }
}

class GeneralHandler extends Handler {
    handle(animal: Animal): void { /* ... */ } // OK — akceptuje wiecej
}
```

### Reguły typów w LSP

| Aspekt | Dozwolone w podtypie | Niedozwolone |
|--------|---------------------|-------------|
| Typ zwracany | Bardziej szczegółowy (kowariancja) | Bardziej ogólny |
| Typ parametru | Bardziej ogólny (kontrawariancja) | Bardziej szczegółowy |
| Warunek wstępny | Słabszy lub równy | Silniejszy |
| Warunek końcowy | Silniejszy lub równy | Słabszy |
| Wyjątki | Podtypy istniejących | Nowe typy wyjątków |
| Niezmienniki | Zachowane | Naruszone |

## Jak testować zgodność z LSP?

1. **Testy kontraktowe** — napisz testy dla klasy bazowej i uruchom je na każdej podklasie
2. **Testy parametryzowane** — użyj tego samego zestawu testów z różnymi implementacjami
3. **Property-based testing** — generuj losowe dane i sprawdzaj niezmienniki

```python
import pytest

# Testy kontraktowe — dzialaja dla KAZDEJ implementacji Shape
class ShapeContractTests:
    """Kazda implementacja Shape musi przejsc te testy."""

    def test_area_is_non_negative(self, shape):
        assert shape.get_area() >= 0

    def test_area_is_deterministic(self, shape):
        assert shape.get_area() == shape.get_area()


class TestRectangle(ShapeContractTests):
    @pytest.fixture
    def shape(self):
        return Rectangle(5, 4)

    def test_area_calculation(self, shape):
        assert shape.get_area() == 20


class TestCircle(ShapeContractTests):
    @pytest.fixture
    def shape(self):
        return Circle(3)

    def test_area_calculation(self, shape):
        assert abs(shape.get_area() - 28.274) < 0.01
```

## Podsumowanie

- LSP gwarantuje, że podtypy są bezpiecznie wymienne z typami bazowymi
- Klasyczny błąd: Kwadrat dziedziczący po Prostokącie
- Nie zaostrzaj warunków wstępnych, nie osłabiaj warunków końcowych
- Nie rzucaj nowych typów wyjątków, których klient się nie spodziewa
- Preferuj kompozycję i interfejsy nad głębokie hierarchie dziedziczenia
- Testuj kontrakt klasy bazowej na wszystkich implementacjach
