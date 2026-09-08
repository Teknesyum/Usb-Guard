# 003 — Teknik Analiz ve v1.7 Kararları

Tarih: 2026-09-08. Kaynak: usb-guard.ps1 v1.6 (547 satır) + USB-Guard.bat başlatıcı.
Ölçüt: basit, etkili, geri alınabilir, düşük efor. "Saçma" dediğin için yapılmayanlar en altta.


## Bulgular

### A. Hatalar (düzeltildi)

1. **Türkçe karakter.** Bat, betiği `WriteAllText` ile BOM'suz yazıyor; PowerShell 5.1 BOM'suz
   dosyayı ANSI (cp1254) okuyor, `ş ğ ı` bozuluyor. Çözüm: BOM'lu UTF-8 yaz (tek argüman).

2. **Veri kaybı riski — Restore-Hidden.** Gizli klasördeki bir öğe kökte aynı adla varsa
   taşınmıyor, ardından klasör `Nuke-Path` ile siliniyor → taşınmayan dosya gidiyor. Çözüm:
   çakışan ad ` (2)` eki alır, klasör yalnız boşalınca silinir; boşalmayan klasör görünür
   yapılıp yerinde bırakılır. Ayrıca `Spin($label,$sb)` parametresi çağıran fonksiyonun
   `$label`'ını gölgeliyordu; `sysvolume\<etiket>` geri taşıma hiç çalışmıyordu, `rapor.txt`
   sentetik testte kayboldu. Parametreler `$spText/$spBlock` oldu; test yeşil.

3. **Yanlış pozitif — "Solucan İzi".** Kökte herhangi bir `.lnk` olması enfekte sayılıyordu;
   kullanıcının kendi kısayolu da kırmızıya boyanıyordu. Çözüm: hedef+argüman `$lnkRx` ile
   eşleşen ya da adı etiketle/gizli klasörle aynı olan `.lnk` sayılır.

4. **Get-Volume bağımlılığı.** Storage modülü olmayan makinede etiket ve FS boş dönüyordu.
   Çözüm: `Win32_LogicalDisk.VolumeName/FileSystem` kullanılır, modül gerekmez.

5. **USB HDD / büyük bellekler görünmüyor.** `DriveType=3` (sabit) bildiren USB diskler
   listelenmiyordu. Çözüm: sabit diskler için `Get-Disk.BusType -eq 'USB'` kontrolü.

### B. Solucan benzerleri — ucuz kapsam genişletme (yapıldı)

Kısayol solucanı aileleri (Jenxcus/Houdini, Dinihou, Bondat, Vjw0rm, Gamarue, PrintMiner)
ve klasör-ikonu solucanları incelendi. Ortak teknikler ve durumumuz:

| Teknik | v1.6 | v1.7 |
| --- | --- | --- |
| Tek `<etiket>.lnk`, dosyalar `sysvolume\<etiket>` altında | ✔ | ✔ |
| Dosya başına `.lnk` (`cmd /c start x.vbs & start dosya`) | ✔ silme | ✔ |
| Dosyalar kökte gizli+sistem (klasörsüz) | ✔ unhide | ✔ |
| Dosyalar `_`, ` `, `recycle.bin` gibi gizli klasörde | kısmi | ✔ tüm gizli kök klasörleri (SVI ve $RECYCLE.BIN hariç) |
| Yük dosyası kökte gizli `.vbs .js .bat .hta .scr .pif .com` | ✘ | ✔ karantina |
| Klasör-ikonu solucanı: gizli klasörle aynı adlı `.exe` | ✘ | ✔ karantina |
| `autorun.inf` dosyası | ✔ | ✔ |
| PC: Run/RunOnce, Startup, görev, servis, Winlogon | ✔ | ✔ |
| PC: HKCU Winlogon Shell (kullanıcı kabuğu değişimi) | ✘ | ✔ |
| PC: IFEO `Debugger` (taskmgr/regedit/cmd/msconfig ele geçirme) | ✘ | ✔ |
| PC: `AppInit_DLLs` | ✘ | ✔ |

USB yükü artık silinmiyor, `%LOCALAPPDATA%\Usb-Guard\quarantine\<tarih>-usb-<harf>` altına
taşınıyor; PC temizliğiyle aynı ilke.

### C. Basit ve etkili önlem (yapıldı, menüde isteğe bağlı)

**Windows Script Host'u kapat.** VBS/JS solucanlarının tamamı `wscript.exe` ile çalışır.
`HKLM\Software\Microsoft\Windows Script Host\Settings\Enabled=0` tek kayıtla bunu keser;
kısayola tıklansa bile yük çalışmaz. Yan etki: meşru `.vbs` betikleri (bazı yazıcı kurulumları,
kurumsal logon betikleri) de çalışmaz. Bu yüzden zorunlu değil, menüden aç/kapa; durum
satırında görünür.

### D. Arayüz (istendi, yapıldı)

Pencere 80×34, Consolas 20, kutu 60 karakter, tüm metinler Türkçe karakterli.


## Yapılmayanlar ve nedeni

- **Antivirüs imza tabanı / heuristik motor.** Kapsam dışı; README'de zaten "antivirüs değil".
- **WMI event subscription, COM hijack, DLL side-load taraması.** USB solucanlarında nadir,
  yanlış pozitif riski yüksek, efor büyük.
- **Autorun'ı kapatma (`NoDriveTypeAutoRun`).** Windows 7+ zaten USB autorun'ı kapalı;
  kazanım yok.
- **Gizli dosya / uzantı gösterimini zorla açma.** Kullanıcı tercihi; sabotaj değilse
  dokunulmaz. (SHOWALL bozulması zaten yakalanıyor.)
- **Gerçek zamanlı koruma / sürücü.** Tek bat felsefesine aykırı.


## Test

Kayıtlar: `docs/danisma/003-test-cikti.txt` (sentetik USB + PC taraması + bat çözme).

- Temiz makinede PC taraması (IFEO / AppInit / HKCU Shell dahil): 0 bulgu.
- Sentetik USB (`subst X:`): gizli `_` (belge.docx, çakış.txt, Alt\) + gizli `x.vbs` +
  `belge.docx.lnk` (`cmd /c start x.vbs`) + gizli `Fotoğraflar` + `Fotoğraflar.exe` taklidi +
  meşru `mylink.lnk` + `sysvolume\TESTUSB\rapor.txt` + `sysvolume\u123456.vbs` + `autorun.inf`.
  Sonuç: zararlı lnk silindi, meşru lnk kaldı; belge.docx, Alt\, rapor.txt, Fotoğraflar köke
  döndü; x.vbs, u123456.vbs, Fotoğraflar.exe karantinada; `_` ve sysvolume kaldırıldı;
  5 ad aşılandı; yeniden Inspect → Infected=False.
- Çakışma: kökte `çakış.txt` varken içerideki `çakış (2).txt` olarak köke geldi, içerik korundu.
- bat → ps1 çözme: BOM var, sürüm 1.7, çıkan dosya kaynakla bayt bayt aynı; roundtrip True.
