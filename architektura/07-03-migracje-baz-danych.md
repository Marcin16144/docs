# Migracje baz danych

## Czym sa migracje?

Migracje baz danych to kontrolowane, wersjonowane zmiany schematu bazy danych. Tak jak Git sluzy do wersjonowania kodu, migracje sluza do wersjonowania struktury bazy danych. Kazda migracja opisuje zmiane (np. dodanie kolumny, tabeli, indeksu) i moze byc zastosowana lub cofnieta.

## Dlaczego migracje sa wazne?

- **Powtarzalnosc** — ten sam schemat na kazdym srodowisku (dev, staging, prod)
- **Historia zmian** — kto, kiedy i dlaczego zmienil schemat
- **Automatyzacja** — migracje uruchamiane w pipeline CI/CD
- **Wspolpraca** — wielu developerow moze zmieniac schemat bez konfliktow
- **Rollback** — mozliwosc cofniecia zmian w razie problemow

## Podstawowa struktura migracji

### Numerowane migracje (Flyway)

```
migrations/
  V001__create_users_table.sql
  V002__add_email_to_users.sql
  V003__create_orders_table.sql
  V004__add_index_on_orders_user_id.sql
```

```sql
-- V001__create_users_table.sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- V002__add_email_to_users.sql
ALTER TABLE users ADD COLUMN email VARCHAR(255);
UPDATE users SET email = 'unknown@example.com' WHERE email IS NULL;
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
ALTER TABLE users ADD CONSTRAINT users_email_unique UNIQUE(email);
```

### Migracje z rollbackiem (Liquibase)

```xml
<!-- changelog.xml -->
<changeSet id="001" author="jan">
  <createTable tableName="users">
    <column name="id" type="UUID" defaultValueComputed="gen_random_uuid()">
      <constraints primaryKey="true"/>
    </column>
    <column name="name" type="VARCHAR(100)">
      <constraints nullable="false"/>
    </column>
    <column name="email" type="VARCHAR(255)">
      <constraints unique="true" nullable="false"/>
    </column>
  </createTable>
  <rollback>
    <dropTable tableName="users"/>
  </rollback>
</changeSet>
```

### Prisma Migrate

```prisma
// schema.prisma
model User {
  id    String  @id @default(uuid())
  name  String
  email String  @unique
  orders Order[]
}

model Order {
  id     String @id @default(uuid())
  total  Float
  userId String
  user   User   @relation(fields: [userId], references: [id])
}
```

```bash
# Generowanie migracji z modelu
npx prisma migrate dev --name add_orders_table

# Zastosowanie na produkcji
npx prisma migrate deploy
```

## Zero-Downtime Migrations

Migracje bez przerwy w dzialaniu systemu — kluczowe dla systemow 24/7. Glowna zasada: **nigdy nie lamiemy kompatybilnosci wstecznej** w jednym kroku.

### Problem

```
Krok 1: Deploy nowego kodu (uzywa nowej kolumny)
Krok 2: Migracja bazy (dodaje nowa kolumne)

BLAD! Miedzy krokiem 1 a 2 — kod szuka kolumny, ktorej nie ma.

Odwrotnie:
Krok 1: Migracja bazy (usuwa stara kolumne)
Krok 2: Deploy nowego kodu (nie uzywa starej kolumny)

BLAD! Miedzy krokiem 1 a 2 — stary kod szuka kolumny, ktora usunieto.
```

### Rozwiazanie: Expand-Contract Pattern

Kazda niebezpieczna zmiana rozbita na bezpieczne kroki:

```
Faza 1: EXPAND (rozszerzenie)
  - Dodaj nowa kolumne/tabele
  - Stary kod dziala bez zmian

Faza 2: MIGRATE (migracja danych)
  - Przepisz dane do nowej struktury
  - Nowy kod pisze do obu miejsc (dual write)

Faza 3: CONTRACT (skurcz)
  - Usun stara kolumne/tabele
  - Tylko po pelnym przejsciu na nowy kod
```

## Expand-Contract — przyklady

### Zmiana nazwy kolumny

```sql
-- ZLE: jedna migracja, lamie kompatybilnosc
ALTER TABLE users RENAME COLUMN name TO full_name;

-- DOBRZE: 3 kroki

-- Krok 1: EXPAND — dodaj nowa kolumne
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);
UPDATE users SET full_name = name;
-- Trigger do synchronizacji w okresie przejsciowym:
CREATE TRIGGER sync_name_to_fullname
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION sync_columns();

-- Krok 2: DEPLOY — nowy kod uzywa full_name
-- (stary kod dalej dziala, bo kolumna name istnieje)

-- Krok 3: CONTRACT — usun stara kolumne
DROP TRIGGER sync_name_to_fullname ON users;
ALTER TABLE users DROP COLUMN name;
```

### Zmiana typu kolumny

```sql
-- ZLE: bezposrednia zmiana
ALTER TABLE orders ALTER COLUMN total TYPE BIGINT;

-- DOBRZE: expand-contract

-- Krok 1: EXPAND
ALTER TABLE orders ADD COLUMN total_v2 BIGINT;
UPDATE orders SET total_v2 = CAST(total * 100 AS BIGINT);

-- Krok 2: DEPLOY nowy kod (pisze do obu kolumn)
-- INSERT INTO orders (total, total_v2) VALUES (19.99, 1999);

-- Krok 3: CONTRACT
ALTER TABLE orders DROP COLUMN total;
ALTER TABLE orders RENAME COLUMN total_v2 TO total;
```

### Usuwanie kolumny

```sql
-- ZLE: usun od razu
ALTER TABLE users DROP COLUMN phone;

-- DOBRZE:

-- Krok 1: DEPLOY — nowy kod nie czyta/pisze do kolumny phone
-- (ale kolumna dalej istnieje w bazie)

-- Krok 2: Oznacz jako deprecated (opcjonalnie)
COMMENT ON COLUMN users.phone IS 'DEPRECATED - do not use';

-- Krok 3: CONTRACT — usun kolumne (po pelnym wdrozeniu nowego kodu)
ALTER TABLE users DROP COLUMN phone;
```

## Backward Compatible Changes

### Zawsze bezpieczne (nie wymagaja expand-contract)

| Zmiana | Przyklad |
|--------|----------|
| Dodanie tabeli | `CREATE TABLE orders (...)` |
| Dodanie kolumny nullable | `ALTER TABLE users ADD COLUMN bio TEXT` |
| Dodanie indeksu (CONCURRENTLY) | `CREATE INDEX CONCURRENTLY idx_email ON users(email)` |
| Dodanie widoku | `CREATE VIEW active_users AS ...` |
| Dodanie wartosci do enum | `ALTER TYPE status ADD VALUE 'archived'` |

### Wymagaja expand-contract

| Zmiana | Ryzyko |
|--------|--------|
| Zmiana nazwy kolumny | Stary kod nie znajdzie kolumny |
| Zmiana typu kolumny | Niekompatybilne dane |
| Usuwanie kolumny | Stary kod nie znajdzie kolumny |
| Dodanie NOT NULL | Stary kod moze nie wysylac wartosci |
| Usuwanie tabeli | Stary kod odwoluje sie do tabeli |
| Zmiana klucza glownego | Zalezy od niego cala struktura |

## Indeksy bez downtime

Tworzenie indeksow na duzych tabelach moze blokowac tabele na minuty. Rozwiazanie:

```sql
-- ZLE: blokuje tabele na czas tworzenia indeksu
CREATE INDEX idx_users_email ON users(email);

-- DOBRZE: nie blokuje tabeli (PostgreSQL)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Uwaga: CONCURRENTLY nie dziala w transakcji
-- Flyway: ustaw executeInTransaction=false
```

## Narzedzia do migracji

### Flyway

```yaml
# flyway.conf
flyway.url=jdbc:postgresql://localhost:5432/mydb
flyway.user=admin
flyway.locations=filesystem:./migrations
flyway.baselineOnMigrate=true
```

```bash
# Zastosuj migracje
flyway migrate

# Sprawdz status
flyway info

# Waliduj migracje
flyway validate
```

**Zalety:** Prosty, SQL-native, szeroka adopcja.
**Wady:** Brak automatycznego rollbacka (community edition), tylko SQL.

### Liquibase

```yaml
# changelog.yaml
databaseChangeLog:
  - changeSet:
      id: 001
      author: jan
      changes:
        - createTable:
            tableName: users
            columns:
              - column:
                  name: id
                  type: UUID
                  constraints:
                    primaryKey: true
              - column:
                  name: email
                  type: VARCHAR(255)
                  constraints:
                    unique: true
      rollback:
        - dropTable:
            tableName: users
```

**Zalety:** Wiele formatow (XML, YAML, JSON, SQL), automatyczny rollback, diff miedzy bazami.
**Wady:** Bardziej skomplikowany niz Flyway, XML moze byc uciazliwy.

### Prisma Migrate

```bash
# Tworzenie migracji
npx prisma migrate dev --name init

# Wdrozenie na produkcji
npx prisma migrate deploy

# Reset bazy (development)
npx prisma migrate reset

# Status migracji
npx prisma migrate status
```

**Zalety:** Integracja z Prisma ORM, deklaratywny model, TypeScript type safety.
**Wady:** Tylko dla ekosystemu Prisma, mniejsza kontrola nad SQL.

### Porownanie narzedzi

| Cecha | Flyway | Liquibase | Prisma |
|-------|--------|-----------|--------|
| Jezyk migracji | SQL | XML/YAML/SQL | Deklaratywny model |
| Rollback | Reczny (community) | Automatyczny | Reczny |
| Jezyki programowania | Java, .NET, CLI | Java, CLI | Node.js/TS |
| Diff schematu | Nie | Tak | Tak |
| Popularnosc | Bardzo wysoka | Wysoka | Rosnie (JS/TS) |
| Krzywa uczenia | Niska | Srednia | Niska |

## Dobre praktyki

1. **Jedna migracja = jedna zmiana** — latwiejszy rollback i debugging
2. **Migracje sa niezmienne** — raz zastosowanej migracji nigdy nie edytuj
3. **Testuj migracje** — na kopii bazy produkcyjnej przed wdrozeniem
4. **Monitoruj czas** — dlugie migracje moga powodowac locki
5. **Backupuj przed migracja** — szczegolnie na produkcji
6. **Uzywaj transakcji** — jesli baza to wspiera (PostgreSQL: tak, MySQL: czesciowo)
7. **Unikaj danych w migracjach** — oddzielaj zmiany schematu od danych seed
8. **Review migracji** — traktuj migracje jak kod — code review obowiazkowy

## Kluczowe wnioski

1. **Migracje to wersjonowanie schematu** — traktuj je jak kod
2. **Zero-downtime** wymaga expand-contract pattern — nigdy nie lamiemy kompatybilnosci w jednym kroku
3. **Backward compatible changes** sa zawsze bezpieczne — dodawanie nullable kolumn, indeksow
4. **CONCURRENTLY** dla indeksow na duzych tabelach — unikaj lockow
5. **Wybor narzedzia** zalezy od ekosystemu — Flyway (Java), Liquibase (uniwersalny), Prisma (Node.js)
6. **Testuj migracje na kopii produkcji** — nie na pustej bazie
