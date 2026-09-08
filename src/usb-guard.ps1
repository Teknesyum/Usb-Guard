param([switch]$Watch,[string]$Drive,[switch]$Bg)
$ErrorActionPreference = 'SilentlyContinue'
try{ [Console]::OutputEncoding = [Text.Encoding]::UTF8 }catch{}
$VER = '1.17'
$ACC = 'Cyan'
$ACC2 = 'Magenta'
$W = 60
$script:M = ''
$script:bol = $true
$repo = 'Teknesyum/Usb-Guard'
$script:upd = $null
$script:def = ''
$script:bgJob = $null
$script:scanned = $false
$script:pcFound = @()
$script:usbBus = @()
$dxKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\RemovableStorageDevices\{53f5630d-b6bf-11d0-94f2-00a0c91efb8b}'
$dblRx = '(?i)\.(jpe?g|png|gif|bmp|pdf|docx?|xlsx?|pptx?|txt|mp[34]|avi|mkv|zip|rar)\.(exe|scr|pif|com)$'
$reserved = 'con..'
$fixed = @('sysvolume','autorun.inf','recycler','recycled')
$base = Join-Path $env:ProgramData 'Usb-Guard'
$oldBase = Join-Path $env:LOCALAPPDATA 'Usb-Guard'
$psInstalled = Join-Path $base 'usb-guard.ps1'
$batInstalled = Join-Path $base 'USB-Guard.bat'
$ignFile = Join-Path $base 'ignore.txt'
$batName = 'USB-Guard.bat'
$runName = 'UsbGuard'
$taskName = 'UsbGuard'
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$wshKey = 'HKLM:\Software\Microsoft\Windows Script Host\Settings'
$sysDir = [Environment]::SystemDirectory
$spaceDir = Join-Path $env:SystemDrive 'Windows \System32'
$knownNames = '(?i)\b(xmrig|svctrl64|svcinsty64|wsvcz|ugate)\b'
$susRx = '(?i)\.(vbs|vbe|js|jse|wsf|hta|bat|cmd)\b|\b(wscript|cscript|mshta)(\.exe)?\b|rundll32[^"]*\\(AppData|ProgramData|Temp)\\|powershell[^"]*(-e(c|nc|ncodedcommand)?\s|-w(indowstyle)? ?hidden)|powershell[^"]*bypass[^"]*\\(Temp|AppData|ProgramData|Public)\\|\\Temp\\[^"]*\.exe|\\Users\\Public\\[^"]*\.exe|sysvolume|\\Windows \\|wsvcz|\\u\d{6}\.(dll|dat)|\b(xmrig|svctrl64|svcinsty64)\b'
$scriptExt = '(?i)\.(vbs|vbe|js|jse|wsf|hta|bat|cmd)$'
$payloadExt = '(?i)\.(vbs|vbe|js|jse|wsf|hta|bat|cmd|scr|pif|com|url|scf)$'
$codeRx = '(?i)CreateObject|ActiveXObject|WScript\.|<script|On Error Resume Next|ShellExecute|powershell'
$dataExt = '(?i)^(|\.(jpe?g|png|gif|bmp|webp|tiff?|pdf|docx?|xlsx?|pptx?|txt|rtf|csv|log|dat|bin|ini|cfg|swy|chk|usb|ico|tmp|xml|json|db|mp[34]|avi|mkv|zip|rar|7z))$'
$rtlRx = '[\u200B-\u200F\u202A-\u202E\u2066-\u2069]'
$containerRx = '(?i)^(_|\s+|[^\w]{1,3}|recycle\.?bin|\$?recycle[rd]?(\.bin)?\.?|_recycle|sysvolume|.*\.\{[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}\})$'
$cloakClsid = '(?i)\{(645FF040-5081-101B-9F08-00AA002F954E|20D04FE0-3AEA-1069-A2D8-08002B30309D|21EC2020-3AEA-1069-A2DD-08002B30309D|2559A1F[0-7]-21D7-11D4-BDAF-00C04F60B9F0|ED7BA470-8E54-465E-825C-99712043E01C)\}'
$sysNameRx = '(?i)^(\$[IR][A-Z0-9]{6}(\..*)?|desktop\.ini|IndexerVolumeGuid|WPSettings\.dat|tracking\.log|ClientRecoveryPasswordRotation|AadRecoveryPasswordDelete|ChkDskDiag\.txt|MountPointManagerRemoteDatabase|\{[0-9a-f-]{36}\}(\{[0-9a-f-]{36}\})?|.*\.(tmp|blf|regtrans-ms))$'
$lnkRx = '(?i)sysvolume|\.(vbs|vbe|js|jse|wsf|bat|cmd|hta|ps1)\b|wscript|cscript|mshta|powershell|rundll32|cmd(\.exe)?\s|/c\s|/r\s|%comspec%|%windir%|%systemroot%|conhost|msiexec|regsvr32|certutil|bitsadmin|forfiles|wmic|explorer(\.exe)?\s+[^"]*\\'
$keepDirs = @('System Volume Information','$RECYCLE.BIN')
$script:pcFound = @()

$langFile = Join-Path $base 'lang.txt'
$script:LANG = 'tr'
$script:STR = $null
$script:wSt = 9
$script:wAdv = 18
$script:wDrv = 6

$STRTR = @{
 'ban.tag'      = "Düzelt * Kilitle * Koru   v{0}"
 'pk.enter'     = "Devam İçin Enter..."
 'sp.ok'        = "Ok"
 'sp.already'   = "Zaten"

 'dr.target'    = "Hedef"
 'dr.label'     = "Etiket"
 'dr.fs'        = "Fs"
 'dr.status'    = "Durum"
 'dr.infected'  = "Solucan İzi Var"
 'dr.guarded'   = "Zaten Korumalı"
 'dr.partial'   = "Kısmen Korumalı"
 'dr.unprot'    = "Korumasız"
 'dr.nothing'   = "  Zaten Korumalı, İşlem Gerekmiyor."
 'dr.hcleanup'  = "  [ Temizlik ]"
 'dr.sstop'     = "Çalışan Solucanı Durdur"
 'dr.slnk'      = "Zararlı Kısayollar ({0})"
 'dr.spayload'  = "Yük Dosyalarını Karantinaya Al ({0})"
 'dr.sunhide'   = "Gizlenmiş Dosyaları Geri Aç ({0})"
 'dr.srestore'  = "Gizlenen Dosyaları Geri Taşı"
 'dr.ssys'      = "Sysvolume Yükünü Kaldır"
 'dr.hvisible'  = "  [ Görünürlük ]"
 'dr.sshow'     = "Dosyaları Görünür Yap"
 'dr.himmune'   = "  [ Bağışıklık ]"
 'dr.slock'     = "Kilitle: {0}"
 'dr.noacl'     = "  Not: {0}, ACL Kilidi Yok; Ayrılmış-İsim Klasörü Korur."
 'dr.done'      = "  {0} Tamamlandı."
 'dr.quar'      = "  Karantina: {0}"
 'dr.tip'       = "  Öneri: Menüden ""Bu PC'yi Tara"" ile bilgisayarı da kontrol et."
 'dr.sysdrive'  = "  Sistem Sürücüsü İşlenmez."
 'dr.notfound'  = "  {0} Bulunamadı."

 'cp.hc'        = "  [ C: Köküne Kur ]"
 'cp.husb'      = "  [ USB Köküne Kur ]"
 'cp.nosrc'     = "  Kaynak Bulunamadı."
 'cp.scopy'     = "Kopyala"
 'cp.scopyto'   = "Kopyala -> {0}"
 'cp.created'   = "  {0} Oluşturuldu."
 'cp.done'      = "  Tamamlandı."
 'dr.askcopy'   = "  USB-Guard'ı bu USB'ye de kopyalayayım mı? (E/H): "
 'dr.copywhy'   = "  Böylece virüslü başka bir bilgisayarda da çift tıkla çalışır."
 'dr.copied'    = "  Kopyalandı: {0}"
 'dr.nocopy'    = "  Kopyalanmadı."

 'fnd.ushell'   = "Kullanıcı Shell = {0}"
 'fnd.startup'  = "Başlangıç: {0}"
 'fnd.task'     = "Görev: {0}"
 'fnd.svc'      = "Servis: {0}"
 'fnd.wsvcz'    = "System32\wsvcz (madenci klasörü)"
 'fnd.fakedir'  = """C:\Windows \System32"" (sahte klasör)"
 'fnd.script'   = "Betik: {0}"
 'fnd.excl'     = "Defender Dışlama: {0}"
 'fnd.startredir' = "Başlangıç Klasörü Yönlendirilmiş: {0}"
 'fnd.sideload' = "Yandan Yüklenen DLL: {0}"
 'fnd.setting'  = "Ayar: {0}"
 'fnd.showall'  = "Ayar: Gizli Dosyaları Göster Bozulmuş"
 'fnd.taskmgr'  = "Görev Yöneticisi Kapalı"
 'fnd.regedit'  = "Kayıt Defteri Kapalı"
 'fnd.cmd'      = "Komut İstemi Kapalı"
 'fnd.folderop' = "Klasör Seçenekleri Kapalı"
 'fnd.norun'    = "Çalıştır Kapalı"
 'fnd.nodrives' = "Sürücüler Gizli"
 'fnd.noview'   = "Sürücü Erişimi Kapalı"
 'fnd.taskmgrm' = "Görev Yöneticisi Kapalı (HKLM)"
 'fnd.regeditm' = "Kayıt Defteri Kapalı (HKLM)"

 'cln.stop'     = "Durdur: {0}"
 'cln.svcdel'   = "Servis Kaldır: {0}"
 'cln.svcfix'   = "Servis DLL Onar: {0}"
 'cln.regfix'   = "Kayıt Onar: {0}"
 'cln.regdel'   = "Kayıt Sil: {0}"
 'cln.taskdel'  = "Görev Sil: {0}"
 'cln.exclrm'   = "Dışlama Kaldır"
 'cln.exclman'  = "    Elle kaldır: Windows Güvenlik > Virüs > Dışlamalar > {0}"
 'cln.polfix'   = "Ayar Onar: {0}"
 'cln.quar'     = "Karantina: {0}"
 'cln.nomove'   = "    Taşınamadı: {0}"
 'cln.done'     = "  Tamamlandı. Karantina: {0}"
 'cln.reboot'   = "  Bazı dosyalar kilitli; yeniden başlatınca taşınacak."

 'scan.head'    = "  [ Bu PC - Solucan Kalıntıları ]"
 'scan.spin'    = "Süreçler, Kayıtlar, Görevler, Servisler"
 'scan.clean'   = "  Temiz. Bu PC'de solucan kalıntısı bulunamadı."
 'scan.note1'   = "  Not: Bu tarama yüzeyseldir. Yalnız solucanların kullandığı başlangıç"
 'scan.note2'   = "  noktalarına bakar (süreçler, Run kayıtları, görevler, servisler, başlangıç"
 'scan.note3'   = "  klasörleri). Tam bir virüs taraması değildir; antivirüsünün yerini tutmaz."
 'scan.found'   = "  {0} şüpheli kalıntı bulundu:"
 'scan.found1'  = "  1 şüpheli kalıntı bulundu:"
 'scan.ignored' = "  {0} bulgu yoksayıldı. Bir daha listelenmeyecek."
 'scan.nothing' = "  Temizlenecek bir şey kalmadı."
 'scan.ignhow'  = "  Silmesini istemediğin varsa numarasını yaz; o bulgu bir daha çıkmaz."
 'scan.ask'     = "  E = hepsini temizle,  numara = yoksay (örn 1,3),  H = vazgeç: "
 'scan.cancel'  = "  İptal edildi. Hiçbir şey değiştirilmedi."
 'scan.left'    = "  Kalan: {0} (tekrar tara)"

 'dx.hoff'      = "  [ USB'den Çalıştırmayı Kapat ]"
 'dx.hon'       = "  [ USB'den Çalıştırmayı Aç ]"
 'dx.what'      = "  Çıkarılabilir disklerden .exe açılmaz; klasör-ikonlu sahte .exe çalışamaz."
 'dx.side'      = "  Yan etki: USB'den kurulum / taşınabilir program çalıştıramazsın."
 'dx.swrite'    = "Deny_Execute İlkesi Yaz"
 'dx.sclear'    = "Deny_Execute İlkesi Kaldır"
 'dx.offdone'   = "  Kapatıldı. Oturumu kapatıp açınca tam etkin olur."
 'dx.ondone'    = "  Açıldı. USB'den .exe yeniden çalışır."

 'wsh.hon'      = "  [ Betik Motorunu Aç ]"
 'wsh.hoff'     = "  [ Betik Motorunu Kapat ]"
 'wsh.what'     = "  Kısayol solucanları wscript.exe ile çalışır; bu ayar onu keser."
 'wsh.side'     = "  Yan etki: meşru .vbs / .js betikleri de çalışmaz. Menüden geri açılır."
 'wsh.son'      = "Windows Script Host Aç"
 'wsh.soff'     = "Windows Script Host Kapat"
 'wsh.ondone'   = "  Açıldı. .vbs / .js betikleri yeniden çalışır."
 'wsh.offdone'  = "  Kapatıldı. Bu PC'de .vbs / .js artık çalışmaz."

 'wat.hinst'    = "  [ Otomatik İzleme Kurulumu ]"
 'wat.hrem'     = "  [ Otomatik İzlemeyi Kaldır ]"
 'wat.scopy'    = "Dosyaları Kopyala"
 'wat.srun'     = "Zamanlanmış Görev"
 'wat.sstart'   = "İzleyiciyi Başlat"
 'wat.sdel'     = "Görevi Sil"
 'wat.sstop'    = "İzleyiciyi Durdur"
 'wat.done'     = "  Kuruldu. Bu bilgisayardaki her hesapta çalışır; virüslü USB"
 'wat.done2'    = "  takılınca ""Temizleyeyim mi?"" diye sorar."
 'wat.failed'   = "  Görev kurulamadı. Yönetici olarak çalıştırdığından emin ol."
 'wat.removed'  = "  Kaldırıldı. (Aşılanmış USB'ler Kilitli Kalır.)"
 'wat.popup'    = "Virüslü USB algılandı: {0}`n`nTemizleyip aşılayayım mı?"

 'st.ver'       = "Sürüm"
 'st.pc'        = "Bu PC"
 'st.av'        = "Antivirüs"
 'st.uptodate'  = "Güncel"
 'st.newver'    = "v{0} Var - github.com/{1}"
 'st.upderr'    = "Denetlenemedi"
 'st.checking'  = "Denetleniyor..."
 'st.scanning'  = "Taranıyor..."
 'st.pcclean'   = "Temiz"
 'st.pcdirty'   = "{0} Kalıntı - Temizlik Önerilir"
 'st.pcdirty1'  = "1 Kalıntı - Temizlik Önerilir"
 'st.avon'      = "Koruma Açık"
 'st.avoff'     = "Koruma Kapalı"
 'st.avna'      = "Bilinmiyor"
 'st.nousb'     = "  Şu An Guard Edilebilir USB Yok."
 'st.usblist'   = "  Uygun USB'ler:"
 'st.nolabel'   = "(Etiketsiz)"
 'st.wormtrace' = "Solucan İzi"
 'st.guarded'   = "Korumalı"
 'st.partial'   = "Kısmen Korumalı"
 'st.unprot'    = "Korumasız"
 'st.updating'  = "  Yeni sürüm v{0} indirildi, yeniden başlatılıyor..."

 'adv.head'     = "  [ Gelişmiş Seçenekler ]"
 'adv.watcher'  = "İzleyici"
 'adv.wsh'      = "Betik Motoru"
 'adv.dx'       = "USB'den Çalıştırma"
 'adv.lang'     = "Dil"
 'adv.ign'      = "Yoksayılan"
 'adv.on'       = "Açık"
 'adv.off'      = "Kapalı"
 'adv.wshon'    = "Açık  (.vbs / .js çalışır)"
 'adv.wshoff'   = "Kapalı  (solucan betikleri çalışamaz)"
 'adv.dxoff'    = "Kapalı  (USB'deki .exe açılmaz)"
 'adv.dxon'     = "Açık"

 'mn.cleanpc'   = "Bu PC'yi Temizle  (Önerilen)"
 'mn.fixall'    = "Tümünü Düzelt"
 'mn.fix'       = "Düzelt  ->  {0} {1}"
 'mn.scanpc'    = "Bu PC'yi Tara"
 'mn.copyc'     = "USB-Guard'ı C:'ye Kur"
 'mn.copyusb1'  = "USB-Guard'ı USB'ye Kur  ->  {0} {1}"
 'mn.copyusbn'  = "USB-Guard'ı USB'ye Kur..."
 'mn.adv'       = "Gelişmiş Seçenekler  >"
 'mn.exit'      = "Çıkış"
 'mn.back'      = "<  Geri"
 'mn.backword'  = "Geri"
 'mn.watinst'   = "İzleyici Kur"
 'mn.watrem'    = "İzleyiciyi Kaldır"
 'mn.wshoff'    = "Betik Motorunu Kapat  (.vbs / .js)"
 'mn.wshon'     = "Betik Motorunu Aç  (.vbs / .js)"
 'mn.dxoff'     = "USB'den Çalıştırmayı Kapat  (.exe)"
 'mn.dxon'      = "USB'den Çalıştırmayı Aç  (.exe)"
 'mn.ignclear'  = "Yoksayma Listesini Temizle ({0})"
 'mn.restoreq'  = "Karantinadan Geri Al"
 'mn.lang'      = "Dil / Language  >"

 'hint.main'    = "  Yön: Ok   Seç: Enter   Bilgi: Sağ Ok   GitHub: G   {0}: Esc"
 'hint.sub'     = "  Yön: Ok   Seç: Enter   Bilgi: Sağ Ok   Geri: Sol Ok / Esc"

 'pick.usb'     = "USB-Guard'ı hangi USB'ye kurayım?"
 'pick.allusb'  = "TÜM USB'LER"
 'pick.quar'    = "Hangi karantinayı geri alayım?"

 'rq.head'      = "  [ Karantinadan Geri Al ]"
 'rq.empty'     = "  Karantina boş."
 'rq.items'     = "{0}   ({1} öğe)"
 'rq.ask'       = "  Dosyalar alındıkları yere geri taşınsın mı? (E/H): "
 'rq.cancel'    = "  İptal edildi."
 'rq.nomanifest'= "  Bu karantinanın kayıt dosyası yok (eski sürüm); dosyaları elle taşı."
 'rq.done'      = "  {0} öğe geri taşındı."

 'help.scanpc'  = "Bu bilgisayarı solucan kalıntısı için tarar: çalışan`nbetik süreçleri, Run/RunOnce, Winlogon, başlangıç`nklasörleri, görevler, servisler, Defender dışlamaları,`nExplorer sabotajı. Bulunanlar listelenir; onay verirsen`nkayıtlar silinir, dosyalar karantinaya taşınır.`nYüzeysel bir taramadır, tam virüs taraması değildir."
 'help.fixall'  = "Listedeki tüm USB'leri sırayla temizler ve aşılar."
 'help.fix'     = "Seçili USB'yi temizler ve aşılar: solucan sürecini`ndurdurur, zararlı kısayolları siler (alt klasörler dahil),`ngizlenen dosyalarını köke geri taşır, yükü karantinaya`nalır, ardından solucanın kullandığı adları kilitli`nklasörlerle işgal eder. Dosyaların silinmez; çakışan ad`n' (2)' eki alır."
 'help.adv'     = "İzleyici, betik motoru, USB'den çalıştırma anahtarı,`ndil seçimi ve karantinadan geri alma."
 'help.back'    = "Ana menüye döner."
 'help.install' = "Arka planda küçük bir izleyici kurar (HKCU Run).`nVirüslü USB takıldığında Evet/Hayır sorusuyla temizlemeyi`nönerir. Tıklamadan hiçbir şey yapmaz."
 'help.uninst'  = "Arka plan izleyicisini ve Run kaydını kaldırır."
 'help.wshoff'  = "Windows Script Host'u kapatır (tek kayıt değeri).`n.vbs / .js solucanları wscript.exe ile çalışır; kapalıyken`nkısayola tıklansa bile yük çalışmaz.`nYan etki: meşru .vbs / .js betikleri de durur (bazı yazıcı`nkurulumları, kurumsal logon betikleri, eski kurulum`nsihirbazları). Aynı menüden geri açılır."
 'help.wshon'   = "Windows Script Host'u yeniden açar; .vbs / .js betikleri`ntekrar çalışır."
 'help.dxoff'   = "Windows ilkesi: çıkarılabilir disklerden .exe çalıştırmayı`nyasaklar (Removable Disks: Deny execute access).`nKlasör-ikonlu sahte .exe solucanları açılamaz.`nYan etki: USB'den kurulum ya da taşınabilir program`nçalıştıramazsın; önce C:'ye kopyalaman gerekir.`nOturumu kapatıp açınca tam etkin olur."
 'help.dxon'    = "USB'den .exe çalıştırma yasağını kaldırır."
 'help.ignclear'= "Taramada yoksay dediğin bulguların listesini siler.`nSonraki taramada hepsi yeniden listelenir."
 'help.restoreq'= "Karantina klasörlerinden birini seçer, içindeki dosyaları`nalındıkları yere geri taşır. Yanlış pozitif için."
 'help.copyc'   = "USB-Guard.bat'ı C: köküne ve C:\ProgramData\Usb-Guard`naltına kurar; izleyici ve hızlı erişim için."
 'help.copyusb' = "USB-Guard.bat'ı seçtiğin USB'nin köküne kurar; başka`nbilgisayarda da çalıştırabilirsin. Birden fazla USB varsa`nhangisi olduğunu adıyla seçersin."
 'help.exit'    = "Programı kapatır."
 'help.lang'    = "Arayüz dilini değiştirir: İngilizce ya da Türkçe.`nSeçim kaydedilir, sonraki açılışta sorulmaz."
 'help.none'    = "Açıklama yok."
}

$STREN = @{
 'ban.tag'      = "Fix * Lock * Guard   v{0}"
 'pk.enter'     = "Press Enter To Continue..."
 'sp.ok'        = "Ok"
 'sp.already'   = "Already"

 'dr.target'    = "Target"
 'dr.label'     = "Label"
 'dr.fs'        = "Fs"
 'dr.status'    = "Status"
 'dr.infected'  = "Worm Traces Found"
 'dr.guarded'   = "Already Guarded"
 'dr.partial'   = "Partially Guarded"
 'dr.unprot'    = "Not Guarded"
 'dr.nothing'   = "  Already Guarded, Nothing To Do."
 'dr.hcleanup'  = "  [ Cleanup ]"
 'dr.sstop'     = "Stop The Running Worm"
 'dr.slnk'      = "Malicious Shortcuts ({0})"
 'dr.spayload'  = "Quarantine Payload Files ({0})"
 'dr.sunhide'   = "Unhide Restored Files ({0})"
 'dr.srestore'  = "Move Hidden Files Back"
 'dr.ssys'      = "Remove The Sysvolume Payload"
 'dr.hvisible'  = "  [ Visibility ]"
 'dr.sshow'     = "Make Files Visible"
 'dr.himmune'   = "  [ Immunity ]"
 'dr.slock'     = "Lock: {0}"
 'dr.noacl'     = "  Note: {0}, No ACL Lock; The Reserved-Name Folder Protects It."
 'dr.done'      = "  {0} Done."
 'dr.quar'      = "  Quarantine: {0}"
 'dr.tip'       = "  Tip: Run ""Scan This PC"" from the menu to check the computer too."
 'dr.sysdrive'  = "  The System Drive Is Not Processed."
 'dr.notfound'  = "  {0} Not Found."

 'cp.hc'        = "  [ Install To C: ]"
 'cp.husb'      = "  [ Install To The USB ]"
 'cp.nosrc'     = "  Source Not Found."
 'cp.scopy'     = "Copy"
 'cp.scopyto'   = "Copy -> {0}"
 'cp.created'   = "  {0} Created."
 'cp.done'      = "  Done."
 'dr.askcopy'   = "  Copy USB-Guard onto this USB as well? (Y/N): "
 'dr.copywhy'   = "  Then it also runs by double-click on another infected PC."
 'dr.copied'    = "  Copied: {0}"
 'dr.nocopy'    = "  Not copied."

 'fnd.ushell'   = "User Shell = {0}"
 'fnd.startup'  = "Startup: {0}"
 'fnd.task'     = "Task: {0}"
 'fnd.svc'      = "Service: {0}"
 'fnd.wsvcz'    = "System32\wsvcz (miner folder)"
 'fnd.fakedir'  = """C:\Windows \System32"" (fake folder)"
 'fnd.script'   = "Script: {0}"
 'fnd.excl'     = "Defender Exclusion: {0}"
 'fnd.startredir' = "Startup Folder Redirected: {0}"
 'fnd.sideload' = "Sideloaded DLL: {0}"
 'fnd.setting'  = "Setting: {0}"
 'fnd.showall'  = "Setting: Show Hidden Files Broken"
 'fnd.taskmgr'  = "Task Manager Disabled"
 'fnd.regedit'  = "Registry Editor Disabled"
 'fnd.cmd'      = "Command Prompt Disabled"
 'fnd.folderop' = "Folder Options Disabled"
 'fnd.norun'    = "Run Dialog Disabled"
 'fnd.nodrives' = "Drives Hidden"
 'fnd.noview'   = "Drive Access Blocked"
 'fnd.taskmgrm' = "Task Manager Disabled (HKLM)"
 'fnd.regeditm' = "Registry Editor Disabled (HKLM)"

 'cln.stop'     = "Stop: {0}"
 'cln.svcdel'   = "Remove Service: {0}"
 'cln.svcfix'   = "Repair Service DLL: {0}"
 'cln.regfix'   = "Repair Registry Value: {0}"
 'cln.regdel'   = "Delete Registry Value: {0}"
 'cln.taskdel'  = "Delete Task: {0}"
 'cln.exclrm'   = "Remove Exclusion"
 'cln.exclman'  = "    Remove by hand: Windows Security > Virus > Exclusions > {0}"
 'cln.polfix'   = "Repair Setting: {0}"
 'cln.quar'     = "Quarantine: {0}"
 'cln.nomove'   = "    Could Not Move: {0}"
 'cln.done'     = "  Done. Quarantine: {0}"
 'cln.reboot'   = "  Some files are locked; they will be moved after a restart."

 'scan.head'    = "  [ This PC - Worm Remnants ]"
 'scan.spin'    = "Processes, Registry, Tasks, Services"
 'scan.clean'   = "  Clean. No worm remnants were found on this PC."
 'scan.note1'   = "  Note: this scan is shallow. It looks only at the startup points a worm"
 'scan.note2'   = "  uses (processes, Run keys, tasks, services, startup folders). It is not"
 'scan.note3'   = "  a full virus scan and does not replace your antivirus."
 'scan.found'   = "  {0} suspicious remnants found:"
 'scan.found1'  = "  1 suspicious remnant found:"
 'scan.ignored' = "  {0} finding ignored from now on. It will not be listed again."
 'scan.nothing' = "  Nothing left to clean."
 'scan.ignhow'  = "  If you want to keep one, type its number; it will not come up again."
 'scan.ask'     = "  Y = clean everything,  number = ignore (e.g. 1,3),  N = cancel: "
 'scan.cancel'  = "  Cancelled. Nothing was changed."
 'scan.left'    = "  Remaining: {0} (scan again)"

 'dx.hoff'      = "  [ Block Running From USB ]"
 'dx.hon'       = "  [ Allow Running From USB ]"
 'dx.what'      = "  No .exe opens from a removable disk; a folder-icon fake cannot run."
 'dx.side'      = "  Side effect: installers and portable programs on a USB stop working."
 'dx.swrite'    = "Write The Deny_Execute Policy"
 'dx.sclear'    = "Remove The Deny_Execute Policy"
 'dx.offdone'   = "  Blocked. Sign out and back in for full effect."
 'dx.ondone'    = "  Allowed. An .exe runs from a USB again."

 'wsh.hon'      = "  [ Turn The Script Engine On ]"
 'wsh.hoff'     = "  [ Turn The Script Engine Off ]"
 'wsh.what'     = "  Shortcut worms run through wscript.exe; this setting cuts them off."
 'wsh.side'     = "  Side effect: legitimate .vbs / .js scripts stop too. Reversible here."
 'wsh.son'      = "Turn Windows Script Host On"
 'wsh.soff'     = "Turn Windows Script Host Off"
 'wsh.ondone'   = "  On. Your .vbs / .js scripts run again."
 'wsh.offdone'  = "  Off. No .vbs / .js runs on this PC any more."

 'wat.hinst'    = "  [ Install The Background Watcher ]"
 'wat.hrem'     = "  [ Remove The Background Watcher ]"
 'wat.scopy'    = "Copy The Files"
 'wat.srun'     = "Scheduled Task"
 'wat.sstart'   = "Start The Watcher"
 'wat.sdel'     = "Delete The Task"
 'wat.sstop'    = "Stop The Watcher"
 'wat.done'     = "  Installed. It runs for every account on this PC and asks"
 'wat.done2'    = "  ""Clean it?"" when an infected USB is plugged in."
 'wat.failed'   = "  The task could not be created. Make sure you are running as admin."
 'wat.removed'  = "  Removed. (Guarded USB Drives Stay Locked.)"
 'wat.popup'    = "Infected USB detected: {0}`n`nClean and guard it?"

 'st.ver'       = "Version"
 'st.pc'        = "This PC"
 'st.av'        = "Antivirus"
 'st.uptodate'  = "Up To Date"
 'st.newver'    = "v{0} Available - github.com/{1}"
 'st.upderr'    = "Check Failed"
 'st.checking'  = "Checking..."
 'st.scanning'  = "Scanning..."
 'st.pcclean'   = "Clean"
 'st.pcdirty'   = "{0} Remnants - Cleanup Recommended"
 'st.pcdirty1'  = "1 Remnant - Cleanup Recommended"
 'st.avon'      = "Protection On"
 'st.avoff'     = "Protection Off"
 'st.avna'      = "Unknown"
 'st.nousb'     = "  No USB Can Be Guarded Right Now."
 'st.usblist'   = "  Eligible USB Drives:"
 'st.nolabel'   = "(No Label)"
 'st.wormtrace' = "Worm Traces"
 'st.guarded'   = "Guarded"
 'st.partial'   = "Partially Guarded"
 'st.unprot'    = "Not Guarded"
 'st.updating'  = "  New version v{0} downloaded, restarting..."

 'adv.head'     = "  [ Advanced Options ]"
 'adv.watcher'  = "Watcher"
 'adv.wsh'      = "Script Engine"
 'adv.dx'       = "Running From USB"
 'adv.lang'     = "Language"
 'adv.ign'      = "Ignored"
 'adv.on'       = "On"
 'adv.off'      = "Off"
 'adv.wshon'    = "On  (.vbs / .js run)"
 'adv.wshoff'   = "Off  (worm scripts cannot run)"
 'adv.dxoff'    = "Off  (no .exe runs from a USB)"
 'adv.dxon'     = "On"

 'mn.cleanpc'   = "Clean This PC  (Recommended)"
 'mn.fixall'    = "Fix Them All"
 'mn.fix'       = "Fix  ->  {0} {1}"
 'mn.scanpc'    = "Scan This PC"
 'mn.copyc'     = "Install USB-Guard To C:"
 'mn.copyusb1'  = "Install USB-Guard To The USB  ->  {0} {1}"
 'mn.copyusbn'  = "Install USB-Guard To A USB..."
 'mn.adv'       = "Advanced Options  >"
 'mn.exit'      = "Exit"
 'mn.back'      = "<  Back"
 'mn.backword'  = "Back"
 'mn.watinst'   = "Install The Watcher"
 'mn.watrem'    = "Remove The Watcher"
 'mn.wshoff'    = "Turn The Script Engine Off  (.vbs / .js)"
 'mn.wshon'     = "Turn The Script Engine On  (.vbs / .js)"
 'mn.dxoff'     = "Block Running From USB  (.exe)"
 'mn.dxon'      = "Allow Running From USB  (.exe)"
 'mn.ignclear'  = "Clear The Ignore List ({0})"
 'mn.restoreq'  = "Restore From Quarantine"
 'mn.lang'      = "Language / Dil  >"

 'hint.main'    = "  Move: Arrows  Select: Enter  Info: Right  GitHub: G  {0}: Esc"
 'hint.sub'     = "  Move: Arrows   Select: Enter   Info: Right   Back: Left / Esc"

 'pick.usb'     = "Which USB should I install USB-Guard to?"
 'pick.allusb'  = "ALL USB DRIVES"
 'pick.quar'    = "Which quarantine should I restore?"

 'rq.head'      = "  [ Restore From Quarantine ]"
 'rq.empty'     = "  The quarantine is empty."
 'rq.items'     = "{0}   ({1} items)"
 'rq.ask'       = "  Move the files back where they came from? (Y/N): "
 'rq.cancel'    = "  Cancelled."
 'rq.nomanifest'= "  This quarantine has no record file (older version); move the files by hand."
 'rq.done'      = "  {0} items moved back."

 'help.scanpc'  = "Scans this computer for worm remnants: running script`nprocesses, Run/RunOnce, Winlogon, startup folders,`nscheduled tasks, services, Defender exclusions and`nExplorer sabotage. Findings are listed first; on your`nconfirmation the entries are deleted and the files are`nmoved to quarantine. A shallow scan, not a virus scan."
 'help.fixall'  = "Cleans and guards every USB in the list, one by one."
 'help.fix'     = "Cleans and guards the selected USB: stops the worm`nprocess, deletes malicious shortcuts (subfolders too),`nmoves your hidden files back to the root, quarantines`nthe payload, then occupies the names the worm needs`nwith locked folders. Your files are never deleted; a`nname clash gets a ' (2)' suffix."
 'help.adv'     = "The watcher, the script engine, the USB execute switch,`nthe language choice and restore from quarantine."
 'help.back'    = "Returns to the main menu."
 'help.install' = "Installs a small background watcher (HKCU Run). When an`ninfected USB is plugged in it offers to clean it with a`nYes/No prompt. Nothing runs without your click."
 'help.uninst'  = "Removes the background watcher and its Run entry."
 'help.wshoff'  = "Turns Windows Script Host off (one registry value).`nThe .vbs / .js worms run through wscript.exe; with this`noff, a clicked shortcut launches nothing.`nSide effect: legitimate .vbs / .js scripts stop too (some`nprinter installers, corporate logon scripts, old setup`nwizards). Reversible from the same menu."
 'help.wshon'   = "Turns Windows Script Host back on; .vbs / .js scripts`nrun again."
 'help.dxoff'   = "A Windows policy: forbids running .exe from removable`ndisks (Removable Disks: Deny execute access).`nA folder-icon fake cannot start at all.`nSide effect: you cannot run an installer or a portable`nprogram from a USB; copy it to C: first.`nSign out and back in for full effect."
 'help.dxon'    = "Lifts the ban on running .exe from a USB."
 'help.ignclear'= "Clears the list of findings you chose to ignore.`nThe next scan lists all of them again."
 'help.restoreq'= "Picks one of the quarantine folders and moves its files`nback where they were taken from. For a false positive."
 'help.copyc'   = "Installs USB-Guard.bat in the root of C: and under`nC:\ProgramData\Usb-Guard; for the watcher and quick access."
 'help.copyusb' = "Installs USB-Guard.bat to the root of the USB you pick,`nso you can run it on another computer too. With several`nsticks you choose the right one by its name."
 'help.exit'    = "Closes the program."
 'help.lang'    = "Changes the interface language: English or Turkish.`nThe choice is saved and not asked again."
 'help.none'    = "No description."
}

function S($k){ $v=$script:STR[$k]; if($null -eq $v){ return $k }; return $v }
function SF($k,[object[]]$a){ return ((S $k) -f $a) }
function Max-Len($keys){ $m=0; foreach($k in $keys){ $n=(S $k).Length; if($n -gt $m){ $m=$n } }; return $m }
function Set-Lang($l){
    $script:LANG=$l
    $script:STR=$(if($l -eq 'en'){ $STREN } else { $STRTR })
    $script:wSt=Max-Len @('st.ver','st.pc','st.av')
    $script:wAdv=Max-Len @('adv.watcher','adv.wsh','adv.dx','adv.lang','adv.ign')
    $script:wDrv=Max-Len @('dr.target','dr.label','dr.fs','dr.status')
}
function Get-Lang {
    try{ if(Test-Path -LiteralPath $langFile){ $v="$((Get-Content -LiteralPath $langFile -TotalCount 1))".Trim().ToLower(); if($v -eq 'en' -or $v -eq 'tr'){ return $v } } }catch{}
    return $null
}
function Save-Lang($l){ try{ [IO.Directory]::CreateDirectory($base) | Out-Null; [IO.File]::WriteAllText($langFile,$l,[Text.Encoding]::ASCII) }catch{} }
function LB($k,$w,$c='Gray'){ TN ('  '+(S $k).PadRight($w)+' : ') $c }

function NL { Write-Host ''; $script:bol=$true }
function TN($t,$c='Gray'){ if($script:M){ $bol=$script:bol; try{ $bol=([Console]::CursorLeft -eq 0) }catch{}; if($bol){ Write-Host $script:M -NoNewline } }; Write-Host "$t" -NoNewline -ForegroundColor $c; $script:bol=$false }
function T($t,$c='Gray'){ TN $t $c; Write-Host ''; $script:bol=$true }
function Link($url,$text,$c='Cyan'){ $e=[char]27; Write-Host ("{0}]8;;{1}{0}\{2}{0}]8;;{0}\" -f $e,$url,$text) -NoNewline -ForegroundColor $c }
function Bar($c=$ACC){ T ('  ' + ('=' * $W)) $c }
function Spin($spText,$spBlock,$okText=$null,$okColor='Green'){
    if($null -eq $okText){ $okText=(S 'sp.ok') }
    $frames='|','/','-','\'
    TN ("  {0,-50}" -f $spText) 'Gray'
    for($i=0;$i -lt 4;$i++){ Write-Host ("`b{0}" -f $frames[$i]) -NoNewline -ForegroundColor $ACC; Start-Sleep -Milliseconds 30 }
    $spOut = & $spBlock
    Write-Host "`b " -NoNewline
    Write-Host '[' -NoNewline -ForegroundColor DarkGray
    Write-Host $okText -NoNewline -ForegroundColor $okColor
    Write-Host ']' -ForegroundColor DarkGray
    NL
    return $spOut
}
function Box-Line($t,$c='White'){
    $t="$t"; if($t.Length -gt $W){ $t=$t.Substring(0,$W) }
    $pad=$W-$t.Length; $l=[int]($pad/2); $r=$pad-$l
    Write-Host ($script:M+'  |') -ForegroundColor $ACC -NoNewline
    Write-Host ((' '*$l)+$t+(' '*$r)) -ForegroundColor $c -NoNewline
    Write-Host '|' -ForegroundColor $ACC; $script:bol=$true
}
function Calc-M {
    $cw=0
    try{ $cw=[Console]::WindowWidth }catch{}
    if($cw -lt 10){ try{ $cw=$Host.UI.RawUI.WindowSize.Width }catch{} }
    if($cw -ge ($W+8)){ $script:M=' '*[int](($cw-$W-6)/2) } else { $script:M='' }
}
function Print-Banner {
    Calc-M
    NL
    T ('  +'+('-'*$W)+'+') $ACC
    Box-Line ''
    Box-Line 'U S B - G U A R D' 'White'
    Box-Line ''
    Box-Line (SF 'ban.tag' $VER) 'Gray'
    Box-Line ''
    T ('  +'+('-'*$W)+'+') $ACC
    TN '  ' 'DarkGray'; TN 'by ' 'DarkGray'; Link 'https://github.com/Teknesyum' 'github.com/Teknesyum' $ACC; NL
    TN '  ' 'DarkGray'; TN 'Sponsor: ' 'DarkGray'; Link 'https://github.com/sponsors/Teknesyum' 'github.com/sponsors/Teknesyum' $ACC2; NL
    NL
}
function Show-Footer {
    NL
    TN '  Teknesyum' $ACC; T ("   |   Usb-Guard v{0}" -f $VER) 'DarkGray'
    TN '  GitHub  : ' 'DarkGray'; Link 'https://github.com/Teknesyum' 'github.com/Teknesyum' 'White'; NL
    TN '  Sponsor : ' 'DarkGray'; Link 'https://github.com/sponsors/Teknesyum' 'github.com/sponsors/Teknesyum' $ACC2; NL
    NL
}
function Fit-Window($rows=36){
    try{
        Add-Type -AssemblyName System.Windows.Forms
        if(-not ('Win32c' -as [type])){
            Add-Type -TypeDefinition @'
using System;using System.Runtime.InteropServices;
public class Win32c{
 [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
 [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr h,int x,int y,int w,int ht,bool rp);
 [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] public static extern bool MoveFileEx(string a, string b, int f);
 [DllImport("kernel32.dll", SetLastError=true)] public static extern IntPtr GetStdHandle(int h);
 [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)] public static extern bool SetCurrentConsoleFontEx(IntPtr h, bool max, ref FONTEX f);
 public struct RECT{public int Left,Top,Right,Bottom;}
 [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Unicode)]
 public struct FONTEX{ public uint cbSize; public uint nFont; public short X; public short Y; public uint FontFamily; public uint FontWeight; [MarshalAs(UnmanagedType.ByValTStr, SizeConst=32)] public string FaceName; }
 public static bool SetFont(string name, short h){ var f=new FONTEX(); f.cbSize=(uint)Marshal.SizeOf(typeof(FONTEX)); f.nFont=0; f.X=0; f.Y=h; f.FontFamily=54; f.FontWeight=400; f.FaceName=name; return SetCurrentConsoleFontEx(GetStdHandle(-11), false, ref f); }
}
'@
        }
        try{ [void][Win32c]::SetFont('Consolas',20) }catch{}
        try{
            $raw=$Host.UI.RawUI; $mx=$raw.MaxPhysicalWindowSize
            $cw=[Math]::Min(80,$mx.Width); $ch=[Math]::Min($rows,$mx.Height)
            $win=$raw.WindowSize; $win.Width=$cw; $win.Height=$ch; $raw.WindowSize=$win
            $b=$raw.BufferSize; $b.Width=$cw; $b.Height=3000; $raw.BufferSize=$b
            $win=$raw.WindowSize; $win.Width=$cw; $win.Height=$ch; $raw.WindowSize=$win
        }catch{}
        Calc-M
        $hwnd=[Win32c]::GetConsoleWindow()
        $r=New-Object 'Win32c+RECT'
        [void][Win32c]::GetWindowRect($hwnd,[ref]$r)
        $ww=$r.Right-$r.Left; $wh=$r.Bottom-$r.Top
        $sc=[System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
        $x=$sc.X+[int](($sc.Width-$ww)/2); $y=$sc.Y+[int](($sc.Height-$wh)/2)
        [void][Win32c]::MoveWindow($hwnd,$x,$y,$ww,$wh,$true)
    }catch{}
}

function Unlock-Path($p){ if(Test-Path -LiteralPath $p){ attrib -s -h -r "$p" /s /d 2>$null | Out-Null; takeown /f "$p" /r /d y 2>$null | Out-Null; icacls "$p" /reset /t /c /q 2>$null | Out-Null } }
function Nuke-Path($p){ if(-not (Test-Path -LiteralPath $p)){ return }; Unlock-Path $p; $lp='\\?\'+$p; try{ [IO.Directory]::Delete($lp,$true) }catch{ Remove-Item -LiteralPath $p -Recurse -Force 2>$null } }
function Test-Immunized($p){ (Test-Path -LiteralPath $p) -and (Test-Path -LiteralPath ('\\?\'+$p+'\'+$reserved)) }
function Immunity-State($root,$label){
    $t=@($fixed); if($label){ $t+=$label }
    $n=0; foreach($x in $t){ if(Test-Immunized (Join-Path $root $x)){ $n++ } }
    if($n -eq 0){ return 'none' }
    if($n -eq $t.Count){ return 'full' }
    return 'part'
}
function Lock-Immunity($p,$ntfs){
    if(Test-Path -LiteralPath $p){
        $it=Get-Item -LiteralPath $p -Force
        if($it -and -not $it.PSIsContainer){ attrib -s -h -r "$p" 2>$null | Out-Null; Remove-Item -LiteralPath $p -Force 2>$null }
        else{ Unlock-Path $p }
    }
    $lp='\\?\'+$p
    [IO.Directory]::CreateDirectory($lp) | Out-Null
    [IO.Directory]::CreateDirectory(($lp+'\'+$reserved)) | Out-Null
    attrib +s +h +r "$p" 2>$null | Out-Null
    if($ntfs){ icacls "$p" /deny "*S-1-1-0:(OI)(CI)(WD,AD,DC,DE)" /q 2>$null | Out-Null }
}
function Get-UsbLogical {
    $out=@()
    try{
        foreach($dd in @(Get-CimInstance Win32_DiskDrive -EA Stop | Where-Object { $_.InterfaceType -eq 'USB' -or "$($_.PNPDeviceID)" -like 'USBSTOR*' })){
            foreach($pt in @(Get-CimAssociatedInstance -InputObject $dd -ResultClassName Win32_DiskPartition -EA SilentlyContinue)){
                foreach($ld in @(Get-CimAssociatedInstance -InputObject $pt -ResultClassName Win32_LogicalDisk -EA SilentlyContinue)){ $out+=$ld.DeviceID }
            }
        }
    }catch{}
    return $out
}
function Eligible($v){
    if("$($v.DeviceID)" -eq $env:SystemDrive){ return $false }
    if($v.DriveType -eq 3){ if($script:usbBus -notcontains $v.DeviceID){ return $false } }
    elseif($v.DriveType -ne 2){ return $false }
    if("$($v.VolumeName)" -match '(?i)vtoyefi|^efi$|boot|recovery|system reserved|winre'){ return $false }
    if($v.Size -lt 300MB){ return $false }
    return $true
}
function Migrate-Base {
    try{ Remove-Item -LiteralPath (Join-Path $env:TEMP 'usb-guard.ps1') -Force -EA SilentlyContinue }catch{}
    try{
        if(-not (Test-Path -LiteralPath $oldBase)){ return }
        if(Test-Path -LiteralPath (Join-Path $base 'quarantine')){ return }
        [IO.Directory]::CreateDirectory($base) | Out-Null
        foreach($it in @(Get-ChildItem -LiteralPath $oldBase -Force -EA SilentlyContinue)){
            Move-Item -LiteralPath $it.FullName -Destination (Join-Path $base $it.Name) -Force -EA SilentlyContinue
        }
        if(@(Get-ChildItem -LiteralPath $oldBase -Force -EA SilentlyContinue).Count -eq 0){ Remove-Item -LiteralPath $oldBase -Force -EA SilentlyContinue }
    }catch{}
}
function Get-BatSource {
    if($env:SELFBAT -and (Test-Path -LiteralPath $env:SELFBAT)){ return $env:SELFBAT }
    if($PSCommandPath -and (Test-Path -LiteralPath $PSCommandPath)){ return $PSCommandPath }
    if(Test-Path -LiteralPath $batInstalled){ return $batInstalled }
    return $null
}
function Self-Line($file,$extra){
    return ('& ([scriptblock]::Create([IO.File]::ReadAllText(''' + $file + '''))) ' + $extra).Trim()
}
function Pause-Key { Write-Host ''; TN ('  '+(S 'pk.enter')) 'DarkGray'; while($true){ $k=[Console]::ReadKey($true); if('Enter','Escape','LeftArrow','Spacebar' -contains "$($k.Key)"){ break } }; NL }
function Read-Head($p){
    try{
        $fs=[IO.File]::Open($p,'Open','Read','ReadWrite')
        try{ $n=[int][math]::Min(4096,$fs.Length); if($n -le 0){ return $null }; $b=New-Object byte[] $n; [void]$fs.Read($b,0,$n); return $b }
        finally{ $fs.Close() }
    }catch{ return $null }
}
function Test-Payload($p){
    try{ if(-not (Test-Path -LiteralPath $p -PathType Leaf)){ return $false } }catch{ return $false }
    $e=[IO.Path]::GetExtension($p)
    if($e -match $payloadExt){ return $true }
    if($e -match '(?i)^\.(exe|dll)$'){ return $true }
    $b=Read-Head $p; if(-not $b -or $b.Length -lt 2){ return $false }
    if($b[0] -eq 77 -and $b[1] -eq 90){ return $true }
    if($b.Length -ge 4 -and $b[0] -eq 35 -and $b[1] -eq 64 -and $b[2] -eq 126 -and $b[3] -eq 94){ return $true }
    if($e -match $dataExt){
        $t=[Text.Encoding]::ASCII.GetString($b)
        if($t -match $codeRx){ return $true }
    }
    return $false
}
function Test-Cloak($d){
    try{
        if((Split-Path $d -Leaf) -match '\.\{[0-9a-fA-F-]{36}\}$'){ return $true }
        $di=Join-Path $d 'desktop.ini'
        if(-not (Test-Path -LiteralPath $di)){ return $false }
        return ((Get-Content -LiteralPath $di -Raw -EA SilentlyContinue) -match $cloakClsid)
    }catch{ return $false }
}
function Lnk-Files($info,$dir,$root){
    $out=@()
    foreach($tok in ($info -split '["'' \t<>&|,;=]+')){
        if($out.Count -ge 8){ break }
        if($tok -notmatch '(?i)\.[a-z0-9]{1,5}$'){ continue }
        $t=$tok -replace '^\.\\',''
        if($t -match '%'){ try{ $t=[Environment]::ExpandEnvironmentVariables($t) }catch{ continue } }
        foreach($b in @($dir,$root)){
            $c=$null
            try{ $c=if([IO.Path]::IsPathRooted($t)){ $t } else { Join-Path $b $t } }catch{ continue }
            if(-not $c){ continue }
            if($c -notmatch ('(?i)^'+[regex]::Escape($root.TrimEnd('\')))){ continue }
            if(Test-Path -LiteralPath $c -PathType Leaf){ $out+=$c; break }
        }
    }
    return @($out | Select-Object -Unique)
}
function Lnk-Info($path){ try{ $s=(New-Object -ComObject WScript.Shell).CreateShortcut($path); return ("{0} {1}" -f $s.TargetPath,$s.Arguments) }catch{ return '' } }
function New-Quarantine($tag){ $q=Join-Path $base ('quarantine\'+(Get-Date -Format 'yyyyMMdd-HHmmss')+$tag); [IO.Directory]::CreateDirectory($q) | Out-Null; return $q }
function Move-Quarantine($p,$q){
    $leaf=(Split-Path $p -Leaf).Trim(); if(-not $leaf){ $leaf='item' }
    $dest=Join-Path $q $leaf; $n=1; while(Test-Path -LiteralPath $dest){ $dest=Join-Path $q ("{0}_{1}" -f $n,$leaf); $n++ }
    attrib -s -h -r "$p" 2>$null | Out-Null
    try{ Move-Item -LiteralPath $p -Destination $dest -Force -EA Stop; Note-Q $q $dest $p; return $true }catch{ return $false }
}
function Note-Q($q,$dest,$p){ try{ [IO.File]::AppendAllText((Join-Path $q 'manifest.txt'),"$dest|$p`r`n",[Text.Encoding]::UTF8) }catch{} }
function Inspect-Drive($root,$label){
    $r=@{BadLnk=@();Hidden=@();Mimic=@();Payload=@();SysHide=@();Unhide=@()}
    $items=@(Get-ChildItem -LiteralPath $root -Force -EA SilentlyContinue)
    $dirs=@($items | Where-Object { $_.PSIsContainer })
    $hiddenDirs=@($dirs | Where-Object { ($_.Attributes -match 'Hidden') -and ($keepDirs -notcontains $_.Name) -and -not (Test-Immunized $_.FullName) })
    $hiddenNames=@($hiddenDirs | ForEach-Object { $_.Name })
    $dirNames=@($dirs | ForEach-Object { $_.Name })
    $lnkInfo=@()
    foreach($it in ($items | Where-Object { -not $_.PSIsContainer })){
        $ext=$it.Extension
        if($ext -match '(?i)^\.lnk$'){
            $info=Lnk-Info $it.FullName
            if(($info -match $lnkRx) -or ($label -and $it.BaseName -eq $label) -or ($hiddenNames -contains $it.BaseName)){ $r.BadLnk+=$it.FullName; $lnkInfo+=$info }
        }
        elseif($it.Name -match $payloadExt){ if($it.Attributes -match 'Hidden|System'){ $r.Payload+=$it.FullName } }
        elseif($ext -match '(?i)^\.(exe|scr|pif|com)$'){ if(($dirNames -contains $it.BaseName) -or ($it.Attributes -match 'Hidden|System') -or ($it.Name -match $dblRx) -or ($it.Name -match $rtlRx)){ $r.Mimic+=$it.FullName } }
        elseif($it.Name -match $rtlRx){ $r.Mimic+=$it.FullName }
        elseif(($it.Attributes -match 'Hidden|System') -and ($ext -match $dataExt) -and (Test-Payload $it.FullName)){ $r.Payload+=$it.FullName }
    }
    $skipTop=@($keepDirs)+@($fixed)+@($hiddenNames); if($label){ $skipTop+=$label }
    $rootLen=$root.TrimEnd('\').Length+1
    foreach($it in @(Get-ChildItem -LiteralPath $root -Recurse -Depth 3 -Force -File -EA SilentlyContinue | Select-Object -First 20000)){
        $rel=$it.FullName.Substring($rootLen); if($rel -notmatch '\\'){ continue }
        $topSeg=$rel.Split('\')[0]; if($skipTop -contains $topSeg){ continue }
        $ext=$it.Extension
        if($ext -match '(?i)^\.lnk$'){ $info=Lnk-Info $it.FullName; if($info -match $lnkRx){ $r.BadLnk+=$it.FullName; $lnkInfo+=$info } }
        elseif($it.Name -match $payloadExt){ if($it.Attributes -match 'Hidden|System'){ $r.Payload+=$it.FullName } }
        elseif($ext -match '(?i)^\.(exe|scr|pif|com)$'){ if(($it.Attributes -match 'Hidden|System') -or ($it.Name -match $dblRx) -or ($it.Name -match $rtlRx)){ $r.Mimic+=$it.FullName } }
        elseif($it.Name -match $rtlRx){ $r.Mimic+=$it.FullName }
        elseif(($it.Attributes -match 'Hidden|System') -and ($ext -match $dataExt) -and (Test-Payload $it.FullName)){ $r.Payload+=$it.FullName }
    }
    $joined=($lnkInfo -join "`n")
    foreach($hd in $hiddenDirs){
        $n=$hd.Name
        $isBox=($n -match $containerRx) -or ($label -and $n -eq $label) -or (Test-Cloak $hd.FullName) -or ($joined -match ('(?i)(^|[\s"\\])'+[regex]::Escape($n)+'\\'))
        if($isBox){ $r.Hidden+=$hd.FullName }
    }
    foreach($li in $lnkInfo){
        foreach($ref in (Lnk-Files $li $root $root)){
            if($r.BadLnk -contains $ref -or $r.Payload -contains $ref -or $r.Mimic -contains $ref){ continue }
            if(Test-Payload $ref){ if($r.Payload -notcontains $ref){ $r.Payload+=$ref } }
            elseif($r.Unhide -notcontains $ref){ $r.Unhide+=$ref }
        }
    }
    foreach($kd in $keepDirs){
        $kp=Join-Path $root $kd
        if(-not (Test-Path -LiteralPath $kp)){ continue }
        foreach($it in @(Get-ChildItem -LiteralPath $kp -Recurse -Depth 3 -Force -File -EA SilentlyContinue | Select-Object -First 2000)){
            if($it.Name -match $sysNameRx){ continue }
            if(Test-Payload $it.FullName){ $r.SysHide+=$it.FullName }
        }
    }
    $sysP=Join-Path $root 'sysvolume'
    $r.HasSys=(Test-Path -LiteralPath $sysP) -and -not (Test-Immunized $sysP)
    $ar=Get-Item -LiteralPath (Join-Path $root 'autorun.inf') -Force -EA SilentlyContinue
    $r.ArFile=[bool]($ar -and -not $ar.PSIsContainer)
    $recP=Join-Path $root 'recycler'
    $r.RecBad=(Test-Path -LiteralPath $recP) -and -not (Test-Immunized $recP)
    $r.Infected=($r.BadLnk.Count -gt 0) -or $r.HasSys -or $r.ArFile -or $r.RecBad -or ($r.Mimic.Count -gt 0) -or ($r.Payload.Count -gt 0) -or ($r.SysHide.Count -gt 0)
    return $r
}
function Restore-Hidden($hide,$root,$q){
    if(-not (Test-Path -LiteralPath $hide)){ return }
    $kids=@(Get-ChildItem -Force -LiteralPath $hide -EA SilentlyContinue | Where-Object { $_.Name -ne $reserved })
    foreach($k in $kids){
        if($q -and -not $k.PSIsContainer -and (Test-Payload $k.FullName)){ [void](Move-Quarantine $k.FullName $q); continue }
        $dest=Join-Path $root $k.Name
        if(Test-Path -LiteralPath $dest){ $n=2; $stem=[IO.Path]::GetFileNameWithoutExtension($k.Name); $ext=[IO.Path]::GetExtension($k.Name); do{ $dest=Join-Path $root ("{0} ({1}){2}" -f $stem,$n,$ext); $n++ }while(Test-Path -LiteralPath $dest) }
        attrib -s -h -r "$($k.FullName)" /s /d 2>$null | Out-Null
        try{ [IO.Directory]::Move($k.FullName,$dest) }catch{ try{ [IO.File]::Move($k.FullName,$dest) }catch{ Move-Item -LiteralPath $k.FullName -Destination $dest -Force 2>$null } }
    }
    $left=@(Get-ChildItem -Force -LiteralPath $hide -EA SilentlyContinue | Where-Object { $_.Name -ne $reserved })
    if($left.Count -eq 0){ Nuke-Path $hide } else { attrib -s -h "$hide" 2>$null | Out-Null }
}

function Process-Drive($dsk){
    $letter=$dsk.DeviceID.TrimEnd(':')
    $root="$letter`:\"
    $label="$($dsk.VolumeName)"
    $fs="$($dsk.FileSystem)"
    $ntfs=$fs -eq 'NTFS'
    $targets=@($fixed); if($label){ $targets+=$label }
    $immState=Immunity-State $root $label
    $allImm=($immState -eq 'full')
    $ins=Inspect-Drive $root $label
    $infected=$ins.Infected

    Write-Host ''; Bar
    LB 'dr.target' $script:wDrv 'DarkGray'; T $root 'White'
    LB 'dr.label' $script:wDrv 'DarkGray'; T "'$label'" 'White'
    LB 'dr.fs' $script:wDrv 'DarkGray'; T $fs 'White'
    LB 'dr.status' $script:wDrv 'DarkGray'
    if($infected){ T (S 'dr.infected') 'Red' } elseif($allImm){ T (S 'dr.guarded') 'Green' } elseif($immState -eq 'part'){ T (S 'dr.partial') 'Yellow' } else{ T (S 'dr.unprot') 'Yellow' }
    Bar; NL

    if($allImm -and -not $infected){ T (S 'dr.nothing') 'Green'; return }

    $q=$null
    if($infected){
        $q=New-Quarantine ("-usb-"+$letter)
        T (S 'dr.hcleanup') $ACC2; NL
        Spin (S 'dr.sstop') {
            Get-CimInstance Win32_Process -Filter "Name='wscript.exe' OR Name='cscript.exe' OR Name='mshta.exe'" | Where-Object { "$($_.CommandLine)" -match ('(?i)'+[regex]::Escape("$letter`:")+'|sysvolume') } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force 2>$null }
        } | Out-Null
        Spin (SF 'dr.slnk' $ins.BadLnk.Count) {
            foreach($p in $ins.BadLnk){ attrib -s -h -r "$p" 2>$null | Out-Null; Remove-Item -LiteralPath $p -Force 2>$null }
        } | Out-Null
        Spin (SF 'dr.spayload' ($ins.Payload.Count+$ins.Mimic.Count+$ins.SysHide.Count)) {
            foreach($p in ($ins.Payload+$ins.Mimic+$ins.SysHide)){ [void](Move-Quarantine $p $q) }
        } | Out-Null
        if($ins.Unhide.Count -gt 0){
            Spin (SF 'dr.sunhide' $ins.Unhide.Count) {
                foreach($p in $ins.Unhide){ attrib -s -h "$p" 2>$null | Out-Null }
            } | Out-Null
        }
        Spin (S 'dr.srestore') {
            if($label){ Restore-Hidden (Join-Path (Join-Path $root 'sysvolume') $label) $root $q }
            foreach($h in $ins.Hidden){ if($label -and $h -eq (Join-Path $root $label)){ Restore-Hidden $h $root $q } }
            foreach($h in $ins.Hidden){ if(Test-Path -LiteralPath $h){ Restore-Hidden $h $root $q } }
        } | Out-Null
        Spin (S 'dr.ssys') { $s=Join-Path $root 'sysvolume'; if(-not (Test-Immunized $s)){ Restore-Hidden $s $root $q } } | Out-Null
    }
    Write-Host ''; T (S 'dr.hvisible') $ACC2; NL
    Spin (S 'dr.sshow') { $skip=@($keepDirs)+@($batName,$label)+$fixed; Get-ChildItem -LiteralPath $root -Force | Where-Object { $skip -notcontains $_.Name } | ForEach-Object { attrib -s -h "$($_.FullName)" 2>$null | Out-Null } } | Out-Null

    Write-Host ''; T (S 'dr.himmune') $ACC2; NL
    foreach($n in $targets){ $was=Test-Immunized (Join-Path $root $n); Spin (SF 'dr.slock' $n) { Lock-Immunity (Join-Path $root $n) $ntfs } ($(if($was){(S 'sp.already')}else{(S 'sp.ok')})) $(if($was){'DarkGray'}else{'Green'}) | Out-Null }
    if(-not $ntfs){ Write-Host ''; T (SF 'dr.noacl' $fs) 'DarkYellow' }
    Write-Host ''; T (SF 'dr.done' $root) 'Green'
    if($q){ T (SF 'dr.quar' $q) 'Gray' }
    if($infected){ T (S 'dr.tip') 'Yellow' }
    Offer-Copy $root
}
function Offer-Copy($root){
    $src=Get-BatSource
    if(-not $src){ return }
    $dest=Join-Path $root $batName
    Write-Host ''; T (S 'dr.copywhy') 'DarkGray'
    TN (S 'dr.askcopy') 'Yellow'
    $ans=[Console]::ReadLine()
    if($ans -notmatch '(?i)^[ey]'){ T (S 'dr.nocopy') 'DarkGray'; return }
    try{ Copy-Item -LiteralPath $src -Destination $dest -Force -EA Stop; T (SF 'dr.copied' $dest) 'Green' }
    catch{ T (S 'cp.nosrc') 'Red' }
}

function Copy-ToC {
    $src=Get-BatSource
    Write-Host ''; T (S 'cp.hc') $ACC2
    if(-not $src){ T (S 'cp.nosrc') 'Red'; return }
    $dest=Join-Path $env:SystemDrive ('\'+$batName)
    Spin (S 'cp.scopy') { Copy-Item -LiteralPath $src -Destination $dest -Force } | Out-Null
    T (SF 'cp.created' $dest) 'Green'
}
function Copy-ToUsb($drives){
    $src=Get-BatSource
    Write-Host ''; T (S 'cp.husb') $ACC2
    if(-not $src){ T (S 'cp.nosrc') 'Red'; return }
    foreach($d in $drives){ $root="$($d.DeviceID)\"; Spin (SF 'cp.scopyto' $d.DeviceID) { Copy-Item -LiteralPath $src -Destination (Join-Path $root $batName) -Force } | Out-Null }
    T (S 'cp.done') 'Green'
}

function Add-Find($list,$h){ $h.Desc="$($h.Desc)"; [void]$list.Add($h) }
function Find-Procs($f){
    foreach($p in Get-CimInstance Win32_Process){
        $n="$($p.Name)"; $cl="$($p.CommandLine)"; $ep="$($p.ExecutablePath)"
        if($cl -match '(?i)usb-guard'){ continue }
        $bad=($n -match '(?i)^(xmrig|svctrl64|svcinsty64)\.exe$') -or ($ep -match '(?i)\\Windows \\|\\wsvcz\\') -or ($n -match '(?i)^(wscript|cscript|mshta)\.exe$' -and $cl -match $susRx)
        if($bad){ Add-Find $f @{Type='Proc';Pid=$p.ProcessId;Desc=("{0} [{1}]" -f $n,$p.ProcessId);Detail=$cl} }
    }
}
function Find-RunKeys($f){
    $rk=@('HKCU:\Software\Microsoft\Windows\CurrentVersion\Run','HKLM:\Software\Microsoft\Windows\CurrentVersion\Run','HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce','HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce','HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run','HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run','HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\Run')
    foreach($k in $rk){
        $p=Get-ItemProperty -Path $k -EA SilentlyContinue; if(-not $p){ continue }
        foreach($pr in $p.PSObject.Properties){
            if($pr.Name -match '^PS(Path|ParentPath|ChildName|Drive|Provider)$'){ continue }
            $v="$($pr.Value)"; if($v -match '(?i)usb-guard'){ continue }
            if($v -notmatch $susRx){ continue }
            if($v -match '(?i)\\(Temp|Public)\\[^"]*\.exe' -and -not ($v -match $knownNames) -and (Test-Trusted $v)){
                $sl=Find-Sideload $v
                if($sl){ Add-Find $f @{Type='File';Path=$sl;Desc=(SF 'fnd.sideload' (Split-Path $sl -Leaf));Detail=$sl} }
                continue
            }
            Add-Find $f @{Type='Reg';Key=$k;Name=$pr.Name;Desc=("{0} = {1}" -f $pr.Name,$v)}
        }
    }
    $wlk='HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
    $wl=Get-ItemProperty -Path $wlk -EA SilentlyContinue
    if($wl.Shell -and "$($wl.Shell)" -ne 'explorer.exe'){ Add-Find $f @{Type='Reg';Key=$wlk;Name='Shell';Restore='explorer.exe';Desc=("Winlogon Shell = {0}" -f $wl.Shell)} }
    if($wl.Userinit -and "$($wl.Userinit)" -notmatch ('^(?i)'+[regex]::Escape($sysDir)+'\\userinit\.exe,?\s*$')){ Add-Find $f @{Type='Reg';Key=$wlk;Name='Userinit';Restore=($sysDir+'\userinit.exe,');Desc=("Winlogon Userinit = {0}" -f $wl.Userinit)} }
    $wlu='HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
    $us=(Get-ItemProperty -Path $wlu -Name Shell -EA SilentlyContinue).Shell
    if($us){ Add-Find $f @{Type='Reg';Key=$wlu;Name='Shell';Desc=(SF 'fnd.ushell' $us)} }
    $ai='HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Windows'
    $ad="$((Get-ItemProperty -Path $ai -Name AppInit_DLLs -EA SilentlyContinue).AppInit_DLLs)".Trim()
    if($ad){ Add-Find $f @{Type='Reg';Key=$ai;Name='AppInit_DLLs';Restore='';Desc=("AppInit_DLLs = {0}" -f $ad)} }
    $envk='HKCU:\Environment'
    $ums="$((Get-ItemProperty -Path $envk -Name UserInitMprLogonScript -EA SilentlyContinue).UserInitMprLogonScript)"
    if($ums){ Add-Find $f @{Type='Reg';Key=$envk;Name='UserInitMprLogonScript';Desc=("UserInitMprLogonScript = {0}" -f $ums)} }
    $sfk='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
    $sf="$((Get-ItemProperty -Path $sfk -Name Startup -EA SilentlyContinue).Startup)"
    if($sf -and $sf -notmatch '(?i)Start Menu\\Programs\\Startup$'){ Add-Find $f @{Type='Reg';Key=$sfk;Name='Startup';Restore=(Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup');Desc=(SF 'fnd.startredir' $sf)} }
    $ifeo='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
    foreach($exe in 'taskmgr.exe','regedit.exe','cmd.exe','msconfig.exe','explorer.exe','mmc.exe','powershell.exe','procexp.exe','msseces.exe'){
        $k=Join-Path $ifeo $exe
        $dbg="$((Get-ItemProperty -Path $k -Name Debugger -EA SilentlyContinue).Debugger)"
        if($dbg){ Add-Find $f @{Type='Reg';Key=$k;Name='Debugger';Desc=("{0} Debugger = {1}" -f $exe,$dbg)} }
    }
}
function Find-Startup($f){
    $dirs=@((Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup'),(Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\StartUp'))
    foreach($st in $dirs){
        Get-ChildItem -LiteralPath $st -Force -File -EA SilentlyContinue | ForEach-Object {
            $bad=$false
            if($_.Name -match $scriptExt){ $bad=$true }
            elseif($_.Extension -match '(?i)^\.lnk$'){ $bad=((Lnk-Info $_.FullName) -match $susRx) }
            elseif($_.Extension -match '(?i)^\.exe$'){ $bad=($_.Name -match '(?i)^(xmrig|svctrl64|svcinsty64)') }
            if($bad){ Add-Find $f @{Type='File';Path=$_.FullName;Desc=(SF 'fnd.startup' $_.Name);Detail=$_.FullName} }
        }
    }
}
function Find-Tasks($f){
    $tasks=Get-ScheduledTask -EA SilentlyContinue | Where-Object { $_.TaskPath -notlike '\Microsoft\*' }
    foreach($t in $tasks){
        foreach($a in @($t.Actions)){
            $cmd=("{0} {1}" -f $a.Execute,$a.Arguments)
            if($cmd -match '(?i)usb-guard'){ continue }
            if($cmd -match $susRx){ Add-Find $f @{Type='Task';Name=$t.TaskName;Path=$t.TaskPath;Desc=(SF 'fnd.task' $t.TaskName);Detail=$cmd}; break }
        }
    }
}
function Bin-Path($s){
    $p="$s"
    if(-not $p){ return '' }
    $p=$p.Trim()
    $p=$p -replace '^\\\?\?\\',''
    $p=$p -replace '^\\SystemRoot\\',"$env:SystemRoot\"
    if($p -match '%'){ $p=[Environment]::ExpandEnvironmentVariables($p) }
    if($p.StartsWith('"')){
        $e=$p.IndexOf('"',1)
        if($e -gt 0){ return $p.Substring(1,$e-1) }
        return $p.Trim('"')
    }
    $m=[regex]::Match($p,'(?i)^.*?\.(exe|dll|sys|scr|com)\b')
    if($m.Success){ return $m.Value }
    return ($p -split '\s+')[0]
}
function Test-Trusted($s){
    try{
        $p=Bin-Path $s
        if(-not $p -or -not (Test-Path -LiteralPath $p -PathType Leaf)){ return $false }
        $sig=Get-AuthenticodeSignature -LiteralPath $p -EA SilentlyContinue
        return ($sig -and $sig.Status -eq 'Valid')
    }catch{ return $false }
}
function Find-Sideload($s){
    try{
        $p=Bin-Path $s
        if(-not $p){ return $null }
        $d=Split-Path $p -Parent
        if(-not $d -or $d -notmatch '(?i)\\(Users|ProgramData|Temp|Public)(\\|$)'){ return $null }
        foreach($dl in @(Get-ChildItem -LiteralPath $d -Filter '*.dll' -Force -File -EA SilentlyContinue | Select-Object -First 20)){
            $sg=Get-AuthenticodeSignature -LiteralPath $dl.FullName -EA SilentlyContinue
            if(-not $sg -or $sg.Status -ne 'Valid'){ return $dl.FullName }
        }
    }catch{}
    return $null
}
function Find-Services($f){
    $svcRx='(?i)\\Temp\\|\\Windows \\|\\u\d{6}\.(dll|dat)|wsvcz|svctrl64|svcinsty64|xmrig|\.(vbs|js|bat|cmd)\b'
    $dllRx='(?i)\\Temp\\|\\AppData\\|\\ProgramData\\|\\Users\\|\\Windows \\|\\u\d{6}\.(dll|dat)|wsvcz'
    foreach($s in Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services' -EA SilentlyContinue){
        $ip="$((Get-ItemProperty -Path $s.PSPath -EA SilentlyContinue).ImagePath)"
        $dll="$((Get-ItemProperty -Path (Join-Path $s.PSPath 'Parameters') -EA SilentlyContinue).ServiceDll)"
        $hit=$false
        if($ip -match $svcRx){ if(Test-Trusted $ip){ $sl=Find-Sideload $ip; if($sl){ Add-Find $f @{Type='File';Path=$sl;Desc=(SF 'fnd.sideload' (Split-Path $sl -Leaf));Detail=$sl} } } else { $hit=$true } }
        if($dll -match $dllRx -and -not (Test-Trusted $dll)){ $hit=$true }
        if($hit){ Add-Find $f @{Type='Svc';Name=$s.PSChildName;Desc=(SF 'fnd.svc' $s.PSChildName);Detail=(@($ip,$dll) | Where-Object { $_ }) -join ' | '} }
    }
    $dc="$((Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\DcomLaunch\Parameters' -EA SilentlyContinue).ServiceDll)"
    if($dc -and $dc -notmatch '(?i)\\system32\\rpcss\.dll$'){ Add-Find $f @{Type='SvcDll';Name='DcomLaunch';Restore='%SystemRoot%\system32\rpcss.dll';Desc=("DcomLaunch ServiceDll = {0}" -f $dc)} }
}
function Find-MinerFiles($f){
    foreach($n in 'svcinsty64.exe','svctrl64.exe','svctrl64.dll'){ $p=Join-Path $sysDir $n; if(Test-Path -LiteralPath $p){ Add-Find $f @{Type='File';Path=$p;Desc=("System32: {0}" -f $n);Detail=$p} } }
    $wz=Join-Path $sysDir 'wsvcz'; if(Test-Path -LiteralPath $wz){ Add-Find $f @{Type='File';Path=$wz;Desc=(S 'fnd.wsvcz');Detail=$wz} }
    if(Test-Path -LiteralPath $spaceDir){ Add-Find $f @{Type='File';Path=$spaceDir;Desc=(S 'fnd.fakedir');Detail=$spaceDir} }
    Get-ChildItem -LiteralPath $sysDir -Filter 'u*.dll' -Force -EA SilentlyContinue | Where-Object { $_.Name -match '^u\d{6}\.dll$' } | ForEach-Object { Add-Find $f @{Type='File';Path=$_.FullName;Desc=("System32: {0}" -f $_.Name);Detail=$_.FullName} }
}
function Find-Scripts($f){
    $roots=@($env:TEMP,$env:APPDATA,$env:LOCALAPPDATA,$env:ProgramData,$env:USERPROFILE,$env:PUBLIC,(Join-Path $env:PUBLIC 'Documents'),(Join-Path $env:SystemDrive '\Users\Default')) | ForEach-Object { try{ (Get-Item -LiteralPath $_ -Force).FullName }catch{} } | Select-Object -Unique
    $tempFull=try{ (Get-Item -LiteralPath $env:TEMP -Force).FullName }catch{ $env:TEMP }
    $a='(?i)WScript\.Shell|Scripting\.FileSystemObject|ActiveXObject|CreateObject'
    $b='(?i)sysvolume|autorun|\.lnk|DriveType|RemovableDrive|attrib\s|\.Drives\b|\\Startup\\|CurrentVersion\\Run|\+h\s|\+s\s'
    $skipDir='(?i)^(Temp|Microsoft|Packages|Google|Mozilla|Programs|node_modules|Usb-Guard|NVIDIA|Adobe|Discord|Steam|Package Cache|\..*)$'
    $extRx='(?i)\.(vbs|vbe|js|jse|wsf|hta)$'
    $dirs=New-Object System.Collections.ArrayList
    foreach($d in $roots){
        if(-not (Test-Path -LiteralPath $d)){ continue }
        [void]$dirs.Add($d)
        if($d -eq $tempFull){ continue }
        $n=0
        try{ foreach($sd in [IO.Directory]::EnumerateDirectories($d)){
            if((Split-Path $sd -Leaf) -match $skipDir){ continue }
            [void]$dirs.Add($sd); $n++
            try{ foreach($sd2 in [IO.Directory]::EnumerateDirectories($sd)){ if((Split-Path $sd2 -Leaf) -notmatch $skipDir){ [void]$dirs.Add($sd2); $n++ }; if($n -ge 1500){ break } } }catch{}
            if($n -ge 1500){ break }
        } }catch{}
    }
    foreach($d in ($dirs | Select-Object -Unique)){
        $files=@(); try{ $files=@([IO.Directory]::EnumerateFiles($d) | Where-Object { $_ -match $extRx }) }catch{}
        foreach($fp in $files){
            try{ $fi=New-Object IO.FileInfo $fp; if($fi.Length -gt 500KB -or $fi.Length -lt 64){ continue } }catch{ continue }
            $c=Get-Content -LiteralPath $fp -Raw -EA SilentlyContinue
            if($c -match $a -and $c -match $b){ Add-Find $f @{Type='File';Path=$fp;Desc=(SF 'fnd.script' (Split-Path $fp -Leaf));Detail=$fp} }
        }
    }
}
function Find-Exclusions($f){
    $rx='(?i)\\Windows \\|wsvcz|\\Temp\\|\\AppData\\|\\ProgramData\\|\\Users\\Public\\|sysvolume'
    $seen=@()
    foreach($b in @('HKLM:\SOFTWARE\Microsoft\Windows Defender\Exclusions','HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions')){
        foreach($sub in @('Paths','Extensions','Processes')){
            $it=Get-Item -Path (Join-Path $b $sub) -EA SilentlyContinue; if(-not $it){ continue }
            foreach($p in $it.Property){
                if($sub -eq 'Paths' -and $p -notmatch $rx){ continue }
                if($seen -contains $p){ continue }
                $seen+=$p
                Add-Find $f @{Type='Excl';Path=$p;Kind=$sub;Desc=(SF 'fnd.excl' $p)}
            }
        }
    }
}
function Find-Sabotage($f){
    $checks=@(
        @{K='HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System';N='DisableTaskMgr';L='fnd.taskmgr'},
        @{K='HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System';N='DisableRegistryTools';L='fnd.regedit'},
        @{K='HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System';N='DisableCMD';L='fnd.cmd'},
        @{K='HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer';N='NoFolderOptions';L='fnd.folderop'},
        @{K='HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer';N='NoRun';L='fnd.norun'},
        @{K='HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer';N='NoDrives';L='fnd.nodrives'},
        @{K='HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer';N='NoViewOnDrive';L='fnd.noview'},
        @{K='HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System';N='DisableTaskMgr';L='fnd.taskmgrm'},
        @{K='HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System';N='DisableRegistryTools';L='fnd.regeditm'}
    )
    foreach($c in $checks){ $k=$c['K']; $n=$c['N']; $it=Get-ItemProperty -Path $k -EA SilentlyContinue; if(-not $it){ continue }; $v=$it.PSObject.Properties[$n].Value; if($null -ne $v -and [int]$v -ne 0){ Add-Find $f @{Type='Policy';Key=$k;Name=$n;Desc=(SF 'fnd.setting' (S $c['L']))} } }
    $sk='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\Hidden\SHOWALL'
    $cv=(Get-ItemProperty -Path $sk -Name 'CheckedValue' -EA SilentlyContinue).CheckedValue
    if($null -ne $cv -and [int]$cv -ne 1){ Add-Find $f @{Type='Policy';Key=$sk;Name='CheckedValue';Set=1;Desc=(S 'fnd.showall')} }
}
function Find-Key($x){
    $k=("{0}|{1}|{2}" -f $x.Type,$x.Desc,$x.Detail)
    return ($k -replace '[\r\n]+',' ').Trim()
}
function Get-Ignored {
    if(-not (Test-Path -LiteralPath $ignFile)){ return @() }
    return @(Get-Content -LiteralPath $ignFile -Encoding UTF8 -EA SilentlyContinue | Where-Object { "$_".Trim() })
}
function Add-Ignored($keys){
    try{
        [IO.Directory]::CreateDirectory($base) | Out-Null
        $all=@(Get-Ignored) + @($keys) | Select-Object -Unique
        [IO.File]::WriteAllLines($ignFile,[string[]]$all,(New-Object Text.UTF8Encoding($false)))
    }catch{}
}
function Clear-Ignored { Remove-Item -LiteralPath $ignFile -Force -EA SilentlyContinue }
function Find-PcRemnants {
    $f=New-Object System.Collections.ArrayList
    Find-Procs $f; Find-RunKeys $f; Find-Startup $f; Find-Tasks $f; Find-Services $f; Find-MinerFiles $f; Find-Scripts $f; Find-Exclusions $f; Find-Sabotage $f
    $ign=@(Get-Ignored)
    if($ign.Count -eq 0){ return @($f.ToArray()) }
    return @($f.ToArray() | Where-Object { $ign -notcontains (Find-Key $_) })
}
function Quarantine-Path($p,$q){
    if(-not (Test-Path -LiteralPath $p)){ return $true }
    $isDir=(Get-Item -LiteralPath $p -Force).PSIsContainer
    if($isDir){ attrib -s -h -r "$p" /s /d 2>$null | Out-Null } else { attrib -s -h -r "$p" 2>$null | Out-Null }
    $leaf=Split-Path $p -Leaf; if(-not $leaf){ $leaf='item' }
    $dest=Join-Path $q ($leaf.Trim())
    try{ Move-Item -LiteralPath $p -Destination $dest -Force -EA Stop; Note-Q $q $dest $p; return $true }catch{}
    try{ if($isDir){ takeown /f "$p" /r /d y 2>$null | Out-Null; icacls "$p" /grant "*S-1-5-32-544:F" /t /c /q 2>$null | Out-Null } else { takeown /f "$p" 2>$null | Out-Null; icacls "$p" /grant "*S-1-5-32-544:F" /q 2>$null | Out-Null }; Move-Item -LiteralPath $p -Destination $dest -Force -EA Stop; Note-Q $q $dest $p; return $true }catch{}
    try{ if([Win32c]::MoveFileEx($p,$dest,4)){ $script:needReboot=$true; Note-Q $q $dest $p; return $true } }catch{}
    return $false
}
function Clean-PcRemnants($found){
    $q=New-Quarantine ''
    $script:needReboot=$false
    $order=@('Proc','Svc','SvcDll','Reg','Task','Excl','Policy','File')
    foreach($ty in $order){
        foreach($x in ($found | Where-Object { $_.Type -eq $ty })){
            switch($ty){
                'Proc'   { Spin (SF 'cln.stop' $x.Desc) { Stop-Process -Id $x.Pid -Force -EA SilentlyContinue } | Out-Null }
                'Svc'    { Spin (SF 'cln.svcdel' $x.Name) { Stop-Service -Name $x.Name -Force -EA SilentlyContinue; sc.exe delete "$($x.Name)" 2>$null | Out-Null } | Out-Null }
                'SvcDll' { Spin (SF 'cln.svcfix' $x.Name) { Set-ItemProperty -Path ("HKLM:\SYSTEM\CurrentControlSet\Services\{0}\Parameters" -f $x.Name) -Name ServiceDll -Value $x.Restore -Type ExpandString; $script:needReboot=$true } | Out-Null }
                'Reg'    { if($x.ContainsKey('Restore')){ Spin (SF 'cln.regfix' $x.Name) { Set-ItemProperty -Path $x.Key -Name $x.Name -Value $x.Restore } | Out-Null } else { Spin (SF 'cln.regdel' $x.Name) { Remove-ItemProperty -Path $x.Key -Name $x.Name -EA SilentlyContinue } | Out-Null } }
                'Task'   { Spin (SF 'cln.taskdel' $x.Name) { Unregister-ScheduledTask -TaskName $x.Name -TaskPath $x.Path -Confirm:$false -EA SilentlyContinue } | Out-Null }
                'Excl'   { $ok=Spin (S 'cln.exclrm') { try{ switch("$($x.Kind)"){ 'Extensions' { Remove-MpPreference -ExclusionExtension $x.Path -EA Stop } 'Processes' { Remove-MpPreference -ExclusionProcess $x.Path -EA Stop } default { Remove-MpPreference -ExclusionPath $x.Path -EA Stop } }; $true }catch{ $false } } | Select-Object -Last 1; if(-not $ok){ T (SF 'cln.exclman' $x.Path) 'DarkYellow' } }
                'Policy' { Spin (SF 'cln.polfix' $x.Name) { if($x.ContainsKey('Set')){ Set-ItemProperty -Path $x.Key -Name $x.Name -Value $x.Set -Type DWord } else { Remove-ItemProperty -Path $x.Key -Name $x.Name -EA SilentlyContinue } } | Out-Null }
                'File'   { $ok=Spin (SF 'cln.quar' (Split-Path $x.Path -Leaf)) { Quarantine-Path $x.Path $q } | Select-Object -Last 1; if(-not $ok){ T (SF 'cln.nomove' $x.Path) 'Red' } }
            }
        }
    }
    Write-Host ''; T (SF 'cln.done' $q) 'Green'
    if($script:needReboot){ T (S 'cln.reboot') 'Yellow' }
}
function Scan-Pc {
    Write-Host ''; T (S 'scan.head') $ACC2; NL
    $script:scanTmp=@()
    Spin (S 'scan.spin') { $script:scanTmp=@(Find-PcRemnants) } | Out-Null
    $found=@($script:scanTmp)
    NL
    if($found.Count -eq 0){
        $script:pcFound=@()
        T (S 'scan.clean') 'Green'; NL
        T (S 'scan.note1') 'DarkGray'
        T (S 'scan.note2') 'DarkGray'
        T (S 'scan.note3') 'DarkGray'
        return
    }
    T $(if($found.Count -eq 1){ S 'scan.found1' } else { SF 'scan.found' $found.Count }) 'Red'; NL
    for($i=0;$i -lt $found.Count;$i++){
        $x=$found[$i]
        TN ("   {0,2}. " -f ($i+1)) 'DarkGray'; TN ("[{0,-6}] " -f $x.Type) 'DarkGray'; T $x.Desc 'Yellow'
        if($x.Detail -and $x.Detail -ne $x.Desc){ $d="$($x.Detail)"; if($d.Length -gt 62){ $d=$d.Substring(0,62)+'..' }; T ("                {0}" -f $d) 'Gray' }
    }
    Write-Host ''; T (S 'scan.ignhow') 'DarkGray'
    TN (S 'scan.ask') 'Yellow'
    $ans="$([Console]::ReadLine())"
    $nums=@([regex]::Matches($ans,'\d+') | ForEach-Object { [int]$_.Value } | Where-Object { $_ -ge 1 -and $_ -le $found.Count } | Select-Object -Unique)
    if($nums.Count -gt 0){
        Add-Ignored @($nums | ForEach-Object { Find-Key $found[$_-1] })
        $keep=@(); for($i=0;$i -lt $found.Count;$i++){ if($nums -notcontains ($i+1)){ $keep+=,$found[$i] } }
        $found=@($keep)
        Write-Host ''; T (SF 'scan.ignored' $nums.Count) 'DarkYellow'
        if($found.Count -eq 0){ $script:pcFound=@(Find-PcRemnants); T (S 'scan.nothing') 'Green'; return }
    }
    elseif($ans -notmatch '(?i)^[ey]'){ Write-Host ''; T (S 'scan.cancel') 'DarkYellow'; return }
    NL
    Clean-PcRemnants $found
    $script:pcFound=@(Find-PcRemnants)
    if($script:pcFound.Count -gt 0){ T (SF 'scan.left' $script:pcFound.Count) 'Yellow' }
}
function Test-Wsh { $v=(Get-ItemProperty -Path $wshKey -Name Enabled -EA SilentlyContinue).Enabled; return -not ($null -ne $v -and [int]$v -eq 0) }
function Test-DenyExec { $v=(Get-ItemProperty -Path $dxKey -Name Deny_Execute -EA SilentlyContinue).Deny_Execute; return ($null -ne $v -and [int]$v -eq 1) }
function Toggle-DenyExec($on){
    NL
    if($on){
        T (S 'dx.hoff') $ACC2
        T (S 'dx.what') 'Gray'
        T (S 'dx.side') 'DarkYellow'
        NL
        Spin (S 'dx.swrite') { if(-not (Test-Path $dxKey)){ New-Item -Path $dxKey -Force | Out-Null }; Set-ItemProperty -Path $dxKey -Name Deny_Execute -Value 1 -Type DWord } | Out-Null
        Write-Host ''; T (S 'dx.offdone') 'Green'
    } else {
        T (S 'dx.hon') $ACC2
        Spin (S 'dx.sclear') { Remove-ItemProperty -Path $dxKey -Name Deny_Execute -EA SilentlyContinue } | Out-Null
        Write-Host ''; T (S 'dx.ondone') 'Green'
    }
}
function Toggle-Wsh($on){
    NL
    if($on){
        T (S 'wsh.hon') $ACC2
        Spin (S 'wsh.son') { Remove-ItemProperty -Path $wshKey -Name Enabled -EA SilentlyContinue } | Out-Null
        Write-Host ''; T (S 'wsh.ondone') 'Green'
    } else {
        T (S 'wsh.hoff') $ACC2
        T (S 'wsh.what') 'Gray'
        T (S 'wsh.side') 'DarkYellow'
        NL
        Spin (S 'wsh.soff') { if(-not (Test-Path $wshKey)){ New-Item -Path $wshKey -Force | Out-Null }; Set-ItemProperty -Path $wshKey -Name Enabled -Value 0 -Type DWord } | Out-Null
        Write-Host ''; T (S 'wsh.offdone') 'Green'
    }
}
function Test-WatcherTask {
    try{ & schtasks.exe /Query /TN $taskName 2>&1 | Out-Null; return ($LASTEXITCODE -eq 0) }catch{ return $false }
}
function Task-Xml {
    $argLine='-NoProfile -WindowStyle Hidden -Command "'+(Self-Line $batInstalled '-Watch')+'"'
    $argLine=$argLine.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;')
    return @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>USB-Guard: asks to clean an infected USB when one is plugged in.</Description>
    <URI>\$taskName</URI>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger><Enabled>true</Enabled><Delay>PT20S</Delay></LogonTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <GroupId>S-1-5-32-545</GroupId>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings><StopOnIdleEnd>false</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>$argLine</Arguments>
    </Exec>
  </Actions>
</Task>
"@
}
function Stop-Watchers {
    Get-CimInstance Win32_Process -Filter "Name='powershell.exe'" -EA SilentlyContinue |
        Where-Object { $_.CommandLine -match '(?i)usb-guard\.(bat|ps1).*-Watch' -and $_.ProcessId -ne $PID } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -EA SilentlyContinue }
}
function Install-Watcher {
    Write-Host ''; T (S 'wat.hinst') $ACC2
    Spin (S 'wat.scopy') {
        [IO.Directory]::CreateDirectory($base) | Out-Null
        Remove-Item -LiteralPath $psInstalled -Force -EA SilentlyContinue
        $bs=Get-BatSource
        if($bs){
            if($bs -ne $batInstalled){ Copy-Item -LiteralPath $bs -Destination $batInstalled -Force }
            Copy-Item -LiteralPath $batInstalled -Destination (Join-Path $env:SystemDrive ('\'+$batName)) -Force
        }
    } | Out-Null
    $script:taskOk=$false
    Spin (S 'wat.srun') {
        Remove-ItemProperty -Path $runKey -Name $runName -EA SilentlyContinue
        $xml=Join-Path $env:TEMP 'usb-guard-task.xml'
        [IO.File]::WriteAllText($xml,(Task-Xml),[Text.Encoding]::Unicode)
        & schtasks.exe /Create /TN $taskName /XML $xml /F 2>&1 | Out-Null
        $script:taskOk = ($LASTEXITCODE -eq 0)
        Remove-Item -LiteralPath $xml -Force -EA SilentlyContinue
    } | Out-Null
    Spin (S 'wat.sstart') {
        Stop-Watchers
        Start-Process powershell -WindowStyle Hidden -ArgumentList '-NoProfile','-WindowStyle','Hidden','-Command',(Self-Line $batInstalled '-Watch')
    } | Out-Null
    Write-Host ''
    if($script:taskOk){ T (S 'wat.done') 'Green'; T (S 'wat.done2') 'Green' } else { T (S 'wat.failed') 'Red' }
}
function Uninstall-Watcher {
    Write-Host ''; T (S 'wat.hrem') $ACC2
    Spin (S 'wat.sdel') {
        Remove-ItemProperty -Path $runKey -Name $runName -EA SilentlyContinue
        & schtasks.exe /Delete /TN $taskName /F 2>&1 | Out-Null
    } | Out-Null
    Spin (S 'wat.sstop') { Stop-Watchers } | Out-Null
    Write-Host ''; T (S 'wat.removed') 'Green'
}

function Start-Watcher {
    $global:GuardBat = if(Test-Path -LiteralPath $batInstalled){ $batInstalled } else { Get-BatSource }
    $global:GuardRes = $reserved
    $global:GuardLnk = $lnkRx
    $global:GuardMsg = (S 'wat.popup')
    Register-CimIndicationEvent -Query "SELECT * FROM Win32_VolumeChangeEvent WHERE EventType=2" -SourceIdentifier 'UsbGuardArrive' -Action {
        $dn=$Event.SourceEventArgs.NewEvent.DriveName; if(-not $dn){ return }
        Start-Sleep -Seconds 2
        $root="$dn\"; $res=$global:GuardRes
        $lnk=$false
        try{ $sh=New-Object -ComObject WScript.Shell; foreach($l in @(Get-ChildItem -LiteralPath $root -Filter *.lnk -Force -EA SilentlyContinue)){ $s=$sh.CreateShortcut($l.FullName); if(("{0} {1}" -f $s.TargetPath,$s.Arguments) -match $global:GuardLnk){ $lnk=$true; break } } }catch{}
        $sysP=Join-Path $root 'sysvolume'
        $sysBad=(Test-Path -LiteralPath $sysP) -and -not (Test-Path -LiteralPath ('\\?\'+$sysP+'\'+$res))
        $arI=Get-Item -LiteralPath (Join-Path $root 'autorun.inf') -Force -EA SilentlyContinue
        $arBad=($arI -and -not $arI.PSIsContainer)
        $recP=Join-Path $root 'recycler'
        $recBad=(Test-Path -LiteralPath $recP) -and -not (Test-Path -LiteralPath ('\\?\'+$recP+'\'+$res))
        if($lnk -or $sysBad -or $arBad -or $recBad){
            Add-Type -AssemblyName System.Windows.Forms
            $r=[System.Windows.Forms.MessageBox]::Show(($global:GuardMsg -f $dn),'Usb-Guard','YesNo','Warning')
            if($r -eq 'Yes'){ Start-Process -FilePath $global:GuardBat -Verb RunAs -ArgumentList ('-Drive '+$dn.TrimEnd(':')) }
        }
    } | Out-Null
    while($true){ Start-Sleep -Seconds 3600 }
}

function Print-Status($drives){
    LB 'st.ver' $script:wSt; TN ("v{0}  " -f $VER) 'White'
    switch -regex ("$($script:upd)"){ '^ok' { T (S 'st.uptodate') 'Green' } '^new (.+)' { T (SF 'st.newver' $matches[1],$repo) 'Yellow' } '^err' { T (S 'st.upderr') 'DarkGray' } default { T (S 'st.checking') 'DarkGray' } }
    NL
    LB 'st.pc' $script:wSt
    if(-not $script:scanned){ T (S 'st.scanning') 'DarkGray' } elseif($script:pcFound.Count -eq 0){ T (S 'st.pcclean') 'Green' } else { T $(if($script:pcFound.Count -eq 1){ S 'st.pcdirty1' } else { SF 'st.pcdirty' $script:pcFound.Count }) 'Red' }
    NL
    LB 'st.av' $script:wSt
    $dv="$($script:def)"; $dn=''; if($dv -match '\|'){ $a=$dv.Split('|',2); $dv=$a[0]; $dn=$a[1] }
    if($dn.Length -gt 28){ $dn=$dn.Substring(0,28) }
    switch ($dv){
        'on'  { TN (S 'st.avon') 'Green'; if($dn){ TN ("   ({0})" -f $dn) 'DarkGray' } }
        'off' { TN (S 'st.avoff') 'Red'; if($dn){ TN ("   ({0})" -f $dn) 'DarkGray' } }
        'na'  { TN (S 'st.avna') 'DarkGray' }
        default { TN (S 'st.checking') 'DarkGray' }
    }
    NL
    NL
    if($drives.Count -eq 0){ T (S 'st.nousb') 'DarkYellow' }
    else{
        T (S 'st.usblist') 'Yellow'; NL
        foreach($v in $drives){
            $lbl=if($v.VolumeName){ $v.VolumeName } else { (S 'st.nolabel') }; if($lbl.Length -gt 18){ $lbl=$lbl.Substring(0,18) }
            $gb=[math]::Round($v.Size/1GB,1)
            $root="$($v.DeviceID)\"
            $imm=Immunity-State $root "$($v.VolumeName)"
            $inf=(Inspect-Drive $root "$($v.VolumeName)").Infected
            TN ('    {0}  ' -f $v.DeviceID) 'White'; TN 'USB  ' $ACC; TN ('{0,-18} ' -f $lbl) 'Gray'; TN ('{0,6} GB   ' -f $gb) 'DarkGray'
            if($inf){ T (S 'st.wormtrace') 'Red' } elseif($imm -eq 'full'){ T (S 'st.guarded') 'Green' } elseif($imm -eq 'part'){ T (S 'st.partial') 'DarkYellow' } else { T (S 'st.unprot') 'Yellow' }
        }
    }
    NL
}
function Print-AdvStatus($installed,$wsh,$dx){
    T (S 'adv.head') $ACC2; NL
    LB 'adv.watcher' $script:wAdv 'DarkGray'; if($installed){ T (S 'adv.on') 'Green' } else { T (S 'adv.off') 'DarkYellow' }
    NL
    LB 'adv.wsh' $script:wAdv 'DarkGray'; if($wsh){ T (S 'adv.wshon') 'DarkYellow' } else { T (S 'adv.wshoff') 'Green' }
    NL
    LB 'adv.dx' $script:wAdv 'DarkGray'; if($dx){ T (S 'adv.dxoff') 'Green' } else { T (S 'adv.dxon') 'DarkYellow' }
    NL
    LB 'adv.lang' $script:wAdv 'DarkGray'; T $(if($script:LANG -eq 'en'){ 'English' } else { 'Türkçe' }) 'Gray'
    NL
    LB 'adv.ign' $script:wAdv 'DarkGray'; T ("{0}" -f @(Get-Ignored).Count) 'Gray'
    NL
}
function PadW($s){ $pw=$W+4; if($s.Length -gt $pw){ return $s.Substring(0,$pw) }; return $s.PadRight($pw) }
function Row($s,$fg='Gray',$bg=$null){ Write-Host $script:M -NoNewline; if($bg){ Write-Host (PadW $s) -ForegroundColor $fg -BackgroundColor $bg } else { Write-Host (PadW $s) -ForegroundColor $fg }; $script:bol=$true }
function Fit-Rows { try{ $need=[Console]::CursorTop+2; $raw=$Host.UI.RawUI; if($need -gt $raw.WindowSize.Height -and $need -le $raw.MaxPhysicalWindowSize.Height){ Fit-Window $need; return $true } }catch{}; return $false }
function Open-Url($u){ try{ Start-Process $u }catch{} }
function Show-Help($it){
    Clear-Host; Print-Banner
    T ('  [ '+$it.Text+' ]') $ACC2; NL
    foreach($l in @($it.Help -split "`n")){ T ('  '+$l) 'Gray' }
    Pause-Key
}
function Help-For($a){
    switch($a){
        'scanpc'    { S 'help.scanpc' }
        'fixall'    { S 'help.fixall' }
        'fix'       { S 'help.fix' }
        'adv'       { S 'help.adv' }
        'back'      { S 'help.back' }
        'install'   { S 'help.install' }
        'uninstall' { S 'help.uninst' }
        'wshoff'    { S 'help.wshoff' }
        'wshon'     { S 'help.wshon' }
        'dxoff'     { S 'help.dxoff' }
        'dxon'      { S 'help.dxon' }
        'restoreq'  { S 'help.restoreq' }
        'ignclear'  { S 'help.ignclear' }
        'copyC'     { S 'help.copyc' }
        'copyUsb'   { S 'help.copyusb' }
        'lang'      { S 'help.lang' }
        'exit'      { S 'help.exit' }
        default     { S 'help.none' }
    }
}
function Check-Update {
    try{
        [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
        $rq=[Net.HttpWebRequest]::Create("https://api.github.com/repos/$repo/releases/latest"); $rq.Timeout=4000; $rq.UserAgent='USB-Guard'
        $rs=$rq.GetResponse(); $sr=New-Object IO.StreamReader($rs.GetResponseStream()); $j=$sr.ReadToEnd(); $sr.Close(); $rs.Close()
        $tag=[regex]::Match($j,'"tag_name"\s*:\s*"v?([\d.]+)"').Groups[1].Value
        if(-not $tag){ return 'err' }
        if([version]$tag -le [version]$VER){ return 'ok' }
        $rxh='(?i)(?<![0-9a-f])([0-9a-f]{64})(?![0-9a-f])'
        $bi=$j.IndexOf('"body"')
        $want=if($bi -ge 0){ [regex]::Match($j.Substring($bi),$rxh).Groups[1].Value } else { '' }
        if(-not $want){ $want=[regex]::Match($j,$rxh).Groups[1].Value }
        if(-not $want){ return "new $tag" }
        $src=Get-BatSource; if(-not $src){ return "new $tag" }
        $tmp="$src.new"
        $rq=[Net.HttpWebRequest]::Create("https://github.com/$repo/releases/latest/download/USB-Guard.bat"); $rq.Timeout=15000; $rq.UserAgent='USB-Guard'; $rq.AllowAutoRedirect=$true
        $rs=$rq.GetResponse()
        if($rs.ResponseUri.Scheme -ne 'https' -or $rs.ResponseUri.Host -notmatch '(?i)(^|\.)(github\.com|githubusercontent\.com)$'){ $rs.Close(); return 'err' }
        $fs=[IO.File]::Create($tmp); $rs.GetResponseStream().CopyTo($fs); $fs.Close(); $rs.Close()
        $got=[BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([IO.File]::ReadAllBytes($tmp))).Replace('-','')
        $txt=[IO.File]::ReadAllText($tmp)
        if($got -ne $want.ToUpper() -or $txt.Length -lt 5000 -or $txt -notmatch 'USB-Guard'){ Remove-Item -LiteralPath $tmp -Force; return "new $tag" }
        if((Test-Path -LiteralPath $batInstalled) -and $batInstalled -ne $src){ Copy-Item -LiteralPath $tmp -Destination $batInstalled -Force }
        return "apply $tag"
    }catch{ return 'err' }
}
function Apply-Update($tag){
    $src=Get-BatSource; $tmp="$src.new"
    try{
        $bk=Join-Path $base 'backup'
        [IO.Directory]::CreateDirectory($bk) | Out-Null
        Copy-Item -LiteralPath $src -Destination (Join-Path $bk ("USB-Guard-v{0}.bat" -f $VER)) -Force
    }catch{}
    Write-Host ''; T (SF 'st.updating' $tag) 'Green'
    Start-Sleep -Milliseconds 800
    $cmd="timeout /t 2 /nobreak >nul & move /y `"$tmp`" `"$src`" & start `"`" `"$src`""
    Start-Process cmd.exe -ArgumentList ('/c '+$cmd) -WindowStyle Hidden
    exit
}
function Get-AvStatus {
    try{
        $av=@(Get-CimInstance -Namespace 'root/SecurityCenter2' -ClassName AntiVirusProduct -EA Stop)
        if($av.Count -gt 0){
            foreach($a in $av){ $hex='{0:X6}' -f [int]$a.productState; if($hex.Substring(2,2) -match '^(10|11)$'){ return ('on|'+$a.displayName) } }
            return ('off|'+$av[0].displayName)
        }
    }catch{}
    try{ if((Get-MpComputerStatus -EA Stop).RealTimeProtectionEnabled){ return 'on|Microsoft Defender' } else { return 'off|Microsoft Defender' } }catch{}
    try{ $sv=Get-Service WinDefend -EA Stop; if($sv.Status -eq 'Running'){ return 'on|Microsoft Defender' } }catch{}
    return 'na'
}
function Start-Bg {
    try{
        $self=Get-BatSource
        if(-not $self){ throw 'no source' }
        $ps=[PowerShell]::Create(); [void]$ps.AddScript('param($p) & ([scriptblock]::Create([IO.File]::ReadAllText($p))) -Bg').AddArgument($self)
        $script:bgJob=@{Ps=$ps; H=$ps.BeginInvoke()}
    }catch{ $script:bgJob=$null; $script:upd='err'; $script:scanned=$true }
}
function Poll-Bg {
    if(-not $script:bgJob){ return $false }
    if(-not $script:bgJob.H.IsCompleted){ return $false }
    $r=@(); try{ $r=@($script:bgJob.Ps.EndInvoke($script:bgJob.H) | Where-Object { $_ -is [hashtable] } | Select-Object -Last 1) }catch{}
    try{ $script:bgJob.Ps.Dispose() }catch{}; $script:bgJob=$null
    if($r.Count -gt 0){ $h=$r[0]; $script:upd="$($h.Upd)"; $script:def="$($h.Def)"; $script:pcFound=@($h.Found | Where-Object { $_ }) } else { $script:upd='err'; $script:def='na' }
    $script:scanned=$true
    if($script:upd -match '^apply (.+)'){ Apply-Update $matches[1] }
    return $true
}
function Render-Items($items,$idx,$top,$esc,$hasLeft=$false){
    [Console]::SetCursorPosition(0,$top)
    for($i=0;$i -lt $items.Count;$i++){
        $it=$items[$i]
        if($it.Action -eq 'sep'){
            $txt=if($it.Text -eq '---'){ '  '+('-'*$W) } else { '    '+$it.Text }
            Row $txt 'DarkGray'
        }
        elseif($i -eq $idx){ Row ('  > '+$it.Text) 'Black' $ACC }
        elseif($it.Hot){ Row ('    '+$it.Text) 'Red' }
        else{ Row ('    '+$it.Text) 'Gray' }
        Row ''
    }
    $hint=if($hasLeft){ (S 'hint.sub') } else { (SF 'hint.main' $esc) }
    Row $hint 'DarkGray'
}
function Add-Help($items){ foreach($it in $items){ if($it.Action -ne 'sep'){ $it.Help=Help-For $it.Action } }; return $items }
function Build-Items($drives){
    $items=@()
    $dirty=$script:pcFound.Count -gt 0
    if($dirty){ $items += @{Text=(S 'mn.cleanpc'); Action='scanpc'; Hot=$true} }
    if($drives.Count -gt 1){ $items += @{Text=(S 'mn.fixall'); Action='fixall'} }
    foreach($d in $drives){ $lbl=if($d.VolumeName){$d.VolumeName}else{(S 'st.nolabel')}; $items += @{Text=(SF 'mn.fix' $d.DeviceID,$lbl); Action='fix'; Drive=$d} }
    if($items.Count -gt 0){ $items += @{Text='---'; Action='sep'} }
    if(-not $dirty){ $items += @{Text=(S 'mn.scanpc'); Action='scanpc'} }
    $items += @{Text=(S 'mn.copyc'); Action='copyC'}
    if($drives.Count -eq 1){
        $lbl=if($drives[0].VolumeName){$drives[0].VolumeName}else{(S 'st.nolabel')}
        $items += @{Text=(SF 'mn.copyusb1' $drives[0].DeviceID,$lbl); Action='copyUsb'}
    }
    elseif($drives.Count -gt 1){ $items += @{Text=(S 'mn.copyusbn'); Action='copyUsb'} }
    $items += @{Text='---'; Action='sep'}
    $items += @{Text=(S 'mn.adv'); Action='adv'}
    $items += @{Text=(S 'mn.exit'); Action='exit'}
    return (Add-Help $items)
}
function Build-AdvItems($drives,$installed,$wsh,$dx,$hasQ){
    $items=@()
    if($installed){ $items += @{Text=(S 'mn.watrem'); Action='uninstall'} } else { $items += @{Text=(S 'mn.watinst'); Action='install'} }
    if($wsh){ $items += @{Text=(S 'mn.wshoff'); Action='wshoff'} } else { $items += @{Text=(S 'mn.wshon'); Action='wshon'} }
    if($dx){ $items += @{Text=(S 'mn.dxon'); Action='dxon'} } else { $items += @{Text=(S 'mn.dxoff'); Action='dxoff'} }
    if($hasQ){ $items += @{Text=(S 'mn.restoreq'); Action='restoreq'} }
    $ignN=@(Get-Ignored).Count
    if($ignN -gt 0){ $items += @{Text=(SF 'mn.ignclear' $ignN); Action='ignclear'} }
    $items += @{Text=(S 'mn.lang'); Action='lang'}
    $items += @{Text='---'; Action='sep'}
    $items += @{Text=(S 'mn.back'); Action='back'}
    return (Add-Help $items)
}
function Menu-Loop($items,$escAction,$escText,$leftAction=$null){
    $idx=0; while($items[$idx].Action -eq 'sep'){ $idx++ }
    $top=[Console]::CursorTop
    $hasLeft=[bool]$leftAction
    try{ [Console]::CursorVisible=$false }catch{}
    Render-Items $items $idx $top $escText $hasLeft
    if(Fit-Rows){ return @{Action='redraw'} }
    while($true){
        Render-Items $items $idx $top $escText $hasLeft
        while(-not [Console]::KeyAvailable){ Start-Sleep -Milliseconds 120; if(Poll-Bg){ return @{Action='redraw'} } }
        $k=[Console]::ReadKey($true)
        switch($k.Key){
            'UpArrow'   { do{ $idx=($idx-1+$items.Count)%$items.Count }while($items[$idx].Action -eq 'sep') }
            'DownArrow' { do{ $idx=($idx+1)%$items.Count }while($items[$idx].Action -eq 'sep') }
            'Enter'     { try{ [Console]::CursorVisible=$true }catch{}; return $items[$idx] }
            'Escape'    { try{ [Console]::CursorVisible=$true }catch{}; return @{Action=$escAction} }
            'RightArrow'{ return @{Action='help'; Item=$items[$idx]} }
            'LeftArrow' { if($leftAction){ try{ [Console]::CursorVisible=$true }catch{}; return @{Action=$leftAction} } }
            'G'         { Open-Url "https://github.com/$repo" }
            'S'         { Open-Url 'https://github.com/sponsors/Teknesyum' }
        }
    }
}
function Pick-List($title,$opts){
    Clear-Host; Print-Banner
    T ('  '+$title) $ACC2; NL
    $items=@(); foreach($o in $opts){ $items += @{Text=$o.Text; Action='pick'; Val=$o.Val} }
    $items += @{Text=(S 'mn.back'); Action='back'}
    $go=Menu-Loop $items 'back' (S 'mn.backword') 'back'
    if($go.Action -eq 'pick'){ return $go.Val }
    return $null
}
function Pick-Usb($drives){
    $opts=@()
    if($drives.Count -gt 1){ $opts += @{Text=(S 'pick.allusb'); Val=$drives} }
    foreach($d in $drives){ $lbl=if($d.VolumeName){$d.VolumeName}else{(S 'st.nolabel')}; $opts += @{Text=('{0}  {1}' -f $d.DeviceID,$lbl); Val=@($d)} }
    return (Pick-List (S 'pick.usb') $opts)
}
function Restore-Quarantine($q){
    $mf=Join-Path $q 'manifest.txt'; if(-not (Test-Path -LiteralPath $mf)){ return -1 }
    $n=0
    foreach($line in @(Get-Content -LiteralPath $mf -Encoding UTF8 | Where-Object { $_ -match '\|' })){
        $a=$line.Split('|',2); $src=$a[0]; $dst=$a[1]
        if(-not (Test-Path -LiteralPath $src)){ continue }
        $dir=Split-Path $dst -Parent; if(-not (Test-Path -LiteralPath $dir)){ continue }
        if(Test-Path -LiteralPath $dst){ $i=2; $stem=[IO.Path]::GetFileNameWithoutExtension($dst); $ext=[IO.Path]::GetExtension($dst); do{ $dst=Join-Path $dir ("{0} ({1}){2}" -f $stem,$i,$ext); $i++ }while(Test-Path -LiteralPath $dst) }
        try{ Move-Item -LiteralPath $src -Destination $dst -Force -EA Stop; $n++ }catch{}
    }
    $left=@(Get-ChildItem -LiteralPath $q -Force -EA SilentlyContinue | Where-Object { $_.Name -ne 'manifest.txt' })
    if($left.Count -eq 0){ Remove-Item -LiteralPath $q -Recurse -Force -EA SilentlyContinue }
    return $n
}
function Restore-Menu {
    $qs=@(Get-ChildItem -LiteralPath (Join-Path $base 'quarantine') -Directory -EA SilentlyContinue | Sort-Object Name -Descending)
    $opts=@()
    foreach($d in $qs){ $c=@(Get-ChildItem -LiteralPath $d.FullName -Force -EA SilentlyContinue | Where-Object { $_.Name -ne 'manifest.txt' }).Count; if($c -gt 0){ $opts += @{Text=(SF 'rq.items' $d.Name,$c); Val=$d.FullName} } }
    if($opts.Count -eq 0){ Clear-Host; Print-Banner; T (S 'rq.empty') 'DarkYellow'; Pause-Key; return }
    $q=Pick-List (S 'pick.quar') $opts
    if(-not $q){ return }
    Clear-Host; Print-Banner; T (S 'rq.head') $ACC2; NL
    T ('  '+$q) 'Gray'; NL
    foreach($f in @(Get-ChildItem -LiteralPath $q -Force -EA SilentlyContinue | Where-Object { $_.Name -ne 'manifest.txt' })){ T ('    '+$f.Name) 'Yellow' }
    Write-Host ''; TN (S 'rq.ask') 'Yellow'
    $ans=[Console]::ReadLine()
    if($ans -notmatch '(?i)^[ey]'){ Write-Host ''; T (S 'rq.cancel') 'DarkYellow'; Pause-Key; return }
    $n=Restore-Quarantine $q
    NL
    if($n -lt 0){ T (S 'rq.nomanifest') 'DarkYellow' }
    else{ T (SF 'rq.done' $n) 'Green' }
    Pause-Key
}
function Choose-Lang {
    Clear-Host; Print-Banner
    T '  Language / Dil' $ACC2; NL
    $codes=@('en','tr'); $names=@('English','Türkçe')
    $i=if($script:LANG -eq 'en'){ 0 } else { 1 }
    $top=[Console]::CursorTop
    try{ [Console]::CursorVisible=$false }catch{}
    while($true){
        [Console]::SetCursorPosition(0,$top)
        for($n=0;$n -lt $codes.Count;$n++){
            $line=("{0}  {1}" -f ($n+1),$names[$n])
            if($n -eq $i){ Row ('  > '+$line) 'Black' $ACC } else { Row ('    '+$line) 'Gray' }
            Row ''
        }
        Row '  1/2 or arrows, Enter   /   1/2 ya da oklar, Enter' 'DarkGray'
        $k=[Console]::ReadKey($true)
        $ch="$($k.KeyChar)"
        if($ch -eq '1'){ $i=0 }
        elseif($ch -eq '2'){ $i=1 }
        elseif($k.Key -eq 'UpArrow' -or $k.Key -eq 'DownArrow'){ $i=($i+1)%$codes.Count; continue }
        elseif($k.Key -ne 'Enter'){ continue }
        try{ [Console]::CursorVisible=$true }catch{}
        Set-Lang $codes[$i]; Save-Lang $codes[$i]; return
    }
}
function Run-Menu {
    try{ [Console]::CursorVisible=$false }catch{}
    Clear-Host; Print-Banner; Start-Bg
    $view='main'
    while($true){
        $script:usbBus=Get-UsbLogical
        $all=Get-CimInstance Win32_LogicalDisk -Filter "DriveType=2 OR DriveType=3" | Sort-Object DeviceID
        $drives=@($all | Where-Object { Eligible $_ })
        $installed=(Test-WatcherTask) -or ((Get-ItemProperty -Path $runKey -Name $runName -EA SilentlyContinue) -ne $null)
        $wsh=Test-Wsh; $dx=Test-DenyExec
        $hasQ=(@(Get-ChildItem -LiteralPath (Join-Path $base 'quarantine') -Directory -EA SilentlyContinue).Count -gt 0)
        Clear-Host; Print-Banner
        if($view -eq 'adv'){ Print-AdvStatus $installed $wsh $dx; $items=Build-AdvItems $drives $installed $wsh $dx $hasQ; $go=Menu-Loop $items 'back' (S 'mn.backword') 'back' }
        else{ Print-Status $drives; $items=Build-Items $drives; $go=Menu-Loop $items 'exit' (S 'mn.exit') }
        switch($go.Action){
            'redraw'    { }
            'adv'       { $view='adv' }
            'back'      { $view='main' }
            'help'      { Show-Help $go.Item }
            'exit'      { Clear-Host; Print-Banner; Show-Footer; return }
            'fixall'    { Clear-Host; Print-Banner; foreach($d in $drives){ Process-Drive $d }; Pause-Key }
            'fix'       { Clear-Host; Print-Banner; Process-Drive $go.Drive; Pause-Key }
            'install'   { Clear-Host; Print-Banner; Install-Watcher; Pause-Key }
            'uninstall' { Clear-Host; Print-Banner; Uninstall-Watcher; Pause-Key }
            'wshoff'    { Clear-Host; Print-Banner; Toggle-Wsh $false; Pause-Key }
            'wshon'     { Clear-Host; Print-Banner; Toggle-Wsh $true; Pause-Key }
            'dxoff'     { Clear-Host; Print-Banner; Toggle-DenyExec $true; Pause-Key }
            'dxon'      { Clear-Host; Print-Banner; Toggle-DenyExec $false; Pause-Key }
            'restoreq'  { Restore-Menu }
            'ignclear'  { Clear-Ignored; $script:pcFound=@(Find-PcRemnants) }
            'lang'      { Choose-Lang }
            'scanpc'    { Clear-Host; Print-Banner; Scan-Pc; $script:scanned=$true; Pause-Key }
            'copyC'     { Clear-Host; Print-Banner; Copy-ToC; Pause-Key }
            'copyUsb'   { if($drives.Count -eq 1){ Clear-Host; Print-Banner; Copy-ToUsb $drives; Pause-Key } else { $sel=Pick-Usb $drives; if($sel){ Clear-Host; Print-Banner; Copy-ToUsb $sel; Pause-Key } } }
        }
    }
}

$script:savedLang = Get-Lang
Set-Lang $(if($script:savedLang){ $script:savedLang } else { 'tr' })

if($Watch){ Start-Watcher; return }
if($Bg){
    $f=@(Find-PcRemnants)
    $d=Get-AvStatus
    @{Upd=(Check-Update);Def=$d;Found=$f}
    return
}

Migrate-Base
Fit-Window
if(-not $script:savedLang -and -not $Drive){ Choose-Lang }
if($Drive){
    Clear-Host; Print-Banner
    $letter=$Drive.TrimEnd(':').Substring(0,1).ToUpper()
    if("$letter`:" -eq $env:SystemDrive){ T (S 'dr.sysdrive') 'Red'; Pause-Key; return }
    $dsk=Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$letter`:'"
    if(-not $dsk){ T (SF 'dr.notfound' "$letter`:") 'Red'; Pause-Key; return }
    Process-Drive $dsk
    Show-Footer; Pause-Key; return
}

Run-Menu
