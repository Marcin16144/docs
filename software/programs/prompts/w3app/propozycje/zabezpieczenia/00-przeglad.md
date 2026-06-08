# Propozycje zabezpieczeń — przegląd

> Katalog zawiera propozycje zabezpieczeń **niezaimplementowanych** w panelu administracyjnym K2 CMS.
> Każda propozycja to osobny plik z opisem problemu, rozwiązania i gotowym szkicem implementacji.

---

## Zaimplementowane (referencja)

| Nr | Zabezpieczenie | Plik źródłowy |
|---|---|---|
| 1.1 | Session fixation — `session_regenerate_id(true)` po logowaniu | `admin/index.php` |
| 1.2 | CSRF — synchronizer token, `hash_equals()`, 22 formularze | `admin/admcore.php` |
| 1.3 | Rate limiting — 10 prób / 15 min / IP (SHA-256 bucket) | `admin/admcore.php` + migracja |
| 2.1 | Bezpieczne ciasteczko sesji — SameSite=Strict, httponly, strict_mode | `admin/index.php` |
| 2.2 | Nagłówki HTTP — CSP, HSTS, X-Frame-Options, Referrer-Policy… | `admin/index.php` |
| 3.4 | Honeypot — pole `hp_phone` poza ekranem (CSS offscreen) | `admin/admlogin.view.php` |

---

## Do zaimplementowania

| Plik | Tytuł | Priorytet | Trudność |
|---|---|---|---|
| [01-2fa-totp.md](01-2fa-totp.md) | Dwuetapowe logowanie (TOTP) | 🔴 Wysoki | Duża |
| [02-polityka-hasel.md](02-polityka-hasel.md) | Polityka siły i historii haseł | 🟠 Średni | Mała |
| [03-csp-nonce.md](03-csp-nonce.md) | CSP nonce — usunięcie `unsafe-inline` | 🟠 Średni | Średnia |
| [04-zarzadzanie-sesjami.md](04-zarzadzanie-sesjami.md) | Zarządzanie aktywnymi sesjami | 🟠 Średni | Średnia |
| [05-alerty-bezpieczenstwa.md](05-alerty-bezpieczenstwa.md) | Alerty e-mail przy atakach | 🟠 Średni | Mała |
| [06-szyfrowanie-backupow.md](06-szyfrowanie-backupow.md) | Szyfrowanie i integralność backupów | 🔴 Wysoki | Średnia |
| [07-naglowki-cors.md](07-naglowki-cors.md) | Dodatkowe nagłówki CORP/COEP/COOP | 🟢 Niski | Mała |
| [08-brute-force-per-konto.md](08-brute-force-per-konto.md) | Brute-force per konto (nie tylko per IP) | 🟠 Średni | Mała |

---

## Legenda priorytetów

| Symbol | Opis |
|---|---|
| 🔴 Wysoki | Bezpośrednia ochrona wrażliwych danych lub dostępu |
| 🟠 Średni | Istotne wzmocnienie obrony, brak pilnej konieczności |
| 🟢 Niski | Hardening — dodatkowa warstwa, nie krytyczna |
