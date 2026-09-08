$sp = "$PSScriptRoot\usb-guard.ps1"
$bat = Join-Path (Split-Path $PSScriptRoot -Parent) 'USB-Guard.bat'
$bytes = [IO.File]::ReadAllBytes($sp)
$ms = New-Object IO.MemoryStream
$gz = New-Object IO.Compression.GzipStream($ms, [IO.Compression.CompressionMode]::Compress)
$gz.Write($bytes,0,$bytes.Length); $gz.Close()
$b64 = [Convert]::ToBase64String($ms.ToArray())
$c = [IO.File]::ReadAllText($bat)
$rx = "FromBase64String\('[^']+'\)"
if (-not [regex]::IsMatch($c,$rx)) { throw "pattern not found" }
$c2 = [regex]::Replace($c,$rx,"FromBase64String('$b64')")
[IO.File]::WriteAllText($bat,$c2,(New-Object Text.UTF8Encoding($false)))
"bat bytes: " + (Get-Item $bat).Length
$m = [regex]::Match($c2,"FromBase64String\('([^']+)'\)").Groups[1].Value
$gs = New-Object IO.Compression.GzipStream((New-Object IO.MemoryStream(,[Convert]::FromBase64String($m))),[IO.Compression.CompressionMode]::Decompress)
$o = New-Object IO.MemoryStream; $gs.CopyTo($o)
$h1 = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($o.ToArray()))
$h2 = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($bytes))
"roundtrip: " + ($h1 -eq $h2)
