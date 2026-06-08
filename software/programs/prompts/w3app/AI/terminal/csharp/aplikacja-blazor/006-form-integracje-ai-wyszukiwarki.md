# 006 — Formularze wyszukiwarek + search chain

## Rola
Programista Blazor. Dodaj do „Integracje AI" zakładki **wyszukiwarek** i edytor **kolejności
łańcucha wyszukiwania** (search chain), z którego korzysta narzędzie `web_search` (wątek 011).

## Cel
Zakładki: **Brave, Tavily, SearxNG, ScrapeGraph** + zakładka **„Łańcuch wyszukiwania"**.

## Zakładki providerów wyszukiwania (proste — tylko klucz/URL + test)
- **Brave** (`ApiBrave`): `ApiKey`, test → liczba wyników. Free 2000/mc, klucz z brave.com/search/api.
- **Tavily** (`ApiTavily`): `ApiKey` (`tvly-…`), test. Zwraca oczyszczony tekst pod LLM.
- **ScrapeGraph** (`ApiScrapeGraph`): `ApiKey` (`sgai-…`), test (SearchScraper API).
- **SearxNG** (`ApiSearxng`): `BaseUrl` (np. `http://localhost:8888`), test (`GET /search?format=json`).
Każda: zapis + przycisk „Testuj" + status/data ostatniego testu + liczba zwróconych wyników.

## Zakładka „Łańcuch wyszukiwania" (kolejność + aktywność)
- Lista 7 providerów z `SearchChain` z możliwością: **przeciągnij/zmień kolejność** (SortOrder)
  i **włącz/wyłącz** (Active). Providerzy: `tavily`, `scrapegraph`, `searxng_selfhosted`,
  `ddg_html`, `ddg_lite`, `searxng_public`, `brave`.
- Zapis kolejności → `ISearchChainRepository.SaveOrderAsync`.
- Opis działania (info dla usera): `web_search` próbuje providerów po kolei (tylko aktywne),
  pierwszy z wynikami wygrywa; `ddg_*` i `searxng_public` nie wymagają klucza.

## Wymagania
- DnD kolejności w Blazor: lekki (np. natywny `draggable` + handlery) lub strzałki góra/dół.
- Walidacja URL SearxNG; klucze maskowane.
- Test każdego providera niezależnie, bez blokowania UI.

## Kryteria akceptacji
- [ ] Cztery zakładki wyszukiwarek zapisują/odczytują konfigurację i testują połączenie.
- [ ] Edytor łańcucha zmienia kolejność i aktywność; zmiany trwałe w `SearchChain`.
- [ ] Stan łańcucha jest odczytywalny przez serwis wyszukiwania (kontrakt dla wątku 011).

## Następny wątek
[007-form-prompt-snippets.md](007-form-prompt-snippets.md)
