# Changelog

> Zmiany strukturalne w bazach danych (migracje, tabele) prowadzone są osobno: [docs/changelog-db.md](changelog-db.md).

## [0.7.50] — 2026-06-03

### Dodano

#### Menedżer promptów (wstawek) Console AI — grupy, kolejność, historia

Słownik haseł do modala „Wstaw prompt" (Console AI → Terminal) dostał pełne
zarządzanie — dostępne **w dwóch miejscach** na wspólnej logice:

- **Ustawienia → Integracje AI → „Wstawki prompta"** — pełny edytor:
  grupy jako zwijane karty z licznikiem („X haseł · Y aktywnych"), **drag&drop**
  kolejności grup i haseł, aktywacja/deaktywacja grupy i pojedynczego hasła,
  zmiana nazwy / usuwanie grupy (z przeniesieniem haseł do „Ogólne" albo usunięciem
  razem z hasłami), dodawanie pustych grup, podgląd **Historii zmian** (audyt).
- **Terminal → modal „Wstaw prompt" → „Tryb edycji"** — te same operacje inline
  (dodaj/edytuj/usuń/deaktywuj/przeciągnij hasło i grupę) bez wychodzenia z terminala;
  zwinięcie grup zapamiętane w bazie (`GrpCollapsed`).

Wspólny moduł: [prompt_manager.php](admin/pages/settings/ai/prompt_manager.php)
(ensure schematu + migracja grup + audyt) i
[prompt_manager_handlers.php](admin/pages/settings/ai/prompt_manager_handlers.php)
(akcje `ai_prompt_snippets_*` / `ai_prompt_groups_*` / `ai_prompt_history_list`),
dołączane przez `admai.php` (`?page=ai`) oraz `admterminal_actions.php` (`?page=consoleai`).
Każda zmiana (dodanie/edycja/usunięcie/toggle/kolejność/grupa) trafia do tabeli audytu
`console_prompt_history`. Szczegóły schematu: [changelog-db.md](changelog-db.md).

#### Dostęp do kolejki wątków z modala „Wstaw prompt" + pasek terminala

- Nowy przycisk **„Kolejka"** w modalu „Wstaw prompt": otwiera istniejącą kolejkę
  wątków (`tc-batch-modal`) i — jeśli w polu jest treść — **dopisuje ją jako nowy wątek**
  na koniec kolejki (bez nadpisywania i resetu statusów istniejących; przez
  `console_ai_batch_add_item`). Dla pustej kolejki tworzy nową.
- Nowy przycisk **kolejki w głównym pasku terminala** (obok „Wstaw prompt") — otwiera
  istniejącą kolejkę do podglądu / wznowienia.
- Funkcje `window.tcOpenQueue()` / `window.tcQueueAppend(text)` w
  [viewjs/04_send_queue.php](admin/pages/consoleai/terminal/viewjs/04_send_queue.php).

### Poprawione

#### Sub-taski (decompose_and_execute) — widoczność i odporność

- **Szybszy live-progress**: polling stanu sub-tasków skrócony 1500 ms → 800 ms + pierwszy
  odczyt po 600 ms ([viewjs/02_messages.php](admin/pages/consoleai/terminal/viewjs/02_messages.php)).
  Wcześniej szybkie kroki (model chmurowy <1,5 s) nie pokazywały statusu „w toku" —
  pierwszy krok bywał widoczny dopiero jako „gotowy".
- **Live-podgląd na kroku „w toku"**: model pomocnika + `iter X/max` + ostatnie wywołane
  narzędzie — widać DLACZEGO krok trwa (np. zły model kręcący iteracje bez tool-calli).
- **Watchdog „martwego pomocnika"** ([tools_lib.php](admin/pages/consoleai/terminal/tools_lib.php)):
  przy zadaniu wymagającym narzędzia (`run_command`/`write_file`, flaga `require_tool_use`)
  po `N` (domyślnie 4) iteracjach BEZ tool-calla sub-pętla przerywa → failover na kolejny
  model. Łapie modele bez function-callingu (np. `*-image`) i wyczerpane kredyty.
- **Failover na wyczerpane kredyty/limit/autoryzację** ([tools_delegate.php](admin/pages/consoleai/terminal/tools_delegate.php)):
  błędy `429`/`quota`/`RESOURCE_EXHAUSTED`/`billing`/`401`/`403` w sub-loopie pomocnika są
  twardą porażką wymuszającą przejście na następny sub-model (wcześniej bywały uznane za sukces).
- **Werdyktor — koniec fałszywych porażek dla „sprawdź czy zainstalowany/jaka wersja"**
  ([tools_executors.php](admin/pages/consoleai/terminal/tools_executors.php)): gdy zadanie
  to sprawdzenie instalacji/wersji/dostępności, a helper poprawnie użył `run_command`,
  werdykt „należało użyć inspekcji zamiast run_command" jest auto-korygowany na SUKCES.
- **Lista pomocnika (Deleguj)** ([viewjs/03_helpers_models.php](admin/pages/consoleai/terminal/viewjs/03_helpers_models.php)):
  modele OpenRouter scalone w JEDNĄ grupę „🔀 OpenRouter" — wcześniej grupowane per-org
  (ai21, anthropic, amazon…), przez co lista grup zawierała dziesiątki pozycji zamiast grup.
- **Filtr modeli obrazowych z list pomocnika**: modele do generowania obrazów
  (`*-image`, `imagen`, DALL·E, FLUX, SDXL, playground-v, text-to-image) są wykluczone
  z wyboru pomocnika (pasek + modal Deleguj) — nie potrafią wołać narzędzi, więc nie
  nadają się na sub-taski agentowe. Pozostają dostępne na głównym selektorze modeli.

## [0.7.49] — 2026-05-31

### Dodano

#### Gemini 2.5 — kontrola chain-of-thought (`reasoning_effort`)

Gemini 2.5 Flash i 2.5 Pro to **hybrid reasoning models** — przed wygenerowaniem
odpowiedzi mogą wykonać wewnętrzny chain-of-thought (CoT). Dla zadań agentic
(debug, multi-step fixes, decompose) różnica jakości między `none` a `high` jest
drastyczna — szczególnie dla error-fix typu CS1503.

Wcześniej nasz `tcChatGemini` nie wysyłał **żadnej** konfiguracji thinking →
Google OpenAI-compat layer używał default'u (zmienny, czasem mały budżet).
Mogło tłumaczyć, dlaczego cloud Gemini 2.5 czasem bywał słabszy niż oczekiwano.

**Implementacja:**

1. **Schema** `def_api_gemini.GemThinkingEffort` — ENUM(`none`,`low`,`medium`,`high`),
   default `high`. Idempotent ALTER + nowy CREATE dodaje kolumnę.

2. **Payload** w `tcChatGemini` ([tools_providers.php](admin/pages/consoleai/terminal/tools_providers.php)):
   ```php
   if (preg_match('/^gemini-(2\.5|3|4)/i', $model)) {
       $basePayload['reasoning_effort'] = $thinkingEffort;
   }
   ```
   Wysyłane tylko dla 2.5+ modeli (1.5/2.0 ignorują parametr).

3. **UI** w *Ustawienia → Integracje AI → Gemini* — nowy select:
   - **None** — bez myślenia (najszybciej, najtaniej, najgorsza jakość)
   - **Low** — minimalny CoT
   - **Medium** — balans
   - **High** — max jakość (default, ~3× droższy output)

4. **Handler save** `ai_gemini_save` — sanitize do enum + UPSERT.

### Kontekst

W trakcie debugowania user'a, gdzie cloud Gemini 2.5 Flash poprawnie naprawiał
błąd CS1503 a lokalna Gemma 27b nie potrafiła — okazało się że nie miał
możliwości kontrolować thinking. Teraz operator może świadomie wybrać między:
- **High** (default) → ~30% wolniej, ale 2-3× lepiej dla agentic code
- **None** → najszybciej, dla prostych pytań / generowania tekstu

### Zmieniono

- `Core\Version::PATCH` → **49**.
- `def_api_gemini.GemModel` default zmieniony z `gemini-2.0-flash` na
  `gemini-2.5-flash` (już de facto polecane).

## [0.7.48] — 2026-05-31

### Dodano

#### Profil `gemma` + Format E parser (YAML-style tool calls)

**Problem:** Gemma (gemma:7b/9b/12b/27b, gemma2, gemma3) źle radzi sobie z natywnym
function callingiem przez Ollamę. Zamiast structured `tool_calls` emituje:
1. **YAML-style tool calls** w treści: `command: "dotnet build", purpose: "Build app"`
2. **Code blocks** z całą zawartością pliku (```csharp ... ```) zamiast wywołania
   `write_file` — wynik: kod jest „w odpowiedzi" ale plik na dysku nietknięty
3. **Verbose narratywę**: „Okay, I will read..." + długie wyjaśnienia bez akcji

**Nowy plik:** [`models/gemma.php`](admin/pages/consoleai/terminal/models/gemma.php)

Match: `/\bgemma(?:[-_]?\d)?(?::|@|-|$)/i` — łapie gemma/gemma2/gemma3 + warianty.

Konfiguracja:
- **skip_native_tools = TRUE** — tools wbity w prompt (text-emulation Format A)
- **`tools_text_format`** — pokazuje pełen schemat tools + EXPLICIT „WRONG vs RIGHT"
  z gemma's natural style jako kontrprzykład
- **`prompt_tail`** — 6 reguł GM1-GM6 (anti-code-blocks-in-reply, anti-yaml-tool-calls,
  anti-preamble, one-tool-per-turn, anti-placeholder, relative-paths-only)
- **Stop tokens:** `<start_of_turn>`, `<end_of_turn>`, `<eos>` (ChatML gemmy)
- **Sampling:** `temperature ≤ 0.2` (gemma default 1.0 robi się creative), `top_p 0.9`,
  `top_k 40`, `repeat_penalty 1.10`, `num_predict ≥ 4096`, `num_ctx 8192`
- **`clean_content`** — wycina special tokeny gdyby wyciekły
- **`max_iter`** = 24

#### Format E parser — `tcParseGemmaStyleCalls`

Nowy parser w `tools_lib.php` rozpoznający YAML-style tool calls. Wpięty
w `tcParseTextToolCalls` chain między Format D (bare) a Format B (JSON).

Wzorzec: pary `key: "value"` (lub `'value'`, lub bez cudzysłowów) rozdzielone
przecinkami. Regex bierze wszystkie wystąpienia w treści, agreguje, dispatch
po kluczach:

| Klucze obecne | Tool wywołany |
|---|---|
| `command` (+ purpose, shell) | `run_command` |
| `path` + `content` | `write_file` |
| `path` + `find` + `replace` (+ count_expected) | `find_and_replace` |
| `path` + `diff` | `apply_diff` |
| `filename` + `content` | `save_file` |
| `query` (+ num_results) | `web_search` |
| `url` | `fetch_url` |
| sam `path` | `read_file` |
| `task` | `ask_helper` |

**Test:** 4/4 warianty Format E + 6/6 model dispatch (gemma:12b, gemma2:9b,
gemma3:27b, gemma-7b-instruct, qwen3-coder:30b, deepseek-coder-v2:16b) +
full chain `tcParseTextToolCalls` rozpoznaje gemma YAML.

### Po refreshu z gemma:12b

Twój output z screenshota:
```
Okay, I will read the file...
command: "dotnet build", purpose: "Build the application"
```

Teraz zostanie poprawnie sparsowane jako `run_command(command='dotnet build',
purpose='Build the application')` i wykonane (po zgodzie operatora lub w auto-mode).

Dodatkowo profile gemma wstrzyknie do system prompta hint:

> (GM2) NO YAML/NATURAL TOOL CALLS: do NOT emit `command: "X", purpose: "Y"`.
> Use `<function=run_command>...</function>` instead. Parser will silently drop
> other formats.
>
> WRONG: `command: "dotnet build", purpose: "Build app"`
> RIGHT: `<function=run_command><parameter=command>dotnet build</parameter>...`

— więc z czasem gemma powinna preferować Format A. Format E jest **safety net**.

### Zmieniono

- `Core\Version::PATCH` → **48**.

## [0.7.47] — 2026-05-31

### Naprawiono

#### Auto-guard nie łapał czasownika „utwórz" → fałszywe SUCCESS

**Bug:** sub-task „Utwórz katalog Models i pliki..." był zaliczany jako SUKCES
mimo że helper TYLKO opisywał („Utworzyłem katalog Models...") bez faktycznego
wywołania `write_file`. Plik na dysku nie powstawał, ale Krok 1/6 miał zielony
checkmark.

**Przyczyna:** regex'y action verbs nie zawierały kluczowych PL imperatywów:
- `utwórz`/`utworzyć`/`utworzyłem`
- `wygeneruj`/`wygenerowałem`
- `zaimplementuj`/`zaimplementowałem`
- `skonfiguruj`/`skonfigurowałem`
- `zainstaluj`/`zainstalowałem`
- `napisz`/`napisałem`

Również EN części były niekompletne (`create` był tylko w jednym z dwóch regexów).

**Fix w 3 miejscach** ([tools_executors.php](admin/pages/consoleai/terminal/tools_executors.php)
+ [admterminal.php](admin/pages/consoleai/terminal/admterminal.php)):

1. **Imperative regex** (`$needsWriteImp`) — proaktywny hint helper'a:
   dodane `utw[oó]rz\w*|napisz\w*|wygener\w+|zaimplement\w+|implement\w*|
   skonfig\w+|zainstal\w+|install\w*|configure\w*|setup|set-up|generated`

2. **Auto-guard regex** (`$needsAction`) — reaktywny flip SUKCES→PORAŻKA:
   identyczna rozszerzona lista (PL + EN, ~25 verbów)

3. **Fake action detector** (`consoleAiDetectFakeAction` w PHP):
   - Dodane: `created|generated|wrote|written|installed|configured|set up`
   - Dodane PL: `utworzy\w+|stworzy\w+|napisa\w+|wygenerowa\w+|zaimplementowa\w+|
     skonfigurowa\w+|zainstalowa\w+`
   - Rozszerzone obiekty: `katalog/folder/projekt/wpis/repozytorium/model/serwis`
   - Naprawiony wzorzec „plik został utworzony" (był `\w+` wymagający min 1 char,
     teraz `\w*` matchuje też gołe „został")
   - 4 nowe wzorce gołych form: „Utworzyłem", „Stworzyłem", „Napisałem", „Wygenerowałem"

**Test:** 8/8 imperatyw verbs matchują (`Utwórz/Wygeneruj/Zaimplementuj/...`),
2/2 negatywne case (sprawdź/przeczytaj) pomijane. Fake-action detector łapie
wszystkie 8 wariantów PL+EN claim'ów akcji.

**Efekt dla user'a:**

Po refreshu, sub-task „Utwórz katalog Models" gdzie helper tylko opisuje bez
write_file → auto-guard flag'uje:
```
PORAŻKA (auto-guard): zadanie wymaga akcji (build/fix/write),
ale wykonawca nie wywołał żadnego mutującego narzędzia.
```
→ auto-retry z twardszym promptem → jeśli druga próba też pusta → PORAŻKA
+ modal user-decision.

Plus jeśli model w final reply mówi „Utworzyłem 3 pliki..." bez write_file →
**czerwony chip „Fałszywa akcja wykryta"** nad bańką (z 0.7.32).

### Zmieniono

- `Core\Version::PATCH` → **47**.

## [0.7.46] — 2026-05-31

### Naprawiono

#### „Już istnieje / nie było potrzeby zmian" — fałszywa PORAŻKA naprawiona na POMINIĘTO

**Bug:** sub-task „Dodaj PackageReference Microsoft.Data.Sqlite do pliku .csproj"
był flag'owany przez auto-guard (z 0.7.44) jako PORAŻKA, mimo że helper poprawnie
sprawdził plik i powiedział:

> „Plik ConsoleApp.csproj już zawierał PackageReference Microsoft.Data.Sqlite
> w wersji 8.0.0, więc nie było potrzeby wprowadzania zmian."

Auto-guard widział tylko `read_file` (0 mutujących wywołań) + verb „dodaj" =
oczekiwał `write_file`. Ale dla zadań **idempotentnych** ("dodaj X" gdy X już
jest) brak modyfikacji to SUKCES, nie PORAŻKA.

**Fix:** trzeci status w decompose — **POMINIĘTO** (`SKIP`).

**Logika auto-guard'a** ([tools_executors.php](admin/pages/consoleai/terminal/tools_executors.php)):

Po wykryciu „brak mutującego toola" + „task wymaga akcji", **przed** uruchomieniem
auto-retry sprawdza reply helpera regexem (PL + EN):

```
już (istnieje|zawiera|posiada|jest obecn|został dodany|jest zainstalowany)
nie było (potrzeby|wymaga zmian|trzeba zmieniać|trzeba modyfikować)
zmiana nie jest wymagana
already (exists|contains|has|present|in place|configured|added|installed)
no (changes needed|need to|modification needed)
nothing to (do|change|fix|modify)
skipping modification
```

Jeśli któryś wzorzec pasuje:
- `$isSuccess = true` (BEZ flip na PORAŻKĘ)
- `reply` dostaje prefix `[POMINIĘTO — no-op: cel już osiągnięty bez zmian]`
- `verdict = "SUKCES (pominięto)..."`
- `progressState['skipped'] = true` (UI rozróżni)
- `log[]` ma `'skipped' => true`
- `accumulated` zapisuje `[#N] POMINIĘTO (no-op): ...`
- `continue` — bez auto-retry i bez modalu user-decision

**Raport końcowy** generuje teraz trzy tagi: `[OK]` / `[SKIP]` / `[FAIL]`
(zamiast tylko `[OK]`/`[FAIL]`).

**UI** ([admterminal.viewjs.php](admin/pages/consoleai/terminal/admterminal.viewjs.php)):

- Live typing-indicator sub-task ze statusem `done` + `skipped=true` → ikona
  `fa-forward` (neutralna szara) zamiast zielonego ✓
- Klasa CSS `is-skipped` dla custom stylowania
- Bańka decompose w czacie:
  - Regex parsuje teraz `[OK|FAIL|SKIP]`
  - Header pokazuje 3 badge: `N OK` (zielony) / `M POMINIĘTO` (szary) / `K FAIL` (czerwony)
  - Każdy step `SKIP` ma ikonę forward + badge „POMINIĘTO" + brak retry button
    (bo nie ma czego retry'ować)

### Zmieniono

- `Core\Version::PATCH` → **46**.

## [0.7.45] — 2026-05-31

### Naprawiono

#### AUTO mode — model NIE pyta już o pozwolenie w tekście odpowiedzi

**Bug:** mimo włączonego AUTO mode (z 0.7.42), model wciąż emitował frazy typu
„Czy chcesz, żebym rozpoczął implementację tego planu?" w treści odpowiedzi
i zatrzymywał się czekając na potwierdzenie.

**Przyczyna:** AUTO mode z 0.7.42 omijał tylko **okno zgody** na `run_command`
(backend logic) — ale **modelu nie informował** w prompcie że ma działać bez
pytania. Model nadal stosował domyślne uprzejme zachowanie „spytam zanim zacznę".

**Fix:** w `admterminal.php` builder system prompta, gdy
`$_SESSION['console_ai_auto_mode'] === true` — doklejana sekcja **AUTO-MODE IS ON**
z explicit listą zakazanych fraz:

> AUTO-MODE IS ON: proceed immediately to implementation without asking for
> confirmation. FORBIDDEN phrases:
> - „Czy chcesz, żebym rozpoczął/zaczął...?"
> - „Should I proceed?"
> - „Czy mogę przystąpić do implementacji?"
> - „Do I have your permission to..."
> - „Czy zatwierdzasz..."
>
> When the user describes a task, START WORKING ON IT IMMEDIATELY. When you
> outline a plan, FOLLOW IT THROUGH. After completing the task, give a SHORT
> summary, not a question.

Sekcja dodawana **przed** profile tail (czyli wewnątrz głównego promptu) ale
**po** wszystkich istniejących instrukcjach narzędzi — recency bias działa.

### Naprawiono (kontynuacja z 0.7.44)

#### Modal „kontynuuj/przerwij plan" pojawiał się ponownie po wyborze decyzji

**Bug:** user klikał „Przerwij plan", modal zamykał się, ale po 1-2 sekundach
pojawiał się **znowu z tym samym krokiem**. Powtarzało się przy każdej pętli
pollingu typing-indicator'a.

**Przyczyna:** race condition między AJAX POST `console_ai_plan_decision` a backend
update'em `awaiting_user_decision` w `CprgJson`. JS pollu co 1.5s — w okresie
między POST'em a backend write'em (kilka iteracji decompose_and_execute) polling
ciągle widział stary `awaiting_user_decision` i wywoływał `showPlanDecisionModal`
ponownie. Stary `planModalShown` flag był resetowany od razu po success POST'a,
więc kolejny poll przechodził bramkę.

**Fix:** dodany `planDecidedFor` tracker w JS — przechowuje key (`failed_step + task`)
dla którego user już dał decyzję. `showPlanDecisionModal` sprawdza ten klucz PRZED
sprawdzeniem `planModalShown` i ignoruje wszystkie kolejne polls z tym samym kluczem.

- Klucz zapisywany **PRZED** POST'em (eliminuje race)
- Reset trackingu tylko w `removeTyping()` (koniec tury) — nowa tura = czysty stan
- Reset też przy błędzie sieci (`.catch` w postDecision) — recover gdy POST padł
- Inny `failed_step` w tym samym planie dostaje świeży klucz → modal pokaże się
  normalnie

### Zmieniono

- `Core\Version::PATCH` → **45**.

## [0.7.44] — 2026-05-31

### Naprawiono

#### Auto-guard „pomocnik tylko czytał, nie pisał" → teraz proaktywnie wymusza akcję

**Problem:** auto-guard z 0.7.27 wykrywał gdy pomocnik wykonał tylko `list_dir`/
`read_file` przy zadaniu wymagającym `write_file`/`run_command` i flip'ował SUKCES
na PORAŻKA. To dobre, ale user musiał za każdym razem ręcznie wybierać „kontynuuj
plan" w modalu. Powtarzało się — pomocnik wciąż wybierał read-only path.

**Dwa nowe fix'y w `decompose_and_execute` ([tools_executors.php](admin/pages/consoleai/terminal/tools_executors.php)):**

**1. Proaktywne — detekcja czasowników akcji w sub-tasku**

Przed wysłaniem do pomocnika, system parsuje treść sub-taska regexem na 2 kategorie
czasowników:

- **Imperatyw modyfikacji** (dodaj/napraw/popraw/zmodyfikuj/usuń/zapisz/edytuj/
  wstaw/zaktualizuj + EN: add/remove/delete/modify/edit/write/create/insert/
  fix/update/change) → wstrzyknięty hint do prompta:
  > UWAGA — TO PODZADANIE WYMAGA ZMIANY PLIKU: MUSISZ wywołać `write_file`
  > (lub `find_and_replace`/`apply_diff`). Samo `read_file`/`list_dir` NIE
  > wystarczy — zadanie zostanie odrzucone przez auto-guard jako niewykonane.

- **Imperatyw uruchamiania** (wykonaj/uruchom/skompiluj/zbuduj/przetestuj +
  EN: run/execute/build/test/compile/launch) → mocniejszy hint:
  > UWAGA — TO PODZADANIE WYMAGA URUCHOMIENIA KOMENDY: MUSISZ wywołać
  > `run_command` z odpowiednią komendą (np. `dotnet build`). Samo czytanie
  > plików NIE zalicza tego zadania.

**2. Reaktywne — AUTO-RETRY pomocnika po flip auto-guard'a**

Gdy auto-guard wykryje brak mutującego toola po pierwszej próbie, zamiast od razu
raportować PORAŻKA system:

1. Składa twardszy retry prompt:
   > RETRY: poprzednia próba wykonała tylko {list of tools}. ZADANIE: {st}
   > MUSISZ TERAZ wywołać `write_file` (lub `find_and_replace`/`apply_diff`)
   > ALBO `run_command` żeby faktycznie wykonać zadanie. Zacznij od
   > KONKRETNEGO tool calla — bez prozy, bez 'I will'.
2. Uruchamia drugą iterację helper sub-loop.
3. Jeśli retry wykonał mutujący tool → flip z powrotem na SUKCES + dorzuca
   `[AUTO-RETRY OK]` prefix do reply + zapisuje retry tool calls do log.
4. Jeśli retry też failed → PORAŻKA (auto-guard + retry) z czytelnym komunikatem.

**Efekt dla user'a:**

Zamiast 4-7× modal „kontynuuj plan" w długim decompose, system **automatycznie**
poprawia pomocnika. User widzi PORAŻKA modal tylko gdy NAWET 2 próby nie pomogły
(prawdziwy stuck-state, nie zwykłe „zapomniało zapisać").

W UI sub-task pokazuje SUKCES z reply zaczynającym się od `[AUTO-RETRY OK]` jako
sygnał że potrzeba było dwóch prób — przydatne diagnostycznie.

### Zmieniono

- `Core\Version::PATCH` → **44**.

## [0.7.43] — 2026-05-31

### Dodano

#### Phase indicator — UI pokazuje CO DOKŁADNIE robi główny model w czasie rzeczywistym

**Problem:** typing-indicator pokazywał tylko „Ollama #1: qwen3-coder:30b pisze…"
bez wskazówki czy model nadal pracuje czy zawiesił się. Live tool calls były
widoczne TYLKO po wykonaniu tool calla, ale BETWEEN tool calls (gdy model generuje
treść/decyduje co dalej) UI „wisiał".

**Fix:** 3 nowe fazy push'owane do `def_console_progress` z `tcRunToolLoop`:

| Faza | Trigger | Ikona | Label PL |
|---|---|---|---|
| `thinking` | przed `tcChatTurnWithTools()` | 🧠 brain (primary) | „Model myśli / generuje odpowiedź…" |
| `parsing` | po odpowiedzi providera | 💎 microchip (info) | „Otrzymano odpowiedź — parsowanie tool calls…" |
| `executing` | przed każdym `tcExecuteTool()` | ⚙️ gears (warning) | „Wykonuję `<tool_name>`: <arg>" |

Każda faza niesie:
- `phase` (kod), `phase_label` (PL text)
- `phase_iter` + `phase_max` (np. „iter 5/24" badge)
- `phase_model` (nazwa modelu — visible context)
- `phase_msgs` (ile wiadomości w kontekście)
- `phase_started` (timestamp — żeby UI miał heartbeat)

**Backend** ([tools_lib.php:623-665](admin/pages/consoleai/terminal/tools_lib.php#L623-L665)):
- `progressCb(['phase' => 'thinking', ...])` przed `tcChatTurnWithTools`
- `progressCb(['phase' => 'parsing', ...])` po response
- `progressCb(['phase' => 'executing', 'phase_label' => "Wykonuję `read_file`: src/X.cs"])` przed każdym tool call

**Progress endpoint** ([admterminal.php](admin/pages/consoleai/terminal/admterminal.php)) — propaguje
7 nowych pól (`phase`, `phase_label`, `phase_iter`, `phase_max`, `phase_model`, `phase_msgs`, `phase_started`)
z `CprgJson` do response.

**UI:**

- Nowy element `<div id="tc-typing-phase">` pod typing-indicator
- Renderer w `updateTyping(data)` — pokazuje ikonę + label + badge iter/max + elapsed
- **Heartbeat** w `typingTimer` (tick 1s) — odświeża `phase-elapsed` text element
- CSS `.tc-typing-phase` — gradient tło primary + lewy border + monospace elapsed

**Efekt:** zamiast „pisze… (0m 23s)" widzisz:

```
🧠 Model myśli / generuje odpowiedź…  (qwen3-coder:30b)  iter 3/24  0m 23s
```

Albo (po response):

```
💎 Otrzymano odpowiedź — parsowanie tool calls…  0m 24s
```

Albo (gdy wykonuje tool):

```
⚙️ Wykonuję `read_file`: Forms/MainForm.cs  iter 4/24  0m 1s
```

Plus istniejące już live tool calls w `tc-typing-live-tools` (od 0.7.35).

### Zmieniono

- `Core\Version::PATCH` → **43**.

## [0.7.42] — 2026-05-31

### Dodano

#### Tryb pracy operatora — interaktywny vs automatyczny

Nowy przycisk w toolbarze (obok „Komendy") z modalem wyboru trybu:

- **Interaktywny** (domyślny) — każda komenda wymaga zgody operatora w modalu
- **Automatyczny** — wszystkie NIE-niszczące komendy uruchamiają się bez okna zgody

**Wyjątki** (zawsze wymagają ręcznej zgody, w obu trybach):
- Komendy niszczące (`rm -rf`, `git reset --hard`, `git push --force`, …) — wykrywane
  przez `tcCommandNeedsApproval()`
- Dostęp poza folder roboczy — workspace tools (`read_file`/`write_file`/`list_dir`)
  są sandboxowane przez `tcWsResolve` na poziomie ścieżki

### Implementacja

- `tools_executors.php` `run_command` — dodany warunek `$autoMode` w obliczeniu
  `$autoOk`: gdy true, dowolna NIE-destruktywna komenda auto-uruchamia się
- `admterminal.php` — `'auto_mode' => $_SESSION['console_ai_auto_mode']` propagowane
  w `$toolContext`
- `def_console_prefs.CprAutoMode` (TINYINT) — persystencja per user (idempotent ALTER)
- Endpoint `console_ai_set_auto_mode` — UPSERT do DB + session
- Sync na load: gdy DB row istnieje, `$_SESSION['console_ai_auto_mode']` synchronizowany
- UI: chip w toolbarze zmienia kolor (outline-secondary → warning) gdy auto-mode ON,
  zmienia ikonę (shield-halved → bolt) + label („Interaktywny" → „Automatyczny")

### Zmieniono

- `Core\Version::PATCH` → **42**.
- `admin/index.php` ajaxActions: `console_ai_set_auto_mode`.

## [0.7.41] — 2026-05-31

### Dodano

#### Auto-split przy BUDGET_EXHAUSTED — automatyczny pivot na mikro-kroki

**Problem:** model dochodził do limitu 200k tokenów (BUDGET_EXHAUSTED), tura była
przerywana i user musiał ręcznie restartować z mniejszym scope. Przy zadaniach
typu „1/8" sub-tasków każdy mógł wymagać 30k+ tokenów (read big file + write big
file + dotnet build × kilka iteracji).

**Fix:** automat w `tcRunToolLoop`. Gdy budget = `stop`:

1. **Pierwsze 2 razy** w turze — auto-split **nie hard-stop**:
   - Limit podwojony (200k → 400k → 800k) przez `aqSetBudget()`
   - `max_iter += 6` (więcej kroków na mniejsze fragmenty)
   - Synthetic `_auto_budget_split` tool call (ikona ✂️ w UI live tools)
   - Synthetic user message z hardcore'owym MICRO-STEPS hint'em:
     - ONE `read_file` per turn (najmniejszy fragment)
     - Smallest possible `find_and_replace` (1-5 lines)
     - Krótki `run_command` (filter test, nie cały suite)
     - Split tasks: zamiast „fix all CS0246", rób „fix CS0246 in file X only"
     - Krótkie final reply (1 sentence po każdym tool call)
   - `continue` loop — model dostaje hint + większy budget

2. **Po 2× auto-split** (czyli ok. 800k tokens) — wtedy hard stop z explicit
   komunikatem:
   > BUDGET_EXHAUSTED (po 2× auto-split): system automatycznie spróbował rozbić
   > zadanie na mikro-kroki dwukrotnie, ale nadal nie zmieściło się. Podziel
   > zadanie ręcznie / podnieś `AQ_BUDGET_STOP` / przełącz na lokalną Ollamę.

**Efekt:** user widzi w live tool calls progresję:
```
✂️ _auto_budget_split (split #1)
read_file: Forms/MainForm.cs (lines 1-50)
find_and_replace: Forms/MainForm.cs (small chunk)
...
✂️ _auto_budget_split (split #2)
read_file: Utils/ToolLoop.cs (lines 10-30)
...
```

Łącznie zadanie 1/8 (8 sub-tasków × ~30k = 240k tok) → przerodzi się w 1/30
(30 mikro-akcji × ~10k = 300k tok łącznie, mieści się w 800k limicie z 2× split).

UI w `tc-typing-live-tools` pokazuje `_auto_budget_split` z ikoną ✂️ (scissors).

### Zmieniono

- `Core\Version::PATCH` → **41**.
- `tcRunToolLoop` BUDGET_EXHAUSTED handler: zamiast natychmiastowego return,
  próbuje auto-split do 2× zanim podda.

### Pliki (paused work — kontynuacja w kolejnej turze)

Częściowy refactor dokumentacji `docs/AI/terminal/csharp/`:
- ✅ README zaktualizowany (nowa struktura: sub-zadania, testowanie LLM, neutralna nazwa)
- ✅ `etap-01-projekt-i-baza.md` rozbity na 5 sub-zadań z testami akceptacji
- ⏸ Etapy 02-11: czekają na kontynuację

## [0.7.40] — 2026-05-31

### Zmieniono

#### „Wyczyść rozmowę" — Bootstrap modal zamiast natywnego confirm()

Stary potwierdzający dialog używał `window.confirm()` (brzydki natywny browser
dialog, niespójny z resztą UI). Zamieniony na Bootstrap modal:

- Header: czerwone tło (`bg-danger-subtle`) + ikona kasowania
- Body: pytanie + info-hint że preferencje (modele, workdir) zostają zachowane
- Footer: „Anuluj" (outline-secondary) + „Tak, wyczyść" (btn-danger) z spinner
  podczas operacji

JS flow:
1. Klik przycisk „Wyczyść" → otwarcie modalu (zamiast `confirm()`)
2. Klik „Tak, wyczyść" → disable przycisku + spinner + fetch
3. Sukces → wyczyszczenie messages + auto-zamknięcie modalu
4. Fallback do natywnego `confirm()` gdy Bootstrap niedostępny (defensive)

- `Core\Version::PATCH` → **40**.

## [0.7.39] — 2026-05-31

### Zmieniono

#### UI cleanup — usunięto duplikat przycisków „zmień" / „wyłącz" z paska workdir

Pasek folderu roboczego (pod toolbarem) miał dwa przyciski („zmień", „wyłącz"),
które są dostępne w modalu folderu roboczego (otwieranym przez „AppTerminal" /
chip w toolbarze). Duplikat usunięty — pasek pokazuje teraz tylko informację
o folderze + git status + cost meter + profile chip.

JS handlery (`wdBarChange`, `wdBarOff`) są defensywne (sprawdzają `if (element)`),
więc po usunięciu DOM nic nie crashuje — można je zostawić jako dead code lub
posprzątać w przyszłości.

- `Core\Version::PATCH` → **39**.

## [0.7.38] — 2026-05-31

### Naprawiono

#### Persystencja wyboru modeli (main + helper) — DB primary, cookies cache

Wcześniej preferencje modeli były zapisywane TYLKO w cookies, i TYLKO na `change`
event. Skutek: jeśli user widział wybór z defaults i nigdy nie kliknął, cookie nie
powstawał — po „Wyczyść" / „Nowa" / zmianie przeglądarki wracał default.

**Fix:**

**1. `def_console_prefs` rozszerzona** ([admterminal.php:106-138](admin/pages/consoleai/terminal/admterminal.php#L106-L138))
o 4 kolumny: `CprMainProvider`, `CprMainModel`, `CprHelperModel`, `CprHelperMode`.
Idempotent ALTER dla istniejących instalacji (sprawdza information_schema, dodaje
brakujące).

**2. Endpoint `console_ai_save_prefs`** — UPSERT z `IF(VALUES <> '', VALUES, OLD)`
żeby częściowy update (np. tylko helper_mode) nie kasował pozostałych pól.

**3. PHP rendering** — czyta z DB jako pierwsze, cookies jako fallback. View
dostaje 3 nowe data-attributes na `.tc-card`: `data-db-pref-main-model`,
`data-db-pref-helper-model`, `data-db-pref-helper-mode`.

**4. JS save + defensive init**:
- `tcSavePrefsToDb()` z debounce 800ms — wywoływane na każdej zmianie main/helper
- **Defensive init** dla main: gdy DB pref istnieje a current dropdown value nie
  pasuje, system wymusza DB value
- **Defensive init** dla helper: identyczne (helper modal może być zamknięty —
  init i tak ustawia value)
- **Zawsze save aktualnego stanu na load** — gwarantuje że nawet user który nigdy
  nie kliknął change, ma swoje wybory zapisane w DB

### Zmieniono

- `Core\Version::PATCH` → **38**.
- `admin/index.php` `$ajaxActions` dodane: `console_ai_save_prefs`.

## [0.7.37] — 2026-05-31

### Dodano

#### Dedykowany profil `qwen3_coder` + UI „active profile"

**Nowy plik:** `admin/pages/consoleai/terminal/models/qwen3_coder.php`

Wydzielony z generic `qwen_coder` żeby qwen3-coder:30b miał własne tuning:
- **Match:** `/qwen[-_]?3[\d.]*[-_]?coder/i`
- **max_iter:** 28 (qwen3 efektywnie wykonuje agentic loop — daj większy budżet)
- **Sampling:**
  - `temperature` ≤ 0.3 (qwen3 default 0.7 robi się creative przy edycji kodu)
  - `top_p` 0.8 (tighter niż default 0.95)
  - `top_k` 40
  - `repeat_penalty` 1.05 (qwen3 nie repeat-uje, wysoki poziom psuje strukturalność JSON)
  - `num_predict` ≥ 8192 (qwen3 może pisać długie odpowiedzi sensownie)
  - `num_ctx` 16384 (długie agentic loop history mieści się — qwen3 wspiera 256K natywnie)
- **Stop tokens:** `<|im_end|>`, `<|endoftext|>` (ChatML format)
- **skip_native_tools:** false (qwen3 ma stabilny natywny function calling)
- **prompt_tail:** 5 reguł QW3 (native tools, language lock, anti-placeholder,
  prefer find_and_replace, one tool call per turn)

`qwen_coder.php` regex zaktualizowany do `/qwen(?!3)[\d.]*[-_]?coder/i` — wyklucza
qwen3 (negative lookahead).

**Dispatch test:** 10/10 wariantów (qwen3-coder:30b, qwen2.5-coder:32b, deepseek, llama).

#### UI „Active profile" — chip + modal

W toolbarze nowy chip 🖥 obok cost meter pokazujący nazwę aktywnego profilu
(`default` / `qwen3_coder` / `deepseek_coder` itd.). Kolor:
- Zielony — dedykowany profil dopasowany
- Szary — `default` (brak tuning, używane defaults)

Klik → modal z **pełnymi efektywnymi ustawieniami** dla main + helper:
- Provider/model + Profile ID badge
- Max iter
- Skip native tools (yes/no)
- Sampling (temperature, top_p, top_k, repeat_penalty, num_predict, num_ctx) — wszystkie
  PO override z profile, czyli **dokładnie to co idzie do Ollamy**
- Stop tokens
- Prompt tail preview (collapsible, max 600 chars + length info)

**Endpoint:** `console_ai_active_profile` — przyjmuje `provider` + `model`, zwraca
efektywne ustawienia (uruchamia `ollama_options($defaults)` żeby pokazać aktualne wartości).

JS: refresh chip po każdej zmianie modelu (`change` event na `tc-provider`/`tc-model`),
modal pobiera oba profile (main + helper) przy `show.bs.modal`.

### Zmieniono

- `Core\Version::PATCH` → **37**.
- `qwen_coder.php` regex: `/qwen(?!3)[\d.]*[-_]?coder/i` (exclude qwen3).
- `admin/index.php` `$ajaxActions` dodane: `console_ai_active_profile`.

### Jak testować qwen3-coder:30b

1. Ollama #1 (main) → wybierz `qwen3-coder:30b`
2. Chip w toolbarze powinien się zmienić na zielony 🖥 `qwen3_coder`
3. Klik chip → modal pokazuje:
   - `max_iter: 28`, `temperature: 0.3`, `top_p: 0.8`, `top_k: 40`,
   - `repeat_penalty: 1.05`, `num_predict: 8192`, `num_ctx: 16384`
   - Stop: `<|im_end|>`, `<|endoftext|>`
   - Prompt tail: 5 reguł QW3-1 do QW3-5
4. Analogicznie Ollama #2 (helper) — jeśli też qwen3-coder:30b, modal pokaże ten sam profil
5. Wykonaj zadanie, obserwuj live tool calls w typing-indicatorze
6. Po zakończeniu — sprawdź czy są issue'y (halucynacje, type erasure, stub bodies, brak konwergencji)

## [0.7.36] — 2026-05-31

### Naprawiono

#### Sub-tasks znikały podczas streamingu live tool calls

**Bug:** w typing-indicator pojawiały się sub-taski z `decompose_and_execute` (np.
„Krok 1/4..."), a po chwili **znikały** gdy zaczynały się inne tool calls
(read_file, run_command). User nie widział który krok wymagał poprawy / był
ponownie przetwarzany.

**Przyczyna:** `consoleAiProgressUpdateJson` robił **pełny UPDATE** całego
`CprgJson`. Mój push w 0.7.35 z `tcRunToolLoop` (`{live_tool_calls, iter}`)
nadpisywał poprzedni stan zawierający `sub_tasks` → znikały z DB → znikały z UI.

**Fix #1: MERGE mode w `consoleAiProgressUpdateJson`**

Funkcja teraz:
1. Czyta istniejący `CprgJson` z DB
2. Mergeuje top-level z nowym `$data`
3. Zapisuje połączony stan

Specjalne traktowanie `sub_tasks[]` — per-index merge (zachowuje stare pola jeśli
nowe entry ich nie dostarcza).

**Fix #2: Retry detection + counter**

Gdy sub-task ze statusem `done`/`failed` ponownie zmienia status na `running`
(model wraca do przetworzenia kroku), system:
- Inkrementuje `retry_count` (start 0)
- Zachowuje `previous_status` (`done` lub `failed`)
- Te pola lecą do UI w `live_tool_calls` JSON

**Fix #3: UI retry badge**

W typing-indicator sub-task ze stanem retry dostaje:
- Żółty badge `↺ retry #1` obok numeru kroku
- Tooltip: „Krok przetwarzany po raz 2 (po porażce)"
- Lekka żółta poświata na nagłówku (`.is-retry` class)

Czyli zamiast „znika i nie wiem co się dzieje" → „Krok 1/4 ↺ retry #1 — model wraca
do tego, bo poprzednio padło/zostało już zrobione".

### Zmieniono

- `Core\Version::PATCH` → **36**.

## [0.7.35] — 2026-05-31

### Dodano

#### Live tool-call streaming w typing-indicator

Wcześniej tool calls w `tcRunToolLoop` (run_command/read_file/write_file/...) były
widoczne w UI **dopiero po zakończeniu** całego console_ai_send — user musiał czekać
30-180s nie wiedząc co model akurat robi. Wcześniejszy live progress działał TYLKO
dla `decompose_and_execute` sub-tasków.

**Fix:**

**1. `tcRunToolLoop` push'uje stan po każdym tool call** ([tools_lib.php:968-997](admin/pages/consoleai/terminal/tools_lib.php#L968-L997))

Po każdym `tcExecuteTool` woła `$progressCb(['live_tool_calls' => [...], 'iter' => N])`
z ostatnimi 12 toolami. Każdy entry:
```json
{
  "name": "read_file",
  "arg": "Utils/IToolExecutor.cs",
  "result": "(snippet ~200 chars)",
  "error": false
}
```

`arg` jest skróconym podsumowaniem: path/filename/command/query/url/goal/task w tej kolejności.

**2. Progress endpoint propaguje `live_tool_calls`** ([admterminal.php:1828-1834](admin/pages/consoleai/terminal/admterminal.php#L1828-L1834))

`console_ai_progress` AJAX endpoint dociąga teraz `live_tool_calls` i `iter` z
session JSON (`def_console_progress.CprgJson`).

**3. UI renderer w typing-indicator** ([admterminal.viewjs.php updateTyping](admin/pages/consoleai/terminal/admterminal.viewjs.php))

Nowa sekcja `tc-typing-live-tools` pod typing-indicatorem. Renderuje listę z
ikonami per tool (mapa 15 ikon: terminal/file-lines/file-pen/magnifying/code-merge/
folder-open/globe/link/user-gear/list-check/shield-halved/arrow-right-from-bracket/
life-ring/circle-exclamation/wrench fallback).

Każdy tool call jako kompaktowy wiersz:
```
🖥️  run_command: dotnet build
📄  read_file: Utils/IToolExecutor.cs
🛡  _anti_empty_finish: (guard #1)
📄  read_file: K2Terminal/Utils/IToolExecutor.cs    ← czerwone tło (error)
⬅️  _auto_read_file_escape: K2Terminal/Utils/IToolExecutor.cs
🔍  find_and_replace: Utils/IToolExecutor.cs

iteracja 6
```

Błędne tool calls dostają czerwone tło (`is-error`).

**4. CSS dla live tool calls** ([admterminal.viewcss.php](admin/pages/consoleai/terminal/admterminal.viewcss.php))

Box z lewym borderem `border-left: 3px solid info`, ikony per tool kolorowane,
error-state z czerwonawym tłem.

### Zmieniono

- `Core\Version::PATCH` → **35**.

### Co user widzi

Zamiast czarnej skrzynki „pisze… (180s)" — **live stream** wszystkich operacji
modelu w czasie rzeczywistym, z licznikiem iteracji. Można od razu zobaczyć:
- czy model utknął na czymś (długie czekanie na 1 tool)
- ile iteracji już przeszło (vs `max_iter`)
- które tool calls failują (czerwone) — i można interweniować zanim 16 iter się
  wyczerpie

## [0.7.34] — 2026-05-31

### Naprawiono

#### Anti-pattern detection — 9 typowych „fake fix" wzorców LLM

Po obserwacji że qwen2.5-coder:14b „naprawił" `Task<ToolResult>` → `Task<object>`
(type erasure — kod kompiluje ale nic nie naprawia), zebrałem kolekcję wszystkich
znanych anti-pattern'ów które modele kodowe popełniają „naprawiając" kod:

| Kod | Wzorzec |
|---|---|
| `STUB_BODY` | `throw new NotImplementedException()` / `raise NotImplementedError` / `unimplemented!()` / `todo!()` / `TODO()` |
| `EMPTY_CATCH` | `catch (Exception) { }` — swallowing |
| `PRAGMA_DISABLE` | `#pragma warning disable` / `#pragma clang diagnostic ignored` |
| `LINTER_DISABLE` | `// eslint-disable`, `# noqa`, `@SuppressWarnings`, `// tslint:disable`, `// @ts-ignore` / `@ts-nocheck` / `@ts-expect-error` |
| `DEAD_IF` | `if (false) { ... }` / `if (0) { ... }` |
| `COMMENT_OUT_CODE` | ≥60% linii w REPLACE zaczyna się od `//` / `#` / `/*` — kod schowany |
| `NULL_FORGIVING_ABUSE` | `default!` / `null!` / `= null!` — bypass nullable analysis |
| `ASYNC_VOID_STUB` | `async void X(...) { }` — fire-and-forget bez logiki |
| `TYPE_ERASURE` | `Task<Foo>` → `Task<object>`, `Foo x` → `object x` (osobny detektor `seDetectTypeErasure`) |

**Plus `REMOVED_USING`** — wykryty inline w `seFindAndReplace`: FIND zawiera `using X;`
a REPLACE jest pusty → model „naprawił" CS0246 przez wyrzucenie importu.

**Wszystkie 17 case'ów testowych przeszło zielono.**

**Nowy plik:** funkcje w `helpers/safe_edit.php` (~120 linii dodanych):
- `seDetectAntiPatterns($content, $context)` — zwraca listę `[{code, message}, ...]`
- `seDetectTypeErasure($find, $replace)` — osobny, bo wymaga porównania (1 dyspozycja diff)
- `seSearchWorkspaceForTypes($workdir, $names)` — rescue dla CANNOT FIX

**Wpięcia:**
- `seFindAndReplace` — sprawdza `seDetectAntiPatterns($replace)` + `seDetectTypeErasure`
  + `REMOVED_USING` inline
- `tcWsWriteFile` — sprawdza `seDetectAntiPatterns($content)` (zastępuje inline stub-check
  z 0.7.32)
- `tcRunToolLoop` — po reply z `CANNOT FIX` w finalnym tekście, jeśli mamy missing types
  z BUILD_STRUCTURED, system **automatycznie grep'uje workspace** (`seSearchWorkspaceForTypes`)
  szukając gdzie te typy są zdefiniowane. Jeśli znalazł — wstrzykuje raport i **continue
  loop** wymuszając retry z konkretną informacją „typ X istnieje w namespace Y, dodaj
  using". Tylko 1× per turę (synthetic `_cannot_fix_rescue` w tool_calls).

### Zmieniono

- `Core\Version::PATCH` → **34**.
- `tcWsWriteFile` używa shared `seDetectAntiPatterns()` zamiast inline stub-check.
- `helpers/csharp_build.php` ekstraktuje `console_ai_missing_types` z CS0246/CS0103
  errors (regex po polskim/angielskim formacie message).

## [0.7.33] — 2026-05-31

### Naprawiono

#### Iteration budget — per-model + productive extension + smart timeout

Po przełączeniu na `qwen3-coder:30b` zaobserwowano że model **faktycznie pracuje**
(build → read_file → fix → build → ...), tylko 16 iteracji to za mało na 8 błędów CS
× wielu plikach. Trzy poprawki:

**Fix #1: Per-model `max_iter` w profilach**
- DS-Coder: 16 (default — model i tak rzadko coś robi)
- **qwen-coder: 24** (+50% — radzi sobie z agentic, ale wymaga więcej kroków)
- default: 16

Profil może dyktować `max_iter` (`models/<id>.php` → `'max_iter' => 24`).
`tcRunToolLoop` czyta przez `modelProfileGet()`.

**Fix #2: Build error count progression tracking**

`csharpPostProcessBuildResult` po każdym buildzie zapisuje do
`$_SESSION['console_ai_build_history']`:
```
[{errors: 8, at: ...}, {errors: 6, at: ...}, {errors: 3, at: ...}]
```

Trim do 20 ostatnich. Reset na początku każdej tury.

**Fix #3: Productive-iter extension (+4)**

Gdy `iter == maxIter - 1` i ostatnie 2-3 buildy mają **malejący** error count
(np. `[8, 6, 3]`) → automatycznie dorzucamy +4 iter (max 1× per turę). Model
jest blisko konwergencji — szkoda obcinać.

**Fix #4: Smart timeout hint z progresją**

Stary hint mówił tylko „16 iteracji bez sukcesu". Teraz analizuje historię i
klasyfikuje progresję:

```
Progresja błędów buildu: 8 → 6 → 3 → 1 (z 8 do 1)

✓ Model SIĘ ZBLIŻAŁ — kolejny retry najprawdopodobniej domknie problem.
```

Klasyfikacja:
- **descending** (`8→3→1`): „✓ Model się zbliżał — retry domknie"
- **ascending** (`3→6→8`): „⚠ Model robi gorzej — cofnij zmiany"
- **flat** (`5→5→5`): „⚠ Model utknął — podziel zadanie"

Operator natychmiast wie czy retry ma sens czy lepiej zmienić strategię.

### Zmieniono

- `Core\Version::PATCH` → **33**.
- `models/qwen_coder.php` → `max_iter: 24`.

## [0.7.32] — 2026-05-31

### Naprawiono

#### Block stub bodies + detektor halucynacji „claimed action"

Po 0.7.31 zaobserwowano nowy wzorzec failure: model po wymuszonym `_auto_read_file_escape`
dostawał realny content, ale i tak emit'ował `find_and_replace` z:
- **FIND wymyślony** (`// TODO: Implement ExecuteToolAsync method` — tego w pliku nie ma)
- **REPLACE jako placeholder** (`throw new NotImplementedException()` — formalnie „kompiluje", ale nic nie naprawia)

System odmawiał zapisu (0 occurrences w FIND), ale w następnej odpowiedzi model
twierdził „**zaktualizowałem plik**" — czysta halucynacja akcji. Plik na dysku
nietknięty.

**Fix #1: STUB BODIES blocked**

Trzy miejsca:
- `tcWsWriteFile` (write_file content)
- `seFindAndReplace` (REPLACE content)
- Wzorce: `throw new NotImplementedException()`, `=> throw new NotImplementedException`,
  `raise NotImplementedError(`, `unimplemented!()`, `todo!()`, `panic!("todo")`,
  `TODO("...")` (Kotlin)

Komunikat:
> ERROR: content contains a STUB BODY. This does NOT fix anything — it just defers
> the work. Provide a REAL implementation. If you cannot, reply with `CANNOT FIX:
> <reason>` instead of writing a stub.

Pomija pliki czysto interface'owe (`.d.ts`, `.h`, `.hpp`).

**Fix #2: Detektor `consoleAiDetectFakeAction`**

Nowy detektor w `admterminal.php`. Sygnał:
- Reply ≥30 znaków
- Zawiera frazę typu „I have updated/fixed/changed", „I've modified", „Plik został
  zaktualizowany/naprawiony", „zaktualizowałem plik/kod" (5 wzorców PL+EN)
- W tej turze ZERO udanych mutating tool calls (wszystkie write_file/find_and_replace/
  apply_diff zwróciły ERROR — lub w ogóle ich nie było)

Zwraca `true` → JSON response ma `fake_action: true` → UI pokazuje **czerwony chip**:

> ⚠ **Fałszywa akcja wykryta:** model w tekście twierdzi że „zaktualizował/naprawił/
> zmienił" plik, ale w tej turze WSZYSTKIE próby zapisu zakończyły się błędem —
> plik na dysku jest **nietknięty**. Model halucynuje skutek. Ponów wiadomość
> albo przełącz na mocniejszy model.

Operator natychmiast widzi że to było kłamstwo i nie traci czasu na sprawdzanie
„czy faktycznie się zapisało".

### Zmieniono

- `Core\Version::PATCH` → **32**.

## [0.7.31] — 2026-05-31

### Naprawiono

#### Build-context-aware error recovery

Po 0.7.30 zaobserwowano nowy failure mode: model po (wreszcie) wyemitowanym tool
call'u wybierał **niewłaściwy plik** — np. `Program.cs` (klasyczny C# default
file, mocno overrepresented w training data), zamiast jednego z faktycznych
failing files z BUILD_STRUCTURED. read_file zwracał „file not found", model
floundered, iter budget się wyczerpywał.

**Fix #1: Session-tracked failing files** — w `csharpPostProcessBuildResult`
po każdym failed buildzie zapisujemy listę plików z błędami do
`$_SESSION['console_ai_build_failing_files']` + timestamp. Wykorzystywane:

**Fix #2: Build-aware did-you-mean w `read_file`** — gdy model próbuje czytać
nieistniejący plik a w ciągu ostatnich 5 min był failed build, error message
zawiera listę REALNYCH failing files:

```
ERROR: file not found: "Program.cs".

⚠ Last `dotnet build` reported errors in these files — read ONE of them
instead of guessing `Program.cs`:
  - Utils/IToolExecutor.cs
  - Utils/ToolLoop.cs
  - Forms/MainForm.cs
Retry `read_file` with one of those paths.
```

Stary fuzzy match `similar_text` zostaje jako fallback gdy session nie pasuje.

**Fix #3: Rozszerzone okno anti-empty-finish guard'a** — wcześniej sprawdzało
tylko `array_slice($allToolCalls, -3)`. Skutek: gdy model emit'ował 3-4 zbędne
`read_file` po failed build, BUILD_STRUCTURED „wypadał" z okna i guard milczał.
Teraz iterujemy **całą listę** od początku, szukając OSTATNIEGO BUILD_STRUCTURED
FAILURE i sprawdzając czy MIĘDZY nim a teraz pojawił się jakikolwiek mutating
call (write_file/find_and_replace/apply_diff).

**Fix #4: Escape hatch używa session list zamiast regex** — auto-read po 2×
guardach poprzednio robił regex po raw output (zawodne przy długich raportach).
Teraz preferuje `$_SESSION['console_ai_build_failing_files'][0]` (dokładna lista
z BUILD_STRUCTURED parser'a). Regex pozostaje jako fallback.

### Zmieniono

- `Core\Version::PATCH` → **31**.

## [0.7.30] — 2026-05-31

### Naprawiono

#### Anti-empty-finish guard — twardszy hint + escape hatch dla DS-Coder

Po wprowadzeniu guard'a w 0.7.29 zaobserwowano że DS-Coder v2:16b nadal kończył
turę emitując **deklaratywny tekst** typu „I will now read the file..." bez
realnego tool call. Guard odpalał się 3× pod rząd, model za każdym razem obiecywał
ale nie wykonywał („future-tense fallacy" — klasyczne dla modeli z kodowym
training data).

**Dwa fix'y w `tcRunToolLoop` ([tools_lib.php](admin/pages/consoleai/terminal/tools_lib.php)):**

**1. Wzmocniony anti-empty-finish hint:**
- Explicit ban frazom: „I will", „I'll now", „Let me", „Next I'll", „I am going to"
- Wymóg: następna odpowiedź **MUSI** zacząć się tool call'em, no prose
- Przykład formatu (Format A `<function=read_file><parameter=path>...</parameter></function>`)
- Escape route: jeśli model genuinie nie potrafi, ma odpowiedzieć dokładnie
  `CANNOT FIX: <one-sentence reason>` i stop (zamiast obiecywać)

**2. Auto-read escape hatch:**
- Po **2× nieudanego guarda** w jednej turze (model nadal obiecuje zamiast działać)
- System SAM wyłuskuje pierwszy failing file z BUILD_STRUCTURED output (regex po
  formacie `path(line,col): error`), konwertuje absolute → relative
- SAM wykonuje `tcWsReadFile` na tym pliku
- Wstrzykuje wynik jako `role: tool` message PLUS twardy hint user:
  > „AUTO-EXECUTED by system. Here is the content. Your next response MUST be a
  > `find_and_replace` tool call. NO MORE 'I will'. EMIT THE TOOL CALL."
- Synthetic `_auto_read_file_escape` w `$allToolCalls` (UI widzi że system go popchnął)
- Model dostaje już CONTENT pliku — nie ma czego unikać, musi działać

**Logika dlaczego to działa:** model emituje „I will read..." bo decyzja co czytać
i jak działać jest poznawczo kosztowna. Gdy system DA mu już content (z aktualnym
kodem), kolejny krok (find_and_replace fragment) jest dużo bardziej deterministyczny
— model widzi konkretny błędny wiersz i jego kontekst.

Loguje `Anti-empty-finish guard fired` z `count` (do diagnostyki — jeśli `count >= 3`,
oznacza że nawet escape hatch nie pomógł i model jest fundamentalnie nieagentowy).

### Zmieniono

- `Core\Version::PATCH` → **30**.

## [0.7.29] — 2026-05-31

### Dodano

#### Console AI — follow-through po failed build

**1. `csharpPostProcessBuildResult` — sekcja NEXT STEPS** dla failed buildu.
Wcześniej model dostawał czytelny BUILD_STRUCTURED raport i kończył turę.
Teraz po raporcie doklejamy **imperatywną instrukcję** „DO NOT END THE TURN HERE":

```
NEXT STEPS — DO NOT END THE TURN HERE. The build failed; you MUST now FIX the errors:
  1) CS0246 missing types: ToolResult, ToolCall, OllamaService, ChatRepository.
     For EACH: either add `using SomeNamespace;` to the file, OR create the missing class.
     Start with: `read_file Utils/IToolExecutor.cs` to see the current usings.
  STARTING ACTION: call `read_file` on `IToolExecutor.cs` NOW to begin diagnosis.
  After fixing: re-run `dotnet build` to verify. Iterate until exit 0.
  Tools to use: `find_and_replace` (PREFERRED), `apply_diff`, or `write_file`,
  then `run_command dotnet build`. DO NOT just describe what should be done — DO IT.
```

Sekcja dzieli błędy na grupy: CS0246 (missing types — wyciąga nazwy z message
regexem), CS0103 (names not found), inne. Pokazuje konkretny `STARTING ACTION`
z pierwszym plikiem do otwarcia.

**2. Anti-empty-finish guard w `tcRunToolLoop`** — wykrywa wzorzec
„model dostał failed build i zakończył turę bez fixa". Sprawdza ostatnie 3
tool_calls przed finalnym return:
- czy występuje `BUILD_STRUCTURED [FAILURE]` / `NIEPOWODZENIE (exit `
- czy nie było po nim żadnego mutującego toola (`write_file`/`find_and_replace`/`apply_diff`)

Jeśli oba warunki + budget iteracji nie wyczerpany → wstrzykuje syntetyczną
wiadomość `user` z hintem „FOLLOW-UP REQUIRED" i KONTYNUUJE pętlę zamiast zwracać.
Synthetic tool call `_anti_empty_finish` ląduje w `tool_calls` (UI może go pokazać).

#### Console AI — ikony copy/download per sub-task

W bańce `decompose_and_execute` każdy ukończony sub-task (`<div class="tc-decompose-step">`)
ma teraz **trzy ikony** w nagłówku (analogicznie do `tc-msg-actions` w głównych bańkach):
- ⟳ Retry (już wcześniej, tylko gdy `is-fail`)
- ⬇ Download (`.md` z task + verdict + worker)
- 📋 Copy (do schowka)

JS: nowe delegated listenery na `.tc-subtask-copy` / `.tc-subtask-download` w
`messagesEl`, helper `tcExtractSubtaskText(stepEl)` składa markdown:
```md
## Krok 1/3 (SUKCES)
**Zadanie:** ...
**Werdykt:** ...
**Wykonawca:** ...
```
Plus helper `tcDownloadBlob(text, filename)` (reusable). CSS: styl `.tc-subtask-actions`
+ `:hover` + `.tc-copied` (zielony checkmark feedback).

### Zmieniono

- `Core\Version::PATCH` → **29**.

## [0.7.28] — 2026-05-31

### Dodano

#### Console AI — Pakiet A: bezpieczniejsze edycje (Aider-style)

**A1. `find_and_replace` tool** — atomic find/replace na fragmencie zamiast
całego pliku (jak `write_file`). Bezpieczniejsze: nie ma blind overwrite, nie ma
size delta issues, `count_expected` zabezpiecza przed niespodziankami (find pasuje
N×, model myślał że 1×). „Did you mean?" hint przy braku match (similar_text na
pierwszej linii). Backup snapshot + syntax check + post-write hint (build + test).

**A2. `apply_diff` tool** — stosuje unified-diff (z `---`/`+++`/`@@`/`-`/`+`/` `
prefixami). Mniejsze tokeny output dla małych zmian (~10× redukcja). Multi-hunk
support. Odrzuca: hunk nie pasuje, hunk ambiguous (same old-block w wielu miejscach).
Backup + syntax check + post-write hint identyczne jak find_and_replace.

**A3. Live diff w bańce czatu** — wynik write_file/find_and_replace/apply_diff
renderowany z kolorowaniem (zielony `+`, czerwony `-`, fioletowy `@@`). Dla
find_and_replace dodatkowo widget grid „FIND ↔ REPLACE" z dwoma blokami obok
siebie. CSS w admterminal.viewcss.php, JS helper `renderDiffColored()`.

**Nowy plik:** `helpers/safe_edit.php` (~270 linii — `seFindAndReplace`,
`seApplyDiff`, `seParseUnifiedDiff`, `seFuzzyFindHint`, `seDefineSafeEditTools`).

#### Console AI — Pakiet B: feedback loop

**B1. Auto-test discovery** — po `write_file`/`find_and_replace`/`apply_diff` na
pliku źródłowym, system szuka powiązanych testów (`FooTests.cs`, `Foo.test.ts`,
`test_foo.py`, `foo_test.go`) i dorzuca `TEST HINT` z gotową komendą:
- C#: `dotnet test --no-build --filter "FullyQualifiedName~Foo"`
- TS/JS: `npm test -- --testPathPattern=Foo` (lub jest)
- Python: `python -m pytest -k foo`
- Go: `go test -run Foo ./...`

Skanuje rekursywnie (max 5000 plików, pomija node_modules/.git/bin/obj/vendor/.venv).

**Nowy plik:** `helpers/test_discovery.php` (~120 linii — `tdDiscoverTests`,
`tdSuggestTestCommand`, `tdPostWriteTestHint`).

#### Console AI — Pakiet C: lifequality

**C1. Approval policies** — timer-based auto-approve dla `run_command`. Operator
może w UI dodać policy „pattern → TTL". Pattern może być prefix (np. `dotnet build`)
lub regex (`/^git (status|diff)/`). Aktywne policies pomijają okno zgody. Max 20
aktywnych, auto-GC expired przy każdym add.

**C2. Token budget per turn** — limity:
- soft warn @ 50000 tok → hint w odpowiedzi
- hard stop @ 200000 tok → przerwanie pętli z BUDGET_EXHAUSTED error
Reset na początku każdej tury (per-tura, nie kumuluje). Liczone z `$res['usage']`
po każdym `tcChatTurnWithTools`.

**C3. Project memory / RAG** — wczytuje automatycznie `CLAUDE.md` / `AGENT.md`
/ `.cursorrules` / `.windsurfrules` / `.github/copilot-instructions.md` z workdira
(max 8 KB każdy, max 2 sources). Doklejone do system prompta jako PROJECT
INSTRUCTIONS. Model widzi konwencje projektu bez konfiguracji.

**C4. Cost meter UI** — chip w pasku folderu roboczego pokazujący tokeny in/out
i szacunkowy koszt USD. Pricing per 1M tok:
- Claude: $3/$15 (sonnet), $15/$75 (opus), $0.80/$4 (haiku)
- Groq: $0.59/$0.79
- Gemini: $1.25/$5 (pro), $0.075/$0.30 (flash)
- Ollama/GitHub Models: $0 (lokalne/free)

Polling co 8s + odświeżenie po `load`. Chip kolorowany: szary (<$0.10),
żółty (>$0.10), czerwony (>$1.00).

**Nowy plik:** `helpers/agent_quality.php` (~230 linii — 14 funkcji eksportowanych:
`aqMatchesPolicy`/`AddPolicy`/`ListPolicies`/`ClearPolicies`, `aqResetBudget`/
`RecordTokens`/`SetBudget`/`GetBudgetState`, `aqLoadProjectMemory`,
`aqPricingFor`/`RecordCost`/`GetCostMeter`/`ResetCostMeter`).

#### Endpoint'y AJAX

- `console_ai_cost_meter` — zwraca cost meter state (do UI polling)
- `console_ai_add_policy` — `{pattern, ttl_seconds}` → dodaje approval policy
- `console_ai_clear_policies` — kasuje wszystkie policies (panic button)

Wszystkie zarejestrowane w `admin/index.php` `$ajaxActions`.

### Zmieniono

- `Core\Version::PATCH` → **28**.
- `tcDefineWorkspaceTools` — dodaje `find_and_replace` + `apply_diff` gdy
  `$includeWrite` (przed `write_file`).
- `tcExecuteTool` — dispatch dla nowych tools (`find_and_replace`, `apply_diff`).
- `tcRunToolLoop` — record tokens & cost po każdym model call; hard stop @ budget.
- `wvResetTurnContext` — woła też `aqResetBudget`.
- `run_command` auto-approve path — sprawdza `aqMatchesPolicy` przed `cmd_allow`.
- Admterminal builder — `aqLoadProjectMemory($workdir)` w prompcie po project hints.
- `admterminal.view.php` — `<textarea>` zamiast `<pre><code>` dla `tc-cmd-text`
  (już w 0.7.27) + chip `tc-cost-meter` w workdir bar.
- `admterminal.viewjs.php` — `renderDiffColored()`, `refreshCostMeter()` z 8s
  polling, `renderToolCalls` z A3 diff colors i find/replace widget.

### Testy (10/10 zielone w integracji)

| Pakiet | Test | Wynik |
|---|---|---|
| A1 | find_and_replace happy path | OK |
| A1 | count_expected mismatch reject | OK |
| A2 | apply_diff happy path | OK |
| B1 | discovery Calculator.cs → CalculatorTests.cs | OK |
| C1 | prefix policy `dotnet build` matches | OK |
| C1 | regex policy `/^git (status|diff)/` matches | OK |
| C1 | unmatching command not auto-approved | OK |
| C2 | budget states (ok/warn/stop) | OK |
| C3 | CLAUDE.md loaded → „PROJECT INSTRUCTIONS" w prompcie | OK |
| C4 | cost meter — claude pricing, ollama $0 | OK |

## [0.7.27] — 2026-05-31

### Dodano

#### Console AI — error recovery i live correction (12 wzorców z Cline/Continue/Aider/Cursor)

Pełna warstwa korekcji zapytań i błędów w locie. Każde tool call przechodzi
przez 5-stopniowy pipeline:

```
sanitize args → validate schema → execute → auto-retry → enhance error + meta-hint
```

**Nowy plik:** `admin/pages/consoleai/terminal/helpers/error_recovery.php`
(~310 linii, 8 funkcji publicznych):

1. **`erSanitizeArgs($tool, $args)` (#7)** — per-tool cleanup:
   - path/filename: strip cudzysłowy, backticki, leading „file:"/"path:" label
   - command: strip markdown fences, prefix `$`/`>`/`PS>`
   - content (write_file): strip otaczające ` ```lang … ``` `
2. **`erValidateAgainstSchema($tool, $args, $schema)` (#12)** — pre-flight check
   wymaganych parametrów. Brakujące → `MISSING_PARAM` ERROR z listą + typami,
   BEZ uruchamiania toola.
3. **`erEnhanceError($tool, $args, $err, $schema)` (#8)** — dokleja pełny schemat
   toola (lista params + typy) + wysłane args do error message. Pomocne dla
   modeli małych „zapominających" schemat.
4. **`erFuzzyMatchPath($missingRel, $workdir)` (#2)** — „Did you mean?" — `similar_text`
   na podstawie basename, top-3 plików ≥60% similarity. Skanuje rekursywnie
   (max 5000 plików, pomija node_modules/.git/bin/obj/vendor). Wpięte w
   `tcWsReadFile` przy „file not found".
5. **`erAutoRetry($tool, $args, $err)` (#1)** — 1-shot self-heal dla typowych korekt:
   - normalize path (`./`, `//` strip)
   - save_file: strip folder z filename
   - content: strip markdown fences (fallback dla sanitize)
   Po udanym retry: result ma prefix `[AUTO-RECOVERED: <reason>]`.
6. **`erTrackFailure($key)` + `erGetMetaHint($key, $count)` (#11)** — failure
   clustering. Po 3× tym samym błędzie generuje meta-hint:
   - `path:not_found:foo.cs` ×3 → „stop guessing paths, call list_dir first"
   - `cs0246:Type` ×3 → „add `using` directive or CREATE the missing class"
   - `cs0103:name` ×3 → „typo or missing using"
   - `write:placeholder` ×3 → „STOP writing placeholder comments"
   - `write:size_delta` ×3 → „write_file is OVERWRITE not PATCH"
7. **`erClassifyError($tool, $args, $err)`** — klasyfikator → cluster key (used
   internally).
8. **`erResetFailureCluster()`** — reset stanu między turami (wołane z
   `wvResetTurnContext`).

**#4 Pre-execution dry-run** — nowy parametr `dry_run: true` w `write_file`.
Tool zwraca unified diff (stary↔nowy content, max 200 zmian) BEZ zapisu.
Funkcja `tcWsDryRunDiff()` w `tools_workspace.php`. Model może użyć żeby
zweryfikować zmianę przed committem.

**#10 Live command edit** — modal zatwierdzania komendy ma teraz **editable
textarea** (`<textarea id="tc-cmd-text">` zamiast `<pre><code>`). Operator
może zmienić komendę przed Allow. JS wysyła `command_edited` w POST, backend
honoruje to (z logiem zmiany).

**Wpięcia:**
- `tools_lib.php` `tcRunToolLoop` — całe pipeline owija każde wywołanie toola
  w pętli (sanitize → validate → execute → retry → cluster → enhance).
- `tools_workspace.php` `tcWsReadFile` — fuzzy-match przy „file not found".
- `helpers/write_verify.php` `wvResetTurnContext` — woła `erResetFailureCluster`.
- `admterminal.viewjs.php` — `showNextCommand` używa `.value` zamiast
  `.textContent`; `runApprovedCommand` wysyła `command_edited`.
- `admterminal.php` `console_ai_run_command` — honoruje `command_edited` z POST.

### Zmieniono

- `Core\Version::PATCH` → **27**.

### Testy (8/8 zielone)

| Funkcja | Test case'y | Wynik |
|---|---|---|
| `erSanitizeArgs` | 5 (path/cmd/content z prefixami i fences) | 5/5 |
| `erValidateAgainstSchema` | 2 (complete + missing) | 2/2 |
| `erEnhanceError` | 1 (schema reminder doklejony) | OK |
| `erFuzzyMatchPath` | 1 (Mainfrm.cs → MainForm.cs 85%) | OK |
| `erAutoRetry` | 3 (path normalize, filename strip, fences) | 3/3 |
| `erTrackFailure`/`MetaHint` | 4 (counts 1-4, hint po 3) | 4/4 |
| `erClassifyError` | 3 (path/placeholder/size) | 3/3 |

## [0.7.26] — 2026-05-31

### Dodano

#### Console AI — write_file verification (7 checków wzorowanych na Cline/Continue/Aider)

Workspace `write_file` ma teraz pełną warstwę weryfikacji **przed** zapisem
(w stylu popularnych VS Code agentów — Cline, Continue, Aider, Cody, Roo):

1. **Read-before-write enforcement** — `write_file` na istniejącym pliku WYMAGA prior
   `read_file` w tej samej turze. Bez tego model strzela na ślepo. Per-turn tracker
   plików read'owanych żyje w `$_SESSION['console_ai_turn_ctx']`, resetowany na
   początku każdej tury. Nowe pliki: OK bez read.
2. **File-size delta sanity** — gdy istniejący plik >500 B, a nowy <50% rozmiaru →
   BLOCK. Łapie błąd „model wpisał tylko zmienioną sekcję myśląc że write_file
   patch'uje" — kosztowny, bo overwrite kasuje 50% kodu.
3. **Auto-syntax check po write** — uruchamiany dla:
   - `.php` → `php -l` (lint przez tmpfile + proc_open)
   - `.json` → `json_decode` z `json_last_error()`
   - `.xml`/`.html`/`.svg` → DOMDocument + libxml errors
   - `.yaml`/`.yml` → `yaml_parse` (jeśli ext-yaml) / heurystyka mixed tab/space
4. **Auto-revert on syntax fail** — gdy syntax check po overwrite zawiedzie,
   `write_file` zwraca ERROR i NIE wykonuje zapisu (file unchanged). Plik na dysku
   zostaje w starym stanie.
5. **Indent/EOL preservation** — porównuje styl wcięć (tabs vs spaces, sample z
   pierwszych 100 linii) i EOL (LF vs CRLF) między starym a nowym contentem.
   Mismatch = WARNING (nie blokuje — model może legitymalnie konwertować).
6. **Backup ring** — N=3 ostatnich wersji każdego pliku zapisywane w
   `<temp>/console_ai_backup/<hash>/<timestamp>.bak` przed nadpisaniem. Plik max
   512 KB. Ring rotuje (najstarsze kasowane). `wvBackupRestoreLatest()` pozwala
   na manual revert.
7. **Post-write build hint** — po write `.cs`/`.fs`/`.vb`/`.ts`/`.tsx`/`.rs`/`.go`
   automatycznie podpowiada modelowi konkretną komendę weryfikacji (`dotnet build`,
   `tsc --noEmit`, `cargo check`, `go vet`). Hint dodany do return value
   `write_file` jako NEXT-STEP HINT. Detekcja na bazie marker-plików projektu.

**Nowy plik:** `admin/pages/consoleai/terminal/helpers/write_verify.php`
(~390 linii, 12 funkcji eksportowanych: `wvRunAllChecks`, `wvCheckReadBeforeWrite`,
`wvCheckSizeDelta`, `wvCheckIndentEol`, `wvSyntaxCheck` + 4 subwarianty,
`wvBackupSnapshot`/`Restore`/`List`, `wvPostWriteBuildHint`, `wvNoteRead`,
`wvResetTurnContext`).

**Wpięcia:**
- `tcWsWriteFile` ([tools_workspace.php:417-465](admin/pages/consoleai/terminal/tools_workspace.php#L417-L465))
  — `wvRunAllChecks` → blokuje przy błędzie, dokleja warning przy stylu, dorzuca
  build hint. Backup snapshot dla istniejących plików.
- `tcWsReadFile` — woła `wvNoteRead($target)` po sukcesie.
- `console_ai_send` — `wvResetTurnContext()` na początku każdej tury.
- `tools_lib.php` — `require_once helpers/write_verify.php`.

#### Sub-loop helper — `run_command` dostępne + strict verifier

Sub-loop pomocnika w `decompose_and_execute` cierpiał na „fałszywe SUKCES'y" —
helper nie miał `run_command`, więc zadania typu „uruchom build" nie były wykonywane
ale werdyktor zaliczał je. Naprawa:

- **Helper dostaje `run_command`** gdy `cmd_enabled` w ctx (`tcRunHelperSubLoop` w
  `tools_executors.php`). Trusted programs propagują z `cmd_allow`, więc np. `dotnet
  build` auto-uruchamia się bez okna zgody.
- **Strict verifier prompt** — werdyktor dostaje listę REALNYCH wywołań toolów
  i zasady: BUILD/RUN → wymaga `run_command`; FIX/CHANGE → wymaga `write_file`;
  ANALIZA → `read_file` wystarczy.
- **Anti-empty-success guard** — po werdykcie: jeśli SUKCES ale task ma słowa-klucze
  (build/napraw/fix/uruchom/dodaj/zapisz) i helper nie wywołał żadnego mutującego
  toola → automatyczna PORAŻKA z czytelnym komunikatem „brak run_command przy zadaniu
  o build".

### Zmieniono

- `Core\Version::PATCH` → **26**.

## [0.7.25] — 2026-05-31

### Dodano

#### Console AI — architektura per-model profiles + helpers C# build
Konsolidacja całej logiki specyficznej dla konkretnych modeli LLM (DeepSeek-Coder,
qwen-coder, …) do dedykowanych plików profilowych. Każdy model z idiosynkrazjami
ma teraz własny plik `models/<id>.php`, który dyktuje: prompt tail, opcje generacji
Ollamy (temperature, top_p, top_k, stop sequences, num_predict), czy pomijać natywny
function-calling (Text-Emulation), oraz funkcję `clean_content()` do post-processu
odpowiedzi (np. wycinanie wycieków special tokenów).

**Nowe pliki:**
- `admin/pages/consoleai/terminal/models/_registry.php` — dispatch + auto-discovery
  wszystkich profili z folderu `models/*.php` (poza `_*.php`).
- `admin/pages/consoleai/terminal/models/deepseek_coder.php` — profil DS-Coder
  (v1/v2, wszystkie rozmiary). Zawiera: regex match, 9-regułowy prompt tail (DS1-DS9
  — anti-tutor, no-placeholder-code, definitive voice, language lock, no preamble,
  no repetition, anti-tutor reinforcement, absolute paths, tool call JSON key),
  Text-Emulation mode (skip native tools + format A `<function=…>`),
  ollama options override (temp ≤ 0.2, top_p 0.95, top_k 40, repeat_penalty 1.10,
  num_predict ≥ 6144, 9 stop sequences dla special tokenów), clean_content cutting
  `<｜begin▁of▁sentence｜>` i wariantów.
- `admin/pages/consoleai/terminal/models/qwen_coder.php` — profil qwen-coder
  (qwen2.5-coder/qwen3-coder). Lżejsze niż DS — natywne function calling działa
  OK, więc głównie language lock + anti-placeholder rules.
- `admin/pages/consoleai/terminal/helpers/csharp_build.php` — biblioteka funkcji
  post-processu outputu `dotnet build`/`msbuild`/`dotnet test`:
  - `csharpLooksLikeBuildCommand($cmd)` — heurystyka detection
  - `csharpParseCsErrors($output)` — strukturalna lista
    `[{file, line, col, severity, code, message, project}]`, deduplikacja
    po `code:message_prefix`
  - `csharpBuildSummary($output)` — `{ok, errors_count, warnings_count, tail}`
  - `csharpDetectNeedsRestore`, `csharpDetectLockedFiles`,
    `csharpDetectFrameworkMismatch`, `csharpDetectProjectMissing`,
    `csharpDetectScaffoldConflict` — automatyczne ADVICE-hinty
  - `csharpTrimBuildOutput($output, $maxLines)` — wycinanie MSBuild noise
  - `csharpPostProcessBuildResult($cmd, $exit, $output)` — pełen raport
    `BUILD_STRUCTURED [SUCCESS/FAILURE]` z first_errors + hints

**Wpięcia:**
- `tools_providers.php` `tcChatOllama()` — używa `modelProfileGet()` zamiast
  inline `preg_match('/deepseek.../', $model)`. Profile decyduje o opcjach
  generacji i czy pomijać `tools` w payloadzie. `clean_content()` wycina
  artefakty modelu przed zwróceniem.
- `admterminal.php` builder system prompta — wstrzykuje `tools_text_format()`
  i `prompt_tail()` z profilu na końcu (recency bias).
- `tools_executors.php` `run_command` (auto-run path) — gdy build dotnet/msbuild
  zakończony, post-process z `csharpPostProcessBuildResult` przed surowym
  outputem. Model dostaje strukturalny summary zamiast 5000 linii MSBuild noise.
- `admterminal.php` `console_ai_run_command` (po zgodzie operatora) —
  analogicznie post-process.

#### Naprawy parser i pathów
- **Parser JSON akceptuje `"function"` jako alias `"name"`** — DeepSeek-Coder
  często używa tego klucza. Też wspiera nested `{"function": {"name": "...",
  "arguments": {...}}}` (OpenAI spec).
- **Workspace resolve auto-konwersja absolute → relative** — DS i inne modele
  często zwracają pełną ścieżkę `W:/App/AppTerminal/Forms/MainForm.cs`. System
  wykrywa, że jest wewnątrz workdira, i strip-uje prefix (case-insensitive na
  Windows). Poza workdirem → reject z jasnym komunikatem.
- **Detekcja placeholder-comments** w `write_file` — wykrywa `// Your existing
  code`, `// ... existing code ...`, `// rest of file unchanged`, `// fill in
  the rest`, `/* existing code */`, `<!-- existing content -->`, `# ... existing
  code ...` (Python). write_file OVERWRITES cały plik — taki komentarz zastąpiłby
  istniejący kod. Reject z instrukcją „read_file FIRST, then merge, then write".

#### Format A parser — JSON-decode wartości
- `tcParseTextToolCalls` Format A (`<function=NAME><parameter=KEY>VAL</parameter>`)
  teraz próbuje `json_decode` dla wartości wyglądających na strukturalne
  (`[…]`, `{…}`, `true`/`false`/`null`, liczby). Bez tego `sub_tasks=["a","b"]`
  trafiał jako single string, a `verify_first` jako string "true" zamiast bool.

### Zmieniono

- `consoleAiIsDeepSeekCoder()`, `consoleAiDeepSeekPromptTail()`,
  `consoleAiToolsToTextFormat()` w `admterminal.php` — usunięte / wrapped
  jako thin wrappery. Logika żyje teraz w `models/deepseek_coder.php`.
  Zewnętrzne call-sites (jeśli są) używają tylko `consoleAiIsDeepSeekCoder()`.
- `Core\Version::PATCH` → **25**.

### Architektura

Wzorzec na przyszłość: każdy model z idiosynkrazjami dostaje plik
`models/<id>.php` zwracający tablicę z callbackami (`matches`, `prompt_tail`,
`tools_text_format`, `skip_native_tools`, `ollama_options`, `clean_content`).
Registry znajduje pierwszy match po `matches()` i zwraca profil (lub default
no-op). Dodanie nowego modelu = dodanie jednego pliku, bez dotykania
admterminal.php/tools_providers.php.

## [0.7.24] — 2026-05-30

### Dodano

#### Zakładka **„Kolejność"** — sterowanie chain'em wyszukiwarek (sortowanie + aktywność)
- W *Ustawienia → Integracje Search* pojawiła się nowa, **domyślnie otwarta** zakładka
  **„Kolejność"**, z tabelą wszystkich 7 providerów. Per-row:
  - **Checkbox „Aktywny"** (form-switch) — wyłącz providera bez kasowania klucza/URL,
    chain pominie go i przejdzie do następnego.
  - **Numer rangi** (1..N) liczony live z aktualnej kolejności.
  - **Nazwa providera** (ikona + label + key wewnętrzny w `code`).
  - **„Wymaga"** — krótki opis czego potrzebuje (klucz / URL / nic).
  - **Status** (plakietka): `test OK` (zielony) / `test FAIL` (żółty) / `live` (DDG/SearxNG
    public — sprawdzane w runtime) / `brak konfiguracji` (klucz/URL pusty).
  - Przyciski **↑/↓** do reorder'u (auto-disabled na pierwszym/ostatnim wierszu).
- Przycisk **„Reset do defaultu"** — przywraca standardową kolejność (Tavily → ScrapeGraphAI
  → SearxNG self-hosted → DDG html → DDG lite → SearxNG public → Brave) i wszystkie aktywne.
- Save → `ai_search_chain_save` → wpisuje `ScnSortOrder` i `ScnActive` do `def_api_search_chain`,
  redirect z hash'em `#tab-chain`.

#### Refactor `tcWebSearch` — dynamiczny chain z DB
- Funkcja `tcWebSearch` czyta teraz **kolejność i aktywność z `def_api_search_chain`** (tylko
  wiersze `ScnActive=1`, ORDER BY `ScnSortOrder`). Stara hardcoded kolejność pozostaje jako
  fallback gdy tabela jeszcze nie istnieje (np. przed pierwszym wejściem w Settings).
- Każdy provider opakowany w `tcSearchTryProvider($key, $query, $n)` — DRY zamiast 7 powtórzeń
  inline z różnymi config-loadami i wywołaniami.
- Helper `tcSearchProviderLabel($key)` — czytelne nazwy dla logów / komunikatów błędów.
- Końcowy komunikat „all search engines unavailable" wskazuje teraz na zakładkę „Kolejność"
  jako miejsce konfiguracji.

### Zmiany strukturalne (DB)

Zob. [changelog-db.md](changelog-db.md) — nowa tabela `def_api_search_chain` (multi-row,
7 providerów seed).

---

## [0.7.23] — 2026-05-30

### Dodano

#### Nowa strona **Integracje Search** (rozdzielenie z Integracje AI)
- Search-providery przeniesione z `?page=ai` do dedykowanej strony **`?page=aisearch`**
  („Ustawienia → Integracje Search" w menu, obok „Integracje AI").
- 4 zakładki: **Tavily** / **ScrapeGraphAI** / **SearxNG self-hosted** / **Brave Search**.
  Tab-view files reused z `admin/pages/settings/ai/admai.tab-*.view.php` (DRY).
- W „Integracje AI" zostaje **link „Integracje Search →"** w nav-tabach prowadzący na nową stronę.
- Handlery (`ai_tavily_save`, `ai_scrapegraph_save`, `ai_searxng_save`, `ai_brave_save` + odpowiadające `_test_ajax`) w nowym [admaisearch.php](../admin/pages/settings/aisearch/admaisearch.php) z redirectem do `?page=aisearch#tab-<provider>`.
- Wspólny `searchTestModal()` JS helper w [admaisearch.viewjs.php](../admin/pages/settings/aisearch/admaisearch.viewjs.php) — DRY zamiast 4×30 linii.

#### Trzeci search-provider: **ScrapeGraphAI** (sgai-...)
- Agentowa wyszukiwarka + scrape stron — endpoint `POST https://api.scrapegraphai.com/v1/searchscraper`, auth `SGAI-APIKEY: sgai-…`.
- Zwraca AI-zinterpretowany `result` + listę `reference_urls` (URL-e scraped'ed stron).
- Wpięty do chain'u `tcWebSearch` na **pozycji 2** (po Tavily, przed SearxNG self-hosted):
  ```
  Tavily → ScrapeGraphAI → SearxNG self-hosted → DDG html → DDG lite → SearxNG public → Brave
  ```
- Walidacja formatu klucza (`sgai-…`) z czytelnym błędem przy złym prefixie.
- Obsługa specyficznych HTTP: 401/403 (auth), 402 (brak creditów), 429 (rate-limit), async `status: running` (request_id polling — na razie sygnalizujemy „spróbuj ponownie").
- Pliki: [tools_executors.php](../admin/pages/consoleai/terminal/tools_executors.php) (`tcSearchScrapeGraph`),
  [admai.tab-scrapegraph.view.php](../admin/pages/settings/ai/admai.tab-scrapegraph.view.php) (widok zakładki).

### Zmiany strukturalne (DB)

Zob. [changelog-db.md](changelog-db.md) — nowa tabela `def_api_scrapegraph`.

### Naprawiono

- **Tavily auth — `api_key` w body JSON**: poprzednio wysyłaliśmy tylko `Authorization: Bearer`, niektóre wersje Tavily wymagają obu (lub samego body). Teraz wysyłamy `api_key` w body + Bearer header — kompatybilność z każdą wersją API. Plus walidacja formatu klucza (`tvly-…`) z czytelnym błędem przy złym prefixie (np. wkleiony klucz z innego serwisu).

---

## [0.7.22] — 2026-05-30

### Dodano

#### Dwa nowe providery wyszukiwania: **Tavily** (LLM-ready) + **SearxNG self-hosted**
- **Tavily** — search-provider zaprojektowany pod LLM agents. Free tier **1000 zapytań/mc bez karty**.
  Zwraca pole `content` z oczyszczonym tekstem strony (nie surowe linki) → mniejszy wsad dla modelu.
  Endpoint `POST https://api.tavily.com/search`, auth `Authorization: Bearer tvly-…`.
  Nowa zakładka **„Tavily"** w *Ustawienia → Integracje AI* (klucz, test AJAX z licznikiem wyników).
- **SearxNG self-hosted** — własna instancja Dockerowa user-a (`docs/llm/searxng-selfhosted.md`).
  Nielimitowane wyszukiwanie, bez konta, bez karty. Nowa zakładka **„SearxNG self-hosted"** —
  pole na URL bazowy (np. `http://localhost:8888`), test AJAX, sprawdzenie czy `format=json`
  jest włączony w `settings.yml`. Wymagania sprzętowe minimalne (+200 MB RAM, +1 CPU spike per zapytanie,
  **0 MB VRAM** — nie koliduje z Ollamą).
- **Refactor `tcWebSearch` chain** — nowa kolejność wg jakości i niezawodności:
  1. **Tavily** (jeśli klucz) — najlepsza jakość pod LLM
  2. **SearxNG self-hosted** (jeśli URL) — nielimitowane, własne
  3. DDG html — fallback bez konta
  4. DDG lite — fallback bez konta
  5. SearxNG public — fallback bez konta, zawodny
  6. **Brave** (jeśli klucz) — $5 credits/mc free
- Zbiorczy komunikat o niedostępności wyszukiwarek listuje teraz **wszystkie** providery z 80-znakowymi snippetami błędów + sugestie (Tavily / SearxNG self-hosted) zamiast generycznego „retry in 1-2 min".
- Pliki: [ai_lib.php](../admin/pages/settings/ai/ai_lib.php) (schemat `def_api_tavily`, `def_api_searxng`),
  [tools_executors.php](../admin/pages/consoleai/terminal/tools_executors.php) (`tcSearchTavily`, `tcSearchSearxSelfHosted`, refactor chain),
  [admai.php](../admin/pages/settings/ai/admai.php) (handlery `ai_tavily_*`, `ai_searxng_*`),
  [admai.view.php](../admin/pages/settings/ai/admai.view.php) (taby + modale),
  [admai.viewjs.php](../admin/pages/settings/ai/admai.viewjs.php) (`aiSimpleTestModal` helper),
  [admai.tab-tavily.view.php](../admin/pages/settings/ai/admai.tab-tavily.view.php),
  [admai.tab-searxng.view.php](../admin/pages/settings/ai/admai.tab-searxng.view.php).
- Rejestracja akcji AJAX `ai_tavily_test_ajax`, `ai_searxng_test_ajax` w [admin/index.php](../admin/index.php).

### Zmiany strukturalne (DB)

Zob. [changelog-db.md](changelog-db.md) — dodano tabele `def_api_tavily` i `def_api_searxng`.

---

## [0.7.21] — 2026-05-30 — 🏁 **subagenci działają stabilnie**

> Pierwsza wersja, w której **pętla agentowa z delegacją do pomocnika** (decompose
> → plan-wykonaj-weryfikuj → kontynuuj/przerwij) działa **end-to-end** ze stabilnym
> live UI, interaktywną pauzą przy porażce kroku i właściwym honorowaniem limitów
> Ollamy. Polecany setup: `qwen3-coder:30b` (główny) + ten sam lub `qwen2.5-coder:14b/32b`
> (pomocnik), Ollama `num_predict=-1`, timeout 1000s, instancje na różnych komputerach LAN.

### Dodano

#### Interaktywna pauza przy porażce kroku planu — „Kontynuuj plan / Przerwij plan"
- Gdy podzadanie w `decompose_and_execute` pada przy `stop_on_failure=true`, backend **nie przerywa od razu** — wpisuje do `def_console_progress` flagę `awaiting_user_decision` (failed_step, total, remaining, task, verdict) i poll'uje DB co 1s przez 120s.
- UI poprzez polling endpointu `console_ai_progress` widzi flagę i otwiera modal **„Krok N/M nie powiódł się"** z treścią zadania, werdyktem porażki i licznikiem podzadań do wykonania.
- Klik **„Kontynuuj plan"** → AJAX `console_ai_plan_decision?decision=continue` → backend kasuje flagę, ustawia świeży `set_time_limit(900)` i przechodzi do następnego kroku z **zachowanym oryginalnym indeksowaniem** (2/8, 3/8…).
- Klik **„Przerwij plan"** lub **timeout 120s** → `break` jak wcześniej.
- Plik [admterminal.php](../admin/pages/consoleai/terminal/admterminal.php) — `consoleAiProgressAwait()` + akcja `console_ai_plan_decision`; [tools_executors.php](../admin/pages/consoleai/terminal/tools_executors.php) — hook w pętli decompose; modal [admterminal.view.php](../admin/pages/consoleai/terminal/admterminal.view.php) `#tc-plan-decision-modal`; logika w [admterminal.viewjs.php](../admin/pages/consoleai/terminal/admterminal.viewjs.php) (`showPlanDecisionModal`).

#### Pre-populate listy podzadań (cały plan widoczny od t=0)
- Przed pierwszym `tcRunHelperSubLoop` decompose wpisuje **wszystkie podzadania** do `progress.sub_tasks` jako `status='pending'` (z indeksami 1..N i treścią taska).
- Każdy krok przechodzi w trakcie wykonania: `pending` (szary, ikona `fa-hourglass-half`, opacity 65%) → `running` (niebieski spinner + licznik s) → `done` (zielony ✓) / `failed` (czerwony ✗ + przycisk Ponów).
- Eliminuje sytuację „cała lista pojawia się dopiero gdy plan się skończył" — user od razu widzi **mapę całego planu** i postęp.
- [tools_executors.php](../admin/pages/consoleai/terminal/tools_executors.php) — `array_map` pre-populate; [admterminal.viewjs.php](../admin/pages/consoleai/terminal/admterminal.viewjs.php) — obsługa statusu `pending`; CSS `.tc-typing-subtask.is-pending` w [admterminal.viewcss.php](../admin/pages/consoleai/terminal/admterminal.viewcss.php).

#### „Pokaż całość" — expand treści wykonawcy w sub-taskach
- W bloku odpowiedzi wykonawcy (`.tc-typing-subtask-reply`) pojawia się ikona `fa-up-right-and-down-left-from-center` (prawy górny róg). Klik na ikonę **lub całą treść** toggluje klasę `.is-expanded` → znika line-clamp 2 linii, scroll do `max-height: 50vh`.
- Backend cap treści `reply` w `sub_tasks` podniesiony **240 → 2000 znaków** (zmieści cały typowy komunikat błędu z hintami).

#### Ostrzeżenie „jedna Ollama dla głównego i pomocnika"
- Preflight w `sendMessage` JS: jeśli `provider='ollama'` AND `helper.provider='ollama'` AND ten sam `oll_id` AND helper mode ≠ off → modal `#tc-oneollama-modal` przed wysyłką.
- Modal pokazuje którą instancję (`Ollama #N — qwen…`), tłumaczy konsekwencje (różne modele = przełączanie VRAM, ten sam = serializacja), oferuje sugestię oddzielnych instancji LAN.
- Checkbox **„Nie pytaj ponownie w tej sesji"** (flaga w pamięci JS).
- [admterminal.view.php](../admin/pages/consoleai/terminal/admterminal.view.php), [admterminal.viewjs.php](../admin/pages/consoleai/terminal/admterminal.viewjs.php) (`maybeWarnSameOllama`).

#### Wizualizacja modelu pomocnika w live indicator
- `updateTyping(data)` populuje placeholder `#tc-typing-helper`: gdy backend zapisał `data.helper.{provider, model}` w progress, w live indicatorze nad listą podzadań pojawia się **„🔧 Sub-taski wykonuje pomocnik: Ollama #1: qwen3-coder:30b"** — w trakcie tury widać który drugi model realnie pracuje.

#### Przycisk „ponów" na nieudanych podzadaniach
- Czerwona ikona ↻ w prawym górnym rogu każdego kroku z `status='failed'` — w live indicator i w finalnej bańce z tool_calls.
- Klik wczytuje treść podzadania do głównego inputa z prefiksem **„Ponów to podzadanie (poprzednio nie udało się go zrealizować):"** + fokus na textarea. **Nie wysyła auto** — user może dostosować przed kliknięciem Wyślij.
- Wspólny styl `.tc-subtask-retry` (outline-danger → solid-danger hover) w obu rendererach.

#### Przycisk „ponów" na bańkach błędów
- Bańki asystenta z `error: true` mają w `tc-msg-actions` czerwoną ikonę ↻ (`tc-msg-retry`) z `data-retry` = pełna treść oryginalnego prompta usera.
- Klik → spinner → `sendMessage(retryPrompt)` w `setTimeout(0)` → bańka usera + spinner indikatora + fetch.
- Direct event listener przypinany w `appendMessage` (nie event delegation) — niezawodne dla długich/specjalnych treści.

#### Format „Xm YYs" dla czasów ≥ 60s
- Helper `formatElapsed(sec)` (JS) + `consoleAiFormatElapsed($sec)` (PHP): `<60s → Xs`, `<1h → Xm YYs` (np. „3m 08s"), `≥1h → Xh YYm ZZs` (np. „1h 02m 05s"). Pad sekund/minut wiodącym zerem.
- Zastosowane w 5 miejscach: live indicator (top licznik + per-sub-task running + per-sub-task done), historia promptów (plakietka stopera).

### Naprawiono

- **`num_predict = -1` cicho konwertowane na 2048** w `tcChatOllama` — etykieta formularza mówiła „-1 = bez limitu", ale kod klampował twardo, co powodowało truncation HTTP 400 „looks like object" przy długich generacjach kodu. Teraz `-1` (oraz `-2` = fill remaining context) honorowane natywnie zgodnie ze spec Ollamy. Dodatnie wartości klampowane do **[256, 16384]** (sufit podniesiony z 4096). Etykieta formularza zaktualizowana.

- **Limit czasu PHP twardo 360s** zabijał długie tury — podniesiony do **1800s** w `console_ai_send` i **600s** w `console_ai_run_command`. Dodatkowo `set_time_limit(N)` resetowany **dynamicznie**: w każdej iteracji `tcRunToolLoop` (600s), przed każdym podzadaniem decompose (900s), przed każdym `tcAskHelper` (600s), przed każdym auto-run komendy (600s), przed czekaniem na decyzję usera (180s). Suma: realnie tura jest ograniczona tylko przez timeouty providerów (curl) i `TC_TOOLS_MAX_ITER`, nie przez globalny PHP cap.

- **Regresja: `arguments` jako STRING zepsuł poprzednio działający setup** — eksperyment ze stringify (OpenAI spec) cofnięty. Ollama natywnie używa OBJECT, wracamy do tego. Faktyczny HTTP 400 „looks like object" pochodzi z parsowania **wyjścia modelu** przez Ollamę, a nie z naszego request payloadu.

- **Czytelniejszy komunikat HTTP 400 z Ollamy** — listuje 4 prawdziwe przyczyny w kolejności prawdopodobieństwa: (1) truncation `num_predict`, (2) malformed JSON od modelu, (3) zatruta historia, (4) bug Ollamy. Wcześniej mylnie sugerował „model nie wspiera tools" nawet dla qwen3-coder, który wspiera.

- **Dodatkowo czytelne 401/403/404/413** w `tcChatGithubModels` (rozdzielone scope vs per-model access vs limit dzienny) i osobne handlery `404 model not pulled` w `tcChatOllama`.

### Zmiany strukturalne (DB)

Zob. [changelog-db.md](changelog-db.md) — w 0.7.21 dodano tabelę **`def_console_progress`** (single row per user+session) do live wskaźnika i interaktywnej pauzy planu.

---

## [0.7.20] — 2026-05-30

### Dodano

#### Console AI — Terminal: **live wskaźnik „pisze…" z modelem, licznikiem sekund i sub-taskami**
- Statyczny „⚪⚪⚪ Model LLM pisze…" zastąpiony **live** wskaźnikiem pokazującym:
  - **nazwę aktywnego modelu** głównego (etykieta z prefixem providera, np. „GitHub Models: openai/gpt-4o-mini"),
  - **licznik sekund** odliczający czas pracy modelu (lokalny timer JS co 1s),
  - **listę podzadań w czasie rzeczywistym** gdy aktywny jest `decompose_and_execute`
    (każde podzadanie z ikoną statusu running/done/failed, własnym licznikiem czasu
    i skróconym podglądem treści odpowiedzi po zakończeniu),
  - **pomocnika** (provider/model) który wykonuje sub-taski.
- **Architektura** (live progress):
  - Nowa tabela `def_console_progress` (single row per user+session): status,
    główny provider/model, started_at, finished_at, `CprgJson` z listą sub-tasków.
  - Backend zwalnia lock sesji (`session_write_close()`) przed pętlą tool loop —
    inaczej polling endpoint by się blokował na ten sam plik sesji.
  - Po pętli sesja jest re-openowana ze snapshotem `console_ai_pending_cmds`
    (które executor modyfikował in-memory podczas zamkniętej sesji).
  - Executor `decompose_and_execute` i `ask_helper` wywołują przekazany `progress_cb`
    przed/po każdym podzadaniu — callback pisze do `CprgJson`.
  - Nowy endpoint AJAX `console_ai_progress` (rejestrowany w `admin/index.php`) —
    polling co 1500 ms zwraca aktualny stan; JS aktualizuje UI bez przeładowania.
- Pliki: [admterminal.php](../admin/pages/consoleai/terminal/admterminal.php)
  (schema, helpery `consoleAiProgressStart/UpdateJson/Finish/Read`, endpoint, wiring),
  [tools_executors.php](../admin/pages/consoleai/terminal/tools_executors.php)
  (hook `progress_cb` w `decompose_and_execute` + `ask_helper`),
  [admterminal.viewjs.php](../admin/pages/consoleai/terminal/admterminal.viewjs.php)
  (rich `appendTyping` + `updateTyping` polling),
  [admterminal.viewcss.php](../admin/pages/consoleai/terminal/admterminal.viewcss.php)
  (style `.tc-typing-*`).

## [0.7.19] — 2026-05-30

### Dodano

#### Console AI — Terminal: **„Ponów ten sam prompt"** przy bańkach błędu
- Bańka błędu ma teraz w prawym górnym rogu czerwoną ikonę **↻ (rotate-right)**. Klik
  ponawia identyczną wiadomość użytkownika, która wywołała błąd — bez przepisywania,
  bez kopiowania ręcznego. Ikona pokazuje się zawsze (nie tylko on-hover) i ma
  hover-feedback.
- Treść do ponowienia przekazujemy jako `retryPrompt` do `appendMessage` w obu
  ścieżkach błędu (response error oraz fetch catch), zapisywana w `data-retry`
  na elemencie DOM bańki. Event delegation w [admterminal.viewjs.php](../admin/pages/consoleai/terminal/admterminal.viewjs.php)
  na `.tc-msg-retry` wywołuje `sendMessage(text)`.

#### Console AI — Terminal: zakładka **„Historia"** w modalu „Wstaw prompt" + delegacje pomocnika
- Dodatkowo każdy wpis historii pokazuje **delegacje do pomocnika** (gdy zaszły):
  - **Pomocnik**: provider/model wyciągnięty z syntetycznego wpisu `_helper_used` w
    `CmsToolCalls` (np. „Ollama #1: qwen3-coder:30b") — pokazuje który drugi model
    realnie wykonywał części pracy w danej turze.
  - **Plan** (gdy wywołano `decompose_and_execute`): cel + lista podzadań (max 8)
    + bilans „N/M OK" parsowany z raportu sub-loopu.
  - **Delegacje** (gdy wywołano `ask_helper`): lista zadań przesłanych do pomocnika.
- Filtr historii bierze pod uwagę także te treści — można wyszukać po nazwie
  podzadania czy goal'a planu, nie tylko po samym prompcie.
- Prawa kolumna modala (gdzie wcześniej była tylko biblioteka haseł) ma teraz dwie
  zakładki Bootstrap: **„Hasła do promptu"** (poprzednia funkcjonalność) i
  **„Historia"** (lista ostatnich 50 wiadomości użytkownika ze wszystkich sesji).
- Każdy wpis historii pokazuje:
  - datę i godzinę wysłania,
  - **model i providera**, który odpowiedział (np. „GitHub Models: openai/gpt-4o-mini"),
  - **czas przetwarzania** w sekundach (różnica `user.CmsCreatedAt → assistant.CmsCreatedAt`),
  - tokeny in/out (gdy dostępne),
  - 3-wierszowy podgląd treści.
- Klik na element historii **wczytuje pełną treść** do `textarea` (prefiksy zostają,
  można dorzucać dodatkowe hasła). Pole filtra pełni rolę wspólną — filtruje hasła
  *i* treść historii.
- Pairing user↔assistant po stronie SQL: skorelowane podzapytanie biorące najbliższą
  odpowiedź `assistant` w tej samej sesji o większym `CmsID`. Brak dodatkowych kolumn
  ani indeksów — używamy istniejących pól tabeli `def_console_messages`.

## [0.7.18] — 2026-05-30

### Dodano

#### Console AI — Terminal: **„Wstaw prompt"** (biblioteka haseł z bazy + edytor w Ustawieniach)
- Nowy przycisk **<i class="fas fa-wand-magic-sparkles"></i>** w pasku wysyłki terminala (obok klipsa
  i przycisku pomocnika) otwiera **modal z biblioteką wstawek prompta**.
- **Layout modala:** po lewej `textarea` z treścią, po prawej **pogrupowane hasła** z filtrem
  szybkiego wyszukiwania. Klik hasła **dokleja prefix** u góry treści. Przycisk **Wycofaj**
  zdejmuje ostatnio doklejone hasło; klik na konkretny chip prefixu usuwa wybrany. Przyciski
  na dole: **„Wstaw do okna (bez wysyłki)"** i **„Wyślij i zamknij"**.
- **Słownik w bazie:** tabela `def_console_prompt_snippets` (kolumny: `SnpGroup`, `SnpLabel`,
  `SnpText`, `SnpActive`, `SnpSortOrder`). Tworzona idempotentnie przy wejściu do terminala +
  seed 22 defaultami pogrupowanymi w 6 kategorii (Plan i wykonanie / Strategia / Format
  odpowiedzi / Narzędzia / Anti-halucynacja / Weryfikacja).
- **Edytor** w *Ustawienia → Integracje AI → zakładka „Wstawki prompta"*: lista wszystkich haseł
  pogrupowanych po kategorii, każde z **toggle aktywne** (szybki AJAX), przyciskami **Edytuj** /
  **Usuń trwale**, oraz przyciskiem **+ Dodaj hasło**. Edycja w modalu — pola: kategoria
  (z `<datalist>` istniejących kategorii dla autouzupełniania), etykieta, treść, sortowanie,
  aktywne. Nieaktywne wpisy zostają w edytorze, ale **nie pokazują się w modalu terminala**.
- Pliki: [admterminal.view.php](../admin/pages/consoleai/terminal/admterminal.view.php) (modal +
  ładowanie z bazy przez `consoleAiPromptSnippetsList()`),
  [admterminal.viewjs.php](../admin/pages/consoleai/terminal/admterminal.viewjs.php) (logika modala
  + undo prefixów),
  [admterminal.viewcss.php](../admin/pages/consoleai/terminal/admterminal.viewcss.php) (styl chipów),
  [admai.tab-prompt-snippets.view.php](../admin/pages/settings/ai/admai.tab-prompt-snippets.view.php)
  (edytor), handlery `ai_prompt_snippets_save` / `_delete` / `_toggle` w
  [admai.php](../admin/pages/settings/ai/admai.php).

## [0.7.17] — 2026-05-30

### Dodano

#### Console AI — Terminal: **„Plan & Wykonanie"** (decompose + sub-loop pomocnika)
- Nowe narzędzie `decompose_and_execute(goal, sub_tasks[], stop_on_failure?)` dla głównego
  modelu w trybie **Deleguj** — rozbija złożone zadanie na **uporządkowaną listę
  podzadań** (max 8), które są wykonywane **jedno po drugim** przez model pomocniczy.
  Każde podzadanie:
  1. **wykonuje pomocnik** w sub-loopie z dostępem do workspace tools
     (`list_dir` / `read_file` / `write_file`) — bez internetu, bez `run_command`,
     żeby nie wymagać interaktywnej zgody operatora,
  2. **system weryfikuje** wynik krótkim pytaniem „SUKCES/PORAŻKA" do pomocnika,
  3. **postęp jest kumulowany** w kontekst dla kolejnego podzadania,
  4. przy porażce — domyślnie przerywamy plan (`stop_on_failure=true`).
- Wynik wraca do głównego modelu jako sprawozdanie markdown z punktem per krok
  (werdykt + skrót wyjścia wykonawcy + bilans).
- UI ([admterminal.viewjs.php](../admin/pages/consoleai/terminal/admterminal.viewjs.php)
  + [admterminal.viewcss.php](../admin/pages/consoleai/terminal/admterminal.viewcss.php))
  renderuje sprawozdanie jako **subproces** w bańce: jeden collapsible blok „Plan & Wykonanie"
  z plakietkami (`N OK` / `M FAIL` / `K nieuruchom.`) i kartami per krok (ikona statusu,
  numer, treść, rozwijany werdykt + opis wykonawcy).
- Implementacja: `tcDefineDecomposeTool`, `tcRunHelperSubLoop` (reużywa `tcRunToolLoop`
  z provider config pomocnika), `tcLoadHelperConfig`, branch w `tcExecuteTool`
  w [tools_executors.php](../admin/pages/consoleai/terminal/tools_executors.php).
- Przy okazji dodano obsługę **GitHub Models** w `tcAskHelper` — pomocnikiem może być
  teraz `openai/gpt-4o-mini` lub inny model z GitHub Models (poza dotychczasowymi
  Ollama / Groq / Gemini / Claude).
- System prompt głównego modelu w trybie Deleguj zawiera teraz instrukcję, kiedy
  użyć `ask_helper` (pojedyncze proste podzadanie), a kiedy `decompose_and_execute`
  (wieloetapowe taski wymagające planu).

## [0.7.16] — 2026-05-30

### Dodano

#### Integracje AI — **GitHub Models** (nowy provider, darmowy)
- Nowa zakładka **„GitHub Models"** w *Ustawienia → Integracje AI* — bramka Microsoftu
  udostępniająca darmowo (dla kont GitHub z PAT scope `models:read`): OpenAI GPT-4o /
  GPT-4.1 / o-mini, Meta Llama 3.3, Mistral / Codestral, Microsoft Phi-4, Cohere Command R+.
  Endpoint OpenAI-compatible (`models.github.ai/inference`) — tool calling wspierany
  na wszystkich kluczowych modelach.
- Pełna funkcjonalność jak Gemini/Groq:
  - Test połączenia (AJAX modal) z listą dostępnych modeli i przyciskiem „Użyj tego".
  - „Odśwież listę" pobiera katalog z `/catalog/models` i zapisuje w bazie.
  - Konfiguracja: PAT, model (format `publisher/model`), temperatura, max tokens (do 16384),
    system prompt.
- Wpięcie do **Console AI → Terminal** jako pełnoprawny provider w dropdownie obok
  Claude/Groq/Gemini/Ollama. Funkcje [tcChatGithubModels()](../admin/pages/consoleai/terminal/tools_providers.php),
  [musicAiCallGithubModels()](../admin/pages/settings/ai/ai_lib.php), `musicGhmListModels`,
  `musicGhmIsVisionModel` (GPT-4o/4.1, Llama-4, llava). Etykieta w bańce: „GitHub Models: openai/gpt-4o-mini".
- Schemat DB: `def_api_github_models` (single-row, idempotentny `CREATE TABLE IF NOT EXISTS`
  w `aiEnsureSchema()` — utworzy się przy pierwszym requeście). Klucz: GhmID=1.
- Obsługa typowych błędów: HTTP 401/403 → komunikat o wymaganym scope `models:read`,
  HTTP 429 → info o dziennym limicie i resecie 00:00 UTC + jeden auto-retry, HTTP 404 →
  podpowiedź o formacie `publisher/model`.

## [0.7.15] — 2026-05-29

### Dodano

#### Console AI — Terminal: **etykieta modelu w bańce z nazwą providera**
- Plakietka modelu pokazuje teraz `Provider: model` zamiast samej nazwy modelu —
  np. „Claude: claude-opus-4-7", „Groq: llama-3.3-70b-versatile", „Gemini: gemini-2.5-flash",
  „Ollama: qwen2.5-coder:32b". Dla **Ollamy z wieloma instancjami** etykieta nowej
  wiadomości uwzględnia konkretną instancję, np. „Ollama #2: qwen2.5-coder:32b"
  (lub własną nazwę instancji, jeśli ustawiono `OllLabel` — np. „Lokalny PC: qwen…").
  Specjalne etykiety (`komenda`, `pomocnik`) pozostają bez zmian
  ([consoleAiFormatModelLabel()](../admin/pages/consoleai/terminal/admterminal.php),
  `formatModelLabel()` w [admterminal.viewjs.php](../admin/pages/consoleai/terminal/admterminal.viewjs.php)).

#### Console AI — Terminal: **status git** na pasku folderu roboczego
- Gdy wybrany folder roboczy jest **repozytorium git**, pasek u góry terminala pokazuje
  teraz bieżącą **gałąź** (np. `dev`) oraz statystyki zmian: liczbę zmienionych plików
  i `+wstawienia` / `−usunięcia` (`git diff HEAD`), albo plakietkę **„czysty"** gdy brak
  zmian. Dla repo w stanie *detached HEAD* pokazywany jest skrócony hash.
- Obok gałęzi **ahead/behind** względem gałęzi śledzonej (origin) — `↑N` (commity lokalnie
  do wypchnięcia) / `↓N` (do pobrania); ukryte, gdy brak upstreamu lub 0/0.
- Przycisk **↻ (odśwież)** na pasku przelicza status git bez zmiany folderu
  (akcja `console_ai_git_status`).
- Informacja aktualizuje się po wskazaniu/zmianie folderu (`console_ai_set_workdir` zwraca
  pole `git`). Detekcja jest **bezpieczna offline** — gdy git nie jest zainstalowany lub
  folder nie jest repozytorium, sekcja po prostu się nie pokazuje
  ([consoleAiGitInfo()](../admin/pages/consoleai/terminal/admterminal.php), krótki timeout,
  `--no-optional-locks`).

#### Console AI — Terminal: **„Zezwól dla sesji"** (zaufane programy bez ciągłego pytania)
- W oknie zgody na uruchomienie komendy doszedł przycisk **„Zezwól dla sesji"**
  ([admterminal.view.php](../admin/pages/consoleai/terminal/admterminal.view.php)). Kliknięcie
  uruchamia komendę **i** dodaje jej **program** (pierwszy token, np. `git`, `dotnet`, `npm`)
  do listy zaufanych w bieżącej sesji.
- Kolejne komendy tego samego programu (np. wszystkie `git …`) **wykonują się automatycznie**,
  bez okna dialogowego — executor [tcExecuteTool()](../admin/pages/consoleai/terminal/tools_executors.php)
  sprawdza listę `console_ai_cmd_allow` w sesji i przy trafieniu uruchamia komendę od razu,
  zwracając wynik modelowi (płynna pętla agentowa). Operator dostaje w czacie informację, że
  dany program jest teraz zaufany. Niezatwierdzone programy nadal wymagają zgody.
- **Wyjątek dla komend niszczących**: zaufanie programu w sesji **nie obejmuje** operacji
  nieodwracalnych — `git reset --hard`, `git push --force` / `-f` / `--force-with-lease`,
  `git clean -f`, `git checkout --force`, `git branch -D`, `git rebase`/`filter-branch`,
  `git restore`, `git rm`, `rm -rf`, `Remove-Item -Recurse/-Force`, `rmdir /s`, `del`/`erase`,
  `format`/`diskpart`/`mkfs`, `shutdown`/`taskkill`. Takie komendy **zawsze** pokazują okno
  zgody (z czerwonym ostrzeżeniem), nawet jeśli program jest zaufany ([tcCommandNeedsApproval()](../admin/pages/consoleai/terminal/tools_executors.php)).
  Rozróżniana jest wielkość liter tam, gdzie ma znaczenie (np. `git branch -D` blokowane,
  `-d` — nie).

### Naprawiono
- **PowerShell 5.1 nie obsługuje `&&` / `||`** („The token '&&' is not a valid statement
  separator…") — model często łączył komendy w stylu `git add . && git commit -m …`, co
  kończyło się błędem parsera. [tcRunShellCommand()](../admin/pages/consoleai/terminal/tools_executors.php)
  wykrywa teraz `&&`/`||` i wykonuje taką komendę przez **cmd.exe** (ta sama semantyka:
  `A && B` = uruchom B tylko gdy A==0). Komenda jest zapisywana do tymczasowego pliku `.cmd`
  (z `chcp 65001` dla UTF-8) i uruchamiana — eliminuje to problemy z cudzysłowowaniem
  metaznaków przez `cmd /c`. Opis narzędzia `run_command` instruuje też model, by nie łączył
  poleceń `&&` pod PowerShellem (jedna komenda na wywołanie lub `;`, albo `shell:"cmd"`).
- **Osadzony JSON wywołania narzędzia** (np. `run_command` z `git init`) wypisany **po tekście
  wstępnym** nie był wykonywany — parser JSON łapał wcześniej tylko gdy *cała* treść była
  JSON-em. Teraz [tcParseJsonToolCalls()](../admin/pages/consoleai/terminal/tools_lib.php)
  skanuje całą odpowiedź i wyłuskuje każdy zbalansowany blok `{…}` — wywołanie pojawia się
  jako propozycja komendy z oknem zgody.
- **Runtime detektor halucynowanych wyników komend** — gdy odpowiedź modelu zawiera
  systemowe markery `[SUKCES (exit N)]` / `[NIEPOWODZENIE (exit N)]` lub bańkowy format
  `$ <cmd>  — <STATUS>`, a w tej turze NIE wykonano żadnego `run_command`,
  nad bańką pojawia się żółty banner **„Prawdopodobna halucynacja"**
  ([consoleAiDetectHallucinatedOutput()](../admin/pages/consoleai/terminal/admterminal.php)).
  Działa zarówno dla nowych odpowiedzi (`hallucinated_output` w odpowiedzi AJAX), jak
  i dla wiadomości ładowanych z historii (rendering w widoku z `CmsToolCalls`).
  Gdy realny `run_command` się wykonał, te same markery są uznane za **legalne**
  cytowanie z wyniku narzędzia (brak fałszywych trafień).

- **Model halucynował wyniki komend** zamiast je uruchamiać — np. wypisywał w treści
  zmyślony blok `[SUKCES (exit 0)] [stdout] The term 'dotnet' is not recognized…
  [stderr]` imitując format wyników systemu, po czym wyciągał błędne wnioski („SDK
  nie jest zainstalowany"), mimo że `dotnet` nigdy nie został realnie uruchomiony.
  W kolejnej turze halucynacja **narastała**: model zaczynał traktować swoje wcześniejsze
  opisy jak fakty („projekt został poprawnie utworzony", „klasa OllamaClient została
  przeniesiona"), choć żaden tool-call się nie wykonał. System prompt dla `run_command`
  zawiera teraz **twarde reguły anty-halucynacyjne**: (A) markery `[SUKCES …]` /
  `[NIEPOWODZENIE …]` / `[stdout]` / `[stderr]` / `$ <cmd>` pojawiają się **tylko**
  w wiadomościach producentowanych przez system po realnym wykonaniu komendy — modelowi
  nie wolno ich pisać samodzielnie; (B) zanim ogłosi brak jakiegoś narzędzia (np.
  `.NET SDK`), musi zweryfikować realnym wywołaniem (`dotnet --version`); (C) nie wolno
  „celowo demonstrować błędów" wymyślając wyjście; (D) **wcześniejsze opisy modelu w tej
  rozmowie nie są dowodem stanu rzeczywistego** — fakt, że poprzednia wiadomość mówi
  „X zostało zrobione" nie znaczy, że X zaszło na dysku. Tylko realna wiadomość `tool`
  (lub systemowy wynik `$ cmd  — SUKCES/NIEPOWODZENIE`) jest dowodem; w razie wątpliwości
  model ma użyć `list_dir`/`read_file` żeby sprawdzić stan.

- **`dotnet new` nie tworzył projektu, gdy folder miał już pliki z poprzedniej próby**
  (`Utworzenie tego szablonu spowoduje wprowadzenie zmian w istniejących plikach: Zastąp …`)
  — `dotnet new` domyślnie nie nadpisuje plików. System prompt narzędzia `run_command`
  zawiera teraz wskazówki o najczęstszych pułapkach: jak rozpoznać ten błąd, kiedy użyć
  `--force`, kiedy `-o <subfolder>` (preferowane — czysta struktura), kiedy najpierw
  posprzątać, a także przypomnienie o ograniczeniu `&&`/`||` w PowerShellu 5.1 i o
  użyciu `list_dir` przed scaffoldingiem.

- **Format „komendowy" narzędzi nie zapisywał pliku** — qwen2.5-coder:32b potrafi wypisać
  wywołanie w stylu polecenia powłoki, np. `write_file plik.html "<!DOCTYPE html>…"`
  (bez JSON, bez `<function=>`), przez co plik nie powstawał na dysku. Dodano parser tego
  formatu (Format D) w [tcParseBareToolCalls()](../admin/pages/consoleai/terminal/tools_lib.php):
  obsługuje `write_file`/`save_file <ścieżka> "<treść>"` (treść wielolinijkowa, ze zdjęciem
  otaczających cudzysłowów — także gdy domykający został ucięty), `read_file <ścieżka>`,
  `list_dir [ścieżka]`, `run_command "<komenda>"`. Rozpoznawane tylko na początku odpowiedzi
  i filtrowane po liście dozwolonych narzędzi (brak fałszywych trafień na opisie w tekście).

## [0.7.14] — 2026-05-29

### Dodano

#### Integracje AI — Ollama: **wiele instancji** (różne komputery w sieci)
- Konfiguracja Ollamy obsługuje teraz **wiele instancji** — np. Ollama na różnych
  komputerach w sieci LAN, każda z własnym URL/modelem/timeoutem. Na dole zakładki
  Ollama przycisk **„Dodaj kolejną konfigurację Ollamy"** dodaje nową **pod-zakładkę**
  instancji (`ai_ollama_add`).
- Każda instancja: własna **nazwa** (etykieta, kolumna `OllLabel`), URL, model,
  temperatura, max tokenów, timeout, system prompt — z osobnym **Testem połączenia**,
  auto-odświeżaniem listy modeli (per instancja, `oll_id`) i przyciskiem **Usuń
  konfigurację** (poza podstawową #1). Formularz instancji: [admai.tab-ollama-instance.view.php](../admin/pages/settings/ai/admai.tab-ollama-instance.view.php).
- Po zapisie/teście/dodaniu instancji panel **zostaje na jej pod-zakładce** (PRG
  przekazuje `?oll=<id>`) — wcześniej wracał zawsze do instancji #1.
- Handlery `ai_ollama_save`/`_test`/`_refresh_models` przyjmują `oll_id`; tabela
  `def_api_ollama` przechowuje 1..N wierszy (instancja #1 = podstawowa). Modal
  „Polecane modele" wspólny dla wszystkich instancji (+ wskazówka `OLLAMA_HOST=0.0.0.0`
  dla dostępu z sieci).
- **Wybór instancji wszędzie tam, gdzie używa się Ollamy**:
  - **Console AI — Terminal**: dropdown modeli pokazuje modele **wszystkich** instancji
    z prefiksem nazwy (np. „Lokalny PC: qwen3-coder", „Serwer LAN: mistral"); wybór niesie
    `data-oll-id`, wysyłka przekazuje `oll_id`, backend ładuje właściwą instancję
    (`tcChatOllama`/`tcAskHelper` po `OllID`). Działa też dla **Pomocnika** (`ollama|<id>|model`).
  - **Generator opisów/tagów** — SoundCloud (panel *Generuj*), edytor **Mixcloud** oraz
    **YouTube** listują modele wszystkich instancji i przekazują `oll_id` do
    `music_track_ai_suggest` / `music_ytb_video_ai_suggest` (ładowanie instancji po `OllID`).

### Naprawiono
- **Ollama (qwen2.5-coder i pokrewne) nie wykonywały operacji na folderze** — model
  emitował wywołanie narzędzia jako **JSON w treści** (`{"name":"list_dir","arguments":{…}}`)
  zamiast w polu `tool_calls`, więc panel widział pustą listę narzędzi, a model „twierdził",
  że nie ma dostępu do dysku. Parser fallbacku [tcParseTextToolCalls()](../admin/pages/consoleai/terminal/tools_lib.php)
  rozpoznaje teraz także format **JSON** — w tym **osadzony** w treści po preambule
  („Teraz zrobię…\n{json}") lub w ```json``` — wyłuskiwany z dowolnego miejsca przez
  skan zbalansowanych bloków `{…}` (działa też dla `run_command` → pojawia się okno zgody),
  oraz **mimikę** `[wywołano narzędzie NAZWA({…})]` (modele kopiują ten wzorzec z historii —
  ekstrakcja argumentów z balansowaniem klamr, bo treść pliku ma nawiasy/znaki specjalne),
  obok istniejącego `<function=…>`. Wynik jest filtrowany po liście dozwolonych narzędzi
  (brak fałszywych trafień na zwykłym JSON-ie). Potwierdzone: qwen2.5-coder:14b realnie
  wywołuje `list_dir`/`read_file`/`write_file`.

## [0.7.13] — 2026-05-29

### Naprawiono
- Gemini 2.5 — model **naśladował jako tekst** wcześniejszą poprawkę `thought_signature`
  (w historii do Gemini wywołania narzędzi były zapisywane jako `[wywołano narzędzie
  write_file({...})]`), przez co zamiast realnie wołać narzędzie wypisywał ten format
  w czacie (zrzut całej treści pliku) — plik nie był zapisywany, komenda nie uruchamiana.
  Teraz w historii do Gemini idzie WYŁĄCZNIE tekst asystenta + wynik narzędzia jako zwięzła
  wiadomość użytkownika („Wynik narzędzia X: …") — bez żadnego formatu wywołania do naśladowania.
- Czytelny komunikat zamiast `JSON.parse: unexpected end of data` — gdy serwer zwróci **pustą**
  lub niepoprawną odpowiedź (najczęściej lokalny model Ollama generował za długo i żądanie
  padło na timeoucie/serwerze), UI pokazuje wyjaśnienie i podpowiedzi (krótsze zadanie,
  mniejszy „Max tokenów", szybszy model, sprawdź czy Ollama działa) zamiast surowego błędu JS.

### Dodano

#### Console AI — Terminal: **uruchamianie komend konsoli za zgodą operatora**
- Model może **proponować** komendy (PowerShell/cmd, np. .NET SDK: `dotnet build`,
  `dotnet test`, `dotnet run`) narzędziem `run_command(command, purpose, shell)`. Komenda
  **NIE wykonuje się sama** — pojawia się **okno modalne** z komendą, celem, katalogiem (cwd)
  i powłoką, a uruchomienie następuje dopiero po kliknięciu **„Zezwól i uruchom"**.
- Przełącznik **Komendy** w pasku (domyślnie **wyłączony**, zapamiętany w cookie).
  Działa tylko gdy ustawiony jest **folder roboczy** — komendy uruchamiają się w jego
  katalogu (cwd). Po zatwierdzeniu wynik (stdout/stderr/exit) trafia do rozmowy, więc
  model widzi go w kolejnej turze (np. „popraw błędy z builda").
- **Weryfikacja powodzenia**: wynik komendy ma jawny status **SUKCES (exit 0)** /
  **NIEPOWODZENIE (exit N)**, model ma w prompcie instrukcję jak oceniać (kod wyjścia +
  stderr/stdout, dla buildu/testów brak błędów), a po wykonaniu (ostatniej) komendy
  uruchamiana jest **automatyczna weryfikacja** — model analizuje wynik i raportuje
  sukces/porażkę, a przy błędzie diagnozuje przyczynę i proponuje poprawkę.
- Gdy „Komendy" są wyłączone, model nie twierdzi już, że „nie umie nic uruchomić" —
  podpowiada włączenie przełącznika „Komendy".
- Wykonanie: [tcRunShellCommand()](../admin/pages/consoleai/terminal/tools_executors.php)
  (`proc_open`, timeout 120 s, limit outputu 64 KB/strumień, wymuszony UTF-8 na PowerShellu).
- **Bezpieczeństwo**: komendy nigdy nie startują automatycznie; propozycje trzymane
  server-side w sesji (klucz `id`), zatwierdzenie po `id` uruchamia DOKŁADNIE zapisaną
  komendę (operator zatwierdza tylko to, co zaproponował model), jednorazowo; akcja
  `console_ai_run_command` chroniona CSRF; cwd ograniczony do folderu roboczego.

## [0.7.12] — 2026-05-29

### Dodano

#### Console AI — Terminal: **model pomocniczy (Pomocnik)**
- Drugi model (np. lokalny Ollama — bez limitów) odciąża model główny. Przycisk
  **Pomocnik** w pasku + modal: wybór modelu pomocniczego (z listy skonfigurowanych
  providerów) i **tryb współpracy** (przełączalny):
  - **Off** — tylko model główny.
  - **Auto** — router: proste pytania (krótkie, bez kodu/plików/URL — heurystyka
    [consoleAiIsSimpleTask()](../admin/pages/consoleai/terminal/admterminal.php)) idą do
    pomocnika, złożone do głównego. Oszczędza limit głównego (np. Gemini 20/dzień).
  - **Równolegle** — oba modele odpowiadają na to samo; druga odpowiedź pokazywana
    obok (do porównania, na żywo).
  - **Deleguj** — główny prowadzi i może zlecać podzadania narzędziem `ask_helper(task)`
    (streszczenia, klasyfikacja, boilerplate) — oszczędza budżet głównego.
  - **Podział ról** — pomocnik najpierw zbiera/streszcza kontekst, główny pisze finalną
    odpowiedź na bazie jego notatek.
- **Ręczny przełącznik** przy wysyłaniu (ikona pomocnika) — wymusza pomocnika na
  pojedynczą wiadomość, niezależnie od trybu. Tryb i model zapamiętane w cookies.
- **Widoczna informacja o użyciu innego modelu**: gdy w odpowiedź zaangażowany jest
  pomocnik, w wiadomości pojawia się blok „Model pomocniczy" — dla auto/ręczny (kto
  wygenerował odpowiedź), dla „Podział ról" (jaki kontekst przygotował), a dla „Deleguj"
  widać realne wywołania `ask_helper`. Tryb „Równolegle" pokazuje odpowiedź pomocnika
  jako osobną bańkę.
- Single-shot caller [tcAskHelper()](../admin/pages/consoleai/terminal/tools_executors.php)
  reużywa wywołań providerów z ai_lib (Claude/Ollama/Groq/Gemini); konfiguracja Pomocnika
  bez zmian w bazie (parametry wysyłane z każdą wiadomością).

### Zmienione
- **Folder roboczy zapamiętywany w bazie** (per user, tabela `console_prefs`) zamiast
  w sesji PHP — przeżywa wylogowanie. Walidacja `realpath`+`is_dir` na każde użycie.
  Wcześniej znikał po wygaśnięciu sesji (model tracił dostęp do plików).
- Prompt folderu roboczego wzmocniony: model ma OBOWIĄZEK użyć `list_dir`/`read_file`,
  nie wolno mu pytać o wklejenie treści ani twierdzić, że nie ma dostępu, ani obiecywać
  pracy „za chwilę". Tryb „Podział ról" pomija notatki pomocnika sugerujące brak dostępu.

## [0.7.11] — 2026-05-29

### Naprawiono
- Gemini 2.5 w terminalu — błąd **HTTP 400 „Function call is missing a thought_signature"**
  przy wieloturowym użyciu narzędzi (np. list_dir → read_file → write_file). Modele myślące
  wymagają round-tripu „thought_signature" przy odtwarzaniu wywołań funkcji, a OpenAI-compat
  nie udostępnia tej sygnatury (`reasoning_effort: none` okazał się niewiarygodny — nie
  wyłączał myślenia deterministycznie). Rozwiązanie: w [tcChatGemini](../admin/pages/consoleai/terminal/tools_providers.php)
  NIE odtwarzamy wcześniejszych wywołań jako structured `tool_calls` — zapisujemy je jako
  TEKST (assistant: „[wywołano narzędzie X(args)]", wynik jako wiadomość user „[wynik narzędzia X]…").
  Dzięki temu żądanie nie zawiera `functionCall` parts → wymóg sygnatury w ogóle nie powstaje.
  Model nadal wywołuje NOWE narzędzia (to strona odpowiedzi).


### Dodano

#### Console AI — Terminal: **folder roboczy** (odczyt/zapis plików na dysku)
- Nowy przycisk **Folder** w pasku terminala + modal do wskazania katalogu na
  dysku serwera. Po ustawieniu model dostaje trzy narzędzia ograniczone WYŁĄCZNIE
  do tego folderu ([tools_workspace.php](../admin/pages/consoleai/terminal/tools_workspace.php)):
  - `list_dir(path)` — lista plików/podfolderów (1 poziom),
  - `read_file(path)` — odczyt pliku tekstowego (limit ~512 KB, wykrywanie binarnych),
  - `write_file(path, content)` — zapis/nadpisanie pliku (limit 1 MB).
- Cel: poprawa kodu (HTML, PHP, C#, JS…) i aktualizacja dokumentacji bezpośrednio
  na dysku. Folder przechowywany w sesji PHP (`console_ai_set_workdir`); model
  dostaje też instrukcję w system prompcie (czytaj plik przed edycją, zapisuj pełną treść).
- **Wizualny picker folderu** — przycisk „Przeglądaj…" w modalu otwiera serwerową
  przeglądarkę katalogów (`console_ai_browse_dirs`, read-only): lista dysków → wejście
  w podfoldery → „↑ wyżej" → „Wybierz ten folder". Bez ręcznego wpisywania ścieżki.
- Wykrywanie prawa zapisu folderu robi **realną próbę zapisu** (utwórz+usuń plik
  tymczasowy) zamiast `is_writable()`, który na Windows bywa zawodliwy dla katalogów.
- **Pasek aktywnego folderu** na górze terminala (pełna ścieżka + badge „odczyt+zapis"
  / „tylko odczyt" + skróty „zmień"/„wyłącz"), aktualizowany na żywo po ustawieniu/zmianie.
- **„Zapisz do pliku" trafia do folderu roboczego**: gdy ustawiony folder jest
  zapisywalny, `save_file` (pobieranie z sesji) NIE jest oferowany — model zapisuje
  przez `write_file` bezpośrednio do wskazanego folderu. Folder tylko-do-odczytu:
  pozostają `list_dir`/`read_file`, a zapis idzie przez `save_file` (pobieranie),
  z informacją że folder jest read-only. Bez folderu — `save_file` jak dotąd.
- **Bez podwójnej kopii**: gdy folder jest zapisywalny, nawet jeśli model wywoła
  `save_file`, executor przekierowuje zapis do folderu roboczego (nie tworzy kopii
  w `media/console`), a prompt zabrania podawania linku do pobrania — plik zapisywany
  jest dokładnie raz, w jednym miejscu.
- **Łączenie/edycja wielu plików**: limit iteracji narzędzi podniesiony 5 → 8
  (`TC_TOOLS_MAX_ITER`) — `list_dir` + kilka `read_file` + `write_file` nie mieściło się
  w 5 krokach. Sufit tokenów wyjścia Gemini w terminalu podniesiony do 32768 (Gemini 2.5
  wspiera duży output; to ceiling — nie zwiększa kosztu krótkich odpowiedzi), bo treść
  `write_file` jest generowana jako output modelu. Komunikat o wyczerpaniu pętli jest
  teraz kontekstowy (przy operacjach na plikach radzi zwiększyć „Max tokenów", nie mówi
  o DuckDuckGo). Prompt instruuje: czytaj każdy plik raz i złącz jednym `write_file`.
- **Bezpieczeństwo**: wszystkie ścieżki są względne wobec wskazanego folderu;
  segmenty `..`, null-byte i ścieżki bezwzględne są odrzucane; `realpath()` celu/rodzica
  musi mieścić się w realpath(roota) (łapie też dowiązania symboliczne); `write_file`
  ma whitelist rozszerzeń tekstowych/kodu. UI ostrzega, że model może nadpisywać pliki.

## [0.7.10] — 2026-05-29

### Dodano

#### Integracje AI — **Google Gemini** (nowy provider)
- Nowa zakładka *Ustawienia → Integracje AI → Gemini*
  ([admai.tab-gemini.view.php](../admin/pages/settings/ai/admai.tab-gemini.view.php)) —
  darmowy tier Google AI Studio z dużym budżetem tokenów na pojedyncze zapytanie
  (Flash ~1&nbsp;mln) i modelami **multimodalnymi** (widzą okładki/obrazy). Endpoint
  zgodny z OpenAI (`generativelanguage.googleapis.com/v1beta/openai`). Klucz `AIza…`.
  Tabela konfigu `def_api_gemini`, test połączenia (AJAX) + przycisk **„Odśwież listę"**
  (`ai_gemini_refresh_models`) pobierający pełną listę modeli konta z `/models`
  i zapisujący ją w `GemLastTestModels` (działa też przed zapisem — używa klucza z pola).
- Funkcje providera w [ai_lib.php](../admin/pages/settings/ai/ai_lib.php):
  `musicAiCallGemini()`, `musicGeminiListModels()`, `musicGeminiChatModels()` (odsiewa
  embedding/imagen/veo/tts), `musicGeminiIsVisionModel()` (wszystkie `gemini-*` widzą obrazy).
- **Console AI — Terminal**: Gemini jako provider (dropdown 💎), `tcChatGemini()`
  z function callingiem (web_search / fetch_url / save_file) i obrazami; czytelny
  komunikat dla HTTP 429 (RESOURCE_EXHAUSTED).
- **Generator opisów/tagów** (SoundCloud + Mixcloud): Gemini w selektorze providera
  edytora i panelu AI — okładka przekazywana zawsze (modele multimodalne).
  Walidacja długości/tagów wg wymagań platformy działa niezależnie od providera.
- **Automatyczny fallback modeli** ([musicGeminiFallbackModels()](../admin/pages/settings/ai/ai_lib.php)):
  gdy wybrany model zwróci **429** (przekroczona kwota — darmowe limity są PER model)
  lub **404** (model wycofany, np. `gemini-1.5-*`), `musicAiCallGemini()` i `tcChatGemini()`
  automatycznie próbują kolejnych (start: `gemini-2.5-flash`). Dla **500/503** („high
  demand", błąd przejściowy) najpierw krótki retry tego samego modelu (~1,2 s), potem
  fallback. Realnie użyty model jest logowany (`model_used`). Domyślny model: `gemini-2.5-flash`.
- Walidacja klucza Gemini rozluźniona — Google wydaje też klucze w formacie `AQ.…`
  (nie tylko `AIza`), więc sprawdzamy tylko czy klucz niepusty; resztę weryfikuje API.

### Naprawiono
- Groq — lista modeli odsiewa audio/TTS (`whisper-*`, `playai-tts`), które przy
  chat-completions dawały `HTTP 400 „does not support chat completions"`.
- Groq — czytelny komunikat dla **HTTP 413** (zapytanie przekracza limit tokenów/min
  modelu): rada zamiast surowego błędu API (kliknij „Nowa", tryb „Off", model o wyższym
  TPM, lub Claude/Ollama/Gemini).

## [0.7.9] — 2026-05-29

### Dodano

#### Wtyczka Muzyka — integracja **Mixcloud**
- Nowa zakładka *Integracje API → Mixcloud* ([api.tab-mixcloud.view.php](../admin/ext/music/api.tab-mixcloud.view.php)).
  Public API (read) działa bez kluczy; Client ID/Secret + OAuth pod operacje
  user-context. Tabela konfigu `def_m_api_mixcloud`, test połączenia.
- **OAuth Mixcloud** — publiczny callback [music/mixcloud/index.php](../music/mixcloud/index.php).
  Specyfika: brak PKCE, brak scope, **state NIE jest echo-wany** przez Mixcloud →
  fallback na weryfikację świeżości `MixOauthStartedAt` (okno 10 min). Token nie wygasa.
- **Pełny sync cloudcastów** z konta → tabela `def_m_mixcloud_casts`
  ([musicMixSyncCasts()](../admin/ext/music/mixcloud_lib.php)), paginacja, upsert po
  `MccKey`, archiwizacja nieobecnych. Username (slug) brany z `/me/` (skonfigurowany
  `MixUsername` bywa nazwą wyświetlaną ze spacjami → API zwracało 404). Po synchronizacji:
  **weryfikacja powiązań** — utwory oznaczone jako wgrane (`TraMixKey`), których cloudcasta
  już NIE MA na koncie (usunięty / nieopublikowany / 404), są **odpinane** (wracają do
  „Tylko lokalnie" + przycisk „Wyślij"); oraz **auto-linkowanie** cloudcastów do lokalnych
  utworów po tytule (gdy `TraMixKey` puste).
- **Selektor widoku SoundCloud / Mixcloud** na liście utworów — przełączenie ukrywa
  funkcje SC. Widok Mixcloud to **jedna zintegrowana tabela** (jak SoundCloud): wiersze
  to lokalne utwory, a dla wgranych na Mixcloud (`TraMixKey` = `MccKey`) statystyki
  cloudcasta (play/favorite/comment/listener) pokazują się **inline w wierszu** — bez
  osobnej tabeli pod spodem. **Sortowanie kolumn** (klikalne nagłówki, jak SoundCloud):
  Utwór (A→Z), Czas, Rozmiar, Status Mixcloud, oraz statystyki play/♥/komentarze/słuchacze;
  kierunek zapamiętany w `localStorage`.
- **Upload lokalnych plików na Mixcloud** (`POST /upload/`, [musicMixUploadCast()](../admin/ext/music/mixcloud_lib.php)) —
  z listy w widoku Mixcloud przy każdym pliku przycisk *Wyślij*; modal z paskiem
  postępu (upload realizuje serwer — pasek nieokreślony + realny rozmiar pliku).
  Wymaga OAuth. **Walidacja przed wysyłką** (nieblokująca): brak tagów / brak opisu /
  opis >1000 znaków → ostrzeżenie „Czy na pewno wysłać bez kompletu metadanych?"
  z możliwością wysłania mimo to (drugie kliknięcie = „Tak, wyślij mimo to").
- **Osobny edytor metadanych Mixcloud** (kebab *Edytuj…* w liście Mixcloud) —
  modal `#music-mix-edit-modal` BEZ funkcji SoundCloud, własne pola
  `TraMixTitle/TraMixTags/TraMixDescription` zapisywane lokalnie (offline) +
  przycisk *Pobierz* tagów/opisu z innego serwisu (na razie SoundCloud).
  Zakładka **Metadane** ma liczniki zgodności (opis ≤1000, tagi ≤5).
- **Aktualizacja metadanych na Mixcloud** (przycisk *Aktualizuj na Mixcloud*,
  widoczny gdy utwór jest już wgrany) — `musicMixEditCast()` przez
  `POST /upload/{user}/{slug}/edit/` zmienia **tytuł, tagi i opis bez ponownego
  uploadu pliku** (odpowiednik `PUT /tracks/{id}` w SoundCloud). Wspólny helper
  `musicMixPostMultipart()` (retry 5xx + parsowanie błędów) dla upload i edit.
- **Zakładka AI w edytorze Mixcloud** — interfejs jak w SoundCloud (panel
  *Generuj*), ale **bez tytułu** (operacje: tagi / opis / „wszystko"). Provider +
  model + badge konfiguracji, **chipy modeli vision** (klik aktywuje model +
  zaznacza „użyj okładki"), „Zaproponuj wszystko (tagi + opis)", „Zaproponuj inną
  wersję", osobno Tagi/Opis, przełączniki „po angielsku" / „użyj okładki", przycisk
  *Anuluj* (AbortController). Każdy wynik w osobnym panelu z **Zastosuj / Dopisz /
  Skopiuj**. Generowanie zgodne z limitami Mixcloud (opis ≤1000, max 5 tagów) —
  reużywa `music_track_ai_suggest` z `platform=mixcloud`
  ([musicAiBuildInstruction()](../admin/pages/settings/ai/ai_lib.php) ma wariant
  Mixcloud). Liczniki zgodności w polach Metadane.

#### Wtyczka Muzyka — integracja **Audius**
- Nowa zakładka *Integracje API → Audius* ([api.tab-audius.view.php](../admin/ext/music/api.tab-audius.view.php))
  + lib [audius_lib.php](../admin/ext/music/audius_lib.php). Zdecentralizowane Public
  API: **host discovery** (`api.audius.co` → lista node'ów) + wymagany `app_name`
  przy każdym żądaniu. Read-only (search / metadane / profile) — upload niemożliwy
  przez REST (wymaga SDK + portfela krypto). Tabela `def_m_api_audius`, test połączenia.

#### Wtyczka Muzyka — lista utworów (SoundCloud)
- **Synchronizacja pojedynczego utworu** z SC — pozycja *Synchronizuj z SC* w menu
  kebab (tylko utwory powiązane z SC). Aktualizuje statystyki w wierszu (odtworzenia/
  lajki/komentarze/reposty/pobrania) i okładkę **bez przeładowania strony**.
- **Sortowanie kolumn** *Utwór* (alfabetycznie A→Z, PL `localeCompare`), *Czas*
  (długość) i *Data* (data dodania) — klikalne nagłówki, kierunek zapamiętywany w
  `localStorage` (spójne z istniejącym sortowaniem po statystykach).

#### Integracje AI — Ollama
- **Konfigurowalny timeout zapytań** — nowe pole *Timeout zapytania (s)* w
  *Ustawienia → Integracje AI → Ollama* (kolumna `OllTimeout`, 30–1800 s, domyślnie
  300). Duże/gęste lub vision modele (np. qwen3-vl) bywają wolne — można podnieść.
  Wartość przekazywana do `musicAiCallOllama()` (CURLOPT_TIMEOUT) + `set_time_limit`
  po stronie PHP, żeby nie ucinać generowania.
- **Polecane modele** — przycisk obok „Zapisz" otwiera modal z tabelą rekomendowanych
  modeli Ollama w dwóch zakładkach (**Windows** / **macOS**). Każdy wiersz: przycisk
  **„Kopiuj"** komendy `ollama pull <model>`, **podgląd** oraz gotowy **skrypt instalacyjny**
  do skopiowania. ([admai.tab-ollama.view.php](../admin/pages/settings/ai/admai.tab-ollama.view.php) +
  obsługa `.oll-copy-btn`/`.oll-preview-btn`/`.oll-copy-script` w
  [admai.viewjs.php](../admin/pages/settings/ai/admai.viewjs.php)).

#### Console AI — Terminal
- **Pobieranie plików wygenerowanych przez model** — renderowanie linków markdown
  `[tekst](url)` w treści wiadomości (wcześniej pokazywane jako surowy tekst).
  Linki lokalne `/media/…` dostają atrybut `download` (wymusza pobranie zamiast
  wyświetlenia); http(s) → nowa karta; inne schematy (`javascript:`, `data:`) →
  zostają tekstem (anty-XSS). Naprawione w obu ścieżkach: JS `renderContent()`
  (nowe wiadomości) i PHP `$tcRenderBody()` (historia po przeładowaniu).
- **`save_file` dostępny we wszystkich trybach web** (off/auto/rag), nie tylko
  „auto" — generowanie pliku nie wymaga internetu. Tools sieciowe wydzielone do
  `tcDefineWebTools()`, plik do `tcDefineFileTools()`.
- **Instrukcja `save_file` w system prompt** — kategoryczna: przy prośbie o
  utworzenie pliku/dokumentu (HTML, raport, kod, dane) model MUSI wywołać
  `save_file` z pełną treścią zamiast wklejać ją do czatu.
- **Parser tekstowych wywołań toolów** ([tcParseTextToolCalls()](../admin/pages/consoleai/terminal/tools_lib.php)) —
  modele jak qwen3-coder przez Ollama emitują wywołanie jako tekst
  `<function=NAZWA><parameter=klucz>wartość</parameter></function>` zamiast pola
  `tool_calls`. Parser wykrywa ten format (odporny na ucięte zamknięcia) i wykonuje
  go jak strukturalne wywołanie narzędzia.

### Zmienione
- Upload Mixcloud: `@set_time_limit(0)` + `@ignore_user_abort(true)` w handlerze —
  duże pliki (long-form audio) nie są przerywane przez `max_execution_time` w
  kontekście web (obcięty plik → Mixcloud odrzucał jako „za krótki").
- Mixcloud — obsługa ograniczeń platformy: opis przycinany do **1000 znaków**
  (limit Mixcloud), pre-check długości **≥30 s** przed wysyłką, pole *Data publikacji*
  usunięte z okna wysyłki (planowanie premiery wymaga konta **Pro**).
- Mixcloud — czytelniejsze błędy: retry 5xx (×3, przejściowe `ServerErrorException`),
  cooldown po `403 RateLimitException` z odliczaniem `retry_after` (stan w
  `localStorage`, przeżywa reload), wyciąganie szczegółów walidacji z TOP-LEVEL
  `details` (np. „description: max 1000 characters").

### Bezpieczeństwo
- Console AI: linki w treści modelu linkowane tylko dla `http(s)://` i ścieżek
  absolutnych `/…`; pozostałe schematy (`javascript:`, `data:`) renderowane jako
  tekst — ochrona przed XSS w renderowaniu markdown-lite.

## [0.7.8] — 2026-05-27

### Dodano

#### Console AI — Terminal
- **Web search fallback chain** — chain providerów wyszukiwania w
  [tools_executors.php → tcWebSearch()](../admin/pages/consoleai/terminal/tools_executors.php):
  `DDG html → DDG lite → SearxNG public → Brave (opcjonalnie)`. Pierwszy sukces
  wygrywa; każdy provider próbowany sekwencyjnie z 10s timeoutem.
- **Brave Search API** jako search-provider — nowa zakładka w
  *Ustawienia → Integracje AI*. Plan Free: 2000 zapytań/mc. Klucz w
  `def_api_brave.BraApiKey`, wysyłany jako header `X-Subscription-Token`.
  Test połączenia AJAX-em.
- **SearxNG public instances** — fallback pomiędzy DDG a Brave: `searx.be`,
  `searx.tiekoetter.com`, `baresearch.org`, `priv.au`. Każda instancja próbowana
  z `?format=json`, max 10s na request. **0 zł / 0 setup**.
- **SearxNG self-hosted** — dokumentacja Docker compose: [docs/llm/searxng-selfhosted.md](llm/searxng-selfhosted.md).
- **Auto-RAG enhancement** — po `web_search` automatycznie pobierane top 2 URL-e
  (`tcRagFetchTopResults`) i wstrzykiwane do kontekstu — eliminuje meta-odpowiedzi
  typu „ranking jest na tych stronach".
- **`save_file` tool** — AI faktycznie tworzy pliki w
  `media/console/{sessionId}/files/` + przycisk download w UI.
- **Multi-turn fallback** — flag `$fallbackApplied` zamiast `$iter === 1`,
  rozszerzone wzorce wykrywania błędów Groq tool calling (`tool_use_failed`,
  `tool call validation failed`, `not in request.tools`, `attempted to call tool`).
- **Auto-retry HTTP 429** (Groq rate limit) — parser `try again in X.Xs` z
  bazy odpowiedzi, max 30s czekania, retry once.
- **Auto-retry HTTP 202** (DDG anti-bot) — jeden retry po 1.2s.

#### Console AI — UX
- Token badge: `bg-warning-subtle text-warning-emphasis` (theme-aware visibility w dark mode).
- Padding `.tc-msg-head` 60px aby badge nie nakładał się na ikony akcji.
- Collapse długich wiadomości do 3-4 wierszy + przycisk *Pokaż więcej* (mask-image fade-out).
- Akcje per wiadomość: kopiuj + download `.md`.
- Linkifikacja URL-i (`http(s)://`, `/media/...`) w wynikach tool calls.
- Czytelniejszy komunikat `Max tool iterations (5) reached` w jęz. polskim z sugestiami.

#### Wtyczka Muzyka — nowy panel **YouTube**
- Nowa pozycja submenu *Muzyka → YouTube* (między *Utwory* i *Integracje API*).
  Ikona: `fab fa-youtube`, badge filmów + badge `N niezsynchronizowanych`.
- **Lokalny cache filmów** — pełna lista z YouTube API zapisywana do
  `def_m_videos` (offline-friendly). Pola: tytuł, opis, tagi, kategoria,
  języki, status, statystyki, miniaturka.
- **Pristine YT values** (`VidYtTitle/Description/Tags/CategoryId`) trzymane
  osobno do porównań i ochrony lokalnych edycji przy re-syncu (IF `VidHasPending=0`).
- **Modal edycji SEO** z 4 zakładkami:
  - *Podstawowe* — tytuł (max 100), opis (max 5000) z licznikami znaków.
  - *Metadane / SEO* — tagi (suma ≤500 znaków), kategoria (dropdown), `defaultLanguage`, `defaultAudioLanguage`.
  - *AI* — generator propozycji przez Claude/Groq/Ollama. Operacje:
    tytuł (3 propozycje), opis SEO (1500–3000 znaków), tagi (10–15),
    komplet `TYTUL/OPIS/TAGI`. Custom prompt z podglądem. Historia AI w
    `def_m_video_ai_history`. Apply automatycznie parsuje wynik do pól.
  - *Historia* — wszystkie zmiany SEO per film z `def_m_video_history`,
    z ikonami statusu sync (☁️↑ niezsync / ☁️✓ wysłane).
- **Save → Push workflow**: klik *Wyślij do YouTube* zawsze:
  1. Zapis lokalny + wpis w historii per zmienione pole.
  2. PUT `/videos?part=snippet` do API (50 jedn. quoty).
  3. Sukces → mark historii jako synced + update pristine YT*.
  4. Fail (offline) → lokalne zmiany pozostają z flagą pending, można
     spróbować ponownie po odzyskaniu połączenia.
- **Auto-sync** przy pierwszym wejściu (jeśli `def_m_videos` puste).
  Quota ~3 jednostki na pełne pobranie (channels + playlistItems + videos batch).
- **Lokalne miniaturki** — `/music/media/yt-thumbs/{video_id}.jpg` pobierane
  podczas sync (best-effort z CSP fallback do `i.ytimg.com`). Sanitizacja
  video_id regexem `[A-Za-z0-9_-]{1,32}`.
- **Filtrowanie + sortowanie** client-side: search input (lowercased tytuł +
  tagi), dropdown sortowania (najnowsze / najstarsze / wyświetlenia / lajki /
  komentarze / tytuł A→Z / Z→A / niezsync. najpierw). Esc czyści filtr.
- **Linki YT** w tabeli (badge) i w modalu — `target="yt-preview"` (nazwane
  okno, reużywane przy kolejnych klikach).

#### Wtyczka Muzyka — nowy panel **YouTube** (zakładka *Integracje API*)
- **OAuth 2.0 + PKCE (S256)** — Google honoruje verifier+challenge (inaczej
  niż SoundCloud). Authorization Code, scope `youtube.force-ssl`.
- `access_type=offline + prompt=consent` w authorize URL — wymusza zwrot
  `refresh_token`. UWAGA: w trybie Testing Google wygasza refresh_token po 7 dniach.
- Publiczny callback `/music/youtube/index.php` — poza scope sesji admina
  (tak jak `/music/soundcloud/`). Anti-replay przez state + PKCE w DB,
  TTL 10 min, single-use code.
- Status autoryzacji w widoku: tytuł kanału, handle, ID, czas wygaśnięcia tokenu.
- Akcje: *Autoryzuj* (start OAuth), *Odśwież token*, *Odłącz*, *Test: pobierz kanał*.

### Bezpieczeństwo
- CSP `img-src` rozszerzone o `https://i.ytimg.com https://yt3.ggpht.com`
  jako fallback dla miniaturek YouTube przed pierwszym sync-iem
  (po sync-u używane lokalne `/music/media/yt-thumbs/`).
- Walidacja `video_id` regexem przed użyciem w ścieżce pliku (ochrona path traversal).
- PDO HY093 fix w `ytbUpsertVideo` — rozdzielenie nazw placeholderów dla
  pól Vid* i VidYt* (PDO native prepares nie pozwala na duplikaty).

### Zmienione
- `aiEnsureSchema()` przeprowadza migrację: bump `CafMaxTokens` i
  `GrqMaxTokens` z 1024 → 4096 jeśli były na starym defaulcie.
- `TC_TOOLS_RESULT_MAX_CHARS` 6000 → 4500 (Groq free tier TPM budżet).
- Provider tab w Integracje AI: spójny layout (status, test AJAX,
  ostatni wynik testu w `alert-success/warning`).

### Refaktor
- `tools_lib.php` podzielony na 3 moduły (każdy < 1000 linii):
  `tools_executors.php` (search/fetch), `tools_lib.php` (multi-turn runner),
  `tools_providers.php` (Claude/Groq/Ollama chat).
- `musicScApiCallWithRefresh()` jako wspólny helper auto-refresh tokenu
  przy 401; analogiczny `musicYtbApiCallWithRefresh()` w `ytb_lib.php`.

---

## [0.7.7] — 2026-05-23

### Dodano
- **Galeria zdjęć** — nowa sekcja per-domena w panelu administracyjnym:
  - Dowolna liczba galerii per-strona; każda galeria ma nazwę, opis i status (`active`/`hidden`).
  - Kategorie i tagi przypisywane do galerii (zakładka „Kategorie & Tagi").
  - Upload jednego lub wielu zdjęć jednocześnie — drag-and-drop lub klik; progress bar XHR
    (bez przeładowania strony).
  - Automatyczne skalowanie do max. 1920×1080 px (konfigurowalne per-tenant w `configs/`).
  - Generowanie miniatury 300×300 px w folderze `media/cache/{folder}/thumb/`.
  - Obsługiwane formaty: JPEG, PNG, GIF, WebP (walidacja przez `getimagesize()`).
  - Możliwość ustawienia zdjęcia okładkowego galerii.
  - Edycja atrybutów zdjęcia (tytuł, tekst alternatywny).
  - Usunięcie galerii kasuje kaskadowo zdjęcia, relacje kategorii/tagów i pliki na dysku.
  - Pliki zapisywane w: `ROOT/media/originals/{folder}/` i `ROOT/media/cache/{folder}/`.
  - Folder wyznaczany z `DomCmsName` (lub `DomName`); znak `:` usuwany, niedozwolone znaki
    zastępowane podkreślnikiem.
- Konfiguracja galerii w `configs/_default.php`:
  `gallery.max_width`, `gallery.max_height`, `gallery.thumb_size`, `gallery.max_upload_mb`.
- Nowy wpis „Galeria zdjęć" w menu bocznym per-domena (bezpośrednio pod „Menu nawigacyjne").

---

## [0.7.6] — 2026-05-23

### Bezpieczeństwo
- **Szyfrowanie backupów AES-256-CBC (propozycja 06)** — gdy klucz `backup_encryption_key`
  jest skonfigurowany w configs, nowe backupy zapisywane są jako `.sql.enc` (zamiast
  plain-text `.sql`). Format: `[4B magic "K2BC"][16B IV losowe][dane AES-256-CBC]`.
  Stare pliki `.sql` (bez klucza) nadal działają bez zmian.
- **Podpis integralności SHA-256** — przy każdym backupie tworzony jest plik `.sha256`
  (format `sha256sum`). Weryfikowany przed przywróceniem (blokuje) i przed pobraniem
  (ostrzeżenie w logu). Brak sygnatury przy starszych plikach — ostrzeżenie, nie blokada.
- **Ochrona przed path traversal przy pobieraniu** — `realpath()` guard: serwer weryfikuje
  że żądany plik leży wewnątrz `var/backups/` (double-check po `basename()` + regex).
- **Usuwanie sidecara `.sha256`** przy kasowaniu backupu — spójność katalogu.

### Zmienione
- `listBackupFiles()` zwraca teraz pliki `.sql` i `.sql.enc` (połączone dwa globs);
  każdy wpis ma pole `encrypted: bool`.
- Wszystkie regeksy walidacji nazwy pliku (download, delete, restore) rozszerzone
  o opcjonalne `.enc`: `(mysql|sqlite)\.sql(\.enc)?`.
- Widok backupu: badge <span class="badge badge-success"><i class="fas fa-lock"></i> enc</span>
  przy zaszyfrowanych plikach; zaktualizowana nota informacyjna o lokalizacji.

---

## [0.7.5] — 2026-05-23

### Dodano
- **Dokumentacja architektoniczna** — nowy katalog `docs/architektura/` z plikami
  `architektura.md` (Markdown) i `architektura.html` (samodzielny HTML ze stylami,
  działa offline). Dokument obejmuje: przegląd systemu, stos technologiczny, strukturę
  katalogów, warstwy rdzenia i aplikacji, routing panelu, wzorzec multi-tenant oraz
  pełny rozdział bezpieczeństwa (8 podrozdziałów).

### Bezpieczeństwo
- **Honeypot na formularzu logowania (3.4)** — ukryte pole CSS `hp_phone` (klasa
  `.a11y-offscreen`: `position: absolute; left: -9999px; opacity: 0`) niewidoczne
  dla ludzi, wypełniane przez boty parsujące surowy HTML. Wypełnione pole → odrzucenie
  z neutralnym komunikatem + log WARN w kanale `Auth`. Boty wykryte przez honeypot
  nie są liczone w `login_attempts` — nie zużywają budżetu rate limitera.
  Sprawdzanie w kolejności: CSRF → honeypot → rate limit → authenticate().
- **Rate limiting logowania (1.3)** — maksymalnie 10 nieudanych prób logowania
  z jednego adresu IP w oknie 15 minut. Bucket = SHA-256(IP) — surowy adres
  nie jest przechowywany w bazie. Po przekroczeniu limitu żądanie logowania jest
  odrzucane z komunikatem bez ujawniania szczegółów. Licznik jest czyszczony
  automatycznie po wygaśnięciu okna (bez cron-joba) oraz po udanym logowaniu.
  Fail-open: przy braku tabeli (świeża instalacja przed migracją) rate limiting
  nie blokuje dostępu.
  - Nowa tabela `<tenant>_login_attempts` (migracja
    [Version20260523180000](../app/Appdb/Migrations/Version20260523180000.php)).
  - Nowe funkcje w `admcore.php`: `loginAttemptsTable()`, `loginIsBlocked()`,
    `loginRecordFailure()`, `loginClearFailures()`.
- **Bezpieczne ciasteczko sesji (2.1)** — `session_set_cookie_params()` z
  `SameSite=Strict`, `httponly=true`, `secure` (przy HTTPS) ustawiane przed
  `session_start()`. `ini_set('session.use_strict_mode', '1')` — PHP odrzuca
  identyfikatory sesji przesłane z zewnątrz (blokuje Session Fixation przez URL).
- **Nagłówki bezpieczeństwa HTTP (2.2)** — wysyłane po weryfikacji kodu dostępu,
  przed jakimkolwiek wyjściem HTML:
  - `X-Frame-Options: DENY` + `frame-ancestors 'none'` w CSP — ochrona przed
    clickjackingiem.
  - `X-Content-Type-Options: nosniff` — blokuje MIME-sniffing.
  - `Referrer-Policy: strict-origin-when-cross-origin`.
  - `Permissions-Policy: camera=(), microphone=(), geolocation=()`.
  - `X-XSS-Protection: 0` (przestarzałe filtry wyłączone; CSP wystarcza).
  - `Strict-Transport-Security` (max-age=1 rok, includeSubDomains) — tylko gdy HTTPS.
  - `Content-Security-Policy`: `default-src 'self'`, `form-action 'self'`,
    `object-src 'none'`; `unsafe-inline` dla script-src i style-src tymczasowo
    (TODO: nonce).

---

## [0.7.4] — 2026-05-23

### Dodano
- **Wiele zestawów menu nawigacyjnego per-domena** — każda witryna może mieć
  dowolną liczbę niezależnych drzew menu (np. główne, stopka, mobilne).
  Każdy zestaw identyfikowany jest unikalnym **kodem menu** per-strona (np. `main`,
  `footer`) używanym przez front-end do pobrania konkretnego menu.
  - Nowa tabela `<tenant>_navigation_menus` (model
    [NavigationMenusModel](../app/Appdb/Models/NavigationMenusModel.php)) —
    migracja [Version20260523150000](../app/Appdb/Migrations/Version20260523150000.php).
    Pola: nazwa wyświetlana, kod menu, kolejność (`NavMenuSort`).
  - Nowa kolumna `NavMenuID` w `<tenant>_navigation` — przypisuje pozycję do
    konkretnego zestawu (migracja
    [Version20260523160000](../app/Appdb/Migrations/Version20260523160000.php)).
  - Nowa kolumna `NavHistMenuID` w `<tenant>_navigation_history` — historia
    migawkowa scopuje się per-zestaw, nie per-domena (migracja
    [Version20260523170000](../app/Appdb/Migrations/Version20260523170000.php)).
- **Nowy ekran „Zestawy menu"** (`admmenus.view.php`) — lista zestawów danej
  domeny: nazwa, kod menu, liczba pozycji, akcje (otwórz drzewo, edytuj, usuń).
  Modalne formularze dodawania i edycji z automatycznym generowaniem kodu menu z
  nazwy (JS, `/^[a-z0-9][a-z0-9\-]*$/`, maks. 64 znaki, unikalny per-strona).
  Usunięcie **jedynego** zestawu domeny jest blokowane (`err_menu_last`).
- **Migracja istniejących danych** — funkcja `getOrCreateDefaultMenu()` wywoływana
  przy pierwszym wejściu w obszar nawigacyjny: zakłada zestaw „Menu główne"
  (kod menu `main`) i przypisuje do niego wszystkie pozycje z `NavMenuID IS NULL`.

### Zmienione
- **Routing nawigacji** — dwupoziomowy: `?page=navigation&id=<DomID>` otwiera
  listę zestawów menu (nowy widok `admmenus`); `&menu=<MenuID>` otwiera edytor
  drzewa wybranego zestawu. Brak parametru `menu` → zawsze lista zestawów.
- **Widok drzewa** (`admmenu.view.php`) — nagłówek pokazuje nazwę i kod menu
  aktywnego zestawu; przycisk „← Zestawy menu" wraca do listy. Linki akcji
  (edycja, dodaj wewnątrz, usuń) niosą parametr `&menu=`.
- **Historia migawkowa** — snapshoty tworzone i filtrowane per `NavHistMenuID`;
  stare snapshoty (bez wartości w tej kolumnie) izolowane od nowych widoków.
- **`deleteDomain()`** — kaskada obejmuje teraz również wpisy
  `<tenant>_navigation_menus` usuwanej domeny.

---

## [0.7.3] — 2026-05-23

### Bezpieczeństwo
- **Globalne zabezpieczenie podstron** — każda próba wejścia z parametrami GET
  (np. `?page=permissions`, `?id=…`) bez aktywnej sesji jest przekierowana
  (HTTP 302) na czysty URL panelu, gdzie wyświetlany jest formularz logowania.
  Próba zalogowana w dzienniku (`Auth`, WARN, klucz `page`).
- **Idle-timeout sesji = 3 h** — każde żądanie zalogowanego konta odświeża
  `$_SESSION['admin_last_activity']`. Po 3 godzinach bez aktywności sesja jest
  niszczona (`session_destroy()` + `session_regenerate_id()`), a użytkownik
  trafia z powrotem na ekran logowania z komunikatem
  „Sesja wygasła po 3 godzinach bezczynności". Zdarzenie odnotowane w dzienniku
  (`Auth`, INFO).
- Stałą czasu trzyma `SESSION_MAX_IDLE` w [admin/index.php](../admin/index.php)
  (`3 * 3600`). Logowanie inicjalizuje `admin_last_activity` od momentu sukcesu.

### Dodano
- **Wersja CMS** widoczna w stopce panelu (`K2 CMS v.<CMS_VERSION>`). Wartość
  trzymana w [core/version.php](../core/version.php) jako stała
  `CMS_VERSION = '2026.05.3'` — bumpować przy każdym nowym wpisie changelogu
  (N = patch-number).
- **Cache-busting** wspólnych zasobów panelu — linki do `index.css` i `index.js`
  w [admlayout.view.php](../admin/admlayout.view.php) oraz
  [admlogin.view.php](../admin/admlogin.view.php) otrzymują parametr
  `?v=<filemtime>`. Po edycji CSS/JS przeglądarka pobiera świeżą wersję bez
  hard-refresha.

### Zmienione
- **Nagłówek podstrony Menu nawigacyjne** — H1 zmienione z
  `<DomCmsName> — Menu nawigacyjne` na `<i>🗂️</i> Menu nawigacyjne — <DomCmsName>`
  (ikona + przestawiony tytuł). Powłoka [admlayout.view.php](../admin/admlayout.view.php)
  obsługuje opcjonalną zmienną `$pageIcon` (puste `''` w
  [index.php](../admin/index.php), nadpisywane w backendzie podstrony).
  Duplikat tytułu w `card-header` usunięty — zostaje tylko przycisk
  „Dodaj pozycję".
- **Wizualizacja drzewa menu** — boxowane wiersze (`.nav-tree-row`), wiersz
  folderu z ciepłym tłem (`.nav-tree-folder`), ścieżka URL jako monospace „chip"
  (`.nav-tree-path`), lewa linia łącząca dzieci w zagnieżdżeniach, hover
  z `box-shadow`. Pełne wsparcie motywów (jasny / ciemny / WCAG).
  Empty-state z ikoną `fa-sitemap` w skali szarości.

---

## [0.7.2] — 2026-05-23

### Dodano
- **Menu nawigacyjne (drzewo per-domena)** — zakładka domeny otwiera pełny
  edytor menu witryny w `?page=navigation&id=<DomID>` (pliki
  [admin/pages/navigation/admmenu.php](../admin/pages/navigation/admmenu.php)
  + `admmenu.view.php`). Zastępuje wcześniejszy placeholder „w przygotowaniu".
  - Nowa tabela `<tenant>_navigation` (model
    [NavigationModel](../app/Appdb/Models/NavigationModel.php)) — migracja
    [Version20260523120000](../app/Appdb/Migrations/Version20260523120000.php).
  - Pozycje typu **folder** (rozwijane, mogą zawierać dzieci) lub **page**
    (liść); rodzic przez `NavParentID` (self-FK, NULL = poziom najwyższy),
    kolejność wewnątrz rodzica przez `NavSort`, przynależność do witryny
    przez `NavDomID`.
  - Drzewo renderowane jako zagnieżdżone `<ul>`/`<li>` z ikonami (folder/strona)
    i ścieżką URL. Akcje per pozycja: edycja, usunięcie, „dodaj wewnątrz"
    (dla folderów).
  - Walidacja: tytuł wymagany (1–190 znaków), typ ∈ {folder, page}, rodzic
    musi być folderem tej samej domeny i nie może być potomkiem edytowanej
    pozycji (wykrywanie cykli).
  - **Usuwanie kaskadowe** — skasowanie folderu usuwa też wszystkich
    potomków (BFS w PHP, bez FK constraintów w DB).
  - **Cascade na usunięciu domeny** — `deleteDomain()` najpierw kasuje
    wszystkie pozycje menu danej domeny, potem samą domenę.
  - Operacje odnotowane w dzienniku (kanał `Nawigacja`).
  - Etykieta dziecka w sidebarze domeny zmieniona z „w przygotowaniu" na
    „Menu nawigacyjne". Stary placeholder `admin/pages/domain/admdomena.*`
    usunięty wraz z trasą `?page=domain`.
  - **UX nagłówka karty** — przycisk „Dodaj pozycję" przeniesiony na lewą
    stronę nagłówka (zamiast standardowych `card-tools` po prawej);
    usunięto powtórzony adres witryny z body drzewa (widoczny już w sidebarze
    i tytule podstrony).
  - **Usuwanie pozycji** przez **wspólny modal Bootstrap** (tytuł „Menu
    nawigacyjne", stylistyka jak modale Uprawnień/Domen) zamiast natywnego
    `confirm()` przeglądarki. Jeden modal na całe drzewo — id pozycji
    i tytuł podstawiane na zdarzeniu `show.bs.modal` z atrybutów
    `data-nav-id` / `data-nav-title` na przycisku-spustniku.

---

## [0.7.1] — 2026-05-22

### Dodano
- **Zakładki domen w menu bocznym** — każda zdefiniowana domena pojawia się jako
  osobna, **rozwijana zakładka główna** (jak Ustawienia), nazwana wartością pola
  „Nazwa w CMS" (`DomCmsName`).
  - Widoczna dla wszystkich zalogowanych kont; pozycja w menu między Pulpitem
    a Ustawieniami.
  - Nowy obszar roboczy domeny `?page=domain&id=<DomID>` (pliki
    [admin/pages/domain/admdomena.php](../admin/pages/domain/admdomena.php)
    + `admdomena.view.php`) — na razie placeholder („w przygotowaniu") z danymi
    witryny: adres, nazwa w CMS, konfiguracja.
  - Nieznany lub usunięty identyfikator domeny → przekierowanie na Pulpit.

---

## [0.7.0] — 2026-05-22

### Zmienione
- **Reorganizacja panelu administracyjnego** — monolityczne `index.php` +
  `index.view.php` rozbite na osobne pliki: każda podstrona to para
  `adm<strona>.php` (backend) + `adm<strona>.view.php` (widok).
  - `index.php` — **plik startowy**: bootstrap, kontrola kodu dostępu,
    uwierzytelnianie, routing podstron.
  - `admcore.php` — rdzeń: wspólne funkcje (konta, grupy, domeny, baza).
  - `admlayout.view.php` — wspólna powłoka AdminLTE (topbar, menu, stopka).
  - `admlogin.view.php` — wydzielony ekran logowania.
  - Podstrony w `admin/pages/<sekcja>/`: `pages/desktop/` (Pulpit),
    `pages/settings/` (Uprawnienia, Grupy, Domeny), `pages/system/` (System).
  - Usunięto `admin/index.view.php`.
  - Bezpośredni dostęp do plików panelu blokowany: reguła `^adm.*\.php$`
    w [admin/.htaccess](../admin/.htaccess) oraz `Require all denied`
    w `admin/pages/.htaccess`.
- Zmiana wyłącznie strukturalna — funkcjonalność i wygląd panelu bez zmian.

---

## [0.6.6] — 2026-05-22

### Dodano
- **Domeny** — zakładka w sekcji Ustawienia (dostępna wyłącznie dla grupy Administrator): definicje stron internetowych zarządzanych z poziomu CMS-a.
  - Nowa tabela `<tenant>_domains` (model [DomainsModel](../app/Appdb/Models/DomainsModel.php)) — migracja [Version20260522130000](../app/Appdb/Migrations/Version20260522130000.php).
  - Pola: **połączenie** (http/https — pierwsze pole), **nazwa domeny**, **nazwa w CMS**, **konfiguracja**.
  - Nazwa w CMS pozostawiona pusta → przy zapisie kopiowana z nazwy domeny.
  - Pole konfiguracji — wybór pliku z katalogu `configs/` (z pominięciem `_default.php`).
  - Pełne zarządzanie: lista, dodawanie, edycja, usuwanie (z oknem modalnym). Operacje odnotowane w dzienniku (kanał `Domeny`).

---

## [0.6.5] — 2026-05-22

### Zmienione
- **Obsługa hasła w formularzach kont** (strona Uprawnienia):
  - **Dodawanie konta** — hasło wpisywane dwukrotnie (pole + powtórzenie); zgodność sprawdzana po stronie przeglądarki (natywna walidacja) i serwera.
  - **Edycja konta** — pole hasła zastąpione przyciskiem **Zmień hasło**, który otwiera okno modalne (nowe hasło + powtórzenie).
  - Edycja **własnego konta** — okno modalne wymaga dodatkowo podania **aktualnego hasła** (weryfikowane przez `password_verify`).
  - Nowa akcja `change_password` (funkcja `changePassword()`), dostępna tylko dla grupy Administrator. `updateUser()` nie obsługuje już hasła — zmiana hasła jest osobną operacją.
- **Usuwanie konta** — natywne potwierdzenie `confirm()` zastąpione estetycznym oknem modalnym z tytułem sekcji („Uprawnienia").

---

## [0.6.4] — 2026-05-22

### Bezpieczeństwo
- **Kontrola dostępu wg grup** — sekcje **Uprawnienia** i **Grupy** dostępne wyłącznie dla kont z grupy **Administrator** (oraz konta serwisowego `admin`):
  - Konta z grupy Użytkownik nie widzą sekcji Ustawienia w menu bocznym.
  - Próba wejścia z bezpośredniego linku (`?page=permissions` / `?page=groups`) jest blokowana — przekierowanie na Pulpit z komunikatem o braku uprawnień.
  - Akcje zarządzania kontami (`create_user` / `update_user` / `delete_user`) odrzucane dla kont bez uprawnień.
  - Każda zablokowana próba jest odnotowana w dzienniku (`Logger`, poziom WARN, kanał `Auth`) — wraz z nazwą sekcji/akcji i loginem.

---

## [0.6.3] — 2026-05-22

### Dodano
- **Grupy uprawnień** — role kont panelu administracyjnego:
  - Nowa tabela `<tenant>_groups` (model [GroupsModel](../app/Appdb/Models/GroupsModel.php)) — migracja [Version20260522120000](../app/Appdb/Migrations/Version20260522120000.php). Seed: dwie grupy domyślne — **Administrator** i **Użytkownik**.
  - Kolumna `UseGroupID` w tabeli `<tenant>_users` (referencja do grupy) — migracja [Version20260522120100](../app/Appdb/Migrations/Version20260522120100.php).
  - Konto serwisowe `admin` należy do grupy **Administrator**; konta zakładane w panelu trafiają domyślnie do grupy **Użytkownik**.
  - Pozycja **Grupy** w menu bocznym (sekcja Ustawienia, pod Uprawnienia; tooltip „grupy uprawnień") oraz strona `?page=groups` — lista grup z liczbą przypisanych kont.
  - **Wybór grupy w formularzu** dodawania i edycji konta. Grupa konta `admin` jest zablokowana na Administrator (przełącznik wyłączony w UI, wymuszane też w backendzie).

---

## [0.6.2] — 2026-05-22

### Zmienione
- **Strona Uprawnienia** — przebudowa układu: strona pokazuje wyłącznie listę kont. Dodawanie i edycja to osobne widoki (`?page=permissions&new` oraz `&edit=<id>`).
  - Przycisk **Dodaj** w nagłówku listy.
  - Kolumna **Akcje** zredukowana do przycisku edycji (ikona).
  - Usuwanie konta i zmiana statusu aktywności przeniesione do formularza edycji.
- Z listy kont usunięto oznaczenie nazwy tabeli bazodanowej.

### Bezpieczeństwo
- **Konto `admin` chronione** — nie można go dezaktywować ani usunąć. Blokada w UI (formularz edycji: przełącznik statusu wyłączony, brak przycisku usuwania) oraz w backendzie (`updateUser()` wymusza status aktywny dla konta `admin`, a akcja `delete_user` odrzuca to konto).

---

## [0.6.1] — 2026-05-22

### Dodano
- **Mechanizm logowania zdarzeń w stylu NLog** — [core/Log/Logger.php](../core/Log/Logger.php) (`Core\Log\Logger`). Pełny opis: [docs/logowanie.md](logowanie.md).
  - Poziomy (jak NLog): `trace` / `debug` / `info` / `warn` / `error` / `fatal`.
  - Zapisuje structured logi do tabeli `<tenant>_logs` (model `LogsModel`): poziom, kanał, wiadomość, wyjątek, **callsite** (klasa/metoda/linia/plik — wykrywany automatycznie przez `debug_backtrace()`), kontekst strukturalny (`properties` JSON, host, PID, wersja aplikacji), kontekst HTTP (URI, IP, User-Agent) oraz `LogUserID`.
  - `Logger::get('Kanał')` — logger nazwany; `Logger::forCurrentClass()` — nazwa = klasa wywołująca (odpowiednik `GetCurrentClassLogger()`).
  - `Logger::registerHandlers()` — opcjonalne globalne przechwytywanie nieobsłużonych wyjątków i błędów PHP (mapowanych na poziomy WARN/ERROR/FATAL).
  - **Odporność** — logowanie nigdy nie rzuca wyjątku ani nie przerywa aplikacji; błąd zapisu do bazy → zapis awaryjny do `var/logs/app.log`, a w ostateczności do logu błędów PHP.
  - Filtr poziomu — klucz configu `log_level` (domyślnie `TRACE`, czyli zapisywane jest wszystko).
- [docs/logowanie.md](logowanie.md) — dokumentacja mechanizmu logowania (API, przykłady, konfiguracja).
- **Audyt panelu administracyjnego** — panel zapisuje przez `Logger` zdarzenia: udane i nieudane logowania oraz wylogowania (kanał `Auth`), a także operacje na kontach — utworzenie, edycję i usunięcie (kanał `Konta`). ID zalogowanego konta trafia do kolumny `LogUserID`. Włączone globalne przechwytywanie błędów panelu (`Logger::registerHandlers()`).

---

## [0.6.0] — 2026-05-22

Pełnoprawny panel administracyjny **K2 CMS** — od ekranu logowania po zarządzanie kontami. Pełny opis: [docs/panel-admin.md](panel-admin.md).

### Dodano
- **Logowanie oparte o bazę danych** — uwierzytelnianie przez tabelę `<tenant>_users`:
  - Formularz login + hasło; weryfikacja `password_verify()` względem hasha `UsePassword`, warunek `UseIsActive = 1`, zapis `UseLastLogin`.
  - **Automatyczne założenie konta `admin`**, gdy tabela kont jest pusta — hasło `admin` + bieżący rok (np. `admin2026`), zapisane jako hash.
  - **Konto serwisowe** `admin` / `admin{rok}` wbudowane w kod — działa wyłącznie, gdy tabela kont jest pusta (awaryjny bootstrap dostępu).
- **Zarządzanie kontami w panelu** (Ustawienia → Uprawnienia) — lista kont, tworzenie, edycja (login / e-mail / hasło / status), aktywacja/dezaktywacja, usuwanie. Hasła zawsze przez `password_hash()`.
- **Panel oparty o AdminLTE 3** — szablon zwendorowany lokalnie w [admin/assets/](../admin/assets/) (AdminLTE 3.2, Bootstrap 4.6, jQuery 3.6, Font Awesome 6.5) — **działa w pełni offline, bez CDN**.
  - Layout: sidebar (Pulpit / Ustawienia → Uprawnienia / System) + topbar, routing przez `?page=`.
  - Strona **System** — przeniesiona diagnostyka (status bazy, komponenty, raport migracji).
- **Sekretny adres panelu** — panel działa wyłącznie pod `admin/{kod}/`, gdzie `{kod}` to klucz `admin_code` z configu (per-tenant → unikatowy adres dla każdego serwisu). Każda inna ścieżka, w tym `/admin/` i `/admin/index.php`, zwraca 404.
  - Nowy [admin/.htaccess](../admin/.htaccess) — kieruje ruch pod `admin/` do `index.php`.
  - Klucz `admin_code` w [configs/_default.php](../configs/_default.php) i [configs/klient1.local.php](../configs/klient1.local.php).
- **Rozdział logiki i widoku** — konwencja `nazwa.php` → `nazwa.view.php` (szablon HTML) → `nazwa.css` (style):
  - [admin/index.php](../admin/index.php) — backend (uwierzytelnianie, akcje, przygotowanie danych).
  - [admin/index.view.php](../admin/index.view.php) — szablon HTML (ekran logowania + panel).
  - [admin/index.css](../admin/index.css) — style ekranu logowania.
- Ekran logowania — układ dwukolumnowy (powitanie na gradiencie + formularz), tło ze zdjęciem szczytu K2 jako pastelowy znak wodny ([admin/assets/img/login-bg.jpg](../admin/assets/img/login-bg.jpg)).
- **Motyw jasny / ciemny / WCAG** — trzy tryby, przełączane ikonami na ekranie logowania (prawy górny róg) i w topbarze panelu; wybór zapamiętany w ciasteczku `k2_theme`, renderowany serwerowo (bez mignięcia).
  - Tryb **ciemny** — `dark-mode` AdminLTE w panelu + własne style ciemne na ekranie logowania.
  - Tryb **WCAG** — wysoki kontrast wg WCAG 2.2: czarne tło, biały tekst, żółte elementy interaktywne, podkreślone odnośniki, wyraźny fokus, bez obrazów dekoracyjnych. Działa na ekranie logowania i w całym panelu.
  - **Opcje dostępności** (niezależne od motywu) — rozmiar tekstu A / A+ / A++ (ciasteczko `k2_font`, skalowanie `font-size` na `<html>`) oraz skala szarości (ciasteczko `k2_gray`, filtr `grayscale`). Cztery ikony: motyw, WCAG, rozmiar tekstu, szarość.
  - Przełączanie w locie: [admin/index.js](../admin/index.js).
- [docs/panel-admin.md](panel-admin.md) — dokumentacja panelu administracyjnego.
- [docs/media/README.md](media/README.md) — rejestr pochodzenia i licencji mediów pobranych spoza projektu.

### Zmienione
- **Branding panelu: `w3app` → `K2 CMS`** (logo: pasmo górskie SVG nawiązujące do szczytu K2).
- Migracje uruchamiane przy wejściu na stronę **System** panelu (wcześniej: przy każdym otwarciu panelu po zalogowaniu) — Pulpit i Uprawnienia ładują się bez uruchamiania migratora.
- Usunięty klucz configu `admin_password` — zastąpiony uwierzytelnianiem przez tabelę `<tenant>_users` i kontem serwisowym.

### Bezpieczeństwo
- Kod dostępu (`admin_code`) i hasło konta serwisowego porównywane przez `hash_equals()` (odporność na atak czasowy). Odpowiedź 404 nie zdradza istnienia panelu.
- Hasła kont przechowywane wyłącznie jako hash (`password_hash` / `password_verify`); wszystkie zapytania na prepared statements.
- Szablony `*.view.php` zablokowane przed dostępem bezpośrednim — reguła `.htaccess` (`[F]`) + strażnik `defined('ROOT')` w pliku szablonu.
- Akcje na kontach w schemacie POST→Redirect→GET — odświeżenie strony nie powtarza operacji.

### Architektura
- **Konto serwisowe = bootstrap** — rok w haśle (`admin{rok}`) działa tylko przy pustej tabeli kont; po założeniu pierwszego konta logowanie idzie wyłącznie przez bazę.
- **Zasoby front-endu zwendorowane** — panel nie zależy od sieci; każdą bibliotekę pobiera się do `admin/assets/`, bez linków CDN.
- **Widok oddzielony od logiki** — backend przygotowuje dane, szablon `*.view.php` wyłącznie renderuje (zero zapytań do bazy i logiki biznesowej w widoku).

---

## [0.5.3] — 2026-05-13

### Dodano
- **Wersja aplikacji** — [core/Version.php](../core/Version.php) (`final class Core\Version` ze stałą `NUMBER = '2026.05'` i statyczną metodą `current(): string`). Format `YYYY.MM` — wartość bumpowana ręcznie raz na miesiąc przy wdrożeniu cyklicznym.
- Kolumna `LogAppVersion` w tabeli `<tenant>_logs` — przechowuje wersję aplikacji w momencie zapisu wpisu. Pozwala diagnozować "co poszło źle po deployu wersji X". `VARCHAR(20)` (margines na ewentualne suffixy typu `2026.05.dev1`), indeksowana.
- Migracja ALTER: [app/Appdb/Migrations/Version20260513150000.php](../app/Appdb/Migrations/Version20260513150000.php) — `ADD COLUMN LogAppVersion ... AFTER LogProcessId` + `ADD INDEX idx_<table>_appversion`. `down()` cofa zmiany.
- Linia w [app/Appdb/Models/LogsModel.php](../app/Appdb/Models/LogsModel.php) (`Column::varchar('AppVersion', 20)->nullable()->indexKey('appversion')`) — model zsynchronizowany z bazą, świeże wdrożenia dostaną kolumnę od razu w `CREATE TABLE`.

### Architektura
- **Wersja jako kod, nie config** — `Core\Version` to klasa PHP, nie klucz w `configs/`. Powód: wartość jest deterministyczna względem deploya, identyczna dla wszystkich tenantów. Config trzyma rzeczy zmienne per środowisko/klient.
- **Wzorzec dla logu**: warstwa logująca dodaje `'LogAppVersion' => Core\Version::current()` do każdego INSERT-u — jeden source of truth.

---

## [0.5.2] — 2026-05-13

### Zmienione
- **Komponent `appm` przemianowany na `appdb`** (Application Main → "Application database / baza aplikacji"). Nazwa lepiej oddaje funkcję — to moduł danych bazowych aplikacji, niezależny od warstwy panelu/UI
- `app/Appm/` → `app/Appdb/` (rename folderu)
- Namespace: `App\Appm\Migrations` → `App\Appdb\Migrations`, `App\Appm\Models` → `App\Appdb\Models`
- Tabela metadanych: `def_migrations_appm` → `def_migrations_appdb` (`RENAME TABLE`)
- Wpis w `def_migrations_appdb.version` zaktualizowany przez UPDATE
- Lock-pliki: `var/schema-lock/appm.lock*` → `appdb.lock*`

### Dodano
- [app/Appdb/Models/LogsModel.php](../app/Appdb/Models/LogsModel.php) — tabela `logs` w stylu NLog (C#): poziom, źródło, wiadomość, exception + **callsite** (`LogClass`, `LogMethod`, `LogLineNumber`, `LogFile`), kontekst (Properties JSON, HostName, ProcessId), kontekst HTTP (RequestUri, IpAddress, UserAgent), referencja do users (`LogUserID`)
- [app/Appdb/Migrations/Version20260513140000.php](../app/Appdb/Migrations/Version20260513140000.php) — `CREATE TABLE <tenant>_logs` z modelu
- Indeksy: `idx_<tab>_level`, `idx_<tab>_logger`, `idx_<tab>_user` (single) + `idx_<tab>_level_datetime` (compound, dla zapytań "błędy z ostatniej godziny")

### Migracja istniejących wdrożeń
Jeśli ktoś już wdrożył wersję 0.4.4/0.5.0/0.5.1 z `appm`:
```sql
RENAME TABLE def_migrations_appm TO def_migrations_appdb;
UPDATE def_migrations_appdb
SET version = REPLACE(version, 'App\\Appm\\', 'App\\Appdb\\')
WHERE version LIKE 'App\\Appm\\%';
```
Plus rename folderu `app/Appm` → `app/Appdb` i lock-plików w `var/schema-lock/`.

---

## [0.5.1] — 2026-05-13

### Dodano
- **Testy jednostkowe** — pakiet PHPUnit 11, 58 testów, 90 asercji, ~130 ms:
  - [tests/Models/](../tests/Models/) — `ColumnTest`, `IndexTest`, `TableModelTest` (warstwa modeli)
  - [tests/Migrations/](../tests/Migrations/) — `ComponentDiscoveryTest`, `SchemaLockTest`, `TenantMigrationTest`
  - [tests/db/](../tests/db/) — `MySqlDriverTest`, `PgSqlDriverTest`, `SqliteDriverTest`
- `core/` dodane do `<source>` w `phpunit.xml` (coverage obejmuje teraz oba katalogi)
- **VS Code — workspace setup**:
  - [.vscode/extensions.json](../.vscode/extensions.json) — rekomendowane rozszerzenia (PHPUnit Test Explorer, PHP Debug, Intelephense, GitLens). Popup z propozycją instalacji przy otwarciu projektu
  - [docs/vscode.md](vscode.md) — nowy dział z opisem rozszerzeń, szybką instalacją (`code --install-extension ...`) i rolą plików w `.vscode/`
  - Konfiguracja PHPUnit Test Explorer dopisana do `.vscode/settings.json` (`phpunit.php`, `phpunit.phpunit`, `phpunit.args`, `XDEBUG_MODE=off` dla szybkości)
- `.gitignore` — wyjątek `!.vscode/extensions.json` (wersjonowany mimo zignorowanego `.vscode/`)

---

## [0.5.0] — 2026-05-13

### Dodano
- **Warstwa modeli tabel** — deklaratywne źródło prawdy o strukturze:
  - [core/Models/Column.php](../core/Models/Column.php) — fluent builder definicji kolumny. Fabryki dla `guid`, `varchar`, `char`, `text`/`mediumText`/`longText`, `int`/`bigInt`/`smallInt`/`tinyInt`, `autoInc`, `decimal`, `dateTime`/`date`, `json`, `raw`. Modyfikatory: `nullable`, `notNull`, `default`, `primaryKey`, `uniqueKey`, `indexKey`, `onUpdate`, `comment`.
  - [core/Models/Index.php](../core/Models/Index.php) — indeksy wielokolumnowe (`Index::unique('label', [...])`, `Index::index(...)`).
  - [core/Models/TableModel.php](../core/Models/TableModel.php) — abstrakcyjna baza modelu (`entity()`, `columnPrefix()`, `columns()`, opcjonalnie `indexes()`). Renderuje `createTableSql($tenantPrefix)` i `dropTableSql($tenantPrefix)`.
- Pierwsze modele:
  - [app/Appm/Models/UsersModel.php](../app/Appm/Models/UsersModel.php) — tabela `users` z prefiksem kolumn `Use`
  - [app/Cms/Models/PagesModel.php](../app/Cms/Models/PagesModel.php) — tabela `pages` z prefiksem kolumn `Pag`
- Sekcja [3.10a w docs/bazy-danych.md](bazy-danych.md) — opis warstwy modeli + cykl życia po wdrożeniu

### Zmienione
- Migracje CREATE TABLE przepisane na cienką wersję używającą modeli:
  - [app/Appm/Migrations/Version20260513130000.php](../app/Appm/Migrations/Version20260513130000.php) — `(new UsersModel())->createTableSql(...)` w `up()`, `dropTableSql(...)` w `down()`
  - [app/Cms/Migrations/Version20260513120000.php](../app/Cms/Migrations/Version20260513120000.php) — analogicznie z `PagesModel`
- Wygenerowane SQL identyczne do poprzedniej ręcznej wersji (zweryfikowane porównaniem `DESCRIBE` i `SHOW INDEX`)

### Architektura
- **Model = stan pożądany, migracja = przejście**. Edycja modelu sama nie zmienia bazy — wymaga sparowanej migracji ALTER. Świeże wdrożenie zawsze tworzy tabelę zgodnie z bieżącym modelem.
- **Każda kolumna ma osobną linię** — łatwe komentowanie (`// Column::varchar('Phone', 32)->nullable()` wyłącza kolumnę w nowych CREATE), dodawanie, modyfikacja indeksów.
- Pliki migracji CREATE redukują się do ~15 linii — cała logika nazewnictwa (prefix tenant, prefix kolumn, format nazw indeksów) żyje w `TableModel`. Pojedyncza zmiana konwencji → jedna edycja w `core/Models/`.

---

## [0.4.4] — 2026-05-13

### Zmienione
- **Komponent `pmain` przemianowany na `appm`** (skrót od "Application Main"). Nazwa lepiej oddaje funkcję — to bazowy moduł aplikacji, nie tylko panel admin
- `app/Pmain/` → `app/Appm/` (rename folderu)
- Namespace migracji: `App\Pmain\Migrations` → `App\Appm\Migrations`
- Tabela metadanych w bazie: `def_migrations_pmain` → `def_migrations_appm` (wykonane przez `RENAME TABLE`)
- Wpisy w tabeli metadanych zaktualizowane: `App\Pmain\Migrations\Version...` → `App\Appm\Migrations\Version...` (UPDATE po stringu)
- Lock-pliki: `var/schema-lock/pmain.lock*` → `appm.lock*`
- Aktualizacja dokumentacji ([docs/bazy-danych.md](bazy-danych.md), [docs/changelog-db.md](changelog-db.md), [docs/prompt/migracja-tabeli.md](prompt/migracja-tabeli.md))

### Migracja istniejących wdrożeń
Jeśli ktoś już wdrożył wersję 0.4.2/0.4.3 z `pmain`:
```sql
RENAME TABLE def_migrations_pmain TO def_migrations_appm;
UPDATE def_migrations_appm
SET version = REPLACE(version, 'App\\Pmain\\', 'App\\Appm\\')
WHERE version LIKE 'App\\Pmain\\%';
```
Plus rename folderu `app/Pmain` → `app/Appm` i lock-plików w `var/schema-lock/`.

---

## [0.4.3] — 2026-05-13

### Dodano
- **Konwencja nazewnictwa tabel i kolumn** — wymuszona przez infrastrukturę migratora:
  - `core/Migrations/TenantMigration.php` — bazowa klasa migracji świadoma prefiksu tenant; udostępnia `$this->table('users')` zwracające `<prefix>_users`
  - `core/Migrations/TenantMigrationFactory.php` — niestandardowy `Doctrine\Migrations\Version\MigrationFactory` wstrzykujący prefix z configu do każdej instancji migracji
  - Konfiguracja `tenant.prefix` w `configs/_default.php` (`'def'`) i `configs/klient1.local.php` (`'kl1'`) — prefix jednoznacznie identyfikuje tenanta (aplikację/domenę)
- Konwencja kolumn bazowych dla każdej tabeli:
  - `<C>ID` `CHAR(36) NOT NULL` `PRIMARY KEY` — GUID generowany w warstwie aplikacji
  - `<C>DateTime` `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP`
  - `<C>IDAuto` `INT UNSIGNED AUTO_INCREMENT` `UNIQUE KEY` — kompaktowy identyfikator porządkowy
  - Prefix kolumnowy `<C>` — 3–5 znaków, PascalCase, derywowany od logicznej nazwy encji (`Use` / `Pag` / `Ord`)
- Sekcja [3.11 w docs/bazy-danych.md](bazy-danych.md) — pełen opis konwencji z przykładami i regułami indeksów (`uniq_<table>_<purpose>`, `idx_`, `fk_`)

### Zmienione
- `core/Migrations/MigratorFactory.php` — czyta `tenant.prefix`, prefixuje nazwę tabeli metadanych (`def_migrations_pmain` zamiast `migrations_pmain`), rejestruje `TenantMigrationFactory` w `DependencyFactory`
- `app/Cms/Migrations/Version20260513120000.php` — przepisana: tabela `pages` → `<prefix>_pages` z kolumnami `Pag*` (`PagID`, `PagDateTime`, `PagIDAuto`, `PagSlug`, `PagTitle`, `PagBody`)
- `app/Pmain/Migrations/Version20260513130000.php` — przepisana: tabela `admin_users` → `<prefix>_users` z kolumnami `Use*` (`UseID`, `UseDateTime`, `UseIDAuto`, `UseLogin`, `UsePassword`, `UseEmail`, `UseIsActive`, `UseLastLogin`)

### Architektura
- **Prefix = tenant, nie komponent** — jedna domena/aplikacja = jeden prefix; pmain, cms, shop u tego samego klienta dzielą prefix `def_`. Pozwala to umieścić wielu klientów w jednej fizycznej bazie bez kolizji nazw.
- **Migracje sztywno typowane wg konwencji** — autorzy nie piszą `users` ani `<prefix>_users` ręcznie, tylko `$this->table('users')`. Brak hardcodowanych prefiksów w plikach migracji = prefix można zmienić per środowisko bez przepisywania migracji.

---

## [0.4.2] — 2026-05-13

### Dodano
- `app/Pmain/Migrations/` — komponent **pmain** (skrót od "Panel admin"), **bazowy moduł** każdego projektu opartego o ten silnik
  - Niezależny od CMS / shop / innych komponentów domenowych — projekty czysto aplikacyjne (np. SaaS, narzędzie wewnętrzne) korzystają z pmain bez konieczności włączania CMS-a
  - Wykrywany standardowo przez `ComponentDiscovery`, własna tabela śledząca `migrations_pmain`
- Pierwsza migracja: `Version20260513130000` — tabela `admin_users` (login, hasło, e-mail, flaga aktywności, znaczniki czasu)
  - Fundament autentykacji panelu — docelowe miejsce do podpięcia loginu zamiast `admin_password` z configu

### Architektura
- **pmain = baza wspólna** dla wszystkich projektów; cms / shop / kolejne komponenty są **opcjonalnymi nadbudowami**
- Brak hard-couplingu — komponenty nie odwołują się do tabel pmain bezpośrednio w schemacie (`FOREIGN KEY` cross-component dodawane świadomie i tylko gdy oba komponenty współdzielą bazę)

---

## [0.4.1] — 2026-05-13

### Zmienione
- `admin/index.php` przebudowane na panel diagnostyczny:
  - `MigrationRunner::runPending()` wywoływany przy **każdym** wejściu na panel, gdy admin jest zalogowany (nie tylko bezpośrednio po loginie). Lock-pliki utrzymują koszt na poziomie jednego `glob()` + `file_get_contents()` per komponent
  - Sekcja "Połączenie z bazą" — status PDO, wersja MySQL, lista tabel w bazie
  - Sekcja "Komponenty" — tabela z komponentami wykrytymi przez `ComponentDiscovery` (slug, namespace, tabela śledząca, klucz DB, obecność lock-pliku, liczba plików migracji)
  - Sekcja "Raport migracji" — status per komponent + bufor outputu Doctrine
  - Przycisk "Wymuś migrację" — kasuje lock-pliki i odpala runner od nowa
  - `display_errors` + `error_reporting(E_ALL)` przy `debug=true` w configu

### Dodano
- `docs/changelog-db.md` — osobny dziennik zmian dotyczących wyłącznie struktur baz danych (migracje per komponent)

---

## [0.4.0] — 2026-05-13

### Dodano
- `core/Migrations/` — warstwa migracji oparta o `doctrine/migrations` 3.x
  - `Component` — DTO opisujący komponent (slug, namespace, katalog, tabela śledząca, klucz DB)
  - `ComponentDiscovery` — auto-skan `app/*/Migrations/`, brak centralnego rejestru
  - `DbalConnectionFactory` — most między configiem PDO a `Doctrine\DBAL\Connection`
  - `MigratorFactory` — buduje `DependencyFactory` per komponent (osobna tabela `migrations_<slug>`, osobny namespace)
  - `SchemaLock` — fingerprint nazw plików migracji + `flock` w `var/schema-lock/<slug>.lock`
  - `MigrationRunner` — `runPending()` iteruje komponenty, pomija up-to-date, wykonuje `migrations:migrate` programowo
- `bin/migrate` — CLI: `php bin/migrate <komponent> <komenda-doctrine>`, wsparcie `HTTP_HOST=...` dla multi-tenant
- `app/Cms/Migrations/Version20260513120000.php` — przykładowa migracja CMS (tabela `pages`)
- `app/Shop/Migrations/` — pusty katalog drugiego komponentu
- `admin/index.php` — stub panelu z formularzem logowania; po sukcesie wywołuje `MigrationRunner::runPending()` i renderuje raport per komponent
- `var/schema-lock/` — katalog na lock-pliki (w `.gitignore`, per-środowisko)
- Mapping PSR-4 `Core\\ → core/` w `composer.json`
- `vendor/autoload.php` wpięty w `index.php` (frontend) i nowe entrypointy

### Architektura
- **Niezależne komponenty** — każdy w `app/<Komponent>/Migrations/`, własna tabela śledząca, opcjonalna osobna baza przez `app/<Komponent>/component.php`
- **Trigger** — migrator startuje tylko przy logowaniu do panelu admin oraz z CLI. Frontend nie dotyka migratora, Doctrine ładowane leniwie
- **Wydajność** — fingerprint (xxh3 nazw plików) w lock-pliku eliminuje zapytania SQL przy zgodnym stanie. Po pierwszym loginie po deployu kolejne wymagają: jeden `glob()` + jeden `file_get_contents()` per komponent
- **Migracje pisane ręcznie** — czysty SQL przez `$this->addSql(...)`. ORM dostępny w composerze, ale nie wymagany
- **Dodanie komponentu** = utworzenie folderu `app/<Nazwa>/Migrations/` (zero zmian w configu)

---

## [0.3.0] — 2026-05-13

### Dodano
- `core/Connection.php` — singleton PDO z lazy initialization
- `core/db/Driver.php` — abstrakcyjna klasa bazowa driverów (DSN + wspólne opcje PDO)
- `core/db/MySqlDriver.php` — DSN dla MySQL (host, port, dbname, charset)
- `core/db/PgSqlDriver.php` — DSN dla PostgreSQL
- `core/db/SqliteDriver.php` — DSN dla SQLite (`:memory:`, ścieżki absolutne, ścieżki względne rozwijane od `ROOT`)
- `spl_autoload_register` w `index.php` dla katalogu `core/db/` — ładowanie driverów on-demand

### Architektura
- Wybór silnika przez `Config::get('db')['driver']` (`mysql` / `pgsql` / `sqlite`)
- Rejestr driverów w `Connection::DRIVERS` — dodanie nowej bazy sprowadza się do nowego pliku w `core/db/` + jednego wpisu w rejestrze; `index.php` nie wymaga zmian
- Pliki driverów ładowane dopiero przy `new $driverClass()` — nieużywane silniki (np. PgSql/Sqlite przy konfiguracji MySQL) nie trafiają do PHP
- `username` / `password` w configu są opcjonalne — wymagane tylko tam, gdzie driver ich faktycznie używa

---

## [0.2.0] — 2026-05-12

### Dodano
- Multi-tenant architektura — jeden silnik CMS obsługuje wiele domen
- Wykrywanie domeny przez `$_SERVER['HTTP_HOST']`
- `core/Config.php` — dynamiczny loader konfiguracji z `array_replace_recursive`
- `configs/_default.php` — domyślne wartości konfiguracji
- `configs/klient1.local.php` — przykładowa konfiguracja per-domena
- `.htaccess` — routing przez `index.php` + blokada folderów systemowych
- `index.php` w root projektu (kompatybilność z hostingiem współdzielonym)

### Architektura
- Jeden VirtualHost Apache (`ServerAlias *.local`) obsługuje wszystkie lokalne domeny
- Każda domena ładuje własną konfigurację (baza danych, theme, język)
- Wrażliwe foldery (`core/`, `configs/`) zablokowane przez `.htaccess`

---

## [0.1.0] — inicjalizacja projektu

### Dodano
- Inicjalizacja repozytorium
