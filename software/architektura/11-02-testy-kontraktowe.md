# Testy kontraktowe

## Problem — integracja miedzy serwisami

W architekturze mikroserwisowej serwisy komunikuja sie przez API. Zmiana w jednym serwisie moze zlamac inne serwisy, ktore od niego zaleza. Tradycyjne podejscia maja ograniczenia:

```
Problem:
  Order Service → GET /api/users/123 → User Service
  
  User Service zmienia format odpowiedzi:
    Przed: { "name": "Jan Kowalski", "email": "jan@ex.com" }
    Po:    { "fullName": "Jan Kowalski", "emailAddress": "jan@ex.com" }

  Order Service sie lamie — oczekuje "name" i "email"!

Tradycyjne rozwiazania:
  E2E testy — wolne, kruche, trudne do debugowania
  Mocki     — moga byc nieaktualne (drifting mocks)
  Dokumentacja — moze byc nieaktualna
```

## Czym sa testy kontraktowe?

Testy kontraktowe weryfikuja, ze dwa serwisy moga sie ze soba komunikowac — bez uruchamiania obu jednoczesnie. Kontrakt definiuje oczekiwany format komunikacji miedzy konsumentem (klientem) a providerem (serwerem).

```
Consumer (Order Service)        Provider (User Service)
         │                              │
         │  Kontrakt:                   │
         │  "GET /api/users/123         │
         │   zwraca { name, email }"    │
         │                              │
    Consumer Test               Provider Test
    (generuje kontrakt)    (weryfikuje kontrakt)
```

## Consumer-Driven Contracts (CDC)

W podejsciu CDC to konsument (klient) definiuje czego oczekuje od providera. Provider musi spelnic oczekiwania wszystkich swoich konsumentow.

```
           Consumer A
          (oczekuje: name, email)
                │
                ▼
    ┌─────────────────────┐
    │   Pact Broker       │    ← przechowuje kontrakty
    │  (repozytorium      │
    │   kontraktow)       │
    └─────────────────────┘
                │
                ▼
           Provider
    (musi spelnic oczekiwania
     Consumer A i Consumer B)
                │
                ▲
    ┌─────────────────────┐
    │   Pact Broker       │
    └─────────────────────┘
                ▲
                │
           Consumer B
          (oczekuje: name, phone)
```

## Pact Framework

Pact to najpopularniejszy framework do testow kontraktowych. Wspiera wiele jezykow (JavaScript, Java, Python, Go, .NET).

### Krok 1: Consumer Test

Konsument definiuje oczekiwane interakcje:

```javascript
// order-service/tests/userServiceContract.test.js
const { PactV3 } = require('@pact-foundation/pact');
const { UserApiClient } = require('../src/userApiClient');

const provider = new PactV3({
  consumer: 'OrderService',
  provider: 'UserService',
  dir: './pacts'
});

describe('User Service Contract', () => {
  it('returns user details by ID', async () => {
    // Arrange — definiuj oczekiwana interakcje
    provider
      .given('user 123 exists')
      .uponReceiving('a request for user 123')
      .withRequest({
        method: 'GET',
        path: '/api/users/123',
        headers: { Accept: 'application/json' }
      })
      .willRespondWith({
        status: 200,
        headers: { 'Content-Type': 'application/json' },
        body: {
          id: '123',
          name: like('Jan Kowalski'),    // dopasowanie typu
          email: like('jan@example.com'),
          role: term({
            generate: 'user',
            matcher: 'user|admin|editor'  // regex
          })
        }
      });

    // Act — wykonaj test z mock providerem
    await provider.executeTest(async (mockServer) => {
      const client = new UserApiClient(mockServer.url);
      const user = await client.getUser('123');

      // Assert
      expect(user.name).toBe('Jan Kowalski');
      expect(user.email).toBe('jan@example.com');
    });
  });

  it('returns 404 for non-existent user', async () => {
    provider
      .given('user 999 does not exist')
      .uponReceiving('a request for non-existent user')
      .withRequest({
        method: 'GET',
        path: '/api/users/999'
      })
      .willRespondWith({
        status: 404,
        body: { error: like('User not found') }
      });

    await provider.executeTest(async (mockServer) => {
      const client = new UserApiClient(mockServer.url);
      await expect(client.getUser('999'))
        .rejects.toThrow('User not found');
    });
  });
});

// Po uruchomieniu testu — generowany jest plik kontraktu:
// pacts/OrderService-UserService.json
```

### Krok 2: Publikacja kontraktu

```bash
# Publikuj kontrakt do Pact Broker
npx pact-broker publish ./pacts \
  --consumer-app-version=$(git rev-parse --short HEAD) \
  --branch=$(git branch --show-current) \
  --broker-base-url=https://pact.example.com \
  --broker-token=$PACT_TOKEN
```

### Krok 3: Provider Verification

Provider weryfikuje czy spelnia wszystkie kontrakty:

```javascript
// user-service/tests/providerVerification.test.js
const { Verifier } = require('@pact-foundation/pact');

describe('Provider Verification', () => {
  it('validates all consumer contracts', async () => {
    const verifier = new Verifier({
      providerBaseUrl: 'http://localhost:3000',
      provider: 'UserService',
      pactBrokerUrl: 'https://pact.example.com',
      pactBrokerToken: process.env.PACT_TOKEN,
      publishVerificationResult: true,
      providerVersion: process.env.GIT_SHA,
      providerVersionBranch: process.env.GIT_BRANCH,

      // State handlers — przygotowanie danych testowych
      stateHandlers: {
        'user 123 exists': async () => {
          await db.users.create({
            id: '123',
            name: 'Jan Kowalski',
            email: 'jan@example.com',
            role: 'user'
          });
        },
        'user 999 does not exist': async () => {
          await db.users.deleteAll();
        }
      }
    });

    await verifier.verifyProvider();
  });
});
```

## Pact Broker

Centralny serwer przechowujacy kontrakty i wyniki weryfikacji.

```
┌─────────────────────────────────────┐
│           Pact Broker               │
│                                     │
│  Kontrakty:                         │
│    OrderService → UserService       │
│    PaymentService → UserService     │
│    NotificationService → UserSvc    │
│                                     │
│  Weryfikacja:                       │
│    UserService v1.2.3 — PASSED      │
│    UserService v1.2.4 — FAILED      │
│                                     │
│  can-i-deploy:                      │
│    "Czy UserService v1.2.3 moze     │
│     byc wdrozony na produkcje?"     │
│    → TAK (wszystkie kontrakty OK)   │
└─────────────────────────────────────┘
```

### can-i-deploy

Sprawdzenie czy wersja serwisu moze byc bezpiecznie wdrozona:

```bash
# Czy moge wdrozyc UserService na produkcje?
npx pact-broker can-i-deploy \
  --pacticipant=UserService \
  --version=$(git rev-parse --short HEAD) \
  --to-environment=production

# Wynik:
# ✓ OrderService (v3.1.0) — verified
# ✓ PaymentService (v2.0.1) — verified
# ✓ NotificationService (v1.5.0) — verified
# → Mozna wdrozyc!
```

## Integracja z CI/CD

```yaml
# Consumer CI (.github/workflows/consumer.yml)
jobs:
  test:
    steps:
      - run: npm test              # generuje kontrakty
      - run: npx pact-broker publish ./pacts
          --consumer-app-version=${{ github.sha }}
          --branch=${{ github.ref_name }}

# Provider CI (.github/workflows/provider.yml)
jobs:
  verify:
    steps:
      - run: npm run start:test &   # uruchom serwer
      - run: npm run test:pact      # weryfikuj kontrakty
  
  deploy:
    needs: verify
    steps:
      - name: Can I Deploy?
        run: npx pact-broker can-i-deploy
          --pacticipant=UserService
          --version=${{ github.sha }}
          --to-environment=production
      - name: Deploy
        run: ./deploy.sh
      - name: Record Deployment
        run: npx pact-broker record-deployment
          --pacticipant=UserService
          --version=${{ github.sha }}
          --environment=production
```

## Pact Matchers

Zamiast dokladnych wartosci — dopasowania typow:

```javascript
const { like, eachLike, term, integer, decimal, boolean, string }
  = require('@pact-foundation/pact').Matchers;

// like — ten sam typ, dowolna wartosc
body: { name: like('Jan') }
// Akceptuje: "Anna", "Tomek", dowolny string

// eachLike — tablica elementow tego samego ksztaltu
body: { orders: eachLike({ id: like('ord-1'), total: decimal(99.99) }) }
// Akceptuje: tablica z dowolna iloscia obiektow o tym ksztalcie

// term — regex
body: { status: term({ generate: 'active', matcher: 'active|inactive' }) }

// integer, decimal, boolean, string
body: {
  count: integer(5),
  price: decimal(19.99),
  active: boolean(true),
  name: string('Jan')
}
```

## Kontrakty dla komunikacji asynchronicznej

Pact wspiera rowniez kontrakty dla komunikacji event-driven (message-based):

```javascript
// Consumer — oczekiwany format wiadomosci
describe('Order Created Event', () => {
  it('processes order created event', () => {
    return new MessageConsumerPact({
      consumer: 'NotificationService',
      provider: 'OrderService'
    })
    .expectsToReceive('an order created event')
    .withContent({
      orderId: like('ord-123'),
      customerEmail: like('jan@example.com'),
      total: decimal(299.99),
      items: eachLike({
        name: like('Product'),
        quantity: integer(1)
      })
    })
    .verify(async (message) => {
      const handler = new OrderCreatedHandler();
      await handler.handle(message);
      // weryfikuj efekty (np. wyslanie emaila)
    });
  });
});
```

## Kiedy stosowac testy kontraktowe?

### Stosuj gdy:
- Wiele serwisow komunikuje sie przez API
- Rozne zespoly rozwijaja rozne serwisy
- Chcesz wdrazac serwisy niezaleznie
- E2E testy sa wolne i kruche
- Potrzebujesz pewnosci przed wdrozeniem

### Nie stosuj gdy:
- Monolit (jeden deployable)
- Jeden zespol odpowiada za wszystkie serwisy
- Bardzo prosty system (2-3 endpointy)

## Kluczowe wnioski

1. **Testy kontraktowe** weryfikuja kompatybilnosc miedzy serwisami bez uruchamiania obu
2. **Consumer-Driven Contracts** — konsument definiuje czego oczekuje
3. **Pact Broker** przechowuje kontrakty i wyniki — centralny punkt prawdy
4. **can-i-deploy** sprawdza bezpieczenstwo wdrozenia przed deployem
5. **Matchers** zamiast dokladnych wartosci — testuj ksztalt, nie dane
6. **Integracja z CI/CD** — kontrakty publikowane i weryfikowane automatycznie
7. Testy kontraktowe **nie zastepuja** E2E — uzupelniaja je
