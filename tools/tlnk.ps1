. (Join-Path $PSScriptRoot '_load.ps1')

$R=Join-Path $env:TEMP 'uglnk'
Remove-Item -LiteralPath $R -Recurse -Force -EA SilentlyContinue
New-Item -ItemType Directory -Path $R -Force | Out-Null
$R=(Get-Item -LiteralPath $R).FullName

Set-Content -LiteralPath (Join-Path $R 'Odev.docx') -Value 'gercek belge' -Encoding UTF8
attrib +s +h (Join-Path $R 'Odev.docx')
[IO.File]::WriteAllBytes((Join-Path $R 'kurulum.dat'),([byte[]](0x4D,0x5A,0x90,0x00)))
attrib +s +h (Join-Path $R 'kurulum.dat')

$w=New-Object -ComObject WScript.Shell
$l=$w.CreateShortcut((Join-Path $R 'Odev.lnk'))
$l.TargetPath='C:\Windows\System32\cmd.exe'
$l.Arguments='/r start Odev.docx & start wscript.exe kurulum.dat'
$l.Save()

$i=Inspect-Drive ($R+'\') 'USB'
foreach($k in 'BadLnk','Hidden','Mimic','Payload','SysHide','Unhide'){
  "{0,-8}: {1} -> {2}" -f $k,@($i[$k]).Count,((@($i[$k]) | ForEach-Object { Split-Path $_ -Leaf }) -join ' | ')
}
"Infected: " + $i.Infected
