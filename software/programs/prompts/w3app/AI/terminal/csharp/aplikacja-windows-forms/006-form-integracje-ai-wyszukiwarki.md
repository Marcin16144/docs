# 006 — Zakładki wyszukiwarek + search chain (Windows Forms)

## Rola
Programista WinForms. Dodaj zakładki **wyszukiwarek** i edytor **łańcucha wyszukiwania**.

## Cel
Zakładki: **Brave, Tavily, SearxNG, ScrapeGraph** + zakładka **„Łańcuch wyszukiwania"**.

## Zakładki providerów (klucz/URL + test)
- **Brave** (`ApiBrave`): TextBox ApiKey, „Testuj" → liczba wyników.
- **Tavily** (`ApiTavily`): ApiKey (`tvly-`).
- **ScrapeGraph** (`ApiScrapeGraph`): ApiKey (`sgai-`).
- **SearxNG** (`ApiSearxng`): TextBox BaseUrl (`http://localhost:8888`), test (`/search?format=json`).
Każda: zapis + „Testuj" + status/data + liczba wyników. Async, klucze maskowane.

## Zakładka „Łańcuch wyszukiwania"
- `DataGridView`/`ListView` 7 providerów (`tavily`, `scrapegraph`, `searxng_selfhosted`, `ddg_html`,
  `ddg_lite`, `searxng_public`, `brave`) z: kolejnością (przyciski ↑/↓ → SortOrder) i CheckBox `Active`.
- Zapis → `ISearchChainRepository.SaveOrderAsync`. Info: `web_search` próbuje aktywne po kolei,
  pierwszy z wynikami wygrywa; `ddg_*`/`searxng_public` bez klucza.

## Kryteria akceptacji
- [ ] Cztery zakładki wyszukiwarek: zapis/odczyt + test.
- [ ] Edytor łańcucha zmienia kolejność i aktywność (trwałe w `SearchChain`).
- [ ] Stan łańcucha czytelny przez serwis wyszukiwania (kontrakt dla 011).

## Następny wątek
[007-form-prompt-snippets.md](007-form-prompt-snippets.md)
