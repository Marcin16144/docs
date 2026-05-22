# 04-03: Wzorzec Builder

## Czym jest Builder?

Builder to wzorzec kreacyjny, który pozwala na krokowe konstruowanie złożonych obiektów. Zamiast jednego konstruktora z wieloma parametrami, obiekt jest budowany krok po kroku, a każdy krok konfiguruje inny aspekt obiektu.

## Problem — konstruktor z wieloma parametrami

Gdy klasa ma wiele opcjonalnych parametrów, konstruktor staje się nieczytelny. Ten anty-wzorzec nazywany jest "telescoping constructor".

```typescript
// Anty-wzorzec: telescoping constructor
const report = new Report(
    'Raport sprzedazy',     // title
    'pdf',                   // format
    true,                    // includeCharts
    false,                   // includeSummary
    'monthly',               // period
    new Date('2024-01-01'),  // startDate
    new Date('2024-12-31'),  // endDate
    ['sales', 'marketing'],  // departments
    true,                    // landscape
    null,                    // watermark — nie chcemy, ale musimy przekazac
    'A4'                     // pageSize
);
// Co oznacza trzeci `true`? Czwarty `false`? Niemozliwe do odczytania.
```

## Rozwiązanie z Builderem

Builder rozwiązuje ten problem, dając każdemu parametrowi nazwaną metodę.

```typescript
interface ReportConfig {
    title: string;
    format: 'pdf' | 'html' | 'csv';
    includeCharts: boolean;
    includeSummary: boolean;
    period: 'daily' | 'weekly' | 'monthly' | 'yearly';
    startDate: Date;
    endDate: Date;
    departments: string[];
    landscape: boolean;
    watermark?: string;
    pageSize: 'A4' | 'A3' | 'letter';
}

class ReportBuilder {
    private config: Partial<ReportConfig> = {};

    setTitle(title: string): ReportBuilder {
        this.config.title = title;
        return this;
    }

    setFormat(format: ReportConfig['format']): ReportBuilder {
        this.config.format = format;
        return this;
    }

    withCharts(): ReportBuilder {
        this.config.includeCharts = true;
        return this;
    }

    withSummary(): ReportBuilder {
        this.config.includeSummary = true;
        return this;
    }

    forPeriod(period: ReportConfig['period'], start: Date, end: Date): ReportBuilder {
        this.config.period = period;
        this.config.startDate = start;
        this.config.endDate = end;
        return this;
    }

    forDepartments(...departments: string[]): ReportBuilder {
        this.config.departments = departments;
        return this;
    }

    landscape(): ReportBuilder {
        this.config.landscape = true;
        return this;
    }

    withWatermark(text: string): ReportBuilder {
        this.config.watermark = text;
        return this;
    }

    pageSize(size: ReportConfig['pageSize']): ReportBuilder {
        this.config.pageSize = size;
        return this;
    }

    build(): Report {
        // Walidacja wymaganych pól
        if (!this.config.title) throw new Error('Tytuł jest wymagany');
        if (!this.config.format) throw new Error('Format jest wymagany');
        if (!this.config.startDate || !this.config.endDate) {
            throw new Error('Zakres dat jest wymagany');
        }

        return new Report({
            ...this.config,
            includeCharts: this.config.includeCharts ?? false,
            includeSummary: this.config.includeSummary ?? false,
            period: this.config.period ?? 'monthly',
            departments: this.config.departments ?? [],
            landscape: this.config.landscape ?? false,
            pageSize: this.config.pageSize ?? 'A4',
        } as ReportConfig);
    }
}
```

## Fluent API — łańcuchowanie metod

Kluczową cechą Buildera jest fluent API — każda metoda zwraca `this`, co pozwala na łańcuchowe wywoływanie metod. Kod czyta się jak zdanie w języku naturalnym.

```typescript
const report = new ReportBuilder()
    .setTitle('Raport sprzedazy Q4')
    .setFormat('pdf')
    .withCharts()
    .withSummary()
    .forPeriod('quarterly', new Date('2024-10-01'), new Date('2024-12-31'))
    .forDepartments('sales', 'marketing')
    .landscape()
    .pageSize('A3')
    .build();
```

Porównaj czytelność z wersją konstruktorową — tutaj każdy parametr ma jasną nazwę, opcjonalne parametry po prostu się pomija, a kolejność wywołań nie ma znaczenia.

## Wzorzec Director

Director to opcjonalna klasa, która definiuje kolejność kroków budowania. Enkapsuluje typowe konfiguracje, które powtarzają się w kodzie.

```typescript
class ReportDirector {
    constructor(private builder: ReportBuilder) {}

    buildMonthlyDepartmentReport(
        department: string,
        month: Date
    ): Report {
        const startOfMonth = new Date(month.getFullYear(), month.getMonth(), 1);
        const endOfMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0);

        return this.builder
            .setTitle(`Raport miesieczny — ${department}`)
            .setFormat('pdf')
            .withCharts()
            .withSummary()
            .forPeriod('monthly', startOfMonth, endOfMonth)
            .forDepartments(department)
            .pageSize('A4')
            .build();
    }

    buildQuickCsvExport(departments: string[], start: Date, end: Date): Report {
        return this.builder
            .setTitle('Eksport danych')
            .setFormat('csv')
            .forPeriod('daily', start, end)
            .forDepartments(...departments)
            .build();
    }
}

// Użycie
const director = new ReportDirector(new ReportBuilder());
const report = director.buildMonthlyDepartmentReport('sales', new Date());
```

## Builder vs Constructor Overloading

| Cecha | Constructor overloading | Builder |
|-------|------------------------|---------|
| Czytelność | Niska przy wielu parametrach | Wysoka — nazwy metod |
| Opcjonalne parametry | null/undefined placeholdery | Po prostu pominięte |
| Walidacja | W konstruktorze, trudna | W build(), czysta |
| Niemutowalność | Łatwa (readonly) | Łatwa (build() tworzy frozen obiekt) |
| Złożoność kodu | Niska | Średnia (dodatkowa klasa) |
| Warianty obiektów | Wiele konstruktorów | Jeden builder, różne ścieżki |

## Builder dla niemutowalnych obiektów

Builder szczególnie dobrze pasuje do tworzenia niemutowalnych obiektów — wszystkie pola ustawiane są przed wywołaniem `build()`, a wynikowy obiekt jest zamrożony.

```typescript
class HttpRequest {
    readonly method: string;
    readonly url: string;
    readonly headers: Readonly<Record<string, string>>;
    readonly body: string | null;
    readonly timeout: number;

    private constructor(builder: HttpRequestBuilder) {
        this.method = builder.getMethod();
        this.url = builder.getUrl();
        this.headers = Object.freeze({ ...builder.getHeaders() });
        this.body = builder.getBody();
        this.timeout = builder.getTimeout();
    }

    static builder(method: string, url: string): HttpRequestBuilder {
        return new HttpRequestBuilder(method, url);
    }
}

class HttpRequestBuilder {
    private headers: Record<string, string> = {};
    private body: string | null = null;
    private timeout: number = 30000;

    constructor(private method: string, private url: string) {}

    header(key: string, value: string): HttpRequestBuilder {
        this.headers[key] = value;
        return this;
    }

    jsonBody(data: object): HttpRequestBuilder {
        this.body = JSON.stringify(data);
        this.headers['Content-Type'] = 'application/json';
        return this;
    }

    withTimeout(ms: number): HttpRequestBuilder {
        this.timeout = ms;
        return this;
    }

    // Gettery dla klasy HttpRequest
    getMethod() { return this.method; }
    getUrl() { return this.url; }
    getHeaders() { return this.headers; }
    getBody() { return this.body; }
    getTimeout() { return this.timeout; }

    build(): HttpRequest {
        // Wywołuje prywatny konstruktor HttpRequest
        return new (HttpRequest as any)(this);
    }
}

// Użycie
const request = HttpRequest.builder('POST', '/api/orders')
    .header('Authorization', 'Bearer token123')
    .jsonBody({ productId: 'abc', quantity: 2 })
    .withTimeout(5000)
    .build();
```

## Praktyczne zastosowania

Builder jest naturalnym wyborem w wielu bibliotekach i frameworkach:

- **Query builders** — Knex.js, TypeORM QueryBuilder, Prisma
- **Konfiguracja testów** — budowanie fixtures, test data builders
- **HTTP klienty** — budowanie requestów z nagłówkami, body, timeoutem
- **Walidacja** — łańcuchowe definiowanie reguł (Zod, Joi, Yup)

```typescript
// Przykład: Test Data Builder
class UserBuilder {
    private data = {
        name: 'Jan Kowalski',
        email: 'jan@example.com',
        role: 'user' as const,
        active: true,
    };

    withName(name: string) { this.data.name = name; return this; }
    withEmail(email: string) { this.data.email = email; return this; }
    asAdmin() { this.data.role = 'admin'; return this; }
    inactive() { this.data.active = false; return this; }

    build(): User {
        return new User({ ...this.data });
    }
}

// W testach — czytelne i zwięzłe
const admin = new UserBuilder().asAdmin().withName('Anna Nowak').build();
const inactiveUser = new UserBuilder().inactive().build();
```

## Kiedy stosować Builder?

- Obiekt ma więcej niż 4-5 parametrów konstruktora
- Wiele parametrów jest opcjonalnych
- Obiekt może być tworzony w różnych konfiguracjach
- Potrzebujesz walidacji kompletności przed utworzeniem obiektu
- Chcesz wymusić niemutowalność wynikowego obiektu

## Kiedy NIE stosować?

- Obiekt ma 2-3 proste parametry — Builder to przerost formy
- Obiekt jest mutowalny i modyfikowany po utworzeniu
- Proste DTO/POJO bez walidacji
