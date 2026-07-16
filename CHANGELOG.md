# Changelog

## 1.0.0 — Initial release

- `Get-ESUExposureReport`: domain-wide and local discovery, matching the post's `Get-ADComputer` and `Get-CimInstance` examples
- `Test-ESULicenseStatus`: local/remote `slmgr.vbs /dlv` verification, with optional Activation ID
- `Install-ESULicenseKey`: `slmgr.vbs /ipk` + `/ato` install and activate, with `-WhatIf`/`-Confirm` support
- `Test-AzureArcESUStatus`: `slmgr` check plus registry eligibility flag check for Arc-enabled/hybrid ESU
- Companion to the Cloudy Musings post "Ragnarok for Windows Server: A Practitioner's Guide to Extended Security Updates"
