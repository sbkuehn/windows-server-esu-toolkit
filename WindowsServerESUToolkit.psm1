#Requires -Version 5.1
<#
    WindowsServerESUToolkit.psm1
    Loads all public functions for the module. Keep this file dumb on purpose,
    logic belongs in the individual function files under src/Public so each
    one stays independently testable.
#>

$publicFunctionPath = Join-Path -Path $PSScriptRoot -ChildPath 'src\Public'

if (Test-Path -Path $publicFunctionPath) {
    $publicFunctions = Get-ChildItem -Path $publicFunctionPath -Filter '*.ps1' -File -ErrorAction SilentlyContinue

    foreach ($function in $publicFunctions) {
        try {
            . $function.FullName
        }
        catch {
            Write-Error -Message "Failed to import function file '$($function.FullName)': $($_.Exception.Message)"
        }
    }

    Export-ModuleMember -Function $publicFunctions.BaseName
}
else {
    Write-Warning "Public function path not found at '$publicFunctionPath'. Module loaded with no functions."
}
