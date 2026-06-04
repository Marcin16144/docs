# Podstawy CMS (Content Management System)

## Czym jest CMS?

**CMS (Content Management System)** to system zarządzania treścią — oprogramowanie, które pozwala tworzyć, edytować, organizować i publikować treść na stronie internetowej **bez konieczności programowania**. CMS oddziela treść (teksty, zdjęcia, produkty) od warstwy technicznej (kod, szablony, baza danych), dzięki czemu osoba nietechniczna może samodzielnie aktualizować stronę przez panel administracyjny w przeglądarce.

Najprościej: zamiast edytować pliki HTML i wgrywać je przez FTP, logujesz się do panelu, klikasz „Dodaj wpis", wpisujesz tekst i publikujesz.

## Kluczowe pojęcia

| Pojęcie | Wyjaśnienie |
|---------|-------------|
| **Content (treść)** | Dane zarządzane przez CMS: wpisy, strony, produkty, zdjęcia, komentarze. |
| **CMS core (rdzeń)** | Podstawowy silnik systemu — zarządza treścią, użytkownikami, żądaniami. |
| **Backend / panel admina** | Interfejs administracyjny, w którym redaktor zarządza treścią (np. `/wp-admin`). |
| **Frontend** | Publiczna część strony, którą widzi odwiedzający. |
| **Template / szablon** | Plik definiujący wygląd i układ renderowanej strony. |
| **Theme / motyw** | Zestaw szablonów + style (CSS) + assety, nadający stronie wygląd. |
| **Plugin / moduł / rozszerzenie** | Dodatek rozszerzający funkcje CMS bez zmiany rdzenia. |
| **Content type** | Typ treści o określonej strukturze (wpis, strona, produkt, wydarzenie). |
| **Taxonomy (taksonomia)** | System klasyfikacji treści — kategorie, tagi. |
| **Slug** | Przyjazny fragment URL identyfikujący treść (np. `/blog/czym-jest-cms`). |
| **Media library** | Biblioteka plików (obrazy, PDF, wideo) zarządzanych przez CMS. |
| **Workflow** | Proces obiegu treści: szkic → recenzja → publikacja. |
| **WYSIWYG** | „What You See Is What You Get" — edytor wizualny przypominający Worda. |
| **Headless** | CMS bez warstwy prezentacji — dostarcza treść przez API. |

## Po co CMS? Problem, który rozwiązuje

```
BEZ CMS (statyczny HTML)               Z CMS
─────────────────────────              ─────────────────────────
1. Edytuj plik .html                   1. Zaloguj się do panelu
2. Znajdź właściwe miejsce w kodzie    2. Kliknij "Dodaj / Edytuj"
3. Uważaj, by nie zepsuć układu        3. Wpisz tekst w edytorze
4. Wgraj przez FTP                     4. Kliknij "Publikuj"
5. Powtórz na każdej podstronie        → gotowe, zmiana widoczna od razu
   (np. menu, stopka)

Wymaga: znajomości HTML/CSS/FTP        Wymaga: umiejętności obsługi panelu
Ryzyko: literówka psuje stronę         Bezpieczne: treść oddzielona od kodu
Skala: 5 podstron = OK                 Skala: 5000 podstron = bez problemu
```

CMS rozwiązuje cztery główne problemy:
- **Dostępność** — osoba nietechniczna aktualizuje treść samodzielnie.
- **Spójność** — szablon gwarantuje jednolity wygląd wszystkich podstron.
- **Skala** — zarządzanie tysiącami stron z jednego miejsca.
- **Współpraca** — wielu redaktorów, role i uprawnienia, obieg treści.

## Anatomia CMS

```
                    ┌──────────────────────────────────┐
                    │          ODWIEDZAJĄCY             │
                    │         (przeglądarka)            │
                    └─────────────────┬─────────────────┘
                                      │ żądanie HTTP
                                      ▼
   ┌──────────────────────────────────────────────────────────────┐
   │                          CMS                                   │
   │                                                                │
   │   ┌─────────────┐   ┌──────────────┐   ┌──────────────────┐   │
   │   │  FRONTEND   │   │   RDZEŃ CMS  │   │     BACKEND      │   │
   │   │  (szablony, │◄──┤  (routing,   ├──►│  (panel admina,  │   │
   │   │   motyw)    │   │   logika)    │   │   edycja treści) │   │
   │   └─────────────┘   └──────┬───────┘   └──────────────────┘   │
   │                            │                       ▲           │
   │                     ┌──────┴───────┐               │           │
   │                     │   PLUGINY    │         redaktor / admin  │
   │                     │  / moduły    │                           │
   │                     └──────┬───────┘                           │
   └────────────────────────────┼──────────────────────────────────┘
                                 ▼
                       ┌──────────────────┐
                       │  BAZA DANYCH +   │
                       │   pliki (media)  │
                       └──────────────────┘
```

Cztery elementy każdego CMS:
1. **Backend (panel administracyjny)** — gdzie redaktor zarządza treścią.
2. **Baza danych / magazyn treści** — gdzie treść jest przechowywana.
3. **Frontend / warstwa prezentacji** — szablony renderujące treść dla odwiedzających.
4. **Rdzeń + rozszerzenia** — logika łącząca to wszystko, rozszerzalna pluginami.

## Krótka historia CMS

```
1995  — Pierwsze "content management" na bazie skryptów CGI/Perl
2000  — PHP-Nuke, Mambo — pierwsze popularne open-source CMS
2001  — Movable Type — blogi z generowaniem statycznym
2003  — WordPress (fork b2/cafelog), TYPO3 dojrzewa
2005  — Joomla (fork Mambo), Drupal zyskuje na popularności
2008  — WordPress wprowadza pluginy i motywy na dużą skalę
2011  — Pojawia się idea "headless" / API-first
2013  — Contentful — pierwszy popularny headless CMS w chmurze
2015  — JAMstack, Static Site Generators (Jekyll, Hugo)
2018  — Gutenberg (block editor) w WordPressie
2020  — Eksplozja headless: Strapi, Sanity, Directus, Payload
2023  — Visual headless (Storyblok), CMS + AI (generowanie treści)
2026  — AI-native CMS, automatyczne tagowanie, personalizacja treści
```

## Statystyki rynku (2026)

- **WordPress** napędza ok. **43% wszystkich stron** w internecie i ma ok. **60% udziału** w rynku CMS.
- Pozostały rynek dzielą m.in. Shopify, Wix, Squarespace, Joomla, Drupal oraz rosnący segment headless.
- Ponad **70% nowych projektów** korporacyjnych rozważa architekturę headless lub hybrydową.

## Dla kogo jaki CMS? (szybki przegląd)

| Profil | Potrzeby | Typowy wybór |
|--------|----------|--------------|
| **Bloger / twórca** | Prosta publikacja, SEO, newsletter | WordPress, Ghost |
| **Mała firma** | Strona wizytówka, łatwa edycja | WordPress, Wix, Squarespace |
| **Sklep internetowy** | Produkty, koszyk, płatności | WooCommerce, Shopify, PrestaShop |
| **Medium / portal** | Dużo treści, redakcja, workflow | WordPress, Drupal, TYPO3 |
| **Startup / aplikacja** | Treść przez API, wiele kanałów | Strapi, Sanity, Contentful |
| **Korporacja / enterprise** | Skala, bezpieczeństwo, personalizacja | Adobe AEM, Sitecore, Drupal |
| **Developer / portfolio** | Szybkość, Git, Markdown | Astro + headless, Hugo, Grav |

## Kiedy NIE potrzebujesz CMS?

CMS to dodatkowa złożoność (baza danych, aktualizacje, bezpieczeństwo). Nie zawsze się opłaca:

- **Strona-wizytówka 1-5 podstron**, która rzadko się zmienia → zwykły HTML/CSS lub kreator.
- **Landing page** kampanii → statyczny HTML lub builder (Framer, Webflow).
- **Dokumentacja techniczna** → Static Site Generator (Docusaurus, MkDocs, Astro).
- **Portfolio dewelopera** → SSG (Hugo, Eleventy) + Markdown w repozytorium Git.

Zasada: jeśli treść zmienia osoba techniczna i robi to rzadko — CMS bywa nadmiarowy. Jeśli treść zmienia osoba nietechniczna i robi to często — CMS się opłaca.

## Co dalej?

W kolejnych rozdziałach poznasz:
- **Rodzaje CMS** — coupled, headless, decoupled, SaaS vs self-hosted (rozdział 02)
- **Funkcje CMS** — edycja, media, role, workflow, SEO, API (rozdział 03)
- **Architekturę** — warstwy, request lifecycle, hooki, cache (rozdział 04)
- **Popularne rozwiązania** — WordPress, Drupal, Strapi, Contentful i inne (rozdział 05)
- **Headless i JAMstack** — nowoczesne podejście API-first (rozdział 06)
- **Wybór i wdrożenie** — jak wybrać i bezpiecznie uruchomić CMS (rozdział 07)
