# Prompt 010: Fundamenty i bootstrap — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". Następny: [020 Konfiguracja i multi-tenant](020-konfiguracja-i-multitenant.md) →

Ten krok buduje **szkielet repozytorium** K2 CMS: strukturę katalogów, plik `composer.json` (PSR-4, zależności Doctrine), root `.htaccess` (RewriteEngine + blokady), `.gitignore` oraz konwencję bootstrapu (`define('ROOT', …)` + `spl_autoload_register` dla `core/db/`). To pierwszy krok serii — nie wymaga żadnych wcześniejszych. Po jego wykonaniu repo jest gotowe na `composer install` i kolejne warstwy (konfiguracja, połączenie z bazą, migracje).

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Ten krok nie ma `## DANE WEJŚCIOWE` — prompt jest samowystarczalny (wpisz tylko nazwę projektu, jeśli inna niż K2 CMS / `w3app`).
3. Wklej do asystenta LLM. Otrzymasz komplet plików: `composer.json`, `.htaccess`, `.gitignore`, `index.php` (zaślepka bootstrap), oraz `.gitkeep` dla pustych katalogów.
4. Zapisz pliki wg podanych **ŚCIEŻEK** w katalogu głównym repo.
5. Uruchom `composer install`, następnie `composer dump-autoload`.
6. Zweryfikuj wg sekcji **Weryfikacja** poniżej.

---

## PROMPT

```
Jesteś generatorem szkieletu repozytorium dla silnika K2 CMS (kod roboczy: w3app).
Wygeneruj komplet plików fundamentu: strukturę katalogów (pliki .gitkeep),
composer.json, root .htaccess, .gitignore oraz tymczasowy index.php (bootstrap).

## KONTEKST PROJEKTU

- K2 CMS to wielodomenowy (multi-tenant) system CMS w PHP 8.1+.
- Jedna instalacja obsługuje wiele domen; każda ma własny prefiks tabel i config.
- Panel administracyjny oparty na AdminLTE 3 (Bootstrap 4 + jQuery 3.6) — wszystko
  vendorowane LOKALNIE. WYMÓG OFFLINE: system działa BEZ dostępu do internetu,
  ŻADEN zasób (CSS/JS/fonty/ikony) nie jest pobierany z CDN w runtime.
- Migracje schematu: doctrine/migrations 3.x. ORM bazowo: doctrine/orm 3.x.
- Baza: MySQL 8 (InnoDB, utf8mb4) bazowo; alternatywnie SQLite / PgSQL.
- Front controller: jeden root index.php (na tym etapie tymczasowa zaślepka).

## ŚCIEŻKI (względem katalogu głównego repo)

- composer.json
- .htaccess
- .gitignore
- index.php
- katalogi (z plikiem .gitkeep w każdym, by git je zachował):
    admin/.gitkeep
    app/.gitkeep
    configs/.gitkeep
    core/.gitkeep
    core/db/.gitkeep
    docs/.gitkeep
    media/originals/.gitkeep
    media/cache/.gitkeep
    tests/.gitkeep
    var/backups/.gitkeep
    var/logs/.gitkeep
    var/schema-lock/.gitkeep

## KONWENCJE / ZASADY

1. PSR-4 (composer.json):
     "App\\"  → "app/"      (kod aplikacyjny — komponenty Appdb, Cms, Shop)
     "Core\\" → "core/"     (rdzeń: modele, migracje, logger)
   oraz autoload-dev:
     "Tests\\" → "tests/"
   Klasy w core/db/ (Driver, MySqlDriver, PgSqlDriver, SqliteDriver) są BEZ
   namespace (globalne) — ładowane własnym spl_autoload_register w index.php,
   NIE przez PSR-4. Nie dodawaj ich do mapy PSR-4.

2. Wymagania (require): "php": ">=8.1", "doctrine/orm": "^3.6",
   "doctrine/migrations": "^3.9". require-dev: "phpunit/phpunit": "^11".

3. Bootstrap w index.php:
     define('ROOT', __DIR__);
     require ROOT . '/vendor/autoload.php';
     require ROOT . '/core/Config.php';
     require ROOT . '/core/Connection.php';
   Następnie spl_autoload_register ładujący klasy z core/db/<Class>.php
   (sprawdza is_file, robi require), potem Config::load($_SERVER['HTTP_HOST']).
   Na tym etapie index.php to ZAŚLEPKA: po bootstrapie wypisuje print_r(Config::all())
   i sprawdza Connection::get() (echo "Połączenie z bazą: OK"). To celowo tymczasowe.

4. Root .htaccess:
     - Options -Indexes
     - RewriteEngine On
     - Blokada bezpośredniego dostępu do folderów systemowych:
         RewriteRule ^(core|configs|app|database)(/|$) - [F,L]
     - Szablony widoków niedostępne bezpośrednio:
         RewriteRule \.view\.php$ - [F,L]
     - Statyczne pliki serwowane bezpośrednio:
         RewriteCond %{REQUEST_FILENAME} -f
         RewriteRule ^ - [L]
     - Publiczne endpointy wtyczek w music/ (własny index.php w podkatalogu,
       np. callbacki OAuth) — pomijają front controller:
         RewriteRule ^music/ - [L]
     - Wszystko inne przez front controller:
         RewriteRule ^ index.php [QSA,L]

5. .gitignore (najważniejsze grupy):
     - .claude/   .vscode/ (oprócz !.vscode/extensions.json)   .idea/
     - vendor/    composer.lock
     - .env  .env.local
     - .DS_Store  Thumbs.db
     - *.log   /logs/
     - /var/schema-lock/*  z wyjątkiem !/var/schema-lock/.gitkeep
     - /media/originals/*  i /media/cache/*  z wyjątkami !.gitignore !.gitkeep
     - /var/backups/*  z wyjątkami !.gitignore !.gitkeep
     - wtyczka music: /music/media/* z zachowaniem .htaccess, .gitkeep i
       podkatalogu .chunks/ (analogiczne wyjątki)

6. WYMÓG OFFLINE: w żadnym generowanym pliku nie odwołuj się do CDN ani zewnętrznych
   URL-i. Wszystkie zasoby front-endu będą vendorowane lokalnie w admin/assets/.

## SZABLONY / KOD

### composer.json
{
    "name": "w3app/w3app",
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Core\\": "core/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "require": {
        "php": ">=8.1",
        "doctrine/orm": "^3.6",
        "doctrine/migrations": "^3.9"
    },
    "require-dev": {
        "phpunit/phpunit": "^11"
    }
}

### .htaccess (root)
Options -Indexes

RewriteEngine On

# Blokada bezpośredniego dostępu do folderów systemowych
RewriteRule ^(core|configs|app|database)(/|$) - [F,L]

# Szablony widoków (*.view.php) nie są dostępne bezpośrednio
RewriteRule \.view\.php$ - [F,L]

# Statyczne pliki — serwuj bezpośrednio
RewriteCond %{REQUEST_FILENAME} -f
RewriteRule ^ - [L]

# Publiczne endpointy wtyczek (np. callbacki OAuth) — własny index.php
# w podkatalogu, poza front controllerem CMS. DirectoryIndex Apache'a
# automatycznie wskaże /music/<serwis>/index.php przy żądaniu folderu.
RewriteRule ^music/ - [L]

# Wszystko inne — przez index.php
RewriteRule ^ index.php [QSA,L]

### index.php (tymczasowa zaślepka bootstrap)
<?php

declare(strict_types=1);

define('ROOT', __DIR__);

require ROOT . '/vendor/autoload.php';
require ROOT . '/core/Config.php';
require ROOT . '/core/Connection.php';

spl_autoload_register(static function (string $class): void {
    $path = ROOT . '/core/db/' . $class . '.php';
    if (is_file($path)) {
        require $path;
    }
});

Config::load($_SERVER['HTTP_HOST']);

// tymczasowo — do testów
echo '<pre>';
print_r(Config::all());

$pdo = Connection::get();
echo 'Połączenie z bazą: OK';
echo '</pre>';

### .gitignore
# Claude
.claude/

# IDE
.vscode/
!.vscode/extensions.json
.idea/

# PHP
vendor/
composer.lock

# Środowisko
.env
.env.local

# System
.DS_Store
Thumbs.db

# Logi
*.log
/logs/

# Schema-lock (per-środowisko, generowane przez migrator)
/var/schema-lock/*
!/var/schema-lock/.gitkeep

# Media uploads — pliki generowane przez użytkowników, nie wersjonowane
/media/originals/*
!/media/originals/.gitignore
!/media/originals/.gitkeep
/media/cache/*
!/media/cache/.gitignore
!/media/cache/.gitkeep
/var/backups/*
!/var/backups/.gitignore
!/var/backups/.gitkeep

# Wtyczka music — uploady audio i okładki nie są wersjonowane.
# Zachowujemy strukturę katalogów + .htaccess (security config).
/music/media/*
!/music/media/.htaccess
!/music/media/.gitkeep
!/music/media/.chunks/
/music/media/.chunks/*
!/music/media/.chunks/.htaccess
!/music/media/.chunks/.gitkeep

## ZADANIE

1. Wygeneruj plik composer.json dokładnie wg sekcji SZABLONY / KOD.
2. Wygeneruj root .htaccess dokładnie wg sekcji SZABLONY / KOD.
3. Wygeneruj .gitignore dokładnie wg sekcji SZABLONY / KOD.
4. Wygeneruj tymczasowy index.php (bootstrap-zaślepka) wg sekcji SZABLONY / KOD.
5. Wygeneruj puste pliki .gitkeep dla wszystkich katalogów wymienionych w ŚCIEŻKACH
   (zawartość: pusta lub jedna pusta linia), tak by git zachował strukturę katalogów.
6. Każdy plik poprzedź jedną linią-komentarzem ze ścieżką, np.:
   "// === composer.json ===", "# === .htaccess ===".
7. Na końcu dopisz polecenia do uruchomienia w terminalu:
     composer install
     composer dump-autoload
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] `composer install` wykonuje się bez błędu; powstaje katalog `vendor/` z autoloaderem.
- [ ] `composer dump-autoload` przebiega bez ostrzeżeń o nieznalezionych mapach PSR-4.
- [ ] Drzewo katalogów zgodne z architekturą: `admin/`, `app/`, `configs/`, `core/`, `core/db/`, `docs/`, `media/originals/`, `media/cache/`, `tests/`, `var/backups/`, `var/logs/`, `var/schema-lock/`.
- [ ] `git status` pokazuje śledzone `.gitkeep` w pustych katalogach; `vendor/`, `composer.lock`, `media/*`, `var/backups/*` zignorowane.
- [ ] Próba otwarcia `core/`, `configs/`, `app/` lub dowolnego `*.view.php` przez przeglądarkę zwraca 403 (po podpięciu pod Apache).
- [ ] `index.php` zawiera `define('ROOT', __DIR__)` oraz `spl_autoload_register` ładujący `core/db/<Class>.php`.
- [ ] W żadnym pliku nie ma odwołań do CDN ani zewnętrznych URL-i (wymóg offline).

## Powiązane
- [docs/architektura/architektura.md §2 (Stos), §3 (Struktura katalogów)](../../architektura/architektura.md)
- [Następny krok: 020 Konfiguracja i multi-tenant](020-konfiguracja-i-multitenant.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
