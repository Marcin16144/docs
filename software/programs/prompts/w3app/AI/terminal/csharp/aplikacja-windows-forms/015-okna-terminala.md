# 015 — Okna dialogowe Terminala (Windows Forms)

## Rola
Programista WinForms. Zbuduj komplet **okien dialogowych** (`Form` modalne) wspierających czat (014).
Każde okno podawaj etapami.

## Okna do zbudowania (odpowiedniki modali z wersji Blazor)

1. **WorkdirDialog** — wybór folderu (`FolderBrowserDialog` lub własna przeglądarka `TreeView`) +
   tryb (odczyt / odczyt+zapis). Walidacja istnienia/zapisywalności (test plik). Zapis `ConsolePrefs.Workdir`.
   Po ustawieniu — status git jeśli `.git`.
2. **HelperDialog** — lista pomocników (`ConsoleHelperList`): dodaj/usuń/sortuj, provider+model (+OllId),
   aktywność. Wybór trybu (Off/Auto/Parallel/Delegate/Split). Ostrzeżenie gdy główny i pomocnik to ta
   sama instancja Ollamy.
3. **ProfileDialog** — read-only: profil modelu głównego i pomocnika (Id, efektywne opcje
   temperature/top_p/num_ctx/num_predict/stop, podgląd prompt-tail).
4. **CommandApprovalDialog** — propozycja `run_command` (komenda + cel); „Uruchom" / „Uruchom i pozwól
   w sesji" (dodaje program do cmd_allow) / „Odrzuć"; destrukcyjne wyróżnione na czerwono. Po decyzji
   wykonaj (kontrakt z 010), wynik do rozmowy.
5. **PlanDecisionDialog** — po porażce kroku `decompose_and_execute` (gdy stop_on_failure): pokaż werdykt,
   „Kontynuuj plan" / „Ponów krok innym pomocnikiem" / „Przerwij"; **timeout np. 120 s → domyślnie
   przerwij** (jak w oryginale). *Patrz wątek 016: werdykt nie może być sprzeczny ze statusem kroku.*
6. **SubtaskDialog** — podgląd kroków decompose na żywo (status, retry), edycja promptu kroku „w locie",
   pauza/wznowienie planu.
7. **PromptLibraryDialog** — lista aktywnych wstawek (z 007) + filtr (nazwa/grupa), klik = doklej do
   pola wiadomości (stos prefixów z cofaniem pojedynczo / wyczyść), „Wstaw i zamknij".
8. **BatchQueueDialog** — „Rozbij prompt na wątki": podział tekstu (nagłówki/punkty/akapity) → lista
   `ConsoleBatchItem`, edycja/sort/usuń, „Uruchom kolejkę" (zadania po kolei jako osobne wiadomości),
   okno porażki wątku (stop/retry/continue). Status per element trwały w bazie.
9. **WorkModeDialog** — tryb interaktywny vs automatyczny (AUTO ogranicza pytania o zgodę; destrukcyjne
   nadal pytają). Zapis `ConsolePrefs.AutoMode`.
10. **ConfirmDialog** — potwierdzenia (wyczyść rozmowę/composer/kolejkę).

## Wymagania
- Okna jako `Form` modalne (`ShowDialog`), zwracają `DialogResult` + dane przez właściwości.
- Operacje async wewnątrz okien (np. przeglądarka katalogów, test) bez zamrażania.
- PlanDecisionDialog/BatchFailDialog z timeoutem (`System.Windows.Forms.Timer`).

## Kryteria akceptacji
- [ ] Wszystkie 10 okien działa i integruje się z czatem (014).
- [ ] Workdir picker zmienia folder/tryb; zgoda komend wykonuje propozycje; biblioteka wstawia snippety.
- [ ] Decompose: okna planu/podzadań sterują wykonaniem (kontynuuj/stop/edytuj/pauza) z timeoutem.
- [ ] Kolejka wątków wykonuje zadania po kolei z trwałym statusem.

## Następny wątek
[016-streaming-detekcja-bezpieczenstwo.md](016-streaming-detekcja-bezpieczenstwo.md)
