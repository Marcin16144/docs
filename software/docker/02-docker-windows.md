# Docker na Windows

## Architektura — Docker NIE działa natywnie na Windows

**Kluczowy fakt:** Docker uruchamia kontenery **Linux**. Windows kernel ≠ Linux kernel. Aby Docker działał na Windows, musi mieć **mini-VM Linux** w tle.

```
┌─────────────────────────────────────────┐
│           Windows Host                   │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │   Docker Desktop (GUI app)         │ │
│  └──────────────┬─────────────────────┘ │
│                 │                       │
│  ┌──────────────▼─────────────────────┐ │
│  │     WSL2 (Linux VM)                 │ │  ← Tu działają kontenery
│  │  ┌──────────────────────────────┐  │ │
│  │  │  Docker Daemon (Linux)        │  │ │
│  │  │  ┌────────┐ ┌────────┐       │  │ │
│  │  │  │Container│ │Container│      │  │ │
│  │  │  └────────┘ └────────┘       │  │ │
│  │  └──────────────────────────────┘  │ │
│  └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

## WSL2 vs Hyper-V backend

Docker Desktop oferuje 2 backendy:

### WSL2 (preferowany 2026)
- **Lżejszy** — używa WSL2 (Windows Subsystem for Linux v2)
- **Szybszy** start (sekundy)
- **Lepsza integracja** z Windows
- **Działa na Windows 10 Home** (Hyper-V wymaga Pro)
- Filesystem: lepsze performance dla kodu w WSL2 fs niż w `C:\`

### Hyper-V (legacy)
- Starszy backend
- Wymaga **Windows Pro/Enterprise** (Hyper-V feature)
- Wolniejszy
- Już nie zalecany w 2026

**Ustaw w Docker Desktop:** Settings → General → "Use the WSL 2 based engine" ✓

## Wymagania systemowe (2026)

### Minimum:
- **Windows 10/11** 64-bit (Pro, Enterprise, Education, lub Home z WSL2)
- **WSL2** — wymaga Windows 10 build 19041+ (May 2020) lub Windows 11
- **Wirtualizacja włączona w BIOS** (VT-x dla Intel, AMD-V dla AMD)
- **Hyper-V włączony** (dla Hyper-V backend) lub wystarczy WSL2
- **4 GB RAM** (8 GB+ realnie potrzebne)
- **20 GB free disk** dla obrazów + kontenerów

### Sprawdzenie systemowe:
```powershell
# Wersja Windows
winver

# WSL2 dostępny?
wsl --status

# Wirtualizacja włączona?
systeminfo | findstr "Hyper-V Requirements"
# Lub Task Manager → Performance → CPU → "Virtualization: Enabled"

# CPU support (powinien być TAK dla wszystkich x64)
# Sprawdź w BIOS jeśli "Disabled" w Task Manager
```

## Instalacja Docker Desktop na Windows

### Krok 1: Włącz WSL2
```powershell
# Run jako Administrator (PowerShell)
wsl --install

# Lub osobne kroki:
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart komputera

# Po restarcie zainstaluj Ubuntu (lub inny distro)
wsl --install -d Ubuntu

# Sprawdź
wsl --list --verbose
# NAME    STATE    VERSION
# Ubuntu  Running  2

# Jeśli VERSION=1, upgrade:
wsl --set-version Ubuntu 2
wsl --set-default-version 2
```

### Krok 2: Pobierz Docker Desktop
1. Idź do: **docs.docker.com/desktop/install/windows-install/**
2. Pobierz **Docker Desktop Installer.exe**
3. Run installer:
   - **Use WSL 2 instead of Hyper-V** → ✓ (zalecane)
   - **Add shortcut to desktop** → ✓ (opcjonalne)
4. **Restart** wymagany

### Krok 3: Pierwsze uruchomienie
1. Uruchom Docker Desktop z menu Start
2. Akceptuj **Service Agreement**
3. **Sign in to Docker Hub** (opcjonalne, ale przydatne dla pull rate limits)
4. Settings → Resources → WSL Integration:
   - **Enable integration with my default WSL distro** ✓
   - **Enable integration with additional distros** → Ubuntu ✓ (jeśli masz)

### Krok 4: Test
```powershell
docker --version
# Docker version 27.x.x

docker run hello-world
# Pulls image from Docker Hub
# Runs container
# Prints "Hello from Docker!"

docker info
# Pokazuje status daemon, używaną ilość pamięci, itp.
```

## Konfiguracja Docker Desktop

### Resources (ważne!)
**Settings → Resources → Advanced**

| Setting | Default | Recommended |
|---------|---------|-------------|
| **CPUs** | 2 | 4-8 (połowa dostępnych) |
| **Memory** | 2 GB | 8-16 GB (1/3-1/2 RAM) |
| **Swap** | 1 GB | 2-4 GB |
| **Disk image size** | 64 GB | 100-200 GB |

⚠️ **Uwaga:** Docker Desktop alokuje te zasoby **stale** (WSL2 backend zwalnia gdy nieużywane, Hyper-V trzyma).

### File sharing (Hyper-V backend only)
Settings → Resources → File Sharing — wybierz dyski które Docker może mountować jako bind mounts.

W WSL2 backend: pliki w `\\wsl$\Ubuntu\home\user\` są szybkie. Pliki w `C:\Users\...` mountowane jako bind mounts są **wolne** (Plan 9 protocol).

### Docker Engine config
Settings → Docker Engine → JSON config:
```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "features": {
    "buildkit": true
  },
  "registry-mirrors": [],
  "insecure-registries": ["registry.local:5000"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-address-pools": [
    {"base": "172.30.0.0/16", "size": 24}
  ]
}
```

## Filesystem — TIPS dla wydajności

### Problem: bind mount z C:\ jest WOLNY
```bash
# WOLNE (~5-50× wolniej):
docker run -v C:/Users/me/project:/app node:20

# SZYBKIE — kod w WSL2 filesystem:
# 1. W terminalu WSL2:
cd ~
git clone https://github.com/me/project
# 2. Z Windows: \\wsl$\Ubuntu\home\me\project
# 3. Docker:
docker run -v ~/project:/app node:20
```

### Strategia 2026:
- **Kod trzymaj w WSL2** filesystem (`\\wsl$\Ubuntu\home\...`)
- **VS Code Remote-WSL** extension — edycja w WSL2 z poziomu Windows VS Code
- Bind mounty z WSL2 path są szybkie

### Performance per scenariusz

| Scenariusz | Performance |
|------------|-------------|
| Kod w WSL2 + Docker | ⭐ Świetnie (native) |
| Kod w `C:\` + bind mount | ❌ Wolno (5-50×) |
| Tylko named volumes (no bind) | ⭐ Szybko |
| Heavy I/O (database) | Named volume ✓, bind ✗ |
| Watch (file changes) | WSL2 fs OK, Windows fs unreliable |

## Network — Docker Windows specifics

### localhost
```powershell
# Z Windows host do kontenera:
docker run -p 8080:80 nginx
# Działa: http://localhost:8080  ✓

# Z kontenera do Windows host:
# Use specjalna nazwa: host.docker.internal
# np. baza danych na Windows host:
docker run --add-host=host.docker.internal:host-gateway myapp
```

### WSL2 sieć
WSL2 ma swoją siecionkę z osobnym IP:
```bash
# W WSL2:
ip addr  # zazwyczaj 172.x.x.x

# Windows host IP z perspektywy WSL2:
cat /etc/resolv.conf  # nameserver = Windows host IP
```

### Port forwarding
Docker Desktop automatycznie forwarduje porty z WSL2 VM do Windows host.

```powershell
docker run -p 3000:3000 myapp
# Dostępne:
# - http://localhost:3000  (z Windows)
# - http://localhost:3000  (z WSL2 — Windows port forwarding)
# - z innych komputerów w sieci: http://<windows-ip>:3000
```

## GPU support (NVIDIA)

W 2026 GPU passthrough do Docker działa via WSL2:

### Wymagania:
- Windows 11 lub Windows 10 21H2+
- NVIDIA GPU + driver 510.x+ (newer is better)
- Docker Desktop z WSL2 backend
- WSL2 z Linux distro

### Setup:
```powershell
# 1. Update NVIDIA driver na Windows (najnowszy z nvidia.com)

# 2. W WSL2 — NIE instaluj NVIDIA driver! (Windows driver wystarczy)

# 3. Zainstaluj NVIDIA Container Toolkit w WSL2:
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt update && sudo apt install -y nvidia-container-toolkit

# 4. Test:
docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu24.04 nvidia-smi
# Powinno pokazać Twoje GPU
```

**Use cases:** ML training, LLM inference (Ollama w Docker), video processing, GPU-accelerated databases.

## Windows Containers (rzadkie)

Jeśli potrzebujesz Windows containers (np. legacy .NET Framework):

```powershell
# Switch z Linux containers na Windows containers
# (right-click Docker tray icon → "Switch to Windows containers")

# Lub PowerShell:
& 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon

# Test:
docker pull mcr.microsoft.com/windows/nanoserver:ltsc2025
docker run mcr.microsoft.com/windows/nanoserver:ltsc2025 cmd.exe /c echo "Hello from Windows container"
```

**Uwaga:** Przy Windows containers tracisz dostęp do Linux containers (i vice versa). Większość projektów używa Linux containers, ergo zostaw default.

## Docker Desktop license (2026)

Docker Desktop wymaga **Pro/Team/Business subscription** dla:
- Firm > 250 osób, LUB
- Firm z revenue > $10M/rok

**Free dla:**
- Personal use
- Education
- Open source projects
- Small businesses (poniżej limitu)

**Pricing 2026:**
- **Personal**: Free
- **Pro**: $9/mc per user
- **Team**: $15/mc per user
- **Business**: $24/mc per user

**Alternatives jeśli nie chcesz Docker Desktop license:**
- **Podman Desktop** — free, open source
- **Rancher Desktop** — free, open source
- **Docker CE w WSL2** (bez Desktop) — free, ale więcej setupu

### Setup Docker bez Docker Desktop (WSL2)

```bash
# W WSL2 Ubuntu:
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start daemon
sudo service docker start

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Test
docker run hello-world
```

**Plus:** Free, full Docker functionality
**Minus:** Brak GUI, ręczne start service po każdym restarcie WSL2

### Auto-start Docker w WSL2 (bez Desktop)
```bash
# Edytuj ~/.bashrc
echo 'if service docker status > /dev/null 2>&1; then : ; else sudo service docker start; fi' >> ~/.bashrc
```

## Troubleshooting Windows-specific

### "Docker Desktop requires WSL 2"
```powershell
wsl --update
wsl --set-default-version 2
```

### "Hardware assisted virtualization is not enabled"
Włącz w BIOS:
- Intel: VT-x, VT-d
- AMD: SVM, AMD-V
Po włączeniu → restart

### "Docker daemon not running"
```powershell
# Restart Docker Desktop:
Stop-Service docker
Start-Service docker

# Lub: kill Docker Desktop process i uruchom ponownie
```

### "Cannot connect to Docker daemon" w WSL2
```bash
# Sprawdź WSL integration:
# Docker Desktop → Settings → Resources → WSL Integration
# Enable for your distro

# Lub manual:
docker context use desktop-linux
```

### Bind mount jest powolny
- Move kod do WSL2 filesystem (`~`)
- Lub użyj **named volume** zamiast bind mount

### Wysokie zużycie pamięci przez Vmmem.exe
**Vmmem.exe** to proces WSL2 VM. Limit przez `~/.wslconfig`:
```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
```
```powershell
# Po edycji:
wsl --shutdown
# Następne uruchomienie WSL/Docker użyje nowego config
```

### "no space left on device"
```powershell
# Wyczyść Docker:
docker system prune -a --volumes

# Sprawdź disk image WSL2:
# %USERPROFILE%\AppData\Local\Docker\wsl\data\ext4.vhdx
# Może być duży nawet po prune (Docker nie shrink automatically)

# Manual shrink:
wsl --shutdown
diskpart
# w diskpart:
select vdisk file="C:\Users\<user>\AppData\Local\Docker\wsl\data\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```

### Docker Desktop crashes
1. Restart Docker Desktop
2. Reset to factory defaults: Settings → Troubleshoot → Reset to factory defaults
3. Reinstall Docker Desktop (last resort)

### Slow npm install / yarn install w bind mount
**Solution:** node_modules na named volume:
```yaml
# compose.yaml
services:
  app:
    image: node:20
    volumes:
      - .:/app
      - /app/node_modules  # anonymous volume — fast
    working_dir: /app
```

## VS Code + Docker workflow (rekomendowany)

```
1. Install VS Code
2. Install extensions:
   - Docker (Microsoft)
   - Dev Containers (Microsoft)
   - WSL (Microsoft)

3. Otwórz folder w WSL2:
   - Ctrl+Shift+P → "WSL: Open Folder in WSL"
   - Albo: code . z poziomu WSL2

4. Dla projektów Docker:
   - Stwórz .devcontainer/devcontainer.json
   - Ctrl+Shift+P → "Dev Containers: Reopen in Container"
   - VS Code uruchamia kontener i otwiera folder w nim

5. Wszystko (terminal, debugger, extensions) działa wewnątrz kontenera
```

Przykład `.devcontainer/devcontainer.json`:
```json
{
    "name": "Node.js Dev",
    "image": "mcr.microsoft.com/devcontainers/javascript-node:20",
    "forwardPorts": [3000],
    "postCreateCommand": "npm install",
    "customizations": {
        "vscode": {
            "extensions": [
                "esbenp.prettier-vscode",
                "dbaeumer.vscode-eslint"
            ]
        }
    }
}
```

## Komendy Windows-specific

```powershell
# Lista WSL distros
wsl --list --verbose

# Restart WSL (np. po zmianie .wslconfig)
wsl --shutdown

# Switch distro
wsl --set-default Ubuntu

# Eksportuj WSL distro (backup)
wsl --export Ubuntu C:\backup\ubuntu.tar

# Import WSL distro
wsl --import NewName C:\WSL\NewName ubuntu.tar

# Konfig WSL (w Notepad)
notepad %UserProfile%\.wslconfig
```

`~/.wslconfig` opcje:
```ini
[wsl2]
memory=8GB                # max RAM dla WSL2 VM
processors=4              # max CPU
swap=2GB                  # swap size
swapFile=C:\\temp\\wsl-swap.vhdx
localhostForwarding=true  # default true
nestedVirtualization=true # for nested Docker/K8s

[experimental]
sparseVhd=true            # auto-shrink VHD
autoMemoryReclaim=gradual # reclaim unused memory gradually
networkingMode=mirrored   # better networking (Win 11)
dnsTunneling=true
firewall=true
autoProxy=true
```

## Best practices Windows

```
☐ Włącz WSL2 backend (nie Hyper-V)
☐ Trzymaj kod w WSL2 filesystem (nie C:\)
☐ Użyj VS Code Remote-WSL dla edycji
☐ Skonfiguruj memory limit w .wslconfig (8-16 GB)
☐ Disk size dla Docker: 100-200 GB
☐ Auto-update Docker Desktop wyłączony jeśli stabilność krytyczna
☐ Backup Docker volumes regularnie
☐ Wyłącz Docker Desktop przy zamknięciu pracy (oszczędność pamięci)
☐ Zsync z Windows Defender exclusions:
   - C:\Users\<user>\AppData\Local\Docker
   - %USERPROFILE%\.docker
   - WSL2 disk image (ext4.vhdx)
```

## Podsumowanie

Docker na Windows w 2026:
1. **WSL2 backend** to standard
2. **Trzymaj kod w WSL2** dla performance
3. **Docker Desktop** wymaga subscription dla większych firm — alternatywy: Podman Desktop, Rancher Desktop, Docker CE w WSL2
4. **GPU support** działa świetnie z NVIDIA + WSL2
5. **VS Code Remote-WSL** to game changer dla productivity
6. **Linux containers** = 99% przypadków (Windows containers tylko dla legacy .NET Framework)

W kolejnym rozdziale: **macOS specifics** — Docker Desktop, Colima, OrbStack.
