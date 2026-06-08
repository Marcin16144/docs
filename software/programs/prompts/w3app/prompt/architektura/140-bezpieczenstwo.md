# Prompt 140: Bezpieczeństwo panelu (wielowarstwowa ochrona) — odbudowa od zera

> Seria „Odbudowa K2 CMS od zera". ← Poprzedni: [130 Kopie zapasowe](130-kopie-zapasowe.md) · Następny: [150 Front-end publiczny](150-frontend-publiczny.md) →

Ten krok to **checklista-prompt** wdrażający (lub audytujący) wielowarstwową ochronę panelu administracyjnego K2 CMS opisaną w `architektura.md §10`. Każda warstwa działa niezależnie — kompromitacja jednej nie obala pozostałych. Wymaga wcześniejszego `admin/index.php` (front controller) oraz `admcore.php` (funkcje `csrfToken()`, `csrfVerify()`, `authenticate()`, `loginIsBlocked()`, rejestrator `Logger`). Po tym kroku panel ma: sekretny URL z `hash_equals()`, bcrypt + bootstrap admin, twardą sesję, CSRF, rate limiting, nagłówki HTTP/CSP, honeypot, autoryzację `canManageAccess` i pełne logowanie zdarzeń.

## Jak używać
1. Skopiuj zawartość bloku **PROMPT** poniżej.
2. Ten krok nie ma `## DANE WEJŚCIOWE` — działa na istniejącym `admin/index.php` + `admcore.php`.
3. Wklej do asystenta LLM. W trybie WDROŻENIA otrzymasz uzupełniony `admin/index.php` i funkcje w `admcore.php`; w trybie AUDYTU — raport zgodności z checklistą 10.1–10.9.
4. Zastosuj zmiany i ustaw produkcyjne wartości (`admin_code`, `secure` cookie pod HTTPS).
5. Zweryfikuj wg sekcji **Weryfikacja** poniżej.

---

## PROMPT

```
Jesteś inżynierem bezpieczeństwa odtwarzającym wielowarstwową ochronę panelu
administracyjnego K2 CMS. Zaimplementuj (lub zaudytuj) warstwy 10.1–10.9 w
admin/index.php i admin/admcore.php. Traktuj poniższe punkty jako WYMAGANIA
i jednocześnie PUNKTY WERYFIKACJI.

## KONTEKST PROJEKTU

- PHP 8.1+. Panel pod sekretnym URL /admin/{admin_code}/. Front controller:
  admin/index.php; funkcje wspólne: admin/admcore.php; rejestrator: Core\Log\Logger.
- Panel jest ZAWSZE renderowany na konfiguracji _default (NIE jest multi-tenant):
  `admin_code`, parametry sesji i tabele (`<tenant>_users`, `<tenant>_login_attempts`)
  pochodzą z konfiguracji _default. (Front-end publiczny jest multi-tenant po domenie —
  to osobny krok.)
- Hasła: bcrypt (password_hash/password_verify). Logger ma kanały i poziomy
  (TRACE<DEBUG<INFO<WARN<ERROR<FATAL); zdarzenia bezpieczeństwa → kanał Auth/System.

## ŚCIEŻKI

- admin/index.php    — bootstrap, sesja, weryfikacja kodu, nagłówki, akcje login/logout, routing
- admin/admcore.php  — csrfToken(), csrfVerify(), loginIsBlocked()/loginRecordFailure()/
                       loginClearFailures(), authenticate(), findActiveUser(), touchLastLogin()

## WARSTWY OCHRONY (kolejność jak w przepływie żądania)

### 10.1 Sekretny adres URL panelu
- Panel działa wyłącznie pod /admin/{admin_code}/. `admin_code` z konfiguracji _default.
- Porównanie kodu z URL przez `hash_equals($adminCode, $codeInUrl)` (stały czas — bez timing attack).
- Pusty `admin_code` lub niezgodność → HTTP 404 BEZ WSKAZÓWKI (zwykła strona „Not Found",
  bez ujawniania, że panel istnieje). Przykład:
      $adminCode = (string)Config::get('admin_code', '');
      if ($adminCode === '' || !hash_equals($adminCode, $codeInUrl)) {
          http_response_code(404);
          header('Content-Type: text/html; charset=utf-8');
          exit("<!doctype html>\n<title>404 Not Found</title>\n<h1>Not Found</h1>");
      }
- Zalecenie: admin_code min. 20 losowych znaków (`openssl rand -base64 18`).

### 10.2 Uwierzytelnianie (bcrypt + konto bootstrap)
- `authenticate($login, $password)` → `password_verify()` na bcrypt-hashu z `<t>_users`.
- Flaga `UseIsActive`: konto nieaktywne nie loguje się (`findActiveUser()` filtruje aktywne).
- `touchLastLogin()` aktualizuje `UseLastLogin` po udanym logowaniu (audyt).
- KONTO BOOTSTRAP `admin`:
    • `<t>_users` PUSTA  → konto serwisowe `admin` / hasło `admin{rok}` działa; przy
      pierwszym udanym logowaniu zakładane jest w bazie.
    • `<t>_users` NIEPUSTA → konto serwisowe wyłączone; działa tylko autentykacja z BD.

### 10.3 Ochrona sesji
- SESSION FIXATION: `session_regenerate_id(true)` PRZED zapisem `$_SESSION['admin']`
  (po udanym logowaniu) oraz przy starcie zegara idle.
- IDLE-TIMEOUT 3 h: każde żądanie zalogowanego konta odświeża `admin_last_activity`;
  po przekroczeniu 3*3600 s → wyloguj, ustaw `admin_session_expired` (komunikat na ekranie logowania).
- BEZPIECZNE CIASTECZKO SESJI (przed session_start()):
      session_set_cookie_params([
          'lifetime' => 0, 'path' => '/admin/<admin_code>/',
          'secure' => <true pod HTTPS>, 'httponly' => true, 'samesite' => 'Strict',
      ]);
      ini_set('session.use_strict_mode', '1');   // odrzuca obce identyfikatory sesji

### 10.4 CSRF — Synchronizer Token Pattern
- `csrfToken()`: jednorazowo per-sesja `$_SESSION['csrf_token'] = bin2hex(random_bytes(32))` (64 hex).
- Każdy formularz POST renderuje `<input type="hidden" name="_csrf" value="<?= htmlspecialchars(csrfToken()) ?>">`.
- `csrfVerify()`: dla KAŻDEGO POST porównuje `$_POST['_csrf']` z sesją przez `hash_equals()`.
- Niezgodność → log WARN (kanał Auth) + HTTP 403. W index.php:
      if ($_SERVER['REQUEST_METHOD'] === 'POST' && !csrfVerify()) { http_response_code(403); ... exit; }

### 10.5 Rate limiting logowania
- Tabela `<t>_login_attempts`. Bucket = `hash('sha256', REMOTE_ADDR)` (nie przechowuj jawnego IP).
- Okno: 15 minut. Limit: 10 nieudanych prób. Po przekroczeniu → blokada logowania z tego bucketu.
- `loginRecordFailure($ip)` po nieudanej próbie; `loginClearFailures($ip)` po udanym logowaniu.
- `loginIsBlocked($ip)` przy okazji czyści przeterminowane okna (brak cron-joba).
- FAIL-OPEN: brak tabeli `<t>_login_attempts` → blokada wyłączona (panel działa, log informacyjny).

### 10.6 Nagłówki HTTP / CSP (emitowane dla każdego żądania)
    X-Frame-Options: DENY
    X-Content-Type-Options: nosniff
    Referrer-Policy: strict-origin-when-cross-origin
    Permissions-Policy: camera=(), microphone=(), geolocation=()
    Strict-Transport-Security: max-age=31536000; includeSubDomains      (TYLKO pod HTTPS)
    Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline';
        style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self';
        frame-ancestors 'none'

### 10.7 Honeypot
- Ukryte pole `hp_phone` w `.a11y-offscreen` (CSS `position:absolute; left:-9999px`) w formularzu logowania.
- W index.php przy akcji login: `if (($_POST['hp_phone'] ?? '') !== '') { ... }` → odrzuć żądanie i
  zaloguj WARN (Auth) BEZ wyczerpywania budżetu rate limitera (bot się zdradza, człowiek nigdy nie wypełnia).

### 10.8 Autoryzacja (canManageAccess)
- Sekcje wrażliwe (`permissions`, `groups`, `domains`, `ai`, `backup`) wymagają uprawnienia:
      $canManageAccess = $adminUser === 'admin'
          || (string)($currentUser['UseGroupID'] ?? '') === GroupsModel::ADMIN_GROUP_ID;
- Routing: gdy `$page` należy do sekcji wrażliwych i `!$canManageAccess` → odmowa dostępu
  (przekierowanie/404) + log WARN (Auth). To samo egzekwuje sidebar (ukrywa pozycje).

### 10.9 Rejestrowanie zdarzeń bezpieczeństwa
- Każde zdarzenie loguj przez Logger we właściwym kanale i poziomie (tabela w sekcji DANE WEJŚCIOWE).
- Kontekst rekordu: IP, User-Agent, URI, ID użytkownika, callsite (zapewnia Logger).

## DANE WEJŚCIOWE — tabela zdarzeń bezpieczeństwa → poziom → kanał

| Zdarzenie                                | Poziom    | Kanał  |
|------------------------------------------|-----------|--------|
| Udane logowanie                          | INFO      | Auth   |
| Nieudane logowanie                       | WARN      | Auth   |
| Honeypot wypełniony                      | WARN      | Auth   |
| Rate limit — blokada                     | WARN      | Auth   |
| CSRF mismatch                            | WARN      | Auth   |
| Sesja wygasła / brak                     | INFO/WARN | Auth   |
| Dostęp bez uprawnień                     | WARN      | Auth   |
| Wylogowanie                              | INFO      | Auth   |
| Błąd tworzenia backupu                   | ERROR     | System |
| Przywrócenie backupu                     | INFO      | System |
| Naruszenie integralności backupu         | ERROR     | System |

## KOLEJNOŚĆ W admin/index.php (przepływ żądania)

1. Bootstrap (autoload, Config::load, Connection, Logger).
2. Parametry ciasteczka sesji + ini_set use_strict_mode + session_start()        [10.3]
3. Weryfikacja sekretnego kodu URL (hash_equals) → 404 bez wskazówki              [10.1]
4. Emisja nagłówków bezpieczeństwa HTTP / CSP                                     [10.6]
5. require admcore.php
6. Idle-timeout sesji (3 h) — odśwież admin_last_activity lub wyloguj             [10.3]
7. csrfVerify() dla każdego POST → 403 przy niezgodności                          [10.4]
8. Akcje: logout; login (honeypot → rate limit → authenticate → regenerate_id)   [10.7,10.5,10.2,10.3]
9. Routing podstron + kontrola uprawnień ($canManageAccess)                       [10.8]
10. Logowanie zdarzeń na każdym istotnym kroku                                    [10.9]

## ZADANIE

1. Zadeklaruj na początku tryb pracy: WDROŻENIE (uzupełnij/popraw kod) lub AUDYT (raport zgodności).
2. W trybie WDROŻENIA wygeneruj zmiany w `admin/index.php` realizujące kolejność 1–10 powyżej oraz
   brakujące funkcje w `admin/admcore.php` (csrfToken/csrfVerify, loginIsBlocked/RecordFailure/
   ClearFailures, authenticate/findActiveUser/touchLastLogin). Zachowaj istniejące API funkcji.
3. W trybie AUDYTU sprawdź każdy z punktów 10.1–10.9: dla każdego podaj status
   (OK / BRAK / DO POPRAWY) i — jeśli dotyczy — konkretną poprawkę kodu.
4. Upewnij się, że KAŻDE zdarzenie z tabeli DANE WEJŚCIOWE jest logowane we właściwym kanale i poziomie.
5. Nie ujawniaj istnienia panelu przy błędnym kodzie URL (404 identyczne jak dla nieznanej ścieżki).
6. Każdy plik/blok poprzedź jedną linią-komentarzem ze ścieżką, np. „// === admin/index.php ===".
Zwróć tylko pliki, bez wyjaśnień, bez bloków markdown.
```

---

## Weryfikacja
- [ ] **10.1** Wejście pod błędny `admin_code` zwraca 404 identyczne jak dowolna nieistniejąca ścieżka; porównanie przez `hash_equals()`.
- [ ] **10.2** Logowanie weryfikuje bcrypt (`password_verify`); konto nieaktywne (`UseIsActive=0`) nie loguje się; konto `admin` działa tylko gdy `<t>_users` pusta.
- [ ] **10.3** Po udanym logowaniu `session_regenerate_id(true)`; ciasteczko `HttpOnly`+`SameSite=Strict` (`Secure` pod HTTPS); `use_strict_mode=1`; po 3 h bezczynności wylogowanie z komunikatem „sesja wygasła".
- [ ] **10.4** POST bez/ze złym `_csrf` → 403 + log WARN (Auth); token 64-hex per sesja.
- [ ] **10.5** 11. nieudana próba w ciągu 15 min z tego samego IP-bucketu → blokada; brak tabeli `login_attempts` → fail-open (panel działa).
- [ ] **10.6** Odpowiedź zawiera `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`, `Content-Security-Policy` (+ `HSTS` pod HTTPS).
- [ ] **10.7** Wypełnione pole `hp_phone` → żądanie odrzucone i zalogowane (WARN/Auth), bez zużycia budżetu rate limitera.
- [ ] **10.8** Próba wejścia w `permissions`/`groups`/`domains`/`ai`/`backup` bez `canManageAccess` → odmowa + log WARN (Auth); pozycje ukryte w sidebarze.
- [ ] **10.9** Wszystkie zdarzenia z tabeli trafiają do `Logger` we właściwym kanale i poziomie (sprawdź w „Zdarzenia").

## Powiązane
- [docs/architektura/architektura.md §10 (Bezpieczeństwo)](../../architektura/architektura.md)
- [docs/architektura/architektura.md §6.1 (Punkt wejścia i routing)](../../architektura/architektura.md)
- [Poprzedni krok: 130 Kopie zapasowe](130-kopie-zapasowe.md)
- [Następny krok: 150 Front-end publiczny](150-frontend-publiczny.md)
- [Wzorzec stylu promptów: docs/prompt/migracja-tabeli.md](../migracja-tabeli.md)
