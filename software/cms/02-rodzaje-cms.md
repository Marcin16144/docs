# Rodzaje CMS

CMS-y można klasyfikować na kilka niezależnych sposobów. Ten sam system można opisać wieloma „osiami" jednocześnie — np. WordPress to *coupled + database-driven + open-source + self-hosted*, a Contentful to *headless + SaaS + komercyjny*.

## Pięć osi klasyfikacji

```
1. ARCHITEKTURA    → coupled / decoupled / headless / hybrid
2. HOSTING         → self-hosted / SaaS (cloud)
3. LICENCJA        → open-source / komercyjny (proprietary)
4. MAGAZYN TREŚCI  → database-driven / flat-file / git-based
5. PRZEZNACZENIE   → WCMS / e-commerce / DXP / ECM / DAM / wiki / LMS
```

## 1. Podział wg architektury (najważniejszy)

To kluczowy podział decydujący o tym, jak treść trafia do użytkownika.

### Coupled / Traditional (monolityczny)

Backend i frontend są zintegrowane w jednym systemie. CMS przechowuje treść **i** renderuje gotowy HTML.

```
┌─────────────────────────────────────────────┐
│                 CMS (monolit)               │
│  ┌──────────┐  ┌────────┐  ┌─────────────┐  │
│  │  Panel   │  │ Logika │  │  Szablony   │  │──► HTML ──► Przeglądarka
│  │  admina  │  │ + dane │  │ (rendering) │  │
│  └──────────┘  └────────┘  └─────────────┘  │
└─────────────────────────────────────────────┘
Przykłady: WordPress, Joomla, Drupal (klasycznie), TYPO3
```

- ✅ Szybki start, wszystko w jednym, podgląd na żywo, ogromny ekosystem motywów.
- ❌ Sztywne powiązanie treści z prezentacją, trudniejsza obsługa wielu kanałów (web + mobile + IoT).

### Headless (bezgłowy)

CMS to **tylko backend** — przechowuje treść i udostępnia ją przez API (REST/GraphQL). Frontend („głowę") budujesz osobno (Next.js, mobile app, IoT).

```
┌───────────────────┐      API       ┌──────────────────┐
│   HEADLESS CMS    │   REST/GraphQL  │   FRONTEND(Y)    │
│  (treść + admin)  │ ──────────────► │  Web (Next.js)   │
│                   │                 │  App (iOS/Android)│
│   brak warstwy    │                 │  Smart TV / IoT  │
│   prezentacji     │                 │  Kiosk / digital │
└───────────────────┘                 └──────────────────┘
Przykłady: Contentful, Strapi, Sanity, Directus, Hygraph
```

- ✅ Dowolny frontend, omnichannel, wydajność, niezależny rozwój front/back.
- ❌ Wymaga zespołu developerskiego, brak gotowego „podglądu", więcej do zbudowania.

### Decoupled (rozdzielony)

Wariant pośredni: backend i frontend są rozdzielone, ale CMS **dostarcza domyślny frontend** (przez API), który można podmienić. Treść jest „pchana" do warstwy prezentacji.

- ✅ Elastyczność headless + gotowa warstwa prezentacji.
- ❌ Bardziej złożony niż coupled, dwie warstwy do utrzymania.

### Hybrid (hybrydowy)

Nowoczesne podejście: jeden CMS działa **i** jako tradycyjny (z renderowaniem), **i** jako headless (przez API). Redaktor ma wizualny podgląd, a developer dostęp do API.

- Przykłady: Storyblok, WordPress + REST API, Drupal (tryb hybrydowy), Umbraco Heartcore.

```
PORÓWNANIE ARCHITEKTUR
┌────────────┬───────────────┬──────────────┬──────────────────┐
│            │  Renderuje    │  Frontend    │  Najlepsze do    │
│            │  HTML?        │  dowolny?    │                  │
├────────────┼───────────────┼──────────────┼──────────────────┤
│ Coupled    │  TAK          │  NIE         │  blogi, strony   │
│ Decoupled  │  TAK (domyśl.)│  częściowo   │  portale         │
│ Headless   │  NIE (API)    │  TAK         │  apki, omnichannel│
│ Hybrid     │  opcjonalnie  │  TAK         │  enterprise      │
└────────────┴───────────────┴──────────────┴──────────────────┘
```

## 2. Podział wg modelu hostingu

### Self-hosted (instalowany)

Pobierasz oprogramowanie i instalujesz je na własnym serwerze/hostingu. Ty zarządzasz aktualizacjami, kopiami, bezpieczeństwem.

- Przykłady: WordPress.org, Drupal, Joomla, Strapi (self-host).
- ✅ Pełna kontrola, własne dane, brak opłat licencyjnych, dowolne modyfikacje.
- ❌ Odpowiedzialność za hosting, aktualizacje, bezpieczeństwo, backupy.

### SaaS / Cloud (w chmurze)

CMS działa jako usługa u dostawcy. Płacisz abonament, dostawca zarządza infrastrukturą.

- Przykłady: WordPress.com, Wix, Squarespace, Shopify, Contentful, Webflow.
- ✅ Zero administracji serwerem, automatyczne aktualizacje, skalowanie, wsparcie.
- ❌ Abonament, mniejsza kontrola, ograniczenia platformy, vendor lock-in.

```
Self-hosted: TY zarządzasz   [serwer][OS][CMS][aktualizacje][backup][bezpieczeństwo]
SaaS:        DOSTAWCA zarządza  ──────── wszystkim ────────►  Ty: tylko treść
```

## 3. Podział wg licencji

| Typ | Opis | Przykłady |
|-----|------|-----------|
| **Open-source** | Kod otwarty, zwykle darmowy, społeczność | WordPress, Drupal, Joomla, Strapi, Directus |
| **Komercyjny (proprietary)** | Zamknięty kod, licencja płatna | Adobe AEM, Sitecore, Kentico, Contentful |
| **Freemium / Open-core** | Rdzeń darmowy, funkcje premium płatne | Strapi, Ghost(Pro), Sanity, Storyblok |

Open-source nie zawsze znaczy „za darmo w użyciu" — dochodzą koszty hostingu, wdrożenia i utrzymania. Komercyjny nie zawsze znaczy „lepszy" — to kwestia wsparcia, SLA i gwarancji.

## 4. Podział wg magazynu treści

### Database-driven (oparty na bazie danych)

Treść w bazie (MySQL, PostgreSQL, MongoDB). Standard dla większości CMS.
- ✅ Wydajne zapytania, relacje, wyszukiwanie, skala.
- ❌ Backup = baza + pliki, ryzyko uszkodzenia bazy, wymaga serwera DB.

### Flat-file (pliki płaskie)

Treść w plikach (Markdown, YAML, JSON) — brak bazy danych.
- Przykłady: Grav, Kirby, Statamic (opcjonalnie).
- ✅ Prostota, łatwy backup (kopiuj pliki), szybkość, wersjonowanie w Git.
- ❌ Słabsze przy ogromnej liczbie treści i złożonych relacjach.

### Git-based (oparty na Git)

Treść jako pliki w repozytorium Git — edycja przez panel zapisuje commity.
- Przykłady: Decap CMS (Netlify CMS), Tina CMS, Sveltia.
- ✅ Pełna historia zmian, treść = kod, świetne dla JAMstack/SSG, brak osobnej bazy.
- ❌ Wymaga znajomości Git w tle, słabsze dla nietechnicznych zespołów na dużą skalę.

## 5. Podział wg przeznaczenia

| Skrót | Pełna nazwa | Cel | Przykłady |
|-------|-------------|-----|-----------|
| **WCMS** | Web Content Management System | Strony i treść webowa | WordPress, Drupal |
| **E-commerce** | — | Sprzedaż online | Shopify, WooCommerce, Magento |
| **DXP** | Digital Experience Platform | Spersonalizowane doświadczenia omnichannel | Adobe AEM, Sitecore, Optimizely |
| **ECM** | Enterprise Content Management | Dokumenty firmowe, obieg | SharePoint, Alfresco |
| **DAM** | Digital Asset Management | Zarządzanie zasobami (zdjęcia, wideo) | Bynder, Cloudinary |
| **Wiki/Docs** | — | Wiedza, dokumentacja | Confluence, MediaWiki, Docusaurus |
| **LMS** | Learning Management System | Kursy i edukacja | Moodle, LearnDash |

DXP to „CMS na sterydach" — łączy zarządzanie treścią z personalizacją, analityką, marketing automation i testami A/B dla dużych organizacji.

## Jak wybrać typ? (drzewo decyzyjne)

```
Czy treść edytują osoby nietechniczne i chcą podglądu na żywo?
├─ TAK ─► Coupled / Hybrid (WordPress, Drupal, Storyblok)
└─ NIE ─► Czy potrzebujesz wielu kanałów (web + app + IoT)?
          ├─ TAK ─► Headless (Strapi, Sanity, Contentful)
          └─ NIE ─► Czy zespół zna Git i lubi Markdown?
                    ├─ TAK ─► Git-based / Flat-file (Decap, Grav, Hugo)
                    └─ NIE ─► Coupled SaaS (Wix, Squarespace)

Czy to sklep? ──► E-commerce (Shopify / WooCommerce)
Czy enterprise z personalizacją? ──► DXP (Adobe AEM / Sitecore)
```

## Podsumowanie

Nie istnieje „najlepszy rodzaj CMS" — istnieje najlepszy **dla danego przypadku**. Kluczowe pytania: kto edytuje treść, ile kanałów obsługujesz, jak duża skala, jaki budżet i czy masz zespół developerski. W rozdziale 07 znajdziesz szczegółową macierz decyzyjną.
