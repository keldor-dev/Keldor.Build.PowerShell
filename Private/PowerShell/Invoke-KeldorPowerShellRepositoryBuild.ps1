function Invoke-KeldorPowerShellRepositoryBuild {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [psobject]$Configuration,

        [Parameter(Mandatory)]
        [ValidateSet('Validate', 'Build', 'Release', 'Publish')]
        [string]$Task,

        [Parameter()]
        [string]$Version,

        [Parameter()]
        [string]$Repository = 'PSGallery',

        [Parameter()]
        [string]$NuGetApiKey
    )

    $ExpectedVersion = $Configuration.ExpectedManifestVersion

    if ($Task -eq 'Validate') {
        $Manifest = Test-KeldorPowerShellManifestVersion `
            -ManifestPath $Configuration.ManifestPath `
            -ExpectedVersion $ExpectedVersion

        return [pscustomobject]@{
            PSTypeName = 'Keldor.Build.PowerShell.ValidationResult'
            Task = $Task
            ModuleName = $Configuration.ModuleName
            ManifestPath = $Configuration.ManifestPath
            ModuleVersion = $Manifest.Version.ToString()
            Succeeded = $true
        }
    }

    if (($Task -eq 'Release' -or $Task -eq 'Publish') -and -not $Version) {
        throw "$Task requires -Version."
    }

    $VersionParts = $null

    if ($Version) {
        $VersionParts = Split-KeldorPowerShellSemanticVersion -Version $Version
    }

    $ModuleOutputPath = Join-Path -Path $Configuration.OutputPath -ChildPath $Configuration.ModuleName
    $RelativeManifestPath = $Configuration.ManifestPath.Substring($Configuration.SourcePath.Length).TrimStart(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
    $OutputManifestPath = Join-Path -Path $ModuleOutputPath -ChildPath $RelativeManifestPath

    if ($Task -eq 'Publish') {
        $Latest = Find-Module -Name $Configuration.ModuleName -Repository $Repository -ErrorAction SilentlyContinue

        if ($Latest -and [version]$VersionParts.ModuleVersion -le [version]$Latest.Version) {
            throw "Requested version '$Version' must be greater than latest '$($Latest.Version)' in repository '$Repository'."
        }
    }

    $Action = if ($Task -eq 'Publish') { 'Build release artifact and publish module' } else { "Create $Task artifact" }

    if (-not $PSCmdlet.ShouldProcess($ModuleOutputPath, $Action)) {
        return [pscustomobject]@{
            PSTypeName = 'Keldor.Build.PowerShell.BuildResult'
            Task = $Task
            Name = $Configuration.ModuleName
            SourcePath = $Configuration.SourcePath
            OutputPath = $ModuleOutputPath
            ModuleVersion = if ($VersionParts) { $VersionParts.ModuleVersion } else { $ExpectedVersion }
            Published = $false
            WhatIf = $true
        }
    }

    Test-KeldorPowerShellManifestVersion -ManifestPath $Configuration.ManifestPath -ExpectedVersion $ExpectedVersion | Out-Null

    if (Test-Path -LiteralPath $ModuleOutputPath) {
        Remove-Item -LiteralPath $ModuleOutputPath -Recurse -Force -ErrorAction Stop
    }

    $OutputRoot = Split-Path -Parent $ModuleOutputPath
    New-Item -Path $OutputRoot -ItemType Directory -Force -ErrorAction Stop | Out-Null
    Copy-Item -LiteralPath $Configuration.SourcePath -Destination $ModuleOutputPath -Recurse -Force -ErrorAction Stop

    foreach ($ExcludedPath in $Configuration.ExcludedPaths) {
        $ExcludedOutputPath = Join-Path -Path $ModuleOutputPath -ChildPath $ExcludedPath

        if (Test-Path -LiteralPath $ExcludedOutputPath) {
            Remove-Item -LiteralPath $ExcludedOutputPath -Recurse -Force -ErrorAction Stop
        }
    }

    Update-KeldorPowerShellManifestExports `
        -SourceModulePath $Configuration.SourcePath `
        -ManifestPath $OutputManifestPath `
        -Confirm:$false

    if ($Task -eq 'Release' -or $Task -eq 'Publish') {
        Update-KeldorPowerShellManifestVersion `
            -ManifestPath $OutputManifestPath `
            -Version $Version `
            -Confirm:$false
    }

    $OutputManifest = Test-KeldorPowerShellManifestVersion `
        -ManifestPath $OutputManifestPath `
        -ExpectedVersion $(if ($VersionParts) { $VersionParts.ModuleVersion } else { $ExpectedVersion })

    $Published = $false

    if ($Task -eq 'Publish') {
        $PublishParameters = @{
            Path = $ModuleOutputPath
            Repository = $Repository
        }

        if ($NuGetApiKey) {
            $PublishParameters.NuGetApiKey = $NuGetApiKey
        }

        Publish-Module @PublishParameters -ErrorAction Stop
        $Published = $true
    }

    [pscustomobject]@{
        PSTypeName = 'Keldor.Build.PowerShell.BuildResult'
        Task = $Task
        Name = $Configuration.ModuleName
        SourcePath = $Configuration.SourcePath
        OutputPath = $ModuleOutputPath
        ManifestPath = $OutputManifestPath
        ModuleVersion = $OutputManifest.Version.ToString()
        Published = $Published
        WhatIf = $false
    }
}
