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
$sync = 0
$body = [regex]::Replace($body, '(?m)^(\$TK = @\{)(.+)(\}\s*)$', { param($x) $x.Groups[1].Value + [regex]::Replace($x.Groups[2].Value, "'([\w-]+)'='(#[0-9A-Fa-f]{6})'", { param($e) $v = (Resolve-Tok $e.Groups[1].Value).ToUpper(); if ($v -ne $e.Groups[2].Value.ToUpper()) { $script:sync++ }; "'" + $e.Groups[1].Value + "'='" + $v + "'" }) + $x.Groups[3].Value })
$body = [regex]::Replace($body, '(?m)^(\$TKN = @\{)(.+)(\}\s*)$', { param($x) $x.Groups[1].Value + [regex]::Replace($x.Groups[2].Value, "'([\w-]+)'=(\d+)", { param($e) $k = $e.Groups[1].Value; $t = if ($k -match '^space-(\d+)$') { $tok.space.($matches[1]) } elseif ($tok.size.$k) { $tok.size.$k } else { $tok.metric.$k }; if ($null -eq $t) { throw "token missing: $k" }; if ([string]$t.value -ne $e.Groups[2].Value) { $script:sync++ }; "'" + $k + "'=" + $t.value }) + $x.Groups[3].Value })
$lab = @{}
foreach ($lg in 'tr', 'en') { $lab[$lg] = Get-Content (Join-Path (Split-Path $tokFile) "winforms\labels.$lg.json") -Raw -Encoding UTF8 | ConvertFrom-Json }
$body = [regex]::Replace($body, '(?m)^(\$LBL = @\{)(.+)(\}\s*)$', { param($x) $x.Groups[1].Value + [regex]::Replace($x.Groups[2].Value, "'(tr|en)\|([\w.]+)'='([^']*)'", { param($e) $v = $lab[$e.Groups[1].Value].($e.Groups[2].Value); if ($null -eq $v) { throw "label missing: $($e.Groups[2].Value)" }; if ($v -cne $e.Groups[3].Value) { $script:sync++ }; "'" + $e.Groups[1].Value + '|' + $e.Groups[2].Value + "'='" + $v + "'" }) + $x.Groups[3].Value })
foreach ($n in 'TK', 'TKN', 'LBL') { if ($body -notmatch "(?m)^\`$$n = @\{") { throw "no `$$n table in the body" } }
if ($sync) { [IO.File]::WriteAllText($src, $body, (New-Object Text.UTF8Encoding($true))) }
$out = $head.TrimEnd() + "`r`n`r`n" + $body
$out = ($out -replace "`r`n", "`n") -replace "`n", "`r`n"
[IO.File]::WriteAllText($bat, $out, (New-Object Text.UTF8Encoding($false)))

$check = [IO.File]::ReadAllText($bat, [Text.Encoding]::UTF8)
$i = $check.IndexOf("#>`r`n")
$tail = $check.Substring($i + 4).TrimStart([char]13, [char]10)
$norm = { param($s) ($s -replace "`r`n", "`n").Trim() }
"bat bytes  : " + (Get-Item $bat).Length
"body match : " + ((& $norm $tail) -eq (& $norm $body))
"tokens     : synced from teknesyum-ui ($sync changed)"
"sha256     : " + (Get-FileHash $bat -Algorithm SHA256).Hash
$e = $null
[void][System.Management.Automation.Language.Parser]::ParseFile($bat, [ref]$null, [ref]$e)
"parses     : " + ($e.Count -eq 0)
if ($e.Count) { $e | ForEach-Object { "  " + $_.Extent.StartLineNumber + ": " + $_.Message } }
