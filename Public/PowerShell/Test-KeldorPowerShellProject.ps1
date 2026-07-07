function Test-KeldorPowerShellProject {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path,

        [Parameter()]
        [switch]$Analyze
    )

    $Project = Resolve-KeldorPowerShellProject -Path $Path

    Test-ModuleManifest -Path $Project.ManifestPath -ErrorAction Stop | Out-Null

    if ($Analyze) {
        $AnalyzerCommand = Get-Command -Name Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue

        if (-not $AnalyzerCommand) {
            throw 'PSScriptAnalyzer is not available. Install the PSScriptAnalyzer module or run without -Analyze.'
        }

        Invoke-ScriptAnalyzer -Path $Project.Path -Recurse -Severity Warning,Error
    }

    $true
}
