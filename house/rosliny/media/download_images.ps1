# Download images from Wikimedia Commons with rate limiting
$dest = "D:\docs\house\rosliny\media"
$headers = @{ "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }

$files = @(
    @{ name = "grzyb-borowik.jpg";   url = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Boletus_edulis_steinpilz.jpg/500px-Boletus_edulis_steinpilz.jpg" },
    @{ name = "grzyb-kurka.jpg";     url = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Cantharellus_cibarius_2009_G3.jpg/500px-Cantharellus_cibarius_2009_G3.jpg" },
    @{ name = "grzyb-maslak.jpg";    url = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/Suillus_luteus_2010_G2.jpg/500px-Suillus_luteus_2010_G2.jpg" },
    @{ name = "grzyb-rydz.jpg";      url = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Lactarius_deliciosus_2010_G1.jpg/500px-Lactarius_deliciosus_2010_G1.jpg" },
    @{ name = "grzyb-opienka.jpg";   url = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Armillaria-mellea-hallimasch.jpg/500px-Armillaria-mellea-hallimasch.jpg" },
    @{ name = "grzyb-muchomor-cz.jpg"; url = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Amanita_muscaria_qtl4.jpg/500px-Amanita_muscaria_qtl4.jpg" },
    @{ name = "grzyb-szatanskiB.jpg"; url = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Boletus_satanas.JPG/500px-Boletus_satanas.JPG" },
    @{ name = "grzyb-galerina.jpg";  url = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/GalrinaMarginata.jpg/500px-GalrinaMarginata.jpg" },
    @{ name = "laka-koniczyna.jpg";  url = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/Trifolium_repens_%28inflorescense%29_Edit.jpg/500px-Trifolium_repens_%28inflorescense%29_Edit.jpg" },
    @{ name = "laka-fiolek.jpg";     url = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Viola_odorata_ENBLA02.jpg/500px-Viola_odorata_ENBLA02.jpg" },
    @{ name = "laka-wierzbowka.jpg"; url = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Chamerion_angustifolium_RF.jpg/500px-Chamerion_angustifolium_RF.jpg" },
    @{ name = "laka-bylica.jpg";     url = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Artemisia_absinthium_kz09.jpg/500px-Artemisia_absinthium_kz09.jpg" },
    @{ name = "laka-zywokost.jpg";   url = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Symphytum_officinale_RF.jpg/500px-Symphytum_officinale_RF.jpg" },
    @{ name = "laka-glog.jpg";       url = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Crataegus_monogyna_2.jpg/500px-Crataegus_monogyna_2.jpg" },
    @{ name = "laka-jezyna.jpg";     url = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Blackberries_%28Rubus_fruticosus%29.jpg/500px-Blackberries_%28Rubus_fruticosus%29.jpg" },
    @{ name = "laka-bielun.jpg";     url = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Datura_stramonium_2_%282005_07_07%29.jpg/500px-Datura_stramonium_2_%282005_07_07%29.jpg" },
    @{ name = "laka-ostrozen.jpg";   url = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Cirsium_vulgare_-_Keila2.jpg/500px-Cirsium_vulgare_-_Keila2.jpg" }
)

$total = $files.Count
$i = 0

foreach ($f in $files) {
    $i++
    $outPath = Join-Path $dest $f.name

    if (Test-Path $outPath) {
        Write-Host "[$i/$total] SKIP (exists): $($f.name)"
        continue
    }

    Write-Host "[$i/$total] Downloading: $($f.name) ..."
    $success = $false

    for ($attempt = 1; $attempt -le 2; $attempt++) {
        try {
            Invoke-WebRequest -Uri $f.url -OutFile $outPath -Headers $headers -TimeoutSec 60 -ErrorAction Stop
            $size = (Get-Item $outPath).Length
            Write-Host "  OK: $($f.name) ($size bytes)"
            $success = $true
            break
        } catch {
            $statusCode = $null
            if ($_.Exception.Response) {
                $statusCode = [int]$_.Exception.Response.StatusCode
            }
            Write-Host "  FAILED (attempt $attempt): $($_.Exception.Message) [status: $statusCode]"
            if ($statusCode -eq 429) {
                Write-Host "  Rate limited (429) - waiting 60 seconds..."
                Start-Sleep -Seconds 60
            } elseif ($attempt -lt 2) {
                Write-Host "  Waiting 10 seconds before retry..."
                Start-Sleep -Seconds 10
            }
            if (Test-Path $outPath) { Remove-Item $outPath -Force }
        }
    }

    if (-not $success) {
        Write-Host "  SKIPPED after failures: $($f.name)"
    }

    # Wait 30 seconds between downloads (skip wait after last file)
    if ($i -lt $total) {
        Write-Host "  Waiting 30 seconds before next download..."
        Start-Sleep -Seconds 30
    }
}

Write-Host ""
Write-Host "=== FINAL FILE LIST ==="
Get-ChildItem $dest -Filter "grzyb-*.jpg" | Sort-Object Name | ForEach-Object { Write-Host "$($_.Name)  $($_.Length) bytes" }
Get-ChildItem $dest -Filter "laka-*.jpg" | Sort-Object Name | ForEach-Object { Write-Host "$($_.Name)  $($_.Length) bytes" }
