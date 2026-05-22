# OAuth 2.0 i JWT

## Czym jest OAuth 2.0?

OAuth 2.0 to protokol autoryzacji, ktory pozwala aplikacjom uzyskac ograniczony dostep do zasobow uzytkownika bez udostepniania hasla. Uzytkownik deleguje dostep do swoich danych (np. profilu Google) aplikacji trzeciej, ktora otrzymuje token dostepu zamiast hasla.

## Kluczowe role w OAuth 2.0

| Rola | Opis | Przyklad |
|------|------|----------|
| **Resource Owner** | Uzytkownik, ktory posiada dane | Uzytkownik Google |
| **Client** | Aplikacja, ktora chce uzyskac dostep | Twoja aplikacja webowa |
| **Authorization Server** | Wydaje tokeny po autoryzacji | Google OAuth, Auth0, Keycloak |
| **Resource Server** | Serwer z chronionymi zasobami | Google API, Twoje API |

## OAuth 2.0 Flows

### Authorization Code Flow (z PKCE)

Najbezpieczniejszy flow — zalecany dla aplikacji webowych i mobilnych. PKCE (Proof Key for Code Exchange) chroni przed przechwyceniem kodu autoryzacyjnego.

```
1. Uzytkownik klika "Zaloguj przez Google"

2. Klient generuje code_verifier i code_challenge
   code_verifier = losowy_string(43-128 znakow)
   code_challenge = BASE64URL(SHA256(code_verifier))

3. Przekierowanie do Authorization Server:
   GET https://auth.example.com/authorize?
     response_type=code
     &client_id=my-app
     &redirect_uri=https://myapp.com/callback
     &scope=openid profile email
     &state=random_csrf_token
     &code_challenge=E9Melhoa2OwvFrEMTJguCHaoeK1t8URW...
     &code_challenge_method=S256

4. Uzytkownik loguje sie i wyrazenia zgode

5. Redirect z kodem autoryzacyjnym:
   GET https://myapp.com/callback?
     code=AUTH_CODE_xyz
     &state=random_csrf_token

6. Klient wymienia kod na token (server-side):
   POST https://auth.example.com/token
   {
     "grant_type": "authorization_code",
     "code": "AUTH_CODE_xyz",
     "redirect_uri": "https://myapp.com/callback",
     "client_id": "my-app",
     "code_verifier": "original_code_verifier"
   }

7. Odpowiedz — tokeny:
   {
     "access_token": "eyJhbGciOi...",
     "refresh_token": "dGhpcyBpcyBh...",
     "token_type": "Bearer",
     "expires_in": 3600,
     "id_token": "eyJhbGciOi..."
   }
```

### Client Credentials Flow

Dla komunikacji server-to-server (bez uzytkownika). Klient uwierzytelnia sie swoimi poswiadczeniami.

```
POST https://auth.example.com/token
{
  "grant_type": "client_credentials",
  "client_id": "order-service",
  "client_secret": "super_secret_key",
  "scope": "inventory:read orders:write"
}

Odpowiedz:
{
  "access_token": "eyJhbGciOi...",
  "token_type": "Bearer",
  "expires_in": 3600
}

Uzycie:
GET https://api.example.com/inventory
Authorization: Bearer eyJhbGciOi...
```

### Device Authorization Flow

Dla urzadzen bez przegladarki (Smart TV, CLI, IoT):

```
1. Urzadzenie prosi o kod:
   POST https://auth.example.com/device/code
   { "client_id": "smart-tv-app" }

   Odpowiedz:
   {
     "device_code": "GmRh...mPQ",
     "user_code": "WDJB-MJHT",
     "verification_uri": "https://auth.example.com/device",
     "expires_in": 600,
     "interval": 5
   }

2. Uzytkownik wchodzi na verification_uri na telefonie
   i wpisuje kod: WDJB-MJHT

3. Urzadzenie polluje co 5 sekund:
   POST https://auth.example.com/token
   { "grant_type": "urn:ietf:params:oauth:grant-type:device_code",
     "device_code": "GmRh...mPQ",
     "client_id": "smart-tv-app" }

4. Po zatwierdzeniu — urzadzenie otrzymuje token
```

## JWT (JSON Web Token)

### Struktura JWT

JWT sklada sie z trzech czesci oddzielonych kropkami:

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.
eyJzdWIiOiJ1c2VyLTEyMyIsIm5hbWUiOiJKYW4iLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE3MDk4MTYwMDAsImV4cCI6MTcwOTgxOTYwMH0.
SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c

Czesci:
HEADER.PAYLOAD.SIGNATURE
```

### Header

```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "key-2024-03"
}
```

Popularne algorytmy:
- **HS256** — HMAC z SHA-256 (symetryczny — ten sam klucz do podpisu i weryfikacji)
- **RS256** — RSA z SHA-256 (asymetryczny — klucz prywatny do podpisu, publiczny do weryfikacji)
- **ES256** — ECDSA z P-256 (asymetryczny, mniejsze tokeny)

### Payload (Claims)

```json
{
  "sub": "user-123",
  "name": "Jan Kowalski",
  "email": "jan@example.com",
  "role": "admin",
  "permissions": ["orders:read", "orders:write", "users:read"],
  "iss": "https://auth.example.com",
  "aud": "https://api.example.com",
  "iat": 1709816000,
  "exp": 1709819600,
  "jti": "unique-token-id-abc"
}
```

| Claim | Opis |
|-------|------|
| **sub** | Subject — identyfikator uzytkownika |
| **iss** | Issuer — kto wydal token |
| **aud** | Audience — dla kogo token jest przeznaczony |
| **exp** | Expiration — czas wygasniecia (Unix timestamp) |
| **iat** | Issued At — czas wydania |
| **jti** | JWT ID — unikalny identyfikator tokena |

### Signature

```
RSASHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  privateKey
)
```

## Walidacja JWT

Kazdy serwis weryfikuje token niezaleznie — bez kontaktu z Authorization Server:

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

// Pobierz klucz publiczny z JWKS endpoint
const client = jwksClient({
  jwksUri: 'https://auth.example.com/.well-known/jwks.json',
  cache: true,
  cacheMaxAge: 600000  // 10 minut
});

async function validateToken(token) {
  // 1. Dekoduj header (bez weryfikacji)
  const decoded = jwt.decode(token, { complete: true });
  if (!decoded) throw new Error('Invalid token format');

  // 2. Pobierz klucz publiczny po kid
  const key = await client.getSigningKey(decoded.header.kid);
  const publicKey = key.getPublicKey();

  // 3. Weryfikuj podpis, exp, iss, aud
  const payload = jwt.verify(token, publicKey, {
    algorithms: ['RS256'],
    issuer: 'https://auth.example.com',
    audience: 'https://api.example.com'
  });

  return payload;
}
```

### Checklist walidacji

1. Weryfikacja podpisu (signature) kluczem publicznym
2. Sprawdzenie `exp` — czy token nie wygasl
3. Sprawdzenie `iss` — czy wydawca jest zaufany
4. Sprawdzenie `aud` — czy token jest dla tego serwisu
5. Sprawdzenie `nbf` (not before) — czy token jest juz wazny
6. Sprawdzenie wymaganych claims (role, permissions)

## Rotacja kluczy

Regularna zmiana kluczy podpisujacych tokeny:

```
JWKS Endpoint: https://auth.example.com/.well-known/jwks.json

{
  "keys": [
    {
      "kid": "key-2025-03",      // aktualny klucz (podpisuje nowe tokeny)
      "kty": "RSA",
      "use": "sig",
      "n": "...",
      "e": "AQAB"
    },
    {
      "kid": "key-2025-01",      // poprzedni klucz (waliduje stare tokeny)
      "kty": "RSA",
      "use": "sig",
      "n": "...",
      "e": "AQAB"
    }
  ]
}

Procedura rotacji:
1. Wygeneruj nowy klucz (key-2025-03)
2. Dodaj go do JWKS (obok starego)
3. Zacznij podpisywac nowe tokeny nowym kluczem
4. Poczekaj az stare tokeny wygasna
5. Usun stary klucz z JWKS
```

## Refresh Tokens

Access token ma krotki czas zycia (np. 15 minut). Refresh token pozwala uzyskac nowy access token bez ponownego logowania.

```
Access Token:  krotki zycia (15 min), przesylany z kazdym requestem
Refresh Token: dlugi zycia (7 dni), uzywany tylko do odswiezenia

Przeplyw:
1. Login → access_token (15 min) + refresh_token (7 dni)
2. API request → Authorization: Bearer access_token
3. Token wygasa (401 Unauthorized)
4. POST /token { grant_type: "refresh_token", refresh_token: "..." }
5. Nowy access_token (15 min) + nowy refresh_token (7 dni)
```

### Refresh Token Rotation

Kazde uzycie refresh tokena generuje nowy refresh token (stary jest uniewazniany):

```javascript
async function refreshTokens(refreshToken) {
  // 1. Znajdz refresh token w bazie
  const stored = await db.refreshTokens.findOne({
    token: refreshToken
  });

  if (!stored) throw new Error('Token not found');
  if (stored.revoked) {
    // Mozliwe ponowne uzycie — uniewaznij cala rodzine
    await db.refreshTokens.revokeFamily(stored.familyId);
    throw new Error('Refresh token reuse detected');
  }

  // 2. Uniewaznij stary token
  await db.refreshTokens.revoke(stored.id);

  // 3. Wygeneruj nowe tokeny
  const newAccessToken = generateAccessToken(stored.userId);
  const newRefreshToken = generateRefreshToken(stored.userId, stored.familyId);

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
}
```

## Przechowywanie tokenow

| Metoda | Bezpieczenstwo | Uzycie |
|--------|---------------|--------|
| **httpOnly cookie** | Najlepsze — niedostepny z JS | Aplikacje webowe (same-site) |
| **Memory (zmienna)** | Dobre — ginie po odswiezeniu strony | SPA (krotka sesja) |
| **sessionStorage** | Srednie — dostepny z JS, ginie po zamknieciu tab | SPA |
| **localStorage** | Niskie — dostepny z JS, XSS moze wykrasc | Unikaj dla wrazliwych tokenow |

### Zalecane podejscie: BFF Pattern

```
Przegladarka         BFF (Backend for Frontend)      API
    |                        |                         |
    |-- Login ------------->|                         |
    |                       |-- Authorization Code -->|
    |                       |<-- access + refresh ----|
    |                       | (przechowuje w sesji)   |
    |<-- httpOnly cookie ---|                         |
    |                       |                         |
    |-- Request + cookie -->|                         |
    |                       |-- Bearer token -------->|
    |                       |<-- dane ----------------|
    |<-- dane --------------|                         |

Tokeny NIGDY nie trafiaja do przegladarki.
Cookie httpOnly + Secure + SameSite=Strict.
```

## Bezpieczenstwo JWT

### Czeste bledy

1. **Brak weryfikacji podpisu** — zawsze weryfikuj!
2. **Algorytm "none"** — nigdy nie akceptuj `"alg": "none"`
3. **Zbyt dlugi czas zycia** — access token max 15-30 minut
4. **Wrazliwe dane w payload** — JWT jest zakodowany (base64), nie zaszyfrowany
5. **Brak walidacji iss/aud** — umozliwia uzycie tokenow z innego systemu

### Dobre praktyki

```javascript
// Weryfikuj z biala lista algorytmow
jwt.verify(token, key, {
  algorithms: ['RS256'],  // NIGDY nie akceptuj "none"
  issuer: 'https://auth.example.com',
  audience: 'https://api.example.com',
  maxAge: '15m'
});

// Nie przechowuj wrazliwych danych w payload
// ZLE:
{ "sub": "user-123", "creditCard": "4111-1111-1111-1111" }

// DOBRZE:
{ "sub": "user-123", "role": "user", "permissions": ["read"] }
```

## Kluczowe wnioski

1. **Authorization Code + PKCE** to zalecany flow dla aplikacji webowych i mobilnych
2. **Client Credentials** dla komunikacji server-to-server
3. **RS256 > HS256** — asymetryczne klucze sa bezpieczniejsze w systemach rozproszonych
4. **Access token krotki** (15 min), refresh token dlugi (7 dni) z rotacja
5. **httpOnly cookies** lub BFF pattern do przechowywania tokenow w przegladarce
6. **Rotacja kluczy** przez JWKS — zawsze utrzymuj stary klucz do wygasniecia istniejacych tokenow
7. **Waliduj wszystko** — podpis, exp, iss, aud, algorytm
