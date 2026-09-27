# Alt Ajan Bakışı 2 — Ham Çıktı

İstem: yalnızca görüntüler (`<ekran>-<olcek>-once/sonra.png`), kaynak koda bakma yasak; her ekranda 100 once, 100 sonra, 150 sonra.

---

## Usb-Guard Arayüz Denetimi — 2026-09-27

Bakılan: 11 ekran × (100-once, 100-sonra, 150-sonra) = 33 görüntü. Kaynak koda bakılmadı.

**Ortak değişim (tüm ekranlar):** v1.28→v1.29; "by …" → "Teknesyum : …" (mavi etiket), "Sponsor:" → "Destek Ol : …" (mor etiket); linkler artık beyaz (önce maviydi).

**Ortak kusur (tüm ekranlar):** Mavi seçim çubuğu içerik kenarından (x≈89) değil x≈71'den başlıyor ve sağda kutunun dışına taşıyor; "------" ayırıcılar üst kutudan ~2 karakter kısa — sağ kenarlar hizasız.

**01-dil** — (1) yalnızca ortak değişim. (2) kusur yok (ortak seçim çubuğu taşması hariç).

**02-ana-menu** — (1) ortak değişim. (2) ayırıcı çizgi kutudan kısa, seçim çubuğu ondan geniş — üç farklı genişlik. 150'de ölçek doğru.

**03-gelismis** — (1) Üst boşluk kalkmış: kutu ~1 satır yukarı çıkmış, başlık çubuğuna yapışık. (2) **150-sonra görüntüsü 100 ile piksel olarak aynı** — pencere adı "UGCAP15003" ama ölçek uygulanmamış; ya yakalama hatası ya da bu ekran ölçeklenmiyor (belirsiz). Üst boşluğun gitmesi diğer ekranlarla tutarsız.

**04-yardim** — (1) ortak değişim. (2) kusur yok.

**05-tarama** — (1) ortak değişim (sayılar farklı, gerçek tarama). (2) link satırlarından sonra 2 boş satır var, diğer ekranlarda 1; "% 8,0" / "%100,0" biçimi göze tuhaf ama hizalı. Başka kusur yok.

**06-karantina-bos** — (1) ortak değişim. (2) kusur yok.

**07-hata-sistem** — (1) ortak değişim; 100-sonra'da imleç görünmüyor (belirsiz, yanıp sönme olabilir). (2) hata rengi pembe; "Destek Ol" moru ona çok yakın — hata/marka etiketi karışıyor.

**08-hata-yok** — (1) ortak değişim. (2) 07'deki pembe/mor yakınlığı. "Q: Bulunamadı." kısa ve bağlamsız (içerik).

**09-cikis** — (1) "Destek Ol" etiketi, yeni "Web : teknesyum.com" satırı; iki nokta sütunu hizalanmış. (2) Linkler hem başlıkta hem gövdede — iki kez tekrar. Başlık ile gövde arasında 4 boş satır (fazla). Gövdedeki "Teknesyum | Usb-Guard" ile üstteki "USB-GUARD" arasında büyük/küçük harf tutarsızlığı.

**10-kurulum** — (1) [Ok] listesi → ✓ işaretli 5 adım (2 yeni adım), %100 ilerleme çubuğu eklenmiş. (2) ✓ düzgün (kutu değil). Başlık altında 2 boş satır (05'teki tutarsızlığın aynısı). Kusur yok.

**11-uyari** — (1) Klasik Windows mesaj kutusu → koyu temalı özel pencere; uyarı simgesi kalkmış, "Usb-Guard" başlığı eklenmiş, butonlar "Evet, Düzelt / Şimdi Değil". (2) **Bazı satırlarda kelimeler arası çift boşluk**: "dosyalar  neden  görünmüyor", "silinmedi,  yalnızca  gizlendi", "virüs  bilgisayara  da" — iki yana yaslama ya da metin ölçüm hatası. Pencere başlığı ile iç başlık aynı ("Usb-Guard") — gereksiz tekrar. Uyarı simgesinin kalkmasıyla aciliyet zayıflamış. **150-sonra 100 ile aynı** — ölçek uygulanmamış (belirsiz).

### En Önemli 5 Kusur
1. **03-gelismis ve 11-uyari'de 150 ölçeği uygulanmamış** — görüntüler 100 ile birebir aynı (gerçek ölçek hatası ya da yakalama hatası).
2. **11-uyari'de kelimeler arası çift boşluk** — metin bozuk görünüyor.
3. **03-gelismis'te üst boşluk kaybolmuş** — kutu başlık çubuğuna yapışık, diğer ekranlarla tutarsız.
4. **Hata rengi (pembe) ile "Destek Ol" etiketi (mor) çok yakın** (07, 08) — hata mesajı marka etiketinden ayırt edilemiyor.
5. **Genişlik tutarsızlığı** — seçim çubuğu sola taşıyor ve kutudan geniş, ayırıcılar kutudan kısa; ayrıca ekranlar arası boşluklar tutarsız (05, 10'da 2 boş satır; 09'da 4).
