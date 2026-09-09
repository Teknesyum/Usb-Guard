[Console]::OutputEncoding=[Text.Encoding]::UTF8
. (Join-Path $PSScriptRoot '_load.ps1')

$R=Join-Path $env:TEMP 'uglabel'
Remove-Item -LiteralPath $R -Recurse -Force -EA SilentlyContinue
New-Item -ItemType Directory -Path $R -Force | Out-Null
$R=(Get-Item -LiteralPath $R).FullName

function Case($name,$text,$expect){
    $p=Join-Path $R 'autorun.inf'
    Remove-Item -LiteralPath $p -Recurse -Force -EA SilentlyContinue
    if($null -ne $text){ [IO.File]::WriteAllText($p,$text) }
    $got=Read-ArLabel ($R+'\')
    $ok=$(if($got -eq $expect){'OK  '}else{'FAIL'})
    '{0} {1,-28} => "{2}"' -f $ok,$name,$got
}

'--- Read-ArLabel ---'
Case 'duz'            "[autorun]`r`nlabel=Mustafa Ozel`r`nicon=x.ico`r`n"  'Mustafa Ozel'
Case 'bosluklu'       "[autorun]`r`n  LABEL  =   Ders Notlari   `r`n"      'Ders Notlari'
Case 'tirnakli'       "[autorun]`r`nlabel=`"Yedek Disk`"`r`n"              'Yedek Disk'
Case 'label yok'      "[autorun]`r`nopen=worm.exe`r`n"                     ''
Case 'dosya yok'      $null                                               ''
Case 'cmd metakarakter' "[autorun]`r`nlabel=A&calc.exe^%x!`r`n"            'Acalcexex'
Case 'yol karakteri'  "[autorun]`r`nlabel=..\..\x:y|z`r`n"                 'xyz'

'--- Clean-VolLabel (FAT32 11 kr) ---'
foreach($t in @('Mustafa Ozel','Cok Uzun Bir Etiket Adi','   ','A.B*C?D')){
    $g=Clean-VolLabel $t 11
    '  "{0,-24}" => "{1}" ({2})' -f $t,$g,$g.Length
}

'--- klasor autorun.inf (bagisiklik sonrasi) ---'
Remove-Item -LiteralPath (Join-Path $R 'autorun.inf') -Recurse -Force -EA SilentlyContinue
New-Item -ItemType Directory -Path (Join-Path $R 'autorun.inf') -Force | Out-Null
$g=Read-ArLabel ($R+'\')
'{0} klasor okunmadi           => "{1}"' -f $(if($g -eq ''){'OK  '}else{'FAIL'}),$g

Remove-Item -LiteralPath $R -Recurse -Force -EA SilentlyContinue
