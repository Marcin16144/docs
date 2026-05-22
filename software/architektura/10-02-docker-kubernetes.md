# Docker i Kubernetes

## Docker — konteneryzacja

### Czym jest Docker?

Docker to platforma do tworzenia, uruchamiania i zarzadzania kontenerami. Kontener to lekkie, izolowane srodowisko, ktore zawiera aplikacje i wszystkie jej zaleznosci. W przeciwienstwie do maszyn wirtualnych, kontenery wspoldziela jadro systemu operacyjnego.

```
Maszyna wirtualna:              Kontener:
┌────────┐ ┌────────┐          ┌────────┐ ┌────────┐
│  App A │ │  App B │          │  App A │ │  App B │
│  Libs  │ │  Libs  │          │  Libs  │ │  Libs  │
│ Guest  │ │ Guest  │          └───┬────┘ └───┬────┘
│   OS   │ │   OS   │              │          │
└───┬────┘ └───┬────┘          ┌───┴──────────┴────┐
┌───┴──────────┴────┐          │  Docker Engine     │
│    Hypervisor     │          │  Host OS (kernel)  │
│    Host OS        │          │  Hardware          │
│    Hardware       │          └────────────────────┘
└───────────────────┘
Ciezkie (GB), wolny start       Lekkie (MB), szybki start
```

### Dockerfile — dobre praktyki

```dockerfile
# ZLE — duzy obraz, wolny build
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["node", "dist/server.js"]
# Rozmiar: ~1.2 GB, kazda zmiana kodu = reinstalacja zaleznosci

# ─────────────────────────────────────────────

# DOBRZE — multi-stage build, maly obraz
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci                    # najpierw zaleznosci (cache)
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:20-alpine AS production
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

USER appuser                  # nie uruchamiaj jako root
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:3000/healthz || exit 1

CMD ["node", "dist/server.js"]
# Rozmiar: ~150 MB, zaleznosci cachowane
```

### Kluczowe praktyki Dockerfile

| Praktyka | Dlaczego |
|----------|----------|
| **Multi-stage builds** | Mniejszy obraz — tylko runtime, bez build tools |
| **Alpine base** | ~5 MB zamiast ~900 MB (ubuntu) |
| **COPY package*.json najpierw** | Cache warstw — zaleznosci nie zmienia sie czesto |
| **npm ci zamiast npm install** | Deterministyczna instalacja z lock file |
| **USER non-root** | Bezpieczenstwo — ograniczenie uprawnien |
| **HEALTHCHECK** | Automatyczne sprawdzanie zdrowia kontenera |
| **.dockerignore** | Pomijaj node_modules, .git, .env |

### .dockerignore

```
node_modules
.git
.gitignore
.env
.env.*
*.md
docker-compose*.yml
.github
coverage
.nyc_output
```

### Docker Compose

```yaml
# docker-compose.yml
services:
  app:
    build:
      context: .
      target: production
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://postgres:secret@db:5432/myapp
      REDIS_URL: redis://redis:6379
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD: secret
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 3s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru

volumes:
  pgdata:
```

## Kubernetes — orkiestracja

### Czym jest Kubernetes?

Kubernetes (K8s) to platforma do orkiestracji kontenerow — automatyzuje wdrazanie, skalowanie i zarzadzanie konteneryzowanymi aplikacjami.

```
┌──────────────────────────────────────────────┐
│              Kubernetes Cluster               │
│                                               │
│  ┌─────────────────────────────────────────┐ │
│  │          Control Plane                   │ │
│  │  API Server | Scheduler | etcd          │ │
│  │  Controller Manager                      │ │
│  └─────────────────────────────────────────┘ │
│                                               │
│  ┌─────────────┐  ┌─────────────┐           │
│  │   Node 1    │  │   Node 2    │           │
│  │ ┌─────────┐ │  │ ┌─────────┐ │           │
│  │ │  Pod A  │ │  │ │  Pod A  │ │           │
│  │ │  Pod B  │ │  │ │  Pod C  │ │           │
│  │ └─────────┘ │  │ └─────────┘ │           │
│  │   kubelet   │  │   kubelet   │           │
│  └─────────────┘  └─────────────┘           │
└──────────────────────────────────────────────┘
```

### Pod

Najmniejsza jednostka w K8s. Jeden lub wiecej kontenerow wspoldzielacych siec i storage.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  containers:
    - name: app
      image: ghcr.io/org/my-app:1.2.3
      ports:
        - containerPort: 3000
      resources:
        requests:
          memory: "128Mi"
          cpu: "100m"
        limits:
          memory: "256Mi"
          cpu: "500m"
      livenessProbe:
        httpGet:
          path: /healthz
          port: 3000
        initialDelaySeconds: 10
        periodSeconds: 15
      readinessProbe:
        httpGet:
          path: /readyz
          port: 3000
        initialDelaySeconds: 5
        periodSeconds: 5
```

### Deployment

Zarzadza replikami Podow — deklaratywna konfiguracja, rolling updates, rollback.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0    # zero-downtime
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
        - name: app
          image: ghcr.io/org/my-app:1.2.3
          ports:
            - containerPort: 3000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: app-secrets
                  key: database-url
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
```

### Service

Eksponuje Pody jako stabilny endpoint sieciowy (DNS + load balancing).

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 3000
  type: ClusterIP    # wewnetrzny (domyslny)
  # type: NodePort   # na porcie kazdego Node
  # type: LoadBalancer # zewnetrzny LB (cloud)
```

### Ingress

Routing HTTP z zewnatrz do wewnetrznych serwisow — L7 load balancer.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
    - hosts:
        - api.example.com
      secretName: api-tls
  rules:
    - host: api.example.com
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: my-app-service
                port:
                  number: 80
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-service
                port:
                  number: 80
```

### Resource Limits

```yaml
resources:
  requests:          # gwarantowane minimum
    memory: "128Mi"  # 128 MB RAM
    cpu: "100m"      # 0.1 CPU core
  limits:            # maksimum
    memory: "256Mi"  # 256 MB RAM (przekroczenie = OOMKill)
    cpu: "500m"      # 0.5 CPU core (przekroczenie = throttling)
```

| Zasada | Opis |
|--------|------|
| Zawsze ustawiaj requests | Scheduler uzywa ich do planowania |
| Memory limit = requests * 2 | Bufor na spike'i |
| CPU limit ostrożnie | Throttling moze spowolnic aplikacje |
| LimitRange | Domyslne limity dla namespace |

## Helm Charts

Helm to menedzer pakietow dla Kubernetes — szablony YAML z parametrami.

```yaml
# Chart.yaml
apiVersion: v2
name: my-app
version: 1.0.0
appVersion: "1.2.3"

# values.yaml
replicaCount: 3
image:
  repository: ghcr.io/org/my-app
  tag: "1.2.3"
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "500m"
ingress:
  enabled: true
  host: api.example.com
```

```bash
# Instalacja
helm install my-app ./charts/my-app -f values-prod.yaml

# Upgrade
helm upgrade my-app ./charts/my-app --set image.tag=1.2.4

# Rollback
helm rollback my-app 1

# Historia
helm history my-app
```

## Przydatne komendy kubectl

```bash
# Status
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get ingress

# Logi
kubectl logs my-app-pod-abc123
kubectl logs -f deployment/my-app    # follow

# Debugging
kubectl describe pod my-app-pod-abc123
kubectl exec -it my-app-pod-abc123 -- /bin/sh

# Skalowanie
kubectl scale deployment my-app --replicas=5

# Rolling update
kubectl set image deployment/my-app app=ghcr.io/org/app:1.2.4
kubectl rollout status deployment/my-app
kubectl rollout undo deployment/my-app   # rollback

# Port forwarding (debugging)
kubectl port-forward svc/my-app-service 8080:80
```

## Kluczowe wnioski

1. **Multi-stage builds** — mniejsze obrazy, szybsze wdrozenia
2. **Alpine base images** — minimalizuj powierzchnie ataku
3. **Nie uruchamiaj jako root** — USER w Dockerfile
4. **Deployment, nie Pod** — deklaratywne, rolling updates, rollback
5. **Requests i Limits** — zawsze ustawiaj zasoby
6. **Liveness + Readiness probes** — K8s musi wiedziec czy Pod jest zdrowy
7. **Helm** do zarzadzania zlozpna konfiguracja — szablony z wartosciami per srodowisko
