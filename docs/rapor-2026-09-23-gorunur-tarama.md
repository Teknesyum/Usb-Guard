# Rapor — Tarama Artık Yaptığı İşi Gösteriyor (v1.26)

**Tarih:** 23 Eylül 2026

## Sorun

"Bu PC'yi Tara" dokuz ayrı alana bakıyor ve yaklaşık 2.600 öğe inceliyordu. Ekranda ise
yalnızca tek satır görünüyordu: `Süreçler, Kayıtlar, Görevler, Servisler [Ok]`. Kullanıcı
işin büyüklüğünü görmüyor, "temiz" sonucunu "bir şey yapmadı" diye okuyordu.

## Değişiklik (`src/usb-guard.ps1`)

- `Find-PcRemnants($show)` artık dokuz adımı sırayla çalıştırıyor. `$show` açıkken her adım
  için yüzde, alan adı, incelenen öğe sayısı ve `[Temiz]` ya da `[N bulgu]` yazıyor.
- Her `Find-*` fonksiyonu `$script:chk` sayacını gerçekten baktığı öğe kadar artırıyor.
  Sayılar tahmin değil, ölçüm.
- Tarama sonunda özet satırı çıkıyor: öğe sayısı, alan sayısı, süre.
- Kullanıcının yok saydığı bulgular adım satırındaki sayıya girmiyor. Böylece satır ile
  sonuç tutarlı kalıyor.
- Arka plan kullanımı (`$show` kapalı) eskisi gibi sessiz çalışıyor.
- TR/EN metinleri: `scan.s1`–`scan.s9`, `scan.ok`, `scan.hit`, `scan.sum`.

## Ölçüm (Bu Bilgisayar)

```
  %11  Çalışan süreçler               309 süreç  [Temiz]
  %22  Başlangıç kayıtları             30 değer  [Temiz]
  %33  Başlangıç klasörleri             6 dosya  [Temiz]
  %44  Zamanlanmış görevler           247 görev  [Temiz]
  %56  Windows servisleri            804 servis  [Temiz]
  %67  Sistem klasörü (madenci)         6 konum  [Temiz]
  %78  Gizli betikler              1.171 klasör  [Temiz]
  %89  Defender istisnaları            12 kural  [Temiz]
  %100 Kilitlenen ayarlar               10 ayar  [Temiz]

  2.590 öğe, 9 alanda 3,4 saniyede incelendi.
```

İlk denemede iki satır `[1 bulgu]` gösterdi, sonuç ise 0 bulgu oldu. Bunun nedeni, yok
sayılan bulguların adım satırında sayılmasıydı. Adım satırı artık yok sayılanları dışarıda
bırakıyor.

## Testler

`tauto` ve `tlabel` hatasız geçti. `build.ps1` çıktısı: parses True.

## Genel İlke

Core için yazılan ilke raporu:
`~/.claude/teknesyum/openlogs/2026-09-23-gorunur-emek-sessiz-is-yapma.md`

## v1.27 — Akan Seyir, Sade Kalıntı

Kullanıcının isteği: yüzde 5'er 5'er atlamasın, 0,1'lik adımlarla aksın. Yavaş
bilgisayarda bile akıcı görünsün. Bütün veri ekrana basılmasın. Seyir sırasında çok veri
akarken görünsün (illüzyon), bitince yalnız ana hatlar kalsın. Kullanıcı çok veri
görmeyi sever, az veriyi ise ayrıntılı inceler. İkisi birlikte uygulandı.

- **Canlı satır:** Her alan tek satırda çalışır. Satır, o anda incelenen öğenin adını
  gösterir (süreç, servis, görev, klasör yolu) ve yerinde yeniden çizilir; ekran kaymaz.
- **Ana hatlar kalır:** Alan bitince aynı satır özet satırıyla değiştirilir: alan, sayı,
  `[Temiz]`. Akan binlerce ad ekranda birikmez.
- **0,1 çözünürlük:** Yüzde `%57,8` biçiminde yazılır. Her alanın ağırlığı, gerçek süresine
  göre verildi: betik taraması 40, servisler 22, görevler 12, süreçler 8, diğerleri 2-5.
  Böylece yüzde, geçen zamanla orantılı ilerler.
- **Yavaş bilgisayarda akıcılık:** Çizim, öğe sayısına değil zamana bağlıdır: en fazla 40
  ms'de bir, saniyede 25 kare. Hızlı makinede boş yere çizim yapılmaz. Yavaş makinede ise
  her kare ilerlemeyi gösterir. Yüzde hiç geriye gitmez.
- **Çıktı yönlendirilince** (kayıt, test) canlı çizim kapanır, yalnız özet satırları yazılır.

Ölçüm, gerçek konsol penceresinde (conhost) yapıldı. Ekrana çizilen yüzde dizisi:

```
0 0 8 8 12 12 12 15 15,6 27 27 27,5 29,1 30,4 31,8 33,1 34,2 35,3 36,3 37,1 38,1 39,4
40,8 42 43 43,9 44,8 45,8 46,9 48,5 49 51 51,1 55,2 57,8 58,2 58,2 63 70,8 77,1 82,1
88,5 90,6 91 95 95
```

Taramadan sonra ekranda kalan:

```
  %  8,0 Çalışan süreçler               313 süreç  [Temiz]
  % 12,0 Başlangıç kayıtları             30 değer  [Temiz]
  % 15,0 Başlangıç klasörleri             6 dosya  [Temiz]
  % 27,0 Zamanlanmış görevler           247 görev  [Temiz]
  % 49,0 Windows servisleri            804 servis  [Temiz]
  % 51,0 Sistem klasörü (madenci)         6 konum  [Temiz]
  % 91,0 Gizli betikler              1.171 klasör  [Temiz]
  % 95,0 Defender istisnaları            12 kural  [Temiz]
  %100,0 Kilitlenen ayarlar               10 ayar  [Temiz]

  2.599 öğe, 9 alanda 3,5 saniyede incelendi.
```

Yolda iki hata yakalandı. Birincisi: `[Math]::Min(1, x)` tam sayıya yuvarladığı için
alan içinde yüzde ilerlemiyordu; çözüm `1.0` ve `[double]`. İkincisi: toplam ağırlık
değişkeni `$acc`, PowerShell büyük/küçük harf ayırmadığı için renk değişkeni `$ACC`'yi
eziyordu. Bu yüzden 4. adımdan sonra yüzde yazılmıyordu; değişkenin adı `$wsum` yapıldı.

Kalan küçük kusur: görevler adımında `Get-ScheduledTask` başta yarım saniye kadar tek
parça çalışır. Bu sırada yüzde %15,6'da bekler, sonra akar.
