# Zero Trust Architecture (ZTA)

## Czym jest Zero Trust?

Zero Trust to model bezpieczenstwa oparty na zasadzie **"Nigdy nie ufaj, zawsze weryfikuj"**. W przeciwienstwie do tradycyjnego modelu "zamek i fosa" (castle-and-moat), gdzie zaufanie przyznawane jest na podstawie lokalizacji sieciowej, Zero Trust zaklada, ze zagrozenie moze pochodzic zarowno z zewnatrz, jak i z wewnatrz sieci.

## Tradycyjny model vs Zero Trust

### Model tradycyjny (perimeter-based)
```
Internet ──→ [Firewall] ──→ Siec wewnetrzna (zaufana)
                              Wszystko wewnatrz = zaufane
                              Lateral movement = latwy
```

### Model Zero Trust
```
Kazde zadanie ──→ [Weryfikacja tozsamosci]
                  [Weryfikacja urzadzenia]
                  [Weryfikacja kontekstu]
                  [Minimalne uprawnienia]
                  ──→ Dostep do zasobu
```

## Filary Zero Trust

### 1. Weryfikacja tozsamosci (Identity Verification)
- Kazdy uzytkownik i urzadzenie musi byc uwierzytelnione
- Multi-Factor Authentication (MFA) jest obowiazkowe
- Tozsamosc to nowy perymetr bezpieczenstwa

**Praktyka:**
- Centralny Identity Provider (IdP): Azure AD, Okta, Auth0
- SSO (Single Sign-On) dla wszystkich aplikacji
- Certyfikaty klienckie (mTLS) dla komunikacji miedzy serwisami

### 2. Minimalne uprawnienia (Least Privilege Access)
- Uzytkownik/serwis dostaje tylko te uprawnienia, ktore sa niezbedne
- Uprawnienia przyznawane na czas (just-in-time access)
- Regularne przeglady uprawnien (access reviews)

**Praktyka:**
```
// Zle — szerokie uprawnienia
{
  "role": "admin",
  "resources": ["*"],
  "actions": ["*"]
}

// Dobrze — minimalne uprawnienia
{
  "role": "order-service",
  "resources": ["orders", "inventory"],
  "actions": ["read", "create"],
  "conditions": {
    "ip_range": "10.0.1.0/24",
    "time_window": "08:00-20:00",
    "mfa_verified": true
  }
}
```

### 3. Mikrosegmentacja sieci (Microsegmentation)
- Siec podzielona na male segmenty z kontrola dostepu
- Kazdy segment ma wlasne polityki bezpieczenstwa
- Ograniczenie lateral movement (ruchu bocznego)

**Przyklad:**
```
┌─────────────────────────────────────────────────┐
│                    Siec                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │ Segment A│    │ Segment B│    │ Segment C│  │
│  │ Frontend │-X->│ Database │    │ Payments │  │
│  │          │    │          │    │          │  │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘  │
│       │               │               │        │
│       │    ┌──────────┐│               │        │
│       └───>│ Segment D├┘               │        │
│            │ Backend  │────────────────┘        │
│            └──────────┘                         │
└─────────────────────────────────────────────────┘

Frontend → Backend: dozwolone
Frontend → Database: zablokowane (musi isc przez Backend)
Backend → Payments: dozwolone (z mTLS)
```

### 4. Weryfikacja urzadzenia (Device Verification)
- Nie tylko uzytkownik, ale tez urzadzenie musi byc zweryfikowane
- Sprawdzenie stanu urzadzenia: aktualizacje, antywirus, szyfrowanie dysku
- Mozliwosc odmowy dostepu z niezaufanego urzadzenia

**Narzedzia:** Microsoft Intune, Jamf, Google BeyondCorp Enterprise

### 5. Ciagly monitoring i walidacja (Continuous Verification)
- Weryfikacja nie jest jednorazowa — trwa przez cala sesje
- Anomalie w zachowaniu moga spowodowac ponowna autentykacje
- Analiza ryzyka w czasie rzeczywistym

**Sygnaly do monitorowania:**
- Nagla zmiana lokalizacji (impossible travel)
- Nietypowe godziny dostepu
- Masowe pobieranie danych
- Proby dostepu do nieuzywanych zasobow

## Implementacja Zero Trust — krok po kroku

### Faza 1: Identyfikacja
1. Zinwentaryzuj wszystkie zasoby (aplikacje, dane, serwisy)
2. Zmapuj przeplyw danych miedzy zasobami
3. Zidentyfikuj kto/co potrzebuje dostepu do czego

### Faza 2: Ochrona
4. Wdroz silne uwierzytelnianie (MFA) wszedzie
5. Wdroz centralny Identity Provider
6. Zastosuj zasade najmniejszych uprawnien

### Faza 3: Segmentacja
7. Wdroz mikrosegmentacje sieci
8. Ustaw polityki dostepu dla kazdego segmentu
9. Wdroz mTLS dla komunikacji miedzy serwisami

### Faza 4: Monitorowanie
10. Wdroz centralny system logow (SIEM)
11. Skonfiguruj alerty na anomalie
12. Regularne audyty i przeglady dostepu

## Zero Trust w mikroserwisach

### Service-to-Service Authentication (mTLS)
```
Serwis A ──[mTLS]──→ Serwis B

Obie strony prezentuja certyfikaty.
Certyfikaty wydawane przez wewnetrzny CA.
Rotacja automatyczna (np. co 24h).
```

**Narzedzia:** Istio, Linkerd, SPIFFE/SPIRE

### Service Mesh jako enforcement layer
```
┌──────────────────────────────────┐
│           Service Mesh           │
│                                  │
│  ┌─────┐  mTLS  ┌─────┐        │
│  │Proxy│←──────→│Proxy│        │
│  │(A)  │        │(B)  │        │
│  └──┬──┘        └──┬──┘        │
│     │               │           │
│  ┌──┴──┐        ┌──┴──┐        │
│  │Svc A│        │Svc B│        │
│  └─────┘        └─────┘        │
│                                  │
│  Polityki:                       │
│  - Svc A moze wywolac Svc B     │
│  - Svc B NIE moze wywolac Svc A │
│  - Rate limit: 100 req/s        │
└──────────────────────────────────┘
```

### Authorization Policies
```yaml
# Istio AuthorizationPolicy
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: order-service-policy
spec:
  selector:
    matchLabels:
      app: order-service
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/api-gateway"]
    to:
    - operation:
        methods: ["GET", "POST"]
        paths: ["/api/orders/*"]
```

## Zero Trust dla API

### Token-based access
1. Klient uwierzytelnia sie w Identity Provider
2. Otrzymuje token JWT z ograniczonymi uprawnieniami
3. Kazde API weryfikuje token niezaleznie
4. Token ma krotki czas zycia (15 min)

### API Gateway jako enforcement point
```
Klient → [API Gateway] → Serwis
            │
            ├── Weryfikacja tokena
            ├── Sprawdzenie uprawnien
            ├── Rate limiting
            ├── Logowanie dostepu
            └── Threat detection
```

## Narzedzia i technologie

| Kategoria | Narzedzia |
|-----------|-----------|
| Identity Provider | Azure AD, Okta, Auth0, Keycloak |
| Service Mesh | Istio, Linkerd, Consul Connect |
| Network Segmentation | Calico, Cilium, AWS Security Groups |
| Device Trust | Microsoft Intune, Jamf, CrowdStrike |
| SIEM / Monitoring | Splunk, Microsoft Sentinel, Elastic SIEM |
| Policy Engine | Open Policy Agent (OPA), HashiCorp Sentinel |
| Secrets Management | HashiCorp Vault, AWS Secrets Manager |
| Certificate Management | cert-manager, SPIFFE/SPIRE, Vault PKI |

## Wyzwania

- **Zlozonosc wdrozenia** — wymaga zmiany podejscia, nie tylko narzedzi
- **Wydajnosc** — dodatkowa weryfikacja przy kazdym zadaniu
- **Legacy systemy** — nie wszystkie systemy mozna latwo dostosowac
- **Kultura organizacyjna** — wymaga wspolpracy miedzy zespolami
- **Koszt** — narzedzia, szkolenia, czas wdrozenia

## Kluczowe wnioski

1. Zero Trust to **strategia, nie produkt** — nie kupujesz jednego narzedzia
2. Wdrazaj **stopniowo** — zacznij od najwazniejszych zasobow
3. **Automatyzuj** polityki — reczne zarzadzanie nie skaluje sie
4. **Monitoruj ciagle** — statyczna konfiguracja to za malo
5. Zero Trust **nie eliminuje** calkowicie ryzyka — minimalizuje powierzchnie ataku
