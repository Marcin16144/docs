# 090 — Kontrola integralności plików (BLAKE3)

## Cel
Wykryć uszkodzone / zmienione / brakujące pliki kursu między skanami
(np. cichą korupcję na dysku).

## Zadanie
1. **Rust** — komenda `hash_file(path) -> String`: liczy sumę kontrolną
   **BLAKE3** strumieniowo (bufor 1 MB, bez wczytywania całości do RAM).
   Dodaj crate `blake3`.
2. Tabela `file_integrity(relPath PK, size, hash, checkedAt)` (z 030).
3. Komponent `IntegrityPanel(scanned)`:
   - przycisk „🛡️ Sprawdź integralność” + pasek postępu (i/n + nazwa pliku);
   - dla każdego pliku: policz hash, porównaj z zapisanym wzorcem
     (`ok` = zgodny, `changed` = różny, `new` = brak wzorca → zapisz),
     zaktualizuj wzorzec;
   - po przejściu: pliki z bazy nieobecne na dysku → `missing`;
   - raport: liczniki OK / zmienione / brakujące / nowe + lista problemów.
4. Wejście do panelu w Kursie (przełącznik „Integralność”).

## Uwagi
- Pierwszy skan to zapis wzorca (wszystko `new`).
- Hashowanie wielu GB trwa — pokazuj postęp; to akcja na żądanie.

## Kryteria akceptacji
- Po podmianie/uszkodzeniu pliku kolejny skan oznacza go jako „zmieniony”.
