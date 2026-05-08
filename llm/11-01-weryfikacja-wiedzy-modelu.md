# Weryfikacja wiedzy modelu — jak sprawdzić co model wie i jaką użyć bazę danych

## Dlaczego weryfikacja wiedzy jest trudna?

LLM wygląda jakby "wszystko wiedział", ale to iluzja. Faktycznie:
- Wiedza jest **rozproszona** w miliardach parametrów
- Brakuje **niezawodnego mechanizmu retrieval** — model nie zawsze "pamięta" to co umie
- **Halucynacje** — model produkuje wiarygodnie brzmiące, ale fałszywe info
- **Cutoff date** — wiedza zatrzymuje się na pewnej dacie
- **Bias** — popularne fakty znane lepiej niż niszowe
- **Inconsistency** — ten sam fakt może być pamiętany różnie w zależności od pytania

## Metody weryfikacji wiedzy modelu

### 1. Testy faktualne

Ułóż dataset par (pytanie, prawidłowa odpowiedź) z domeny.

```python
test_set = [
    {
        "question": "Kto był premierem Polski w 2024?",
        "expected": ["Donald Tusk", "Tusk"],
        "category": "polityka_polska",
        "year": 2024
    },
    {
        "question": "Jaka jest stolica Burkina Faso?",
        "expected": ["Wagadugu", "Ouagadougou"],
        "category": "geografia",
        "domain": "general"
    },
    # ... 100-1000 przykładów
]

# Pomiar
correct = 0
for item in test_set:
    response = llm.ask(item["question"])
    if any(exp.lower() in response.lower() for exp in item["expected"]):
        correct += 1

accuracy = correct / len(test_set)
```

### 2. Closed-book vs Open-book QA

```python
# Closed-book: tylko model
closed_response = llm.ask(question)

# Open-book: model + RAG
docs = retrieve(question)
open_response = llm.ask(question, context=docs)

# Porównaj — gdzie open-book znacznie lepszy = tam model NIE WIE
```

### 3. Confidence calibration

Pytaj modelu o jego **pewność**:

```python
prompt = f"""
Pytanie: {question}

Odpowiedz w formacie:
ODPOWIEDŹ: [twoja odpowiedź]
PEWNOŚĆ: [0-100%]
ŹRÓDŁO: [skąd to wiesz]
"""

response = llm.ask(prompt)
# Sprawdź korelację: gdy model mówi 90%+, jak często ma rację?
```

Dobrze skalibrowany model: gdy mówi 90% pewny, ma rację w 90% przypadków.

### 4. Probing — sprawdzanie konkretnych faktów

```python
# Sprawdź czy model "zna" konkretne fakty z bazy
fact = "Kraków był stolicą Polski do 1596 roku"

# Test 1: bezpośrednio
q1 = "Do którego roku Kraków był stolicą Polski?"
# expected: 1596

# Test 2: pośrednio
q2 = "Kiedy Warszawa została stolicą Polski?"
# expected: 1596 (lub przybliżone)

# Test 3: counterfactual
q3 = "Czy Kraków jest stolicą Polski?"
# expected: NIE (test przeciwko halucynacji)
```

### 5. Log-prob analysis (dla open-source)

Dla otwartych modeli możesz badać prawdopodobieństwa:

```python
# Sprawdź jak pewny jest model różnych odpowiedzi
import torch

prompt = "Stolica Francji to"
candidates = ["Paryż", "Londyn", "Berlin"]

logits = model(prompt).logits[-1]
probs = torch.softmax(logits, dim=-1)

for cand in candidates:
    token_id = tokenizer.encode(cand)[0]
    print(f"{cand}: {probs[token_id]:.4f}")

# Paryż: 0.9234
# Londyn: 0.0012
# Berlin: 0.0008
```

### 6. Knowledge cutoff testing

```python
events = [
    {"event": "Wybory w USA 2024", "expected_year": 2024},
    {"event": "Premiera Llama 3", "expected_year": 2024},
    {"event": "Claude 4 release", "expected_year": 2025},
]

for event in events:
    response = llm.ask(f"Czy znasz: {event['event']}? Co o tym wiesz?")
    # Analiza: czy model zna? Halucynuje? Mówi "po cutoff"?
```

### 7. Hallucination detection

```python
# Pytania o nie-istniejące rzeczy (test halucynacji)
trick_questions = [
    "Opowiedz o pieśni 'Niewidzialny Czerwony Słoń' Czesława Niemena",
    "Kim była dr Anna Kowalska, polska noblistka z chemii 2019?",
    "Jakie są zasady gry w karty 'Polska Polka 2025'?",
]

for q in trick_questions:
    response = llm.ask(q)
    # Dobry model: "Nie znam takiego..."
    # Zły model: zmyśla szczegółowe wymyślone info
```

### 8. Cross-validation z innymi modelami

```python
def consensus_check(question, models=["claude-opus", "gpt-5", "gemini-pro"]):
    answers = [m.ask(question) for m in models]
    # Jeśli wszystkie zgadzają się → prawdopodobnie prawda
    # Jeśli różne → niepewne, sprawdź ręcznie
```

## RAG jako rozwiązanie problemu wiedzy

Jeśli weryfikacja pokazuje, że **model nie wie** lub **halucynuje** w Twojej domenie — użyj RAG zamiast polegać na wiedzy parametrycznej.

```
LLM tylko z parametrami:
- Stała wiedza z cutoff date
- Halucynacje gdy nie wie
- Brak źródeł
- Kosztowna aktualizacja (retraining)

LLM + RAG:
- Aktualna wiedza (dodajesz dokumenty)
- Mniej halucynacji (model widzi prawdziwe info)
- Cytowanie źródeł
- Łatwa aktualizacja
```

## Wybór bazy danych dla wiedzy

### Pytania pomocnicze

1. **Jaki typ danych?** Tekst / strukturyzowane / mieszane / multimedia
2. **Jaka skala?** MB / GB / TB / PB
3. **Częstość aktualizacji?** Static / daily / real-time
4. **Latency requirements?** ms / s / minuty
5. **Budżet?** $0 / $100/mc / $10k+/mc
6. **Ilość zapytań?** 100/dzień / 100k/dzień / 100M/dzień
7. **Privacy?** Public / private / regulated

### Macierz decyzyjna

```
                  Tekst        Strukturyzowane    Hybrid
                  niestruktury   (relacyjne)
                  zowane

Mała skala       Chroma         SQLite + FTS5    Postgres + pgvector
(< 1 GB)         (lokalnie)     (lokalnie)       (jeden serwer)

Średnia skala    Qdrant         Postgres         Postgres + pgvector
(1-100 GB)       (self-host)    (RDS, Aurora)    + Redis cache

Duża skala       Pinecone       Postgres        Multi-system
(> 100 GB)       Weaviate       (sharded)        (specialized per type)
                 Milvus
```

### Vector databases (dla RAG / semantic search)

#### **Chroma** — start tutaj
```python
# pip install chromadb
import chromadb
client = chromadb.PersistentClient(path="./db")
collection = client.create_collection("docs")
collection.add(
    documents=["text1", "text2"],
    metadatas=[{"source": "..."}],
    ids=["1", "2"]
)
results = collection.query(query_texts=["query"], n_results=5)
```
**Pros:** Najprostsza, lokalna, free, zero ops
**Cons:** Nie skaluje się powyżej kilku GB
**Use case:** Prototypy, lokalne aplikacje, < 100k chunks

#### **Qdrant** — production sweet spot
```python
# docker run -p 6333:6333 qdrant/qdrant
from qdrant_client import QdrantClient
client = QdrantClient("localhost", port=6333)
```
**Pros:** Rust → bardzo szybki, hybrid search wbudowany, scalable
**Cons:** Self-hosted = więcej ops (ale jest też cloud)
**Use case:** Produkcja, 100k - 100M chunks, kontrola własna
**Cena:** Free (self-host) lub $25-1000+/mc cloud

#### **Pinecone** — managed leader
```python
from pinecone import Pinecone
pc = Pinecone(api_key="...")
index = pc.Index("docs")
index.upsert(vectors=[...])
```
**Pros:** Zero ops, najłatwiejsze, świetna performance
**Cons:** Vendor lock-in, drogie przy skali
**Use case:** Startup z budżetem, fast time-to-market
**Cena:** $0 (free tier 100k vectors) → $70+/mc serverless

#### **Weaviate**
**Pros:** GraphQL, multi-tenancy, modules (rerankers, generators)
**Cons:** Bardziej złożone, mniejsza społeczność niż Pinecone
**Use case:** Enterprise z complex requirements

#### **Milvus / Zilliz Cloud**
**Pros:** Skala (miliardy wektorów), enterprise features
**Cons:** Skomplikowany self-host
**Use case:** Bardzo duża skala (>100M vectors)

#### **pgvector** (PostgreSQL extension)
```sql
CREATE EXTENSION vector;
CREATE TABLE docs (id bigserial, embedding vector(1536), content text);
CREATE INDEX ON docs USING hnsw (embedding vector_cosine_ops);

SELECT content FROM docs ORDER BY embedding <=> '[...]' LIMIT 5;
```
**Pros:** Już masz Postgres? Reużyj. Łatwe joiny z relational data.
**Cons:** Wolniejsze od dedykowanych vector DB przy dużej skali
**Use case:** Aplikacje Postgres-first, < 10M vectors

#### **Turbopuffer** (2024+ rising star)
**Pros:** Object storage backend → bardzo tanie
**Cons:** Nowsze, mniej tooling
**Use case:** Cost-sensitive, large scale

#### **LanceDB**
**Pros:** Plikowa (jak SQLite dla wektorów), multimodalna
**Cons:** Embedded, nie skaluje się horyzontalnie
**Use case:** Local apps, AI-powered desktop tools

### Bazy relacyjne (dla strukturyzowanej wiedzy)

#### **PostgreSQL** — uniwersalny standard
- Pełnotekstowe wyszukiwanie (tsvector, FTS5)
- Vector search (pgvector)
- JSON support (jsonb)
- Hosted: AWS RDS, Aurora, Neon, Supabase

#### **MySQL / MariaDB**
- Mniej zaawansowane niż Postgres dla AI
- Ale jeśli masz, można

#### **SQLite + FTS5**
- Embedded, plikowe
- Świetne dla małych aplikacji
- FTS5 = full-text search wbudowany

### Wyspecjalizowane bazy

#### **Elasticsearch / OpenSearch**
- Pełnotekstowe wyszukiwanie king
- Skala TB+
- Vector search od ES 8.0
- Drogie self-host (operacyjnie)

#### **Typesense / Meilisearch**
- Szybsze, prostsze niż ES dla małych zastosowań
- Open source
- Świetne do search-as-you-type

#### **Apache Solr**
- Klasyk, mniej popularne dziś
- Enterprise-friendly

### Knowledge graphs

#### **Neo4j**
- Najpopularniejszy graph DB
- Cypher query language
- Świetny dla relacji encji

#### **AWS Neptune**, **ArangoDB**
- Alternatywy

**GraphRAG (Microsoft, 2024)** — łączy graph DB z RAG, lepsze dla "global queries" o całym korpusie.

### Time-series / Logs

Jeśli wiedza to zdarzenia w czasie:
- **TimescaleDB** (Postgres extension)
- **InfluxDB**
- **ClickHouse** (analytics scale)

## Architektury wiedzy dla LLM

### Architektura 1: Single Vector DB (najprostsza)

```
Dokumenty → Embeddings → Qdrant → Retrieval → LLM
```
**Kiedy:** Mała/średnia skala, jeden typ danych
**Komponenty:** Qdrant + LangChain/LlamaIndex + Claude/GPT

### Architektura 2: Hybrid Search

```
Dokumenty → ┬→ BM25 (keyword) ─┐
            └→ Embeddings ─────┴→ RRF fusion → Rerank → LLM
                  ↓
              Qdrant
```
**Kiedy:** Mieszane queries (nazwy własne + semantyczne)
**Komponenty:** Elasticsearch/Qdrant (hybrid) + Cohere Rerank + LLM

### Architektura 3: Multi-source

```
Vector DB (text)     ─┐
SQL DB (structured)  ─┼→ LLM jako orchestrator → Final answer
Graph DB (relations) ─┘
```
**Kiedy:** Złożona domena, różne typy wiedzy
**Komponenty:** Qdrant + Postgres + Neo4j + LLM agent

### Architektura 4: Tiered (cost optimization)

```
Hot tier:    Cache (Redis) ────┐
Warm tier:   Vector DB ─────────┼→ LLM
Cold tier:   Object storage ────┘  (z dynamicznym ładowaniem)
```
**Kiedy:** Ogromna skala, koszt jest priorytetem

## Przykład end-to-end weryfikacji wiedzy + RAG

```python
class KnowledgeVerifiedLLM:
    def __init__(self, llm, vector_db, eval_dataset):
        self.llm = llm
        self.db = vector_db
        self.eval = eval_dataset

    def ask(self, question: str) -> dict:
        # 1. RAG retrieval
        chunks = self.db.search(question, k=5)

        # 2. Generate with context
        prompt = f"""
        Odpowiedz na pytanie używając WYŁĄCZNIE źródeł poniżej.
        Jeśli źródła nie zawierają odpowiedzi: "Nie wiem".

        ŹRÓDŁA:
        {chunks}

        PYTANIE: {question}
        """
        answer = self.llm.generate(prompt)

        # 3. Faithfulness check
        faithfulness = self.check_faithfulness(answer, chunks)

        # 4. Citation
        sources = [c.source for c in chunks]

        return {
            "answer": answer,
            "sources": sources,
            "faithfulness": faithfulness,  # 0-1
            "confidence": self.estimate_confidence(question)
        }

    def check_faithfulness(self, answer, chunks):
        """Czy odpowiedź wynika ze źródeł?"""
        prompt = f"""
        Czy poniższa ODPOWIEDŹ wynika ze ŹRÓDEŁ?
        Odpowiedz: 0 (nie), 0.5 (częściowo), 1 (tak)

        ŹRÓDŁA: {chunks}
        ODPOWIEDŹ: {answer}
        """
        score = float(self.llm.generate(prompt))
        return score

    def evaluate(self):
        """Run eval dataset"""
        results = []
        for item in self.eval:
            response = self.ask(item["question"])
            correct = self.check_correct(response["answer"], item["expected"])
            results.append({**item, **response, "correct": correct})
        accuracy = sum(r["correct"] for r in results) / len(results)
        return {"accuracy": accuracy, "details": results}
```

## Rekomendacja stacku — 2026

### Dla startupu (szybki time-to-market)
```
- Embeddings: Voyage AI voyage-3-large (lub OpenAI)
- Vector DB: Pinecone Serverless ($0 starter)
- LLM: Claude Sonnet 4.6 + Haiku 4.5 (fallback)
- Reranker: Cohere Rerank v3.5
- Framework: LlamaIndex
- Monitor: Langfuse (free open source)

Koszt startowy: ~$50-200/mc dla pierwszych 10k users
```

### Dla enterprise (kontrola, prywatność)
```
- Embeddings: BGE-M3 (self-host)
- Vector DB: Qdrant cluster (self-host na K8s)
- LLM: Claude API (lub self-host Llama 4 70B)
- Reranker: bge-reranker-v2-m3 (self-host)
- Postgres: dla strukturyzowanych danych
- Framework: LangGraph + custom orchestration
- Monitor: Langfuse self-hosted + Prometheus

Koszt: $5-20k/mc fixed + cloud GPU
```

### Dla aplikacji local-first / privacy
```
- Embeddings: Nomic Embed v2 (lokalnie)
- Vector DB: Chroma (embedded)
- LLM: Ollama z Llama 3.1 8B / 70B Q4
- Wszystko offline
- Postgres lokalnie / SQLite

Koszt: $0/mc + jednorazowy hardware
```

## Praktyczna ścieżka

```
1. Zacznij od weryfikacji: czy LLM faktycznie wie?
   ↓
2. Jeśli nie wie / halucynuje → zbuduj RAG
   ↓
3. Wybierz embeddings (Voyage AI lub BGE-M3)
   ↓
4. Zacznij od Chroma (proste) → upgrade do Qdrant gdy skalujesz
   ↓
5. Dodaj reranking (Cohere lub bge-reranker)
   ↓
6. Zbuduj eval dataset → mierz faithfulness
   ↓
7. Iteruj na chunking strategy
   ↓
8. W produkcji: monitor Langfuse + alerty na regresje
```

## Najczęstsze pułapki

1. **"LLM zna wszystko"** — nie zna. Sprawdź konkretne fakty.
2. **"Większy model = mniej halucynacji"** — częściowo prawda, ale nadal halucynuje
3. **"RAG rozwiąże wszystko"** — tylko jeśli dobrze zbudowany (chunking, hybrid, rerank)
4. **Wybór bazy bez testów** — zacznij od prostej, skaluj gdy potrzeba
5. **Brak ewaluacji** — bez eval datasetu nie wiesz czy poprawiasz
6. **Cutoff awareness** — pamiętaj że wiedza modelu się starzeje
7. **Citation manipulation** — zawsze pokazuj źródła userowi
