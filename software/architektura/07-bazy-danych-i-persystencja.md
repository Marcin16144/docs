# Bazy danych i persystencja

> **Aktualizacja: 2026** — uwzględnia PostgreSQL 17+ (parallel query, native partitioning), Supabase, Neon, Turso, SurrealDB, vector search w pgvector.

## Typy baz danych

### Relacyjne (SQL)
**Przykłady:** PostgreSQL, MySQL, SQL Server, Oracle, **CockroachDB** (rozproszony, kompatybilny z Postgres).

**PostgreSQL 17+ (stan na 2026):**
- Znacząco ulepszony **parallel query** (planowanie i wykonanie na wielu workerach dla agregacji, JOIN, COPY)
- Dojrzała **native partycjonowanie** tabel (range/list/hash) — partition pruning, partition-wise joins
- Logical replication z DDL replication
- Wbudowana obsługa JSON/JSONB konkurująca z dokumentowymi DBs
- **pgvector** dojrzały — wektory do 16k wymiarów, indeksy HNSW i IVFFlat (wektory bez osobnej bazy)
- Dla wielu zespołów Postgres pełni rolę "one database to rule them all" (relacyjne + JSON + vector + full-text + time-series przez TimescaleDB)

**Serverless / managed Postgres (popularne w 2026):**
- **Supabase** — Postgres + Auth + Storage + Realtime + Edge Functions (alternatywa dla Firebase z otwartym SQL-em)
- **Neon** — serverless Postgres z separacją compute/storage, branching jak w Git (dev branche per PR)
- **Crunchy Bridge**, **Aiven**, **AWS Aurora Serverless v2/v3**

**Kiedy stosować:**
- Dane ze złożonymi relacjami
- Potrzeba transakcji ACID
- Złożone zapytania i raporty
- Spójność danych jest priorytetem

### SQLite na edge'u
- **Turso** (oparty o libSQL) i **Cloudflare D1** — replikowany SQLite blisko użytkownika
- Bardzo niskie opóźnienia odczytu, idealne dla aplikacji edge / globalnych
- Embedded SQLite nadal popularny w aplikacjach desktopowych, mobilnych i SaaS per-tenant

### Dokumentowe (NoSQL)
**Przykłady:** MongoDB, CouchDB, Amazon DynamoDB, Firestore

**Kiedy stosować:**
- Schemat danych zmienia się często
- Dane naturalne jako dokumenty (JSON)
- Skalowalność horyzontalna

> Uwaga (2026): Postgres z JSONB i częściowymi indeksami często wystarcza zamiast osobnej bazy dokumentowej.

### Klucz-Wartość
**Przykłady:** Redis (i fork **Valkey** po zmianie licencji Redis), Memcached, Amazon ElastiCache, KeyDB, Dragonfly

**Kiedy stosować:**
- Cache
- Sesje użytkowników
- Proste lookups po kluczu
- Edge KV: **Cloudflare Workers KV**, Vercel KV, Upstash Redis (globalny KV)

### Grafowe
**Przykłady:** Neo4j, Amazon Neptune, ArangoDB

**Kiedy stosować:**
- Sieci społecznościowe
- Silniki rekomendacji
- Złożone relacje między encjami

### Kolumnowe i analityczne
**Przykłady:** Apache Cassandra, ScyllaDB, HBase, **ClickHouse**, **Apache Doris**, **DuckDB** (embedded analityczna)

**Kiedy stosować:**
- Zapis dużych ilości danych
- Dane szeregów czasowych (alternatywnie: TimescaleDB, InfluxDB)
- Analityka na dużych zbiorach (OLAP)

### Wielomodelowe / nowsze
- **SurrealDB** — wielomodelowa (dokumentowa + grafowa + relacyjna), schemafull/schemaless, wbudowane uwierzytelnianie i live queries; w 2026 rośnie jako alternatywa dla połączenia kilku DB w jednym projekcie
- **EdgeDB** — relacyjna z mocnym schematem i językiem zapytań EdgeQL na bazie Postgres

### Wektorowe (Vector DBs) — kluczowe w erze AI/RAG
- **pgvector** (rozszerzenie Postgres) — najczęściej wybierane gdy już używasz Postgres
- **Qdrant** — open source, Rust, świetna wydajność i filtrowanie
- **Pinecone** — managed, prosty start, dobry SLA
- **Turbopuffer** — serverless, bardzo niski koszt na dużych zbiorach (oparty o object storage)
- **Weaviate**, **Milvus**, **Chroma**, **LanceDB** — pozostałe popularne opcje
- Indeksy: HNSW (najpopularniejszy), IVF, ScaNN; metryki: cosine, dot product, L2

---

## Twierdzenie CAP

W systemie rozproszonym możesz mieć tylko 2 z 3:

- **C (Consistency)** — każdy odczyt zwraca najnowsze dane
- **A (Availability)** — każde żądanie otrzymuje odpowiedź
- **P (Partition Tolerance)** — system działa mimo podziału sieci

Ponieważ partycje sieciowe się zdarzają, wybór to: **CP** (spójność) lub **AP** (dostępność).

---

## Wzorce persystencji

### Database per Service
Każdy mikroserwis ma własną bazę danych — pełna izolacja.

### Shared Database
Wiele serwisów korzysta z jednej bazy — prostsze, ale tworzy coupling.

### Event Sourcing
Zamiast przechowywać aktualny stan, przechowuj strumień zdarzeń.

```
Zdarzenia dla zamówienia #123:
1. OrderCreated { items: [...], customer: "Jan" }
2. ItemAdded { item: "Laptop" }
3. PaymentReceived { amount: 5000 }
4. OrderShipped { trackingId: "XYZ" }

Stan aktualny = odtworzenie ze zdarzeń
```

**Zalety:** Pełna historia zmian, audyt, możliwość odtworzenia stanu z dowolnego momentu.
**Wady:** Złożoność, potrzeba snapshotów dla wydajności.

### CQRS + Event Sourcing
Naturalnie łączą się — zdarzenia to model zapisu, projekcje to model odczytu.

---

## Migracje bazy danych

**Narzędzia (2026):** Flyway, Liquibase, **Atlas** (HCL/SQL, pracuje z każdą bazą), Prisma Migrate, **Drizzle Kit**, Knex migrations, **sqlx migrate** (Rust), Entity Framework Migrations, **Goose** (Go)

**Dobre praktyki:**
- Migracje powinny być idempotentne
- Backward-compatible zmiany (np. dodaj kolumnę nullable, nie usuwaj od razu)
- Strategia blue-green / expand-and-contract dla migracji zero-downtime
- Testuj migracje na kopii produkcyjnych danych
- Branching baz (np. Neon, Supabase) dla testowania migracji per Pull Request
