# 06-02: REST API — kompletny przewodnik

## Czym jest REST?

REST (Representational State Transfer) to styl architektoniczny dla systemów rozproszonych, zdefiniowany przez Roya Fieldinga w 2000 roku w jego rozprawie doktorskiej. REST nie jest protokołem ani standardem — to zbiór ograniczeń (constraints), które definiują sposób komunikacji między klientem a serwerem za pośrednictwem HTTP.

## Zasady RESTful

### 6 ograniczeń REST

1. **Client-Server** — separacja odpowiedzialności, klient i serwer rozwijane niezależnie
2. **Stateless** — każde żądanie zawiera wszystkie informacje potrzebne do jego przetworzenia, serwer nie przechowuje stanu sesji
3. **Cacheable** — odpowiedzi muszą definiować, czy mogą być cachowane
4. **Uniform Interface** — jednolity interfejs (identyfikacja zasobów, manipulacja przez reprezentacje, samoopisujące wiadomości, HATEOAS)
5. **Layered System** — klient nie wie, czy komunikuje się bezpośrednio z serwerem, czy z pośrednikiem
6. **Code on Demand** (opcjonalne) — serwer może wysłać kod wykonywalny do klienta

## Richardson Maturity Model

Model dojrzałości REST wg Leonarda Richardsona — 4 poziomy:

### Poziom 0 — The Swamp of POX

Jeden endpoint, jeden verb (zazwyczaj POST). Praktycznie RPC przez HTTP.

```
POST /api
{ "action": "getUser", "userId": 123 }

POST /api
{ "action": "createOrder", "items": [...] }

POST /api
{ "action": "deleteUser", "userId": 123 }
```

Wszystkie operacje trafiają pod ten sam adres. HTTP jest używany jedynie jako transport.

### Poziom 1 — Resources

Wprowadzenie zasobów (osobne URI), ale nadal jeden verb.

```
POST /users/123
{ "action": "get" }

POST /orders
{ "action": "create", "items": [...] }
```

Każdy zasób ma swój adres, ale HTTP metody nie są wykorzystywane poprawnie.

### Poziom 2 — HTTP Verbs

Poprawne użycie metod HTTP i kodów statusu. To poziom, na którym operuje większość "RESTful" API.

```
GET    /users/123          → 200 OK
POST   /orders             → 201 Created
PUT    /users/123          → 200 OK
DELETE /orders/456         → 204 No Content
GET    /nonexistent        → 404 Not Found
```

### Poziom 3 — HATEOAS (Hypermedia Controls)

Odpowiedź zawiera linki do powiązanych zasobów i dostępnych akcji. Klient nie musi znać struktury URL — nawiguje po linkach.

```json
{
  "id": 123,
  "name": "Jan Kowalski",
  "email": "jan@example.com",
  "_links": {
    "self":   { "href": "/users/123" },
    "orders": { "href": "/users/123/orders" },
    "edit":   { "href": "/users/123", "method": "PUT" },
    "delete": { "href": "/users/123", "method": "DELETE" }
  }
}
```

HATEOAS pozwala serwerowi sterować zachowaniem klienta — np. jeśli użytkownik nie ma uprawnień do usunięcia, link "delete" nie pojawi się w odpowiedzi.

## Metody HTTP — semantyka

| Metoda | Cel | Idempotentna | Bezpieczna | Body |
|--------|-----|:------------:|:----------:|:----:|
| GET | Pobranie zasobu | Tak | Tak | Nie |
| POST | Utworzenie zasobu | Nie | Nie | Tak |
| PUT | Zastąpienie zasobu (cały) | Tak | Nie | Tak |
| PATCH | Częściowa aktualizacja | Nie* | Nie | Tak |
| DELETE | Usunięcie zasobu | Tak | Nie | Nie |
| HEAD | Jak GET, ale bez body | Tak | Tak | Nie |
| OPTIONS | Informacja o dostępnych metodach | Tak | Tak | Nie |

*PATCH może być idempotentny, ale nie musi — zależy od implementacji.

### Różnica PUT vs PATCH

```
PUT /users/123
Content-Type: application/json
{
  "name": "Jan Kowalski",
  "email": "jan@example.com",
  "phone": "+48 123 456 789",
  "address": "Warszawa"
}
→ Zastępuje CAŁY zasób (wszystkie pola wymagane)

PATCH /users/123
Content-Type: application/json
{
  "phone": "+48 999 888 777"
}
→ Zmienia TYLKO podane pole
```

## Kody statusu HTTP — przewodnik

### 2xx — Sukces

| Kod | Nazwa | Kiedy używać |
|-----|-------|-------------|
| 200 | OK | Domyślny sukces (GET, PUT, PATCH) |
| 201 | Created | Zasób utworzony (POST), Location header |
| 202 | Accepted | Żądanie przyjęte do asynchronicznego przetwarzania |
| 204 | No Content | Sukces bez body (DELETE) |

### 3xx — Przekierowanie

| Kod | Nazwa | Kiedy używać |
|-----|-------|-------------|
| 301 | Moved Permanently | Zasób przeniesiony na stałe |
| 304 | Not Modified | Cache nadal aktualny |
| 307 | Temporary Redirect | Tymczasowe przekierowanie z zachowaniem metody |

### 4xx — Błąd klienta

| Kod | Nazwa | Kiedy używać |
|-----|-------|-------------|
| 400 | Bad Request | Niepoprawne dane wejściowe |
| 401 | Unauthorized | Brak uwierzytelnienia |
| 403 | Forbidden | Brak uprawnień (uwierzytelniony, ale bez dostępu) |
| 404 | Not Found | Zasób nie istnieje |
| 405 | Method Not Allowed | Niedozwolona metoda HTTP |
| 409 | Conflict | Konflikt (np. duplikat email) |
| 422 | Unprocessable Entity | Walidacja nie przeszła |
| 429 | Too Many Requests | Rate limit przekroczony |

### 5xx — Błąd serwera

| Kod | Nazwa | Kiedy używać |
|-----|-------|-------------|
| 500 | Internal Server Error | Nieoczekiwany błąd serwera |
| 502 | Bad Gateway | Błąd upstream serwisu |
| 503 | Service Unavailable | Serwis tymczasowo niedostępny |
| 504 | Gateway Timeout | Timeout od upstream |

## Idempotentność

Operacja jest idempotentna, gdy wielokrotne wykonanie daje ten sam rezultat co jednokrotne.

```
GET /users/123        → Zawsze ten sam wynik (idempotentne)
DELETE /users/123     → Za pierwszym razem usuwa, za drugim 404 (idempotentne)
PUT /users/123 {...}  → Zawsze ustawia te same dane (idempotentne)

POST /orders {...}    → Każde wywołanie tworzy nowe zamówienie (NIE idempotentne!)
```

### Wymuszanie idempotentności dla POST

```
POST /orders
Idempotency-Key: 550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json
{
  "items": [{ "productId": "prod_1", "quantity": 2 }]
}

→ Pierwsze wywołanie: tworzy zamówienie, 201 Created
→ Drugie wywołanie z tym samym kluczem: zwraca istniejące zamówienie, 200 OK
```

Serwer przechowuje mapę klucz idempotentności -> odpowiedź. Jeśli ten sam klucz pojawi się ponownie, zwraca zapisaną odpowiedź bez ponownego wykonywania operacji.

## Wersjonowanie API

### Strategia 1: Wersja w URL (najpopularniejsza)

```
GET /api/v1/users/123
GET /api/v2/users/123
```

Zalety: proste, jasne, łatwe w routingu.
Wady: zmiana URL łamie kontrakt, duplikacja kodu.

### Strategia 2: Wersja w nagłówku (Accept header)

```
GET /api/users/123
Accept: application/vnd.myapi.v2+json
```

Zalety: URL się nie zmienia.
Wady: trudniejsze w testowaniu (trzeba ustawiać nagłówki).

### Strategia 3: Query parameter

```
GET /api/users/123?version=2
```

Zalety: proste w użyciu.
Wady: łatwe do pominięcia, cache może nie uwzględnić.

### Strategia 4: Ewolucja bez wersjonowania

```json
// v1 — oryginalne pole
{ "name": "Jan Kowalski" }

// v2 — dodaj nowe pole, zachowaj stare
{ "name": "Jan Kowalski", "firstName": "Jan", "lastName": "Kowalski" }

// v3 — oznacz stare jako deprecated, usun po czasie
{ "firstName": "Jan", "lastName": "Kowalski" }
```

Zalety: nie łamie istniejących klientów.
Wady: schema rośnie, wymaga dyscypliny.

## OpenAPI / Swagger

OpenAPI Specification (dawniej Swagger) to standard opisu REST API w formacie YAML/JSON.

```yaml
openapi: 3.0.3
info:
  title: User API
  version: 1.0.0

paths:
  /users/{id}:
    get:
      summary: Pobierz uzytkownika
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
      responses:
        '200':
          description: Sukces
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '404':
          description: Nie znaleziono

components:
  schemas:
    User:
      type: object
      required: [id, name, email]
      properties:
        id:
          type: integer
        name:
          type: string
        email:
          type: string
          format: email
```

### Korzyści OpenAPI

- **Dokumentacja** — automatycznie generowana, interaktywna (Swagger UI)
- **Generowanie kodu** — klienty SDK w dowolnym języku
- **Walidacja** — automatyczna walidacja request/response
- **Testowanie** — generowanie testów z definicji
- **Mockowanie** — mock serwer z definicji

## Paginacja

### Offset-based (tradycyjna)

```
GET /api/users?page=3&limit=20

Odpowiedz:
{
  "data": [...],
  "pagination": {
    "page": 3,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

Zalety: prosta w implementacji, użytkownik może skoczyć do dowolnej strony.
Wady: niestabilna przy wstawianiu/usuwaniu danych (powtórzenia, pominięcia), wolna dla dużych offsetów (DB musi przeskanować N wierszy).

### Cursor-based (zalecana)

```
GET /api/users?limit=20&cursor=eyJpZCI6MTAwfQ==

Odpowiedz:
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTIwfQ==",
    "prevCursor": "eyJpZCI6MTAxfQ==",
    "hasMore": true
  }
}
```

Zalety: stabilna (nie pomija/powtarza), wydajna (WHERE id > cursor LIMIT N).
Wady: nie można skoczyć do konkretnej strony, cursor jest opaque.

### Keyset-based

```
GET /api/users?limit=20&after_id=100&after_created=2024-01-15

→ WHERE (created_at, id) > ('2024-01-15', 100)
  ORDER BY created_at, id
  LIMIT 20
```

Wariant cursor-based z jawnym kluczem sortowania.

## Rate Limiting

### Nagłówki rate limit

```
HTTP/1.1 200 OK
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 997
X-RateLimit-Reset: 1609459200
Retry-After: 60
```

### Strategie

- **Fixed window** — limit na stałe okno czasowe (np. 1000/min)
- **Sliding window** — ruchome okno (bardziej sprawiedliwe)
- **Token bucket** — tokeny generowane ze stałą prędkością, żądanie zużywa token
- **Leaky bucket** — żądania przetwarzane ze stałą prędkością, nadmiar odrzucany

### Odpowiedź przy przekroczeniu limitu

```
HTTP/1.1 429 Too Many Requests
Content-Type: application/json
Retry-After: 60
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1609459200

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Przekroczono limit 1000 zapytan na minute",
    "retryAfter": 60
  }
}
```

## Najlepsze praktyki projektowania REST API

### 1. Nazewnictwo zasobów

```
DOBRZE:
GET    /users                 → lista użytkowników
GET    /users/123             → konkretny użytkownik
GET    /users/123/orders      → zamówienia użytkownika
POST   /users/123/orders      → nowe zamówienie użytkownika

ZLE:
GET    /getUser?id=123
POST   /createNewOrder
DELETE /removeUserFromSystem/123
GET    /user/123              → brak liczby mnogiej
```

### 2. Filtrowanie, sortowanie, wyszukiwanie

```
GET /api/products?category=electronics&price_min=100&price_max=500
GET /api/products?sort=-created_at,name
GET /api/products?search=laptop
GET /api/products?fields=id,name,price
```

### 3. Spójny format błędów

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Walidacja nie powiodla sie",
    "details": [
      {
        "field": "email",
        "message": "Niepoprawny format email",
        "code": "INVALID_FORMAT"
      },
      {
        "field": "age",
        "message": "Wiek musi byc wiekszy niz 0",
        "code": "MIN_VALUE"
      }
    ]
  }
}
```

### 4. Nagłówki i content negotiation

```
Request:
Accept: application/json
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
X-Request-ID: 550e8400-e29b-41d4-a716-446655440000

Response:
Content-Type: application/json; charset=utf-8
ETag: "abc123"
Cache-Control: max-age=3600
```

### 5. HATEOAS w praktyce

```json
{
  "id": 456,
  "status": "PENDING",
  "total": 199.99,
  "_links": {
    "self":    { "href": "/orders/456" },
    "pay":     { "href": "/orders/456/pay", "method": "POST" },
    "cancel":  { "href": "/orders/456/cancel", "method": "POST" },
    "items":   { "href": "/orders/456/items" }
  }
}
```

Gdy zamówienie zmieni status na "PAID", link "pay" zniknie, a pojawi się "refund".

### 6. Bulk operations

```
POST /api/users/bulk
{
  "operations": [
    { "method": "POST", "body": { "name": "Jan", "email": "jan@x.com" } },
    { "method": "POST", "body": { "name": "Anna", "email": "anna@x.com" } }
  ]
}

→ 207 Multi-Status
{
  "results": [
    { "status": 201, "body": { "id": 1, "name": "Jan" } },
    { "status": 409, "body": { "error": "Email already exists" } }
  ]
}
```

## Podsumowanie

REST API to fundament współczesnych systemów rozproszonych. Klucz do sukcesu leży w:
- Poprawnym użyciu metod HTTP i kodów statusu
- Spójnym nazewnictwie i strukturze zasobów
- Dokumentacji przez OpenAPI/Swagger
- Wersjonowaniu strategicznym
- Zabezpieczeniach (rate limiting, walidacja, autoryzacja)
- Wykorzystaniu idempotentności dla niezawodności
