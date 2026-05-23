# 05: Integracje sklepu internetowego

## Po co integracje

Sklep rzadko dziala sam. Im wiekszy wolumen, tym wiecej procesow trzeba
zautomatyzowac — reczne przepisywanie zamowien miedzy systemami jest zrodlem
bledow i kosztow. Integracje lacza sklep z marketplace, kurierami, ksiegowoscia
i marketingiem.

## Mapa typowych integracji

| Obszar | Z czym | Co daje |
|--------|--------|---------|
| Marketplace | Allegro, Amazon, eBay, Empik | Dodatkowy kanal sprzedazy |
| Kurierzy | InPost, DPD, brokerzy (Apaczka, Sendit) | Etykiety, sledzenie, zwroty |
| Ksiegowosc | wFirma, Fakturownia, Comarch, Symfonia | Automatyczne faktury, JPK |
| ERP / hurtownia | Subiekt GT/nexo, Comarch ERP | Stany, ceny, dokumenty magazynowe |
| Mailing / marketing | Mailchimp, GetResponse, Klaviyo, edrone | Newsletter, automatyzacje, porzucony koszyk |
| Analityka | Google Analytics 4, Google Tag Manager, Meta Pixel | Pomiar ruchu i konwersji |
| Porownywarki | Ceneo, Google Shopping | Pozyskiwanie ruchu zakupowego |
| Platnosci | P24, PayU, Tpay, Stripe | Przyjmowanie platnosci |
| Integratory | BaseLinker | Spina to wszystko w jednym panelu |

## Allegro — najwazniejszy kanal w PL

Allegro to najwiekszy marketplace w Polsce. Integracja sklepu z Allegro pozwala
zarzadzac sprzedazą wielokanalowa z jednego miejsca.

### Co daje integracja z Allegro

- **Wystawianie ofert** ze sklepu — opis, zdjecia, cena, parametry.
- **Synchronizacja stanow** — sprzedaz na Allegro zmniejsza stan w sklepie i odwrotnie
  (chroni przed sprzedaza niedostepnego towaru).
- **Pobieranie zamowien** z Allegro do panelu sklepu/integratora.
- **Synchronizacja cen** — jedna zmiana ceny w wielu miejscach.
- **Allegro Smart!** — darmowa dostawa dla kupujacych, wplywa na widocznosc oferty.
- **Obsluga wiadomosci i dyskusji** z poziomu jednego panelu.

### Jak technicznie

- Allegro udostepnia **REST API** z autoryzacja OAuth 2.0.
- Wlasna integracja wymaga rejestracji aplikacji w Allegro Developer Portal.
- W praktyce wiekszosc sklepow korzysta z gotowych rozwiazan:
  **BaseLinker**, modul w platformie (Shoper, IdoSell, PrestaShop) lub
  natywna integracja platformy SaaS.
- Allegro liczy terminy wysylki i ocenia sprzedawce — opoznienia obnizaja konto.

### Allegro a sklep wlasny — strategia

| Podejscie | Uwagi |
|-----------|-------|
| Tylko Allegro | Szybki start, brak kosztu sklepu, prowizja Allegro, brak wlasnej marki |
| Tylko sklep | Pelna kontrola i marka, trudniej o ruch |
| Sklep + Allegro | Najczestsze — Allegro dla zasiegu, sklep dla marzy i marki |

## Inne marketplace

| Platforma | Charakterystyka |
|-----------|-----------------|
| Amazon | Sprzedaz zagraniczna, FBA (fulfillment Amazona), wymagajace regulaminy |
| Empik Marketplace | Polski rynek, ksiazki, multimedia, dom |
| Kaufland / eBay | Dodatkowy zasieg, glownie zagranica |
| Erli, Allegro Lokalnie | Mniejsze kanaly krajowe |

## BaseLinker — integrator zamowien

W praktyce polskiego e-commerce **BaseLinker** jest najczestszym "spoiwem":

- Zbiera zamowienia ze sklepu i wszystkich marketplace w jeden panel.
- Synchronizuje stany magazynowe miedzy kanalami.
- Automatyzuje: zmiany statusow, generowanie etykiet, faktury, maile.
- Integruje sie z kurierami, ksiegowoscia, hurtowniami.

To rozwiazanie dla sprzedawcy wielokanalowego — nie zastepuje sklepu, lecz nim zarzadza.

## Integracja ksiegowosci

- Po oplaceniu zamowienia system ksiegowy automatycznie wystawia fakture/paragon.
- Dane sprzedazy trafiaja do JPK i rozliczen VAT.
- Popularne: Fakturownia, wFirma, Comarch Optima, Symfonia, inFakt.
- Przy kasie online/wirtualnej paragon generowany jest elektronicznie.

## Integracja ERP / hurtowni

- Sklepy oparte o magazyn fizyczny czesto spinaja sie z **Subiekt GT/nexo**
  lub **Comarch ERP** — to one sa zrodlem prawdy o stanach i cenach.
- Dropshipping: integracja z hurtownia pobiera jej katalog i stany,
  a zamowienia przekazuje do realizacji.

## Marketing i analityka

| Narzedzie | Rola |
|-----------|------|
| Google Analytics 4 + GTM | Pomiar ruchu, sciezek, konwersji (e-commerce events) |
| Meta Pixel / Conversions API | Remarketing i pomiar reklam Facebook/Instagram |
| Google Merchant Center | Feed produktowy do Google Shopping |
| Ceneo | Feed XML do porownywarki, ruch zakupowy |
| Mailing (edrone, GetResponse, Klaviyo) | Newsletter, porzucony koszyk, automatyzacje |
| Systemy opinii (Trusted Shops, Opineo, Google) | Zbieranie ocen, social proof |

## Zasady dobrej integracji

- **Webhooki zamiast odpytywania** tam, gdzie to mozliwe — szybsza synchronizacja.
- **Idempotentnosc** — to samo zdarzenie moze przyjsc kilka razy.
- **Obsluga bledow i ponawianie** — API zewnetrzne bywaja niedostepne.
- **Logowanie** kazdej wymiany danych — niezbedne przy reklamacjach i audycie.
- **Limity API (rate limits)** — Allegro i inni ograniczaja liczbe zapytan.
- **Jedno zrodlo prawdy** dla stanow magazynowych — inaczej grozą oversells.

## Powiazane materialy

- Synchronizacja stanow i wysylka — rozdzial `04 — Wysylka i logistyka`.
- Platnosci i bramki — rozdzial `03 — Platnosci i realizacja zamowien`.
- API i webhooki — patrz `software/architektura` oraz dokumentacja jezykow.
