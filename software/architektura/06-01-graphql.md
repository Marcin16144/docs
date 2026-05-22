# 06-01: GraphQL — kompletny przewodnik

## Czym jest GraphQL?

GraphQL to jezyk zapytan do API oraz srodowisko uruchomieniowe do realizacji tych zapytan. Stworzony przez Facebooka w 2012 roku, opublikowany jako open source w 2015. W przeciwienstwie do REST, klient definiuje dokladnie jakie dane chce otrzymac.

## GraphQL vs REST

### Problem REST: Over-fetching i Under-fetching

```
REST — Over-fetching (za duzo danych):
GET /api/users/123
→ { id, name, email, address, phone, avatar, bio, settings, ... }
  (potrzebowales tylko name i email)

REST — Under-fetching (za malo danych, wiele requestow):
GET /api/users/123        → { id, name, ... }
GET /api/users/123/orders → [ { id, total, ... } ]
GET /api/orders/456/items → [ { name, price, ... } ]
  (3 roundtripy do serwera)

GraphQL — dokladnie to, czego potrzebujesz:
POST /graphql
query {
  user(id: "123") {
    name
    email
    orders(last: 5) {
      total
      items { name, price }
    }
  }
}
→ 1 request, dokladnie te pola
```

### Porownanie

| Cecha | REST | GraphQL |
|-------|------|---------|
| Endpointy | Wiele (per zasob) | Jeden (/graphql) |
| Ksztalt odpowiedzi | Zdefiniowany przez serwer | Zdefiniowany przez klienta |
| Over-fetching | Czeste | Brak |
| Under-fetching | Czeste | Brak |
| Wersjonowanie | /api/v1, /api/v2 | Ewolucja schematu |
| Cache HTTP | Natywny (GET + headers) | Wymaga dodatkowej pracy |
| Upload plikow | Natywny | Wymaga spec. rozwiazania |
| Real-time | WebSocket / SSE osobno | Subscriptions wbudowane |
| Krzywa uczenia | Nizsza | Wyzsza |
| Tooling | Powszechny | Rosnie, ale mniejszy |

## Podstawowe koncepcje

### Schema Definition Language (SDL)

```graphql
# Typy (definiuja ksztalt danych)
type User {
  id: ID!
  name: String!
  email: String!
  age: Int
  orders: [Order!]!
  role: Role!
}

type Order {
  id: ID!
  total: Float!
  status: OrderStatus!
  items: [OrderItem!]!
  createdAt: DateTime!
}

type OrderItem {
  product: Product!
  quantity: Int!
  price: Float!
}

# Enum
enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}

enum Role {
  USER
  ADMIN
  MODERATOR
}

# Input (dla mutacji)
input CreateOrderInput {
  items: [OrderItemInput!]!
  shippingAddress: AddressInput!
}

input OrderItemInput {
  productId: ID!
  quantity: Int!
}
```

### Queries (Zapytania — odczyt)

```graphql
# Definicja w schema
type Query {
  user(id: ID!): User
  users(limit: Int, offset: Int): [User!]!
  order(id: ID!): Order
  searchProducts(query: String!, category: String): [Product!]!
}

# Uzycie przez klienta
query GetUserWithOrders {
  user(id: "123") {
    name
    email
    orders(last: 5) {
      id
      total
      status
      items {
        product { name }
        quantity
        price
      }
    }
  }
}
```

### Mutations (Mutacje — zapis/zmiana)

```graphql
# Definicja w schema
type Mutation {
  createOrder(input: CreateOrderInput!): Order!
  updateOrderStatus(id: ID!, status: OrderStatus!): Order!
  cancelOrder(id: ID!): Order!
  register(email: String!, password: String!, name: String!): AuthPayload!
  login(email: String!, password: String!): AuthPayload!
}

type AuthPayload {
  token: String!
  user: User!
}

# Uzycie
mutation CreateNewOrder {
  createOrder(input: {
    items: [
      { productId: "prod_1", quantity: 2 },
      { productId: "prod_2", quantity: 1 }
    ]
    shippingAddress: {
      street: "ul. Glowna 1"
      city: "Warszawa"
      zip: "00-001"
    }
  }) {
    id
    total
    status
  }
}
```

### Subscriptions (Subskrypcje — real-time)

```graphql
# Definicja
type Subscription {
  orderStatusChanged(orderId: ID!): Order!
  newMessage(chatId: ID!): Message!
}

# Uzycie (klient subskrybuje)
subscription WatchOrder {
  orderStatusChanged(orderId: "order_123") {
    id
    status
    updatedAt
  }
}
```

### Fragments (Fragmenty — reuzywalne kawałki zapytan)

```graphql
# Definicja fragmentu
fragment UserBasicInfo on User {
  id
  name
  email
  avatar
}

# Uzycie w zapytaniach
query GetDashboard {
  currentUser {
    ...UserBasicInfo
    role
  }
  recentOrders {
    id
    total
    customer {
      ...UserBasicInfo
    }
  }
}
```

## Architektura serwera GraphQL

### Resolvers (Resolvery)

Funkcje, ktore zwracaja dane dla kazdego pola w schema:

```javascript
const resolvers = {
  Query: {
    user: async (parent, { id }, context) => {
      return context.dataSources.userAPI.getUser(id);
    },
    users: async (parent, { limit, offset }, context) => {
      return context.dataSources.userAPI.getUsers({ limit, offset });
    }
  },

  Mutation: {
    createOrder: async (parent, { input }, context) => {
      // sprawdz autoryzacje
      if (!context.currentUser) throw new AuthenticationError();

      return context.dataSources.orderAPI.create({
        userId: context.currentUser.id,
        ...input
      });
    }
  },

  // Field resolver — leniwe ladowanie
  User: {
    orders: async (user, args, context) => {
      return context.dataSources.orderAPI.getByUserId(user.id);
    }
  }
};
```

### DataLoader (rozwiazanie problemu N+1)

```javascript
// Problem N+1:
// Zapytanie o 10 zamowien → 10 osobnych zapytan o uzytkownika

// Rozwiazanie: DataLoader batchuje zapytania
const userLoader = new DataLoader(async (userIds) => {
  // Jedno zapytanie: SELECT * FROM users WHERE id IN (...)
  const users = await db.users.findByIds(userIds);
  // Zwroc w tej samej kolejnosci co klucze
  return userIds.map(id => users.find(u => u.id === id));
});

// Resolver uzywa loadera
const resolvers = {
  Order: {
    customer: (order) => userLoader.load(order.customerId)
  }
};
```

### Context

Wspoldzielony obiekt dostepny we wszystkich resolverach:

```javascript
const server = new ApolloServer({
  typeDefs,
  resolvers,
  context: async ({ req }) => {
    const token = req.headers.authorization || '';
    const user = await authenticateToken(token);

    return {
      currentUser: user,
      dataSources: {
        userAPI: new UserAPI(),
        orderAPI: new OrderAPI()
      }
    };
  }
});
```

## Bezpieczenstwo GraphQL

### 1. Limitowanie zlozonosci zapytan

```javascript
// Zle — klient moze zlozyc dowolnie zlozoone zapytanie:
query Evil {
  users {
    orders {
      items {
        product {
          reviews {
            author {
              orders {
                items { ... }  // nieskonczone zagniezdzenie
              }
            }
          }
        }
      }
    }
  }
}

// Rozwiazanie: ograniczenie glebokosci
const depthLimit = require('graphql-depth-limit');
const server = new ApolloServer({
  validationRules: [depthLimit(5)]
});
```

### 2. Query cost analysis

```javascript
// Przypisanie kosztu do pol
const costDirective = {
  User: { cost: 1 },
  'User.orders': { cost: 10 },     // droga operacja
  'Order.items': { cost: 5 }
};

// Limit calkowitego kosztu zapytania
const MAX_COST = 1000;
```

### 3. Rate limiting

```javascript
// Per-query rate limiting
const rateLimiter = createRateLimiter({
  max: 100,       // max 100 zapytan
  window: '1m'    // na minute
});
```

### 4. Autoryzacja na poziomie resolverow

```javascript
const resolvers = {
  Query: {
    users: async (_, args, context) => {
      if (!context.currentUser?.role === 'ADMIN') {
        throw new ForbiddenError('Admin only');
      }
      return context.dataSources.userAPI.getAll();
    }
  }
};
```

### 5. Persisted Queries

```javascript
// Zamiast wysylac cale zapytanie, klient wysyla hash
// Serwer ma whitelist dozwolonych zapytan

POST /graphql
{ "id": "abc123hash", "variables": { "userId": "123" } }

// Zapobiega arbitralnym zapytaniom w produkcji
```

## Pagination w GraphQL

### Cursor-based (Relay-style) — zalecane

```graphql
type Query {
  orders(
    first: Int
    after: String
    last: Int
    before: String
  ): OrderConnection!
}

type OrderConnection {
  edges: [OrderEdge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type OrderEdge {
  cursor: String!
  node: Order!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# Uzycie
query {
  orders(first: 10, after: "cursor_abc") {
    edges {
      cursor
      node { id, total, status }
    }
    pageInfo {
      hasNextPage
      endCursor
    }
    totalCount
  }
}
```

## Narzedzia i technologie

### Serwery GraphQL
| Technologia | Jezyk | Uwagi |
|-------------|-------|-------|
| Apollo Server | Node.js / TypeScript | Najpopularniejszy, bogaty ekosystem |
| GraphQL Yoga | Node.js / TypeScript | Lekki, elastyczny |
| Strawberry | Python | Nowoczesny, type-safe |
| Hot Chocolate | C# / .NET | Dojrzaly, wydajny |
| gqlgen | Go | Generowanie kodu z schema |
| Juniper | Rust | Type-safe, wydajny |

### Klienty GraphQL
| Klient | Platforma | Uwagi |
|--------|-----------|-------|
| Apollo Client | React, Angular, Vue | Najpopularniejszy, cache |
| urql | React, Vue, Svelte | Lekki, modularny |
| Relay | React | Stworzony przez Meta, zaawansowany |
| graphql-request | Uniwersalny | Minimalny, prosty |

### Narzedzia developerskie
- **GraphQL Playground / Apollo Studio** — IDE do testowania zapytan
- **GraphQL Code Generator** — generowanie typow z schema
- **GraphQL Inspector** — porownywanie wersji schema, wykrywanie breaking changes

## Kiedy stosowac GraphQL?

### Stosuj gdy:
- Frontend potrzebuje elastycznych zapytan (rozne widoki, rozne dane)
- Masz wiele zrodel danych do agregacji
- Mobile + Web z roznymi wymaganiami danych
- Czeste zmiany wymagan UI (unikasz zmian API)
- Zespol frontendowy chce niezaleznosci od backendu

### Nie stosuj gdy:
- Proste CRUD API (REST wystarczy)
- File upload jest glowna funkcja
- Potrzebujesz natywnego HTTP caching
- Maly zespol / prosty projekt
- Public API (REST jest bardziej znany i latwiejszy do uzycia)

## Dobre praktyki

1. **Schema-first development** — zaprojektuj schema przed implementacja
2. **Nie mapuj 1:1 do bazy** — schema to kontrakt, nie model danych
3. **Uzywaj DataLoader** — zawsze, dla unikniecia N+1
4. **Limituj zlozonosc** — depth limit + cost analysis
5. **Monitoruj resolwery** — sledzenie wydajnosci per-field
6. **Wersjonuj przez ewolucje** — dodawaj pola, deprecjonuj stare, nie usuwaj
7. **Generuj typy** — GraphQL Code Generator dla type safety
