$d="D:\docs\house\rosliny\media"; $h=@{"User-Agent"="Mozilla/5.0"}
$files=@(
  @("laka-kozlek.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/293453309/medium.jpeg"),
  @("laka-nawloc.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/555968859/medium.jpg"),
  @("laka-czosnek-n.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/10674/medium.jpg"),
  @("laka-pierwiosnek.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/186907134/medium.jpg"),
  @("laka-wiazowka.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/51718/medium.jpg"),
  @("laka-kminek.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/60571177/medium.jpeg"),
  @("laka-marchew.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/7663971/medium.jpeg"),
  @("laka-malina.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/358785151/medium.jpg"),
  @("laka-gorczyca.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/326850053/medium.jpeg"),
  @("laka-chaber.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/162587910/medium.jpg"),
  @("laka-konwalia.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/129833718/medium.jpeg"),
  @("laka-krwawnica.jpg","https://static.inaturalist.org/photos/63744014/medium.jpeg"),
  @("laka-kniec.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/324010734/medium.jpeg"),
  @("laka-driakiew.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/252157733/medium.jpg"),
  @("laka-szalwia.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/19428761/medium.jpg"),
  @("laka-mydlnica.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/83287876/medium.jpeg"),
  @("laka-lnica.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/542354433/medium.jpg"),
  @("laka-wyka.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/133717606/medium.jpeg"),
  @("laka-pieciornik.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/43334473/medium.jpeg"),
  @("laka-nawloc-k.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/87573048/medium.jpg")
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
}
Write-Host "---DONE---"
Get-ChildItem "$d\laka-*.jpg"|Sort Name|Select Name,@{N='KB';E={[int]($_.Length/1KB)}}|ft -Auto
