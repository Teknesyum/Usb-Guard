. ./tools/_load.ps1
$script:pcFound=@()
foreach($lang in @('tr','en')){
    Set-Lang $lang
    $items=Build-Items @()
    "--- $lang ---"
    for($i=0;$i -lt $items.Count;$i++){ "{0}  {1}  [{2}]" -f $i,$items[$i].Text,$items[$i].Action }
    $h=Help-For 'setupall'
    if(-not $h){ "FAIL: help.setall bos" }
    if($items[0].Action -ne 'setupall'){ "FAIL: ilk sira setupall degil" }
}
if(-not (Get-Command Setup-All -EA SilentlyContinue)){ "FAIL: Setup-All yok" } else { "Setup-All tanimli" }
