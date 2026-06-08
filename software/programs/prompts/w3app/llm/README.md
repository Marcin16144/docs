# LLM / AI — dokumentacja techniczna

Zbiór instrukcji konfiguracji infrastruktury wspierającej moduł **Console AI**
([admin/pages/consoleai/terminal/](../../admin/pages/consoleai/terminal/))
i wspólny moduł AI w Ustawieniach
([admin/pages/settings/ai/](../../admin/pages/settings/ai/)).

## Pliki

| Plik | Opis |
|------|------|
| [subagenci.md](subagenci.md) | **Sub-agenci** — pętla plan → wykonaj → weryfikuj (`decompose_and_execute`). Architektura, polecany setup, diagnoza problemów. Stabilne od **v0.7.21**. |
| [model-profiles.md](model-profiles.md) | **Per-model profiles** — `models/<id>.php` z prompt tail, ollama options, stop sequences, clean_content. + `helpers/csharp_build.php` z parsowaniem CS-błędów. Od **v0.7.25**. |
| [write-verification.md](write-verification.md) | **Write verification** — 7 checków dla `write_file` (read-before-write, size delta, syntax, indent/EOL, backup ring, post-write build hint). Od **v0.7.26**. |
| [error-recovery.md](error-recovery.md) | **Error recovery** — 12 wzorców auto-korekcji (sanitize args, schema validation, fuzzy match „did you mean?", auto-retry, failure clustering, meta-hints, dry-run, live edit). Od **v0.7.27**. |
| [safe-edit-and-quality.md](safe-edit-and-quality.md) | **Safer editing + quality** — `find_and_replace` + `apply_diff` (Aider-style), live diff w UI, auto-test discovery, approval policies, token budget, project memory (CLAUDE.md), cost meter. Od **v0.7.28**. |
| [searxng-selfhosted.md](searxng-selfhosted.md) | Postawienie własnej instancji SearxNG (Docker) jako reliable fallback search dla Console AI |

## Kontekst

Console AI używa wielu providerów AI (Claude / Ollama / Groq) i search
(DuckDuckGo html, DuckDuckGo lite, SearxNG public, Brave Search API).
Chain wyszukiwania w [tools_executors.php → tcWebSearch()](../../admin/pages/consoleai/terminal/tools_executors.php):

```
DDG html  →  DDG lite  →  SearxNG public  →  Brave (jeśli skonfigurowano klucz)
```

Każdy provider próbuje się odpalić; pierwszy sukces wygrywa.
Dokumentacja w tym katalogu opisuje opcjonalne ulepszenia tego stack-a.
