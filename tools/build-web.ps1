#Requires -Version 5.1
<#
.SYNOPSIS
    Assemble a clean, upload-ready static bundle of the Kompendium under dist/.

.DESCRIPTION
    1. Re-runs Kompendium.Indexer to refresh values/data/*.json and re-inject the
       shared reading-position / related-materials widget into every page.
    2. Mirrors the documentation tree into dist/, stripping dev-only artefacts
       (the C# solution under src/, tooling, VCS metadata, build output, curated
       relation source, gap report).

    The result in dist/ is a pure static site: copy it to any web server
    (IIS, nginx, Apache, Caddy, GitHub Pages, Netlify, ...). It must be served
    over http(s) - opening via file:// blocks the fetch() calls that power search
    and related-materials.

.PARAMETER Root
    Documentation root. Defaults to the parent of this script's folder.

.PARAMETER Out
    Output bundle directory. Defaults to <Root>\dist.

.PARAMETER NoIndex
    Skip the indexer pass and just mirror the current tree.

.PARAMETER Zip
    Also produce <Root>\kompendium-web.zip from the bundle.

.EXAMPLE
    powershell -File tools/build-web.ps1
    powershell -File tools/build-web.ps1 -Zip
    powershell -File tools/build-web.ps1 -NoIndex -Out C:\inetpub\kompendium
#>
[CmdletBinding()]
param(
    [string]$Root,
    [string]$Out,
    [switch]$NoIndex,
    [switch]$Zip
)

$ErrorActionPreference = 'Stop'

if (-not $Root) { $Root = Split-Path -Parent $PSScriptRoot }
$Root = (Resolve-Path $Root).Path
if (-not $Out)  { $Out  = Join-Path $Root 'dist' }

Write-Host "Kompendium web build" -ForegroundColor Cyan
Write-Host "  root -> $Root"
Write-Host "  out  -> $Out"

# 1. Refresh data layer + widget injection ----------------------------------
if (-not $NoIndex) {
    Write-Host "`n[1/3] Indexing (refresh data + inject widget)..." -ForegroundColor Cyan
    $indexer = Join-Path $Root 'src/Kompendium.Indexer'
    if (Test-Path $indexer) {
        dotnet run --project $indexer -c Release -- $Root
        if ($LASTEXITCODE -ne 0) { throw "Indexer failed (exit $LASTEXITCODE)." }
    } else {
        Write-Warning "Indexer project not found at $indexer - skipping index pass."
    }
} else {
    Write-Host "`n[1/3] Indexing skipped (-NoIndex)." -ForegroundColor DarkGray
}

# 2. Mirror deployable tree into the bundle ---------------------------------
Write-Host "`n[2/3] Mirroring static site into bundle..." -ForegroundColor Cyan

# Directories excluded by name anywhere in the tree.
$xdNames = @('.git', '.vs', '.claude', 'node_modules', '__pycache__', 'obj', 'bin', 'publish')
# Top-level directories excluded by full path only.
$xdPaths = @('src', 'tools', 'dist') | ForEach-Object { Join-Path $Root $_ }
# Files excluded by name/pattern anywhere.
$xfNames = @('.gitignore', '*.sln', '*.csproj', '*.user', 'global.json',
             'relations.curated.json', '_report.json',
             '*.ps1', 'desktop.ini', 'Thumbs.db')

if (-not (Test-Path $Out)) { New-Item -ItemType Directory -Path $Out -Force | Out-Null }

$roboArgs = @($Root, $Out, '/MIR', '/NJH', '/NJS', '/NDL', '/NFL', '/NP', '/R:1', '/W:1',
              '/XD') + $xdNames + $xdPaths + @('/XF') + $xfNames
& robocopy @roboArgs | Out-Null
# robocopy exit codes 0-7 are success; 8+ indicate a genuine failure.
if ($LASTEXITCODE -ge 8) { throw "robocopy failed (exit $LASTEXITCODE)." }
$global:LASTEXITCODE = 0

# 3. Report + optional zip ---------------------------------------------------
Write-Host "`n[3/3] Bundle summary" -ForegroundColor Cyan
$htmlCount = (Get-ChildItem -Path $Out -Recurse -Filter *.html -File).Count
$bytes     = (Get-ChildItem -Path $Out -Recurse -File | Measure-Object -Property Length -Sum).Sum
$mb        = [math]::Round($bytes / 1MB, 1)
Write-Host "  HTML pages : $htmlCount"
Write-Host "  total size : $mb MB"
Write-Host "  location   : $Out"

if ($Zip) {
    $zipPath = Join-Path $Root 'kompendium-web.zip'
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    Write-Host "`nCompressing -> $zipPath ..." -ForegroundColor Cyan
    Compress-Archive -Path (Join-Path $Out '*') -DestinationPath $zipPath
    $zmb = [math]::Round((Get-Item $zipPath).Length / 1MB, 1)
    Write-Host "  archive    : $zipPath ($zmb MB)"
}

Write-Host "`nDone. Deploy the bundle (serve over http/https, never file://):" -ForegroundColor Green
Write-Host "  - IIS        : point a site/app at dist\  (or copy dist\* into C:\inetpub\kompendium)"
Write-Host "  - nginx      : set 'root /var/www/kompendium;' to the uploaded dist\ contents"
Write-Host "  - Apache     : copy dist\* into the DocumentRoot (e.g. /var/www/html/kompendium)"
Write-Host "  - static host: upload dist\* to GitHub Pages / Netlify / any CDN web root"
Write-Host "  - quick preview: powershell -File tools/serve.ps1"
