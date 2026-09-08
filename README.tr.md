<!-- lang -->

[<img src="assets/badge-lang.tr.svg" alt="Türkçe seçili, switch to English" width="124" height="44">](README.md)


<div align="center">

# USB&nbsp;·&nbsp;GUARD

### USB'yi Temizle, Aşıla, Arkasındaki PC'yi Kontrol Et

Tek, kendini yükselten `.bat`. Kurulum yok. Sürücüyü seç, temizler ve kilitler.
Menüyü aç, bu bilgisayarın enfekte olup olmadığını söyler.

</div>

İlk açılışta dil sorulur: İngilizce için **1**, Türkçe için **2**. Seçim kaydedilir, bir daha
sorulmaz; **Gelişmiş Seçenekler** altından istediğin zaman değiştirilir. Her menü maddesinin
sağ ok tuşunda, seçtiğin dilde bir yardım sayfası vardır.


---


## USB'ne Ne Oldu


Dosyaların yok. Yerlerinde sürücüyle aynı adı taşıyan tek bir kısayol duruyor. Açınca
dosyaların görünüyor, bir sorun yok sanıyorsun. Bu **kısayol solucanı**: dosyalarını bir
klasöre gizledi, gizli betiği çalıştıran sahte bir `.lnk` bıraktı ve bir sonraki bilgisayar
da kapsın diye yükünü geride bıraktı.

USB-Guard gizli `sysvolume` klasörü kullanan aileye karşı yazıldı; aynı yolla yayılan eski
VBS ve JS solucanlarını da kapsar.


---


## USB-Guard Ne Yapar


### USB'yi Temizler

- Sürücüyü o an tutan solucan sürecini durdurur.

- Zararlı kısayolları siler. Hem hedefe hem argümanlara bakar; `cmd`, `wscript` ya da
  `mshta` çalıştıran kısayollar dosyalarınla aynı adı taşısa da yakalanır.

- Gerçek dosyalarını gizli klasörden geri taşır: solucan sürücü etiketini, `sysvolume\<etiket>`
  yolunu, `_`, boş adı ya da sahte `recycle.bin` klasörünü kullanmış olsa da. Kökte aynı adlı
  dosya varsa ` (2)` eki alır; hiçbir şey üzerine yazılmaz, kaybolmaz.

- Yükü (gizli `.vbs` / `.js` / `.bat` / `.hta` / `.scr` dosyaları, gizli klasörlerinle aynı
  adı taşıyan klasör-ikonlu `.exe` taklitleri ve `tatil.jpg.exe` gibi çift uzantılı sahteler)
  `C:\ProgramData\Usb-Guard` altında karantinaya taşır, ardından Sistem + Gizli
  özniteliklerini kaldırır.

- Yalnız kökü değil, iki seviye derinlikte alt klasörleri de tarar. Jenxcus ailesindeki
  solucanlar kısayolu ve yükü buldukları her klasöre kopyalar.

- Karantinaya alınan her öğenin nereden geldiğini kaydeder. Gelişmiş menüdeki
  **Karantinadan Geri Al** eski karantina klasörlerini listeler ve içindekileri yerine taşır.


### USB'yi Aşılar

- Solucanın ihtiyaç duyduğu adları (`autorun.inf`, `recycler`, `recycled`, `sysvolume` ve
  sürücü etiketi) kilitli sahte klasörlerle işgal eder.

- Her sahte klasörde normal silmeyle kaldırılamayan ayrılmış adlı alt klasör (`con..`) vardır.
  NTFS kadar **FAT32 / exFAT** üzerinde de çalışır.

- NTFS'te Herkes için Deny ACL yazma, oluşturma ve silmeyi engeller. Sahibi her zaman geri
  alabilir.

Zaten aşılanmış sürücü **Guarded** olarak gösterilir ve atlanır.


### Bu PC'yi Kontrol Eder

Menü her açıldığında USB-Guard bilgisayarı tarar ve **Bu PC : Temiz** ya da
**N Kalıntı - Temizlik Önerilir** yazar. Bir şey bulunduysa menünün ilk maddesi
**Bu PC'yi Temizle (Önerilen)** olur.

Baktığı yerler:

| Nerede | Kalıntı sayılan |
| --- | --- |
| Çalışan süreçler | Temp ya da AppData'dan başlatılmış `wscript`, `cscript`, `mshta`; madenci ikilileri |
| `Run` / `RunOnce`, Policies `Run`, Winlogon `Shell` / `Userinit` | Betik yorumlayıcıları, `.vbs` / `.js` / `.bat` yükleri, gizli PowerShell |
| Kullanıcı Winlogon `Shell`, `AppInit_DLLs`, IFEO `Debugger` | Değiştirilmiş kullanıcı kabuğu, enjekte DLL, ele geçirilmiş Görev Yöneticisi / Kayıt Defteri / cmd |
| Başlangıç klasörleri (kullanıcı ve tüm kullanıcılar) | Betikler ve betiğe işaret eden kısayollar |
| Zamanlanmış görevler | Aynı kurallar, Microsoft görevleri hariç |
| Servisler | System32 dışındaki `ServiceDll`, ele geçirilmiş `DcomLaunch`, Temp ya da `Windows \` yolları |
| System32 | `svcinsty64.exe`, `svctrl64.exe`, `u######.dll`, `wsvcz\`, sahte `C:\Windows \System32` |
| Temp, AppData, ProgramData, kullanıcı profili | Sürücülere, kısayollara ya da autorun'a dokunan küçük betik dosyaları |
| Windows Defender | Temp, AppData ya da sahte klasörü gösteren dışlamalar |
| Explorer sabotajı | Kapatılmış Görev Yöneticisi, Kayıt Defteri, Klasör Seçenekleri ya da "gizli dosyaları göster" |

Bulunan her şey önce listelenir. **E / H** ile yanıt vermeden hiçbir şey değişmez. Onayda:
süreçler durdurulur, servisler ve otomatik başlatma kayıtları kaldırılır, Explorer ayarları
geri alınır ve dosyalar `C:\ProgramData\Usb-Guard` altında **karantinaya taşınır**, asla
silinmez. Windows'un kilitlediği dosya bir sonraki açılışta taşınır.


---


### USB'den Çalıştırma Anahtarı

**USB'den Çalıştırmayı Kapat** tek bir Windows ilke değeri (`Removable Disks: Deny execute
access`) yazar; çıkarılabilir hiçbir sürücüden `.exe` çalışmaz. Klasör-ikonlu sahte dosya
tıklansa bile açılmaz. USB'deki kurulum dosyaları ve taşınabilir programlar da çalışmaz;
bu yüzden isteğe bağlıdır ve aynı menüden geri alınır. Tam etkisi için oturumu kapatıp aç.


### Betik Motoru Anahtarı

Her VBS / JS solucanı `wscript.exe` üzerinden çalışır. **Betik Motorunu Kapat** tek bir kayıt
değeriyle Windows Script Host'u kapatır; korumasız bir PC'de bile tıklanan kısayol hiçbir
şey başlatmaz. Durum satırında **Betik Motoru : Açık / Kapalı** görünür. Meşru `.vbs`
betikleri (bazı yazıcı kurulumları, kurumsal logon betikleri) de durur; bu yüzden isteğe
bağlıdır, aynı menüden geri açılır.


## İsteğe Bağlı Arka Plan İzleyici


Menüden kurulur. Virüslü USB takıldığında Evet / Hayır sorusuyla temizleyip aşılamayı
önerir. Tıklamadan hiçbir şey çalışmaz. Aynı menüden kaldırılır.


---


## Kullanım


1. **`USB-Guard.bat`** dosyasını indir.

2. Çift tıkla. Windows yönetici onayı ister; ACL kilitleri ve PC temizliği için gerekli.

3. İlk açılışta İngilizce için **1**, Türkçe için **2** tuşuna bas. Seçim hatırlanır.

4. Ok tuşlarıyla gez, **Enter** ile seç, **sağ ok** ile seçili maddenin ne yaptığını oku,
   **sol ok** ile geri dön, **G** ile GitHub'ı aç, **Esc** ile çık.

İlk ekranda temizlik, PC taraması ve iki kurulum seçeneği vardır. USB'ye kurma seçeneği
yazacağı sürücünün adını gösterir; birden fazla USB takılıysa hangisi olduğu tahmin
edilmez. İzleyici, betik motoru anahtarı, USB'den çalıştırma anahtarı ve karantinadan geri
alma ve dil seçimi **Gelişmiş Seçenekler** altındadır.

Bir sürücü temizlendikten sonra USB-Guard kendini o sürücüye kopyalamayı teklif eder; böylece
sıradaki virüslü bilgisayara elinde taşırsın.

Açılışta USB-Guard sürümünü GitHub'daki son yayınla karşılaştırır. Yeni sürüm varsa indirir,
çalışan `.bat` ile değiştirir ve yeniden başlar. Sürüm denetimi, PC taraması ve antivirüs
sorgusu arka planda çalışır: menü yaklaşık bir saniyede hazır olur, durum satırları
yanıtlar geldikçe dolar.

Çıkarılabilir USB sürücüler ve USB sabit diskler listelenir. Sistem sürücüsü, bulut ve
boot / EFI bölümleri bilerek gizlenir.

Düz bir `.bat` olduğu için **cmd** çalıştırır. İçeride Windows 7 ve sonrasında hazır gelen
**Windows PowerShell 5.1** kullanılır. PowerShell 7 gerekmez, varsayılan kabuk değişmez.


---


## Güvenlik


- **Kendiliğinden yayılmaz.** Yalnız seçtiğin ya da onayladığın sürücüye dokunur.

- **Geri alınabilir.** Aşı, sahibin kaldırabileceği klasörler ve ACL'lerdir. PC temizliği
  silmek yerine karantinaya taşır.

- **Yerel.** Tek ağ çağrısı açılıştaki GitHub sürüm denetimidir; bilgisayardan veri çıkmaz.

- **Okunabilir.** `USB-Guard.bat` düz metin dosyasıdır. Sağ tıkla, Düzenle de: kısa bir bat
  başlığı ve ardından `src/usb-guard.ps1` ile birebir aynı PowerShell kaynağı. Hiçbir şey
  sıkıştırılmaz, kodlanmaz, çalışmadan önce geçici klasöre açılmaz.

- **Doğrulanabilir.** Her yayın notunda dosyanın SHA256'sı yazar. Çalıştırmadan önce
  `Get-FileHash .\USB-Guard.bat -Algorithm SHA256` ile karşılaştır.

- **Belgeli.** [SECURITY.md](SECURITY.md) programın yaptığı her ayrıcalıklı işi, gerekçesini
  ve nasıl geri alınacağını tablo hâlinde listeler.

- **Antivirüs değildir.** USB solucan ailelerini ve kalıntılarını tanır. Gerisi için gerçek
  bir antivirüs kullan.


---


## Kendin Derlemek İstersen


Program `src/usb-guard.ps1`, düz PowerShell. `src/build.ps1` onun önüne `src/header.bat`
başlığını koyup `USB-Guard.bat` dosyasını yazar, sonra üretilen dosyanın gövdesinin kaynakla
birebir aynı olduğunu doğrular ve SHA256'yı yazdırır.


```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\src\build.ps1
```


Aynı dosya hem bat hem PowerShell: `cmd.exe` ilk satırları okuyup `exit /b` ile durur,
PowerShell aynı satırları yorum bloğu sayıp devamını çalıştırır.


---


## Lisans


AGPL-3.0-or-later. Bkz. [LICENSE](LICENSE).


<!-- signature -->
<div align="center">

<a href="https://github.com/sponsors/Teknesyum"><img src="assets/badge-sponsor.svg" alt="Teknesyum'a destek ol" height="38"></a>
&nbsp;
<a href="LICENSE"><img src="assets/badge-license.svg" alt="Lisans AGPL-3.0" height="38"></a>

<br><br>

**Teknesyum** · [github.com/Teknesyum](https://github.com/Teknesyum)

</div>
