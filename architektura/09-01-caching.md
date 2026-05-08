# Strategie cachowania

## Czym jest cache?

Cache to warstwa posrednia przechowujaca kopie danych w szybszym medium, aby przyspieszyc kolejne odczyty. Zamiast za kazdym razem pytac baze danych, serwer sprawdza najpierw cache — jesli dane sa tam dostepne (cache hit), zwraca je natychmiast.

## Poziomy cache

```
Uzytkownik
  ↓
[Przegladarka cache]     — Najblizej uzytkownika, najszybszy
  ↓
[CDN cache]              — Edge servers, rozlokowane globalnie
  ↓
[API Gateway / Reverse Proxy cache]  — Nginx, Varnish
  ↓
[Application cache]      — Redis, Memcached (in-memory)
  ↓
[Database cache]         — Query cache, buffer pool
  ↓
[Baza danych]            — Zrodlo prawdy (source of truth)
```

### Porownanie poziomow

| Poziom | Latencja | Pojemnosc | Kontrola | Przyklad |
|--------|----------|-----------|----------|----------|
| Przegladarka | ~0ms | Mala | Niska | Cache-Control headers |
| CDN | 5-50ms | Duza | Srednia | CloudFront, Cloudflare |
| Reverse Proxy | 1-5ms | Srednia | Wysoka | Nginx, Varnish |
| Aplikacja (Redis) | 1-5ms | Srednia | Pelna | Redis, Memcached |
| Baza danych | 10-100ms | Duza | Niska | Buffer pool, query cache |

## Strategie cachowania

### Cache-Aside (Lazy Loading)

Aplikacja zarzadza cachem recznie — sprawdza cache, jesli brak (miss) to czyta z bazy i zapisuje do cache.

```javascript
async function getUser(userId) {
  // 1. Sprawdz cache
  const cached = await redis.get(`user:${userId}`);
  if (cached) {
    return JSON.parse(cached);  // Cache HIT
  }

  // 2. Cache MISS — czytaj z bazy
  const user = await db.users.findById(userId);

  // 3. Zapisz do cache
  await redis.set(`user:${userId}`, JSON.stringify(user), 'EX', 3600);

  return user;
}
```

**Zalety:** Prostota, cache ma tylko dane ktore sa czytane.
**Wady:** Pierwsze zapytanie zawsze wolne (cold start), mozliwa niespojnosc.

### Read-Through

Cache sam pobiera dane z bazy przy miss — aplikacja zawsze czyta z cache.

```
Aplikacja → Cache → (miss) → Baza danych
                  ← dane ←
            (zapisuje w cache)
         ← dane

Aplikacja → Cache → (hit) → zwraca dane
```

```javascript
// Konfiguracja cache z read-through
const cache = new ReadThroughCache({
  store: redis,
  loader: async (key) => {
    const [type, id] = key.split(':');
    return db[type].findById(id);
  },
  ttl: 3600
});

// Uzycie — zawsze przez cache
const user = await cache.get('user:123');
```

**Zalety:** Prostsza logika aplikacji, cache zarzadza ladowaniem.
**Wady:** Biblioteka/framework musi wspierac ten wzorzec.

### Write-Through

Zapis idzie przez cache do bazy — cache jest zawsze aktualny.

```
Aplikacja → Cache → Baza danych
                  ← potwierdzenie
         ← potwierdzenie

Zapis: Cache + Baza jednoczesnie (synchronicznie)
Odczyt: Zawsze z cache (zawsze aktualny)
```

**Zalety:** Cache zawsze spojny z baza.
**Wady:** Wyzsze latencje zapisu (dwa zapisy), cache moze miec dane ktore nigdy nie sa czytane.

### Write-Behind (Write-Back)

Zapis do cache natychmiast, zapis do bazy asynchronicznie (z opoznieniem).

```
Aplikacja → Cache → (natychmiast) potwierdzenie
                  ↓ (asynchronicznie, batch)
             Baza danych

// Przyklad: buforowanie zapisow
const writeBuffer = [];

async function updateUser(userId, data) {
  // Natychmiastowy zapis do cache
  await redis.set(`user:${userId}`, JSON.stringify(data));

  // Dodaj do bufora zapisow
  writeBuffer.push({ userId, data, timestamp: Date.now() });
}

// Co 5 sekund — flush bufora do bazy
setInterval(async () => {
  if (writeBuffer.length === 0) return;
  const batch = writeBuffer.splice(0, writeBuffer.length);
  await db.users.bulkUpdate(batch);
}, 5000);
```

**Zalety:** Bardzo szybki zapis, mozliwosc batchowania.
**Wady:** Ryzyko utraty danych (cache awaria przed zapisem do bazy).

## Strategie inwalidacji cache

### Time-based (TTL)

```javascript
// TTL — dane wygasaja po okreslonym czasie
await redis.set('user:123', data, 'EX', 3600);  // 1 godzina

// Rozne TTL dla roznych typow danych
const TTL = {
  userProfile: 3600,      // 1h — rzadko sie zmienia
  productList: 300,       // 5min — moze sie zmieniac
  searchResults: 60,      // 1min — czesto sie zmienia
  stockPrice: 5           // 5s — czesto sie zmienia
};
```

### Event-based (aktywna inwalidacja)

```javascript
// Po aktualizacji uzytkownika — usun z cache
async function updateUser(userId, data) {
  await db.users.update(userId, data);
  await redis.del(`user:${userId}`);           // usun cache
  await redis.del(`user-orders:${userId}`);    // powiazane cache
}

// Pub/Sub — inwalidacja w wielu instancjach
redis.publish('cache:invalidate', JSON.stringify({
  keys: [`user:${userId}`, `user-orders:${userId}`]
}));
```

### Wersjonowanie (cache key z wersja)

```javascript
// Zmiana wersji = nowy klucz cache = stare dane ignorowane
const CACHE_VERSION = 'v3';

async function getProduct(productId) {
  const key = `${CACHE_VERSION}:product:${productId}`;
  // Stare klucze (v2:product:123) wygasna naturalnie (TTL)
  return cache.get(key);
}
```

## Cache Stampede (Thundering Herd)

Problem: klucz wygasa → setki requestow jednoczesnie pytaja baze → przeciazenie.

### Rozwiazania

```javascript
// 1. Locking (mutex) — tylko jeden request odnawie cache
async function getWithLock(key, loader, ttl) {
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);

  // Sprobuj uzyskac lock
  const lockKey = `lock:${key}`;
  const acquired = await redis.set(lockKey, '1', 'NX', 'EX', 10);

  if (acquired) {
    // Ten request laduje dane
    const data = await loader();
    await redis.set(key, JSON.stringify(data), 'EX', ttl);
    await redis.del(lockKey);
    return data;
  } else {
    // Inny request laduje — czekaj i sprobuj ponownie
    await sleep(100);
    return getWithLock(key, loader, ttl);
  }
}

// 2. Probabilistic Early Expiration
// Odswiezaj cache PRZED wygasnieciem z pewnym prawdopodobienstwem
async function getWithEarlyRefresh(key, loader, ttl) {
  const cached = await redis.get(key);
  const remainingTTL = await redis.ttl(key);

  if (cached && remainingTTL > ttl * 0.1) {
    return JSON.parse(cached);
  }

  // TTL < 10% — odswiez proaktywnie
  if (cached) {
    // Odswiez w tle, zwroc stare dane
    refreshInBackground(key, loader, ttl);
    return JSON.parse(cached);
  }

  // Brak w cache — zaladuj
  const data = await loader();
  await redis.set(key, JSON.stringify(data), 'EX', ttl);
  return data;
}
```

## Wzorce Redis

### Podstawowe operacje

```javascript
// String — proste klucz-wartosc
await redis.set('user:123', JSON.stringify(user), 'EX', 3600);
const user = JSON.parse(await redis.get('user:123'));

// Hash — struktura z polami
await redis.hset('user:123', { name: 'Jan', email: 'jan@ex.com', role: 'admin' });
const name = await redis.hget('user:123', 'name');
const all = await redis.hgetall('user:123');

// Sorted Set — ranking
await redis.zadd('leaderboard', 1500, 'player:1');
await redis.zadd('leaderboard', 2300, 'player:2');
const top10 = await redis.zrevrange('leaderboard', 0, 9, 'WITHSCORES');

// List — kolejka
await redis.lpush('queue:emails', JSON.stringify(emailJob));
const job = await redis.rpop('queue:emails');
```

### Rate Limiting z Redis

```javascript
async function rateLimit(key, maxRequests, windowSec) {
  const current = await redis.incr(key);

  if (current === 1) {
    await redis.expire(key, windowSec);
  }

  if (current > maxRequests) {
    throw new RateLimitError('Too many requests');
  }

  return { remaining: maxRequests - current };
}

// Uzycie: max 100 requestow na minute per IP
await rateLimit(`rate:${clientIP}`, 100, 60);
```

## CDN (Content Delivery Network)

CDN cachuje statyczne zasoby na serwerach brzegowych (edge) blisko uzytkownikow:

```
Uzytkownik (Warszawa)
  ↓
CDN Edge (Warszawa) ←── cache hit → zwraca natychmiast
  ↓ cache miss
CDN Edge → Origin Server (US-East)
         ← odpowiedz (cachowana na edge)
```

### Cache-Control headers

```
# Statyczne assety (JS, CSS, obrazki) — dlugi cache + wersjonowanie
Cache-Control: public, max-age=31536000, immutable
# Plik: /assets/app.a1b2c3.js (hash w nazwie)

# API responses — krotki cache
Cache-Control: public, max-age=60, s-maxage=300
# max-age: przegladarka (60s), s-maxage: CDN (300s)

# Prywatne dane — nie cachuj na CDN
Cache-Control: private, max-age=0, no-store

# Stale-while-revalidate — zwroc stare, odswiez w tle
Cache-Control: public, max-age=60, stale-while-revalidate=300
```

## Kluczowe wnioski

1. **Cache-aside** to najpopularniejsza strategia — prosta i elastyczna
2. **Write-behind** daje najszybsze zapisy, ale ryzykujesz utrate danych
3. **TTL** to podstawa — zawsze ustawiaj czas wygasniecia
4. **Cache stampede** to realny problem — uzywaj lockingu lub early refresh
5. **CDN** dla statycznych zasobow — latwa wygrana wydajnosciowa
6. **Redis** to swiss army knife — cache, rate limiting, kolejki, ranking
7. **Inwalidacja cache** jest najtrudniejsza — event-based lepsza niz TTL dla krytycznych danych
