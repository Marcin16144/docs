# 011 — Narzędzia sieciowe: web_search (chain), fetch_url, save_file + auto-RAG

## Rola
Inżynier narzędzi. Zaimplementuj narzędzia internetowe i mechanizm **auto-RAG** dla modeli
bez function-callingu. Dostępne gdy tryb internetu ≠ Off (`WebMode`).

## `web_search` (łańcuch providerów)
- Parametry: `query`(wymagany), `num_results`(int, def 5, max 10).
- Wykonanie: pobierz aktywne providery z `SearchChain` **w kolejności** i próbuj po kolei:
  `tavily` → `scrapegraph` → `searxng_selfhosted` → `ddg_html` → `ddg_lite` → `searxng_public` → `brave`.
  Pierwszy zwracający wyniki wygrywa. Pomijaj providery bez klucza/URL i wyłączone.
- Klienci (osobne klasy `ISearchClient`): 
  - **Tavily** (`POST /search`, klucz `tvly-`), **ScrapeGraph** (SearchScraper API, `sgai-`),
  - **SearxNG** self-hosted (`{BaseUrl}/search?format=json`) i publiczny (lista znanych instancji),
  - **DuckDuckGo** HTML i Lite (scrape, bez klucza), **Brave** (`/res/v1/web/search`, nagłówek `X-Subscription-Token`).
- Zwróć listę `{title, url, snippet}` (do `num_results`), sformatowaną dla modelu.

## `fetch_url`
- Parametr: `url`(absolutny http/https). Pobierz stronę, **odetnij HTML** → czysty tekst, zwróć
  do ~6000 znaków. **Anty-SSRF**: odrzuć adresy lokalne/prywatne (127.0.0.1, 10.x, 192.168.x,
  169.254.x, ::1, `localhost`) i schematy inne niż http(s); timeout; limit rozmiaru pobrania.

## `save_file`
- Parametry: `filename`(bez separatorów ścieżki), `content`. Zapisuje plik do pobrania w katalogu
  sesji (np. `media/console/{sessionId}/files/`). Whitelist rozszerzeń: md, txt, json, csv, xml,
  yaml, yml, html. Max 256 KB. Zwróć URL/ścieżkę do pobrania. (To NIE workspace — to artefakty czatu.)

## Auto-RAG (dla modeli bez tooli / trybu RAG)
- Gdy model nie wspiera narzędzi LUB `WebMode=Rag`: **przed** wywołaniem modelu wykryj
  zapytanie/URL w wiadomości usera, zrób `web_search`/`fetch_url` po naszej stronie i **wklej
  wynik do kontekstu** (jako dodatkowy fragment systemowy/tool-like), żeby model miał świeże dane
  bez function-callingu. Wynik ujawnij w UI jako wykonane „tool calls" (web_search/fetch_url).
- To także ścieżka **graceful fallback** z wątku 008 (gdy natywny tool-calling zawiedzie).

## Anty-placeholder
- `fetch_url` z placeholderem zamiast URL (`[URL]`, `{LINK}`, `<YOUR_URL>`) → błąd z prośbą o realny URL.

## Kryteria akceptacji
- [ ] `web_search` przechodzi łańcuch wg `SearchChain` i zwraca wyniki z pierwszego działającego providera.
- [ ] `fetch_url` zwraca czysty tekst, blokuje SSRF i nie-http(s).
- [ ] `save_file` zapisuje artefakt z whitelistą rozszerzeń i limitem 256 KB.
- [ ] Auto-RAG działa dla modelu bez tooli oraz jako fallback po błędzie tool-callingu.

## Następny wątek
[012-delegacja-helper.md](012-delegacja-helper.md)
