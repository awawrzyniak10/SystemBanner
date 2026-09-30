# SystemBanner - Top Secret Remediation

$PolicyPath = "HKLM:\Software\Policies\SystemBanner"
$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
$installPath = Join-Path $programFiles "SystemBanner"
$exePath     = Join-Path $installPath "SystemBanner.exe"

$SimpleClassificationSetting = 5
$BannerPositionSetting       = 0

try {
    if (-not (Test-Path -LiteralPath $PolicyPath)) {
        New-Item -Path $PolicyPath -Force -ErrorAction Stop | Out-Null
    }

    New-ItemProperty -Path $PolicyPath -Name "Simple" -PropertyType DWord -Value $SimpleClassificationSetting -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path $PolicyPath -Name "TopAndBottom" -PropertyType DWord -Value $BannerPositionSetting -Force -ErrorAction Stop | Out-Null
}
catch {
    Write-Host "SystemBanner Top Secret configuration failed: $($_.Exception.Message)"
    exit 1
}

$Simple   = Get-ItemProperty -Path $PolicyPath -Name "Simple" -ErrorAction SilentlyContinue
$Position = Get-ItemProperty -Path $PolicyPath -Name "TopAndBottom" -ErrorAction SilentlyContinue

if ($null -eq $Simple -or $Simple.Simple -ne $SimpleClassificationSetting) {
    Write-Host "Validation failed: Simple Classification is not set to TOP SECRET."
    exit 1
}

if ($null -eq $Position -or $Position.TopAndBottom -ne $BannerPositionSetting) {
    Write-Host "Validation failed: Banner Position is not set to TOP ONLY."
    exit 1
}

try {
    Start-Process -FilePath $exePath -ErrorAction Stop
}
catch {
    Write-Host "SystemBanner configuration is correct, but the application failed to start: $($_.Exception.Message)"
    exit 1
}

Write-Host "SystemBanner is correctly configured for TOP SECRET, TOP ONLY and has been started."
exit 0