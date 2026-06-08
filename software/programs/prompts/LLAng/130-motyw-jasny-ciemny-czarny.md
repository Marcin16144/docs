# 130 — Motyw jasny / ciemny / czarny

## Cel
Przełącznik motywu w postaci ikony, z trzema wariantami i zapamiętywaniem wyboru.

## Zadanie
1. **Tailwind v4 — tryb ciemny klasą**: w `index.css` dodaj
   `@custom-variant dark (&:where(.dark, .dark *));` (warianty `dark:` reagują na
   klasę `.dark` na `<html>`, nie tylko na ustawienie systemowe).
2. Moduł `features/theme.ts`:
   - typ `Theme = "light" | "dark" | "black"`;
   - `applyTheme(t)`: ustaw `.dark` dla `dark`/`black`, `.black` dla `black`;
   - `getInitialTheme()`: zapisany wybór lub preferencja systemowa.
3. Inicjalizacja w `main.tsx` PRZED renderem (bez mignięcia):
   `applyTheme(getInitialTheme())`.
4. **Motyw czarny** — w `index.css` nadpisz ciemne tła/obramowania slate na czerń
   (z `!important`, prefiks `html.black`):
   `dark:bg-slate-900 → #000`, `dark:bg-slate-800 → #0a0a0a`,
   `dark:bg-slate-700 → #1a1a1a`, `dark:border-slate-700 → #1f1f1f`,
   `dark:border-slate-600 → #2a2a2a` (+ wariant `/60`).
5. Komponent `ThemeToggle`: cykl light → dark → black; ikona ☀️/🌙/🌑;
   zapis w `localStorage["theme"]`. **Pokazuj go tylko w menu bocznym** (gdy
   rozwinięte) — nie jako pływającą ikonę w widoku pełnoekranowym.

## Kryteria akceptacji
- Jedna ikona przełącza 3 motywy; w „czarnym” tło jest pełną czernią; wybór
  przeżywa restart.
