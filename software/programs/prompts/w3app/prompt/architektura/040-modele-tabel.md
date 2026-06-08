# Prompt 040: Rdzeń modeli tabel — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [030 Połączenie z bazą](030-polaczenie-z-baza.md) · Następny: [050 System migracji](050-system-migracji.md) →

Ten krok buduje **deklaratywny rdzeń modeli** — trzy klasy w `core/Models/`, które są jedynym źródłem prawdy o strukturze tabel: `TableModel` (klasa bazowa renderująca `CREATE TABLE` / `DROP TABLE`, doklejająca prefiks tenanta do nazwy tabeli i prefiks kolumnowy `<C>` do każdej kolumny), `Column` (fabryki typów + płynne modyfikatory) oraz `Index` (indeksy wielokolumnowe). Wymaga z wcześniejszych kroków jedynie autoloadera PSR-4 dla przestrzeni `Core\` (krok 010) — nie zależy od bazy ani configu, bo prefiks tenanta dostaje jako argument w runtime.

Po tym kroku masz aparaturę do **opisywania** tabel. Samo *dodawanie konkretnych* tabel (model + migracja CREATE) opisuje gotowe narzędzie [migracja-tabeli.md](../migracja-tabeli.md), a uruchamianie migracji — krok [050](050-system-migracji.md).

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Wklej do asystenta LLM bez zmian — prompt jest samowystarczalny (zawiera konwencje i komplet specyfikacji trzech plików).
3. Zapisz wygenerowane pliki pod ścieżkami: `core/Models/TableModel.php`, `core/Models/Column.php`, `core/Models/Index.php`.
4. Zweryfikuj wg sekcji **Weryfikacja** (m.in. szybki smoke-test `createTableSql()` w `php -a`).

---

## PROMPT
```
Jesteś generatorem rdzenia warstwy DB silnika K2 CMS (PHP 8.1+, MySQL 8, InnoDB,
utf8mb4). Wygeneruj TRZY pliki PHP tworzące deklaratywny rdzeń modeli tabel.

## KONTEKST PROJEKTU

- K2 CMS to wielodostępny (multi-tenant) CMS. Wielu klientów współdzieli jedną
  fizyczną bazę; izolację daje PREFIKS TENANTA doklejany do nazwy każdej tabeli
  (`def_users`, `kl1_users`). Prefiks pochodzi z konfiguracji (`tenant.prefix`)
  i jest przekazywany do modelu w RUNTIME jako argument — rdzeń modeli nie zna
  ani configu, ani połączenia z bazą.
- Każda tabela ma swój MODEL: `app/<Komponent>/Models/<Entity>Model.php`,
  rozszerzający `Core\Models\TableModel`. Model deklaruje kolumny i indeksy.
- Modele są DEKLARATYWNYM ŹRÓDŁEM PRAWDY o strukturze. Migracje CREATE TABLE
  wołają tylko `$model->createTableSql($prefix)` — nie zawierają SQL-a explicit.
  Migracje ALTER pisze się ręcznie wokół zmian względem obecnego modelu.

## ŚCIEŻKI

- core/Models/TableModel.php   (namespace Core\Models)
- core/Models/Column.php       (namespace Core\Models)
- core/Models/Index.php        (namespace Core\Models)

## KONWENCJE KOLUMN I NAZEWNICTWA

- Prefiks KOLUMNOWY `<C>`: 3–5 znaków, PascalCase, unikalny per tabela (np. `Use`,
  `Pag`, `GalPhoto`). Zwracany z `columnPrefix()`. W deklaracjach kolumn podaje się
  nazwy BEZ prefiksu (`'Login'`, `'Email'`); pełną nazwę (`UseLogin`) skleja
  `TableModel` przy renderowaniu.
- Każda tabela ma trzy kolumny bazowe (zwykle na początku `columns()`):
    <C>ID       CHAR(36) NOT NULL              → PRIMARY KEY (GUID v4 generowany w PHP)
    <C>DateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP → data utworzenia
    <C>IDAuto   INT UNSIGNED AUTO_INCREMENT    → UNIQUE KEY (kolejność wstawiania)
- Nazwa tabeli: `<tenant>_<entity>` (gdy prefiks pusty → samo `<entity>`).
- Nazwy kluczy: `uniq_<tabela>_<label>`, `idx_<tabela>_<label>`.
- Silnik/kodowanie: `ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`.

## SPECYFIKACJA: core/Models/TableModel.php

Abstrakcyjna klasa bazowa modelu.

Metody abstrakcyjne (implementowane przez modele konkretnych tabel):
- `entity(): string` — logiczna nazwa tabeli BEZ prefiksu tenanta (np. `users`).
- `columnPrefix(): string` — prefiks kolumn `<C>`.
- `columns(): array` — lista obiektów `Column` w kolejności wystąpienia w CREATE TABLE.

Metoda z domyślną implementacją:
- `indexes(): array` — dodatkowe indeksy (`Index[]`); domyślnie zwraca `[]`.

Metody publiczne (konkretne):
- `tableName(string $tenantPrefix): string` — zwraca `entity()` gdy prefiks pusty,
  inaczej `"{$tenantPrefix}_{$entity}"`.
- `createTableSql(string $tenantPrefix): string` — buduje pełny `CREATE TABLE`:
    1. wylicz nazwę tabeli i prefiks kolumnowy `$cp`;
    2. dla każdej kolumny: pełna nazwa = `$cp . $col->shortName()`; dorzuć
       `$col->render($fullName)` do linii kolumn; jeśli `isPrimaryKey()` → zbierz do PK;
       jeśli `uniqueLabel()!==null` → dodaj `UNIQUE KEY uniq_<tabela>_<label> (<fullName>)`;
       jeśli `indexLabel()!==null` → dodaj `INDEX idx_<tabela>_<label> (<fullName>)`;
    3. jeśli są kolumny PK → `PRIMARY KEY (col1, col2, …)`;
    4. dla każdego indeksu z `indexes()` → `$idx->render($tableName, $cp)`;
    5. złóż: linie kolumn + linie kluczy, każda wcięta 4 spacjami, rozdzielone `,\n    `;
    6. zwróć `CREATE TABLE <tabela> (\n<body>\n) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci`.
- `dropTableSql(string $tenantPrefix): string` — `'DROP TABLE ' . tableName($prefix)`.

## SPECYFIKACJA: core/Models/Column.php

Finalna klasa — deklaratywna definicja JEDNEJ kolumny. Tworzona przez fabryki
statyczne, modyfikowana płynnym (fluent) API zwracającym `$this`.

Konstruktor PRYWATNY: `__construct(string $shortName, string $sqlType)` (oba readonly).

Pola wewnętrzne ze stanem: `notNull` (bool, domyślnie true), `default`
(string|int|float|null|false — wartość `false` oznacza BRAK klauzuli DEFAULT),
`isPrimaryKey` (bool), `isAutoIncrement` (bool), `uniqueLabel` (?string),
`indexLabel` (?string), `onUpdate` (?string), `comment` (?string).

Fabryki statyczne (każda zwraca `self` z odpowiednim typem SQL):
- `guid($name)`               → CHAR(36)
- `varchar($name, int $len)`  → VARCHAR(len)
- `char($name, int $len)`     → CHAR(len)
- `text($name)`               → TEXT
- `mediumText($name)`         → MEDIUMTEXT
- `longText($name)`           → LONGTEXT
- `int($name, bool $unsigned=false)`      → INT / INT UNSIGNED
- `bigInt($name, bool $unsigned=false)`   → BIGINT / BIGINT UNSIGNED
- `smallInt($name, bool $unsigned=false)` → SMALLINT / SMALLINT UNSIGNED
- `tinyInt($name, int $display=1)`        → TINYINT(display)
- `autoInc($name)`            → INT UNSIGNED + ustawia isAutoIncrement=true
                                 (standard dla `<C>IDAuto`: UNIQUE, nie PK)
- `decimal($name, int $precision, int $scale)` → DECIMAL(precision,scale)
- `dateTime($name)`           → DATETIME
- `date($name)`               → DATE
- `json($name)`               → JSON
- `raw($name, string $sqlType)` → escape-hatch dla nietypowych typów (ENUM/SET/POINT…)

Modyfikatory (fluent, zwracają `$this`):
- `nullable()`            → notNull=false
- `notNull()`             → notNull=true (domyślne, można pomijać)
- `default(string|int|float|null $value)` → ustawia DEFAULT (patrz render niżej)
- `primaryKey()`          → isPrimaryKey=true
- `uniqueKey(string $label)` → ustawia uniqueLabel
- `indexKey(string $label)`  → ustawia indexLabel
- `onUpdate(string $expr)`   → ustawia onUpdate (np. `CURRENT_TIMESTAMP`)
- `comment(string $text)`    → ustawia comment

Gettery używane przez TableModel: `shortName()`, `isPrimaryKey()`,
`uniqueLabel()`, `indexLabel()`.

`render(string $fullColumnName): string` — linia definicji kolumny w CREATE TABLE
(bez końcowego przecinka). Kolejność członów:
  1. `<fullColumnName> <sqlType>`
  2. `NOT NULL` gdy notNull, inaczej `NULL`
  3. gdy `default !== false`: `DEFAULT <renderDefault(default)>`
  4. gdy onUpdate !== null: `ON UPDATE <onUpdate>`
  5. gdy isAutoIncrement: `AUTO_INCREMENT`
  6. gdy comment !== null: `COMMENT '<escaped>'` (apostrofy podwajane: `'` → `''`)
Człony złączone spacją.

`renderDefault(string|int|float|null $value): string` (prywatna):
  - null → `NULL`
  - int|float → wartość jako string (bez cudzysłowów)
  - string pasujący do `/^(CURRENT_TIMESTAMP|UUID\(\)|NULL|TRUE|FALSE|\(.+\))$/i`
    → wyrażenie SQL bez cudzysłowów
  - pozostałe stringi → literał tekstowy w apostrofach z podwojeniem `'` → `''`

## SPECYFIKACJA: core/Models/Index.php

Finalna klasa — indeks wielokolumnowy lub niewyrażalny przez `Column::uniqueKey/indexKey`.
Tworzona w `TableModel::indexes()`.

Konstruktor PRYWATNY: `__construct(string $type, string $label, array $shortColumnNames)`
(readonly), gdzie `$type` ∈ {'index','unique'}, a nazwy kolumn są BEZ prefiksu.

Fabryki statyczne:
- `unique(string $label, array $shortColumnNames): self`  → typ 'unique'
- `index(string $label, array $shortColumnNames): self`   → typ 'index'

`render(string $tableName, string $columnPrefix): string`:
  - skleja kolumny: każdą poprzedź `$columnPrefix`, złącz `, `;
  - słowo kluczowe: 'unique' → `UNIQUE KEY` + prefiks nazwy `uniq`;
    'index' → `INDEX` + prefiks nazwy `idx`;
  - zwróć `<keyword> <namePrefix>_<tableName>_<label> (<kolumny>)`.

## ZASADY OGÓLNE

- `declare(strict_types=1);` w każdym pliku.
- Wszystkie trzy klasy w przestrzeni `Core\Models`.
- `Column` i `Index` final z prywatnym konstruktorem; `TableModel` abstrakcyjna.
- Komentarze PHPDoc po polsku, zwięzłe, opisujące rolę klasy/metody.
- Brak zależności zewnętrznych poza standardowym PHP.

## ZADANIE

1. Wygeneruj `core/Models/Column.php` wg specyfikacji (fabryki + modyfikatory + render).
2. Wygeneruj `core/Models/Index.php` wg specyfikacji.
3. Wygeneruj `core/Models/TableModel.php` wg specyfikacji (renderowanie CREATE/DROP).
4. Zadbaj o spójność: `TableModel::createTableSql()` musi działać z publicznymi
   getterami `Column` i metodą `Index::render()` dokładnie jak opisano.
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] Powstały trzy pliki: `core/Models/TableModel.php`, `Column.php`, `Index.php` w przestrzeni `Core\Models`.
- [ ] `Column` ma fabryki: `guid, varchar, char, text, mediumText, longText, int, bigInt, smallInt, tinyInt, autoInc, decimal, dateTime, date, json, raw` oraz modyfikatory `nullable, notNull, default, primaryKey, uniqueKey, indexKey, onUpdate, comment`.
- [ ] `Column::default(false)` jest stanem początkowym (brak `DEFAULT` w SQL); `default('CURRENT_TIMESTAMP')` renderuje wyrażenie bez cudzysłowów, a `default('admin')` literał w apostrofach.
- [ ] `autoInc()` ustawia `AUTO_INCREMENT`; typowo łączone z `uniqueKey('idauto')`, nie z `primaryKey()`.
- [ ] Smoke-test renderowania zwraca poprawny `CREATE TABLE`:
  ```php
  // przykładowy model anonimowy
  $m = new class extends Core\Models\TableModel {
      public function entity(): string { return 'users'; }
      public function columnPrefix(): string { return 'Use'; }
      public function columns(): array {
          return [
              Core\Models\Column::guid('ID')->primaryKey(),
              Core\Models\Column::dateTime('DateTime')->default('CURRENT_TIMESTAMP'),
              Core\Models\Column::autoInc('IDAuto')->uniqueKey('idauto'),
              Core\Models\Column::varchar('Login', 64)->uniqueKey('login'),
          ];
      }
  };
  echo $m->createTableSql('def'); // CREATE TABLE def_users ( UseID CHAR(36) NOT NULL, … PRIMARY KEY (UseID) ) ENGINE=InnoDB …
  ```
- [ ] `createTableSql('')` (pusty prefiks) → nazwa tabeli bez prefiksu (`users`).
- [ ] `Index::unique('login_email', ['Login','Email'])->render('def_users','Use')` → `UNIQUE KEY uniq_def_users_login_email (UseLogin, UseEmail)`.
- [ ] Apostrofy w `comment()` i w literałowym `default()` są poprawnie podwajane.

## Powiązane
- [migracja-tabeli.md](../migracja-tabeli.md) — gotowe narzędzie do dodawania KONKRETNYCH tabel (model + migracja CREATE) na bazie tego rdzenia.
- [050 System migracji](050-system-migracji.md) — uruchamia migracje, które wołają `createTableSql()` / `dropTableSql()`.
- [docs/bazy-danych.md §3.10a (Modele)](../../bazy-danych.md#310a-modele-tabel--deklaratywne-źródło-prawdy) i [§3.11 (Nazewnictwo)](../../bazy-danych.md#311-konwencja-nazewnictwa-tabel-i-kolumn).
- [docs/architektura/architektura.md §5 (Warstwa aplikacji — modele)](../../architektura/architektura.md).
