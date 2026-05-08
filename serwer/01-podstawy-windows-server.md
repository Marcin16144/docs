# Podstawy Windows Server

## Wprowadzenie

Windows Server to system operacyjny serwerowy od Microsoft, używany w przedsiębiorstwach do hostowania usług sieciowych, baz danych, aplikacji webowych, kontroli domeny (Active Directory) i wirtualizacji (Hyper-V).

**Aktualna wersja w 2026:** Windows Server 2025 (wydane późno 2024, dojrzała w 2026), wciąż wspierane: Server 2022, 2019.

## Edycje (2026)

| Edycja | Cena/CPU | Use case | Limity |
|--------|----------|----------|--------|
| **Standard** | ~$1100 | SMB, dedykowane role | 2 Hyper-V VM, 1 Container Host |
| **Datacenter** | ~$6200 | Cloud, wysoka wirtualizacja | Nielimitowane VM, Software-Defined Datacenter |
| **Datacenter: Azure Edition** | Subscription | Tylko w Azure / Hot-patching | Hot-patch (no reboots), SMB over QUIC |
| **Essentials** | ~$500 (server-based) | Małe firmy do 25 użytkowników | 1 fizyczny serwer, brak Hyper-V license |
| **Standard / Datacenter ARC** | Subscription | Cross-cloud z Azure ARC | Hybrid management |

### Klucz wyboru:
- **Standard** — 90% scenariuszy on-prem, kilka VM
- **Datacenter** — gdy planujesz ponad 2 VM, hyper-converged, SDN
- **Azure Edition** — Azure-only, z hot-patching (no reboots dla updates!)
- **Essentials** — bardzo małe firmy (rzadko używana w 2026)

## Licencjonowanie

**Per-Core Licensing (od 2016):**
- Min. 16 core licenses na serwer (8 cores × 2 packs)
- Min. 8 core licenses na CPU
- Każdy fizyczny core musi być licencjonowany
- Plus **CAL (Client Access Licenses)** dla każdego użytkownika/urządzenia

```
Przykład: serwer z 2× CPU 16-core (32 cores total)
- 32 core licenses (16 packów po 2 core)
- + CALs dla użytkowników
- Datacenter: nielimitowane VM
- Standard: tylko 2 VM (jeśli więcej, kup kolejne core licenses dla 2 VM więcej)
```

**Ułatwienia w 2026:**
- **Software Assurance (SA)** — daje upgrade do najnowszej wersji + dodatkowe benefity
- **Subscription model** dla Datacenter Azure Edition
- **Azure Hybrid Benefit** — używaj on-prem licencji w Azure (oszczędność do 40%)

## Wymagania sprzętowe (Server 2025)

**Minimum:**
- CPU: 1.4 GHz x64 (z VBS, Hypervisor-V support)
- RAM: 512 MB (Server Core), 2 GB (Desktop Experience)
- Dysk: 32 GB
- TPM 2.0 (preferowane, częściowo wymagane)
- Secure Boot capable

**Realistic dla produkcji (single role):**
- CPU: 8+ cores, 2.5+ GHz (Intel Xeon, AMD EPYC)
- RAM: 32+ GB
- Dysk: NVMe SSD 256+ GB (system) + storage
- 2× NIC (separacja management i data)
- Redundancy: dual PSU, RAID, ECC RAM

**Server 2025 wymagania new:**
- Mocno preferowane: TPM 2.0
- VBS (Virtualization-Based Security) — domyślnie ON
- Memory integrity — domyślnie ON
- Niektóre features wymagają HVCI (Hypervisor-protected Code Integrity)

## Server Core vs Desktop Experience

### Server Core (zalecany dla produkcji)

**Co to:** Windows Server bez GUI. Tylko CMD, PowerShell, wybrane konsole MMC zdalnie.

**Plusy:**
- **Mniejsza powierzchnia ataku** — brak browse, brak GUI bugs
- **Mniej updates** (mniej komponentów = rzadziej restart)
- **Mniej zasobów** (RAM, dysk, CPU)
- **Szybszy boot**
- **Łatwiejsze zarządzanie via PowerShell DSC, Ansible**

**Minusy:**
- Brak GUI lokalnie — wymaga umiejętności PowerShell
- Niektóre aplikacje 3rd party wymagają Desktop (rzadko w 2026)
- Trudniejszy troubleshooting wizualny

### Desktop Experience (Server with Desktop)

**Plusy:**
- GUI (Server Manager, MMC, Edge browser)
- Łatwe dla początkujących administratorów
- Wszystkie 3rd party narzędzia działają

**Minusy:**
- Większa powierzchnia ataku
- Częstsze updates → częstsze reboot
- Więcej zasobów

### Rekomendacja 2026:
- **Server Core** dla produkcji (zwłaszcza usługi publiczne)
- **Desktop Experience** dla labów, jump hostów, rzadko-używanych serwerów
- **Windows Admin Center** zastępuje większość MMC consoles — możesz zarządzać Server Core z webowego GUI

## Role i Features

### Główne role:

| Rola | Co robi |
|------|---------|
| **Active Directory Domain Services** | Centralna kontrola tożsamości, kerberos auth |
| **DNS Server** | Rozwiązywanie nazw |
| **DHCP Server** | Dynamiczne IP |
| **IIS (Web Server)** | Hosting aplikacji webowych |
| **Hyper-V** | Wirtualizacja |
| **File and Storage Services** | SMB, iSCSI, Storage Spaces |
| **Print Services** | Centralne drukowanie |
| **Remote Desktop Services** | Terminal Server / VDI |
| **WSUS / MECM** | Zarządzanie aktualizacjami |
| **Network Policy Server (NPS)** | RADIUS, 802.1x |
| **Active Directory Certificate Services** | Własne PKI |
| **Active Directory Federation Services** | SSO, claims-based auth |
| **Failover Clustering** | High Availability |
| **Storage Replica** | Block-level replication |

### Features (dodatki, nie role):

- **PowerShell, .NET Framework 4.8 / .NET 8/9**
- **WSL2** (od Server 2022) — Linux containers
- **Containers** — Docker / Windows Containers
- **SMB** (różne wersje), **NFS Client/Server**
- **BitLocker** (szyfrowanie dysków)
- **RSAT** (Remote Server Administration Tools)
- **WindowsDefenderFeatures**

### Zasada: minimalizm

> **Instaluj tylko te role i features, których faktycznie potrzebujesz.**

Każda rola = większa powierzchnia ataku. Nie instaluj "na zapas".

```powershell
# Lista zainstalowanych ról
Get-WindowsFeature | Where-Object {$_.Installed -eq $true}

# Instalacja (przykład: IIS)
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Usunięcie niepotrzebnych
Uninstall-WindowsFeature -Name Print-Services
```

## Narzędzia administracyjne

### Tradycyjne:
- **Server Manager** — GUI dashboard z rolami
- **MMC consoles** (services.msc, eventvwr.msc, gpedit.msc...)
- **Active Directory Users and Computers** (dsa.msc)
- **DNS Manager** (dnsmgmt.msc)
- **Group Policy Management** (gpmc.msc)

### Nowoczesne (preferowane w 2026):

#### Windows Admin Center (WAC)
- **Web-based UI** zarządzania serwerami
- Zastępuje wiele MMC consoles
- Działa z lokalnego maszyny lub gateway server
- Free, ale Microsoft promuje
- Integruje się z Azure (Azure Arc)

#### PowerShell + DSC
- **PowerShell 7.x** — modern, cross-platform
- **Desired State Configuration (DSC)** — IaC dla Windows
- **PowerShell Remoting (WinRM)** — zarządzanie zdalne
- **Just Enough Administration (JEA)** — restricted PowerShell endpoints

#### Azure Arc (hybrid)
- Zarządzaj on-prem serwerami **jak Azure VM**
- Update management, security, monitoring centralnie z Azure portal
- Bardzo popularne w 2026 dla hybrid

#### RSAT (Remote Server Administration Tools)
- Pakiet narzędzi do zarządzania zdalnie (z Windows 11)
- AD, DNS, DHCP, GPO, IIS Manager, etc.

## Storage

### Storage Spaces
Software-defined storage. Łączy fizyczne dyski w pule, z RAID-like resilience.

```powershell
# Stwórz storage pool
New-StoragePool -FriendlyName "DataPool" -StorageSubsystemFriendlyName "Windows Storage*" -PhysicalDisks (Get-PhysicalDisk -CanPool $true)

# Stwórz virtual disk z mirroring
New-VirtualDisk -StoragePoolFriendlyName "DataPool" -FriendlyName "Data" -Size 1TB -ResiliencySettingName Mirror
```

### Storage Spaces Direct (S2D)
Hyper-converged storage — kilka serwerów dzieli dyski jako klaster. Datacenter only.

### ReFS vs NTFS

| Cecha | NTFS | ReFS (Resilient FS) |
|-------|------|---------------------|
| Metadata integrity | OK | Excellent (checksums) |
| Self-healing | Nie | Tak |
| Block cloning | Nie | Tak (szybkie kopie VHD) |
| Max file | 256 TB | 35 PB |
| Boot drive | TAK | NIE (w 2026 niewspierany) |
| Compression | Tak | Tak (od Server 2022) |
| Quota | Tak | Tak |

**Zasada:** ReFS dla data volumes (zwłaszcza VHD storage), NTFS dla system.

## Networking

### Komponenty:
- **NIC Teaming** — agregacja kart sieciowych (LACP, switch independent)
- **VLAN tagging** — separacja sieciowa
- **DCB (Data Center Bridging)** — QoS dla storage
- **SR-IOV** — direct hardware access dla VM
- **Windows Defender Firewall** — firewall z zaawansowaną konfiguracją

### Best practices:
1. **Separuj management network** od data
2. **Używaj statycznego IP** dla serwerów (nie DHCP)
3. **DNS resolution** zawsze testuj (`nslookup`, `Resolve-DnsName`)
4. **Disable IPv6** tylko jeśli wiesz co robisz (Microsoft odradza!)
5. **Hardware vs software firewall** — używaj obu

## Wirtualizacja

### Hyper-V
- Built-in hypervisor (od Server 2008)
- Bezpłatny w Windows Server (Standard: 2 VM, Datacenter: unlimited)
- **Generation 2 VM** — UEFI, Secure Boot, większa wydajność
- **Shielded VM** — encrypted, protected from host admin

### Containers (od Server 2016)
- **Windows Containers** — natywne
- **Hyper-V Containers** — większa izolacja
- **Linux Containers via WSL2** (od Server 2022)
- **Kubernetes on Windows** — coraz dojrzalsze, ale Linux wciąż dominuje

### Wybór w 2026:
- **Linux workload?** — Linux na Hyper-V VM lub Linux directly
- **Windows-specific (IIS, .NET Framework)?** — Windows Containers lub VM
- **Modern .NET?** — Linux containers (cross-platform)

## High Availability

### Failover Clustering
- Wiele serwerów, jedna usługa, automatic failover
- **Cluster Shared Volumes (CSV)** — shared storage
- Wymaga: shared storage (iSCSI, FC) lub S2D, witness (disk/cloud)

### Network Load Balancing (NLB)
- Software load balancing dla web, RDS
- Limit ~32 nodes
- Dla nowoczesnych aplikacji: wolisz Application Gateway, KEMP, F5

### Storage Replica
- Block-level replikacja (sync lub async)
- DR dla on-prem
- Datacenter edition only

### Azure Site Recovery
- DR do chmury Azure
- Bardzo popularny w 2026 dla on-prem disaster recovery

## Update lifecycle

| Wersja | Wsparcie do | Status |
|--------|-------------|--------|
| Server 2025 | 2034 (Extended) | Aktualne |
| Server 2022 | 2031 (Extended) | Aktualne |
| Server 2019 | 2029 | Mainstream end |
| Server 2016 | 2027 | Extended only |
| Server 2012 R2 | 2023 (skończony!) | NIEWSPIERANY |

**Zasada:** Nigdy nie używaj niewspieranego OS w produkcji (Server 2012 R2 — krytyczne ryzyko bezpieczeństwa).

## Co nowe w Server 2025?

- **Hot-patching** — instalacja patchy bez restartu (Datacenter Azure Edition)
- **SMB over QUIC** — bezpieczny SMB przez internet (replace VPN)
- **Active Directory improvements** — 32k page size, lateral movement protection
- **WinRM nad QUIC** — szybszy management
- **Witness on Azure** — cluster witness w chmurze
- **Improved virtualization** — VBS Enclaves, GPU partitioning
- **Better security defaults** — VBS, HVCI, Credential Guard ON by default

## Zasady administracji

1. **Principle of Least Privilege** — minimalne uprawnienia dla każdej operacji
2. **Defense in Depth** — wiele warstw zabezpieczeń (firewall, AV, hardening)
3. **Documentation** — dokumentuj każdą zmianę (ADR for infrastructure)
4. **Automation** — PowerShell DSC, Ansible (avoid clicky-click)
5. **Monitoring** — wszystko musi być monitorowane (logs, metrics)
6. **Backups** — 3-2-1 rule (3 kopie, 2 nośniki, 1 off-site)
7. **Patching** — regularnie, ale testuj najpierw (test environment)
8. **Disaster Recovery plan** — masz, testujesz, dokumentujesz

## Nauka i certyfikacje (2026)

**Microsoft certifications:**
- **Microsoft Certified: Windows Server Hybrid Administrator Associate** (AZ-800/801)
- **Microsoft Certified: Identity and Access Administrator Associate** (SC-300)
- **Microsoft Certified: Cybersecurity Architect Expert** (SC-100)

**Książki:**
- "Windows Server 2025 Inside Out" (Microsoft Press)
- "Windows Server Cookbook" (O'Reilly)

**Online:**
- Microsoft Learn — official, free
- Pluralsight — paid, dobre kursy
- LinkedIn Learning
- YouTube: NetworkChuck, John Savill (świetne deep-dives)

## Kiedy NIE używać Windows Server?

- **Web hosting (mass-market)** — Linux + Nginx tańsze i lepsze
- **Containers przy Linux microservices** — Linux native
- **HPC, ML training** — Linux dominuje
- **Edge computing** — często Linux ARM

**Windows Server świeci gdy:**
- Active Directory, Exchange, SharePoint
- Aplikacje .NET Framework (legacy)
- IIS hosting (zwłaszcza ASP.NET legacy)
- Hyper-V dla Windows VM
- Print services
- Integration z Microsoft 365, Azure
