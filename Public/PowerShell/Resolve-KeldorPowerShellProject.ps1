function Resolve-KeldorPowerShellProject {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path
    )

    $ResolvedPath = (Resolve-Path -Path $Path).Path
    $Manifest = Get-KeldorPowerShellManifest -Path $ResolvedPath

    if (-not $Manifest) {
        throw "Unable to resolve a PowerShell module project at '$ResolvedPath'. No module manifest was found."
    }

    New-KeldorPowerShellProject -Path $ResolvedPath -Manifest $Manifest
}
