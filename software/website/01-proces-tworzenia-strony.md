# 01: Proces tworzenia strony internetowej

## Etapy projektu — od pomyslu do wdrozenia

| Etap | Cel | Efekt (deliverable) |
|------|-----|---------------------|
| 1. Brief i odkrywanie | Zrozumiec klienta, cel biznesowy, grupe docelowa | Notatka z briefu, lista wymagan |
| 2. Wycena i umowa | Ustalic zakres, cene, termin | Oferta, umowa, harmonogram |
| 3. Architektura informacji | Zaplanowac strukture stron i tresci | Mapa strony (sitemap), lista podstron |
| 4. Projekt UX (wireframe) | Rozmieszczenie elementow bez grafiki | Szkielety stron (lo-fi / hi-fi) |
| 5. Projekt UI (design) | Warstwa wizualna — kolory, typografia, grafika | Makiety w Figmie, design system |
| 6. Tresci i zdjecia | Teksty, zdjecia, ikony, video | Komplet materialow |
| 7. Implementacja | Kodowanie / budowa w CMS | Dzialajaca strona na srodowisku testowym |
| 8. Testy i QA | Sprawdzenie na urzadzeniach, przegladarkach | Lista poprawek, akceptacja |
| 9. Wdrozenie (deploy) | Publikacja na docelowej domenie | Strona online |
| 10. Utrzymanie | Aktualizacje, kopie zapasowe, monitoring | Umowa serwisowa |

## Zasada: nie zaczynaj od kodu

Najczestszy blad poczatkujacych — otwarcie edytora kodu w pierwszej godzinie projektu.
Kod jest najdrozszy w zmianie. Kolejnosc kosztu zmiany rosnie tak:

```
rozmowa  <  szkic na kartce  <  wireframe  <  makieta Figma  <  kod  <  strona produkcyjna
```

Im wczesniej wykryjesz nieporozumienie z klientem, tym taniej je naprawisz.

## Wybor technologii

| Rozwiazanie | Kiedy uzyc | Uwagi |
|-------------|-----------|-------|
| WordPress | Strony firmowe, blogi, klient chce sam edytowac | Najwiekszy ekosystem, wymaga aktualizacji i zabezpieczen |
| Kreator (Webflow, Wix, Squarespace) | Male strony, szybki termin, budzet ograniczony | Mniej elastyczne, abonament, vendor lock-in |
| Statyczny generator (Astro, Hugo, 11ty) | Strony wizytowki, landing page, blog | Szybkie, tanie w hostingu, bezpieczne |
| Framework JS (Next.js, Nuxt) | Aplikacje, sklepy, dynamiczne tresci | Wiekszy koszt, wymaga utrzymania serwera |
| Sklep (Shopify, WooCommerce, PrestaShop) | E-commerce | Osobny temat — platnosci, magazyn, RODO |

Dobieraj technologie do kompetencji klienta (czy bedzie sam edytowal?) i do budzetu na utrzymanie.

## Harmonogram — realistyczne ramy

- Landing page (1 sekcja): 3-7 dni roboczych
- Strona firmowa (5-8 podstron): 3-6 tygodni
- Sklep internetowy: 2-4 miesiace
- Zawsze dodaj bufor — opoznienia po stronie klienta (tresci, zdjecia, akceptacje) sa regula, nie wyjatkiem.

## Powiazane materialy

- Architektura informacji i UX — patrz rozdzial `03 — Projektowanie strony`.
- Wybor hostingu i wdrozenie — patrz `software/serwer` oraz `software/lang/php/07-website-builder-shared-hosting.html`.
- Frontend (HTML/CSS/JS) — patrz `software/www` i `software/js`.
