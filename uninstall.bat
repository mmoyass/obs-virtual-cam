@echo off
setlocal EnableDelayedExpansion
title OBS Virtual Cam Uninstaller

:: Auto-elevate to Administrator if needed
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo ========================================================
echo   OBS Virtual Cam Uninstaller
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

if not exist "%OBS_DIR%" (
    echo [ERROR] OBS Studio folder not found: "%OBS_DIR%"
    pause
    exit /b 1
)

echo Uninstalling from: "%OBS_DIR%"
echo.

:: Unregister DirectShow virtual cameras
if exist "%OBS_DIR%\bin\64bit\obs-virtualsource.dll" (
    echo Unregistering 64-bit Virtual Cameras...
    "%SystemRoot%\System32\regsvr32.exe" /s /u "%OBS_DIR%\bin\64bit\obs-virtualsource.dll"
)

if exist "%OBS_DIR%\bin\32bit\obs-virtualsource.dll" (
    echo Unregistering 32-bit Virtual Cameras...
    "%SystemRoot%\SysWOW64\regsvr32.exe" /s /u "%OBS_DIR%\bin\32bit\obs-virtualsource.dll"
)

:: Remove plugin files
echo Removing plugin files...
if exist "%OBS_DIR%\obs-plugins\64bit\obs-virtualcam.dll" del /F /Q "%OBS_DIR%\obs-plugins\64bit\obs-virtualcam.dll"
if exist "%OBS_DIR%\obs-plugins\64bit\obs-virtualcam.pdb" del /F /Q "%OBS_DIR%\obs-plugins\64bit\obs-virtualcam.pdb"
if exist "%OBS_DIR%\bin\64bit\obs-virtualsource.dll" del /F /Q "%OBS_DIR%\bin\64bit\obs-virtualsource.dll"
if exist "%OBS_DIR%\bin\64bit\obs-virtualsource.pdb" del /F /Q "%OBS_DIR%\bin\64bit\obs-virtualsource.pdb"
if exist "%OBS_DIR%\bin\32bit\obs-virtualsource.dll" del /F /Q "%OBS_DIR%\bin\32bit\obs-virtualsource.dll"
if exist "%OBS_DIR%\bin\32bit\obs-virtualsource.pdb" del /F /Q "%OBS_DIR%\bin\32bit\obs-virtualsource.pdb"
if exist "%OBS_DIR%\data\obs-plugins\obs-virtualcam" rmdir /S /Q "%OBS_DIR%\data\obs-plugins\obs-virtualcam"

echo.
echo ========================================================
echo   Uninstallation Complete!
echo   All OBS-Camera virtual devices have been removed.
echo ========================================================
echo.
pause
exit /b 0
