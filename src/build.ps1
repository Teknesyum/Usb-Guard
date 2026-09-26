$src = Join-Path $PSScriptRoot 'usb-guard.ps1'
$hdr = Join-Path $PSScriptRoot 'header.bat'
$bat = Join-Path (Split-Path $PSScriptRoot -Parent) 'USB-Guard.bat'

$body = [IO.File]::ReadAllText($src, [Text.Encoding]::UTF8)
if ($body[0] -eq [char]0xFEFF) { $body = $body.Substring(1) }
$head = [IO.File]::ReadAllText($hdr, [Text.Encoding]::UTF8)
if ($head[0] -eq [char]0xFEFF) { $head = $head.Substring(1) }
if ($head -notmatch '(?m)^#>\s*$') { throw 'header does not close its comment block' }
if ($body -match '(?m)^#>') { throw 'body contains a comment terminator at line start' }

$tokFile = Join-Path (Split-Path $PSScriptRoot -Parent) 'teknesyum-ui\theme.tokens.json'
$tok = Get-Content $tokFile -Raw -Encoding UTF8 | ConvertFrom-Json
$flat = @{}
foreach ($grp in 'brand', 'role') { foreach ($p in $tok.$grp.PSObject.Properties) { $flat[$p.Name] = $p.Value } }
function Resolve-Tok($n) { $t = $flat[$n]; if ($null -eq $t) { throw "token missing: $n" }; if ($t.ref) { return Resolve-Tok $t.ref }; return $t.value }
$m = [regex]::Match($body, '(?m)^\$TK = @\{(.+)\}\s*$')
if (-not $m.Success) { throw 'no $TK table in the body' }
$drift = @()
foreach ($e in [regex]::Matches($m.Groups[1].Value, "'([\w-]+)'='(#[0-9A-Fa-f]{6})'")) {
    $want = Resolve-Tok $e.Groups[1].Value
    if ($want.ToUpper() -ne $e.Groups[2].Value.ToUpper()) { $drift += "$($e.Groups[1].Value) $($e.Groups[2].Value) -> $want" }
}
if ($drift.Count) { throw ("tokens drifted: " + ($drift -join '; ')) }

$out = $head.TrimEnd() + "`r`n`r`n" + $body
$out = ($out -replace "`r`n", "`n") -replace "`n", "`r`n"
[IO.File]::WriteAllText($bat, $out, (New-Object Text.UTF8Encoding($false)))

$check = [IO.File]::ReadAllText($bat, [Text.Encoding]::UTF8)
$i = $check.IndexOf("#>`r`n")
$tail = $check.Substring($i + 4).TrimStart([char]13, [char]10)
$norm = { param($s) ($s -replace "`r`n", "`n").Trim() }
"bat bytes  : " + (Get-Item $bat).Length
"body match : " + ((& $norm $tail) -eq (& $norm $body))
"tokens     : match"
"sha256     : " + (Get-FileHash $bat -Algorithm SHA256).Hash
$e = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($bat, [ref]$null, [ref]$e)
"parses     : " + ($e.Count -eq 0)
if ($e.Count) { $e | ForEach-Object { "  " + $_.Extent.StartLineNumber + ": " + $_.Message } }
