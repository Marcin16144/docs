# Skrypt pobierania zdjec grzybow truciznych z Wikimedia Commons
# Uruchom: powershell -ExecutionPolicy Bypass -File pobierz-grzyby.ps1

$media = "D:\docs\house\grzyby\media"

$downloads = @(
    # 1. Amanita phalloides - gills (blaszki od spodu)
    # Najlepszy znaleziony kandydat: seria Lukas Large lub 2025 G3/G4 (ujecia z macro)
    # UWAGA: dla phalloides nie znaleziono pliku z explicite "gills" - uzywamy najlepszego kandydata
    @{
        Name = "12-u.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Amanita_phalloides_2025_G3.jpg/960px-Amanita_phalloides_2025_G3.jpg"
        Note = "Amanita phalloides (Ukraine 2025, macro CC BY 4.0) - kandydat na gills"
    },

    # 2. Amanita phalloides - young (mlody okaz)
    @{
        Name = "12-y.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Young_death_cap_mushroom_%28Amanita_phalloides%29_Heidelberg.jpg/960px-Young_death_cap_mushroom_%28Amanita_phalloides%29_Heidelberg.jpg"
        Note = "Young death cap Amanita phalloides Heidelberg (CC BY-SA 4.0)"
    },

    # 3. Amanita virosa - gills (azpitik = od spodu w jezyku baskijskim)
    @{
        Name = "t-virosa-u.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1c/Amanita_virosa_azpitik.jpg/960px-Amanita_virosa_azpitik.jpg"
        Note = "Amanita virosa azpitik (od spodu) CC BY-SA 4.0 - Jose Angel Urquia Goitia"
    },

    # 4. Amanita virosa - young (mlody okaz)
    # Seria UL (Universite Laval) - seria dokumentacyjna roznych stadiow
    @{
        Name = "t-virosa-y.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Amanita_virosa_UL_01.jpg/960px-Amanita_virosa_UL_01.jpg"
        Note = "Amanita virosa UL 01 (Universite Laval series) CC BY-SA 4.0"
    },

    # 5. Amanita pantherina - gills od spodu
    # Tengdake 06 = japonski "kap no ura" = underside of cap
    @{
        Name = "t-pantherina-u.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/f/fe/Tengdake_20080829_06.jpg"
        Note = "Amanita pantherina - underside of cap (japanski, CC BY-SA 3.0)"
    },

    # 6. Amanita pantherina - young (mlody okaz)
    @{
        Name = "t-pantherina-y.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Amanita_pantherina%2C_young_fruiting_body.jpg/960px-Amanita_pantherina%2C_young_fruiting_body.jpg"
        Note = "Amanita pantherina young fruiting body CC BY-SA 4.0"
    },

    # 7. Galerina marginata - gills od spodu
    # 051106Bmed: autor Strobilomyces, opis 'Spores 9x6 warty' - zdjecie gills
    @{
        Name = "t-galerina-u.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Galerina_marginata_051106Bmed.jpg/960px-Galerina_marginata_051106Bmed.jpg"
        Note = "Galerina marginata gills CC BY-SA 3.0 - Strobilomyces"
    },

    # 8. Galerina marginata - young (mlode owocniki)
    @{
        Name = "t-galerina-y.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Galerina_marginata_%28Haute-Loire%2C_France%29_01.jpg/960px-Galerina_marginata_%28Haute-Loire%2C_France%29_01.jpg"
        Note = "Galerina marginata Haute-Loire France CC BY-SA 4.0"
    },

    # 9. Gyromitra esculenta - przekroj/spod (workowie - brak blaszek)
    # Puszcza Bialowieska specimen
    @{
        Name = "t-gyromitra-u.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Gyromitra_esculenta_BPN1.jpg/960px-Gyromitra_esculenta_BPN1.jpg"
        Note = "Gyromitra esculenta Puszcza Bialowieska CC BY-SA 4.0"
    },

    # 10. Gyromitra esculenta - young (mlody okaz wiosenny)
    @{
        Name = "t-gyromitra-y.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Gyromitra_esculenta_in_Finland.jpg/960px-Gyromitra_esculenta_in_Finland.jpg"
        Note = "Gyromitra esculenta growing on lawn in southern Finland CC BY-SA 4.0"
    },

    # 11. Omphalotus olearius - gills (blaszki prawdziwe od spodu)
    # listast himenofor = chorwacki 'blaszkowaty hymenofor' = gills
    @{
        Name = "t-omphalotus-u.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Omphalotus_olearius_-_listast_himenofor.jpg/960px-Omphalotus_olearius_-_listast_himenofor.jpg"
        Note = "Omphalotus olearius listast himenofor (gills) CC BY-SA 4.0"
    },

    # 12. Omphalotus olearius - young (mlode kapelusze)
    @{
        Name = "t-omphalotus-y.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/A_composition_of_young_and_old_Omphalotus_olearus_at_Schaarsbergen_Hoge_Erf_-_panoramio.jpg/960px-A_composition_of_young_and_old_Omphalotus_olearus_at_Schaarsbergen_Hoge_Erf_-_panoramio.jpg"
        Note = "Young and old Omphalotus olearius Schaarsbergen CC BY 3.0"
    },

    # 13. Tylopilus felleus - pores od spodu (rozowe)
    @{
        Name = "t-tylopilus-u.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Tylopilus_felleus_pores.jpg/960px-Tylopilus_felleus_pores.jpg"
        Note = "Tylopilus felleus pores (closeup od spodu) CC0 - iNaturalist"
    },

    # 14. Tylopilus felleus - young (mlody okaz)
    @{
        Name = "t-tylopilus-y.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/0/08/Tylopilus_felleus_1.jpg"
        Note = "Tylopilus felleus Karmèlava forest Lithuania CC BY-SA 3.0"
    },

    # 15. Boletus/Rubroboletus satanas - pores od spodu (czerwone)
    # Satan onddoa azpitik = baskijski 'grzyb szatanski od spodu'
    @{
        Name = "t-satanas-u.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5b/Satan_onddoa_azpitik.jpg/960px-Satan_onddoa_azpitik.jpg"
        Note = "Rubroboletus satanas azpitik (od spodu/pores) CC BY-SA 4.0"
    },

    # 16. Boletus/Rubroboletus satanas - young (mlody okaz)
    @{
        Name = "t-satanas-y.jpg"
        Url  = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Rubroboletus_satanas_young_collection.jpg/960px-Rubroboletus_satanas_young_collection.jpg"
        Note = "Rubroboletus satanas young collection CC BY 4.0"
    }
)

Write-Host "Pobieranie zdjec grzybow..."
Write-Host "Folder docelowy: $media"
Write-Host ""

$success = 0
$failed = @()

foreach ($item in $downloads) {
    $outFile = Join-Path $media $item.Name
    Write-Host "Pobieranie: $($item.Name)"
    Write-Host "  URL: $($item.Url)"
    Write-Host "  Info: $($item.Note)"

    try {
        $headers = @{
            "User-Agent" = "Mozilla/5.0 (compatible; MushroomPhotoBot/1.0; educational)"
        }
        Invoke-WebRequest -Uri $item.Url -OutFile $outFile -Headers $headers -ErrorAction Stop
        $size = (Get-Item $outFile).Length
        Write-Host "  OK - zapisano $([math]::Round($size/1KB, 1)) KB" -ForegroundColor Green
        $success++
    } catch {
        Write-Host "  BLAD: $_" -ForegroundColor Red
        $failed += $item.Name
    }

    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "=== WYNIKI ==="
Write-Host "Pobrano: $success / $($downloads.Count)"
if ($failed.Count -gt 0) {
    Write-Host "Nie pobrano:"
    $failed | ForEach-Object { Write-Host "  - $_" }
}
