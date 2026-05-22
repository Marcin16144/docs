# Context management — limity, kompresja, wskazówki praktyczne

## Czym jest context window?

**Context window** = maksymalna liczba tokenów które LLM może przetworzyć w jednym wywołaniu. Obejmuje:
- System prompt
- Historia rozmowy (wszystkie poprzednie wiadomości)
- Aktualny prompt użytkownika
- Tools/function definitions
- Aktualnie generowaną odpowiedź (output tokens)

```
┌────────────────────────────────────────────────┐
│              CONTEXT WINDOW (200k)              │
├────────────────────────────────────────────────┤
│  System prompt           │  ~5k tokens          │
├──────────────────────────┼──────────────────────┤
│  Tool definitions        │  ~2k tokens          │
├──────────────────────────┼──────────────────────┤
│  Conversation history    │  ~50k tokens         │
│  (wiadomość 1, 2, ... N) │                      │
├──────────────────────────┼──────────────────────┤
│  Current user message    │  ~1k tokens          │
├──────────────────────────┼──────────────────────┤
│  Output (max_tokens)     │  ~8k tokens          │
└──────────────────────────┴──────────────────────┘
                            Total: ~66k / 200k
```

## Limity kontekstu w 2026 (kluczowe modele)

| Model | Context | Output max | Cena 1M input |
|-------|---------|-----------|---------------|
| **Claude Opus 4.7** | 200k | 8k (extended thinking) | $15 |
| **Claude Sonnet 4.6** | 200k | 8k | $3 |
| **Claude Haiku 4.5** | 200k | 8k | $0.80 |
| **GPT-5** | 128k | 16k | ~$10 |
| **GPT-4o** | 128k | 16k | $2.50 |
| **Gemini 2.5 Pro** | 2M (!) | 8k | $7 |
| **Gemini 2.5 Flash** | 1M | 8k | $0.30 |
| **Llama 4 Maverick** | 1M | 8k | self-host |
| **DeepSeek V3** | 128k | 8k | $0.27 |
| **Mistral Large** | 128k | 8k | $4 |

**Trend 2026:** Gemini przesuwa granice (2M tokenów), reszta walczy w 128-200k. Większość zastosowań produkcyjnych mieści się w 32-100k.

## Tokeny — jak liczyć

### Reguła kciuka:
- **1 token ≈ 0.75 słowa** w angielskim
- **1 token ≈ 0.5 słowa** w polskim (więcej tokenizacji)
- **1 token ≈ 4 znaki** w angielskim
- **1 token ≈ 2-3 znaki** w polskim

### Praktyczne porównanie

```
Tekst: "Hello world!" (12 znaków)
→ 3 tokeny: ["Hello", " world", "!"]

Tekst: "Cześć świecie!" (14 znaków, polski)
→ 7 tokenów: ["Cze", "ść", " ś", "wie", "cie", "!"]
```

### Narzędzia do liczenia
- **tiktoken** (OpenAI) — Python lib, dla GPT
- **anthropic.tokenizer** — dla Claude
- **Hugging Face tokenizers** — dla open source models
- **OpenAI Tokenizer playground** (web): platform.openai.com/tokenizer
- **Anthropic Console** ma wbudowany counter

```python
# tiktoken example
import tiktoken
encoding = tiktoken.encoding_for_model("gpt-4o")
text = "Cześć świecie!"
tokens = encoding.encode(text)
print(f"Tokens: {len(tokens)}")  # 7
print(f"Decoded: {[encoding.decode([t]) for t in tokens]}")
```

## Dlaczego context ma znaczenie?

### 1. Koszt rośnie liniowo

```
Claude Sonnet 4.6: $3 / 1M input tokens

Rozmowa 10k tokenów:    $0.03 per request
Rozmowa 100k tokenów:   $0.30 per request   (10× drożej!)
Rozmowa 200k tokenów:   $0.60 per request

Bez prompt caching: każdy request płacisz pełną cenę.
Z prompt caching: cached tokens są ~10% ceny → $0.003.
```

### 2. Latency rośnie z kontekstem

```
Time to First Token (TTFT) zależy od długości kontekstu:
- 10k tokens:  ~500ms
- 100k tokens: ~3s
- 200k tokens: ~8s

To jest zauważalne dla użytkownika!
```

### 3. Quality DEGRADUJE z długim kontekstem

**"Lost in the middle"** — model gorzej znajduje informacje w środku długiego kontekstu. Eksperymenty pokazują:
- Top 10% kontekstu: ~95% accuracy
- Środek 50%: ~70% accuracy
- Koniec 10%: ~85% accuracy (recency bias)

**"Needle in a Haystack" benchmark** — testuje retrieval z długiego kontekstu. Modele 2026 są coraz lepsze, ale problem nie zniknął.

### 4. Hallucinations rosną z kontekstem

Przy 100k+ tokenów modele zaczynają mylić fakty, mieszać konteksty, halucynować.

## Strategie zarządzania kontekstem

### Strategia 1: Krótszy system prompt

**Problem:** wiele aplikacji ma system prompty 5000-15000 słów.

**Rozwiązanie:**

```
ZŁY system prompt (3000 słów):
"Jesteś asystentem klienta firmy XYZ. Firma została założona w 1995...
[Historia firmy]
[Lista wszystkich produktów]
[Wszystkie polityki zwrotu]
[Wszystkie cenniki]
..."

DOBRY system prompt (300 słów):
"Jesteś asystentem klienta firmy XYZ.
Twoje zadania: [3 punkty]
Twoje ograniczenia: [3 punkty]
W razie wątpliwości użyj narzędzia search_kb()."

+ Tool: search_kb(query) → zwraca relevantne fragmenty z KB

Efekt: 90% redukcja kosztu system promptu, lepsze wyniki
       (model nie zgubi się w 3000 słów).
```

### Strategia 2: RAG zamiast wrzucania wszystkiego

**Problem:** "Wrzucam całą bazę wiedzy w każdy request"

```
ŹLE:
prompt = full_knowledge_base + question  # 100k tokens każdy request

DOBRZE:
relevant_chunks = retrieve(question, top_k=5)  # 2k tokens
prompt = relevant_chunks + question  # 3k tokens
```

Oszczędność: 30-100× mniej tokenów. Patrz rozdział 09 (RAG).

### Strategia 3: Prompt caching (kluczowe w 2026)

**Anthropic, OpenAI, Google** wszyscy oferują prompt caching. **90% redukcja kosztu** dla cached części.

```python
# Anthropic prompt caching
client.messages.create(
    model="claude-opus-4-7",
    system=[
        {
            "type": "text",
            "text": LONG_SYSTEM_PROMPT,  # 5000 tokens
            "cache_control": {"type": "ephemeral"}  # ← CACHE
        },
        {
            "type": "text",
            "text": f"Context: {document}",  # 50k tokens
            "cache_control": {"type": "ephemeral"}  # ← CACHE
        }
    ],
    messages=[{"role": "user", "content": query}]
)

# Pierwszy request: full price (+25% cache write)
# Kolejne (w 5 min): cached parts są 10% ceny
```

**Workflow:**
1. Wrzuć stałe rzeczy (system, dokumenty, examples) z cache_control
2. Tylko user message zmienia się między requestami
3. 90% kosztu zniknie

### Strategia 4: Kompaktowanie historii

Gdy rozmowa rośnie, **podsumuj** stare wiadomości:

```python
def manage_conversation_context(messages, max_tokens=50_000):
    if total_tokens(messages) < max_tokens:
        return messages

    # Wymuś podsumowanie starszych wiadomości
    old = messages[:-10]  # zachowaj 10 ostatnich
    recent = messages[-10:]

    summary = llm.summarize(old)

    return [
        {"role": "system", "content": f"Earlier conversation summary: {summary}"},
        *recent
    ]
```

**Anthropic Claude Code i Cursor** robią to automatycznie — gdy zbliżasz się do limitu kontekstu, kompresują historię.

### Strategia 5: Sliding window

Dla bardzo długich rozmów — zachowaj tylko ostatnie N wiadomości:

```python
MAX_HISTORY = 20  # ostatnich 20 wymian
messages = messages[-MAX_HISTORY:]
```

**Trade-off:** zapominasz początek. Mityguj przez:
- System prompt z kluczowymi info ("user is named X, project is Y")
- External memory (zapisuj fakty do bazy)

### Strategia 6: External memory

Zamiast trzymać wszystko w kontekście — używaj bazy:

```
Każda rozmowa:
1. Retrieve relevant memories from DB
2. Add do system prompt (top 5)
3. Po rozmowie: extract new facts → save to DB
```

Patrz rozdział 11 (Memory systems w agentach).

### Strategia 7: Strukturyzacja zamiast prozy

```
ŹLE (200 tokenów):
"Klient powiedział że chciałby zamówić produkt o numerze ABC-123
w kolorze niebieskim, w rozmiarze L, na adres ulica Główna 5
w Warszawie z kodem pocztowym 00-001, płatność kartą..."

DOBRZE (50 tokenów):
order:
  product: ABC-123
  color: blue
  size: L
  shipping: ul. Główna 5, 00-001 Warszawa
  payment: card
```

**4× mniej tokenów**, model lepiej rozumie.

### Strategia 8: Skróty i kompresja

```
PROZA (100 tokens):
"Po pierwsze, zwróć uwagę na to że trzeba pamiętać o tym żeby
zawsze sprawdzać poprawność danych wejściowych przed ich..."

LISTA (30 tokens):
"Reguły:
1. Waliduj input
2. Sanitize SQL params
3. Escape output"
```

### Strategia 9: Tools zamiast informacji w prompcie

```
ŹLE: Wrzucam całą dokumentację API w prompt

DOBRZE: Daję narzędzie search_docs(query) i model używa tylko
        gdy potrzebuje
```

### Strategia 10: Wybór modelu pod task

```
Mała zadanie (klasyfikacja, ekstrakcja):  Haiku 4.5  → 32k context wystarczy
Średnia zadanie (generacja, analiza):     Sonnet 4.6  → 100k typically OK
Duże dokumenty:                            Opus 4.7   → 200k
Cały codebase:                             Gemini 2.5 → 1-2M
```

## Anatomia "context budget"

**Budget thinking** — planuj ile tokenów na co.

### Przykład: aplikacja chat z RAG

```
Total context budget: 100k tokens

Allocation:
├─ System prompt:           3k  (3%)
├─ Tool definitions:        1k  (1%)
├─ RAG retrieved docs:      8k  (8%)   ← top 5 chunks
├─ Conversation history:    20k (20%)  ← ostatnie 20 wymian
├─ Memory (long-term):      3k  (3%)   ← top 10 facts
├─ Current user message:    2k  (2%)
├─ Reserved for output:     8k  (8%)
└─ Buffer (safety):         55k (55%)  ← na nieoczekiwane

Hard limit per request: 45k actual usage.
```

### Token budgeting w kodzie

```python
class ContextBudget:
    def __init__(self, total: int, output_reserved: int = 8000):
        self.total = total
        self.output_reserved = output_reserved
        self.available = total - output_reserved

    def fit_messages(self, system, messages, rag_docs):
        used = 0
        used += count_tokens(system)
        used += count_tokens(rag_docs)

        if used > self.available * 0.8:
            # Compact RAG (mniej chunks)
            rag_docs = rag_docs[:3]
            used = count_tokens(system) + count_tokens(rag_docs)

        # Fit as many recent messages as possible
        fit_messages = []
        for msg in reversed(messages):
            msg_tokens = count_tokens(msg)
            if used + msg_tokens > self.available:
                break
            fit_messages.insert(0, msg)
            used += msg_tokens

        return system, fit_messages, rag_docs
```

## Jak rozpoznać że context jest problemem

### Symptomy

1. **"Lost in the middle"** — model nie odnajduje info które JEST w prompcie
2. **Zapomnienie instrukcji** — model nie przestrzega system prompta po długiej rozmowie
3. **Halucynacje** — zaczyna zmyślać fakty
4. **Wolny TTFT** — > 5s do pierwszego tokenu
5. **Wysokie koszty** — rachunek rośnie wykładniczo
6. **Errors "context_length_exceeded"** — przekraczasz limit

### Test: Needle in Haystack

Wpisz "ukryty fakt" w środek długiego promptu, zapytaj o niego na końcu.

```
prompt = (
    long_document[:50000] +
    "[UKRYTY FAKT: kod weryfikacyjny to 42-XYZ]\n" +
    long_document[50000:]
)

response = llm.ask(prompt + "\n\nJaki jest kod weryfikacyjny?")
# Czy znalazł?
```

## Praktyczne wskazówki

### 1. Mierz tokeny przed wysyłką

```python
import tiktoken

def safe_send(messages, max_context=180_000):
    enc = tiktoken.encoding_for_model("gpt-4o")
    total = sum(len(enc.encode(m["content"])) for m in messages)

    if total > max_context:
        raise ValueError(f"Too long: {total} > {max_context}")

    return llm.send(messages)
```

### 2. Loguj token usage

```python
response = llm.ask(prompt)
print(f"Input: {response.usage.input_tokens}")
print(f"Output: {response.usage.output_tokens}")
print(f"Cached: {response.usage.cache_read_tokens}")
print(f"Cost: ${calculate_cost(response.usage)}")

# Aggreguj per user, per feature, per day
```

### 3. Set hard limits per user/feature

```python
RATE_LIMITS = {
    "free_user":    {"daily_tokens": 100_000},
    "paid_user":    {"daily_tokens": 1_000_000},
    "enterprise":   {"daily_tokens": 50_000_000},
}

if user.tokens_used_today > RATE_LIMITS[user.tier]["daily_tokens"]:
    return "Daily limit reached. Upgrade or wait."
```

### 4. Use Batch API dla nie-real-time

**Anthropic, OpenAI Batch API:** **50% taniej**, async (godziny do dni).

Idealne dla:
- Analiza dokumentów hurtowo
- Klasyfikacja recenzji
- Generowanie summaries
- Eval datasets

### 5. Reasoning models = więcej output tokenów

Claude extended thinking, GPT-5 thinking, DeepSeek R1 mogą generować **dziesiątki tysięcy tokenów rozumowania**:

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=64000,  # zwiększ!
    thinking={"type": "enabled", "budget_tokens": 32000},
    messages=[{"role": "user", "content": "Solve this..."}]
)

# Output mogą być 50k tokenów (większość = thinking)
# Cost: tylko ~15-30% liczy się jako "visible output"
```

### 6. Stream output żeby user widział progress

Bez streamingu user czeka 30s i widzi nic. Ze streamingiem widzi tokens jak generowane.

```python
with client.messages.stream(...) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

### 7. Truncate inteligentnie

Jeśli musisz skrócić dokument:

```python
# ŹLE: ucięcie na środku
truncated = document[:50000]  # może uciąć w środku zdania

# DOBRZE: ucięcie na granicach
def smart_truncate(text, max_tokens, preserve="end"):
    """Truncate keeping start, middle, or end."""
    enc = tiktoken.get_encoding("cl100k_base")
    tokens = enc.encode(text)
    if len(tokens) <= max_tokens:
        return text

    if preserve == "end":
        return enc.decode(tokens[-max_tokens:])
    elif preserve == "start":
        return enc.decode(tokens[:max_tokens])
    else:  # middle
        half = max_tokens // 2
        return enc.decode(tokens[:half]) + "\n[...]\n" + enc.decode(tokens[-half:])
```

## Wskazówki specyficzne per model

### Claude (Anthropic)

**Co działa świetnie:**
- XML structure: `<context>...</context>` znacznie pomaga
- "Long context" — 200k używaj śmiało, model dobrze sobie radzi
- Prompt caching — zawsze włącz dla powtarzalnych części
- Extended thinking — dla skomplikowanych zadań włącz reasoning

**Pułapki:**
- Bez `cache_control` płacisz pełną cenę
- Extended thinking zjada output tokens — zwiększ `max_tokens`
- Stop sequences są ważne (Claude czasem kontynuuje za długo)

### GPT-5 / GPT-4o (OpenAI)

**Co działa:**
- Markdown format dobrze rozumie
- Function calling vs structured output (response_format)
- Prompt caching automatyczne (od 1024 tokens, nie trzeba flag)

**Pułapki:**
- 128k limit — łatwiej go przekroczyć niż 200k Claude
- Czasem ignoruje system prompt po wielu wiadomościach

### Gemini (Google)

**Co działa:**
- 1-2M context = możesz wrzucić **cały codebase**
- Multimodal native (obraz + tekst + audio + video)
- Świetne caching dla bardzo długich kontekstów

**Pułapki:**
- "Lost in the middle" wciąż problem przy 1M
- Inny tokenizer (różna liczba tokenów dla tego samego tekstu)
- Model ma tendencję do "lazy" przy dużym kontekście

### Llama / Mistral / Qwen (open source)

**Co działa:**
- Self-host = nie ma kosztu per token
- Możesz zwiększyć kontekst (RoPE scaling) z pewnymi trade-offami

**Pułapki:**
- Większość trenowanych do 8-32k, dłuższy kontekst = degradacja
- KV cache zjada VRAM dramatycznie przy długich kontekstach
- Quantization (Q4) zwiększa "lost in the middle"

## Anti-patterns do unikania

### ❌ "Wrzucę cały dokument"

```python
# ŹLE
response = llm.ask(f"Cały dokument: {entire_book}\n\nPytanie: ...")
# 500k tokenów = $$$$ + lost in middle
```

```python
# DOBRZE
chunks = retrieve(question, top_k=5)
response = llm.ask(f"Relevant: {chunks}\n\nPytanie: ...")
```

### ❌ "Jeszcze jeden few-shot"

Każdy few-shot example = 200-500 tokenów. Po 10 examples masz 5k tokenów którzy płacisz w każdym requeście.

```python
# Sprawdź czy wszystkie examples są potrzebne
# Często 2-3 reprezentatywne wystarczą
# Lub: użyj fine-tuningu zamiast wielu shots
```

### ❌ Powtarzanie info

```
ŹLE:
- W system prompt: "Mów tylko po polsku"
- W każdej wiadomości: "Pamiętaj, po polsku!"
- Po każdej odpowiedzi user: "Po polsku!"

DOBRZE:
- W system prompt: "Mów tylko po polsku" (raz)
- Jeśli model myli języki — zmień model lub fine-tune
```

### ❌ Brak garbage collection w historii

Aplikacje konwersacyjne często trzymają **całą** historię. Po 100 wiadomościach masz 50k tokenów, większość nieprzydatna.

```python
# DOBRZE: kompaktuj stare
if len(messages) > 30:
    messages = compact_old_messages(messages, keep_recent=20)
```

### ❌ Zapomnienie o multi-turn

```
Pierwszy prompt: 5k tokens (system + user)
Po 50 wymian: 100k tokens (cała historia + każda odpowiedź)
```

Każda nowa wymiana KOPIUJE całą poprzednią historię. Koszt rośnie kwadratowo!

## Tools i biblioteki

### Liczenie tokenów
- **tiktoken** (Python) — OpenAI
- **anthropic-tokenizer** — Claude
- **transformers AutoTokenizer** — open source models
- **gpt-tokenizer** (JS/TS)
- **OpenAI Tokenizer** (web playground)
- **Anthropic Console** ma counter

### Context management
- **LangChain ConversationBufferWindowMemory** — sliding window
- **LangChain ConversationSummaryMemory** — auto-summary
- **LlamaIndex** — wbudowane chunking i retrieval
- **mem0** — managed memory layer dla agentów
- **Letta** (dawniej MemGPT) — open source memory

### Cost tracking
- **Helicone** — proxy + analytics
- **Langfuse** — open source observability
- **LangSmith** — LangChain native
- **OpenAI Usage dashboard** — built-in

### Compression
- **LLMLingua** (Microsoft) — kompresja promptów (2-10×)
- **AutoCompressor** — semantic compression
- **GPT-4 sumarization** jako pre-processing

## Pattern: Hierarchical context

Dla bardzo dużych dokumentów (książki, codebases):

```
┌────────────────────────────┐
│  Level 1: TOC + summary    │  ← zawsze w prompcie (1k tokens)
└──────────┬─────────────────┘
           │
           ▼ (model decyduje co potrzebuje)
┌────────────────────────────┐
│  Level 2: Section summary  │  ← retrieval gdy potrzeba (5k)
└──────────┬─────────────────┘
           │
           ▼
┌────────────────────────────┐
│  Level 3: Full section     │  ← retrieval ostatecznie (20k)
└────────────────────────────┘
```

Model widzi summary, decyduje czy zoomować w details. Jak Google Maps zoom in.

## Mierzenie efektywności kontekstu

### Metryki do trackowania

| Metryka | Cel | Jak mierzyć |
|---------|-----|-------------|
| **Input tokens / request** | minimalizuj | log z API |
| **Cache hit rate** | maksymalizuj (>70%) | usage.cache_read_tokens / total |
| **Output tokens / request** | dopasuj do potrzeby | log |
| **Cost per query** | track per feature | sum × model price |
| **Context utilization** | używasz całego budgetu? | tokens / max_context |
| **TTFT (Time to First Token)** | < 2s dla good UX | client-side mierzony |
| **Failure rate (context_length_exceeded)** | 0 | log błędów |

### Dashboard w Langfuse / Helicone

```
┌───────────────────────────────────────┐
│  Token usage by feature              │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     │
│  Chat:        45M tokens / mc         │
│  RAG:         120M / mc (most cost!)  │
│  Email gen:   8M / mc                 │
│  Classifier:  3M / mc                 │
│                                       │
│  Cache hit rate: 72% ✓                │
│  Avg context utilization: 35%         │
│  P95 TTFT: 2.4s                       │
└───────────────────────────────────────┘
```

## Decyzja: long context vs RAG

W 2026 z modelami 1M+ kontekstu pojawiło się pytanie: **czy RAG jest jeszcze potrzebny?**

### Long context wygrywa gdy:
- Dokument < 500k tokenów (mieści się w 1M Gemini)
- Zapytania wymagają **całościowego** zrozumienia
- Niska liczba zapytań (< 100/dzień)
- Złożone reasoning po dokumencie
- Aktualizacja dokumentu rzadka

### RAG wygrywa gdy:
- Korpus > 1M tokenów (TB tekstu)
- Wysoka liczba zapytań (RAG dramatycznie tańszy per query)
- Częste aktualizacje (RAG = dodaj dokument, long context = re-process)
- Wymagane cytowanie źródeł
- Selektywne info wystarczy

### Hybrid (zalecane w 2026):
```
1. Retrieval pobiera top-50 chunks
2. Long-context model (Gemini 1M) przetwarza wszystkie 50
3. Gemini decyduje co relevantne, generuje odpowiedź

Best of both worlds:
- Retrieval = filtrowanie z TB
- Long context = kompletny widok dla relevantnych
```

## Praktyczny checklist

Przed wysłaniem requestu zapytaj się:

- [ ] Czy potrzebuję wszystkich tych tokenów?
- [ ] Czy system prompt jest zoptymalizowany?
- [ ] Czy włączyłem prompt caching dla stałych części?
- [ ] Czy używam RAG zamiast wrzucać wszystko?
- [ ] Czy historia rozmowy jest skompaktowana?
- [ ] Czy mierzę i loguję usage?
- [ ] Czy testuję "needle in haystack" dla mojego use case?
- [ ] Czy wybrałem właściwy model (mały dla prostych task)?
- [ ] Czy mam fallback gdy context exceeded?
- [ ] Czy mam rate limits per user?

## Praktyczne reguły kciuka (2026)

```
1. Cel: < 30% wykorzystania context window
   200k limit → trzymaj się 60k typically

2. Cache hit rate > 70%
   Jeśli niższy → reorganizuj prompt structure

3. Output max_tokens: ustaw realistic limit
   Bez tego model może gadać 8k tokenów niepotrzebnie

4. Token cost > $0.10 per request?
   Sprawdź czy potrzebujesz, czy możesz zopt.

5. RAG > 5k tokens retrieved?
   Lepszy reranking, mniej top_k

6. History > 20 wiadomości?
   Skompaktuj lub sliding window

7. System prompt > 1000 słów?
   Refaktor, użyj tools zamiast info w prompcie

8. Latency > 3s?
   Skróć kontekst lub mniejszy model
```

## Dla developerów: snippets

### Token counter helper

```python
import tiktoken
from typing import List, Dict

class TokenCounter:
    def __init__(self, model: str = "gpt-4o"):
        try:
            self.enc = tiktoken.encoding_for_model(model)
        except KeyError:
            self.enc = tiktoken.get_encoding("cl100k_base")

    def count(self, text: str) -> int:
        return len(self.enc.encode(text))

    def count_messages(self, messages: List[Dict]) -> int:
        # Approximation — actual is +3 tokens per message overhead
        total = 0
        for m in messages:
            total += 3  # role tokens
            total += self.count(m.get("content", ""))
        return total

    def truncate_to_fit(self, text: str, max_tokens: int) -> str:
        tokens = self.enc.encode(text)
        if len(tokens) <= max_tokens:
            return text
        return self.enc.decode(tokens[:max_tokens])

# Usage
counter = TokenCounter()
print(counter.count("Hello world"))  # 2
print(counter.count_messages([
    {"role": "user", "content": "Hi"}
]))  # ~4
```

### Conversation manager

```python
class ConversationManager:
    def __init__(
        self,
        max_tokens: int = 100_000,
        keep_recent: int = 10,
        summarize_threshold: int = 50_000,
    ):
        self.max_tokens = max_tokens
        self.keep_recent = keep_recent
        self.summarize_threshold = summarize_threshold
        self.counter = TokenCounter()

    def manage(self, messages, summarizer_llm):
        total = self.counter.count_messages(messages)

        if total < self.summarize_threshold:
            return messages

        # Summarize old messages
        old = messages[:-self.keep_recent]
        recent = messages[-self.keep_recent:]

        summary = summarizer_llm.ask(
            f"Summarize this conversation in 200 words:\n{old}"
        )

        return [
            {"role": "system", "content": f"Earlier: {summary}"},
            *recent
        ]

    def force_fit(self, messages):
        """Hard truncate if still too long"""
        while self.counter.count_messages(messages) > self.max_tokens:
            if len(messages) <= 2:
                # Truncate content
                messages[-1]["content"] = self.counter.truncate_to_fit(
                    messages[-1]["content"],
                    self.max_tokens // 2
                )
                break
            messages = messages[1:]  # drop oldest
        return messages
```

## Najczęstsze błędy w kontekście

### 1. "Mam 200k, używam wszystkie"
Nawet jeśli model wspiera 200k, **używaj minimum potrzebne**. Mniej = szybciej + taniej + lepsza jakość.

### 2. "Cachowanie nie działa u mnie"
- Sprawdź czy używasz `cache_control` (Anthropic) lub że prompt > 1024 tokens (OpenAI)
- Cache TTL: Anthropic 5 min, dłuższy z `cache_control: 1h` (premium)
- Cache invalidation: jakakolwiek zmiana w cached części = miss

### 3. "Liczę tokeny w słowach"
Liczba słów ≠ tokens. **Zawsze używaj tokenizera** dla dokładnych liczb.

### 4. "Pomijam tool definitions w liczeniu"
Tool definitions też zajmują tokens (czasem 1-3k!). Loguj.

### 5. "System prompt to mała sprawa"
W aplikacji z 1M requestów/mc, każdy 1000 tokenów w system prompcie = $3000/mc. Optymalizuj.

## Testowanie wpływu kontekstu

### A/B test: krótki vs długi system prompt

```python
SYSTEM_LONG = "..."   # 5000 słów
SYSTEM_SHORT = "..."  # 500 słów + tools

# Test na eval datasecie
results_long = evaluate(SYSTEM_LONG, eval_set)
results_short = evaluate(SYSTEM_SHORT, eval_set)

# Porównaj:
# - Accuracy
# - Cost per request
# - Latency
# - User satisfaction
```

Często **krótszy działa lepiej** — model ma jasne instrukcje bez "zagubienia".

## Przyszłość (2026+)

### Trend: Infinite context
Modele coraz lepiej radzą sobie z długim kontekstem. Gemini ma 2M, są eksperymenty z 100M+. Jednak:
- Koszt rośnie liniowo
- "Lost in the middle" wciąż problem
- KV cache jest bottleneck

### Trend: Smart context management
- Modele uczą się **same** kompresować historię
- Hierarchiczne attention
- Memory tokens (model ma "scratchpad")
- Recursive summarization w trakcie generacji

### Trend: External memory dominuje
Mimo dużych kontekstów, **agenci z external memory** (mem0, Letta) zyskują popularność. Zalety:
- Pamięć przekracza limity kontekstu
- Persystentna między sesjami
- Selektywna recall

## Podsumowanie — 10 najważniejszych zasad

1. **Mierz tokeny** — bez tego nic nie zmienisz
2. **Loguj koszt** per request, per feature, per user
3. **Krótszy system prompt** > długi monolit (rozbij na tools)
4. **Prompt caching** — zawsze włącz, 90% redukcja kosztu
5. **RAG** zamiast wrzucania całego dokumentu
6. **Kompaktuj historię** w długich rozmowach
7. **Mniejszy model** dla prostych zadań (Haiku zamiast Opus)
8. **Stream output** dla lepszego UX
9. **Test "needle in haystack"** dla swojego use case
10. **Hard limits** per user/feature żeby uniknąć overspendingu
