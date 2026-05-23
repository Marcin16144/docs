# 03: Platnosci i realizacja zamowien

## Metody platnosci na rynku polskim

| Metoda | Charakterystyka | Uwagi |
|--------|-----------------|-------|
| BLIK | Dominujaca w PL, kod z aplikacji bankowej | Szybka, wysoka konwersja, must-have |
| Szybki przelew (pay-by-link) | Przekierowanie do banku | Standard, obsluga przez bramke |
| Karta platnicza | Visa / Mastercard | Wymaga 3D Secure, czesta przy zagranicy |
| Platnosc odroczona | PayPo, Twisto — "kup teraz, zaplac pozniej" | Podnosi konwersje, prowizja wyzsza |
| Pobranie (COD) | Platnosc kurierowi przy odbiorze | Wysoki odsetek niedoreczen, dodatkowy koszt |
| Przelew tradycyjny | Reczny przelew na konto | Tani, ale wydluza realizacje |
| Portfele (Apple Pay, Google Pay, PayPal) | Platnosc jednym kliknieciem | Wygodne na mobile |

## Bramki platnicze (operatorzy)

| Bramka | Uwagi |
|--------|-------|
| Przelewy24 (P24) | Popularna w PL, szeroki wybor metod |
| PayU | Duzy gracz, integracja z Allegro, raty |
| Tpay | Polska bramka, prosta integracja |
| Autopay (dawniej BlueMedia) | Obsluguje m.in. platnosci masowe |
| Stripe | Globalny, swietne API, slabiej z lokalnymi metodami PL |
| PayPal | Rozpoznawalny, wygodny przy sprzedazy zagranicznej |

Bramka pobiera prowizje (zwykle ok. 1-2% + oplata stala). Rozliczenie srodkow
trafia na konto sklepu z opoznieniem (T+1 do T+7 zaleznie od umowy).

## Integracja platnosci — jak to dziala

```
klient placi  ->  bramka przetwarza  ->  webhook do sklepu  ->  zmiana statusu zamowienia
```

Zasady bezpiecznej integracji:

- Status zamowienia zmieniaj **dopiero po webhooku** od bramki, nie po powrocie
  klienta na strone (klient moze zamknac karte przed potwierdzeniem).
- Weryfikuj podpis/hash powiadomienia — chroni przed podrobionym webhookiem.
- Obsluz idempotentnosc — webhook moze przyjsc kilka razy.
- Loguj kazda transakcje; uzgadniaj raporty bramki z zamowieniami.
- Nigdy nie przechowuj danych kart — to robi bramka (zgodnosc PCI DSS).

## Cykl zycia zamowienia (statusy)

| Status | Znaczenie |
|--------|-----------|
| Nowe / oczekuje na platnosc | Zlozono, brak wplaty |
| Oplacone | Platnosc potwierdzona webhookiem |
| W realizacji | Kompletowanie na magazynie |
| Wyslane | Paczka przekazana kurierowi, numer sledzenia |
| Dostarczone | Potwierdzenie doreczenia |
| Anulowane | Brak platnosci / rezygnacja klienta |
| Zwrot / reklamacja | Procedura posprzedazowa |

Kazda zmiana statusu zwykle wyzwala mail do klienta i aktualizacje magazynu.

## Podatki i dokumenty

- **VAT** — sklep nalicza wlasciwa stawke; przy sprzedazy do UE obowiazuje
  procedura VAT OSS po przekroczeniu progu.
- **Paragon / faktura** — sprzedaz do konsumenta wymaga paragonu (kasa fiskalna
  lub kasa online/wirtualna); faktura na zadanie lub dla firm.
- **Faktura automatyczna** — integracja z systemem ksiegowym generuje dokument
  po oplaceniu (patrz rozdzial `05 — Integracje`).
- **JPK** — dane sprzedazowe trafiaja do jednolitego pliku kontrolnego.

## Bezpieczenstwo platnosci

- Certyfikat SSL/TLS na calym sklepie (HTTPS) — obowiazkowo.
- Zgodnosc PCI DSS realizowana przez bramke — sklep nie dotyka danych kart.
- Silne uwierzytelnienie (SCA / 3D Secure 2) wymagane przez PSD2.
- Ochrona przed fraudem: limity, weryfikacja adresu, monitoring nietypowych zamowien.

## Powiazane materialy

- Funkcje checkoutu — rozdzial `02 — Funkcje sklepu internetowego`.
- Integracja ksiegowosci i fakturowania — rozdzial `05 — Integracje`.
- Prawo konsumenckie i zwroty — rozdzial `06 — Prawo, RODO i utrzymanie`.
