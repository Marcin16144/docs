#Requires -Version 5.1
<#
.SYNOPSIS
    Publish Kompendium.Desktop as a single, self-contained .exe.

.DESCRIPTION
    Produces one standalone executable that bundles the .NET 8 runtime and every
    managed/native dependency (incl. the WebView2 loader). It runs on a clean
    Windows machine with NO .NET install and NO extra libraries to deploy.

    The only OS prerequisite is the Microsoft Edge WebView2 Runtime (Evergreen),
    which ships pre-installed on Windows 11 and current Windows 10. If a target
    box lacks it, run the free bootstrapper once:
        https://developer.microsoft.com/microsoft-edge/webview2/  (Evergreen Standalone)

.PARAMETER Runtime
    Target RID. Defaults to win-x64. Use win-arm64 for ARM devices.

.PARAMETER Out
    Output directory. Defaults to <repo>\publish\<runtime>.

.EXAMPLE
    powershell -File tools/build-desktop.ps1
    powershell -File tools/build-desktop.ps1 -Runtime win-arm64
#>
[CmdletBinding()]
param(
    [ValidateSet('win-x64', 'win-arm64')]
    [string]$Runtime = 'win-x64',
    [string]$Out
)

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$proj = Join-Path $root 'src/Kompendium.Desktop/Kompendium.Desktop.csproj'
if (-not (Test-Path $proj)) { throw "Desktop project not found at $proj" }
if (-not $Out) { $Out = Join-Path $root (Join-Path 'publish' $Runtime) }

Write-Host "Kompendium desktop publish" -ForegroundColor Cyan
Write-Host "  project -> $proj"
Write-Host "  runtime -> $Runtime"
Write-Host "  out     -> $Out"

if (Test-Path $Out) { Remove-Item $Out -Recurse -Force }

Write-Host "`nPublishing self-contained single-file exe..." -ForegroundColor Cyan
dotnet publish $proj `
    -c Release `
    -r $Runtime `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -p:EnableCompressionInSingleFile=true `
    -o $Out
if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed (exit $LASTEXITCODE)." }

$exe = Get-ChildItem -Path $Out -Filter 'Kompendium.Desktop.exe' -File -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $exe) { throw "Published exe not found in $Out." }
$mb = [math]::Round($exe.Length / 1MB, 1)

Write-Host "`nDone." -ForegroundColor Green
Write-Host "  exe  : $($exe.FullName)"
Write-Host "  size : $mb MB (single file, self-contained)"
Write-Host "  run  : double-click the .exe - no .NET install required."
Write-Host "  note : needs the Evergreen WebView2 Runtime (pre-installed on Win10/11)."
