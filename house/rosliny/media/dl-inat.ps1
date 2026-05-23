$d="D:\docs\house\rosliny\media"; $h=@{"User-Agent"="Mozilla/5.0"}
$files=@(
  @("laka-koniczyna.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/64586855/medium.jpeg"),
  @("laka-fiolek.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/622851735/medium.jpg"),
  @("laka-szczaw.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/130014502/medium.jpeg"),
  @("laka-komosa.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/234299048/medium.jpeg"),
  @("laka-wierzbowka.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/589344702/medium.jpg"),
  @("laka-macierzanka.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/147682040/medium.jpg"),
  @("laka-nostrzyk.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/16273/medium.jpg"),
  @("laka-mak.jpg","https://static.inaturalist.org/photos/234132991/medium.jpg"),
  @("laka-bylica.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/45876952/medium.jpeg"),
  @("laka-wrotycz.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/45581182/medium.jpg"),
  @("laka-zywokost.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/243496829/medium.jpeg"),
  @("laka-przytulia.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/113728457/medium.jpeg"),
  @("laka-stokrotka.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/515847774/medium.jpg"),
  @("laka-szanta.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/34608821/medium.jpg"),
  @("laka-glistnik.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/202516664/medium.jpeg"),
  @("laka-glog.jpg","https://static.inaturalist.org/photos/26280730/medium.jpg"),
  @("laka-tarnina.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/578763668/medium.jpg"),
  @("laka-jezyna.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/10407/medium.jpg"),
  @("laka-jaskier.jpg","https://inaturalist-open-data.s3.amazonaws.com/photos/38652836/medium.jpeg"),
  @("laka-bez-hebd.jpg","https://static.inaturalist.org/photos/214051630/medium.jpg")
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
