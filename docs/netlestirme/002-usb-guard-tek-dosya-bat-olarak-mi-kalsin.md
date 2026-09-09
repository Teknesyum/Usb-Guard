# Netleştirme: USB-Guard tek dosya .bat olarak mi kalsin, yoksa paket yoneticisi ve imza icin y

- tarih: 2026-09-09
- girdi: 002-usb-guard-tek-dosya-bat-olarak-mi-kalsin-girdi.md
- maliyet: 49 420 token, 10 sn

## Dönen

Belirsiz noktalar:

1. "Paket yöneticisi kapsaması" hedefi ne: gerçek kullanıcı talebi mi (issue, indirme sayısı), yoksa "olsa iyi olur" mu?
2. Kod imzalama sertifikası (EV/OV, yıllık ücret) alınacak mı, yoksa yalnız kendinden imzalı mı düşünülüyor?
3. Hedef kitle kim: BT yöneticisi/teknisyen (paket yöneticisi kullanır) mi, sıradan ev kullanıcısı (indir-çift tıkla) mı?
4. A seçilirse `.exe` kaynağı depoda derlenip CI ile bayt bayt doğrulanacak mı, yoksa güven gerekçesinin kaybı kabul mü edilecek?
5. "Doğrudan uygulanacak" tek seçenek mi demek, yoksa B + C gibi bileşik bir karar kabul edilebilir mi?

---

## İkinci tur — karar

Netleştirme sorularına ölçülmüş cevaplar verildi (talep ölçümü: yıldız 1, fork 0, issue 0,
yayın başına indirme 1-2; ücretli sertifika yok, yol haritası "kendinden imzalı" diyor;
hedef kitle README'ye göre sıradan kullanıcı; bileşik karar serbest) ve karar istendi.

Maliyet: 48 195 token, 18 sn.

### Fable'ın cevabı (birebir)

**Karar: B, tek ek adımla — açık "yol haritasından düşür" notu.**

Gerekçe:

- A'nın tüm bedeli sabit (SmartScreen sürtünmesi, ikili yeniden üretilebilirliği, güven gerekçesinin kaybı), getirisi sıfır: kullanıcı yok, ücretli sertifika yok, kendinden imzalı imza SmartScreen'de hiçbir şey kazandırmıyor. Ölçülmüş talep olmadan projenin tek somut güven iddiasını ("indirdiğini okuyabilirsin") feda etmek net kayıp.

- C'nin bedeli düşük ama getirisi de sıfır: sıradan kullanıcı Chocolatey kurmaz, README zaten "çift tıkla" diyor. Ayrı bakım yükü, hizmet ettiği kimse olmayan bir kanal için. B+C bileşimi bu yüzden değmez.

- B'de zaten olan şey (CI doğrulamalı hash zinciri, VirusTotal otomasyonu, yeniden üretilebilir derleme kanıtı) bir `.bat` için elde edilebilecek en güçlü güven sinyali. Winget'in dosya-tipi kuralı bunu bozan dış kısıt; ona uymak için mimariyi değiştirmek kuyruğun köpeği sallaması.

Yeniden açma eşiği: talep ölçülebilir hale gelince (ilk dış issue ya da yayın başına ≥50 indirme) önce C, ancak EV/OV bütçesi çıkarsa A.

Uygulama: winget manifest dosyaları `trash/`'e, yol haritasındaki winget ve Authenticode maddeleri "ertelendi, eşik: dış talep" diye işaretlenir, README'ye tek satır "neden kurulum paketi yok" eklenir.
