# 007 — Biblioteka wstawek promptu (snippets)

## Rola
Programista Blazor. Zbuduj zarządzanie **wstawkami promptu** — gotowymi fragmentami tekstu
pogrupowanymi tematycznie, które user docelowo wstawia do pola wiadomości w Terminalu
(modal „Wstaw prompt", wątek 015).

## Cel
Zakładka „Wstawki promptu" w „Integracje AI": CRUD na `PromptSnippet` z grupami i sortowaniem.

## Funkcje
- **Lista pogrupowana** po `Group` (np. „Kod", „Analiza", „Refaktor"), w grupie sort po `SortOrder`.
- **CRUD**: dodaj / edytuj / usuń wstawkę (`Group`, `Label`, `Text`, `Active`, `SortOrder`).
- **Włącz/wyłącz** (`Active`) — nieaktywne nie pojawiają się w modalu wstawiania, ale zostają w edytorze.
- **Sortowanie** w obrębie grupy (strzałki lub DnD).
- Edytor `Text` to textarea (wstawka może być wielolinijkowa, np. szablon instrukcji).

## Kontrakt (repozytorium)
`IPromptSnippetRepository`: `ListAsync(bool activeOnly)`, `GetAsync(id)`, `SaveAsync(snippet)`,
`DeleteAsync(id)`, `SetActiveAsync(id, active)`, `ReorderAsync(group, orderedIds)`.

## Wymagania
- Zapis async; po zmianie odśwież listę.
- Walidacja: `Label` i `Text` niepuste; `Group` domyślnie „Ogólne".
- Seed z wątku 002 (kilka przykładów) ma być widoczny po pierwszym uruchomieniu.

## Kryteria akceptacji
- [ ] CRUD wstawek działa (round-trip do SQLite), z grupowaniem i sortowaniem.
- [ ] `ListAsync(activeOnly:true)` zwraca tylko aktywne (kontrakt dla modalu wstawiania w 015).
- [ ] Przełącznik aktywności i zmiana kolejności trwałe.

## Następny wątek
[008-silnik-petli-narzedzi.md](008-silnik-petli-narzedzi.md) — serce Terminala.
