# Model C4

## Czym jest model C4?

Model C4 (Context, Containers, Components, Code) to podejscie do wizualizacji architektury oprogramowania stworzone przez Simona Browna. Zamiast jednego skomplikowanego diagramu, C4 uzywa czterech poziomow abstrakcji — jak przybylizanie na mapie, od widoku kraju do widoku ulicy.

## Cztery poziomy

```
Poziom 1: System Context
  "Jak nasz system wpisuje sie w swiat?"
  Aktorzy, systemy zewnetrzne, relacje

Poziom 2: Container
  "Z jakich glownych czesci sklada sie system?"
  Aplikacje, bazy danych, kolejki, API

Poziom 3: Component
  "Jak wyglada wnetrze kontenera?"
  Moduly, serwisy, kontrolery, repozytoria

Poziom 4: Code
  "Jak wyglada kod?"
  Klasy, interfejsy, UML (rzadko uzywany)
```

## Poziom 1: System Context

Najwyzszy poziom — pokazuje system jako czarna skrzynke w kontekscie uzytkownikow i systemow zewnetrznych. Odpowiada na pytanie: "Kto uzywa systemu i z czym sie integruje?"

```
┌─────────────┐
│   Klient    │
│ (uzytkownik)│
└──────┬──────┘
       │ uzywa
       ▼
┌──────────────┐     ┌───────────────┐
│   System     │────→│ Payment       │
│  E-commerce  │     │ Provider      │
│              │     │ (Stripe)      │
└──────┬───────┘     └───────────────┘
       │
       │ wysyla emaile przez
       ▼
┌──────────────┐
│   Email      │
│   Service    │
│  (SendGrid)  │
└──────────────┘
```

### Kiedy uzywac?
- Poczatek projektu — komunikacja z interesariuszami
- Onboarding nowych czlonkow zespolu
- Rozmowy z zespolem biznesowym (netechnicznym)

### Elementy
| Element | Opis | Przyklad |
|---------|------|----------|
| **Person** | Uzytkownik lub rola | Klient, Admin, Kurier |
| **Software System** | Nasz system (czarna skrzynka) | System E-commerce |
| **External System** | System zewnetrzny | Stripe, SendGrid, SAP |
| **Relacja** | Interakcja miedzy elementami | "uzywa", "wysyla emaile" |

## Poziom 2: Container

Przybylizamy — wnetrze naszego systemu. Kontenery to oddzielne deployable units: aplikacje webowe, API, bazy danych, kolejki.

```
┌─────────────────────────────────────────────────────┐
│                  System E-commerce                   │
│                                                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────────┐  │
│  │ Frontend  │───→│   API    │───→│  PostgreSQL  │  │
│  │   (SPA)   │    │ (Node.js)│    │  (database)  │  │
│  │  React    │    │ Express  │    └──────────────┘  │
│  └──────────┘    └────┬─────┘                       │
│                       │         ┌──────────────┐    │
│                       ├────────→│    Redis     │    │
│                       │         │   (cache)    │    │
│                       │         └──────────────┘    │
│                       │                              │
│                       │         ┌──────────────┐    │
│                       └────────→│  RabbitMQ   │    │
│                                 │  (kolejka)   │    │
│                                 └──────┬───────┘    │
│                                        │            │
│                                 ┌──────▼───────┐    │
│                                 │   Worker     │    │
│                                 │  (Node.js)   │    │
│                                 └──────────────┘    │
└─────────────────────────────────────────────────────┘
```

### Kiedy uzywac?
- Planowanie architektury systemu
- Decyzje technologiczne (jaka baza, jaki framework)
- Dokumentacja dla zespolu technicznego
- Rozmowy o infrastrukturze

### Elementy
| Element | Opis | Przyklad |
|---------|------|----------|
| **Web Application** | Aplikacja frontendowa | React SPA, Angular |
| **API** | Serwer backendowy | Express, Spring Boot |
| **Database** | Baza danych | PostgreSQL, MongoDB |
| **Message Queue** | Kolejka komunikatow | RabbitMQ, Kafka |
| **Cache** | Warstwa cache | Redis, Memcached |
| **Worker** | Background processor | Consumer kolejki |

## Poziom 3: Component

Wnetrze jednego kontenera — moduly, serwisy, kontrolery. Pokazuje glowne bloki funkcjonalne i ich interakcje.

```
┌──────────────────────────────────────────────┐
│                API Container                  │
│                                               │
│  ┌────────────┐    ┌───────────────────────┐ │
│  │  Auth      │    │   Order Controller    │ │
│  │ Middleware  │───→│   /api/orders/*       │ │
│  └────────────┘    └──────────┬────────────┘ │
│                               │              │
│                    ┌──────────▼────────────┐ │
│                    │    Order Service      │ │
│                    │   (logika biznesowa)  │ │
│                    └──────────┬────────────┘ │
│                               │              │
│              ┌────────────────┼────────────┐ │
│              │                │            │ │
│  ┌───────────▼──┐  ┌─────────▼──┐  ┌──────▼┐│
│  │   Order     │  │  Payment  │  │ Email  ││
│  │ Repository  │  │  Gateway  │  │ Sender ││
│  └──────┬──────┘  └──────┬───┘  └────┬───┘│
│         │                │            │    │
└─────────┼────────────────┼────────────┼────┘
          ↓                ↓            ↓
     PostgreSQL        Stripe       SendGrid
```

### Kiedy uzywac?
- Szczegolowe planowanie nowej funkcjonalnosci
- Code review architektury kontenera
- Dokumentacja wewnetrzna modulu

## Poziom 4: Code

Najnizszy poziom — klasy, interfejsy, diagramy UML. Zwykle generowany automatycznie z kodu. Rzadko tworzony recznie.

### Kiedy uzywac?
- Skomplikowana logika biznesowa wymagajaca wizualizacji
- Generowanie automatyczne z kodu (IDE, narzedzia)
- Dokumentacja bibliotek / frameworkow

**Wazne:** Poziom 4 jest rzadko potrzebny. Kod powinien byc na tyle czytelny, ze diagram jest zbedny. Jesli potrzebujesz diagramu kodu — moze kod jest za skomplikowany.

## Structurizr DSL

Structurizr to narzedzie do tworzenia diagramow C4 jako kod (diagram-as-code):

```
workspace "E-commerce" "System sprzedazy online" {

  model {
    customer = person "Klient" "Kupuje produkty"
    admin = person "Administrator" "Zarzadza systemem"

    ecommerce = softwareSystem "System E-commerce" "Obsluga sprzedazy" {
      frontend = container "Frontend" "React SPA" "TypeScript"
      api = container "API" "REST API" "Node.js / Express" {
        orderController = component "Order Controller" "Obsluga zamowien"
        orderService = component "Order Service" "Logika biznesowa"
        orderRepo = component "Order Repository" "Dostep do danych"
        paymentGateway = component "Payment Gateway" "Integracja platnosci"
      }
      database = container "Database" "PostgreSQL" "Dane" "database"
      cache = container "Cache" "Redis" "Sesje, cache"
      queue = container "Queue" "RabbitMQ" "Async tasks"
      worker = container "Worker" "Background jobs" "Node.js"
    }

    stripe = softwareSystem "Stripe" "Platnosci" "external"
    sendgrid = softwareSystem "SendGrid" "Emaile" "external"

    customer -> frontend "Przegladarka"
    admin -> frontend "Przegladarka"
    frontend -> api "HTTPS / JSON"
    api -> database "TCP / SQL"
    api -> cache "TCP / Redis protocol"
    api -> queue "AMQP"
    api -> stripe "HTTPS"
    worker -> queue "AMQP"
    worker -> sendgrid "HTTPS"
    worker -> database "TCP / SQL"

    orderController -> orderService "wywoluje"
    orderService -> orderRepo "uzywa"
    orderService -> paymentGateway "deleguje platnosc"
    orderRepo -> database "SQL queries"
    paymentGateway -> stripe "HTTPS"
  }

  views {
    systemContext ecommerce "Context" {
      include *
      autoLayout
    }

    container ecommerce "Containers" {
      include *
      autoLayout
    }

    component api "Components" {
      include *
      autoLayout
    }
  }
}
```

```bash
# Generowanie diagramow
# Opcja 1: Structurizr Lite (Docker)
docker run -it --rm -p 8080:8080 \
  -v ./workspace:/usr/local/structurizr structurizr/lite

# Opcja 2: Structurizr CLI (export do PNG/SVG)
structurizr-cli export -workspace workspace.dsl -format plantuml
```

## Czeste bledy

| Blad | Problem | Rozwiazanie |
|------|---------|-------------|
| Zbyt wiele szczegolow na L1 | Context diagram wyglada jak Container | Tylko osoby i systemy na L1 |
| Mieszanie poziomow | Container i Component na jednym diagramie | Kazdy poziom oddzielnie |
| Brak opisu relacji | Strzalki bez etykiet | Zawsze opisuj CO przechodzi |
| Brak technologii | "Backend" zamiast "Node.js Express API" | Podaj technologie na L2+ |
| Nieaktualne diagramy | Diagram z 2 lata temu | Diagram-as-code + CI |

## Kiedy uzywac ktorego poziomu?

| Odbiorcy | Poziom | Cel |
|----------|--------|-----|
| Zarzad, PM, biznes | L1 Context | "Co robi system?" |
| Architekci, zespol | L2 Container | "Z czego sie sklada?" |
| Developerzy | L3 Component | "Jak dziala wnetrze?" |
| Nowi w projekcie | L1 + L2 | Onboarding |
| Code review | L3 (opcjonalnie) | Zrozumienie modulu |

## Kluczowe wnioski

1. **4 poziomy abstrakcji** — od panoramy do detalu, jak przybylizanie na mapie
2. **Context (L1)** dla interesariuszy — kto, co, z czym sie laczy
3. **Container (L2)** dla zespolu — decyzje technologiczne, infrastruktura
4. **Component (L3)** dla developerow — wnetrze kontenera
5. **Code (L4)** rzadko potrzebny — generuj automatycznie lub pomiij
6. **Structurizr DSL** — diagram-as-code, wersjonowanie w Git
7. **Aktualizuj diagramy** — nieaktualny diagram jest gorszy niz brak diagramu
