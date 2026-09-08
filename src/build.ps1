$src = Join-Path $PSScriptRoot 'usb-guard.ps1'
$hdr = Join-Path $PSScriptRoot 'header.bat'
$bat = Join-Path (Split-Path $PSScriptRoot -Parent) 'USB-Guard.bat'

$body = [IO.File]::ReadAllText($src, [Text.Encoding]::UTF8)
if ($body[0] -eq [char]0xFEFF) { $body = $body.Substring(1) }
$head = [IO.File]::ReadAllText($hdr, [Text.Encoding]::UTF8)
if ($head[0] -eq [char]0xFEFF) { $head = $head.Substring(1) }
if ($head -notmatch '(?m)^#>\s*$') { throw 'header does not close its comment block' }
if ($body -match '(?m)^#>') { throw 'body contains a comment terminator at line start' }

$out = $head.TrimEnd() + "`r`n`r`n" + $body
$out = ($out -replace "`r`n", "`n") -replace "`n", "`r`n"
[IO.File]::WriteAllText($bat, $out, (New-Object Text.UTF8Encoding($false)))

$check = [IO.File]::ReadAllText($bat, [Text.Encoding]::UTF8)
$i = $check.IndexOf("#>`r`n")
$tail = $check.Substring($i + 4).TrimStart([char]13, [char]10)
$norm = { param($s) ($s -replace "`r`n", "`n").Trim() }
"bat bytes  : " + (Get-Item $bat).Length
"body match : " + ((& $norm $tail) -eq (& $norm $body))
"sha256     : " + (Get-FileHash $bat -Algorithm SHA256).Hash
$e = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($bat, [ref]$null, [ref]$e)
"parses     : " + ($e.Count -eq 0)
if ($e.Count) { $e | ForEach-Object { "  " + $_.Extent.StartLineNumber + ": " + $_.Message } }
