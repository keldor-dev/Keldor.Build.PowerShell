function Test-KeldorPowerShellSemanticVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    $Pattern = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9A-Za-z-][0-9A-Za-z-]*)(?:\.(?:0|[1-9A-Za-z-][0-9A-Za-z-]*))*))?$'
    $Version -match $Pattern
}

function Split-KeldorPowerShellSemanticVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Version
    )

    if (-not (Test-KeldorPowerShellSemanticVersion -Version $Version)) {
        throw "Version '$Version' is not a valid semantic version. Use MAJOR.MINOR.PATCH or MAJOR.MINOR.PATCH-prerelease."
    }

    $Parts = $Version -split '-', 2

    [pscustomobject]@{
        ModuleVersion = $Parts[0]
        Prerelease = if ($Parts.Count -gt 1) { $Parts[1] } else { $null }
    }
}

function Update-KeldorPowerShellManifestVersion {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [Parameter(Mandatory)]
        [string]$Version
    )

    $VersionParts = Split-KeldorPowerShellSemanticVersion -Version $Version
    $Content = Get-Content -LiteralPath $ManifestPath -Raw
    $UpdatedContent = $Content -replace "(?m)^(\s*ModuleVersion\s*=\s*)'[^']+'", "`$1'$($VersionParts.ModuleVersion)'"

    if ($VersionParts.Prerelease) {
        if ($UpdatedContent -match "(?m)^\s*#\s*Prerelease\s*=\s*''") {
            $UpdatedContent = $UpdatedContent -replace "(?m)^(\s*)#\s*Prerelease\s*=\s*''", "`$1Prerelease = '$($VersionParts.Prerelease)'"
        }
        elseif ($UpdatedContent -match '(?m)^\s*Prerelease\s*=') {
            $UpdatedContent = $UpdatedContent -replace "(?m)^(\s*Prerelease\s*=\s*)'[^']*'", "`$1'$($VersionParts.Prerelease)'"
        }
        else {
            throw "Manifest '$ManifestPath' does not define a Prerelease placeholder in PrivateData.PSData."
        }
    }
    else {
        $UpdatedContent = $UpdatedContent -replace "(?m)^(\s*)Prerelease\s*=\s*'[^']*'", "`$1# Prerelease = ''"
    }

    if ($PSCmdlet.ShouldProcess($ManifestPath, "Update module manifest version to '$Version'")) {
        Set-Content -LiteralPath $ManifestPath -Value $UpdatedContent -NoNewline -Encoding utf8
    }
}

function Test-KeldorPowerShellManifestVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath,

        [Parameter()]
        [string]$ExpectedVersion
    )

    $Manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
    $ManifestVersion = $Manifest.Version.ToString()

    if (-not (Test-KeldorPowerShellSemanticVersion -Version $ManifestVersion)) {
        throw "Manifest version '$ManifestVersion' is not a valid semantic version."
    }

    if ($ExpectedVersion) {
        $ExpectedVersionParts = Split-KeldorPowerShellSemanticVersion -Version $ExpectedVersion

        if ($ManifestVersion -ne $ExpectedVersionParts.ModuleVersion) {
            throw "Manifest version '$ManifestVersion' does not match expected version '$($ExpectedVersionParts.ModuleVersion)'."
        }
    }

    $Manifest
}

function Update-KeldorPowerShellManifestExports {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$SourceModulePath,

        [Parameter(Mandatory)]
        [string]$ManifestPath
    )

    $PublicPath = Join-Path -Path $SourceModulePath -ChildPath 'Public'
    $FunctionNames = @(
        Get-ChildItem -LiteralPath $PublicPath -Filter '*.ps1' -File -Recurse -ErrorAction Stop |
            Select-Object -ExpandProperty BaseName |
            Sort-Object -Unique
    )
    $ExportLines = @($FunctionNames | ForEach-Object { "        '$_'" })
    $Replacement = "    FunctionsToExport = @(`n" + ($ExportLines -join "`n") + "`n    )"
    $Content = Get-Content -LiteralPath $ManifestPath -Raw
    $UpdatedContent = [regex]::Replace($Content, "(?m)^\s*FunctionsToExport\s*=\s*'\*'\s*$", $Replacement)

    if ($UpdatedContent -eq $Content) {
        throw "Could not replace the development FunctionsToExport wildcard in '$ManifestPath'."
    }

    if ($PSCmdlet.ShouldProcess($ManifestPath, 'Write explicit function exports')) {
        Set-Content -LiteralPath $ManifestPath -Value $UpdatedContent -NoNewline -Encoding utf8
    }
}
