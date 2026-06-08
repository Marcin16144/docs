# 013 — Profile modeli (dostrojenie per rodzina)

## Rola
Inżynier jakości modeli. `IModelProfile` + rejestr.

## Ważne: warstwa współdzielona
`TerminalAi.Services/Profiles` — **identyczna jak w wersji Blazor**. Zaimplementuj **dokładnie wg**
[`../aplikacja-blazor/013-profile-modeli.md`](../aplikacja-blazor/013-profile-modeli.md):
- Rejestr `Get(provider, model)` → pierwszy pasujący profil lub no-op.
- **DeepSeek-Coder**: opcje Ollama (temp ≤0.2, repeat_penalty 1.10, num_predict ≥6144, stop=special
  tokeny), `SkipNativeTools=true` (text-emulation `<function=…><parameter=…>`), prompt-tail DS1-DS11,
  CleanContent (utnij special tokeny / HTML-tutorial start).
- **Qwen3-Coder**: temp ≤0.3, num_ctx 32768, stop ChatML, MaxIterations ≈24.
- **Gemma**: num_ctx 8192.
- Punkty integracji: 004 (opcje/skip tools/clean), 008 (prompt-tail + tools-text + maxIter), 015 (modal profilu).

## Różnice/uwagi dla WinForms
- Brak różnic logicznych. Modal „Aktywny profil" (015) to okno WinForms pokazujące Id profilu +
  efektywne opcje + podgląd prompt-tail.

## Kryteria akceptacji
- [ ] Rejestr zwraca właściwy profil / no-op; DeepSeek text-emulation + clean działają.
- [ ] Qwen3/Gemma nadpisują num_ctx i sampling; nowy profil = jedna klasa `IModelProfile`.

## Następny wątek
[014-form-terminal-chat.md](014-form-terminal-chat.md)
