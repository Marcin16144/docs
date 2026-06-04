# Headless i JAMstack

Headless CMS i JAMstack to dominujące podejście w nowoczesnych projektach webowych. Ten rozdział wyjaśnia, czym się różnią od tradycyjnego CMS, jak działa renderowanie statyczne i kiedy to podejście ma sens.

## Czym jest headless CMS?

**Headless** = „bez głowy". Głowa to warstwa prezentacji (frontend). Headless CMS to system, który zarządza treścią i udostępnia ją przez **API**, ale **nie renderuje** strony — robi to osobny frontend.

```
TRADYCYJNY (coupled)                 HEADLESS
─────────────────────                ─────────────────────
┌─────────────────┐                  ┌─────────────────┐
│   Panel admina  │                  │   Panel admina  │
├─────────────────┤                  ├─────────────────┤
│   Baza treści   │                  │   Baza treści   │
├─────────────────┤                  ├─────────────────┤
│  RENDEROWANIE   │ ← połączone      │   API (JSON)    │ ← tylko dane
│  (szablony→HTML)│                  └────────┬────────┘
└────────┬────────┘                           │ REST/GraphQL
         │ HTML                                ▼
         ▼                            ┌─────────────────┐
   Przeglądarka                       │  FRONTEND (osob.)│
                                      │  Next.js / app  │ → HTML
                                      └────────┬────────┘
                                               ▼
                                         Przeglądarka
```

CMS zwraca treść jako JSON:

```json
GET /api/posts/czym-jest-cms
{
  "title": "Czym jest CMS",
  "slug": "czym-jest-cms",
  "content": "CMS to system zarządzania treścią...",
  "author": { "name": "Marcin" },
  "publishedAt": "2026-06-01"
}
```

Frontend pobiera ten JSON i sam decyduje, jak go wyświetlić — na stronie WWW, w aplikacji mobilnej, na smartwatchu czy ekranie reklamowym.

## Headless vs tradycyjny — porównanie

| Cecha | Tradycyjny (coupled) | Headless |
|-------|----------------------|----------|
| **Renderowanie** | CMS generuje HTML | Frontend generuje HTML |
| **Frontend** | Narzucony przez motyw | Dowolny (React, Vue, mobile) |
| **Kanały** | Głównie web | Omnichannel (web, app, IoT, TV) |
| **Wydajność** | Zależna od serwera CMS | Bardzo wysoka (CDN, statyczne) |
| **Próg wejścia** | Niski (gotowe motywy) | Wyższy (trzeba zbudować front) |
| **Podgląd treści** | Wbudowany, na żywo | Wymaga konfiguracji |
| **Bezpieczeństwo** | Większa powierzchnia ataku | Mniejsza (admin oddzielony) |
| **Zespół** | Może być nietechniczny | Wymaga developerów |

## Czym jest JAMstack?

**JAMstack** = **J**avaScript + **A**PIs + **M**arkup. Architektura, w której strona to wstępnie zbudowany statyczny **Markup** (HTML), wzbogacony **JavaScriptem**, korzystający z usług przez **API**.

```
JAMSTACK — przepływ
┌──────────────┐   build   ┌──────────────┐   deploy   ┌──────────────┐
│ Headless CMS │ ────────► │  Generator   │ ─────────► │     CDN      │
│ (treść JSON) │           │  (Next/Astro)│            │ (statyczny   │
│              │           │  HTML+JS+CSS │            │  HTML)       │
└──────────────┘           └──────────────┘            └──────┬───────┘
       │                                                      │
       │ webhook: "treść zmieniona → przebuduj"               ▼
       └──────────────────────────────────────────►    Użytkownik
                                                      (błyskawicznie)
```

Zasady JAMstack:
- **Pre-rendering** — strony budowane z wyprzedzeniem, serwowane jako statyczne pliki.
- **Decoupling** — frontend oddzielony od backendu, komunikacja przez API.
- **CDN-first** — statyczne pliki blisko użytkownika = szybkość i bezpieczeństwo.

## Static Site Generators (SSG)

Generatory budujące statyczny HTML z treści + szablonów:

| Generator | Technologia | Wyróżnik |
|-----------|-------------|----------|
| **Next.js** | React | Hybrydowy (SSG+SSR+ISR), najpopularniejszy |
| **Astro** | Multi-framework | „Islands", minimum JS, bardzo szybki |
| **Nuxt** | Vue | Odpowiednik Next.js dla Vue |
| **Gatsby** | React + GraphQL | Bogaty ekosystem pluginów |
| **Hugo** | Go | Najszybszy build, świetny do dokumentacji |
| **Eleventy** | JavaScript | Prosty, lekki, elastyczny |
| **SvelteKit** | Svelte | Wydajny, mały bundle |

## Strategie renderowania

Kluczowy wybór w nowoczesnym froncie — **kiedy** i **gdzie** powstaje HTML:

```
SSG (Static)      build-time:  HTML gotowy podczas budowania
                  ┌──────┐ build ┌──────┐ request ┌──────┐
                  │ Treść│ ────► │ HTML │ ──────► │ User │
                  └──────┘       └──────┘         └──────┘
                  ✓ najszybsze  ✗ trzeba przebudować przy zmianie

SSR (Server)      request-time: HTML generowany przy każdym żądaniu
                  ┌──────┐ request ┌────────┐ HTML ┌──────┐
                  │ User │ ──────► │ Serwer │ ───► │ User │
                  └──────┘         └────────┘      └──────┘
                  ✓ zawsze świeże ✗ wolniejsze, obciąża serwer

ISR (Incremental) hybryda: statyczne + odświeżanie co X
                  ✓ szybkie + w miarę świeże (Next.js)

CSR (Client)      przeglądarka renderuje JS po pobraniu
                  ✓ interaktywne ✗ wolny pierwszy render, gorsze SEO
```

| Strategia | HTML powstaje | Najlepsze do | Świeżość |
|-----------|---------------|--------------|----------|
| **SSG** | Podczas build | Blogi, docs, landing | Po przebudowie |
| **SSR** | Przy żądaniu (serwer) | Dashboardy, personalizacja | Zawsze świeże |
| **ISR** | Build + odświeżanie | E-commerce, duże portale | Quasi-świeże |
| **CSR** | W przeglądarce | Aplikacje SPA, panele | Dynamiczne |

Nowoczesne frameworki (Next.js, Nuxt) pozwalają **mieszać** strategie per strona — blog jako SSG, koszyk jako SSR.

## Przykładowy nowoczesny stack

```
┌─────────────────────────────────────────────────────────────┐
│  Sanity (headless CMS)  →  treść jako JSON przez API         │
│         │                                                     │
│         ▼                                                     │
│  Next.js (frontend)     →  pobiera treść, renderuje (ISR)    │
│         │                                                     │
│         ▼                                                     │
│  Vercel (hosting/CDN)   →  deploy, edge network, podgląd     │
│         │                                                     │
│         ▼                                                     │
│  Webhook: zmiana w Sanity → automatyczny rebuild w Vercel    │
└─────────────────────────────────────────────────────────────┘
```

Inne popularne zestawy:
- **Contentful + Next.js + Vercel** — enterprise.
- **Strapi + Nuxt + własny VPS** — pełna kontrola, self-host.
- **Decap CMS + Astro + Netlify** — Git-based, w pełni darmowy stack.
- **WordPress (headless) + Next.js** — treść w znanym WP, nowoczesny front.

## Zalety i wady headless/JAMstack

```
ZALETY                              WADY
──────────────────────────          ──────────────────────────
✓ Wydajność (statyczne + CDN)       ✗ Wyższy próg wejścia
✓ Bezpieczeństwo (mniej ataków)     ✗ Trzeba zbudować frontend
✓ Omnichannel (web, app, IoT)       ✗ Podgląd treści wymaga pracy
✓ Skalowalność (CDN globalnie)      ✗ Dynamiczne funkcje = więcej kodu
✓ Niezależny rozwój front/back      ✗ Build przy dużej treści bywa wolny
✓ Wolność wyboru technologii        ✗ Więcej usług do zarządzania
✓ Lepsze Core Web Vitals (SEO)      ✗ Koszt SaaS rośnie ze skalą
```

## Kiedy headless ma sens, a kiedy nie?

**Wybierz headless/JAMstack, gdy:**
- Masz wiele kanałów (web + aplikacja mobilna + inne).
- Zależy Ci na maksymalnej wydajności i SEO.
- Masz zespół developerski znający React/Vue.
- Budujesz produkt, nie tylko stronę.

**Zostań przy tradycyjnym CMS, gdy:**
- Treść edytują osoby nietechniczne i potrzebują podglądu na żywo.
- Budżet i czas są ograniczone (gotowe motywy = szybciej).
- Projekt to typowa strona/blog na jednym kanale (web).
- Nie masz zespołu developerskiego do utrzymania frontu.

## Podsumowanie

Headless i JAMstack przesuwają renderowanie z serwera CMS na build-time i CDN, dając wydajność, bezpieczeństwo i wolność technologiczną — kosztem większego nakładu developerskiego. To świetny wybór dla produktów omnichannel z zespołem technicznym, ale nadmiarowy dla prostej strony firmowej, którą redaguje osoba nietechniczna.
