. (Join-Path $PSScriptRoot '_load.ps1')
Set-Lang 'tr'
Calc-M

$T=Join-Path $env:TEMP 'ugsubst'
cmd /c ('rmdir /s /q "\\?\' + $T + '"') 2>&1 | Out-Null
New-Item -ItemType Directory -Path $T -Force | Out-Null
Set-Content -LiteralPath (Join-Path $T 'Odev.docx') -Value 'belge' -Encoding UTF8
$box=Join-Path $T 'RECYCLER'
New-Item -ItemType Directory -Path $box -Force | Out-Null
Set-Content -LiteralPath (Join-Path $box 'gercek.docx') -Value 'belge' -Encoding UTF8
Set-Content -LiteralPath (Join-Path $box 'worm.vbs') -Value 'CreateObject("WScript.Shell")' -Encoding ASCII
attrib +s +h "$box"
$sh=New-Object -ComObject WScript.Shell
$l=$sh.CreateShortcut((Join-Path $T 'Odev.lnk')); $l.TargetPath='C:\Windows\System32\wscript.exe'; $l.Arguments='//b RECYCLER\worm.vbs'; $l.Save()

cmd /c "subst X: /d" 2>&1 | Out-Null
cmd /c ('subst X: "' + $T + '"') 2>&1 | Out-Null

function Ask-YN { Write-Host 'H' -ForegroundColor White; return $false }
function Get-BatSource { return (Join-Path (Split-Path $PSScriptRoot -Parent) 'USB-Guard.bat') }

Clear-Host
$a=[Console]::CursorTop
Process-Drive ([pscustomobject]@{DeviceID='X:';VolumeName='Mustafa Ozel';FileSystem='NTFS'})
$b=[Console]::CursorTop
cmd /c "subst X: /d" 2>&1 | Out-Null
Write-Host ''
Write-Host ("SATIR: " + ($b-$a))
