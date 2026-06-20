#Requires -Version 5.1
<#
.SYNOPSIS
    Zero-dependency static web server for previewing the Kompendium locally.

.DESCRIPTION
    Serves the documentation over http:// so the fetch()-powered search and
    related-materials work (file:// blocks them). Uses System.Net.HttpListener -
    no install, no admin rights (binds to localhost only).

.PARAMETER Path
    Folder to serve. Defaults to <repo>\dist if present, otherwise the repo root.

.PARAMETER Port
    TCP port. Default 8080.

.EXAMPLE
    pwsh tools/serve.ps1
    pwsh tools/serve.ps1 -Path . -Port 5500
#>
[CmdletBinding()]
param(
    [string]$Path,
    [int]$Port = 8080
)

$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
if (-not $Path) {
    $dist = Join-Path $repo 'dist'
    if (Test-Path $dist) { $Path = $dist } else { $Path = $repo }
}
$root = (Resolve-Path $Path).Path

$mime = @{
    '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8';
    '.css'='text/css; charset=utf-8';   '.js'='text/javascript; charset=utf-8';
    '.json'='application/json; charset=utf-8'; '.md'='text/markdown; charset=utf-8';
    '.txt'='text/plain; charset=utf-8'; '.xml'='application/xml; charset=utf-8';
    '.svg'='image/svg+xml'; '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg';
    '.gif'='image/gif'; '.webp'='image/webp'; '.ico'='image/x-icon';
    '.woff'='font/woff'; '.woff2'='font/woff2'; '.ttf'='font/ttf'; '.eot'='application/vnd.ms-fontobject';
    '.pdf'='application/pdf'; '.mp4'='video/mp4'; '.webm'='video/webm'; '.mp3'='audio/mpeg'
}

$listener = [System.Net.HttpListener]::new()
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)
try { $listener.Start() }
catch { throw "Cannot bind $prefix - is port $Port already in use? ($($_.Exception.Message))" }

Write-Host "Kompendium preview server" -ForegroundColor Cyan
Write-Host "  serving : $root"
Write-Host "  url     : $prefix" -ForegroundColor Green
Write-Host "  stop    : Ctrl+C`n"

try {
    while ($listener.IsListening) {
        $ctx = $listener.GetContext()
        $req = $ctx.Request
        $res = $ctx.Response
        try {
            $rel = [Uri]::UnescapeDataString($req.Url.AbsolutePath).TrimStart('/')
            if ([string]::IsNullOrEmpty($rel)) { $rel = 'index.html' }
            $full = Join-Path $root ($rel -replace '/', '\')
            if ((Test-Path $full -PathType Container)) { $full = Join-Path $full 'index.html' }

            # Path-traversal guard: resolved file must stay under root.
            $fullResolved = [System.IO.Path]::GetFullPath($full)
            if (-not $fullResolved.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) {
                $res.StatusCode = 403; $res.Close(); continue
            }

            if (Test-Path $fullResolved -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($fullResolved).ToLowerInvariant()
                $res.ContentType = $mime[$ext]; if (-not $res.ContentType) { $res.ContentType = 'application/octet-stream' }
                $bytes = [System.IO.File]::ReadAllBytes($fullResolved)
                $res.ContentLength64 = $bytes.Length
                $res.OutputStream.Write($bytes, 0, $bytes.Length)
                Write-Host ("  200  /{0}" -f $rel) -ForegroundColor DarkGray
            } else {
                $res.StatusCode = 404
                $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - $rel")
                $res.OutputStream.Write($msg, 0, $msg.Length)
                Write-Host ("  404  /{0}" -f $rel) -ForegroundColor DarkYellow
            }
        } catch {
            try { $res.StatusCode = 500 } catch {}
            Write-Host "  500  $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            try { $res.OutputStream.Close() } catch {}
        }
    }
} finally {
    $listener.Stop(); $listener.Close()
}
