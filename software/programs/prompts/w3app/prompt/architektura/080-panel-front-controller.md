# Prompt 080: Panel — front controller (admin/index.php) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [070 Modele aplikacji (Appdb)](070-modele-aplikacji-appdb.md) · Następny: [090 admcore — wspólne funkcje](090-admcore-wspolne-funkcje.md) →

Ten krok odtwarza **punkt wejścia panelu administracyjnego** — front controller `admin/index.php` wraz z plikami `.htaccess`. Plik realizuje pełny bootstrap (autoload, `Config`, `Connection`, `Logger`), globalny bufor wyjścia z shutdown-guardem zwracającym JSON dla akcji AJAX, bezpieczne ciasteczko sesji, ZAWSZE ładowaną konfigurację `_default`, weryfikację sekretnego kodu URL przez `hash_equals()` (inaczej 404), nagłówki bezpieczeństwa HTTP/CSP, idle-timeout 3 h, weryfikację CSRF dla POST, akcje `login`/`logout` oraz routing podstron (`?page=…` → `pages/<sekcja>/adm<strona>.php`) zakończony renderem powłoki. Wymaga gotowego rdzenia (`core/Config.php`, `core/Connection.php`, `core/Version.php`, `core/db/` autoload, `Core\Log\Logger` z [060 Logger](060-logger.md)) i modeli aplikacji (z [070](070-modele-aplikacji-appdb.md), w szczególności `App\Appdb\Models\GroupsModel`).

## Jak używać
1. Upewnij się, że rdzeń (Config, Connection, Logger) i modele Appdb są gotowe (kroki 010–070).
2. Skopiuj blok **PROMPT** poniżej do asystenta LLM.
3. Asystent wygeneruje `admin/index.php`, `admin/.htaccess` oraz `admin/pages/.htaccess`.
4. Zapisz pliki wg podanych **ŚCIEŻEK**.
5. Zweryfikuj wg sekcji **Weryfikacja** (m.in. 404 dla błędnego kodu, 200 dla `/admin/{admin_code}/`).

---

## PROMPT

```
Jesteś generatorem warstwy wejścia panelu administracyjnego K2 CMS. Wygeneruj
FRONT CONTROLLER panelu (admin/index.php) oraz dwa pliki .htaccess. Plik index.php
ma być routerem: bootstrap → bezpieczeństwo → autentykacja → routing podstron → render.

## KONTEKST PROJEKTU

- K2 CMS — wielodomenowy CMS w PHP 8.1+ (declare(strict_types=1)).
- Panel administracyjny jest JEDEN, systemowy. NIE jest multi-tenant: działa
  ZAWSZE na konfiguracji `_default` (Config::load('_default')) NIEZALEŻNIE od
  domeny w adresie. (Publiczne strony wybiera się po domenie — ale to inny krok.)
- Panel jest dostępny WYŁĄCZNIE pod sekretnym adresem /admin/{admin_code}/, gdzie
  admin_code pochodzi z _default.php (klucz `admin_code`, domyślnie „panel1").
  Każda inna ścieżka — w tym samo /admin/ oraz /admin/index.php — zwraca 404.
- Ten SAM plik admin/.htaccess obsługuje wszystkie domeny; weryfikacja sekretu
  odbywa się w PHP (hash_equals), nie w regule rewrite.
- Każda podstrona to PARA plików w pages/<sekcja>/:
    adm<strona>.php       — backend (obsługa akcji POST + przygotowanie danych)
    adm<strona>.view.php  — treść osadzana w powłoce admlayout.view.php
  Wspólne funkcje są w admcore.php, wspólna powłoka w admlayout.view.php.
- Rdzeń dostępny: core/Config.php (Config::load/get), core/Connection.php
  (Connection::get → PDO), core/Version.php, autoload klas z core/db/,
  oraz Core\Log\Logger (registerHandlers/setUserId/get($kanal)->info|warn).
- Modele aplikacji: App\Appdb\Models\GroupsModel ze stałą ADMIN_GROUP_ID.

## ŚCIEŻKI

- admin/index.php        — front controller (router)
- admin/.htaccess        — rewrite całego ruchu pod admin/ do index.php
- admin/pages/.htaccess  — twardy zakaz bezpośredniego dostępu do plików podstron

## ZASADY I KOLEJNOŚĆ W index.php (ŚCIŚLE)

1. ob_start() jako PIERWSZA instrukcja po declare — globalny bufor wyjścia
   chroni odpowiedzi JSON przed wyciekiem PHP notice/warning.
2. register_shutdown_function: przy błędzie fatalnym (E_ERROR/E_PARSE/
   E_CORE_ERROR/E_COMPILE_ERROR) i akcji z WHITELISTY akcji AJAX (np.
   upload_photos, console_ai_send, ai_*_test_ajax…) — czyści bufor i zwraca
   czysty JSON {ok:false,error:…} zamiast HTML; inaczej nic nie robi.
3. define('ROOT', dirname(__DIR__)); require vendor/autoload.php; require
   core/Config.php, core/Connection.php, core/Version.php; spl_autoload_register
   ładujący klasy z core/db/<Class>.php.
4. Bezpieczne ciasteczko sesji — USTAWIONE PRZED session_start():
     - path liczony z dirname(SCRIPT_NAME) (jak $adminBase niżej),
     - lifetime=0, secure (tylko gdy HTTPS aktywne), httponly=true,
       samesite='Strict', ini_set('session.use_strict_mode','1').
   Następnie session_start().
5. Config::load('_default')  — ZAWSZE, niezależnie od HTTP_HOST. Po tym:
   jeśli Config::get('debug') → włącz display_errors + error_reporting(E_ALL).
6. Weryfikacja sekretnego kodu URL:
     $adminBase = rtrim(str_replace('\\','/', dirname(SCRIPT_NAME)), '/')
     $adminCode = (string)Config::get('admin_code','')
     $reqPath   = parse_url(REQUEST_URI, PHP_URL_PATH)
     $codeInUrl = rawurldecode(pierwszy segment ścieżki po $adminBase)
     if ($adminCode === '' || !hash_equals($adminCode, $codeInUrl)) → 404 i exit.
   Kanoniczny adres: $panelUrl = $adminBase.'/'.rawurlencode($adminCode).'/'.
7. Nagłówki bezpieczeństwa HTTP (po weryfikacji kodu, przed wyjściem HTML):
     X-Frame-Options: DENY
     X-Content-Type-Options: nosniff
     Referrer-Policy: strict-origin-when-cross-origin
     Permissions-Policy: camera=(), microphone=(), geolocation=()
     X-XSS-Protection: 0
     Strict-Transport-Security: max-age=31536000; includeSubDomains   (tylko HTTPS)
     Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline';
       style-src 'self' 'unsafe-inline'; img-src 'self' data: https://i.ytimg.com
       https://yt3.ggpht.com; font-src 'self'; connect-src 'self';
       frame-ancestors 'none'; form-action 'self'; object-src 'none'; base-uri 'self';
8. require __DIR__.'/admcore.php'  — wspólne funkcje panelu.
9. Logger::registerHandlers(); Logger::setUserId($_SESSION['admin_uid'] ?? null).
10. Idle-timeout 3 h: const SESSION_MAX_IDLE = 3*3600; jeśli zalogowany i
    (time()-admin_last_activity) > limit → zaloguj INFO, zniszcz sesję,
    session_start()+regenerate_id(true), ustaw $_SESSION['admin_session_expired'];
    inaczej odśwież admin_last_activity = time().
11. $action = $_POST['_action'] ?? $_GET['_action'] ?? ''.
12. Przepełnienie post_max_size (PRZED CSRF): gdy POST z pustym $_POST/$_FILES
    a CONTENT_LENGTH > iniSizeToBytes(post_max_size) — dla AJAX (X-Requested-With)
    zwróć ajaxJson({ok:false,error:'Plik za duży…'}); inaczej zostaw normalny tok.
13. CSRF: if (METHOD==='POST' && !csrfVerify()) → http_response_code(403); exit;
14. Akcja 'logout': log INFO, $_SESSION=[]; session_destroy(); redirect $panelUrl.
15. Akcja 'login' (gdy niezalogowany):
      - honeypot: pole hp_phone musi być puste (inaczej cichy błąd „Niepoprawny login lub hasło.”),
      - rate limit: loginIsBlocked($ip) → komunikat o blokadzie 15 min,
      - authenticate($login,$password); przy sukcesie: session_regenerate_id(true),
        loginClearFailures, ustaw $_SESSION['admin']=true, admin_user, admin_uid
        (z findActiveUser), admin_last_activity=time(); log INFO; redirect $panelUrl,
      - przy porażce: loginRecordFailure; log WARN; $loginError = komunikat.
16. Motyw (ciasteczko k2_theme: light|dark|wcag → klasa body) + dostępność
    (k2_font 0|1|2 → font-lg/font-xl, k2_gray='1' → grayscale → klasy <html>).
17. Niezalogowany: jeśli są parametry GET (np. ?page=…) → log WARN i redirect
    na czysty $panelUrl; inaczej require admlogin.view.php; exit.
18. Zalogowany — routing:
      - $currentUser = getUser($_SESSION['admin_uid']);
        $canManageAccess = (admin_user==='admin') ||
          ($currentUser['UseGroupID'] === GroupsModel::ADMIN_GROUP_ID);
      - $navDomains = listDomains();
      - mapy $pageFile[$page] i $pageTitles[$page] (patrz MAPA ROUTINGU niżej),
      - wtyczki z katalogu admin/ext/<slug>/init.php (zwraca [name,icon,submenu]),
        routing ?page=ext&plugin=…&sub=…,
      - $page = $_GET['page'] ?? 'dashboard'; nieznana strona → 'dashboard',
      - blokada sekcji wrażliwych (permissions, groups, domains, ai, backup) gdy
        !$canManageAccess: log WARN, $page='dashboard', $accessDenied=true,
      - $userNotice = adminNotice($_GET['un'] ?? ''),
      - require __DIR__.'/'.$pageFile[$page].'.php'   (backend podstrony),
      - require __DIR__.'/admlayout.view.php'         (render powłoki).

## MAPA ROUTINGU (?page= → plik backendu → tytuł)

  dashboard      pages/desktop/dashboard/admpulpit          Pulpit
  permissions    pages/settings/permissions/admuprawnienia  Uprawnienia
  groups         pages/settings/groups/admgrupy             Grupy
  domains        pages/settings/domains/admdomeny           Domeny
  ai             pages/settings/ai/admai                    Integracje AI
  aisearch       pages/settings/aisearch/admaisearch        Integracje Search
  terminal       pages/consoleai/terminal/admterminal       Console AI — Terminal
  navigation     pages/navigation/menu/admmenu              Menu nawigacyjne
  pages          pages/navigation/pages/admpages            Strony
  gallery        pages/gallery/admgallery                   Galeria zdjęć
  gallery_params pages/gallery/admgalleryparams             Parametry galerii
  system         pages/system/diagnostics/admsystem         System
  events         pages/system/events/admevent               Zdarzenia
  backup         pages/system/backup/admbackup              Kopia zapasowa
  help           pages/system/help/admhelp                  Pomoc

Layout dokleja sufiks „.view.php” do $pageView, więc backend ustawia $pageView
BEZ tego sufiksu (np. 'pages/gallery/admgallery').

## SZKIELET admin/index.php (ODTWÓRZ WIERNIE, w tej kolejności)

<?php
declare(strict_types=1);

ob_start();                                  // 1. bufor — pierwsza instrukcja

register_shutdown_function(static function (): void {   // 2. JSON guard dla AJAX
    $err = error_get_last();
    if ($err === null || !in_array($err['type'],
        [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR], true)) { return; }
    $action = $_POST['_action'] ?? $_GET['_action'] ?? '';
    $ajaxActions = [ /* WHITELISTA: upload_photos, upload_chunk, make_preview,
        photo_details, reorder_photos, music_*…, ai_*_test_ajax, ai_*_refresh_models,
        ai_prompt_*…, console_ai_*…, music_ytb_video_*… */ ];
    if (!in_array($action, $ajaxActions, true)) { return; }
    while (ob_get_level() > 0) { ob_end_clean(); }
    if (!headers_sent()) { header('Content-Type: application/json; charset=utf-8'); }
    echo json_encode(['ok' => false, 'error' => 'Błąd serwera: ' . ($err['message'] ?? 'nieznany błąd PHP')],
        JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);
});

use App\Appdb\Models\GroupsModel;
use Core\Log\Logger;

define('ROOT', dirname(__DIR__));            // 3. bootstrap
require ROOT . '/vendor/autoload.php';
require ROOT . '/core/Config.php';
require ROOT . '/core/Connection.php';
require ROOT . '/core/Version.php';
spl_autoload_register(static function (string $class): void {
    $path = ROOT . '/core/db/' . $class . '.php';
    if (is_file($path)) { require $path; }
});

$_sessionCookiePath = rtrim(                 // 4. ciasteczko sesji PRZED start
    str_replace('\\', '/', dirname((string)($_SERVER['SCRIPT_NAME'] ?? ''))), '/') . '/';
session_set_cookie_params([
    'lifetime' => 0,
    'path'     => $_sessionCookiePath,
    'secure'   => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    'httponly' => true,
    'samesite' => 'Strict',
]);
ini_set('session.use_strict_mode', '1');
unset($_sessionCookiePath);
session_start();

Config::load('_default');                    // 5. ZAWSZE _default, nie po HTTP_HOST
if (Config::get('debug', false)) {
    ini_set('display_errors', '1');
    ini_set('display_startup_errors', '1');
    error_reporting(E_ALL);
}

$adminBase = rtrim(str_replace('\\', '/', dirname((string)($_SERVER['SCRIPT_NAME'] ?? ''))), '/'); // 6.
$adminCode = (string)Config::get('admin_code', '');
$reqPath   = (string)(parse_url((string)($_SERVER['REQUEST_URI'] ?? ''), PHP_URL_PATH) ?: '');
$codeInUrl = rawurldecode(explode('/', ltrim((string)substr($reqPath, strlen($adminBase)), '/'))[0] ?? '');
if ($adminCode === '' || !hash_equals($adminCode, $codeInUrl)) {
    http_response_code(404);
    header('Content-Type: text/html; charset=utf-8');
    exit("<!doctype html>\n<title>404 Not Found</title>\n<h1>Not Found</h1>\n"
        . "<p>The requested URL was not found on this server.</p>\n");
}
$panelUrl = $adminBase . '/' . rawurlencode($adminCode) . '/';

header('X-Frame-Options: DENY');             // 7. nagłówki bezpieczeństwa + CSP
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: strict-origin-when-cross-origin');
header('Permissions-Policy: camera=(), microphone=(), geolocation=()');
header('X-XSS-Protection: 0');
if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
    header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
}
header("Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline'; "
    . "style-src 'self' 'unsafe-inline'; img-src 'self' data: https://i.ytimg.com https://yt3.ggpht.com; "
    . "font-src 'self'; connect-src 'self'; frame-ancestors 'none'; form-action 'self'; "
    . "object-src 'none'; base-uri 'self';");

require __DIR__ . '/admcore.php';            // 8. wspólne funkcje
Logger::registerHandlers();                  // 9. dziennik
Logger::setUserId(isset($_SESSION['admin_uid']) ? (string)$_SESSION['admin_uid'] : null);

const SESSION_MAX_IDLE = 3 * 3600;           // 10. idle-timeout 3 h
if (!empty($_SESSION['admin'])) {
    $lastActivity = (int)($_SESSION['admin_last_activity'] ?? 0);
    if ($lastActivity > 0 && (time() - $lastActivity) > SESSION_MAX_IDLE) {
        Logger::get('Auth')->info('Sesja wygasła (>3h bez aktywności): ' . (string)($_SESSION['admin_user'] ?? ''));
        $_SESSION = []; session_unset(); session_destroy();
        session_start(); session_regenerate_id(true);
        $_SESSION['admin_session_expired'] = true; Logger::setUserId(null);
    } else {
        $_SESSION['admin_last_activity'] = time();
    }
}

$loginError = null;
$action     = $_POST['_action'] ?? $_GET['_action'] ?? '';            // 11.

// 12. przepełnienie post_max_size → ajaxJson dla AJAX (przed CSRF)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && empty($_POST) && empty($_FILES)
    && !empty($_SERVER['CONTENT_LENGTH'])) {
    $postMaxB = iniSizeToBytes((string)ini_get('post_max_size'));
    if ($postMaxB > 0 && (int)$_SERVER['CONTENT_LENGTH'] > $postMaxB
        && strtolower((string)($_SERVER['HTTP_X_REQUESTED_WITH'] ?? '')) === 'xmlhttprequest') {
        ajaxJson(['ok' => false, 'error' => 'Plik za duży — przekracza limit serwera PHP (' . ini_get('post_max_size') . ').']);
    }
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !csrfVerify()) {         // 13. CSRF
    http_response_code(403); exit;
}

if ($action === 'logout') { /* … log + zniszcz sesję + redirect $panelUrl */ }   // 14.

if (!($_SESSION['admin'] ?? false) && $action === 'login') {         // 15. logowanie
    // honeypot hp_phone → loginIsBlocked($ip) → authenticate() → sukces/porażka
}

$loggedIn = (bool)($_SESSION['admin'] ?? false);
// 16. motyw + dostępność (k2_theme / k2_font / k2_gray) → $themeClass, $htmlClass

if (!$loggedIn) {                                                     // 17.
    if (!empty($_GET)) { /* log WARN gdy ?page */ header('Location: ' . $panelUrl); exit; }
    require __DIR__ . '/admlogin.view.php'; exit;
}

// 18. ROUTING — zalogowany
$adminUser       = (string)($_SESSION['admin_user'] ?? 'admin');
$currentUser     = getUser((string)($_SESSION['admin_uid'] ?? ''));
$canManageAccess = $adminUser === 'admin'
    || (string)($currentUser['UseGroupID'] ?? '') === GroupsModel::ADMIN_GROUP_ID;
$navDomains      = listDomains();
$pageFile   = [ /* mapa wg MAPY ROUTINGU */ ];
$pageTitles = [ /* mapa wg MAPY ROUTINGU */ ];
// wtyczki ext/, $page (fallback 'dashboard'), blokada sekcji wrażliwych gdy !$canManageAccess
$userNotice = adminNotice((string)($_GET['un'] ?? ''));
$pageTitle  = $pageTitles[$page];
$pageView   = $pageFile[$page];
require __DIR__ . '/' . $pageFile[$page] . '.php';     // backend podstrony
require __DIR__ . '/admlayout.view.php';               // render powłoki

## SZABLON admin/.htaccess

# Panel administracyjny — cały ruch pod admin/ obsługuje index.php.
# Realny adres panelu to admin/{admin_code}/ (kod z pliku konfiguracyjnego);
# index.php weryfikuje kod i dla każdej innej ścieżki zwraca 404.
RewriteEngine On
# Pliki panelu poza index.php (adm*.php — backendy, rdzeń, szablony) — niedostępne.
RewriteRule ^adm.*\.php$ - [F]
# Statyczne pliki (assets/…) oraz index.php — serwuj bezpośrednio.
RewriteCond %{REQUEST_FILENAME} -f
RewriteRule ^ - [L]
# Wszystko inne pod admin/ — przez index.php (z query string).
RewriteRule ^ index.php [QSA,L]

## SZABLON admin/pages/.htaccess

# Podstrony panelu (pages/<sekcja>/adm<strona>.php oraz .view.php) są dołączane
# przez index.php i nie mogą być wywoływane bezpośrednio z przeglądarki.
Require all denied

## ZADANIE

1. Wygeneruj kompletny admin/index.php wierny SZKIELETOWI powyżej, z PEŁNĄ
   logiką akcji login/logout (honeypot, rate limit, authenticate, session
   regenerate, logowanie zdarzeń), pełnymi mapami $pageFile/$pageTitles z MAPY
   ROUTINGU, routingiem wtyczek ext/ i blokadą sekcji wrażliwych.
2. Zachowaj DOKŁADNIE: ob_start() jako pierwszą instrukcję, shutdown JSON-guard
   z whitelistą akcji AJAX, Config::load('_default') (NIE po HTTP_HOST),
   weryfikację admin_code przez hash_equals z 404, komplet nagłówków + CSP,
   idle-timeout 3 h, CSRF dla POST.
3. Wygeneruj admin/.htaccess i admin/pages/.htaccess wg szablonów.
4. Każdy plik poprzedź jedną linią-komentarzem ze ścieżką, np.
   „// === admin/index.php ===” (dla .htaccess: „# === admin/.htaccess ===”).
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] `GET /admin/{admin_code}/` zwraca 200 i ekran logowania (gdy niezalogowany).
- [ ] `GET /admin/`, `/admin/index.php`, `/admin/zlykod/` zwracają 404 bez wskazówki (porównanie przez `hash_equals`).
- [ ] Panel renderuje się na konfiguracji `_default` niezależnie od domeny — `Config::load('_default')` (nie po `HTTP_HOST`).
- [ ] Każdy `POST` bez poprawnego `_csrf` zwraca 403 i pusty body; `csrfVerify()` loguje WARN do kanału `Auth`.
- [ ] Po 3 h bezczynności sesja jest niszczona, a ekran logowania pokazuje komunikat o wygaśnięciu (`admin_session_expired`).
- [ ] Po udanym logowaniu wywołane `session_regenerate_id(true)` i `loginClearFailures`; nagłówki bezpieczeństwa + CSP są obecne w odpowiedzi.
- [ ] Błąd fatalny przy akcji z whitelisty AJAX zwraca `{ok:false,error:…}` (Content-Type application/json), a nie HTML.
- [ ] Nieznane `?page=` przekierowuje do `dashboard`; sekcje wrażliwe bez `$canManageAccess` logują WARN i wracają na `dashboard`.
- [ ] Bezpośrednie wywołanie `pages/<sekcja>/adm<strona>.php` zwraca 403 (z `admin/pages/.htaccess`), a `adm*.php` w `admin/` zwraca 403 (reguła `[F]`).

## Powiązane
- [docs/architektura/architektura.md §6.1 (Punkt wejścia i routing)](../../architektura/architektura.md)
- [docs/architektura/architektura.md §10 (Bezpieczeństwo — sekretny URL, sesja, CSRF, nagłówki)](../../architektura/architektura.md)
- [Poprzedni krok: 070 Modele aplikacji (Appdb)](070-modele-aplikacji-appdb.md)
- [Następny krok: 090 admcore — wspólne funkcje](090-admcore-wspolne-funkcje.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
