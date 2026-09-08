[[netlestirme:001]]

# Netleştirme: USB-Guard'a iki dil desteği ekleyeceğim: açılışta 1 İngilizce / 2 Türkçe, İngili

İşe başlamadan önce soruyu keskinleştir. Görüş verme, plan yazma, kod yazma.
Yalnız şunu döndür: soruda belirsiz kalan yerler, her biri için tek satırlık bir netleştirme sorusu, en fazla beş. Belirsizlik yoksa "net" yaz.

## Soru

USB-Guard'a iki dil desteği ekleyeceğim: açılışta 1 İngilizce / 2 Türkçe, İngilizce seçilince programdaki her metin İngilizce. Tek dosya, gömülü PowerShell 5.1 betiği, 861 satır, ~190 Türkçe metin. Hangi mimariyi kurayım, hizalama ve kalıcılık nasıl çözülmeli, hangi tuzaklara düşerim?

## Elde olan olgular

# USB-Guard — İki Dil Desteği İçin Olgular

## Program nedir

Tek dosya: `USB-Guard.bat`, 23 KB. İçinde gzip+base64 gömülü bir PowerShell betiği var.
Bat çalışınca betiği `%TEMP%\usb-guard.ps1` olarak UTF-8 BOM ile yazar ve
`powershell -NoProfile -ExecutionPolicy Bypass -File` ile çalıştırır. Yönetici olarak
kendini yükseltir. Kaynak betik 861 satır, Windows PowerShell 5.1 hedefli (PS7 yok).
Sürüm 1.11. Konsol uygulaması, ok tuşlu menü, tüm arayüz şu an Türkçe.

İşi: USB kısayol solucanlarını temizlemek, USB'yi aşılamak (kilitli tuzak klasörler),
bu PC'yi kalıntı için taramak, karantina, izleyici, betik motoru ve USB'den çalıştırma
anahtarları.

## İstenen

Açılışta dil seçimi: `1` İngilizce, `2` Türkçe. İngilizce seçilince programdaki tüm
metinler İngilizce olacak. Seçim hatırlanmalı. Kalite maliyetten önemli.

## Metin envanteri

Betikte 150 Türkçe karakter içeren string literali var, 144'ü benzersiz, toplam 5528
karakter. Ayrıca Türkçe ama düz ASCII olan (`Temiz`, `Geri`, `Ok`) ~40 literal daha.
Kabaca 190 metin, ~7 KB.

## Ekrana çıkış hunisi

Tüm çıktı bu fonksiyonlardan geçer:

```powershell
function TN($t,$c='Gray'){ ... Write-Host "$t" -NoNewline -ForegroundColor $c ... }
function T($t,$c='Gray'){ TN $t $c; Write-Host ''; $script:bol=$true }
function Box-Line($t,$c='White'){
    $t="$t"; if($t.Length -gt $W){ $t=$t.Substring(0,$W) }
    $pad=$W-$t.Length; $l=[int]($pad/2); $r=$pad-$l
    ...
}
function PadW($s){ $pw=$W+4; if($s.Length -gt $pw){ return $s.Substring(0,$pw) }; return $s.PadRight($pw) }
function Row($s,$fg='Gray',$bg=$null){ Write-Host $script:M -NoNewline; ... }
```

`$W = 60` sabit blok genişliği. `$script:M` sol boşluk, konsol genişliğinden her çizimde
hesaplanır (ortalama). `Row` menü satırlarını basar, seçili satır ters renkte ve
`PadW` ile `$W+4` sütuna doldurulur.

## Metinlerin geldiği biçimler

1. Doğrudan sabit: `T '  Zaten Guarded, İşlem Gerekmiyor.' 'Green'`

2. Etiket + değer, iki çağrı, etiket sabit genişlikte hizalı:

```powershell
TN '  Sürüm     : ' 'Gray'; TN ("v{0}  " -f $VER) 'White'
TN '  Bu PC     : ' 'Gray'
TN '  Antivirüs : ' 'Gray'
TN '  İzleyici          : ' 'DarkGray'
TN '  Betik Motoru      : ' 'DarkGray'
TN '  USB''den Çalıştırma: ' 'DarkGray'
```

3. `-f` ile kurulan kalıp, çağrı yerinde biçimlenip T'ye öyle gider:

```powershell
T ("{0} Kalıntı - Temizlik Önerilir" -f $script:pcFound.Count) 'Red'
T ("v{0} Var - github.com/{1}" -f $matches[1],$repo) 'Yellow'
T ("  Yeni sürüm v{0} indirildi, yeniden başlatılıyor..." -f $tag) 'Green'
$items += @{Text=('USB-Guard''ı USB''ye Kur  ->  {0} {1}' -f $drives[0].DeviceID,$lbl); Action='copyUsb'}
```

4. Menü öğesi metni: hashtable alanı olarak taşınır, sonra `Row` basar:

```powershell
$items += @{Text='Bu PC''yi Tara'; Action='scanpc'}
$items += @{Text='Gelişmiş Seçenekler  >'; Action='adv'}
```

5. İpucu satırı, koşullu kurulur:

```powershell
$hint=if($hasLeft){ '  Yön: Ok   Seç: Enter   Bilgi: Sağ Ok   Geri: Sol Ok / Esc' }
      else { "  Yön: Ok   Seç: Enter   Bilgi: Sağ Ok   GitHub: G   {0}: Esc" -f $esc }
```

6. Çok satırlı yardım metinleri, `` `n `` ile ayrılmış, sağ okta gösterilir. 14 tane,
   en uzunu 6 satır, satırlar 60 sütuna sığacak şekilde elle sarılmış:

```powershell
'wshoff' { "Windows Script Host'u kapatır (tek kayıt değeri).`n.vbs / .js solucanları wscript.exe ile çalışır; kapalıyken`nkısayola tıklansa bile yük çalışmaz.`nYan etki: meşru .vbs / .js betikleri de durur (bazı yazıcı`nkurulumları, kurumsal logon betikleri, eski kurulum`nsihirbazları). Aynı menüden geri açılır." }
```

7. `Spin 'Adım Adı' { ... }` — ilerleme adımı adı, 40 kadar çağrı.

8. Evet/Hayır sorusu şu an `E / H` tuşlarını okuyor.

## Kısıtlar

- Windows PowerShell 5.1. Betik `%TEMP%`'e UTF-8 BOM ile yazılıyor, Türkçe karakterler
  bu sayede doğru okunuyor. Konsol kod sayfası ayrıca ayarlanıyor.
- Kutu genişliği 60 sabit; `Box-Line` taşan metni keser, `PadW` de öyle.
- Betik gzip'lenip base64 olarak bat'a gömülüyor; 190 metnin ikinci dili dosya boyutunu
  büyütür (şu an 23 KB).
- Açılışta hız önemli: menü ~1 saniyede hazır olmalı, sürüm denetimi ve PC taraması
  arka plan runspace'inde dönüyor.
- Otomatik güncelleme var: her açılışta GitHub'daki son yayınla karşılaştırıp kendini
  değiştiriyor. Yani dil seçimi eklenen sürüm herkese kendiliğinden iner. Eski
  sürümden yeniye geçen kullanıcının kaydedilmiş dili yoksa ne olmalı, karar gerekiyor.
- Program hem etkileşimli menüyle hem `-Watch` ve `-Bg` anahtarlarıyla (izleyici ve
  arka plan runspace'i) çalışıyor; izleyici bildirimleri de metin içeriyor.
- Yönetici olarak çalışıyor; `%LOCALAPPDATA%` yükseltilmiş oturumda da aynı kullanıcıya
  ait, karantina zaten oraya yazılıyor.

## Benim düşündüğüm iki yol

**A. Huni sözlüğü.** `T` / `TN` / `Row` / `Box-Line` içine Türkçe→İngilizce sözlük
koymak. Çağrı yerleri değişmez. Ama `-f` ile kurulan metinler huniye biçimlenmiş
geldiği için sözlükte bulunamaz; onlar (~30 yer) elle düzeltilir. Hizalı etiketler
(`Sürüm     : `) İngilizcede farklı uzunlukta, dolgu bozulur.

**B. Anahtar tablosu.** Her metne slug verip `S 'ver.label'` çağrısı yapmak. 190 çağrı
yeri değişir. Temiz ama büyük ve kırılgan.
