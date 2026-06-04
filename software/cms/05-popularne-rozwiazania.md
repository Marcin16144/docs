# Popularne rozwiązania CMS

Przegląd najważniejszych systemów CMS w 2026 roku — pogrupowanych wg typu. Dla każdego: technologia, model, mocne strony i typowe zastosowanie.

## Tradycyjne CMS (coupled, open-source)

### WordPress

Najpopularniejszy CMS świata — napędza ok. **43% wszystkich stron** internetowych.

- **Technologia:** PHP + MySQL
- **Licencja:** open-source (GPL), self-hosted (.org) lub SaaS (.com)
- **Mocne strony:** największy ekosystem (60 000+ pluginów, tysiące motywów), niski próg wejścia, ogromna społeczność, WooCommerce dla e-commerce.
- **Słabe strony:** wydajność przy nadmiarze pluginów, bezpieczeństwo (popularny cel ataków), „spaghetti" przy rozbudowie.
- **Dla kogo:** blogi, strony firmowe, sklepy, media, 80% typowych projektów.

### Drupal

Zaawansowany CMS dla wymagających projektów.

- **Technologia:** PHP (Symfony) + MySQL/PostgreSQL
- **Licencja:** open-source (GPL)
- **Mocne strony:** elastyczne modelowanie treści, uprawnienia granularnie, wielojęzyczność klasy enterprise, tryb headless (JSON:API).
- **Słabe strony:** stromy próg wejścia, droższy development.
- **Dla kogo:** instytucje rządowe, uniwersytety, duże portale, projekty z złożoną strukturą treści.

### Joomla

CMS pośredni między WordPressem a Drupalem.

- **Technologia:** PHP + MySQL
- **Mocne strony:** wbudowana wielojęzyczność i kontrola dostępu, bez pluginów.
- **Dla kogo:** portale społecznościowe, katalogi, strony średniej złożoności.

### TYPO3

Enterprise CMS popularny w Europie (szczególnie DACH).

- **Technologia:** PHP + MySQL
- **Mocne strony:** skala enterprise, wielojęzyczność, wielodomenowość, długie wsparcie LTS.
- **Dla kogo:** duże firmy i korporacje europejskie.

### Ghost

Nowoczesna platforma do publikacji i newsletterów.

- **Technologia:** Node.js + MySQL/SQLite
- **Mocne strony:** szybkość, czysty edytor, wbudowane subskrypcje i newsletter (membership), tryb headless.
- **Dla kogo:** twórcy, blogi premium, newslettery, media subskrypcyjne.

## Headless CMS

### Strapi

Lider open-source headless.

- **Technologia:** Node.js, baza dowolna (PostgreSQL/MySQL/SQLite)
- **Licencja:** open-source (self-host) + Strapi Cloud
- **Mocne strony:** REST + GraphQL out-of-the-box, własny model treści, panel admina, samodzielny hosting (dane u Ciebie).
- **Dla kogo:** zespoły chcące headless z pełną kontrolą.

### Contentful

Pionier headless w chmurze (enterprise SaaS).

- **Technologia:** SaaS, API-first
- **Mocne strony:** dojrzałość, skala, CDN, bogate API, integracje.
- **Słabe strony:** koszt rośnie z użyciem, vendor lock-in.
- **Dla kogo:** korporacje, omnichannel, duże zespoły.

### Sanity

Headless z naciskiem na elastyczność i edycję w czasie rzeczywistym.

- **Technologia:** SaaS + open-source studio (React)
- **Mocne strony:** konfigurowalny edytor (Sanity Studio), GROQ query, real-time, hojny darmowy plan.
- **Dla kogo:** zespoły produktowe, projekty z nietypowym modelem treści.

### Directus

Headless nakładany na **dowolną istniejącą bazę SQL**.

- **Technologia:** Node.js, mapuje istniejącą bazę
- **Mocne strony:** „data platform" — działa na Twojej bazie, REST + GraphQL, no-code panel.
- **Dla kogo:** projekty z istniejącą bazą danych, backend dla aplikacji.

### Payload

Nowoczesny headless w TypeScript.

- **Technologia:** Node.js + TypeScript + MongoDB/PostgreSQL
- **Mocne strony:** code-first, pełny TypeScript, własny backend + admin, lokalna kontrola.
- **Dla kogo:** developerzy TypeScript, aplikacje Next.js.

### Pozostałe headless

| System | Wyróżnik |
|--------|----------|
| **Storyblok** | Visual editor + headless (podgląd na żywo) |
| **Hygraph** | GraphQL-native (dawniej GraphCMS) |
| **Prismic** | Slices — komponentowe sekcje treści |
| **Builder.io** | Visual no-code + AI, drag & drop na produkcji |
| **Decap CMS** | Git-based, open-source (dawniej Netlify CMS) |
| **Tina CMS** | Git-based z edycją wizualną inline |

## CMS dla e-commerce

| System | Technologia | Model | Dla kogo |
|--------|-------------|-------|----------|
| **Shopify** | SaaS (Liquid) | Abonament | Sklepy bez zaplecza technicznego, szybki start |
| **WooCommerce** | WordPress (PHP) | Open-source | Sklepy na WordPressie, elastyczność |
| **Magento / Adobe Commerce** | PHP | Open-source/enterprise | Duże sklepy, złożone katalogi |
| **PrestaShop** | PHP | Open-source | Sklepy europejskie, średnia skala |
| **Medusa** | Node.js | Open-source headless | Headless commerce, customizacja |
| **commercetools** | SaaS | Enterprise headless | Korporacyjny omnichannel |

## SaaS site buildery (no-code)

| System | Wyróżnik | Dla kogo |
|--------|----------|----------|
| **Wix** | Drag & drop, AI builder | Małe firmy, brak technicznych |
| **Squarespace** | Eleganckie szablony, portfolio | Twórcy, restauracje, portfolio |
| **Webflow** | Wizualny + czysty kod + CMS | Designerzy, agencje |
| **Framer** | Strony + animacje, AI | Landing pages, startupy |

## Enterprise DXP (Digital Experience Platforms)

| System | Technologia | Wyróżnik |
|--------|-------------|----------|
| **Adobe Experience Manager** | Java | Personalizacja + Adobe Cloud, marketing |
| **Sitecore** | .NET | Personalizacja, marketing automation |
| **Optimizely** | .NET | A/B testy, eksperymentacja |
| **Kentico / Xperience** | .NET | DXP dla średnich firm |
| **Contentstack** | SaaS | Composable, headless DXP |

## Flat-file i Git-based

| System | Technologia | Wyróżnik |
|--------|-------------|----------|
| **Grav** | PHP, flat-file | Bez bazy danych, szybki |
| **Kirby** | PHP, flat-file | Elastyczny, dla developerów |
| **Statamic** | PHP (Laravel) | Flat-file lub baza, dla Laravela |
| **Hugo** | Go, SSG | Bardzo szybki generator statyczny |
| **Astro** | JS, SSG | Nowoczesny, „islands", multi-framework |
| **Eleventy (11ty)** | JS, SSG | Prosty, lekki generator |

## Wielka tabela porównawcza

| CMS | Typ | Tech | Licencja | Najlepsze do |
|-----|-----|------|----------|--------------|
| WordPress | Coupled/Hybrid | PHP | Open-source | Uniwersalne, blogi, firmy |
| Drupal | Coupled/Hybrid | PHP | Open-source | Enterprise, złożona treść |
| Joomla | Coupled | PHP | Open-source | Portale, katalogi |
| Ghost | Coupled/Headless | Node | Open-core | Blogi, newslettery |
| TYPO3 | Coupled | PHP | Open-source | Enterprise EU |
| Strapi | Headless | Node | Open-core | API-first, self-host |
| Contentful | Headless | SaaS | Komercyjny | Enterprise omnichannel |
| Sanity | Headless | SaaS | Open-core | Elastyczny model treści |
| Directus | Headless | Node | Open-source | Istniejąca baza, backend |
| Payload | Headless | TS | Open-source | Aplikacje TypeScript/Next |
| Storyblok | Hybrid headless | SaaS | Komercyjny | Visual + headless |
| Shopify | E-commerce | SaaS | Komercyjny | Sklepy, szybki start |
| WooCommerce | E-commerce | PHP | Open-source | Sklepy na WordPressie |
| Webflow | SaaS builder | SaaS | Komercyjny | Designerzy, agencje |
| Adobe AEM | DXP | Java | Komercyjny | Korporacje, personalizacja |

## Mapa „co wybrać" (skrót)

```
Chcę szybko, tanio, sam ──────────────► WordPress / Wix
Blog premium z newsletterem ──────────► Ghost
Sklep bez technicznych ───────────────► Shopify
Sklep elastyczny na WP ───────────────► WooCommerce
Wiele kanałów (web+app), mam dev ─────► Strapi / Sanity / Contentful
Mam już bazę danych ──────────────────► Directus
Projekt Next.js / TypeScript ─────────► Payload / Sanity
Korporacja, personalizacja, budżet ───► Adobe AEM / Sitecore
Designer, pełna kontrola wizualna ────► Webflow
Developer, Git + Markdown, statyczne ─► Astro + Decap / Hugo
```

Szczegółowe kryteria wyboru i macierz decyzyjną znajdziesz w rozdziale 07.
