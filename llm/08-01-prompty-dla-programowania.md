# Prompty dla programowania i architektury — z przykładami PHP/CMS

## Filozofia: programowanie z LLM ≠ chat

LLM jako para programisty wymaga **innego podejścia** niż ChatGPT-konwersacja. Kluczowe różnice:

```
Chat:                              Programowanie z LLM:
- "Wyjaśnij rekurencję"            - Specyfikacja → projekt → kod → testy → review
- Jeden prompt, jedna odpowiedź    - Łańcuch promptów, iteracja
- Tekstowa odpowiedź               - Pliki, struktury, testy
- Brak kontekstu projektu          - Pełny kontekst (codebase, konwencje)
```

**Zasada #1**: Im bardziej złożone zadanie, tym bardziej **dziel pracę na fazy** zamiast jednego mega-promptu.

## 4-fazowy model promptowania dla developmentu

```
┌────────────────────┐
│ FAZA 1: ANALIZA    │  Zrozumienie problemu, wymagań
│ (Discovery)         │  Output: spec, user stories, edge cases
└──────────┬─────────┘
           ▼
┌────────────────────┐
│ FAZA 2: PROJEKT    │  Architektura, struktura plików, schema DB
│ (Design)           │  Output: diagramy, ADR, interfejsy
└──────────┬─────────┘
           ▼
┌────────────────────┐
│ FAZA 3: KOD        │  Implementacja krok po kroku
│ (Implementation)   │  Output: pliki, testy, dokumentacja
└──────────┬─────────┘
           ▼
┌────────────────────┐
│ FAZA 4: REVIEW     │  Bezpieczeństwo, wydajność, refactor
│ (Quality)          │  Output: poprawki, optymalizacje
└────────────────────┘
```

## FAZA 1: Analiza i wymagania

### Cel
Wydobyć z LLM **pełne zrozumienie problemu** zanim zaczniesz pisać kod.

### Template — Discovery prompt

```
ROLA: Jesteś senior software architectem z 15-letnim doświadczeniem
w budowaniu systemów CMS w PHP.

KONTEKST:
Buduję CMS dla średniej wielkości portalu (~50k użytkowników/dzień).
Wymagania:
- Multi-author publishing
- SEO optimization
- Multi-language (PL/EN)
- Performance < 200ms TTFB
- Komentarze i moderacja

ZADANIE: Przeprowadź analizę wymagań:

1. Zadaj 5-10 pytań które pomogą doprecyzować wymagania
2. Zidentyfikuj nietypowe edge cases które mogą umknąć
3. Wskaż ryzyka techniczne dla tej skali
4. Zaproponuj 3 alternatywne podejścia (np. headless vs tradycyjny CMS)
   z analizą trade-offs

NIE pisz jeszcze kodu. Skupiamy się na zrozumieniu.
```

### Dlaczego to działa
- **Rola** ustawia oczekiwania jakości
- **Kontekst** daje istotne ograniczenia (skala, perf, lang)
- **Strukturalne zadanie** zamiast "napisz CMS"
- **NIE pisz kodu** — wymusza fazowość

### Przykład analizy edge cases
LLM dobrze zaprojektowanym promptem znajdzie:
- Co przy konfliktach edycji (2 autorów edytuje ten sam artykuł)?
- Cache invalidation przy publikacji
- Rollback po błędzie w workflow
- GDPR przy komentarzach (anonymous + IP)
- Filename sanitization (XSS w mediach)

## FAZA 2: Projekt architektury

### Cel
Zaprojektować **strukturę** zanim zaczniesz pisać kod.

### Template — Architecture prompt

```
KONTEKST:
[wklej output z fazy 1 — wymagania, edge cases, decyzje]

STACK:
- PHP 8.3 (strict types, readonly properties)
- MySQL 8.0
- Redis (cache, sessions)
- Nginx + PHP-FPM
- Docker Compose (dev)

ZADANIE: Zaprojektuj architekturę CMS:

1. STRUKTURA KATALOGÓW (pełne drzewo, PSR-4 namespaces)
2. WARSTWY (Domain, Application, Infrastructure, Presentation)
3. KLUCZOWE ENCJE i ich relacje (UML class diagram w mermaid)
4. SCHEMA BAZY (tabele, indeksy, FK)
5. PUBLIC API (endpointy REST, request/response)
6. STRATEGIA CACHE'OWANIA
7. PIPELINE PUBLIKACJI (kto, co, kiedy)

Format: Markdown z sekcjami. Diagramy w Mermaid.
WAŻNE: Uzasadnij każdą decyzję (dlaczego ten wzorzec, nie inny).
```

### Output PHP CMS (przykład)

```
src/
├── Domain/                    # Logika biznesowa, czysty PHP
│   ├── Article/
│   │   ├── Article.php        # Aggregate root
│   │   ├── ArticleId.php      # Value object
│   │   ├── ArticleStatus.php  # Enum
│   │   └── ArticleRepository.php  # Interface
│   ├── User/
│   │   └── ...
│   └── Shared/
├── Application/               # Use cases (CQRS)
│   ├── Command/
│   │   ├── PublishArticle/
│   │   │   ├── PublishArticleCommand.php
│   │   │   └── PublishArticleHandler.php
│   │   └── ...
│   └── Query/
├── Infrastructure/            # Implementacje techniczne
│   ├── Persistence/
│   │   └── Doctrine/
│   ├── Cache/
│   │   └── RedisCache.php
│   └── Http/
└── UI/                        # Controllers, views
    ├── Http/
    │   └── Controller/
    └── Cli/
```

### Dobre praktyki dla architektury

1. **Iteruj** — pierwszy szkic od LLM nie jest finałem. Zadawaj pytania:
   - "Dlaczego tu wybrałeś X zamiast Y?"
   - "Jak ten design zachowa się przy 10× obciążeniu?"
   - "Gdzie tu są single points of failure?"

2. **Architecture Decision Records (ADR)** — zapisuj decyzje w kodzie:
   ```
   docs/adr/
   ├── 0001-php-83-strict-types.md
   ├── 0002-doctrine-vs-eloquent.md
   ├── 0003-redis-cache-strategy.md
   └── 0004-cqrs-light-implementation.md
   ```

3. **Generuj diagramy w Mermaid** — renderują się w GitHub:

```
graph TB
    Client[Browser] -->|HTTP| Nginx
    Nginx -->|FastCGI| PHP[PHP-FPM]
    PHP --> Redis[(Redis Cache)]
    PHP --> MySQL[(MySQL)]
    PHP --> Search[Elasticsearch]
    PHP -->|Async| Queue[RabbitMQ]
    Queue --> Worker[Workers]
    Worker --> MySQL
    Worker --> Mailer[SMTP]
```

## FAZA 3: Implementacja

### Cel
Pisać kod **iteracyjnie**, fragment po fragmencie, z testami.

### Anty-pattern: "Napisz cały CMS w PHP"
LLM wygeneruje 500 linii kiepskiego kodu. **NIE rób tego.**

### Pattern: Iteracyjne małe kroki

```
KROK 1: "Implementuj klasę Article (aggregate root) zgodnie z architekturą.
         Tylko ta klasa, z testami PHPUnit."

KROK 2: "Implementuj ArticleRepository (interface) i jej Doctrine implementation."

KROK 3: "Implementuj PublishArticleCommand + Handler. Tylko logika, bez HTTP."

KROK 4: "Dodaj HTTP controller dla POST /api/articles/{id}/publish."

KROK 5: "Dodaj integration test dla pełnego flow publikacji."
```

### Template — Implementation prompt

```
KONTEKST: [link do architektury z fazy 2]

PLIK: src/Domain/Article/Article.php

ZADANIE: Implementuj klasę Article jako aggregate root.

WYMAGANIA:
- PHP 8.3, strict_types
- Readonly properties tam gdzie możliwe
- Wszystkie metody mutacji rzucają DomainException jeśli invariant naruszony
- Emituj Domain Events (ArticlePublished, ArticleEdited)
- Nie zna szczegółów persystencji (Doctrine itp.)

INTERFEJS (zarys):
class Article {
    public static function create(ArticleId $id, string $title, AuthorId $authorId): self;
    public function publish(\DateTimeImmutable $now): void;
    public function unpublish(): void;
    public function edit(string $title, string $content): void;
    public function getDomainEvents(): array;
}

REGUŁY BIZNESOWE:
- Można publikować tylko Article w stanie DRAFT
- Tytuł: 5-200 znaków
- Edycja resetuje publishedAt do null jeśli zmiana > 50% treści
- Po archiwizacji nie można już edytować

DOSTARCZ:
1. Plik Article.php (z komentarzami WHY, nie WHAT)
2. Plik ArticleStatus.php (enum)
3. Plik ArticleId.php (value object)
4. Pliki domain events
5. Test PHPUnit z 100% coverage scenariuszy biznesowych
```

### Przykład output

```php
<?php
declare(strict_types=1);

namespace App\Domain\Article;

use App\Domain\Article\Event\ArticlePublished;
use App\Domain\Article\Event\ArticleEdited;
use App\Domain\Shared\AggregateRoot;

final class Article extends AggregateRoot
{
    private string $title;
    private string $content;
    private ArticleStatus $status;
    private ?\DateTimeImmutable $publishedAt = null;

    private function __construct(
        public readonly ArticleId $id,
        public readonly AuthorId $authorId,
        public readonly \DateTimeImmutable $createdAt,
    ) {}

    public static function create(
        ArticleId $id,
        string $title,
        AuthorId $authorId,
    ): self {
        self::assertTitleLength($title);

        $article = new self($id, $authorId, new \DateTimeImmutable());
        $article->title = $title;
        $article->content = '';
        $article->status = ArticleStatus::Draft;

        return $article;
    }

    public function publish(\DateTimeImmutable $now): void
    {
        if ($this->status !== ArticleStatus::Draft) {
            throw new \DomainException(
                'Only draft articles can be published'
            );
        }

        $this->status = ArticleStatus::Published;
        $this->publishedAt = $now;

        $this->recordEvent(new ArticlePublished(
            $this->id,
            $this->authorId,
            $now
        ));
    }

    // ... edit(), unpublish(), archive()...

    private static function assertTitleLength(string $title): void
    {
        $len = mb_strlen($title);
        if ($len < 5 || $len > 200) {
            throw new \DomainException(
                "Title must be 5-200 chars, got {$len}"
            );
        }
    }
}
```

### Patterns dla efektywnej implementacji

#### Pattern: "Show me X first"
Zanim LLM napisze kod, niech pokaże **plan**:
```
"Zanim napiszesz kod, pokaż:
1. Lista plików które utworzysz
2. Krótka odpowiedź jak każdy plik wpisuje się w architekturę
3. Czy są dependencies na inne klasy które nie istnieją?

Czekaj na moje OK przed pisaniem kodu."
```

#### Pattern: "Test-first"
```
"Najpierw napisz testy (PHPUnit) dla scenariuszy:
- Tworzenie article z poprawnym tytułem (happy path)
- Title za krótki / za długi → DomainException
- Publish DRAFT → status = PUBLISHED, event emitted
- Publish PUBLISHED → DomainException

Pokaż testy. Po mojej akceptacji napisz implementację."
```

#### Pattern: Constraint-driven prompts
```
"Przy implementacji TRZYMAJ SIĘ zasad:
- NIE używaj static methods (poza named constructors)
- NIE używaj global state
- NIE używaj zmiennych mutable poza klasą
- KAŻDA publiczna metoda ma test
- KAŻDY public param ma type hint
- Komentarze tylko WHY, nigdy WHAT"
```

## FAZA 4: Review i refactor

### Cel
LLM jako **niezależny reviewer** — często widzi rzeczy których autor nie widzi.

### Template — Review prompt

```
ROLA: Senior PHP engineer specjalizujący się w bezpieczeństwie aplikacji webowych.

KONTEKST: Aplikacja CMS na PHP 8.3. Public-facing.

KOD DO REVIEW:
[wklej kod]

ZADANIE: Code review pod kątem:
1. BEZPIECZEŃSTWO
   - SQL injection
   - XSS (output escaping)
   - CSRF
   - File upload vulnerabilities
   - Path traversal
   - Authentication/authorization
   - Sekrety w kodzie

2. WYDAJNOŚĆ
   - N+1 queries
   - Brakujące indeksy DB
   - Cache opportunities
   - Memory leaks (długie procesy)

3. JAKOŚĆ KODU
   - SOLID violations
   - Code smells
   - Duplikacja
   - Nieczytelne nazwy

4. TESTOWALNOŚĆ
   - Hard-to-mock dependencies
   - Hidden side effects

DLA KAŻDEGO ZNALEZIONEGO PROBLEMU:
- Severity: Critical / High / Medium / Low
- Linia / fragment kodu
- Wyjaśnienie problemu
- Konkretna propozycja fix-a (kod)
```

### Specjalistyczne review prompty

#### Security review
```
"Sprawdź ten kod pod kątem OWASP Top 10 2021. Dla każdego znalezionego
problemu pokaż exploit (proof of concept) i fix."
```

#### Performance review
```
"Profiluj logikę: które operacje są najwolniejsze przy 10000 req/min?
Gdzie dodać cache? Które queries powinny mieć indeksy?"
```

#### Database review
```
"Przeanalizuj schema MySQL pod kątem:
- Brakujące indeksy (na podstawie typowych queries)
- Niewłaściwe typy kolumn
- Możliwości partycjonowania
- Czy tabele są w 3NF?"
```

## Kompletny workflow: budowa CMS w PHP od zera

### Krok 1: Discovery (1 prompt)
```
"Pomóż mi zaplanować CMS dla portalu newsowego.
Skala: 50k unique/day, 10 autorów, 100 artykułów/tydzień.

Zadaj 10 pytań przed projektowaniem. Czekaj na odpowiedzi."
```

### Krok 2: ADR (1 prompt)
```
"Na bazie odpowiedzi, wygeneruj 5 ADR (Architecture Decision Records)
dla kluczowych decyzji:
- Framework (custom vs Symfony vs Laravel)
- Database (MySQL vs Postgres)
- Cache (Redis vs Memcached)
- Search (DB vs Elasticsearch vs Meilisearch)
- Frontend (server-rendered vs SPA vs hybrid)

Format: ADR z kontekstem, decyzją i konsekwencjami."
```

### Krok 3: Architektura (1 prompt)
```
"Na podstawie ADR-ów wygeneruj:
1. C4 diagram (Context, Container) w Mermaid
2. Strukturę katalogów (PSR-4)
3. Schema bazy danych (10-15 tabel)
4. Listę bounded contexts (Article, User, Comment, Media...)"
```

### Krok 4: Implementacja per Bounded Context (wiele promptów)
```
"Zacznij od bounded context Article. Implementuj:
1. Aggregate Article + value objects
2. Repository interface
3. Domain events
4. Doctrine implementation repository
5. PHPUnit tests

Po każdym pliku — pokaż go i czekaj na review."
```

### Krok 5: Application layer (CQRS)
```
"Teraz application layer dla Article. Use cases:
- CreateArticleCommand + Handler
- PublishArticleCommand + Handler
- UpdateArticleCommand + Handler
- GetArticleQuery + Handler
- ListPublishedArticlesQuery + Handler

Wszystko z testami integracyjnymi (z prawdziwą bazą via testcontainers)."
```

### Krok 6: HTTP layer
```
"REST API:
POST   /api/articles
GET    /api/articles/{slug}
PATCH  /api/articles/{id}
POST   /api/articles/{id}/publish
DELETE /api/articles/{id}

Każdy endpoint:
- Controller (cienki)
- Request validation (DTO)
- Authorization (Voter pattern)
- Response format JSON:API

Plus testy E2E (Behat lub PHPUnit)."
```

### Krok 7: UI (frontend)
```
"Server-side rendered frontend z Twig:
- Layout
- Lista artykułów
- Detail artykułu z komentarzami
- Admin panel (lista, edit, publish)

Use Hotwire (Turbo + Stimulus) dla interactivity bez SPA."
```

### Krok 8: DevOps
```
"Docker Compose dla dev:
- PHP 8.3 FPM
- Nginx
- MySQL 8
- Redis
- Mailhog (dev SMTP)
- phpMyAdmin

Plus:
- GitHub Actions CI (PHPUnit, PHPStan level 8, Psalm, php-cs-fixer)
- Deployment script (zero downtime)
- Healthchecks"
```

## Najczęstsze błędy promptowania w developmencie

### ❌ Mega-prompt
"Napisz cały CMS w PHP z bazą, panelem, frontendem i deploymentem"
→ LLM wygeneruje 2000 linii kiepskiego kodu

### ❌ Brak kontekstu projektu
"Jak naprawić błąd w funkcji?"
→ LLM nie wie co to za projekt, jakie konwencje, jaki framework

### ❌ Tylko happy path
"Napisz funkcję publikującą artykuł"
→ Brak edge cases, walidacji, testów błędów

### ❌ Brak ograniczeń
"Napisz kod"
→ LLM może użyć dowolnego frameworka, dowolnej wersji PHP

### ❌ Brak iteracji
Jeden prompt → akceptacja kodu bez pytań
→ Niezweryfikowane założenia, kod-zombie

### ✅ Dobry prompt zawiera
1. **Rolę** (Senior PHP architect)
2. **Kontekst** (CMS, skala, stack)
3. **Konkretne zadanie** (jeden plik, jedna funkcja)
4. **Constraints** (PSR, strict_types, no static)
5. **Format output** (kod + testy + komentarze WHY)
6. **Checkpoint** (pokaż plan przed kodem)

## Praktyczne komendy dla Claude Code / Cursor

### `/build-cms-feature`
```
Implementuj feature [NAME] zgodnie z architekturą CMS.

KROK 1: Pokaż plan (pliki, dependencies, testy)
KROK 2: Czekaj na akceptację
KROK 3: Implementuj plik po pliku
KROK 4: Po każdym pliku → pokaż go, run testy, czekaj na akceptację
KROK 5: Update CHANGELOG.md i README z nową funkcją
```

### `/security-audit-php`
```
Przeprowadź security audit zmienionych plików (git diff main).
Sprawdź:
- SQLi (czy są przygotowane statements?)
- XSS (czy output escapowany w Twig/PHP?)
- Mass assignment
- File upload (rozszerzenia, MIME, path)
- Hardcoded secrets
- CSRF tokens

Output: lista problemów + fix-y.
```

### `/refactor-legacy-php`
```
Refaktor legacy PHP na nowoczesny:
1. Dodaj declare(strict_types=1)
2. Type hints wszędzie
3. Readonly properties
4. Enum zamiast const
5. Dependency injection zamiast new
6. PHPUnit dla każdej publicznej metody

Pokaż diff. Nie zmieniaj zachowania (testy muszą passować).
```

## System prompt dla CMS PHP project

```
Jesteś senior PHP engineer pracującym nad CMS dla średniego portalu.

STACK:
- PHP 8.3 (strict types, readonly, enums)
- Symfony 7.x lub Laravel 11.x (zależnie od projektu)
- MySQL 8 / PostgreSQL 16
- Redis dla cache i kolejek
- Doctrine ORM
- PHPUnit + Pest dla testów
- PHPStan level 8

KONWENCJE:
- PSR-4 autoloading, PSR-12 code style
- Domain-Driven Design (Domain/Application/Infrastructure/UI)
- CQRS-light (osobne handlery dla command i query)
- Repository pattern z interface w Domain
- Domain Events dla side effects
- Wszystkie testy: AAA pattern (Arrange-Act-Assert)

ZASADY:
- Nigdy nie używaj globals, $GLOBALS, statics (poza named constructors)
- Każda publiczna metoda ma type hint i dokumentacjã PHPDoc
- Komentarze WHY, nie WHAT
- 100% test coverage dla Domain layer
- Wszystkie SQL przez prepared statements
- Output zawsze escapowany (Twig auto-escape ON)
- Nie commituj sekretów (.env w .gitignore)

PRZY PISANIU KODU:
1. Najpierw pokaż plan (pliki, dependencies)
2. Potem testy (jako kontrakt)
3. Potem implementacja
4. Po każdej fazie czekaj na review

PYTAJ jeśli:
- Wymagania niejasne
- Może być wiele poprawnych rozwiązań
- Brakuje kontekstu (struktury istniejącego kodu)
```

## Przykładowy łańcuch promptów: dodawanie komentarzy do CMS

### Prompt 1: Discovery
```
"Dodajemy system komentarzy do CMS. Główne pytania:
- Logowanie wymagane czy goście też mogą?
- Moderacja: pre-moderation, post-moderation, AI?
- Threading (odpowiedzi)?
- Reakcje (like, dislike)?
- Anty-spam (captcha, rate limit, honeypot)?
- GDPR (anonimizacja po N czasie)?
- Markdown czy plain text?

Zaproponuj strategię."
```

### Prompt 2: Schema + ADR
```
"Wygeneruj:
1. ADR: Comments — moderation strategy
2. Schema MySQL (tabele: comments, comment_reactions, banned_users, spam_log)
3. Indeksy uwzględniające: lista komentarzy artykułu, top liked, najnowsze
4. Constraints (FK, unique)
5. Migration file (Doctrine migrations)"
```

### Prompt 3: Domain
```
"Bounded Context: Comment.
Implementuj:
- Comment (aggregate)
- CommentId, CommentBody (value objects)
- CommentStatus (enum: Pending, Approved, Rejected, Spam)
- Domain events: CommentPosted, CommentApproved, CommentMarkedAsSpam

Reguły:
- Body 5-2000 znaków (rich text disabled)
- Nie można edytować po 5 min od posted
- Approved comment nie może być edytowany przez autora (tylko mod)
- Reply (parent_id) musi być w tym samym artykule

Pokaż testy najpierw, czekaj na akceptację."
```

### Prompt 4: Anti-spam
```
"Application service AntiSpamService:
- Rate limiting per IP (3 / minutę, 30 / godzinę)
- Honeypot field check
- Blacklist słów (configurable)
- Akismet API integration (jeśli klucz w env)
- Heuristic: link count > 2, all caps, repeated chars

Output: SpamCheckResult (clean/suspicious/spam) + reason."
```

### Prompt 5: HTTP + Frontend
```
"REST endpoints:
POST   /api/articles/{id}/comments
GET    /api/articles/{id}/comments?page=1
POST   /api/comments/{id}/approve  (admin)
POST   /api/comments/{id}/reject   (admin)
POST   /api/comments/{id}/react    (auth user)

Plus Twig template z Hotwire (Turbo Stream dla nowych komentarzy
real-time, bez page reload)."
```

## Co warto zapamiętać

1. **Faza > prompt** — dziel pracę, nie dawaj jednego mega-zadania
2. **Show plan first** — niech LLM pokaże co zrobi przed kodem
3. **Test-first** — testy jako kontrakt, potem implementacja
4. **Iteracja** — pierwszy szkic to nie finał
5. **Niezależny review** — LLM jako reviewer często widzi co Ty przeoczyłeś
6. **Constraints** — bez constraints LLM użyje "popularnych" rozwiązań (nie zawsze najlepszych)
7. **Kontekst projektu** — zawsze przekaż konwencje, stack, decyzje
8. **Komendy / templates** — zapisz dobre prompty jako reusable templates

## Stack rekomendowany dla CMS PHP w 2026

```
Framework:    Symfony 7.x (więcej kontroli) lub Laravel 11.x (szybciej startujesz)
PHP:          8.3+ (lub 8.4 gdy stable)
DB:           PostgreSQL 17 (lepsze niż MySQL dla CMS)
Cache:        Redis 7+ / Valkey
Search:       Meilisearch (prostsze niż Elasticsearch dla CMS)
Frontend:     Twig + Hotwire (Turbo + Stimulus) — SSR, lekkie
Admin panel:  EasyAdmin (Symfony) lub Filament (Laravel)
Auth:         Symfony Security / Laravel Sanctum + 2FA
Queue:        Symfony Messenger / Laravel Horizon (Redis backend)
File storage: Flysystem (S3, local, MinIO)
Mail:         Symfony Mailer / Laravel Mail (SMTP, SES, Postmark)
Tests:        PHPUnit + Pest + Symfony Panther (E2E)
Static:       PHPStan level 8, Psalm, Rector
CI/CD:        GitHub Actions
Deploy:       Deployer (PHP-native) lub GitHub Actions + ssh
Container:    Docker Compose (dev), FrankenPHP/Caddy (prod alternatywa Nginx+FPM)
Monitoring:   Symfony Profiler (dev), Sentry (prod), Grafana
```

## Czego unikać

- **Stare CMS (WordPress 5.x bez bloków)** — security ryzyko, vendor lock
- **Custom framework "from scratch"** — chyba że to research, nie produkcja
- **PHP < 8.1** — brakuje readonly, enums, fibers
- **MySQL < 8** — brakuje window functions, JSON improvements
- **CodeIgniter / Yii** — można, ale ekosystem mniejszy w 2026
- **Server-side templating bez auto-escape** — XSS risk
