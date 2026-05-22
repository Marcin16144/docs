# Dokumentacja i diagramy architektoniczne

> **Aktualizacja: 2026** — Mermaid renderowany natywnie w GitHubie/GitLabie, dojrzałe ADR tooling (log4brains), AI-assisted documentation (Claude, Cursor, GPT) jako codzienna praktyka.

## Model C4

Cztery poziomy abstrakcji diagramów (Simon Brown):

### Level 1: System Context
Widok z lotu ptaka — system i jego otoczenie.

```
┌─────────┐         ┌──────────────────┐        ┌─────────────┐
│ Klient  │────────→│   Nasz System    │───────→│  System     │
│ (osoba) │         │  (oprogramowanie)│        │  Płatności  │
└─────────┘         └──────────────────┘        │  (zewn.)    │
                                                 └─────────────┘
```

### Level 2: Container
Główne kontenery systemu (aplikacje, bazy, kolejki).

```
┌──────────────────────────────────────────┐
│              Nasz System                  │
│  ┌─────────┐  ┌──────────┐  ┌─────────┐ │
│  │  SPA    │  │   API    │  │  Baza   │ │
│  │ (React) │→│ (Node.js)│→│ (Postgres)│ │
│  └─────────┘  └──────────┘  └─────────┘ │
└──────────────────────────────────────────┘
```

### Level 3: Component
Komponenty wewnątrz kontenera.

### Level 4: Code
Diagramy klas/sekwencji — tylko dla krytycznych części.

---

## Inne przydatne diagramy

### Diagram sekwencji (Sequence Diagram)
Pokazuje interakcje między komponentami w czasie.

```
Klient      API Gateway    Order Service    Payment Service
  │              │               │                │
  │──POST /order─→               │                │
  │              │──create order──→                │
  │              │               │──process pay───→│
  │              │               │←──pay result────│
  │              │←──order created─│                │
  │←──201 Created─│               │                │
```

### Diagram przepływu danych (Data Flow)
Jak dane przemieszczają się przez system.

### Diagram wdrożeniowy (Deployment Diagram)
Jak komponenty mapują się na infrastrukturę.

---

## Architecture Decision Records (ADR)

Dokumentuj kluczowe decyzje i ich kontekst. Format:
- **Tytuł** — zwięzły opis decyzji
- **Status** — Proposed / Accepted / Deprecated / Superseded
- **Kontekst** — dlaczego ta decyzja jest potrzebna
- **Decyzja** — co wybraliśmy
- **Konsekwencje** — pozytywne i negatywne skutki

**Narzędzia ADR (2026):**
- **log4brains** — generuje statyczną stronę z ADR-ów w repozytorium, świetne wyszukiwanie i nawigacja
- **adr-tools** — proste narzędzie CLI (Bash) do tworzenia i numerowania ADR
- **Markdown Architectural Decision Records (MADR)** — popularny szablon
- Dla większych organizacji: **Backstage** (Spotify) z pluginem Tech Docs / ADR

**Dobra praktyka:** ADR żyją w repozytorium kodu (`docs/adr/`), są wersjonowane i recenzowane razem z kodem.

---

## Narzędzia do diagramów (2026)

| Narzędzie | Typ | Opis |
|-----------|-----|------|
| **Mermaid** | Diagram as Code | Renderowany **natywnie w GitHub i GitLab** w plikach Markdown — zero dodatkowych narzędzi |
| **PlantUML** | Diagram as Code | UML, C4, sekwencyjne |
| **Structurizr (DSL)** | C4 Model | Dedykowane dla C4, jeden model = wiele widoków |
| **D2** | Diagram as Code | Nowoczesny język diagramów (Terrastruct), przyjemny render |
| **Excalidraw** | GUI | Diagramy w stylu odręcznym, świetne do whiteboardingu zespołowego |
| **draw.io / diagrams.net** | GUI | Darmowy edytor diagramów |
| **Lucidchart**, **Miro**, **Whimsical** | GUI/SaaS | Profesjonalne diagramy i tablice |
| **Eraser.io**, **tldraw** | GUI | Hybryda Markdown + diagramów, popularne w 2026 |

> **Mermaid w 2026** to praktyczny default — działa w GitHubie, GitLabie, Notionie, Obsidianie, MS Teams; obsługuje C4 (`C4Context`, `C4Container`), sekwencje, ER, gantt, flowcharts.

---

## Co dokumentować?

**Dokumentuj:**
- Decyzje architektoniczne (ADR)
- Konteksty i granice (Context Map)
- Interfejsy między systemami (API contracts)
- Proces wdrożenia
- Runbooki operacyjne

**Nie dokumentuj (bo się zdezaktualizuje):**
- Szczegóły implementacji (czytaj kod)
- Aktualna struktura klas (generuj z kodu)
- Konfiguracja (trzymaj w repozytorium)

---

## AI-assisted documentation (2026)

Dokumentacja generowana i utrzymywana z pomocą LLM-ów to standardowa praktyka:

- **Claude (Sonnet/Opus), GPT, Gemini** — generowanie i odświeżanie ADR-ów, README, runbooków, dokumentacji API z kodu
- **Claude Code, Cursor, Aider** — generowanie diagramów Mermaid / C4 wprost w repo na podstawie kodu
- **Mintlify, Docusaurus + AI search, Backstage TechDocs** — platformy dokumentacyjne z wbudowanym wyszukiwaniem semantycznym (RAG nad bazą dokumentacji)
- Auto-generowane API docs: **Scalar**, **Redoc**, **Swagger UI**, **Mintlify** (z OpenAPI / GraphQL schema)

**Dobre praktyki AI w dokumentacji:**
- LLM jako pierwszy draft, człowiek jako review
- Trzymaj prompty / generatory w repozytorium (powtarzalność)
- Generowane sekcje wyraźnie oznaczaj — łatwiej regenerować przy zmianach
- Linkuj ADR-y, kod i diagramy nawzajem (LLM-y łatwiej robią cross-reference)
- Docs as Code: dokumentacja w repo, w PR review, z testami linków (np. lychee, link-check)
