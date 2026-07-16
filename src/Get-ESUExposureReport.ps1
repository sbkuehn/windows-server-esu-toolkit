function Get-ESUExposureReport {
    <#
    .SYNOPSIS
        Finds Windows Server machines at or approaching end of support.

    .DESCRIPTION
        Wraps the two discovery commands from the "Ragnarok for Windows Server" post:
        an Active Directory sweep for Server 2012 and 2016 machines, and a local
        Get-CimInstance check for the OS version and build on a single box.
        This function does not add scope beyond what's shown in the post, it's the
        same commands, made reusable and pipeline-friendly.

    .PARAMETER Scope
        'Domain' runs the Get-ADComputer sweep (requires the ActiveDirectory module).
        'Local' runs the Get-CimInstance check against the local machine only.
        Default is 'Domain'.

    .PARAMETER ComputerName
        Only used when -Scope Local. Target machine for the CIM check. Defaults to
        the local computer. Requires WinRM/CIM access to remote targets.

    .EXAMPLE
        Get-ESUExposureReport -Scope Domain

        Runs the AD sweep for every computer object with "2012" or "2016" in its
        OperatingSystem attribute, matching the query from the blog post exactly.

    .EXAMPLE
        Get-ESUExposureReport -Scope Local

        Returns Caption, Version, BuildNumber, and OSArchitecture for the local
        machine.

    .EXAMPLE
        Get-ESUExposureReport -Scope Local -ComputerName SQL01, SQL02 |
            Export-Csv -Path .\esu-exposure.csv -NoTypeInformation

        Runs the local-style CIM check against a short list of named servers and
        exports the results.

    .NOTES
        Author: Shannon Eldridge-Kuehn
        Requires the ActiveDirectory module for -Scope Domain.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('Domain', 'Local')]
        [string]$Scope = 'Domain',

        [Parameter()]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    switch ($Scope) {

        'Domain' {
            if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
                Write-Error "The ActiveDirectory module isn't available on this machine. Install RSAT, or run this from a domain-joined host that has it, then rerun with -Scope Domain."
                return
            }

            Import-Module ActiveDirectory -ErrorAction Stop

            Write-Verbose "Querying AD for computer objects with '2012' or '2016' in OperatingSystem."

            try {
                Get-ADComputer -Filter {
                    OperatingSystem -like "*2012*" -or
                    OperatingSystem -like "*2016*"
                } -Properties OperatingSystem, OperatingSystemVersion, LastLogonDate |
                    Select-Object Name, OperatingSystem, OperatingSystemVersion, LastLogonDate |
                    Sort-Object OperatingSystem
            }
            catch {
                Write-Error "AD query failed: $($_.Exception.Message)"
            }
        }

        'Local' {
            foreach ($computer in $ComputerName) {
                Write-Verbose "Checking OS details on $computer."
                try {
                    Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop |
                        Select-Object @{Name = 'ComputerName'; Expression = { $computer } },
                                      Caption, Version, BuildNumber, OSArchitecture
                }
                catch {
                    Write-Warning "Could not query $computer : $($_.Exception.Message)"
                }
            }
        }
    }
}
