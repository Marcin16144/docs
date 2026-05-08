# Prompty dla CMS plugin-based — core + rozszerzenia

## Wprowadzenie: dlaczego plugin architecture?

**Tradycyjny CMS:**
- Wszystkie funkcje "wbudowane"
- Customizacja = forking core
- Każda zmiana ryzyko regresji w innych miejscach

**Plugin-based CMS:**
- Mały, stabilny **core** (publish, users, routing, plugins API)
- Funkcje jako **plugins/extensions** (komentarze, SEO, formularze, sklep)
- Marketplace plugins
- Niezależny lifecycle plugin vs core
- Update core bez psucia pluginów (backward compatibility)

### Przykłady systemów plugin-based

| System | Język | Plugin model | Ekosystem |
|--------|-------|-------------|-----------|
| **WordPress** | PHP | Hooks (actions/filters) | 60k+ plugins |
| **Drupal** | PHP | Modules + Hooks | 40k+ modules |
| **TYPO3** | PHP | Extensions | 5k+ extensions |
| **Joomla** | PHP | Components/Modules/Plugins | 8k+ extensions |
| **Statamic** | PHP/Laravel | Addons (Composer) | 200+ addons |
| **OctoberCMS** | PHP/Laravel | Plugins | 1k+ plugins |
| **Strapi** | Node.js | Plugins | 500+ |
| **Ghost** | Node.js | Apps + integrations | Limited |

## Kluczowe koncepcje

```
┌──────────────────────────────────────────┐
│              CORE CMS                     │
│  ┌─────────────────────────────────────┐ │
│  │  Plugin Manager (dyskvr, load)       │ │
│  ├─────────────────────────────────────┤ │
│  │  Event Bus (hooks, filters)          │ │
│  ├─────────────────────────────────────┤ │
│  │  Service Container (DI)              │ │
│  ├─────────────────────────────────────┤ │
│  │  Public API (interfaces)             │ │
│  ├─────────────────────────────────────┤ │
│  │  Admin Panel + UI extensions         │ │
│  └─────────────────────────────────────┘ │
└─────────────────┬────────────────────────┘
                  │ Plugin API
   ┌──────────────┼──────────────────────┐
   ▼              ▼                      ▼
┌────────┐   ┌──────────┐          ┌──────────┐
│ Plugin │   │ Plugin   │          │ Plugin   │
│  SEO   │   │ Comments │          │  Shop    │
└────────┘   └──────────┘          └──────────┘
```

### Koncepty:

1. **Hooks (actions/filters)** — punkty rozszerzeń w core gdzie pluginy mogą się "podpiąć"
2. **Service Container** — DI zarejestrowane przez pluginy
3. **Event Bus** — publish/subscribe dla pluginów (luźny coupling)
4. **Plugin Manifest** — metadata (version, dependencies, hooks)
5. **Public API** — stabilne interfejsy które core zachowuje
6. **Lifecycle hooks** — install, activate, deactivate, uninstall
7. **Plugin Storage** — własne tabele DB / pliki konfiguracyjne per plugin

## Łańcuch promptów: budowa CMS plugin-based

### KROK 1: Wybór modelu plugin (1 prompt)

```
ROLA: Senior software architect z doświadczeniem w plugin-based systems.

KONTEKST: Buduję CMS w PHP (Symfony 7) dla klientów którzy chcą
elastycznego systemu rozszerzalnego o niestandardowe funkcje.

ZADANIE: Zaproponuj model plugin architecture:

1. Porównaj 3 podejścia:
   a) Hook-based (jak WordPress) — actions/filters
   b) Bundle-based (Symfony Bundles) — autonomous modules
   c) Service Container + Events (Laravel Service Providers + Events)

2. Dla każdego: plusy, minusy, target audience

3. Rekomendacja dla mojego CMS uwzględniając:
   - Łatwość pisania pluginów (DX dla 3rd party developers)
   - Bezpieczeństwo (sandboxing, permissions)
   - Wydajność (lazy loading, caching)
   - Stabilność API (BC compatibility)

4. Pokaż jak struktura folderów wyglądałaby dla Twojej rekomendacji.

Bez kodu jeszcze. Skupiamy się na architekturze.
```

### KROK 2: Definicja Plugin API (1 prompt)

```
KONTEKST: Wybraliśmy hybrid: Symfony Bundles + Event Bus + Hook system
(luźny coupling, dobre DX dla developerów).

ZADANIE: Zaprojektuj Plugin API (kontrakt core ↔ plugin).

Powinien zawierać:

1. INTERFEJS PluginInterface
   - Lifecycle: install(), uninstall(), activate(), deactivate()
   - Metadata: getName(), getVersion(), getDependencies()
   - Permissions: getRequiredPermissions()

2. PLUGIN MANIFEST (plugin.yaml lub composer.json extension)
   - name, version, author, license
   - core_version_constraint (^2.0)
   - dependencies (other plugins)
   - permissions (db.write, http.outbound, file.write...)
   - hooks (które rejestruje)

3. HOOK SYSTEM (zdefiniuj API)
   - Action hooks: void, side effects (np. po publikacji artykułu)
   - Filter hooks: zwracają zmodyfikowaną wartość (np. modyfikacja contentu)
   - Priority (0-100, lower = first)

4. SERVICE CONTAINER EXTENSION
   - Plugin może rejestrować services (DI tags)
   - Auto-discovery class implementations

5. EXTENSION POINTS
   - Admin menu items
   - Routes (frontend + admin)
   - Twig templates / template overrides
   - CLI commands
   - Console scheduled jobs
   - REST/GraphQL API endpoints
   - Database migrations (per plugin schema)

6. EVENTS (oficjalne wydarzenia core)
   - Article: BeforePublish, AfterPublish, BeforeDelete
   - User: AfterRegister, AfterLogin
   - System: PluginActivated, PluginDeactivated

Output: Markdown z PHP interfejsami i przykładowym manifest.
```

### KROK 3: Plugin Manager (core component)

```
KONTEKST: Mamy Plugin API z kroku 2.

PLIK: src/Core/Plugin/PluginManager.php

ZADANIE: Implementuj PluginManager — serce systemu pluginów.

ODPOWIEDZIALNOŚCI:
1. Discovery — skanowanie folderu plugins/ dla plugin.yaml
2. Validation — sprawdzanie manifestu (semver, dependencies, signature)
3. Loading — kolejność wg dependency graph (topological sort)
4. Lifecycle — install/activate/deactivate/uninstall
5. Permission check — czy plugin ma uprawnienia do operacji
6. Health check — czy plugin nie crashuje, czy core_version_constraint match
7. Dependency resolution — graph + cycle detection
8. State management — który plugin jest active w DB

WYMAGANIA:
- Lazy loading — plugin tylko gdy potrzebny (lazy events)
- Cached registry (Redis/file) — szybki bootstrap
- Logging — wszystkie lifecycle events
- Atomic operations — install/uninstall jako transakcja
- Rollback — gdy install fails, undo zmian

INTERFEJS:
class PluginManager {
    public function discover(): array;
    public function install(string $pluginId): InstallResult;
    public function activate(string $pluginId): void;
    public function deactivate(string $pluginId): void;
    public function uninstall(string $pluginId): void;
    public function getActive(): array;
    public function isCompatible(Plugin $plugin): bool;
    public function getDependencyGraph(): Graph;
}

DOSTARCZ:
1. PluginManager.php
2. Plugin.php (value object reprezentujący plugin)
3. PluginManifest.php (parsowanie + walidacja YAML)
4. PluginException + concrete exceptions
5. PluginInstallResult (success/failure z reason)
6. PHPUnit testy (z prawdziwymi plugin fixtures)

Pokaż plan plików najpierw, czekaj na akceptację.
```

### KROK 4: Hook System (jak w WordPress)

```
PLIK: src/Core/Hook/HookManager.php

ZADANIE: Implementuj hook system inspirowany WordPress (actions + filters).

WYMAGANIA:

1. ACTION HOOKS (void, side effects)
   $hooks->doAction('article.published', $article);

   Plugin rejestruje:
   $hooks->addAction('article.published', [$emailNotifier, 'send'], priority: 10);

2. FILTER HOOKS (zwracają zmodyfikowaną wartość)
   $title = $hooks->applyFilter('article.title', $rawTitle);

   Plugin rejestruje:
   $hooks->addFilter('article.title', [$seoPlugin, 'addPrefix'], priority: 20);

3. PRIORITY (0-100, lower = wcześniej)

4. NAMESPACING (hook names: 'system.article.published', 'plugin.seo.metaTags')

5. WILDCARD support: 'article.*' łapie wszystkie article events

6. PERFORMANCE
   - Skompilowany registry (po bootstrap)
   - Brak refleksji w runtime
   - Lazy listeners (DI lookup tylko przy wywołaniu)

7. DEBUGGING
   - getRegisteredHooks(): lista wszystkich
   - getListeners('hook.name'): kto słucha
   - Profiler: ile hook calls, czas każdego

8. INTEGRACJA Z SYMFONY EVENTS
   - HookManager wraps EventDispatcher (under the hood)
   - Albo: dual API (hooks dla pluginów, events dla core)

Implementuj + testy. Pokaż edge cases (priorytety równe, wildcard, brak listenerów).
```

### KROK 5: Tworzenie pierwszego pluginu (SEO)

```
KONTEKST: Mamy core CMS z Plugin API i Hook System. Czas zbudować
pierwszy plugin który pokaże jak system działa.

PLUGIN: SEO Plugin
- Meta tags (description, og:image, twitter:card)
- Sitemap.xml (auto-generated)
- robots.txt control
- Canonical URLs
- Schema.org JSON-LD
- Redirect manager (301/302 rules)

STRUKTURA PLUGINU:
plugins/seo-plugin/
├── plugin.yaml              # Manifest
├── composer.json            # Composer dla autoloadingu
├── src/
│   ├── SeoPlugin.php        # Main class implements PluginInterface
│   ├── EventListener/
│   ├── Service/
│   ├── Controller/
│   ├── Twig/Extension/
│   └── Repository/
├── config/
│   ├── routes.yaml          # Plugin routes (admin)
│   └── services.yaml        # DI configuration
├── migrations/
│   └── Version20260507_001_create_seo_redirects.php
├── templates/
│   └── admin/
│       └── seo/
│           └── settings.html.twig
├── translations/
│   ├── messages.en.yaml
│   └── messages.pl.yaml
└── tests/

ZADANIE:

1. plugin.yaml manifest:
   name: seo-plugin
   version: 1.0.0
   author: ...
   description: ...
   core_version_constraint: ^2.0
   dependencies: [] (lub: cms-core: ^2.0)
   permissions:
     - db.write (own schema)
     - admin.menu (add menu item)
   hooks:
     listens:
       - article.published
       - article.title (filter)
       - admin.dashboard.widgets
     emits:
       - seo.sitemap.regenerated

2. SeoPlugin.php — main class implementująca PluginInterface
   - install(): create tables (seo_redirects, seo_meta)
   - activate(): register routes, hooks, services
   - deactivate(): cleanup
   - uninstall(): drop tables

3. Listener: ArticlePublishedListener
   - Po publikacji → invalidate sitemap cache
   - Auto-generate meta description jeśli brak

4. Filter: ArticleTitleFilter
   - Dodaje site name suffix: "Article Title | My Site"
   - Konfigurowalne w settings

5. Twig Extension
   - {{ seo_meta(article) }} → renderuje meta tags
   - {{ seo_jsonld(article) }} → schema.org

6. Admin route + controller
   - /admin/seo — lista redirectów
   - /admin/seo/settings — ustawienia globalne

7. CLI Command:
   php bin/console seo:sitemap:regenerate

Pokaż plik po pliku. Po każdym czekaj na review.
```

### KROK 6: Plugin marketplace / installer

```
KONTEKST: Core + Plugin API + przykładowy plugin gotowe.
Dodajemy mechanizm dystrybucji pluginów.

ZADANIE: Zaprojektuj system dystrybucji pluginów:

1. PLUGIN PACKAGE FORMAT
   - .zip z określoną strukturą
   - Lub: Composer package (preferowane!)
     composer require my-vendor/cms-seo-plugin

2. SOURCES
   - Composer (Packagist) — main
   - Private Composer repo (Satis/Private Packagist)
   - GitHub release (.zip)
   - Internal marketplace (own server)

3. INSTALLER FLOW (admin UI)
   - Browse marketplace (lista, search, filter, ratings)
   - Click install → download → validate signature → run install()
   - Show progress (download, install, migrate, activate)
   - Rollback if any step fails
   - Restart cache, regenerate registry

4. SECURITY
   - Code signing (composer + GPG)
   - Permission prompt (jak Android: "Plugin wants: db.write, http.outbound")
   - Sandbox mode (opcjonalnie: container per plugin)
   - Static analysis on install (PHPStan, security scan)
   - Vendor reputation system

5. UPDATE MANAGEMENT
   - Check updates daily (cron)
   - Notify admin in dashboard
   - One-click update with auto-backup
   - Semver-aware (major = manual confirm, minor/patch = auto)

6. COMPATIBILITY
   - Test plugin against core version before activating
   - "Compatibility check" tool
   - Block activation if incompatible

7. MONITORING
   - Plugin error rates (Sentry per plugin)
   - Performance impact (slow hooks)
   - Admin alerts on plugin failure

Dostarcz:
1. Architektura (diagram + opis)
2. Database schema (plugins_installed, plugins_versions, plugins_permissions)
3. Admin UI mockup (tekstowy)
4. Plugin discovery service
5. Installer command (CLI + API)
```

### KROK 7: Theme system (specjalne pluginy)

```
KONTEKST: Tematy graficzne to specjalna kategoria pluginów.
W przeciwieństwie do funkcjonalnych pluginów, mogą:
- Zastępować templates Twig core
- Dodawać assets (CSS, JS)
- Customizować admin (białoetykietowe rozwiązania)
- Tylko jeden aktywny w danym czasie (vs wiele pluginów)

ZADANIE: Zaprojektuj system tematów.

1. THEME PACKAGE
   themes/my-theme/
   ├── theme.yaml
   ├── templates/         (override core templates)
   │   ├── article/show.html.twig
   │   └── homepage.html.twig
   ├── public/
   │   ├── css/
   │   ├── js/
   │   └── images/
   ├── config/
   │   └── theme.yaml     (customizable settings)
   └── ThemeServiceProvider.php

2. TEMPLATE RESOLUTION ORDER
   1. Active theme templates
   2. Plugin templates (if plugin defines fallback)
   3. Core templates

3. ASSET COMPILATION
   - Webpack Encore / Vite per theme
   - Compiled assets w public/themes/{name}/
   - Cache busting przez hash

4. CUSTOMIZER
   - Frontend customizer (kolory, fonty, układ)
   - Live preview przed publikacją
   - Stored as theme settings (JSON in DB)

5. CHILD THEMES
   - Inherit od parent theme
   - Override tylko określone części
   - Update parent bez utraty customizacji

6. THEME SWITCHING
   - Bezpieczna zmiana (preview mode dla admin)
   - Frontend nadal widzi starą podczas testowania nowej

Wygeneruj:
1. ThemeManager.php (analogia do PluginManager)
2. ThemeInterface.php
3. Twig template loader z priority chain
4. AssetManager dla theme assets
5. Migration do default theme (po install core)
```

### KROK 8: Plugin testing framework

```
KONTEKST: Pluginy będą pisane przez 3rd party developerów.
Potrzebujemy testing utilities aby ułatwić im pisanie testów.

ZADANIE: Zaprojektuj testing framework dla pluginów.

KOMPONENTY:

1. PLUGIN TEST CASE
   abstract class PluginTestCase extends WebTestCase {
       protected function setUpPluginEnvironment(): void;
       protected function activatePlugin(string $name): void;
       protected function assertHookWasCalled(string $hook): void;
       protected function getPluginContainer(): ContainerInterface;
   }

2. FIXTURES
   - Sample articles, users, settings
   - Plugin-specific fixtures (np. SEO settings)

3. MOCK CORE SERVICES
   - In-memory event bus
   - In-memory plugin registry
   - Test database (sqlite in-memory)
   - HTTP client mock

4. PLUGIN COMPATIBILITY MATRIX
   - Test plugin against multiple core versions
   - GitHub Actions matrix:
     - core: [2.0, 2.1, 2.2]
     - php: [8.3, 8.4]

5. MUTATION TESTING (opcjonalnie)
   - Infection PHP integration
   - Pewność że testy faktycznie testują

6. DOCS
   - "Writing your first plugin" tutorial
   - "Testing plugins" guide
   - "Publishing plugin" checklist

Wygeneruj:
1. PluginTestCase abstract class
2. Helpers: HookSpy, EventCollector, FakeContainer
3. Sample plugin z pełnymi testami (SEO Plugin testy)
4. CI configuration (GitHub Actions)
5. CONTRIBUTING.md template dla plugin developers
```

## Wzorzec: Plugin oparty o Symfony Bundle

### Plugin manifest (plugin.yaml)
```yaml
name: my-vendor/seo-plugin
display_name: SEO Tools
version: 1.2.0
author:
  name: My Vendor
  email: hello@myvendor.com
  url: https://myvendor.com

license: MIT
description: SEO meta tags, sitemap, redirects
homepage: https://github.com/myvendor/seo-plugin

core:
  min_version: 2.0
  max_version: 2.999

php_version: ^8.3

dependencies:
  required:
    - my-vendor/cms-core: ^2.0
  optional:
    - my-vendor/analytics-plugin: ^1.0  # for tracking

permissions:
  - db.write       # creates own tables
  - admin.menu     # adds menu item
  - cache.write    # caches sitemap
  - http.outbound  # checks robots.txt

hooks:
  listens:
    - article.published     # priority 10
    - article.unpublished
    - article.title         # filter
    - admin.dashboard.widgets

  emits:
    - seo.sitemap.regenerated
    - seo.redirect.added

services:
  auto_register: true       # all classes in src/ auto-loaded

routes:
  admin: routes/admin.yaml

migrations:
  path: migrations/

translations:
  default: en
  available: [en, pl, de]

assets:
  admin:
    - assets/admin/seo.js
    - assets/admin/seo.css

settings:
  schema: config/settings_schema.yaml
  default: config/settings_default.yaml
```

### Plugin main class

```php
<?php
declare(strict_types=1);

namespace MyVendor\SeoPlugin;

use App\Core\Plugin\AbstractPlugin;
use App\Core\Plugin\InstallContext;
use App\Core\Plugin\ActivateContext;

final class SeoPlugin extends AbstractPlugin
{
    public function getName(): string
    {
        return 'seo-plugin';
    }

    public function getVersion(): string
    {
        return '1.2.0';
    }

    public function install(InstallContext $ctx): void
    {
        // Run migrations (own schema)
        $ctx->migrate(__DIR__ . '/../migrations');

        // Initial settings
        $ctx->settings()->setDefaults([
            'sitemap_enabled' => true,
            'meta_title_suffix' => ' | {site_name}',
            'auto_generate_description' => true,
        ]);

        // Subscribe initial cron jobs
        $ctx->scheduleJob('seo:sitemap:regenerate', '@daily');
    }

    public function activate(ActivateContext $ctx): void
    {
        // Register hooks
        $ctx->hooks()->addAction(
            'article.published',
            [SitemapInvalidator::class, 'invalidate'],
            priority: 10
        );

        $ctx->hooks()->addFilter(
            'article.title',
            [TitleEnhancer::class, 'addSuffix'],
            priority: 20
        );

        // Register admin menu
        $ctx->menu()->addAdminMenuItem([
            'label' => 'SEO',
            'icon' => 'search',
            'route' => 'seo_admin_dashboard',
            'permission' => 'manage_seo',
        ]);

        // Register Twig functions
        $ctx->twig()->addFunction('seo_meta', [SeoTwigExtension::class, 'metaTags']);
    }

    public function deactivate(): void
    {
        // Hooks auto-deregistered by core
        // Settings remain in DB (in case of reactivation)
    }

    public function uninstall(): void
    {
        // Drop plugin tables (with confirmation in UI)
        // Remove all settings
        // Remove cron jobs
    }

    public function getDependencies(): array
    {
        return ['cms-core' => '^2.0'];
    }

    public function getRequiredPermissions(): array
    {
        return ['db.write', 'admin.menu', 'cache.write'];
    }
}
```

## Szczegółowe prompty na konkretne sytuacje

### Plugin: Komentarze (z przykładem reaktywności)

```
ZADANIE: Implementuj plugin "comments" z funkcjami:
- Public comments form pod artykułami (Twig component)
- Real-time updates via Mercure (Server-Sent Events)
- Threading (replies)
- Moderation queue (admin)
- AI-based spam filter (opcjonalnie, plugin sam decyduje)
- Email notifications (opcjonalny dependency: notification-plugin)

ARCHITEKTURA:
- Plugin domain: Comment, Thread (oddzielony od core)
- Plugin tabele: plugin_comments_*  (prefix uniknie kolizji)
- Public API plugin: CommentService dla innych pluginów
  (np. spam-plugin może hookować się na comment.posted)

EVENTS plugin emits:
- plugin.comments.posted
- plugin.comments.approved
- plugin.comments.rejected
- plugin.comments.spam_detected

EVENTS plugin listens:
- article.deleted (cascade delete comments)
- user.deleted (anonymize lub delete based on settings)

INTEGRATION POINTS:
- Twig: {% comments_for(article) %}
- Article admin: tab "Comments" w edit screen (count, recent)
- Dashboard widget: "Pending comments"
- CLI: php bin/console comments:moderate {id}

Wygeneruj:
1. Plugin structure (manifest, main class)
2. Comment domain (aggregate, value objects)
3. Hooks integration
4. Twig component
5. Mercure publisher dla real-time
6. Admin moderation UI
7. Tests
```

### Plugin: E-commerce (heavy plugin)

```
ZADANIE: Plugin e-commerce dodający shop do CMS.
Pokaż jak zaprojektować ŻE PLUGIN MOŻE BYĆ DUŻY (kilka modułów wewnętrznych).

WYMAGANIA:
- Produkty (z wariantami, atrybutami, mediami)
- Kategorie
- Koszyk (session-based + persistent dla logged users)
- Zamówienia
- Płatności (Stripe, PayU, Przelewy24 — sub-pluginy?)
- Wysyłka (rules + integracje z firmami kurierskimi)
- Faktury (PDF generation)
- Inventory management
- Kupony i promocje

PYTANIA do siebie zadać:
1. Czy to wszystko w jednym pluginie ("ecommerce-plugin")?
2. Czy core plugin + sub-pluginy? (ecommerce-core, ecommerce-stripe, ecommerce-pdf)
3. Jak handle deep dependencies?

ZAPROPONUJ:
- Model "Plugin Suite" — meta-plugin który składa się z innych
- Lub: monolithic plugin z wewnętrznymi modułami
- Trade-offs każdego podejścia
- Konkretną strukturę katalogów

Pokaż jak inne CMS-y to robią (WooCommerce vs Shopify apps vs Sylius bundles).
Rekomendacja na bazie analizy.
```

### Plugin: API rozszerzenia (REST/GraphQL)

```
ZADANIE: System pluginów rozszerza public API CMS.

CORE EXPOSES:
GET /api/articles
GET /api/articles/{slug}
GET /api/categories

PLUGIN MOŻE DODAĆ:
- Nowe endpointy (/api/products, /api/cart)
- Nowe pola w istniejących (article.seo_meta, article.comments_count)
- Filters/sorting (article.where('comments', '>', 5))
- Nowe operacje (article.publish via API)

ZAPROPONUJ:
1. Mechanizm extending response shapes (jak GraphQL Federation lub OpenAPI extensions)
2. Dla REST: API Platform extensions vs custom resolvers
3. Dla GraphQL: schema stitching, type extensions
4. Versioning extensions (API v2 może mieć inne extensions niż v1)
5. Permission integration (plugin permissions → API scopes)

PRZYKŁAD: SEO plugin dodaje:
- field article.seoMeta (JSON object)
- endpoint GET /api/sitemap
- query GraphQL: query { article(slug:"x") { ... seoMeta { metaTitle metaDescription } } }

Wygeneruj kod dla obu API: REST (API Platform) i GraphQL (Lighthouse-PHP lub graphql-php).
```

## Wzorce architektoniczne dla plugin systems

### Wzorzec 1: Service Locator + Tags

```php
// Plugin rejestruje:
$services->set(SeoMetaProvider::class)
    ->tag('seo.meta_provider', ['priority' => 10]);

// Core używa:
foreach ($container->findTaggedServices('seo.meta_provider') as $provider) {
    $provider->provide($article);
}
```

**Plus:** Symfony-native, dobre dla DI
**Minus:** Wymaga znajomości DI tags

### Wzorzec 2: Event-driven (loose coupling)

```php
// Core emit:
$dispatcher->dispatch(new ArticlePublished($article));

// Plugin listen (Symfony attributes):
#[AsEventListener(event: ArticlePublished::class)]
class SitemapInvalidator {
    public function __invoke(ArticlePublished $event): void {
        $this->cache->delete('sitemap');
    }
}
```

**Plus:** Najluźniejszy coupling, najłatwiej testować
**Minus:** Trudniej śledzić flow w kodzie

### Wzorzec 3: Plugin Interface (jak Drupal hooks)

```php
// Każdy plugin implementuje:
interface ArticleHookInterface {
    public function onArticlePublished(Article $article): void;
}

// Core wywołuje:
foreach ($pluginManager->getImplementing(ArticleHookInterface::class) as $plugin) {
    $plugin->onArticlePublished($article);
}
```

**Plus:** Jawny kontrakt, type-safe
**Minus:** Wymagaduje plugin api per typ hooka (interfejs explosion)

### Wzorzec 4: Hybrid (rekomendowany)

```
- Service Tags dla: providers, processors, decorators (silnie typed)
- Events dla: side effects (notifications, cache invalidation)
- Hooks (filters) dla: modyfikacji wartości (jak WP filter_pre)
- Plugin Interface dla: lifecycle (install/uninstall)
```

## Bezpieczeństwo plugin systems

### Threat model

1. **Malicious plugin** — instalujesz, kradnie dane
2. **Vulnerable plugin** — exploit przez plugin (SQLi, XSS)
3. **Plugin conflict** — psuje inne pluginy lub core
4. **Performance attack** — plugin hookuje hot path i spowalnia
5. **Privilege escalation** — plugin uzyskuje więcej uprawnień niż prosi
6. **Supply chain attack** — wstrzyknięcie złego kodu w update

### Mitigations (dla CMS author)

```
1. Code signing
   - Composer + GPG keys
   - Verify signature przed install

2. Permission system
   - Manifest deklaruje permissions
   - Runtime check (np. plugin bez 'http.outbound' nie może curl)
   - User confirmation przy install

3. Sandboxing (advanced)
   - PHP fpm pool per plugin (resource limits)
   - Filesystem chroot (per-plugin storage)
   - Network policy (firewall rules)

4. Static analysis on install
   - PHPStan (level 8)
   - Psalm taint analysis (SQLi, XSS)
   - Security advisories check

5. Runtime isolation
   - Plugin DB schema separate (plugin_seo_*)
   - Plugin filesystem dir (storage/plugins/seo/)
   - Plugin sessions namespaced

6. Audit log
   - Wszystkie plugin actions w audit log
   - Plugin modifying core data → flag for review

7. Update strategy
   - Auto-update tylko patch versions
   - Major versions wymagają manual approval + diff review
   - Backup przed update (rollback)
```

### Security review prompt

```
ZADANIE: Code review pluginu pod kątem bezpieczeństwa.

KOD: [wklej plugin]

SPRAWDŹ:
1. Czy plugin używa tylko zadeklarowanych permissions z manifestu?
2. SQL queries — wszystkie prepared?
3. User input — sanitized przed użyciem?
4. File operations — path traversal possible?
5. HTTP calls — SSRF possible?
6. Sekrety w kodzie?
7. Reflection / dynamic class loading (RCE risk)?
8. Session manipulation (privilege escalation)?
9. Czy plugin słusznie modyfikuje shared state?
10. Czy plugin nie używa internals core (które mogą się zmienić)?

Format raportu:
- Severity (Critical/High/Medium/Low)
- Location
- Description
- Exploit scenario
- Fix
```

## Plugin lifecycle UX

### Admin UI prompt

```
ZADANIE: Zaprojektuj admin panel dla zarządzania pluginami.

EKRANY:

1. /admin/plugins (lista zainstalowanych)
   - Search, filter (active/inactive, category)
   - Per plugin: name, version, status, author, last updated
   - Bulk actions: activate, deactivate, update
   - "Update available" badge
   - Performance impact indicator (request time delta)

2. /admin/plugins/marketplace (browse)
   - Categories (SEO, e-commerce, integrations, themes...)
   - Search z filterami (free/paid, rating, compatibility)
   - Featured / popular
   - Per plugin card: screenshot, description, install button

3. /admin/plugins/{id} (detail)
   - Description, screenshots, changelog, README
   - Settings (configurable)
   - Permissions (read-only after install)
   - Logs (errors, audit)
   - Uninstall (with data retention options)

4. /admin/plugins/install (instalacja)
   - 3-step wizard:
     a) Permission review (list + accept)
     b) Dependencies check (auto-install required?)
     c) Install progress (download → migrate → activate)
   - Rollback button if anything fails

5. /admin/plugins/{id}/settings
   - Auto-generated form z plugin manifest
   - Validation (manifest defines schema)
   - Save / reset to defaults / export config

WIREFRAMES (text-based ok, np. ASCII).
TECH: Twig + Hotwire (Turbo for live updates) + AlpineJS dla simple interactivity.
```

## Co LLM często źle robi

### ❌ Tight coupling core ↔ plugin

```php
// Źle: core wie o konkretnym pluginie
if ($pluginManager->isActive('seo-plugin')) {
    $title = $container->get('seo.title_enhancer')->enhance($title);
}

// Dobrze: hook system, plugin sam się "podpina"
$title = $hooks->applyFilter('article.title', $title);
```

### ❌ Brak permission system

LLM domyślnie nie myśli o uprawnieniach. Zawsze pytaj:
"Jakie permissions powinien mieć plugin? Czy core wymusza ich respect?"

### ❌ Plugin = mini-aplikacja zamiast extension

Plugin powinien **rozszerzać**, nie duplikować. Np. plugin nie powinien mieć własnego user system — używa core users.

### ❌ Brak BC compatibility planu

```
"Co się dzieje gdy core zmienia API w wersji 3.0?
- Stare pluginy z v2 nadal działają? (BC layer)
- Pluginy must-update? (breaking change)
- Migration tool dla plugin developers?"
```

## Checklist promptów dla plugin-based CMS

Gdy planujesz CMS:

- [ ] Wybór modelu plugin (hooks vs services vs hybrid)
- [ ] Definicja Plugin API (interfejsy, manifest)
- [ ] Plugin Manager (lifecycle)
- [ ] Hook System (actions/filters)
- [ ] Service Container Extensions
- [ ] Event System (publishing/subscribing)
- [ ] Plugin marketplace / installer
- [ ] Permission system
- [ ] Theme system (oddzielnie)
- [ ] Plugin testing framework
- [ ] Security model (signing, sandbox)
- [ ] Update mechanism
- [ ] Plugin developer docs
- [ ] Backward compatibility strategy
- [ ] Sample plugin (jako reference)
- [ ] Admin UI dla plugin management

Każdy z tych = jeden łańcuch promptów (Discovery → Design → Implementation → Review).

## Real-world inspiracje (do studiowania)

```
1. Symfony Bundles
   github.com/symfony/symfony — zobacz jak SecurityBundle, FrameworkBundle są zorganizowane

2. Laravel Service Providers
   laravel.com/docs/providers — service providers + facades + events

3. Drupal Module API
   drupal.org/docs/extending-drupal/creating-modules — hooks api, service container

4. WordPress Hooks
   developer.wordpress.org/plugins/hooks/ — actions/filters w czystej postaci

5. Shopify Apps
   shopify.dev/docs/apps — sandboxed apps (Node), iframe admin

6. Strapi Plugins
   docs.strapi.io/dev-docs/plugins/developing-plugins — modern Node plugin system

7. Statamic Addons
   statamic.dev/extending — Composer-based addons w Laravel

8. OctoberCMS
   octobercms.com/docs — full CMS na Laravel, plugin-first
```

## Stack rekomendowany dla plugin-based CMS w PHP (2026)

```
Core framework: Symfony 7.x
Architecture:   DDD + CQRS-light
Plugin system:  Symfony Bundles + Custom Hook Layer
Plugin format:  Composer packages (lokalny lub Packagist)
Database:       PostgreSQL 17 + plugin schemas (plugin_xxx_*)
Cache:          Redis (plugin registry, hooks, sitemap...)
Search:         Meilisearch (plugins mogą rejestrować indeksy)
Frontend:       Twig + Hotwire (plugins mogą rejestrować templates)
Admin:          EasyAdmin + Hotwire (plugins extend menu)
Auth:           Symfony Security + plugin permissions layer
Queue:          Symfony Messenger (plugins enqueue jobs)
Tests:          PHPUnit + Pest + custom PluginTestCase
Static:         PHPStan level 8, Psalm (taint analysis)
CI/CD:          GitHub Actions (matrix testing for plugin compatibility)
Monitoring:     Sentry (per-plugin error tracking)
Marketplace:    Packagist (public) lub Private Packagist (premium)
Signing:        Composer + GPG signed releases
Documentation:  VitePress lub Hugo (oddzielnie od kodu)
```

## Końcowa lista promptów do skopiowania

### "Plan plugin-based CMS"
```
Plan plugin-based CMS w PHP/Symfony 7. Generuj sekwencyjnie:
1. Wybór modelu plugin (hybrid Symfony Bundles + Hooks + Events)
2. Plugin API (interfejsy + manifest YAML)
3. Plugin Manager (discovery, lifecycle, dependencies)
4. Hook System (actions + filters z priority)
5. Permission system
6. Marketplace + installer
7. Theme system
8. Plugin developer docs
9. Sample plugin (SEO) jako reference
10. Security model + signing
```

### "Build my plugin"
```
Buduję plugin "[NAZWA]" do mojego plugin-based CMS.

CO ROBI: [opisz funkcje]

INTEGRATION:
- Listen na hooks: [...]
- Emit events: [...]
- Extend admin: [...]
- Database: [own schema lub shared]
- Public API: [REST endpoints? Twig functions?]

KROKI:
1. plugin.yaml manifest (zaproponuj permissions)
2. Main plugin class (PluginInterface)
3. Domain layer (jeśli plugin ma logikę biznesową)
4. Listeners + filters
5. Admin UI (Twig + Hotwire)
6. Tests (using PluginTestCase)
7. README dla użytkowników plugin
8. CHANGELOG.md
```

### "Refactor monolith CMS to plugin-based"
```
Mam istniejący CMS w PHP (Symfony) jako monolit. Chcę zrefaktorować do plugin-based.

OBECNE FUNKCJE: [list]

PLAN MIGRACJI (zaplanuj):
1. Identyfikuj boundaries (które funkcje to plugin candidates)
2. Strangler Fig pattern — extract feature po feature
3. Definicja stable Plugin API (BC contract)
4. Pierwsze 3 pluginy do extract (priorytetyzuj impact/effort)
5. Migration path dla istniejących klientów

Pokaż konkretny plan z timeline (sprintach).
```
