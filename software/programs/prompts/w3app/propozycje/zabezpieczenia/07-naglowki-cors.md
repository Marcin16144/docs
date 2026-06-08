# 07 — Dodatkowe nagłówki CORP / COEP / COOP

**Priorytet:** 🟢 Niski · **Trudność implementacji:** Mała

---

## Problem

Ataki Spectre (2018) i kolejne side-channel attacks na procesory mogą wyciągać dane
z pamięci przeglądarki między cross-origin kontekstami. Zabezpieczają przed tym trzy
nagłówki HTTP, które izolują kontekst panelu administracyjnego.

Dodatkowy nagłówek `X-Permitted-Cross-Domain-Policies` blokuje odczyt panelu przez
pluginy Adobe (Flash, Acrobat) z innych domen.

---

## Nagłówki do dodania

### Cross-Origin-Resource-Policy (CORP)

```
Cross-Origin-Resource-Policy: same-origin
```

Blokuje ładowanie zasobów panelu (JS, CSS, obrazy) z innych domen przez tag
`<img src="...">`, `<script src="...">` itp. Zapobiega cross-origin leaks.

### Cross-Origin-Opener-Policy (COOP)

```
Cross-Origin-Opener-Policy: same-origin
```

Izoluje okno przeglądarki — strony otwarte przez panel (lub otwierające panel)
nie mają dostępu do `window.opener`. Zapobiega cross-origin window attacks.

### Cross-Origin-Embedder-Policy (COEP)

```
Cross-Origin-Embedder-Policy: require-corp
```

Wymaga aby wszystkie zasoby ładowane przez panel miały nagłówek CORP lub były
tego samego origin. Odblokuje `SharedArrayBuffer` (wymagane przez Spectre mitigations),
ale nakłada ograniczenia na zasoby zewnętrzne.

> ⚠️ **Uwaga:** COEP wymaga aby WSZYSTKIE zasoby (JS, CSS, fonty, obrazy) były
> same-origin lub miały nagłówek `Cross-Origin-Resource-Policy`. Ponieważ panel
> vendoruje wszystko lokalnie — powinno działać, ale wymaga przetestowania.

### X-Permitted-Cross-Domain-Policies

```
X-Permitted-Cross-Domain-Policies: none
```

Blokuje pliki `crossdomain.xml` i `clientaccesspolicy.xml` — używane przez Flash
i Silverlight do cross-origin access. Nieistotne dla nowoczesnych przeglądarek,
ale dobra praktyka.

---

## Implementacja

### Dodanie do index.php (po istniejących nagłówkach)

```php
// Dołącz do bloku nagłówków HTTP bezpieczeństwa (2.2)
header('Cross-Origin-Resource-Policy: same-origin');
header('Cross-Origin-Opener-Policy: same-origin');
header('X-Permitted-Cross-Domain-Policies: none');

// COEP — dodaj dopiero po przetestowaniu (może zablokować zasoby)
// header('Cross-Origin-Embedder-Policy: require-corp');
```

### Weryfikacja

Po wdrożeniu CORP i COOP sprawdź konsolę przeglądarki (`F12 → Console`)
pod kątem błędów cross-origin. Panel powinien działać bez zmian, bo wszystkie
zasoby są same-origin (vendored).

Przed włączeniem COEP:
1. Otwórz DevTools → Network
2. Sprawdź nagłówki każdego zasobu (JS, CSS, fonty w `assets/`)
3. Każdy powinien zwracać `Cross-Origin-Resource-Policy: same-origin`
4. Jeśli nie — skonfiguruj `.htaccess` lub nginx żeby dodawał ten nagłówek do plików statycznych

### .htaccess dla assets/ (jeśli potrzebne dla COEP)

```apache
<Directory /admin/assets/>
    Header set Cross-Origin-Resource-Policy "same-origin"
</Directory>
```

---

## Tabela wpływu

| Nagłówek | Ryzyko zepsucia czegoś | Kiedy włączyć |
|---|---|---|
| CORP | Bardzo niskie | Teraz |
| COOP | Niskie | Teraz |
| COEP | Średnie | Po przetestowaniu zasobów |
| X-Permitted-Cross-Domain-Policies | Zerowe | Teraz |

---

## Pełen docelowy blok nagłówków (index.php)

```php
header('X-Frame-Options: DENY');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: strict-origin-when-cross-origin');
header('Permissions-Policy: camera=(), microphone=(), geolocation=()');
header('X-XSS-Protection: 0');
header('Cross-Origin-Resource-Policy: same-origin');       // ← nowe
header('Cross-Origin-Opener-Policy: same-origin');         // ← nowe
header('X-Permitted-Cross-Domain-Policies: none');         // ← nowe
// header('Cross-Origin-Embedder-Policy: require-corp');   // ← po testach
if (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') {
    header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
}
header("Content-Security-Policy: …");
```
