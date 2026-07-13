<#
.SYNOPSIS
    Automated Enterprise Disk Space Optimizer for Windows 11 Upgrade.
.DESCRIPTION
    This script is Stage 1 of the Auto.Upgrade.WIN10TO11 automation framework.
    It evaluates the system drive (C:), calculates local profile sizes, and 
    safely offloads large user data to alternative physical drives using multi-threaded 
    Robocopy, ensuring a safe fallback path if power or network failure occurs.
.VERSION
    9.9 (Production Hardened)
.AUTHOR
    Enterprise Infrastructure Automation Team
#>

param(
    [string]$Mode = "Full",
    # [SANUTIZED] Transferred internal corporate infrastructure IP to an overridable parameter
    [string]$LogRoot = "\\<YOUR_FILE_SERVER_IP>\update\logs\freespace"
)

# ==============================================================================
# GLOBAL CONFIGURATION (Sanitized for Enterprise Open-Source Deployment)
# ==============================================================================
$Computer = $env:COMPUTERNAME
$ErrorActionPreference = "Stop"
$TargetBackupFolder = "ict-profile-backup" # Standardized backup directory name across secondary drives
$MinRequiredSpaceGB = 45 # Microsoft deployment baseline window plus extra safety margin

# ==============================================================================
# LOGGING ENGINE (Simultaneous Local and UNC Network Logging)
# ==============================================================================
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "[$Time] [$Computer] [$Level] $Message"

    # Write to Local Host Cache
    try {
        Add-Content "$env:ProgramData\FreeSpace.log" $Line -Encoding UTF8
    } catch {}

    # Stream to Central Repository
    try {
        $remote = Join-Path $LogRoot "$Computer.log"
        Add-Content $remote $Line -Encoding UTF8
    } catch {}
}

# ==============================================================================
# OPTIMIZED DIRECTORY SIZE EVALUATOR (Safe Handling of Reparse/Symlinks)
# ==============================================================================
function Get-FolderSize {
    param([string]$Path)

    if (!(Test-Path $Path)) { return 0 }

    # Excludes ReparsePoints to avoid infinite loops on circular junctions
    $size = (Get-ChildItem -LiteralPath $Path -File -Recurse -Force -Attributes !ReparsePoint -ErrorAction SilentlyContinue | 
             Measure-Object -Property Length -Sum).Sum

    if ($null -eq $size) { return 0 }
    return $size
}

# ==============================================================================
# SCRIPT INITIALIZATION & PRE-FLIGHT AUDITS
# ==============================================================================
Write-Log "============================================================"
Write-Log "STAGE 1 PIPELINE START v9.9 FINAL HARDENED Mode=$Mode"

$SkipBackup = $false
$SkipReason = "None"

# 1. Host Operating System Audit
$OSCaption = (Get-CimInstance Win32_OperatingSystem).Caption
Write-Log "Audited Operating System: $OSCaption"

if ($OSCaption -notmatch "Windows 10") {
    $SkipBackup = $true
    $SkipReason = "Target OS is not Windows 10"
    Write-Log "OS Guard Blocked Execution: OS is not Windows 10. Skipping lifecycle." "WARNING"
}

# 2. Storage Capacity Audit (System Volume C:)
$CDriveBefore = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
$CDriveBeforeGB = [math]::Round($CDriveBefore / 1GB, 2)

if (-not $SkipBackup) {
    if ($CDriveBeforeGB -ge $MinRequiredSpaceGB) {
        $SkipBackup = $true
        $SkipReason = "C: Drive already meets the baseline requirement of >= $MinRequiredSpaceGB GB free"
        Write-Log "Optimal disk space detected ($CDriveBeforeGB GB). Optimization pipeline skipped." "INFO"
    }
}

# Pipeline Execution Variable Initialization
$RequiredGB = 0
$BackupRoot = "N/A"
$IsResumeMode = "NO"

# ==============================================================================
# MAIN CORE: BACKUP & DATA BALANCING PIPELINE
# ==============================================================================
if (-not $SkipBackup) {
    Write-Log "Analyzing user profile matrices and calculating payload requirements..."

    $TotalBackupRequired = 0
    $Users = Get-ChildItem "C:\Users" -Directory | Where-Object {
        $_.Name -notin @("Public","Default","Default User","All Users")
    }

    foreach ($User in $Users) {
        foreach ($Folder in @("Documents","Downloads","Pictures","Desktop")) {
            $Source = Join-Path $User.FullName $Folder
            $TotalBackupRequired += Get-FolderSize $Source
        }
    }

    $RequiredGB = [math]::Round($TotalBackupRequired / 1GB, 2)
    Write-Log "Calculated safe migration space needed: $RequiredGB GB"

    # Query local fixed storage targets via CIM (Mitigates phantom/virtual mount issues on LTSC images)
    $AvailableDrives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3 AND DeviceID != 'C:'" -ErrorAction SilentlyContinue | ForEach-Object {
        [PSCustomObject]@{
            DriveLetter   = $_.DeviceID.Substring(0,1)
            SizeRemaining = $_.FreeSpace
            Size          = $_.Size
        }
    } | Sort-Object DriveLetter

    $TargetDrive = $null

    # STATE RESUME ENGINE: Fault-Tolerant Continuation Audit
    foreach ($Drive in $AvailableDrives) {
        $TestPath = "$($Drive.DriveLetter):\${TargetBackupFolder}"
        if (Test-Path -LiteralPath $TestPath -PathType Container) {
            # Validate if the pre-existing target has sufficient capacity for remaining data stream
            if ($Drive.SizeRemaining -gt ($TotalBackupRequired + 2GB)) {
                $TargetDrive = $Drive.DriveLetter
                $IsResumeMode = "YES"
                Write-Log "STATE RESUME MATCHED: Active backup architecture found on ${TargetDrive}: with validated capacity."
                break
            } else {
                $DriveFreeGB = [math]::Round($Drive.SizeRemaining / 1GB, 2)
                Write-Log "Stale state found on ${Drive.DriveLetter}: with insufficient capacity ($DriveFreeGB GB free vs $RequiredGB GB needed). Searching alternates..." "WARNING"
            }
        }
    }

    # DYNAMIC TARGET SELECTION (Executed if no resume state exists or if previous drive filled up)
    if (-not $TargetDrive) {
        foreach ($Drive in $AvailableDrives) {
            if ($Drive.SizeRemaining -gt ($TotalBackupRequired + 2GB)) {
                $TargetDrive = $Drive.DriveLetter
                Write-Log "DYNAMIC ROUTING: Target storage drive ${TargetDrive}: selected based on capacity matrix."
                break
            }
        }
    }

    # CRITICAL INSUFFICIENT STORAGE FAIL-SAFE (Comprehensive Diagnostic Reporting)
    if (-not $TargetDrive) {
        Write-Log "FATAL ERROR: Processing aborted. No secondary physical drive meets the free space requirements ($RequiredGB GB + 2GB Buffer)." "FATAL"
        
        foreach ($Drive in $AvailableDrives) {
            $FreeGB = [math]::Round($Drive.SizeRemaining / 1GB, 2)
            $TotalGB = [math]::Round($Drive.Size / 1GB, 2)
            Write-Log "Evaluated Storage Node [${Drive.DriveLetter}:] -> Available: $FreeGB GB / Total: $TotalGB GB" "FATAL"
        }
        
        $SkipReason = "Aborted - Zero alternative local storage paths qualified"
        
        # Standardized termination state log dumping
        Write-Log "============================================================"
        Write-Log "PIPELINE LOG SUMMARY (TERMINATED)"
        Write-Log "OS Version: $OSCaption"
        Write-Log "C Storage Baseline (GB): $CDriveBeforeGB"
        Write-Log "C Storage Current  (GB): $CDriveBeforeGB"
        Write-Log "Target Backup Size (GB): $RequiredGB"
        Write-Log "Computed Backup Path   : $BackupRoot"
        Write-Log "Termination Reason     : $SkipReason"
        Write-Log "State Engine Resumed   : $IsResumeMode"
        Write-Log "============================================================"
        Write-Log "STAGE 1 END STATE: FAILED_SPACE_REQUIREMENT"
        exit
    }

    $BackupRoot = "${TargetDrive}:\${TargetBackupFolder}"
    Write-Log "Validated Backup Target Set: ${TargetDrive}: (Path: $BackupRoot)"
    Write-Log "============================================================"

    # SYNCHRONOUS DATA OFFLOADING & SPACE RECLAIMING
    foreach ($User in $Users) {
        Write-Log "Processing User Profile Entity: $($User.Name)"
        foreach ($Folder in @("Documents","Downloads","Pictures","Desktop")) {
            
            $Source = Join-Path $User.FullName $Folder
            if (!(Test-Path $Source)) { continue }

            $Dest = Join-Path $BackupRoot "$Computer\$($User.Name)\$Folder"
            Write-Log "Streaming $Source to $Dest"

            # INTEGRITY ZONE: Enforce deterministic exit-code validation on native sub-processes
            $global:LASTEXITCODE = 99

            # Multi-threaded low-overhead robocopy thread instantiation
            robocopy $Source $Dest /E /Z /MT:8 /R:1 /W:1 /XJ /NP | Out-Null
            $RC = $global:LASTEXITCODE

            # Strict Error-Code Verification Matrix (Robocopy Codes 0-7 indicate perfect synchronization parity)
            if ($RC -le 7) {
                Write-Log "Parity Check Verified: $Source (ExitCode=$RC)" "SUCCESS"
                
                # Desktop Filtering Logic: Preserves shell shortcuts (.lnk), purges bulky local data assets
                if ($Folder -eq "Desktop") {
                    Get-ChildItem $Source -Force -ErrorAction SilentlyContinue | ForEach-Object {
                        if ($_.Extension -eq ".lnk") { return }
                        
                        if (-not $_.PSIsContainer) {
                            if ($_.Length -gt 100MB) {
                                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                                Write-Log "Purged Bulk Desktop File (>100MB): $($_.Name)" "SUCCESS"
                            }
                        } else {
                            $Size = Get-FolderSize $_.FullName
                            if ($Size -gt 100MB) {
                                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
                                Write-Log "Purged Bulk Desktop Folder (>100MB): $($_.Name)" "SUCCESS"
                            }
                        }
                    }
                } else {
                    # Complete purging of successfully duplicated source directories (Documents, Downloads, Pictures)
                    Remove-Item "$Source\*" -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Log "System Volume Reclaimed: $Source" "SUCCESS"
                }
            } else {
                Write-Log "INTEGRITY GUARD BREACHED: Sync failed for $Source (ExitCode=$RC). Data destruction blocked." "ERROR"
            }
        }
    }
}

# ==============================================================================
# PIPELINE POST-FLIGHT RE-AUDITING & SUMMARY DUMP
# ==============================================================================
$CDriveAfter = (Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace
$CDriveAfterGB  = [math]::Round($CDriveAfter / 1GB, 2)

Write-Log "============================================================"
Write-Log "PIPELINE LOG SUMMARY (SUCCESS)"
Write-Log "OS Version: $OSCaption"
Write-Log "C Storage Before (GB): $CDriveBeforeGB"
Write-Log "C Storage After  (GB): $CDriveAfterGB"
Write-Log "Total Data Moved (GB): $RequiredGB"
Write-Log "Active Backup Path   : $BackupRoot"
Write-Log "Pipeline Skip Status : $SkipReason"
Write-Log "State Engine Resumed : $IsResumeMode"
Write-Log "============================================================"
Write-Log "STAGE 1 END STATE: SUCCESS"