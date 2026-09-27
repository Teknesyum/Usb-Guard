param([string]$Tag='sonra',[string]$Only='',[int[]]$Scale=@(100,125,150),[string]$Day=(Get-Date -Format 'yyyy-MM-dd'))
$proj=Split-Path $PSScriptRoot -Parent
$dir=Join-Path $proj "docs\ui-denetim\$Day"
[IO.Directory]::CreateDirectory($dir) | Out-Null
$tmp=Join-Path $proj 'tmp'; [IO.Directory]::CreateDirectory($tmp) | Out-Null
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;using System.Runtime.InteropServices;
public class Cap{
 [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr h, IntPtr dc, uint f);
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
 [DllImport("user32.dll",CharSet=CharSet.Unicode)] public static extern IntPtr FindWindow(string c, string t);
 public struct RECT{public int L,T,R,B;}
}
'@
$font=@'
Add-Type -TypeDefinition 'using System;using System.Runtime.InteropServices;public class CF{[StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)]public struct F{public int cb;public int n;public short x;public short y;public int fam;public int w;[MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)]public string face;}[DllImport("kernel32.dll")]public static extern IntPtr GetStdHandle(int h);[DllImport("kernel32.dll",CharSet=CharSet.Unicode)]public static extern bool SetCurrentConsoleFontEx(IntPtr h,bool m,ref F f);public static void Set(short y){var f=new F();f.cb=Marshal.SizeOf(f);f.y=y;f.fam=54;f.w=400;f.face="Consolas";SetCurrentConsoleFontEx(GetStdHandle(-11),false,ref f);}}'
'@
$pre=". '$proj\tools\_load.ps1'; Set-Palette; Fit-Window; "
$screens=[ordered]@{
 '01-dil'='Choose-Lang'
 '02-ana-menu'='do{ Clear-Host; Print-Banner; $script:usbBus=Get-UsbLogical; $d=@(Get-CimInstance Win32_LogicalDisk -Filter ''DriveType=2 OR DriveType=3'' | ? { Eligible $_ }); Print-Status $d; $g=Menu-Loop (Build-Items $d) ''exit'' (S ''mn.exit'') }while($g.Action -eq ''redraw''); Start-Sleep 99'
 '03-gelismis'='do{ Clear-Host; Print-Banner; $d=@(); $a=Test-WatcherTask; $b=Test-Wsh; $c=Test-DenyExec; Print-AdvStatus $a $b $c; $g=Menu-Loop (Build-AdvItems $d $a $b $c $false) ''back'' (S ''mn.backword'') ''back'' }while($g.Action -eq ''redraw''); Start-Sleep 99'
 '04-yardim'='$d=@(); $it=@(Build-Items $d) | ? { $_.Action -ne ''sep'' } | select -First 1; Show-Help $it'
 '05-tarama'='Clear-Host; Print-Banner; Scan-Pc; Pause-Key'
 '06-karantina-bos'='Clear-Host; Print-Banner; T (S ''rq.empty'') ''DarkYellow''; Pause-Key'
 '07-hata-sistem'='Clear-Host; Print-Banner; T (S ''dr.sysdrive'') ''Red''; Pause-Key'
 '08-hata-yok'='Clear-Host; Print-Banner; T (SF ''dr.notfound'' ''Q:'') ''Red''; Pause-Key'
 '09-cikis'='Clear-Host; Print-Banner; Show-Footer; Pause-Key'
 '10-kurulum'='$script:dl=''' + (Join-Path $proj 'USB-Guard.bat') + '''; function Get-BatSource { return $script:dl }; Clear-Host; Print-Banner; Install-Watcher; Pause-Key'
 '11-uyari'='Add-Type -AssemblyName System.Windows.Forms; $m=(S ''wat.popup'') -f ''E:''; if(Get-Command Show-GuardPop -EA 0){ [void](Show-GuardPop $m) } else { [void][System.Windows.Forms.MessageBox]::Show($m,''Usb-Guard'',''YesNo'',''Warning'') }'
}
$wait=@{ '05-tarama'=150; '03-gelismis'=20; '02-ana-menu'=10; '10-kurulum'=30 }
foreach($s in $Scale){
 $px=[int][Math]::Round(20*$s/100)
 foreach($k in @($screens.Keys | ? { -not $Only -or $_ -like $Only })){
  $title="UGCAP$s$k"
  $f=Join-Path $tmp "cap-$k.ps1"
  Set-Content -LiteralPath $f -Encoding UTF8 -Value ($font+"`r`n"+$pre+"[void][Win32c]::SetFont('Consolas',$px); `$fw=`${function:Fit-Window}; function Fit-Window(`$rows=36){ & `$fw `$rows; [void][Win32c]::SetFont('Consolas',$px) }; [Console]::Title='$title'; "+$screens[$k])
  $p=Start-Process conhost.exe -ArgumentList "powershell -NoProfile -ExecutionPolicy Bypass -File `"$f`"" -PassThru
  $t=if($wait[$k]){$wait[$k]}else{6}; Start-Sleep $t
  $h=[IntPtr]::Zero
  for($i=0;$i -lt 20 -and $h -eq [IntPtr]::Zero;$i++){ if($k -eq '11-uyari'){ $h=[Cap]::FindWindow([NullString]::Value,'Usb-Guard'); if($h -ne [IntPtr]::Zero){ break } }; $w=Get-Process powershell | ? MainWindowTitle -eq $title | select -First 1; if($w){ $h=$w.MainWindowHandle } else { Start-Sleep -m 300 } }
  if($h -eq [IntPtr]::Zero){ "$k-$s : pencere yok"; continue }
  $r=New-Object Cap+RECT; [void][Cap]::GetWindowRect($h,[ref]$r)
  $bmp=New-Object Drawing.Bitmap ($r.R-$r.L),($r.B-$r.T); $g=[Drawing.Graphics]::FromImage($bmp); $dc=$g.GetHdc()
  [void][Cap]::PrintWindow($h,$dc,2); $g.ReleaseHdc($dc); $g.Dispose()
  $bmp.Save((Join-Path $dir "$k-$s-$Tag.png"),[Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
  Get-Process powershell | ? MainWindowTitle -eq $title | Stop-Process -Force; if($k -eq '11-uyari'){ Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" | ? CommandLine -match 'cap-11-uyari' | % { Stop-Process -Id $_.ProcessId -Force -EA SilentlyContinue } }
  "$k-$s : $($r.R-$r.L)x$($r.B-$r.T)"
 }
}
Remove-Item -LiteralPath (Join-Path $tmp 'cap-*.ps1') -EA SilentlyContinue
