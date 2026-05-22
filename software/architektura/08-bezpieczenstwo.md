# Bezpieczeństwo w architekturze

## Fundamenty bezpieczeństwa (CIA Triad)

- **Confidentiality (Poufność)** — dane dostępne tylko dla uprawnionych
- **Integrity (Integralność)** — dane nie mogą być nieautoryzowanie zmienione
- **Availability (Dostępność)** — system dostępny gdy potrzebny

## Uwierzytelnianie (Authentication)

### Mechanizmy
- **Hasła** — hashowane (bcrypt, Argon2), nigdy nie przechowuj w plaintext
- **Multi-Factor Authentication (MFA)** — TOTP, klucze sprzętowe (YubiKey)
- **OAuth 2.0 / OpenID Connect** — delegowane uwierzytelnianie
- **JWT (JSON Web Tokens)** — bezstanowe tokeny z podpisem
- **API Keys** — dla komunikacji machine-to-machine

### JWT — struktura i uwagi

```
Header.Payload.Signature

Header:  { "alg": "RS256", "typ": "JWT" }
Payload: { "sub": "user123", "role": "admin", "exp": 1700000000 }
Signature: RSASHA256(header + "." + payload, privateKey)
```

**Uwagi:**
- Ustaw krótki czas ważności (15 min access token)
- Używaj refresh tokenów do odnawiania
- Waliduj podpis po stronie serwera
- Nie przechowuj wrażliwych danych w payload (jest zakodowany, nie zaszyfrowany)

---

## Autoryzacja (Authorization)

### Modele
- **RBAC (Role-Based Access Control)** — uprawnienia przypisane do ról
- **ABAC (Attribute-Based Access Control)** — decyzje na podstawie atrybutów
- **PBAC (Policy-Based Access Control)** — centralne polityki (np. Open Policy Agent)
- **ReBAC (Relationship-Based Access Control)** — uprawnienia na podstawie relacji (np. Google Zanzibar)

### Zasada najmniejszych uprawnień (Principle of Least Privilege)
Każdy użytkownik/serwis powinien mieć minimalny zestaw uprawnień potrzebnych do działania.

---

## OWASP Top 10

Najważniejsze zagrożenia wg OWASP:

1. **Broken Access Control** — brak weryfikacji uprawnień
2. **Cryptographic Failures** — słabe szyfrowanie, wycieki danych
3. **Injection** — SQL injection, XSS, command injection
4. **Insecure Design** — brak threat modelingu
5. **Security Misconfiguration** — domyślne hasła, otwarte porty
6. **Vulnerable Components** — nieaktualne zależności
7. **Authentication Failures** — słabe mechanizmy logowania
8. **Data Integrity Failures** — brak weryfikacji integralności
9. **Logging Failures** — brak logów bezpieczeństwa
10. **SSRF** — Server-Side Request Forgery

---

## Bezpieczeństwo w praktyce

### Szyfrowanie
- **At rest** — dane w bazie (AES-256)
- **In transit** — komunikacja (TLS 1.3)
- **End-to-end** — tylko nadawca i odbiorca mogą odczytać

### Zarządzanie sekretami
- Nigdy nie przechowuj sekretów w kodzie
- Używaj: HashiCorp Vault, AWS Secrets Manager, Azure Key Vault
- Rotuj sekrety regularnie

### Threat Modeling
Systematyczna identyfikacja zagrożeń. Metodologia STRIDE:
- **S**poofing — podszywanie się
- **T**ampering — manipulacja danymi
- **R**epudiation — zaprzeczanie akcjom
- **I**nformation disclosure — wyciek informacji
- **D**enial of service — odmowa usługi
- **E**levation of privilege — eskalacja uprawnień

### Zero Trust Architecture
"Nigdy nie ufaj, zawsze weryfikuj" — każde żądanie wymaga uwierzytelnienia i autoryzacji, niezależnie od sieci.
