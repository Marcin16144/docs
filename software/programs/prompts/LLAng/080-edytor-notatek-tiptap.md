# 080 — Edytor notatek WYSIWYG (TipTap)

## Cel
Bogaty edytor treści notatki: pogrubienie, font i rozmiar, justowanie, listy,
tabele, wstawianie zdjęć. Treść zapisywana jako HTML.

## Zadanie
1. Biblioteka **TipTap v3**. Zainstaluj: `@tiptap/react @tiptap/pm
   @tiptap/starter-kit @tiptap/extension-text-style @tiptap/extension-text-align
   @tiptap/extension-image @tiptap/extension-table` (+ powiązane).
   - Uwaga: StarterKit v3 zawiera już bold/italic/underline/strike/listy.
   - Z `@tiptap/extension-text-style` weź `TextStyle`, `FontFamily`, `FontSize`.
   - Tabele: `TableKit` (z `@tiptap/extension-table`).
2. Komponent `RichNoteEditor` (`forwardRef`, uchwyt `{ getHTML, getText, clear }`):
   - extensions: StarterKit, TextStyle, FontFamily, FontSize,
     `TextAlign.configure({types:["heading","paragraph"]})`,
     `Image.configure({allowBase64:true})`, `TableKit`.
   - **Toolbar**: B / I / U / S, wybór fontu (`setFontFamily`), rozmiaru
     (`setFontSize`), justowanie (`setTextAlign` left/center/right/justify),
     listy, wstaw tabelę (`insertTable`) + dodaj wiersz/kolumnę/usuń, wstaw
     zdjęcie.
   - **Zdjęcia**: ukryty `<input type="file" accept="image/*">` → `FileReader`
     → data URL → `setImage({src})` (samowystarczalne, działa też w web).
3. Render notatki: `dangerouslySetInnerHTML` w kontenerze `.note-content`.
   W `index.css` dodaj style tabel (border-collapse, obramowania komórek) i
   obrazów (`max-width:100%`).
4. Podłącz edytor w `TimedNotesPanel` (z 070) zamiast zwykłego pola tekstowego.

## Kryteria akceptacji
- Można sformatować tekst, wstawić tabelę i zdjęcie; notatka zapisuje HTML i
  poprawnie się wyświetla na liście.
