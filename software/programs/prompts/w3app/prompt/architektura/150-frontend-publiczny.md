# Prompt 150: Front-end publiczny (multi-tenant po domenie) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [140 Bezpieczeństwo panelu](140-bezpieczenstwo.md) · To ostatni krok serii.

Ten krok odtwarza **publiczny front-end** K2 CMS: root `index.php` jako front controller, który ładuje konfigurację dopasowaną po domenie (`Config::load($_SERVER['HTTP_HOST'])`), warstwę silnika strony w `app/Web/` (namespace `App\Web`, klasa `Site`) oraz szkielet motywów w `layout/`. Wymaga wcześniejszego `core/Config.php` (dopasowanie po polu `website`) i `core/Connection.php`. Po tym kroku jedna instalacja obsługuje wiele publicznych stron rozpoznawanych po domenie — a panel administracyjny pozostaje osobny i zawsze na `_default`.

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Ten krok nie ma `## DANE WEJŚCIOWE` — prompt jest samowystarczalny (zakłada `Config`/`Connection` z wcześniejszych kroków).
3. Wklej do asystenta LLM. Otrzymasz: docelowy root `index.php` (router publiczny), `app/Web/Site.php`, szkielet `layout/<motyw>/` oraz przykładowy `configs/<host>.php`.
4. Zapisz pliki wg podanych **ŚCIEŻEK**. Nowa strona = nowy plik `configs/<host>.php` z polem `website` (bez zmian w Apache).
5. Zweryfikuj wg sekcji **Weryfikacja** poniżej.

---

## PROMPT

```
Jesteś generatorem publicznego front-endu (warstwy prezentacji stron) silnika
K2 CMS. Wygeneruj docelowy root index.php (front controller publiczny), klasę
App\Web\Site oraz szkielet motywu w layout/. Front-end jest multi-tenant po
DOMENIE; panel administracyjny to osobna warstwa (zawsze na _default).

## KONTEKST PROJEKTU

- K2 CMS — wielodomenowy CMS w PHP 8.1+. Jedna instalacja obsługuje wiele
  publicznych stron; każda rozpoznawana jest po DOMENIE żądania.
- `core/Config.php` jest już zaimplementowany. `Config::load($host)` NIE wybiera
  configu po nazwie pliku, lecz skanuje configs/*.php i dopasowuje po polu `website`
  (string LUB lista aliasów, np. ['localhost','127.0.0.1']); port jest pomijany.
  `_default.php` jest zawsze bazą scalania (array_replace_recursive); config konkretnej
  strony nadpisuje _default. BRAK dopasowania domeny → 404 (web) / wyjątek (CLI).
- `core/Connection.php` to singleton PDO (Connection::get()).
- ROZDZIAŁ ODPOWIEDZIALNOŚCI:
    • FRONT-END PUBLICZNY: multi-tenant — wybór strony po domenie (Config::load(HTTP_HOST)).
    • PANEL ADMINISTRACYJNY: ZAWSZE na _default (NIE multi-tenant) — opisany w osobnym kroku.
- WYMÓG OFFLINE: zasoby motywów vendorowane lokalnie, bez CDN.

## ŚCIEŻKI

- index.php                       — root front controller publiczny (docelowy, zastępuje zaślepkę bootstrap)
- app/Web/Site.php                — klasa App\Web\Site (dostęp do danych bieżącej strony)
- layout/<motyw>/                 — szablony konkretnego motywu (np. layout/default/)
- layout/config/                  — ustawienia warstwy layoutu (NIE configi stron)
- configs/<host>.php              — config nowej strony (pole `website` dopasowywane do domeny)

## KONWENCJE / ZASADY

1. NAMESPACE FRONT-ENDU: klasy silnika strony są pod `App\Web` (folder app/Web/),
   ładowane przez PSR-4 (`App\` → app/). NIE twórz nowego root-folderu na te klasy.
2. SZABLONY/MOTYWY: w layout/. Każdy motyw to podfolder (layout/default/, layout/basic/…)
   ze swoimi widokami i zasobami. Motyw strony wskazuje klucz `theme` w jej configu,
   odczytywany przez `App\Web\Site::theme()`. Folder `layout/config/` to ustawienia
   SAMEJ warstwy layoutu — NIE wybór tenanta (configi STRON pozostają w configs/).
3. KLASA App\Web\Site (czytelny dostęp do danych już załadowanej konfiguracji):
     website()      — domena strony (gdy `website` jest listą → pierwszy alias)
     scheme()       — 'http' lub 'https' z klucza `website_scheme` (domyślnie 'https')
     baseUrl()      — scheme() . '://' . website()
     theme()        — klucz `theme` (domyślnie 'default') → folder w layout/
     tenantPrefix() — prefiks tabel z Config::get('tenant')['prefix']
   Site czyta z globalnej klasy \Config (już załadowanej w index.php). Nie ładuje nic sam.
4. ROOT index.php (publiczny front controller):
     - define('ROOT', __DIR__); require vendor/autoload; require core/Config.php;
       require core/Connection.php; spl_autoload_register dla core/db/<Class>.php.
     - Config::load($_SERVER['HTTP_HOST']) — przy nieznanej domenie Config sam zwraca
       404 (web), więc poniżej kod wykonuje się tylko dla rozpoznanej strony.
     - Wybór motywu: $theme = App\Web\Site::theme(); dołącz layout/<theme>/index.php
       (lub front kontroler motywu). Fallback do 'default', gdy folder motywu nie istnieje.
     - Połączenie z bazą leniwie: Connection::get() (tylko gdy strona go potrzebuje).
5. NOWA STRONA = nowy plik configs/<host>.php z polem `website` => '<host>' (lub listą
   aliasów). BEZ zmian w konfiguracji Apache — jeden catch-all VirtualHost kieruje
   wszystkie domeny do tego samego root index.php; rozróżnienie robi Config po `website`.

## SZABLONY / KOD

### app/Web/Site.php (docelowo)
<?php
declare(strict_types=1);
namespace App\Web;
/**
 * Bieżąca strona (tenant) rozpoznana po domenie. Konfiguracja jest już
 * załadowana w index.php przez Config::load($_SERVER['HTTP_HOST']).
 */
final class Site
{
    public static function website(): string
    {
        $w = \Config::get('website', '');
        if (is_array($w)) { $w = $w[0] ?? ''; }
        return (string) $w;
    }
    public static function scheme(): string
    {
        return \Config::get('website_scheme', 'https') === 'http' ? 'http' : 'https';
    }
    public static function baseUrl(): string
    {
        return self::scheme() . '://' . self::website();
    }
    public static function theme(): string
    {
        return (string) \Config::get('theme', 'default');
    }
    public static function tenantPrefix(): string
    {
        return (string) (\Config::get('tenant')['prefix'] ?? '');
    }
}

### index.php — szkielet front controllera (uzupełnij wg ZADANIA)
<?php
declare(strict_types=1);
define('ROOT', __DIR__);
require ROOT . '/vendor/autoload.php';
require ROOT . '/core/Config.php';
require ROOT . '/core/Connection.php';
spl_autoload_register(static function (string $class): void {
    $path = ROOT . '/core/db/' . $class . '.php';
    if (is_file($path)) { require $path; }
});
// Dopasowanie strony po domenie. Nieznana domena → Config zwraca 404 i kończy.
Config::load($_SERVER['HTTP_HOST']);
// Stąd: strona rozpoznana. Wybór motywu i render przez layout/<motyw>/.
// $theme = \App\Web\Site::theme(); fallback 'default'; require layout/<theme>/index.php

### configs/<host>.php — przykład nowej strony
<?php
return [
    'website'        => 'klient1.localhost',   // lub ['klient1.localhost', 'www.klient1.localhost']
    'website_scheme' => 'https',               // 'http' lokalnie
    'tenant'         => ['prefix' => 'kl1'],
    'theme'          => 'default',
    'admin_code'     => '<unikatowy-sekretny-kod>',
    // pozostałe klucze dziedziczone z _default.php (db, gallery, …)
];

### layout/<motyw>/ — szkielet (np. layout/default/)
layout/
  config/                # ustawienia warstwy layoutu (wspólne parametry motywów)
  default/
    index.php            # front kontroler motywu (render strony)
    partials/            # nagłówek, stopka, nawigacja
    assets/              # CSS/JS/obrazy motywu — vendorowane lokalnie (bez CDN)

## ZADANIE

1. Wygeneruj docelowy root `index.php`:
   - bootstrap jak w szablonie (ROOT, autoload, Config, Connection, spl_autoload_register);
   - `Config::load($_SERVER['HTTP_HOST'])` — pamiętaj, że przy nieznanej domenie Config sam
     zwraca 404, więc dalszy kod dotyczy wyłącznie rozpoznanej strony;
   - ustal motyw przez `\App\Web\Site::theme()` z fallbackiem do 'default' (gdy folder
     layout/<motyw>/ nie istnieje) i dołącz front kontroler motywu (layout/<motyw>/index.php);
   - połączenie z bazą leniwie (Connection::get() tylko gdy potrzebne).
2. Wygeneruj `app/Web/Site.php` dokładnie wg szablonu (namespace App\Web; metody
   website/scheme/baseUrl/theme/tenantPrefix; czyta z globalnej \Config).
3. Wygeneruj szkielet `layout/default/`: index.php (prosty render: <html> z baseUrl/website,
   dołączenie partiali), partials/header.php, partials/footer.php oraz layout/config/.gitkeep.
   Zasoby motywu vendorowane lokalnie — bez CDN.
4. Wygeneruj przykładowy `configs/klient1.localhost.php` z polem `website` i nadpisaniami
   (tenant.prefix, theme, admin_code) — reszta dziedziczona z _default.php.
5. W komentarzu wyjaśnij rozdział: front-end multi-tenant po domenie vs panel zawsze na _default,
   oraz że NOWA strona = nowy plik configs/<host>.php (bez zmian w Apache — jeden catch-all VirtualHost).
6. Każdy plik poprzedź jedną linią-komentarzem ze ścieżką, np. „// === index.php ===".
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] Żądanie znanej domeny (pole `website` w jakimś `configs/*.php`) renderuje stronę przez `layout/<motyw>/`.
- [ ] Żądanie NIEznanej domeny zwraca 404 („No site configured for this domain.") — bezpośrednio z `Config::load()`.
- [ ] Domena dopasowywana po POLU `website` (string lub lista aliasów), nie po nazwie pliku configu; port jest pomijany.
- [ ] `App\Web\Site` znajduje się w `app/Web/Site.php` (namespace `App\Web`, ładowany przez PSR-4 `App\` → `app/`).
- [ ] `Site::scheme()` zwraca 'https' domyślnie; `Site::baseUrl()` = scheme + '://' + website.
- [ ] `Site::theme()` wybiera folder w `layout/`; brak folderu motywu → fallback do `default`.
- [ ] Dodanie nowej strony to wyłącznie nowy `configs/<host>.php` z polem `website` — bez zmian w konfiguracji Apache (catch-all VirtualHost).
- [ ] Front-end jest multi-tenant po domenie, a panel admin pozostaje osobny i zawsze na `_default`.
- [ ] Zasoby motywu serwowane lokalnie — w zakładce Network brak żądań do CDN.

## Powiązane
- [docs/architektura/architektura.md §9 (Wzorzec multi-tenant)](../../architektura/architektura.md)
- [docs/architektura/architektura.md §4.1 (Config)](../../architektura/architektura.md)
- [layout/README.md (struktura motywów)](../../../layout/README.md)
- [Poprzedni krok: 140 Bezpieczeństwo panelu](140-bezpieczenstwo.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
