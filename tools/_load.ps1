$root=Split-Path $PSScriptRoot -Parent
$src=[IO.File]::ReadAllText((Join-Path $root 'src\usb-guard.ps1'),[Text.Encoding]::UTF8)
$body=$src.Substring(0,$src.IndexOf('if($Watch){ Start-Watcher; return }')) -replace 'param\(\[switch\]\$Watch,\[string\]\$Drive,\[switch\]\$Bg\)',''
Invoke-Expression $body
