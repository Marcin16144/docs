# Model proxy (router / cascade) — model, który deleguje gdy nie wie

## O co chodzi

Chcesz zbudować model, który **sam odpowiada na to, co umie**, a gdy **nie wie — odwołuje się do innych modeli** (większych, specjalistycznych albo chmurowych). To klasyczny wzorzec zwany **LLM router**, **model gateway** albo **cascade**.

**Najważniejsza rzecz na start:** model proxy to **NIE** jest model trenowany od zera. To **warstwa orkiestracji** (kilkadziesiąt linii kodu) + opcjonalnie mały klasyfikator decydujący o trasie. Nie potrzebujesz klastra GPU ani milionów dolarów — potrzebujesz dobrego mechanizmu "wiem, że nie wiem".

```
            ┌──────────────────────┐
   pytanie  │   MODEL PROXY        │
 ──────────▶│  (mały, lokalny)     │
            └─────────┬────────────┘
                      │ ocena pewności
              ┌───────┴────────┐
        pewny │                │ niepewny / nie wie
              ▼                ▼
       ┌────────────┐   ┌──────────────────┐
       │ odpowiedz  │   │  ESKALACJA        │
       │ lokalnie   │   │  duży / cloud /   │
       │ (tanio)    │   │  specjalista      │
       └────────────┘   └──────────────────┘
```

## Terminologia — co to naprawdę jest

Ludzie mylą "model proxy" z MoE. To różne rzeczy:

| Pojęcie | Co routuje | Granularność | Gdzie żyje |
|---------|-----------|--------------|------------|
| **Model proxy / router** | między osobnymi modelami | per zapytanie | warstwa aplikacji |
| **Cascade** (FrugalGPT) | tani → drogi, sekwencyjnie | per zapytanie | warstwa aplikacji |
| **Mixture of Agents (MoA)** | wiele modeli równolegle + agregacja | per zapytanie | warstwa aplikacji |
| **MoE** (Mixture of Experts) | między ekspertami **wewnątrz 1 modelu** | per token | wewnątrz wag modelu |

To, co opisujesz ("jak nie wie, pyta innych"), to **cascade z bramką pewności** — najprostszy i najtańszy wariant routera. MoE to coś zupełnie innego (routing wewnątrz jednego modelu) — nie myl tych dwóch.

## Wzorce architektoniczne

### A) Pre-routing (klasyfikuj → wybierz model PRZED generacją)
Lekki klasyfikator patrzy na pytanie i od razu kieruje je do właściwego modelu. Zero podwójnego kosztu, ale wymaga dobrego klasyfikatora.
```
pytanie → [router/klasyfikator] → wybór modelu → odpowiedź
```

### B) Cascade / fallback (próbuj tanio → eskaluj gdy niepewny)
Dokładnie Twój scenariusz. Najpierw mały model, a jeśli "nie wie" — większy. Prosty, ale płacisz za obie próby przy eskalacji.
```
pytanie → mały → pewny? → TAK: zwróć
                       └── NIE: → duży → zwróć
```

### C) Mixture of Agents (pytaj kilka, agreguj)
Kilka modeli odpowiada równolegle, model-agregator scala. Najlepsza jakość, najwyższy koszt.

### D) Verifier / judge
Mały model odpowiada, drugi model (lub ten sam) **weryfikuje** odpowiedź; jeśli weryfikacja wypada źle → eskalacja.

> Dla Twojego celu zacznij od **B (cascade)**. Gdy zbierzesz dane z logów, dołóż **A (pre-routing)**, żeby uniknąć podwójnego kosztu.

## Sedno problemu: skąd model wie, że "nie wie"?

To jest cała trudność. LLM domyślnie brzmi pewnie nawet gdy halucynuje. Musisz dołożyć **sygnał pewności**. Metody (od najprostszej):

### 1. Self-evaluation (structured output) — najłatwiejsze
Każ modelowi zwrócić JSON z polem `confidence` i instrukcją: "jeśli nie znasz odpowiedzi, ustaw confidence < 0.5".
```json
{"answer": "...", "confidence": 0.0-1.0, "domain": "..."}
```
Działa zaskakująco dobrze jako pierwsza bramka. Wada: model bywa **przesadnie pewny** (słaba kalibracja).

### 2. Logprobs / perplexity
Niska średnia prawdopodobieństwa tokenów = model "się waha". Próg na perplexity → eskalacja. Wymaga modelu zwracającego logprob-y (Ollama/llama.cpp potrafią).

### 3. Self-consistency (semantic entropy)
Spróbuj N razy z `temperature>0`. Jeśli odpowiedzi się **rozjeżdżają** → model nie wie → eskaluj. Drogie (N wywołań), ale najlepiej koreluje z halucynacjami (Nature 2024, "semantic entropy").

### 4. Heurystyki
Wykrycie fraz typu "nie jestem pewien", "nie mam informacji", wykrycie domeny poza zakresem (np. pytanie o świeże dane → cutoff), bardzo krótka/pusta odpowiedź.

### 5. Verifier model
Osobny (mały) model-sędzia ocenia odpowiedź: "Czy ta odpowiedź jest poprawna i kompletna? TAK/NIE".

> Szczegóły mierzenia wiedzy modelu i kalibracji — patrz rozdział **11-01 Weryfikacja wiedzy modelu**. Pamiętaj: surowe `confidence` bez kalibracji **kłamie** — zawsze zwaliduj próg na realnych danych.

## Implementacja krok po kroku (Ollama + fallback do chmury)

Pod Twój sprzęt (RTX 5060 8GB): proxy = mały model lokalny przez Ollama, eskalacja = większy model w chmurze (lub większy lokalny, jeśli masz VRAM).

```python
import json
import ollama                      # pip install ollama
from anthropic import Anthropic    # pip install anthropic

LOCAL_MODEL  = "llama3.2:3b"          # proxy / drzwi frontowe (mały, lokalny, darmowy)
REMOTE_MODEL = "claude-sonnet-4-6"    # eskalacja (duży, płatny)
CONF_THRESHOLD = 0.7

client = Anthropic()  # czyta ANTHROPIC_API_KEY ze środowiska

SYSTEM = """Jesteś asystentem-proxy. Odpowiadaj rzetelnie, ale TYLKO gdy jesteś pewien.
Zwróć WYŁĄCZNIE JSON: {"answer": "...", "confidence": 0.0-1.0, "domain": "..."}.
Jeśli nie znasz odpowiedzi lub się wahasz, ustaw confidence poniżej 0.5."""

def ask_local(question: str) -> dict:
    resp = ollama.chat(
        model=LOCAL_MODEL,
        messages=[{"role": "system", "content": SYSTEM},
                  {"role": "user",   "content": question}],
        format="json",                 # wymuś poprawny JSON
        options={"temperature": 0},
    )
    return json.loads(resp["message"]["content"])

def ask_remote(question: str) -> str:
    msg = client.messages.create(
        model=REMOTE_MODEL,
        max_tokens=1024,
        messages=[{"role": "user", "content": question}],
    )
    return msg.content[0].text

def proxy(question: str) -> dict:
    local = ask_local(question)
    if local.get("confidence", 0) >= CONF_THRESHOLD:
        return {"source": LOCAL_MODEL, "answer": local["answer"]}
    # model "nie wie" — deleguj do większego
    return {"source": REMOTE_MODEL, "answer": ask_remote(question)}

print(proxy("Ile to 2+2?"))                        # → lokalny (pewny)
print(proxy("Udowodnij twierdzenie Gödla o niezupełności"))  # → eskalacja
```

### Wariant z self-consistency (gdy nie ufasz `confidence`)
```python
from collections import Counter

def ask_local_consistent(question: str, n: int = 5) -> tuple[str, float]:
    answers = []
    for _ in range(n):
        r = ollama.chat(model=LOCAL_MODEL,
                        messages=[{"role": "user", "content": question}],
                        options={"temperature": 0.7})
        answers.append(r["message"]["content"].strip())
    top, count = Counter(answers).most_common(1)[0]
    return top, count / n          # zgodność jako pewność

answer, agreement = ask_local_consistent("Stolica Australii?")
if agreement < 0.6:               # odpowiedzi się rozjechały → nie wie
    answer = ask_remote("Stolica Australii?")
```

## Gotowe narzędzia — nie wymyślaj koła na nowo

Zanim napiszesz własny router, sprawdź te (kolejność: najpierw open-source / darmowe):

| Narzędzie | Co robi | Licencja | Uwagi |
|-----------|---------|----------|-------|
| **LiteLLM** | proxy/gateway, fallback przy błędzie, retry, load-balance | open source | jednolite API do 100+ modeli; standard branżowy |
| **RouteLLM** (LMSYS/Berkeley) | wytrenowany router weak↔strong | open source | router uczony na danych preferencji |
| **Semantic Router** (Aurelio) | routing po embeddingach (intencja) | open source | bardzo szybki, deterministyczny |
| **OpenRouter** | hostowany gateway do wielu modeli | usługa (ma free tier) | dobre do prototypu, darmowe modele w ofercie |
| **NotDiamond** | router-as-a-service | usługa | dobiera model pod zapytanie |
| **Martian** | komercyjny model router | usługa | optymalizacja koszt/jakość |

**Ważne rozróżnienie:** LiteLLM robi fallback **przy błędzie/timeout** (model padł, limit), a NIE "przy niskiej pewności". Routing typu "model nie wie" musisz dołożyć sam (bramka pewności wyżej) albo użyć RouteLLM. To dwa różne fallbacki — nie myl ich.

### Minimalny szkielet na LiteLLM (fallback przy błędzie)
```python
from litellm import completion        # pip install litellm

response = completion(
    model="ollama/llama3.2:3b",                  # próbuj najpierw lokalnie
    messages=[{"role": "user", "content": "..."}],
    fallbacks=["claude-sonnet-4-6", "gpt-4o"],   # gdy lokalny zawiedzie
)
```

### RouteLLM (wytrenowany pre-router)
```python
from routellm.controller import Controller       # pip install routellm

client = Controller(
    routers=["mf"],                               # matrix-factorization router
    strong_model="claude-sonnet-4-6",
    weak_model="ollama/llama3.2:3b",
)
resp = client.chat.completions.create(
    model="router-mf-0.11593",                    # próg skalibrowany pod budżet
    messages=[{"role": "user", "content": "..."}],
)
```

## Trenowanie własnego routera "od zera" (opcjonalnie)

Jeśli chcesz prawdziwy własny model-router (a nie heurystykę), wytrenuj **mały klasyfikator** decydujący "zostań lokalnie vs eskaluj". To jest ta część, którą realnie "tworzysz od podstaw".

**Skąd dane?** Z logów własnego cascade'a: dla każdego pytania zapisz, czy mały model wystarczył (`1`) czy trzeba było eskalować (`0`).

```python
# pip install sentence-transformers scikit-learn
from sentence_transformers import SentenceTransformer
from sklearn.linear_model import LogisticRegression

emb = SentenceTransformer("all-MiniLM-L6-v2")     # mały, lokalny, darmowy

X = emb.encode([row["question"] for row in logs]) # logi z cascade'a
y = [row["local_was_enough"] for row in logs]      # 1 = zostań, 0 = eskaluj

router = LogisticRegression().fit(X, y)

def should_stay_local(question: str) -> bool:
    x = emb.encode([question])
    return router.predict_proba(x)[0][1] >= 0.5
```

To **pre-router** (wzorzec A): podejmuje decyzję bez uruchamiania dużego modelu → zero podwójnego kosztu. Gdy zbierzesz więcej danych, możesz zamienić regresję logistyczną na fine-tune małego BERT/DistilBERT albo małego LLM jako klasyfikatora.

## Koszt i latencja — kompromisy

Sens cascade'a to **oszczędność**: mały lokalny model łapie większość zapytań za darmo.

```
E[koszt] = p · c_lokalny + (1−p) · (c_lokalny + c_zdalny)
         = c_lokalny + (1−p) · c_zdalny        (przy eskalacji płacisz OBA)

p          = odsetek zapytań obsłużonych lokalnie
c_lokalny  ≈ 0   (własny GPU, prąd)
c_zdalny   = cena dużego modelu w chmurze
```

| p (łapie lokalnie) | Względny koszt vs "wszystko w chmurze" |
|--------------------|----------------------------------------|
| 0%                 | ~100% (a nawet >100% przez podwójne wywołanie) |
| 50%                | ~50% |
| 80%                | ~20% |
| 95%                | ~5% |

Im lepiej proxy łapie proste pytania, tym taniej. **Ale** cascade dokłada latencję (sekwencyjne wywołania) i przy eskalacji płacisz dwa razy — dlatego pre-routing (wzorzec A) bywa lepszy, gdy masz dobry klasyfikator.

## Pułapki

- **Niekalibrowane `confidence`** — model bywa pewny błędnych odpowiedzi. Zwaliduj próg na realnym zbiorze testowym, nie zgaduj.
- **Podwójny koszt i latencja** — eskalacja = dwie próby. Przy dużym ruchu przejdź na pre-routing.
- **Router drift** — rozkład pytań się zmienia; klasyfikator trzeba douczać.
- **Niespójność formatów** — różne modele zwracają inaczej; ujednolicaj output po stronie proxy.
- **Bezpieczeństwo / prywatność** — eskalacja wysyła dane do zewnętrznego API. Nie loguj sekretów i pilnuj, co opuszcza maszynę lokalną.
- **Pojedynczy punkt awarii** — proxy to wąskie gardło; dodaj timeouty i twardy fallback.

## Ścieżka wdrożenia

```
1. Uruchom mały model lokalnie (Ollama: llama3.2:3b / qwen2.5:3b)
   ↓
2. Dodaj bramkę pewności (structured output {answer, confidence})
   ↓
3. Eskalacja przy niskiej pewności → większy model / chmura
   ↓
4. Owiń to w LiteLLM (jednolite API + fallback przy błędzie)
   ↓
5. Loguj każde zapytanie: pytanie, pewność, czy eskalowano, wynik
   ↓
6. Z logów wytrenuj pre-router (klasyfikator) → tnij podwójny koszt
   ↓
7. Skalibruj próg pod swój budżet (koszt vs jakość)
```

## Zasoby

**Papers (kanon tematu):**
- **FrugalGPT** (Chen et al., Stanford 2023) — LLM cascade dla redukcji kosztów; to dokładnie Twój wzorzec
- **RouteLLM** (Ong et al., LMSYS/Berkeley 2024) — uczony router weak↔strong
- **Mixture-of-Agents** (Wang et al., 2024) — agregacja wielu LLM
- **Semantic entropy** (Farquhar et al., Nature 2024) — wykrywanie halucynacji / "nie wiem"

**Narzędzia:**
- LiteLLM — docs.litellm.ai (gateway + fallback)
- RouteLLM — github.com/lm-sys/RouteLLM
- Semantic Router — github.com/aurelio-labs/semantic-router
- OpenRouter — openrouter.ai (hostowany gateway, ma darmowe modele)
