# 020 — Stack technologiczny i inicjalizacja

## Cel
Zainicjuj projekt i skonfiguruj narzędzia.

## Stack
- **Wrapper desktop:** Tauri v2 (Rust) — mały `.exe`, niski RAM, build na
  Windows/macOS/Linux. Frontend ten sam co web.
- **Frontend:** React + TypeScript + Vite.
- **Style:** Tailwind CSS v4 (plugin `@tailwindcss/vite`).
- **Routing:** React Router (HashRouter — działa w web na statycznym hostingu
  i w Tauri bez konfiguracji serwera).
- **Stan:** hooki React (+ ewentualnie Zustand).

## Zadanie
1. Wygeneruj szkielet:
   `npm create tauri-app@latest <nazwa> -- -t react-ts -m npm --tauri-version 2 -y`
2. Ustaw identyfikator aplikacji, nazwę produktu i tytuł okna (np. 1000×720).
3. Dodaj Tailwind v4: w `vite.config.ts` plugin `@tailwindcss/vite`,
   w `src/index.css` linia `@import "tailwindcss";`.
4. Routing: w `main.tsx` owiń `<App/>` w `HashRouter`.
5. Zadbaj o skrypty: `dev` (web), `build` (web prod → `dist/`),
   `tauri dev`, `tauri build`.

## Wymagania środowiska (desktop)
- Node 20+, npm.
- Rust (rustup, toolchain stable-msvc) — potrzebny TYLKO do `.exe`.
- Windows: WebView2 (zwykle obecny) + Microsoft C++ Build Tools.

## Kryteria akceptacji
- `npm run dev` pokazuje stronę pod http://localhost:1420.
- `npm run build` tworzy `dist/`.
- `npm run tauri build` (po instalacji Rust) tworzy `.exe` + instalatory.
