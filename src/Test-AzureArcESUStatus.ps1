function Test-AzureArcESUStatus {
    <#
    .SYNOPSIS
        Checks ESU enrollment status for Azure Arc-enabled or hybrid-enrolled
        machines.

    .DESCRIPTION
        Wraps the two verification paths from the "Ragnarok for Windows Server"
        post: the local slmgr.vbs /dlv check (the same one used for MAK-based
        ESU, which also applies to Arc-linked ESU licenses), and the registry
        check for the ESU eligibility flags described in the post
        (HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\ESU).
        This function does not call the Azure Resource Graph or Az PowerShell
        module, the post's guidance for portal-based confirmation is to check
        the server's Overview page under the Capabilities tab, which is a
        manual step outside the scope of this script.

    .PARAMETER ComputerName
        Optional. Runs the check remotely via Invoke-Command. Defaults to the
        local machine.

    .EXAMPLE
        Test-AzureArcESUStatus

        Runs the slmgr /dlv check and the registry eligibility check locally,
        returning both results together.

    .EXAMPLE
        Test-AzureArcESUStatus -ComputerName ARC-SRV01

        Runs the same two checks remotely against a named Arc-enabled server.

    .NOTES
        Author: Shannon Eldridge-Kuehn
        Must be run from an elevated session for the slmgr portion. Remote
        registry checks require the Remote Registry service running on the
        target and appropriate firewall rules, as noted in the post.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    $scriptBlock = {
        $licenseOutput = cscript.exe //NoLogo C:\Windows\System32\slmgr.vbs /dlv
        $licensed = ($licenseOutput -match 'License Status:\s*Licensed') -as [bool]

        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\ESU'
        $regValues = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue

        [PSCustomObject]@{
            ComputerName              = $env:COMPUTERNAME
            SlmgrLicensed             = $licensed
            EnableESUSubscriptionCheck = if ($regValues) { $regValues.EnableESUSubscriptionCheck } else { $null }
            RegistryKeyFound          = [bool]$regValues
        }
    }

    foreach ($computer in $ComputerName) {
        Write-Verbose "Checking Arc/ESU status on $computer."

        try {
            if ($computer -eq $env:COMPUTERNAME) {
                & $scriptBlock
            }
            else {
                Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ErrorAction Stop
            }
        }
        catch {
            Write-Warning "Could not check Arc/ESU status on $computer : $($_.Exception.Message). If this is a remote registry error, confirm the Remote Registry service is running on the target and that the required firewall ports are open, as noted in the post."
        }
    }

    Write-Verbose "Reminder from the post: also confirm status in the Azure Portal by searching the server name and checking the Overview page under the Capabilities tab for ESUs showing 'Enabled.'"
}
