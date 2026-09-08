<# :
@echo off
chcp 65001 >nul
setlocal EnableExtensions
set "SELFBAT=%~f0"
set "GARGS=%*"
net session >nul 2>&1
if %errorlevel% NEQ 0 (
  if defined GARGS (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList '%GARGS%'"
  ) else (
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
  )
  exit /b
)
powershell -NoProfile -Command "& ([scriptblock]::Create([IO.File]::ReadAllText('%~f0'))) %*"
endlocal
exit /b

: --------------------------------------------------------------------------
: The lines above are the Windows batch launcher. Everything below is the
: complete PowerShell source of USB-Guard, in plain readable text. Open this
: file in Notepad and read it: nothing is hidden, compressed or encoded, and
: nothing is written to a temporary folder before it runs.
:
: Source and releases: https://github.com/Teknesyum/Usb-Guard
: --------------------------------------------------------------------------
#>
