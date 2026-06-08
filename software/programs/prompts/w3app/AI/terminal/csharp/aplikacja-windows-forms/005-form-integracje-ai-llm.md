# 005 — Zakładki konfiguracji LLM (Windows Forms)

## Rola
Programista WinForms. Zbuduj sekcję **„Integracje AI"** jako `TabControl` z zakładkami providerów
LLM. Każda zakładka = `UserControl` (osobny etap) z zapisem do bazy i testem połączenia.

## Cel
Kontrolka/okno `AiSettingsControl` z `TabControl`: **Claude, Ollama, Groq, Gemini, GitHub Models, OpenRouter**.

## Wzorzec UI
- `AiSettingsControl` (UserControl osadzony w sekcji „Integracje AI" `MainForm`).
- Każdy provider: `Ai/ClaudeTabControl`, `Ai/OllamaTabControl`, … jako `UserControl` w `TabPage`.
- Wspólna kontrolka `Controls/ProviderTestPanel` (przycisk „Testuj", `ProgressBar`/spinner,
  Label wyniku + data ostatniego testu, kolor statusu) reużywana w każdej zakładce.
- Zapis: walidacja pól → serwis → repozytorium; po zapisie `MessageBox`/toast „Zapisano".
- **Async bez blokowania**: test/odświeżanie modeli w `async` handlerze; UI aktualizowane po `await`.

## Zakładka Claude
`ComboBox Env` (production/development), per-tryb `TextBox ApiKey` + `ComboBox Model`
(claude-opus-4-7 „najmocniejszy", claude-sonnet-4-6 „zbalansowany", claude-haiku-4-5-20251001
„najszybszy"), `NumericUpDown MaxTokens`, `TrackBar/NumericUpDown Temperature` (0-1),
`TextBox SystemPrompt` (multiline). Walidacja: prefiks `sk-ant-`. Test → pokaż zużyte tokeny.

## Zakładka Ollama (multi-instance)
- `ListView`/`DataGridView` instancji (Label, ServerUrl, DefaultModel, status) + „Dodaj"/„Usuń"/edycja.
- Formularz instancji: Label, ServerUrl (walidacja `https?://host[:port]`), DefaultModel,
  Temperature, NumPredict (-1=bez limitu), Timeout (s), NumCtx (16384), KeepAlive (`30m`), SystemPrompt.
- „Odśwież modele" → `/api/tags` → zapis do LastTestModels → zasil ComboBox modeli.
- Test instancji: `/api/version` + krótki czat (wersja + liczba modeli).

## Zakładki Groq / Gemini / GitHub / OpenRouter
Wspólny `OpenAiLikeTabControl` parametryzowany providerem: ApiKey, Model (ComboBox z cache modeli
lub lista domyślna), Temperature, MaxTokens, SystemPrompt, „Odśwież modele", „Testuj".
Gemini +ThinkingEffort; OpenRouter +SiteUrl/SiteName. Filtruj listę do chat-capable.

## Logika
1. „Zapisz" → walidacja → `IAiConfigRepository.SaveAsync`.
2. „Testuj" → `IAiProviderFactory.Get(kind).TestAsync()` → zapis `LastTest*` → odśwież panel.
3. ComboBoxy modeli z `LastTestModels` (JSON) lub fallback do listy domyślnej.

## Wymagania
- Każda zakładka samodzielna (dodawalna etapami). Klucze maskowane (`PasswordChar` lub prefiks+`••••`).
- Brak zamrażania UI (async); status testu widoczny (kolor + komunikat z providera).

## Kryteria akceptacji
- [ ] `TabControl` z 6 providerami LLM; zapis/odczyt round-trip do SQLite.
- [ ] Test połączenia działa; lista modeli ląduje w ComboBoxie.
- [ ] Ollama: wiele instancji (dodaj/usuń/edytuj), każda z NumCtx/KeepAlive.

## Następny wątek
[006-form-integracje-ai-wyszukiwarki.md](006-form-integracje-ai-wyszukiwarki.md)
