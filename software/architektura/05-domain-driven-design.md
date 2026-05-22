# Domain-Driven Design (DDD)

## Czym jest DDD?

Podejście do tworzenia oprogramowania, w którym model domeny biznesowej jest centralnym elementem architektury. Wprowadzone przez Erica Evansa w 2003 roku.

## Pojęcia strategiczne

### Ubiquitous Language (Język wszechobecny)
Wspólny język używany przez programistów i ekspertów biznesowych. Terminy biznesowe są bezpośrednio odzwierciedlone w kodzie.

```
// Źle — techniczny żargon
class DataProcessor {
    processRecord(record) { ... }
}

// Dobrze — język domeny
class OrderFulfillment {
    shipOrder(order) { ... }
}
```

### Bounded Context (Kontekst ograniczony)
Wyraźna granica, w której dany model ma spójne znaczenie.

Przykład: "Klient" oznacza co innego w kontekście:
- **Sprzedaż** — potencjalny nabywca z budżetem
- **Wysyłka** — adres dostawy i preferencje
- **Rozliczenia** — dane do faktury i historia płatności

Każdy kontekst ma swój własny model "Klienta".

### Context Map (Mapa kontekstów)
Diagram relacji między kontekstami ograniczonymi:

- **Partnership** — oba zespoły współpracują
- **Shared Kernel** — wspólna część modelu
- **Customer-Supplier** — jeden zespół dostarcza, drugi konsumuje
- **Conformist** — konsument dostosowuje się do dostawcy
- **Anti-Corruption Layer** — warstwa tłumacząca między kontekstami
- **Open Host Service** — dostawca udostępnia protokół
- **Published Language** — wspólny format wymiany danych

---

## Pojęcia taktyczne

### Entity (Encja)
Obiekt z unikalną tożsamością, istotny przez cykl życia.
Przykład: Zamówienie (identyfikowane przez OrderId).

### Value Object (Obiekt wartości)
Obiekt bez tożsamości, definiowany przez swoje atrybuty. Niemutowalny.
Przykład: Adres, Pieniądze, Zakres dat.

```
class Money {
    constructor(readonly amount: number, readonly currency: string) {}

    add(other: Money): Money {
        if (this.currency !== other.currency) throw new Error("Currency mismatch");
        return new Money(this.amount + other.amount, this.currency);
    }

    equals(other: Money): boolean {
        return this.amount === other.amount && this.currency === other.currency;
    }
}
```

### Aggregate (Agregat)
Klaster powiązanych obiektów traktowanych jako jednostka do celów zmian danych. Ma korzeń agregatu (Aggregate Root).

**Zasady:**
- Zewnętrzne obiekty mogą odwoływać się tylko do korzenia agregatu
- Korzeń odpowiada za spójność całego agregatu
- Agregaty powinny być małe

### Domain Service (Serwis domenowy)
Operacja, która nie należy naturalnie do żadnej encji ani obiektu wartości.

### Domain Event (Zdarzenie domenowe)
Fakt, który się wydarzył w domenie.
Przykład: `OrderPlaced`, `PaymentReceived`, `ShipmentDispatched`.

### Repository
Interfejs do pobierania i zapisywania agregatów.

---

## Kiedy stosować DDD?

**Stosuj gdy:**
- Domena jest złożona
- Eksperci biznesowi są dostępni do współpracy
- System będzie długo rozwijany

**Nie stosuj gdy:**
- Prosta domena (CRUD)
- Brak dostępu do ekspertów biznesowych
- Prototyp/MVP
