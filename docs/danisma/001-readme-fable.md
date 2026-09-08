# 001 — README Danışması (Fable)

Tarih: 2026-09-08 · Model: claude-fable-5-1 · Maliyet: 51.973 token, 65 sn, 0 araç çağrısı

Uygulanan sapmalar: EN'de "Y / N" yerine programın gerçek istemi olan "E / H (Yes / No)" yazıldı;
yönetici onayı adımına "ACL kilitleri için gerekli" gerekçesi geri kondu (doğru olgu, sadece
prompt'ta eksikti).


## Gönderilen

```
Sen bir açık kaynak projesi için README editörüsün. Aşağıda "USB-Guard" adlı küçük bir Windows aracının İngilizce ve Türkçe README dosyaları var. Görevin: ikisini de gözden geçirip DÜZELTİLMİŞ TAM METİNLERİNİ vermek.

Proje hakkında bilinmesi gerekenler (uydurma, sadece bunları kullan):
- USB-Guard tek bir kendini-yükselten .bat dosyasıdır. Kurulum gerektirmez. Çift tıklanır, yönetici onayı ister.
- Kısayol/autorun solucanlarına karşı USB'yi TEMİZLER (zararlı .lnk kısayollarını siler, solucanın sürücü etiketi adlı klasöre gizlediği gerçek dosyaları geri taşır, sysvolume yükünü siler, Sistem+Gizli işaretli dosyaları görünür yapar).
- USB'yi AŞILAR: solucanın ihtiyaç duyduğu isimleri (autorun.inf, recycler, recycled, sysvolume ve sürücü etiketi) kilitli sahte klasörlerle işgal eder; her sahte klasörde normal silmeyle kaldırılamayan ayrılmış adlı alt klasör (con..) vardır; bu FAT32/exFAT'te de çalışır; NTFS'te ayrıca Herkes için Deny ACL uygular.
- Zaten aşılı sürücü algılanır, "Zaten Aşılı" gösterilir, atlanır.
- YENİ (v1.4): "Bu PC'yi Tara ve Kalıntıları Temizle" seçeneği. Windows'un otomatik başlatma kayıtlarında (Run/RunOnce), Başlangıç klasöründe ve Temp/AppData'daki şüpheli .vbs yüklerinde solucan kalıntısı arar; bulduklarını listeler; kullanıcı E/H ile onaylarsa kayıtları siler, dosyaları silmez KARANTİNAYA taşır (geri alınabilir).
- İsteğe bağlı arka plan izleyici: virüslü USB takılınca Evet/Hayır sorar; tıklamadan hiçbir şey çalışmaz; menüden kaldırılır.
- Yalnız çıkarılabilir USB'ler listelenir; sistem, bulut, boot/EFI bölümleri gizlenir.
- Ok tuşlarıyla menü.
- cmd çalıştırır; içeride Windows'un yerleşik PowerShell 5.1'i kullanılır (Win7+'ta hep var); PowerShell 7 gerekmez.
- Kendiliğinden yayılmaz; geri alınabilir; ağ kullanmaz.
- Lisans: AGPL-3.0-or-later. Yazar: Teknesyum. GitHub: https://github.com/Teknesyum  Sponsor: https://github.com/sponsors/Teknesyum

Kurallar:
- Başlıklar Title Case (Her Kelimenin İlk Harfi Büyük).
- Yorum satırı, boş laf, pazarlama abartısı yok. Kısa, net, teknik olarak doğru.
- Havadar düzeni koru: bölümler arası "---" ayraç ve bol boş satır; ortalı büyük başlık bloğu ve imza bloğu aynen kalsın.
- Şu HTML/rozet satırlarını AYNEN koru, değiştirme: en üstteki "<!-- lang -->" bloğu, "<div align=\"center\">" başlık bloğu, en alttaki "<!-- signature -->" bloğu.
- İngilizce README doğal, akıcı İngilizce olsun; Türkçe README doğal Türkçe olsun (çeviri kokmasın).
- Yeni v1.4 PC tarama özelliğini "What USB-Guard Does / USB-Guard Ne Yapar" altına uygun bir alt başlıkla EKLE.
- Yanlış, eksik ya da belirsiz bulduğun yerleri düzelt.

ÇIKTI FORMATI (kesinlikle bu sırayla, başka hiçbir şey yazma):
=== DEGERLENDIRME ===
(Türkçe, en çok 8 madde: neyi neden değiştirdin)
=== README.md ===
(İngilizce README'nin TAM yeni metni)
=== README.tr.md ===
(Türkçe README'nin TAM yeni metni)

--- MEVCUT README.md ---
(v1.3 README.md tam metni — git geçmişinde: commit öncesi hali)

--- MEVCUT README.tr.md ---
(v1.3 README.tr.md tam metni — git geçmişinde: commit öncesi hali)
```


## Gelen

```
=== DEGERLENDIRME ===
- "Bu PC'yi Tara ve Kalıntıları Temizle" (v1.4) için "What USB-Guard Does / USB-Guard Ne Yapar" altına "Scan This PC / Bu PC'yi Tarar" alt başlığı eklendi: Run/RunOnce, Başlangıç klasörü, Temp/AppData `.vbs`, liste + E/H onayı, kayıt silme, dosyaların karantinaya taşınması.
- Kullanım adımlarına PC tarama menü seçeneği ve Enter ile seçim akışı eklendi; "Only drives" cümlesi menüde artık sürücü dışı seçenek de olduğu için "drive list" olarak netleştirildi.
- Yönetici onayı adımındaki "ACL kilitleri için gerekli" gerekçesi verilen olgularda yok; gerekçe kaldırıldı, yalnız "onayla" kaldı.
- TR "aşılanması güvenli ve faydalı" ifadesindeki "faydalı" olgu dışı; kaldırıldı. "flash flash yayılan" ifadesi "bir flash bellekten diğerine" ile düzeltildi.
- "Güvenlik / Geri alınabilir" maddesine karantina eklendi; TR'de "Bağışıklık" yerine belgenin geri kalanıyla tutarlı "Aşı" kullanıldı.
- EN "Zaten Aşılı" arayüz metni olduğu için korundu, parantez içi açıklaması bırakıldı.
- EN'de "look-alike shortcut", "payload drop" gibi ifadeler sadeleştirildi; TR'de "taklit kısayol" ve "yük" cümleleri Türkçe akışa göre yeniden yazıldı.
- Korunması istenen `<!-- lang -->`, `<div align="center">` başlık ve `<!-- signature -->` blokları birebir bırakıldı.

=== README.md ===
(Uygulandı: README.md — tek fark: "Y / N" → "E / H (Yes / No)", admin adımına ACL gerekçesi geri kondu)

=== README.tr.md ===
(Uygulandı: README.tr.md — tek fark: admin adımına ACL gerekçesi geri kondu)
```
