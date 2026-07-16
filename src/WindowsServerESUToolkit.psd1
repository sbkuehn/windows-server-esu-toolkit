@{
    RootModule        = 'WindowsServerESUToolkit.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a3f2c9de-6b1a-4e7f-9c2d-8e4f1b7a5d3c'
    Author            = 'Shannon Eldridge-Kuehn'
    CompanyName       = 'Cloudy Musings'
    Copyright         = '(c) Shannon Eldridge-Kuehn. Licensed under MIT.'
    Description       = 'Discovery and license verification tooling for Windows Server Extended Security Updates (ESU) planning. Companion code to the Cloudy Musings post "Ragnarok for Windows Server."'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')

    FunctionsToExport = @(
        'Get-ESUExposureReport',
        'Test-ESULicenseStatus',
        'Install-ESULicenseKey',
        'Test-AzureArcESUStatus'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('Windows Server', 'ESU', 'ExtendedSecurityUpdates', 'Licensing', 'AzureArc')
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            ProjectUri   = 'https://github.com/shankuehn/windows-server-esu-toolkit'
            ReleaseNotes = 'Initial release. Companion tooling for the Cloudy Musings post on Windows Server ESU. Mirrors the PowerShell in the post exactly, no additional functionality.'
        }
    }
}
