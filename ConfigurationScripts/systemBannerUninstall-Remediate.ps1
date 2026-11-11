# ============================================================
# SystemBanner - Uninstall / Remediation
#
# Exit codes:
#   0 = SystemBanner completely uninstalled
#   1 = Uninstall failed
# ============================================================

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------

$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
$installPath = Join-Path $programFiles "SystemBanner"
$exePath     = Join-Path $installPath "SystemBanner.exe"

$admxPath = Join-Path $env:windir "PolicyDefinitions\SystemBanner.admx"
$admlPath = Join-Path $env:windir "PolicyDefinitions\en-US\SystemBanner.adml"

$appCompatPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$runPath       = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$policyPath    = "HKLM:\Software\Policies\SystemBanner"


# ------------------------------------------------------------
# Stop SystemBanner
# ------------------------------------------------------------

Stop-Process -Name "SystemBanner" -Force -ErrorAction SilentlyContinue


# ============================================================
# REMOVE SYSTEMBANNER
# ============================================================

try {

    # Remove startup entry
    Remove-ItemProperty `
        -Path $runPath `
        -Name "SystemBanner" `
        -ErrorAction SilentlyContinue


    # Remove High DPI compatibility setting
    Remove-ItemProperty `
        -Path $appCompatPath `
        -Name $exePath `
        -ErrorAction SilentlyContinue


    # Remove SystemBanner policy configuration
    if (Test-Path -LiteralPath $policyPath -PathType Container) {
        Remove-Item `
            -LiteralPath $policyPath `
            -Recurse `
            -Force `
            -ErrorAction Stop
    }


    # Remove application directory
    if (Test-Path -LiteralPath $installPath -PathType Container) {
        Remove-Item `
            -LiteralPath $installPath `
            -Recurse `
            -Force `
            -ErrorAction Stop
    }


    # Remove ADMX
    if (Test-Path -LiteralPath $admxPath -PathType Leaf) {
        Remove-Item `
            -LiteralPath $admxPath `
            -Force `
            -ErrorAction Stop
    }


    # Remove ADML
    if (Test-Path -LiteralPath $admlPath -PathType Leaf) {
        Remove-Item `
            -LiteralPath $admlPath `
            -Force `
            -ErrorAction Stop
    }

}
catch {
    Write-Host "SystemBanner uninstall failed: $($_.Exception.Message)"
    exit 1
}


# ============================================================
# VALIDATE UNINSTALL
# ============================================================

$uninstallValid = $true


# Installation directory
if (Test-Path -LiteralPath $installPath -PathType Container) {
    Write-Host "Validation failed: SystemBanner installation directory still exists."
    $uninstallValid = $false
}


# ADMX
if (Test-Path -LiteralPath $admxPath -PathType Leaf) {
    Write-Host "Validation failed: SystemBanner.admx still exists."
    $uninstallValid = $false
}


# ADML
if (Test-Path -LiteralPath $admlPath -PathType Leaf) {
    Write-Host "Validation failed: SystemBanner.adml still exists."
    $uninstallValid = $false
}


# Startup entry
$runValue = Get-ItemProperty `
    -Path $runPath `
    -Name "SystemBanner" `
    -ErrorAction SilentlyContinue

if ($null -ne $runValue) {
    Write-Host "Validation failed: SystemBanner startup entry still exists."
    $uninstallValid = $false
}


# High DPI compatibility entry
$appCompatValue = Get-ItemProperty `
    -Path $appCompatPath `
    -Name $exePath `
    -ErrorAction SilentlyContinue

if ($null -ne $appCompatValue) {
    Write-Host "Validation failed: SystemBanner compatibility setting still exists."
    $uninstallValid = $false
}


# Policy configuration
if (Test-Path -LiteralPath $policyPath -PathType Container) {
    Write-Host "Validation failed: SystemBanner policy configuration still exists."
    $uninstallValid = $false
}


# Running process
if (Get-Process -Name "SystemBanner" -ErrorAction SilentlyContinue) {
    Write-Host "Validation failed: SystemBanner process is still running."
    $uninstallValid = $false
}


# ============================================================
# FINAL RESULT
# ============================================================

if ($uninstallValid) {
    Write-Host "SystemBanner has been completely uninstalled."
    exit 0
}

Write-Host "SystemBanner uninstall validation failed."
exit 1