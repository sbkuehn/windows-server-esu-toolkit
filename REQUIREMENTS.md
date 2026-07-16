# Requirements

## Runtime

- PowerShell 5.1 or PowerShell 7.x (Windows only, this module shells out to `cscript.exe` and `slmgr.vbs`, both Windows-only components)
- Windows Server (any version referenced in the companion blog post: 2012, 2012 R2, 2016) or a management workstation with RSAT installed
- Administrative/elevated session for `Test-ESULicenseStatus`, `Install-ESULicenseKey`, and the `slmgr` portion of `Test-AzureArcESUStatus`

## Module dependencies

- **ActiveDirectory PowerShell module** — required only for `Get-ESUExposureReport -Scope Domain`. Install via RSAT:
  ```powershell
  Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
  ```
- No other external modules are required. This toolkit intentionally does not depend on the Az PowerShell module, everything here mirrors the native `slmgr.vbs` and registry checks from the blog post rather than calling Azure Resource Manager APIs.

## Permissions

- **Domain discovery**: read access to computer objects in Active Directory (standard authenticated user rights are sufficient for `Get-ADComputer`)
- **Remote checks**: PowerShell remoting (WinRM) enabled on target machines for any `-ComputerName` parameter pointed at a remote host
- **Remote registry checks**: the Remote Registry service running on the target, and firewall rules permitting remote registry access, as called out in the blog post

## Network

- No internet access is required to run any function in this module. All checks are local or intra-network (AD, WinRM, remote registry).
