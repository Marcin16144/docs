# Prompt 100: Powłoka panelu (AdminLTE, offline) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [090 admcore — wspólne funkcje](090-admcore-wspolne-funkcje.md) · Następny: [110 Podstrony panelu](110-podstrony-panelu.md) →

Ten krok odtwarza **powłokę interfejsu panelu administracyjnego**: wspólny layout AdminLTE (`admlayout.view.php`), ekran logowania (`admlogin.view.php`), globalne style i skrypt panelu (`admin/index.css`, `admin/index.js`) oraz katalog zasobów `admin/assets/` z lokalnie vendorowanymi AdminLTE / Bootstrap / jQuery / Font Awesome. Wymaga wcześniejszego `admin/index.php` (router + zmienne widoku) oraz `admcore.php` (funkcje `csrfToken()` itd.). Po tym kroku panel ma kompletny, działający OFFLINE szkielet UI: head z lokalnymi assetami, sidebar z listą domen, topbar z breadcrumbem i miejsce na widok podstrony.

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Ten krok nie ma `## DANE WEJŚCIOWE` — prompt jest samowystarczalny (zakłada strukturę z kroków 010–090).
3. Wklej do asystenta LLM. Otrzymasz: `admin/admlayout.view.php`, `admin/admlogin.view.php`, `admin/index.css`, `admin/index.js` oraz opis układu `admin/assets/`.
4. Zapisz pliki wg podanych **ŚCIEŻEK**. Pobierz i rozpakuj zvendorowane paczki do `admin/assets/` zgodnie z opisanym układem.
5. Zweryfikuj wg sekcji **Weryfikacja** poniżej (m.in. brak żądań do CDN w zakładce Network).

---

## PROMPT

```
Jesteś generatorem warstwy prezentacji panelu administracyjnego K2 CMS. Wygeneruj
POWŁOKĘ panelu: wspólny layout AdminLTE, ekran logowania, globalne style i skrypt,
oraz opisz układ katalogu zasobów vendorowanych lokalnie (offline, bez CDN).

## KONTEKST PROJEKTU

- K2 CMS — wielodomenowy CMS w PHP 8.1+. Panel działa pod sekretnym URL
  /admin/{admin_code}/ i jest ZAWSZE renderowany na konfiguracji _default
  (panel nie jest multi-tenant — to opisuje osobny krok bezpieczeństwa).
- Front controller panelu: admin/index.php. Po bootstrapie i autentykacji
  woła `require admcore.php` (funkcje globalne: csrfToken(), adminNotice(),
  listy danych), wykonuje backend podstrony `pages/<sekcja>/adm<strona>.php`,
  a na końcu renderuje powłokę: `require admlayout.view.php`.
- Stos UI VENDOROWANY LOKALNIE: AdminLTE (Bootstrap + jQuery + Font Awesome).
  WYMÓG OFFLINE: system działa BEZ internetu — ŻADEN zasób (CSS/JS/fonty/ikony/
  obrazy) nie jest pobierany z CDN ani zewnętrznego URL w runtime. Wszystko
  serwowane z admin/assets/.

## ŚCIEŻKI

- admin/admlayout.view.php   — wspólna powłoka (head + sidebar + topbar + treść + modal + footer)
- admin/admlogin.view.php    — ekran logowania (gdy użytkownik niezalogowany)
- admin/index.css            — globalne style panelu i ekranu logowania (statyczny, url() względne)
- admin/index.js             — globalny JS panelu (motywy + dostępność)
- admin/assets/              — katalog zasobów vendorowanych lokalnie

## KONWENCJE / ZASADY

1. ROZDZIAŁ PLIKÓW WIDOKU (obowiązuje w całym panelu):
     - adm<strona>.php        → backend (logika, zapytania, ustawia zmienne widoku)
     - adm<strona>.view.php   → TYLKO HTML (markup, echo zmiennych) — bez logiki
     - adm<strona>.viewjs.php → TYLKO skrypt JS danej podstrony
     - adm<strona>.viewcss.php→ TYLKO style CSS danej podstrony
   Powłoka (admlayout.view.php) dołącza widok podstrony przez
   `require __DIR__ . '/' . $pageView . '.view.php';`. Pliki *.view.php nigdy
   nie są dostępne bezpośrednio (blokada w root .htaccess: `\.view\.php$ → F`).

2. KAŻDY plik *.view.php zaczyna od strażnika:
       if (!defined('ROOT')) { http_response_code(404); exit; }
   To gwarantuje, że szablon nie zostanie wykonany poza front controllerem.

3. UKŁAD admin/assets/ (vendorowane lokalnie, zero CDN):
       admin/assets/
         adminlte/css/adminlte.min.css
         adminlte/js/adminlte.min.js
         bootstrap/css/bootstrap.min.css
         bootstrap/js/bootstrap.bundle.min.js
         jquery/jquery.min.js
         fontawesome/css/all.min.css
         fontawesome/webfonts/         (pliki .woff2 czcionek ikon)
         img/login-bg.jpg              (tło ekranu logowania)
   Kolejność ładowania CSS w <head>: fontawesome → bootstrap → adminlte → index.css.
   Kolejność JS przed </body>: jquery → bootstrap.bundle → adminlte → (utils) → index.js.

4. CACHE-BUSTING plików statycznych panelu: do własnych CSS/JS doklejaj
   `?v=<?= @filemtime(__DIR__ . '/<plik>') ?: '1' ?>` (vendorowane paczki bez wersji).

5. ZMIENNE WIDOKU przekazywane z admin/index.php do powłoki:
     $adminBase     — bazowy URL panelu (np. /admin/panel1), prefiks ścieżek assetów
     $page          — aktywny klucz podstrony (do podświetlenia menu)
     $pageView      — ścieżka pliku widoku (bez .view.php) do dołączenia
     $pageTitle     — tytuł podstrony (topbar + <title>)
     $pageIcon      — klasa ikony Font Awesome tytułu (może być '')
     $pageSubtitle  — podtytuł/breadcrumb w topbarze (HTML, może być '')
     $adminUser     — login zalogowanego (w topbarze)
     $theme         — 'light' | 'dark' (renderowane przez serwer, bez mignięcia)
     $themeClass    — dodatkowa klasa <body> (np. 'dark-mode', 'wcag-mode', '')
     $htmlClass     — dodatkowa klasa <html> (np. 'font-lg', 'font-xl', 'grayscale', '')
     $fontLevel     — 0|1|2 (etykieta A / A+ / A++)
     $canManageAccess — bool (czy pokazać sekcję Ustawienia/Backup)
     $navDomains    — lista domen do sidebara (rekordy z kolumnami DomID, DomCmsName)
     $extPlugins    — mapa wtyczek z ext/ (slug => ['name','icon','submenu'=>[...]])
   Ekran logowania (admlogin.view.php) używa: $adminBase, $loginError, $theme,
   $themeClass, $htmlClass, $fontLevel.

6. MOTYWY I DOSTĘPNOŚĆ (index.js): stan w ciasteczkach, klasy renderuje serwer:
     #theme-toggle — jasny ↔ ciemny  (body.dark-mode, cookie k2_theme; w dark dodaj data-bs-theme="dark" na <html>)
     #wcag-toggle  — tryb WCAG        (body.wcag-mode,  cookie k2_theme)
     #font-toggle  — A / A+ / A++     (html.font-lg / html.font-xl, cookie k2_font)
     #gray-toggle  — skala szarości   (html.grayscale,  cookie k2_gray)
   Ciasteczka: `path=/; max-age=31536000; samesite=lax`.

7. CSRF w widokach: każdy formularz POST zawiera ukryte pola
     <input type="hidden" name="_action" value="...">
     <input type="hidden" name="_csrf"   value="<?= htmlspecialchars(csrfToken()) ?>">
   Token JS-owy udostępnij globalnie: <script>window.K2_CSRF = <?= json_encode(csrfToken()) ?>;</script>.

## SZABLONY / KOD

### admlayout.view.php — szkielet powłoki (uzupełnij sidebar/topbar wg ZADANIA)
<?php
declare(strict_types=1);
use Core\Version;
/*
 * Panel K2 CMS — WSPÓLNA POWŁOKA (AdminLTE + Bootstrap).
 * Topbar, menu boczne, treść podstrony, modal globalny.
 * Zmienne z index.php: $adminBase, $page, $pageView, $pageTitle, $pageIcon,
 * $pageSubtitle, $adminUser, $theme, $themeClass, $htmlClass, $fontLevel,
 * $canManageAccess, $navDomains, $extPlugins.
 */
if (!defined('ROOT')) { http_response_code(404); exit; }
?>
<!doctype html>
<html lang="pl"<?= $htmlClass !== '' ? ' class="' . htmlspecialchars($htmlClass) . '"' : '' ?><?= $theme === 'dark' ? ' data-bs-theme="dark"' : '' ?>>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>K2 CMS — <?= htmlspecialchars($pageTitle) ?></title>
<link rel="stylesheet" href="<?= $adminBase ?>/assets/fontawesome/css/all.min.css">
<link rel="stylesheet" href="<?= $adminBase ?>/assets/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" href="<?= $adminBase ?>/assets/adminlte/css/adminlte.min.css">
<link rel="stylesheet" href="<?= $adminBase ?>/index.css?v=<?= @filemtime(__DIR__ . '/index.css') ?: '1' ?>">
</head>
<body class="layout-fixed sidebar-expand-lg<?= $themeClass !== '' ? ' ' . $themeClass : '' ?>">
<div class="app-wrapper">
    <!-- TOPBAR: hamburger (data-lte-toggle="sidebar"), tytuł+ikona, podtytuł,
         po prawej: przełączniki motywu/WCAG/font/szarości, login, formularz Wyloguj -->
    <!-- SIDEBAR: marka K2 (SVG logo) + menu: Pulpit; pętla $navDomains (treeview
         Menu/Strony/Galeria/Parametry); pętla $extPlugins; sekcja Console AI;
         sekcja Ustawienia (gdy $canManageAccess); sekcja System; stopka z wersją -->
    <!-- MAIN: <main class="app-main"><div class="app-content"><div class="container-fluid">
              require __DIR__ . '/' . $pageView . '.view.php'; </div></div></main> -->
</div>
<!-- Globalny modal potwierdzenia (#modal-k2confirm) z formularzem POST (_csrf + _action) -->
<script>window.K2_CSRF = <?= json_encode(csrfToken()) ?>;</script>
<script src="<?= $adminBase ?>/assets/jquery/jquery.min.js"></script>
<script src="<?= $adminBase ?>/assets/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<?= $adminBase ?>/assets/adminlte/js/adminlte.min.js"></script>
<script src="<?= $adminBase ?>/index.js?v=<?= @filemtime(__DIR__ . '/index.js') ?: '1' ?>"></script>
</body>
</html>

### admlogin.view.php — szkielet ekranu logowania (uzupełnij wg ZADANIA)
<?php
declare(strict_types=1);
/* Ekran logowania. Dołączany przez index.php, gdy użytkownik niezalogowany.
 * Zmienne: $adminBase, $loginError, $theme, $themeClass, $htmlClass, $fontLevel. */
if (!defined('ROOT')) { http_response_code(404); exit; }
/* Flaga „sesja wygasła" — pokaż raz i wyczyść. */
$sessionExpired = !empty($_SESSION['admin_session_expired']);
if ($sessionExpired) { unset($_SESSION['admin_session_expired']); }
?>
<!doctype html>
<html lang="pl"<?= $htmlClass !== '' ? ' class="' . $htmlClass . '"' : '' ?>>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>K2 CMS — logowanie</title>
<link rel="stylesheet" href="<?= $adminBase ?>/assets/fontawesome/css/all.min.css">
<link rel="stylesheet" href="<?= $adminBase ?>/assets/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" href="<?= $adminBase ?>/assets/adminlte/css/adminlte.min.css">
<link rel="stylesheet" href="<?= $adminBase ?>/index.css?v=<?= @filemtime(__DIR__ . '/index.css') ?: '1' ?>">
</head>
<body class="hold-transition login-page<?= $themeClass !== '' ? ' ' . $themeClass : '' ?>">
    <!-- .theme-controls: przyciski #theme-toggle / #wcag-toggle / #font-toggle / #gray-toggle -->
    <!-- .login-box > .card > .login-split: lewy .login-welcome (powitanie),
         prawy .login-panel z formularzem -->
    <!-- alerty: $sessionExpired (warning), $loginError (danger) -->
    <!-- <form method="post" autocomplete="off">: _action=login, _csrf, login, password,
         HONEYPOT w .a11y-offscreen aria-hidden, przycisk Zaloguj -->
<script src="<?= $adminBase ?>/assets/jquery/jquery.min.js"></script>
<script src="<?= $adminBase ?>/assets/bootstrap/js/bootstrap.bundle.min.js"></script>
<script src="<?= $adminBase ?>/assets/adminlte/js/adminlte.min.js"></script>
<script src="<?= $adminBase ?>/index.js?v=<?= @filemtime(__DIR__ . '/index.js') ?: '1' ?>"></script>
</body>
</html>

### Honeypot (pułapka na boty) — fragment formularza logowania
<!-- Pole poza ekranem, niewidoczne dla człowieka; boty wypełniają wszystkie pola.
     Wypełnione hp_phone → żądanie odrzucone (weryfikacja w index.php). -->
<div class="a11y-offscreen" aria-hidden="true">
    <label for="hp_phone">Phone</label>
    <input type="text" id="hp_phone" name="hp_phone" tabindex="-1" autocomplete="off">
</div>

### index.css — fragment kluczowych reguł (offline: url() WZGLĘDNE do admin/)
/* Tło logowania serwowane lokalnie — bez PHP, niezależnie od adresu panelu. */
.login-page { background: #dbe3f1; }
.login-page::before {
    content: ""; position: fixed; inset: 0;
    background: url('assets/img/login-bg.jpg') center / cover no-repeat;
}
/* Honeypot — pole poza ekranem (dostępne dla czytników, niewidoczne wizualnie). */
.a11y-offscreen {
    position: absolute !important; left: -9999px !important;
    width: 1px; height: 1px; overflow: hidden;
}

### index.js — szkielet (uzupełnij handlery wg ZADANIA)
/*
 * K2 CMS — opcje motywu i dostępności. Stan w ciasteczkach; klasy na <body>/<html>
 * renderuje serwer (index.php) przy ładowaniu — bez mignięcia. Ten skrypt obsługuje
 * przełączanie w locie: #theme-toggle, #wcag-toggle, #font-toggle, #gray-toggle.
 */
(function () {
    'use strict';
    var root = document.documentElement;
    var body = document.body;
    function setCookie(name, value) {
        document.cookie = name + '=' + value + '; path=/; max-age=31536000; samesite=lax';
    }
    function bind(id, handler) {
        var el = document.getElementById(id);
        if (el) { el.addEventListener('click', function (e) { e.preventDefault(); handler(); }); }
    }
    // applyTheme(theme): toggle body.dark-mode / body.wcag-mode,
    //   ustaw/usun data-bs-theme="dark" na <html>, podmień ikonę #theme-toggle i, zapis cookie k2_theme.
    // applyFont(level): html.font-lg / html.font-xl, etykieta #font-toggle .a11y-label, cookie k2_font.
    // applyGray(on): html.grayscale, cookie k2_gray.
})();

## ZADANIE

1. Wygeneruj kompletny `admin/admlayout.view.php`:
   - <html> z klasą z $htmlClass oraz data-bs-theme="dark" w trybie ciemnym; <title> z $pageTitle.
   - W <head> CSS w kolejności: fontawesome → bootstrap → adminlte → index.css (z cache-bustingiem).
   - TOPBAR (`.app-header navbar`): hamburger `data-lte-toggle="sidebar"`; tytuł z $pageIcon i $pageTitle;
     podtytuł z $pageSubtitle (gdy ≠ ''); po prawej przełączniki #theme-toggle/#wcag-toggle/#font-toggle/
     #gray-toggle, login $adminUser, formularz POST „Wyloguj" (_action=logout + _csrf).
   - SIDEBAR (`.app-sidebar`): marka K2 (inline SVG logo) + link do ?page=dashboard; menu:
       • „Pulpit" (active gdy $page==='dashboard'),
       • pętla po $navDomains → treeview z podpozycjami Menu nawigacyjne / Strony / Zdjęcia·pliki /
         Parametry (linki ?page=navigation|pages|gallery|gallery_params&id=<DomID>, klasa active/menu-open
         wg $page i $_GET['id']),
       • pętla po $extPlugins → pozycja z submenu (linki ?page=ext&plugin=<slug>&sub=<key>),
       • stała sekcja „Console AI" (?page=terminal),
       • sekcja „Ustawienia" TYLKO gdy $canManageAccess (Uprawnienia/Grupy/Domeny/Integracje AI/Integracje Search),
       • sekcja „System" (Diagnostyka, Zdarzenia, Kopia zapasowa[tylko $canManageAccess], Pomoc),
       • stopka `.sidebar-version`: „© <rok> K2 CMS v.<Version::full()>".
   - MAIN: dołącz widok podstrony przez `require __DIR__ . '/' . $pageView . '.view.php';`
     wewnątrz `.app-main > .app-content > .container-fluid`.
   - Globalny modal potwierdzenia `#modal-k2confirm` z formularzem POST (ukryte _csrf + _action).
   - Przed </body>: window.K2_CSRF, potem JS w kolejności jquery → bootstrap.bundle → adminlte → index.js (cache-busting).
2. Wygeneruj kompletny `admin/admlogin.view.php`: <head> jak wyżej; `.theme-controls`;
   `.login-box > .card > .login-split` (lewy `.login-welcome`, prawy `.login-panel`); alerty
   $sessionExpired i $loginError; formularz POST (_action=login, _csrf, login[autofocus], password)
   + HONEYPOT `.a11y-offscreen` (pole hp_phone); JS jak w layoucie.
3. Wygeneruj `admin/index.css`: style ekranu logowania (tło z assets/img/login-bg.jpg — url() WZGLĘDNE),
   `.a11y-offscreen` (pole poza ekranem), warianty motywów (.dark-mode, .wcag-mode) oraz `.font-lg`/`.font-xl`/
   `.grayscale` na <html>. ŻADNYCH adresów CDN ani absolutnych URL-i zewnętrznych.
4. Wygeneruj `admin/index.js`: przełączniki motywu/WCAG/rozmiaru tekstu/szarości wg sekcji KONWENCJE pkt 6,
   stan w ciasteczkach (path=/; max-age=31536000; samesite=lax).
5. Na końcu opisz w komentarzu wymagany układ katalogu `admin/assets/` (adminlte, bootstrap, jquery,
   fontawesome + webfonts, img) i zaznacz, że wszystkie paczki są vendorowane lokalnie (zero CDN).
6. Każdy plik poprzedź jedną linią-komentarzem ze ścieżką, np. „// === admin/admlayout.view.php ===".
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] Otwarcie panelu pod `/admin/{admin_code}/` renderuje powłokę AdminLTE: topbar, sidebar, treść.
- [ ] W zakładce Network przeglądarki NIE ma żadnych żądań do CDN ani zewnętrznych domen — wszystkie CSS/JS/fonty/obrazy ładują się z `/admin/assets/` i `/admin/index.{css,js}`.
- [ ] Działa offline (wyłączona sieć): style, ikony Font Awesome i przełączniki motywu nadal działają.
- [ ] `admlogin.view.php` zawiera honeypot `.a11y-offscreen` z polem `hp_phone` (poza ekranem, `aria-hidden`).
- [ ] Sidebar wyświetla „Pulpit", listę domen z `$navDomains` (treeview), Console AI, System; sekcja „Ustawienia" widoczna tylko gdy `$canManageAccess`.
- [ ] Każdy formularz POST w powłoce zawiera `_csrf` = `csrfToken()`; `window.K2_CSRF` dostępne w JS.
- [ ] Pliki `*.view.php` mają strażnik `if (!defined('ROOT'))` i są niedostępne bezpośrednio (403 z root .htaccess).
- [ ] Przełączniki motywu/WCAG/font/szarości zmieniają klasy `<body>`/`<html>` i zapisują ciasteczka `k2_theme`/`k2_font`/`k2_gray`.

## Powiązane
- [docs/architektura/architektura.md §6 (Panel administracyjny)](../../architektura/architektura.md)
- [Konwencja rozdziału plików widoku: view.php / viewjs.php / viewcss.php](../../architektura/architektura.md)
- [Poprzedni krok: 090 admcore — wspólne funkcje](090-admcore-wspolne-funkcje.md)
- [Następny krok: 110 Podstrony panelu](110-podstrony-panelu.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
