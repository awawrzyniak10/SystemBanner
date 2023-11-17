@ECHO ON & CLS & ECHO.
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (ECHO You must right-click and select "RUN AS ADMINISTRATOR"  to run this installer)
PAUSE
TASKKILL /F /IM SYSTEMBANNER.EXE
MKDIR "C:\Program Files\SystemBanner"
COPY  %~dp0\Code\SystemBanner\SystemBanner\bin\Release\SystemBanner* "C:\Program Files\SystemBanner\"
COPY "%~dp0\Group Policy\SystemBanner.admx" "C:\Windows\PolicyDefinitions\"
COPY "%~dp0\Group Policy\en-US\SystemBanner.adml" "C:\Windows\PolicyDefinitions\en-US\"
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /V "C:\Program Files\SystemBanner\SystemBanner.exe" /T REG_SZ /D "~ HIGHDPIAWARE" /F
RED ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "SystemBanner" /T REG_SZ /D "C:\Program Files\SystemBanner\SystemBanner.exe" /F
"C:\Program Files\SystemBanner\SystemBanner.exe"
PAUSE