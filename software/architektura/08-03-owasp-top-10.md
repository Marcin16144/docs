# OWASP Top 10

## Czym jest OWASP Top 10?

OWASP (Open Web Application Security Project) Top 10 to lista dziesieciu najkrytyczniejszych zagrozen bezpieczenstwa aplikacji webowych. Jest aktualizowana co kilka lat na podstawie danych z rzeczywistych atakow i audytow bezpieczenstwa. Stanowi podstawowy punkt odniesienia dla kazdego zespolu tworzacego aplikacje webowe.

## A01: Broken Access Control

Nieprawidlowa kontrola dostepu — uzytkownik moze wykonywac akcje lub widziec dane, do ktorych nie powinien miec dostepu.

### Przyklady atakow

```
# IDOR (Insecure Direct Object Reference)
GET /api/users/123/orders     # Moje zamowienia
GET /api/users/456/orders     # Cudze zamowienia — brak weryfikacji!

# Path traversal
GET /api/files?path=../../etc/passwd

# Eskalacja uprawnien
POST /api/users/123
{ "role": "admin" }           # Zmiana roli przez zwykly POST
```

### Zapobieganie

```javascript
// DOBRZE: weryfikacja wlasciciela zasobu
app.get('/api/users/:userId/orders', auth, async (req, res) => {
  // Sprawdz czy zalogowany uzytkownik = wlasciciel
  if (req.params.userId !== req.user.id && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  const orders = await orderService.getByUserId(req.params.userId);
  res.json(orders);
});

// DOBRZE: domyslnie odmawiaj dostepu (deny by default)
// Biala lista dozwolonych akcji zamiast czarnej listy zabronionych
```

## A02: Cryptographic Failures

Bledy kryptograficzne — brak szyfrowania lub uzycie slabych algorytmow dla danych wrazliwych.

### Czeste bledy

- Przesylanie hasel w plain text (brak HTTPS)
- Przechowywanie hasel jako MD5/SHA1 (bez salt)
- Uzycie przestarzalych algorytmow (DES, RC4)
- Klucze szyfrowania w kodzie zrodlowym

### Zapobieganie

```javascript
// ZLE: MD5 bez salt
const hash = md5(password);

// ZLE: SHA256 bez salt
const hash = sha256(password);

// DOBRZE: bcrypt z salt
const bcrypt = require('bcrypt');
const SALT_ROUNDS = 12;

async function hashPassword(password) {
  return bcrypt.hash(password, SALT_ROUNDS);
}

async function verifyPassword(password, hash) {
  return bcrypt.compare(password, hash);
}

// DOBRZE: Argon2 (jeszcze lepszy)
const argon2 = require('argon2');

async function hashPassword(password) {
  return argon2.hash(password, {
    type: argon2.argon2id,
    memoryCost: 65536,
    timeCost: 3,
    parallelism: 4
  });
}
```

## A03: Injection

Wstrzykniecie zloslliwego kodu do zapytan (SQL, NoSQL, LDAP, OS commands). Atakujacy manipuluje danymi wejsciowymi, ktore sa bezposrednio wstawiane do zapytan.

### SQL Injection

```sql
-- Podatny kod:
query = "SELECT * FROM users WHERE email = '" + userInput + "'";

-- Atak:
userInput = "' OR '1'='1' --"
-- Wynik: SELECT * FROM users WHERE email = '' OR '1'='1' --'
-- Zwraca WSZYSTKICH uzytkownikow!

-- Gorszy atak:
userInput = "'; DROP TABLE users; --"
```

### Zapobieganie: Parameterized Queries

```javascript
// ZLE: konkatenacja stringow
const query = `SELECT * FROM users WHERE email = '${email}'`;

// DOBRZE: parametryzowane zapytania
const result = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email]
);

// DOBRZE: ORM (Prisma)
const user = await prisma.user.findUnique({
  where: { email: email }
});

// DOBRZE: Query builder (Knex)
const user = await knex('users')
  .where('email', email)
  .first();
```

### NoSQL Injection

```javascript
// ZLE: MongoDB — operator injection
app.post('/login', async (req, res) => {
  const user = await db.users.findOne({
    email: req.body.email,
    password: req.body.password
  });
});

// Atak: { "email": {"$gt": ""}, "password": {"$gt": ""} }
// Zwraca pierwszego uzytkownika!

// DOBRZE: walidacja typow
app.post('/login', async (req, res) => {
  if (typeof req.body.email !== 'string' ||
      typeof req.body.password !== 'string') {
    return res.status(400).json({ error: 'Invalid input' });
  }
  // ...
});
```

## A04: Insecure Design

Bledy projektowe — brak mechanizmow bezpieczenstwa na poziomie architektury. Nie da sie naprawic kodem — wymaga zmiany podejscia.

### Przyklady

- Brak rate limiting na endpoincie logowania
- Pytania bezpieczenstwa zamiast 2FA
- Brak limitu prob przy resetowaniu hasla
- Nieograniczony upload plikow

### Zapobieganie

```javascript
// Rate limiting na logowanie
const rateLimit = require('express-rate-limit');

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minut
  max: 5,                     // max 5 prob
  message: 'Zbyt wiele prob logowania',
  standardHeaders: true
});

app.post('/login', loginLimiter, loginHandler);

// Walidacja uploadu plikow
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'application/pdf'];
const MAX_SIZE = 5 * 1024 * 1024;  // 5MB

function validateUpload(file) {
  if (!ALLOWED_TYPES.includes(file.mimetype)) {
    throw new Error('Niedozwolony typ pliku');
  }
  if (file.size > MAX_SIZE) {
    throw new Error('Plik za duzy');
  }
}
```

## A05: Security Misconfiguration

Bledna konfiguracja bezpieczenstwa — domyslne hasla, otwarte porty, zbedne funkcje, brak aktualizacji.

### Czeste bledy

- Domyslne hasla (admin/admin)
- Stack trace w odpowiedziach produkcyjnych
- Niepotrzebne porty i serwisy
- Brak naglowkow bezpieczenstwa
- Directory listing wlaczony

### Zapobieganie: Security Headers

```javascript
const helmet = require('helmet');

app.use(helmet());
// Ustawia automatycznie:
// X-Content-Type-Options: nosniff
// X-Frame-Options: DENY
// X-XSS-Protection: 0 (nowoczesne przegladarki uzywaja CSP)
// Strict-Transport-Security: max-age=15552000
// Content-Security-Policy: ...

// Wylacz stack trace na produkcji
app.use((err, req, res, next) => {
  const status = err.status || 500;
  res.status(status).json({
    error: process.env.NODE_ENV === 'production'
      ? 'Internal Server Error'
      : err.message
  });
});
```

## A06: Vulnerable and Outdated Components

Uzycie komponentow ze znanymi podatnosciami — przestarzale biblioteki, frameworki, systemy operacyjne.

### Zapobieganie

```bash
# NPM — audyt zaleznosci
npm audit
npm audit fix

# Snyk — skanowanie podatnosci
npx snyk test

# Dependabot (GitHub) — automatyczne PR z aktualizacjami
# .github/dependabot.yml
```

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10
```

## A07: Identification and Authentication Failures

Bledy w identyfikacji i uwierzytelnianiu — slabe hasla, brak 2FA, podatnosc na brute force.

### Zapobieganie

```javascript
// Polityka hasel
function validatePassword(password) {
  const errors = [];
  if (password.length < 12) errors.push('Min. 12 znakow');
  if (!/[A-Z]/.test(password)) errors.push('Min. 1 wielka litera');
  if (!/[a-z]/.test(password)) errors.push('Min. 1 mala litera');
  if (!/[0-9]/.test(password)) errors.push('Min. 1 cyfra');
  if (!/[^A-Za-z0-9]/.test(password)) errors.push('Min. 1 znak specjalny');

  // Sprawdz czy haslo nie jest w liscie najpopularniejszych
  if (COMMON_PASSWORDS.has(password.toLowerCase())) {
    errors.push('Haslo zbyt popularne');
  }
  return errors;
}

// Stale-time porownanie (zapobiega timing attacks)
const crypto = require('crypto');

function safeCompare(a, b) {
  const bufA = Buffer.from(a);
  const bufB = Buffer.from(b);
  if (bufA.length !== bufB.length) return false;
  return crypto.timingSafeEqual(bufA, bufB);
}
```

## A08: Software and Data Integrity Failures

Bledy integralnosci oprogramowania i danych — brak weryfikacji zrodel kodu, aktualizacji, pipeline CI/CD.

### Przyklady zagrozen

- Zatrute zaleznosci (dependency confusion)
- Niezweryfikowane aktualizacje automatyczne
- Niezabezpieczony pipeline CI/CD
- Deserializacja niezaufanych danych

### Zapobieganie

```bash
# Lock file — dokladne wersje zaleznosci
npm ci    # instaluje dokladnie z package-lock.json
# (nie npm install, ktory moze aktualizowac)

# Weryfikacja integralnosci
npm audit signatures

# Subresource Integrity (SRI) w HTML
```

```html
<script
  src="https://cdn.example.com/lib.js"
  integrity="sha384-oqVuAfXRKap7fdgcCY5uykM6+R9GqQ8K/uxy9rx7HNQlGYl1kPzQho1wx4JwY8w"
  crossorigin="anonymous">
</script>
```

## A09: Security Logging and Monitoring Failures

Brak lub niewystarczajace logowanie i monitorowanie — ataki pozostaja niewykryte.

### Co logowac

```javascript
// Loguj zdarzenia bezpieczenstwa
const securityLogger = {
  loginSuccess: (userId, ip) =>
    log.info('AUTH_SUCCESS', { userId, ip, timestamp: Date.now() }),

  loginFailure: (email, ip, reason) =>
    log.warn('AUTH_FAILURE', { email, ip, reason, timestamp: Date.now() }),

  accessDenied: (userId, resource, ip) =>
    log.warn('ACCESS_DENIED', { userId, resource, ip }),

  suspiciousActivity: (userId, action, details) =>
    log.error('SUSPICIOUS', { userId, action, details }),

  dataExport: (userId, dataType, recordCount) =>
    log.info('DATA_EXPORT', { userId, dataType, recordCount })
};
```

### Alerty

```yaml
# Przykladowe reguly alertow
alerts:
  - name: brute_force_detection
    condition: "login_failures > 10 in 5m from same IP"
    severity: high
    action: block_ip_and_notify

  - name: impossible_travel
    condition: "logins from 2 countries within 1h"
    severity: critical
    action: lock_account_and_notify

  - name: mass_data_access
    condition: "data_exports > 1000 records in 1h"
    severity: medium
    action: notify_security_team
```

## A10: Server-Side Request Forgery (SSRF)

Serwer wykonuje zapytanie do URL podanego przez uzytkownika — atakujacy moze odczytac wewnetrzne zasoby.

### Przyklad ataku

```
# Uzytkownik podaje URL do pobrania obrazka:
POST /api/fetch-image
{ "url": "https://example.com/image.png" }    // OK

# Atak — odczyt metadanych AWS:
POST /api/fetch-image
{ "url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/" }

# Atak — skanowanie sieci wewnetrznej:
POST /api/fetch-image
{ "url": "http://10.0.0.1:8080/admin" }
```

### Zapobieganie

```javascript
const { URL } = require('url');
const dns = require('dns').promises;

async function validateUrl(inputUrl) {
  const parsed = new URL(inputUrl);

  // 1. Tylko HTTPS
  if (parsed.protocol !== 'https:') {
    throw new Error('Only HTTPS allowed');
  }

  // 2. Zablokuj prywatne IP
  const addresses = await dns.resolve4(parsed.hostname);
  for (const ip of addresses) {
    if (isPrivateIP(ip)) {
      throw new Error('Private IPs not allowed');
    }
  }

  // 3. Biala lista domen (najlepsze rozwiazanie)
  const ALLOWED_DOMAINS = ['cdn.example.com', 'images.example.com'];
  if (!ALLOWED_DOMAINS.includes(parsed.hostname)) {
    throw new Error('Domain not allowed');
  }

  return parsed.href;
}

function isPrivateIP(ip) {
  const parts = ip.split('.').map(Number);
  return (
    parts[0] === 10 ||
    (parts[0] === 172 && parts[1] >= 16 && parts[1] <= 31) ||
    (parts[0] === 192 && parts[1] === 168) ||
    parts[0] === 127 ||
    ip === '169.254.169.254'
  );
}
```

## Content Security Policy (CSP)

CSP to potezny mechanizm obrony przed XSS — kontroluje jakie zasoby przegladarka moze ladowac:

```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-abc123';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https://cdn.example.com;
  connect-src 'self' https://api.example.com;
  font-src 'self' https://fonts.googleapis.com;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
```

```javascript
// Express z helmet
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'", (req, res) => `'nonce-${res.locals.nonce}'`],
    styleSrc: ["'self'", "'unsafe-inline'"],
    imgSrc: ["'self'", "data:", "https://cdn.example.com"],
    connectSrc: ["'self'", "https://api.example.com"],
    frameAncestors: ["'none'"]
  }
}));
```

## Walidacja danych wejsciowych

```javascript
const Joi = require('joi');

// Schema walidacji
const createUserSchema = Joi.object({
  name: Joi.string().min(2).max(100).required()
    .pattern(/^[a-zA-Z\s\-']+$/),
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(18).max(120),
  role: Joi.string().valid('user', 'editor').default('user')
});

app.post('/api/users', async (req, res) => {
  const { error, value } = createUserSchema.validate(req.body, {
    abortEarly: false,
    stripUnknown: true    // usun nieznane pola
  });

  if (error) {
    return res.status(400).json({
      errors: error.details.map(d => d.message)
    });
  }

  const user = await userService.create(value);
  res.status(201).json(user);
});
```

## Podsumowanie OWASP Top 10

| # | Zagrozenie | Kluczowa obrona |
|---|-----------|-----------------|
| A01 | Broken Access Control | Weryfikacja uprawnien, deny by default |
| A02 | Cryptographic Failures | bcrypt/Argon2, HTTPS, rotacja kluczy |
| A03 | Injection | Parametryzowane zapytania, walidacja |
| A04 | Insecure Design | Rate limiting, threat modeling |
| A05 | Security Misconfiguration | Helmet, security headers, audyt |
| A06 | Vulnerable Components | npm audit, Dependabot, Snyk |
| A07 | Auth Failures | MFA, silne hasla, account lockout |
| A08 | Integrity Failures | Lock files, SRI, pipeline security |
| A09 | Logging Failures | Security logging, alerty, SIEM |
| A10 | SSRF | Biala lista URL, blokada prywatnych IP |

## Kluczowe wnioski

1. **Waliduj wszystkie dane wejsciowe** — uzytkownik to niezaufane zrodlo
2. **Parametryzowane zapytania** zawsze — nigdy konkatenacja stringow
3. **Defense in depth** — wiele warstw obrony, nie jedna
4. **Security headers** (CSP, HSTS, X-Frame-Options) — latwi do wdrozenia, duzy efekt
5. **Loguj i monitoruj** — nie mozesz obronic sie przed tym, czego nie widzisz
6. **Aktualizuj zaleznosci** — znane podatnosci to najlatwiejszy wektor ataku
