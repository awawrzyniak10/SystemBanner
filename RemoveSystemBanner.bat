@ECHO OFF
SETLOCAL EnableExtensions
REM Ensure %ProgramFiles% points at 64-bit Program Files even if invoked from 32-bit cmd.exe
IF DEFINED ProgramW6432 SET "ProgramFiles=%ProgramW6432%"
REM (unused variables removed)
CLS
REM ============================================================
REM SystemBanner Uninstaller
REM ============================================================
SET "REMOVE_STATUS=SUCCESS"
SET "PROCESS_STATUS=NOT RUNNING"
SET "APP_STATUS=FAIL"
SET "ADMX_STATUS=FAIL"
SET "ADML_STATUS=FAIL"
SET "DPI_STATUS=FAIL"
SET "RUN_STATUS=FAIL"
REM ============================================================
REM Verify administrator privileges
REM ============================================================
NET SESSION >NUL 2>&1
IF ERRORLEVEL 1 (
    ECHO.
    ECHO You must right-click and select "RUN AS ADMINISTRATOR" to run this uninstaller.
    ECHO.
    ECHO This window will close in 15 seconds...
    TIMEOUT /T 15 /NOBREAK >NUL
    EXIT /B 1
)
REM ============================================================
REM Confirm removal
REM ============================================================
ECHO.
ECHO Press any key to remove SystemBanner, use CTRL+C to cancel.
PAUSE >NUL
REM ============================================================
REM Stop SystemBanner
REM ============================================================
ECHO.
ECHO Stopping SystemBanner...
TASKLIST /FI "IMAGENAME eq SYSTEMBANNER.EXE" 2>NUL | FIND /I "SYSTEMBANNER.EXE" >NUL
IF NOT ERRORLEVEL 1 (
    TASKKILL /F /IM SYSTEMBANNER.EXE >NUL 2>&1
    TIMEOUT /T 1 /NOBREAK >NUL
    TASKLIST /FI "IMAGENAME eq SYSTEMBANNER.EXE" 2>NUL | FIND /I "SYSTEMBANNER.EXE" >NUL
    IF ERRORLEVEL 1 (
        SET "PROCESS_STATUS=STOPPED"
    ) ELSE (
        SET "PROCESS_STATUS=FAILED"
        SET "REMOVE_STATUS=FAILED"
    )
) ELSE (
    SET "PROCESS_STATUS=NOT RUNNING"
)
REM ============================================================
REM File system operations
REM ============================================================
ECHO.
ECHO File system operations
ECHO ----------------------
REM ------------------------------------------------------------
REM SystemBanner application
REM ------------------------------------------------------------
ECHO Removing SystemBanner application files...
IF EXIST "%ProgramFiles%\SystemBanner" (
    RMDIR /S /Q "%ProgramFiles%\SystemBanner"
    IF EXIST "%ProgramFiles%\SystemBanner" (
        SET "APP_STATUS=FAILED"
        SET "REMOVE_STATUS=FAILED"
    ) ELSE (
        SET "APP_STATUS=SUCCESS"
    )
) ELSE (
    SET "APP_STATUS=NOT INSTALLED"
)
REM ------------------------------------------------------------
REM SystemBanner ADMX
REM ------------------------------------------------------------
ECHO Removing SystemBanner.admx...
IF EXIST "%WINDIR%\PolicyDefinitions\SystemBanner.admx" (
    DEL /F /Q "%WINDIR%\PolicyDefinitions\SystemBanner.admx"
    IF EXIST "%WINDIR%\PolicyDefinitions\SystemBanner.admx" (
        SET "ADMX_STATUS=FAILED"
        SET "REMOVE_STATUS=FAILED"
    ) ELSE (
        SET "ADMX_STATUS=SUCCESS"
    )
) ELSE (
    SET "ADMX_STATUS=NOT INSTALLED"
)
REM ------------------------------------------------------------
REM SystemBanner ADML
REM ------------------------------------------------------------
ECHO Removing SystemBanner.adml...
IF EXIST "%WINDIR%\PolicyDefinitions\en-US\SystemBanner.adml" (
    DEL /F /Q "%WINDIR%\PolicyDefinitions\en-US\SystemBanner.adml"
    IF EXIST "%WINDIR%\PolicyDefinitions\en-US\SystemBanner.adml" (
        SET "ADML_STATUS=FAILED"
        SET "REMOVE_STATUS=FAILED"
    ) ELSE (
        SET "ADML_STATUS=SUCCESS"
    )
) ELSE (
    SET "ADML_STATUS=NOT INSTALLED"
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
ECHO Removing SystemBanner DPI awareness registry entry...
REG QUERY "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /V "%ProgramFiles%\SystemBanner\SystemBanner.exe" >NUL 2>&1
IF NOT ERRORLEVEL 1 (
    REG DELETE "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /V "%ProgramFiles%\SystemBanner\SystemBanner.exe" /F >NUL
    REG QUERY "HKLM\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /V "%ProgramFiles%\SystemBanner\SystemBanner.exe" >NUL 2>&1
    IF ERRORLEVEL 1 (
        SET "DPI_STATUS=SUCCESS"
    ) ELSE (
        SET "DPI_STATUS=FAILED"
        SET "REMOVE_STATUS=FAILED"
    )
) ELSE (
    SET "DPI_STATUS=NOT INSTALLED"
)
REM ------------------------------------------------------------
REM Startup
REM ------------------------------------------------------------
ECHO Removing SystemBanner startup registry entry...
REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "SystemBanner" >NUL 2>&1
IF NOT ERRORLEVEL 1 (
    REG DELETE "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "SystemBanner" /F >NUL
    REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /V "SystemBanner" >NUL 2>&1
    IF ERRORLEVEL 1 (
        SET "RUN_STATUS=SUCCESS"
    ) ELSE (
        SET "RUN_STATUS=FAILED"
        SET "REMOVE_STATUS=FAILED"
    )
) ELSE (
    SET "RUN_STATUS=NOT INSTALLED"
)
 REM ------------------------------------------------------------
 REM Policy configuration
 REM ------------------------------------------------------------
 ECHO Removing SystemBanner policy registry key...
 REG QUERY "HKLM\Software\Policies\SystemBanner" >NUL 2>&1
 IF NOT ERRORLEVEL 1 (
     REG DELETE "HKLM\Software\Policies\SystemBanner" /F >NUL
     REG QUERY "HKLM\Software\Policies\SystemBanner" >NUL 2>&1
     IF NOT ERRORLEVEL 1 SET "REMOVE_STATUS=FAILED"
 )
REM ============================================================
REM Removal summary
REM ============================================================
ECHO.
ECHO ============================================================
ECHO SystemBanner Removal Summary
ECHO ============================================================
ECHO.
ECHO SystemBanner process:         %PROCESS_STATUS%
ECHO SystemBanner application:     %APP_STATUS%
ECHO SystemBanner.admx:            %ADMX_STATUS%
ECHO SystemBanner.adml:            %ADML_STATUS%
ECHO DPI registry entry:           %DPI_STATUS%
ECHO Startup registry entry:       %RUN_STATUS%
ECHO.
IF "%REMOVE_STATUS%"=="SUCCESS" (
    ECHO SystemBanner removal completed successfully.
) ELSE (
    ECHO SystemBanner removal completed with errors.
    ECHO Review the results above.
)
ECHO.
PAUSE