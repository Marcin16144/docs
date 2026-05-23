# 02: Architektura i struktura bloga

## Mapa strony — typowa struktura

```
/                      strona glowna (lista najnowszych wpisow)
/blog/ lub /artykuly/  archiwum wszystkich wpisow z paginacja
/kategoria/{nazwa}/    wpisy z jednej kategorii
/tag/{nazwa}/          wpisy z jednym tagiem
/{slug-wpisu}/         pojedynczy wpis (post)
/o-mnie/               strona autora / o blogu
/kontakt/              formularz kontaktowy
/polityka-prywatnosci/ wymagana prawnie
/newsletter/           zapis do listy mailowej
/wyszukiwarka          wyniki wyszukiwania
```

Adresy URL powinny byc **krotkie, czytelne i bez dat** (data w URL postarza
wpis). Slug oparty na slowie kluczowym, np. `/jak-zalozyc-blog/`.

## Typy stron — co kazda zawiera

| Strona | Rola | Kluczowe elementy |
|--------|------|-------------------|
| Strona glowna | Pierwsze wrazenie, kierowanie ruchu | Najnowsze i wyrozn. wpisy, opis bloga, CTA newsletter |
| Archiwum / lista wpisow | Przeglad calej tresci | Karty wpisow, paginacja, filtr kategorii |
| Strona wpisu | Wlasciwa tresc — serce bloga | Patrz: anatomia wpisu ponizej |
| Strona kategorii | Grupowanie tematyczne, SEO | Opis kategorii, lista wpisow |
| O mnie / O blogu | Zaufanie, autorytet (EEAT) | Kim jestes, doswiadczenie, zdjecie, kontakt |
| Kontakt | Mozliwosc kontaktu | Formularz, e-mail, social media |
| Strony prawne | Wymog prawny | Polityka prywatnosci, cookies, regulamin |

## Anatomia wpisu — element po elemencie

1. **Tytul (H1)** — jeden na strone, zawiera slowo kluczowe.
2. **Metadane** — autor, data publikacji, czas czytania, kategoria.
3. **Obraz wyrozniajacy** — miniatura na listach i w social media.
4. **Lead / wstep** — 2-3 zdania, ktore zatrzymuja czytelnika.
5. **Spis tresci** — przy dluzszych wpisach, ulatwia nawigacje.
6. **Tresc** — naglowki H2/H3, krotkie akapity, listy, grafiki.
7. **Call to action** — newsletter, powiazany wpis lub produkt.
8. **Bio autora** — krotka notka budujaca autorytet.
9. **Powiazane wpisy** — linkowanie wewnetrzne, zatrzymanie ruchu.
10. **Komentarze / udostepnianie** — interakcja i dystrybucja.

## Kategorie kontra tagi

| | Kategorie | Tagi |
|--|-----------|------|
| Rola | Glowne dzialy bloga (jak rozdzialy) | Szczegolowe tematy przekrojowe |
| Liczba | Malo — 5-8 na caly blog | Wiecej, ale z umiarem |
| Hierarchia | Moga miec podkategorie | Plaskie, bez hierarchii |
| Przyklad | "SEO", "Copywriting" | "Google Analytics", "ChatGPT" |

Najczestszy blad: dziesiatki tagow uzytych raz. Tworza cienkie, bezwartosciowe
strony archiwum. Kazda kategoria i tag powinny grupowac co najmniej kilka wpisow.

## Model tresci — filary i klastry

Skuteczna architektura SEO opiera sie na **pillar & cluster**: jeden obszerny
wpis filarowy (szeroki temat) linkuje do wpisow szczegolowych (klastry),
a te linkuja z powrotem do filaru.

```
FILAR: "Jak zalozyc blog" (kompletny przewodnik)
  +-- klaster: "Wybor platformy blogowej"
  +-- klaster: "Jak wybrac nazwe i domene"
  +-- klaster: "Pierwsze 10 wpisow — pomysly"
```

Taki uklad buduje autorytet tematyczny i ulatwia Google zrozumienie, ze blog
jest ekspertem w danej dziedzinie.

## Nawigacja i elementy globalne

- **Menu glowne** — kategorie, O mnie, Kontakt; krotkie i stabilne.
- **Wyszukiwarka** — obowiazkowa przy >30 wpisach.
- **Sidebar** (opcjonalny) — popularne wpisy, zapis newsletter, kategorie.
- **Stopka** — strony prawne, social media, mapa strony.
- **Okruszki (breadcrumbs)** — orientacja i dane strukturalne dla SEO.

## Responsywnosc i czytelnosc

- Ponad polowa ruchu na blogu pochodzi z telefonow — projektuj mobile-first.
- Szerokosc kolumny tekstu 60-75 znakow w wierszu.
- Rozmiar fontu tresci min. 16-18 px, wysoki kontrast.
- Wyrazne odstepy miedzy akapitami — "sciana tekstu" odstrasza.

## Powiazane materialy

- Struktura artykulu i jakosc tresci — rozdzial `03 — Tworzenie tresci`.
- Linkowanie wewnetrzne i SEO on-page — rozdzial `04 — SEO bloga`.
- Projektowanie UX, typografia, RWD — patrz `software/website/03-projektowanie-strony`.
