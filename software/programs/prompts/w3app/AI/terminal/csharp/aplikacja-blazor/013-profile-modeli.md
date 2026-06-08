# 013 — Profile modeli (dostrojenie per rodzina)

## Rola
Inżynier jakości modeli. Zaimplementuj `IModelProfile` + rejestr `IModelProfileRegistry` —
dostrojenie zachowania, opcji generacji i formatu narzędzi **per rodzina modeli**. To eliminuje
typowe patologie modeli lokalnych.

## Rejestr
`ModelProfileRegistry.Get(provider, model)` zwraca pierwszy pasujący profil (po `Matches`) albo
**profil domyślny** (no-op: pusty prompt-tail, natywne tools, brak override opcji, CleanContent=identyczność).

## Profile do zaimplementowania

### DeepSeek-Coder (`Matches`: regex `deepseek[-_]?cod(e|er)`)
- **Opcje Ollama**: temperature ≤ 0.2, top_p 0.95, top_k 40, repeat_penalty 1.10, num_predict ≥ 6144;
  `stop` = special tokeny DS (`<｜begin▁of▁sentence｜>`, `<｜User｜>`, `<｜Assistant｜>`, warianty `<|...|>`).
- **SkipNativeTools = true** → narzędzia opisane TEKSTOWO w system prompcie (text-emulation),
  bo DS źle używa natywnego function-callingu. Format wywołania w tekście:
  ```
  <function=NAZWA>
  <parameter=param>wartość</parameter>
  </function>
  ```
  (parser w 008 wyłuskuje to z treści; tablice/obiekty/bool jako JSON w `<parameter>`).
- **PromptTail** (reguły DS1-DS11, najwyższy priorytet): emituj tool-call jako raw JSON lub kanał
  funkcyjny, NIGDY w ```` ```json ```` fence; write_file zamiast wklejania kodu do czatu (i `.gitignore`/
  `.env`/config: read→merge→write, inaczej blind-overwrite block); definitywny ton (bez „might want to");
  ODPOWIADAJ w języku usera, ZERO chińskich znaków; ZERO HTML na starcie odpowiedzi; bez preambuły/
  powtórzeń; anti-tutor („fix X" = read+write+verify, nie wykład); ścieżki względne; `decompose_and_execute`
  WOŁAJ jako narzędzie (nie wypisuj planu jako JSON tekstem; `sub_tasks` = tablica stringów);
  `run_command` OBOWIĄZKOWE dla zadań wykonania (git/dotnet/npm/build/test/„zrób to") — bez fabrykowania outputu.
- **CleanContent**: utnij od pierwszego special tokenu DS (training-data leak); jeśli odpowiedź
  zaczyna się od `<div style=...>`/`<div class=...>` (tutorial HTML artefact) — wyzeruj (loop wymusi retry).

### Qwen3-Coder (`Matches`: `qwen[-_]?3.*coder`)
- Opcje: temperature ≤ 0.3, top_p 0.8, top_k 40, repeat_penalty 1.05, num_predict ≥ 8192,
  **num_ctx 32768** (długa eksploracja agentowa), `stop` = ChatML (`<|im_end|>`, `<|endoftext|>`).
- `MaxIterations` podniesione (np. 24). Natywne tools OK (SkipNativeTools=false).

### Gemma (`Matches`: `gemma`)
- Opcje: **num_ctx 8192**, sensowne sampling defaults. (Gemma ma mniejsze okno.)

## Punkty integracji (gdzie profil jest używany)
- **004 (providerzy)**: `OllamaOptions(defaults)` nadpisuje `options`; `SkipNativeTools` decyduje czy
  wysłać pole `tools`; `CleanContent` czyści odpowiedź.
- **008 (pętla)**: dokleja `PromptTail()` do system promptu; gdy `SkipNativeTools` — wstrzykuje
  `ToolsTextFormat(tools)` do promptu i używa text-parsera tool-calli; honoruje `MaxIterations`/`MaxTurnSeconds`.
- **015 (UI)**: modal „Aktywny profil" pokazuje wykryty profil + efektywne opcje + podgląd prompt-tail.

## Kryteria akceptacji
- [ ] Rejestr zwraca właściwy profil po (provider, model) i no-op gdy brak dopasowania.
- [ ] DeepSeek: text-emulation tools + prompt-tail + clean special tokenów działają end-to-end.
- [ ] Qwen3/Gemma nadpisują `num_ctx` i sampling; opcje trafiają do wywołania Ollamy.
- [ ] Nowy profil dodaje się jako jedna klasa implementująca `IModelProfile` (rejestr auto-wykrywa).

## Następny wątek
[014-form-terminal-chat.md](014-form-terminal-chat.md)
