# Aplikacja Windows Forms — indeks promptów

Odtworzenie „Integracje AI" + „Terminal" jako **Windows Forms (.NET 8)** na **SQLite**
(`Microsoft.Data.Sqlite`, warstwa repozytoriów). Realizuj wątki po kolei.

## Kolejność wątków

| # | Plik | Temat |
|---|------|-------|
| 001 | [001-architektura.md](001-architektura.md) | Architektura, projekty, wzorzec MVP/usługi, struktura folderów |
| 002 | [002-baza-danych-sqlite.md](002-baza-danych-sqlite.md) | Schemat SQLite (Microsoft.Data.Sqlite), tabele, inicjalizacja, seed |
| 003 | [003-modele-domenowe.md](003-modele-domenowe.md) | Modele domenowe, enumy, DTO, kontrakty wiadomości i narzędzi |
| 004 | [004-warstwa-providerow-ai.md](004-warstwa-providerow-ai.md) | Abstrakcja `IAiProvider` + klienci HTTP wszystkich providerów |
| 005 | [005-form-integracje-ai-llm.md](005-form-integracje-ai-llm.md) | Zakładki konfiguracji LLM (Claude/Ollama/Groq/Gemini/GitHub/OpenRouter) + test |
| 006 | [006-form-integracje-ai-wyszukiwarki.md](006-form-integracje-ai-wyszukiwarki.md) | Zakładki wyszukiwarek (Brave/Tavily/SearxNG/ScrapeGraph) + search chain |
| 007 | [007-form-prompt-snippets.md](007-form-prompt-snippets.md) | Biblioteka wstawek promptu (CRUD, grupy, sortowanie) |
| 008 | [008-silnik-petli-narzedzi.md](008-silnik-petli-narzedzi.md) | `ToolLoopRunner` — wieloturowa pętla, fallback, kompakcja kontekstu |
| 009 | [009-narzedzia-plikowe-workspace.md](009-narzedzia-plikowe-workspace.md) | Folder roboczy + narzędzia plikowe + bezpieczeństwo ścieżek + weryfikacja zapisu |
| 010 | [010-narzedzie-komend.md](010-narzedzie-komend.md) | `run_command` + zgoda operatora + mapowanie powłoki |
| 011 | [011-narzedzia-web-rag.md](011-narzedzia-web-rag.md) | `web_search` (chain), `fetch_url`, `save_file`, auto-RAG |
| 012 | [012-delegacja-helper.md](012-delegacja-helper.md) | `ask_helper`, `decompose_and_execute`, lista pomocników, failover, tryby |
| 013 | [013-profile-modeli.md](013-profile-modeli.md) | Profile modeli (deepseek/qwen/gemma): prompt-tail, opcje, text-emulation |
| 014 | [014-form-terminal-chat.md](014-form-terminal-chat.md) | Główny formularz czatu (composer, lista wiadomości, dropdown modeli, pasek workdir) |
| 015 | [015-okna-terminala.md](015-okna-terminala.md) | Okna dialogowe: workdir, pomocnik, profil, zgoda komendy, plan, podzadanie, kolejka, biblioteka |
| 016 | [016-streaming-detekcja-bezpieczenstwo.md](016-streaming-detekcja-bezpieczenstwo.md) | Streaming (IProgress), detekcja halucynacji/fake/tutor, loop-guard |

## Specyfika Windows Forms (trzymaj się tego we wszystkich wątkach)
- **.NET 8** (`net8.0-windows`, `UseWindowsForms=true`), `Microsoft.Data.Sqlite`.
- Warstwy: `Domain` (modele) → `Data` (repozytoria + `SqliteConnectionFactory`) →
  `Services` (providerzy AI, silnik narzędzi) → `Forms`/`Controls` (UI).
- UI **nie blokuje wątku**: operacje sieci/narzędzi przez `async/await`; aktualizacje
  kontrolek przez `Control.Invoke`/`IProgress<T>`; anulowanie przez `CancellationTokenSource`.
- Streaming = `IProgress<string>` dopisujący tokeny do `RichTextBox`/kontrolki czatu.
- Brak DI z hosta — zastosuj prosty kontener (`Microsoft.Extensions.DependencyInjection`)
  inicjalizowany w `Program.Main`, albo ręczną kompozycję w `MainForm`.
