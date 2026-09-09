$ErrorActionPreference='Continue'
. (Join-Path $PSScriptRoot '_load.ps1')
Set-Lang 'tr'
$sw=[Diagnostics.Stopwatch]::StartNew()
$f=@(Find-PcRemnants)
$sw.Stop()
"sure: {0:N1} sn, bulgu: {1}" -f $sw.Elapsed.TotalSeconds,$f.Count
$f | ForEach-Object { "  [{0}] {1}" -f $_.Type,$_.Desc }
