# ============================================================
# SystemBanner - CUI Detection
#
# Exit codes:
#   0 = Configuration is correct
#   1 = Configuration is not correct
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

$ExpectedSimpleClassification = 2
$ExpectedBannerPosition       = 0


# ------------------------------------------------------------
# Check policy key
# ------------------------------------------------------------

if (-not (Test-Path -LiteralPath $PolicyPath)) {
    Write-Host "SystemBanner CUI configuration is not present."
    exit 1
}


# ------------------------------------------------------------
# Check Simple Classification
# ------------------------------------------------------------

$Simple = Get-ItemProperty -Path $PolicyPath -Name "Simple" -ErrorAction SilentlyContinue
if ($null -eq $Simple -or 
    $Simple.Simple -ne $ExpectedSimpleClassification) {

    Write-Host "SystemBanner CUI configuration is incorrect: Simple is not set to 2."
    exit 1
}


# ------------------------------------------------------------
# Check Banner Position
# ------------------------------------------------------------

$Position = Get-ItemProperty -Path $PolicyPath -Name "TopAndBottom" -ErrorAction SilentlyContinue

if ($null -eq $Position -or 
    $Position.TopAndBottom -ne $ExpectedBannerPosition) {

    Write-Host "SystemBanner CUI configuration is incorrect: TopAndBottom is not set to 0."
    exit 1
}



# ------------------------------------------------------------
# Configuration is correct
# ------------------------------------------------------------

Write-Host "SystemBanner is correctly configured for CUI, TOP ONLY."
exit 0