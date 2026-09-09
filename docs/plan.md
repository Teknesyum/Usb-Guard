# Plan — 9 Eylül 2026 turu

Devir notundaki üç açık madde, artı devralma sırasında bulunan bir hata. Kullanıcı
"önerdiğin sırayla hepsini yap" dedi. Sıra, bağımlılık yüzünden 0 → 3 → 1 → 2 oldu:
winget manifesti yayında bir `.zip` varlığı ister, onu da CI üreten yayın akışı koyar.


## 0 — autorun.inf adı kaybı (bitti, v1.19, `7cd2e44`)

Bağışıklık `autorun.inf` dosyasını kilitli klasörle değiştirirken siliyordu; Windows
çıkarılabilir sürücünün adını o dosyanın `label=` satırından okuduğu için sürücünün adı
kalıcı olarak kayboluyordu. Karantinaya da alınmıyordu, geri dönüşü yoktu.

Ad artık dosya yok edilmeden önce okunup dosya sistemi birim etiketine yazılıyor. Etiket
dosya değil meta veridir; solucan `autorun.inf` bırakarak ele geçiremez. Ad yoksa ve
kurtarılacak bir şey de yoksa tek satırlık soru sorulup yazılıyor.

Değer saldırganın denetimindeki dosyadan geldiği için temizleniyor ve kabuğa hiç
verilmiyor — `SetVolumeLabelW`. Test: `tools/tlabel.ps1`.


## 3 — CI ile yeniden üretilebilir yayın

`.github/workflows/release.yml`. Etiket itilince `windows-latest` üzerinde:

1. `$VER` ile etiket birebir aynı mı,
2. `src/build.ps1` çalıştırılır ve üretilen `USB-Guard.bat` depodakiyle **bayt bayt**
   aynı mı (değilse yayın durur),
3. üretilen dosya ayrıştırılıyor mu,
4. `t117` ve `tlabel` koşar,
5. `USB-Guard-<ver>.zip` üretilir,
6. yayın açılır; sürüm notuna iki dosyanın sha256'sı tablo olarak girer.

Böylece hash'i herkes depodan yeniden üretebilir; derlemeyi elle yapıp yükleme biter.
Mevcut `virustotal.yml` yayın açılışına bağlı olduğu için kendiliğinden zincirlenir.


## 1 — Winget manifesti

`.bat` winget'in tanıdığı bir kurulum türü değil. Yol: `InstallerType: zip` +
`NestedInstallerType: portable`, arşivin içindeki `USB-Guard.bat` takma adla bağlanır.
Arşivi 3. madde üretiyor — bağımlılık bu.

Manifest üç dosyadır (`version`, `installer`, `locale`), depoda `packaging/winget/`
altında durur; `microsoft/winget-pkgs` deposuna PR olarak gider.


## 2 — Kendinden imzalı Authenticode

En pahalısı ve tek başına mimariyi değiştiren madde: Authenticode imzası `.bat`'e
gömülemez, `.ps1`'e gömülür. Ürünün tamamı "tek dosya polyglot" fikri üzerine kurulu
olduğu için imza, iki dosyalı dağıtıma geçmeden eklenemez.

Bu yüzden 2. madde bir kod işi değil, bir dağıtım kararıdır ve kullanıcıya sorulacaktır.
Ayrıntı ve seçenekler işin sonundaki raporda.
