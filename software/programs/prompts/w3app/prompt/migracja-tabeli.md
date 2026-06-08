# Prompt: nowa tabela (model + migracja CREATE)

Gotowy prompt do skopiowania do Claude'a / dowolnego asystenta LLM. Generuje **parę plików**:
1. `app/<Komponent>/Models/<Entity>Model.php` — model z deklaracją kolumn i indeksów
2. `app/<Komponent>/Migrations/Version<TS>.php` — cienka migracja używająca modelu

Konwencja: [docs/bazy-danych.md §3.10a (Modele)](../bazy-danych.md#310a-modele-tabel--deklaratywne-źródło-prawdy) i [§3.11 (Nazewnictwo)](../bazy-danych.md#311-konwencja-nazewnictwa-tabel-i-kolumn).

## Jak używać

1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Wypełnij placeholdery w sekcji `## DANE WEJŚCIOWE` (komponent, encja, prefix kolumn, kolumny biznesowe).
3. Wklej do asystenta. Otrzymasz kompletny plik PHP gotowy do umieszczenia w `app/<Komponent>/Migrations/Version<TS>.php`.
4. Zapisz pod nazwą `Version<YYYYMMDDHHMMSS>.php` (timestamp = aktualny moment generowania).
5. Zweryfikuj: `php bin/migrate <komponent> migrations:status` (powinna pokazać się jako nowa), potem `migrations:migrate`.

---

## PROMPT

```
Jesteś generatorem warstwy DB dla silnika K2 CMS. Wygeneruj DWA pliki PHP:
(1) MODEL tabeli, (2) MIGRACJĘ CREATE używającą tego modelu.

## KONTEKST PROJEKTU

- PHP 8.1+, doctrine/migrations 3.x, MySQL 8 (InnoDB, utf8mb4)
- Model rozszerza `Core\Models\TableModel`, używa `Core\Models\Column` i `Core\Models\Index`
- Migracja rozszerza `Core\Migrations\TenantMigration`, woła tylko `$model->createTableSql(...)` / `dropTableSql(...)`
- Prefix tenant wstrzykiwany w runtime z `configs/<host>.php` (`tenant.prefix`)

## ŚCIEŻKI

- Model:   `app/<Komponent>/Models/<Entity>Model.php`
- Migracja: `app/<Komponent>/Migrations/Version<YYYYMMDDHHMMSS>.php`
- Namespace modelu:    `App\<Komponent>\Models`
- Namespace migracji:  `App\<Komponent>\Migrations`
- Nazwa klasy modelu:  `<Entity>Model` (PascalCase, np. `UsersModel`, `BlogPostsModel`)

## OBOWIĄZKOWE KOLUMNY KAŻDEGO MODELU (w tej kolejności, na początku `columns()`)

  Column::guid('ID')->primaryKey()
  Column::dateTime('DateTime')->default('CURRENT_TIMESTAMP')
  Column::autoInc('IDAuto')->uniqueKey('idauto')

Prefix kolumn `<C>` (3–5 znaków, PascalCase) zwracany z `columnPrefix()`. Wszystkie
kolumny w modelu używają nazw BEZ prefiksu (`'Login'`, `'Email'`) — prefix doklejany
automatycznie przez `TableModel` przy renderowaniu.

## ZASADY KOLUMN

- Brak `created_at` / `updated_at` — `<C>DateTime` zastępuje `created_at`.
  Modyfikacje: `Column::dateTime('Modified')->nullable()->onUpdate('CURRENT_TIMESTAMP')`.
- VARCHAR z `uniqueKey()`: max 190 znaków (limit indeksu utf8mb4 = 767 bajtów).
- Wszystkie biznesowe kolumny używają TEGO SAMEGO prefiksu co bazowe (`Use`, `Pag`, ...).
- Modyfikatory:
    ->nullable()              -- NULL
    ->notNull()               -- NOT NULL (domyślne — można pomijać)
    ->default(value)          -- DEFAULT: string-expr ('CURRENT_TIMESTAMP', 'UUID()'),
                                  string-literal ('admin'), int/float, lub null
    ->primaryKey()            -- składowa PRIMARY KEY
    ->uniqueKey('label')      -- UNIQUE KEY uniq_<table>_<label> (jedna kolumna)
    ->indexKey('label')       -- INDEX idx_<table>_<label> (jedna kolumna)
    ->onUpdate('expr')        -- ON UPDATE expr
    ->comment('text')         -- COMMENT

## INDEKSY WIELOKOLUMNOWE

W metodzie `indexes()`:
    Index::unique('label', ['Col1', 'Col2'])
    Index::index('label', ['Col1', 'Col2'])

Kolumny podawaj BEZ prefiksu (jak w `columns()`).

## SZABLON MODELU

```php
<?php

declare(strict_types=1);

namespace App\<KOMPONENT>\Models;

use Core\Models\Column;
use Core\Models\Index;
use Core\Models\TableModel;

final class <ENTITY_PASCAL>Model extends TableModel
{
    public function entity(): string
    {
        return '<ENCJA>';
    }

    public function columnPrefix(): string
    {
        return '<C>';
    }

    public function columns(): array
    {
        return [
            // ── Kolumny bazowe (wymagane wg konwencji) ──
            Column::guid('ID')->primaryKey(),
            Column::dateTime('DateTime')->default('CURRENT_TIMESTAMP'),
            Column::autoInc('IDAuto')->uniqueKey('idauto'),

            // ── Kolumny biznesowe ──
            // <wstaw kolumny z DANE WEJŚCIOWE>
        ];
    }

    public function indexes(): array
    {
        return [
            // <wstaw indeksy wielokolumnowe lub usuń, jeśli brak>
        ];
    }
}
```

## SZABLON MIGRACJI

```php
<?php

declare(strict_types=1);

namespace App\<KOMPONENT>\Migrations;

use App\<KOMPONENT>\Models\<ENTITY_PASCAL>Model;
use Core\Migrations\TenantMigration;
use Doctrine\DBAL\Schema\Schema;

final class Version<TIMESTAMP> extends TenantMigration
{
    public function getDescription(): string
    {
        return '<KOMPONENT>: CREATE TABLE <ENCJA> (model: <ENTITY_PASCAL>Model)';
    }

    public function up(Schema $schema): void
    {
        $this->addSql((new <ENTITY_PASCAL>Model())->createTableSql($this->tenantPrefix()));
    }

    public function down(Schema $schema): void
    {
        $this->addSql((new <ENTITY_PASCAL>Model())->dropTableSql($this->tenantPrefix()));
    }
}
```

## DANE WEJŚCIOWE

Komponent (folder w `app/`, PascalCase, np. `Cms`, `Appdb`, `Shop`):
> <WPISZ_KOMPONENT>

Encja (logiczna nazwa tabeli BEZ prefiksu tenant, snake_case, l.mn., np. `users`, `blog_posts`):
> <WPISZ_ENCJE>

<ENTITY_PASCAL> (PascalCase od encji, np. `users` → `Users`, `blog_posts` → `BlogPosts`):
> <WPISZ_ENTITY_PASCAL>

Prefix kolumnowy <C> (3–5 znaków, PascalCase, np. `Use`, `Pag`, `BlPos`):
> <WPISZ_PREFIX_KOLUMN>

Timestamp pliku migracji (`YYYYMMDDHHMMSS`, aktualna chwila — wymyśl jeśli nie podano):
> <WPISZ_TIMESTAMP>

Kolumny biznesowe — każda jedna z fabryk `Column::...()` z modyfikatorami:
>
> Przykłady:
>   Column::varchar('Login', 64)->uniqueKey('login'),
>   Column::varchar('Email', 190)->nullable()->uniqueKey('email'),
>   Column::tinyInt('IsActive')->default(1),
>   Column::int('SortOrder')->default(0),
>   Column::mediumText('Body')->nullable(),
>   Column::guid('ParentID')->nullable()->indexKey('parent'),

> <WPISZ_KOLUMNY>

Indeksy wielokolumnowe (opcjonalne, format `Index::unique('label', [...])`):
> <WPISZ_INDEKSY_LUB_BRAK>

## ZADANIE

1. Wygeneruj DWA bloki kodu PHP:
   - blok 1: zawartość pliku `<ENTITY_PASCAL>Model.php`
   - blok 2: zawartość pliku `Version<TIMESTAMP>.php`
2. W modelu: bazowe trzy kolumny (`ID`, `DateTime`, `IDAuto`) → kolumny biznesowe w kolejności z DANE WEJŚCIOWE.
3. Migracja zawiera TYLKO opis + wywołania `$model->createTableSql(...)` / `dropTableSql(...)`. Bez raw SQL.
4. Każdą blok poprzedź jedną linijką: "// === app/<Komponent>/Models/<...>.php ===" / "// === app/<Komponent>/Migrations/Version<TS>.php ===".
5. Bez wstępu, bez wyjaśnień, bez bloku markdown. Tylko dwie linie-komentarze + dwa pliki PHP.
```

---

## Przykład wypełnionego promptu

```
Komponent: Cms
Encja: categories
ENTITY_PASCAL: Categories
Prefix kolumnowy <C>: Cat
Timestamp pliku migracji: 20260520140000

Kolumny biznesowe:
  Column::varchar('Slug', 190)->uniqueKey('slug'),
  Column::varchar('Name', 255),
  Column::guid('ParentID')->nullable()->indexKey('parent'),
  Column::int('SortOrder')->default(0),

Indeksy wielokolumnowe: brak
```

**Oczekiwany output**:

```
// === app/Cms/Models/CategoriesModel.php ===
<?php

declare(strict_types=1);

namespace App\Cms\Models;

use Core\Models\Column;
use Core\Models\Index;
use Core\Models\TableModel;

final class CategoriesModel extends TableModel
{
    public function entity(): string      { return 'categories'; }
    public function columnPrefix(): string { return 'Cat'; }

    public function columns(): array
    {
        return [
            Column::guid('ID')->primaryKey(),
            Column::dateTime('DateTime')->default('CURRENT_TIMESTAMP'),
            Column::autoInc('IDAuto')->uniqueKey('idauto'),

            Column::varchar('Slug', 190)->uniqueKey('slug'),
            Column::varchar('Name', 255),
            Column::guid('ParentID')->nullable()->indexKey('parent'),
            Column::int('SortOrder')->default(0),
        ];
    }
}

// === app/Cms/Migrations/Version20260520140000.php ===
<?php

declare(strict_types=1);

namespace App\Cms\Migrations;

use App\Cms\Models\CategoriesModel;
use Core\Migrations\TenantMigration;
use Doctrine\DBAL\Schema\Schema;

final class Version20260520140000 extends TenantMigration
{
    public function getDescription(): string
    {
        return 'Cms: CREATE TABLE categories (model: CategoriesModel)';
    }

    public function up(Schema $schema): void
    {
        $this->addSql((new CategoriesModel())->createTableSql($this->tenantPrefix()));
    }

    public function down(Schema $schema): void
    {
        $this->addSql((new CategoriesModel())->dropTableSql($this->tenantPrefix()));
    }
}
```

---

## Checklist po wygenerowaniu

- [ ] Model zapisany w `app/<Komponent>/Models/<Entity>Model.php`, migracja w `Migrations/Version<TS>.php`
- [ ] Namespace modelu: `App\<Komponent>\Models`, migracji: `App\<Komponent>\Migrations`
- [ ] Pierwsze trzy kolumny w modelu: `guid('ID')->primaryKey()`, `dateTime('DateTime')->default('CURRENT_TIMESTAMP')`, `autoInc('IDAuto')->uniqueKey('idauto')`
- [ ] Wszystkie kolumny BEZ prefiksu w wywołaniach (`'Login'` nie `'UseLogin'`) — prefix doklejany przez `TableModel`
- [ ] Migracja zawiera TYLKO `(new <Model>())->createTableSql(...)` / `dropTableSql(...)` — bez raw SQL
- [ ] `php bin/migrate <komponent> migrations:status` pokazuje nową migrację
- [ ] `php bin/migrate <komponent> migrations:migrate` wykonuje się bez błędu
- [ ] Wpis dodany do [docs/changelog-db.md](../changelog-db.md) (sekcja właściwego komponentu)

---

## Powiązane: edycja istniejącej tabeli

Jeśli zmieniasz model **już wdrożonej** tabeli (dodajesz/komentujesz kolumnę, zmieniasz typ, zmieniasz indeks), poza edycją modelu **musisz** dorzucić nową migrację ALTER. Sam model nie zmienia stanu istniejącej bazy — patrz [docs/bazy-danych.md §3.10a "Cykl życia modelu po wdrożeniu"](../bazy-danych.md#310a-modele-tabel--deklaratywne-źródło-prawdy).
