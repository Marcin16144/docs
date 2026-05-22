# IIS — podstawy

## Czym jest IIS?

**Internet Information Services (IIS)** to serwer webowy Microsoftu, zintegrowany z Windows Server. Aktualne wersje (2026):
- **IIS 10.0** w Windows Server 2016/2019/2022
- **IIS 11.0** w Windows Server 2025

IIS hostuje:
- Strony statyczne (HTML/CSS/JS)
- Aplikacje ASP.NET / ASP.NET Core
- WCF / Web API services
- PHP (przez FastCGI)
- Node.js (przez iisnode lub jako reverse proxy)
- Reverse proxy do innych backendów (Java/Tomcat, Python, etc.)

## IIS vs Nginx vs Apache

| Cecha | IIS | Nginx | Apache |
|-------|-----|-------|--------|
| Platform | Windows | Linux/Win/Mac | Linux/Win/Mac |
| Performance (static) | Bardzo dobra | Najlepsza | Dobra |
| Performance (dynamic) | ASP.NET native | Reverse proxy do FPM/Node | mod_php, mod_wsgi |
| Konfiguracja | GUI + XML/applicationHost.config | Plain text (nginx.conf) | Plain text (httpd.conf) |
| Reverse proxy | URL Rewrite + ARR | Native | mod_proxy |
| ASP.NET | Native, idealne | Możliwe via reverse proxy | Możliwe via reverse proxy |
| Modules | C++ ISAPI / managed | C modules | C modules |
| Cena | Z Windows Server | Free / Plus paid | Free |
| W produkcji | Enterprise Microsoft stack | Web/cloud-scale | Tradycyjne hosting |

**Kiedy IIS:**
- Aplikacje ASP.NET / .NET Framework (legacy)
- Integracja z Active Directory (Windows Authentication)
- Microsoft stack (SharePoint, Exchange OWA, RDWeb)
- Klient wymaga Windows Server

**Kiedy NIE IIS:**
- Web-scale / mass hosting (Nginx tańszy, szybszy)
- Modern .NET (.NET 8/9 cross-platform — lepiej Linux + Kestrel za Nginx)
- Stack PHP-only (LAMP/LEMP lepiej)

## Instalacja IIS

### Via Server Manager (GUI)
```
Server Manager → Manage → Add Roles and Features →
Server Roles → Web Server (IIS) → Add Features → Next →
Wybierz wymagane Role Services → Install
```

### Via PowerShell (preferowane)

```powershell
# Lista feature
Get-WindowsFeature *Web*

# Podstawowa instalacja (web server + management)
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# Pełna instalacja z popularnymi features
Install-WindowsFeature -Name `
    Web-Server, `
    Web-Common-Http, `
    Web-Default-Doc, `
    Web-Dir-Browsing, `
    Web-Http-Errors, `
    Web-Static-Content, `
    Web-Http-Redirect, `
    Web-Health, `
    Web-Http-Logging, `
    Web-Custom-Logging, `
    Web-Log-Libraries, `
    Web-Request-Monitor, `
    Web-Http-Tracing, `
    Web-Performance, `
    Web-Stat-Compression, `
    Web-Dyn-Compression, `
    Web-Security, `
    Web-Filtering, `
    Web-Basic-Auth, `
    Web-CertProvider, `
    Web-Client-Auth, `
    Web-Digest-Auth, `
    Web-Cert-Auth, `
    Web-IP-Security, `
    Web-Url-Auth, `
    Web-Windows-Auth, `
    Web-App-Dev, `
    Web-Net-Ext45, `
    Web-AppInit, `
    Web-Asp-Net45, `
    Web-ISAPI-Ext, `
    Web-ISAPI-Filter, `
    Web-Mgmt-Tools, `
    Web-Mgmt-Console, `
    Web-Scripting-Tools, `
    Web-Mgmt-Service `
    -IncludeManagementTools
```

### Sprawdzenie instalacji
```powershell
# Czy IIS działa?
Get-Service W3SVC

# Otwórz w przeglądarce
http://localhost  # powinien pokazać welcome page

# Wersja IIS
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\InetStp | Select VersionString
```

## Architektura IIS

```
┌─────────────────────────────────────────────────────┐
│              W3SVC (Windows Service)                 │
│              Worldwide Web Publishing Service        │
└──────────────────────┬──────────────────────────────┘
                       │ manages
                       ▼
┌─────────────────────────────────────────────────────┐
│              WAS (Windows Process Activation)        │
│              Activates worker processes              │
└──────────────────────┬──────────────────────────────┘
                       │ creates
       ┌───────────────┼────────────────┐
       ▼               ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Application │ │  Application │ │  Application │
│  Pool 1      │ │  Pool 2      │ │  Pool 3      │
│  (w3wp.exe)  │ │  (w3wp.exe)  │ │  (w3wp.exe)  │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       │ hosts          │                │
       ▼                ▼                ▼
   ┌───────┐       ┌───────┐         ┌───────┐
   │ Site A│       │ Site B│         │ Site C│
   │ + Apps│       │       │         │       │
   └───────┘       └───────┘         └───────┘
```

### Komponenty:

1. **HTTP.SYS** — kernel-mode driver, słucha na portach (80/443), buduje request queue
2. **W3SVC** — windows service, zarządza konfiguracją i routing requestów
3. **WAS** — aktywuje worker processes (w3wp.exe) jako application pools
4. **Application Pool** — izolowany proces w3wp.exe (1 pool = 1 process)
5. **Site (Website)** — kontenery dla aplikacji, przypisane do app pool
6. **Application** — aplikacja webowa (ASP.NET, PHP, etc.)
7. **Virtual Directory** — wskaźnik na fizyczny katalog

## Application Pools

### Co to?
**Application Pool** = izolowany worker process (w3wp.exe) hostujący jedną lub więcej aplikacji.

**Kluczowe zasady:**
- Każdy app pool = osobny proces (crash jednej aplikacji nie wpływa na inne)
- Każdy app pool może mieć inną tożsamość (security)
- Każdy app pool ma swój CLR version (.NET 4.8 vs .NET Core w3wp różni się — w nowszych IIS Hostable Web Core)

### Typy app pools:

| Mode | Use case |
|------|----------|
| **Integrated** | Standard ASP.NET (preferred) |
| **Classic** | Legacy ASP.NET pre-2.0 |
| **No Managed Code** | PHP, static, ASP.NET Core (bo .NET Core hostowany OutOfProcess) |

### Application Pool Identity (security!)

| Identity | Bezpieczeństwo |
|----------|----------------|
| **ApplicationPoolIdentity** ⭐ | Best — virtual identity per app pool, unikalne SID |
| **NetworkService** | OK ale współdzielona dla wielu serwisów |
| **LocalService** | Mniej privileges niż NetworkService |
| **LocalSystem** | ⚠️ NIE — pełne privileges, security risk |
| **Custom domain account** | Dla AD integration, services accounts |

**Best practice 2026:** Każdy app pool z **ApplicationPoolIdentity** (unique virtual SID `IIS APPPOOL\YourPoolName`).

### PowerShell management

```powershell
# Import modułu (jeśli nie zaimportowany)
Import-Module WebAdministration

# Lista app pools
Get-IISAppPool
# lub: Get-ChildItem IIS:\AppPools

# Stwórz nowy app pool
New-WebAppPool -Name "MyAppPool"

# Konfiguracja: integrated mode, no managed code
Set-ItemProperty -Path "IIS:\AppPools\MyAppPool" -Name "managedRuntimeVersion" -Value ""
Set-ItemProperty -Path "IIS:\AppPools\MyAppPool" -Name "managedPipelineMode" -Value "Integrated"

# Zmiana identity na custom user
Set-ItemProperty -Path "IIS:\AppPools\MyAppPool" -Name processModel -Value @{
    identityType = "SpecificUser"
    userName = "DOMAIN\ServiceAccount"
    password = "..."
}

# Recycling co 4 hours (w nocy żeby nie crashowało użytkownikom)
Set-ItemProperty -Path "IIS:\AppPools\MyAppPool" -Name "recycling.periodicRestart.time" -Value "04:00:00"

# Restart app pool
Restart-WebAppPool -Name "MyAppPool"
```

## Websites

### Tworzenie site'u

```powershell
# Nowy site
New-Website -Name "MyApp" `
    -PhysicalPath "C:\inetpub\wwwroot\myapp" `
    -ApplicationPool "MyAppPool" `
    -Port 80 `
    -HostHeader "myapp.example.com"

# Z HTTPS bindingiem
New-WebBinding -Name "MyApp" `
    -Protocol https `
    -Port 443 `
    -HostHeader "myapp.example.com" `
    -SslFlags 1  # SNI
```

### Bindings

**Binding** = kombinacja IP + Port + Host Header która kieruje request do site.

```
Examples:
*:80:                       — wszystkie HTTP requesty na port 80
*:443:myapp.example.com     — HTTPS, tylko myapp.example.com
192.168.1.100:80:           — tylko z konkretnego IP
```

**SNI (Server Name Indication):**
Pozwala mieć **wiele HTTPS sites na tym samym IP**. Każdy z osobnym certyfikatem.
```powershell
New-WebBinding -Name "Site1" -Protocol https -Port 443 -HostHeader "site1.com" -SslFlags 1
New-WebBinding -Name "Site2" -Protocol https -Port 443 -HostHeader "site2.com" -SslFlags 1
```

## Konfiguracja — applicationHost.config

Centralna konfiguracja IIS znajduje się w:
```
C:\Windows\System32\inetsrv\config\applicationHost.config
```

To **XML** i można edytować ręcznie (z backupem!) lub via:
- IIS Manager (GUI)
- `appcmd.exe` (CLI)
- PowerShell `WebAdministration` module

### Hierarchia configów:
```
1. applicationHost.config (server-wide)
2. web.config w site root
3. web.config w sub-folder (override)
4. web.config w aplikacji
```

Niższe poziomy nadpisują wyższe (jeśli `<location>` z `overrideMode="Allow"`).

### Web.config przykład

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <!-- Default document -->
    <defaultDocument>
      <files>
        <clear />
        <add value="index.html" />
        <add value="default.aspx" />
      </files>
    </defaultDocument>

    <!-- Static content -->
    <staticContent>
      <mimeMap fileExtension=".webmanifest" mimeType="application/manifest+json" />
    </staticContent>

    <!-- HTTP Errors -->
    <httpErrors errorMode="Custom" defaultResponseMode="Redirect">
      <remove statusCode="404" />
      <error statusCode="404" path="/404.html" />
    </httpErrors>

    <!-- HTTPS only -->
    <rewrite>
      <rules>
        <rule name="HTTPS Redirect" stopProcessing="true">
          <match url="(.*)" />
          <conditions>
            <add input="{HTTPS}" pattern="off" />
          </conditions>
          <action type="Redirect" url="https://{HTTP_HOST}/{R:1}" redirectType="Permanent" />
        </rule>
      </rules>
    </rewrite>

    <!-- Security headers -->
    <httpProtocol>
      <customHeaders>
        <add name="Strict-Transport-Security" value="max-age=31536000; includeSubDomains" />
        <add name="X-Content-Type-Options" value="nosniff" />
        <add name="X-Frame-Options" value="SAMEORIGIN" />
        <add name="Referrer-Policy" value="strict-origin-when-cross-origin" />
      </customHeaders>
    </httpProtocol>

    <!-- Hide IIS info -->
    <security>
      <requestFiltering removeServerHeader="true" />
    </security>
  </system.webServer>
</configuration>
```

## Modules (handlery)

IIS jest **modular**. Każda funkcjonalność (auth, logging, compression) to module.

### Native vs Managed:
- **Native modules** (C++ ISAPI) — szybkie, system-level
- **Managed modules** (.NET) — pisane w C#, łatwiejsze

### Kluczowe modules:
- **HttpLogging** — request logs
- **StaticCompressionModule** / **DynamicCompressionModule** — gzip
- **WindowsAuthenticationModule** — Negotiate/NTLM/Kerberos
- **BasicAuthenticationModule** — Basic auth
- **AnonymousAuthenticationModule** — anon access
- **RequestFilteringModule** — security filter (URL length, etc.)
- **UrlMappingModule** — URL rewriting
- **DefaultDocumentModule** — index.html resolution

```powershell
# Lista modules
Get-WebGlobalModule

# Disable module dla site
Remove-WebConfigurationProperty -PSPath "IIS:\Sites\MyApp" -Filter "system.webServer/modules" -Name "." -AtElement @{name='WindowsAuthenticationModule'}
```

## Application Initialization

**Problem:** Pierwszy request po deployment lub recycling jest wolny (cold start).

**Rozwiązanie:** Application Initialization wstępnie "rozgrzewa" aplikację.

```xml
<applicationPools>
  <add name="MyAppPool" autoStart="true" startMode="AlwaysRunning" />
</applicationPools>

<sites>
  <site name="MyApp">
    <application path="/" applicationPool="MyAppPool" preloadEnabled="true">
      <virtualDirectory path="/" physicalPath="C:\wwwroot" />
    </application>
  </site>
</sites>

<system.webServer>
  <applicationInitialization doAppInitAfterRestart="true">
    <add initializationPage="/warmup" hostName="myapp.example.com" />
  </applicationInitialization>
</system.webServer>
```

## Logowanie

### Domyślne logi IIS
```
C:\inetpub\logs\LogFiles\W3SVC{N}\u_exYYMMDD.log
```

Format: **W3C Extended** (kolumny konfiguralne).

### Włącz przydatne pola:
- `cs-host` — host header
- `cs-User-Agent`
- `cs-Referer`
- `sc-substatus` — szczegółowy kod (404.7 = file extension blocked)
- `sc-win32-status` — Windows error code
- `time-taken` — czas requesta

### Failed Request Tracing (FRT)
**Najpotężniejsze narzędzie debug w IIS.** Loguje całe processing requestu krok po kroku.

```powershell
# Włącz FRT
Set-WebConfigurationProperty -Filter "/system.applicationHost/sites/siteDefaults/traceFailedRequestsLogging" -Name "enabled" -Value "True"

# Reguła dla konkretnego site
Add-WebConfigurationProperty -PSPath "IIS:\Sites\MyApp" -Filter "system.webServer/tracing/traceFailedRequests" -Name "." -Value @{
    path = "*"
    failureDefinitions = @{
        statusCodes = "500-599"
    }
}
```

Logi w: `C:\inetpub\logs\FailedReqLogFiles\`

## Performance

### Static content caching

```xml
<system.webServer>
  <staticContent>
    <clientCache cacheControlMode="UseMaxAge" cacheControlMaxAge="365.00:00:00" />
  </staticContent>
</system.webServer>
```

### Compression

```xml
<system.webServer>
  <urlCompression doStaticCompression="true" doDynamicCompression="true" />
  <httpCompression>
    <dynamicTypes>
      <add mimeType="text/*" enabled="true" />
      <add mimeType="application/json" enabled="true" />
      <add mimeType="application/javascript" enabled="true" />
    </dynamicTypes>
    <staticTypes>
      <add mimeType="*/*" enabled="true" />
    </staticTypes>
  </httpCompression>
</system.webServer>
```

### Output Caching

Cachuje response per URL/header (RAM-based).

### Connection limits
- Domyślnie 5000 connections per app pool
- Tweakuj dla high-traffic

## ASP.NET Core hosting

ASP.NET Core to **out-of-process** model — IIS służy jako reverse proxy do Kestrel.

```
Browser → IIS (port 80/443) → ASP.NET Core Module → Kestrel (port wewnętrzny) → app
```

```xml
<!-- web.config dla ASP.NET Core -->
<system.webServer>
  <handlers>
    <add name="aspNetCore" path="*" verb="*"
         modules="AspNetCoreModuleV2"
         resourceType="Unspecified" />
  </handlers>
  <aspNetCore processPath="dotnet"
              arguments=".\MyApp.dll"
              stdoutLogEnabled="true"
              stdoutLogFile=".\logs\stdout"
              hostingModel="OutOfProcess" />
</system.webServer>
```

App pool: **No Managed Code** (Kestrel jest .NET Core, nie .NET Framework).

## PHP hosting

### FastCGI + PHP

```powershell
# Pobierz PHP NTS x64 (z windows.php.net)
# Wypakuj do C:\PHP

# Instalacja CGI module
Install-WindowsFeature Web-CGI

# Skonfiguruj FastCGI
appcmd set config /section:system.webServer/fastCGI /+"[fullPath='C:\PHP\php-cgi.exe']"

# Mapuj rozszerzenia .php do FastCGI
appcmd set config /section:system.webServer/handlers /+"[name='PHP_FastCGI',path='*.php',verb='*',modules='FastCgiModule',scriptProcessor='C:\PHP\php-cgi.exe',resourceType='Unspecified']"
```

**Lepiej:** Użyj **PHP Manager for IIS** (GUI tool).

### Performance dla PHP:
- **OPcache** w php.ini — kluczowe!
- **WinCache** — Microsoft cache rozszerzenie
- App pool recycling = wolniejsze (PHP nie ma persistent state, ale OPcache się czyści)

## Bezpieczeństwo IIS — quick wins

```
1. Hide server header (X-Powered-By, Server)
2. Disable unused modules
3. ApplicationPoolIdentity (nie LocalSystem!)
4. HTTPS only (HSTS)
5. Request Filtering — limity URL/query
6. IP filtering dla admin URLs
7. Default page disabled (wyłącz iisstart.htm)
8. Update regularnie (Windows Update for IIS)
9. Audit logs włączony
10. Failed Request Tracing dla diagnostyki
```

Szczegóły hardeningu — patrz rozdział 07 (Bezpieczeństwo) i 06 (Certyfikaty).

## Narzędzia

- **IIS Manager (inetmgr.exe)** — main GUI
- **appcmd.exe** — CLI dla quick changes
- **PowerShell WebAdministration / IISAdministration** modules
- **IIS Crypto** (Nartac Software) — TLS/SSL hardening GUI
- **LogParser / Log Parser Studio** — analyza logów IIS
- **PerfMon** — performance monitoring
- **Process Monitor (Sysinternals)** — file/registry tracing
- **Wireshark/Fiddler** — network traffic analysis

## Następne kroki

- **Rozdział 05** — Konfiguracja zaawansowana (URL Rewrite, ARR, reverse proxy)
- **Rozdział 06** — Certyfikaty SSL/TLS
- **Rozdział 07** — Bezpieczeństwo i hardening
- **Rozdział 09** — Publikowanie usług publicznych
