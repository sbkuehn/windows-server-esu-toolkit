<#
    Example-Usage.ps1

    Runnable example chaining discovery into a license status check across a
    fleet, and exporting the combined result. Matches the workflow described
    in the "Ragnarok for Windows Server" post: find what's exposed, then
    verify what's actually licensed.

    Run from an elevated session with the ActiveDirectory module available.
#>

Import-Module (Join-Path $PSScriptRoot '..\WindowsServerESUToolkit.psd1') -Force

# Step 1: find every Server 2012/2012 R2/2016 machine in the domain
Write-Host "Running domain discovery..." -ForegroundColor Cyan
$exposedServers = Get-ESUExposureReport -Scope Domain

if (-not $exposedServers) {
    Write-Host "No Server 2012/2016 machines found in AD. Nothing further to check." -ForegroundColor Green
    return
}

Write-Host "Found $($exposedServers.Count) server(s) at risk. Checking ESU license status..." -ForegroundColor Cyan

# Step 2: check ESU license status on each one found
$results = foreach ($server in $exposedServers) {
    Test-ESULicenseStatus -ComputerName $server.Name |
        Select-Object *, @{Name = 'OperatingSystem'; Expression = { $server.OperatingSystem } }
}

# Step 3: export a combined report
$outputPath = Join-Path $PSScriptRoot 'esu-status-report.csv'
$results | Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "Report written to $outputPath" -ForegroundColor Green
$results | Format-Table ComputerName, OperatingSystem, Licensed -AutoSize
