[Console]::OutputEncoding=[Text.Encoding]::UTF8
. (Join-Path $PSScriptRoot '_load.ps1')

$R=Join-Path $env:TEMP 'ugfake'
Remove-Item -LiteralPath $R -Recurse -Force -EA SilentlyContinue
New-Item -ItemType Directory -Path $R -Force | Out-Null
$R=(Get-Item -LiteralPath $R).FullName

# 1. gizli kutu klasoru: RECYCLER
$box=Join-Path $R 'RECYCLER'
New-Item -ItemType Directory -Path $box -Force | Out-Null
Set-Content -LiteralPath (Join-Path $box 'Odev.docx') -Value 'plain doc' -Encoding UTF8
Set-Content -LiteralPath (Join-Path $box 'gizli.exe') -Value 'MZfake' -Encoding ASCII
attrib +s +h "$box"

# 2. desktop.ini ile CLSID kilifi
$cl=Join-Path $R 'Fotograflar'
New-Item -ItemType Directory -Path $cl -Force | Out-Null
Set-Content -LiteralPath (Join-Path $cl 'desktop.ini') -Value "[.ShellClassInfo]`r`nCLSID={645FF040-5081-101B-9F08-00AA002F954E}" -Encoding ASCII
attrib +s +h "$cl"

# 3. MZ basligi tasiyan .dat (uzanti veri, icerik kod)
$mz=Join-Path $R 'update.dat'
[IO.File]::WriteAllBytes($mz,([byte[]](0x4D,0x5A,0x90,0x00,0x03,0x00,0x00,0x00)))

# 4. #@~^ kodlanmis vbs, .txt uzantili
Set-Content -LiteralPath (Join-Path $R 'notlar.txt') -Value '#@~^ZgAAAA==' -Encoding ASCII

# 5. duz veri dosyasi (yakalanmamali)
Set-Content -LiteralPath (Join-Path $R 'temiz.txt') -Value 'merhaba dunya' -Encoding UTF8

# 6. System Volume Information icinde yuk
$svi=Join-Path $R 'System Volume Information'
New-Item -ItemType Directory -Path $svi -Force | Out-Null
Set-Content -LiteralPath (Join-Path $svi 'WPSettings.dat') -Value 'x' -Encoding ASCII
Set-Content -LiteralPath (Join-Path $svi 'winsvc.vbs') -Value 'CreateObject("WScript.Shell")' -Encoding ASCII

# 7. RTLO isimli exe
Set-Content -LiteralPath (Join-Path $R ("resim" + [char]0x202E + "gpj.exe")) -Value 'x' -Encoding ASCII

attrib +s +h (Join-Path $R 'update.dat')
attrib +s +h (Join-Path $R 'notlar.txt')
"--- Test-Payload ---"
foreach($f in @('update.dat','notlar.txt','temiz.txt')){
  $p=Join-Path $R $f
  "{0,-14} => {1}" -f $f,(Test-Payload $p)
}
"--- Test-Cloak ---"
"Fotograflar   => " + (Test-Cloak $cl)
"--- Immunity-State ---"
"bos surucu    => " + (Immunity-State $R '')
New-Item -ItemType Directory -Path (Join-Path $R 'sysvolume') -Force | Out-Null
cmd /c ("mkdir " + '"\\?\' + (Join-Path $R 'sysvolume') + '\con..\"') 2>$null | Out-Null
"1/4 asili     => " + (Immunity-State $R '')
"--- Inspect-Drive ---"
$i=Inspect-Drive ($R+'\') ''
foreach($k in 'BadLnk','Hidden','Mimic','Payload','SysHide','Unhide'){
  "{0,-8}: {1} -> {2}" -f $k,@($i[$k]).Count,((@($i[$k]) | ForEach-Object { (Split-Path $_ -Leaf) -replace '[^ -~]','?' }) -join ' | ')
}
"Infected: " + $i.Infected
