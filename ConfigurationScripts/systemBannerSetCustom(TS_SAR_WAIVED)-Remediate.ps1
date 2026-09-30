<#
================================================================================
SystemBanner - Custom TS//SAR//WAIVED Remediation
================================================================================

Direct registry configuration for the SystemBanner Group Policy settings.

Exit codes:

    0 = Configuration successfully applied
    1 = Configuration failed

#>


# ==============================================================================
# CONFIGURATION
# ==============================================================================

$SimpleClassificationSetting = 0
$BannerPositionSetting       = 0

$BackgroundColor = @(255, 140, 0)

$ForegroundColor = @(0, 0, 0)

$BannerText = "TOP SECRET//SAR-RED CAR/SAR-TIN BAKER//WAIVED"


# ==============================================================================
# PATHS
# ==============================================================================

$PolicyPath = "HKLM:\Software\Policies\SystemBanner"

$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }

$installPath = Join-Path $programFiles "SystemBanner"
$exePath     = Join-Path $installPath "SystemBanner.exe"


# ==============================================================================
# CONFIGURATION VALIDATION
# ==============================================================================

if ($SimpleClassificationSetting -notin 0..6) {
    Write-Host "SystemBanner TS//SAR//WAIVED remediation failed: SimpleClassificationSetting must be between 0 and 6."
    exit 1
}

if ($BannerPositionSetting -notin 0..1) {
    Write-Host "SystemBanner TS//SAR//WAIVED remediation failed: BannerPositionSetting must be 0 or 1."
    exit 1
}

if ($BackgroundColor.Count -ne 3) {
    Write-Host "SystemBanner TS//SAR//WAIVED remediation failed: BackgroundColor must contain exactly three RGB values."
    exit 1
}

if ($ForegroundColor.Count -ne 3) {
    Write-Host "SystemBanner TS//SAR//WAIVED remediation failed: ForegroundColor must contain exactly three RGB values."
    exit 1
}

foreach ($Value in ($BackgroundColor + $ForegroundColor)) {
    if ($Value -lt 0 -or $Value -gt 255) {
        Write-Host "SystemBanner TS//SAR//WAIVED remediation failed: All RGB values must be between 0 and 255."
        exit 1
    }
}


# ==============================================================================
# APPLY CONFIGURATION
# ==============================================================================

try {

    if (-not (Test-Path -LiteralPath $PolicyPath -PathType Container)) {
        New-Item -Path $PolicyPath -Force -ErrorAction Stop | Out-Null
    }


    # Simple Classification

    New-ItemProperty -Path $PolicyPath -Name "Simple" -PropertyType DWord -Value $SimpleClassificationSetting -Force -ErrorAction Stop | Out-Null

    # Banner Position

    New-ItemProperty -Path $PolicyPath -Name "TopAndBottom" -PropertyType DWord -Value $BannerPositionSetting -Force -ErrorAction Stop | Out-Null


    # Background Color

    New-ItemProperty -Path $PolicyPath -Name "0" -PropertyType DWord -Value $BackgroundColor[0] -Force -ErrorAction Stop | Out-Null

    New-ItemProperty -Path $PolicyPath -Name "1" -PropertyType DWord -Value $BackgroundColor[1] -Force -ErrorAction Stop | Out-Null

    New-ItemProperty -Path $PolicyPath -Name "2" -PropertyType DWord -Value $BackgroundColor[2] -Force -ErrorAction Stop | Out-Null


    # Foreground Color

    New-ItemProperty -Path $PolicyPath -Name "3" -PropertyType DWord -Value $ForegroundColor[0] -Force -ErrorAction Stop | Out-Null

    New-ItemProperty -Path $PolicyPath -Name "4" -PropertyType DWord -Value $ForegroundColor[1] -Force -ErrorAction Stop | Out-Null

    New-ItemProperty -Path $PolicyPath -Name "5" -PropertyType DWord -Value $ForegroundColor[2] -Force -ErrorAction Stop | Out-Null


    # Custom Text

    New-ItemProperty -Path $PolicyPath -Name "Text" -PropertyType String -Value $BannerText -Force -ErrorAction Stop | Out-Null
}
catch {
    Write-Host "SystemBanner TS//SAR//WAIVED remediation failed: Unable to apply registry configuration. $($_.Exception.Message)"
    exit 1
}


# ==============================================================================
# VALIDATE CONFIGURATION
# ==============================================================================

$Simple = Get-ItemProperty -Path $PolicyPath -Name "Simple" -ErrorAction SilentlyContinue

if ($null -eq $Simple -or $Simple.Simple -ne $SimpleClassificationSetting) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Simple Classification does not match the configured value."
    exit 1
}


$Position = Get-ItemProperty -Path $PolicyPath -Name "TopAndBottom" -ErrorAction SilentlyContinue

if ($null -eq $Position -or $Position.TopAndBottom -ne $BannerPositionSetting) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Banner Position does not match the configured value."
    exit 1
}


# Background Color

$Red = Get-ItemProperty -Path $PolicyPath -Name "0" -ErrorAction SilentlyContinue

$Green = Get-ItemProperty -Path $PolicyPath -Name "1" -ErrorAction SilentlyContinue

$Blue = Get-ItemProperty -Path $PolicyPath -Name "2" -ErrorAction SilentlyContinue

if ($null -eq $Red -or $Red.'0' -ne $BackgroundColor[0]) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Background Red does not match the configured value."
    exit 1
}

if ($null -eq $Green -or $Green.'1' -ne $BackgroundColor[1]) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Background Green does not match the configured value."
    exit 1
}

if ($null -eq $Blue -or $Blue.'2' -ne $BackgroundColor[2]) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Background Blue does not match the configured value."
    exit 1
}


# Foreground Color

$ForegroundRed = Get-ItemProperty -Path $PolicyPath -Name "3" -ErrorAction SilentlyContinue

$ForegroundGreen = Get-ItemProperty -Path $PolicyPath -Name "4" -ErrorAction SilentlyContinue

$ForegroundBlue = Get-ItemProperty -Path $PolicyPath -Name "5" -ErrorAction SilentlyContinue

if ($null -eq $ForegroundRed -or $ForegroundRed.'3' -ne $ForegroundColor[0]) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Foreground Red does not match the configured value."
    exit 1
}

if ($null -eq $ForegroundGreen -or $ForegroundGreen.'4' -ne $ForegroundColor[1]) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Foreground Green does not match the configured value."
    exit 1
}

if ($null -eq $ForegroundBlue -or $ForegroundBlue.'5' -ne $ForegroundColor[2]) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Foreground Blue does not match the configured value."
    exit 1
}


# Custom Text

$Text = Get-ItemProperty -Path $PolicyPath -Name "Text" -ErrorAction SilentlyContinue

if ($null -eq $Text -or $Text.Text -ne $BannerText) {
    Write-Host "SystemBanner TS//SAR//WAIVED validation failed: Custom Banner Text does not match the configured value."
    exit 1
}


# ==============================================================================
# START SYSTEMBANNER
# ==============================================================================

if (-not (Test-Path -LiteralPath $exePath -PathType Leaf)) {
    Write-Host "SystemBanner TS//SAR//WAIVED remediation failed: SystemBanner executable was not found: $exePath"
    exit 1
}

try {
    Stop-Process -Name "SystemBanner" -Force -ErrorAction SilentlyContinue

    Start-Process -FilePath $exePath -ErrorAction Stop
}
catch {
    Write-Host "SystemBanner TS//SAR//WAIVED remediation failed: Configuration is correct, but SystemBanner could not be started. $($_.Exception.Message)"
    exit 1
}


# ==============================================================================
# COMPLETE
# ==============================================================================

Write-Host "SystemBanner TS//SAR//WAIVED remediation succeeded: Configuration is correct and SystemBanner has been started."

exit 0