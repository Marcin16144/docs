# 04: Wysylka i logistyka

## Metody dostawy na rynku polskim

| Metoda | Charakterystyka |
|--------|-----------------|
| Paczkomaty InPost | Najpopularniejsza w PL, odbior 24/7, wysoka konwersja |
| Kurier (InPost, DPD, DHL, GLS, UPS, Pocztex) | Dostawa pod adres, takze za pobraniem |
| Punkty odbioru (PUDO) | Odbior w sklepie/kiosku, tanszy niz kurier |
| Odbior osobisty | Klient odbiera w sklepie stacjonarnym |
| Dostawa wlasna | Lokalna dostawa wlasnym transportem |
| Przesylka zagraniczna | Wyzszy koszt, czas, ewentualne clo poza UE |

Paczkomaty to de facto standard w Polsce — brak tej opcji obniza konwersje.

## Integracja z kurierami (broker przesylkowy)

Zamiast laczyc sklep z kazdym kurierem osobno, uzywa sie brokera:

| Broker | Uwagi |
|--------|-------|
| Apaczka | Agregator wielu kurierow, jeden panel |
| Sendit | Popularny broker, konkurencyjne ceny |
| Furgonetka | Porownywarka i nadawanie przesylek |
| BaseLinker | Integrator zamowien + nadawanie etykiet |
| API InPost ShipX | Bezposrednia integracja z InPost |

Broker daje: jedna integracje, negocjowane ceny, generowanie etykiet,
sledzenie paczek, obsluge zwrotow.

## Proces realizacji wysylki

```
zamowienie oplacone  ->  kompletacja  ->  pakowanie  ->  etykieta i list przewozowy
  ->  przekazanie kurierowi  ->  numer sledzenia do klienta  ->  doreczenie
```

- Numer sledzenia powinien trafic do klienta automatycznie mailem/SMS.
- Status "wyslane" warto synchronizowac z marketplace (Allegro liczy terminy).
- Etykiety generuj hurtowo — przy wiekszym wolumenie reczne jest waskim gardlem.

## Koszt dostawy — strategia

| Model | Efekt |
|-------|-------|
| Darmowa dostawa od kwoty X | Podnosi srednia wartosc koszyka |
| Stala oplata | Prosta, przewidywalna dla klienta |
| Koszt wg wagi/gabarytu | Sprawiedliwy przy roznych produktach |
| Darmowa dostawa zawsze | Koszt wliczony w cene produktu |
| Pobranie z doplata | Pokrywa wyzsze ryzyko niedoreczenia |

Ukryty wysoki koszt dostawy na ostatnim kroku to glowna przyczyna porzucen koszyka.

## Magazyn i stany

- **Rezerwacja stanu** — przy zlozeniu zamowienia, by nie sprzedac tego samego
  produktu dwa razy (szczegolnie wazne przy sprzedazy wielokanalowej).
- **Synchronizacja stanow** miedzy sklepem a Allegro/Amazon — w czasie zbliżonym
  do rzeczywistego, inaczej grozą oversells i kary marketplace.
- **Progi alarmowe** — powiadomienie o niskim stanie, automatyczne zamowienie u dostawcy.
- **WMS** (Warehouse Management System) — przy duzym magazynie: lokalizacje,
  skanery, optymalizacja kompletacji.

## Fulfillment i dropshipping

| Model | Opis |
|-------|------|
| Magazyn wlasny | Pelna kontrola, koszt powierzchni i obslugi |
| Fulfillment 3PL | Zewnetrzny operator magazynuje i wysyla (np. Amazon FBA, Omnipack) |
| Dropshipping | Dostawca wysyla bezposrednio do klienta, sklep nie trzyma towaru |

Dropshipping obniza barier wejscia, ale oddaje kontrole nad jakoscia,
czasem wysylki i obsluga zwrotow — to ryzyko reputacyjne.

## Zwroty (logistyka odwrotna)

- Konsument ma 14 dni na odstapienie od umowy (szczegoly w rozdziale `06`).
- Ulatwij zwrot: formularz online, gotowa etykieta zwrotna, integracja z brokerem.
- Po przyjeciu zwrotu: kontrola towaru, przyjecie na magazyn, zwrot platnosci.
- Wysoki odsetek zwrotow (np. odziez) trzeba wkalkulowac w marze.

## Powiazane materialy

- Statusy zamowien — rozdzial `03 — Platnosci i realizacja zamowien`.
- Synchronizacja z marketplace — rozdzial `05 — Integracje`.
- Prawo zwrotow konsumenckich — rozdzial `06 — Prawo, RODO i utrzymanie`.
