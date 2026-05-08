# DevOps i wdrażanie

> **Aktualizacja: 2026** — GitHub Actions dominują, ArgoCD jako mainstream GitOps, Pulumi rosnące obok Terraform/OpenTofu, Cloud Run/Fly.io/Railway jako prostsze niż K8s, WASM jako alternatywny format serverless, OpenTelemetry jako standard observability, AI w narzędziach DevOps (Claude Code, Cursor, Aider).

## CI/CD (Continuous Integration / Continuous Delivery)

### Continuous Integration (CI)
Automatyczne budowanie i testowanie kodu po każdym commicie.

**Pipeline CI:**
```
Commit → Build → Unit Tests → Integration Tests → Static Analysis → Artifact
```

### Continuous Delivery (CD)
Automatyczne wdrażanie na środowiska po pomyślnym CI.

**Pipeline CD:**
```
Artifact → Deploy Staging → E2E Tests → Manual Approval → Deploy Production
```

### Narzędzia CI/CD (stan na 2026)
- **GitHub Actions** — dominujący wybór dla nowych projektów; bogaty marketplace, reusable workflows, runners w chmurze i self-hosted
- **GitLab CI/CD** — zintegrowany w GitLabie, mocny w samodzielnie hostowanych instancjach
- **ArgoCD** — *de facto* standard GitOps dla Kubernetes (deklaratywne, pull-based)
- **Flux CD** — alternatywa GitOps, lekka, dobra integracja z Helm/Kustomize
- **Dagger** — programowalne pipeline'y (TypeScript / Python / Go), uruchamiane lokalnie i w CI
- **Buildkite**, **CircleCI**, **Jenkins**, **Azure DevOps Pipelines**, **TeamCity**

### AI w narzędziach DevOps (2026)
AI-assisted development jest mainstream:
- **Claude Code**, **Cursor**, **Aider**, **GitHub Copilot Workspace** — wsparcie pisania kodu, generowania PR-ów, refactoringu
- AI w code review (np. CodeRabbit, automatyczne komentarze w PR)
- Generowanie testów, migracji, runbooków, ADR-ów

---

## Strategie wdrażania

### Blue-Green Deployment
Dwa identyczne środowiska. Nowa wersja na "green", po weryfikacji przełączenie ruchu.

```
[Load Balancer]
      │
      ├──→ Blue (v1.0) ← aktualny ruch
      │
      └──→ Green (v2.0) ← nowa wersja, testowana
      
Po weryfikacji: przełączenie na Green
```

### Canary Deployment
Stopniowe przekierowywanie ruchu na nową wersję (np. 5% → 25% → 50% → 100%).

### Rolling Update
Stopniowa wymiana instancji — jedna po drugiej.

### Feature Flags
Włączanie/wyłączanie funkcji bez wdrożenia nowego kodu.
**Narzędzia:** LaunchDarkly, Unleash, Flagsmith

---

## Konteneryzacja i orkiestracja

### Docker / OCI
Pakowanie aplikacji z zależnościami w izolowany kontener (standard OCI).

**Dobre praktyki Dockerfile:**
- Używaj wieloetapowych buildów (multi-stage)
- Minimalizuj warstwy
- Nie uruchamiaj jako root (USER nonroot)
- Używaj .dockerignore
- Pinuj wersje bazowego obrazu (najlepiej po digestach SHA, nie tagach)
- Skanuj obrazy pod kątem CVE (Trivy, Grype, Snyk)
- Buduj minimalne obrazy: distroless (Google), Chainguard Images, Wolfi
- **Buildery (2026):** Docker Buildx, **BuildKit**, **Podman**, **Buildah**, **Nixpacks** (Railway/Vercel), **ko** (Go)

### WASM jako alternatywa serverless (2026)
- **WebAssembly + WASI** dojrzewa jako lekki, szybki, sandboxowany format do uruchamiania kodu
- **Spin** (Fermyon), **Fastly Compute**, **wasmCloud**, **WasmEdge**, **Cloudflare Workers**
- Czas startu liczy się w mikrosekundach (vs sekundy w kontenerach)
- Idealny dla edge functions, multi-tenant SaaS, plug-inów

### Kubernetes (K8s)
Nadal *de facto* standard orkiestracji kontenerów — automatyczne skalowanie, self-healing, rolling updates.

**Kluczowe obiekty:**
- **Pod** — najmniejsza jednostka (1+ kontenerów)
- **Deployment** — zarządza replikami podów
- **Service** — stabilny endpoint sieciowy
- **Ingress / Gateway API** — routing HTTP z zewnątrz (Gateway API zastępuje Ingress w nowych projektach)
- **ConfigMap / Secret** — konfiguracja i sekrety (sekrety lepiej zarządzane przez External Secrets Operator + Vault/AWS Secrets Manager)

**Ekosystem K8s (2026):**
- **Helm** i **Kustomize** dla pakowania
- **Cilium** jako CNI/Service Mesh oparty o eBPF
- **KEDA** — autoscaling oparty o eventy (Kafka lag, kolejki)
- **Karpenter** — efektywny autoscaler węzłów (AWS, oraz coraz częściej multi-cloud)

### Prostsze platformy niż K8s (rosnąca popularność)
Dla wielu zespołów K8s to nadmiar — w 2026 popularne są platformy aplikacyjne abstrahujące infrastrukturę:
- **Google Cloud Run** — kontenery serverless, skalowanie do zera, prosty deploy
- **Fly.io** — globalne wdrożenia kontenerów blisko użytkowników
- **Railway**, **Render**, **Vercel**, **Netlify** — PaaS dla aplikacji webowych
- **AWS App Runner**, **Azure Container Apps** — managed kontenery w hyperscalerach
- **Kamal** (Basecamp/37signals) — deploy kontenerów na własnych VPS-ach bez K8s

---

## Infrastructure as Code (IaC)

Infrastruktura definiowana jako kod — wersjonowalna, powtarzalna, automatyczna.

**Narzędzia (2026):**
- **Terraform** — wciąż lider, deklaratywny, multi-cloud (HCL); od zmiany licencji wielu wybiera fork **OpenTofu** (CNCF)
- **Pulumi** — szybko zyskuje popularność, IaC w prawdziwych językach (TypeScript, Python, Go, C#) — łatwiej testować, refaktoryzować, używać pętli i abstrakcji
- **AWS CDK** — IaC w językach programowania, generuje CloudFormation
- **AWS CloudFormation**, **Azure Bicep**, **Google Cloud Deployment Manager** — natywne IaC w hyperscalerach
- **Crossplane** — zarządzanie infrastrukturą jako zasoby Kubernetes (CRDs)
- **Ansible** — konfiguracja serwerów (config management), provisioning
- **Nix / NixOS** — deklaratywne, reprodukowalne środowiska i systemy
- Polityki: **OPA / Conftest**, **Checkov**, **tfsec**, **Terrascan**

---

## Observability (Obserwowalność)

### Trzy filary + jeden bonus

1. **Logs (Logi)** — zdarzenia w systemie
   - Strukturalne (JSON) > tekst
   - Poziomy: DEBUG, INFO, WARN, ERROR
   - Centralny agregator: Grafana Loki, ELK, OpenSearch, Vector

2. **Metrics (Metryki)** — pomiary liczbowe w czasie
   - RED: Rate, Errors, Duration
   - USE: Utilization, Saturation, Errors
   - Narzędzia: Prometheus + Grafana, Mimir, VictoriaMetrics

3. **Traces (Ślady)** — ścieżka żądania przez system
   - Distributed tracing dla mikroserwisów
   - Backendy: Grafana Tempo, Jaeger, Honeycomb, Datadog APM

4. **Continuous Profiling** (czwarty filar w 2026) — profil CPU/heap z produkcji
   - Grafana Pyroscope, Polar Signals, Datadog Continuous Profiler

### OpenTelemetry — standard w 2026
**OpenTelemetry (OTel)** to *de facto* standard instrumentacji aplikacji:
- Jeden zestaw SDK i jeden protokół (OTLP) dla traces / metrics / logs
- Auto-instrumentation dla większości języków (Java, Python, Node, Go, .NET, Ruby, PHP)
- **OpenTelemetry Collector** — uniwersalny przekaźnik telemetrii (eliminuje vendor lock-in)
- W praktyce: jeden SDK w aplikacji, kierujesz dane do dowolnego backendu (Datadog, Honeycomb, Grafana, Jaeger…)

### Alerting
- Alerty na symptomy (wysoki error rate, naruszone SLO), nie przyczyny
- Unikaj alert fatigue — każdy alert powinien wymagać akcji
- Runbooki opisujące co robić przy danym alercie
- SLO/SLI/SLA jako podstawa alertów (error budget)
