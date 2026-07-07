[CmdletBinding()]
param(
    [switch]$Test,
    [switch]$Analyze,
    [switch]$Clean
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ModuleManifest = Join-Path $RepoRoot 'Keldor.Build.PowerShell.psd1'

Import-Module $ModuleManifest -Force

if ($Analyze) {
    $AnalyzerCommand = Get-Command -Name Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue

    if (-not $AnalyzerCommand) {
        throw 'PSScriptAnalyzer is not available. Install the PSScriptAnalyzer module before running analysis.'
    }

    Invoke-ScriptAnalyzer -Path $RepoRoot -Recurse -Severity Warning,Error
}

Invoke-KeldorPowerShellBuild -Path $RepoRoot -Clean:$Clean -Test:$Test

Get-Module Keldor.Build.PowerShell
