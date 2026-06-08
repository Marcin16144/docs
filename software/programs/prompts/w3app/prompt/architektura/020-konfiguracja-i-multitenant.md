# Prompt 020: Konfiguracja i multi-tenant — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [010 Fundamenty i bootstrap](010-fundamenty-i-bootstrap.md) · Następny: [030 Połączenie z bazą](030-polaczenie-z-baza.md) →

Ten krok buduje **warstwę konfiguracji i model multi-tenant**: klasę `core/Config.php` (dopasowanie strony po polu `website`, nie po nazwie pliku), bazowy `configs/_default.php` oraz przykładowy `configs/<host>.php` z nadpisaniami. Wymaga szkieletu z kroku 010 (`define('ROOT')`, `index.php` woła `Config::load(...)`). Po nim system potrafi wybrać właściwego tenanta na podstawie domeny żądania; kolejny krok (030) podłącza bazę z tej konfiguracji.

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Uzupełnij `## DANE WEJŚCIOWE` (host przykładowego tenanta, jego prefiks, `admin_code`, dane bazy) — albo zostaw wartości przykładowe.
3. Wklej do asystenta LLM. Otrzymasz: `core/Config.php`, `configs/_default.php`, `configs/<host>.php`.
4. Zapisz pliki wg **ŚCIEŻEK**.
5. Dopisz domenę testową do pliku hosts Windows (patrz nota poniżej) i zweryfikuj wg sekcji **Weryfikacja**.

---

## PROMPT

```
Jesteś generatorem warstwy konfiguracji silnika K2 CMS (multi-tenant).
Wygeneruj klasę core/Config.php oraz dwa pliki konfiguracyjne: configs/_default.php
(baza scalania) i configs/<host>.php (nadpisania per-tenant).

## KONTEKST PROJEKTU

- K2 CMS to wielodomenowy CMS w PHP 8.1+. Jedna instalacja obsługuje wiele domen.
- Bootstrap (index.php) ustawia define('ROOT', __DIR__) i woła:
    Config::load($_SERVER['HTTP_HOST']);
- Strona NIE jest wybierana po NAZWIE pliku configu, lecz po wartości pola `website`
  w środku pliku. Config::load skanuje configs/*.php i wybiera ten, którego `website`
  pokrywa się z domeną żądania.
- `website` może być STRINGIEM lub TABLICĄ aliasów, np. ['localhost', '127.0.0.1'].
- Z hosta odcinany jest port (np. 'localhost:93' → 'localhost').
- Brak dopasowania: 404 dla przeglądarki, wyjątek RuntimeException dla CLI.
- configs/_default.php jest ZAWSZE bazą scalania (array_replace_recursive); config
  konkretnej strony nadpisuje tylko wybrane klucze. _default może też deklarować własne
  `website` (np. 'localhost') — wtedy sam obsługuje tę domenę jako fallback (niższy
  priorytet niż config konkretnej strony).
- Wywołanie Config::load('') lub Config::load('_default') ładuje samą bazę (CLI/bootstrap
  bez konkretnej domeny, np. bin/migrate bez --host).

## ŚCIEŻKI

- core/Config.php          (klasa Config, BEZ namespace — globalna)
- configs/_default.php     (zwraca tablicę PHP — baza scalania)
- configs/<host>.php       (zwraca tablicę PHP — nadpisania; nazwa pliku dowolna,
                            liczy się pole `website` w środku)

## KONWENCJE / ZASADY

1. Config to klasa statyczna: private static array $data = [];
   Publiczne metody: load(string $host): void, get(string $key, mixed $default = null): mixed,
   all(): array.
2. normalizeHost(): strtolower, odetnij port przez explode(':', $host, 2)[0],
   przepuść tylko znaki [a-z0-9.\-_] (preg_replace).
3. findByWebsite(): glob(configs/*.php), require każdego pliku; dopasuj po
   websiteMatches($cfg['website'] ?? null, $host). _default.php traktuj jako fallback
   (zapamiętaj, ale nie zwracaj od razu) — konkretna strona wygrywa.
4. websiteMatches(): null → false; iteruj po (is_array ? website : [website]),
   porównuj strtolower((string)$w) === $host.
5. handleUnknownHost(): PHP_SAPI === 'cli' → throw RuntimeException z podpowiedzią
   (dodaj plik w configs/ z 'website' => '<host>'); inaczej http_response_code(404),
   nagłówek Content-Type text/html; charset=utf-8, exit z prostym HTML 404.
6. loadFile(): require configs/<name>.php jeśli istnieje, inaczej [].
7. Parametry configu (klucze): db (driver, host, port, database, username, password,
   charset), tenant (prefix), admin_code (sekretny segment URL panelu /admin/{admin_code}/),
   website (string|array), website_scheme ('https' domyślnie, 'http' lokalnie),
   backup_encryption_key (''=wyłączone; 'base64:<32B>' = AES-256-CBC),
   theme, language, debug, gallery (max_width, max_height, thumb_size, max_upload_mb).
   tenant.prefix w _default = 'def'; admin_code w _default = 'panel1'.

## SZABLON / KOD

### core/Config.php  (PEŁNY docelowy kod — odtwórz wiernie)
<?php

declare(strict_types=1);

class Config
{
    private static array $data = [];

    /**
     * Ładuje konfigurację strony dopasowaną po polu `website`.
     *
     * Strona NIE jest wybierana po nazwie pliku, lecz po wartości `website`
     * w środku pliku w configs/. index.php woła Config::load($_SERVER['HTTP_HOST']);
     * wybierany jest ten config, którego `website` pokrywa się z domeną żądania
     * (port pomijany). Brak dopasowania = 404 (web) lub wyjątek (CLI).
     *
     * `_default.php` jest zawsze bazą scalania; może też deklarować własne
     * `website` (np. 'localhost'), wtedy obsługuje tę domenę.
     */
    public static function load(string $host): void
    {
        $host    = self::normalizeHost($host);
        $default = self::loadFile('_default');

        // Bootstrap / CLI bez konkretnej domeny (np. bin/migrate bez --host).
        if ($host === '' || $host === '_default') {
            self::$data = $default;
            return;
        }

        $site = self::findByWebsite($host);

        if ($site === null) {
            self::handleUnknownHost($host);
            return;
        }

        self::$data = array_replace_recursive($default, $site);
    }

    public static function get(string $key, mixed $default = null): mixed
    {
        return self::$data[$key] ?? $default;
    }

    public static function all(): array
    {
        return self::$data;
    }

    /** Normalizacja domeny: małe litery, bez portu, tylko bezpieczne znaki. */
    private static function normalizeHost(string $host): string
    {
        $host = strtolower($host);
        $host = explode(':', $host, 2)[0];           // odetnij port (np. :93)
        return (string) preg_replace('/[^a-z0-9.\-_]/', '', $host);
    }

    /**
     * Skanuje configs/*.php i zwraca konfigurację, której `website` pasuje do
     * domeny. `website` może być stringiem lub tablicą aliasów (np.
     * ['localhost', '127.0.0.1']). Config konkretnej strony ma pierwszeństwo
     * przed _default, gdy obie pasują do tego samego hosta.
     */
    private static function findByWebsite(string $host): ?array
    {
        $dir = ROOT . '/configs';
        if (!is_dir($dir)) {
            return null;
        }

        $fallback = null; // dopasowanie pochodzące z _default (niższy priorytet)

        foreach (glob($dir . '/*.php') ?: [] as $path) {
            $cfg = require $path;
            if (!is_array($cfg) || !self::websiteMatches($cfg['website'] ?? null, $host)) {
                continue;
            }
            if (basename($path) === '_default.php') {
                $fallback = $cfg;
                continue;
            }
            return $cfg; // konkretna strona wygrywa
        }

        return $fallback;
    }

    /** Czy `website` (string lub lista) pokrywa się z domeną. */
    private static function websiteMatches(mixed $website, string $host): bool
    {
        if ($website === null) {
            return false;
        }
        foreach (is_array($website) ? $website : [$website] as $w) {
            if (strtolower((string) $w) === $host) {
                return true;
            }
        }
        return false;
    }

    /** Brak konfiguracji dla domeny: 404 dla przeglądarki, wyjątek dla CLI. */
    private static function handleUnknownHost(string $host): void
    {
        if (PHP_SAPI === 'cli') {
            throw new \RuntimeException(
                "Brak konfiguracji dla domeny '{$host}'. "
                . "Dodaj plik w configs/ z polem 'website' => '{$host}'."
            );
        }

        http_response_code(404);
        header('Content-Type: text/html; charset=utf-8');
        exit("<!doctype html>\n<title>404 Not Found</title>\n"
            . "<h1>Not Found</h1>\n<p>No site configured for this domain.</p>\n");
    }

    private static function loadFile(string $name): array
    {
        $path = ROOT . "/configs/{$name}.php";

        return file_exists($path) ? require $path : [];
    }
}

### configs/_default.php  (baza scalania — odtwórz wiernie)
<?php

return [
    'db' => [
        'driver'   => 'mysql',
        'host'     => 'localhost',
        'port'     => 3306,
        'database' => 'web_new',
        'username' => 'root',
        'password' => 'admin1234',
        'charset'  => 'utf8mb4',
    ],
    'tenant' => [
        'prefix' => 'def',
    ],

    // Sekretny segment URL panelu administracyjnego: /admin/{admin_code}/
    // Każdy tenant powinien nadpisać własnym, unikatowym kodem.
    'admin_code' => 'panel1',

    // Adres (host) tej strony — używany do budowania pełnych URL-i (linki, webhooki, podgląd).
    // Dla środowiska lokalnego można podać host z portem, np. 'localhost:93'.
    //
    // Aby używać własnej nazwy hosta lokalnie (np. 'klient1.local'), dopisz wpis w pliku
    // hosts systemu Windows:  C:\Windows\System32\drivers\etc\hosts
    //   1. Otwórz Notatnik JAKO ADMINISTRATOR (inaczej zapis się nie powiedzie).
    //   2. Plik → Otwórz → C:\Windows\System32\drivers\etc\hosts  (zmień filtr na „Wszystkie pliki").
    //   3. Dopisz linię:   127.0.0.1    klient1.localhost
    //   4. Zapisz. Nazwa pliku configu musi odpowiadać hostowi (np. configs/klient1.local.php).
    'website' => ['localhost', '127.0.0.1'],

    // Schemat protokołu strony: 'https' (domyślnie) lub 'http' (np. lokalnie).
    'website_scheme' => 'https',

    // Klucz szyfrowania backupów AES-256-CBC (propozycja 06).
    // '' = wyłączone (plain-text SQL). Gdy ustawiony: pliki zapisywane jako .sql.enc.
    // Wygeneruj: php -r "echo 'base64:'.base64_encode(random_bytes(32)).PHP_EOL;"
    // UWAGA: utrata klucza = utrata możliwości odszyfrowania wszystkich backupów.
    'backup_encryption_key' => '',

    'theme'    => 'default',
    'language' => 'pl',
    'debug'    => false,

    'gallery' => [
        'max_width'     => 1920,
        'max_height'    => 1080,
        'thumb_size'    => 300,
        'max_upload_mb' => 20,
    ],
];

### configs/<host>.php  (przykład nadpisań per-tenant — wzór z configs/klient1.localhost.php)
<?php

return [
    'db' => [
        'database' => 'klient1_db',
        'username' => 'root',
        'password' => '',
    ],
    'tenant' => [
        'prefix' => 'kl1',
    ],

    // Sekretny segment URL panelu: /admin/{admin_code}/
    'admin_code' => 'kl1-Qm84-ztP3',

    // Host tej strony = nazwa pliku (Config::load wg HTTP_HOST, bez portu).
    'website' => 'klient1.localhost',

    // Lokalne środowisko → http (produkcyjnie zmień na 'https').
    'website_scheme' => 'http',

    'theme' => 'basic',
    'debug' => true,
];

## MODEL MULTI-TENANT (opisz i uwzględnij)

- Front-end wybiera tenanta po polu `website` (string lub lista aliasów), NIE po nazwie
  pliku configu. Dzięki temu jeden plik configu może obsłużyć wiele aliasów domeny.
- Po stronie serwera WWW działa JEDEN „łapie-wszystko" (catch-all) VirtualHost Apache:
  ServerAlias * na porcie 80, document root ustawiony na katalog repo. Cały routing
  domen odbywa się w PHP (Config::load), nie w konfiguracji Apache.
- NOWA STRONA = tylko NOWY plik configs/<host>.php z polem `website`. Nie trzeba
  dodawać VirtualHosta ani restartować Apache — wystarczy plik configu (i wpis w DNS/
  hosts wskazujący domenę na serwer).
- _default.php to wspólna baza; per-tenant nadpisuje wybrane klucze (db, prefix,
  admin_code, theme, debug, website_scheme). Scalanie: array_replace_recursive.

## NOTA: hosts Windows + catch-all VirtualHost (uwzględnij krótko)

- Plik hosts Windows: C:\Windows\System32\drivers\etc\hosts — dopisz linię, np.:
    127.0.0.1    klient1.localhost
  (edytuj jako Administrator). Mapuje domenę testową na localhost.
- Apache: jeden catch-all VirtualHost na porcie 80 z ServerAlias * i DocumentRoot
  wskazującym katalog repo. Wszystkie hosty trafiają do tego samego index.php;
  rozróżnienie tenantów robi Config::load wg `website`.

## DANE WEJŚCIOWE (opcjonalne — zostaw przykładowe, jeśli brak)

Host przykładowego tenanta (pole `website` i sugerowana nazwa pliku configu):
> klient1.localhost

Prefiks tabel tenanta (tenant.prefix, 3 znaki):
> kl1

admin_code tenanta (sekretny segment URL panelu):
> kl1-Qm84-ztP3

Baza tenanta (database / username / password):
> klient1_db / root / (puste)

website_scheme tenanta ('http' lokalnie / 'https' produkcyjnie):
> http

## ZADANIE

1. Wygeneruj core/Config.php — wiernie wg sekcji SZABLON / KOD (pełny kod klasy).
2. Wygeneruj configs/_default.php — wiernie wg sekcji SZABLON / KOD (baza scalania).
3. Wygeneruj configs/<host>.php — na bazie wzoru i DANE WEJŚCIOWE; nazwij plik zgodnie
   z hostem (np. configs/klient1.localhost.php), a pole `website` ustaw na ten host.
4. Każdy plik poprzedź jedną linią-komentarzem ze ścieżką, np. "// === core/Config.php ===".
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] `Config::load('klient1.localhost')` ładuje config tenanta scalony z `_default` (array_replace_recursive).
- [ ] `Config::load('localhost')` oraz `Config::load('127.0.0.1')` trafiają w alias-tablicę `website` z `_default`.
- [ ] Port jest odcinany: `Config::load('localhost:93')` zachowuje się jak `Config::load('localhost')`.
- [ ] Nieznana domena w przeglądarce → HTTP 404; w CLI → `RuntimeException` z podpowiedzią o pliku configu.
- [ ] `Config::load('')` i `Config::load('_default')` ładują samą bazę `_default` (bootstrap/CLI).
- [ ] `Config::get('tenant')['prefix']` zwraca prefiks właściwego tenanta; `Config::get('admin_code')` — jego sekretny kod.
- [ ] Nowa strona = nowy plik `configs/<host>.php` (bez zmian w Apache); wpis w hosts Windows mapuje domenę na localhost.
- [ ] Klasa `Config` jest globalna (bez namespace), zgodna z bootstrapem z kroku 010.

## Powiązane
- [docs/architektura/architektura.md §4.1 (Config), §9 (Wzorzec multi-tenant)](../../architektura/architektura.md)
- [Poprzedni krok: 010 Fundamenty i bootstrap](010-fundamenty-i-bootstrap.md)
- [Następny krok: 030 Połączenie z bazą](030-polaczenie-z-baza.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
