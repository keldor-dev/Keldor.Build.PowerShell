[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Clean,

    [Parameter()]
    [switch]$Test,

    [Parameter()]
    [switch]$Analyze
)

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ModuleManifest = Join-Path -Path $RepoRoot -ChildPath 'Keldor.Build.PowerShell.psd1'
$AnalyzerSettings = Join-Path -Path $RepoRoot -ChildPath 'PSScriptAnalyzerSettings.psd1'

Import-Module $ModuleManifest -Force

if ($Analyze) {
    $AnalyzerCommand = Get-Command -Name Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue

    if (-not $AnalyzerCommand) {
        throw 'PSScriptAnalyzer is not available. Install the PSScriptAnalyzer module before running analysis.'
    }

    Invoke-ScriptAnalyzer -Path $RepoRoot -Recurse -Settings $AnalyzerSettings
}

Invoke-KeldorPowerShellBuild -Path $RepoRoot -Clean:$Clean -Test:$Test

Get-Module Keldor.Build.PowerShell
