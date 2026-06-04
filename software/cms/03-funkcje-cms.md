# Funkcje CMS

Ten rozdział to przegląd funkcji, które oferuje dojrzały CMS. Nie każdy system ma wszystkie — przy wyborze warto sprawdzić, które są wbudowane, które wymagają pluginu, a których brakuje.

## Mapa funkcji CMS

```
                          ┌─────────────────────┐
                          │        CMS          │
                          └─────────────────────┘
        ┌──────────────┬───────────┴───────┬──────────────┐
        ▼              ▼                   ▼              ▼
  ZARZĄDZANIE      UŻYTKOWNICY         PUBLIKACJA      ROZSZERZENIA
   TREŚCIĄ         I ROLE              I WORKFLOW       I INTEGRACJE
  ─────────       ──────────          ───────────     ────────────
  • edytory       • role (RBAC)       • draft/publish • pluginy
  • media         • uprawnienia       • wersjonowanie • motywy
  • modelowanie   • 2FA / SSO         • scheduling    • API REST/GraphQL
  • taksonomie    • audyt             • i18n          • webhooks
  • SEO           • profile           • podgląd       • marketplace
```

## 1. Zarządzanie i edycja treści

Serce każdego CMS. Sposób tworzenia treści zależy od typu edytora:

| Edytor | Opis | Dla kogo |
|--------|------|----------|
| **WYSIWYG** | Wizualny, jak Word (TinyMCE, CKEditor) | Redaktorzy nietechniczni |
| **Block editor** | Treść z bloków (Gutenberg, Editor.js) | Nowoczesne strony, układy |
| **Markdown** | Tekst ze składnią `**bold**` | Developerzy, dokumentacja |
| **Structured / fields** | Pola formularza (tytuł, cena, data) | Headless, dane strukturalne |
| **Visual / page builder** | Drag & drop sekcji (Elementor, Webflow) | Marketerzy, landing pages |

Operacje CRUD na treści: **Create** (utwórz), **Read** (odczytaj/podgląd), **Update** (edytuj), **Delete** (usuń/kosz).

## 2. Modelowanie treści (content modeling)

Definiowanie **struktury** treści — najważniejsza funkcja w headless CMS.

```
CONTENT TYPE: "Produkt"
├── Pole: nazwa          (text, wymagane)
├── Pole: cena           (number)
├── Pole: opis           (rich text)
├── Pole: zdjęcia        (media, wiele)
├── Pole: kategoria      (relacja → Taxonomy)
└── Pole: dostępny       (boolean)

CONTENT TYPE: "Artykuł"
├── Pole: tytuł          (text)
├── Pole: treść          (rich text / blocks)
├── Pole: autor          (relacja → User)
└── Pole: tagi           (relacja → Tag, wiele)
```

- **Content types** — typy treści o określonym schemacie (wpis, produkt, wydarzenie).
- **Fields** — pola o typach (tekst, liczba, data, media, relacja).
- **Relations** — powiązania (artykuł → autor, produkt → kategoria).
- **Taxonomies** — systemy klasyfikacji (kategorie hierarchiczne, tagi płaskie).

## 3. Zarządzanie mediami (media / DAM)

- **Biblioteka mediów** — centralne miejsce na obrazy, PDF, wideo, audio.
- **Upload i organizacja** — foldery, metadane, alt text, opisy.
- **Transformacje obrazów** — automatyczne miniatury, kadrowanie, formaty (WebP/AVIF).
- **Responsive images** — `srcset` dla różnych ekranów, lazy loading.
- **CDN / storage** — integracja z S3, Cloudinary, zewnętrznym magazynem.

## 4. Użytkownicy, role i uprawnienia (RBAC)

**RBAC (Role-Based Access Control)** — uprawnienia przypisane do ról, role do użytkowników.

```
ROLE (typowy model, np. WordPress)
┌────────────────┬──────────────────────────────────────────┐
│ Administrator  │ pełna kontrola, ustawienia, użytkownicy   │
│ Editor         │ publikuje i edytuje treść wszystkich      │
│ Author         │ tworzy i publikuje WŁASNE wpisy           │
│ Contributor    │ pisze, ale NIE publikuje (do recenzji)    │
│ Subscriber     │ tylko profil / komentarze                 │
└────────────────┴──────────────────────────────────────────┘
```

- **Granularne uprawnienia** — kto może co (create/edit/publish/delete) na jakim typie treści.
- **2FA / MFA** — uwierzytelnianie dwuskładnikowe.
- **SSO** — logowanie firmowe (SAML, OAuth, LDAP) w rozwiązaniach enterprise.
- **Audyt** — log kto, co i kiedy zmienił.

## 5. Workflow i publikacja

```
OBIEG TREŚCI (editorial workflow)
[Szkic] ──► [Do recenzji] ──► [Zatwierdzone] ──► [Opublikowane] ──► [Archiwum]
   │             │                  │                 │
 autor       redaktor           redaktor      widoczne publicznie
```

- **Statusy** — draft, pending review, scheduled, published, private, trash.
- **Scheduling** — zaplanowana publikacja na konkretną datę/godzinę.
- **Podgląd (preview)** — zobacz treść przed publikacją, także w headless.
- **Approval workflow** — wieloetapowa akceptacja w dużych redakcjach.

## 6. Wersjonowanie i historia (revisions)

- **Revisions** — automatyczny zapis wersji przy każdej edycji.
- **Rollback** — przywrócenie poprzedniej wersji jednym kliknięciem.
- **Porównanie (diff)** — co się zmieniło między wersjami.
- **Autosave** — ochrona przed utratą pracy.

## 7. Wielojęzyczność (i18n / l10n)

- **i18n (internationalization)** — przygotowanie systemu do wielu języków.
- **l10n (localization)** — konkretne tłumaczenia treści i interfejsu.
- Podejścia: osobne wpisy per język, pola tłumaczeń, osobne instancje, integracja z tłumaczeniami (np. WPML, Polylang, wbudowane w Strapi/Contentful).
- Elementy: tłumaczenie treści, interfejsu, URL-i, formatów dat/walut, RTL (arabski, hebrajski).

## 8. SEO (optymalizacja pod wyszukiwarki)

| Funkcja | Opis |
|---------|------|
| **Meta title / description** | Edytowalne znaczniki dla wyników wyszukiwania |
| **Przyjazne URL (slug)** | `/blog/czym-jest-cms` zamiast `?p=123` |
| **Sitemap XML** | Mapa strony dla robotów Google |
| **Schema.org / structured data** | Dane strukturalne (rich snippets) |
| **Canonical / robots** | Kontrola indeksowania, duplikatów |
| **Open Graph / Twitter Cards** | Podgląd przy udostępnianiu w social media |
| **Redirecty** | Przekierowania 301 przy zmianie URL |

Popularne pluginy SEO: Yoast, Rank Math (WordPress); wbudowane moduły w Drupal, TYPO3.

## 9. Szablony i motywy

- **Theme / motyw** — kompletny wygląd strony (szablony + CSS + JS).
- **Template hierarchy** — który szablon renderuje który typ treści (strona główna, wpis, kategoria, 404).
- **Template engine** — silnik szablonów (Twig w Drupal, Blade w Laravel, Liquid w Shopify, PHP w WordPress).
- **Child themes** — bezpieczna personalizacja bez modyfikacji rdzenia motywu.
- **Block patterns / komponenty** — gotowe sekcje do wielokrotnego użycia.

## 10. Rozszerzalność (pluginy, hooki, API)

- **Pluginy / moduły / rozszerzenia** — dodają funkcje bez modyfikacji rdzenia.
- **Hooks (actions/filters)** — punkty zaczepienia w kodzie, gdzie plugin wstrzykuje logikę.
- **Events / webhooks** — powiadomienia o zdarzeniach (opublikowano wpis → wyślij do Slacka).
- **API** — REST i/lub GraphQL do odczytu/zapisu treści z zewnątrz.
- **Marketplace** — repozytorium gotowych dodatków (WordPress: 60 000+ pluginów).

## 11. Pozostałe funkcje

- **Wyszukiwarka** — full-text search, integracja z Elasticsearch/Algolia.
- **Formularze** — kontakt, zapis na newsletter, ankiety.
- **Komentarze i moderacja** — natywne lub przez Disqus.
- **Cache** — wbudowane buforowanie wydajnościowe (więcej w rozdziale 04).
- **Backup** — kopie zapasowe treści i bazy.
- **Analytics** — integracja z Google Analytics, Matomo, statystyki wbudowane.

## Must-have vs nice-to-have

```
MUST-HAVE (każdy poważny projekt)        NICE-TO-HAVE (zależnie od potrzeb)
─────────────────────────────────       ──────────────────────────────────
✓ Edytor treści                          ○ Wielojęzyczność
✓ Zarządzanie mediami                    ○ Workflow z akceptacją
✓ Role i uprawnienia                     ○ A/B testy, personalizacja
✓ Wersjonowanie                          ○ Marketing automation
✓ SEO podstawowe                         ○ GraphQL API
✓ Bezpieczeństwo (auth, aktualizacje)    ○ Headless / omnichannel
✓ Backup                                 ○ Marketplace rozszerzeń
```

Przy wyborze CMS (rozdział 07) zrób listę funkcji **wymaganych** i sprawdź, czy są wbudowane, dostępne jako plugin, czy w ogóle niemożliwe.
