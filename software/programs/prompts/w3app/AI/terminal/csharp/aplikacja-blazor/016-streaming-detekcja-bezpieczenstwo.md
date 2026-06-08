# 016 — Streaming, detekcja patologii, bezpieczeństwo

## Rola
Inżynier wykończenia. Dodaj **streaming** odpowiedzi, **detektory patologii** modelu oraz
zabezpieczenia. Ostatni wątek — domyka jakość Terminala.

## A. Streaming odpowiedzi (eksperymentalny, gated)
- Tryb: tylko **Ollama + czysty czat** (Internet=Off, brak workdir/pomocnika/obrazów). W innym
  przypadku UI cicho wraca do zwykłej (nie-streamingowej) wysyłki. Przełącznik „Stream" w UI (014), domyślnie OFF.
- Provider (004): `ChatStreamAsync` → wywołanie Ollamy z `stream:true` (NDJSON, jeden obiekt/linia
  z przyrostem `message.content`); parsuj chunki i yielduj fragmenty tekstu (`IAsyncEnumerable<string>`).
- `ToolLoopRunner.RunStreamAsync` → `IAsyncEnumerable<StreamEvent>` (`Delta`/`Done`/`Error`).
- **Blazor**: konsumuj strumień w komponencie, dopisuj tokeny do bańki na żywo (`await foreach` +
  `InvokeAsync(StateHasChanged)`); na końcu re-renderuj pełną treść jako markdown. Zapisz finalną
  odpowiedź do `ConsoleMessage` jak zwykle.
- `num_ctx`/`keep_alive` spójne z wątkiem 004 (ten sam model jako main/helper nie może mieć różnego num_ctx).
- Uwaga: per-delta nie nakładaj `CleanContent` (special tokeny mogą przeciąć granicę chunku) —
  czyść dopiero pełną treść przed zapisem.

## B. Detektory patologii (uruchamiane na finalnej odpowiedzi w 008)
- **FakeActionDetector** — model twierdzi że zapisał/utworzył plik (czasowniki „zaktualizowałem/
  naprawiłem/utworzyłem/updated/created/fixed…"), ALE w tej turze WSZYSTKIE mutujące tool-calle
  (`write_file`/`find_and_replace`/`apply_diff`/`save_file`) zakończyły się błędem (lub nie było
  żadnego). Pomiń gdy użyto delegacji (`ask_helper`/`decompose_and_execute` — pliki pisze sub-pętla).
  → flaga + w UI alert „Fałszywa akcja" z przyciskami „Ponów" / „Pomocnik".
- **HallucinatedOutputDetector** — odpowiedź zawiera markery wyniku komendy (`[SUKCES (exit N)]`,
  `[NIEPOWODZENIE (exit N)]`, `$ cmd — STATUS`) ALE nie było realnego `run_command`; albo udaje
  wynik `ask_helper`/`decompose` bez realnego wywołania. → flaga + alert „Prawdopodobna halucynacja".
- **TutorModeDetector** — model dał wykład/porady dla człowieka („upewnij się że…", „sprawdź czy…",
  „należy…", „you should…") zamiast użyć narzędzi, mimo że je miał i nie wywołał żadnego mutującego.
  → flaga + podpowiedź „przełącz na większy model".

## C. Bezpieczeństwo
- **Anty-SSRF** w `fetch_url`/SearxNG/Ollama URL: blokuj adresy lokalne/prywatne tam gdzie to
  niepożądane (uwaga: Ollama bywa `localhost` — to dozwolony wyjątek konfigurowany przez usera).
- **Path traversal**: egzekwowane w narzędziach plikowych (009).
- **Sekrety**: klucze API maskowane w UI i NIE logowane w pełnej postaci (loguj prefiks + ostatnie 4 znaki).
- **CSRF/auth**: w Blazor Server interakcje idą przez SignalR (circuit) — nie ma klasycznego CSRF
  formularzy; jeśli wystawisz dodatkowe HTTP API, zabezpiecz antiforgery. Aplikacja lokalna —
  rozważ binding tylko na `localhost`.
- **Limity**: obrazy 4×5 MB; `read_file` 512 KB; `write_file` 1 MB; `save_file` 256 KB; `list_dir` 500.

## Kryteria akceptacji
- [ ] Streaming działa dla Ollama w trybie czatu i jest domyślnie wyłączony; reszta przypadków → zwykła wysyłka.
- [ ] Trzy detektory ustawiają flagi i UI pokazuje odpowiednie ostrzeżenia (z akcjami „Ponów"/„Pomocnik").
- [ ] Klucze API nie wyciekają do logów; ścieżki/SSRF zabezpieczone; limity egzekwowane.
- [ ] Aplikacja stabilna przy długich turach i anulowaniu.

## Koniec serii Blazor
Masz komplet: architektura → baza → modele → providerzy → Integracje AI (formularze) →
silnik narzędzi → narzędzia → delegacja → profile → czat → modale → streaming/detekcja.
Wersja Windows Forms tej samej funkcjonalności: [`../aplikacja-windows-forms/`](../aplikacja-windows-forms/).
