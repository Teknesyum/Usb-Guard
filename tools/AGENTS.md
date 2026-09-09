# tools/

Geliştirme test takımı. Programa ait değil, yayın dosyasına girmez.

`_load.ps1` programı ana döngüye girmeden belleğe alır; diğerleri onu dot-source edip iç
fonksiyonları doğrudan çağırır. Yollar `$PSScriptRoot`'a göre çözülür.

- `t117.ps1` — sahte sürücü; `Test-Payload`, `Test-Cloak`, `Immunity-State`, `Inspect-Drive`
- `tlnk.ps1` — zararlı `.lnk` argüman çözümlemesi
- `tpc.ps1` — gerçek PC taraması, süre ve bulgu sayısı
- `tlines.ps1` — `subst X:` ile bitiş ekranı, satır sayısı
- `twrap.ps1` — cetvelli çıktı, satır genişliği

Çalıştırma: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\t117.ps1`

`src/usb-guard.ps1` değişince önce `src/build.ps1`, sonra bunlar. Beklenen sonuçlar
`docs/devir-2026-09-09.md` içinde.
