@ECHO OFF
SETLOCAL EnableExtensions
CLS
REM Ensure %ProgramFiles% points at 64-bit Program Files even if invoked from 32-bit cmd.exe
IF DEFINED ProgramW6432 SET "ProgramFiles=%ProgramW6432%"
SET "PERCENT=%%"
SET "EXPECTED_RUN_VALUE=%PERCENT%ProgramFiles%PERCENT%\SystemBanner\SystemBanner.exe"
REM ============================================================
REM SystemBanner Installer
REM ============================================================
SET "INSTALL_STATUS=SUCCESS"
SET "DIR_STATUS=FAIL"
SET "APP_STATUS=FAIL"
SET "ADMX_STATUS=FAIL"
SET "ADML_STATUS=FAIL"
SET "DPI_STATUS=FAIL"
SET "RUN_STATUS=FAIL"
SET "START_STATUS=FAIL"
REM ============================================================
REM Verify administrator privileges
REM ============================================================
NET SESSION >NUL 2>&1
IF ERRORLEVEL 1 (
    ECHO.
    ECHO You must right-click and select "RUN AS ADMINISTRATOR" to run this installer.
    ECHO.
    ECHO This window will close in 15 seconds...
    TIMEOUT /T 15 /NOBREAK >NUL
    EXIT /B 1
)
REM ============================================================
REM Stop SystemBanner if currently running
REM ============================================================
TASKLIST /FI "IMAGENAME eq SYSTEMBANNER.EXE" 2>NUL | FIND /I "SYSTEMBANNER.EXE" >NUL
IF NOT ERRORLEVEL 1 (
    TASKKILL /F /IM SYSTEMBANNER.EXE >NUL 2>&1
)
REM ============================================================
REM Installation directory
REM ============================================================
IF NOT EXIST "%ProgramFiles%\SystemBanner" (
    ECHO Creating directory "%ProgramFiles%\SystemBanner"...
    MKDIR "%ProgramFiles%\SystemBanner"
)
IF EXIST "%ProgramFiles%\SystemBanner" (
    SET "DIR_STATUS=SUCCESS"
) ELSE (
    SET "INSTALL_STATUS=FAILED"
)
REM ============================================================
REM File system operations
REM ============================================================
ECHO.
ECHO File system operations
ECHO ----------------------
REM ------------------------------------------------------------
REM SystemBanner application files
REM ------------------------------------------------------------
ECHO Copying SystemBanner files...
COPY /Y "%~dp0Code\SystemBanner\SystemBanner\bin\Release\SystemBanner*" "%ProgramFiles%\SystemBanner\" >NUL
IF ERRORLEVEL 1 (
    SET "INSTALL_STATUS=FAILED"
) ELSE (
    REM Verify the primary application files exist
    IF EXIST "%ProgramFiles%\SystemBanner\SystemBanner.exe" (
        IF EXIST "%ProgramFiles%\SystemBanner\SystemBanner.exe.config" (
            IF EXIST "%ProgramFiles%\SystemBanner\SystemBanner.exe.manifest" (
                SET "APP_STATUS=SUCCESS"
            ) ELSE (
                SET "INSTALL_STATUS=FAILED"
            )
        ) ELSE (
            SET "INSTALL_STATUS=FAILED"
        )
    ) ELSE (
        SET "INSTALL_STATUS=FAILED"
    )
)
REM ------------------------------------------------------------
REM SystemBanner ADMX
REM ------------------------------------------------------------
ECHO Copying SystemBanner.admx...
COPY /Y "%~dp0Group Policy\SystemBanner.admx" "%WINDIR%\PolicyDefinitions\" >NUL
IF ERRORLEVEL 1 (
    SET "INSTALL_STATUS=FAILED"
) ELSE (
    IF EXIST "%WINDIR%\PolicyDefinitions\SystemBanner.admx" (
        SET "ADMX_STATUS=SUCCESS"
    ) ELSE (
        SET "INSTALL_STATUS=FAILED"
    )
)
REM ------------------------------------------------------------
REM SystemBanner ADML
REM ------------------------------------------------------------
ECHO Copying SystemBanner.adml...
COPY /Y "%~dp0Group Policy\en-US\SystemBanner.adml" "%WINDIR%\PolicyDefinitions\en-US\" >NUL
IF ERRORLEVEL 1 (
    SET "INSTALL_STATUS=FAILED"
) ELSE (
    IF EXIST "%WINDIR%\PolicyDefinitions\en-US\SystemBanner.adml" (
        SET "ADML_STATUS=SUCCESS"
    ) ELSE (
        SET "INSTALL_STATUS=FAILED"
    )
)
REM ============================================================
REM Registry operations
REM ============================================================
ECHO.
ECHO Registry operations
ECHO -------------------
REM ------------------------------------------------------------
REM DPI awareness
REM ------------------------------------------------------------
ECHO Adding SystemBanner DPI awareness...
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /V "%ProgramFiles%\SystemBanner\SystemBanner.exe" /T REG_SZ /D "~ HIGHDPIAWARE" /F >NUL
IF ERRORLEVEL 1 (
    SET "INSTALL_STATUS=FAILED"
) ELSE (
    REM Verify the registry value exists
    REG QUERY "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /V "%ProgramFiles%\SystemBanner\SystemBanner.exe" >NUL 2>&1
    IF NOT ERRORLEVEL 1 (
        SET "DPI_STATUS=SUCCESS"
    ) ELSE (
        SET "INSTALL_STATUS=FAILED"
    )
)
REM ------------------------------------------------------------
REM Startup
REM ------------------------------------------------------------
ECHO Adding SystemBanner startup entry...
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "SystemBanner" /T REG_EXPAND_SZ /D "%EXPECTED_RUN_VALUE%" /F
IF ERRORLEVEL 1 (
    SET "RUN_STATUS=FAILED"
    SET "INSTALL_STATUS=FAILED"
) ELSE (
    REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "SystemBanner" 2>NUL | FIND /I "REG_EXPAND_SZ" | FIND /I "%EXPECTED_RUN_VALUE%" >NUL
    IF NOT ERRORLEVEL 1 (
        SET "RUN_STATUS=SUCCESS"
    ) ELSE (
        SET "RUN_STATUS=FAILED"
        SET "INSTALL_STATUS=FAILED"
    )
)
REM ============================================================
REM Start SystemBanner
REM ============================================================
ECHO.
ECHO Starting SystemBanner...
START "" "%ProgramFiles%\SystemBanner\SystemBanner.exe"
IF ERRORLEVEL 1 (
    SET "INSTALL_STATUS=FAILED"
) ELSE (
    REM Give the application time to initialize
    TIMEOUT /T 2 /NOBREAK >NUL
    REM Verify that the process actually started
    TASKLIST /FI "IMAGENAME eq SYSTEMBANNER.EXE" 2>NUL | FIND /I "SYSTEMBANNER.EXE" >NUL
    IF NOT ERRORLEVEL 1 (
        SET "START_STATUS=SUCCESS"
    ) ELSE (
        SET "INSTALL_STATUS=FAILED"
    )
)
REM ============================================================
REM Installation summary
REM ============================================================
ECHO.
ECHO ============================================================
ECHO SystemBanner Installation Summary
ECHO ============================================================
ECHO.
ECHO Installation directory:       %DIR_STATUS%
ECHO SystemBanner files:            %APP_STATUS%
ECHO SystemBanner.admx:             %ADMX_STATUS%
ECHO SystemBanner.adml:             %ADML_STATUS%
ECHO DPI registry entry:            %DPI_STATUS%
ECHO Startup registry entry:        %RUN_STATUS%
ECHO Application startup:           %START_STATUS%
ECHO.
IF "%INSTALL_STATUS%"=="SUCCESS" (
    ECHO Installation completed successfully.
) ELSE (
    ECHO Installation completed with errors.
    ECHO Review the results above.
)
ECHO.
PAUSE