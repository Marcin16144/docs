# 015 — Modale Terminala

## Rola
Programista Blazor. Zbuduj komplet **modali** wspierających główny ekran czatu (014). Każdy modal
to osobny komponent; podawaj je etapami.

## Modale do zbudowania

### 1. Folder roboczy (`WorkdirModal`)
- Wybór katalogu na dysku serwera + tryb (odczyt / odczyt+zapis). Serwerowa **przeglądarka katalogów**
  (lista podfolderów, wejdź/wyjdź, „w górę"). Zapis do `ConsolePrefs.Workdir`. Walidacja istnienia
  i zapisywalności (test plik). Po ustawieniu — pokaż status git jeśli `.git` istnieje.

### 2. Pomocnik (`HelperModal`)
- Konfiguracja **listy modeli pomocniczych** (`ConsoleHelperList`): dodaj/usuń/sortuj, provider+model
  (+ OllId dla Ollamy), aktywność. Wybór trybu współpracy (Off/Auto/Parallel/Delegate/Split).
  Ostrzeżenie gdy główny i pomocnik to ta sama instancja Ollamy (kolizja VRAM/reload).

### 3. Aktywny profil (`ProfileModal`)
- Pokaż wykryty profil modelu głównego i pomocnika (z 013): `Id`, efektywne opcje generacji
  (temperature/top_p/num_ctx/num_predict/stop), podgląd `PromptTail` (pierwsze ~600 znaków). Read-only.

### 4. Zgoda na komendę (`CommandApprovalModal`)
- Pokaż propozycję `run_command` (komenda + cel), przyciski „Uruchom" / „Uruchom i pozwól w sesji"
  (dodaje program do cmd_allow) / „Odrzuć". Wyróżnij komendy destrukcyjne (czerwone). Po decyzji
  wywołaj serwis zatwierdzenia (kontrakt z 010), wynik dopisz do rozmowy.

### 5. Decyzja planu (`PlanDecisionModal`)
- Po porażce podzadania w `decompose_and_execute` (gdy `stop_on_failure`): pokaż werdykt porażki,
  zapytaj „kontynuować plan od następnego kroku (oznaczając ten jako PORAŻKA)" / „zatrzymać".
  Komunikacja przez `ConsoleProgress.Json` (pole oczekiwania na decyzję) albo bezpośredni callback.

### 6. Podgląd/edycja podzadania (`SubtaskModal`)
- Podgląd kroków decompose na żywo (status, retry); możliwość edycji promptu kroku „w locie"
  i pauzy/wznowienia planu (side-channel sterowania w `ConsoleProgress.Json`).

### 7. Biblioteka promptów (`PromptLibraryModal`)
- Lista aktywnych wstawek (z 007) z filtrem (nazwa/grupa), klik = **doklej** do pola wiadomości
  (stos doklejonych prefixów z możliwością cofnięcia pojedynczo / wyczyść wszystko). „Wstaw i zamknij".

### 8. Kolejka wątków (`BatchQueueModal`)
- „Rozbij prompt na wątki": podziel tekst (po nagłówkach / punktach / akapitach) na listę zadań
  (`ConsoleBatchItem`), edytuj/sortuj/usuń, „Uruchom kolejkę" — wykonuje zadania po kolei jako
  osobne wiadomości; modal porażki wątku (stop/retry/continue). Status per element (pending/running/
  done/failed/skipped) trwały w bazie.

### 9. Tryb pracy (`WorkModeModal`)
- Wybór trybu interaktywny vs automatyczny (AUTO ogranicza pytania o zgodę komend — destrukcyjne nadal pytają).
  Zapis do `ConsolePrefs.AutoMode`.

### 10. Potwierdzenia (`ConfirmModal`)
- Wyczyść rozmowę / wyczyść composer / wyczyść kolejkę — zastępują natywne `confirm()`.

## Wymagania
- Modale jako komponenty wielokrotnego użytku (parametry + EventCallback wyników).
- Stan modali nie blokuje czatu; operacje async.
- Spójny wygląd (Bootstrap modal) z resztą aplikacji.

## Kryteria akceptacji
- [ ] Wszystkie 10 modali działa i integruje się z ekranem czatu (014).
- [ ] Workdir picker zmienia folder i tryb; zgoda komend wykonuje propozycje; biblioteka wstawia snippety.
- [ ] Decompose: modale planu/podzadania pozwalają sterować wykonaniem (kontynuuj/stop/edytuj/pauza).
- [ ] Kolejka wątków wykonuje zadania po kolei z trwałym statusem.

## Następny wątek
[016-streaming-detekcja-bezpieczenstwo.md](016-streaming-detekcja-bezpieczenstwo.md)
