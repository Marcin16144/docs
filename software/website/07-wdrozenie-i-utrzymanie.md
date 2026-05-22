# 07: Wdrozenie i utrzymanie

## Checklist przed publikacja (pre-launch)

### Tresc i wyglad
- [ ] Brak tekstow zastepczych (lorem ipsum), placeholderow zdjec.
- [ ] Sprawdzona ortografia i interpunkcja.
- [ ] Dane kontaktowe poprawne (telefon, e-mail, adres, NIP).
- [ ] Favicon ustawiony.
- [ ] Strona 404 przygotowana.

### Techniczne
- [ ] Certyfikat SSL dziala, wymuszone HTTPS.
- [ ] Wybrana wersja domeny (z www lub bez) + przekierowanie drugiej.
- [ ] Strona dziala na Chrome, Firefox, Safari, Edge.
- [ ] Responsywnosc sprawdzona na telefonie i tablecie.
- [ ] Formularze wysylaja i docieraja na wlasciwy adres.
- [ ] Linki dzialaja, brak bledow 404.
- [ ] Szybkosc sprawdzona (PageSpeed Insights).
- [ ] Obrazy zoptymalizowane.

### SEO i analityka
- [ ] `title` i `meta description` na kazdej podstronie.
- [ ] `sitemap.xml` + `robots.txt`.
- [ ] Google Search Console — domena dodana i zweryfikowana, sitemap zgloszona.
- [ ] Google Analytics 4 (lub inny) podpiety.
- [ ] Usuniety `noindex` ze srodowiska testowego (czesty blad!).
- [ ] Open Graph (podglad przy udostepnianiu w social media).

### Prawne (Polska / UE)
- [ ] Polityka prywatnosci.
- [ ] Baner zgody na cookies (RODO) — analytics dopiero po zgodzie.
- [ ] Informacja o administratorze danych przy formularzach.
- [ ] Regulamin (jesli sklep / uslugi online).

### Bezpieczenstwo i kopie
- [ ] Kopia zapasowa wykonana.
- [ ] Silne hasla, zmienione domyslne loginy (np. WordPress).
- [ ] CMS, motyw, wtyczki zaktualizowane.

## Wdrozenie (deploy)

- Najpierw na srodowisko testowe (staging) -> akceptacja klienta -> produkcja.
- Przy redesignie istniejacej strony: przygotuj **przekierowania 301** ze starych URL na nowe.
- Po wdrozeniu: ponownie sprawdz SSL, formularze, indeksowalnosc i szybkosc na produkcji.
- Poinformuj Google — zglos sitemap, popros o indeksacje kluczowych podstron.

## Hosting i domena

- Domena i hosting najlepiej na koncie KLIENTA (jego wlasnosc) — przekazujesz dostepy.
- Dobierz hosting do technologii: shared (WordPress, statyczne), VPS/cloud (aplikacje).
- Wazne: kopie zapasowe po stronie hostingu, certyfikat SSL (Let's Encrypt), wsparcie.
- Pilnuj odnowienia domeny — wygasniecie = strona znika.

## Utrzymanie (po wdrozeniu)

Strona to nie projekt jednorazowy. Zaproponuj klientowi umowe serwisowa:
- Regularne aktualizacje CMS / wtyczek / zaleznosci (luki bezpieczenstwa).
- Cykliczne kopie zapasowe i test ich przywracania.
- Monitoring dostepnosci (uptime) i bledow.
- Monitoring wygasania domeny i certyfikatu SSL.
- Drobne zmiany tresci, dodawanie wpisow.
- Przeglad wydajnosci i SEO.

To rownoczesnie powtarzalny przychod i ochrona klienta przed zaniedbana, zhakowana strona.

## Po starcie — analiza i rozwoj

- Obserwuj Search Console (frazy, bledy) i Analytics (ruch, konwersje).
- Zbieraj uwagi uzytkownikow, poprawiaj sciezki konwersji.
- SEO i tresc rozwijaj iteracyjnie — patrz `06 — SEO i pozycjonowanie`.

## Powiazane materialy

- Konfiguracja serwera, IIS, hosting — `software/serwer`, `software/przyklady/iis.html`.
- Linux, certyfikaty, deploy — `software/linux`, `software/docker`.
- Cala sekcja zaczyna sie od `01 — Proces tworzenia strony`.
