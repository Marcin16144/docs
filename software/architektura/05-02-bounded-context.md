# 05-02: Bounded Context — Kontekst ograniczony

## Czym jest Bounded Context?

Bounded Context (kontekst ograniczony) to wyraźna granica, wewnątrz której dany model domenowy ma spójne, jednoznaczne znaczenie. Poza tą granicą te same słowa mogą oznaczać zupełnie co innego.

To jeden z najważniejszych konceptów strategicznego DDD — pozwala rozbić dużą, złożoną domenę na mniejsze, zarządzalne części, z których każda ma własny model, własny język i własne reguły.

## Dlaczego potrzebujemy granic?

W dużym systemie nie da się utrzymać jednego, spójnego modelu dla wszystkiego. Słowo "Klient" oznacza co innego w różnych częściach biznesu:

```
Kontekst Sprzedaży:
  Klient = potencjalny nabywca z budżetem, historią zakupów, segmentem

Kontekst Wysyłki:
  Klient = adres dostawy, preferencje doręczenia, telefon kontaktowy

Kontekst Rozliczeń:
  Klient = NIP, dane do faktury, historia płatności, limit kredytowy

Kontekst Obsługi:
  Klient = historia zgłoszeń, poziom SLA, preferowany kanał kontaktu
```

Próba stworzenia jednej klasy `Klient` z wszystkimi tymi polami prowadzi do "God Object" — klasy, która wie i robi za dużo.

## Definiowanie granic kontekstów

### Sygnały, że potrzebujesz osobnych kontekstów

- Ten sam termin ma różne znaczenia w różnych częściach systemu
- Różne zespoły pracują nad różnymi aspektami domeny
- Zmiany w jednej części nie powinny wymuszać zmian w innej
- Różne modele danych lepiej pasują do różnych części systemu
- Różne wymagania niefunkcjonalne (np. wysoka dostępność vs spójność)

### Przykład: system e-commerce

```typescript
// Kontekst: Katalog Produktów
// Model skupiony na opisie i prezentacji
class Product {
    id: ProductId;
    name: string;
    description: string;
    images: Image[];
    categories: Category[];
    specifications: Map<string, string>;
    seoMetadata: SeoMetadata;
}

// Kontekst: Zarządzanie Magazynem
// Ten sam "produkt" ale zupełnie inny model
class StockItem {
    sku: SKU;
    warehouseLocation: string;
    quantityOnHand: number;
    reorderLevel: number;
    supplier: SupplierId;
    lastRestockedAt: Date;
}

// Kontekst: Cennik
// Jeszcze inny widok na "produkt"
class PricedItem {
    productId: ProductId;
    basePrice: Money;
    discountRules: DiscountRule[];
    taxCategory: TaxCategory;
    currency: Currency;
    priceValidUntil: Date;
}
```

Każdy kontekst ma własny model — prosty, spójny i skupiony na jednym aspekcie domeny.

## Context Mapping — wzorce relacji

Konteksty nie żyją w izolacji — muszą ze sobą współpracować. Context Map opisuje relacje między kontekstami.

### Anti-Corruption Layer (ACL)

Warstwa tłumacząca między kontekstami. Chroni Twój model przed "zanieczyszczeniem" przez zewnętrzny model.

```typescript
// Kontekst Zamówień potrzebuje danych z Kontekstu Magazynu
// ACL tłumaczy model magazynowy na model zamówieniowy

class InventoryAntiCorruptionLayer {
    constructor(private inventoryClient: InventoryServiceClient) {}

    async checkAvailability(productId: ProductId, quantity: number):
        Promise<ProductAvailability> {
        // Wywołanie do zewnętrznego kontekstu
        const stockData = await this.inventoryClient.getStockLevel(
            productId.value
        );

        // Tłumaczenie na nasz model domenowy
        return new ProductAvailability({
            productId,
            isAvailable: stockData.qty_on_hand >= quantity,
            availableQuantity: stockData.qty_on_hand,
            estimatedRestockDate: stockData.next_delivery_date
                ? new Date(stockData.next_delivery_date)
                : null,
        });
    }
}

// Nasz kontekst używa SWOJEGO modelu, nie modelu magazynu
class OrderService {
    constructor(private inventoryACL: InventoryAntiCorruptionLayer) {}

    async placeOrder(request: PlaceOrderRequest): Promise<Order> {
        for (const item of request.items) {
            const availability = await this.inventoryACL
                .checkAvailability(item.productId, item.quantity);

            if (!availability.isAvailable) {
                throw new ProductUnavailableError(
                    item.productId,
                    availability.estimatedRestockDate
                );
            }
        }
        // ... reszta logiki zamówienia
    }
}
```

### Shared Kernel

Wspólna część modelu, dzielona przez dwa konteksty. Musi być mała i stabilna — zmiany wpływają na oba konteksty.

```typescript
// Shared Kernel — współdzielone Value Objects
// Używane zarówno przez kontekst Zamówień jak i Rozliczeń

class Money {
    constructor(readonly amount: number, readonly currency: Currency) {}

    add(other: Money): Money {
        this.ensureSameCurrency(other);
        return new Money(this.amount + other.amount, this.currency);
    }

    subtract(other: Money): Money {
        this.ensureSameCurrency(other);
        return new Money(this.amount - other.amount, this.currency);
    }

    private ensureSameCurrency(other: Money): void {
        if (this.currency !== other.currency) {
            throw new CurrencyMismatchError(this.currency, other.currency);
        }
    }
}

class Address {
    constructor(
        readonly street: string,
        readonly city: string,
        readonly postalCode: string,
        readonly country: CountryCode,
    ) {}
}

// Shared Kernel jest małe i stabilne — zmiany wymagają koordynacji
```

### Open Host Service

Kontekst udostępnia dobrze zdefiniowane API (protokół) dla innych kontekstów. Konsumenci dostosowują się do tego protokołu.

```typescript
// Kontekst Magazynu udostępnia Open Host Service
// Dobrze udokumentowane API, wersjonowane, stabilne

// API contract (Published Language)
interface InventoryAPI {
    // Queries
    getStockLevel(sku: string): Promise<StockLevelResponse>;
    getStockLevels(skus: string[]): Promise<StockLevelResponse[]>;

    // Commands
    reserveStock(reservation: StockReservationRequest): Promise<ReservationId>;
    releaseReservation(reservationId: string): Promise<void>;

    // Events (webhooks lub message bus)
    onStockDepleted(handler: (event: StockDepletedEvent) => void): void;
    onStockReplenished(handler: (event: StockReplenishedEvent) => void): void;
}

// Published Language — wspólny format wymiany danych
interface StockLevelResponse {
    sku: string;
    quantityAvailable: number;
    quantityReserved: number;
    warehouse: string;
    updatedAt: string; // ISO 8601
}
```

### Customer-Supplier

Relacja, w której jeden kontekst (supplier) dostarcza dane, a drugi (customer) je konsumuje. Customer może negocjować wymagania, supplier zobowiązuje się je spełnić.

### Conformist

Konsument nie ma wpływu na dostawcę i musi się w pełni dostosować do jego modelu. Typowe przy integracji z zewnętrznymi systemami (np. API płatności, API dostawcy).

## Mapowanie kontekstów na zespoły

Bounded Contexts naturalnie mapują się na strukturę zespołów (zgodnie z prawem Conwaya). Każdy kontekst powinien mieć jeden właścicielski zespół.

```
Kontekst Katalog Produktów  ←→  Zespół Produktowy
Kontekst Zamówienia          ←→  Zespół Zamówień
Kontekst Płatności           ←→  Zespół Płatności
Kontekst Wysyłka             ←→  Zespół Logistyki
Kontekst Obsługa Klienta     ←→  Zespół Supportu
```

### Topologia zespołów a wzorce kontekstowe

| Relacja zespołów | Wzorzec kontekstowy | Charakterystyka |
|-----------------|---------------------|-----------------|
| Bliski współpraca | Partnership | Dwa zespoły współpracują, zmiany koordynowane |
| Wspólny mikroserwis | Shared Kernel | Mały, wspólny moduł — wymaga dyscypliny |
| Dostawca-konsument | Customer-Supplier | Dostawca priorytetyzuje potrzeby konsumenta |
| Bez wpływu | Conformist | Konsument dostosowuje się lub buduje ACL |
| Izolacja | Separate Ways | Zespoły nie integrują się — duplikacja OK |

## Praktyczny przykład: Context Map

```
┌─────────────────┐     ACL      ┌──────────────────┐
│   Zamowienia     │◄────────────│   Platnosci       │
│   (core domain)  │             │   (external)       │
└────────┬────────┘             └──────────────────┘
         │
         │ Domain Events
         ▼
┌─────────────────┐  Open Host  ┌──────────────────┐
│   Magazyn        │◄───────────│   Katalog          │
│   (supporting)   │  Service   │   (supporting)     │
└────────┬────────┘             └──────────────────┘
         │
         │ Shared Kernel (Money, Address)
         ▼
┌─────────────────┐  Conformist ┌──────────────────┐
│   Wysylka        │────────────►│  Kurier API       │
│   (supporting)   │             │  (external)       │
└─────────────────┘             └──────────────────┘
```

## Typowe błędy

1. **Zbyt duże konteksty** — jeśli kontekst ma setki encji, prawdopodobnie powinien być rozbity
2. **Zbyt małe konteksty** — jeden agregat to za mało na osobny kontekst; prowadzi do nadmiernej komunikacji
3. **Brak ACL** — bezpośrednie użycie modelu innego kontekstu "zanieczyszcza" Twój model
4. **Shared Kernel jako śmietnik** — do Shared Kernel trafia wszystko, co "wydaje się wspólne"
5. **Konteksty techniczne zamiast domenowych** — podział na "frontend", "backend", "baza danych" to nie Bounded Contexts
