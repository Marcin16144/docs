# 007 — Biblioteka wstawek promptu (Windows Forms)

## Rola
Programista WinForms. Zarządzanie **wstawkami promptu** (gotowe fragmenty tekstu, grupowane),
wstawiane później do pola wiadomości w Terminalu (okno „Wstaw prompt", wątek 015).

## Cel
Zakładka/okno „Wstawki promptu": CRUD na `PromptSnippet` z grupami i sortowaniem.

## Funkcje
- `TreeView`/`ListView` pogrupowany po `Group`, w grupie sort po `SortOrder`.
- CRUD: dodaj/edytuj/usuń (`Group`, `Label`, `Text` multiline, `Active`, `SortOrder`).
- CheckBox `Active` (nieaktywne nie pojawią się w oknie wstawiania, zostają w edytorze).
- Sortowanie ↑/↓ w obrębie grupy.

## Kontrakt
`IPromptSnippetRepository`: `ListAsync(bool activeOnly)`, `GetAsync(id)`, `SaveAsync`, `DeleteAsync`,
`SetActiveAsync`, `ReorderAsync(group, orderedIds)`.

## Kryteria akceptacji
- [ ] CRUD round-trip do SQLite z grupowaniem i sortowaniem.
- [ ] `ListAsync(activeOnly:true)` zwraca tylko aktywne (kontrakt dla okna wstawiania w 015).

## Następny wątek
[008-silnik-petli-narzedzi.md](008-silnik-petli-narzedzi.md)
