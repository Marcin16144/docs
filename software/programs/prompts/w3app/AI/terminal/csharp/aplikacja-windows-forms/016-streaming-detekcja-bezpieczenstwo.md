# 016 — Streaming, detekcja patologii, bezpieczeństwo (Windows Forms)

## Rola
Inżynier wykończenia. Streaming odpowiedzi + detektory patologii + bezpieczeństwo. Ostatni wątek.

## A. Streaming odpowiedzi (eksperymentalny, gated)
- Tryb: tylko **Ollama + czysty czat** (Internet=Off, brak workdir/pomocnika/obrazów). Inaczej UI
  cicho wraca do zwykłej wysyłki. `CheckBox` „Stream" (014), domyślnie OFF.
- Provider (004): `ChatStreamAsync` → Ollama `stream:true` (NDJSON), yield fragmentów tekstu.
- `ToolLoopRunner.RunStreamAsync` → `IAsyncEnumerable<StreamEvent>`.
- **WinForms**: `await foreach (var ev in runner.RunStreamAsync(req, ct))` w async handlerze;
  dopisuj `ev.Delta` do kontrolki czatu (WebView2: JS append / RichTextBox: AppendText) — jesteś na
  wątku UI po `await`, więc bezpiecznie. Na końcu re-render pełnej treści jako markdown; zapisz do
  `ConsoleMessage`. `CleanContent` tylko na pełnej treści (nie per-delta).
- `num_ctx`/`keep_alive` spójne z 004.

## B. Detektory patologii (warstwa współdzielona — wg [`../aplikacja-blazor/016-...`](../aplikacja-blazor/016-streaming-detekcja-bezpieczenstwo.md))
Uruchamiane na finalnej odpowiedzi (008), ustawiają flagi w `ToolLoopResult`; UI pokazuje alerty:
- **FakeActionDetector** — twierdzi że zapisał/utworzył plik, ale mutujące tool-calle (write_file/
  find_and_replace/apply_diff/save_file) zawiodły lub ich nie było (pomiń przy delegacji). Alert
  „Fałszywa akcja" + przyciski „Ponów" / „Pomocnik".
- **HallucinatedOutputDetector** — markery wyniku komendy (`[SUKCES (exit N)]`, `$ cmd — STATUS`) bez
  realnego `run_command`; lub udawany wynik ask_helper/decompose. Alert „Prawdopodobna halucynacja".
- **TutorModeDetector** — wykład/porady dla człowieka zamiast użycia narzędzi. Alert „za mały model".

## C. Klasyfikacja zadań w weryfikatorze decompose (POPRAW względem oryginału)
> **Bug do uniknięcia** (zaobserwowany w wersji PHP): krok „**Sprawdź wersję .NET SDK**" bywał
> klasyfikowany jako *inspekcja* (bo zawiera słowo „sprawdź") → weryfikator dawał **SUKCES** mimo że
> wykonawca nic nie uruchomił, a UI i tak pokazywał **„krok nie powiódł się"** (sprzeczność werdyktu
> ze statusem). Reguła: zadanie sprawdzenia **wersji/obecności narzędzia** (`dotnet --version`,
> `node -v`, `git --version`, „czy zainstalowane") to **KOMENDA** (wymaga `run_command`), NIE inspekcja
> plikowa. Klasyfikuj po **intencji**, nie po pojedynczym słowie „sprawdź".
- Zapewnij **spójność**: wyświetlany werdykt i flaga `IsSuccess` pochodzą z TEJ SAMEJ decyzji — jeśli
  anti-empty-success wymusza PORAŻKĘ, tekst werdyktu też musi mówić PORAŻKA (nie zostawiaj stałego „SUKCES:").
- No-op (cel już spełniony) = SUKCES tylko gdy wykonawca jawnie to stwierdził; brak akcji + brak no-op +
  zadanie wymagające komendy/zapisu = PORAŻKA.

## D. Bezpieczeństwo
- Anty-SSRF w fetch_url/SearxNG (Ollama `localhost` to dozwolony wyjątek konfigurowalny).
- Path traversal — w narzędziach plikowych (009). Sekrety: klucze maskowane w UI, nie logowane w pełni.
- Brak CSRF (aplikacja desktop). Limity: obrazy 4×5 MB; read 512 KB; write 1 MB; save_file 256 KB; list 500.

## Kryteria akceptacji
- [ ] Streaming działa dla Ollama (czat), domyślnie OFF; reszta przypadków → zwykła wysyłka.
- [ ] Trzy detektory ustawiają flagi; UI pokazuje ostrzeżenia (z akcjami).
- [ ] Weryfikator decompose poprawnie klasyfikuje „sprawdź wersję SDK" jako komendę; werdykt spójny ze statusem.
- [ ] Klucze nie wyciekają; ścieżki/SSRF zabezpieczone; limity egzekwowane; brak zamrażania UI.

## Koniec serii Windows Forms
Komplet: architektura → baza → modele → providerzy → Integracje AI → silnik → narzędzia → delegacja →
profile → czat → okna → streaming/detekcja. Wersja Blazor Server: [`../aplikacja-blazor/`](../aplikacja-blazor/).
