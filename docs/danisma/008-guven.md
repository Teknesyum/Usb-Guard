# Fable'ın cevabı (008) — güven / zararsızlık ispatı

Girdi: [008-guven-girdi.md](008-guven-girdi.md) — maliyet: 49233 token, 92 s.

---

# Görüş

## 1. Paketleme kalksın mı

**Evet, kalksın.** Gerekçe üç katlı:

- gzip+base64 gövde + `%TEMP%`'e yazma + `-ExecutionPolicy Bypass` + UAC yükseltme: bu zincirin her halkası tek başına heuristik puan, dördü birlikte neredeyse kesin "Trojan:Script/Wacatac"-tipi genel imza. Paketleme hiçbir işlevsel fayda sağlamıyor; yalnızca AV'nin ve kullanıcının okumasını engelliyor. Okunmazlığın tek gerekçesi "tek dosya" şartı, o da paketlemesiz sağlanabilir.
- Kaynak depoda yok. Yani şu an dağıtılan şeyle görünen kaynak arasında hiçbir bağ kurulamıyor; "açık kaynak" iddiası doğrulanamaz durumda. Bu, paketlemeden bile daha ağır güven açığı.
- Statik gizleme AV'ye karşı hiçbir zaman kazanılmaz bir yarış; görünürlük ise kalıcı puan.

**Yerine ne konur — polyglot bat/ps1, tek dosya kalır:**

`.bat`'ın ilk birkaç satırı kendini PowerShell'e okutur, ps1 gövdesi düz metin olarak aynı dosyada devam eder. Klasik desen: bat başı `<# :` ile PowerShell yorum bloğu açar, `powershell -NoProfile -File "%~f0"` yerine `-Command "iex (Get-Content '%~f0' -Raw)"` ile kendi içeriğini çalıştırır, `#>` sonrası ps1 kodu gelir. Kullanıcı Not Defteri'nde açınca tüm kodu okur. `%TEMP%`'e yazma kalkar. Bypass yerine `-ExecutionPolicy RemoteSigned` yeterlidir çünkü dosya artık diskten değil bellekten yürütülüyor; yine de `iex` bir bayrak, ama Bypass+TEMP ikilisinden hafif.

Daha temiz alternatif: **iki dosya, tek zip** — `USB-Guard.bat` (10 satır, sadece yükseltip `usb-guard.ps1`'i çağırır) + `usb-guard.ps1` düz metin. Tek dosya şartını kırıyor ama AV profili en düşük olan bu. Hedef kitle zip açmayı biliyor; "klasörü masaüstüne çıkar, bat'a çift tıkla" makul.

Önerim: polyglot ile başla; AV taramalarında hâlâ takılıyorsa iki dosyaya geç.

## 2. Bedava adımlar, sırayla

1. **Kaynağı depoya koy.** `.gitignore`'dan `*.ps1` çıkar, `usb-guard.ps1` ve `pack.ps1` commit. Bu her şeyin ön şartı; yapılmadan diğerleri anlamsız.
2. **Paketlemeyi kaldır** (madde 1). Dağıtılan dosya = depodaki dosya, byte byte.
3. **Yeniden üretilebilir yayın.** GitHub Actions ile release'i CI üretsin; yayın notunda SHA256 yazsın. Kullanıcı `Get-FileHash` ile karşılaştırabilsin. Actions loguna herkes bakabilir: "bu dosya bu kaynaktan bu işlemle çıktı."
4. **Self-signed sertifika ile Authenticode imzası** (`New-SelfSignedCertificate -Type CodeSigningCert`, `Set-AuthenticodeSignature`). SmartScreen'i ikna etmez ama (a) dosya bütünlüğünü kanıtlar, (b) güncelleme doğrulamasında kullanılır (bölüm 5), (c) sertifika parmak izi README'de yayınlanır. Bat'a Authenticode gömülmez; ps1'e gömülür — iki dosya modelinin bir avantajı daha.
5. **VirusTotal'a her sürümü kendin yükle**, sonucu README'ye linkle. Takılma varsa Microsoft Defender'ın "Submit a file for malware analysis" formuyla yanlış pozitif bildir; tek geliştirici için ücretsiz ve genelde 1-3 günde temizliyorlar. Kaspersky, ESET, Avast benzer formlar sunar.
6. **Davranış listesini yumuşat:**
   - `-ExecutionPolicy Bypass` → `RemoteSigned` veya hiç (bellekten yürütme).
   - WSH kapatma ve çıkarılabilir diskten exe engelleme HKLM anahtarları varsayılan kapalı kalsın, açıkça "sistem ilkesi değiştirir" uyarısıyla.
   - Defender dışlamalarını okuma → yalnız okuma, silme onaylı; zaten öyle, ama README'de yazsın.
   - Kendini güncelleme varsayılan **kapalı** ya da yalnız "yeni sürüm var" bildirimi; indirme kullanıcı onayıyla (bölüm 5).
7. **SECURITY.md ve `docs/threat-model`** (İngilizce): programın yaptığı her ayrıcalıklı işi tablo hâlinde listele — ne, neden, geri alınabilir mi, nerede log'lanır. AV analistleri bu dosyayı okur.
8. **Kayıt tut**: program her çalışmada `%LOCALAPPDATA%\Usb-Guard\log.txt`'ye ne sildiğini, ne taşıdığını yazsın. Karantina manifesti zaten var; log da olsun. "Neyi değiştirdi" sorusuna cevap.
9. **Winget manifest** gönder (ücretsiz). Winget'e alınmış olmak bir güven sinyali; PR süreci Microsoft'un temel taramasından geçer.

## 3. Para isteyen adımlar

- **OV kod imzalama sertifikası** (Sectigo/Certum bayileri): yıllık ~200-400 $ + 2023'ten beri zorunlu donanım token'ı (~50-100 $). Bireysel adına alınabilir, tüzel kişilik şart değil; kimlik ve adres doğrulaması ister. **Sınırlı değer:** SmartScreen itibarı OV ile sıfırdan başlar, itibar kazanana kadar yine "bilinmeyen yayıncı" uyarısı çıkar. Bat dosyasına imza gömülmez, yalnız ps1/exe'ye. Hedef kitle uyarıları okumaz, "Yine de çalıştır"a basar. Şu an için **değmez**; önce bedava adımlar.
- **EV sertifikası**: ~400-700 $/yıl, **tüzel kişilik şart**. SmartScreen'de anında itibar. Şirket yok → şu an mümkün değil.
- **Azure Trusted Signing**: ~10 $/ay, ama yine 3 yıllık doğrulanabilir tüzel kişilik veya kimlik ister, Türkiye'de birey için erişim belirsiz. Takip et, henüz değil.
- **Certum Open Source Code Signing**: ~70-90 €/yıl + kart okuyucu, açık kaynak projelere bireysel verilir. Para harcanacaksa **en makul seçenek bu**; adım 1-6 bittikten ve proje birkaç ay sorunsuz yaşadıktan sonra.

Özet: bugün sıfır lira ile puanın %80'i alınır. Sertifika, kaynak açık ve dağıtım şeffaf olmadan hiçbir şeyi kanıtlamaz.

## 4. Teknik olmayan kullanıcıya ne söylenir

README'ye (İngilizce; Türkçe README'ye aynısı):

> **Is this safe?** USB-Guard is a plain text file. Right-click it and choose Edit — everything it does is written there in readable code. Nothing is hidden, compressed or downloaded from anywhere except our own release page.
>
> **Why does Windows ask for permission?** Cleaning a USB stick and checking startup entries needs administrator rights. USB-Guard never installs anything and never runs in the background unless you turn on the optional watcher.
>
> **Why does my antivirus warn?** Because USB-Guard does the same things a worm does — creates folders on the USB root and edits startup entries — but in reverse. The file you downloaded is exactly the one at github.com/Teknesyum/Usb-Guard/releases; compare the checksum shown there. Nothing is deleted permanently: everything goes to `%LOCALAPPDATA%\Usb-Guard\quarantine` and can be restored.

Programın açılış ekranına, ilk çalıştırmada bir kez:

> Bu program USB'nizdeki kısayol virüsünü temizler ve bu bilgisayarın başlangıç kayıtlarını denetler. Hiçbir dosyayı kalıcı silmez; şüpheli dosyalar karantina klasörüne taşınır ve geri alınabilir. Kaynak kodu: github.com/Teknesyum/Usb-Guard — Devam etmek için E, çıkmak için Q.

Her ayrıcalıklı işlemin öncesinde tek satır: "Şunu yapacak: [ne]. Geri alma: [nasıl]." Zaten onay soruluyor; onayın yanında geri alma yolu da yazsın.

## 5. Kendini güncelleme

Mevcut hâl en zayıf nokta: imzasız dosya indirip kendini üzerine yazmak, ilerde GitHub hesabı çalınsa veya DNS/proxy araya girse tam ele geçirme demek. "5 KB ve FromBase64String var mı" denetimi sıfır güvenlik.

- **Varsayılan davranış: yalnız bildir.** "v1.13 çıktı — indirmek için: [link]". İndirmeyi kullanıcı yapar.
- Otomatik güncelleme kalacaksa: **yayın notunda SHA256**, indirilen dosyanın hash'i eşleşmezse sil ve uyar. Hash'i `releases/latest` API'sinden değil, depodaki imzalı bir `checksums.txt`'den al.
- Daha iyi: self-signed sertifika (bölüm 2, adım 4) parmak izini programa göm; indirilen ps1'de `Get-AuthenticodeSignature` ile imzayı ve parmak izini doğrula. Bat için Authenticode yok → bu da iki dosya modelini destekler.
- HTTPS'i zorla, yönlendirmeleri `github.com`/`objects.githubusercontent.com` dışına izin verme.
- Geri alma: eski sürümü `%LOCALAPPDATA%\Usb-Guard\backup\` altına koy, yeni sürüm ilk çalışmada çökerse eskiyi geri yaz.
- Sürüm düşürmeyi engelle: indirilen sürüm numarası mevcuttan küçükse reddet.
- Güncelleme kontrolünü açılışta değil, kullanıcı menüden istediğinde ya da en fazla haftada bir yap; her açılışta ağa çıkan bat AV için ayrı bir bayrak.
