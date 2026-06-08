# 014 — Główny formularz czatu Terminala (Windows Forms)

## Rola
Programista WinForms. Zbuduj `TerminalControl` (lub `TerminalForm`) — czat z modelem + sterowanie sesją.
Spina providerów (004), silnik (008), profile (013), historię (002).

## Cel
Działający czat: wybór modelu, pasek workdir, lista wiadomości, composer, wysyłka przez
`ToolLoopRunner`, zapis historii, licznik tokenów — bez zamrażania UI.

## Układ (kontrolki WinForms)
- **Górny panel**:
  - `ComboBox` providera/modelu — grupowany (Claude 3 modele; Ollama per instancja z `OllId` w `Tag`;
    Groq/Gemini/GitHub/OpenRouter). Źródło: cache `LastTestModels` + listy domyślne.
  - `ComboBox` trybu internetu (Off/Auto/RAG).
  - `CheckBox` „Stream" (domyślnie OFF — wątek 016).
  - Label tokenów sesji; przyciski „Nowa", „Wyczyść" (dialog), chip profilu (klik → dialog profilu).
- **Pasek workdir**: ścieżka + badge trybu (odczyt / odczyt+zapis), „Zmień" (dialog 015), „Wyłącz";
  status git (branch, ahead/behind) jeśli repo.
- **Pasek pomocnika**: `ComboBox` trybu (Off/Auto/Parallel/Delegate/Split), wybór modelu pomocnika,
  „wymuś na następną", `CheckBox` „Komendy" (włącz `run_command`).
- **Lista wiadomości**: kontrolka renderująca bańki user/assistant. Rekomendacja: **WebView2** z HTML
  (markdown→HTML: linki `[text](url)`, lokalne `/…`/pliki jako odnośnik „otwórz", nl2br, podświetlenie
  diffów) — wygodniejsze niż RichTextBox dla tool-calls i kolorowania. Alternatywa: panel z dynamicznie
  dodawanymi `MessageBubble` UserControl. W bańce asystenta: model, tokeny, rozwijane tool-calls
  (nazwa+argumenty+wynik), ostrzeżenia detekcji (016).
- **Composer**: `TextBox` multiline (Enter=wyślij, Shift+Enter=nowa linia — obsłuż `KeyDown`),
  załączanie obrazów (do 4, 5 MB, jpeg/png/gif/webp — `OpenFileDialog`, miniatury), „Wstaw prompt"
  (okno biblioteki 015), „Rozbij na wątki" (kolejka 015), przycisk wyślij ↔ stop.

## Przepływ wysyłki (async, bez blokowania UI)
1. Zapisz wiadomość usera (z obrazami) do `ConsoleMessage`.
2. Zbuduj historię (~30 ostatnich par) → `ChatMessage[]`; obrazy tylko do ostatniej.
3. Zbuduj **system prompt**: baza + sekcje zależne od WebMode/workdir/komend/helpera +
   `profile.PromptTail()` (+ `ToolsTextFormat` gdy SkipNativeTools) + reguły agentowe (gdy workdir).
4. Zbierz dostępne narzędzia wg kontekstu (workdir→file tools; komendy→run_command; web→web tools;
   delegate→ask_helper+decompose).
5. `await ToolLoopRunner.RunAsync(request, progress, cts.Token)`; `progress = new Progress<>(u => UpdateTyping(u))`
   pokazuje wskaźnik „pisze…" (faza, iteracja, model, live tool-calls/sub-taski).
6. Zapisz odpowiedź asystenta (treść/tokeny/tool-calls/błąd) do `ConsoleMessage`.
7. Dodaj bańkę odpowiedzi + flagi detekcji; tryb Parallel → też odpowiedź pomocnika; propozycje
   komend → okno zgody (015).
8. „Stop" → `cts.Cancel()`.

## Sesja i preferencje
- `SessionId` w stanie kontrolki; „Nowa" generuje nowy. Preferencje (`ConsolePrefs`): zapisuj główny
  model, model pomocnika, tryb helpera, workdir, auto-mode; odtwarzaj przy starcie.

## Wątkowość (krytyczne dla WinForms)
- Żadnych operacji sieci/narzędzi na wątku UI. `async`/`await`; aktualizacje kontrolek po `await`
  (jesteś z powrotem na wątku UI) lub przez `IProgress<T>` utworzony na wątku UI.
- Autoscroll listy na dół po dodaniu wiadomości; focus do composera po wysłaniu.

## Kryteria akceptacji
- [ ] Wybór modelu (w tym instancji Ollamy), wysyłka i odpowiedź działają.
- [ ] Pętla narzędzi end-to-end (np. read_file/write_file w workdir).
- [ ] Historia/tokeny/tool-calls/flagi widoczne; „Nowa"/„Wyczyść" działają; UI się nie zawiesza.
- [ ] Preferencje trwałe; „Stop" przerywa generowanie.

## Następny wątek
[015-okna-terminala.md](015-okna-terminala.md)
