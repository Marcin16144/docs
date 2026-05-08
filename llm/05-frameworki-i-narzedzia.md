# Frameworki i narzędzia do pracy z LLM

## Mapa ekosystemu (2026)

```
┌─────────────────────────────────────────────────────┐
│              APLIKACJE / AGENT FRAMEWORKS           │
│  LangGraph │ Anthropic SDK │ DSPy │ AutoGen │ ...   │
├─────────────────────────────────────────────────────┤
│                  WYŻSZE WARSTWY                     │
│  LangChain │ LlamaIndex │ Haystack │ Pydantic AI    │
├─────────────────────────────────────────────────────┤
│                       SDKI                          │
│  Anthropic SDK │ OpenAI SDK │ Google AI │ ...       │
├─────────────────────────────────────────────────────┤
│           SERVING / INFERENCE ENGINES               │
│  vLLM │ TGI │ Ollama │ llama.cpp │ MLC LLM          │
├─────────────────────────────────────────────────────┤
│              FRAMEWORKI ML                          │
│  PyTorch │ JAX │ Hugging Face Transformers          │
├─────────────────────────────────────────────────────┤
│                  HARDWARE / CUDA                    │
└─────────────────────────────────────────────────────┘
```

## 1. PyTorch — fundament

Stworzony przez Meta (Facebook), de facto standard dla research i produkcji LLM.

```python
import torch
import torch.nn as nn

# Self-attention w pigułce
class SimpleAttention(nn.Module):
    def __init__(self, dim):
        super().__init__()
        self.q = nn.Linear(dim, dim)
        self.k = nn.Linear(dim, dim)
        self.v = nn.Linear(dim, dim)

    def forward(self, x):
        Q, K, V = self.q(x), self.k(x), self.v(x)
        scores = (Q @ K.transpose(-2, -1)) / (x.size(-1) ** 0.5)
        attn = torch.softmax(scores, dim=-1)
        return attn @ V
```

**Alternatywy:**
- **JAX** (Google) — używany w Gemini, PaLM. Szybszy do trainingu na TPU.
- **MLX** (Apple) — natywny dla Apple Silicon.
- **TensorFlow** — praktycznie nieużywany w nowych projektach LLM.

## 2. Hugging Face Transformers

**Najpopularniejsza biblioteka** do pracy z transformerami. Repo `transformers` ma 130k+ gwiazdek.

```bash
pip install transformers accelerate
```

```python
from transformers import AutoModelForCausalLM, AutoTokenizer
import torch

model_name = "meta-llama/Llama-3.3-70B-Instruct"

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name,
    torch_dtype=torch.bfloat16,
    device_map="auto"  # automatyczne rozłożenie na GPU
)

messages = [
    {"role": "user", "content": "Wyjaśnij CAP theorem"}
]
inputs = tokenizer.apply_chat_template(
    messages, return_tensors="pt", add_generation_prompt=True
).to(model.device)

outputs = model.generate(inputs, max_new_tokens=512, temperature=0.7)
print(tokenizer.decode(outputs[0]))
```

**Hugging Face Hub** — repozytorium 1.5M+ modeli:
- huggingface.co/models
- Pobieranie automatyczne przez `from_pretrained`
- Spaces — demo aplikacje
- Datasets — dataset hub

**Powiązane biblioteki HF:**
- `datasets` — ładowanie i przetwarzanie datasetów
- `accelerate` — distributed training, mixed precision
- `peft` — Parameter Efficient Fine-Tuning (LoRA, QLoRA)
- `trl` — Transformers Reinforcement Learning (DPO, PPO)
- `evaluate` — metryki ewaluacji
- `optimum` — optymalizacja inference (ONNX, TensorRT)

## 3. SDK do API komercyjnych LLM

### Anthropic SDK (Claude)
```bash
pip install anthropic
```

```python
import anthropic

client = anthropic.Anthropic()  # ANTHROPIC_API_KEY z env

message = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    system="Jesteś ekspertem od architektury oprogramowania.",
    messages=[
        {"role": "user", "content": "Jakie są kompromisy mikroserwisów?"}
    ]
)
print(message.content[0].text)
```

**Funkcje:** prompt caching, extended thinking, vision, tool use, batch API, files API, citations.

### OpenAI SDK
```python
from openai import OpenAI
client = OpenAI()

response = client.chat.completions.create(
    model="gpt-5",
    messages=[{"role": "user", "content": "Hi!"}]
)
```

### Google AI SDK
```python
from google import genai
client = genai.Client()
response = client.models.generate_content(
    model="gemini-2.5-pro",
    contents="Hi!"
)
```

### Universal: LiteLLM
Jeden interfejs do 100+ dostawców LLM:
```python
from litellm import completion
response = completion(
    model="claude-opus-4-7",  # lub "gpt-5", "gemini-2.5-pro"
    messages=[{"role": "user", "content": "Hi"}]
)
```

## 4. Frameworki do budowy aplikacji LLM

### LangChain
Najbardziej znany framework. Modułowy, ale bywa over-engineered.

```python
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate

llm = ChatAnthropic(model="claude-sonnet-4-6")

prompt = ChatPromptTemplate.from_messages([
    ("system", "Jesteś tłumaczem na język {language}."),
    ("user", "{text}")
])

chain = prompt | llm
result = chain.invoke({"language": "francuski", "text": "Cześć!"})
```

### LangGraph (preferowany w 2026)
Następca LangChain dla agentów. Graph-based, stateful, lepiej zaprojektowany.

```python
from langgraph.graph import StateGraph
from langgraph.prebuilt import create_react_agent

agent = create_react_agent(
    model="anthropic:claude-sonnet-4-6",
    tools=[search_tool, calculator_tool],
    prompt="Jesteś badaczem internetu."
)

result = agent.invoke({
    "messages": [("user", "Jakie są ostatnie nowiny o AI?")]
})
```

### DSPy (Stanford)
"Programowanie zamiast promptowania". Optymalizuje prompty automatycznie.

```python
import dspy

dspy.configure(lm=dspy.LM("anthropic/claude-sonnet-4-6"))

class QA(dspy.Signature):
    """Odpowiadaj zwięźle."""
    question = dspy.InputField()
    answer = dspy.OutputField()

predictor = dspy.ChainOfThought(QA)
result = predictor(question="Co to jest CAP theorem?")
```

### Pydantic AI
Type-safe agent framework. Wykorzystuje Pydantic do strukturalnych odpowiedzi.

```python
from pydantic import BaseModel
from pydantic_ai import Agent

class CityInfo(BaseModel):
    name: str
    population: int
    country: str

agent = Agent("anthropic:claude-sonnet-4-6", result_type=CityInfo)
result = agent.run_sync("Powiedz mi o Warszawie")
print(result.data)  # CityInfo(name='Warszawa', population=1860000, country='Polska')
```

### Instructor
Strukturalne odpowiedzi przez Pydantic, działa ze wszystkimi LLM:
```python
import instructor
from anthropic import Anthropic

client = instructor.from_anthropic(Anthropic())
result = client.messages.create(
    model="claude-opus-4-7",
    response_model=CityInfo,
    messages=[{"role": "user", "content": "Powiedz o Warszawie"}]
)
```

### Claude Agent SDK
SDK od Anthropic do budowania własnych agentów (jak Claude Code):
```python
from claude_agent_sdk import Agent, tool

@tool
def search_web(query: str) -> str:
    """Search the web for information."""
    return ...

agent = Agent(
    model="claude-opus-4-7",
    tools=[search_web],
    system_prompt="Jesteś badaczem."
)
```

## 5. RAG / Vector Stores

### LlamaIndex
Specjalizowany w RAG i indeksowaniu danych.

```python
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader

documents = SimpleDirectoryReader("./docs").load_data()
index = VectorStoreIndex.from_documents(documents)

query_engine = index.as_query_engine()
response = query_engine.query("Co mówią dokumenty o X?")
```

### Vector Databases

| Baza | Typ | Charakterystyka |
|------|-----|-----------------|
| **Chroma** | Open source, in-process | Najprostsza do startu, lokalna |
| **Qdrant** | Open source, server | Rust, bardzo szybka |
| **Weaviate** | Open source, server | GraphQL API, hybrid search |
| **Pinecone** | SaaS | Najpopularniejsza komercyjna, łatwa |
| **Milvus** | Open source | Skalowalna, używana w produkcji |
| **pgvector** | PostgreSQL extension | Vector search w istniejącej Postgres |
| **LanceDB** | Embedded | Plikowa, multimodalna |
| **Turbopuffer** | SaaS | Tanio, dobry balance ceny/wydajności |

### Embedding modele
- **OpenAI text-embedding-3-large** — komercyjny standard
- **Voyage AI** — komercyjny, świetna jakość, partner Anthropic
- **Cohere embed-v4** — komercyjny, multilingual
- **BGE-M3** — open source, multilingual
- **Nomic Embed** — open source, długi kontekst

## 6. Model Context Protocol (MCP)

**MCP** (Anthropic, 2024) — otwarty protokół do łączenia LLM z zewnętrznymi narzędziami i danymi. Stał się de facto standardem w 2025/2026.

```
LLM Application  ←─MCP─→  MCP Server  ←─→  Tool/Data
(Claude Desktop,         (Filesystem,       (pliki, API,
 Claude Code,             Postgres,          baza danych)
 Cursor)                  GitHub, ...)
```

**Popularne MCP servery:**
- `@modelcontextprotocol/server-filesystem`
- `@modelcontextprotocol/server-postgres`
- `@modelcontextprotocol/server-github`
- `@modelcontextprotocol/server-slack`
- Ponad 1000 community servers w 2026

**Zastosowanie:** Claude Code, Cursor, Zed używają MCP do integracji z narzędziami developerskimi.

## 7. Narzędzia developerskie

### IDE z AI

**Komercyjne:**
- **Cursor** — VS Code fork z głęboką integracją AI
- **Windsurf** (Codeium) — alternatywa do Cursora
- **GitHub Copilot** — najstarszy, dostępny w wielu IDE
- **JetBrains AI Assistant** — natywny w IntelliJ/PyCharm

**Open source / darmowe:**
- **Continue.dev** (VS Code, JetBrains) — open source, własne LLM
- **Cline** (VS Code) — dawniej Claude Dev, agentic
- **Aider** — terminalowy AI pair programmer
- **Zed** z natywną AI

### CLI Agents
- **Claude Code** (Anthropic) — terminalowy agent, multi-step tasks
- **Codex CLI** (OpenAI)
- **Gemini CLI** (Google)
- **Aider** — open source

### Notebooki AI
- **Cursor Composer** — multi-file editing
- **Claude Artifacts / Projects** — claude.ai
- **ChatGPT Canvas** — chat.openai.com

## 8. Specjalizowane narzędzia

### Trening i fine-tuning
- **Axolotl** — wrapper na trl, łatwy fine-tuning
- **Unsloth** — 2-5× szybszy fine-tuning, mniej VRAM
- **TRL** (HF) — RLHF, DPO, GRPO
- **Llama Factory** — GUI do fine-tuningu

### Ewaluacja
- **lm-evaluation-harness** (EleutherAI) — standard benchmarków
- **OpenAI Evals**
- **Promptfoo** — eval prompts
- **DeepEval** — LLM testing framework
- **Ragas** — eval RAG systems
- **TruLens** — observability + eval

### Observability i monitoring
- **LangSmith** (LangChain) — tracing, eval
- **Helicone** — proxy + analytics
- **Langfuse** — open source observability
- **Weights & Biases** — ML experiments tracking
- **Anthropic Console** — natywne dla Claude API

### Bezpieczeństwo
- **Lakera Guard** — protection przeciw prompt injection
- **Prompt Armor**
- **NeMo Guardrails** (NVIDIA) — open source
- **Llama Guard** (Meta) — open source content safety

## 9. Polecane stacki technologiczne (2026)

### Stack "minimum viable LLM app"
```
Frontend: Next.js + Vercel AI SDK
Backend:  Python (FastAPI) + Anthropic SDK
LLM:      Claude Sonnet 4.6 (API)
Vector:   pgvector w Postgres (Supabase)
```

### Stack "produkcyjny RAG"
```
Frontend: React/Next.js
Backend:  Python + LlamaIndex
LLM:      Claude (główny) + GPT-5 (fallback) via LiteLLM
Vector:   Qdrant lub Pinecone
Embed:    Voyage AI voyage-3-large
Cache:    Redis (semantic cache)
Monitor:  Langfuse
```

### Stack "lokalny self-hosted"
```
Inference: vLLM (Llama 4 70B AWQ)
Frontend:  Open WebUI
Vector:    Qdrant
Embed:     BGE-M3 (lokalnie)
RAG:       LlamaIndex
Tools:     MCP servers
```

### Stack "agent z narzędziami"
```
Framework: LangGraph lub Claude Agent SDK
LLM:       Claude Opus 4.7 (extended thinking)
Tools:     MCP servers
State:     LangGraph checkpoints (Postgres)
Observe:   LangSmith
```

## Co wybrać?

**Zaczynasz?**
→ Anthropic SDK lub OpenAI SDK + prosty Python skrypt

**Budujesz aplikację z RAG?**
→ LlamaIndex (RAG-first) lub LangChain + Qdrant/Pinecone

**Budujesz agenta?**
→ LangGraph lub Claude Agent SDK

**Eksperymentujesz lokalnie?**
→ Ollama dla startu, vLLM dla wydajności

**Fine-tuning?**
→ Unsloth (najszybszy) lub Axolotl (najpopularniejszy)

**Strukturalne odpowiedzi?**
→ Pydantic AI lub Instructor

**Chcesz uniknąć vendor lock-in?**
→ LiteLLM jako warstwa abstrakcji
