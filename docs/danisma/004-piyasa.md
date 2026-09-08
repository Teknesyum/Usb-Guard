# 004 — Piyasa Taraması ve Geliştirme Adayları

Tarih: 2026-09-08. Durum: v1.8 yayında. Ölçüt: basit, geri alınabilir, tek bat felsefesine uygun.
Kaynaklar en altta; her satırın yanında hangi araçtan geldiği yazıyor.


## Rakipler ve öne çıkan yanları

| Araç | Ne yapıyor | Bizde |
| --- | --- | --- |
| UsbFix (SOSVirus) | Kısayol solucanı temizliği, dosya kurtarma, aşı (autorun.inf), bozulan Explorer/regedit/taskmgr onarımı, süreç yöneticisi, rapor dosyası, gerçek zamanlı tarama | Temizlik ✔, kurtarma ✔, aşı ✔, onarım ✔, rapor ✘, süreç yöneticisi ✘ |
| Panda USB Vaccine | Kilitli autorun.inf; ayrıca PC'de AutoRun kapatma | autorun.inf ✔ (üstüne 4 ad daha), AutoRun kapatma ✘ (Win7+ zaten kapalı) |
| Bitdefender USB Immunizer | Silinemez sahte autorun.inf | ✔ |
| MCShield | Takılan sürücüyü anında tarar, heuristik + imza, güvenilir yayıncı listesi, açılışta tüm diskleri tarama, otomatik/etkileşimli mod | İzleyici ✔ (sorar), heuristik ✔ kısmi, otomatik mod ✘, açılış taraması ✘ |
| Ninja Pendisk | Tepside bekler, takılanı otomatik tarar ve aşılar, sıfır etkileşim | İzleyici soruyor; sessiz otomatik aşı ✘ |
| Smadav | İkinci katman AV, USB'de klasör-kısayol hilesi tespiti, "AI" tahmin | Klasör-ikon taklidi ✔; AI kapsam dışı |
| USB Disk Security | Her çıkarılabilir aygıtı kapsar, ücretli | Kapsam ✔ |
| GitHub betikleri (yousseffathy511, Smoodie7, nshaibu, lemasc) | Tek dosya bat/ps1/py; alt klasörlerdeki kısayolları da tarar (Jenxcus her klasöre kopyalıyor), dry-run seçeneği | **Alt klasör taraması ✘**, dry-run ✘ |
| Windows ilkesi | `Removable Disks: Deny execute access` — USB'den exe çalışmasını keser | ✘ |

Tehdit tarafı: ThreatDown 2024'te USB solucanlarında artış bildiriyor (Jenxcus / WSH RAT);
BleepingComputer 2025'te kısayol dosyasıyla yayılan kripto hırsızı solucan yazdı. Microsoft
VBScript'i 2027'de kaldıracak; WSH anahtarımız bu yönle uyumlu. Yeni varyantlar `.lnk` yerine
`cmd /c` argümanı, klasör-ikon `.exe` ve her alt klasöre kopya kullanıyor.


## Geliştirme adayları (ucuzdan pahalıya)

| # | Ne | Neden | Efor |
| --- | --- | --- | --- |
| 1 | **Alt klasörleri de tara** — kök dışındaki `.lnk` + gizli yükler | Jenxcus her klasöre kopyalıyor; bugün yalnız kök bakılıyor, en büyük boşluk | ~20 satır |
| 2 | **Karantinadan geri al** menüsü | Yanlış pozitifte kullanıcı dosyayı elle bulmak zorunda; UsbFix'te var | ~30 satır |
| 3 | **USB'den çalıştırmayı kapat** anahtarı (`RemovableStorageDevices\{53f5630d-...}\Deny_Execute=1`) | Klasör-ikon `.exe` solucanlarını tek kayıtla keser; WSH anahtarı gibi aç/kapa | ~15 satır |
| 4 | **Temizlik raporu** `%LOCALAPPDATA%\Usb-Guard\logs\<tarih>.txt` | Ne silindi, ne taşındı; destek isterken kanıt | ~15 satır |
| 5 | **İzleyici sessiz mod**: takılan USB'yi sormadan aşıla (temizlik yine sorar) | Ninja Pendisk'in tek üstünlüğü | ~15 satır |
| 6 | **Çift uzantı taklidi** (`foto.jpg.exe`, `belge.pdf.scr`) → Mimic | Yaygın hile, tek regex | ~3 satır |
| 7 | **Defender durumu** satırı (gerçek zamanlı koruma açık/kapalı) | Solucanlar kapatıyor; bir bakışta görünür | ~8 satır |
| 8 | **Sağ tık → "USB-Guard ile Düzelt"** (Drive shell kaydı) | Erişim kolaylığı | ~15 satır |
| 9 | **Dry-run / "Sadece Göster"** — temizlemeden bulguları listele | GitHub betiklerinde var, güven verir | ~20 satır |
| 10 | **İngilizce arayüz** (dil tablosu) | Rakiplerin hepsi EN; GitHub kitlesi | ~150 satır |
| 11 | Süreç yöneticisi, imza veritabanı, AI | Antivirüs alanı, kapsam dışı | — |

Önerilen paket **v1.9 = 1 + 2 + 3 + 6 + 7**: yaklaşık 80 satır, tek paketleme, bir test turu
(sentetik USB'ye alt klasör kısayolu ve çift uzantılı dosya eklenir). Kalanlar isteğe bağlı.

**Durum (v1.9 yayında):** 1, 2, 3, 6, 7 yapıldı. 7 Defender yerine Windows Güvenlik
Merkezi'nden okunuyor; hangi antivirüs kayıtlı ve koruması açık mı, onu gösteriyor.
Üstüne iki madde daha: ana menü sadeleşti (gelişmiş işler alt menüye indi) ve açılıştaki
güncelleme + PC taraması + antivirüs sorgusu arka plan runspace'ine taşındı; menü ~9 s
yerine ~1 s'de hazır. Kalan adaylar: 4 (rapor), 5 (sessiz izleyici), 8 (sağ tık),
9 (dry-run), 10 (İngilizce arayüz).


## Kaynaklar

- https://www.sosvirus.net/en/download/usbfix/
- https://www.softpedia.com/get/Antivirus/Removal-Tools/UsbFix.shtml
- https://www.pandasecurity.com/en/mediacenter/Panda-USB-and-AutoRun-Vaccine/
- https://www.bitdefender.com/en-us/blog/hotforsecurity/block-autorun-malware-with-bitdefender-usb-immunizer
- https://www.askvg.com/panda-usb-vaccine-and-bitdefender-usb-immunizer-free-tools-to-prevent-autorun-based-malware-attacks/
- https://www.softpedia.com/get/Antivirus/MCShield.shtml
- https://gearupwindows.com/mcshield-usb-security-windows/
- https://www.softpedia.com/get/Antivirus/Ninja-Pendisk.shtml
- https://www.smadav.net/?lang=en
- https://github.com/yousseffathy511/shortcut-virus-remover
- https://github.com/Smoodie7/ShortcutAntiVirus
- https://github.com/nshaibu/shortcutVirusRemover
- https://github.com/lemasc/lemascusbrem
- https://www.threatdown.com/blog/usb-worms-still-wriggling-on-to-under-protected-computers-after-all-these-years/
- https://www.bleepingcomputer.com/news/security/usb-worm-spreads-crypto-stealing-malware-via-windows-shortcut-files/
- https://malpedia.caad.fkie.fraunhofer.de/details/win.vjw0rm
- https://woshub.com/how-to-disable-usb-drives-using-group-policy/
