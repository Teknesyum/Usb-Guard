# Ölçüm — v1.14 polyglot bat/ps1

Tek dosya artık hem bat hem PowerShell. Paketleme, %TEMP%'e yazma ve
`-ExecutionPolicy Bypass` kalktı.

## src/build.ps1 çıktısı

    bat bytes  : 85335
    body match : True
    sha256     : 41F7CE3B1EE33215EC986176CF7E7DACE75A14E6CED54058398B0F95101C423F
    parses     : True

## cmd tarafı (yükseltme bloğu çıkarılmış kopya ile)

    cmd /c "poly3.bat -Bg"
    Found {}  Upd ok  Def na

## PowerShell tarafı

    & ([scriptblock]::Create([IO.File]::ReadAllText($bat))) -Bg  ->  Hashtable
    menü/durum ekranı iki dilde de çiziliyor (langtest)
    izleyici: powershell -Command "& ([scriptblock]::Create(...)) -Watch" -> süreç ayakta

## Dil tabloları

    tr anahtar: 190   en anahtar: 190 — kümeler ayni, bos deger yok
