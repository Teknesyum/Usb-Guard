param([switch]$Static)
[Console]::OutputEncoding=[Text.Encoding]::UTF8
. (Join-Path $PSScriptRoot '_load.ps1')

$proj=Split-Path $PSScriptRoot -Parent
function Lum($h){
    $h=$h.TrimStart('#'); $c=@(0,2,4) | ForEach-Object { [Convert]::ToInt32($h.Substring($_,2),16)/255.0 }
    $l=$c | ForEach-Object { if($_ -le 0.03928){ $_/12.92 } else { [Math]::Pow(($_+0.055)/1.055,2.4) } }
    return 0.2126*$l[0]+0.7152*$l[1]+0.0722*$l[2]
}
function Ratio($a,$b){ $x=Lum $a; $y=Lum $b; return ([Math]::Max($x,$y)+0.05)/([Math]::Min($x,$y)+0.05) }
$names=[enum]::GetNames([ConsoleColor])
function Slot-Hex($n){ $i=[int][ConsoleColor]$n; return $TK[$TKMAP[$i]] }

$src=[IO.File]::ReadAllText((Join-Path $proj 'src\usb-guard.ps1'))
$used=@([regex]::Matches($src,"(?:-ForegroundColor|-BackgroundColor)\s+'?(\w+)|'(\w+)'\)?\s*(?:$|;|\})|\) '(\w+)'|\s'(Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White)'") | ForEach-Object { $g=$_.Groups; @($g[1].Value,$g[2].Value,$g[3].Value,$g[4].Value) } | Where-Object { $names -contains $_ }) + @($ACC,$ACC2,$SUPC) | Select-Object -Unique

$rows=@()
foreach($n in $used){
    if($n -eq 'Black'){ continue }
    $i=[int][ConsoleColor]$n
    $mapped=$TKMAP.ContainsKey($i)
    $r=if($mapped){ Ratio (Slot-Hex $n) $TK['surface'] } else { 0 }
    $rows+=[pscustomobject]@{Oge="$n on Black";Token=$(if($mapped){ $TKMAP[$i] } else { '-' });Oran=[Math]::Round($r,2);OK=($mapped -and $r -ge 7)}
}
$sel=Ratio (Slot-Hex 'Black') (Slot-Hex $ACC)
$rows+=[pscustomobject]@{Oge="Black on $ACC (secili satir)";Token="surface / $($TKMAP[[int][ConsoleColor]$ACC])";Oran=[Math]::Round($sel,2);OK=($sel -ge 7)}
$rows | Format-Table -AutoSize | Out-String -Width 120

if($Static){ $bad=@($rows | ? { -not $_.OK }).Count; if($bad){ throw "$bad colour(s) fail" }; 'static OK'; return }
$out=Join-Path $proj 'tmp\tui-table.txt'
[IO.Directory]::CreateDirectory((Split-Path $out)) | Out-Null
Remove-Item -LiteralPath $out -EA SilentlyContinue
$probe=Join-Path $proj 'tmp\tui-probe.ps1'
Set-Content -LiteralPath $probe -Encoding UTF8 -Value @"
. '$PSScriptRoot\_load.ps1'
`$before=[Win32p]::Get
Set-Palette
`$t=[Win32p]::Get()
(`$t | ForEach-Object { '{0:X6}' -f `$_ }) -join ' ' | Set-Content '$out'
Restore-Palette
`$b=[Win32p]::Get()
'restored ' + ((`$b | ForEach-Object { '{0:X6}' -f `$_ }) -join ' ' -eq ((`$script:palOld | ForEach-Object { '{0:X6}' -f `$_ }) -join ' ')) | Add-Content '$out'
"@
Start-Process conhost.exe -ArgumentList "powershell -NoProfile -ExecutionPolicy Bypass -File `"$probe`"" -Wait
$got=@(Get-Content -LiteralPath $out -EA SilentlyContinue)
$tbl=if($got.Count){ $got[0] -split ' ' } else { @() }
$applied=$true
foreach($k in $TKMAP.Keys){ $want='{0:X6}' -f (Hex-Ref $TK[$TKMAP[$k]]); if($tbl.Count -lt 16 -or $tbl[[int]$k] -ne $want){ $applied=$false } }

"--- kontrol ---"
$chk=@(
  @('her renk token a bagli',    (@($rows | Where-Object { $_.Token -eq '-' }).Count -eq 0)),
  @('her oran >= 7:1',           (@($rows | Where-Object { -not $_.OK }).Count -eq 0)),
  @('tablo conhost ta uygulandi', $applied),
  @('cikista geri yuklendi',     ($got -contains 'restored True'))
)
foreach($c in $chk){ "{0,-4} {1}" -f $(if($c[1]){'OK'}else{'FAIL'}),$c[0] }
