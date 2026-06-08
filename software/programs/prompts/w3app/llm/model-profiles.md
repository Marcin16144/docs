# Model profiles — per-model tuning Console AI Terminala

> Dokumentacja architektury `admin/pages/consoleai/terminal/models/`. Wprowadzona
> w `0.7.25` (2026-05-31). Powiązane: [changelog](../changelog.md#0725--2026-05-31).

## Po co

Każdy model LLM ma własne dziwactwa — DeepSeek-Coder gada zamiast działać, qwen2.5
miesza chińskie znaki, niektóre modele wkładają tool calle w markdown fences itp.
Bez wspólnego punktu prawdy każde takie dziwactwo lądowałoby jako `if (preg_match(...))`
rozsiane po `admterminal.php`, `tools_providers.php`, `tools_executors.php`.

Profile per-model konsolidują tę wiedzę w jednym pliku per rodzina modeli.

## Struktura

```
admin/pages/consoleai/terminal/
├── models/
│   ├── _registry.php          ← dispatch (auto-glob discovery + match-first)
│   ├── deepseek_coder.php     ← DS-Coder (v1/v2, wszystkie rozmiary)
│   └── qwen_coder.php         ← qwen2.5-coder, qwen3-coder
└── helpers/
    └── csharp_build.php       ← parsowanie outputu dotnet build
```

## Kontrakt profilu

Plik `models/<id>.php` musi `return` tablicą z polami (wszystkie opcjonalne — registry
dopełnia defaultami):

```php
return [
    'id'                => 'deepseek_coder',
    'matches'           => fn(string $provider, string $model): bool => ...,
    'prompt_tail'       => fn(): string,
    'tools_text_format' => fn(array $tools): string,
    'skip_native_tools' => true|false,
    'ollama_options'    => fn(array $defaults): array,
    'clean_content'     => fn(string $text): string,
];
```

### `matches($provider, $model)`
Czy ten profil dotyczy danego (provider, model). Pierwszy match wygrywa — kolejność
zależy od glob'a w `_registry.php` (alfabetyczna).

### `prompt_tail()`
Tekst doklejany na **końcu** system prompta. Recency bias — modele lepiej trzymają się
reguł położonych blisko końca.

### `tools_text_format($tools)`
Konwersja listy narzędzi do **tekstowego** opisu w prompcie. Używane tylko gdy
`skip_native_tools = true`. Wzorzec Format A: `<function=NAME><parameter=KEY>VAL</parameter></function>`,
który już rozpoznaje parser `tcParseTextToolCalls` w `tools_lib.php`. Wzorowane na
Cline / Continue.

### `skip_native_tools`
Jeśli `true`, `tcChatOllama` pomija pole `tools` w payloadzie do Ollamy. Tool list
trafia wyłącznie w prompcie (przez `tools_text_format`). Stosowane gdy model
nieprawidłowo używa natywnego function callingu (DS-Coder zwraca w odpowiedzi JSON-raporty
zamiast tool calls).

### `ollama_options($defaults)`
Przyjmuje aktualne opcje generacji, zwraca zmodyfikowane. Może zmienić:
- `temperature`, `top_p`, `top_k`, `repeat_penalty`, `num_predict`
- `stop` — lista sekwencji STOP (tnie generację gdy się pojawi)

### `clean_content($text)`
Post-process odpowiedzi modelu PRZED zwróceniem do reszty systemu. Używane np. dla
DS — wycinanie special tokenów `<｜begin▁of▁sentence｜>` które wyciekają i powodują
training-data leak.

## Użycie

```php
$profile = modelProfileGet($provider, $model);

// Tail w system prompcie
$systemPrompt .= ($profile['prompt_tail'])();

// Text-emulation tool list
if ($profile['skip_native_tools'] && !empty($tools)) {
    $systemPrompt .= ($profile['tools_text_format'])($tools);
}

// Opcje generacji w providerze
$options = ($profile['ollama_options'])($defaults);

// Post-process odpowiedzi
$reply = ($profile['clean_content'])($rawReply);
```

## Profile dostępne (0.7.25)

### `deepseek_coder.php`
- **Match:** `/deepseek[-_]?cod(?:e|er)/i` (DS-Coder v1/v2, wszystkie rozmiary)
- **Prompt tail:** 9 reguł (DS1-DS9):
  - DS1: tool call format (no markdown fences)
  - DS2: no placeholder code (`// TODO`, `// Your existing code`, …)
  - DS3: definitive voice (no hedging)
  - DS4: language lock (no CJK)
  - DS5: no preamble narration
  - DS6: no repetition
  - DS7: anti-tutor reinforcement (read/write/run, not Ensure/Check/Make sure)
  - DS8: absolute paths → relative
  - DS9: tool call JSON key `name` not `function`
- **Text-emulation:** TAK — `skip_native_tools = true`
- **Sampling:** `temp ≤ 0.2`, `top_p 0.95`, `top_k 40`, `repeat_penalty 1.10`, `num_predict ≥ 6144`
- **Stop sequences:** `<｜begin▁of▁sentence｜>`, `<｜end▁of▁sentence｜>`, `<｜User｜>`,
  `<｜Assistant｜>`, `<｜fim▁begin｜>` + ASCII fallbacks
- **clean_content:** wycina special tokeny + ich znormalizowane warianty
  (`< | begin__of__sentence | >` itd.)

### `qwen_coder.php`
- **Match:** `/qwen[\d.]*[-_]?coder/i` (qwen2.5-coder, qwen3-coder)
- **Prompt tail:** 3 reguły (QW1-QW3): prefer structural tool calls, language lock, anti-placeholder
- **Text-emulation:** NIE (qwen dobrze radzi sobie z natywnym function calling)
- **Sampling:** `temp ≤ 0.3` (lekkie zacieśnienie)
- **clean_content:** brak (qwen nie ma znanych wycieków special tokenów)

## Dodanie nowego profilu

1. Utwórz `models/<id>.php`
2. Zwróć tablicę z `matches` (regex po nazwie modelu) i potrzebnymi callbackami
3. **Bez dotykania innych plików** — auto-discovery zadziała przy następnym request

## helpers/csharp_build.php

Funkcje pomocnicze do post-processu outputu `dotnet build` / `msbuild` / `dotnet test`.
Wpięte w dwóch miejscach:
- `tools_executors.php` `run_command` (auto-run path, gdy program na trusted list)
- `admterminal.php` `console_ai_run_command` (po zatwierdzeniu przez operatora)

Gdy komenda wygląda na build C# (`csharpLooksLikeBuildCommand`), system:
1. Parsuje błędy CS (`csharpParseCsErrors`) — strukturalna lista `[{file,line,col,severity,code,message,project}]`
2. Zlicza summary (`csharpBuildSummary`) — `{ok, errors_count, warnings_count, tail}`
3. Wykrywa typowe problemy → hinty:
   - `NU1101` / „could not be restored" → „run `dotnet restore` first"
   - `MSB3027` / „being used by another process" → „a file is locked, close IDE"
   - `NETSDK1045` → „TargetFramework mismatch — check `dotnet --list-sdks`"
   - `MSB1009` → „project file not found, pass explicit path"
   - „would create files that already exist" → „use `-o <subfolder>` or `--force`"
4. Trim hałas msbuild-a (`csharpTrimBuildOutput`) — zostawia linie z błędami + ogon 10
5. Składa `BUILD_STRUCTURED [SUCCESS/FAILURE]` raport jako prefiks tool-result

Model dostaje strukturalny raport ZAMIAST surowych 5000 linii MSBuild output — może
od razu naprawiać konkretne błędy zamiast parsować tekst.
