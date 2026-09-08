# Girdi — USB-Guard v1.17 tespit kapsamı

## Program nedir

Tek dosya (`USB-Guard.bat`, polyglot bat/PowerShell, düz metin, ~89 KB, yönetici olarak
çalışır). İki iş yapıyor: (a) takılan USB'deki kısayol-solucanı izlerini temizleyip gizlenen
dosyaları geri çıkarır ve `autorun.inf` / `sysvolume` / `recycler` / `recycled` / etiket adlı
klasörleri **kilitli boş klasör** olarak aşılar; (b) PC'de solucan kalıntısı arar (süreç, Run
anahtarı, başlangıç klasörü, görev, servis, betik, Defender istisnası, Explorer sabotajı) ve
onay alıp temizler, dosyaları karantinaya taşır. Antivirüs değil; imza veritabanı yok,
gerçek zamanlı dosya tarayıcısı yok. Felsefe: **basit, geri alınabilir, tek dosya, okunabilir.**

## Bugünkü tespit sabitleri (v1.16, birebir)

```
$dblRx      = '(?i)\.(jpe?g|png|gif|bmp|pdf|docx?|xlsx?|pptx?|txt|mp[34]|avi|mkv|zip|rar)\.(exe|scr|pif|com)$'
$fixed      = @('sysvolume','autorun.inf','recycler','recycled')
$payloadExt = '(?i)\.(vbs|vbe|js|jse|wsf|hta|bat|cmd|scr|pif|com)$'
$lnkRx      = '(?i)sysvolume|\.(vbs|vbe|js|jse|wsf|bat|cmd|hta|ps1)\b|wscript|cscript|mshta|powershell|rundll32|cmd(\.exe)?\s|/c\s'
$keepDirs   = @('System Volume Information','$RECYCLE.BIN')
$containerRx= '(?i)^(_|\s+|[^\w]{1,3}|recycle\.bin|\$recycle\.bin\.?|sysvolume)$'
$susRx      = '(?i)\.(vbs|vbe|js|jse|wsf|hta|bat|cmd)\b|\b(wscript|cscript|mshta)(\.exe)?\b|rundll32[^"]*\(AppData|ProgramData|Temp)\|powershell[^"]*(-enc|-e |-w hidden|-windowstyle hidden|bypass)|\Temp\[^"]*\.exe|sysvolume|\Windows \|wsvcz|\u\d{6}\.(dll|dat)|\b(xmrig|svctrl64|svcinsty64)\b'
```

USB taraması: kök + `Get-ChildItem -Recurse -Depth 2 -File`. Kökte `.lnk` şu üç halden biriyle
kötü sayılır: hedefi `$lnkRx` ile eşleşir, adı sürücü etiketiyle aynı, ya da adı gizli bir
klasörle aynı. Alt klasörlerde yalnız `$lnkRx`. Gizli/sistem `$payloadExt` dosyaları ve
klasör adını taklit eden / gizli / çift uzantılı `exe|scr|pif|com` karantinaya gider.
Gizli klasör "kutu" sayılırsa (`$containerRx`, etiket adı, ya da kötü bir `.lnk`'in
argümanında adı geçiyorsa) içi köke geri çıkarılır.

PC taraması `Find-Scripts`: kökler `TEMP, APPDATA, LOCALAPPDATA, ProgramData, USERPROFILE,
PUBLIC`; her kökün **bir** alt seviyesi (en fazla 400 klasör), `.vbs .vbe .js .jse .wsf .hta`,
64 B – 500 KB, içerik iki regex birden tutmalı (`WScript.Shell|FileSystemObject|ActiveXObject|
CreateObject` **ve** `sysvolume|autorun|\.lnk|DriveType|RemovableDrive|attrib |\.Drives\b|
\Startup\|CurrentVersion\Run|\+h |\+s `).

Defender istisnaları: yalnız `HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths`,
desen `\Windows \|wsvcz|\Temp\|\AppData\|\ProgramData\|sysvolume`.

Yanlış pozitif önlemi: servis/DLL yolu Authenticode ile imzalıysa (`Get-AuthenticodeSignature`
Status=Valid) bulgu sayılmaz. Kullanıcı bir bulguyu numarasıyla **yoksayabiliyor**
(`ProgramData\Usb-Guard\ignore.txt`).

## Araştırmada çıkan boşluklar

1. **PlugX / Mustang Panda:** gizli `RECYCLER.BIN` klasörü + `desktop.ini` (CLSID ile Geri
   Dönüşüm Kutusu gibi görünür), içinde meşru **imzalı** exe + kötü DLL + `.dat` blob (DLL
   yan yükleme). `.lnk` sürücü adıyla adlandırılıyor. → `$containerRx` `RECYCLER.BIN`'i
   tanımıyor, `desktop.ini` hiç bakılmıyor, `.lnk` hedefi imzalı exe olduğu için `$lnkRx`
   patlamıyor, `.dll`/`.dat` `$payloadExt`'te yok (gizli klasör boşaltılırken **kullanıcının
   köküne çıkarılıyorlar**).
2. **Gamarue / Andromeda:** `.lnk` → `rundll32` + gizli DLL. `.lnk` yakalanıyor, DLL kalıyor.
3. **Raspberry Robin:** 2–5 harfli `.lnk`, hedef `cmd /R < xxx.swy`, yük uzantıları
   `.swy .chk .ico .usb .cfg .xml`. `.lnk` siliniyor, yük dosyası sürücüde kalıyor.
4. **CryptoBandits** (Microsoft, 17 Haziran 2026): USB'de gerçek `.doc/.xlsx/.pdf` gizlenip
   aynı adla `.lnk` bırakılıyor (bizde yakalanıyor). PC'de `C:\Users\Public\Documents\<5
   harf>\<5 harf>.js` + aynı klasörde `.xml`, iki süresiz zamanlanmış görev, Tor ikilisi
   `ugate.exe` adıyla gizli pencerede, SOCKS5 `localhost:9050`, Defender'a staging klasörü
   istisnası. → `Find-Scripts` bir seviye kısa kalıyor (`Public\Documents\omoho` görülmüyor).
5. Defender'ın `Exclusions\Extensions` ve `Exclusions\Processes` anahtarları okunmuyor;
   desende `\Users\Public\` yok.
6. `HKCU\...\Explorer\Advanced` altındaki `Hidden`=2 ve `ShowSuperHidden`=0 sabotaj olarak
   bakılmıyor (yalnız `SHOWALL\CheckedValue` bakılıyor).
7. `.url` ve `.scf` yük listesinde yok.

## Planlanan v1.17 (~50 satır)

| # | İş |
| --- | --- |
| 1 | `$containerRx`'e `recycler(\.bin)?`, `recycled`, `_recycle`; gizli klasörde `desktop.ini` + CLSID varsa kutu say |
| 2 | Gizli klasör boşaltılırken gizli `.dll`, `.dat`, `.bin` dosyaları da karantinaya |
| 3 | USB tarama derinliği `-Depth 2` → `-Depth 4` (dosya sayısı tavanı ile) |
| 4 | Kötü `.lnk`'in argümanında **adı geçen her dosyayı** uzantıya bakmadan karantinaya al |
| 5 | `Find-Scripts` derinliği 2; `Public` altında 5 harfli klasör deseni |
| 6 | `Exclusions\Extensions` + `Processes`, desene `\Users\Public\` |
| 7 | `Advanced\Hidden`=2 / `ShowSuperHidden`=0 sabotaj bulgusu |
| 8 | `$payloadExt`'e `url`, `scf` |
| 9 | README'ye "yapmadıklarımız": BadUSB/HID, dosya bulaştıranlar, ISO/VHD |

Bilerek kapsam dışı: BadUSB/HID savunması (aygıt kurulum GPO'su — yanlış ayarda klavyeyi
kilitler, geri alması zor), dosya bulaştıran virüslerin onarımı, ISO/VHD taşıyıcılar.

## Sorular

1. Bu 9 maddede **yanlış pozitif riski** taşıyan var mı? Özellikle 3 (derinlik 4), 4 (uzantıya
   bakmadan karantina) ve 1 (`desktop.ini` sezgiseli) — kullanıcının kendi dosyasını
   karantinaya alma ihtimali nedir, nasıl daraltılır?
2. Kaçırdığımız **başka bir USB bulaşma tekniği** var mı? Listemizde olmayan, gerçekten
   yaygın bir aile ya da numara.
3. Sıralama doğru mu — hangi madde en çok kullanıcıyı korur, hangisi süs?
4. "Tek dosya, basit, geri alınabilir, antivirüs değil" felsefesini zorlayan bir madde var mı?
5. Eklemek yerine **kaldırmamız** gereken bir şey var mı (aşırı geniş regex, ölü kontrol)?
