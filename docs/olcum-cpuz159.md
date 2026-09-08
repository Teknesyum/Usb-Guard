# Ölçüm — cpuz159 yanlış pozitifi (v1.13)

Ekran görüntüsündeki bulgu:

    [Svc   ] Service: cpuz159
             \??\C:\WINDOWS\temp\cpuz159\cpuz159_x64.sys |

`Find-Services` içindeki `\Temp\` sezgiseli tetikliyordu. Sondaki `|`,
`(($ip,$dll) -join ' | ')` ifadesinin boş `ServiceDll` ile birleşmesi.

## Bin-Path / Test-Trusted çıktısı (bintest.ps1)

    IN : \??\C:\WINDOWS\temp\cpuz159\cpuz159_x64.sys
    BIN: C:\WINDOWS\temp\cpuz159\cpuz159_x64.sys
    TRU: False
    
    IN : \SystemRoot\System32\drivers\storahci.sys
    BIN: C:\Windows\System32\drivers\storahci.sys
    TRU: True
    
    IN : "C:\Program Files\App\a b.exe" -k netsvcs
    BIN: C:\Program Files\App\a b.exe
    TRU: False
    
    IN : C:\Windows\Temp\evil\u123456.dll
    BIN: C:\Windows\Temp\evil\u123456.dll
    TRU: False
    
    IN : %SystemRoot%\system32\svchost.exe -k LocalService
    BIN: C:\Windows\system32\svchost.exe
    TRU: True
    

## İmza katalogdan da bulunuyor mu

    storahci.sys -> %TEMP% kopyası : Valid
    notepad.exe  -> %TEMP% kopyası : Valid

Yani imzalı bir ikili Temp'e taşınsa da doğrulanıyor; imzasız solucan yükü
doğrulanamadığı için hâlâ raporlanıyor.

## Düzeltme sonrası tarama (pcscan2.ps1)

    bulgu: 0

cpuz159 servisi bu taramada hiç yoktu — CPU-Z sürücüyü yalnız çalışırken
kaydediyor. Durum satırındaki "3 Kalıntı" ile taramadaki "1" farkının sebebi de
bu: sayım, o an açık olan programa göre değişiyor.
