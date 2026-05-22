# 06-06: Circuit Breaker i wzorce odporności

## Problem kaskadowych awarii

W systemach rozproszonych awaria jednego serwisu może spowodować kaskadę awarii. Gdy serwis B przestaje odpowiadać, serwis A (który go wywołuje) blokuje wątki czekając na odpowiedź. Wkrótce serwis A też przestaje odpowiadać, co wpływa na serwis C, itd.

```
Klient → Serwis A → Serwis B (awaria!)
                     ↑ timeout 30s
         Serwis A czeka...
         Wątki się kończą...
         Serwis A też pada!
         ↑
Klient → Serwis C → Serwis A (nie odpowiada!)
                     Serwis C też pada!

Efekt domina — jedna awaria paraliżuje cały system.
```

## Circuit Breaker

Wzorzec inspirowany bezpiecznikiem elektrycznym — przerywa komunikację z niestabilnym serwisem, zanim problem się rozprzestrzeni.

### 3 stany Circuit Breakera

```
                   sukces
    ┌──────────── CLOSED ←──────────┐
    │  (normalny ruch)              │
    │                               │
    │ próg błędów                   │ próba
    │ przekroczony                  │ udana
    ↓                               │
   OPEN ──── timeout ────→ HALF-OPEN
(blokuje ruch)           (przepuszcza próbne żądania)
    ↑                        │
    │     próba              │
    └──── nieudana ──────────┘
```

### Stan CLOSED (zamknięty — normalny)

Żądania przechodzą normalnie. Circuit Breaker liczy błędy.

```
Konfiguracja:
- failureThreshold: 5       (max 5 błędów)
- failureWindow: 60s        (w oknie 60 sekund)

Żądanie 1: sukces  (failures: 0)
Żądanie 2: sukces  (failures: 0)
Żądanie 3: BŁĄD   (failures: 1)
Żądanie 4: sukces  (failures: 1)
Żądanie 5: BŁĄD   (failures: 2)
Żądanie 6: BŁĄD   (failures: 3)
Żądanie 7: BŁĄD   (failures: 4)
Żądanie 8: BŁĄD   (failures: 5) → OTWÓRZ circuit!
```

### Stan OPEN (otwarty — blokujący)

Żądania natychmiast odrzucane bez próby połączenia. Chroni zasoby i daje serwisowi czas na regenerację.

```
Żądanie 9:  → natychmiast odrzucone (CircuitBreakerOpenException)
Żądanie 10: → natychmiast odrzucone
Żądanie 11: → natychmiast odrzucone

Po upływie openTimeout (np. 30s) → przejdź do HALF-OPEN
```

### Stan HALF-OPEN (pół-otwarty — testowy)

Przepuszcza ograniczoną liczbę żądań testowych, aby sprawdzić, czy serwis wrócił.

```
successThreshold: 3 (potrzebne 3 sukcesy)

Żądanie testowe 1: sukces  → (1/3)
Żądanie testowe 2: sukces  → (2/3)
Żądanie testowe 3: sukces  → (3/3) → zamknij circuit!
                                      Powrót do CLOSED

LUB:
Żądanie testowe 1: sukces  → (1/3)
Żądanie testowe 2: BŁĄD   → Powrót do OPEN
```

### Implementacja (pseudokod)

```python
class CircuitBreaker:
    def __init__(self, failure_threshold=5, open_timeout=30,
                 success_threshold=3):
        self.state = "CLOSED"
        self.failure_count = 0
        self.success_count = 0
        self.failure_threshold = failure_threshold
        self.open_timeout = open_timeout
        self.success_threshold = success_threshold
        self.last_failure_time = None

    def call(self, func, *args, **kwargs):
        if self.state == "OPEN":
            if self._timeout_expired():
                self.state = "HALF_OPEN"
                self.success_count = 0
            else:
                raise CircuitBreakerOpenError(
                    "Circuit is OPEN — request rejected")

        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise e

    def _on_success(self):
        if self.state == "HALF_OPEN":
            self.success_count += 1
            if self.success_count >= self.success_threshold:
                self.state = "CLOSED"
                self.failure_count = 0
        elif self.state == "CLOSED":
            self.failure_count = 0  # reset na sukces

    def _on_failure(self):
        self.failure_count += 1
        self.last_failure_time = time.time()
        if self.state == "HALF_OPEN":
            self.state = "OPEN"  # powrót do OPEN
        elif self.failure_count >= self.failure_threshold:
            self.state = "OPEN"

    def _timeout_expired(self):
        return (time.time() - self.last_failure_time) >= self.open_timeout
```

## Retry z Exponential Backoff

Automatyczne ponawianie żądań z rosnącym opóźnieniem między próbami.

### Dlaczego exponential backoff?

```
Natychmiastowy retry (źle):
Próba 1: BŁĄD → retry → BŁĄD → retry → BŁĄD → retry...
Serwer jest przeciążony, a my go bombardujemy!

Exponential backoff (dobrze):
Próba 1: BŁĄD → czekaj 1s
Próba 2: BŁĄD → czekaj 2s
Próba 3: BŁĄD → czekaj 4s
Próba 4: BŁĄD → czekaj 8s
Próba 5: sukces!

Z jitter (losowe odchylenie):
Próba 1: BŁĄD → czekaj 1s + random(0, 500ms)
Próba 2: BŁĄD → czekaj 2s + random(0, 1000ms)
...
Jitter zapobiega thundering herd — wielu klientów
nie retry'uje w tym samym momencie.
```

### Implementacja

```python
import random
import time

def retry_with_backoff(func, max_retries=5, base_delay=1.0,
                       max_delay=60.0, jitter=True):
    for attempt in range(max_retries):
        try:
            return func()
        except RetryableError as e:
            if attempt == max_retries - 1:
                raise  # ostatnia próba — propaguj błąd

            delay = min(base_delay * (2 ** attempt), max_delay)
            if jitter:
                delay = delay * (0.5 + random.random())  # 50-150%

            print(f"Próba {attempt + 1} nieudana, "
                  f"czekam {delay:.1f}s: {e}")
            time.sleep(delay)
```

### Które błędy ponawiać?

```
PONAWIAJ (transient errors):
- 429 Too Many Requests
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Service Unavailable
- 504 Gateway Timeout
- Connection timeout
- Network error

NIE PONAWIAJ (permanent errors):
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 422 Validation Error
```

## Bulkhead Pattern (wzorzec grodzi)

Inspirowany grodziami na statkach — izoluj zasoby, aby awaria jednego komponentu nie wpływała na resztę.

### Problem

```
Serwis A — jedna pula wątków (100 wątków):
  → wywołuje Serwis B (wolny!) — 80 wątków zablokowanych
  → wywołuje Serwis C (OK) — brak wolnych wątków!
  → wywołuje Serwis D (OK) — brak wolnych wątków!

Powolny Serwis B zablokował komunikację ze WSZYSTKIMI serwisami!
```

### Rozwiązanie — osobne pule

```
Serwis A:
  Pula dla Serwis B: [30 wątków] → max 30 zablokowanych
  Pula dla Serwis C: [30 wątków] → działa normalnie!
  Pula dla Serwis D: [30 wątków] → działa normalnie!

Awaria B nie blokuje C i D.
```

### Typy Bulkhead

#### 1. Thread Pool Isolation

Osobna pula wątków dla każdego dependency.

```java
// Resilience4j — thread pool bulkhead
BulkheadConfig config = BulkheadConfig.custom()
    .maxConcurrentCalls(30)     // max 30 równoległych wywołań
    .maxWaitDuration(Duration.ofMillis(500))  // max czekanie
    .build();

Bulkhead bulkhead = Bulkhead.of("serviceB", config);

Supplier<String> decorated = Bulkhead
    .decorateSupplier(bulkhead, () -> serviceB.getData());
```

#### 2. Semaphore Isolation

Lżejsza wersja — ogranicza liczbę równoległych wywołań bez osobnej puli wątków.

```python
import asyncio

semaphore_service_b = asyncio.Semaphore(30)

async def call_service_b():
    async with semaphore_service_b:
        return await http_client.get("http://service-b/api")
    # Jeśli 30 wywołań w toku — następne czekają
```

## Timeout Pattern

Ustaw maksymalny czas oczekiwania na odpowiedź. Prosty, ale krytyczny wzorzec.

```python
import httpx

# Timeout na każde wywołanie
response = httpx.get(
    "http://service-b/api/data",
    timeout=httpx.Timeout(
        connect=2.0,    # max 2s na połączenie
        read=5.0,       # max 5s na odczyt
        write=5.0,      # max 5s na zapis
        pool=10.0       # max 10s na uzyskanie połączenia z puli
    )
)
```

### Zasady timeoutów

```
Klient → Serwis A → Serwis B → Serwis C

Timeout klienta:  10s
Timeout A → B:     5s (mniejszy niż klienta!)
Timeout B → C:     2s (mniejszy niż A → B!)

WAŻNE: Timeout w łańcuchu musi maleć!
Jeśli A czeka 10s na B, a B czeka 10s na C,
klient może czekać 20+ sekund.
```

## Fallback Pattern

Zapasowe zachowanie, gdy główna ścieżka zawiedzie.

### Strategie Fallback

```python
class ProductService:
    def get_product(self, product_id):
        try:
            # 1. Główne źródło
            return self.primary_api.get(product_id)
        except ServiceUnavailableError:
            pass

        try:
            # 2. Cache
            cached = self.cache.get(f"product:{product_id}")
            if cached:
                return cached  # stale data is better than no data
        except CacheError:
            pass

        try:
            # 3. Zapasowe API
            return self.backup_api.get(product_id)
        except ServiceUnavailableError:
            pass

        # 4. Domyślna odpowiedź
        return Product.default(product_id)
```

### Typy Fallback

| Strategia | Opis | Kiedy |
|-----------|------|-------|
| Cache fallback | Zwróć dane z cache (stale) | Dane mogą być nieaktualne |
| Default value | Zwróć wartość domyślną | Gdy brak danych jest akceptowalny |
| Backup service | Wywołaj zapasowy serwis | Gdy jest redundancja |
| Graceful degradation | Ogranicz funkcjonalność | Gdy część systemu wystarczy |
| Fail fast | Natychmiast zwróć błąd | Gdy fallback nie istnieje |

## Polly (.NET)

Polly to biblioteka odporności dla .NET — obsługuje wszystkie omawiane wzorce.

```csharp
// Circuit Breaker + Retry + Timeout — łączenie polityk
var retryPolicy = Policy
    .Handle<HttpRequestException>()
    .Or<TimeoutException>()
    .WaitAndRetryAsync(
        retryCount: 3,
        sleepDurationProvider: attempt =>
            TimeSpan.FromSeconds(Math.Pow(2, attempt))  // 2s, 4s, 8s
    );

var circuitBreaker = Policy
    .Handle<HttpRequestException>()
    .CircuitBreakerAsync(
        exceptionsAllowedBeforeBreaking: 5,
        durationOfBreak: TimeSpan.FromSeconds(30),
        onBreak: (ex, duration) =>
            logger.LogWarning($"Circuit OPEN for {duration}"),
        onReset: () =>
            logger.LogInformation("Circuit CLOSED")
    );

var timeout = Policy
    .TimeoutAsync(TimeSpan.FromSeconds(5));

var bulkhead = Policy
    .BulkheadAsync(
        maxParallelization: 30,
        maxQueuingActions: 10
    );

// Złożenie polityk (wykonanie od zewnątrz do wewnątrz)
var resilientPolicy = Policy.WrapAsync(
    retryPolicy,      // Zewnętrzna: retry
    circuitBreaker,   // Circuit breaker
    bulkhead,         // Bulkhead
    timeout           // Wewnętrzna: timeout
);

// Użycie
var result = await resilientPolicy.ExecuteAsync(async () =>
{
    return await httpClient.GetAsync("http://service-b/api");
});
```

### Polly v8+ (Microsoft.Extensions.Resilience)

```csharp
// .NET 8+ — nowe API
builder.Services.AddHttpClient("service-b")
    .AddStandardResilienceHandler(options =>
    {
        options.Retry.MaxRetryAttempts = 3;
        options.Retry.BackoffType = DelayBackoffType.Exponential;
        options.CircuitBreaker.BreakDuration = TimeSpan.FromSeconds(30);
        options.AttemptTimeout.Timeout = TimeSpan.FromSeconds(5);
        options.TotalRequestTimeout.Timeout = TimeSpan.FromSeconds(30);
    });
```

## Resilience4j (Java)

Biblioteka odporności dla Javy, inspirowana Netflix Hystrix.

```java
// Circuit Breaker
CircuitBreakerConfig cbConfig = CircuitBreakerConfig.custom()
    .failureRateThreshold(50)              // 50% błędów otwiera circuit
    .slowCallRateThreshold(80)             // 80% wolnych wywołań
    .slowCallDurationThreshold(Duration.ofSeconds(2))
    .waitDurationInOpenState(Duration.ofSeconds(30))
    .permittedNumberOfCallsInHalfOpenState(5)
    .slidingWindowSize(10)
    .build();

CircuitBreaker circuitBreaker = CircuitBreaker.of("serviceB", cbConfig);

// Retry
RetryConfig retryConfig = RetryConfig.custom()
    .maxAttempts(3)
    .waitDuration(Duration.ofMillis(500))
    .retryOnResult(response -> response.getStatus() == 500)
    .retryExceptions(IOException.class, TimeoutException.class)
    .build();

Retry retry = Retry.of("serviceB", retryConfig);

// Bulkhead
BulkheadConfig bhConfig = BulkheadConfig.custom()
    .maxConcurrentCalls(30)
    .maxWaitDuration(Duration.ofMillis(500))
    .build();

Bulkhead bulkhead = Bulkhead.of("serviceB", bhConfig);

// Złożenie (wykonanie od prawej do lewej)
Supplier<String> decorated = Decorators.ofSupplier(() -> serviceB.call())
    .withCircuitBreaker(circuitBreaker)
    .withBulkhead(bulkhead)
    .withRetry(retry)
    .withFallback(Arrays.asList(CallNotPermittedException.class),
        e -> "Fallback response")
    .decorate();

String result = decorated.get();
```

### Spring Boot + Resilience4j

```java
@Service
public class ProductService {

    @CircuitBreaker(name = "inventory", fallbackMethod = "fallback")
    @Retry(name = "inventory")
    @Bulkhead(name = "inventory")
    @TimeLimiter(name = "inventory")
    public CompletableFuture<Product> getProduct(String id) {
        return CompletableFuture.supplyAsync(() ->
            inventoryClient.getProduct(id));
    }

    public CompletableFuture<Product> fallback(String id, Throwable t) {
        log.warn("Fallback for product {}: {}", id, t.getMessage());
        return CompletableFuture.completedFuture(
            Product.defaultProduct(id));
    }
}
```

## Łączenie wzorców

Prawidłowa kolejność zastosowania wzorców w łańcuchu wywołania:

```
Żądanie wchodzi
  ↓
[1. Bulkhead]         — ogranicz równoległość
  ↓
[2. Circuit Breaker]  — sprawdź czy circuit otwarty
  ↓
[3. Retry]            — ponawiaj przy błędzie
  ↓
[4. Timeout]          — ogranicz czas odpowiedzi
  ↓
Właściwe wywołanie serwisu
  ↓
Odpowiedź (lub Fallback)
```

## Monitorowanie i metryki

Każdy wzorzec powinien emitować metryki:

```
Circuit Breaker:
- circuit_breaker_state{name="serviceB"} = 0/1/0.5  (closed/open/half-open)
- circuit_breaker_calls_total{name="serviceB", result="success|failure"}
- circuit_breaker_not_permitted_total{name="serviceB"}

Retry:
- retry_calls_total{name="serviceB", result="success|failure"}
- retry_calls_total{name="serviceB", retry_count="1|2|3"}

Bulkhead:
- bulkhead_concurrent_calls{name="serviceB"}
- bulkhead_rejected_total{name="serviceB"}

Timeout:
- timeout_total{name="serviceB"}
- call_duration_seconds{name="serviceB"}
```

## Dobre praktyki

1. **Zawsze ustawiaj timeout** — brak timeoutu = ryzyko wyczerpania zasobów
2. **Circuit breaker per dependency** — osobny breaker dla każdego serwisu
3. **Retry tylko dla transient errors** — nie ponawiaj 400/404
4. **Jitter w backoff** — zapobiegaj thundering herd
5. **Fallback zawsze dostępny** — nawet jeśli to domyślna wartość
6. **Monitoruj stany** — dashboard ze stanem wszystkich circuit breakerów
7. **Testuj z Chaos Engineering** — symuluj awarie (Chaos Monkey, Toxiproxy)
8. **Łącz wzorce mądrze** — retry wewnątrz circuit breakera, nie odwrotnie
9. **Nie ukrywaj błędów** — fallback loguj, alertuj, analizuj przyczynę
10. **Dostosuj progi** — za niski threshold otwiera circuit zbyt łatwo, za wysoki — zbyt późno
