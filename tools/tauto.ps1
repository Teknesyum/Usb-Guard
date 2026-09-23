[Console]::OutputEncoding=[Text.Encoding]::UTF8
. (Join-Path $PSScriptRoot '_load.ps1')

$proj=Split-Path $PSScriptRoot -Parent
$R=Join-Path $proj '.tauto'
if(Test-Path -LiteralPath $R){ attrib -s -h -r "$R\*" /s /d 2>$null | Out-Null; Remove-Item -LiteralPath $R -Recurse -Force -EA SilentlyContinue }
New-Item -ItemType Directory -Path $R -Force | Out-Null
$R=(Get-Item -LiteralPath $R).FullName

$box=Join-Path $R 'Odevler'
New-Item -ItemType Directory -Path $box -Force | Out-Null
Set-Content -LiteralPath (Join-Path $box 'tez.docx') -Value 'plain doc' -Encoding UTF8
attrib +s +h "$box"
Set-Content -LiteralPath (Join-Path $R 'notlar.txt') -Value '#@~^ZgAAAA==' -Encoding ASCII
attrib +s +h (Join-Path $R 'notlar.txt')
$sh=New-Object -ComObject WScript.Shell
$l=$sh.CreateShortcut((Join-Path $R 'Odevler.lnk')); $l.TargetPath="$env:SystemRoot\System32\cmd.exe"; $l.Arguments='/c start wscript /e:VBScript.Encode notlar.txt & start explorer Odevler'; $l.Save()

$free=@('Q','R','T','V','W','X','Y') | Where-Object { -not (Test-Path "$($_):\") } | Select-Object -First 1
subst "$free`:" "$R"
$base=Join-Path $proj '.tauto-base'
$script:batSrc=Join-Path $proj 'USB-Guard.bat'
function Get-BatSource { return $script:batSrc }
function Install-Watcher { Write-Host ''; T (S 'wat.hinst') $ACC2; Spin (S 'wat.scopy') {} | Out-Null; Spin (S 'wat.srun') {} | Out-Null; Spin (S 'wat.sstart') {} | Out-Null; $script:taskOk=$true }

$dsk=[pscustomobject]@{DeviceID="$free`:";VolumeName='TEST';FileSystem='FAT32'}
$out=Auto-Fix $dsk *>&1 | Out-String
$out

"--- kontrol ---"
$chk=@(
  @('%100 yazildi',            ($out -match '%100')),
  @('yuzde adim adim',         ($out -match '%[1-9]\d? ')),
  @('ozet basligi',            ($out -match [regex]::Escape((S 'au.done').Trim()))),
  @('klasor gorunur',          -not ((Get-Item -LiteralPath (Join-Path $R 'Odevler') -Force).Attributes -band [IO.FileAttributes]::Hidden)),
  @('geri getirilen >= 1',     ($out -match ([regex]::Escape((S 'au.back').Split(':')[0].Trim())+'\s*:\s*[1-9]'))),
  @('dosya yerinde',           (Test-Path -LiteralPath (Join-Path $R 'Odevler\tez.docx'))),
  @('sahte kisayol gitti',     -not (Test-Path -LiteralPath (Join-Path $R 'Odevler.lnk'))),
  @('guard USB ye kopyalandi', (Test-Path -LiteralPath (Join-Path $R 'USB-Guard.bat'))),
  @('soru sorulmadi',          (($out -notmatch [regex]::Escape((S 'lb.ask').Trim())) -and ($out -notmatch [regex]::Escape((S 'dr.askcopy').Trim()))))
)
foreach($c in $chk){ "{0,-4} {1}" -f $(if($c[1]){'OK'}else{'FAIL'}),$c[0] }

subst "$free`:" /d
attrib -s -h -r "$R\*" /s /d 2>$null | Out-Null
Get-ChildItem -LiteralPath $R -Directory -Force -EA SilentlyContinue | ForEach-Object { cmd /c ('rd /s /q "\\?\' + $_.FullName + '"') 2>$null | Out-Null }
Remove-Item -LiteralPath $R -Recurse -Force -EA SilentlyContinue
Remove-Item -LiteralPath $base -Recurse -Force -EA SilentlyContinue
