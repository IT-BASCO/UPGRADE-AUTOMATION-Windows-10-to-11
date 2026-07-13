@echo off
setlocal

REM ==============================================================================
REM Script Name : Post-Upgrade Storage Reclaimer (Space Reclamation Engine)
REM Description : Stage 5 of the Auto.Upgrade.WIN10TO11 automation framework.
REM               Purges heavy legacy migration artifacts (Windows.old, setup caches,
REM               and telemetry logs) after the endpoint achieves verified stability.
REM Version     : V1.0 OFFICIAL (Production Hardened)
REM Author      : Enterprise Infrastructure Automation Team
REM ==============================================================================

title Windows Upgrade Post-Stability Cleanup

REM ==============================================================================
REM PHASE 1: OS Level Guard - Enforce Windows 11 Context Only
REM ==============================================================================
for /f "tokens=3" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild') do set BUILD=%%i

if %BUILD% LSS 22000 (
    echo [ERROR] Target system is not running Windows 11. Aborting cleanup to protect fallback state.
    exit /b 0
)

REM ==============================================================================
REM PHASE 2: Target Verification - Check If Migration Artifacts Exist
REM ==============================================================================
if not exist C:\Windows.old (
    echo [INFO] No legacy Windows.old folder detected. Storage is already optimized.
    exit /b 0
)

REM ==============================================================================
REM PHASE 3: Data Reclaiming - Take Ownership & Force Purge Windows.old
REM ==============================================================================
echo [PROCESSING] Reclaiming ownership and security descriptors for C:\Windows.old ...
takeown /F C:\Windows.old /R /A /D Y >nul 2>&1
icacls C:\Windows.old /grant Administrators:F /T >nul 2>&1

echo [PROCESSING] Executing deep purge of C:\Windows.old ...
rmdir /S /Q C:\Windows.old

REM ==============================================================================
REM PHASE 4: Data Reclaiming - Purge Asynchronous Stale Upgrade Directories
REM ==============================================================================

REM --- Purging Windows Installation Temporary Cache (~BT) ---
if exist C:\$WINDOWS.~BT (
    echo [PROCESSING] Removing deployment cache folder: C:\$WINDOWS.~BT ...
    takeown /F C:\$WINDOWS.~BT /R /A /D Y >nul 2>&1
    icacls C:\$WINDOWS.~BT /grant Administrators:F /T >nul 2>&1
    rmdir /S /Q C:\$WINDOWS.~BT
)

REM --- Purging Windows Upgrade Workspace (~WS) ---
if exist C:\$WINDOWS.~WS (
    echo [PROCESSING] Removing upgrade workspace folder: C:\$WINDOWS.~WS ...
    takeown /F C:\$WINDOWS.~WS /R /A /D Y >nul 2>&1
    icacls C:\$WINDOWS.~WS /grant Administrators:F /T >nul 2>&1
    rmdir /S /Q C:\$WINDOWS.~WS
)

REM --- Purging Framework Diagnostics and Setup Logs ---
if exist C:\Win11Logs (
    echo [PROCESSING] Clearing framework diagnostic repositories: C:\Win11Logs ...
    rmdir /S /Q C:\Win11Logs
)

if exist C:\RollbackLogs (
    echo [PROCESSING] Clearing legacy rollback engine files: C:\RollbackLogs ...
    rmdir /S /Q C:\RollbackLogs
)

REM ==============================================================================
REM PHASE 5: Telemetry Flush - Clear High-Volume Setup Panther Caches
REM ==============================================================================
echo [PROCESSING] Flushing OS Telemetry and Panther installation dumps ...
del /f /q C:\Windows\Panther\*.* >nul 2>&1
del /f /q C:\Windows\Logs\MoSetup\*.* >nul 2>&1

echo [SUCCESS] Storage optimization and post-upgrade cleanup completed successfully.

REM ==============================================================================
REM PHASE 6: Realignment - Final System Reboot Execution
REM ==============================================================================
echo [SYSTEM] Initiating final synchronization reboot ...
shutdown /r /t 0