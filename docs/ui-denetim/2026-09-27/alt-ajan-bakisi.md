# Alt Ajan Bakışı — Ham Çıktı

Taze bir alt ajana (sonnet) yalnızca bu klasördeki 9 PNG verildi, kaynak kod verilmedi. Aşağıdaki metin
değiştirilmeden aktarılmıştır. `05-tarama.png` bu bakıştan sonra düzeltilip yeniden alınmıştır.

---

**01-dil:** temiz.

**02-ana-menu:**
- "Şu An Guard Edilebilir USB Yok." — sarı kullanılmış ama uyarı değil, bilgi; hata/uyarı sarısıyla karışıyor. Nötr beyaz/gri daha doğru olur.
- "Bilgi: Sağ Ok" ile "Yön: Ok" alt satırda yakın hizalı ama aralarında boşluk tutarsız (geniş boşlukla ayrılmış tek satır) — okunuyor, sorun değil.

**03-gelismis:**
- "İzleyici: Açık" yeşil, ama "Betik Motoru: Açık" ve "USB'den Çalıştırma: Açık" beyaz/varsayılan renkte — aynı anlam (açık/etkin durum) farklı renklendirilmiş, tutarsızlık. Üçü de aynı durumu gösteriyorsa aynı renk (yeşil) kullanılmalı.
- "Yoksayılan: 2" nötr beyaz, kabul edilebilir.

**04-yardim:** temiz, düzgün satır sarımı.

**05-tarama:**
- Yüzde hizası: "% 8,0", "%100,0" gibi değişken genişlikte yüzde işareti boşluğu — dikey hizasızlık, sayılar sağa yaslı değil (8,0 ile 100,0 arasında karakter kayması var). Sabit genişlikli alan/sağa hizalama önerilir.
- Sağ kenarda görünen "\" ve "d" harfleri (satır kesikleri, ekran sağında taşma) — "Gizli betikler" ve "Defender istisnaları" satırları pencere genişliğini aşıyor, kesiliyor. Pencere genişletilmeli veya metin kısaltılmalı.
- "[Temiz]" etiketleri hep beyaz, ama en alttaki genel sonuç "Temiz." yeşil — aynı kelime iki farklı bağlamda iki renk, hafif tutarsız ama kabul edilebilir (biri etiket, biri sonuç).

**06-karantina-bos:** "Karantina boş." sarı — bilgi mesajı, hata/uyarı değil; sarı yerine nötr/beyaz veya yeşil ("her şey temiz" anlamında) daha tutarlı olur.

**07-hata-sistem:** "Sistem Sürücüsü İşlenmez." pembe/hata rengi (#FA8CFF) kullanılmış — bu bir hata mı yoksa bilgilendirme mi belirsiz; metin başlı başına açıklayıcı değil, hangi işlemin reddedildiği belirtilmemiş.

**08-hata-yok:** "Q: Bulunamadı." — hata rengiyle gösterilmiş ama "Q:" kısaltması anlamsız/belirsiz (muhtemelen "Karantina" kısaltması), kullanıcı için açık değil. "Bulunamadı." tek başına neyin bulunamadığını söylemiyor.

**09-cikis:** temiz.

**En önemli 3 bulgu:**
1. 03-gelismis: Aynı "Açık" durumu için tutarsız renk (İzleyici yeşil, diğer ikisi beyaz) — durum renklendirmesi standardize edilmeli.
2. 05-tarama: Sağda metin taşması/kesilmesi ("Gizli betikler", "Defender istisnaları" satırları) ve yüzde sütununun hizasızlığı.
3. 07/08: Hata mesajları çok kısa ve belirsiz ("Sistem Sürücüsü İşlenmez.", "Q: Bulunamadı.") — kullanıcı hangi işlemin, neden başarısız olduğunu anlamıyor.
