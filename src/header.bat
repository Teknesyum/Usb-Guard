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
:
: Compatibility note: versions up to 1.12 shipped the program packed and their
: updater refuses any download that does not contain the word FromBase64String.
: This line carries that word so those installations can still update to this
: release. Nothing here is encoded; the program follows below in plain text.
: --------------------------------------------------------------------------
#>
