# 002 — Solucan Araştırması ve PC Kontrolü (Fable)

Tarih: 2026-09-08 · Model: claude-fable-5-1 · Maliyet: ~35k token, 2 web arama, 2 sayfa çekimi, 2 salt-okunur PC komutu


## Flaştaki solucanın kimliği

USB'de `sysvolume` + etiket adlı gizli klasör + `USB Drive.lnk` deseni, AhnLab ASEC'in
belgelediği **PrintMiner / CoinMiner USB kampanyası** ile birebir örtüşüyor.

Kaynaklar:
- https://asec.ahnlab.com/en/91415/
- https://securityonline.info/stealth-cryptominer-uses-usb-lnk-and-dll-side-loading-to-deploy-smart-mining-evasion/
- https://www.microsoft.com/en-us/wdsi/threats/malware-encyclopedia-description?Name=Worm:VBS/Jenxcus!lnk
- https://unit42.paloaltonetworks.com/plugx-variants-in-usbs/
- https://www.microsoft.com/en-us/security/blog/2026/06/17/crypto-clipper-uses-tor-worm-like-propagation-for-persistence-control/


## ASEC sayfasından dönen olgular (aynen)

USB tarafı:
- Gizli `sysvolume\` içinde `u######.vbs` (örn. `u566387.vbs`) ve `u######.bat` (örn. `u643257.bat`).
- Kullanıcı dosyaları `sysvolume\<Etiket>\` altına taşınır; görünürde tek `<Etiket>.lnk` kalır.
- lnk → vbs → bat zinciri; bat gerçek klasörü açar, kullanıcı fark etmez.

PC tarafı (Usb-Guard v1.4 bunların hiçbirine bakmıyor):
- `%SystemRoot%\System32\svcinsty64.exe`, `svctrl64.exe` (dropper)
- `%SystemRoot%\System32\u######.dll` — **DcomLaunch servisine ServiceDll olarak kaydedilir**
- `%SystemRoot%\System32\wsvcz\wlogz.dat` (yapılandırma) ve `wsvcz\` altında XMRig
- `C:\Windows \System32\` (Windows'tan sonra boşluk) içinde `printui.exe` + sahte `printui.dll` (DLL side-loading)
- Windows Defender dışlama listesine kendi yolunu ekler (PowerShell ile)
- XMRig; Taskmgr / ProcessHacker / oyun açıkken madenciliği durdurur


## Bu PC'de kontrol (salt okunur, 2026-09-08)

```
svcinsty64.exe : False
svctrl64.exe : False
svctrl64.dll : False
wsvcz\wlogz.dat : False
space-folder: False
u######.dll in System32: (yok)
DcomLaunch ServiceDll: C:\Windows\system32\rpcss.dll   (doğru, orijinal)
Defender exclusions Paths/Processes/Extensions: (boş)
xmrig/svctrl/svcinsty/printui süreçleri: (yok)
wscript/cscript süreçleri: (yok)
Zamanlanmış görevler: yalnız Windows yerleşikleri (CleanupTemporaryState, Automatic-Device-Join, Recovery-Check)
```

Sonuç: **PC temiz.** Flaş enfekte olmuş ama solucan bu makineye geçmemiş (lnk'ye tıklanmamış
ya da AV kesmiş).
