[[netlestirme:002]]

# Netleştirme: USB-Guard tek bir .bat dosyasi olarak dagitiliyor ve icinde gzip+base64 gomulu b

İşe başlamadan önce soruyu keskinleştir. Görüş verme, plan yazma, kod yazma.
Yalnız şunu döndür: soruda belirsiz kalan yerler, her biri için tek satırlık bir netleştirme sorusu, en fazla beş. Belirsizlik yoksa "net" yaz.

## Soru

USB-Guard tek bir .bat dosyasi olarak dagitiliyor ve icinde gzip+base64 gomulu bir PowerShell betigi var; bu, zararli yazilim paketleyicileriyle birebir ayni desen. Kullaniciya ve antivirus motorlarina zararli olmadigimizi nasil ispat ederiz? Paketleme kaldirilsin mi, kaldirilirsa yerine ne konur, ve imza/seffaflik icin hangi somut adimlar hangi sirayla atilir?

## Elde olan olgular

# USB-Guard — güven / zararsızlık ispatı için olgular

## Program ne

Windows için tek dosyalık bir USB kısayol-solucanı temizleyicisi. Kullanıcı `USB-Guard.bat`
dosyasını çift tıklar, program kendini yönetici olarak yükseltir, takılı USB'leri listeler,
seçilen sürücüyü temizler ve "aşılar" (solucanın kullandığı adları kilitli klasörlerle işgal
eder). Ayrıca bu bilgisayarı solucan kalıntısı için tarar.

Sürüm v1.12. Depo: github.com/Teknesyum/Usb-Guard. Yazar tek kişi, şirket yok.

## Dağıtım biçimi — sorunun kaynağı

Dağıtılan tek şey `USB-Guard.bat`, 30 KB. İçeriği şu:

```
@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "SELFBAT=%~f0"
set "PS1=%TEMP%\usb-guard.ps1"
powershell -NoProfile -Command "$b=[Convert]::FromBase64String('H4sIAAAA... ~30 000 karakter ...'); $i=New-Object IO.MemoryStream(,$b); $g=New-Object IO.Compression.GzipStream($i,[IO.Compression.CompressionMode]::Decompress); $r=New-Object IO.StreamReader($g,[Text.Encoding]::UTF8); [IO.File]::WriteAllText($env:PS1,$r.ReadToEnd(),[Text.Encoding]::UTF8)"
net session >nul 2>&1
if %errorlevel% NEQ 0 (
  powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" %*
endlocal
```

Yani: gzip+base64 gömülü bir PowerShell betiği `%TEMP%`'e açılır ve
`-ExecutionPolicy Bypass` ile çalıştırılır; ardından UAC ile yönetici olunur.

Bu, zararlı yazılım paketleyicilerinin birebir aynı deseni. Kullanıcı açısından okunabilir
hiçbir şey yok.

## Kaynak kod nerede

Asıl kaynak `usb-guard.ps1`, 1300 satır, yaklaşık 77 KB. **Depoda yok** — `.gitignore`
içinde `*.ps1` ve `usb-guard.ps1` satırları var, kaynak hiç commit edilmemiş. Depoda
yalnızca paketlenmiş `.bat`, README (İngilizce + Türkçe), CHANGELOG, LICENSE ve
`docs/` altında Türkçe notlar var.

Paketleme betiği (`pack.ps1`) da depoda değil; yerel makinede duruyor. Yaptığı iş:
ps1'i gzip'le, base64'le, bat içindeki `FromBase64String('...')` deseninin içini değiştir,
sonra geri açıp SHA256 karşılaştır.

## Programın gerçekten yaptığı ayrıcalıklı işler

- USB kökünde kilitli klasörler açar (ACL ile `Everyone: Deny Write`), `autorun.inf`,
  `sysvolume`, `recycler`, `recycled` ve sürücü etiketi adlarını işgal eder.
- Zararlı `.lnk` dosyalarını siler; `.vbs/.js/.exe` yükleri `%LOCALAPPDATA%\Usb-Guard\quarantine`
  altına taşır (silmez, manifest yazar, geri alınabilir).
- Bu PC taramasında: Run/RunOnce, Winlogon, başlangıç klasörleri, zamanlanmış görevler,
  servisler, Defender dışlamaları ve Explorer sabotajı kayıtlarını okur; onay verilirse siler.
- İki isteğe bağlı anahtar: Windows Script Host'u kapatır (HKLM kayıt değeri),
  çıkarılabilir diskten `.exe` çalıştırmayı kapatır (HKLM ilke değeri).
- İsteğe bağlı arka plan izleyicisi: WMI `Win32_VolumeChangeEvent` aboneliği, USB takılınca
  Evet/Hayır soran bir kutu. Şu an HKCU `Run` anahtarına yazılıyor.
- Açılışta GitHub'ın son yayınını sorar, yeni sürüm varsa `.bat`'ı indirip kendini değiştirir
  ve yeniden başlar. (İmza doğrulaması yok; yalnızca "5 KB'dan büyük mü ve içinde
  `FromBase64String` geçiyor mu" denetimi var.)

Bunların her biri tek başına bir antivirüsün davranış motorunda kırmızı bayrak.

## Kısıtlar

- Kod imzalama sertifikası yok, satın alma bütçesi belirsiz (EV sertifika yıllık birkaç yüz
  dolar). Bir şirket tüzel kişiliği yok.
- Program tek `.bat` olarak kalmalı isteniyor: kurulum yok, çift tıkla çalışsın.
  Ama bu şart, ispat için gerekiyorsa gevşetilebilir.
- Hedef kitle teknik değil: internet kafe, fotokopici, okul, küçük ofis. "Kaynağı oku"
  demek onlar için bir cevap değil.
- Depo İngilizce; program artık iki dilli (İngilizce/Türkçe).

## Sorulan

Kullanıcının cümlesi: "bizim zararlı olmadığımızın ispatını nasıl yapabiliriz diye fable a
soralım, şifreleme gerekirse kalksın."

Yani gzip+base64 paketleme kaldırılabilir; bu bir gereklilik değil, sadece tek dosya
kolaylığı için var.
