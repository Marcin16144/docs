# Bezpieczeństwo Windows Server — fundamenty

## Filozofia: Defense in Depth

Bezpieczeństwo serwera to **wiele warstw**, nie jeden firewall.

```
┌─────────────────────────────────────────────┐
│  WARSTWA 1: Fizyczna                         │  data center, lock, BIOS
├─────────────────────────────────────────────┤
│  WARSTWA 2: Sieć                              │  firewall, IDS, segmentacja
├─────────────────────────────────────────────┤
│  WARSTWA 3: Host                              │  hardening OS, AV, patches
├─────────────────────────────────────────────┤
│  WARSTWA 4: Aplikacja                         │  WAF, IIS hardening, code
├─────────────────────────────────────────────┤
│  WARSTWA 5: Tożsamość                         │  MFA, RBAC, JEA, PAM
├─────────────────────────────────────────────┤
│  WARSTWA 6: Dane                              │  szyfrowanie, DLP, backup
└─────────────────────────────────────────────┘
```

Każdy atak musi przebić **wszystkie** warstwy. Jedna warstwa skompromitowana ≠ system padł.

## Zasada najmniejszych uprawnień (PoLP)

**Każde konto/usługa dostaje minimum uprawnień potrzebnych do działania.**

### Praktyka:
- Service accounts ≠ user accounts
- Service nie ma `Logon Locally` (chyba że potrzebne)
- Admin accounts używaj **tylko** do admin tasks (osobne konto)
- Domain Admin **nigdy** nie loguje się na workstation
- Web app pool **nie** uruchamiaj jako LocalSystem

### Tier model (Microsoft Privileged Access)

```
Tier 0 (Forest Admins, Domain Controllers)
   ↑ Nie loguje się na Tier 1 lub Tier 2
   │
Tier 1 (Server Admins)
   ↑ Nie loguje się na Tier 2
   │
Tier 2 (Workstation Admins, Help Desk)
   ↑ Nie loguje się na Tier 0 lub 1
```

**Złamanie tego = lateral movement.** Pojedyncze compromise → cała domena.

## Built-in Security Features (2026)

### 1. Defender for Identity (formerly ATA)
Wykrywa anomalie w AD (lateral movement, golden ticket attacks).

### 2. Microsoft Defender for Endpoint
Antivirus + EDR, integracja z Microsoft Sentinel.
```powershell
# Status Defender
Get-MpComputerStatus

# Update definitions
Update-MpSignature

# Scan
Start-MpScan -ScanType FullScan
```

### 3. Credential Guard
Izoluje LSA secrets w VBS (Virtualization-Based Security). Chroni przed Mimikatz/Pass-the-Hash.

```powershell
# Status
DG_Readiness.ps1 -Capable
# lub
Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\Microsoft\Windows\DeviceGuard
```

W Server 2025: **domyślnie ON**.

### 4. LSA Protection (RunAsPPL)
LSASS jako Protected Process Light — niemożliwe debugowanie (Mimikatz nie wyciąga creds).

```powershell
# Włącz
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
New-ItemProperty -Path $path -Name "RunAsPPL" -Value 1 -PropertyType DWORD -Force

# Restart
Restart-Computer
```

W Server 2025: **domyślnie ON**.

### 5. Hypervisor-Protected Code Integrity (HVCI)
Kernel mode code integrity protected by Hyper-V. Blokuje malicious drivers.

W Server 2025: **domyślnie ON**.

### 6. Windows Defender Application Control (WDAC)
Następca AppLocker. Whitelist aplikacji.

```powershell
# Stwórz policy
New-CIPolicy -FilePath "C:\WDAC\policy.xml" -Level Publisher -Fallback Hash

# Convert do binary
ConvertFrom-CIPolicy "C:\WDAC\policy.xml" "C:\WDAC\policy.bin"

# Deploy via GPO lub Registry
```

### 7. AppLocker (legacy, ale wciąż używane)
Whitelist/blacklist aplikacji per user/group.

### 8. Just Enough Administration (JEA)
Restricted PowerShell endpoints. Admin może `Restart-Service IIS` ale nie `Get-ChildItem C:\`.

```powershell
# Capability file
New-PSRoleCapabilityFile -Path .\IISAdmin.psrc

# W pliku:
@{
    VisibleCmdlets = @(
        @{ Name = 'Restart-Service'; Parameters = @{ Name = 'Name'; ValidateSet = 'W3SVC' } }
        'Get-Website'
    )
    VisibleFunctions = 'Get-WebSiteStatus'
}

# Session config
New-PSSessionConfigurationFile -Path .\IISAdmin.pssc -RunAsVirtualAccount -RoleDefinitions @{ 'CONTOSO\IISAdmins' = @{ RoleCapabilities = 'IISAdmin' } }

# Register endpoint
Register-PSSessionConfiguration -Name "IISAdmin" -Path .\IISAdmin.pssc
```

User `IISAdmins` może:
```powershell
Enter-PSSession -ComputerName SERVER -ConfigurationName IISAdmin
# Tylko Get-Website, Restart-Service W3SVC
```

## Hardening — kluczowe kroki

### 1. Wyłącz niepotrzebne usługi

```powershell
# Lista uruchomionych
Get-Service | Where-Object {$_.Status -eq "Running"}

# Wyłącz print spooler jeśli serwer nie drukuje (PrintNightmare!)
Stop-Service -Name Spooler
Set-Service -Name Spooler -StartupType Disabled

# Wyłącz Xbox services, Windows Search jeśli nie używasz
```

### 2. Wyłącz LM/NTLMv1
LM hash i NTLMv1 są crackowane w sekundach.

```powershell
# Force NTLMv2
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
Set-ItemProperty -Path $path -Name "LmCompatibilityLevel" -Value 5
# 5 = Send NTLMv2 only, refuse LM and NTLM
```

### 3. SMB hardening
```powershell
# Disable SMBv1 (KRYTYCZNE — używane w WannaCry!)
Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol"

# Wymuszanie SMB signing
Set-SmbServerConfiguration -RequireSecuritySignature $true -EnableSecuritySignature $true

# SMB encryption (od SMB 3.0)
Set-SmbServerConfiguration -EncryptData $true

# SMB over QUIC (Server 2022+) — dla publicznych usług SMB!
```

### 4. Windows Update — automatyczne
```powershell
# Włącz automatic updates
sconfig
# Opcja 5 → A (automatic)

# Lub via GPO:
# Computer Configuration → Administrative Templates →
# Windows Components → Windows Update → Configure Automatic Updates
```

### 5. Audit Policy

```powershell
# Włącz comprehensive audit
auditpol /set /category:* /success:enable /failure:enable

# Konkretne ważne:
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
auditpol /set /subcategory:"Special Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable
auditpol /set /subcategory:"Authentication Policy Change" /success:enable /failure:enable
```

Logi w Event Viewer → Security log. Forward do SIEM (Sentinel, Splunk, Wazuh).

### 6. PowerShell Hardening

```powershell
# Logging modułów
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 1

# Script Block Logging (LOGUJE WSZYSTKO)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1

# Constrained Language Mode (jeśli nie potrzebujesz full language)
$ExecutionContext.SessionState.LanguageMode = "ConstrainedLanguage"

# Execution Policy
Set-ExecutionPolicy AllSigned -Scope LocalMachine -Force
```

### 7. Disable Guest, Rename Administrator

```powershell
# Disable Guest
Disable-LocalUser -Name Guest

# Rename Administrator (security through obscurity, ale dodaje wartość)
Rename-LocalUser -Name Administrator -NewName "AdmDaJaSekretne"

# Stwórz fake "Administrator" trap account (limited rights, audit logon attempts)
```

### 8. Password Policy

```powershell
# Via secedit (lub GPO)
net accounts /minpwlen:14 /maxpwage:90 /minpwage:1 /uniquepw:24

# Account lockout
net accounts /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30
```

**Zalecenia 2026 (NIST SP 800-63B):**
- Min. 14 znaków (lepiej 16+)
- Brak wymuszania complexity (cyfra/symbol nie pomaga jeśli passphrase długi)
- **Sprawdzaj przeciw breach passwords** (Have I Been Pwned API)
- **MFA** zawsze gdy możliwe

### 9. BitLocker (szyfrowanie dysków)

```powershell
# Włącz BitLocker dla C:
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector

# Backup recovery key do AD (jeśli domain joined)
$rec = Get-BitLockerVolume -MountPoint "C:" | Select -ExpandProperty KeyProtector | Where {$_.KeyProtectorType -eq "RecoveryPassword"}
Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $rec.KeyProtectorId
```

### 10. Network Security

```powershell
# Wyłącz NetBIOS over TCP/IP (legacy)
$adapters = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "TcpipNetbiosOptions IS NOT NULL"
foreach ($adapter in $adapters) {
    $adapter.SetTcpipNetbios(2)  # 2 = Disable NetBIOS
}

# Wyłącz LLMNR (Link-Local Multicast Name Resolution) — atak Responder
$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
New-Item -Path $path -Force
New-ItemProperty -Path $path -Name "EnableMulticast" -Value 0 -PropertyType DWORD -Force

# Wyłącz mDNS
sc.exe config "Dnscache" start= disabled  # tylko jeśli na pewno
```

## Microsoft Security Compliance Toolkit

Microsoft publikuje **security baselines** — gotowe konfigurację GPO dla różnych ról.

```
Pobierz z: microsoft.com/en-us/download/details.aspx?id=55319

Zawiera:
- Windows Server 2025 baseline (gpo)
- Windows 11 baseline
- Office baselines
- Microsoft Edge baseline
```

### LGPO.exe
Apply baseline na lokalnej maszynie:
```cmd
LGPO.exe /g "C:\Baselines\Server2025\GPOs\Member Server Baseline"
```

### CIS Benchmarks
**Center for Internet Security** — alternatywa, bardzo szczegółowe (700+ checks).

- **CIS Microsoft Windows Server 2025 Benchmark v1.0**
- Free for personal, $$$ for enterprise
- Tools: CIS-CAT (assessment tool)

### DISA STIGs
Department of Defense compliance. Najsurowsze. Dla federal/military.

## Antivirus / EDR

### Microsoft Defender for Endpoint (preferowany 2026)
- Built-in (premium dla Windows Server: Server Standard/Datacenter daje basic, Defender for Endpoint = subscription)
- EDR (Endpoint Detection & Response)
- Integracja z Sentinel SIEM
- Threat intelligence z Microsoft

### Alternatywy:
- **CrowdStrike Falcon** — premium EDR, bardzo dobry (drogi)
- **SentinelOne** — autonomous EDR
- **Sophos Intercept X** — solid mid-range
- **ESET Endpoint Security** — lekki, popular w EU

### Co konfigurować:
```powershell
# Włącz wszystkie funkcje Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableBlockAtFirstSeen $false
Set-MpPreference -DisableScriptScanning $false
Set-MpPreference -EnableNetworkProtection Enabled
Set-MpPreference -EnableControlledFolderAccess Enabled

# Cloud protection
Set-MpPreference -MAPSReporting Advanced
Set-MpPreference -SubmitSamplesConsent SendAllSamples

# Attack Surface Reduction (ASR) rules
Add-MpPreference -AttackSurfaceReductionRules_Ids "BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550" -AttackSurfaceReductionRules_Actions Enabled
# (block executable content from email)
```

## Active Directory Hardening

### Critical:
1. **Disable LM/NTLMv1**
2. **Disable RC4 in Kerberos** (use AES only)
3. **LAPS (Local Administrator Password Solution)** — unique passwords for local admin per machine
4. **Tier model** — Tier 0/1/2 separation
5. **Privileged Access Workstations (PAW)** — separate workstations dla admin tasks
6. **Password length** dla service accounts: 25+ znaków (bo nie wpisujesz ręcznie)
7. **kerbtgt password reset** co rok (defensa przeciw Golden Ticket)
8. **DSRM password** — secure, regularly rotated
9. **Group Policy Object (GPO) audit** — kto modyfikował co
10. **Privileged Identity Management (PIM)** — JIT access do AD groups

```powershell
# Reset kerbtgt password (NORMAL, raz w roku)
# Najpierw 1×:
Reset-ADServiceAccountPassword -Identity krbtgt
# Czekaj 24h (replikacja, ticket lifetimes)
Reset-ADServiceAccountPassword -Identity krbtgt
# 2× zmiana eliminuje wszystkie istniejące tickety
```

## Sysmon — must-have dla logging

**Sysmon** (Sysinternals) loguje szczegółowe events:
- Process creation (z full command line)
- Network connections
- File creation
- Registry modifications
- DNS queries

### Instalacja:
```powershell
# Pobierz Sysmon
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "Sysmon.zip"
Expand-Archive Sysmon.zip

# Pobierz config (SwiftOnSecurity to standardowy excellent config)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "sysmonconfig.xml"

# Install
.\Sysmon64.exe -accepteula -i sysmonconfig.xml
```

Logi w Event Viewer: `Applications and Services Logs → Microsoft → Windows → Sysmon → Operational`

Forward do SIEM przez Windows Event Forwarding (WEF) lub agent (Splunk UF, Microsoft Sentinel agent).

## Certyfikaty i kerberos

Patrz rozdział 06 (SSL/TLS) i 03 (AD).

### Quick wins:
- Wyłącz **NTLM** gdzie tylko możliwe (audit najpierw aby wiedzieć czy używane)
- **Smart card authentication** dla privileged users
- **Windows Hello for Business** — passwordless dla regular users
- **FIDO2** keys dla sensitive operations

## Backup z perspektywy bezpieczeństwa

### Ransomware-proof backup
- **3-2-1 rule:** 3 kopie, 2 różne nośniki, 1 off-site
- **Immutable backups** — nie można usunąć przez X dni (nawet admin!)
- **Air-gapped** — fizycznie odłączone od sieci
- **Tested restore** — backup który nigdy nie był testowany **nie działa**

### Tools:
- **Veeam** — leader, świetne ransomware protection
- **Azure Backup** — managed, integracja z Azure
- **Windows Server Backup** — basic, free
- **Commvault, Rubrik, Cohesity** — enterprise

## Vulnerability Management

### Patch management:
- **Windows Update for Business** — modern
- **WSUS** — traditional
- **MECM (Configuration Manager)** — enterprise
- **Microsoft Intune** — cloud-based

### Vulnerability scanners:
- **Nessus** (Tenable) — industry standard
- **Qualys** — cloud-based
- **OpenVAS** — open source
- **Microsoft Defender Vulnerability Management** — built-in for Defender for Endpoint

### Cadence:
- **Patch Tuesday** (drugi wtorek miesiąca) — Microsoft updates
- **Critical patches** — w ciągu 7 dni
- **High** — 30 dni
- **Medium** — 90 dni
- **Test** w lab przed prod (zwłaszcza driver updates)

## Compliance

W zależności od branży:
- **PCI DSS** — payment cards
- **HIPAA** — healthcare (US)
- **GDPR** — privacy (EU)
- **SOX** — financial (US)
- **ISO 27001** — info security mgmt
- **NIST CSF** — cybersecurity framework
- **CIS Controls** — practical controls

**Compliance ≠ security** — minimum, nie maksimum.

## Incident Response

### Plan:
1. **Preparation** — playbook, contacts, tools ready
2. **Detection** — SIEM, alerts, user reports
3. **Containment** — izolacja maszyn (network disconnect, NOT shutdown — tracimy memory!)
4. **Eradication** — usunięcie threat
5. **Recovery** — restore z backup (verified clean)
6. **Lessons learned** — post-mortem, update plan

### Quick actions przy podejrzeniu kompromitacji:
```powershell
# 1. Snapshot stan systemu
Get-Process | Export-Csv processes.csv
Get-Service | Export-Csv services.csv
netstat -anob > netstat.txt
schtasks /query /v /fo csv > tasks.csv

# 2. Capture network traffic (jeśli Wireshark zainstalowany)

# 3. Capture memory (Belkasoft RAM Capturer, Magnet RAM Capture)

# 4. Disconnect network (NIE shutdown!)
Get-NetAdapter | Disable-NetAdapter -Confirm:$false

# 5. Wezwij security team / SOC
```

## Zero Trust

**Klasyczny model:** "Wszystko za firewall = trusted"
**Zero Trust:** "Nigdy nie ufaj, zawsze weryfikuj"

### Zasady:
1. **Verify explicitly** — każdy request authenticated + authorized
2. **Least privilege** — minimum potrzebne
3. **Assume breach** — projektuj jakby ktoś już był wewnątrz

### Implementacja w Windows env:
- Microsoft Entra ID (formerly Azure AD) Conditional Access
- Microsoft Defender for Identity
- Microsoft Defender for Cloud Apps (CASB)
- Application Proxy zamiast VPN
- Privileged Access Management (PAM)

Patrz: rozdział o Zero Trust w architektura/08-01.

## Tools — quick reference

```
PowerShell modules:
  Microsoft.PowerShell.Security
  ActiveDirectory
  GroupPolicy
  CertificateProvider
  WindowsUpdate

Sysinternals (must-have):
  Sysmon, Process Explorer, Process Monitor, Autoruns,
  PsExec (use carefully!), TCPView, Procdump

Microsoft tools:
  LAPS, BitLocker Manager, MBSA (deprecated, use Defender VM),
  Security Compliance Toolkit, LGPO

Open source:
  PowerView (red team), BloodHound (AD attack paths),
  Sysinternals Suite, Wazuh (SIEM)

Commercial:
  CrowdStrike, SentinelOne, Sophos, ESET (EDR)
  Tenable Nessus (vuln scan)
  Splunk, Sentinel (SIEM)
  Veeam, Rubrik (backup)
```

## Hardening checklist (skrót)

```
☐ Server Core (zamiast Desktop) gdzie możliwe
☐ Tylko niezbędne role/features
☐ Windows Update for Business / WSUS
☐ Defender + ASR rules + Network Protection
☐ Credential Guard + LSA Protection ON
☐ Disable SMBv1, NTLMv1, LM hash
☐ Force NTLMv2 (LmCompatibilityLevel = 5)
☐ Disable LLMNR, NetBIOS over TCP/IP
☐ BitLocker dla wszystkich dysków
☐ Audit Policy comprehensive
☐ PowerShell Logging (module + script block)
☐ Sysmon installed + monitoring
☐ Account lockout policy
☐ Strong password policy + MFA
☐ Tier model dla admin accounts
☐ LAPS dla local admin passwords
☐ JEA dla delegated admin
☐ Disable Guest, rename Administrator
☐ Disable Print Spooler (jeśli nie drukuje)
☐ Application baseline (WDAC/AppLocker)
☐ Network Segmentation (VLAN, firewall rules)
☐ Backup tested + immutable + off-site
☐ Vulnerability scanning regularnie
☐ Penetration test przynajmniej raz w roku
☐ Documented incident response plan
☐ User training (phishing awareness)
```

## Najczęstsze ataki i obrona

| Atak | Co robi | Obrona |
|------|---------|--------|
| **Phishing** | Email z malware/credentials harvest | User training, email filtering, MFA |
| **Brute force** | Próba haseł | Account lockout, MFA, monitoring |
| **Pass-the-Hash** | Kradzież NTLM hash | Credential Guard, LSA Protection, Restricted Admin |
| **Pass-the-Ticket** | Kradzież Kerberos ticket | Credential Guard, kerbtgt rotation |
| **Golden Ticket** | Forge Kerberos ticket via krbtgt | krbtgt 2x reset, monitoring AD |
| **Silver Ticket** | Forged service ticket | Service account password rotation |
| **DCSync** | Symulacja DC, dump password DB | Restrict replication permissions, monitor |
| **Kerberoasting** | Crack offline service account hash | Long passwords (25+) for service accounts |
| **DCShadow** | Push fake DC changes | Monitor schema changes, restrict permissions |
| **Lateral movement** | Move between machines | Tier model, segmentation, EDR |
| **Privilege escalation** | Local user → SYSTEM | Patches, AppLocker, EDR |
| **Ransomware** | Encrypt files, demand ransom | Backups (immutable!), Defender, ASR rules |
| **Supply chain** | Compromised software/updates | Verified sources, EDR behavioral detection |

## Podsumowanie — top 10 priorytetów

1. **Aktualizuj** — patches w 7-30 dni
2. **MFA wszędzie** — admin accounts especially
3. **Backup + test** — 3-2-1 rule, immutable
4. **Defender + EDR** — full functionality
5. **Network segmentation** — flat networks = easy lateral movement
6. **Audit + SIEM** — bez logs nie wiesz że coś się dzieje
7. **Tier model** — separacja Tier 0/1/2
8. **Hardening baselines** — Microsoft Security Compliance Toolkit lub CIS
9. **Password manager + LAPS** — eliminate password reuse
10. **Trening użytkowników** — najsłabsze ogniwo zazwyczaj

## Linki

- **Microsoft Security Compliance Toolkit**: aka.ms/SCT
- **CIS Benchmarks**: cisecurity.org/cis-benchmarks
- **NIST SP 800-53**: csrc.nist.gov
- **Microsoft Defender docs**: learn.microsoft.com/defender
- **MITRE ATT&CK**: attack.mitre.org (TTPs catalog)
- **Sysinternals**: learn.microsoft.com/sysinternals
