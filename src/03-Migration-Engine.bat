@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ==============================================================================
REM Script Name : Registry Safe Guard (Enterprise Centralized Backup)
REM Description : Stage 2 of the Auto.Upgrade.WIN10TO11 automation framework.
REM               Executes a resilient, native, locale-independent backup of the 
REM               HKLM core system hive before OS migration.
REM Version     : V1.3 OFFICIAL (Production Hardened)
REM Author      : Enterprise Infrastructure Automation Team
REM ==============================================================================

REM ==============================================================================
REM GLOBAL CONFIGURATION (Sanitized for Enterprise Open-Source Deployment)
REM ==============================================================================
set "SCRIPT_VERSION=V1.3"
set "CENTRAL_UPDATE_SHARE=\\<YOUR_FILE_SERVER_IP>\update"
set "LOCAL_BACKUP_FOLDER=ict-backup-registery"

REM ==============================================================================
REM INITIALIZATION & ENVIRONMENT AUDITING
REM ==============================================================================
for /f %%i in ('hostname') do set "PC=%%i"

REM --- Dynamic Path Allocation ---
set "LOGDIR=%CENTRAL_UPDATE_SHARE%\logs\registery"
set "LOGFILE=%LOGDIR%\%PC%.log"

REM --- Ensure Network Log Directory Exists Safely ---
if not exist "%LOGDIR%" mkdir "%LOGDIR%" >nul 2>&1

REM --- Fetch Active IPv4 Address via Pipeless Ping Method (High-Performance) ---
set "IP="
for /f "tokens=2 delims=[]" %%A in ('ping -4 -n 1 %PC% 2^>nul') do set "IP=%%A"
if not defined IP set "IP=Unknown"

REM ==============================================================================
REM PHASE 1: Locale-Independent Date Extraction & Native OS Auditing
REM ==============================================================================
set "CUR_YEAR="&set "CUR_MONTH="&set "CUR_DAY="&set "CUR_TIME="&set "OS_NAME="&set "OS_BUILD="

REM --- Fetch Date Components using Dash Separators (Bypasses Windows Region/Language Bugs) ---
for /f "tokens=1-4 delims=-" %%A in ('powershell -NoProfile -Command "Get-Date -Format \"yyyy-MM-dd-HHmm\""') do (
    set "CUR_YEAR=%%A"
    set "CUR_MONTH=%%B"
    set "CUR_DAY=%%C"
    set "CUR_TIME=%%D"
)

REM --- Fetch OS Build Number Natively via Registry Query ---
for /f "tokens=1,2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul') do (
    if /I "%%A"=="CurrentBuild" set "OS_BUILD=%%C"
)

REM --- Fetch OS Product Name Natively & Apply Formatting ---
set "RAW_OS_NAME="
for /f "tokens=1,2*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul') do (
    if /I "%%A"=="ProductName" set "RAW_OS_NAME=%%C"
)

REM --- Smart Validation: Override Target Properties if Build >= 22000 (Windows 11) ---
if %OS_BUILD% GEQ 22000 (
    set "OS_NAME=Windows_11_Enterprise"
) else (
    set "OS_NAME=%RAW_OS_NAME:Microsoft =%"
    set "OS_NAME=%OS_NAME: =_%"
)

REM ==============================================================================
REM PHASE 2: Smart Drive Routing Pipeline (Protects C: and Reuses Validated Paths)
REM ==============================================================================
set "TARGET_DRIVE="

REM --- Strategy A: Look for existing optimization target directories ---
for /f "tokens=1 delims=:" %%D in ('powershell -NoProfile -Command "[System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq [System.IO.DriveType]::Fixed -and $_.IsReady -and (Test-Path (Join-Path $_.Name \"%LOCAL_BACKUP_FOLDER%\")) } | Select-Object -First 1 -ExpandProperty Name" 2^>nul') do set "TARGET_DRIVE=%%D"

REM --- Strategy B: Fallback to any alternative non-OS fixed storage volume ---
if not defined TARGET_DRIVE (
    for /f "tokens=1 delims=:" %%D in ('powershell -NoProfile -Command "[System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq [System.IO.DriveType]::Fixed -and $_.IsReady -and $_.Name -notmatch \"C\" } | Select-Object -First 1 -ExpandProperty Name" 2^>nul') do set "TARGET_DRIVE=%%D"
)

REM --- Strategy C: Absolute emergency fallback to primary system volume C: ---
if not defined TARGET_DRIVE (
    set "TARGET_DRIVE=C"
)

REM ==============================================================================
REM PHASE 3: Directory Structure Creation & Core Registry Export
REM ==============================================================================
set "BACKUP_ROOT=%TARGET_DRIVE%:\%LOCAL_BACKUP_FOLDER%"
set "FINAL_DEST=%BACKUP_ROOT%\%CUR_YEAR%\%CUR_MONTH%"
set "FILENAME=%PC%-%OS_NAME%-%OS_BUILD%-%CUR_DAY%-%CUR_TIME%.reg"
set "FULL_PATH=%FINAL_DEST%\%FILENAME%"

if not exist "%FINAL_DEST%" mkdir "%FINAL_DEST%" >nul 2>&1

REM --- Execute Registry Export for HKLM (System Core Hive Safeguard) ---
reg export HKLM "%FULL_PATH%" /y >nul 2>&1

REM ==============================================================================
REM PHASE 4: Universal Deterministic Centralized Logging
REM ==============================================================================
if %errorlevel% equ 0 (
    echo [%CUR_YEAR%/%CUR_MONTH%/%CUR_DAY% %TIME%] [VER: %SCRIPT_VERSION%] [IP: %IP%] [HOST: %PC%] [OS: %OS_NAME%_B:%OS_BUILD%] [PATH: %FULL_PATH%] [STATUS: SUCCESS]>>"%LOGFILE%"
    exit /b 0
) else (
    echo [%CUR_YEAR%/%CUR_MONTH%/%CUR_DAY% %TIME%] [VER: %SCRIPT_VERSION%] [IP: %IP%] [HOST: %PC%] [OS: %OS_NAME%_B:%OS_BUILD%] [PATH: %FULL_PATH%] [STATUS: FAILED_EXPORT_ERROR]>>"%LOGFILE%"
    exit /b 1
)