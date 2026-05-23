# 01: Proces tworzenia sklepu internetowego

## Etapy projektu — od pomyslu do sprzedazy

| Etap | Cel | Efekt (deliverable) |
|------|-----|---------------------|
| 1. Brief i model biznesowy | Zrozumiec produkt, marze, grupe docelowa, konkurencje | Notatka, lista wymagan, analiza rynku |
| 2. Wybor platformy | Dobrac silnik sklepu do skali i budzetu | Decyzja technologiczna |
| 3. Architektura katalogu | Kategorie, atrybuty, warianty produktow | Struktura katalogu, drzewo kategorii |
| 4. Projekt UX/UI | Sciezka zakupowa, karta produktu, koszyk, checkout | Makiety, design system |
| 5. Konfiguracja sklepu | Platnosci, wysylka, podatki, regulamin | Dzialajacy sklep testowy |
| 6. Wprowadzenie produktow | Zdjecia, opisy, ceny, stany magazynowe | Pelny katalog |
| 7. Integracje | Allegro, kurierzy, ksiegowosc, mailing | Polaczone systemy zewnetrzne |
| 8. Testy i QA | Test zakupu, platnosci, zwrotow na urzadzeniach | Lista poprawek, akceptacja |
| 9. Wdrozenie | Publikacja, przekierowania, SSL, analityka | Sklep online |
| 10. Utrzymanie i rozwoj | Marketing, optymalizacja konwersji, aktualizacje | Umowa serwisowa, plan rozwoju |

## Sklep to nie strona — to system

Strona wizytowka prezentuje informacje. Sklep dodatkowo: przyjmuje pieniadze,
zarzadza magazynem, generuje dokumenty, wysyla paczki i obsluguje zwroty.
Kazdy z tych obszarow to osobne ryzyko prawne i operacyjne.

```
katalog  ->  koszyk  ->  checkout  ->  platnosc  ->  realizacja  ->  wysylka  ->  obsluga posprzedazowa
```

Najczestszy blad: skupienie na wygladzie sklepu, a zaniedbanie procesow po
zlozeniu zamowienia (magazyn, faktury, zwroty, reklamacje).

## Wybor platformy e-commerce

| Platforma | Kiedy uzyc | Uwagi |
|-----------|-----------|-------|
| Shopify | Szybki start, brak wlasnego zaplecza IT | Abonament + prowizja, ograniczona personalizacja, hosting w cenie |
| WooCommerce (WordPress) | Maly/sredni sklep, znany ekosystem WP | Tanie wejscie, samodzielne utrzymanie i bezpieczenstwo |
| PrestaShop | Sredni sklep, rynek PL, wiele modulow | Open-source, polski ekosystem, koszt modulow |
| Magento / Adobe Commerce | Duzy sklep, zlozony katalog, B2B | Drogie utrzymanie, wymaga zespolu |
| BaseLinker + marketplace | Sprzedaz glownie przez Allegro/Amazon | Nie sklep, lecz integrator zamowien |
| Headless (Next.js + Medusa/commercetools) | Niestandardowy UX, duza skala | Najdrozszy, wymaga zespolu deweloperskiego |
| Platformy SaaS PL (Sky-Shop, Shoper, IdoSell) | Rynek PL, integracje krajowe gotowe | Abonament, mniejsza elastycznosc, szybkie wdrozenie |

Dobieraj do skali sprzedazy, kompetencji zespolu i budzetu na utrzymanie —
nie do ambicji. Migracja platformy pozniej jest kosztowna.

## Modele sprzedazy

- **B2C** — sprzedaz do konsumenta, prawo konsumenckie, 14 dni na zwrot.
- **B2B** — sprzedaz do firm, ceny netto, limity kredytowe, indywidualne cenniki.
- **Dropshipping** — brak wlasnego magazynu, dostawca wysyla do klienta.
- **Marketplace-first** — sklep jako dodatek do sprzedazy na Allegro/Amazon.
- **Subskrypcja** — cykliczne platnosci, dostawy abonamentowe.

## Harmonogram — realistyczne ramy

- Maly sklep na gotowej platformie (do 50 produktow): 2-4 tygodnie
- Sredni sklep z integracjami (kurierzy, Allegro, ksiegowosc): 2-4 miesiace
- Duzy sklep / headless / B2B: 6-12 miesiecy
- Najwiekszy posrednik opoznien: zdjecia i opisy produktow po stronie klienta.

## Powiazane materialy

- Funkcje sklepu — rozdzial `02 — Funkcje sklepu internetowego`.
- Integracje (Allegro, kurierzy) — rozdzial `05 — Integracje`.
- Projektowanie UX i karty produktu — patrz `software/website/03-projektowanie-strony`.
