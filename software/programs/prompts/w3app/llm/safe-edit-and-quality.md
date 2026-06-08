# Safer editing + agent quality-of-life (0.7.28)

> Pakiet zmian wprowadzony 2026-05-31 — analogie z Aider, Cline, Continue, Cursor.

## Pakiet A — Safer edits

### `find_and_replace` tool

Atomic find/replace dla **małych targeted zmian**. Bezpieczniejsze niż `write_file`:
operuje na fragmencie, nie nadpisuje całego pliku.

```json
{
  "name": "find_and_replace",
  "arguments": {
    "path": "Forms/MainForm.cs",
    "find": "public class MainForm : Form\n{",
    "replace": "public partial class MainForm : Form\n{",
    "count_expected": 1
  }
}
```

**Reguły:**
- `find` block musi pasować **EXACTLY** (whitespace, indentation, line endings)
- `count_expected` jest hard check — jeśli faktyczna liczba ≠ oczekiwana → REJECT
  z hintem „dodaj kontekst dla unikalności"
- 0 occurrences → ERROR + „Did you mean?" hint (similar_text na pierwszej linii find)
- Po sukcesie: backup snapshot + syntax check + post-write hint (build + test)

### `apply_diff` tool

Stosuje unified-diff. Mniejsze tokeny output dla małych zmian.

```json
{
  "name": "apply_diff",
  "arguments": {
    "path": "src/Helper.cs",
    "diff": "--- a/src/Helper.cs\n+++ b/src/Helper.cs\n@@ line 15 @@\n-    var x = 1;\n+    var x = 42;\n     return x * 2;\n"
  }
}
```

**Reguły:**
- Format: `---`/`+++`/`@@`/`-`/`+`/` ` (space = context)
- Hunk's old-block (`-` + context) musi pasować exact w pliku
- Ambiguous hunk (same old-block w wielu miejscach) → REJECT
- Multi-hunk OK

### Live diff w UI

Po `write_file`/`find_and_replace`/`apply_diff` wynik renderowany w bańce z
kolorowaniem:
- 🟢 linie `+` → zielone tło
- 🔴 linie `-` → czerwone tło
- 🟣 nagłówki `@@` → fioletowe
- ⚪ summary lines (`File overwritten`, `find_and_replace OK`, `BUILD_STRUCTURED`,
  `NEXT-STEP HINT`, `WARNING`, `META-HINT`) → bold

Dla `find_and_replace` dodatkowo widget grid „FIND ↔ REPLACE" z dwoma blokami
side-by-side (responsive — vertical na mobile).

## Pakiet B — Feedback loop

### Auto-test discovery

Po edycji pliku źródłowego (`.cs`/`.ts`/`.js`/`.py`/`.go`), system szuka
powiązanych testów i dorzuca `TEST HINT` do wyniku z gotową komendą:

| Plik źródłowy | Szukane testy | Komenda |
|---|---|---|
| `Calculator.cs` | `CalculatorTests.cs`, `Calculator.Tests.cs`, `TestCalculator.cs` | `dotnet test --no-build --filter "FullyQualifiedName~Calculator"` |
| `parser.ts` | `parser.test.ts`, `parser.spec.ts`, `__tests__/parser.*` | `npm test -- --testPathPattern=parser` |
| `auth.py` | `test_auth.py`, `auth_test.py`, `tests/test_auth.py` | `python -m pytest -k auth` |
| `handler.go` | `handler_test.go` | `go test -run handler ./...` |

Skanowane rekursywnie (max 5000 plików, skip `node_modules`/`.git`/`bin`/`obj`/
`vendor`/`.venv`).

## Pakiet C — Quality-of-life

### C1: Approval policies

Operator może w sesji ustawić „auto-approve pattern przez TTL". Wpinane w
`run_command` przed prośbą o zgodę.

```php
aqAddPolicy('dotnet build', 600);        // 10 min
aqAddPolicy('/^git (status|diff)/', 300); // regex, 5 min
```

Matching:
- Pattern bez `/.../` → prefix match (case-insensitive)
- Pattern w `/.../` → regex

Endpoint AJAX: `console_ai_add_policy`, `console_ai_clear_policies`.

### C2: Token budget per turn

Domyślnie:
- **soft warn** @ 50 000 tok → hint w odpowiedzi
- **hard stop** @ 200 000 tok → przerwanie pętli z `BUDGET_EXHAUSTED` error

Reset na początku każdej tury (wołane z `wvResetTurnContext`). Override przez
`aqSetBudget($warn, $stop)`.

```
Status after 30k:  ok
Status after 60k:  warn
Status after 210k: stop → loop returns BUDGET_EXHAUSTED
```

### C3: Project memory (CLAUDE.md RAG)

System automatycznie czyta z workdira (priorytetem):
1. `CLAUDE.md` / `Claude.md`
2. `AGENT.md` / `AGENTS.md`
3. `.cursorrules` (Cursor)
4. `.windsurfrules` (Windsurf)
5. `.github/copilot-instructions.md`

Pierwsze 2 znalezione (max 8 KB każde) trafia do system prompta jako
`=== PROJECT INSTRUCTIONS ===` sekcja. Model widzi konwencje projektu bez
konfiguracji.

Przykład CLAUDE.md:
```md
# Project rules
- Never touch vendor/
- Use 4-space indent
- All commit messages in English
- Run `dotnet test` after any .cs change
```

### C4: Cost meter

Chip w toolbarze pokazujący tokeny in/out + szacunkowy koszt USD per sesja.
Pricing per 1M tok:

| Provider/Model | Input | Output |
|---|---|---|
| claude-opus | $15 | $75 |
| claude-sonnet | $3 | $15 |
| claude-haiku | $0.80 | $4 |
| groq (llama-70b) | $0.59 | $0.79 |
| gemini-pro | $1.25 | $5 |
| gemini-flash | $0.075 | $0.30 |
| ollama, github_models | $0 | $0 |

Polling co 8s, kolorowy chip:
- szary `<$0.10`
- żółty `$0.10–$1.00`
- czerwony `>$1.00`

Endpoint: `console_ai_cost_meter`.

## Diagram przepływu

```
User: "fix CS0246 in MainForm.cs"
   │
   ▼
[wvResetTurnContext → reset turn ctx + budget + failure cluster]
[Build system prompt + project memory (CLAUDE.md)]
[modelProfileGet → DS-Coder tail + tools-text-format if DS]
   │
   ▼
tcRunToolLoop (max_iter=16 if run_command else 8)
   ├── tcChatTurnWithTools → res
   ├── aggregate usage; aqRecordTokens + aqRecordCost
   ├── if budget=stop → return BUDGET_EXHAUSTED
   ├── parse tool calls (Format A/B/C/D + JSON repair)
   ├── for each tool call:
   │   ├── erSanitizeArgs (strip fences, normalize path)
   │   ├── erValidateAgainstSchema (block missing required)
   │   ├── tcExecuteTool (with workspace tools incl. find_and_replace, apply_diff)
   │   │   └── if run_command: aqMatchesPolicy → auto-run? OR queue for operator
   │   ├── if ERROR: erAutoRetry (1 shot); erEnhanceError; erTrackFailure → meta-hint
   │   └── if write/replace/diff: csharpPostProcessBuildResult, tdPostWriteTestHint
   └── continue or final return
   │
   ▼
UI: live diff in bubble + cost meter update + chip warnings (hallucination/tutor)
```

## Pliki

- `helpers/safe_edit.php` — find_and_replace + apply_diff
- `helpers/test_discovery.php` — auto-test discovery
- `helpers/agent_quality.php` — policies + budget + memory + cost
- `helpers/csharp_build.php` — C# build parser (0.7.25)
- `helpers/write_verify.php` — write_file safety net (0.7.26)
- `helpers/error_recovery.php` — error correction (0.7.27)
- `models/deepseek_coder.php` — DS profile (0.7.25)
- `models/qwen_coder.php` — qwen profile (0.7.25)
