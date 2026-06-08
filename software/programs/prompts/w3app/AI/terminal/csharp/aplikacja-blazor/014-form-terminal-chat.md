# 014 — Główny ekran czatu Terminala

## Rola
Programista Blazor. Zbuduj główny ekran `/terminal` — czat z modelem + sterowanie sesją.
To spina warstwy: providerzy (004), silnik (008), profile (013), historia (002).

## Cel
`Terminal.razor` — działający czat: wybór modelu, pasek folderu roboczego, lista wiadomości,
composer, wysyłka przez `ToolLoopRunner`, zapis historii, licznik tokenów.

## Układ (odwzoruj oryginał)
- **Pasek górny (header karty)**:
  - Dropdown **providera/modelu** — grupowany: Claude (3 modele), Ollama (per instancja, każda opcja
    niesie `OllId`), Groq, Gemini, GitHub, OpenRouter. Źródło: cache `LastTestModels` + listy domyślne (z 005).
  - Selektor **trybu internetu** (`Off`/`Auto`/`RAG`).
  - Przełącznik **„Stream"** (eksperymentalny, domyślnie OFF — wątek 016).
  - Licznik **tokenów** sesji, przyciski **„Nowa"** (nowa sesja) i **„Wyczyść"** (modal, 015).
  - Chip aktywnego **profilu modelu** (klik → modal profilu, 015).
- **Pasek folderu roboczego**: ścieżka + badge trybu (odczyt / odczyt+zapis), „Zmień" (modal, 015),
  „Wyłącz"; status git (branch, ahead/behind) jeśli to repo.
- **Pasek pomocnika**: tryb współpracy (Off/Auto/Parallel/Delegate/Split), wybór modelu pomocnika,
  „wymuś pomocnika na następną wiadomość", przełącznik „Komendy" (włącz `run_command`).
- **Lista wiadomości**: bańki user/assistant; w bańce asystenta: model, tokeny, **rozwijane tool-calls**
  (nazwa + argumenty + wynik), ostrzeżenia detekcji (016). Render treści: markdown-lite (linki
  `[text](url)`, lokalne `/…` jako download, nl2br, podświetlenie diffów).
- **Composer**: textarea (Enter=wyślij, Shift+Enter=nowa linia), załączanie obrazów (do 4, 5 MB,
  jpeg/png/gif/webp — vision), „Wstaw prompt" (modal biblioteki, 015), „Rozbij na wątki" (kolejka, 015),
  przycisk wyślij ↔ stop (abort).

## Przepływ wysyłki
1. Zapisz wiadomość usera (z obrazami) do `ConsoleMessage`.
2. Zbuduj historię (ostatnie ~30 par user/assistant) → `ChatMessage[]`; obrazy tylko do ostatniej.
3. Zbuduj **system prompt**: baza (rola asystenta w panelu) + sekcja zależna od `WebMode`/workdir/
   komend/helpera + `profile.PromptTail()` (+ `ToolsTextFormat` gdy SkipNativeTools) + reguły agentowe
   (gdy workdir). Reguły agentowe trzymaj w jednym, czytelnym miejscu (edytowalna stała) — anty-blind-
   overwrite, anty-truncation, anty-halucynacja, cmd-vs-PowerShell.
4. Zbierz dostępne narzędzia wg kontekstu (workdir → file tools; komendy → run_command; web → web tools;
   helper delegate → ask_helper + decompose).
5. `ToolLoopRunner.RunAsync(request, progress, ct)`; pokazuj `progress` jako wskaźnik „pisze…"
   (faza, iteracja, model, live tool-calls/sub-taski).
6. Zapisz odpowiedź asystenta (treść, tokeny, tool-calls JSON, błąd) do `ConsoleMessage`.
7. Pokaż bańkę odpowiedzi + flagi detekcji; w trybie Parallel pokaż też odpowiedź pomocnika;
   propozycje komend → modal zgody (015).
8. Abort: przycisk „Stop" anuluje `CancellationTokenSource`.

## Sesja i preferencje
- Sesja: identyfikator w stanie aplikacji (Blazor: per-circuit/scoped; „Nowa" generuje nowy `SessionId`).
- Preferencje (`ConsolePrefs`): zapisuj wybrany główny model, model pomocnika, tryb helpera, workdir,
  auto-mode — i odtwarzaj przy wejściu.

## Wymagania
- UI reaktywne, bez blokowania (async + `InvokeAsync(StateHasChanged)` na update progressu).
- Historia ładowana z bazy przy wejściu i po „Nowa"/„Wyczyść".
- Dostępność: Enter/Shift+Enter, focus po wysłaniu, autoscroll na dół.

## Kryteria akceptacji
- [ ] Można wybrać model (w tym konkretną instancję Ollamy), wysłać wiadomość i dostać odpowiedź.
- [ ] Pętla narzędzi działa end-to-end (np. read_file/write_file w ustawionym workdir).
- [ ] Historia, tokeny, tool-calls i flagi detekcji widoczne; „Nowa"/„Wyczyść" działają.
- [ ] Preferencje (model/helper/workdir) są trwałe między uruchomieniami.
- [ ] „Stop" przerywa generowanie.

## Następny wątek
[015-modale-terminala.md](015-modale-terminala.md)
