<!-- lang -->

[<img src="assets/badge-lang.tr.svg" alt="Türkçe seçili, switch to English" width="124" height="44">](README.md)


<div align="center">

# USB&nbsp;·&nbsp;GUARD

### USB'leri Kısayol Solucanlarına Karşı Düzeltir Ve Aşılar

Tek, kendini yükselten `.bat`. Kurulum yok. Sürücüyü seç — temizler ve kilitler.

</div>


---


## Sorun


USB'yi takıyorsun, dosyaların yok. Yerinde tek bir kısayol ya da tıklamadığın bir şeyi açan
bir klasör duruyor. Bu, **kısayol / autorun solucanı** — koca bir bilgisayar laboratuvarına
bir flash bellekten diğerine yayılan cinsten.

Üç iş yapar: gerçek dosyalarını **gizler**, gizli bir betiği çalıştıran **taklit bir kısayol**
bırakır ve bir sonraki makineye de bulaşsın diye geride bir **yük** bırakır.


---


## USB-Guard Ne Yapar


### Temizler

- Gizli bir betiğe işaret eden zararlı `.lnk` kısayollarını siler.

- Solucanın sürücü etiketi adlı klasöre gizlediği gerçek dosyaları yerine geri taşır.

- Yükü (`sysvolume` vb.) siler.

- Solucanın Sistem + Gizli işaretlediği dosyaları görünür yapar.


### Aşılar

- Solucanın ihtiyaç duyduğu isimleri — `autorun.inf`, `recycler`, `recycled`, `sysvolume` ve
  sürücü etiketi — kilitli sahte klasörlerle işgal eder; solucan bunları yeniden oluşturamaz.

- Her sahte klasörün içinde, normal silmenin kaldıramadığı ayrılmış adlı bir alt klasör
  (`con..`) durur. Bu, yalnız NTFS'te değil **FAT32 / exFAT**'te de çalışır.

- NTFS'te ayrıca Herkes için **Deny ACL** uygular; sahte klasöre yazma / oluşturma / silmeyi
  engeller. Sahibi her zaman geri alabilir.


Zaten korunan sürücü algılanır, **Zaten Aşılı** diye gösterilir ve atlanır.


### Bu PC'yi Tarar

**v1.4** ile gelen **Bu PC'yi Tara ve Kalıntıları Temizle** seçeneği, solucan kalıntısını
bilgisayarın kendisinde arar:

- Windows otomatik başlatma kayıtları (`Run` / `RunOnce`).

- Başlangıç klasörü.

- `Temp` ve `AppData` içindeki şüpheli `.vbs` yükleri.

Bulduklarını önce listeler. **E / H** ile onaylamadan hiçbir şeye dokunmaz. Onay verirsen
kayıtları siler; dosyaları silmez, **karantinaya taşır** — geri alabilirsin.


---


## İsteğe Bağlı Arka Plan İzleyici


Menüden, isteğe bağlı, hafif bir izleyici kurabilirsin. Virüslü bir USB takılınca Evet / Hayır
sorusuyla temizleyip aşılamak isteyip istemediğini sorar.

Tıklamadan hiçbir şey çalışmaz. Aynı menüden istediğin an kaldırılır.


---


## Kullanım


1. **`USB-Guard.bat`** dosyasını indir.

2. Çift tıkla. Windows yönetici onayı ister — ACL kilitleri için gerekli — onayla.

3. **Ok tuşlarıyla** sürücüyü ya da menü seçeneğini seç, **Enter**'a bas.


Sürücü listesinde yalnızca çıkarılabilir USB'ler görünür. Sistem, bulut ve boot / EFI
bölümleri kasıtla gizlenir.


### Her Yerde Çalışır

Bu düz bir `.bat` — onu **cmd** çalıştırır. İçeride Windows'un **yerleşik PowerShell 5.1**'ini
çağırır; bu, Windows 7 ve sonrasındaki her sürümde kuruludur. **PowerShell 7 gerekmez** ve
varsayılan kabuğun PowerShell olması **gerekmez**.


---


## Güvenlik


- **Kendiliğinden yayılmaz.** Yalnız senin seçtiğin ya da uyarıda onayladığın sürücüye dokunur.

- **Geri alınabilir.** Aşı, sahibinin kaldırabileceği bir dizi klasör ve ACL'dir; PC taraması
  dosyaları silmez, karantinaya alır.

- **Yerel.** Hiçbir ağla konuşmaz.


---


## Lisans


AGPL-3.0-or-later — bkz. [LICENSE](LICENSE).


<!-- signature -->
<div align="center">

<a href="https://github.com/sponsors/Teknesyum"><img src="assets/badge-sponsor.svg" alt="Teknesyum'a destek ol" height="38"></a>
&nbsp;
<a href="LICENSE"><img src="assets/badge-license.svg" alt="Lisans AGPL-3.0" height="38"></a>

<br><br>

**Teknesyum** · [github.com/Teknesyum](https://github.com/Teknesyum)

</div>
