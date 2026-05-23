# 06: Prawo, RODO i utrzymanie sklepu

## Obowiazki prawne sklepu (rynek PL/UE)

Sklep internetowy sprzedajacy konsumentom podlega prawu konsumenckiemu.
Braki w tym obszarze grozą karami UOKiK i sporami z klientami.

| Dokument / obowiazek | Czego dotyczy |
|----------------------|---------------|
| Regulamin sklepu | Zasady sprzedazy, dostawy, platnosci, reklamacji |
| Polityka prywatnosci | Przetwarzanie danych osobowych (RODO) |
| Polityka cookies | Informacja i zgoda na pliki cookie |
| Dane sprzedawcy | Pelna nazwa, adres, NIP, kontakt — widoczne |
| Informacja o prawie odstapienia | 14 dni na zwrot + wzor formularza |
| Informacja o cenie | Cena calkowita brutto, koszt dostawy przed zakupem |

## Prawo odstapienia (zwrot 14 dni)

- Konsument moze odstapic od umowy w ciagu **14 dni** bez podania przyczyny.
- Sklep musi poinformowac o tym prawie — brak informacji wydluza termin do 12 miesiecy.
- Zwrot platnosci (z kosztem najtanszej dostawy) w 14 dni od otrzymania oswiadczenia.
- Wyjatki: produkty na zamowienie/personalizowane, szybko psujace sie,
  zapieczetowane ze wzgledow higienicznych po otwarciu, tresci cyfrowe.
- Dotyczy B2C; sprzedaz B2B nie ma ustawowego prawa zwrotu.

## Reklamacje (rekojmia / gwarancja)

- **Rekojmia** — odpowiedzialnosc sprzedawcy za wade towaru (ustawowa).
- **Gwarancja** — dobrowolne zobowiazanie producenta/sprzedawcy.
- Sklep musi miec jasna, dostepna procedure reklamacyjna i jej dotrzymywac.

## RODO — ochrona danych osobowych

Sklep przetwarza dane osobowe (imie, adres, e-mail, historia zamowien) i jest
ich administratorem.

| Wymog RODO | Praktyka w sklepie |
|------------|--------------------|
| Podstawa prawna przetwarzania | Realizacja umowy, zgoda, prawnie uzasadniony interes |
| Zgody | Oddzielne checkboxy: newsletter, marketing — nigdy domyslnie zaznaczone |
| Prawo dostepu i usuniecia | Mechanizm wgladu i usuniecia konta/danych |
| Powierzenie przetwarzania | Umowy z kurierem, hostingiem, bramka, mailingiem |
| Rejestr czynnosci przetwarzania | Dokumentacja wewnetrzna |
| Zglaszanie naruszen | Procedura na wypadek wycieku danych (72h do UODO) |
| Minimalizacja danych | Zbieraj tylko to, co potrzebne do realizacji zamowienia |

## Dostepnosc cyfrowa (EAA)

Europejski Akt o Dostepnosci (obowiazuje od 2025 r.) obejmuje takze sklepy
internetowe — interfejs powinien spelniac wytyczne **WCAG** (kontrast,
nawigacja klawiatura, opisy alt, czytelne formularze). Dotyczy to wiekszosci
sklepow komercyjnych powyzej progu mikroprzedsiebiorstwa.

## Checklist przed startem sklepu

- [ ] Regulamin, polityka prywatnosci, polityka cookies — opublikowane
- [ ] Dane firmy (NIP, adres, kontakt) widoczne
- [ ] Certyfikat SSL aktywny, caly sklep na HTTPS
- [ ] Platnosci testowane (udane i nieudane scenariusze)
- [ ] Metody i koszty dostawy skonfigurowane
- [ ] Maile transakcyjne dzialaja (potwierdzenie, wysylka)
- [ ] Stawki VAT i fakturowanie poprawne
- [ ] Formularz zwrotu i procedura reklamacji dostepne
- [ ] Analityka (GA4) i feedy (Ceneo, Google Shopping) podlaczone
- [ ] Kopia zapasowa skonfigurowana
- [ ] Test zakupu od poczatku do konca na urzadzeniu mobilnym
- [ ] Strona 404, regulamin promocji, zgody RODO przy rejestracji

## Wydajnosc i SEO sklepu

- **Szybkosc** — wolny sklep traci konwersje; optymalizuj zdjecia, cache, CDN.
- **SEO** — unikalne opisy produktow (nie kopiuj od producenta), przyjazne URL,
  dane strukturalne Product/Offer/Review, mapa strony, obsluga wyczerpanych produktow.
- **Mobile-first** — wiekszosc zakupow z telefonu.
- Szczegoly SEO — patrz `software/website/06-seo-pozycjonowanie`.

## Utrzymanie i bezpieczenstwo

| Obszar | Dzialanie |
|--------|-----------|
| Aktualizacje | Silnik sklepu, moduly, wtyczki — regularnie, ze wzgledu na luki |
| Kopie zapasowe | Automatyczne, codzienne, testowane odtwarzanie |
| Monitoring | Dostepnosc sklepu, czas odpowiedzi, alarmy |
| Bezpieczenstwo | Silne hasla, 2FA w panelu, ograniczenie dostepu, WAF |
| Logi i audyt | Kto i co zmienil w zamowieniach/cenach |
| Wydajnosc | Monitoring konwersji, szybkosci, porzucen koszyka |

## Rozwoj — optymalizacja konwersji (CRO)

Po starcie sklep sie nie konczy. Cykl rozwoju:

```
mierz (analityka)  ->  znajdz waskie gardlo  ->  hipoteza  ->  test A/B  ->  wdroz lepsze
```

Typowe obszary poprawy: skrocenie checkoutu, lepsze zdjecia, opinie,
szybkosc strony, jasne koszty dostawy, remarketing porzuconych koszykow.

## Powiazane materialy

- SEO i pozycjonowanie — `software/website/06-seo-pozycjonowanie`.
- Wdrozenie, hosting, RODO ogolnie — `software/website/07-wdrozenie-i-utrzymanie`.
- Integracje analityki i mailingu — rozdzial `05 — Integracje`.
