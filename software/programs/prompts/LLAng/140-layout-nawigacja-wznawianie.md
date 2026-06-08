# 140 — Layout, nawigacja, wznawianie stanu

## Cel
Spójny układ z bocznym menu, trybem skupienia w Kursie i powrotem do miejsca,
w którym użytkownik skończył.

## Zadanie
1. **Menu boczne** (`Sidebar`): logo + `ThemeToggle` (130) + linki: Pulpit,
   Kurs, Materiały, Rozmowa, Fiszki, Ustawienia.
2. **Tryb Kursu = pełen ekran**: w widoku `/course` ukryj stałe menu; pokaż w
   rogu małą ikonę **☰** „powrót do menu”, która otwiera menu jako **nakładkę**
   (overlay z przyciemnieniem; klik w tło lub w link zamyka). Główny obszar
   dostaje lewy margines na ikonę.
3. **Drzewo od góry**: w Kursie pasek narzędzi przenieś do prawej kolumny, a
   drzewo daj na pełną wysokość od samej góry.
4. **Wznawianie po restarcie**:
   - zapisuj bieżącą trasę w `localStorage["lastRoute"]`; przy starcie
     nawiguj do niej (overlay menu NIE zmienia trasy, więc Kurs pozostaje Kursem);
   - zapisuj ostatnio otwarty materiał Kursu (`course.lastItem`) i Materiałów
     (`materials.lastItem`); po starcie automatycznie go otwórz (film/PDF wczytany
     i zatrzymany w miejscu przerwania) oraz rozwiń jego rozdział.
5. Routing: `HashRouter`, trasy dla wszystkich zakładek.

## Kryteria akceptacji
- W Kursie menu znika i wraca przez ☰; po zamknięciu i ponownym otwarciu apka
  wraca dokładnie tam, gdzie użytkownik skończył.
