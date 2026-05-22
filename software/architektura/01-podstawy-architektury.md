# Podstawy architektury oprogramowania

## Czym jest architektura oprogramowania?

Architektura oprogramowania to zbiór fundamentalnych decyzji dotyczących struktury systemu — jak dzielony jest na komponenty, jak te komponenty się komunikują i jakie zasady rządzą ich projektowaniem oraz ewolucją w czasie.

## Rola architekta

- Podejmowanie decyzji technicznych o dużym zasięgu wpływu
- Balansowanie między wymaganiami funkcjonalnymi a niefunkcjonalnymi
- Komunikacja wizji technicznej zespołowi
- Ocena kompromisów (trade-offs) przy każdej decyzji
- Zarządzanie ryzykiem technicznym

## Kluczowe atrybuty jakościowe (Quality Attributes)

| Atrybut | Opis |
|---------|------|
| **Wydajność (Performance)** | Czas odpowiedzi, przepustowość, wykorzystanie zasobów |
| **Skalowalność (Scalability)** | Zdolność do obsługi rosnącego obciążenia |
| **Dostępność (Availability)** | Procent czasu, w którym system jest sprawny (np. 99.9%) |
| **Niezawodność (Reliability)** | Odporność na błędy, spójność działania |
| **Bezpieczeństwo (Security)** | Ochrona danych, autoryzacja, uwierzytelnianie |
| **Modyfikowalność (Modifiability)** | Łatwość wprowadzania zmian |
| **Testowalność (Testability)** | Łatwość weryfikacji poprawności |
| **Obserwowalność (Observability)** | Zdolność monitorowania stanu systemu |
| **Odporność (Resilience)** | Zdolność do degradacji zamiast całkowitej awarii |

## Zasada kompromisu (Trade-off)

Nie da się zoptymalizować wszystkich atrybutów jednocześnie. Każda decyzja architektoniczna to kompromis:

- Większa wydajność może oznaczać mniejszą modyfikowalność
- Wyższe bezpieczeństwo może obniżyć wygodę użytkowania
- Lepsza skalowalność może zwiększyć złożoność systemu

Dokumentuj decyzje i ich uzasadnienia za pomocą **Architecture Decision Records (ADR)**.

## Architecture Decision Record (ADR)

Prosty szablon:

```
# ADR-001: Wybór bazy danych

## Status: Zaakceptowany

## Kontekst
Potrzebujemy bazy danych dla modułu zamówień obsługującego 10k operacji/s.

## Decyzja
Wybieramy PostgreSQL z partycjonowaniem tabel.

## Konsekwencje
+ Dojrzały ekosystem, wsparcie społeczności
+ Obsługa ACID
- Wymaga zarządzania partycjami
- Skalowalność horyzontalna trudniejsza niż w NoSQL
```
