# RAG — Retrieval Augmented Generation

## Czym jest RAG?

**RAG** to technika łącząca wyszukiwanie (retrieval) z generowaniem przez LLM. Zamiast polegać tylko na wiedzy modelu (która jest statyczna i ograniczona), RAG dynamicznie pobiera odpowiednie informacje z bazy wiedzy i wkleja je do promptu.

```
┌─────────┐    ┌──────────┐    ┌──────────┐    ┌─────────┐
│ Pytanie │───→│  Search  │───→│ Top-K    │───→│   LLM   │
│ usera   │    │ (vector  │    │ chunks   │    │+ chunki │
└─────────┘    │  + BM25) │    │z bazy    │    │ + query │
               └──────────┘    └──────────┘    └────┬────┘
                                                     │
                                              ┌──────▼──────┐
                                              │  Answer +   │
                                              │  źródła     │
                                              └─────────────┘
```

## Po co RAG?

### Problemy LLM, które RAG rozwiązuje:
1. **Aktualność** — model ma cutoff date, nie zna najnowszych info
2. **Wiedza domenowa** — Twoje dokumenty firmowe nie są w danych treningowych
3. **Halucynacje** — bez konkretnych danych model zmyśla
4. **Cytowanie źródeł** — możesz pokazać skąd info pochodzi
5. **Aktualizacja bez retreningu** — dodajesz dokumenty, nie zmieniasz modelu

### RAG vs fine-tuning vs long context

| Aspekt | RAG | Fine-tuning | Long context |
|--------|-----|-------------|--------------|
| Aktualizacja | Łatwa (dodaj dok.) | Wymaga retreningu | Każdorazowo |
| Koszt | $ (tylko inference) | $$$ (training) | $$ (długie prompty) |
| Wiedza domenowa | ✓ Dobre | ✓ Najlepsze | ✓ ad-hoc |
| Cytowanie źródeł | ✓ Tak | ✗ Nie | ⚠ Trudne |
| Skalowalność danych | TB+ | GB-TB | MB (limit kontekstu) |
| Złożoność | Średnia | Wysoka | Niska |
| Kiedy używać | Dynamiczna wiedza | Styl, format | Małe dokumenty |

W 2026, z modelami 1M+ kontekstu (Gemini, Claude), pojawia się pytanie czy RAG jest jeszcze potrzebny. **Odpowiedź: tak**, dla dużych korpusów (>10MB) RAG jest tańszy i szybszy.

## Komponenty RAG

### 1. Document Loaders
Pobieranie danych z różnych źródeł.

```python
# LlamaIndex
from llama_index.core import SimpleDirectoryReader
docs = SimpleDirectoryReader("./docs").load_data()

# Web pages
from llama_index.readers.web import SimpleWebPageReader
docs = SimpleWebPageReader().load_data(["https://anthropic.com"])

# PDF
from llama_index.readers.file import PDFReader
docs = PDFReader().load_data("manual.pdf")

# Notion, Slack, Google Drive — gotowe loadery w llamaindex i langchain
```

### 2. Chunking — kluczowy krok!

Dokumenty trzeba podzielić na kawałki (chunks). **Strategia chunkowania ma ogromny wpływ na jakość RAG.**

#### Strategie chunkowania

**Fixed-size chunking** (najprostszy):
```python
chunk_size = 512  # tokeny
chunk_overlap = 50

# Tnij co 512 tokenów z overlap 50
```

**Recursive character splitting:**
```python
from langchain.text_splitter import RecursiveCharacterTextSplitter

splitter = RecursiveCharacterTextSplitter(
    chunk_size=1000,
    chunk_overlap=200,
    separators=["\n\n", "\n", ". ", " ", ""]
)
chunks = splitter.split_documents(docs)
```

**Semantic chunking** (lepszy):
Tnij na granicach semantycznych (gdy embedding zmienia się znacząco).

**Document structure chunking** (najlepszy dla strukturyzowanych dokumentów):
- Markdown → po nagłówkach (`MarkdownHeaderTextSplitter`)
- Code → po funkcjach/klasach
- HTML → po sekcjach

**Late chunking** (2024 trend):
Embedduj cały dokument, dopiero potem chunkuj embeddingi.

### 3. Embeddings

Konwersja tekstu na wektory.

```python
from openai import OpenAI
client = OpenAI()

response = client.embeddings.create(
    model="text-embedding-3-large",
    input="Hello world"
)
vector = response.data[0].embedding  # [0.123, -0.456, ...] (3072 wymiarów)
```

### Najlepsze modele embeddingowe (2026)

| Model | Wymiary | Koszt | Multilingual | Open Source |
|-------|---------|-------|--------------|-------------|
| **OpenAI text-embedding-3-large** | 3072 | $$$ | ✓ | ✗ |
| **Voyage AI voyage-3-large** | 1024 | $$ | ✓ | ✗ |
| **Cohere embed-v4** | 1536 | $$ | ✓✓ (100+ lang) | ✗ |
| **BGE-M3** | 1024 | $0 | ✓ | ✓ |
| **Jina embeddings v3** | 1024 | $/+ | ✓ | ✓ |
| **Nomic Embed v2** | 768 | $0 | ✓ | ✓ |
| **mxbai-embed-large** | 1024 | $0 | ⚠ | ✓ |

**Wybór:** Voyage AI dla komercyjnych, BGE-M3 dla open source/local.

### 4. Vector Database

| Baza | Hosting | Charakterystyka | Cena |
|------|---------|-----------------|------|
| **Chroma** | Self-hosted, embedded | Najprostsza, lokalna | Free |
| **Qdrant** | Self-hosted lub cloud | Rust, bardzo szybka | Free + cloud |
| **Weaviate** | Self-hosted lub cloud | GraphQL API, hybrid search | Free + cloud |
| **Pinecone** | SaaS only | Najpopularniejsza komercyjna | $$ |
| **Milvus** | Self-hosted lub Zilliz cloud | Skalowalna, enterprise | Free + cloud |
| **pgvector** | PostgreSQL extension | W istniejącej Postgres | Free |
| **Turbopuffer** | SaaS | Ekstremalnie tania, wydajna | $ |
| **LanceDB** | Embedded | Plikowa, multimodal | Free |

```python
# Qdrant przykład
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

client = QdrantClient(":memory:")  # lub url="http://localhost:6333"

client.create_collection(
    collection_name="docs",
    vectors_config=VectorParams(size=1024, distance=Distance.COSINE)
)

client.upsert(
    collection_name="docs",
    points=[
        PointStruct(id=1, vector=embed("...")[0], payload={"text": "..."}),
        ...
    ]
)

# Search
results = client.search(
    collection_name="docs",
    query_vector=embed("query")[0],
    limit=5
)
```

### 5. Retrieval

```python
def retrieve(query: str, top_k: int = 5):
    # 1. Embed query
    query_embedding = embed_model.encode(query)

    # 2. Search vector DB
    results = vector_db.search(
        query_vector=query_embedding,
        top_k=top_k
    )

    # 3. Return chunks
    return [r.payload["text"] for r in results]
```

### 6. Augmented Generation

```python
def rag_query(question: str):
    # 1. Retrieve
    chunks = retrieve(question, top_k=5)

    # 2. Build prompt
    context = "\n\n".join([f"[{i+1}] {c}" for i, c in enumerate(chunks)])

    prompt = f"""Odpowiedz na pytanie używając WYŁĄCZNIE poniższych źródeł.
Cytuj numery źródeł w odpowiedzi (np. [1], [2]).
Jeśli odpowiedź nie znajduje się w źródłach, powiedz "Nie wiem".

ŹRÓDŁA:
{context}

PYTANIE: {question}

ODPOWIEDŹ:"""

    # 3. Generate
    response = llm.generate(prompt)
    return response
```

## Hybrid Search — zawsze lepszy

Połączenie **vector search** (semantic) z **BM25** (keyword) daje znacznie lepsze wyniki niż samo vector search.

```python
# Reciprocal Rank Fusion
def hybrid_search(query: str, top_k: int = 10):
    vector_results = vector_search(query, k=20)  # semantyczne
    keyword_results = bm25_search(query, k=20)   # keywords

    # Łączenie wyników (RRF)
    scores = {}
    for rank, doc in enumerate(vector_results):
        scores[doc.id] = scores.get(doc.id, 0) + 1 / (rank + 60)
    for rank, doc in enumerate(keyword_results):
        scores[doc.id] = scores.get(doc.id, 0) + 1 / (rank + 60)

    # Top K
    return sorted(scores.items(), key=lambda x: -x[1])[:top_k]
```

Większość vector DB ma wbudowany hybrid search (Weaviate, Qdrant, Pinecone).

## Reranking — kluczowy boost

Po retrieval pobierz top-50, potem **rerankuj** modelem reranker do top-5.

```python
# Cohere Rerank
import cohere
co = cohere.Client()

results = co.rerank(
    model="rerank-v3.5",
    query=query,
    documents=initial_results,  # 50 chunks
    top_n=5
)
```

**Rerankery:**
- **Cohere Rerank v3.5** ($$) — komercyjny standard
- **Voyage AI Rerank-2** ($$) — partner Anthropic
- **bge-reranker-v2-m3** (free) — open source, dobry
- **mxbai-rerank-large-v1** (free) — open source

Reranking to **drugi etap** — najczęściej daje +20-30% jakości RAG.

## Zaawansowane techniki RAG

### HyDE (Hypothetical Document Embeddings)

Zamiast embeddować pytanie, embedduj **wygenerowaną hipotetyczną odpowiedź**:

```python
def hyde_search(query):
    # 1. Generuj hipotetyczną odpowiedź
    hypothetical = llm.generate(f"Odpowiedz na: {query}")

    # 2. Embedduj odpowiedź (nie pytanie!)
    embedding = embed_model.encode(hypothetical)

    # 3. Search
    return vector_db.search(embedding)
```

Działa lepiej dla skomplikowanych pytań.

### Multi-query / Query expansion

```python
def multi_query(query):
    # Wygeneruj 3 wariacje pytania
    variations = llm.generate(f"""Wygeneruj 3 wariacje pytania:
    {query}""")

    # Search każdej, pomerguj wyniki
    all_results = []
    for q in variations:
        all_results.extend(vector_search(q))

    return deduplicate(all_results)
```

### Contextual chunking (Anthropic)

Przed embedingiem chunka, dodaj kontekst gdzie chunk się znajduje w dokumencie:

```python
chunk_with_context = f"""
Dokument: {doc_title}
Sekcja: {section}
Kontekst: {summary_of_surrounding_text}

{chunk_text}
"""
```

Anthropic pokazał +35% jakości tylko z tym trickiem.

### Self-RAG / Corrective RAG

Model sam decyduje:
1. Czy w ogóle potrzebuje wyszukiwać
2. Czy wyniki są dobre
3. Czy wygenerować nowy query

### GraphRAG (Microsoft)

Buduj graf wiedzy z dokumentów (encje + relacje), pozwala na global queries (nie tylko lokalne).

```
Pytanie: "Jakie są główne tematy w korpusie dokumentów?"

Standard RAG: nie poradzi sobie (każdy chunk widzi mały fragment)
GraphRAG: agreguje encje i relacje z całego korpusu
```

## Architektury RAG

### Naive RAG
```
Query → Retrieve → Generate
```
Działa dla prostych przypadków.

### Advanced RAG
```
Query → Query rewriting → Hybrid search → Rerank → Generate
                                    ↓
                            HyDE / Multi-query
```

### Modular / Agentic RAG (2025-2026 trend)

Agent decyduje jakie narzędzia użyć:
```
User question
  ↓
Agent: "Czy potrzebuję search?"
  ↓ TAK
  ├─→ Search docs
  ├─→ Search web
  ├─→ Query SQL database
  └─→ Compute (calculator)
  ↓
Agent łączy wyniki
  ↓
Final answer with citations
```

## Frameworki RAG

### LlamaIndex — RAG-first
```python
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader

docs = SimpleDirectoryReader("./docs").load_data()
index = VectorStoreIndex.from_documents(docs)

query_engine = index.as_query_engine(
    similarity_top_k=5,
    response_mode="tree_summarize"
)
response = query_engine.query("Co to jest CAP theorem?")
```

### LangChain
```python
from langchain.chains import RetrievalQA
qa = RetrievalQA.from_chain_type(llm=llm, retriever=retriever)
response = qa.run("query")
```

### Haystack
Niemiecki framework, mocny w produkcyjnym deployu.

### txtai
Lekki, embedded RAG.

## Ewaluacja RAG

**Bez ewaluacji RAG to ślepa droga.**

### Metryki
- **Context Recall** — czy retrieval znalazł właściwe info?
- **Context Precision** — czy info jest na temat?
- **Faithfulness** — czy odpowiedź wynika ze źródeł?
- **Answer Relevance** — czy odpowiada na pytanie?

### Narzędzia
- **Ragas** — najpopularniejszy framework eval RAG
- **DeepEval** — pytest-style testing
- **TruLens** — observability + eval
- **Langfuse / LangSmith** — tracing + eval
- **Phoenix** (Arize) — open source

```python
# Ragas
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall

result = evaluate(
    dataset=eval_dataset,  # questions, contexts, answers, ground_truth
    metrics=[faithfulness, answer_relevancy, context_recall]
)
```

## Pułapki produkcyjne

1. **Słabe chunki** — najczęstszy problem. Eksperymentuj ze strategiami.
2. **Brak rerankingu** — naive search to za mało.
3. **Brak hybrid search** — tylko vector to ślepa uliczka dla nazw, ID, kodów.
4. **Stale embeddings** — gdy zmienisz model embeddingowy, musisz reembedować wszystko.
5. **Out-of-domain queries** — RAG odpowiada na pytania spoza bazy → halucynacje.
6. **Brak monitoringu** — nie wiesz co user pyta, jakie chunki są zwracane.
7. **PII w bazie** — wyciek danych osobowych przez context.

## Cost optimization

```
Koszt RAG = embedding_cost + storage_cost + inference_cost

Dla 1M dokumentów ~500 słów każdy:
- Embedding (one-time): ~$50-200 (OpenAI/Voyage)
- Storage: ~$50-200/mc (Pinecone) lub $0 (self-hosted Qdrant)
- Inference per query: ~$0.001-0.01

Dla skali milionów queries/mc → self-host vector DB!
```

## Stack RAG w 2026 — rekomendacja

### Startup (szybko, niska skala)
```
Documents → LlamaIndex → Pinecone → Voyage embeddings → Claude/GPT
                                                  ↓
                                         Cohere Rerank → Answer
```

### Enterprise (kontrola, skala)
```
Documents → Custom pipeline → Qdrant (self-host) → BGE-M3 embeddings
                              ↓
                       BM25 + Vector hybrid → bge-reranker → Claude
                                                                ↓
                                                          Langfuse monitor
```

### Lokalny / privacy-first
```
Docs → LlamaIndex → Chroma (lokalnie) → Nomic Embed → Llama 3 8B (Ollama)
                                              ↓
                                    bge-reranker (lokalnie)
```
