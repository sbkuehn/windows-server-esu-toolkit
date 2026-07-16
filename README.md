# Windows Server ESU Toolkit

Companion code for the Cloudy Musings post **"Ragnarok for Windows Server: A Practitioner's Guide to Extended Security Updates."**

This module wraps the exact PowerShell and `slmgr.vbs` commands shown in that post into four reusable, parameterized functions. It does not add functionality beyond what's covered there, no cost calculators, no Azure Resource Manager calls, no scope creep. If you read the post, this is that same tooling made pipeline-friendly and safe to reuse across a fleet instead of copy-pasted one server at a time.

Read the post first if you haven't: it explains *why* each of these checks matters and what to factor into the ESU decision itself. This repo is the *how*.

## What's in here

| Function | Mirrors this from the post |
|---|---|
| `Get-ESUExposureReport` | The `Get-ADComputer` domain sweep, and the `Get-CimInstance Win32_OperatingSystem` local check |
| `Test-ESULicenseStatus` | The `slmgr.vbs /dlv` and `slmgr.vbs /dlv <ActivationID>` verification steps |
| `Install-ESULicenseKey` | The `slmgr.vbs /ipk` and `slmgr.vbs /ato` install-then-activate steps |
| `Test-AzureArcESUStatus` | The Arc-enabled server verification: the `slmgr` check plus the registry eligibility flags under `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\ESU` |

## Quick start

```powershell
# Import the module from a cloned or extracted copy of this repo
Import-Module .\WindowsServerESUToolkit.psd1

# Find every Server 2012/2012 R2/2016 machine in the domain
Get-ESUExposureReport -Scope Domain

# Check OS build details on a specific box
Get-ESUExposureReport -Scope Local -ComputerName SQL01

# Verify ESU license status locally
Test-ESULicenseStatus

# Verify against a specific Activation ID, on a remote server
Test-ESULicenseStatus -ComputerName ARC-SRV01 -ActivationID '12345678-abcd-1234-abcd-1234567890ab'

# Install and activate a key (prompts for confirmation, supports -WhatIf)
Install-ESULicenseKey -LicenseKey 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' -ActivationID '12345678-abcd-1234-abcd-1234567890ab' -WhatIf

# Check Azure Arc ESU enrollment status
Test-AzureArcESUStatus -ComputerName ARC-SRV01
```

See [`docs/HOW-TO.md`](docs/HOW-TO.md) for a walkthrough of each function, and [`examples/Example-Usage.ps1`](examples/Example-Usage.ps1) for a runnable script that chains discovery into a license check across a list of servers.

## Requirements

See [`REQUIREMENTS.md`](REQUIREMENTS.md). Short version: Windows, PowerShell 5.1+, elevated session for the license functions, and the ActiveDirectory module only if you're using the domain-wide discovery scope.

## A note on `Install-ESULicenseKey`

This function makes a real licensing change on the target machine. It supports `-WhatIf` and will prompt for confirmation by default. Review the key and Activation ID before confirming, and test against a single non-production server before scripting it across a fleet.

## License

MIT. See [`LICENSE`](LICENSE).

## Author

Shannon Eldridge-Kuehn ([Cloudy Musings](https://shankuehn.io))
