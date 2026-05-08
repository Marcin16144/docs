# 01-03: Komunikacja wizji technicznej

## Dlaczego komunikacja wizji jest kluczowa?

Nawet najlepsza architektura jest bezwartościowa, jeśli nikt jej nie rozumie. Architekt oprogramowania spędza znaczną część czasu nie na projektowaniu, ale na **komunikowaniu** decyzji, wizji i kierunku technicznego. Brak skutecznej komunikacji prowadzi do:

- Niespójnych implementacji — zespoły interpretują architekturę po swojemu
- Oporu wobec zmian — ludzie nie rozumieją "dlaczego"
- Duplikowania pracy — brak wiedzy o istniejących rozwiązaniach
- Błędnych decyzji — brak kontekstu architektonicznego

## Diagramy architektoniczne

### Model C4 (Simon Brown)

Czterowarstwowy model dokumentacji wizualnej:

```
Poziom 1: System Context
  → Jak system wchodzi w interakcje z użytkownikami i innymi systemami
  → Dla: wszyscy (biznes, dev, ops)

Poziom 2: Container
  → Główne kontenery (aplikacje, bazy danych, kolejki)
  → Dla: deweloperzy, architekci

Poziom 3: Component
  → Komponenty wewnątrz kontenera
  → Dla: deweloperzy pracujący nad danym kontenerem

Poziom 4: Code
  → Diagramy klas/interfejsów
  → Dla: deweloperzy implementujący konkretny komponent
```

### Kiedy używać UML?

UML pozostaje użyteczny w specyficznych kontekstach:

| Diagram | Zastosowanie | Kiedy używać |
|---------|-------------|--------------|
| Sekwencji | Przepływ komunikacji | Złożone interakcje między serwisami |
| Komponentów | Struktura systemu | Przegląd modułów i zależności |
| Wdrożeniowy | Infrastruktura | Planowanie deploymentu |
| Stanów | Maszyna stanów | Złożone cykle życia obiektów |
| Aktywności | Procesy biznesowe | Workflow i orkiestracja |

### Zasady dobrych diagramów

1. **Jeden diagram = jeden cel** — nie upychaj wszystkiego na jednym obrazku
2. **Legenda jest obowiązkowa** — nie zakładaj, że czytelnik zna notację
3. **Poziom szczegółowości dopasuj do odbiorcy** — CTO nie potrzebuje diagramu klas
4. **Aktualizuj albo usuwaj** — nieaktualny diagram jest gorszy niż brak diagramu

## Architecture Decision Records (ADR)

ADR to lekki dokument opisujący jedną decyzję architektoniczną.

### Format ADR

```markdown
# ADR-007: Wybór brokera komunikatów

## Status
Zaakceptowany (2024-03-15)

## Kontekst
System wymaga asynchronicznej komunikacji między 12 mikroserwisami.
Obecne rozwiązanie (HTTP sync) powoduje cascade failures.
Wymagana przepustowość: 50 000 msg/s z gwarancją dostarczenia.

## Decyzja
Wybieramy Apache Kafka jako główny broker komunikatów.

## Uzasadnienie
- Kafka obsługuje > 100k msg/s na partycję
- Wbudowana replikacja i trwałość komunikatów
- Zespół ma doświadczenie z Kafka (3 osoby certyfikowane)
- Ecosystem (Kafka Streams, Connect) pokrywa nasze potrzeby

## Alternatywy rozważane
- RabbitMQ — niewystarczająca przepustowość przy naszej skali
- AWS SQS — vendor lock-in, brak ordering guarantee
- Apache Pulsar — mniejsza społeczność, brak doświadczenia w zespole

## Konsekwencje
- Potrzebna infrastruktura Kafka (min. 3 brokery)
- Krzywa uczenia dla 7 osób w zespole
- Dodatkowy koszt operacyjny (~$500/mies. na klaster)
- Zysk: eliminacja cascade failures, lepsza odporność
```

### Zarządzanie ADR-ami

- Przechowuj w repozytorium kodu (np. `/docs/adr/`)
- Nigdy nie usuwaj — zmień status na "Zastąpiony" z linkiem do nowego ADR
- Numeruj sekwencyjnie
- Używaj narzędzi: `adr-tools`, `log4brains`

## Tech Radar

Tech Radar to wizualne narzędzie do komunikowania strategii technologicznej organizacji.

### Pierścienie (Rings)

```
ADOPT    — Używaj w nowych projektach. Sprawdzone i rekomendowane.
TRIAL    — Wypróbuj w ograniczonym zakresie. Obiecujące, ale wymaga walidacji.
ASSESS   — Zbadaj. Warto śledzić, ale za wcześnie na projekty produkcyjne.
HOLD     — Nie zaczynaj nowych projektów z tą technologią. Migruj istniejące.
```

### Kategorie (Quadrants)

1. **Języki i frameworki** — TypeScript, React, Spring Boot
2. **Narzędzia** — Docker, Terraform, GitHub Actions
3. **Platformy** — AWS, Kubernetes, Confluent
4. **Techniki** — Event Sourcing, TDD, Feature Flags

### Przykład wpisu

```
Technologia:  React Server Components
Pierścień:    TRIAL
Data:         2024-Q2
Uzasadnienie: Znaczące korzyści dla wydajności SSR.
              Testujemy w projekcie X.
              Wyniki do przeglądu w Q3.
```

## Proces RFC (Request for Comments)

RFC to formalny sposób proponowania i dyskutowania zmian technicznych.

### Struktura RFC

```
Tytuł:        RFC-042: Migracja z REST na gRPC dla komunikacji wewnętrznej
Autor:        Jan Kowalski
Data:         2024-04-01
Status:       W dyskusji (deadline: 2024-04-15)

## Problem
Komunikacja REST między serwisami generuje 30% overhead
na serializację JSON i brakuje contract enforcement.

## Proponowane rozwiązanie
Migracja komunikacji inter-service na gRPC z Protocol Buffers.

## Plan migracji
Faza 1: Nowe serwisy od razu na gRPC (Q2)
Faza 2: Dual-stack dla istniejących serwisów (Q3)
Faza 3: Pełna migracja, wyłączenie REST wewnętrznego (Q4)

## Metryki sukcesu
- Redukcja latencji inter-service o 40%
- 100% contract coverage (proto files)

## Otwarte pytania
1. Jak obsłużyć streaming w serwisie X?
2. Czy potrzebujemy gRPC-Web dla frontendu?
```

### Zasady procesu RFC

- Każdy w zespole może złożyć RFC
- Ustal deadline na komentarze (zazwyczaj 1-2 tygodnie)
- Wymagaj minimum 2 recenzentów
- Decyzja: zaakceptowany, odrzucony, odłożony
- Archiwizuj wszystkie RFC (nawet odrzucone — to cenna wiedza)

## Architecture Reviews

### Rodzaje przeglądów

| Typ | Częstotliwość | Cel |
|-----|---------------|-----|
| Lightweight ADR Review | Przy każdym ADR | Walidacja pojedynczej decyzji |
| Design Review | Przed implementacją | Weryfikacja projektu technicznego |
| Architecture Review | Kwartalnie | Przegląd zgodności z wizją |
| Fitness Function Review | Co sprint | Analiza metryk architektonicznych |

### Format przeglądu architektonicznego

```
1. Prezentacja kontekstu (10 min)
   — Problem biznesowy
   — Ograniczenia techniczne

2. Przedstawienie rozwiązania (20 min)
   — Diagramy C4 (poziom 2-3)
   — Kluczowe decyzje i uzasadnienia

3. Dyskusja (30 min)
   — Pytania i wątpliwości
   — Identyfikacja ryzyk
   — Propozycje alternatyw

4. Podsumowanie (10 min)
   — Lista action items
   — Decyzja: go / no-go / potrzeba więcej informacji
```

## Warsztaty architektoniczne

### Event Storming

Kolaboratywna technika odkrywania domeny:

```
1. Big Picture Event Storming
   — Cały zespół (dev + biznes)
   — Pomarańczowe karteczki = zdarzenia domenowe
   — Linia czasu od lewej do prawej
   — Czas: 2-4 godziny

2. Process Level Event Storming
   — Zespół deweloperski + ekspert domenowy
   — Dodajemy: komendy, aktorów, polityki, read modele
   — Czas: 4-8 godzin

3. Design Level Event Storming
   — Zespół deweloperski
   — Agregaty, bounded contexts, kontrakty
   — Czas: 1-2 dni
```

### Architecture Kata

Ćwiczenie projektowania architektury:

```
Scenariusz: Platforma e-learningowa
Użytkownicy: 100 000
Wymagania:
  - Streaming wideo (live + VOD)
  - System quizów z oceną real-time
  - Certyfikaty po ukończeniu kursu
Ograniczenia:
  - Budżet chmurowy: $5000/mies.
  - Zespół: 8 deweloperów
  - MVP w 3 miesiące

Czas na rozwiązanie: 45 minut
Prezentacja: 10 minut + 5 minut pytań
```

## Documentation as Code

### Zasady

1. **Dokumentacja żyje w repozytorium** — obok kodu, nie na wiki
2. **Przeglądana w code review** — zmiany w architekturze wymagają zmian w docs
3. **Generowana automatycznie** — diagramy z kodu (PlantUML, Mermaid, Structurizr)
4. **Wersjonowana** — historia zmian w Git

### Narzędzia

```
Diagramy:
  - Structurizr (C4 as code)
  - PlantUML (UML as code)
  - Mermaid (diagramy w Markdown)

Dokumentacja:
  - Arc42 (szablon dokumentacji architektonicznej)
  - Docusaurus / MkDocs (portale dokumentacji)
  - ADR Tools (zarządzanie ADR-ami)

Generowanie:
  - OpenAPI / Swagger (API docs)
  - AsyncAPI (event-driven API docs)
  - Dependency graphs (automatyczne diagramy zależności)
```

### Przykład diagramu Mermaid

```
graph TD
    A[Klient mobilny] --> B[API Gateway]
    A2[Klient webowy] --> B
    B --> C[Auth Service]
    B --> D[Order Service]
    B --> E[Product Service]
    D --> F[(PostgreSQL)]
    D --> G[Kafka]
    G --> H[Notification Service]
    G --> I[Analytics Service]
```

## Umiejętności prezentacyjne architekta

### Dopasowanie przekazu do odbiorcy

| Odbiorca | Język | Fokus | Format |
|----------|-------|-------|--------|
| Zarząd / CTO | Biznesowy | ROI, ryzyko, timeline | Slajdy, 1-pager |
| Product Owner | Funkcjonalny | Wpływ na features, kompromisy | Diagramy kontekstu |
| Zespół dev | Techniczny | Jak implementować, wzorce | Diagramy C4, kod |
| Zespół ops | Operacyjny | Deployment, monitoring | Diagramy wdrożenia |

### Tłumaczenie technicznego na biznesowy

```
ŹRÓDLE (techniczny):
  "Musimy zrefaktorować moduł płatności na architekturę 
   event-driven z CQRS, bo obecne synchroniczne wywołania 
   powodują cascade failures przy peak load."

CEL (biznesowy):
  "Nasz system płatności nie radzi sobie w godzinach szczytu 
   — tracimy ~2% transakcji. Proponuję przebudowę, która 
   wyeliminuje ten problem. Koszt: 3 sprinty. Zysk: ~$50K/mies. 
   odzyskanych transakcji."
```

## Zarządzanie interesariuszami

### Mapa interesariuszy

```
                    Wysoki wpływ
                         |
        CTO ●            |         ● CEO
                         |
   Tech Lead ●           |      ● Product Owner
  ─────────────────────── + ───────────────────
   Senior Dev ●          |      ● Project Manager
                         |
    Junior Dev ●         |    ● Marketing
                         |
                    Niski wpływ
        Wysoki interes ←───→ Niski interes
```

### Strategie komunikacji

- **Wysoki wpływ + Wysoki interes** (CTO) → Aktywne zarządzanie relacją
- **Wysoki wpływ + Niski interes** (CEO) → Informuj o kluczowych decyzjach
- **Niski wpływ + Wysoki interes** (Senior Dev) → Konsultuj i angażuj
- **Niski wpływ + Niski interes** (Marketing) → Informuj w razie potrzeby

## Praktyczne wskazówki

1. **Rysuj na tablicy** — wizualizacja jest potężniejszym narzędziem niż słowa
2. **Powtarzaj kluczowe przesłanie** — ludzie zapominają 80% po 24 godzinach
3. **Zbieraj feedback** — pytaj "Czy to jest jasne?" po każdej prezentacji
4. **Dokumentuj decyzje, nie tylko rozwiązania** — "dlaczego" jest ważniejsze niż "co"
5. **Używaj wspólnego słownika** — zdefiniuj terminy na początku projektu (Ubiquitous Language)
6. **Bądź otwarty na krytykę** — architektura to dialog, nie monolog
