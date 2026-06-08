# Prompt 110: Podstrony panelu (para adm<strona>.php + .view.php) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [100 Powłoka panelu (AdminLTE, offline)](100-layout-adminlte-offline.md) · Następny: [120 Galeria i media](120-galeria-i-media.md) →

Ten krok odtwarza **wzorzec podstrony panelu** — parę plików `pages/<sekcja>/adm<strona>.php` (backend: obsługa akcji POST z PRG, przygotowanie danych, ustawienie `$pageView`/`$pageTitle`/`$pageIcon`) oraz `adm<strona>.view.php` (czysty HTML osadzany w `admlayout.view.php`, odczyt powiadomień przez `adminNotice($_GET['un'])`). Uwzględnia konwencję rozdziału plików widoku: `view.php` (HTML), `viewjs.php` (skrypt), `viewcss.php` (style) — dołączane wewnątrz `.view.php`. Wymaga gotowego routera (`admin/index.php`, krok 080), wspólnych funkcji (`admcore.php`, krok 090) oraz powłoki (`admlayout.view.php`, krok 100).

## Jak używać
1. Upewnij się, że router, `admcore.php` i powłoka są gotowe (kroki 080–100).
2. Skopiuj blok **PROMPT** poniżej do asystenta LLM.
3. Wypełnij `## DANE WEJŚCIOWE` (sekcja, strona, klucz routingu, tytuł, akcje).
4. Asystent wygeneruje parę (lub trio: + viewjs/viewcss) plików podstrony.
5. Dopisz klucz routingu do map `$pageFile`/`$pageTitles` w `admin/index.php` i zweryfikuj wg sekcji **Weryfikacja**.

---

## PROMPT

```
Jesteś generatorem podstron panelu administracyjnego K2 CMS. Wygeneruj PARĘ
plików jednej podstrony: backend „adm<strona>.php” + widok „adm<strona>.view.php”
(opcjonalnie też adm<strona>.viewjs.php i adm<strona>.viewcss.php). Podstrona
osadza się w powłoce admlayout.view.php i działa w cyklu PRG (POST→Redirect→GET).

## KONTEKST PROJEKTU

- K2 CMS — wielodomenowy CMS w PHP 8.1+ (declare(strict_types=1)).
- Router admin/index.php po autentykacji wykonuje:
    require __DIR__ . '/' . $pageFile[$page] . '.php';   // backend podstrony
    require __DIR__ . '/admlayout.view.php';              // render powłoki
  Powłoka na końcu osadza treść:  require __DIR__ . '/' . $pageView . '.view.php';
  (layout DOKLEJA sufiks „.view.php”, więc backend ustawia $pageView BEZ niego).
- Przed dotarciem do backendu router już:
    • zweryfikował CSRF każdego POST (csrfVerify → 403),
    • ustawił $action = $_POST['_action'] ?? $_GET['_action'] ?? '',
    • ustawił $canManageAccess, $navDomains, $adminBase, $panelUrl,
    • ustawił $userNotice = adminNotice($_GET['un'] ?? '') i wstępny
      $pageTitle = $pageTitles[$page]; $pageView = $pageFile[$page].
- Wspólne funkcje z admcore.php dostępne w backendzie i widoku: csrfToken(),
  csrfVerify(), adminNotice(), renderNotice(), listy/CRUD danych, uuidv4(), itd.

## ŚCIEŻKI I KONWENCJA NAZW

- Backend:  admin/pages/<sekcja>/adm<strona>.php
- Widok:    admin/pages/<sekcja>/adm<strona>.view.php           — tylko HTML
- Skrypt:   admin/pages/<sekcja>/adm<strona>.viewjs.php         — tylko <script>
- Style:    admin/pages/<sekcja>/adm<strona>.viewcss.php        — tylko <style>
- Klucz routingu (?page=<klucz>) mapuje na 'pages/<sekcja>/adm<strona>' w index.php.

ROZDZIAŁ PLIKÓW WIDOKU (twardy wymóg projektu):
  • .view.php   zawiera WYŁĄCZNIE HTML (z osadzonym PHP do wypisywania danych),
  • .viewjs.php zawiera WYŁĄCZNIE blok <script> (logika UI, jQuery/AdminLTE),
  • .viewcss.php zawiera WYŁĄCZNIE blok <style>.
  viewjs/viewcss NIE są dołączane przez router — dołącza je samo .view.php:
    <?php require __DIR__ . '/adm<strona>.viewcss.php'; ?>   (na górze widoku)
    <?php require __DIR__ . '/adm<strona>.viewjs.php'; ?>    (na dole widoku)

## MAPA ROUTINGU (?page= → 'pages/<sekcja>/adm<strona>' → tytuł)

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

## ZASADY BACKENDU (adm<strona>.php)

1. Nagłówek: <?php declare(strict_types=1); + krótki komentarz (URL, akcje, zmienne do widoku).
2. STRAŻNIK na początku:
     if (!defined('ROOT')) { http_response_code(404); exit; }
   (plik nie może działać poza routerem; dodatkowo blokuje go pages/.htaccess).
3. Może nadpisać metadane podstrony: $pageIcon (np. 'fas fa-images'),
   $pageSubtitle (dopuszczalny HTML), a dla podstron dynamicznych — $pageTitle.
4. Obsługa akcji POST wg $action. Każdy handler mutujący stosuje PRG:
     if ($action === 'create_x') {
         // (CSRF już zweryfikowany w routerze; krytyczne handlery AJAX mogą
         //  dodatkowo wołać csrfVerify()/csrfGuardOrFail())
         $notice = createX(...);                         // funkcja z admcore zwraca kod notice
         header('Location: ' . $redirect . '&un=' . urlencode($notice));
         exit;                                            // REDIRECT — przeglądarka robi GET
     }
   Dla żądań AJAX zamiast redirectu: ajaxJson(['ok'=>true, …]) / ajaxJson(['ok'=>false,'error'=>…]).
5. Przygotowanie danych do widoku (listy/rekordy z admcore: listX(), getX(), …).
6. Na końcu USTAW: $pageView = 'pages/<sekcja>/adm<strona>'; (BEZ sufiksu .view.php).

## ZASADY WIDOKU (adm<strona>.view.php)

1. Nagłówek: <?php declare(strict_types=1); + komentarz z listą zmiennych z backendu.
2. STRAŻNIK: if (!defined('ROOT')) { http_response_code(404); exit; }
3. Tylko HTML + osadzone PHP do wypisywania danych; escape przez htmlspecialchars().
4. Powiadomienie PRG na górze treści:
     <?php renderNotice($userNotice); ?>        // $userNotice = adminNotice($_GET['un'])
   (router ustawia $userNotice; backond może go nadpisać własnym [typ, treść]).
5. Każdy formularz POST zawiera ukryte pola:
     <input type="hidden" name="_csrf"   value="<?= htmlspecialchars(csrfToken()) ?>">
     <input type="hidden" name="_action" value="create_x">
6. Jeśli istnieją: na górze <?php require __DIR__ . '/adm<strona>.viewcss.php'; ?>,
   na dole   <?php require __DIR__ . '/adm<strona>.viewjs.php'; ?>.

## SZABLON — backend (adm<strona>.php)

<?php

declare(strict_types=1);

/*
 * Podstrona <Tytuł> — backend (kontroler).
 * URL: ?page=<klucz>[&id=<…>]
 * Akcje (POST): <akcja_1> — …, <akcja_2> — …
 * Zmienne do widoku:
 *   ?array  $userNotice   komunikat PRG
 *   array   $rows         dane do tabeli
 *   ?array  $editRow      rekord w trybie edycji (lub null)
 */

if (!defined('ROOT')) {
    http_response_code(404);
    exit;
}

$pageIcon = '<IKONA_FA>';                      // np. 'fas fa-list'
$redirect = $panelUrl . '?page=<klucz>';       // baza przekierowań PRG

/* ── POST: utwórz ─────────────────────────────────────────────── */
if ($action === 'create_x') {
    $name   = trim((string)($_POST['name'] ?? ''));
    $notice = create<Encja>($name /*, … */);   // funkcja z admcore → kod notice
    header('Location: ' . $redirect . '&un=' . urlencode($notice));
    exit;
}

/* ── POST: usuń ───────────────────────────────────────────────── */
if ($action === 'delete_x') {
    delete<Encja>((string)($_POST['id'] ?? ''));
    header('Location: ' . $redirect . '&un=deleted');
    exit;
}

/* ── Dane do widoku ───────────────────────────────────────────── */
$rows    = list<Encja>();
$editRow = isset($_GET['edit']) ? get<Encja>((string)$_GET['edit']) : null;

$pageView = 'pages/<sekcja>/adm<strona>';      // BEZ sufiksu .view.php

## SZABLON — widok (adm<strona>.view.php)

<?php

declare(strict_types=1);

/*
 * Podstrona <Tytuł> — WIDOK (HTML osadzany w admlayout.view.php).
 * Zmienne: ?array $userNotice, array $rows, ?array $editRow
 */

if (!defined('ROOT')) {
    http_response_code(404);
    exit;
}

?>
<?php require __DIR__ . '/adm<strona>.viewcss.php'; ?>   <!-- jeśli istnieje -->

<?php renderNotice($userNotice); ?>

<div class="card">
    <div class="card-header"><h3 class="card-title"><?= htmlspecialchars($pageTitle) ?></h3></div>
    <div class="card-body">
        <table class="table table-striped">
            <thead><tr><th>Nazwa</th><th></th></tr></thead>
            <tbody>
            <?php foreach ($rows as $row): ?>
                <tr>
                    <td><?= htmlspecialchars((string)$row['<Pre>Name']) ?></td>
                    <td class="text-end">
                        <form method="post" class="d-inline">
                            <input type="hidden" name="_csrf"   value="<?= htmlspecialchars(csrfToken()) ?>">
                            <input type="hidden" name="_action" value="delete_x">
                            <input type="hidden" name="id"      value="<?= htmlspecialchars((string)$row['<Pre>ID']) ?>">
                            <button class="btn btn-sm btn-danger">Usuń</button>
                        </form>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>

        <form method="post" class="mt-3">
            <input type="hidden" name="_csrf"   value="<?= htmlspecialchars(csrfToken()) ?>">
            <input type="hidden" name="_action" value="create_x">
            <div class="input-group">
                <input type="text" name="name" class="form-control" placeholder="Nazwa" required>
                <button class="btn btn-primary">Dodaj</button>
            </div>
        </form>
    </div>
</div>

<?php require __DIR__ . '/adm<strona>.viewjs.php'; ?>    <!-- jeśli istnieje -->

## SZABLON — skrypt (adm<strona>.viewjs.php, opcjonalny)

                <script>
                document.addEventListener('DOMContentLoaded', function () {
                    if (typeof jQuery === 'undefined') return;
                    var $ = jQuery;
                    // logika UI: modale edycji, potwierdzenia, AJAX (z window.K2_CSRF)
                });
                </script>

## SZABLON — style (adm<strona>.viewcss.php, opcjonalny)

                <style>
                /* style lokalne podstrony */
                </style>

## DANE WEJŚCIOWE

Sekcja (folder w admin/pages/, np. settings, system, navigation, gallery):
> <WPISZ_SEKCJE>

Nazwa pliku strony bez prefiksu „adm” i bez rozszerzenia (np. „grupy”, „domeny”):
> <WPISZ_STRONE>

Klucz routingu (?page=…, np. „groups”, „domains”):
> <WPISZ_KLUCZ>

Tytuł podstrony (widoczny w topbarze, np. „Grupy”):
> <WPISZ_TYTUL>

Ikona Font Awesome (np. „fas fa-users”) lub brak:
> <WPISZ_IKONE>

Encja i funkcje admcore do użycia (np. listGroups/createGroup/deleteGroup; prefiks kolumn Gro):
> <WPISZ_ENCJE_I_FUNKCJE>

Akcje POST (każda: nazwa _action → opis efektu + kod notice):
> <WPISZ_AKCJE>

Czy generować viewjs.php / viewcss.php (tak/nie dla każdego):
> <WPISZ_TAK_NIE>

## ZADANIE

1. Wygeneruj backend adm<strona>.php wg SZABLONU: strażnik ROOT, $pageIcon,
   handlery akcji z DANE WEJŚCIOWE w cyklu PRG (header Location + exit; AJAX →
   ajaxJson), przygotowanie danych, na końcu $pageView = 'pages/<sekcja>/adm<strona>'.
2. Wygeneruj widok adm<strona>.view.php wg SZABLONU: strażnik ROOT,
   renderNotice($userNotice) na górze, HTML z escapowaniem htmlspecialchars(),
   formularze z ukrytymi _csrf (csrfToken()) i _action.
3. Jeśli zaznaczono w DANE WEJŚCIOWE — wygeneruj adm<strona>.viewjs.php
   (tylko <script>) i/lub adm<strona>.viewcss.php (tylko <style>) i dołącz je
   z .view.php (viewcss na górze, viewjs na dole). NIE umieszczaj <script>/<style>
   bezpośrednio w .view.php.
4. Dopisz w komentarzu instrukcję rejestracji klucza routingu w mapach
   $pageFile/$pageTitles w admin/index.php.
5. Każdy plik poprzedź jedną linią-komentarzem ze ścieżką, np.
   „// === admin/pages/<sekcja>/adm<strona>.php ===”.
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] Backend `adm<strona>.php` i widok `adm<strona>.view.php` mają strażnik `if (!defined('ROOT')) { http_response_code(404); exit; }` i są niedostępne bezpośrednio (403 z `admin/pages/.htaccess`).
- [ ] Backend ustawia `$pageView` BEZ sufiksu `.view.php` (np. `'pages/system/diagnostics/admsystem'`); powłoka dokleja sufiks przy `require`.
- [ ] Każdy handler mutujący kończy się `header('Location: …&un=<kod>'); exit;` (PRG); żądania AJAX zwracają `ajaxJson()` zamiast redirectu.
- [ ] Widok wypisuje powiadomienie przez `renderNotice($userNotice)`, gdzie `$userNotice = adminNotice($_GET['un'])`; nieznany kod `un` nie pokazuje alertu.
- [ ] Każdy formularz POST zawiera `_csrf = csrfToken()` oraz `_action`; dane wyjściowe escapowane przez `htmlspecialchars()`.
- [ ] `.view.php` zawiera tylko HTML; ewentualny JS jest w `adm<strona>.viewjs.php`, a CSS w `adm<strona>.viewcss.php` — dołączane wewnątrz `.view.php` (viewcss na górze, viewjs na dole), nie przez router.
- [ ] Klucz routingu dodany do `$pageFile` i `$pageTitles` w `admin/index.php`; `?page=<klucz>` renderuje podstronę w powłoce.

## Powiązane
- [docs/architektura/architektura.md §6.1 (Mapa routingu)](../../architektura/architektura.md)
- [docs/architektura/architektura.md §6.3–6.4 (Cykl żądania GET / POST PRG)](../../architektura/architektura.md)
- [docs/architektura/architektura.md §6.5 (System powiadomień adminNotice)](../../architektura/architektura.md)
- [Konwencja rozdziału plików widoku: view.php / viewjs.php / viewcss.php](../../architektura/architektura.md)
- [Poprzedni krok: 100 Powłoka panelu (AdminLTE, offline)](100-layout-adminlte-offline.md)
- [Następny krok: 120 Galeria i media](120-galeria-i-media.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
