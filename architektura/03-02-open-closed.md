# 03-02: Open/Closed Principle (OCP) — Zasada otwarte/zamknięte

## Czym jest OCP?

Zasada otwarte/zamknięte mówi, że **klasy (moduły, funkcje) powinny być otwarte na rozszerzanie, ale zamknięte na modyfikacje**. Sformułował ją Bertrand Meyer w 1988 roku, a Robert C. Martin spopularyzował ją w kontekście SOLID.

W praktyce oznacza to: gdy pojawia się nowe wymaganie, powinieneś móc dodać nowy kod, nie zmieniając istniejącego. Istniejący, przetestowany kod pozostaje nienaruszony.

## Dlaczego to ważne?

- Zmiana istniejącego kodu może wprowadzić regresje
- Każda modyfikacja wymaga ponownego testowania
- W dużych systemach zmiana jednej klasy może kaskadowo wpłynąć na wiele innych
- Zamknięty kod można bezpiecznie wdrażać jako bibliotekę

## Przykład 1: Kalkulator zniżek — złe podejście

```typescript
// ZLE — dodanie nowej znizki wymaga modyfikacji istniejacego kodu
class DiscountCalculator {
    calculate(order: Order): number {
        let discount = 0;

        if (order.customer.type === 'vip') {
            discount = order.total * 0.15;
        } else if (order.customer.type === 'regular' && order.total > 500) {
            discount = order.total * 0.05;
        } else if (order.customer.type === 'employee') {
            discount = order.total * 0.30;
        }
        // Kazda nowa znizka = modyfikacja tej metody
        // A co z sezonowymi promocjami? Kuponami? Programami lojalnosciowymi?

        return discount;
    }
}
```

Problem: każda nowa reguła zniżkowa wymaga zmiany metody `calculate`. Jeśli mamy 20 reguł, metoda staje się nieczytelna, a ryzyko regresji rośnie.

## Przykład 1: Rozwiązanie z wzorcem Strategy

```typescript
// DOBRZE — nowe znizki = nowe klasy, zero zmian w kalkulatorze

interface DiscountStrategy {
    isApplicable(order: Order): boolean;
    calculate(order: Order): number;
}

class VipDiscount implements DiscountStrategy {
    isApplicable(order: Order): boolean {
        return order.customer.type === 'vip';
    }
    calculate(order: Order): number {
        return order.total * 0.15;
    }
}

class BulkOrderDiscount implements DiscountStrategy {
    isApplicable(order: Order): boolean {
        return order.total > 500;
    }
    calculate(order: Order): number {
        return order.total * 0.05;
    }
}

class EmployeeDiscount implements DiscountStrategy {
    isApplicable(order: Order): boolean {
        return order.customer.type === 'employee';
    }
    calculate(order: Order): number {
        return order.total * 0.30;
    }
}

// Kalkulator jest ZAMKNIETY na modyfikacje
class DiscountCalculator {
    constructor(private strategies: DiscountStrategy[]) {}

    calculate(order: Order): number {
        return this.strategies
            .filter(s => s.isApplicable(order))
            .reduce((sum, s) => sum + s.calculate(order), 0);
    }
}

// Dodanie nowej znizki — zero zmian w istniejacym kodzie
class SeasonalDiscount implements DiscountStrategy {
    isApplicable(order: Order): boolean {
        const month = new Date().getMonth();
        return month === 11; // grudzien
    }
    calculate(order: Order): number {
        return order.total * 0.10;
    }
}
```

## Przykład 2: Eksporter danych — złe podejście

```python
# ZLE — kazdy nowy format wymaga modyfikacji klasy
class DataExporter:
    def export(self, data: list, format: str) -> str:
        if format == 'json':
            return json.dumps(data)
        elif format == 'csv':
            output = StringIO()
            writer = csv.writer(output)
            for row in data:
                writer.writerow(row.values())
            return output.getvalue()
        elif format == 'xml':
            root = ET.Element("data")
            for item in data:
                entry = ET.SubElement(root, "entry")
                for key, val in item.items():
                    child = ET.SubElement(entry, key)
                    child.text = str(val)
            return ET.tostring(root, encoding='unicode')
        else:
            raise ValueError(f"Nieznany format: {format}")
```

## Przykład 2: Rozwiązanie z architekturą pluginów

```python
# DOBRZE — architektura pluginow

from abc import ABC, abstractmethod

class Exporter(ABC):
    @abstractmethod
    def export(self, data: list) -> str:
        pass

class JsonExporter(Exporter):
    def export(self, data: list) -> str:
        return json.dumps(data, indent=2, ensure_ascii=False)

class CsvExporter(Exporter):
    def export(self, data: list) -> str:
        output = StringIO()
        writer = csv.DictWriter(output, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)
        return output.getvalue()

class XmlExporter(Exporter):
    def export(self, data: list) -> str:
        root = ET.Element("data")
        for item in data:
            entry = ET.SubElement(root, "entry")
            for key, val in item.items():
                child = ET.SubElement(entry, key)
                child.text = str(val)
        return ET.tostring(root, encoding='unicode')


# Rejestr pluginow — nowe formaty bez modyfikacji istniejacego kodu
class ExporterRegistry:
    def __init__(self):
        self._exporters: dict[str, Exporter] = {}

    def register(self, format_name: str, exporter: Exporter):
        self._exporters[format_name] = exporter

    def get(self, format_name: str) -> Exporter:
        if format_name not in self._exporters:
            raise ValueError(f"Brak eksportera dla: {format_name}")
        return self._exporters[format_name]


# Konfiguracja
registry = ExporterRegistry()
registry.register('json', JsonExporter())
registry.register('csv', CsvExporter())
registry.register('xml', XmlExporter())

# Pozniej ktos dodaje YAML — zero zmian w istniejacym kodzie
class YamlExporter(Exporter):
    def export(self, data: list) -> str:
        return yaml.dump(data, allow_unicode=True)

registry.register('yaml', YamlExporter())
```

## Przykład 3: Wzorzec Decorator dla OCP

```typescript
// Bazowy serwis logowania
interface Logger {
    log(message: string): void;
}

class ConsoleLogger implements Logger {
    log(message: string): void {
        console.log(message);
    }
}

// Dekoratory rozszerzaja funkcjonalnosc BEZ modyfikacji bazowej klasy
class TimestampLogger implements Logger {
    constructor(private inner: Logger) {}

    log(message: string): void {
        const timestamp = new Date().toISOString();
        this.inner.log(`[${timestamp}] ${message}`);
    }
}

class JsonLogger implements Logger {
    constructor(private inner: Logger) {}

    log(message: string): void {
        this.inner.log(JSON.stringify({
            message,
            level: 'info',
            service: 'app'
        }));
    }
}

class FilteredLogger implements Logger {
    constructor(
        private inner: Logger,
        private minLevel: string
    ) {}

    log(message: string): void {
        // filtrowanie wedlug poziomu
        this.inner.log(message);
    }
}

// Kompozycja — kazdy dekorator dodaje funkcjonalnosc
const logger = new TimestampLogger(
    new FilteredLogger(
        new ConsoleLogger(),
        'warn'
    )
);
```

## Techniki realizacji OCP

| Technika | Kiedy stosowac | Przyklad |
|----------|---------------|---------|
| **Strategy** | Wymienne algorytmy | Sortowanie, walidacja, kalkulacje |
| **Decorator** | Dodawanie zachowan | Logowanie, cache, autoryzacja |
| **Plugin/Registry** | Dynamiczne rozszerzanie | Formaty eksportu, providery |
| **Template Method** | Wspolny szkielet, rozne kroki | Procesy ETL, generatory raportow |
| **Observer/Events** | Reakcja na zdarzenia | Notyfikacje, audyt, metryki |

## Kiedy OCP jest niepraktyczne?

- **Proste aplikacje CRUD** — nadmiarowa abstrakcja spowalnia rozwoj
- **Prototypy** — zbyt wczesne zamykanie ogranicza eksploracje
- **Gdy nie wiadomo, co sie zmieni** — nie przewiduj przyszlosci, stosuj Rule of Three (zamknij po trzeciej zmianie)

```
// Jezeli zmodyfikowales ten sam if/switch 3 razy
// — czas na refaktoryzacje ku OCP
// Nie rob tego profilaktycznie przy pierwszym if-ie
```

## Podsumowanie

- OCP chroni istniejacy, przetestowany kod przed regresja
- Nowe wymagania = nowy kod, nie modyfikacja starego
- Kluczowe wzorce: Strategy, Decorator, Plugin/Registry
- Nie stosuj OCP przedwczesnie — poczekaj na realne potrzeby zmian
- OCP wspolgra z SRP — jezeli klasa ma jedna odpowiedzialnosc, latwiej ja zamknac
