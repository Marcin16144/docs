# VS Code — rozszerzenia projektu

Lista rozszerzeń VS Code, z których korzysta projekt, i sposoby ich instalacji.

Cały katalog `.vscode/` jest w `.gitignore` (per-developer), ale `.vscode/extensions.json` jest specyficznie wyłączony z ignorowania — żeby workspace mógł podpowiedzieć nowym osobom, co zainstalować.

---

## Szybka instalacja (zalecane)

Otwórz projekt w VS Code — wyświetli popup **"This workspace has extension recommendations"**. Klik **Install All** instaluje wszystkie wymienione w [.vscode/extensions.json](../.vscode/extensions.json) jednym ruchem.

Jeśli popup nie wyskoczył: `Ctrl+Shift+P` → wpisz **"Show Recommended Extensions"** → klik **Install Workspace Recommended Extensions** w nagłówku panelu Extensions.

Alternatywa z terminala (bash / PowerShell):

```powershell
code --install-extension recca0120.vscode-phpunit `
     --install-extension xdebug.php-debug `
     --install-extension bmewburn.vscode-intelephense-client `
     --install-extension neilbrayfield.php-docblocker `
     --install-extension mehedidracula.php-namespace-resolver `
     --install-extension junstyle.php-cs-fixer `
     --install-extension eamodio.gitlens `
     --install-extension mikestead.dotenv `
     --install-extension editorconfig.editorconfig `
     --install-extension redhat.vscode-xml `
     --install-extension mtxr.sqltools `
     --install-extension yzhang.markdown-all-in-one `
     --install-extension dracula-theme.theme-dracula
```

Po instalacji wszystkich rozszerzeń: `Ctrl+Shift+P` → **Developer: Reload Window**.

---

## Wymagane (żeby `.vscode/` configi działały)

### PHPUnit Test Explorer

- **ID**: `recca0120.vscode-phpunit`
- **Po co**: integracja z wbudowanym panelem **Testing** VS Code. Drzewo testów, gutter icons przy metodach `test*`, klik = uruchom pojedynczy test, F5 = debug z breakpointami.
- **Konfiguracja**: [.vscode/settings.json](../.vscode/settings.json) — klucze `phpunit.php`, `phpunit.phpunit`, `phpunit.args`, `phpunit.environment` (Xdebug wyłączony dla szybkości).
- **Skróty po instalacji**: `Ctrl+; A` — run all, `Ctrl+; F` — run current file, `Ctrl+; T` — run test under cursor.
- **Dokumentacja**: szczegóły w [docs/bazy-danych.md](bazy-danych.md) (sekcja o testach migracji).

### PHP Debug (Xdebug)

- **ID**: `xdebug.php-debug`
- **Po co**: debugowanie PHP przez Xdebug 3 — breakpointy, step-into, watch, call stack.
- **Konfiguracja**: [.vscode/launch.json](../.vscode/launch.json) — profil **"PHP (Xdebug) — XAMPP"** nasłuchuje na porcie 9003, `pathMappings` dla XAMPP-a.
- **Wymaga**: Xdebug zainstalowanego w PHP. W XAMPP 8.2 (`W:\XAMPP82\php`) jest natywnie — sprawdź `php -v` (wpis `with Xdebug v3.x.x`).
- **Użycie**: F5 → wybierz profil → ustaw breakpoint → odśwież stronę / odpal CLI. VS Code zatrzyma się w breakpointcie.

---

## Rekomendowane (jakość pracy z PHP)

### PHP Intelephense

- **ID**: `bmewburn.vscode-intelephense-client`
- **Po co**: autouzupełnianie, hinty typów, "Go to definition", "Find references", inline błędy składni, refaktoryzacja (rename symbol). De facto standard dla PHP w VS Code.
- **Konfiguracja**: bez dodatkowej — działa od razu po instalacji.
- **Wyłącz wbudowane PHP**: po instalacji Intelephense zaleca się wyłączyć wbudowane "PHP Language Features" VS Code (Intelephense pokaże popup z propozycją). Wbudowany może produkować duplikaty błędów składni.

### GitLens

- **ID**: `eamodio.gitlens`
- **Po co**: inline blame przy każdej linii (kto, kiedy, jaki commit), historia pliku, porównanie wersji, eksplorator branchy/tagów/stashów. Bezcenny przy pracy nad cudzym kodem i archeologii bugów.
- **Konfiguracja**: bez dodatkowej, ale można wyłączyć niektóre podpowiedzi w `settings.json` jeśli przeszkadzają (np. `"gitlens.currentLine.enabled": false`).

---

## Pozostałe rozszerzenia

Dopisane do rekomendacji dla wygody pracy z tym stosem (PHP + Doctrine + dokumentacja). Pełna, źródłowa lista: [.vscode/extensions.json](../.vscode/extensions.json).

| Rozszerzenie | ID | Po co |
|---|---|---|
| PHP DocBlocker | `neilbrayfield.php-docblocker` | Generowanie bloków PHPDoc |
| PHP Namespace Resolver | `mehedidracula.php-namespace-resolver` | Import i sortowanie namespace (PSR-4) |
| PHP CS Fixer | `junstyle.php-cs-fixer` | Formatowanie kodu wg PSR-12 |
| DotENV | `mikestead.dotenv` | Podświetlanie plików `.env` |
| EditorConfig | `editorconfig.editorconfig` | Spójny styl edycji między edytorami |
| XML | `redhat.vscode-xml` | Wsparcie dla `phpunit.xml` |
| SQLTools | `mtxr.sqltools` | Klient SQL (migracje Doctrine: MySQL/PgSQL/SQLite) |
| Markdown All in One | `yzhang.markdown-all-in-one` | Edycja dokumentacji w `docs/*.md` |
| Dracula Theme | `dracula-theme.theme-dracula` | Motyw kolorów (opcjonalny) |

---

## Pliki `.vscode/` używane w projekcie

| Plik | Rola |
|---|---|
| [.vscode/extensions.json](../.vscode/extensions.json) | Lista rekomendowanych rozszerzeń — popup przy otwarciu projektu. **Wersjonowany w git** (wyjątek od `.gitignore`). |
| [.vscode/settings.json](../.vscode/settings.json) | Ustawienia per-workspace: ścieżka PHP do walidacji składni, config PHPUnit, drobne preferencje git/edytora. |
| [.vscode/launch.json](../.vscode/launch.json) | Konfiguracja Xdebug — listener na porcie 9003 z mapowaniem ścieżek XAMPP-a. |
| [.vscode/tasks.json](../.vscode/tasks.json) | Task uruchamiany przy otwarciu folderu (`runOn: folderOpen`). |

---

## Manualna instalacja pojedynczego rozszerzenia

Jeśli wolisz po jednym:

1. `Ctrl+Shift+X` (panel Extensions)
2. W polu szukania wpisz dokładnie: `@id:<rozszerzenie>` (np. `@id:recca0120.vscode-phpunit`)
3. Klik **Install**
4. `Ctrl+Shift+P` → **Developer: Reload Window**

Albo z palety: `Ctrl+P` → wpisz `ext install <id>` → Enter.

---

## Co warto dodać do `.gitignore`

`.vscode/` jest ignorowany globalnie, ale `extensions.json` powinien być **wersjonowany** — w `.gitignore` projektu powinna być reguła pozytywna:

```
.vscode/
!.vscode/extensions.json
```

Bez tego nowi developerzy nie zobaczą popupu z rekomendacjami.
