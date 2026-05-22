# Wzorce architektoniczne

## 1. Architektura monolityczna

Cały system jako jedna jednostka wdrożeniowa.

**Zalety:**
- Prostota wdrożenia i debugowania
- Łatwa komunikacja między komponentami (wywołania w procesie)
- Proste transakcje

**Wady:**
- Trudna skalowalność poszczególnych modułów
- Ryzyko "big ball of mud" przy braku dyscypliny
- Długi czas budowania i wdrażania przy dużym systemie

**Kiedy stosować:** Małe/średnie projekty, MVP, mały zespół.

---

## 2. Architektura warstwowa (Layered / N-Tier)

Podział na warstwy: prezentacja → logika biznesowa → dostęp do danych.

```
┌─────────────────────┐
│   Prezentacja (UI)   │
├─────────────────────┤
│   Logika biznesowa   │
├─────────────────────┤
│   Dostęp do danych   │
├─────────────────────┤
│    Baza danych       │
└─────────────────────┘
```

**Zasada:** Warstwa może komunikować się tylko z warstwą bezpośrednio poniżej.

---

## 3. Mikroserwisy (Microservices)

System podzielony na małe, niezależnie wdrażane usługi.

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│  Serwis  │  │  Serwis  │  │  Serwis  │
│ Zamówień │  │ Płatności│  │ Użytkow. │
└────┬─────┘  └────┬─────┘  └────┬─────┘
     │              │              │
     └──────────┬───┘──────────────┘
                │
         Message Broker / API Gateway
```

**Zalety:**
- Niezależne wdrażanie i skalowanie
- Autonomia zespołów
- Izolacja błędów

**Wady:**
- Złożoność operacyjna (sieć, monitoring, wdrożenia)
- Transakcje rozproszone (saga pattern)
- Debugowanie trudniejsze

**Kiedy stosować:** Duże systemy, wiele zespołów, potrzeba niezależnego skalowania.

---

## 4. Architektura sterowana zdarzeniami (Event-Driven)

Komponenty komunikują się przez zdarzenia (events).

**Modele:**
- **Event Notification** — powiadomienie, że coś się stało
- **Event-Carried State Transfer** — zdarzenie niesie pełne dane
- **Event Sourcing** — stan systemu odtwarzany ze strumienia zdarzeń

**Technologie:** Apache Kafka, RabbitMQ, AWS EventBridge, NATS

---

## 5. CQRS (Command Query Responsibility Segregation)

Rozdzielenie modelu zapisu (Command) od modelu odczytu (Query).

```
Komendy ──→ [Model zapisu] ──→ Baza zapisu
                                     │
                                Synchronizacja
                                     │
Zapytania ←── [Model odczytu] ←── Baza odczytu
```

**Kiedy stosować:** Różne wymagania wydajnościowe dla odczytu i zapisu, złożone raporty.

---

## 6. Architektura heksagonalna (Ports & Adapters)

Rdzeń biznesowy nie zależy od infrastruktury — komunikacja przez porty i adaptery.

```
          ┌─────────────────────┐
Adapter ──│  Port    Domena     │── Port ── Adapter
(REST)    │         (logika     │         (Baza danych)
          │       biznesowa)    │
Adapter ──│  Port               │── Port ── Adapter
(CLI)     └─────────────────────┘         (Kolejka)
```

**Zalety:** Łatwa wymiana infrastruktury, testowalność domeny w izolacji.

---

## 7. Architektura serverless

Logika w funkcjach uruchamianych na żądanie (FaaS).

**Technologie:** AWS Lambda, Azure Functions, Google Cloud Functions

**Zalety:** Brak zarządzania infrastrukturą, płatność za użycie
**Wady:** Cold start, ograniczenia czasu wykonania, vendor lock-in

---

## 8. Architektura modularna (Modular Monolith)

Monolit z wyraźnymi granicami modułów — kompromis między monolitem a mikroserwisami.

**Zasady:**
- Moduły komunikują się przez zdefiniowane interfejsy
- Każdy moduł ma własną bazę/schemat danych
- Brak bezpośrednich zależności między modułami

**Kiedy stosować:** Gdy mikroserwisy to za dużo złożoności, ale potrzebujesz granic modułów.
