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
