. (Join-Path $PSScriptRoot '_load.ps1')

$root = Join-Path $env:TEMP ('ugar_'+[guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Path $root | Out-Null
$ai = Join-Path $root 'autorun.inf'
$pass=0; $fail=0
function chk($n,$c){ if($c){ $script:pass++; $s='OK' } else { $script:fail++; $s='FAIL' }; '{0,-50} {1}' -f $n,$s }

Lock-Immunity $ai $false
$it=Get-Item -LiteralPath $ai -Force
chk 'file olustu' (-not $it.PSIsContainer)
chk '+s +h +r' (($it.Attributes -band [IO.FileAttributes]::Hidden) -and ($it.Attributes -band [IO.FileAttributes]::System) -and ($it.Attributes -band [IO.FileAttributes]::ReadOnly))
chk 'icerik [autorun]' ((Get-Content -Raw $ai).Trim() -eq '[autorun]')
chk 'immunized' (Test-Immunized $ai)

[IO.File]::SetAttributes($ai,[IO.FileAttributes]::Normal)
[IO.File]::WriteAllText($ai,"[autorun]`r`nopen=evil.exe`r`n")
chk 'kotucul: ArSafe false' (-not (Test-ArSafe $ai))
chk 'kotucul: Inspect ArFile true' ((Inspect-Drive $root '').ArFile)

Lock-Immunity $ai $false
chk 're-immunize guvenli' ((Test-Immunized $ai) -and -not (Inspect-Drive $root '').ArFile)

Nuke-Path $ai
[IO.Directory]::CreateDirectory('\\?\'+$ai) | Out-Null
[IO.Directory]::CreateDirectory('\\?\'+$ai+'\'+$reserved) | Out-Null
chk 'klasor-autorun immunized false' (-not (Test-Immunized $ai))
Lock-Immunity $ai $false
chk 'migrate klasor->file' ((-not (Get-Item -LiteralPath $ai -Force).PSIsContainer) -and (Test-Immunized $ai))

$dc = Join-Path $root 'sysvolume'
Lock-Immunity $dc $false
chk 'decoy klasor immunized' ((Test-Immunized $dc) -and (Get-Item -LiteralPath $dc -Force).PSIsContainer)

try{ [IO.Directory]::Delete('\\?\'+$root,$true) }catch{ & cmd /c rd /s /q "\\?\$root" 2>$null | Out-Null }
''
"pass=$pass fail=$fail temiz=$(-not (Test-Path -LiteralPath $root))"
if($fail){ exit 1 }
