# LLM router — jak inteligentnie kierować zapytania między modelami

> Rozwinięcie rozdziału [06-02 Model proxy](06-02-model-proxy-router.md). Tam opisany jest cały wzorzec proxy/cascade; tutaj skupiamy się na **samym routerze** — komponencie decyzyjnym, który wybiera model.

## Po co router?

Nie każde zapytanie potrzebuje najdroższego modelu. "Ile to 2+2?" i "zaprojektuj rozproszony system kolejkowania" to dwie różne ligi. **Router** kieruje każde zapytanie do **najtańszego modelu, który jeszcze da radę** — dzięki temu masz jakość najlepszego modelu przy ułamku kosztu.

To inny mechanizm niż "model proxy" jako całość: proxy to cały system (router + modele + orkiestracja), a router to **mózg decyzyjny** w środku.

## Router vs cascade — dwie filozofie dyspozytora

To kluczowe rozróżnienie. Oba kierują ruch, ale w innym momencie:

| | **Router** (pre-dispatch) | **Cascade** (post-hoc) |
|---|---|---|
| Kiedy decyzja | przed generacją | po próbie taniego modelu |
| Wejście decyzji | samo pytanie | pytanie + odpowiedź taniego |
| Koszt | 1 model | do 2 modeli przy eskalacji |
| Trafność | zależy od predyktora trudności | wyższa (widzi już odpowiedź) |
| Latencja | niska (1 strzał) | wyższa przy eskalacji (2 strzały) |
| Cold start | trudny (potrzeba danych do treningu) | łatwy (działa od razu) |

**Praktyczna recepta:** zacznij od cascade (działa bez danych), loguj wyniki, a gdy masz dane — dołóż router, by ciąć podwójny koszt. Często łączy się oba: router łapie oczywiste przypadki, cascade obsługuje resztę.

## Taksonomia routerów (wg celu)

- **Quality routing** — weak ↔ strong: tani model dla łatwych, mocny dla trudnych. Najczęstszy.
- **Cost routing** — minimalizuj $ przy zadanym progu jakości.
- **Domain / skill routing** — kod → model-koder, matematyka → model-matematyk, obraz → vision, prawo → model prawniczy.
- **Latency routing** — pilne zapytania → szybki model, batch → wolniejszy/tańszy.
- **Multi-tier** — 3+ poziomy (np. lokalny 3B → lokalny 30B → cloud frontier).

## Jak router decyduje — mechanizmy

Serce routera to funkcja `pytanie → wybór modelu`. Sposoby (od najprostszego):

| Mechanizm | Koszt decyzji | Trafność | Kiedy używać |
|-----------|---------------|----------|--------------|
| **Reguły / keywordy** | ~0 | niska | jasne sygnały (język, słowa-klucze, długość) |
| **Embedding similarity** | bardzo niski | średnia | routing po intencji/domenie (Semantic Router) |
| **Klasyfikator** (LR/BERT) | niski | wysoka (z danymi) | masz logi do treningu |
| **LLM-as-router** | średni (1 wywołanie) | wysoka, elastyczna | mało danych, złożone decyzje |
| **Learned preference** (RouteLLM) | niski | wysoka | quality routing weak↔strong |

### Reguły
Najprostsze: regex, język zapytania, długość, obecność bloku kodu. Kruche i nie skaluje się, ale dobre na start i jako twarde "zawsze do X".

### Embedding similarity
Definiujesz "trasy" przez przykładowe wypowiedzi, embedujesz je, a zapytanie kierujesz do najbliższej trasy. Deterministyczne, milisekundowe (Semantic Router).

### Klasyfikator
Trenujesz model (regresja logistyczna / BERT) przewidujący "czy weak wystarczy / która domena". Najlepsza trafność, ale potrzebuje danych.

### LLM-as-router
Pytasz tani LLM: "Do którego modelu skierować to zapytanie? [opcje]". Elastyczne, radzi sobie bez danych treningowych, ale dokłada jedno wywołanie (koszt + latencja).

### Learned preference (RouteLLM) — niżej osobno.

## RouteLLM — kanoniczny open-source router

[RouteLLM](https://github.com/lm-sys/RouteLLM) (Ong et al., LMSYS/Berkeley 2024) to referencyjna implementacja uczonego routera weak↔strong. Uczy się na **danych preferencji** (Chatbot Arena) — które odpowiedzi ludzie woleli — i przewiduje, czy słaby model wystarczy.

**Cztery typy routerów w RouteLLM:**
1. **Similarity-weighted (SW) ranking** — waży podobne historyczne zapytania.
2. **Matrix factorization (MF)** — uczy ukrytej "trudności" zapytań i "siły" modeli.
3. **BERT classifier** — fine-tune BERT na (pytanie → weak wystarczy?).
4. **Causal LLM classifier** — mały LLM jako klasyfikator.

**Próg kalibrowany pod budżet:** ustawiasz, jaki % zapytań może iść do mocnego modelu (np. `router-mf-0.11593` = próg dla ~określonego udziału strong).

**Wyniki (wg autorów):** na MT-Bench router osiągał ~95% jakości GPT-4 wołając go tylko w części przypadków → **ponad 85% redukcji kosztów** względem "wszystko do GPT-4". Co ważne — **router generalizuje**: wytrenowany na jednej parze (GPT-4 / Mixtral) działa na innych parach (np. Claude / Llama) bez ponownego treningu.

```python
from routellm.controller import Controller   # pip install routellm

client = Controller(
    routers=["mf"],                            # matrix factorization
    strong_model="claude-sonnet-4-6",
    weak_model="ollama/qwen3-coder:30b",       # np. Twój mocniejszy LAN-owy Ollama
)
resp = client.chat.completions.create(
    model="router-mf-0.11593",                 # prog: udzial wywolan do strong
    messages=[{"role": "user", "content": "..."}],
)
```

## Ewaluacja routera — czy w ogóle jest dobry?

Router oceniasz na **krzywej koszt–jakość**, nie pojedynczą liczbą.

**PGR (Performance Gap Recovered)** — ile luki między weak a strong odzyskuje router:
```
PGR = (jakość_router − jakość_weak) / (jakość_strong − jakość_weak)

PGR = 0 → tak słabo jak sam weak
PGR = 1 → tak dobrze jak sam strong
```

**APGR (Average PGR)** — pole pod krzywą PGR(% wywołań do strong). Im wyżej nad przekątną (= losowym routerem), tym lepiej.

**CPT(x%) (Call-Performance Threshold)** — ile wywołań do strong potrzeba, by osiągnąć x% gap recovered. Np. CPT(50%) = 18% → połowę luki odzyskujesz wysyłając tylko 18% ruchu do mocnego modelu.

```
PGR
1.0 ┤                          ╭───── strong-only
    │                    ╭─────╯
    │              ╭────╯   ← dobry router (nad przekątną)
    │         ╭───╯
0.5 ┤      ╭─╯- - - - - - - - - losowy router (przekątna)
    │   ╭─╯
0.0 ┼─╯──────────────────────────────▶
    0%         % wywołań do strong      100%
```

Zawsze porównuj z **losowym routerem** (przekątna) — to dolna granica sensu.

## Trening własnego routera — pełny workflow

```
1. Zbierz dane  → logi z cascade'a: (pytanie, czy weak wystarczył)
   ↓               albo public preference data (Chatbot Arena)
2. Etykietuj    → binarnie (weak_ok: 0/1) lub preferencyjnie
   ↓
3. Cechy        → embedding pytania (+ metadane: długość, język, domena)
   ↓
4. Model        → regresja logistyczna → fine-tune BERT
   ↓
5. Kalibruj próg → pod % ruchu do strong / budżet
   ↓
6. Monitoruj    → drift rozkładu pytań → douczaj
```

```python
# pip install sentence-transformers scikit-learn numpy
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split

emb = SentenceTransformer("all-MiniLM-L6-v2")     # maly, lokalny, darmowy

def features(questions):
    e = emb.encode(questions)
    meta = np.array([[len(q), q.count("?")] for q in questions])  # proste metadane
    return np.hstack([e, meta])

# logs = [{"question": "...", "weak_ok": 1}, ...]   # 1 = weak wystarczyl
X = features([r["question"] for r in logs])
y = np.array([r["weak_ok"] for r in logs])

Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=0)
clf = LogisticRegression(max_iter=1000).fit(Xtr, ytr)

# P(weak NIE wystarczy) = "trudnosc" zapytania
def difficulty(questions):
    return 1 - clf.predict_proba(features(questions))[:, 1]

# Kalibracja: chcemy slac do strong ~20% najtrudniejszych
threshold = np.quantile(difficulty([r["question"] for r in logs]), 0.80)

def route(question: str) -> str:
    return "strong" if difficulty([question])[0] >= threshold else "weak"
```

Gdy masz więcej danych, zamień regresję na fine-tune DistilBERT — wyższa trafność przy podobnej latencji.

## Router domenowy (skill routing) — przykład

Zamiast weak/strong, kieruj po **umiejętności** do wyspecjalizowanego modelu. Idealne pod Twój zestaw lokalnych modeli (np. koder + ogólny + cloud do trudnej matmy):

```python
# pip install semantic-router
from semantic_router import Route, RouteLayer
from semantic_router.encoders import HuggingFaceEncoder

code = Route(name="code", utterances=[
    "napisz funkcje w python", "popraw ten bug", "zrefaktoryzuj klase"])
math = Route(name="math", utterances=[
    "policz calke", "rozwiaz rownanie", "udowodnij twierdzenie"])
chat = Route(name="chat", utterances=[
    "opowiedz dowcip", "jak sie masz", "co slychac"])

rl = RouteLayer(encoder=HuggingFaceEncoder(), routes=[code, math, chat])

MODEL_FOR = {
    "code": "qwen2.5-coder:7b",     # lokalny koder
    "math": "claude-sonnet-4-6",    # trudna matma → cloud
    "chat": "llama3.2:3b",          # lekki, lokalny
}
choice = rl("zrefaktoryzuj te metode").name          # → "code"
model = MODEL_FOR.get(choice, "llama3.2:3b")          # fallback na lekki
```

## Routery produkcyjne / narzędzia

| Narzędzie | Typ routingu | Licencja | Uwagi |
|-----------|--------------|----------|-------|
| **RouteLLM** | quality (weak↔strong), uczony | open source | 4 typy routerów, próg kalibrowany |
| **Semantic Router** | domena/intencja (embedding) | open source | deterministyczny, ms-latency |
| **LiteLLM Router** | niezawodność między **deploymentami** | open source | NIE quality routing! patrz niżej |
| **OpenRouter** (auto) | quality, hostowany | usługa | `openrouter/auto` (NotDiamond) |
| **NotDiamond** | quality, hostowany | usługa | dobiera model pod prompt |
| **Martian** | quality/cost, hostowany | usługa | komercyjny |

> **Uwaga na LiteLLM Router:** to routing dla **niezawodności i load-balancingu** między wieloma instancjami/deploymentami tego samego logicznego modelu (strategie: latency-based, least-busy, cost-based, usage-based + fallback/retry). To **nie** jest "który model jest mądrzejszy do tego pytania". Quality routing dokładasz osobno (RouteLLM / własny klasyfikator).

## Architektura: gdzie siedzi router (gateway)

W produkcji router zwykle żyje w **gateway** — jednym wejściu, które centralizuje routing, auth, limity, logowanie i fallback:

```
                    ┌──────────── GATEWAY ────────────┐
  klient ──────────▶│  auth · rate-limit · ROUTER ·    │
                    │  logging · fallback · retry      │
                    └───┬──────────┬──────────┬────────┘
                        ▼          ▼          ▼
                   ┌────────┐ ┌────────┐ ┌─────────┐
                   │ weak   │ │ strong │ │ domena/ │
                   │ lokalny│ │ cloud  │ │ vision  │
                   └────────┘ └────────┘ └─────────┘
```

Logi z gatewaya to **paliwo do trenowania routera** — zamknij pętlę: loguj (pytanie, wybór, wynik, czy trzeba było eskalować) → trenuj → wdrażaj → powtarzaj.

## Pułapki specyficzne dla routerów

- **Router jest tak dobry jak dane treningowe.** Zmiana rozkładu pytań (drift) psuje trafność — douczaj.
- **Próg trzeba rekalibrować** po każdej zmianie modeli lub ich cen. Próg z zeszłego kwartału może już nie być optymalny.
- **Over-routing do strong** (próg za niski) zżera oszczędności — pilnuj realnego % ruchu do mocnego modelu.
- **LLM-as-router dokłada koszt i latencję** — mały, ale realny; przy dużym ruchu wolisz klasyfikator.
- **Cold start.** Bez danych nie wytrenujesz routera — zacznij od cascade, zbierz logi, potem przełącz na router.
- **Router nie naprawia braków obu modeli.** Jeśli ani weak, ani strong nie znają odpowiedzi (świeże dane, niszowa domena), routing nie pomoże — potrzebny RAG albo tools, nie inny model.

## Ścieżka wdrożenia

```
1. Cascade z bramką pewności (cold start, działa od razu)
   ↓
2. Loguj wszystko: pytanie, pewność, wybór, czy eskalowano, wynik
   ↓
3. Wytrenuj klasyfikator-router na logach (LR → BERT)
   ↓
4. Skalibruj próg pod budżet (krzywa koszt–jakość, APGR)
   ↓
5. Wdróż jako pre-router; cascade zostaw jako bezpiecznik
   ↓
6. Monitoruj drift i % ruchu do strong → rekalibruj / douczaj
```

## Zasoby

**Papers:**
- **RouteLLM** (Ong et al., 2024) — "Learning to Route LLMs with Preference Data"
- **Hybrid LLM** (Ding et al., ICLR 2024) — routing wg trudności + docelowej jakości
- **FrugalGPT** (Chen et al., 2023) — cascade + scorer (fundament routingu kosztowego)
- **AutoMix** (Madaan et al., 2023) — self-verification + meta-router
- **LLM Routing with Benchmark Datasets** (Shnitzer et al., 2023) — wczesne prace

**Narzędzia:**
- RouteLLM — github.com/lm-sys/RouteLLM
- Semantic Router — github.com/aurelio-labs/semantic-router
- LiteLLM Router — docs.litellm.ai (load-balance + fallback)
- OpenRouter — openrouter.ai (`openrouter/auto`)
