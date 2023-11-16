@ECHO ON & CLS & ECHO.
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (ECHO You must right-click and select "RUN AS ADMINISTRATOR"  to run this installer)
PAUSE
TASKKILL /F /IM SYSTEMBANNER.EXE
MKDIR "C:\Program Files\SystemBanner"
COPY  %~dp0\Code\SystemBanner\SystemBanner\bin\Release\SystemBanner* "C:\Program Files\SystemBanner\"
COPY "%~dp0\Group Policy\SystemBanner.admx" "C:\Windows\PolicyDefinitions\"
COPY "%~dp0\Group Policy\en-US\SystemBanner.adml" "C:\Windows\PolicyDefinitions\en-US\"
SCHTASKS /CREATE /XML %~dp0\Tasks\SystemBanner.XML /TN "SystemBanner" 
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /V "%programfiles%\SystemBanner\SystemBanner.exe" /T REG_SZ /D ~HIGHDPIAWARE /F
SCHTASKS /RUN /TN "SystemBanner" 
PAUSE