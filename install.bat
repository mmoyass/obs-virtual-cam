@echo off
setlocal EnableDelayedExpansion
title OBS Virtual Cam (60 FPS - 4 Cameras) Installer

:: Auto-elevate to Administrator if needed
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo ========================================================
echo   OBS Virtual Cam (60 FPS - 4 Virtual Cameras) Installer
echo ========================================================
echo.

:: Check if OBS is currently running
tasklist /FI "IMAGENAME eq obs64.exe" 2>NUL | find /I /N "obs64.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [WARNING] OBS Studio is currently running!
    echo Please close OBS Studio first, then press any key to continue...
    pause >nul
)

:: Auto-detect OBS Studio installation directory
set "OBS_DIR="
for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\WOW6432Node\OBS Studio" /ve 2^>nul ^| find /i "REG_SZ"') do set "OBS_DIR=%%B"
if not defined OBS_DIR (
    for /f "tokens=2*" %%A in ('reg query "HKLM\SOFTWARE\OBS Studio" /ve 2^>nul ^| find /i "REG_SZ"') do set "OBS_DIR=%%B"
)
if not defined OBS_DIR (
    if exist "C:\Program Files\obs-studio\bin\64bit\obs64.exe" set "OBS_DIR=C:\Program Files\obs-studio"
)

if not defined OBS_DIR (
    echo Could not auto-detect OBS Studio installation folder.
    set /p "OBS_DIR=Enter your OBS Studio folder path (e.g. C:\Program Files\obs-studio): "
)

:: Remove any trailing backslash or quotes
set "OBS_DIR=%OBS_DIR:"=%"
if "%OBS_DIR:~-1%"=="\" set "OBS_DIR=%OBS_DIR:~0,-1%"

if not exist "%OBS_DIR%\bin\64bit" (
    echo [ERROR] OBS Studio folder not valid: "%OBS_DIR%"
    echo Make sure you point to the main obs-studio folder.
    pause
    exit /b 1
)

echo Installing to: "%OBS_DIR%"
echo.

:: Unregister any existing virtual cameras first
if exist "%OBS_DIR%\bin\64bit\obs-virtualsource.dll" (
    "%SystemRoot%\System32\regsvr32.exe" /s /u "%OBS_DIR%\bin\64bit\obs-virtualsource.dll"
)
if exist "%OBS_DIR%\bin\32bit\obs-virtualsource.dll" (
    "%SystemRoot%\SysWOW64\regsvr32.exe" /s /u "%OBS_DIR%\bin\32bit\obs-virtualsource.dll"
)

:: Copy plugin files
echo Copying plugin files...
if exist "%~dp0bin" (
    xcopy /E /Y /I "%~dp0bin" "%OBS_DIR%\bin" >nul
) else (
    echo [ERROR] Missing "bin" folder next to install.bat!
    pause
    exit /b 1
)

if exist "%~dp0obs-plugins" (
    xcopy /E /Y /I "%~dp0obs-plugins" "%OBS_DIR%\obs-plugins" >nul
) else (
    echo [ERROR] Missing "obs-plugins" folder next to install.bat!
    pause
    exit /b 1
)

if exist "%~dp0data" (
    xcopy /E /Y /I "%~dp0data" "%OBS_DIR%\data" >nul
)

:: Register 4 Virtual Cameras (64-bit and 32-bit)
echo Registering 4 Virtual Cameras (64-bit)...
"%SystemRoot%\System32\regsvr32.exe" /s /n /i:4 "%OBS_DIR%\bin\64bit\obs-virtualsource.dll"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to register 64-bit obs-virtualsource.dll!
    pause
    exit /b 1
)

if exist "%OBS_DIR%\bin\32bit\obs-virtualsource.dll" (
    echo Registering 4 Virtual Cameras (32-bit)...
    "%SystemRoot%\SysWOW64\regsvr32.exe" /s /n /i:4 "%OBS_DIR%\bin\32bit\obs-virtualsource.dll"
    if %errorLevel% neq 0 (
        echo [WARNING] Failed to register 32-bit obs-virtualsource.dll. 64-bit cameras will still work.
    )
)

echo.
echo ========================================================
echo   Installation Complete!
echo   Registered 4 Virtual Cameras (60 FPS supported):
echo     - OBS-Camera
echo     - OBS-Camera2
echo     - OBS-Camera3
echo     - OBS-Camera4
echo.
echo   In OBS Studio:
echo     1. Set Settings -^> Video -^> Common FPS Values to 60
echo     2. Use Tools -^> VirtualCam or the "VirtualCam" Filter
echo ========================================================
echo.
pause
exit /b 0
