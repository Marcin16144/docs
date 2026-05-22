# 01-01: Podejmowanie decyzji technicznych o duzym zasiegu wplywu

## Czym sa decyzje architektoniczne?

Decyzje architektoniczne to wybory, ktore sa trudne do odwrocenia i wplywaja na caly system lub jego znaczna czesc. Roznia sie od codziennych decyzji programistycznych skala wplywu i kosztem zmiany.

## Przyklady decyzji architektonicznych

| Decyzja | Przyklad | Koszt zmiany |
|---------|----------|-------------|
| Wybor jezyka/platformy | Java vs .NET vs Node.js | Bardzo wysoki |
| Styl architektury | Monolit vs mikroserwisy | Bardzo wysoki |
| Baza danych | SQL vs NoSQL, konkretny silnik | Wysoki |
| Protokol komunikacji | REST vs gRPC vs GraphQL | Sredni-wysoki |
| Strategia deploymentu | Cloud vs on-premise | Wysoki |
| Framework frontendowy | React vs Angular vs Vue | Sredni |

## Proces podejmowania decyzji

### 1. Zidentyfikuj problem
Jasno zdefiniuj, jaki problem rozwiazujesz. Nie wybieraj technologii, zanim nie zrozumiesz wymagania.

```
Zle:  "Uzyjem Kafke, bo jest popularna"
Dobrze: "Potrzebujemy niezawodnego przetwarzania 50k zdarzen/s
         z gwarancja kolejnosci i mozliwoscia replay.
         Kafka spelnia te wymagania."
```

### 2. Zdefiniuj kryteria oceny
Spisz wymagania niefunkcjonalne, ktore decyzja musi spelniac:
- Wydajnosc (latency, throughput)
- Skalowalnosc (ile uzytkownikow, jaki wzrost)
- Koszt (licencje, infrastruktura, zespol)
- Dostepnosc kompetencji w zespole
- Dojrzalosc ekosystemu

### 3. Rozważ alternatywy
Zawsze rozwaz minimum 2-3 opcje. Jedna z nich powinna byc "nie rob nic" lub najprostsze mozliwe rozwiazanie.

### 4. Przeprowadz Proof of Concept (PoC)
Dla decyzji o wysokim ryzyku — przetestuj kluczowe zalozenia na prototypie.

### 5. Udokumentuj w ADR
Zapisz decyzje, kontekst i konsekwencje w Architecture Decision Record.

## Typowe pulapki

### Analysis Paralysis
Zbyt dluga analiza bez podjecia decyzji. Ustaw deadline na decyzje.

### Resume-Driven Development
Wybor technologii dla CV, nie dla projektu.

### Hype-Driven Development
Podazanie za trendami bez oceny czy pasuja do problemu.

### Anchoring Bias
Przywiazanie do pierwszego rozwiazania, ktore przyszlo do glowy.

## Last Responsible Moment

Podejmuj decyzje tak pozno, jak to mozliwe, ale nie pozniej. Im pozniej podejmujesz decyzje, tym wiecej informacji posiadasz. Ale czekanie zbyt dlugo tworzy ryzyko opoznien.

```
Zbyt wczesnie: Wybieramy baze danych w pierwszym dniu projektu
Zbyt pozno:    Wybieramy baze danych tydzen przed produkcja
W sam raz:     Wybieramy baze danych gdy rozumiemy model danych
               i wymagania wydajnosciowe
```

## Odwracalnosc decyzji

Jeff Bezos wyroznia dwa typy decyzji:

- **Type 1 (drzwi jednokierunkowe)** — trudne do odwrocenia. Wymagaja starannej analizy.
  Przyklad: wybor chmury, architektura danych.

- **Type 2 (drzwi dwukierunkowe)** — latwe do odwrocenia. Podejmuj szybko.
  Przyklad: framework testowy, biblioteka do logowania.

Traktuj wiecej decyzji jako Type 2 niz myslisz.
