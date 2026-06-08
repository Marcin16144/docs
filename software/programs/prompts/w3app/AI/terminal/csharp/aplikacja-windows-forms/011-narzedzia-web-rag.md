# 011 — Narzędzia sieciowe: web_search, fetch_url, save_file + auto-RAG

## Rola
Inżynier narzędzi. Narzędzia internetowe + auto-RAG.

## Ważne: warstwa współdzielona
`TerminalAi.Services/Search` + web tools — **identyczne jak w wersji Blazor**. Zaimplementuj
**wg** [`../aplikacja-blazor/011-narzedzia-web-rag.md`](../aplikacja-blazor/011-narzedzia-web-rag.md):
- `web_search` (łańcuch wg `SearchChain`: tavily→scrapegraph→searxng_selfhosted→ddg_html→ddg_lite→
  searxng_public→brave; pierwszy z wynikami wygrywa), klienci per provider (`ISearchClient`).
- `fetch_url` (HTML→tekst do ~6000 zn., anty-SSRF: blokuj lokalne/prywatne IP i nie-http(s), limit/timeout).
- `save_file` (artefakt czatu: whitelist md/txt/json/csv/xml/yaml/html, max 256 KB, katalog sesji).
- Auto-RAG (model bez tooli / tryb RAG / fallback): wstrzyknięcie wyników wyszukiwania do kontekstu.

## Różnice/uwagi dla WinForms
- `HttpClient` z `IHttpClientFactory` (DI z `Program.Main`); wszystko `async` + `CancellationToken`.
- `save_file`: katalog artefaktów np. `%AppData%/TerminalAi/sessions/{sessionId}/files`; po zapisie
  zwróć ścieżkę i pozwól otworzyć w eksploratorze (link/przycisk w bańce — wątek 014).

## Kryteria akceptacji
- [ ] `web_search` przechodzi łańcuch; `fetch_url` zwraca czysty tekst i blokuje SSRF.
- [ ] `save_file` zapisuje artefakt z whitelistą/limitem; auto-RAG działa dla modelu bez tooli i jako fallback.

## Następny wątek
[012-delegacja-helper.md](012-delegacja-helper.md)
