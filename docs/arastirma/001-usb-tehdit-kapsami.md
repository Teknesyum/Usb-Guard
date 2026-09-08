# 001 — USB Tehdit Kapsamı ve Boşluk Analizi

Tarih: 2026-09-09. Sürüm: v1.16. Soru: "her türlü USB virüsüne karşı koruma" için ne eksik?
Yöntem: güncel tehdit raporları okundu, her ailenin bıraktığı iz `src/usb-guard.ps1` içindeki
tespit yüzeyiyle satır satır karşılaştırıldı. Kaynaklar en altta.


## Bugün taradığımız yüzey

USB tarafı (`Inspect-Drive`, satır 648):

- Kök + `-Recurse -Depth 2` içindeki `.lnk`, hedefi `$lnkRx` ile eşleşiyorsa
  (`wscript|cscript|mshta|powershell|rundll32|cmd |/c |sysvolume|.vbs .js .wsf .bat .cmd .hta .ps1`)
- Sürücü etiketiyle ya da gizli bir klasörle **aynı adı taşıyan** `.lnk`
- Gizli/sistem betik yükleri: `vbs vbe js jse wsf hta bat cmd scr pif com`
- Klasör adını taklit eden, gizli olan ya da çift uzantılı `exe scr pif com`
- Kutu klasörler: `_`, boşluk, ≤3 sembol, `recycle.bin`, `$recycle.bin`, `sysvolume`,
  etiket adı, ya da kötü bir `.lnk` argümanında adı geçen gizli klasör
- `autorun.inf`, `recycler`, `recycled`, `sysvolume` → temizlik + kilitli aşı

PC tarafı: süreçler, Run/RunOnce, Başlangıç klasörü, görevler, servisler, madenci dosyaları,
`Temp/AppData/ProgramData/Public/UserProfile` altında **bir seviye** betik taraması,
Defender `Exclusions\Paths`, Explorer sabotajı.


## Aile aile karşılaştırma

| Aile | Bıraktığı iz | Bizde | Not |
| --- | --- | --- | --- |
| **Jenxcus / Houdini / Vjw0rm / Bladabindi** (klasik VBS solucanı) | Klasör adında `.lnk` + gizli `.vbs`, her klasöre kopya | ✔ | Ana senaryomuz |
| **Gamarue / Andromeda** | `.lnk` → `rundll32` + gizli DLL | ✔ kısmi | `.lnk` yakalanır, **DLL karantinaya alınmaz** |
| **Raspberry Robin** | 2–5 harfli `.lnk` → `cmd /R <`, yük `.swy .chk .ico .usb .cfg` | ✔ kısmi | `.lnk` silinir, **yük dosyası sürücüde kalır** |
| **PlugX / Mustang Panda** | Gizli `RECYCLER.BIN` + `desktop.ini` (CLSID ile Geri Dönüşüm gibi görünür), içinde meşru imzalı exe + kötü DLL + `.dat` | ✘ **büyük boşluk** | `RECYCLER.BIN` kutu listesinde yok; `.lnk` hedefi imzalı exe olduğu için `$lnkRx` de patlamaz |
| **CryptoBandits** (Haziran 2026, kripto clipper) | USB'de gerçek `.doc/.xlsx/.pdf` gizlenir, aynı adla `.lnk`; PC'de `C:\Users\Public\Documents\<5 harf>\<5 harf>.js` + `.xml`, iki zamanlanmış görev, Tor'un adı `ugate.exe`, localhost:9050 | ✔ kısmi | USB tarafı tamam; **PC tarafında `Public\Documents\<klasör>` bizim tarama derinliğimizin bir altında kalıyor** |
| **Sality / Ramnit** | Dosya bulaştıran (infector), USB'ye `.lnk` + gizli exe | ✔ kısmi | Damla temizlenir, **bulaşmış exe'ler onarılmaz** — antivirüs işi, kapsam dışı |
| **autorun.inf klasikleri** | `autorun.inf` + exe | ✔ | Aşı da var |
| **BadUSB / HID (Rubber Ducky)** | Dosya yok; aygıt kendini klavye gösterip yazıyor | ✘ | Dosya tabanlı hiçbir araç göremez; savunması `Device Installation Restrictions` GPO'su. **Kapsam dışı, README'de açıkça yazmalı** |
| **ISO / IMG / VHD taşıyıcı** | Sürücüde imaj dosyası, çift tıkta bağlanır ve MotW'yi kırar | ✘ | Nadiren USB solucanı; düşük öncelik |


## Somut boşluklar

1. **`RECYCLER.BIN` kutusu tanınmıyor.** `$containerRx` (satır 675) `recycle\.bin` ve
   `\$recycle\.bin\.?` içeriyor; PlugX'in kullandığı `RECYCLER.BIN` **eşleşmiyor**.
   Ayrıca klasörü Geri Dönüşüm Kutusu gibi gösteren `desktop.ini` hiç kontrol edilmiyor.

2. **DLL yükleri karantinaya alınmıyor.** `$payloadExt` (satır 35) `.dll` ve `.dat`
   içermiyor. PlugX ve Gamarue tam olarak bunu kullanıyor: meşru imzalı exe + kötü DLL.
   `Restore-Hidden` gizli klasörü boşaltırken bu ikisini kullanıcının köküne çıkarıyor.

3. **Tarama derinliği 2.** `Inspect-Drive` `-Depth 2` ile duruyor; Jenxcus her klasöre
   kopyalıyor, dolu bir bellekte 3. seviye sık.

4. **`C:\Users\Public\Documents\<klasör>` görülmüyor.** `Find-Scripts` köklerin **bir**
   alt seviyesini geziyor. CryptoBandits'in yolu iki seviye aşağıda.

5. **Defender istisnaları eksik okunuyor.** Yalnız `Exclusions\Paths` bakılıyor;
   `Exclusions\Extensions` ve `Exclusions\Processes` yok. Desende `\Users\Public\` de yok.

6. **Raspberry Robin yükü sürücüde kalıyor.** Kötü `.lnk` silindikten sonra
   `cmd /R < xxx.swy` hedefindeki dosya duruyor; kullanıcı elle çift tıklarsa yeniden bulaşır.

7. **Explorer'ın "gizli dosyaları göster" değeri.** `SHOWALL\CheckedValue` bakılıyor ama
   kullanıcının kendi `Advanced\Hidden` ve `ShowSuperHidden` değerleri bakılmıyor; solucan
   bunları 2/0 yapıp kendini görünmez tutuyor.

8. **`.url` ve `.scf`** yük listesinde yok — ikisi de çift tıkla dış hedef çalıştırabiliyor.


## Öneri: v1.17 paketi

| # | İş | Boşluk | Tahmini |
| --- | --- | --- | --- |
| 1 | `$containerRx`'e `recycler(\.bin)?`, `recycled`, `_recycle`; gizli klasörde `desktop.ini` + CLSID varsa kutu say | 1 | ~8 satır |
| 2 | Gizli klasör boşaltılırken `.dll`, `.dat`, `.bin` gizli dosyaları da karantinaya | 2 | ~4 satır |
| 3 | `-Depth 2` → `-Depth 4`, dosya sayısı tavanı ile | 3 | ~3 satır |
| 4 | Kötü `.lnk`'in argümanında adı geçen **her** dosyayı karantinaya al (uzantı bakmadan) | 6 | ~10 satır |
| 5 | `Find-Scripts` derinliği 2, `Public` altında 5 harfli klasör deseni | 4 | ~6 satır |
| 6 | `Exclusions\Extensions` + `Processes`, desene `\Users\Public\` | 5 | ~5 satır |
| 7 | `Advanced\Hidden` = 2 ve `ShowSuperHidden` = 0 sabotaj bulgusu (düzeltmesi mevcut mekanizmada zaten var) | 7 | ~5 satır |
| 8 | `$payloadExt`'e `url`, `scf` | 8 | ~1 satır |
| 9 | README'ye "yapmadıklarımız" bölümü: BadUSB/HID, dosya bulaştıranlar, imaj dosyaları | — | ~10 satır |

Toplam ~50 satır kod + README. Tek paketleme, bir test turu: sentetik USB'ye
`RECYCLER.BIN\desktop.ini` + imzalı exe + sahte dll, 3. seviyede `.lnk`, `.swy` yükü,
`.url` dosyası koyulur; `Public\Documents\abcde\abcde.js` yazılır.

**Kapsam dışı bırakılanlar** (bilerek): BadUSB/HID savunması (aygıt kurulum GPO'su, geri
alması zor, yanlış ayarda klavye kilitler), dosya bulaştıran virüslerin onarımı, ISO/VHD.


## Kaynaklar

- https://www.microsoft.com/en-us/security/blog/2026/06/17/crypto-clipper-uses-tor-worm-like-propagation-for-persistence-control/
- https://www.bleepingcomputer.com/news/security/usb-worm-spreads-crypto-stealing-malware-via-windows-shortcut-files/
- https://www.picussecurity.com/resource/blog/raspberry-robin-malware-in-2025-from-usb-worm-to-elite-initial-access-broker
- https://redcanary.com/blog/threat-intelligence/raspberry-robin/
- https://wazuh.com/blog/using-wazuh-to-detect-raspberry-robin-worms/
- https://unit42.paloaltonetworks.com/plugx-variants-in-usbs/
- https://news.sophos.com/en-us/2023/03/09/border-hopping-plugx-usb-worm/
- https://blog.sekoia.io/unplugging-plugx-sinkholing-the-plugx-usb-worm-botnet/
- https://cybersecuritynews.com/new-plugx-usb-worm-spreads/
- https://www.microsoft.com/en-us/wdsi/threats/threat-search?query=worm%3Awin32%2Fgamarue
- https://www.threatdown.com/blog/usb-worms-still-wriggling-on-to-under-protected-computers-after-all-these-years/
- https://insbug.medium.com/badusb-attack-explained-from-principles-to-practice-and-defense-3bfe88ec2eeb
- https://www.ivanti.com/blog/what-is-badusb
