# tools/

Geliştirme test takımı. Programa ait değil, yayın dosyasına girmez.

`_load.ps1` programı ana döngüye girmeden belleğe alır; diğerleri onu dot-source edip iç
fonksiyonları doğrudan çağırır. Yollar `$PSScriptRoot`'a göre çözülür.

- `t117.ps1` — sahte sürücü; `Test-Payload`, `Test-Cloak`, `Immunity-State`, `Inspect-Drive`
- `tlnk.ps1` — zararlı `.lnk` argüman çözümlemesi
- `tpc.ps1` — gerçek PC taraması, süre ve bulgu sayısı
- `tlines.ps1` / `twrap.ps1` — `subst X:` bitiş ekranı satır sayısı; cetvelli satır genişliği
- `tlabel.ps1` — `autorun.inf` etiket ayrıştırma ve ad temizleme
- `tmenu.ps1` — ana menü sırası ve "Her Yere Kur ve Tara" seçeneği
- `tauto.ps1` — `subst` ile virüslü sahte USB; otomatik düzeltme, yüzde ve özet
- `tui.ps1` — renk tablosu: her renk token'a bağlı, 7:1 kontrast, conhost'ta uygulanıp geri yükleniyor (`-Static` CI için)
- `tcap.ps1` — gerçek pencere görüntüleri, 100/125/150 (`-Tag once|sonra`, `-Only`, `-Scale`)
- `tar.ps1` — dosya-tabanlı `autorun.inf` bağışıklığı, klasör→dosya göçü, kötücül ayrımı

Çalıştırma: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\t117.ps1`; kaynak değişince
önce `src/build.ps1`, sonra bunlar. Beklenen sonuçlar `docs/devir-2026-09-09.md` içinde.
