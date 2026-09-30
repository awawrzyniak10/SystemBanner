# ============================================================
# SystemBanner - Unclassified Remediation
#
# Exit codes:
#   0 = Configuration successfully applied
#   1 = Configuration failed
# ============================================================

$PolicyPath = "HKLM:\Software\Policies\SystemBanner"

# Expected settings:
#
# Simple:
#   0 = UNCONFIGURED
#   1 = UNCLASSIFIED
#   2 = CUI
#   3 = CONFIDENTIAL
#   4 = SECRET
#   5 = TOP SECRET
#   6 = TOP SECRET SCI
#
# TopAndBottom:
#   0 = TOP ONLY
#   1 = TOP AND BOTTOM

$SimpleClassificationSetting = 1
$BannerPositionSetting       = 0


# ------------------------------------------------------------
# Create policy key if necessary
# ------------------------------------------------------------

try {

    if (-not (Test-Path -LiteralPath $PolicyPath)) {
        New-Item -Path $PolicyPath -Force -ErrorAction Stop | Out-Null
    }

    # --------------------------------------------------------
    # Simple Classification
    #
    # 1 = UNCLASSIFIED
    # --------------------------------------------------------

    New-ItemProperty -Path $PolicyPath -Name "Simple" -PropertyType DWord -Value $SimpleClassificationSetting -Force -ErrorAction Stop | Out-Null

    # --------------------------------------------------------
    # Banner Position
    #
    # 0 = TOP ONLY
    # --------------------------------------------------------

    New-ItemProperty -Path $PolicyPath -Name "TopAndBottom" -PropertyType DWord -Value $BannerPositionSetting -Force -ErrorAction Stop | Out-Null

}
catch {
    Write-Host "SystemBanner Unclassified configuration failed: $($_.Exception.Message)"
    exit 1
}


# ============================================================
# VALIDATE
# ============================================================

$Simple = Get-ItemProperty -Path $PolicyPath -Name "Simple" -ErrorAction SilentlyContinue

$Position = Get-ItemProperty -Path $PolicyPath -Name "TopAndBottom" -ErrorAction SilentlyContinue


if ($null -eq $Simple -or
    $Simple.Simple -ne 1) {

    Write-Host "Validation failed: Simple Classification is not set to UNCLASSIFIED."
    exit 1
}


if ($null -eq $Position -or
    $Position.TopAndBottom -ne 0) {

    Write-Host "Validation failed: Banner Position is not set to TOP ONLY."
    exit 1
}

# ------------------------------------------------------------
# Start SystemBanner
# ------------------------------------------------------------

$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
$installPath = Join-Path $programFiles "SystemBanner"
$exePath     = Join-Path $installPath "SystemBanner.exe"

try {
    Start-Process -FilePath $exePath -ErrorAction Stop
}
catch {
    Write-Host "SystemBanner configuration is correct, but the application failed to start: $($_.Exception.Message)"
    exit 1
}


# ============================================================
# COMPLETE
# ============================================================

Write-Host "SystemBanner is correctly configured for UNCLASSIFIED, TOP ONLY and has been started."
exit 0