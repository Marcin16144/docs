# 06: SEO i pozycjonowanie stron

## Czym jest SEO

SEO (Search Engine Optimization) to ogol dzialan, ktore poprawiaja widocznosc strony
w wynikach wyszukiwania (glownie Google). Dzieli sie na: techniczne, on-page (na stronie)
i off-page (poza strona, np. linki).

## SEO techniczne

- **Szybkosc** — Core Web Vitals: LCP < 2.5s, INP < 200ms, CLS < 0.1. Mierz w PageSpeed Insights.
- **Mobile-first** — Google indeksuje wersje mobilna. Strona musi byc responsywna.
- **HTTPS** — certyfikat SSL obowiazkowy.
- **Indeksowalnosc** — poprawny `robots.txt`, brak przypadkowego `noindex`.
- **Mapa strony XML** (`sitemap.xml`) — zglos w Google Search Console.
- **Czyste adresy URL** — `/oferta/strony-www`, nie `/?p=123`.
- **Przekierowania 301** przy redesignie — zachowuja moc starych adresow.
- **Dane strukturalne (Schema.org)** — JSON-LD: LocalBusiness, Product, Article, FAQ, Breadcrumb.
- **Kanoniczne adresy** (`rel=canonical`) — zapobiegaja duplikacji tresci.
- **Brak bledow** — martwe linki, 404, lancuchy przekierowan.

## SEO on-page

### Tytul i opis
```html
<title>Strony internetowe Krakow — projektowanie i wdrozenie | NazwaFirmy</title>
<meta name="description" content="Projektujemy szybkie strony www dla firm. Wycena w 24h. Sprawdz portfolio.">
```
- `title` 50-60 znakow, slowo kluczowe blisko poczatku.
- `description` 140-160 znakow, zachecajacy — wplywa na klikalnosc (CTR).
- Unikalne dla kazdej podstrony.

### Naglowki
- Jeden `<h1>` na strone — glowny temat.
- `h2`, `h3` w logicznej hierarchii, ze slowami kluczowymi naturalnie.

### Tresc
- Pisz dla ludzi, nie dla robota. "Keyword stuffing" szkodzi.
- Odpowiadaj na realne pytania uzytkownikow (intencja wyszukiwania).
- Dluzsze, wartosciowe tresci radza sobie lepiej — ale jakosc > dlugosc.
- Unikalna tresc — kopiowanie z innych stron szkodzi.
- Linkowanie wewnetrzne — lacz powiazane podstrony.

### Obrazy
- `alt` opisowy, nazwy plikow z trescia (`strony-www-krakow.webp`).
- Zoptymalizowana waga — patrz `05 — Dobor zdjec i grafiki`.

## Slowa kluczowe

- Zacznij od intencji: czego szuka klient i jakimi slowami.
- Narzedzia: Google Keyword Planner, Ubersuggest, Senuto, Ahrefs, Semstorm, podpowiedzi Google.
- **Long tail** — dluzsze frazy ("tani fotograf slubny Wroclaw") maja mniejsza konkurencje i wyzsza konwersje.
- Przypisz jedna glowna fraze do jednej podstrony.

## SEO lokalne

Dla firm dzialajacych lokalnie (uslugi, gastronomia, gabinety):
- **Profil Firmy w Google** (dawne Google Moja Firma) — zaloz, uzupelnij, zdjecia, opinie.
- Spojne dane NAP (nazwa, adres, telefon) na stronie i w katalogach.
- Slowa kluczowe z nazwa miasta/dzielnicy.
- Schema `LocalBusiness`.

## SEO off-page

- **Linki przychodzace (backlinki)** — z wartosciowych, tematycznych stron. Jakosc > ilosc.
- Unikaj kupowania linkow masowo / spamu — grozi kara od Google.
- Wpisy w branzowych katalogach, publikacje gosci, PR.

## Narzedzia — obowiazkowy zestaw

| Narzedzie | Do czego |
|-----------|----------|
| Google Search Console | Indeksowanie, frazy, bledy, sitemap |
| Google Analytics 4 | Ruch, zachowanie, konwersje |
| PageSpeed Insights / Lighthouse | Wydajnosc, Core Web Vitals |
| Google Keyword Planner | Slowa kluczowe |
| Ahrefs / Semrush / Senuto | Audyt, konkurencja, frazy (platne) |
| Screaming Frog | Audyt techniczny (crawl) |

## Czego NIE robic (Black Hat)

- Ukryty tekst, cloaking (inna tresc dla Google niz dla ludzi).
- Upychanie slow kluczowych.
- Kupowanie spamowych linkow.
- Kopiowana / generowana masowo bezwartosciowa tresc.
Google karze takie praktyki — ryzykujesz spadek lub usuniecie z wynikow.

## SEO to proces

Efekty pozycjonowania pojawiaja sie po tygodniach/miesiacach. Wytlumacz to klientowi —
strona po wdrozeniu nie jest "od razu pierwsza w Google". To ciagla praca, nie jednorazowa.

## Powiazane materialy

- Wydajnosc i optymalizacja obrazow — `05 — Dobor zdjec i grafiki`.
- Checklist przed startem (sitemap, SSL, analytics) — `07 — Wdrozenie i utrzymanie`.
