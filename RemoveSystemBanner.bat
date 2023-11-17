@ECHO OFF & CLS & ECHO.
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (ECHO You must right-click and select "RUN AS ADMINISTRATOR"  to run this installer)
PAUSE
TASKKILL /IM SystemBanner.exe /F
TASKKILL /F /IM explorer.exe
EXPLORER.EXE
DEL "C:\Program Files\SystemBanner\SystemBanner.exe"
RMDIR /S /Q "C:\Program Files\SystemBanner"
DEL "C:\Windows\PolicyDefinitions\SystemBanner.admx"
DEL "C:\Windows\PolicyDefinitions\en-US\SystemBanner.adml"
REG DELETE "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /V "C:\Program Files\SystemBanner\SystemBanner.exe" /F
RED DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "SystemBanner"/F
PAUSE