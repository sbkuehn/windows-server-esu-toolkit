function Test-ESULicenseStatus {
    <#
    .SYNOPSIS
        Verifies whether an ESU key is installed and activated, using slmgr.vbs.

    .DESCRIPTION
        Wraps the slmgr.vbs /dlv verification shown in the "Ragnarok for Windows
        Server" post. Runs it locally or against a remote machine via PowerShell
        remoting, and reports whether an ESU program shows a License Status of
        "Licensed" in the output. This does not change licensing state, it only
        reads and reports it. Must be run elevated.

    .PARAMETER ActivationID
        Optional. Passed straight through to `slmgr.vbs /dlv <ActivationID>` as
        shown in the post, to check a specific ESU program rather than the
        general /dlv output.

    .PARAMETER ComputerName
        Optional. Runs the check remotely via Invoke-Command. Defaults to the
        local machine. Requires PowerShell remoting to be enabled on the target.

    .EXAMPLE
        Test-ESULicenseStatus

        Runs `cscript slmgr.vbs /dlv` locally and reports the raw output plus a
        parsed Licensed/NotLicensed summary.

    .EXAMPLE
        Test-ESULicenseStatus -ActivationID '12345678-abcd-1234-abcd-1234567890ab'

        Checks the status of a specific ESU Activation ID, matching the post's
        `slmgr /dlv <Activation ID>` example.

    .EXAMPLE
        Test-ESULicenseStatus -ComputerName SQL01, SQL02

        Runs the same check remotely against a short list of servers.

    .NOTES
        Author: Shannon Eldridge-Kuehn
        Must be run from an elevated session. Requires cscript.exe and
        slmgr.vbs, both present by default on Windows Server.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$ActivationID,

        [Parameter()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    $scriptBlock = {
        param($ActivationID)

        $arguments = if ($ActivationID) {
            "C:\Windows\System32\slmgr.vbs /dlv $ActivationID"
        }
        else {
            "C:\Windows\System32\slmgr.vbs /dlv"
        }

        $output = cscript.exe //NoLogo $arguments.Split(' ', 2)[1]

        [PSCustomObject]@{
            ComputerName  = $env:COMPUTERNAME
            Licensed      = ($output -match 'License Status:\s*Licensed') -as [bool]
            RawOutput     = $output -join "`n"
        }
    }

    foreach ($computer in $ComputerName) {
        Write-Verbose "Checking ESU license status on $computer."

        try {
            if ($computer -eq $env:COMPUTERNAME) {
                & $scriptBlock $ActivationID
            }
            else {
                Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ArgumentList $ActivationID -ErrorAction Stop
            }
        }
        catch {
            Write-Warning "Could not check ESU status on $computer : $($_.Exception.Message)"
        }
    }
}
