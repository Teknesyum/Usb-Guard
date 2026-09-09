[[netlestirme:002]]

# Netleştirme: USB-Guard tek dosya .bat olarak mi kalsin, yoksa paket yoneticisi ve imza icin y

İşe başlamadan önce soruyu keskinleştir. Görüş verme, plan yazma, kod yazma.
Yalnız şunu döndür: soruda belirsiz kalan yerler, her biri için tek satırlık bir netleştirme sorusu, en fazla beş. Belirsizlik yoksa "net" yaz.

## Soru

USB-Guard tek dosya .bat olarak mi kalsin, yoksa paket yoneticisi ve imza icin yayina ikili dosya girsin mi? A (baslatici .exe + winget + imza), B (tek dosya kal), C (Chocolatey) secenekleri arasindan hangisini secmeliyim ve neden? Karar dogrudan uygulanacak.

## Elde olan olgular

# Olgular — USB-Guard dağıtım kararı

## Ürün nedir

USB-Guard, Windows için kısayol solucanı (shortcut worm) temizleyicisi. Solucan USB'deki
her klasörü gizleyip yerine aynı adlı `.lnk` bırakır; dosyalar duruyor görünür, tıklayınca
solucan çalışır. USB-Guard yükü karantinaya alır, gizli klasörleri geri taşır, öznitelikleri
temizler, sonra USB'yi "bağışıklar": solucanın ihtiyaç duyduğu adları (`sysvolume`,
`autorun.inf`, `recycler`, `recycled`) yeniden oluşturamayacağı kilitli klasörlere çevirir.
Ayrıca arkadaki PC'yi solucanın başlangıç kayıtları için tarar; betik motoru ve
çıkarılabilir sürücüden çalıştırma anahtarlarını kapatabilir. Antivirüs değildir ve
yerine geçmez.

Lisans AGPL-3.0. Depo public: `Teknesyum/Usb-Guard`. Yayında v1.19.

## Mimari — kararın çarptığı yer

Ürün **tek dosya polyglot**. `src/build.ps1`, `src/header.bat` ile `src/usb-guard.ps1`'i
birleştirip kökteki tek `USB-Guard.bat`'i üretir (UTF-8 BOM'suz, CRLF). Kullanıcı tek bir
`.bat` indirir, çift tıklar, biter. Kurulum yok, bağımlılık yok, ikili yok.

`.gitattributes` içinde `USB-Guard.bat -text` var; depodaki baytlar yayın dosyasının
baytlarına eşit. Yani indirilen dosyayı depoyla bayt bayt karşılaştırmak mümkün.

Dosya boyutu 101 153 bayt, sha256 `EE93F3BDAC828301FAA1F8391543533071153DA858AE0999BF77C638C7640292`.

## Bu turda biten iki iş

1. **autorun.inf ad kaybı düzeltildi (v1.19).** Bağışıklık `autorun.inf` dosyasını kilitli
   klasörle değiştirirken siliyordu. Windows çıkarılabilir sürücünün Gezgin'deki adını o
   dosyanın `label=` satırından okur, gerçek birim etiketinin önünde tutar. Dolayısıyla
   kullanıcının USB'sinin adı kalıcı olarak kayboluyordu; karantinaya da alınmadığı için
   geri dönüşü yoktu. Artık ad dosya yok edilmeden önce okunup dosya sistemi birim
   etiketine (`SetVolumeLabelW`) yazılıyor.

2. **CI ile yeniden üretilebilir yayın.** Etiket itilince GitHub Actions temiz bir
   `windows-latest` üzerinde kaynaktan derliyor; depodaki `USB-Guard.bat` yeniden
   derlenenle bayt bayt aynı değilse yayın duruyor. Testler koşuyor, `.zip` üretiliyor,
   sürüm notuna iki dosyanın sha256'sı tablo olarak giriyor. Yani hash zincirini artık
   herkes depodan tekrar üretebiliyor, elle derleyip yükleme bitti.

Ayrıca sürüm yayınlanınca VirusTotal'a otomatik gönderim var (yalnız `.0` ile biten
etiketlerde); rapor bağlantısı sürüm notuna kendiliğinden ekleniyor.

## Karara sebep olan iki blokaj

### Winget

Manifestler yazıldı (`InstallerType: zip` + `NestedInstallerType: portable`, arşivin
içinde `USB-Guard.bat`). `winget validate` (sürüm v1.29.290) reddetti:

    Manifest Error: The file type of the referenced file is not allowed.
    [RelativeFilePath] Value: USB-Guard.bat

Uzantıyı `.cmd` yapıp tekrar denendi, birebir aynı hata. winget'in `portable` kurulum türü
yalnız çalıştırılabilir ikili kabul ediyor. Ürün tek dosya `.bat` kaldığı sürece winget'e
giriş yolu yok. PR açılmadı.

### Authenticode imza

Authenticode imzası `.bat` dosyasına gömülemez; PowerShell imzayı `.ps1` sonuna yorum
bloğu olarak yazar. Yani imza, tek dosya polyglot'tan iki dosyalı dağıtıma geçmeyi
gerektirir.

Buna ek bir olgu: `cmd.exe` bir `.bat`'i çalıştırırken Authenticode imzasını hiç kontrol
etmez. İmza ancak `.exe`'de (SmartScreen/UAC kapısı) ya da `AllSigned` yürütme politikası
altındaki `.ps1`'de bir kapıya bağlanır. Tek dosya modelinde imzanın çalışma anında
getirisi yok; yalnızca kullanıcı dosyanın Özellikler penceresinden bakarsa görür.

Not: bu iddia deneyle doğrulanmadı — kod imzalama sertifikası üretmek sertifika deposuna
yazmak demek, kullanıcıdan izin istenmeden yapılmadı.

## Masadaki üç seçenek

**A — Arşive küçük bir başlatıcı `.exe` koymak.** Winget kapısı açılır, imza anlam
kazanır. Bedeli: yayına ilk kez derlenmiş bir ikili girer. Ürünün güven gerekçesi
"indirdiğin dosyayı metin editöründe açıp okuyabilirsin" olduğu için bu gerekçe zayıflar.
Ayrıca imzasız yeni bir `.exe` SmartScreen ve antivirüs sürtünmesi üretir; kendinden
imzalı sertifika SmartScreen'i geçirmez.

**B — Tek dosya kalmak.** Güven gerekçesi korunur; hash zinciri ve VirusTotal zaten var.
Bedeli: winget yok, imza yok, paket yöneticisi kapsaması yok.

**C — Chocolatey.** Chocolatey paketi PowerShell kurulum betiği kabul eder, ikili
istemez. Paket yöneticisi kapsaması ikiliye geçmeden gelir. Bedeli: winget'e göre dar
kitle, ayrı bakım yükü.

## Kullanıcı bağlamı

Kullanıcı bu üç seçeneği gördü ve karar vermek yerine "fable'a danış, ne derse yap" dedi.
Yani verilecek cevap doğrudan uygulanacak.
