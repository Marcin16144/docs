# 06: Wdrozenie, analityka i utrzymanie

## Checklist przed publikacja

| Obszar | Do sprawdzenia |
|--------|----------------|
| Tresc | 5-10 wpisow gotowych, strony O mnie i Kontakt |
| Domena i SSL | Domena podpieta, certyfikat HTTPS aktywny |
| Wyglad | Test na telefonie, tablecie i desktopie |
| Nawigacja | Menu, wyszukiwarka, stopka, linki dzialaja |
| SEO | Tytuly, opisy, sitemap.xml, robots.txt |
| Analityka | GA4 i Search Console podlaczone i zweryfikowane |
| Prawo | Polityka prywatnosci, cookies, zgody RODO |
| Newsletter | Formularz zapisu i powitalna wiadomosc dzialaja |
| Wydajnosc | PageSpeed Insights — wynik akceptowalny |
| Kopia zapasowa | Backup skonfigurowany i przetestowany |

## Hosting i wydajnosc

- **Hosting** — dla WordPressa hosting wspoldzielony lub dedykowany pod WP;
  dla blogow statycznych darmowy Netlify / Vercel / Cloudflare Pages.
- **Cache** — wtyczka cache (np. WP Rocket, LiteSpeed Cache) drastycznie
  przyspiesza WordPressa.
- **CDN** — Cloudflare przyspiesza i chroni; czesto w darmowym planie.
- **Obrazy** — kompresja, format WebP, lazy loading; obrazy to najwiekszy
  "ciezar" wpisu.
- **Wtyczki** — kazda spowalnia; instaluj tylko potrzebne.

## Analityka — co mierzyc

| Metryka | Co mowi | Zrodlo |
|---------|---------|--------|
| Uzytkownicy / sesje | Skala ruchu i jego trend | GA4 |
| Zrodla ruchu | Skad przychodza czytelnicy (Google, social, mail) | GA4 |
| Najpopularniejsze wpisy | Co dziala — gdzie pisac wiecej | GA4 |
| Klikniecia i pozycje w Google | Skutecznosc SEO wpisow | Search Console |
| CTR | Czy tytul i opis zachecaja do klikniecia | Search Console |
| Zapisy do newslettera | Wzrost wlasnej listy odbiorcow | Narzedzie mailowe |

Nie patrz na dane codziennie. Raz w miesiacu wyciagnij wnioski: ktore tematy
dzialaja, ktore wpisy poprawic.

## Aktualizacja tresci

Stare wpisy to ukryty kapital. Tracac aktualnosc, traca pozycje w Google.
Regularny **content refresh** bywa skuteczniejszy niz pisanie nowych wpisow:

- Aktualizuj dane, liczby, zrzuty ekranu, nieaktualne narzedzia.
- Rozbudowuj wpisy, ktore sa blisko TOP 10 w Search Console.
- Napraw lub usun martwe linki.
- Dodawaj linki wewnetrzne do nowszych, powiazanych wpisow.
- Lacz lub usuwaj cienkie, kanibalizujace sie wpisy.

## Rutyna utrzymania

```
Co tydzien   : publikacja wpisu, odpowiedzi na komentarze, dystrybucja
Co miesiac   : przeglad analityki, aktualizacja 1-2 starych wpisow
Co kwartal   : audyt SEO, martwe linki, refresh tresci, backup-test
Na biezaco   : aktualizacje CMS i wtyczek, monitoring bledow
```

## Obowiazki prawne

- **Polityka prywatnosci** — obowiazkowa, gdy zbierasz dane (komentarze,
  newsletter, analityka).
- **RODO** — informacja o przetwarzaniu danych, podstawa prawna, prawa uzytkownika.
- **Cookies** — baner zgody przed zaladowaniem skryptow sledzacych.
- **Newsletter** — zgoda marketingowa, double opt-in, latwa rezygnacja.
- **Tresci sponsorowane i afiliacja** — wyrazne oznaczenie wspolpracy.
- **Prawa autorskie** — uzywaj zdjec z licencja; nie kopiuj cudzych tresci.

To ogolny zarys — przy blogu komercyjnym skonsultuj zapisy z prawnikiem.

## Bezpieczenstwo

- Aktualizuj CMS, motyw i wtyczki — nieaktualne to glowny wektor wlaman.
- Silne hasla i uwierzytelnianie dwuskladnikowe w panelu.
- Regularne, automatyczne kopie zapasowe poza serwerem.
- Wtyczka zabezpieczajaca i ochrona logowania (limit prob).
- Monitoring dostepnosci (uptime) — powiadomienie, gdy blog padnie.

## Kiedy blog uznac za sukces

Blog to projekt dlugoterminowy. Realne efekty SEO przychodza po 6-12 miesiacach
regularnej pracy. Najczestszy powod porazki nie jest techniczny — to porzucenie
projektu, zanim zaczal dzialac. Konsekwencja wygrywa.

## Powiazane materialy

- SEO techniczne i pomiar — rozdzial `04 — SEO bloga`.
- Newsletter i monetyzacja — rozdzial `05 — Monetyzacja i spolecznosc`.
- Wdrozenie i opieka serwisowa stron — patrz `software/website/07-wdrozenie-i-utrzymanie`.
