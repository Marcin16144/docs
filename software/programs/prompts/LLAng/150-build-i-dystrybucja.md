# 150 — Build i dystrybucja (.exe, instalatory, macOS)

## Cel
Zbudować wersje produkcyjne i wiedzieć, jak je wydawać.

## Wymagania (desktop)
- **Rust** (rustup, toolchain `stable-x86_64-pc-windows-msvc`).
- **Microsoft C++ Build Tools** (komponent „Desktop development with C++”).
- **WebView2** (zwykle obecny w Win10/11).
- Instalacja Rust: `winget install Rustlang.Rustup` (cargo trafia do
  `%USERPROFILE%\.cargo\bin`; dodaj do PATH w świeżym terminalu).

## Komendy
- Web (dev): `npm run dev` → http://localhost:1420
- Web (prod): `npm run build` → folder `dist/` (wrzucasz na hosting/XAMPP)
- Desktop (dev): `npm run tauri dev`
- Desktop (prod): `npm run tauri build` →
  - `src-tauri/target/release/llang.exe` (samodzielny plik),
  - `.../bundle/msi/*.msi` i `.../bundle/nsis/*-setup.exe` (instalatory).

## Konfiguracja wydania
- `tauri.conf.json`: `productName`, `identifier`, `version`, ikony, `bundle.targets`.
- Uprawnienia w `src-tauri/capabilities/default.json`: `core:default`,
  `sql:*`, `dialog:default`, `opener:default` + `allow-open-path/allow-open-url`,
  `assetProtocol` w sekcji security.

## macOS / multi-OS
- Tauri **nie zbuduje** `.app`/`.dmg` na Windowsie — potrzebny macOS.
- Zalecane: **GitHub Actions** z macierzą (windows/macos/linux) i akcją
  `tauri-apps/tauri-action` — automatyczny build i artefakty/release przy tagu.

## Kryteria akceptacji
- `npm run tauri build` produkuje działający `.exe` + instalatory.
- `npm run build` produkuje wersję web do wrzucenia na serwer.
