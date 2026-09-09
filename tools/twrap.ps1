. (Join-Path $PSScriptRoot '_load.ps1')
foreach($lang in 'tr','en'){
  Set-Lang $lang
  $script:M=''
  Write-Host ('123456789.'*6)
  foreach($k in 'scan.note','scan.ignhow','dx.what','dx.side','wsh.what','wsh.side','rq.nomanifest','dr.tip','cln.reboot'){ Wrap-T (S $k) 'Gray' }
}
