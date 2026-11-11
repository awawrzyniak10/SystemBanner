$programFiles = if ($env:ProgramW6432) { $env:ProgramW6432 } else { $env:ProgramFiles }
$installPath = Join-Path $programFiles "SystemBanner"

$admxPath = Join-Path $env:windir "PolicyDefinitions\SystemBanner.admx"
$admlPath = Join-Path $env:windir "PolicyDefinitions\en-US\SystemBanner.adml"

$appCompatPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$runPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
$policyPath = "HKLM:\Software\Policies\SystemBanner"


# Check installation files
if (Test-Path -LiteralPath $installPath -PathType Container) {
    Write-Host "SystemBanner installation detected."
    exit 1
}

if (Test-Path -LiteralPath $admxPath -PathType Leaf) {
    Write-Host "SystemBanner ADMX detected."
    exit 1
}

if (Test-Path -LiteralPath $admlPath -PathType Leaf) {
    Write-Host "SystemBanner ADML detected."
    exit 1
}


# Check startup entry
$runValue = Get-ItemProperty -Path $runPath -Name "SystemBanner" -ErrorAction SilentlyContinue

if ($null -ne $runValue) {
    Write-Host "SystemBanner startup entry detected."
    exit 1
}


# Check High DPI compatibility entry
$exePath = Join-Path $installPath "SystemBanner.exe"
$appCompatValue = Get-ItemProperty -Path $appCompatPath -Name $exePath -ErrorAction SilentlyContinue

if ($null -ne $appCompatValue) {
    Write-Host "SystemBanner compatibility setting detected."
    exit 1
}


# Check policy configuration
if (Test-Path -LiteralPath $policyPath -PathType Container) {
    Write-Host "SystemBanner policy configuration detected."
    exit 1
}


Write-Host "SystemBanner is not installed."
exit 0