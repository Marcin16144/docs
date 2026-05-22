# Architektura Transformerów

## Dlaczego Transformer?

Przed 2017 rokiem do przetwarzania języka używano głównie RNN i LSTM — sieci, które przetwarzały tekst sekwencyjnie (słowo po słowie). Miały dwa problemy:
1. **Wolne** — nie da się ich łatwo zrównoleglić
2. **Słaba pamięć długoterminowa** — gubiły kontekst w długich tekstach

W 2017 zespół Google opublikował artykuł "Attention is All You Need" (Vaswani et al.), który wprowadził architekturę **Transformer**. Cały współczesny ekosystem LLM (GPT, Claude, Llama) opiera się na tej architekturze.

## Główna idea: Self-Attention

**Self-attention** pozwala każdemu tokenowi w sekwencji "zwracać uwagę" na inne tokeny i obliczać, które z nich są dla niego najważniejsze.

### Przykład intuicyjny

```
Zdanie: "Kot siedzi na macie, ponieważ jest ona ciepła."

Pytanie: do czego odnosi się słowo "ona"?

Self-attention przy słowie "ona" oblicza wagi:
- "Kot"      → 0.05
- "siedzi"   → 0.02
- "na"       → 0.01
- "macie"    → 0.85   ← najwyższa waga!
- "ponieważ" → 0.03
- "jest"     → 0.02
- "ciepła"   → 0.02

Wniosek: "ona" odnosi się do "maty"
```

### Mechanizm Q, K, V

Self-attention dla każdego tokenu tworzy 3 wektory:
- **Q (Query)** — "czego szukam?"
- **K (Key)** — "co oferuję?"
- **V (Value)** — "jaka jest moja zawartość?"

```
Attention(Q, K, V) = softmax(Q · K^T / √d) · V

Krok 1: Q · K^T  — porównanie zapytań z kluczami (podobieństwo)
Krok 2: / √d     — skalowanie (stabilność numeryczna)
Krok 3: softmax  — normalizacja do prawdopodobieństw
Krok 4: · V      — ważona suma wartości
```

## Multi-Head Attention

Zamiast jednego mechanizmu attention, używamy **wielu głów (heads)** równolegle. Każda głowa może uczyć się innego rodzaju relacji:
- Głowa 1: relacje gramatyczne (podmiot-orzeczenie)
- Głowa 2: relacje semantyczne (zaimek-poprzednik)
- Głowa 3: relacje pozycyjne (sąsiadujące słowa)
- ...

```
MultiHead(Q, K, V) = Concat(head_1, ..., head_h) · W^O

gdzie head_i = Attention(Q · W^Q_i, K · W^K_i, V · W^V_i)
```

Typowo 8-128 głów w jednej warstwie.

## Pełna architektura Transformer

### Decoder-only (GPT, Claude, Llama — większość LLM)

```
┌─────────────────────────────┐
│       Token Embeddings       │  ← input
│    + Positional Encoding     │
└──────────────┬──────────────┘
               │
        ┌──────▼──────┐
        │  Block 1    │  ┐
        │ (attention  │  │
        │  + FFN)     │  │
        └──────┬──────┘  │
               │          │
        ┌──────▼──────┐  │  N warstw
        │  Block 2    │  │  (np. 32 dla
        └──────┬──────┘  │   Llama 3 8B)
               │          │
              ...         │
               │          │
        ┌──────▼──────┐  │
        │  Block N    │  ┘
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │ Layer Norm  │
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │   Linear    │  ← projekcja na vocabulary
        └──────┬──────┘
               │
        ┌──────▼──────┐
        │   Softmax   │  ← prawdopodobieństwa tokenów
        └─────────────┘
```

### Pojedynczy blok Transformer

```
Input
  │
  ├─→ Layer Norm ─→ Multi-Head Attention ─→ + (residual)
  │                                            │
  │←───────────────────────────────────────────┘
  │
  ├─→ Layer Norm ─→ Feed-Forward Network ─→ + (residual)
  │                                            │
  │←───────────────────────────────────────────┘
  │
Output
```

## Tokenizacja

Modele nie rozumieją surowego tekstu — pracują na **tokenach**.

### Byte Pair Encoding (BPE)
Najpopularniejszy algorytm tokenizacji (GPT, Llama):
1. Zacznij od pojedynczych znaków
2. Znajdź najczęstszą parę sąsiadujących tokenów
3. Połącz w jeden token
4. Powtarzaj aż osiągniesz docelowy rozmiar słownika (np. 100k)

### Przykład
```
"Hello world!"
→ Tokenizer
→ ["Hello", " world", "!"]
→ [9906, 1917, 0]  (token IDs)
```

```
"Programming is fun"  →  ["Program", "ming", " is", " fun"]
"przeprogramowanie"   →  ["prze", "program", "owanie"]
```

### Specjalne tokeny
- `<|begin_of_text|>` — start sekwencji
- `<|end_of_text|>` — koniec sekwencji
- `<|im_start|>` / `<|im_end|>` — granice wiadomości w czacie
- `[PAD]` — padding (wyrównanie batcha)

## Positional Encoding

Self-attention sam w sobie nie zna **kolejności** tokenów. Trzeba dodać informację o pozycji.

### Sinusoidal (oryginalny Transformer)
```
PE(pos, 2i)   = sin(pos / 10000^(2i/d))
PE(pos, 2i+1) = cos(pos / 10000^(2i/d))
```

### Learned Positional Embeddings
Pozycje są wyuczonymi wektorami (jak embeddingi tokenów).

### RoPE (Rotary Position Embedding) — nowoczesny standard
Używany w Llama, Mistral. Pozwala na lepsze generalizowanie do dłuższych kontekstów niż widziane w treningu.

### ALiBi (Attention with Linear Biases)
Alternatywa do RoPE, używana w niektórych modelach.

## Encoder vs Decoder vs Encoder-Decoder

| Typ | Przykłady | Zastosowanie |
|-----|-----------|--------------|
| **Encoder-only** | BERT, RoBERTa | Klasyfikacja, NER, embeddingi |
| **Decoder-only** | GPT, Claude, Llama | Generacja tekstu (autoregresyjna) |
| **Encoder-Decoder** | T5, BART | Tłumaczenie, streszczanie |

**Decoder-only** dominuje obecnie w LLM. Generuje tekst token po tokenie, gdzie każdy nowy token zależy od wszystkich poprzednich.

## Causal masking

W decoderze stosuje się **maskę przyczynową** — token może patrzyć tylko na tokeny **przed** sobą, nigdy na te po nim. To kluczowe dla generacji.

```
Pozycja:    1  2  3  4  5
Token 1:    1  0  0  0  0     ← widzi tylko siebie
Token 2:    1  1  0  0  0     ← widzi 1 i 2
Token 3:    1  1  1  0  0     ← widzi 1, 2, 3
Token 4:    1  1  1  1  0
Token 5:    1  1  1  1  1
```

## Feed-Forward Network (FFN)

Każdy blok Transformer zawiera FFN — zwykle 2-warstwową sieć:
```
FFN(x) = activation(x · W_1 + b_1) · W_2 + b_2
```

W nowoczesnych modelach (Llama, Mistral) używa się **SwiGLU**:
```
SwiGLU(x) = (Swish(x · W_1) ⊗ (x · W_2)) · W_3
```

FFN ma typowo 4× więcej parametrów niż attention. To tu "mieszka" większość wiedzy modelu.

## Mixture of Experts (MoE)

Zamiast jednego dużego FFN, używamy wielu mniejszych "ekspertów" i routera, który wybiera 1-2 z nich dla każdego tokenu.

**Zalety:** więcej parametrów bez zwiększenia kosztu inferencji.

Przykłady: Mixtral 8x7B (47B params, ale tylko 13B aktywnych), GPT-4 (podejrzewane MoE), DeepSeek V3.

## Skalowanie i Scaling Laws

Chinchilla scaling laws (DeepMind, 2022): aby model osiągnął optymalną wydajność, musi mieć:
- ~20 tokenów treningowych na każdy parametr

Przykład: Llama 3 8B trenowano na ~15T tokenów (znacznie więcej niż Chinchilla-optimal — to "over-trained" model, lepszy w inferencji).

## Warstwy nowoczesnych LLM

Nowoczesne LLM (Llama 3, Claude) wprowadziły ulepszenia:
- **Pre-Layer Norm** zamiast Post-Layer Norm (stabilność treningu)
- **RMSNorm** zamiast LayerNorm (szybsze)
- **SwiGLU** zamiast ReLU (lepsza jakość)
- **RoPE** zamiast sinusoidal (lepsze długie konteksty)
- **Grouped-Query Attention (GQA)** — kompromis między MHA a MQA, oszczędza pamięć
