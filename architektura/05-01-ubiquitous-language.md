# 05-01: Ubiquitous Language — Język wszechobecny

## Czym jest Ubiquitous Language?

Ubiquitous Language (język wszechobecny) to wspólny, precyzyjny język używany przez cały zespół — programistów, analityków, testerów i ekspertów biznesowych. Każdy termin ma jedno, uzgodnione znaczenie, które jest odzwierciedlone zarówno w rozmowach, dokumentacji, jak i w kodzie.

To nie jest glossariusz napisany raz i zapomniany. To żywy język, który ewoluuje wraz z rozumieniem domeny i jest aktywnie używany na co dzień.

## Dlaczego to takie ważne?

Większość błędów w oprogramowaniu nie wynika z problemów technicznych, lecz z nieporozumień między biznesem a zespołem technicznym. Gdy programista mówi "user", analityk "klient", a ekspert biznesowy "kontrahent" — i każdy myśli o czymś innym — powstają błędy w wymaganiach, które kosztują tygodnie pracy.

### Przykład problemu

```
Spotkanie bez wspólnego języka:

Biznes:     "Klient składa zamówienie"
Analityk:   "Użytkownik tworzy order"
Programista: "User submituje request do API"
Tester:     "Aktor wykonuje transakcję zakupu"

Cztery osoby — cztery terminologie — zero wspólnego zrozumienia.
```

## Budowanie glossariusza

Glossariusz to formalny zapis terminów Ubiquitous Language. Każdy wpis powinien zawierać termin, definicję, kontekst (Bounded Context) i ewentualnie przykłady.

```
| Termin              | Definicja                                           | Kontekst       |
|---------------------|-----------------------------------------------------|----------------|
| Zamówienie (Order)  | Złożone przez klienta żądanie zakupu produktów      | Sprzedaż       |
| Pozycja zamówienia  | Jeden produkt z ilością w ramach zamówienia          | Sprzedaż       |
| Koszyk (Cart)       | Tymczasowa kolekcja produktów przed złożeniem zamów. | Zakupy         |
| Faktura (Invoice)   | Dokument rozliczeniowy wystawiony po realizacji      | Rozliczenia    |
| Wysyłka (Shipment)  | Fizyczna paczka wysłana do klienta                   | Logistyka      |
| Zwrot (Return)      | Procedura oddania produktu i zwrotu pieniędzy        | Obsługa klienta|
```

### Zasady dobrego glossariusza

- Jeden termin = jedno znaczenie w danym kontekście
- Terminy biznesowe, nie techniczne (Zamówienie, nie OrderDTO)
- Utrzymywany wspólnie przez cały zespół
- Aktualizowany gdy rozumienie się zmienia
- Dostępny dla wszystkich (wiki, Confluence, repozytorium)

## Event Storming dla odkrywania języka

Event Storming to warsztatowa technika modelowania, która jest jednym z najskuteczniejszych narzędzi do odkrywania Ubiquitous Language. Zespół (programiści + eksperci biznesowi) przyklejają karteczki na ścianie, opisując zdarzenia domenowe.

### Przebieg sesji

1. **Zdarzenia domenowe (pomarańczowe karteczki)** — co się wydarzyło?
   - KlientZłożyłZamówienie
   - PłatnośćZostałaZatwierdzona
   - WysyłkaZostałaNadana
   - ZwrotZostałZaakceptowany

2. **Komendy (niebieskie)** — co spowodowało zdarzenie?
   - ZłóżZamówienie → KlientZłożyłZamówienie
   - ZatwierdzPłatność → PłatnośćZostałaZatwierdzona

3. **Agregaty (żółte)** — kto wykonał komendę?
   - Zamówienie.złóż() → KlientZłożyłZamówienie
   - Płatność.zatwierdź() → PłatnośćZostałaZatwierdzona

4. **Polityki (liliowe)** — automatyczne reakcje
   - Gdy KlientZłożyłZamówienie → RezerujProdukty
   - Gdy PłatnośćZostałaZatwierdzona → NadajWysyłkę

### Efekt

Po sesji Event Storming zespół ma:
- Listę zdarzeń domenowych (naturalny język domeny)
- Zrozumienie przepływu procesów biznesowych
- Wspólne nazewnictwo dla kluczowych koncepcji
- Identyfikację granic kontekstów (Bounded Contexts)

## Kod odzwierciedlający terminy biznesowe

Ubiquitous Language nie jest tylko dla dokumentacji. Kluczowa zasada DDD: kod powinien używać tych samych terminów co biznes.

### Złe nazewnictwo — techniczny żargon

```typescript
// Kod, który nie mówi językiem domeny
class DataProcessor {
    processRecord(record: Record): Result {
        if (record.flag === 'A') {
            return this.handleTypeA(record);
        }
        // Co to jest "flag A"? Co to jest "Record"?
    }
}

class EntityManager {
    updateEntity(id: string, payload: object): void { /* ... */ }
}

class TransactionHandler {
    handleTransaction(txn: Transaction): void {
        txn.status = 'COMPLETED';
        this.repo.persist(txn);
    }
}
```

### Dobre nazewnictwo — język domeny

```typescript
// Kod, który mówi językiem ekspertów biznesowych
class OrderFulfillment {
    shipOrder(order: Order): Shipment {
        order.markAsShipped();
        return Shipment.create({
            orderId: order.id,
            items: order.items,
            shippingAddress: order.deliveryAddress,
        });
    }
}

class InvoiceService {
    issueInvoice(order: Order): Invoice {
        const invoice = Invoice.createFrom(order);
        invoice.calculateTax();
        return invoice;
    }
}

class ReturnPolicy {
    canAcceptReturn(order: Order, reason: ReturnReason): boolean {
        if (order.isOlderThan(Days.of(30))) return false;
        if (order.hasBeenReturned()) return false;
        return reason.isEligibleForReturn();
    }
}
```

### Porównanie

| Aspekt | Złe nazewnictwo | Dobre nazewnictwo |
|--------|-----------------|-------------------|
| Klasa | DataProcessor | OrderFulfillment |
| Metoda | processRecord() | shipOrder() |
| Parametr | record, payload, txn | order, invoice, returnReason |
| Status | "COMPLETED", "flag A" | shipped, invoiceIssued |
| Zmienna | entity, item, data | order, shipment, customer |

## Przykłady dobrego vs złego nazewnictwa

### Domena: e-commerce

```typescript
// ŹLE: nazwy generyczne, techniczne
class Service1 {
    execute(data: any): any {
        const result = this.validator.validate(data);
        if (result.ok) {
            this.repository.save(data);
            this.notifier.notify(data.userId);
        }
    }
}

// DOBRZE: nazwy domenowe, czytelne dla eksperta biznesowego
class OrderPlacement {
    placeOrder(cart: ShoppingCart, customer: Customer): Order {
        const order = Order.createFromCart(cart, customer);
        order.validateMinimumOrderValue();
        this.orderRepository.save(order);
        this.customerNotification.sendOrderConfirmation(customer, order);
        return order;
    }
}
```

### Domena: bankowość

```typescript
// ŹLE
class AccountManager {
    transfer(from: string, to: string, amount: number) { /* ... */ }
}

// DOBRZE
class FundsTransfer {
    execute(
        sourceAccount: BankAccount,
        destinationAccount: BankAccount,
        transferAmount: Money,
        transferPurpose: TransferPurpose,
    ): TransferConfirmation {
        sourceAccount.ensureSufficientFunds(transferAmount);
        sourceAccount.debit(transferAmount);
        destinationAccount.credit(transferAmount);
        return TransferConfirmation.issue(
            sourceAccount, destinationAccount, transferAmount
        );
    }
}
```

## Ewolucja języka

Ubiquitous Language nie jest statyczny — zmienia się gdy zespół lepiej rozumie domenę. Ważne jest, aby zmiany w języku były propagowane do kodu.

```
Wersja 1: "Klient anuluje zamówienie"
  → Order.cancel()

Wersja 2: Po rozmowie z ekspertem okazuje się, że jest różnica między:
  - Klient wycofuje zamówienie (przed wysyłką) → Order.withdraw()
  - Klient zwraca zamówienie (po otrzymaniu)   → Order.returnItems()
  - System anuluje zamówienie (brak płatności)  → Order.cancelDueToNonPayment()

Każdy scenariusz ma inne reguły biznesowe — wspólny język to ujawnia.
```

## Praktyczne wskazówki

- Używaj terminów biznesowych w kodzie, commitach, PR-ach i dokumentacji
- Gdy ekspert biznesowy nie rozumie nazwy klasy — nazwa jest zła
- Nie tłumacz terminów na siłę — jeśli biznes mówi "Invoice", klasa to Invoice, nie Faktura
- Termin "util", "helper", "manager", "handler" to sygnał braku języka domenowego
- Regularnie weryfikuj język z ekspertami — co kwartał rób przegląd glossariusza
- Nazwy metod powinny opisywać intencję biznesową, nie techniczną implementację
