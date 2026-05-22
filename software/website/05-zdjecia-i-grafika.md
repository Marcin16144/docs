# 05: Dobor zdjec i grafiki

## Dobre zdjecie na stronie

- Spojne ze soba — jeden styl, podobna tonacja, swiatlo.
- Pasujace do branzy i marki, nie przypadkowe "ladne obrazki".
- Autentyczne — realne zdjecia firmy/zespolu bija sztuczne "stock photo z usmiechem".
- O wysokiej rozdzielczosci, ale zoptymalizowane do wagi.
- Z miejscem na tekst, jesli sluza jako tlo (hero).

## Licencje — to musisz rozumiec

| Pojecie | Znaczenie |
|---------|-----------|
| Royalty-free (RF) | Placisz raz, uzywasz wielokrotnie. NIE znaczy "za darmo" |
| Rights-managed (RM) | Licencja na konkretne uzycie, czas, zasieg |
| Editorial use only | Tylko do celow redakcyjnych — NIE komercyjnych/reklamowych |
| CC0 / Public Domain | Bez praw, dowolne uzycie, takze komercyjne, bez podawania autora |
| CC BY | Wolno uzyc komercyjnie, ale trzeba podac autora |
| CC BY-NC | Zakaz uzycia komercyjnego — NIE uzywaj na stronie firmowej |

Zasada: na strone komercyjna potrzebujesz licencji na uzycie komercyjne. Zawsze zachowaj
dowod licencji (faktura, zrzut warunkow). Wpisz w umowie z klientem, kto kupuje licencje.

## Darmowe banki zdjec — uzycie komercyjne dozwolone

Te serwisy oferuja zdjecia za darmo, takze do projektow komercyjnych, zwykle bez
obowiazku podawania autora (wlasne licencje zblizone do CC0):

- **Unsplash** — unsplash.com — duza baza, wysoka jakosc.
- **Pexels** — pexels.com — zdjecia i video.
- **Pixabay** — pixabay.com — zdjecia, wektory, ilustracje, video.
- **Openverse** — openverse.org — wyszukiwarka tresci CC (sprawdzaj licencje kazdego pliku).
- **StockSnap.io**, **Burst** (Shopify), **Kaboompics**, **Life of Pix**.

Uwagi do darmowych bankow:
- Sprawdzaj licencje przy KAZDYM pliku — bywaja wyjatki.
- Nie wolno: odsprzedawac zdjec jako takich, sugerowac poparcia osob ze zdjecia.
- Wizerunek osob i znaki towarowe / logo na zdjeciu — osobna kwestia (brak zgody = ryzyko).
- Te same zdjecia sa wszedzie — dla marki lepsze wlasne sesje.

## Platne banki zdjec (stock)

Gdy potrzebujesz unikalnosci, szerokiego wyboru lub pewnosci prawnej:

- **Adobe Stock** — stock.adobe.com — integracja z Photoshop/Illustrator, subskrypcja lub pakiety.
- **Shutterstock** — ogromna baza, subskrypcje i pakiety.
- **iStock / Getty Images** — Getty premium, iStock tansza polka.
- **Depositphotos**, **123RF**, **Dreamstime** — tansze alternatywy.
- **EyeEm**, **Stocksy** — bardziej autorskie, mniej "stockowe" kadry.

## Grafika wektorowa, ikony, ilustracje

- Ikony: **Lucide**, **Heroicons**, **Feather**, **Tabler Icons**, **Font Awesome** (czesc darmowa).
- Ilustracje: **unDraw** (darmowe, edytowalny kolor), **Storyset**, **Humaaans**.
- Wektory: **SVG Repo**, sekcje wektorowe Pixabay/Freepik (Freepik — czesto wymaga atrybucji w wersji darmowej, sprawdz).

## Czcionki — pamietaj o licencji

- **Google Fonts** — fonts.google.com — darmowe, komercyjne, najprostszy wybor.
- Czcionki komercyjne (MyFonts, Adobe Fonts) — sprawdz licencje webfont.
- Licencja desktopowa czcionki NIE obejmuje uzycia na stronie (webfont).

## Optymalizacja zdjec — obowiazkowo

Ciezkie zdjecia to wolna strona i gorsze SEO. Zanim wrzucisz:

1. **Format** — uzywaj **WebP** lub **AVIF** zamiast JPG/PNG (mniejsza waga).
2. **Wymiary** — przeskaluj do realnego rozmiaru wyswietlania (nie wrzucaj 6000px do bloku 800px).
3. **Kompresja** — TinyPNG, Squoosh, Photoshop "save for web".
4. **Lazy loading** — `loading="lazy"` dla zdjec ponizej ekranu.
5. **Responsywne obrazy** — `srcset` / `<picture>` dla roznych ekranow.
6. **Atrybut alt** — opis dla SEO i dostepnosci.
7. **Wymiary w HTML** (`width`/`height`) — zapobiega "skakaniu" ukladu (CLS).

## Powiazane materialy

- Wplyw zdjec na szybkosc i SEO — `06 — SEO i pozycjonowanie`.
- Prawa w umowie z klientem — `02 — Rozmowa z klientem`.
