# Wybór i wdrożenie CMS

Praktyczny przewodnik: jak wybrać właściwy CMS, bezpiecznie go wdrożyć, utrzymać i ile to kosztuje.

## Kryteria wyboru CMS (checklist)

```
☐ KTO edytuje treść?         techniczny / nietechniczny zespół
☐ ILE kanałów?               tylko web / web + app + inne
☐ JAKA skala?                10 stron / 10 000 stron / miliony
☐ JAKI budżet?               darmowy / abonament / enterprise
☐ JAKI zespół?               solo / agencja / dział IT
☐ WYMAGANE funkcje?          e-commerce, wielojęzyczność, workflow
☐ INTEGRACJE?                CRM, ERP, płatności, marketing
☐ HOSTING?                   self-host / SaaS / cloud
☐ BEZPIECZEŃSTWO?            standardowe / RODO / compliance
☐ PRZYSZŁOŚĆ?                czy łatwo migrować / skalować?
```

## Macierz decyzyjna

| Twój przypadek | Rekomendacja | Dlaczego |
|----------------|--------------|----------|
| Blog osobisty | WordPress / Ghost | Prostota, SEO, niski koszt |
| Strona firmowa (wizytówka) | WordPress / Wix / Squarespace | Szybko, tanio, łatwa edycja |
| Sklep — szybki start | Shopify | Zero zaplecza, gotowe płatności |
| Sklep — elastyczny | WooCommerce / PrestaShop | Kontrola, własny hosting |
| Portal / medium | WordPress / Drupal | Redakcja, workflow, skala |
| Aplikacja + treść | Strapi / Sanity / Contentful | Headless, API, omnichannel |
| Projekt Next.js | Payload / Sanity | TypeScript, integracja |
| Mam istniejącą bazę | Directus | Headless na Twojej bazie |
| Korporacja, personalizacja | Adobe AEM / Sitecore | DXP, marketing, SLA |
| Dokumentacja techniczna | Docusaurus / MkDocs / Astro | SSG, Markdown, Git |
| Designer, pełna kontrola | Webflow | Wizualnie + czysty kod |

## Proces wdrożenia (etapy)

```
1. ANALIZA          wymagania, audyt treści, wybór CMS
       │
2. ARCHITEKTURA     model treści, typy, taksonomie, role
       │
3. SETUP            instalacja, środowiska (dev/staging/prod)
       │
4. DESIGN           motyw / frontend, design system
       │
5. DEVELOPMENT      szablony, pluginy, integracje, API
       │
6. MIGRACJA         import treści ze starego systemu
       │
7. TESTY            funkcjonalne, wydajność, bezpieczeństwo, RWD
       │
8. GO-LIVE          DNS, SSL, redirecty 301, monitoring
       │
9. UTRZYMANIE       aktualizacje, backupy, optymalizacja
```

Zawsze pracuj na trzech środowiskach: **dev** (development), **staging** (testowe, kopia produkcji), **production** (live). Nigdy nie testuj na produkcji.

## Migracja treści

Najtrudniejszy etap przy zmianie CMS. Plan:

- **Audyt treści** — co migrować, co odrzucić (często 30-50% treści jest zbędne).
- **Mapowanie** — stara struktura → nowy model (typy, pola, kategorie).
- **Eksport/import** — narzędzia migracyjne, skrypty, API.
- **Redirecty 301** — KAŻDY stary URL musi przekierowywać na nowy (ochrona SEO).
- **Weryfikacja** — sprawdź linki, obrazy, formatowanie, metadane.
- **Zachowaj stary system** — w trybie tylko do odczytu, na wszelki wypadek.

```
⚠️ Najczęstszy błąd migracji: brak redirectów 301
   Stare URL-e znikają → Google traci strony → spadek ruchu o 40-70%
   Rozwiązanie: mapa przekierowań stary→nowy URL przed go-live
```

## Hosting — opcje

| Typ | Opis | Dla kogo | Koszt |
|-----|------|----------|-------|
| **Shared hosting** | Współdzielony serwer | Małe strony, blogi | $ |
| **VPS** | Wirtualny serwer prywatny | Średnie projekty, kontrola | $$ |
| **Managed (np. WP Engine)** | Zarządzany pod konkretny CMS | Firmy bez działu IT | $$$ |
| **Cloud (AWS/GCP/Azure)** | Skalowalna infrastruktura | Duży ruch, enterprise | $$$$ |
| **Serverless / Edge** | Funkcje + CDN (headless) | JAMstack, statyczne | $-$$ |
| **PaaS (Vercel/Netlify)** | Deploy frontu + CDN | Headless/JAMstack | $-$$$ |

## Bezpieczeństwo CMS

Bezpieczeństwo to proces, nie jednorazowa konfiguracja. CMS-y (szczególnie popularne) są celem ataków.

```
WEKTORY ATAKU                       OBRONA
─────────────────────               ─────────────────────
Nieaktualne pluginy/rdzeń    ──►   Regularne aktualizacje
Słabe hasła                  ──►   Silne hasła + 2FA
Brak HTTPS                   ──►   SSL/TLS wszędzie
SQL injection / XSS          ──►   Walidacja, sanityzacja, WAF
Brute force na login         ──►   Limit prób, rate limiting, captcha
Brak backupów                ──►   Automatyczne kopie + test odtwarzania
Nadmiarowe uprawnienia       ──►   Zasada najmniejszych uprawnień
```

Checklist bezpieczeństwa:
- ✅ Aktualizuj rdzeń i pluginy (główny wektor ataku).
- ✅ HTTPS na całej stronie (Let's Encrypt = darmowe SSL).
- ✅ 2FA dla wszystkich kont administracyjnych.
- ✅ Automatyczne backupy + okresowy test odtwarzania.
- ✅ WAF (np. Cloudflare) i limitowanie prób logowania.
- ✅ Usuń nieużywane pluginy i motywy (mniejsza powierzchnia ataku).
- ✅ Minimalne uprawnienia plików i konta bazy danych.

## Wydajność

```
PIRAMIDA OPTYMALIZACJI (od podstaw)
┌─────────────────────────────────────┐
│  5. CDN globalnie                    │  ← najszybciej dla użytkownika
├─────────────────────────────────────┤
│  4. Cache (page + object + opcode)   │
├─────────────────────────────────────┤
│  3. Optymalizacja obrazów (WebP)     │
├─────────────────────────────────────┤
│  2. Optymalizacja zapytań do bazy    │
├─────────────────────────────────────┤
│  1. Dobry hosting + aktualny PHP/Node│  ← fundament
└─────────────────────────────────────┘
```

- **Cache** — najważniejszy mechanizm (patrz rozdział 04).
- **Obrazy** — WebP/AVIF, lazy loading, responsywne `srcset` (obrazy to zwykle 50%+ wagi strony).
- **CDN** — serwowanie blisko użytkownika.
- **Minimalizacja** — mniej pluginów, lekki motyw, minifikacja CSS/JS.
- **Core Web Vitals** — LCP, INP, CLS — wpływają na SEO i konwersję.

## Utrzymanie (maintenance)

Strona po wdrożeniu wymaga stałej opieki:

- **Aktualizacje** — rdzeń, pluginy, motywy (najpierw na staging!).
- **Backupy** — automatyczne, codzienne, przechowywane poza serwerem.
- **Monitoring** — uptime, błędy, wydajność, bezpieczeństwo.
- **Refresh treści** — aktualizacja starych wpisów (SEO).
- **Przeglądy** — kwartalny audyt bezpieczeństwa i wydajności.

## Koszty (TCO — Total Cost of Ownership)

Cena CMS to nie tylko licencja. Pełny koszt posiadania:

```
TCO = LICENCJA + HOSTING + WDROŻENIE + UTRZYMANIE + ROZWÓJ

┌────────────────┬──────────────────────────────────────────┐
│ Licencja       │ open-source: 0 zł / SaaS: abonament       │
│ Hosting        │ od kilkudziesięciu zł do tysięcy/mies.    │
│ Wdrożenie      │ jednorazowo: motyw, development, migracja │
│ Utrzymanie     │ aktualizacje, backupy, monitoring         │
│ Rozwój         │ nowe funkcje, pluginy, integracje         │
│ Ukryte         │ szkolenia, support, czas zespołu          │
└────────────────┴──────────────────────────────────────────┘
```

| Scenariusz | Orientacyjny koszt startowy | Miesięcznie |
|------------|----------------------------|-------------|
| Blog WordPress (sam) | ~0-200 zł | ~30-60 zł hosting |
| Strona firmowa (agencja) | ~3 000-15 000 zł | ~100-300 zł |
| Sklep Shopify | ~setup | ~150-1500 zł abonament |
| Sklep WooCommerce | ~5 000-30 000 zł | ~200-800 zł |
| Headless (Sanity+Next) | ~10 000-50 000 zł | ~zależnie od ruchu |
| Enterprise DXP | ~setki tys. zł | ~licencja + zespół |

Open-source bywa droższy w utrzymaniu niż SaaS (więcej pracy własnej); SaaS bywa droższy przy dużej skali (abonament rośnie). Licz **pełny TCO w horyzoncie 3 lat**, nie tylko koszt startowy.

## Częste błędy

```
✗ Wybór CMS „bo popularny", bez analizy potrzeb
✗ Przeładowanie pluginami (wydajność, bezpieczeństwo, konflikty)
✗ Brak środowiska staging — testy na produkcji
✗ Zaniedbane aktualizacje — włamania przez stare pluginy
✗ Brak backupów lub backupy nigdy nietestowane
✗ Migracja bez redirectów 301 — utrata SEO
✗ Modyfikacja rdzenia zamiast użycia hooków — problemy z aktualizacją
✗ Brak myślenia o skali i przyszłej migracji (vendor lock-in)
```

## Podsumowanie

Dobry wybór CMS zaczyna się od **wymagań, nie od mody**: kto edytuje, ile kanałów, jaka skala i budżet. Wdrożenie wymaga środowisk dev/staging/prod, przemyślanej migracji z redirectami i planu bezpieczeństwa. A prawdziwy koszt to TCO w horyzoncie lat — licencja to często najmniejsza jego część.

To kończy kompendium CMS. Wróć do [spisu treści](index.html), by przejść do dowolnego rozdziału.
