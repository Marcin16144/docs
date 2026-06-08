# 03 — CSP nonce — usunięcie `unsafe-inline`

**Priorytet:** 🟠 Średni · **Trudność implementacji:** Średnia

---

## Problem

Obecny nagłówek `Content-Security-Policy` zawiera `'unsafe-inline'` dla `script-src`
i `style-src`. Oznacza to, że CSP **nie blokuje inline XSS** — atakujący, który zdoła
wstrzyknąć tag `<script>alert(1)</script>`, wykona go bez przeszkód.

`'unsafe-inline'` jest tymczasowym kompromisem, bo panel AdminLTE i widoki K2 CMS
zawierają liczne inline-skrypty (obsługa modali, spinnerów, drzewa nawigacji).

```
// Obecny stan — unsafe
"script-src 'self' 'unsafe-inline';"
```

---

## Rozwiązanie — nonce per-request

**Nonce** (number used once) to losowy token generowany przy każdym żądaniu.
Serwer umieszcza go w nagłówku CSP i w każdym tagu `<script>` / `<style>`.
Przeglądarka wykonuje tylko skrypty z pasującym nonce.

```
// Docelowy stan
"script-src 'self' 'nonce-{LOSOWY_TOKEN}';"
```

Atakujący wstrzykujący `<script>` nie zna nonce — skrypt zostanie zablokowany.

---

## Implementacja

### 1. Generowanie nonce (index.php)

```php
// Po weryfikacji admin_code, przed emit nagłówków
$cspNonce = base64_encode(random_bytes(16));   // 128-bit entropy

// W nagłówku CSP (zamiast 'unsafe-inline'):
header(
    "Content-Security-Policy: default-src 'self'; "
    . "script-src 'self' 'nonce-{$cspNonce}'; "
    . "style-src  'self' 'nonce-{$cspNonce}'; "
    . "img-src 'self' data:; font-src 'self'; connect-src 'self'; "
    . "frame-ancestors 'none'; form-action 'self'; "
    . "object-src 'none'; base-uri 'self';"
);
```

### 2. Przekazanie nonce do widoków

```php
// index.php — $cspNonce dostępne jako zmienna globalna lub przez $GLOBALS
// Alternatywnie: define('CSP_NONCE', $cspNonce);
```

### 3. Każdy tag <script> i <style> musi mieć atrybut nonce

**admlayout.view.php** — skrypty zewnętrzne (src=) nie potrzebują nonce — CSP `'self'`
już im ufa. Nonce potrzebny jest tylko dla **inline** bloków:

```html
<!-- Zewnętrzne pliki — bez nonce (pokryte 'self') -->
<script src="/admin/assets/jquery/jquery.min.js"></script>

<!-- Inline blok — wymaga nonce -->
<script nonce="<?= htmlspecialchars($cspNonce) ?>">
    // kod JS
</script>

<!-- Inline style — wymaga nonce -->
<style nonce="<?= htmlspecialchars($cspNonce) ?>">
    /* style */
</style>
```

### 4. Skala zmiany w widokach

Każdy plik widoku z inline `<script>` musi otrzymać nonce. Zakres:

| Plik widoku | Inline skrypty |
|---|---|
| `admlayout.view.php` | Theme toggle, accessibility JS |
| `admmenus.view.php` | Auto-slug, modal fill |
| `admmenu.view.php` | AJAX history, drzewo drag-drop |
| `admmenuedit.view.php` | — |
| `admbackup.view.php` | Spinner create backup |
| `admsystem.view.php` | — |
| `admlogin.view.php` | — |

Łącznie ok. 8 plików do zaktualizowania.

### 5. Atrybuty event handler w HTML

`onclick="..."`, `onsubmit="..."` w atrybutach HTML są **zawsze blokowane** przez CSP
(nawet z nonce) — wymagają przeniesienia do bloków `<script nonce="...">`.

Sprawdź czy panel używa atrybutów event-handler:

```bash
grep -r 'onclick\|onsubmit\|onchange\|oninput' admin/pages/
```

Każde trafienie wymaga refactoru: `addEventListener()` w bloku `<script nonce="...">`.

---

## Strategia migracji

Ze względu na skalę zmiany zalecana jest migracja etapowa:

```
Etap 1: Dodaj $cspNonce do index.php (bez zmiany nagłówka)
Etap 2: Dodaj nonce do wszystkich inline <script> i <style> w widokach
Etap 3: Zmień nagłówek CSP: zastąp 'unsafe-inline' nonce
Etap 4: Sprawdź konsolę przeglądarki — CSP violations = brakujące nonce
Etap 5: Napraw błędy, włącz report-uri dla monitoringu
```

### Tymczasowy tryb raportowania (nie blokujący)

```
Content-Security-Policy-Report-Only: script-src 'nonce-{$cspNonce}' 'self'; report-uri /csp-report
```

Przeglądarka zgłasza naruszenia bez blokowania — pozwala znaleźć wszystkie brakujące nonce
przed włączeniem trybu enforce.

---

## Uwagi

- Nonce musi być generowany **przy każdym żądaniu** — nie może być stały (cachowany).
- `strict-dynamic` + nonce pozwala skryptom zaufanym ładować kolejne skrypty dynamicznie,
  bez potrzeby listowania wszystkich `src`. Przydatne jeśli AdminLTE ładuje pluginy.
- Zewnętrzne pliki JS/CSS z `src=` są już pokryte przez `'self'` — nie potrzebują nonce.
