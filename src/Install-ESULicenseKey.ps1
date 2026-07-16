function Install-ESULicenseKey {
    <#
    .SYNOPSIS
        Installs and activates an ESU key using slmgr.vbs.

    .DESCRIPTION
        Wraps the install-then-activate pattern from the "Ragnarok for Windows
        Server" post: `slmgr.vbs /ipk <key>` followed by `slmgr.vbs /ato
        <ActivationID>`. This performs a real licensing change on the target
        machine, so it supports -WhatIf and will prompt for confirmation before
        running unless -Confirm:$false is passed.

    .PARAMETER LicenseKey
        The ESU Multiple Activation Key (MAK), matching the post's
        `slmgr.vbs /ipk <ESU-MAK-Key>` step.

    .PARAMETER ActivationID
        The ESU Activation ID for the program being activated, matching the
        post's `slmgr.vbs /ato <ActivationID>` step.

    .EXAMPLE
        Install-ESULicenseKey -LicenseKey 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' -ActivationID '12345678-abcd-1234-abcd-1234567890ab'

        Installs the key, then activates it, in that order, exactly as shown in
        the post.

    .EXAMPLE
        Install-ESULicenseKey -LicenseKey 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX' -ActivationID '12345678-abcd-1234-abcd-1234567890ab' -WhatIf

        Shows what would happen without installing or activating anything.

    .NOTES
        Author: Shannon Eldridge-Kuehn
        Must be run from an elevated session. This changes licensing state on
        the target machine, review the key and Activation ID carefully before
        confirming.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LicenseKey,

        [Parameter(Mandatory = $true)]
        [string]$ActivationID
    )

    if ($PSCmdlet.ShouldProcess($env:COMPUTERNAME, "Install and activate ESU key ending in '...$($LicenseKey.Substring($LicenseKey.Length - 5))'")) {

        Write-Verbose "Installing ESU key."
        try {
            cscript.exe //NoLogo C:\Windows\System32\slmgr.vbs /ipk $LicenseKey
        }
        catch {
            Write-Error "Key install failed: $($_.Exception.Message)"
            return
        }

        Write-Verbose "Activating ESU Activation ID $ActivationID."
        try {
            cscript.exe //NoLogo C:\Windows\System32\slmgr.vbs /ato $ActivationID
        }
        catch {
            Write-Error "Activation failed: $($_.Exception.Message)"
            return
        }

        Write-Verbose "Install and activation complete. Run Test-ESULicenseStatus to confirm License Status shows Licensed."
    }
}
