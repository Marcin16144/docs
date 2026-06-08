# Sub-agenci — pętla plan → wykonaj → weryfikuj (Console AI Terminal)

> Status: **stabilny od wersji 0.7.21** (2026-05-30). Pierwsze wydanie, w którym
> end-to-end flow z delegacją do pomocnika, live UI i interaktywną pauzą działają
> niezawodnie. **0.7.50** (2026-06-03): hardening odporności pomocnika — watchdog
> martwego modelu, failover na wyczerpane kredyty, auto-korekta werdyktu, szybszy
> live-podgląd, filtr modeli obrazowych (zob. „Odporność pomocnika").

## Czego dotyczy

Mechanizm rozbijania złożonego zadania użytkownika przez **model główny** na listę
podzadań wykonywanych **sekwencyjnie przez model pomocniczy**, z weryfikacją
sukcesu/porażki po każdym kroku i możliwością interaktywnej decyzji "kontynuuj/przerwij"
przy awariach.

Implementacja: narzędzie `decompose_and_execute(goal, sub_tasks[], stop_on_failure?)`
dostępne dla modela głównego w trybie **Pomocnik → Deleguj**.

## Polecany setup (przetestowany na 0.7.21)

| Komponent | Wartość |
|---|---|
| Model główny | `qwen3-coder:30b` (Ollama lokalnie) lub `openai/gpt-4o-mini` (GitHub Models) |
| Model pomocniczy | `qwen3-coder:30b` lub `qwen2.5-coder:14b/32b` (Ollama) |
| Tryb Pomocnika | **Deleguj** (główny ma dostęp do `ask_helper` i `decompose_and_execute`) |
| Instancje Ollamy | **rozdzielne** komputery w LAN (`Ollama #1` lokal + `Ollama #2` LAN) — żeby GPU nie serializowały głównego i pomocnika |
| `num_predict` (Max tokens) | **-1** (bez limitu — Ollama generuje aż model sam się zatrzyma) |
| `OllTimeout` (Timeout s) | **1000** |
| `max_execution_time` w `php.ini` | **≥ 1800** |

## Architektura

```
┌─────────────────────────────────────────────────────────────────┐
│  USER                                                            │
│  └─ wpisuje zadanie + klika Wyślij                              │
└──────────────────────────────────┬──────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  MODEL GŁÓWNY  (np. qwen3-coder:30b)                            │
│  ├─ widzi tools: list_dir, read_file, write_file, run_command,  │
│  │              ask_helper, decompose_and_execute               │
│  └─ wywołuje decompose_and_execute(goal, [task1..taskN])        │
└──────────────────────────────────┬──────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  EXECUTOR  (tools_executors.php)                                 │
│  ├─ pre-populate sub_tasks z status='pending' (UI od t=0)       │
│  ├─ FOREACH task:                                                │
│  │   ├─ set_time_limit(900)                                     │
│  │   ├─ status → 'running' + started=time()                     │
│  │   ├─ progressCb → DB (live update)                           │
│  │   ├─ POMOCNIK wykonuje (tcRunHelperSubLoop):                 │
│  │   │   ├─ workspace tools: list_dir, read_file, write_file    │
│  │   │   ├─ max 8 iteracji tool loop                            │
│  │   │   └─ zwraca tekstowy raport                              │
│  │   ├─ WERYFIKATOR (drugie wywołanie pomocnika):               │
│  │   │   └─ ocenia: "SUKCES: …" / "PORAŻKA: …"                  │
│  │   ├─ status → 'done' / 'failed' + elapsed + reply (do 2KB)   │
│  │   ├─ progressCb → DB                                          │
│  │   └─ IF failed && stop_on_failure:                            │
│  │       └─ consoleAiProgressAwait(120s)  ◄── modal w UI         │
│  │           ├─ DB poll co 1s                                    │
│  │           ├─ czeka na user_decision='continue'|'stop'         │
│  │           └─ timeout → 'stop'                                 │
│  └─ Agreguje wynik markdown → zwraca głównemu modelowi          │
└──────────────────────────────────┬──────────────────────────────┘
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│  MODEL GŁÓWNY                                                    │
│  └─ czyta sprawozdanie → pisze finalną odpowiedź userowi        │
└─────────────────────────────────────────────────────────────────┘
```

## Live UI

Komponenty wskaźnika **„pisze…"** podczas tury (polling endpointu
`console_ai_progress` co **800 ms**, pierwszy odczyt po 600 ms — od 0.7.50; wcześniej
1500 ms, przez co krótkie kroki <1,5 s nie pokazywały statusu „w toku" i pierwszy krok
bywał widoczny dopiero jako „gotowy"):

- **Główny licznik czasu** w formacie `Xs` / `Xm YYs` / `Xh YYm ZZs` (`formatElapsed`).
- **Etykieta modelu głównego** (np. „Ollama #2: qwen2.5-coder:14b").
- **Sekcja pomocnika** „🔧 Sub-taski wykonuje pomocnik: Ollama #1: qwen3-coder:30b".
- **Lista podzadań** ze stanami:
  - `pending` — szary border, ikona klepsydry, opacity 65% (przyszłe kroki widoczne od początku),
  - `running` — niebieski spinner + licznik sekund tickujący co 1s,
  - `retrying` — żółta ikona ↻ (ponawianie z innym pomocnikiem),
  - `done` — zielony ✓, finalny elapsed,
  - `failed` — czerwony ✗, ikona ↻ „ponów" (klik wczytuje treść do głównego inputa),
  - `skipped` — neutralny (no-op: cel już osiągnięty bez zmian),
  - klik na treść `reply` → expand do 50vh.
- **Live-podgląd na kroku „w toku"** (0.7.50): obok licznika krok pokazuje
  `iter X/max` + aktualny model pomocnika + ostatnie wywołane narzędzie — widać DLACZEGO
  krok trwa (np. zły model kręcący iteracje bez tool-calli). Źródło: pola `phase_iter`/
  `phase_model`/`live_tool_calls` z `tcRunToolLoop`.

## Tabela DB

`def_console_progress` (single row per `(UserId, SessionId)`) — pełen opis kolumn
i format `CprgJson` w [changelog-db.md](../changelog-db.md).

## Endpointy AJAX

| Akcja | Co robi |
|---|---|
| `console_ai_send` | Główny chat — uruchamia pętlę agentową, otwiera progress row |
| `console_ai_progress` | Polling — JS czyta live stan co 800 ms (od 0.7.50; było 1.5s) |
| `console_ai_plan_decision` | UI wpisuje decyzję `continue`/`stop` przy pauzie |

Wszystkie zwalniają session lock natychmiast (`session_write_close()`) żeby polling
nie blokował się na pliku sesji.

## Resety limitów czasu (dynamiczne)

`set_time_limit(N)` zeruje zegar PHP (nie kumuluje), więc każdy krok dostaje świeży
budżet — patrz changelog 0.7.21 sekcja „Naprawiono".

| Punkt | Budżet |
|---|---|
| Wejście do `console_ai_send` | 1800s |
| Każda iteracja `tcRunToolLoop` | 600s |
| Każde podzadanie w `decompose_and_execute` | 900s |
| Każdy `tcAskHelper` | 600s |
| `console_ai_run_command` (operator zatwierdza) | 600s |
| `consoleAiProgressAwait` (czekanie na decyzję usera) | 180s |

## Odporność pomocnika (0.7.50)

Zabezpieczenia przed zawieszeniem sub-tasków na nieodpowiednim / niedostępnym modelu:

- **Watchdog „martwego pomocnika"** ([tools_lib.php](../../admin/pages/consoleai/terminal/tools_lib.php)
  — `tcRunToolLoop`): dla podzadania wymagającego narzędzia (`run_command`/`write_file`,
  flaga `require_tool_use` ustawiana przez `decompose` z klasyfikacji zadania) po
  **`N` kolejnych iteracjach BEZ wykonanego tool-calla** (domyślnie 4, `no_tool_iters_max`)
  sub-pętla przerywa z błędem → failover na następny model. Łapie modele bez
  function-callingu (np. `*-image`) i modele bez kredytów (odpowiadają tekstem zamiast
  tool-calla). Licznik resetuje się przy każdym realnym wywołaniu narzędzia.
- **Failover na wyczerpane kredyty / limit / autoryzację**
  ([tools_delegate.php](../../admin/pages/consoleai/terminal/tools_delegate.php)
  — `tcRunHelperSubLoopWithFailover`): błędy `429` / `quota` / `RESOURCE_EXHAUSTED` /
  `billing` / `401` / `403` w polu `error` sub-loopa są **twardą porażką** — nawet jeśli
  model zwrócił pozornie-„ok" odpowiedź, wymuszamy przejście na kolejny sub-model.
- **Auto-korekta werdyktu „sprawdź wersję/instalację"**
  ([tools_executors.php](../../admin/pages/consoleai/terminal/tools_executors.php)):
  gdy zadanie to sprawdzenie instalacji / wersji / dostępności (np. „Sprawdź, czy .NET
  SDK jest zainstalowany"), a helper poprawnie użył `run_command` (`dotnet --version`),
  błędny werdykt „należało użyć inspekcji (`read_file`/`list_dir`) zamiast `run_command`"
  jest nadpisywany na SUKCES. Sprawdzenie obecności/wersji narzędzia z definicji wymaga
  uruchomienia komendy, nie odczytu plików.
- **Filtr modeli obrazowych z list pomocnika**
  ([viewjs/03_helpers_models.php](../../admin/pages/consoleai/terminal/viewjs/03_helpers_models.php)
  — `tcIsImageModel`): modele do generowania obrazów (`*-image`, `imagen`, DALL·E, FLUX,
  SDXL, playground-v, text-to-image) są wykluczone z wyboru pomocnika (pasek + modal
  Deleguj) — nie wołają narzędzi. Pozostają na GŁÓWNYM selektorze.
- **Lista pomocnika — OpenRouter jako jedna grupa**: w `buildModelGroups` modele
  OpenRouter są w jednej grupie „🔀 OpenRouter" (wcześniej per-org: ai21, anthropic,
  amazon… → dziesiątki pozornych „grup").

> Failover działa tylko gdy na liście pomocników jest **≥ 2 aktywne modele**. Z jednym
> modelem watchdog/twarda porażka jedynie szybciej zakończą krok błędem (zamiast wisieć).

## Diagnoza typowych problemów

### „Ollama (HTTP 400): walidator JSON odrzucił payload modelu"

Cztery najczęstsze przyczyny w kolejności prawdopodobieństwa:

1. **Truncation odpowiedzi przez `num_predict`** — sprawdź czy w *Ustawienia → AI → Ollama
   → Max tokens* masz **-1** (nie liczbę dodatnią). Stary cap 2048 powodował urywanie
   długich tool_calls w połowie JSON.
2. **Model emituje malformed JSON** — przejdź na `qwen2.5-coder:14b/32b`, `qwen3-coder:30b`,
   `deepseek-r1:14b/32b`. Unikaj `codellama`, `llama2`, czystego `qwen2`.
3. **Zatruta historia** — wcześniejszy tool_call w tej sesji miał błędny JSON. Kliknij **„Nowa"**.
4. **Bug Ollamy** — `ollama --version`; podnieś przez `winget upgrade Ollama.Ollama`.

### „Maximum execution time of N seconds exceeded"

Sprawdź w `php.ini`:
```ini
max_execution_time = 1800
```
Apache wymaga restartu po zmianie. Dodatkowo nasze hardcoded sufity w kodzie:
1800s w `console_ai_send` + 900s reset per krok decompose.

### Sub-taski pojawiają się dopiero gdy plan się skończył

Naprawione w 0.7.21 przez pre-populate. Status „w toku" pojedynczego kroku doprecyzowany
w 0.7.50 (polling 800 ms + live-podgląd). Jeśli widzisz stare zachowanie — wyczyść cache
przeglądarki (Ctrl+F5), JS musi się przeładować.

### Krok „w toku" wisi wiele minut na „szybkim" modelu chmurowym

Najczęściej pomocnikiem jest model **nieodpowiedni do narzędzi** (np. `gemini-2.5-flash-image`
— model OBRAZOWY). Nie potrafi zwrócić tool-calla, więc pętla kręci się do `maxIter`
(każda iteracja = wolne wywołanie API). Od 0.7.50: watchdog przerywa po 4 iteracjach bez
tool-calla, a modele `*-image` są odfiltrowane z listy pomocnika. Na kroku „w toku" widać
teraz `iter X/max` + model — jeśli iteracja rośnie bez efektu, model jest zły. Ustaw
pomocnika tekstowego (`gemini-2.5-flash`, `qwen-coder`, Claude).

### Wyczerpane kredyty/tokeny — plan nie przeskakuje na kolejny model

Od 0.7.50 błędy `429`/`quota`/`RESOURCE_EXHAUSTED`/`billing`/`401`/`403` wymuszają failover.
Warunek: na liście pomocnika muszą być **≥ 2 aktywne modele** (przycisk 👥). Z jednym
modelem nie ma na co przeskoczyć — dodaj zapasowy (np. lokalna Ollama jako fallback).

### „Sprawdź czy zainstalowany / jaka wersja" oznaczane jako PORAŻKA

Werdyktor błędnie traktował frazę „sprawdź" jako inspekcję plików. Naprawione w 0.7.50
(auto-korekta): sprawdzenie instalacji/wersji/dostępności przez `run_command` jest
poprawnym wykonaniem → SUKCES.

## Co celowo NIE jest sub-agentem

- **Tryb „Pomocnik → Off"** — brak pomocnika, główny robi wszystko sam.
- **Tryb „Auto-router"** — pomocnik dostaje tylko proste taski (heurystyka po długości
  i słowach kluczowych); brak planowania.
- **Tryb „Równolegle"** — pomocnik odpowiada OBOK głównego (nie pod nim).
- **Tryb „Podział ról"** — pomocnik przygotowuje kontekst (RAG-like), nie wykonuje
  podzadań.

Tylko **„Deleguj"** uruchamia narzędzia `ask_helper` + `decompose_and_execute`.
