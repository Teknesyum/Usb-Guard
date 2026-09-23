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
