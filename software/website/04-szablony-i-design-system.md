# 04: Szablony i design system

## Po co szablon (template)

Szablon to powtarzalny uklad, ktory raz zaprojektowany, sluzy wielu stronom i projektom.
Korzysci: szybszy projekt, spojnosc, latwiejsze utrzymanie, mniej decyzji ad hoc.

## Anatomia szablonu strony

| Element | Zawartosc |
|---------|-----------|
| Header | Logo, menu, ewentualnie CTA / kontakt / przelacznik jezyka |
| Hero | Glowny komunikat, podtytul, CTA, grafika/tlo |
| Sekcje tresci | Bloki: o nas, oferta, realizacje, opinie, FAQ |
| Dowod spoleczny | Opinie, logotypy klientow, liczby, certyfikaty |
| Call to action | Sekcja zachecajaca do kontaktu/zakupu |
| Footer | Kontakt, mapa strony, social media, nota prawna, RODO |

## Podejscie modulowe (bloki)

Projektuj strone z **klockow**, nie jako jeden monolit:
- Kazda sekcja to samodzielny, powtarzalny blok (hero, galeria, cennik, kontakt).
- Klient (lub Ty) buduje podstrony, ukladajac bloki w roznej kolejnosci.
- To podejscie stosuja kreatory i WordPress (Gutenberg, Elementor) — i warto je nasladowac.

## Design system / design tokens

Design system to zbior wielokrotnie uzywanych zasad i komponentow. Podstawa to **tokeny** —
nazwane wartosci zamiast "magicznych liczb" rozsianych po kodzie:

```css
:root {
  /* kolory */
  --color-primary: #2563eb;
  --color-accent:  #f97316;
  --color-text:    #1e293b;
  --color-bg:      #ffffff;

  /* typografia */
  --font-sans: 'Inter', system-ui, sans-serif;
  --text-base: 1rem;
  --text-lg:   1.25rem;
  --text-xl:   1.5rem;

  /* odstepy — skala */
  --space-1: 0.5rem;
  --space-2: 1rem;
  --space-3: 1.5rem;
  --space-4: 2rem;

  /* inne */
  --radius:  0.5rem;
  --shadow:  0 4px 12px rgba(0,0,0,.08);
}
```

Zmiana jednej wartosci aktualizuje cala strone. To samo robia frameworki (Tailwind config).

## Komponenty wielokrotnego uzytku

Zdefiniuj raz, uzywaj wszedzie: przycisk, karta, formularz, naglowek sekcji, stopka.
Kazdy komponent ma stany: domyslny, hover, focus, active, disabled.

## System siatki i odstepow

- Trzymaj sie jednej skali odstepow (np. wielokrotnosci 4 lub 8 px).
- Jedna siatka (12 kolumn) dla calego projektu.
- Spojne promienie zaokraglen i cienie.

## Tworzenie wlasnej biblioteki szablonow

Praktyka dla osoby robiacej wiele stron:
1. Wybierz stack (np. Astro + komponenty, albo motyw startowy WordPress).
2. Zbuduj bazowy szablon: header, footer, typografia, tokeny, 8-10 blokow.
3. Kazdy nowy projekt = kopia bazy + podmiana tokenow (kolory, czcionki, logo).
4. Poprawki i nowe bloki cofaj do bazy — biblioteka rosnie z kazdym projektem.

## Gotowe szablony — kupowac czy nie

| Zrodlo | Uwagi |
|--------|-------|
| ThemeForest, TemplateMonster | Tysiace motywow WordPress/HTML, plat. jednorazowa. Sprawdz aktualizacje i opinie |
| Motywy oficjalne (Astro, Next themes) | Czesto darmowe, czysty kod |
| Tailwind UI, Flowbite, Webflow templates | Komponenty/szablony, czesc platna |
| Wlasny szablon | Najwiecej kontroli, najlepiej dlugofalowo |

Uwaga: kupiony motyw to szybki start, ale czesto "przerost" funkcji, wolniejszy i trudniejszy
do utrzymania. Zawsze sprawdz licencje (uzycie komercyjne, dla wielu klientow).

## Powiazane materialy

- Zasady projektowania (kolory, typografia) — `03 — Projektowanie strony`.
- React/komponenty — `software/reactjs`. CSS — `software/www`.
- Builder stron w PHP — `software/przyklady/php-website-builder.html`.
