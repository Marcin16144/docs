# Load Balancing

## Czym jest load balancing?

Load balancing to rozkladanie ruchu sieciowego na wiele serwerow (instancji), aby zapewnic wysoka dostepnosc, niezawodnosc i optymalne wykorzystanie zasobow. Load balancer stoi miedzy klientem a grupa serwerow i decyduje, ktory serwer obsluzy dane zapytanie.

```
Klienty
  │  │  │
  ▼  ▼  ▼
┌──────────────┐
│ Load Balancer│
└──┬───┬───┬───┘
   │   │   │
   ▼   ▼   ▼
 Srv1 Srv2 Srv3
```

## L4 vs L7 Load Balancing

### Layer 4 (Transport)

Operuje na poziomie TCP/UDP — nie analizuje tresci requestu. Decyzja na podstawie IP zrodlowego, portu i prostych regul.

```
Klient → [L4 LB] → Serwer

LB widzi: IP:port, protokol TCP/UDP
LB NIE widzi: URL, headers, cookies, body

Zalety: szybki, niski narzut, prosty
Wady: brak routingu na podstawie tresci
```

### Layer 7 (Application)

Operuje na poziomie HTTP — analizuje URL, headery, cookies. Umozliwia zaawansowany routing.

```
Klient → [L7 LB] → Serwer

LB widzi: URL, HTTP method, headers, cookies, body
LB MOZE: routowac po URL, dodawac headery, terminowac SSL

Przyklad routingu L7:
  /api/*       → backend-pool
  /static/*    → cdn-pool
  /ws/*        → websocket-pool
  /admin/*     → admin-pool (tylko VPN)
```

### Porownanie

| Cecha | L4 | L7 |
|-------|----|----|
| Warstwa | TCP/UDP | HTTP/HTTPS |
| Wydajnosc | Wyzsza | Nizsza (parsuje HTTP) |
| Routing | IP + port | URL, headers, cookies |
| SSL termination | Nie | Tak |
| WebSocket | Pass-through | Pelna obsluga |
| Modyfikacja requestu | Nie | Tak (headery, rewrite) |
| Przyklad | AWS NLB, HAProxy (TCP) | Nginx, HAProxy (HTTP), ALB |

## Algorytmy load balancingu

### Round Robin

Kolejne requesty do kolejnych serwerow w kolko:

```
Request 1 → Serwer A
Request 2 → Serwer B
Request 3 → Serwer C
Request 4 → Serwer A  (od poczatku)
```

**Zalety:** Prosty, rownomierny.
**Wady:** Nie uwzglednia obciazenia serwera ani ciezaru requestu.

### Weighted Round Robin

Serwery z rozna waga — mocniejsze serwery dostaja wiecej ruchu:

```
# Serwer A: waga 5 (mocny)
# Serwer B: waga 3 (sredni)
# Serwer C: waga 2 (slaby)

Request 1-5 → Serwer A
Request 6-8 → Serwer B
Request 9-10 → Serwer C
(powtorka)
```

### Least Connections

Request idzie do serwera z najmniejsza liczba aktywnych polaczen:

```
Stan:
  Serwer A: 12 aktywnych polaczen
  Serwer B: 3 aktywne polaczenia   ← tu idzie request
  Serwer C: 8 aktywnych polaczen
```

**Zalety:** Lepsze dla requestow o roznym czasie przetwarzania.

### IP Hash

Hash IP klienta determinuje serwer — ten sam klient zawsze trafia do tego samego serwera:

```
hash(client_IP) % liczba_serwerow = indeks serwera

hash("192.168.1.1") % 3 = 0 → Serwer A
hash("192.168.1.2") % 3 = 2 → Serwer C
hash("192.168.1.3") % 3 = 1 → Serwer B
```

**Zalety:** Prosta sesja affinity.
**Wady:** Nierowny rozklad, problem przy dodawaniu/usuwaniu serwerow.

### Least Response Time

Request idzie do serwera z najkrotszym czasem odpowiedzi:

```
Serwer A: avg 45ms
Serwer B: avg 12ms  ← tu idzie request
Serwer C: avg 30ms
```

### Random

Losowy wybor serwera. Statystycznie rownomierny przy duzej liczbie requestow.

## Health Checks

Load balancer musi wiedziec, ktore serwery sa zdrowe. Chore serwery sa usuwane z puli.

### Passive Health Checks

Monitorowanie odpowiedzi — jesli serwer zaczyna zwracac bledy, jest oznaczany jako niezdowy:

```
# Nginx passive check
upstream backend {
  server 10.0.0.1:8080 max_fails=3 fail_timeout=30s;
  server 10.0.0.2:8080 max_fails=3 fail_timeout=30s;
  server 10.0.0.3:8080 max_fails=3 fail_timeout=30s;
}

# 3 bledy w ciagu 30s = serwer oznaczony jako down
# Po 30s — probuje ponownie
```

### Active Health Checks

Regularne zapytania do endpointu health:

```
# HAProxy active check
backend app_servers
  option httpchk GET /healthz
  http-check expect status 200

  server srv1 10.0.0.1:8080 check inter 5s fall 3 rise 2
  server srv2 10.0.0.2:8080 check inter 5s fall 3 rise 2

# inter 5s  — sprawdzaj co 5 sekund
# fall 3    — 3 bledy = oznacz jako down
# rise 2    — 2 sukcesy = oznacz jako zdrowy
```

### Health Endpoint

```javascript
app.get('/healthz', async (req, res) => {
  try {
    // Sprawdz zaleznosci
    await db.query('SELECT 1');
    await redis.ping();

    res.status(200).json({
      status: 'healthy',
      uptime: process.uptime(),
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(503).json({
      status: 'unhealthy',
      error: err.message
    });
  }
});

// Readiness vs Liveness (Kubernetes)
app.get('/readyz', ...);  // Czy gotowy na ruch?
app.get('/livez', ...);   // Czy proces zyje?
```

## Session Affinity (Sticky Sessions)

Problem: uzytkownik zalogowany na Serwerze A — nastepny request trafia do Serwera B (nie ma sesji).

### Cookie-based affinity

```
# Nginx — sticky cookie
upstream backend {
  sticky cookie srv_id expires=1h domain=.example.com path=/;
  server 10.0.0.1:8080;
  server 10.0.0.2:8080;
}

# LB ustawia cookie: srv_id=<hash_serwera>
# Kolejne requesty z tym cookie trafiaja do tego samego serwera
```

### Lepsze rozwiazanie: externalizacja sesji

```
# Zamiast sticky sessions — przechowuj sesje w Redis
# Kazdy serwer czyta sesje z tego samego Redis

Klient → [LB] → Serwer A ──→ Redis (sesja)
                 Serwer B ──→ Redis (sesja)
                 Serwer C ──→ Redis (sesja)

# Nie potrzeba affinity — kazdy serwer ma dostep do sesji
```

```javascript
const session = require('express-session');
const RedisStore = require('connect-redis')(session);

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: 'session-secret',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: true, httpOnly: true, maxAge: 3600000 }
}));
```

## Konfiguracja Nginx

```nginx
# Podstawowy load balancing
upstream backend {
  least_conn;  # algorytm

  server 10.0.0.1:8080 weight=5;
  server 10.0.0.2:8080 weight=3;
  server 10.0.0.3:8080 weight=2;
  server 10.0.0.4:8080 backup;  # tylko gdy inne down
}

server {
  listen 443 ssl http2;
  server_name api.example.com;

  ssl_certificate /etc/ssl/cert.pem;
  ssl_certificate_key /etc/ssl/key.pem;

  location /api/ {
    proxy_pass http://backend;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # Timeouty
    proxy_connect_timeout 5s;
    proxy_send_timeout 30s;
    proxy_read_timeout 30s;

    # Retry przy bledach
    proxy_next_upstream error timeout http_502 http_503;
    proxy_next_upstream_tries 2;
  }

  location /static/ {
    root /var/www;
    expires 1y;
    add_header Cache-Control "public, immutable";
  }
}
```

## Konfiguracja HAProxy

```
# haproxy.cfg
global
  maxconn 50000
  log stdout format raw local0

defaults
  mode http
  timeout connect 5s
  timeout client 30s
  timeout server 30s
  option httplog

frontend http_front
  bind *:443 ssl crt /etc/ssl/cert.pem
  default_backend app_servers

  # Routing L7
  acl is_api path_beg /api/
  acl is_admin path_beg /admin/
  use_backend api_servers if is_api
  use_backend admin_servers if is_admin

backend app_servers
  balance roundrobin
  option httpchk GET /healthz
  http-check expect status 200

  server srv1 10.0.0.1:8080 check inter 5s fall 3 rise 2
  server srv2 10.0.0.2:8080 check inter 5s fall 3 rise 2
  server srv3 10.0.0.3:8080 check inter 5s fall 3 rise 2
```

## Cloud Load Balancers

| Usluga | Typ | Cecha |
|--------|-----|-------|
| AWS ALB | L7 | HTTP/HTTPS, path routing, WAF |
| AWS NLB | L4 | TCP/UDP, ultra niska latencja |
| GCP Cloud LB | L4/L7 | Globalny, anycast IP |
| Azure App Gateway | L7 | WAF, SSL, URL routing |
| Azure Load Balancer | L4 | TCP/UDP, zony dostepnosci |

## Auto-scaling

Load balancer wspolpracuje z auto-scalingiem — automatyczne dodawanie/usuwanie instancji:

```yaml
# AWS Auto Scaling Group
AutoScalingGroup:
  MinSize: 2
  MaxSize: 10
  DesiredCapacity: 3
  TargetGroupARNs:
    - !Ref ALBTargetGroup

  # Skaluj na podstawie CPU
ScalingPolicy:
  PolicyType: TargetTrackingScaling
  TargetTrackingConfiguration:
    PredefinedMetricSpecification:
      PredefinedMetricType: ASGAverageCPUUtilization
    TargetValue: 70  # utrzymuj CPU ~70%
```

```
Ruch rosnie → CPU > 70% → Auto-scaler dodaje instancje
                         → LB dodaje je do puli
                         → Health check OK → ruch kierowany

Ruch spada  → CPU < 30% → Auto-scaler usuwa instancje
                         → LB usuwa je z puli (drain connections)
```

### Connection Draining

Przed usunieciem instancji — dokoncz istniejace requesty:

```
1. Oznacz instancje jako "draining"
2. Nie kieruj NOWYCH requestow
3. Poczekaj na zakonczenie istniejacych (timeout: 30s)
4. Usun instancje
```

## Kluczowe wnioski

1. **L7** dla HTTP (routing po URL, headery) — **L4** dla TCP/UDP (wydajnosc)
2. **Least Connections** to najczesciej najlepszy algorytm ogolnego przeznaczenia
3. **Health checks** sa obowiazkowe — active + passive dla pewnosci
4. **Unikaj sticky sessions** — externalizuj sesje do Redis
5. **Auto-scaling** z load balancerem = elastycznosc kosztowa i wydajnosciowa
6. **Connection draining** zapobiega blednym odpowiedziom przy skalowaniu w dol
7. W chmurze uzywaj **managed LB** (ALB, NLB) — mniej operacji
