# SQL vs NoSQL

## Wprowadzenie

Wybor bazy danych to jedna z najwazniejszych decyzji architektonicznych. Nie istnieje uniwersalne rozwiazanie — kazdy typ bazy danych ma swoje mocne strony i ograniczenia. Kluczem jest zrozumienie wymagan systemu i dopasowanie technologii.

## Modele danych

### SQL (relacyjne)

Dane zorganizowane w tabelach z wierszami i kolumnami. Relacje miedzy tabelami przez klucze obce. Schema jest scisle zdefiniowana (schema-on-write).

```sql
-- Schema definiowana z gory
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  total DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Relacja przez JOIN
SELECT u.name, o.total, o.status
FROM users u
JOIN orders o ON o.user_id = u.id
WHERE u.id = 'abc-123';
```

### NoSQL — Document (MongoDB, Couchbase)

Dane przechowywane jako dokumenty (JSON/BSON). Schema jest elastyczna (schema-on-read). Mozliwosc zagniezdzania powiazanych danych.

```json
// Kolekcja: users
{
  "_id": "abc-123",
  "email": "jan@example.com",
  "name": "Jan Kowalski",
  "orders": [
    {
      "id": "ord-1",
      "total": 299.99,
      "status": "delivered",
      "items": [
        { "product": "Laptop Stand", "qty": 1, "price": 299.99 }
      ]
    }
  ]
}
```

### NoSQL — Key-Value (Redis, DynamoDB)

Najprostszy model — klucz mapowany na wartosc. Ekstremalnie szybki odczyt/zapis. Idealny do cache, sesji, countery.

```
SET user:abc-123 '{"name":"Jan","email":"jan@example.com"}'
GET user:abc-123

SET session:token-xyz '{"userId":"abc-123","expires":"2025-12-31"}'
EXPIRE session:token-xyz 3600
```

### NoSQL — Column-Family (Cassandra, HBase)

Dane zorganizowane w rodziny kolumn. Zoptymalizowane do zapisu i odczytu duzych wolumenow danych. Idealny do danych czasowych (time-series).

```
// Cassandra CQL
CREATE TABLE events (
  sensor_id TEXT,
  event_time TIMESTAMP,
  temperature DOUBLE,
  humidity DOUBLE,
  PRIMARY KEY (sensor_id, event_time)
) WITH CLUSTERING ORDER BY (event_time DESC);
```

### NoSQL — Graph (Neo4j, Amazon Neptune)

Dane jako wezly i krawedzie. Naturalny model dla relacji wielokierunkowych. Idealny do sieci spolecznosciowych, rekomendacji, wykrywania oszustw.

```cypher
// Neo4j Cypher
CREATE (jan:User {name: "Jan"})
CREATE (anna:User {name: "Anna"})
CREATE (jan)-[:FOLLOWS]->(anna)
CREATE (anna)-[:FOLLOWS]->(jan)

// Znajdz przyjaciol przyjaciol
MATCH (u:User {name: "Jan"})-[:FOLLOWS]->()-[:FOLLOWS]->(fof)
WHERE fof <> u
RETURN DISTINCT fof.name
```

## ACID vs BASE

### ACID (SQL)

| Wlasciwosc | Opis |
|-------------|------|
| **Atomicity** | Transakcja jest niepodzielna — albo wszystko, albo nic |
| **Consistency** | Dane po transakcji sa w spocojnym stanie |
| **Isolation** | Rownolegle transakcje nie wplywaja na siebie |
| **Durability** | Zatwierdzone dane przetrwaja awarie |

```sql
BEGIN TRANSACTION;
  UPDATE accounts SET balance = balance - 100 WHERE id = 'A';
  UPDATE accounts SET balance = balance + 100 WHERE id = 'B';
  -- Jesli cokolwiek sie nie powiedzie, oba UPDATE sa cofane
COMMIT;
```

### BASE (NoSQL)

| Wlasciwosc | Opis |
|-------------|------|
| **Basically Available** | System zawsze odpowiada (moze byc nieaktualna odpowiedz) |
| **Soft state** | Stan systemu moze sie zmieniac z czasem |
| **Eventually consistent** | Dane beda spojne po pewnym czasie |

```
Zapis do Node A ──→ Replikacja ──→ Node B (opoznienie ~ms)
                                   Node C (opoznienie ~ms)

Klient czyta z Node B zaraz po zapisie do Node A
→ Moze dostac stara wartosc (eventual consistency)
→ Po chwili wartosc bedzie aktualna
```

## Porownanie SQL vs NoSQL

| Aspekt | SQL | NoSQL |
|--------|-----|-------|
| Schema | Sztywna, zdefiniowana z gory | Elastyczna, dynamiczna |
| Skalowanie | Wertykalne (wiekszy serwer) | Horyzontalne (wiecej serwerow) |
| Spojnosc | Silna (ACID) | Eventual consistency (BASE) |
| Zapytania | SQL — potezny, standardowy | Specyficzne per baza |
| JOINy | Natywne, wydajne | Ograniczone lub brak |
| Transakcje | Pelne, wielotabelowe | Ograniczone (czesto per dokument) |
| Normalizacja | Tak — unikanie redundancji | Denormalizacja — szybkosc odczytu |

## Twierdzenie CAP

Rozproszony system moze gwarantowac tylko **2 z 3** wlasciwosci:

- **Consistency** — wszystkie wezly widza te same dane
- **Availability** — system odpowiada na kazde zapytanie
- **Partition tolerance** — system dziala mimo awarii sieci

```
         Consistency
           /     \
          /       \
    CA (SQL)    CP (MongoDB)
        |         |
        |    Partition
        |   Tolerance
        |         |
    ----+---------+----
        |         |
   AP (Cassandra, DynamoDB)
        |
    Availability
```

**Praktyczne wnioski:**
- **CP** (MongoDB, HBase) — preferuj spojnosc, akceptuj niedostepnosc
- **AP** (Cassandra, DynamoDB) — preferuj dostepnosc, akceptuj chwilowa niespojnosc
- **CA** (tradycyjny SQL) — nie toleruje partycji (tylko jeden wezel)

## Sciezki migracji

### SQL -> NoSQL

1. **Zidentyfikuj wzorce dostepu** — jakie zapytania sa najczestsze?
2. **Zaprojektuj model pod zapytania** — w NoSQL model danych wynika z zapytan
3. **Denormalizuj dane** — zaakceptuj redundancje dla szybkosci
4. **Migruj inkrementalnie** — zacznij od jednego serwisu/kolekcji
5. **Utrzymuj podwojny zapis** (dual write) w okresie przejsciowym

### NoSQL -> SQL

1. **Zidentyfikuj relacje** miedzy danymi
2. **Znormalizuj dane** — usun redundancje
3. **Zdefiniuj schema** i constrainty
4. **Migruj dane** z transformacja
5. **Zweryfikuj integralnosc** po migracji

## Polyglot Persistence

Uzywanie roznych baz danych do roznych celow w jednym systemie:

```
┌─────────────────────────────────────────────────┐
│              System e-commerce                   │
│                                                  │
│  ┌──────────┐  ┌───────────┐  ┌──────────────┐ │
│  │ Uzytkow. │  │ Zamowienia│  │   Sesje      │ │
│  │ PostgreSQL│  │ PostgreSQL│  │   Redis      │ │
│  │ (ACID)   │  │ (ACID)    │  │ (szybkosc)   │ │
│  └──────────┘  └───────────┘  └──────────────┘ │
│                                                  │
│  ┌──────────┐  ┌───────────┐  ┌──────────────┐ │
│  │ Katalog  │  │ Wyszukiw. │  │ Rekomendacje │ │
│  │ MongoDB  │  │ Elastic   │  │   Neo4j      │ │
│  │ (elast.) │  │ (full-txt)│  │ (graf relac.)│ │
│  └──────────┘  └───────────┘  └──────────────┘ │
│                                                  │
│  ┌──────────┐  ┌───────────┐                    │
│  │ Logi     │  │ Analityka │                    │
│  │ Elastic  │  │ ClickHouse│                    │
│  │ (logi)   │  │ (OLAP)    │                    │
│  └──────────┘  └───────────┘                    │
└─────────────────────────────────────────────────┘
```

**Zasady polyglot persistence:**
1. Wybieraj baze pod **konkretny problem**, nie odwrotnie
2. Pamietaj o **koszcie operacyjnym** — kazda baza to dodatkowa infrastruktura
3. Rozważ **spojnosc danych** miedzy bazami (eventy, saga)
4. Zacznij od **jednej bazy** i dodawaj kolejne gdy potrzeba udowodni wartosc

## Popularne bazy danych

| Baza | Typ | Kiedy stosowac |
|------|-----|---------------|
| PostgreSQL | Relacyjna | Ogolnego przeznaczenia, JSONB, pelnotekstowe |
| MySQL | Relacyjna | Proste aplikacje webowe, WordPress |
| MongoDB | Dokumentowa | Elastyczny schemat, prototypowanie |
| Redis | Key-Value | Cache, sesje, kolejki, pub/sub |
| Cassandra | Kolumnowa | Duze wolumeny zapisu, time-series |
| Elasticsearch | Wyszukiwarka | Full-text search, logi, analityka |
| Neo4j | Grafowa | Relacje, rekomendacje, fraud detection |
| ClickHouse | Kolumnowa (OLAP) | Analityka, agregacje na duzych danych |
| DynamoDB | Key-Value/Document | AWS, serverless, niska latencja |

## Kluczowe wnioski

1. **Nie ma uniwersalnej bazy** — kazda ma swoje mocne strony
2. **Zacznij od wymagan** — wzorce dostepu determinuja wybor
3. **ACID nie zawsze potrzebny** — eventual consistency czesto wystarczy
4. **Polyglot persistence** to sila, ale i koszt operacyjny
5. **PostgreSQL** to czesto najlepszy punkt startu — relacyjna z cechami NoSQL (JSONB)
6. **Migruj inkrementalnie** — dual write + stopniowe przelaczanie ruchu
