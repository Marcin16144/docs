# 04-04: Wzorce strukturalne — Adapter, Facade, Decorator

## Wzorce strukturalne

Wzorce strukturalne dotyczą kompozycji klas i obiektów w większe struktury. Pomagają zapewnić, że zmiana w jednej części systemu nie wymusza zmian w pozostałych. Trzy najczęściej stosowane to Adapter, Facade i Decorator.

## Adapter — opakowywanie zewnętrznych API

### Problem

Masz istniejący kod, który oczekuje określonego interfejsu, ale zewnętrzna biblioteka lub API dostarcza inny interfejs. Nie chcesz uzależniać całego systemu od konkretnej implementacji zewnętrznej.

### Rozwiązanie

Adapter tworzy warstwę pośredniczącą, która tłumaczy jeden interfejs na drugi.

```typescript
// Twój wewnętrzny interfejs
interface EmailService {
    send(to: string, subject: string, body: string): Promise<void>;
    sendBulk(messages: EmailMessage[]): Promise<BulkResult>;
}

// Zewnętrzne API (SendGrid) — inny kształt interfejsu
class SendGridClient {
    sendMail(params: {
        to: { email: string }[];
        subject: string;
        content: { type: string; value: string }[];
    }): Promise<SendGridResponse> { /* ... */ }
}

// Adapter tłumaczy Twój interfejs na API SendGrid
class SendGridAdapter implements EmailService {
    constructor(private client: SendGridClient) {}

    async send(to: string, subject: string, body: string): Promise<void> {
        await this.client.sendMail({
            to: [{ email: to }],
            subject,
            content: [{ type: 'text/html', value: body }],
        });
    }

    async sendBulk(messages: EmailMessage[]): Promise<BulkResult> {
        const results = await Promise.allSettled(
            messages.map(msg =>
                this.client.sendMail({
                    to: [{ email: msg.to }],
                    subject: msg.subject,
                    content: [{ type: 'text/html', value: msg.body }],
                })
            )
        );
        return {
            sent: results.filter(r => r.status === 'fulfilled').length,
            failed: results.filter(r => r.status === 'rejected').length,
        };
    }
}
```

### Wymiana implementacji

Dzięki adapterowi wymiana dostawcy (np. z SendGrid na AWS SES) wymaga tylko nowego adaptera, bez zmian w reszcie kodu.

```typescript
class AwsSesAdapter implements EmailService {
    constructor(private ses: SESClient) {}

    async send(to: string, subject: string, body: string): Promise<void> {
        await this.ses.send(new SendEmailCommand({
            Destination: { ToAddresses: [to] },
            Message: {
                Subject: { Data: subject },
                Body: { Html: { Data: body } },
            },
            Source: 'noreply@example.com',
        }));
    }

    async sendBulk(messages: EmailMessage[]): Promise<BulkResult> {
        // Implementacja z użyciem SES batch API
    }
}

// Konfiguracja DI — zmiana dostawcy w jednym miejscu
container.register<EmailService>(
    'EmailService',
    process.env.EMAIL_PROVIDER === 'ses'
        ? new AwsSesAdapter(sesClient)
        : new SendGridAdapter(sendGridClient)
);
```

## Facade — upraszczanie podsystemów

### Problem

Podsystem składa się z wielu klas z własnymi interfejsami. Klient musi znać szczegóły wielu komponentów, żeby wykonać prostą operację.

### Rozwiązanie

Facade zapewnia uproszczony interfejs do złożonego podsystemu. Nie ukrywa podsystemu — nadal można korzystać z poszczególnych klas bezpośrednio — ale oferuje wygodny skrót dla typowych operacji.

```typescript
// Złożony podsystem zamówień
class InventoryService {
    checkStock(productId: string): Promise<number> { /* ... */ }
    reserveStock(productId: string, qty: number): Promise<string> { /* ... */ }
    releaseReservation(reservationId: string): Promise<void> { /* ... */ }
}

class PricingService {
    calculatePrice(items: CartItem[]): Promise<PriceBreakdown> { /* ... */ }
    applyDiscount(code: string, price: PriceBreakdown): Promise<PriceBreakdown> { /* ... */ }
}

class PaymentService {
    authorize(amount: number, method: PaymentMethod): Promise<AuthResult> { /* ... */ }
    capture(authorizationId: string): Promise<CaptureResult> { /* ... */ }
    void(authorizationId: string): Promise<void> { /* ... */ }
}

class ShippingService {
    calculateShipping(address: Address, items: CartItem[]): Promise<ShippingOption[]> { /* ... */ }
    createShipment(orderId: string, option: ShippingOption): Promise<Shipment> { /* ... */ }
}

// Facade — uproszczony interfejs dla procesu składania zamówienia
class OrderFacade {
    constructor(
        private inventory: InventoryService,
        private pricing: PricingService,
        private payment: PaymentService,
        private shipping: ShippingService,
    ) {}

    async placeOrder(request: PlaceOrderRequest): Promise<OrderResult> {
        // 1. Sprawdź dostępność
        for (const item of request.items) {
            const stock = await this.inventory.checkStock(item.productId);
            if (stock < item.quantity) {
                throw new InsufficientStockError(item.productId);
            }
        }

        // 2. Rezerwuj towary
        const reservations = [];
        for (const item of request.items) {
            const resId = await this.inventory.reserveStock(
                item.productId, item.quantity
            );
            reservations.push(resId);
        }

        try {
            // 3. Oblicz cenę
            let price = await this.pricing.calculatePrice(request.items);
            if (request.discountCode) {
                price = await this.pricing.applyDiscount(
                    request.discountCode, price
                );
            }

            // 4. Autoryzuj płatność
            const auth = await this.payment.authorize(
                price.total, request.paymentMethod
            );

            // 5. Potwierdź płatność
            await this.payment.capture(auth.authorizationId);

            return { orderId: generateOrderId(), total: price.total };
        } catch (error) {
            // Cofnij rezerwacje w razie błędu
            for (const resId of reservations) {
                await this.inventory.releaseReservation(resId);
            }
            throw error;
        }
    }
}
```

### Facade vs Adapter

| Cecha | Adapter | Facade |
|-------|---------|--------|
| Cel | Konwersja interfejsu | Uproszczenie interfejsu |
| Liczba obiektów za fasadą | Jeden (opakowywany) | Wiele (cały podsystem) |
| Istniejący interfejs | Zmienia na kompatybilny | Upraszcza na wygodniejszy |
| Klient może pominąć? | Nie — potrzebuje kompatybilności | Tak — może użyć podsystemu bezpośrednio |

## Decorator — łańcuchy middleware

### Problem

Chcesz dynamicznie dodawać funkcjonalność do obiektu bez modyfikowania jego kodu. Na przykład: logowanie, cache, retry, walidacja — każda z tych cech powinna być niezależna i komponowalna.

### Rozwiązanie

Decorator opakowuje obiekt implementując ten sam interfejs i delegując wywołanie do opakowywanego obiektu, dodając własne zachowanie przed lub po.

```typescript
// Bazowy interfejs
interface HttpClient {
    request(config: RequestConfig): Promise<Response>;
}

// Podstawowa implementacja
class FetchHttpClient implements HttpClient {
    async request(config: RequestConfig): Promise<Response> {
        return fetch(config.url, {
            method: config.method,
            headers: config.headers,
            body: config.body,
        });
    }
}

// Decorator: logowanie
class LoggingHttpClient implements HttpClient {
    constructor(private inner: HttpClient) {}

    async request(config: RequestConfig): Promise<Response> {
        console.log(`→ ${config.method} ${config.url}`);
        const start = Date.now();
        try {
            const response = await this.inner.request(config);
            console.log(`← ${response.status} (${Date.now() - start}ms)`);
            return response;
        } catch (error) {
            console.error(`✗ ${config.method} ${config.url} FAILED`);
            throw error;
        }
    }
}

// Decorator: retry
class RetryHttpClient implements HttpClient {
    constructor(
        private inner: HttpClient,
        private maxRetries: number = 3,
    ) {}

    async request(config: RequestConfig): Promise<Response> {
        let lastError: Error;
        for (let attempt = 0; attempt <= this.maxRetries; attempt++) {
            try {
                return await this.inner.request(config);
            } catch (error) {
                lastError = error as Error;
                if (attempt < this.maxRetries) {
                    await this.delay(Math.pow(2, attempt) * 1000);
                }
            }
        }
        throw lastError!;
    }

    private delay(ms: number) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Decorator: cache
class CachingHttpClient implements HttpClient {
    private cache = new Map<string, { response: Response; expires: number }>();

    constructor(private inner: HttpClient, private ttlMs: number = 60000) {}

    async request(config: RequestConfig): Promise<Response> {
        if (config.method !== 'GET') {
            return this.inner.request(config);
        }
        const cached = this.cache.get(config.url);
        if (cached && cached.expires > Date.now()) {
            return cached.response.clone();
        }
        const response = await this.inner.request(config);
        this.cache.set(config.url, {
            response: response.clone(),
            expires: Date.now() + this.ttlMs,
        });
        return response;
    }
}
```

### Kompozycja dekoratorów

Siła wzorca leży w komponowaniu — każdy dekorator dodaje jedną odpowiedzialność, a łańcuch można składać dowolnie.

```typescript
// Składanie łańcucha dekoratorów
const httpClient: HttpClient =
    new LoggingHttpClient(           // 3. Loguj request/response
        new RetryHttpClient(          // 2. Ponów w razie błędu
            new CachingHttpClient(    // 1. Sprawdź cache
                new FetchHttpClient() // 0. Wykonaj request
            ),
            3
        )
    );

// Kolejność ma znaczenie!
// Logging → Retry → Cache → Fetch
// Log zobaczy retry, cache hit nie wywoła fetch
```

### Dekorator vs Dziedziczenie

| Cecha | Dziedziczenie | Decorator |
|-------|--------------|-----------|
| Dodawanie cech | Statyczne (kompilacja) | Dynamiczne (runtime) |
| Kombinacje | Eksplozja klas (2^n) | Dowolna kompozycja |
| Single Responsibility | Trudne do utrzymania | Naturalnie wymuszone |
| Usuwanie cech | Nowa hierarchia | Usunięcie z łańcucha |

## Kiedy stosować który wzorzec?

- **Adapter** — gdy integrujesz się z zewnętrznym API/biblioteką i chcesz odizolować swój kod od jej interfejsu
- **Facade** — gdy podsystem jest złożony i klienci potrzebują prostego API dla typowych operacji
- **Decorator** — gdy chcesz dynamicznie dodawać cross-cutting concerns (logowanie, cache, retry, metryki) bez modyfikacji istniejącego kodu
