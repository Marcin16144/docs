# Podstawy Docker

## Czym jest Docker?

**Docker** to platforma do **konteneryzacji** aplikacji. Pozwala "zapakować" aplikację razem z jej zależnościami (biblioteki, narzędzia, konfiguracja) w izolowane kontenery, które uruchamiają się identycznie na każdym systemie.

```
"Działa u mnie na komputerze" → "Działa wszędzie"
```

## Kontenery vs Maszyny Wirtualne (VM)

```
┌────────────────────────────┐  ┌────────────────────────────┐
│      Maszyny Wirtualne      │  │        Kontenery            │
├────────────────────────────┤  ├────────────────────────────┤
│  App A    App B    App C   │  │  App A    App B    App C   │
│  Bins/Libs Bins/Libs Bins/Libs│ │  Bins/Libs Bins/Libs Bins/Libs│
│  ┌────┐  ┌────┐  ┌────┐     │  │  ┌────────────────────┐    │
│  │Guest│ │Guest│ │Guest│    │  │  │   Docker Engine    │    │
│  │ OS  │ │ OS  │ │ OS  │    │  │  └────────────────────┘    │
│  └────┘  └────┘  └────┘     │  │       Host OS              │
│      Hypervisor             │  │         Hardware           │
│       Host OS               │  │                            │
│       Hardware              │  │                            │
└────────────────────────────┘  └────────────────────────────┘

VM:                              Kontener:
- Pełny OS guest                 - Współdzieli kernel hosta
- ~GB pamięci                    - ~MB pamięci
- Minuty startu                  - Sekundy startu
- Pełna izolacja                 - Process-level izolacja
```

| Aspekt | VM | Kontener |
|--------|-----|----------|
| Rozmiar | GB | MB |
| Start | minuty | sekundy |
| Zasoby | ciężkie | lekkie |
| Izolacja | pełna (różne kernele) | namespace + cgroups |
| Use case | różne OS, full isolation | mikroservices, dev/prod parity |
| Density | dziesiątki na hoście | tysiące na hoście |

**Kluczowa różnica:** kontenery **współdzielą kernel** hosta. Dlatego są lekkie ale **muszą być Linux** (na macOS i Windows Docker uruchamia mini-VM Linux).

## Kluczowe pojęcia

### Image (obraz)
**Niemodyfikowalny** template aplikacji + zależności. Składa się z **warstw** (layers).

```
my-app:1.0
├── Layer 1: Ubuntu 22.04 base       ← współdzielony między obrazami
├── Layer 2: apt install nodejs       ← współdzielony jeśli inne obrazy też
├── Layer 3: COPY package.json
├── Layer 4: RUN npm install
└── Layer 5: COPY src/                ← zmienia się przy każdym build
```

### Container (kontener)
**Działająca instancja** obrazu. Można mieć wiele kontenerów z tego samego obrazu.

```
docker run nginx          # Kontener 1
docker run nginx          # Kontener 2 (z tego samego obrazu nginx)
```

### Registry (rejestr)
**Repozytorium obrazów**. Gdzie przechowujesz/pobierasz obrazy.

- **Docker Hub** (hub.docker.com) — domyślny, publiczny
- **GitHub Container Registry** (ghcr.io) — popularny w 2026
- **AWS ECR**, **Google Artifact Registry**, **Azure Container Registry** — cloud
- **Harbor**, **Nexus**, **JFrog Artifactory** — self-hosted
- **GitLab Container Registry** — wbudowany w GitLab

### Dockerfile
**Tekstowy plik** opisujący jak zbudować obraz.

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Volume (wolumen)
**Trwały storage** dla kontenerów (kontenery są ephemeral — dane giną przy rm).

### Network (sieć)
Pozwala kontenerom komunikować się ze sobą.

### Compose
**docker-compose.yaml** lub **compose.yaml** — definiuje wieloskładnikowe aplikacje.

## Architektura Docker

```
┌──────────────────────────────────────────┐
│           Docker Client (CLI)             │
│  docker run, docker build, docker ps...   │
└──────────────────┬───────────────────────┘
                   │ REST API
┌──────────────────▼───────────────────────┐
│           Docker Daemon (dockerd)         │
│  - Manages images, containers, networks   │
│  - Runs as root (Linux) lub WSL2 (Win)    │
└──────────────────┬───────────────────────┘
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   ┌────────┐ ┌────────┐ ┌────────┐
   │Container│ │Container│ │Container│
   │   A    │ │   B    │ │   C    │
   └────────┘ └────────┘ └────────┘
        │          │          │
        └──────────┼──────────┘
                   ▼
           Docker Network (bridge)
```

**Komponenty pod spodem:**
- **runc / containerd** — niskopoziomowy runtime
- **OCI** (Open Container Initiative) — standard format obrazów
- **Linux kernel features**: namespaces, cgroups, capabilities, seccomp

## Docker Engine vs Docker Desktop

### Docker Engine (CE — Community Edition)
- **Free**, open source
- Tylko Linux (natively)
- Sam Docker daemon + CLI
- Dla serwerów, CI/CD, produkcja

### Docker Desktop
- GUI app + Docker Engine + dodatki
- Windows, macOS, Linux
- **Płatne** dla firm > 250 osób / >$10M revenue (od 2021)
- Free dla individuals i small businesses
- Zawiera: Docker Compose, Kubernetes (opcjonalnie), Extensions

**W 2026:** licencjonowanie Docker Desktop kontrowersyjne — wiele firm migruje do **Podman Desktop**, **Rancher Desktop**, **OrbStack** (macOS), **Colima** (macOS).

## Workflow Docker — typowy

```
1. Stwórz Dockerfile
   ↓
2. docker build -t myapp:1.0 .
   (buduje obraz z Dockerfile)
   ↓
3. docker run myapp:1.0
   (uruchamia kontener)
   ↓
4. docker push myapp:1.0
   (wysyła do registry)
   ↓
5. Inny serwer:
   docker pull myapp:1.0
   docker run myapp:1.0
```

## Pierwsza interakcja

```bash
# Pobierz i uruchom hello-world
docker run hello-world

# Co się stało?
# 1. Docker daemon szuka obrazu hello-world lokalnie
# 2. Nie znalazł → pobiera z Docker Hub (registry)
# 3. Tworzy kontener z tego obrazu
# 4. Daemon uruchamia kontener który wypisuje "Hello from Docker!"
# 5. Kontener kończy się i zatrzymuje
```

## Dlaczego Docker?

### Plusy:
- **Reproducibility** — działa identycznie wszędzie
- **Isolation** — aplikacje nie wchodzą sobie w paradę
- **Lightweight** — szybkie, mało zasobów
- **Portability** — Windows, Mac, Linux, cloud
- **Microservices** — naturalne podejście
- **CI/CD friendly** — builds, tests w izolacji
- **Onboarding** — `docker compose up` i juniora w 5 min ma środowisko

### Minusy:
- **Performance overhead** — zwłaszcza na Mac/Windows (mini-VM)
- **Persistence** — wymaga Volumes (kontenery są ephemeral)
- **Networking** — bywa skomplikowane (zwłaszcza multi-host)
- **Security** — domyślnie root, wymaga konfiguracji
- **Docker Desktop licensing** — koszt dla większych firm
- **Storage** — obrazy zajmują miejsce (czyść regularnie!)

## Alternatywy Docker (2026)

| Narzędzie | Platform | Charakterystyka |
|-----------|----------|-----------------|
| **Podman** | Linux, Win, Mac | Daemonless, rootless first, Red Hat |
| **containerd** | Linux | Niskopoziomowy, używany przez K8s |
| **Buildah** | Linux | Tylko building images (pair z Podman) |
| **OrbStack** | macOS | Najszybszy na Mac, $96/yr personal, free dla edu |
| **Colima** | macOS | Free, open source alternative do Docker Desktop |
| **Rancher Desktop** | Win, Mac, Linux | Free, dla K8s |
| **Lima** | macOS | Linux VM, baza Colimy |
| **nerdctl** | Linux | Docker-compatible CLI dla containerd |

## Standard OCI

**OCI (Open Container Initiative)** to standard zapewniający compatibility:
- **OCI Image Spec** — format obrazów
- **OCI Runtime Spec** — uruchamianie kontenerów

Skutek: obraz zbudowany przez Docker działa w Podman, containerd, etc.

## Kontenery Linux vs Windows

### Kontenery Linux (99% przypadków)
- Działają na Linux hosts natywnie
- Na macOS / Windows: przez mini-VM Linux
- Standard branżowy

### Kontenery Windows (rzadkie)
- Tylko Windows hosts (Server 2016+, Windows 11 Pro)
- 2 modele: **Windows Server containers** (shared kernel) i **Hyper-V containers** (isolated)
- Use case: legacy .NET Framework apps, Windows-specific deps
- Cięższe niż Linux containers (GB+ image sizes)

**W 2026:** Windows Containers są niche — większość modern .NET apps używa .NET 8/9 które działa cross-platform → kontener Linux preferowany.

## Co dalej w tej dokumentacji?

| Rozdział | Co znajdziesz |
|----------|---------------|
| **02. Docker na Windows** | Docker Desktop, WSL2, troubleshooting, GPU |
| **03. Docker na macOS** | Docker Desktop, Colima, OrbStack, Apple Silicon |
| **04. Docker na Linux** | Native install per distro, rootless, Podman |
| **05. Komendy Docker** | Kompletny reference wszystkich komend |
| **06. Dockerfile best practices** | Multi-stage, caching, security, BuildKit |
| **07. Docker Compose** | Aplikacje wieloskładnikowe |
| **08. Sieć Docker** | Network drivers, port mapping, DNS |
| **09. Wolumeny** | Persistence, backup, performance |
| **10. Bezpieczeństwo** | Rootless, secrets, image scanning |

## Zasoby do nauki

- **docs.docker.com** — oficjalna dokumentacja
- **Play with Docker** (labs.play-with-docker.com) — playground w przeglądarce
- **DockerCon** — konferencja, nagrania na YouTube
- **Bret Fisher** — popular Docker trainer (YouTube, Udemy)
- **TechWorld with Nana** — YouTube tutoriale
- **Awesome Docker** (github.com/veggiemonk/awesome-docker) — curated lista
