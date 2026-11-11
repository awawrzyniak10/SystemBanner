<#
================================================================================
SystemBanner - Custom TS//SAR//WAIVED Detection
================================================================================

Intune Remediation detection script for the custom SystemBanner
classification banner.

Exit codes:

    0 = Configuration is correct
    1 = Configuration is not correct

#>


# ==============================================================================
# EXPECTED CONFIGURATION
# ==============================================================================

$PolicyPath = "HKLM:\Software\Policies\SystemBanner"

$ExpectedSimpleClassification = 0
$ExpectedBannerPosition       = 0

$ExpectedBackgroundColor = @{
    Red   = 255
    Green = 140
    Blue  = 0
}

$ExpectedForegroundColor = @{
    Red   = 0
    Green = 0
    Blue  = 0
}

$ExpectedBannerText = "TOP SECRET//SAR-RED CAR/SAR-TIN BAKER//WAIVED"


# ==============================================================================
# POLICY KEY
# ==============================================================================

if (-not (Test-Path -LiteralPath $PolicyPath -PathType Container)) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Policy configuration is not present."
    exit 1
}


# ==============================================================================
# SIMPLE CLASSIFICATION
# ==============================================================================

$Simple = Get-ItemProperty -Path $PolicyPath -Name "Simple" -ErrorAction SilentlyContinue

if ($null -eq $Simple -or $Simple.Simple -ne $ExpectedSimpleClassification) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Simple Classification does not match the expected configuration."
    exit 1
}


# ==============================================================================
# BANNER POSITION
# ==============================================================================

$Position = Get-ItemProperty -Path $PolicyPath -Name "TopAndBottom" -ErrorAction SilentlyContinue

if ($null -eq $Position -or $Position.TopAndBottom -ne $ExpectedBannerPosition) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Banner Position does not match the expected configuration."
    exit 1
}


# ==============================================================================
# BACKGROUND COLOR
# ==============================================================================

$Red = Get-ItemProperty -Path $PolicyPath -Name "0" -ErrorAction SilentlyContinue

$Green = Get-ItemProperty -Path $PolicyPath -Name "1" -ErrorAction SilentlyContinue

$Blue = Get-ItemProperty -Path $PolicyPath -Name "2" -ErrorAction SilentlyContinue

if ($null -eq $Red -or $Red.'0' -ne $ExpectedBackgroundColor.Red) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Background Red does not match the expected configuration."
    exit 1
}

if ($null -eq $Green -or $Green.'1' -ne $ExpectedBackgroundColor.Green) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Background Green does not match the expected configuration."
    exit 1
}

if ($null -eq $Blue -or $Blue.'2' -ne $ExpectedBackgroundColor.Blue) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Background Blue does not match the expected configuration."
    exit 1
}


# ==============================================================================
# FOREGROUND COLOR
# ==============================================================================

$ForegroundRed = Get-ItemProperty -Path $PolicyPath -Name "3" -ErrorAction SilentlyContinue

$ForegroundGreen = Get-ItemProperty -Path $PolicyPath -Name "4" -ErrorAction SilentlyContinue

$ForegroundBlue = Get-ItemProperty -Path $PolicyPath -Name "5" -ErrorAction SilentlyContinue

if ($null -eq $ForegroundRed -or $ForegroundRed.'3' -ne $ExpectedForegroundColor.Red) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Foreground Red does not match the expected configuration."
    exit 1
}

if ($null -eq $ForegroundGreen -or $ForegroundGreen.'4' -ne $ExpectedForegroundColor.Green) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Foreground Green does not match the expected configuration."
    exit 1
}

if ($null -eq $ForegroundBlue -or $ForegroundBlue.'5' -ne $ExpectedForegroundColor.Blue) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Foreground Blue does not match the expected configuration."
    exit 1
}


# ==============================================================================
# CUSTOM TEXT
# ==============================================================================

$Text = Get-ItemProperty -Path $PolicyPath -Name "Text" -ErrorAction SilentlyContinue

if ($null -eq $Text -or $Text.Text -ne $ExpectedBannerText) {
    Write-Host "SystemBanner TS//SAR//WAIVED detection failed: Custom Banner Text does not match the expected configuration."
    exit 1
}


# ==============================================================================
# COMPLETE
# ==============================================================================

Write-Host "SystemBanner TS//SAR//WAIVED detection succeeded: Configuration is correct."

exit 0