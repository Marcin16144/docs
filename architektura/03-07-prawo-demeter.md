# 03-07: Prawo Demeter (Law of Demeter) — Zasada minimalnej wiedzy

## Czym jest Prawo Demeter?

Prawo Demeter (Law of Demeter, LoD), sformułowane w 1987 roku na Northeastern University, mówi: **obiekt powinien rozmawiać tylko ze swoimi bezpośrednimi sąsiadami**. Formalnie, metoda M obiektu O może wywoływać metody tylko na:

1. Samym obiekcie O (`this`)
2. Parametrach metody M
3. Obiektach stworzonych wewnątrz M
4. Bezpośrednich polach obiektu O

Nie powinna wywoływać metod na obiektach zwróconych przez inne wywołania — to tak zwany **train wreck** (łańcuch wywołań).

## Anti-pattern: Train Wreck

```typescript
// ZLE — lancuch wywolan ("train wreck")

// Kazdy . to dodatkowa zaleznosc
const city = order.getCustomer().getAddress().getCity();
const zip = order.getCustomer().getAddress().getZipCode();
const discount = order.getCustomer().getLoyaltyProgram().getDiscount();

// Ten kod musi WIEDZIEC o:
// - Order ma Customer
// - Customer ma Address
// - Address ma City i ZipCode
// - Customer ma LoyaltyProgram
// - LoyaltyProgram ma Discount
//
// Zmiana w DOWOLNEJ z tych klas moze zlamac ten kod.
```

### Dlaczego to problem?

- **Wysokie sprzężenie** — kod zależy od całego łańcucha obiektów
- **Kruchy kod** — zmiana w dowolnej klasie łańcucha łamie wywołujący kod
- **Trudne testowanie** — trzeba mockować cały łańcuch
- **Ukryte zależności** — prawdziwe potrzeby kodu nie są widoczne w jego interfejsie

## Tell, Don't Ask

Prawo Demeter jest ściśle powiązane z zasadą **Tell, Don't Ask**: zamiast odpytywać obiekt o jego stan i podejmować decyzje, powiedz mu co ma zrobić.

```typescript
// ZLE — Ask (odpytujesz i decydujesz)
function applyDiscount(order: Order): void {
    const customer = order.getCustomer();
    const loyalty = customer.getLoyaltyProgram();

    if (loyalty.getPoints() > 1000) {
        const discount = loyalty.getDiscount();
        const total = order.getTotal();
        order.setTotal(total - (total * discount));
    }
}

// DOBRZE — Tell (mowisz co zrobic)
function applyDiscount(order: Order): void {
    order.applyLoyaltyDiscount();
}

// Logika przeniesiona do Order
class Order {
    applyLoyaltyDiscount(): void {
        const discount = this.customer.calculateDiscount();
        this.total = this.total.subtract(
            this.total.multiply(discount)
        );
    }
}

// Customer enkapsuluje swoje dane
class Customer {
    calculateDiscount(): number {
        return this.loyaltyProgram.getDiscountRate();
    }
}
```

## Przykład 1: Komponent UI — złe podejście

```typescript
// ZLE — komponent UI siega gleboko w model danych

function OrderSummary({ order }: { order: Order }) {
    return (
        <div>
            <h2>Podsumowanie zamowienia</h2>
            <p>Klient: {order.customer.profile.firstName}
               {order.customer.profile.lastName}</p>
            <p>Email: {order.customer.contactInfo.email}</p>
            <p>Miasto: {order.customer.addresses[0].city}</p>
            <p>Rabat: {order.customer.loyaltyProgram.currentTier.discount}%</p>
            <p>Suma: {order.lineItems
                .reduce((sum, item) => sum + item.product.price * item.quantity, 0)
            } PLN</p>
        </div>
    );
}

// Jezeli zmienisz strukture Customer lub Address,
// musisz zmienic ten komponent UI.
```

### Rozwiązanie: Dedykowany ViewModel

```typescript
// DOBRZE — ViewModel z plaskim interfejsem

interface OrderSummaryViewModel {
    customerName: string;
    customerEmail: string;
    deliveryCity: string;
    discountPercent: number;
    totalAmount: number;
}

// Mapowanie w jednym miejscu
function toOrderSummaryVM(order: Order): OrderSummaryViewModel {
    return {
        customerName: order.getCustomerFullName(),
        customerEmail: order.getCustomerEmail(),
        deliveryCity: order.getDeliveryCity(),
        discountPercent: order.getLoyaltyDiscount(),
        totalAmount: order.calculateTotal()
    };
}

// Komponent UI — zero lancuchow
function OrderSummary({ vm }: { vm: OrderSummaryViewModel }) {
    return (
        <div>
            <h2>Podsumowanie zamowienia</h2>
            <p>Klient: {vm.customerName}</p>
            <p>Email: {vm.customerEmail}</p>
            <p>Miasto: {vm.deliveryCity}</p>
            <p>Rabat: {vm.discountPercent}%</p>
            <p>Suma: {vm.totalAmount} PLN</p>
        </div>
    );
}
```

## Przykład 2: Serwis powiadomień — złe podejście

```python
# ZLE — serwis siega po dane przez lancuchy wywolan

class NotificationService:
    def send_order_confirmation(self, order):
        # Train wreck: order -> customer -> contact -> email
        email = order.customer.contact_info.email
        
        # Train wreck: order -> customer -> preferences -> language
        lang = order.customer.preferences.language
        
        # Train wreck: order -> items -> product -> name
        items = [item.product.name for item in order.items]
        
        # Train wreck: order -> payment -> method -> display_name
        payment = order.payment.method.display_name
        
        template = self.get_template('order_confirmation', lang)
        self.mailer.send(email, template.render(
            items=items, payment=payment
        ))
```

### Rozwiązanie: Metody delegujące

```python
# DOBRZE — Order dostarcza dane przez wlasne metody

class Order:
    def get_notification_email(self) -> str:
        return self.customer.get_email()

    def get_preferred_language(self) -> str:
        return self.customer.get_language()

    def get_item_names(self) -> list[str]:
        return [item.get_display_name() for item in self.items]

    def get_payment_display_name(self) -> str:
        return self.payment.get_display_name()


class Customer:
    def get_email(self) -> str:
        return self.contact_info.email

    def get_language(self) -> str:
        return self.preferences.language


class OrderItem:
    def get_display_name(self) -> str:
        return self.product.name


class NotificationService:
    def send_order_confirmation(self, order: Order):
        email = order.get_notification_email()
        lang = order.get_preferred_language()
        items = order.get_item_names()
        payment = order.get_payment_display_name()

        template = self.get_template('order_confirmation', lang)
        self.mailer.send(email, template.render(
            items=items, payment=payment
        ))
```

## Przykład 3: Refaktoryzacja łańcuchów

```typescript
// Rozne poziomy naruszen i ich rozwiazania

// POZIOM 1: Prosty lancuch — dodaj metode delegujaca
// Zle:
order.getCustomer().getEmail()
// Dobrze:
order.getCustomerEmail()

// POZIOM 2: Lancuch z logika — przenies logike do wlasciwego obiektu
// Zle:
if (order.getCustomer().getLoyalty().getPoints() > 1000) {
    order.getCustomer().getLoyalty().applyDiscount(order);
}
// Dobrze:
order.applyLoyaltyDiscountIfEligible();

// POZIOM 3: Lancuch z iteracja — uzyj dedykowanej metody
// Zle:
const total = order.getItems()
    .map(item => item.getProduct().getPrice() * item.getQuantity())
    .reduce((a, b) => a + b, 0);
// Dobrze:
const total = order.calculateTotal();

// POZIOM 4: Lancuch w warunku — uzyj polimorfizmu lub wzorca
// Zle:
if (user.getAccount().getSubscription().getPlan().getFeatures().includes('export')) {
    allowExport();
}
// Dobrze:
if (user.hasFeature('export')) {
    allowExport();
}
```

## Wyjątki od Prawa Demeter

### Fluent API / Builder Pattern

```typescript
// Fluent API — lancuch JEST zamierzonym interfejsem
const query = db.select('users')
    .where('age', '>', 18)
    .orderBy('name')
    .limit(10);

// To NIE jest naruszenie LoD, bo kazda metoda
// zwraca TEN SAM obiekt (lub nowy tego samego typu).
```

### Data Transfer Objects (DTO)

```typescript
// DTO / struktury danych — brak zachowania, tylko dane
interface OrderDTO {
    customer: {
        name: string;
        email: string;
    };
    items: Array<{
        name: string;
        price: number;
    }>;
}

// Dostep do pol DTO jest akceptowalny
const name = orderDTO.customer.name;

// DTO nie maja logiki biznesowej — sa transparentne.
// Prawo Demeter dotyczy OBIEKTOW z zachowaniem, nie struktur danych.
```

### Strumienie i kolekcje

```typescript
// Operacje na strumieniach/kolekcjach — idiom jezyka
const names = users
    .filter(u => u.isActive)
    .map(u => u.name)
    .sort();

// To nie jest train wreck — to przetwarzanie danych
// w stylu funkcyjnym, gdzie kazda operacja zwraca nowa kolekcje.
```

## Metryki łamania Prawa Demeter

| Sygnał | Opis |
|--------|------|
| Więcej niż 1 kropka | `a.b().c()` — potencjalne naruszenie |
| Mock łańcuchy w testach | `when(mock.getA().getB()).thenReturn(...)` |
| Feature Envy | Metoda używa więcej danych innego obiektu niż swojego |
| Shotgun Surgery | Zmiana w jednej klasie wymaga zmian w wielu miejscach |

## Jak testować zgodność z LoD?

```typescript
// ZLE — test wymaga budowania calego lancucha
describe('applyDiscount', () => {
    it('should apply loyalty discount', () => {
        const loyalty = { getPoints: () => 1500, getDiscount: () => 0.1 };
        const customer = { getLoyaltyProgram: () => loyalty };
        const order = { getCustomer: () => customer, getTotal: () => 100,
                        setTotal: jest.fn() };
        
        applyDiscount(order);
        expect(order.setTotal).toHaveBeenCalledWith(90);
    });
});

// DOBRZE — test jest prosty, bo interfejs jest prosty
describe('Order.applyLoyaltyDiscount', () => {
    it('should reduce total by discount', () => {
        const order = new Order(/* ... */);
        order.applyLoyaltyDiscount();
        expect(order.getTotal()).toBe(Money.of(90));
    });
});
```

## Podsumowanie

- Prawo Demeter: rozmawiaj tylko z bezpośrednimi sąsiadami
- Train wreck (`a.b().c().d()`) to sygnał naruszenia — każda kropka to dodatkowa zależność
- Tell, Don't Ask: mów obiektom co robić, zamiast odpytywać ich stan
- Dodawaj metody delegujące, by ukryć wewnętrzną strukturę
- Wyjątki: Fluent API, DTO/struktury danych, operacje na kolekcjach
- Prosty test: jeśli mock w teście wymaga łańcucha `when(...).thenReturn(...)`, łamiesz LoD
