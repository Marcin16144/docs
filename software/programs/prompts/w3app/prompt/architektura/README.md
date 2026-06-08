# Odbudowa K2 CMS (w3app) od zera — seria promptów

Zestaw gotowych **promptów do skopiowania do asystenta LLM**, które krok po kroku
odtwarzają cały rdzeń K2 CMS — od pustego repozytorium do działającego panelu
administracyjnego i publicznego front-endu multi-tenant.

Każdy plik to jedna **warstwa** projektu. Numeracja co 10 (`010`, `020`, …) — luki
(`011`, `015`) zostają wolne na ewentualne kroki pośrednie wstawiane później.

> Źródłem prawdy pozostaje kod. Prompty odwzorowują realne pliki repo (stan na
> 2026-06-03) i są wierne kodowi, nawet gdy [architektura.md](../../architektura/architektura.md)
> miejscami się od niego rozjeżdża (np. modularny `admcore`, AdminLTE/Bootstrap w wersji z repo).

---

## Jak używać

1. Idź **po kolei** od `010` w górę — każdy krok zakłada, że poprzednie warstwy istnieją.
2. W pliku skopiuj zawartość bloku **`## PROMPT`**.
3. Wypełnij sekcję **`## DANE WEJŚCIOWE`** (jeśli występuje).
4. Wklej do asystenta → otrzymasz pliki PHP/konfiguracyjne gotowe do zapisania pod ścieżkami z **`## ŚCIEŻKI`**.
5. Wykonaj punkty z **`## Weryfikacja`** (np. `php bin/migrate …`, `php -l …`, wejście na panel).
6. Przejdź do następnego kroku (linki „Następny →" na górze każdego pliku).

---

## Kolejność budowania

| # | Plik | Warstwa |
|---|---|---|
| 010 | [010-fundamenty-i-bootstrap.md](010-fundamenty-i-bootstrap.md) | Struktura katalogów, `composer.json` (PSR-4), root `.htaccess`, `.gitignore`, bootstrap `ROOT`/autoload, wymóg offline |
| 020 | [020-konfiguracja-i-multitenant.md](020-konfiguracja-i-multitenant.md) | `core/Config.php` (wybór configu po polu **`website`**), `configs/_default.php`, model multi-tenant, catch-all VirtualHost |
| 030 | [030-polaczenie-z-baza.md](030-polaczenie-z-baza.md) | `core/Connection.php` (singleton PDO) + sterowniki `core/db/` (MySQL/PgSQL/SQLite) |
| 040 | [040-modele-tabel.md](040-modele-tabel.md) | Rdzeń modeli: `Core\Models\TableModel`, `Column`, `Index` (deklaratywne źródło prawdy schematu) |
| 050 | [050-system-migracji.md](050-system-migracji.md) | Migracje Doctrine: `core/Migrations/*` + `bin/migrate`, komponenty appdb/cms/shop, tabele śledzące per tenant |
| 060 | [060-logger.md](060-logger.md) | `core/Log/Logger.php` — kanały, poziomy, zapis do `<t>_logs` z fallbackiem plikowym |
| 070 | [070-modele-aplikacji-appdb.md](070-modele-aplikacji-appdb.md) | Modele `app/Appdb/Models/` (Users/Groups/Domains/Nav*/Gallery*/Logs) + migracje |
| 080 | [080-panel-front-controller.md](080-panel-front-controller.md) | `admin/index.php` — router panelu (sesja, **`Config::load('_default')`**, `admin_code`, CSP, CSRF) + `.htaccess` |
| 090 | [090-admcore-wspolne-funkcje.md](090-admcore-wspolne-funkcje.md) | `admin/admcore.php` + moduły — wspólne funkcje (auth, CSRF, rate-limit, CRUD, snapshoty) |
| 100 | [100-layout-adminlte-offline.md](100-layout-adminlte-offline.md) | Powłoka panelu: `admlayout.view.php`, `admlogin.view.php`, `index.css/js`, vendorowane `admin/assets/` |
| 110 | [110-podstrony-panelu.md](110-podstrony-panelu.md) | Wzorzec podstrony: para `adm<strona>.php` + `.view.php`, PRG, `adminNotice`, rozdział view/viewjs/viewcss |
| 120 | [120-galeria-i-media.md](120-galeria-i-media.md) | Galeria (6 tabel, `ensureGalleryTables`), upload cascade, GD, soft-delete (kosz), struktura `media/` |
| 130 | [130-kopie-zapasowe.md](130-kopie-zapasowe.md) | Backup db/full/media, ZipArchive/PharData, sidecar SHA-256, AES-256-CBC |
| 140 | [140-bezpieczenstwo.md](140-bezpieczenstwo.md) | Wielowarstwowa ochrona (10.1–10.9): sekretny URL, bcrypt, sesja, CSRF, rate-limit, nagłówki, honeypot, autoryzacja |
| 150 | [150-frontend-publiczny.md](150-frontend-publiczny.md) | Publiczny front: root `index.php` (router po domenie), `app/Web/Site`, `layout/<motyw>/` |

---

## Konwencje przewijające się przez całą serię

- **Multi-tenant po `website`** — `Config::load($_SERVER['HTTP_HOST'])` skanuje `configs/*.php`
  i wybiera plik, którego pole `website` (string lub lista aliasów, np. `['localhost','127.0.0.1']`)
  pokrywa się z domeną. Brak dopasowania → **404** (web) / wyjątek (CLI). Nowa strona = **nowy plik
  `configs/<host>.php`**, bez zmian w Apache (jeden catch-all VirtualHost).
- **Panel zawsze na `_default.php`** — `admin/index.php` woła `Config::load('_default')` niezależnie
  od domeny; brama to sekretny `admin_code` (`/admin/{admin_code}/`, `hash_equals`, 404).
- **Tabele tenant-prefixed** — nazwa = `<prefix><encja>` (np. `def_users`); prefix z `tenant.prefix`.
- **Kolumny bazowe** — `<C>ID CHAR(36)` (GUID PK), `<C>DateTime`, `<C>IDAuto INT AUTO_INCREMENT UNIQUE`.
- **Offline-first** — wszystkie zasoby UI vendorowane lokalnie (`admin/assets/`, `vendor/`), zero CDN.
- **Rozdział plików widoku** — `*.view.php` (HTML), `*.viewjs.php` (skrypt), `*.viewcss.php` (style).

---

## Zakres

Seria obejmuje **rdzeń CMS** (konfiguracja, baza, migracje, panel, galeria, backup, bezpieczeństwo,
front publiczny). **Poza zakresem** jest wspólny moduł AI / Console AI (`admin/pages/settings/ai/`,
`admin/pages/consoleai/`) — to osobny podsystem dokumentowany w `docs/llm/` i `docs/AI/`; w razie
potrzeby można go dołożyć jako kroki `160+`.

## Powiązane

- [docs/architektura/architektura.md](../../architektura/architektura.md) — pełny opis architektury (źródło tej serii)
- [docs/prompt/migracja-tabeli.md](../migracja-tabeli.md) — prompt do dodawania pojedynczej tabeli (model + migracja)
- [docs/bazy-danych.md](../../bazy-danych.md) — konwencje schematu i nazewnictwa
