$d="D:\docs\house\rosliny\media"
$h=@{"User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
$files=@(
  @("laka-wierzba.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/Salix_caprea_Male.jpg/500px-Salix_caprea_Male.jpg"),
  @("laka-bluszczyk.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Glechoma_hederacea_-_Keila.jpg/500px-Glechoma_hederacea_-_Keila.jpg"),
  @("laka-koniczyna-r.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Trifolium_pratense_-_Keila.jpg/500px-Trifolium_pratense_-_Keila.jpg"),
  @("laka-koniczyna.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Trifolium_repens_kz02.jpg/500px-Trifolium_repens_kz02.jpg"),
  @("laka-fiolek.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Viola_odorata_ENBLA02.jpg/500px-Viola_odorata_ENBLA02.jpg"),
  @("laka-szczaw.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Rumex_acetosa_kz14.jpg/500px-Rumex_acetosa_kz14.jpg"),
  @("laka-komosa.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Chenopodium_album_kz02.jpg/500px-Chenopodium_album_kz02.jpg"),
  @("laka-wierzbowka.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Chamerion_angustifolium_RF.jpg/500px-Chamerion_angustifolium_RF.jpg"),
  @("laka-cykoria.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Cichorium_intybus-alvesgaspar1.jpg/500px-Cichorium_intybus-alvesgaspar1.jpg"),
  @("laka-macierzanka.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Thymus_serpyllum_kz02.jpg/500px-Thymus_serpyllum_kz02.jpg"),
  @("laka-nostrzyk.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Melilotus_officinalis_kz17.jpg/500px-Melilotus_officinalis_kz17.jpg"),
  @("laka-dziewanna.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Verbascum_thapsus_fruit_kz.jpg/500px-Verbascum_thapsus_fruit_kz.jpg"),
  @("laka-mak.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Papaver_rhoeas_050526.jpg/500px-Papaver_rhoeas_050526.jpg"),
  @("laka-bylica.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Artemisia_absinthium_kz09.jpg/500px-Artemisia_absinthium_kz09.jpg"),
  @("laka-wrotycz.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Tanacetum_vulgare_4_RF.jpg/500px-Tanacetum_vulgare_4_RF.jpg"),
  @("laka-lebiodka.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/Origanum_vulgare_inflorescence_-_Keila.jpg/500px-Origanum_vulgare_inflorescence_-_Keila.jpg"),
  @("laka-zywokost.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Symphytum_officinale_RF.jpg/500px-Symphytum_officinale_RF.jpg"),
  @("laka-przytulia.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Galium_aparine-04-05-05.jpg/500px-Galium_aparine-04-05-05.jpg"),
  @("laka-stokrotka.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Bellis_perennis_%E2%80%93_Flower.jpg/500px-Bellis_perennis_%E2%80%93_Flower.jpg"),
  @("laka-szanta.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Marrubium_vulgare_kz20.jpg/500px-Marrubium_vulgare_kz20.jpg"),
  @("laka-glistnik.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Chelidonium_majus_kz05.jpg/500px-Chelidonium_majus_kz05.jpg"),
  @("laka-glog.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Crataegus_monogyna_2.jpg/500px-Crataegus_monogyna_2.jpg"),
  @("laka-tarnina.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Prunus_spinosa_-_geograph.org.uk_-_1216187.jpg/500px-Prunus_spinosa_-_geograph.org.uk_-_1216187.jpg"),
  @("laka-jezyna.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Blackberries_%28Rubus_fruticosus%29.jpg/500px-Blackberries_%28Rubus_fruticosus%29.jpg"),
  @("laka-poziomka.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Fragaria_vesca_fruit_-_Keila.jpg/500px-Fragaria_vesca_fruit_-_Keila.jpg"),
  @("laka-jaskier.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Renoncule_rampante_%28Ranunculus_repens%29.jpg/500px-Renoncule_rampante_%28Ranunculus_repens%29.jpg"),
  @("laka-bez-hebd.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Sambucus_ebulus_Bez_hebd_2021-10-02_01.jpg/500px-Sambucus_ebulus_Bez_hebd_2021-10-02_01.jpg"),
  @("laka-lulek.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Hyoscyamus_niger_0002.JPG/500px-Hyoscyamus_niger_0002.JPG"),
  @("laka-bielun.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Datura_stramonium_2_%282005_07_07%29.jpg/500px-Datura_stramonium_2_%282005_07_07%29.jpg"),
  @("laka-ostrozen.jpg","https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Cirsium_vulgare_-_Keila2.jpg/500px-Cirsium_vulgare_-_Keila2.jpg")
)
foreach($f in $files){
  $p=Join-Path $d $f[0]
  if(Test-Path $p){Write-Host "EXISTS $($f[0])";continue}
  try{
    Invoke-WebRequest $f[1] -OutFile $p -Headers $h -UseBasicParsing -TimeoutSec 30 -EA Stop
    Write-Host "OK $($f[0]) $([int]((gi $p).Length/1KB))KB"
  }catch{
    Write-Host "FAIL $($f[0]) $($_.Exception.Message.Split([char]10)[0])"
    if(Test-Path $p){ri $p -Force}
  }
  Start-Sleep -Seconds 2
}
Write-Host "---"
Get-ChildItem "$d\laka-*.jpg"|Select Name,@{N='KB';E={[int]($_.Length/1KB)}}|ft -Auto
