# Podstawy LLM (Large Language Models)

## Czym jest LLM?

Duży Model Językowy (Large Language Model, LLM) to model uczenia maszynowego wytrenowany na ogromnych ilościach tekstu, zdolny do rozumienia i generowania języka naturalnego. LLM przewiduje następny token (fragment słowa) na podstawie poprzednich, co pozwala mu prowadzić rozmowy, pisać kod, tłumaczyć teksty i rozwiązywać złożone zadania.

## Kluczowe pojęcia

| Pojęcie | Wyjaśnienie |
|---------|-------------|
| **Token** | Najmniejsza jednostka tekstu (~3-4 znaki w angielskim). Modele przetwarzają tokeny, nie znaki/słowa. |
| **Embedding** | Wektorowa reprezentacja tokenu — np. 4096 liczb opisujących znaczenie. |
| **Parameter** | Pojedyncza wartość wagi w sieci neuronowej. Llama 3 70B = 70 mld parametrów. |
| **Context window** | Maksymalna liczba tokenów, które model może przetworzyć naraz (np. 200k dla Claude). |
| **Inference** | Proces generowania odpowiedzi przez wytrenowany model. |
| **Training** | Proces uczenia modelu na danych. |
| **Fine-tuning** | Dostosowanie wytrenowanego modelu do specyficznego zadania. |
| **Temperature** | Parametr losowości (0 = deterministyczny, 1 = kreatywny). |
| **Top-p / Top-k** | Strategie samplowania kolejnego tokenu. |
| **Hallucination** | Generowanie nieprawdziwych, ale przekonujących informacji. |

## Krótka historia

```
1950s — Modele n-gramowe (statystyka)
1980s — Sieci neuronowe (Hopfield, Boltzmann)
1997  — LSTM (Long Short-Term Memory)
2013  — Word2Vec (embeddingi słów)
2017  — Transformer ("Attention is All You Need")
2018  — BERT (Google), GPT-1 (OpenAI)
2019  — GPT-2 (1.5B parametrów)
2020  — GPT-3 (175B parametrów)
2022  — ChatGPT — przełom dla mainstreamu
2023  — GPT-4, Claude, Llama 2 (open source)
2024  — Claude 3.5/3.7, GPT-4o, Llama 3, multimodal
2025  — Claude 4, GPT-5, agentic systems, reasoning models
2026  — Claude Opus 4.6/4.7, AI agents w produkcji
```

## Główne rodziny modeli

### Closed-source (komercyjne API)

| Model | Producent | Mocne strony |
|-------|-----------|--------------|
| **Claude** (Opus, Sonnet, Haiku) | Anthropic | Bezpieczeństwo, długi kontekst (200k+), kod, agentic tasks |
| **GPT** (GPT-4o, GPT-5) | OpenAI | Wszechstronność, ekosystem, multimodal |
| **Gemini** (Pro, Ultra) | Google | Integracja z Google, multimodal, długi kontekst |

### Open-source (model weights publicznie dostępne)

| Model | Producent | Rozmiary |
|-------|-----------|----------|
| **Llama 3.x** | Meta | 8B, 70B, 405B |
| **Mistral / Mixtral** | Mistral AI | 7B, 8x7B (MoE), 8x22B |
| **Qwen** | Alibaba | 0.5B - 72B, multilingual |
| **Phi** | Microsoft | 3B-14B, mała ale skuteczna |
| **DeepSeek** | DeepSeek AI | Coding, R1 reasoning |
| **Gemma** | Google | 2B-27B |

## Open source vs closed source

### Closed-source (API)
**Zalety:**
- Najnowsze, najmocniejsze modele
- Bez kosztów infrastruktury
- Skalowanie automatyczne
- Wsparcie producenta

**Wady:**
- Zależność od dostawcy (vendor lock-in)
- Koszt per token (drogie przy dużej skali)
- Dane wysyłane na zewnątrz
- Brak kontroli nad modelem

### Open-source (lokalnie)
**Zalety:**
- Pełna kontrola nad modelem i danymi
- Brak kosztów per request (po inwestycji w hardware)
- Możliwość fine-tuningu
- Privacy — dane zostają u Ciebie
- Brak limitów rate

**Wady:**
- Wymagany hardware (GPU)
- Słabsze niż największe modele zamknięte (różnica się jednak zmniejsza)
- Konieczność zarządzania infrastrukturą
- Brak najnowszych funkcji (tool use często słabszy)

## Czego oczekiwać od LLM?

### Co LLM robią dobrze:
- Rozumienie języka naturalnego
- Generowanie tekstu (artykuły, e-maile, kod)
- Tłumaczenie między językami
- Streszczanie i parafrazowanie
- Klasyfikacja tekstu i analiza sentymentu
- Odpowiadanie na pytania na podstawie kontekstu
- Pomoc w programowaniu (Claude Code, GitHub Copilot)

### Co LLM robią słabo:
- Liczenie i precyzyjna matematyka (bez tools)
- Aktualne informacje (cutoff date)
- Spójność długich rozumowań
- Faktografia bez RAG (halucynacje)
- Operacje na bardzo długich dokumentach (mimo dużego kontekstu)
- Deterministyczne, powtarzalne wyniki

## Skala modeli

```
~1B params   → Phi-3-mini, Llama 3.2 (1B)
              ✓ Działa na laptopie
              ✓ Proste zadania, klasyfikacja
              ✗ Słabe rozumowanie

~7B params   → Llama 3.1 8B, Mistral 7B
              ✓ Działa na 8GB VRAM (kwantyzacja)
              ✓ Dobre do większości zastosowań
              ~ Rozumowanie ograniczone

~70B params  → Llama 3.3 70B
              ✓ Bardzo zdolne
              ✗ Wymaga 40+ GB VRAM (lub kwantyzacja na 24GB)
              ✓ Bliskie GPT-4 w wielu zadaniach

~400B+ params → Llama 3.1 405B, Claude Opus, GPT-4
              ✓ Najwyższa jakość
              ✗ Trudne do uruchomienia lokalnie
              → Najczęściej via API
```

## Co dalej?

W kolejnych rozdziałach poznasz:
- **Architekturę** — jak działa Transformer i mechanizm uwagi (rozdział 02)
- **Trening** — od pre-trainingu do RLHF (rozdział 03)
- **Lokalną konfigurację** — uruchom LLM na swoim komputerze (rozdział 04)
- **Frameworki** — narzędzia do pracy z LLM (rozdział 05)
- **Praktykę** — fine-tuning, prompty, RAG, agenci (rozdziały 06-10)
