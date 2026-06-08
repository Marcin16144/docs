# 120 — Rozmowa z AI po angielsku (lokalny Ollama)

## Cel
Zakładka „Rozmowa”: konwersacja po angielsku z **lokalnym** modelem (offline,
bez kosztów, prywatnie) przez Ollama.

## Zadanie
1. **Rust** (proxy do Ollamy — omija CORS WebView). Dodaj crate
   `reqwest = { version="0.12", default-features=false, features=["json"] }`.
   Komendy:
   - `ollama_models() -> Vec<String>`: GET `http://localhost:11434/api/tags`,
     zwróć nazwy modeli;
   - `ollama_chat(model, messages) -> String`: POST `/api/chat`
     `{ model, messages, stream:false }`, zwróć `message.content`.
   Czytelny błąd, gdy serwer nie odpowiada.
2. **Frontend** `src/features/chat/ollama.ts`: `ollamaModels()`,
   `ollamaChat(model, messages)` przez `invoke`.
3. **Strona Chat**:
   - system prompt: przyjazny rozmówca/korepetytor; zawsze po angielsku, krótko,
     z pytaniem podtrzymującym; delikatne korekty „(correction: …)”;
   - lista modeli (wybór + zapis w `chat.model`), przycisk odświeżenia;
   - okno rozmowy (dymki user/assistant), pole wprowadzania (Enter wysyła);
   - **TTS**: czytanie odpowiedzi (`speak`, en-US) z możliwością wyłączenia;
   - **mikrofon**: Web Speech API `SpeechRecognition` (jeśli WebView wspiera) →
     dyktowanie po angielsku;
   - gdy brak serwera/modelu: komunikat z instrukcją `ollama serve` i
     `ollama pull llama3.2`.
4. Desktop-only (lokalny serwer).

## Kryteria akceptacji
- Po uruchomieniu Ollamy i pobraniu modelu można prowadzić rozmowę po angielsku;
  AI odpowiada i może czytać odpowiedzi głosem.
