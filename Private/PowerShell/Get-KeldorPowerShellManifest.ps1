function Get-KeldorPowerShellManifest {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path
    )

    $ResolvedPath = (Resolve-Path -Path $Path).Path

    if (-not (Test-Path -Path $ResolvedPath -PathType Container)) {
        throw "Path '$ResolvedPath' is not a directory."
    }

    $Manifests = Get-ChildItem -Path $ResolvedPath -Filter '*.psd1' |
        Where-Object { -not $_.PSIsContainer }

    if (-not $Manifests) {
        return $null
    }

    if ($Manifests.Count -gt 1) {
        $RootNamedManifest = $Manifests | Where-Object { $_.BaseName -eq (Split-Path -Path $ResolvedPath -Leaf) } | Select-Object -First 1

        if ($RootNamedManifest) {
            return $RootNamedManifest
        }

        throw "Multiple PowerShell module manifests were found in '$ResolvedPath'. Unable to determine the primary manifest."
    }

    $Manifests | Select-Object -First 1
}
