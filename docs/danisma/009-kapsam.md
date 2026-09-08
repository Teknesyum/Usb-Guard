# Fable'ın cevabı (009) — v1.17 tespit kapsamı

Girdi: [009-kapsam-girdi.md](009-kapsam-girdi.md) — maliyet: 66079 token, 245 s.

---

# USB-Guard v1.17 — Değerlendirme

## Önce en sert bulgu: plan bugünkü **en tehlikeli davranışı** düzeltmiyor

Kutu boşaltma mantığı (`$containerRx` eşleşti → içi köke çıkar → klasörü sil) bugün bir
**kötü amaçlı yazılım dağıtıcısı** gibi davranıyor: gizli `.dll/.dat/.bin/desktop.ini` yükü
kullanıcının görünür köküne taşınıyor, gizli bayrağı kalkıyor. Madde 2 bunu yalnız üç uzantı için
kapatıyor. Uzantı listesi genişletmek yanlış araç — Gamarue yükü `desktop.ini` adında DLL'dir,
Raspberry Robin `.swy/.chk/.usb/.cfg`, wscript `//e:vbscript dosya.txt` ile `.txt` çalıştırır.

Doğru kural uzantısız, içerik tabanlı ve 10 satır:

```
İlk 4 KB'ı oku.
  ilk 2 bayt "MZ"                          → yük (PE), karantina
  ilk 4 bayt "#@~^"                        → yük (kodlanmış VBS/JS), karantina
  '(?i)(CreateObject|ActiveXObject|WScript\.|<script|On Error Resume Next|ShellExecute|powershell)'
    ve uzantı medya/ofis/arşiv ise           → yük (maskeli betik), karantina
  aksi                                      → kullanıcı verisi, köke çıkar
```

Bu tek kural 1–4 numaralı boşlukların yük tarafını birden kapatır, `$payloadExt`'i madde 8
dahil büyütme ihtiyacını büyük oranda kaldırır ve **yanlış pozitifi neredeyse sıfırlar**:
kullanıcının fotoğrafı/PDF'i asla `MZ` ile başlamaz. Fotoğraf/PDF/ofis dosyası sinyal
taşıyorsa (ör. `MZ` ile başlayan `.jpg`) zaten kesin yüktür.

---

## Soru 1 — Yanlış pozitif riski

### Madde 1 — `desktop.ini` sezgiseli: **daraltılırsa güvenli**

"desktop.ini + herhangi CLSID" fazla geniş. Windows, kullanıcının kendi klasörlerine de
`desktop.ini` yazar (`LocalizedResourceName`, `IconResource`, `FolderType`); bunlarda CLSID
satırı olabilir. Yalnız kimlik hırsızlığı yapan CLSID'lere bak, ve klasör **gizli+sistem**
olsun:

```
$cloakClsid = '(?i)\{(645FF040-5081-101B-9F08-00AA002F954E|20D04FE0-3AEA-1069-A2D8-08002B30309D|21EC2020-3AEA-1069-A2DD-08002B30309D|2559A1F[0-7]-21D7-11D4-BDAF-00C04F60B9F0|ED7BA470-8E54-465E-825C-99712043E01C)\}'
```

(Geri Dönüşüm Kutusu, Bilgisayarım, Denetim Masası, arama/yardım kısayolları, God Mode.)

Aynı numaranın **klasör adı** biçimini de ekle: `Foo.{645FF040-…}` adlı klasör Explorer'da
Geri Dönüşüm Kutusu olarak görünür, `desktop.ini` gerektirmez.

```
$containerRx = '(?i)^(_|\s+|[^\w]{1,3}|recycle\.?bin|\$?recycle[rd]?(\.bin)?\.?|_recycle|sysvolume|.*\.\{[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}\})$'
```

Meşru `RECYCLER`/`RECYCLED` FAT32 sürücüde XP mirasıdır, gizli+sistem olur — bugün zaten
`$fixed`'te aşılıyorsun, yani gerçek olanı da siliyorsun. Çelişki yok, tutarlı davran: boşalt,
sil, kilitli boş klasör koy.

### Madde 3 — Derinlik 4: **tespit FP'si değil, süre ve kutu FP'si**

Tespit ölçütleri aynı (gizli+sistem yük, çift uzantı, `$lnkRx`); derinlik tek başına yanlış
pozitif üretmez. İki gerçek sorun:

- 128 GB fotoğraf arşivinde `-Recurse -Depth 4` dakikalarca sürer, internet kafe kullanıcısı
  çubuğu çeker. Tavan: **20.000 dosya** ya da **20 saniye**; aşılınca derinlik 2'ye düşüp
  ekrana "büyük sürücü, sığ tarama" yaz.
- Kutu kuralı (`$containerRx`) derin seviyede çalışırsa kullanıcının `Proje\_\` adlı gizli
  olmayan klasörünü de yakalayamaz ama `Yedek\_` gibi gizli klasörü yakalar. Kutu kuralını
  **yalnız kök + 1. seviye** ile sınırla; derinlik 4 yalnız yük/çift uzantı/`.lnk` için.

Derinliği 4 yapan gerçek gerekçe nedir? PlugX ve Raspberry Robin kökte veya 1. seviyede.
Gamarue 1. seviye. Derinlik 3 yeterli; 4 süs.

### Madde 4 — Argümanda adı geçen dosya: **en yüksek FP maddesi, ama düzeltilebilir**

Asıl tehlike CryptoBandits'in kendisi: `.lnk` argümanı `cmd /c start "" "Rapor.docx" & wscript…`
biçiminde **kullanıcının gerçek belgesini** açar. Uzantıya bakmadan karantinaya alırsan
solucanın gizlediği belgeyi bu kez sen kaçırırsın. Geri alınabilir ama kullanıcı belgeyi
kaybetti sanır.

Kural:

```
1. Argümanı ["'\s<>&|,;=] ile böl; yalnız \.[a-z0-9]{1,5}$ biten belirteçleri tut (≤ 8 belirteç).
2. Her belirteci sırayla: .lnk'nin çalışma dizini, bulunduğu klasör, sürücü kökü altında çöz.
   Var olmayanı, klasörü, başka sürücüdekini, $keepDirs içindekini at.
3. Var olan her dosyaya yukarıdaki içerik sınamasını uygula:
   MZ / #@~^ / betik izi → karantina
   aksi → gizli/sistem bayrağını kaldır, yerinde bırak (kullanıcı belgesi).
```

`%comspec%`, `%windir%\system32\cmd.exe` gibi hedefleri de çözmeyi unutma; bugün `$lnkRx`'te
`comspec` yok, `cmd(\.exe)?\s` `%comspec% /R <x.swy` ile eşleşmez. Ekle:

```
$lnkRx += '|%comspec%|%windir%|%systemroot%|/r\s|conhost|msiexec|regsvr32|certutil|bitsadmin|forfiles|wmic|explorer(\.exe)?\s+[^"]*\\'
```

Son öge: CryptoBandits/Bondat türü `explorer.exe <gizli klasör>` hedefleri. Kullanıcının
kendi Explorer kısayolu USB kökünde nadir.

### Madde 7 — **Yanlış. Olduğu gibi kalırsa her makinede pozitif verir.**

`Advanced\Hidden=2` ve `ShowSuperHidden=0` **Windows varsayılanıdır**. Sabotaj değil,
temiz kurulum. Solucanlar bu değerleri sürekli yazar ama statik bakışla varsayılandan ayırt
edilemez. Kaldır. Yerine gerçek sabotaj anahtarları:

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer   NoFolderOptions=1, NoRun=1, NoViewOnDrive, NoDrives
HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System     DisableTaskMgr=1, DisableRegistryTools=1
HKCU\Software\Policies\Microsoft\Windows\System                    DisableCMD=1|2
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon         Shell ≠ 'explorer.exe', Userinit ≠ 'C:\Windows\system32\userinit.exe,'
HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\{taskmgr,regedit,cmd,msconfig}.exe\Debugger
HKLM\...\Explorer\Advanced\Folder\Hidden\SHOWALL\CheckedValue      (zaten var) + tipi REG_SZ'ye çevrilmiş mi
```

Uyarı: hedef kitlen okul/kafe. Oralarda `DisableTaskMgr`, `NoRun`, `NoDrives` **GPO ile
bilerek** ayarlanır. Bu grubu "bilgi" seviyesi göster, önerilen temizliğe **katma**, makine
etki alanına üyeyse (`(Get-CimInstance Win32_ComputerSystem).PartOfDomain`) hiç gösterme.
`Winlogon\Shell/Userinit` ve `Debugger` ise her ortamda kesin bulgu.

### Madde 5 — "5 harfli klasör" deseni: **yazma**

Bu bir kampanya imzasıdır; önümüzdeki sürümde 6 harf olur. Derinlik 2 zaten
`Public\Documents\omoho\omoho.js`'yi görür. Derinlik 2'de klasör tavanı 400 → **1500**
(AppData\Local altında 300+ klasör normal). Roots'a `Public\Documents` ve `Users\Default`
açıkça ekle.

### Madde 6 ve 8 — FP yok, ucuz

`Extensions/Processes` iyi. Kayıt defteri yerine `Get-MpPreference` üçünü tek çağrıda verir ve
`HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions` (GPO dalı, solucanlar orayı da
kullanır) dahil olur; ama Defender kapalıysa cmdlet patlar, try/catch ile kayıt defterine düş.

`.url` ekle (`URL=file:///` hedefi ayrıca `$lnkRx`'e tabi olsun). `.scf` USB solucanı aracı
değil (NTLM sızdırma), gizli+sistem `.scf` USB kökünde yine de meşru olmaz — bedava, kalsın.

---

## Soru 2 — Kaçırılan teknikler

### `$keepDirs` = solucanların en sevdiği iki saklanma yeri

`System Volume Information` ve `$RECYCLE.BIN`'i **hiç bakmadan** geçiyorsun. Sality, Gamarue
varyantları, birçok VBS solucanı ve Raspberry Robin yükü tam oraya koyar; kötü `.lnk`
`..\$RECYCLE.BIN\S-1-5-21-…\x.exe` hedefler. Gerçek `$RECYCLE.BIN` içeriği tamamen
öngörülebilir:

```
$RECYCLE.BIN\S-1-5-21-…\            → yalnız  ^\$[IR][A-Z0-9]{6}(\..*)?$  ve desktop.ini
System Volume Information\          → IndexerVolumeGuid, WPSettings.dat, tracking.log, {GUID}, *.tmp
```

Bu desene uymayan ve içerik sınaması `MZ`/betik veren dosya → karantina. Klasörlere dokunma.
FAT32'de sahte `System Volume Information` (Windows gerçekten de FAT32'ye yazar, ayırt etmek
zor) yerine dosya tabanlı kural yeterli.

### DLL yan yükleme için Authenticode muafiyeti bir delik

PlugX'in tüm numarası bu: imzalı exe temiz, yanındaki DLL kirli. "Yol imzalıysa bulgu değil"
kuralını şöyle daralt: imzalı exe `\Users\`, `\ProgramData\`, `\Temp\`, `\Public\` altındaysa
**aynı klasördeki imzasız `.dll`** var mı bak; varsa bulgu (exe değil, DLL karantinaya).
CryptoBandits `ugate.exe` (Tor, imzalı olabilir) aynı şekilde `\Users\Public\` altında yakalanır.
`$susRx`'e ekle: `\\Users\\Public\\[^"]*\.exe`.

### Eksik kalıcılık noktaları

Gamarue `HKCU\...\Policies\Explorer\Run` kullanır. Listede yoksa: `RunOnce`,
`Policies\Explorer\Run`, `Winlogon\Shell/Userinit`, `HKCU\Environment\UserInitMprLogonScript`,
`Explorer\Shell Folders\Startup` (başlangıç klasörünün yolunu başka yere çevirme numarası —
sen `Startup`'a bakıyorsun, solucan onu `AppData\Local\Temp\x` yapmış olabilir). WMI abonelikleri
(`root\subscription __EventFilter`) 5 satır; ofis makinesinde meşru olanı yok denecek kadar az.

### Diğer

- **RTLO/Unicode ad numarası**: `Rapor\u202Excod.exe` → görünür ad `Raporexe.docx`.
  `$dblRx` yakalamaz. Ekle: ad `[\u200B-\u200F\u202A-\u202E\u2066-\u2069]` içeriyorsa
  ve uzantı `exe|scr|pif|com|lnk` → karantina. FP: sıfır; hiçbir kullanıcı adına RTLO koymaz.
- **`.lnk` argümanı Base64/`-enc`** zaten `powershell` ile yakalanıyor.
- BadUSB, dosya bulaştıran, ISO/VHD dışlaması doğru. **ISO/IMG için tek satırlık bilgi bulgusu**
  (USB kökünde gizli+sistem `.iso/.img/.vhd/.vhdx`) zararsız, ama madde 9 dışlaması olduğu
  gibi kalsın; kapsam sürünmesi.

---

## Soru 3 — Sıralama

Koruma değeri, yüksekten alçağa:

1. **İçerik sınaması (MZ/#@~^/betik izi) + madde 2 + madde 4** — bugün kendin dağıttığın yükü
   durdurur. Tek grup, ~25 satır.
2. **`$keepDirs` içini dosya deseniyle tarama** — planda yok, en yaygın saklanma yeri.
3. **Madde 1** (kutu deseni + CLSID) — PlugX/kimlik hırsızı klasörler.
4. **Madde 6** — Defender istisnası her ailenin ilk işi, ucuz.
5. **Madde 5** (5 harf kısmı olmadan) ve kalıcılık anahtarları.
6. **Madde 7 düzeltilmiş hali** (Winlogon/Debugger kesin, Policies bilgi).
7. Madde 3 (derinlik 3, tavanla), madde 8, RTLO.
8. Madde 9.

Süs: 5-harf deseni, derinlik 4'ün 3'e karşı farkı, `.scf`.

---

## Soru 4 — Felsefeyi zoran maddeler

- **Madde 5'in 5-harf kısmı** ve `$susRx`'teki `xmrig|svctrl64|svcinsty64|wsvcz|ugate`: bunlar
  imzadır. "İmza veritabanı yok" diyorsan ya kaldır ya dürüst ol — ayrı bir `$knownNames`
  değişkenine tarihle koy ("2026-06 CryptoBandits"), README'de "birkaç kampanya adı" de.
  Davranış kuralları (Public'te exe, Temp'te imzasız DLL) bu adları gereksiz kılar.
- **Madde 3** süre tavanı olmadan "basit" kullanıcının sabrını zorlar.
- **Madde 4** geri alınabilirliği korur; uygun. İçerik sınaması da geri alınabilir.
- Politika anahtarlarını **otomatik düzeltmek** "geri alınabilir" değil (GPO 90 dakikada
  geri yazar, kullanıcı neyin değiştiğini anlamaz). Yalnız göster.

---

## Soru 5 — Kaldırılacaklar / daraltılacaklar

- **Madde 7 orijinal hali** — yukarıda.
- `$susRx` içinde `bypass`: `-ExecutionPolicy Bypass` Chocolatey, geliştirici araçları, IT
  betiklerinde standart. Tek başına bulgu olmasın; `-w hidden|-enc|\\Temp\\|\\AppData\\` ile
  **birlikte** olsun.
- `\\Temp\\[^"]*\.exe`: `RunOnce`'ta yeniden başlatma sonrası kurulumlar, Edge/Chrome güncelleyici
  artıkları. Tut, ama imza denetimini bu ögeye de uygula (şu an yalnız servis/DLL için).
- `powershell[^"]*-e `: `-e ` yalnız boşluklu `-e`; `-ec`, `-en`, `-EncodedCommand` kaçar.
  `-e(c|nc|ncodedcommand)?\s` yap.
- `$lnkRx`'te `/c\s`: yalnız `.lnk` hedefinde çalıştığı için FP düşük; `/r\s` ekle (yukarıda).
- Find-Scripts ikinci regex'inde `\.lnk` ve `attrib ` iyi; `\+h |\+s ` gereksiz (`attrib ` zaten
  içeriyor). `CurrentVersion\\Run` tek başına yeterli sinyal değil ama iki regex "ve" ile
  bağlı, sorun yok.
- `Get-ChildItem -Recurse -Depth 2 -File` ve ardından kutu boşaltma: **gizli klasörü boşaltıp
  silme adımı `$keepDirs`'i gerçekten atlıyor mu** — `System Volume Information` gizli+sistem
  ve `$containerRx`'e girmez ama `.lnk` argümanında adı geçtiyse "kutu" sayılıp **silinir**.
  Bu yolu açıkça kapat: `$keepDirs` hiçbir koşulda silinmez, yalnız içi dosya deseniyle taranır.

---

## Özet karar

Plan yönü doğru ama iki yerde zayıf: uzantı listelerini büyüterek yük yakalamaya çalışıyor
(kaybedilen yarış) ve madde 7 yanlış. Uzantı yerine **4 KB içerik sınaması** tek kural olarak
girsin; `$keepDirs` içi taransın; madde 7 Winlogon/Debugger/Policies ile değişsin; 5-harf ve
kampanya adları imza olduğu kabul edilerek ayrılsın ya da atılsın. Satır bütçesi ~50'den ~80'e
çıkar; yanlış pozitif riski bugünkünden düşer çünkü `MZ` sınaması, gizli-uzantı sezgisinden
daha kesindir.
