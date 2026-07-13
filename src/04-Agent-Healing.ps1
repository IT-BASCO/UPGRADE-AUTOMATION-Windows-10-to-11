<#
.SYNOPSIS
    Post-Deployment Enterprise Agent Healing & Silent Deployment Framework.
.DESCRIPTION
    This script is Stage 4 of the Auto.Upgrade.WIN10TO11 automation framework.
    It executes a completely silent background deployment and validation loop 
    for critical endpoint infrastructure agents (UEMS, OpManager, SEP, NetSupport).
.VERSION
    12.8 (Production Hardened - Zero-GUI Edition)
.AUTHOR
    Enterprise Infrastructure Automation Team
#>

param(
    # [SANITIZED] Centralized storage share porting
    [string]$SourceShare = "\\<YOUR_FILE_SERVER_IP>\update\agents",
    [string]$LogRoot = "\\<YOUR_FILE_SERVER_IP>\update\logs\agents"
)

# ==============================================================================
# GLOBAL CONFIGURATION & ZERO-GUI ENVIRONMENT HARDENING
# ==============================================================================
$Computer = $env:COMPUTERNAME
$ErrorActionPreference = "Stop"

# Force absolute silence by bypassing Windows Zone Checks for UNC network paths
$env:SEE_MASK_NOZONECHECKS = 1

# ==============================================================================
# OS SAFEGUARD GATE: ABSOLUTE WINDOWS SERVER BLOCK
# ==============================================================================
$OSProduct = (Get-CimInstance Win32_OperatingSystem).Caption
if ($OSProduct -match "Server") {
    $ServerBlockMsg = "CRITICAL VIOLATION: Installation on Windows Server is strictly prohibited! (نصب بر روی ویندوز سرور اکیدا ممنوع است)"
    
    # Attempt immediate emergency remote logging before termination
    try {
        if (-not (Test-Path $LogRoot)) { New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null }
        "[(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Computer] [FATAL] $ServerBlockMsg" | Add-Content (Join-Path $LogRoot "$Computer.log") -Encoding UTF8
    } catch {}
    
    Write-Error "نصب بر روی ویندوز سرور اکیدا ممنوع است"
    exit 1
}

# ==============================================================================
# LOGGING ENGINE
# ==============================================================================
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "[$Time] [$Computer] [V12.8] [$Level] $Message"

    # Write to local cache
    try { Add-Content "$env:ProgramData\AgentHealing.log" $Line -Encoding UTF8 } catch {}

    # Stream to central infrastructure share
    try {
        if (-not (Test-Path $LogRoot)) { New-Item -ItemType Directory -Path $LogRoot -Force | Out-Null }
        Add-Content (Join-Path $LogRoot "$Computer.log") $Line -Encoding UTF8
    } catch {}
}

Write-Log "============================================================"
Write-Log "STAGE 4 AGENT HEALING PIPELINE INITIALIZED"
Write-Log "Target OS Verified: $OSProduct"

# ==============================================================================
# PHASE 1: SILENT EXECUTION WORKLOADS (UNC Direct Injections)
# ==============================================================================

# 1. ManageEngine UEMS Agent Execution
$UEMSAgentService = "DesktopCentralAgent"
if (-not (Get-Service $UEMSAgentService -ErrorAction SilentlyContinue)) {
    Write-Log "UEMS Agent missing. Triggering quiet background MSI package execution..."
    $UEMSPath = Join-Path $SourceShare "UEMSAgent.msi"
    if (Test-Path $UEMSPath) {
        Start-Process msiexec.exe -ArgumentList "/i `"$UEMSPath`" /qn /norestart" -Wait -WindowStyle Hidden
    } else { Write-Log "Payload source not found: $UEMSPath" "ERROR" }
}

# 2. ManageEngine OpManager Agent Execution
$OpManagerService = "OpManagerAgent"
if (-not (Get-Service $OpManagerService -ErrorAction SilentlyContinue)) {
    Write-Log "OpManager Agent missing. Triggering zero-window installation payload..."
    $OpMPath = Join-Path $SourceShare "OpManagerAgent.exe"
    if (Test-Path $OpMPath) {
        # Executing with native silent switches to completely suppress rogue GUI installers
        Start-Process $OpMPath -ArgumentList "/s /v`"/qn /norestart`"" -Wait -WindowStyle Hidden
    } else { Write-Log "Payload source not found: $OpMPath" "ERROR" }
}

# 3. Symantec Endpoint Protection (SEP) Execution
$SEPService = "SepMasterService"
if (-not (Get-Service $SEPService -ErrorAction SilentlyContinue)) {
    Write-Log "Symantec Security Guard missing. Injected silent MSI installation pipeline..."
    $SEPPath = Join-Path $SourceShare "SepSetup.exe"
    if (Test-Path $SEPPath) {
        Start-Process $SEPPath -ArgumentList "/s /v`"/qn /norestart`"" -Wait -WindowStyle Hidden
    } else { Write-Log "Payload source not found: $SEPPath" "ERROR" }
}

# 4. NetSupport Client Execution
$NetSupportService = "Client32"
if (-not (Get-Service $NetSupportService -ErrorAction SilentlyContinue)) {
    Write-Log "NetSupport Support Core missing. Triggering headless deploy..."
    $NSPath = Join-Path $SourceShare "NetSupportClient.msi"
    if (Test-Path $NSPath) {
        Start-Process msiexec.exe -ArgumentList "/i `"$NSPath`" /qn /norestart" -Wait -WindowStyle Hidden
    } else { Write-Log "Payload source not found: $NSPath" "ERROR" }
}

# ==============================================================================
# PHASE 2: POST-DEPLOYMENT PARITY VALIDATION LOOP
# ==============================================================================
Write-Log "Entering system state evaluation and service verification routines..."

$Status_EC  = if (Get-Service "DesktopCentralAgent" -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "Running"}) { "OK" } else { "FAILED" }
$Status_OM  = if (Get-Service "OpManagerAgent" -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "Running"}) { "OK" } else { "FAILED" }
$Status_SYM = if (Get-Service "SepMasterService" -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "Running"}) { "OK" } else { "FAILED" }
$Status_NS  = if (Get-Service "Client32" -ErrorAction SilentlyContinue | Where-Object {$_.Status -eq "Running"}) { "OK" } else { "FAILED" }

# Log individual structural verification status for transparency
Write-Log "Verified service: ManageEngine UEMS - Agent -> State: $Status_EC" "VALIDATION"
Write-Log "Verified service: ManageEngine OpManager Agent -> State: $Status_OM" "VALIDATION"
Write-Log "Verified service: SepMasterService -> State: $Status_SYM" "VALIDATION"
Write-Log "NetSupport Verified: Service 'Client32' -> State: $Status_NS" "VALIDATION"

# ==============================================================================
# PIPELINE SUMMATION (Strict GitHub Metrics Conformity)
# ==============================================================================
Write-Log "FINAL SUMMARY" -Level "SUMMARY"
Write-Log "Final Status -> EC: $Status_EC, OM: $Status_OM, SYM: $Status_SYM, NS: $Status_NS" -Level "SUMMARY"
Write-Log "STAGE 4 PIPELINE EXECUTION LIFECYCLE COMPLETE"
Write-Log "============================================================"