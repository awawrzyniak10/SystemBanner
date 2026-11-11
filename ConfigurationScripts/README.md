# SystemBanner PowerShell Configuration Scripts

This directory contains PowerShell scripts for configuring and removing SystemBanner on Windows.

The scripts are intended to provide an alternative to the existing GPO, gpedit.msc, and manual registry methods and are used to automate configuration and uninstallation when you do not have Group Policy (Cloud Only) or you do not have access to gpedit.msc (Windows Home Edition). 

The scripts are in Detect/Remediate pairs for deployment via your favorite endpoint management platform such as Microsoft Intune or Automox.

## Contents

### Uninstallation

`systemBannerUninstall-Detect.ps1` and `systemBannerUninstall-Remediate.ps1`

Detects the installation of SystemBanner. If SystemBanner is detected it removes SystemBanner and its associated configuration:

* Stops the SystemBanner process
* Removes the machine-wide startup entry
* Removes the high-DPI compatibility setting
* Removes the SystemBanner policy registry key
* Removes the installed application files
* Removes the ADMX and ADML policy templates
* Validates that the installation has been removed

### Classification Configuration

The classification configuration scripts use the registry settings defined by the SystemBanner Group Policy templates.

`systemBannerSetConfidential-Detect.ps1` and `systemBannerSetConfidential-Remediate.ps1`

`systemBannerSetCUI-Detect.ps1` and `systemBannerSetCUI-Remediate.ps1`

`systemBannerSetCustom(TS_SAR_WAIVED)-Detect.ps1` and `systemBannerSetCustom(TS_SAR_WAIVED)-Remediate.ps1`

`systemBannerSetSecret-Detect.ps1` and `systemBannerSetSecret-Remediate.ps1`

`systemBannerSetTopSecret-Detect.ps1` and `systemBannerSetTopSecret-Remediate.ps1`

`systemBannerSetTopSecretSCI-Detect.ps1` and `systemBannerSetTopSecretSCI-Remediate.ps1`

`systemBannerSetUnclassified-Detect.ps1` and `systemBannerSetUnclassified-Remediate.ps1`


The built-in classifications are:

| Classification | Value |
| -------------- | ----: |
| Unconfigured   |     0 |
| Unclassified   |     1 |
| CUI            |     2 |
| Confidential   |     3 |
| Secret         |     4 |
| Top Secret     |     5 |
| Top Secret SCI |     6 |

Use the configuration scripts independently of the installation script.

For example, an organization can install SystemBanner once and use its endpoint management platform to apply the appropriate classification 
configuration to different groups of computers.

## Custom Configuration

SystemBanner also supports a custom configuration when the simple classification setting is set to `0` (Unconfigured).

The `systemBannerSetCustom(TS_SAR_WAIVED)-Detect.ps1` and `systemBannerSetCustom(TS_SAR_WAIVED)-Remediate.ps1` scripts are an example of a custom configuration.

Custom configuration can specify:

* Banner text
* Background color
* Foreground color
* Banner position

The registry values correspond to the settings exposed by the SystemBanner Group Policy templates.

For example, a custom banner can be configured with text such as:

`TOP SECRET//SAR-RED CAR/SAR-TIN BAKER//WAIVED`

and custom foreground color, #000000 (RGB: 0, 0, 0) and background color, #FF8C00 (RGB: 255, 140, 0).

Custom configuration should only be used where the organization's security marking requirements permit it.

## Using With Microsoft Intune or Automox

The scripts can be used with Intune Proactive Remediations or Automox Worklets to separate installation, detection, and configuration.

A typical deployment can consist of:

1. Install SystemBanner
2. Apply the desired classification configuration by creating a Proactive Remediation (Intune) or Worklet (Automox) with the desired classification scripts, i.e., `systemBannerSetTopSecretSCI-Detect.ps1` and `systemBannerSetTopSecretSCI-Remediate.ps1`

## Administrative Privileges

Uninstallation and configuration modify locations under `HKLM` and `C:\Program Files`.

The scripts therefore require administrative privileges when run interactively.

When deployed through an endpoint management platform, they should run in the system context and in **64-bit PowerShell** on 64-bit Windows (Intune: enable “Run script in 64-bit PowerShell”). SystemBanner reads policy from the 64-bit registry view (`RegistryView.Registry64`), so 32-bit execution can write to WOW6432Node and have no effect.

## Notes

The scripts are intended to complement the existing SystemBanner application and Group Policy templates. The registry paths and values used by the configuration scripts correspond to the settings defined in the included SystemBanner ADMX/ADML files.

For additional information about SystemBanner, see the main project documentation.
