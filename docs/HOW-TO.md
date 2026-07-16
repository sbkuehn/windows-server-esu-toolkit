# How-To

Each section below maps to a function and, in turn, to the matching section of the blog post. Nothing here goes beyond what the post covers.

## 1. Find out what you're exposed to

Start with discovery, you can't plan for ESU on servers you don't know exist.

```powershell
# Domain-wide sweep for Server 2012 and 2016 machines
Get-ESUExposureReport -Scope Domain | Format-Table -AutoSize

# Export it for a spreadsheet or a client deliverable
Get-ESUExposureReport -Scope Domain | Export-Csv -Path .\esu-exposure.csv -NoTypeInformation
```

For a single machine, or a short list, when you don't need or have the ActiveDirectory module:

```powershell
Get-ESUExposureReport -Scope Local -ComputerName SQL01, SQL02, ARC-SRV01
```

## 2. Verify whether a machine already has an active ESU license

```powershell
# Local check
Test-ESULicenseStatus

# Local check against a specific Activation ID
Test-ESULicenseStatus -ActivationID '12345678-abcd-1234-abcd-1234567890ab'

# Remote check across a short list
Test-ESULicenseStatus -ComputerName SRV01, SRV02
```

The `Licensed` field in the output is `$true` only when the raw `slmgr` output contains `License Status: Licensed`. If you get `$false` and expected `$true`, check the `RawOutput` field, the post notes this can also show up as a cosmetic "reached end of support" message even when the license is active, so don't treat a UI warning alone as proof either way.

## 3. Install and activate a key

Only run this once you've confirmed the correct MAK and Activation ID from your Volume Licensing contract (Microsoft 365 admin center → Billing → Your Products → Volume licensing → Contracts).

```powershell
Install-ESULicenseKey -LicenseKey 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' `
    -ActivationID '12345678-abcd-1234-abcd-1234567890ab' `
    -WhatIf
```

Drop `-WhatIf` once you've confirmed the plan looks right. The function will still prompt for confirmation unless you pass `-Confirm:$false`.

Then verify it took:

```powershell
Test-ESULicenseStatus
```

## 4. Check Azure Arc ESU enrollment

```powershell
Test-AzureArcESUStatus -ComputerName ARC-SRV01
```

This checks the same two things the post recommends: the `slmgr` license status, and the registry eligibility flags. It does **not** check the Azure Portal for you, that's a manual step the post calls out separately (search the server name, check the Overview page under the Capabilities tab for ESUs showing "Enabled"). Treat this function's output as the on-box half of the verification, not the whole picture.

## Running against a fleet

All three read-only functions (`Get-ESUExposureReport -Scope Local`, `Test-ESULicenseStatus`, `Test-AzureArcESUStatus`) accept an array for `-ComputerName`, so you can pipe a discovery result straight into a status check:

```powershell
$atRisk = Get-ESUExposureReport -Scope Domain
Test-ESULicenseStatus -ComputerName $atRisk.Name
```
