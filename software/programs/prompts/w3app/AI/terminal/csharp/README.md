# Odtworzenie „Integracje AI" + „Terminal (Console AI)" jako aplikacja C#

Ten katalog zawiera **prompty rekonstrukcyjne** — zestaw ponumerowanych instrukcji, które
podajesz modelowi AI (lub realizujesz ręcznie) etapami, aby odtworzyć dwa podsystemy
istniejącego panelu PHP (`admin/pages/settings/ai/` + `admin/pages/consoleai/terminal/`)
jako natywne aplikacje .NET na bazie **SQLite**.

Powstają **dwie równoległe wersje** (każda samowystarczalna, własny podfolder):

| Podfolder | Stack | Uruchomienie |
|-----------|-------|--------------|
| [`aplikacja-blazor/`](aplikacja-blazor/) | **Blazor Server** (.NET 8, EF Core + SQLite, SignalR) | `dotnet run`, przeglądarka |
| [`aplikacja-windows-forms/`](aplikacja-windows-forms/) | **Windows Forms** (.NET 8, Microsoft.Data.Sqlite, async) | desktop `.exe` |

## Co odtwarzamy (zakres funkcjonalny)

**Integracje AI** — konfiguracja providerów LLM i wyszukiwarek:
- LLM: **Claude, Ollama** (wiele instancji), **Groq, Gemini, GitHub Models, OpenRouter**.
- Wyszukiwarki: **Brave, Tavily, SearxNG, ScrapeGraph** + konfigurowalny *search chain* (kolejność/aktywność).
- Każdy provider: klucz/URL, model, temperatura, max tokenów, system prompt, **test połączenia**, cache listy modeli.
- **Biblioteka wstawek promptu** (snippets) z grupami i kolejnością.

**Terminal (Console AI)** — agentowy czat z modelem + wykonywanie narzędzi:
- Wieloturowa **pętla narzędzi** (model → tool call → wynik → model …).
- Narzędzia: `list_dir`, `read_file`, `write_file` (+dry-run diff), `find_and_replace`, `apply_diff`,
  `run_command`, `web_search`, `fetch_url`, `save_file`, `ask_helper`, `decompose_and_execute`.
- **Folder roboczy** (workdir) z trybem odczyt / odczyt+zapis i zabezpieczeniem ścieżek.
- **Profile modeli** (deepseek-coder, qwen3-coder, gemma) — dostrojenie promptu/opcji per model.
- **Model pomocniczy** (delegacja, równolegle, podział ról, auto-router) z failoverem.
- **Streaming** odpowiedzi, detekcja halucynacji/fałszywej akcji/trybu tutora, loop-guard,
  kompakcja kontekstu, weryfikacja zapisu, kolejka wątków (batch), licznik tokenów/kosztów.

## Jak używać tych promptów

1. Wejdź do podfolderu wybranej aplikacji i otwórz jego `README.md` (indeks wątków).
2. Realizuj prompty **po kolei** (001 → 016). Każdy buduje na poprzednim i kończy się
   **kryteriami akceptacji** + wskazaniem następnego wątku.
3. Prompt podajesz modelowi razem z dotychczasowym kodem (kontekst rośnie etapami).
4. Kolejność jest celowa: najpierw **architektura**, potem **modele/baza**, potem warstwa
   providerów i silnik narzędzi, a na końcu **formularz po formularzu** (UI).

## Zasada wierności

Prompty opisują **zachowanie i kontrakty** oryginału (nazwy pól DB, parametry narzędzi,
tryby pracy) na tyle dokładnie, by odtworzyć funkcjonalność bez dostępu do kodu PHP.
Gdzie oryginał miał ograniczenie (np. limit 512 KB na `read_file`, 1 MB na `write_file`,
500 wpisów w `list_dir`) — jest ono podane wprost.

> Wersja źródłowa: panel „K2 CMS", PHP 8.2 + MySQL/MariaDB. Tu portujemy na **SQLite**
> (jedna lokalna baza `app.db`), bo aplikacje są jednostanowiskowe/desktopowe.
