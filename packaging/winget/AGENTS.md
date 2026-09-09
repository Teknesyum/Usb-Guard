# packaging/winget/

`microsoft/winget-pkgs` deposuna gidecek manifestler. Sürüm başına bir klasör, içinde
üç dosya: `version`, `installer`, `locale.en-US`.

**Durum: gönderilemiyor — blokaj winget tarafında.**

`winget validate` (v1.29.290) reddediyor:

    Manifest Error: The file type of the referenced file is not allowed.
    [RelativeFilePath] Value: USB-Guard.bat

`portable` kurulum türü yalnız çalıştırılabilir ikili kabul ediyor; `.bat` de `.cmd` de
listede yok. Ürün tek dosya `.bat` olduğu sürece winget'e girmesinin yolu yok.

Açık tek yol arşive küçük bir başlatıcı `.exe` koymaktır — yani yayına ilk kez derlenmiş
ikili girer. Bu bir paketleme ayrıntısı değil, ürün kararıdır: okunabilir tek dosya olmak
USB-Guard'ın güven gerekçesi. Karar verilmeden PR açılmaz.

Buradaki manifestler karar "evet" çıkarsa hazır durur; `InstallerSha256` ve
`InstallerUrl` o sürümün yayınından alınır, `packaging/winget/<sürüm>/` altına kopyalanır.

Doğrulama: `winget validate --manifest packaging\winget\<sürüm>`
