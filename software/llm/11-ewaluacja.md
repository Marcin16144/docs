# Ewaluacja modeli LLM

## Dlaczego ewaluacja jest trudna?

**LLM nie produkują "poprawnej" odpowiedzi** — są generatywne. Ta sama prawidłowa odpowiedź może być wyrażona na 100 sposobów. Klasyczne metryki ML (accuracy, F1) nie wystarczają.

### Wyzwania:
- Subiektywność (co to "dobra" odpowiedź?)
- Wielość poprawnych odpowiedzi
- Kontekst jest kluczowy (ta sama odpowiedź dobra w jednym kontekście, zła w innym)
- Halucynacje vs kreatywność (cienka granica)
- Koszt human eval — ludzie są drogo

## Rodzaje ewaluacji

### 1. Benchmarki (akademickie)

Standardowe testy używane do porównań modeli.

| Benchmark | Co mierzy | Format |
|-----------|-----------|--------|
| **MMLU** | Wiedza ogólna (57 dziedzin) | Multiple choice |
| **MMLU-Pro** | Trudniejsza wersja MMLU | Multiple choice |
| **GPQA** | Trudne pytania naukowe (PhD-level) | Multiple choice |
| **HumanEval** | Kod (Python) | Generacja funkcji |
| **HumanEval+** | Rozszerzony HumanEval z więcej testami | Generacja |
| **MBPP** | Podstawowe problemy programistyczne | Generacja |
| **SWE-Bench** | Real GitHub issues | Multi-file edits |
| **GSM8K** | Matematyka szkolna | Free-form |
| **MATH** | Matematyka olimpijska | Free-form |
| **AIME** | Math competitions | Free-form |
| **TruthfulQA** | Faktualność, anti-bullshit | Multiple choice |
| **HellaSwag** | Common sense | Multiple choice |
| **ARC** | Rozumowanie naukowe | Multiple choice |
| **BBH** | Big Bench Hard | Various |
| **MT-Bench** | Multi-turn chat | LLM judge |
| **AlpacaEval 2** | Instruction following | LLM judge |
| **LiveBench** | Aktualizowany co miesiąc | Various |
| **Arena Elo** | Ranking z porównań ludzi | ELO |

### 2. Custom evals (Twoje)

**Najważniejsze!** Generic benchmarki nie powiedzą Ci czy model działa dla Twojego use case.

```python
# Przykład eval dataset
eval_dataset = [
    {
        "input": "Czy mogę odstąpić od umowy konsumenckiej w 14 dni?",
        "expected": "TAK",
        "criteria": "Musi wspomnieć o ustawowym 14-dniowym terminie"
    },
    # ... 50-200 przykładów
]
```

### 3. A/B testing
Produkcyjny test — pokaż 50% userów wariant A, 50% wariant B, mierz outcome.

### 4. Human eval
Ludzie oceniają odpowiedzi (1-5, Likert) lub porównują pary.

### 5. LLM-as-judge
Model (np. Claude Opus, GPT-5) ocenia inne modele.

## LLM-as-Judge

W 2024-2026 stał się **standardem**. Mocny LLM ocenia output słabszego.

```python
JUDGE_PROMPT = """
Oceń odpowiedź AI w skali 1-10 pod kątem:
- Faktualności
- Pomocności
- Klarowności
- Bezpieczeństwa

PYTANIE: {question}
ODPOWIEDŹ: {answer}
KONTEKST (źródła): {context}

Twoja ocena (JSON):
{{
  "factuality": <1-10>,
  "helpfulness": <1-10>,
  "clarity": <1-10>,
  "safety": <1-10>,
  "reasoning": "<wyjaśnienie>"
}}
"""

result = judge_llm.generate(JUDGE_PROMPT.format(...))
```

### Pros LLM-as-judge:
- Skalowalna (tysiące eval w godzinach)
- Tania (vs human ~$0.01-0.10 per eval)
- Konsystentna (z jednym modelem)
- Może oceniać niuansowane criteria

### Cons:
- **Bias** — judge favoryzuje styl podobny do siebie
- **Position bias** — pierwsza odpowiedź często wygrywa (mitygacja: shuffle)
- **Length bias** — dłuższe odpowiedzi wygrywają
- **Self-preference** — GPT ocenia GPT lepiej niż Claude

### Najlepsze praktyki:
1. **Pair-wise** lepsze niż scoring (porównanie A vs B)
2. **Multiple judges** — średnia z 3 różnych modeli
3. **CoT prompting** — judge musi uzasadnić ocenę
4. **Constitutional criteria** — eksplicite zasady
5. **Calibracja** — porównaj judge z human evals

## Pareto frontier — wybór modelu

Nie szukaj "najlepszego modelu". Szukaj **najlepszego dla ceny / latency / privacy**.

```
       Quality
         ▲
    100% │   ★ Claude Opus 4.7
         │     ★ GPT-5
     90% │       ★ Claude Sonnet 4.6
         │         ★ Gemini 2.5 Pro
     80% │           ★ Llama 4 Maverick
         │             ★ Claude Haiku 4.5
     70% │               ★ Llama 3.1 70B
         │                 ★ Llama 4 Scout
     60% │                   ★ Llama 3 8B
         │
         └────────────────────────────► Cost
            $$$$  $$$  $$  $  $0
```

## Frameworki ewaluacji

### Promptfoo
**Najpopularniejszy** open source eval framework.

```yaml
# promptfooconfig.yaml
prompts:
  - "Translate to French: {{input}}"
providers:
  - anthropic:claude-sonnet-4-6
  - openai:gpt-5
tests:
  - vars:
      input: "Hello world"
    assert:
      - type: contains-any
        value: ["Bonjour", "Salut"]
      - type: llm-rubric
        value: "Translation should be grammatically correct"
```

```bash
promptfoo eval
promptfoo view  # web UI
```

### DeepEval
Pytest-style testing dla LLM.

```python
from deepeval import assert_test
from deepeval.metrics import AnswerRelevancyMetric

def test_answer():
    metric = AnswerRelevancyMetric(threshold=0.7)
    test_case = LLMTestCase(
        input="Co to jest mikroserwis?",
        actual_output=llm_response,
        expected_output="Mikroserwis to..."
    )
    assert_test(test_case, [metric])
```

### Ragas (specjalnie dla RAG)
```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness, answer_relevancy,
    context_precision, context_recall
)

result = evaluate(
    dataset=test_data,
    metrics=[faithfulness, answer_relevancy, context_precision]
)
```

### LangSmith / Langfuse
Production monitoring + eval w jednym.

```python
# Langfuse — open source
from langfuse import Langfuse
langfuse = Langfuse()

# Loguj traces, eval automatycznie
trace = langfuse.trace(name="user_query")
trace.span(name="retrieval", input=query, output=docs)
trace.span(name="generation", input=context, output=response)
trace.score(name="faithfulness", value=0.85)
```

### Braintrust ($)
Komercyjna platforma eval, najwygodniejsza w 2026.

### Inne
- **lm-evaluation-harness** (EleutherAI) — standard dla benchmarków akademickich
- **OpenAI Evals** — open source framework OpenAI
- **TruLens** — observability + eval, open source
- **Phoenix (Arize)** — open source observability
- **Patronus AI** ($$) — automated eval i safety
- **Galileo** ($$) — enterprise

## Pipeline ewaluacji w produkcji

```
1. Stwórz eval dataset (50-200 przykładów reprezentatywnych)
   ↓
2. Zdefiniuj metryki (faithfulness, latency, cost, ...)
   ↓
3. Run eval przed każdym deployem (CI/CD)
   ↓
4. A/B test w produkcji
   ↓
5. Continuous monitoring (Langfuse/LangSmith)
   ↓
6. Anomaly detection (alerty na regresje)
   ↓
7. Loop: nowe edge cases → dataset → eval
```

## Eval dataset — jak zbudować

### Źródła:
1. **Real production logs** — najlepsze!
2. **Manual creation** — domain experts
3. **Synthetic** — LLM generuje (uważaj na bias)
4. **Public datasets** — adapter do swojej domeny

### Co powinien zawierać:
- **Happy paths** — typowe przypadki (60%)
- **Edge cases** — rzadkie, trudne (25%)
- **Adversarial** — próby wymanewrowania modelu (10%)
- **Out of scope** — pytania spoza zakresu (5%)

### Rozmiar:
- **Smoke test**: 10-20 przykładów (CI każdy commit)
- **Regression test**: 50-100 (przed każdym deployem)
- **Comprehensive**: 500-2000 (cotygodniowo)
- **A/B test production**: 1000+ real users

## Metryki produkcyjne

Poza jakością merytoryczną — mierz:

| Metryka | Cel |
|---------|-----|
| **Latency p50/p95/p99** | Time-to-first-token, time-to-completion |
| **Cost per query** | Total LLM cost / number of queries |
| **Token usage** | Input/output tokens, cache hit rate |
| **Error rate** | 4xx, 5xx, timeouts |
| **User satisfaction** | Thumbs up/down, feedback |
| **Containment rate** | (chatboty) % zapytań rozwiązanych bez eskalacji |
| **Hallucination rate** | % faktycznie błędnych odpowiedzi |
| **Refusal rate** | % zbyt ostrożnych refusal |
| **Safety violations** | Jailbreaks, harmful content |

## Bias i safety eval

### Bias
- **BBQ** — Bias Benchmark for Q&A
- **CrowS-Pairs** — stereotype detection
- **WinoBias** — gender bias

### Safety
- **HarmBench** — harmfulness
- **AdvBench** — adversarial prompts
- **AILuminate** — comprehensive safety eval

### Tools:
- **Llama Guard** (Meta) — open source content classifier
- **PromptArmor** — comprehensive safety
- **Lakera Guard** — anti-injection

## Reasoning evals (2025-2026 trend)

Nowoczesne benchmarki dla reasoning models:
- **GPQA Diamond** — najtrudniejsze pytania naukowe
- **AIME** — matematyka olimpijska
- **HLE (Humanity's Last Exam)** — extremely hard
- **ARC-AGI** — abstract reasoning
- **FrontierMath** — research-level math
- **SWE-Bench Verified** — real GitHub issues

Modele typu o3, Claude z extended thinking, DeepSeek R1 osiągają dramatycznie lepsze wyniki niż klasyczne LLM.

## Praktyczny workflow ewaluacji

### Faza 1: Setup (jednorazowo)
1. Zbuduj eval dataset (50 przykładów + ground truth)
2. Wybierz 3-5 metryk (jakość + cost + latency)
3. Zaimplementuj harness (promptfoo / DeepEval)

### Faza 2: Każda zmiana modelu/promptu
4. Run eval lokalnie
5. Porównaj z baseline
6. Ship tylko gdy improvement (z istotnością statystyczną)

### Faza 3: Production
7. Loguj wszystkie request/response (Langfuse)
8. Sample 1% do continuous eval
9. Alerty na regresje

### Faza 4: Continuous improvement
10. Analizuj failure cases
11. Dodaj do eval dataset
12. Iteruj

## Pułapki ewaluacji

1. **Overfitting do benchmarka** — model dobrze na MMLU, słabo w produkcji
2. **Test set contamination** — model widział benchmark w treningu
3. **Cherry-picking metric** — tylko metryki gdzie wygrywasz
4. **Brak baseline** — bez porównania nie wiesz czy poprawiasz
5. **Mała próbka** — 10 przykładów to za mało (noise)
6. **Brak human eval** — LLM-judge to nie wszystko
7. **Outdated dataset** — świat się zmienia, eval też musi

## Top dashboards porównań modeli

W 2026 do śledzenia state-of-the-art:
- **lmarena.ai** (LMSys Chatbot Arena) — ELO ranking z human votes
- **livebench.ai** — uncontaminated benchmarks
- **Artificial Analysis** — comprehensive comparisons
- **OpenLLM Leaderboard** (HuggingFace) — open source models
- **Berkeley Function-Calling Leaderboard** — tool use
- **SWE-bench** — coding tasks

## Praktyczna rada

**Najlepsza eval to Twoja własna**, na realnych przykładach z Twojej aplikacji. Generic benchmarki to tylko punkt startowy.

```
50 dobrze dobranych przykładów >>> 5000 z public benchmarka
```

Inwestuj czas w **eval dataset** — wracasz do niego setki razy.
