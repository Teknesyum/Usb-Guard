# Ölçüm — D: sürücüsünün adı Gezgin'de görünmüyor

Tarih: 10 Eylül 2026. Sürücü: D:, NTFS, seri A0EC-4984, Ventoy'lu USB.

## Belirti

Gezgin "USB Sürücüsü (D:)" gösteriyor. USB-Guard aynı anda `Mustafa Özel` görüyor ve
adı yerinde saydığı için `Fix-VolLabel` hiçbir şey yapmıyor.

## Ölçülenler

Dosya sistemi etiketi doğru — üç ayrı kaynak aynı şeyi söylüyor:

    Win32_LogicalDisk.VolumeName : Mustafa Özel
    Get-Volume.FileSystemLabel   : Mustafa Özel
    cmd /c vol D:                : Volume in drive D is Mustafa Özel

Kabuğun gösterdiği ad (Shell.Application, Bilgisayarım ad alanı):

    C:\ => Yerel Disk (C:)
    D:\ => USB Sürücüsü (D:)

C:'nin de etiketi boş ve o da genel adı gösteriyor; yani kabuk boş etiket görünce
böyle davranıyor. D:'de etiket boş değil, buna rağmen genel ad geliyor.

Kök dizin — bağışıklık sonrası hâli:

    d-rhs- autorun.inf          <- bağışıklık bunu klasöre çevirdi
    d-rhs- Mustafa Özel
    d-rhs- recycled
    d-rhs- recycler
    d-rhs- sysvolume

Denenen ve sonuç vermeyenler:

- `HKCU\...\Explorer\MountPoints2\{40b492c9-...}` anahtarı **boş**; `_LabelFromReg`
  yok. Yani bilinen autorun.inf etiket önbelleği burada devrede değil.
- `HKLM\...\Explorer\DriveIcons` boş.
- Etiket `SetVolumeLabelW` ile yeniden yazıldı — kabuk yine genel adı verdi.
- `D:\autorun.inf` klasörü `zz-autorun-test` adına çevrildi — kabuk yine genel adı
  verdi. **Ancak** kabuk bu iki değişikliği takmadan da yanıt vermiş olabilir; kaldırılabilir
  sürücünün adını takılma anında okuyup oturum boyunca saklıyor olması kuvvetli ihtimal.
- `explorer.exe` öldürülüp yeniden başlatıldı; süreç önbelleği değilse bir şey değişmez,
  değişmedi.

## Ayakta duran iki hipotez

1. **Kabuk adı takılma anında okuyor.** v1.19 etiketi sürücü zaten takılıyken yazdı;
   Gezgin bir daha bakmadı. Doğrusu: çıkar-tak, ad görünür.
2. **Kök dizindeki `autorun.inf` adlı klasör.** Kabuk autorun.inf'i açıp etiket okumaya
   çalışıyor, klasör olduğu için okuyamıyor ve elinde kalan boş etiketle genel adı
   yazıyor. Doğruysa bağışıklık, sürücünün adını kalıcı olarak yutuyor demektir ve
   v1.19'un birim etiketi çözümü bunu kurtarmıyor.

İki hipotez tek deneyle ayrışıyor: `autorun.inf` klasörü **şu an yok** (yeniden
adlandırıldı). Sürücü tekrar takıldığında ad görünürse 2 elenir, sebep 1'dir; yine
görünmezse 2 doğrudur.

## Sürücüde bırakılan durum

Ölçüm sırasında USB çıkarıldı. `D:\autorun.inf` klasörü **`D:\zz-autorun-test` adında
duruyor** ve o ada karşı bağışıklık şu an yok. Sürücü tekrar takılınca ya USB-Guard'ın
"Düzelt" adımı bağışıklığı yeniden kurar ya da klasör eski adına döndürülür.

## Sonuç — 11 Eylül 2026

Sebep **2 numaralı hipotez**: kökteki `autorun.inf` **klasörü**. Kabuk kök `autorun.inf`'i
INI olarak açıp adı ondan okumaya çalışıyor; klasör olduğu için okuyamıyor ve birim
etiketini yok sayıp genel "USB Sürücüsü" adına düşüyor. v1.19 etiketi birim metadata'sına
yazdı ama klasörün etiketi bastırdığını görmedi, o yüzden ad hâlâ görünmedi.

Kesin deney (aynı oturumda, taze süreç):

    autorun.inf klasoru VAR  + mount  -> "USB Sürücüsü (D:)"
    autorun.inf klasoru YOK  + mount  -> "Mustafa Ozel (D:)"

Tek değişken `autorun.inf` klasörünün varlığı. Yokken birim etiketi görünüyor.

Düzeltme (v1.21): bağışıklık `autorun.inf`'i klasör değil, içinde yalnız `[autorun]` olan
**kilitli DOSYA** yapıyor. Kabuk dosyayı okuyabiliyor, üzerine yazacak `label=` bulamıyor
ve gerçek birim etiketini gösteriyor. Dosya yine `+s +h +r` ve NTFS'te Deny ACE ile kilitli,
kötücül autorun engellenmeye devam ediyor. Kötücül `autorun.inf` yalnızca `open=` /
`shellexecute=` / `shell\` içerdiğinde enfeksiyon sayılıyor.

Etiketin `Özel → Ozel` (ASCII) hâline gelmesinin kaynağı bulunamadı; koddaki yol
(`Clean-VolLabel` + `SetVolumeLabelW`, CharSet.Unicode) Ö'yü korur, kodda üretilmiyor.
Canlı USB'de etiket elle `Mustafa Özel` olarak geri yazıldı.

Canlı USB'de yapılanlar: etiket `Mustafa Özel`, `autorun.inf` kilitli dosyaya çevrildi,
görünür kalan eski `Mustafa Özel` decoy'u ve `zz-autorun-test` temizlendi/gizlendi, `ventoy`
klasörü gizlendi, `VentoyPlugson.log` silindi. Bir kaza: `Mustafa Özel` gibi Türkçe yollu
`icacls`/`attrib` çağrısı `-File` betiğinde kod sayfası yüzünden bozulup kök `D:\`'ye Deny
ACE düşürdü; fark edilip geri alındı (kök `Everyone:(M)`). Ders: canlı diskte native araca
Türkçe yol verme, .NET kullan.
