# Pobieranie zdjec krysztalow — zweryfikowane URL-e przez Wikimedia Commons API
$dest = "D:\docs\house\krysztaly\media"
$headers = @{
    "User-Agent" = "KrysztaBot/1.0 (strona edukacyjna o mineralach; kontakt@i4n.pl) PowerShell/5.1"
    "Accept"     = "image/jpeg,image/png,image/*,*/*;q=0.8"
}

$files = @(
    # --- 01 Ametyst ---
    @{ name="01-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/b/b5/Amatista_Laye_2.jpg" },
    @{ name="01-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/7/71/Amethyst_Jos_Plateau_01.jpg" },
    @{ name="01-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/9/9b/Amethyst_Jos_Plateau_02.jpg" },

    # --- 02 Kwarc rozowy ---
    @{ name="02-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/3/3a/Rose_quartz_12.jpg" },
    @{ name="02-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/5/58/2014-08-17-12.00.24_ZS_PMax_Rose_Quartz-1_%2814949715972%29.jpg" },
    @{ name="02-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/c/c9/Akwamaryn_i_kwarc_r%C3%B3%C5%BCowy.JPG" },

    # --- 03 Krysztal gorski ---
    @{ name="03-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/c/ce/Quartz_Br%C3%A9sil.jpg" },
    @{ name="03-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/1/1c/1036_Kreme%C5%88_%C5%BEezlovit%C3%BD_-_Bansk%C3%A1_%C5%A0tiavnica.jpg" },
    @{ name="03-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/7/74/1042_Kreme%C5%88_-_Bansk%C3%A1_%C5%A0tiavnica.jpg" },

    # --- 04 Obsydian ---
    @{ name="04-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/1/17/Lipari-Obsidienne_%285%29.jpg" },
    @{ name="04-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/c/c0/20141231_155025-_Prehistoric-_Obsidian-Turkey-cropped.jpg" },
    @{ name="04-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/d/db/Glass_Mountain_on_Medicine_Lake_Volcano-750px.jpg" },

    # --- 05 Labradoryt ---
    @{ name="05-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/3/38/Labradorite_polie_3%28Madagascar%29.jpg" },
    @{ name="05-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/3/38/1.labradoryt.jpg" },
    @{ name="05-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/b/bf/2493_sunstone_knoll.jpg" },

    # --- 06 Malachit ---
    @{ name="06-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/5/55/Malachite%2C_Zaire.jpg" },
    @{ name="06-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/e/ed/10_malahit_sa_Urala_%28r%D0%B5t%D0%BEuch%D0%B5d%29.jpg" },
    @{ name="06-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/c/c6/10_malahit_sa_Urala.JPG" },

    # --- 07 Lapis lazuli ---
    @{ name="07-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/d/da/Lapis-lazuli_hg.jpg" },
    @{ name="07-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/d/df/1Lapis_lazuli.jpeg" },
    @{ name="07-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/8/8d/2Lapis_lazuli.jpeg" },

    # --- 08 Bursztyn baltycki ---
    @{ name="08-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/b/b6/Amber2.jpg" },
    @{ name="08-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/8/8c/2bursztyn_ba%C5%82tycki_J.JPG" },
    @{ name="08-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/1/18/A_huge_piece_of_Baltic_amber_%289%2C7_kg%29._The_piece_is_stored_at_the_Natural_History_Museum_in_Berlin..jpg" },

    # --- 09 Turmalin ---
    @{ name="09-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/0/00/Tourmaline-121240.jpg" },
    @{ name="09-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/4/47/..Tourmaline_-_Tourmali.jpg" },
    @{ name="09-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/1/15/.Tourmaline_-_Tourmali.jpg" },

    # --- 10 Fluoryt ---
    @{ name="10-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/0/0d/3192M-fluorite1.jpg" },
    @{ name="10-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/2/2d/23Pseudomorphose1_hg.jpg" },
    @{ name="10-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/5/59/295_Fluort_Mskvt_Apatt.jpg" },

    # --- 11 Selenite ---
    @{ name="11-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/e/e1/NM_Gypsum_Selenite_Cluster.jpg" },
    @{ name="11-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/a/ab/NM_Gypsum_Selenite_Cluster_2.jpg" },
    @{ name="11-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/5/53/NM_Selenite_Crystal_Cluster.jpg" },

    # --- 12 Tygrysie oko ---
    @{ name="12-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/b/be/Tiger%27s_eye.jpg" },
    @{ name="12-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/8/8e/1tygrysie_oko.jpg" },
    @{ name="12-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/3/3e/2009_%D0%A2%D0%B8%D0%B3%D1%80%D0%BE%D0%B2%D1%8B%D0%B9_%D0%B3%D0%BB%D0%B0%D0%B7_%D1%81%D0%B5%D1%80.%D0%9C%D0%B8%D0%BD%D0%B5%D1%80%D0%B0%D0%BB%D1%8B_%D0%A3%D0%BA%D1%80%D0%B0%D0%B8%D0%BD%D1%8B.jpg" },

    # --- 13 Agat ---
    @{ name="13-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/2/26/Malawi_Agate_%28Malawi%2C_southeastern_Africa%29_%2832734668126%29.jpg" },
    @{ name="13-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/c/c4/%22Polka_Dot_Agate%22_%28Polka_Dot_Agate_Mine%2C_northeast_of_Madras%2C_Oregon%2C_USA%29_1.jpg" },
    @{ name="13-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/2/2f/%22Polka_Dot_Agate%22_%28Polka_Dot_Agate_Mine%2C_northeast_of_Madras%2C_Oregon%2C_USA%29_3.jpg" },

    # --- 14 Jadeit ---
    @{ name="14-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/8/8d/Jadeite_%28GeoDIL_number_-_1607%29.jpg" },
    @{ name="14-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/2/22/Jadeitite_%28jadeite_jade%29_%28Burma%29_1_%2824665206206%29.jpg" },
    @{ name="14-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/7/7a/Jadeitite_%28jadeite_jade%29_%28Burma%29_2_%2824666650906%29.jpg" },

    # --- 15 Piryt ---
    @{ name="15-1.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/9/91/Pyrite_-_Huanzala_mine%2C_Huallanca%2C_Bolognesi%2C_Ancash%2C_Peru.jpg" },
    @{ name="15-2.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/9/95/2780M-pyrite1.jpg" },
    @{ name="15-3.jpg"; url="https://upload.wikimedia.org/wikipedia/commons/6/6e/Bullypyrite2.jpg" }
)

$total = $files.Count
$i = 0; $ok = 0; $failed = @()

foreach ($f in $files) {
    $i++
    $outPath = Join-Path $dest $f.name
    if (Test-Path $outPath) {
        $sz = (Get-Item $outPath).Length
        if ($sz -gt 10000) { Write-Host "[$i/$total] SKIP $($f.name) ($sz B)"; $ok++; continue }
        Remove-Item $outPath -Force
    }
    Write-Host "[$i/$total] $($f.name) ..." -NoNewline
    $success = $false
    for ($a = 1; $a -le 3; $a++) {
        try {
            Invoke-WebRequest -Uri $f.url -OutFile $outPath -Headers $headers -TimeoutSec 60 -ErrorAction Stop
            $sz = (Get-Item $outPath).Length
            if ($sz -gt 10000) { Write-Host " OK ($sz B)"; $success = $true; $ok++; break }
            else { Write-Host " TINY ($sz B)"; if (Test-Path $outPath) { Remove-Item $outPath -Force } }
        } catch {
            $code = if ($_.Exception.Response) { [int]$_.Exception.Response.StatusCode } else { 0 }
            Write-Host " ERR $code ($a/3)"
            if ($code -eq 429) { Write-Host "  Rate limit! Czekam 90s..."; Start-Sleep -Seconds 90 }
            elseif ($a -lt 3) { Start-Sleep -Seconds 8 }
            if (Test-Path $outPath) { Remove-Item $outPath -Force }
        }
    }
    if (-not $success) { $failed += $f.name }
    if ($i -lt $total) { Start-Sleep -Seconds 4 }
}

Write-Host "`n=== WYNIK: $ok/$total OK ==="
if ($failed.Count -gt 0) { Write-Host "Bledy: $($failed -join ', ')" }
Get-ChildItem $dest -Filter "*.jpg" | Sort-Object Name | ForEach-Object { Write-Host "$($_.Name) $($_.Length)B" }
