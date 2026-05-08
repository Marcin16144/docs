# Skalowalność i wydajność

> **Aktualizacja: 2026** — OpenTelemetry jako standard tracingu, edge computing (Cloudflare Workers KV, Fly.io, Vercel Edge) jako naturalna warstwa cache i obliczeń blisko użytkownika.

## Typy skalowania

### Skalowanie wertykalne (Scale Up)
Zwiększenie zasobów jednego serwera (CPU, RAM, dysk).
- Prostsze w implementacji
- Ma fizyczny limit
- Jeden punkt awarii

### Skalowanie horyzontalne (Scale Out)
Dodanie kolejnych instancji serwera.
- Teoretycznie nieograniczone
- Wymaga load balancera
- Złożoność przy stanie współdzielonym

---

## Load Balancing

### Algorytmy
- **Round Robin** — po kolei do każdej instancji
- **Least Connections** — do instancji z najmniejszą liczbą połączeń
- **IP Hash** — stały serwer dla danego klienta
- **Weighted** — proporcjonalnie do wagi/mocy serwera

### Narzędzia
Nginx, HAProxy, AWS ALB/NLB, Traefik

---

## Caching (Buforowanie)

### Poziomy cache
1. **Przeglądarka** — HTTP cache headers (Cache-Control, ETag)
2. **CDN / Edge** — statyczne zasoby i dynamiczne odpowiedzi blisko użytkownika
   - Cloudflare CDN, Fastly, AWS CloudFront, Vercel Edge Network, Bunny CDN
3. **Edge KV / Edge runtime (2026)** — stan i logika na edge'u
   - **Cloudflare Workers KV / Durable Objects / Cache API**
   - **Vercel Edge Config / Vercel KV**
   - **Fly.io** (regionalne instancje aplikacji blisko użytkowników)
   - **Deno Deploy**, **AWS Lambda@Edge**
4. **API Gateway** — cache odpowiedzi API
5. **Aplikacja** — Redis / Valkey, Memcached, Dragonfly, lokalny in-process cache (np. Caffeine, BigCache, ristretto)
6. **Baza danych** — query cache, materialized views, indexed views

### Strategie

| Strategia | Opis | Użycie |
|-----------|------|--------|
| **Cache-Aside** | Aplikacja zarządza cache | Ogólne zastosowanie |
| **Read-Through** | Cache sam pobiera z bazy | Częsty odczyt |
| **Write-Through** | Zapis do cache i bazy jednocześnie | Spójność ważna |
| **Write-Behind** | Zapis do cache, asynchronicznie do bazy | Wydajność zapisu |

### Cache Invalidation
"There are only two hard things in Computer Science: cache invalidation and naming things."

**Strategie:**
- **TTL (Time To Live)** — automatyczne wygaśnięcie
- **Event-based** — invalidacja przy zmianie danych
- **Version-based** — nowa wersja = nowy klucz cache

---

## Wzorce wydajnościowe

### Connection Pooling
Pula połączeń do bazy danych — unikaj otwierania nowego połączenia przy każdym żądaniu.

### Async Processing
Przetwarzanie zadań w tle — nie blokuj odpowiedzi API.

```
POST /api/reports → 202 Accepted { "jobId": "abc123" }
GET /api/reports/abc123/status → { "status": "processing" }
GET /api/reports/abc123/status → { "status": "completed", "url": "..." }
```

### Pagination
Nigdy nie zwracaj wszystkich rekordów — dziel na strony.
- **Offset-based:** ?page=3&limit=20
- **Cursor-based:** ?after=abc123&limit=20 (wydajniejsze dla dużych zbiorów)

### Database Indexing
Indeksy przyspieszają odczyt, ale spowalniają zapis. Indeksuj kolumny używane w WHERE, JOIN, ORDER BY.

### Sharding
Podział danych między wiele instancji bazy. Klucz shardingu determinuje gdzie trafią dane.

### Read Replicas
Kopie bazy danych do odczytu — odciążenie głównej bazy.

---

## Monitoring wydajności

### Kluczowe metryki
- **Latency** — czas odpowiedzi (p50, p95, p99)
- **Throughput** — żądania na sekundę (RPS)
- **Error rate** — procent błędnych odpowiedzi
- **Saturation** — wykorzystanie zasobów (CPU, RAM, dysk, sieć)

### Narzędzia (2026)
- **Standard instrumentacji: OpenTelemetry (OTel)** — jednolite SDK i protokół (OTLP) dla traces, metrics, logs. Eliminuje vendor lock-in.
- **APM:** Datadog, New Relic, Honeycomb, Dynatrace, Grafana Cloud
- **Metryki:** Prometheus + Grafana, **Mimir** (skalowalny long-term storage), **VictoriaMetrics**
- **Logi:** Grafana Loki, ELK Stack, OpenSearch, **Vector** (router logów)
- **Tracing (backendy):** Grafana Tempo, Jaeger, Zipkin, AWS X-Ray, Datadog APM
- **Profilowanie ciągłe:** Grafana Pyroscope, Polar Signals, Datadog Continuous Profiler

### Edge computing dla wydajności
Edge runtimes (Cloudflare Workers, Vercel Edge, Deno Deploy) pozwalają wykonywać kod w setkach lokalizacji bliskich użytkownikom — krytyczne dla aplikacji globalnych:
- Mniej hopów sieciowych = niższe RTT
- Cache stanu (Workers KV, Durable Objects) blisko użytkownika
- Personalizacja na edge bez round-tripa do origin
- WASM jako format dla edge functions (Fastly Compute, fermyon Spin)
