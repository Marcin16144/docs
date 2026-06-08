# 001 — Architektura (Windows Forms)

## Rola
Architekt .NET desktop. Zaprojektuj **szkielet aplikacji Windows Forms (.NET 8)** odtwarzającej
„Integracje AI" + „Terminal" na **SQLite** (`Microsoft.Data.Sqlite`, wzorzec repozytoriów).
Pierwszy z 16 wątków — fundament.

## Cel
Solution `TerminalAi.sln` z projektami + działające okno główne z dwiema sekcjami (zakładki/menu:
„Integracje AI", „Terminal"), gotowe do rozbudowy.

## Projekty
```
TerminalAi.sln
├─ TerminalAi.Domain     (classlib net8.0)          — modele, enumy, kontrakty
├─ TerminalAi.Data       (classlib net8.0)          — repozytoria ADO.NET (Microsoft.Data.Sqlite)
├─ TerminalAi.Services   (classlib net8.0)          — providerzy AI, silnik narzędzi, detektory
└─ TerminalAi.App        (WinForms, net8.0-windows)  — Formularze/Kontrolki, kompozycja, hosting
```
`App.csproj`: `<TargetFramework>net8.0-windows</TargetFramework>`, `<UseWindowsForms>true</UseWindowsForms>`,
`<Nullable>enable</Nullable>`. Zależności: `App → Services → Data → Domain`.

## Stack i pakiety
- `Microsoft.Data.Sqlite` (8.x) w `Data`.
- `Microsoft.Extensions.DependencyInjection` + `Microsoft.Extensions.Http` (IHttpClientFactory) — prosty
  kontener DI budowany w `Program.Main`.
- `Microsoft.Extensions.Logging` (kategorie `Ai`, `ConsoleAi`).
- UI: natywne WinForms (TabControl, kontrolki). Render markdown w czacie — własna lekka kontrolka
  (RichTextBox lub WebView2 — do wyboru; rekomendacja: WebView2 dla wygodnego HTML/markdown).

## Wymagania architektoniczne
1. **Warstwy**: Formularze wołają tylko serwisy (interfejsy z Domain). Serwisy → repozytoria. Brak
   SQL w formularzach.
2. **UI nie blokuje wątku**: każda operacja IO/sieć/narzędzia jest `async`; aktualizacja kontrolek
   tylko przez `Control.Invoke`/`BeginInvoke` lub `IProgress<T>` (utworzony na wątku UI). Anulowanie:
   `CancellationTokenSource` (przycisk „Stop").
3. **DI w `Program.Main`**: zbuduj `ServiceProvider` (rejestracja repozytoriów, providerów, serwisów,
   `HttpClientFactory`), wstrzykuj do formularzy (factory/`ActivatorUtilities`).
4. **Inicjalizacja bazy przy starcie**: `DbInitializer` tworzy tabele (`CREATE TABLE IF NOT EXISTS`)
   i seeduje (wątek 002). Plik `app.db` obok exe (lub w `%AppData%`).
5. **User lokalny**: `UserId = "local"`; ZOSTAW kolumny `UserId`/`SessionId` w bazie (historia, preferencje).

## Struktura folderów (orientacyjnie)
```
TerminalAi.Domain/   Models/ Enums/ Contracts/        (identyczne jak w wersji Blazor)
TerminalAi.Data/     SqliteConnectionFactory.cs, Repositories/, DbInitializer.cs
TerminalAi.Services/ Providers/ Tools/ Engine/ Profiles/ Detection/ Search/   (logika współdzielona)
TerminalAi.App/
  Program.cs                 (Main: DI + ApplicationConfiguration + MainForm)
  MainForm.cs                (hostuje 2 sekcje — TabControl albo lewy panel nawigacji)
  Ai/        (UserControl per zakładka providera — wątki 005-007)
  Terminal/  (TerminalControl + okna dialogowe — wątki 014-015)
  Controls/  (wspólne kontrolki: ProviderTestPanel, MessageBubble, ...)
```

## Deliverable tego wątku
- `dotnet build` przechodzi; `dotnet run --project TerminalAi.App` otwiera okno z dwiema pustymi
  sekcjami („Integracje AI", „Terminal").
- `SqliteConnectionFactory` + pusty `DbInitializer` (wołany w `Program.Main`).
- Interfejsy-zaślepki: `IAiProvider`, `IToolLoopRunner`, `IAiConfigRepository`.
- `app.db` powstaje przy starcie.

## Kryteria akceptacji
- [ ] Solution kompiluje; aplikacja startuje z dwiema sekcjami (placeholdery).
- [ ] DI zbudowane w `Program.Main`; formularze dostają zależności z kontenera.
- [ ] `app.db` tworzony przy starcie; brak blokowania UI w kodzie startowym.

## Następny wątek
[002-baza-danych-sqlite.md](002-baza-danych-sqlite.md)
