# Wdrożenie i optymalizacja LLM

## Architektura produkcyjnego LLM

```
┌────────────────────────────────────────────────┐
│             KLIENT (web/mobile/API)             │
└──────────────────────┬─────────────────────────┘
                       │
┌──────────────────────▼─────────────────────────┐
│              LOAD BALANCER + CDN                │
└──────────────────────┬─────────────────────────┘
                       │
┌──────────────────────▼─────────────────────────┐
│          API GATEWAY (auth, rate limit)         │
└──────────────────────┬─────────────────────────┘
                       │
┌──────────────────────▼─────────────────────────┐
│            APPLICATION LAYER                    │
│   - Prompt construction                         │
│   - RAG retrieval                               │
│   - Tool execution                              │
│   - Cache check                                 │
└──────────────────────┬─────────────────────────┘
                       │
┌──────────────────────▼─────────────────────────┐
│          INFERENCE LAYER (vLLM/TGI)             │
│   - Model serving                               │
│   - Batching                                    │
│   - KV cache                                    │
└──────────────────────┬─────────────────────────┘
                       │
┌──────────────────────▼─────────────────────────┐
│          GPU CLUSTER (H100/A100)                │
└─────────────────────────────────────────────────┘

Sidecars:
- Vector DB (Qdrant/Pinecone)
- Cache (Redis)
- Observability (Langfuse/LangSmith)
- Logs/Metrics (ELK/Prometheus)
```

## Strategie deploymentu

### 1. Managed API (najszybsze)
```
Claude API / GPT API / Gemini API
```
**Plus:** Zero ops, najnowsze modele, skalowanie automatyczne
**Minus:** Cost, vendor lock-in, dane na zewnątrz

### 2. Cloud GPU (środek)
```
AWS Bedrock / Azure AI / Vertex AI
```
**Plus:** Managed, ale więcej kontroli niż API
**Minus:** Wciąż drogie, vendor lock-in

### 3. Self-hosted (najwięcej kontroli)
```
vLLM / TGI / Ollama na własnych GPU
```
**Plus:** Pełna kontrola, prywatność, niskie koszty per query
**Minus:** Ops, fixed cost (GPU), trzeba znać się na ML serving

## Kwantyzacja — najważniejsza optymalizacja

Zmniejsza rozmiar modelu i przyspiesza inferencję.

### Formaty kwantyzacji (2026)

| Format | Bity | Quality | Speed | Use case |
|--------|------|---------|-------|----------|
| **FP16/BF16** | 16 | 100% | 1× | Reference, training |
| **INT8 (W8A16)** | 8 wagi, 16 act | 99% | 1.5× | Production safe |
| **FP8** | 8 wagi+act | 99% | 2× | H100, latest |
| **INT4 (W4A16)** | 4 wagi | 95-98% | 2-3× | **Production sweet spot** |
| **GPTQ** | 4 | 96% | 2.5× | NVIDIA inference |
| **AWQ** | 4 | 97% | 2.5× | Lepsza niż GPTQ |
| **EXL2** | 2-8 | varies | 3× | NVIDIA, fastest |
| **GGUF** | 2-8 | varies | 1-2× | CPU+GPU mixed |

### Kwantyzacja w praktyce

```python
# AWQ (najlepsze GPU inference)
from awq import AutoAWQForCausalLM
model = AutoAWQForCausalLM.from_quantized(
    "TheBloke/Llama-3.1-70B-Instruct-AWQ"
)

# GPTQ (vLLM-compatible)
# Po prostu wybierz model z "-GPTQ" suffix

# GGUF (llama.cpp)
# Wybierz np. llama-3.1-70b-instruct-Q4_K_M.gguf
```

## Inference servers

### vLLM — produkcyjny standard

```bash
pip install vllm

# Single GPU
vllm serve meta-llama/Llama-3.1-8B-Instruct \
    --gpu-memory-utilization 0.9

# Multi-GPU tensor parallel
vllm serve meta-llama/Llama-3.1-70B-Instruct \
    --tensor-parallel-size 4 \
    --quantization awq

# OpenAI-compatible API na localhost:8000
```

**Kluczowe features:**
- **PagedAttention** — efektywne KV cache (od UC Berkeley)
- **Continuous batching** — dynamiczne łączenie requestów
- **Chunked prefill** — równoważenie prefill i decode
- **Speculative decoding** — przyspieszenie z draft model
- **Prefix caching** — cache wspólnych prefixów

### Text Generation Inference (TGI) — Hugging Face

```bash
docker run --gpus all -p 8080:80 \
    -v $PWD/data:/data \
    ghcr.io/huggingface/text-generation-inference:latest \
    --model-id meta-llama/Llama-3.1-8B-Instruct
```

Podobne featury do vLLM, dobrze zintegrowane z HF ecosystem.

### NVIDIA Triton + TensorRT-LLM

Najwyższa wydajność na NVIDIA GPU. Trudniejsze w setup, ale 2-3× szybsze.

### Ollama (dev/small scale)

```bash
ollama serve  # production-ready dla small/medium scale
```

Pod spodem llama.cpp, prosty deploy.

### MLC LLM

Multi-platform: serwer + mobile + browser (WebGPU).

## KV Cache — zrozumienie kluczowe

W generation, model dla każdego tokenu liczy K i V dla wszystkich poprzednich tokenów.
**KV cache** zapisuje to, by nie przeliczać.

```
Bez cache: dla N tokenów, przy generowaniu N+1 → przelicz wszystkie N
Z cache:   przy generowaniu N+1 → przelicz tylko nowy
```

**Rozmiar KV cache:**
```
KV_size = 2 × num_layers × num_kv_heads × head_dim × seq_len × dtype_bytes

Llama 3 8B, kontekst 8192:
2 × 32 × 8 × 128 × 8192 × 2 (BF16) = 1 GB

Llama 3 70B, kontekst 8192:
2 × 80 × 8 × 128 × 8192 × 2 = 2.6 GB
```

Dla długich kontekstów (100k+) KV cache zajmuje **więcej niż sam model**!

### KV cache optimizations
- **Quantization** — INT8/INT4 KV cache (2-4× mniej pamięci)
- **PagedAttention** (vLLM) — like virtual memory dla KV
- **Sliding window** — limit kontekstu w attention
- **Multi-query / Grouped-query attention** — mniej K/V heads

## Prompt Caching — masowa oszczędność

Anthropic, OpenAI i inni wprowadzili **prompt caching** — system prompt + initial context są cache'owane przez kilka minut.

```python
# Anthropic prompt caching
client.messages.create(
    model="claude-opus-4-7",
    system=[
        {
            "type": "text",
            "text": LONG_SYSTEM_PROMPT,  # 5000 tokens
            "cache_control": {"type": "ephemeral"}
        }
    ],
    messages=[...]
)

# Pierwszy request: pełna cena (nawet +25% za cache write)
# Kolejne (w 5 min): 90% taniej dla cached części
```

**Praktycznie:** 70-95% redukcja kosztów dla aplikacji z dużym system promptem.

## Batching strategies

### Static batching
Czekaj aż zbierzesz N requestów, processuj razem.
**Problem:** opóźnienie dla pierwszych requestów.

### Continuous batching (vLLM)
Dynamicznie dodawaj/usuwaj requesty z batcha podczas inferencji.
**2-10× wyższy throughput** niż static batching.

```
Time:    t1     t2     t3     t4
Req A:   [████████████]
Req B:        [████████████]
Req C:             [████████]
Req D:                  [████████████]

Każdy request kończy się gdy gotowy, nowy może dołączyć.
```

## Speculative Decoding

Przyspieszenie z draft model:
```
1. Mały model (draft) generuje N tokenów szybko
2. Duży model weryfikuje wszystkie N naraz
3. Akceptuj tokeny gdzie się zgadzają
4. Mismatch → kontynuuj od tego punktu

Przyspieszenie: 2-3× przy zachowaniu jakości dużego modelu.
```

W 2026 standard w vLLM/TGI.

## Streaming

User widzi tokeny w trakcie generacji (jak ChatGPT).
**Time to first token (TTFT)** jest kluczowy dla UX.

```python
# Anthropic streaming
with client.messages.stream(
    model="claude-sonnet-4-6",
    messages=[...]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

## Monitoring i observability

### Co mierzyć:
1. **Latency**: TTFT, TPOT (time per output token), total
2. **Throughput**: tokens/s, requests/s
3. **GPU**: utilization, memory, temperatura
4. **Cost**: per request, per user, per feature
5. **Quality**: hallucinations, refusals (sample real conversations)
6. **Errors**: timeouts, OOM, model errors

### Tools:
- **Langfuse** (open source) — najlepszy compromise
- **LangSmith** (LangChain) — managed
- **Helicone** — proxy + analytics
- **Anthropic Console** — natywne dla Claude
- **Phoenix Arize** — open source
- **Prometheus + Grafana** — niskopoziomowe metrics

## Cost optimization — checklist

### 1. Cache aggressively
- Prompt caching (90% redukcja)
- Semantic cache (Redis + embeddings) dla powtarzających się queries
- HTTP cache headers

### 2. Use right-sized model
- Haiku/Mini dla prostych zadań → 10× tańsze
- Opus/o3 tylko dla skomplikowanych

### 3. Batch API
- Anthropic/OpenAI batch API → 50% taniej (async, godziny)
- Dla nie-real-time tasks (analiza, classification)

### 4. Optimize prompts
- Krótszy system prompt
- Few-shot tylko gdy potrzebne
- Compression (krótki format, bez redundancji)

### 5. Reduce output length
- `max_tokens` z głową
- "Odpowiedz zwięźle"
- Structured output (JSON > prose)

### 6. RAG optimization
- Mniej chunks = krótszy kontekst = taniej
- Reranking → top 3-5 zamiast top 20
- Chunk size optimization

### 7. Self-host gdy duża skala
- $0.001/query API → $50/mc dla 50k queries
- Self-host: ~$1000/mc fixed (GPU rental) — break even przy 1M+ queries

### 8. Streaming + early stopping
- User widzi odpowiedź wcześniej
- Może przerwać niepotrzebne tokeny

## Bezpieczeństwo w produkcji

### Input safety:
- **PII detection** — usuń przed wysłaniem do LLM
- **Prompt injection guard** — Lakera, Llama Guard
- **Topic boundary** — odmów odpowiedzi off-topic
- **Rate limiting** — per user/IP
- **Input length limits** — max prompt size

### Output safety:
- **Content filtering** — Llama Guard, OpenAI Moderation
- **PII redaction** — przed zwróceniem userowi
- **Hallucination detection** — RAG faithfulness check
- **Refusal validation** — czasem model "powinien" odmówić

### Operational:
- **API keys rotation** — regularna
- **Audit logs** — wszystkie requesty
- **Cost limits** — per user, per day
- **Anomaly detection** — niezwykłe wzorce użycia

## Wzorzec: Production-grade LLM endpoint

```python
from fastapi import FastAPI, HTTPException
from anthropic import Anthropic

app = FastAPI()
client = Anthropic()

@app.post("/chat")
async def chat(request: ChatRequest):
    # 1. Auth & rate limit
    user = await authenticate(request)
    await rate_limit_check(user)

    # 2. Input validation & safety
    if len(request.message) > MAX_INPUT_LEN:
        raise HTTPException(400, "Message too long")

    if await contains_pii(request.message):
        request.message = await redact_pii(request.message)

    if await is_prompt_injection(request.message):
        log_security_event(user, "injection_attempt")
        raise HTTPException(400, "Invalid input")

    # 3. Cache check
    cache_key = hash(request.message + request.system)
    if cached := await cache.get(cache_key):
        return cached

    # 4. RAG retrieval
    context = await retrieve_context(request.message)

    # 5. Build prompt with caching
    response = await client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        system=[
            {
                "type": "text",
                "text": SYSTEM_PROMPT,
                "cache_control": {"type": "ephemeral"}
            },
            {
                "type": "text",
                "text": f"Context:\n{context}"
            }
        ],
        messages=[{"role": "user", "content": request.message}]
    )

    # 6. Output safety
    answer = response.content[0].text
    if await contains_harmful(answer):
        return SAFE_FALLBACK_RESPONSE

    # 7. Cache, log, monitor
    await cache.set(cache_key, answer, ttl=3600)
    await log_interaction(user, request, response)
    await metrics.record(latency=..., tokens=...)

    return {"answer": answer, "sources": context.sources}
```

## Capacity planning

```
Scenariusz: 1000 użytkowników, 10 queries/user/day = 10k queries/dzień

API approach:
  Cost: 10k × $0.005 = $50/dzień = $1500/mc
  Pros: zero ops, perfect scaling
  Cons: cost scales linearly

Self-host (Llama 3.1 70B AWQ na A100 80GB):
  GPU: 1× A100 (~$1500/mc rental, lub własna ~$15k upfront)
  Throughput: ~50 req/s = 4.3M queries/dzień (znacznie więcej niż 10k)
  Cost: $1500/mc fixed
  Break-even: ~30k queries/mc

Decyzja:
  < 30k queries/mc: API
  > 30k queries/mc: Self-host (lub wielu modeli)
```

## Ewolucja — od POC do produkcji

```
1. POC (1 weekend)
   - Anthropic API + Streamlit
   - 1 prompt, 1 model
   - In-memory state

2. Beta (1 miesiąc)
   - FastAPI/Next.js backend
   - Postgres dla state
   - Langfuse dla observability
   - Eval dataset (50 examples)

3. Production (3-6 miesięcy)
   - Auto-scaling (Kubernetes/serverless)
   - Caching (Redis + prompt cache)
   - RAG (Qdrant/Pinecone)
   - Multi-model fallback
   - Comprehensive monitoring

4. Scale (6+ miesięcy)
   - Self-hosted dla cost optimization
   - Custom fine-tunes dla specyficznych zadań
   - Multi-region deployment
   - SLA monitoring
```

## Trendy 2026

1. **Long context bez RAG** — modele 1M+ kontekst, "wrzuć wszystko"
2. **Reasoning models** — chain of thought wbudowane (Claude extended thinking, o3)
3. **Agentic systems** — wieloetapowe agenty zamiast pojedynczych queries
4. **Edge inference** — modele na phone (Llama 3.2 1B/3B)
5. **Specialized models** — coding, math, vision-specific (zamiast general-purpose)
6. **MoE w inference** — większe modele bez wyższych kosztów
7. **MCP** — universal tool protocol
8. **Computer Use** — agenci jako digital workers
