function Resolve-KeldorPowerShellBuildConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationPath
    )

    $ResolvedConfigurationPath = (Resolve-Path -LiteralPath $ConfigurationPath -ErrorAction Stop).Path

    if ([System.IO.Path]::GetExtension($ResolvedConfigurationPath) -ne '.psd1') {
        throw "Build configuration '$ResolvedConfigurationPath' must be a PowerShell data file (.psd1)."
    }

    $Configuration = Import-PowerShellDataFile -LiteralPath $ResolvedConfigurationPath -ErrorAction Stop
    $AllowedKeys = @(
        'AnalyzerSettingsPath',
        'ExpectedManifestVersion',
        'ExcludedPaths',
        'ManifestPath',
        'ModuleName',
        'OutputPath',
        'RequiredPowerShellVersion',
        'SourcePath',
        'TestPath'
    )
    $RequiredKeys = @('ManifestPath', 'ModuleName', 'OutputPath', 'SourcePath', 'TestPath')

    foreach ($Key in $Configuration.Keys) {
        if ($AllowedKeys -notcontains $Key) {
            throw "Build configuration contains unknown key '$Key'. Allowed keys: $($AllowedKeys -join ', ')."
        }
    }

    foreach ($Key in $RequiredKeys) {
        if (-not $Configuration.ContainsKey($Key) -or [string]::IsNullOrWhiteSpace([string]$Configuration[$Key])) {
            throw "Build configuration requires a non-empty '$Key' value."
        }
    }

    if ([string]$Configuration.ModuleName -notmatch '^[A-Za-z][A-Za-z0-9.-]*$') {
        throw "ModuleName '$($Configuration.ModuleName)' is not a valid PowerShell module name."
    }

    $RepositoryRoot = Split-Path -Parent $ResolvedConfigurationPath
    $PathKeys = @('AnalyzerSettingsPath', 'ManifestPath', 'OutputPath', 'SourcePath', 'TestPath')
    $ResolvedPaths = @{}

    foreach ($Key in $PathKeys) {
        if (-not $Configuration.ContainsKey($Key) -or [string]::IsNullOrWhiteSpace([string]$Configuration[$Key])) {
            continue
        }

        $RelativePath = [string]$Configuration[$Key]

        if ([System.IO.Path]::IsPathRooted($RelativePath)) {
            throw "Build configuration path '$Key' must be relative to the repository root."
        }

        $FullPath = [System.IO.Path]::GetFullPath((Join-Path -Path $RepositoryRoot -ChildPath $RelativePath))
        $RootPrefix = $RepositoryRoot.TrimEnd(
            [System.IO.Path]::DirectorySeparatorChar,
            [System.IO.Path]::AltDirectorySeparatorChar
        ) + [System.IO.Path]::DirectorySeparatorChar
        $Comparison = [System.StringComparison]::Ordinal

        if ($env:OS -eq 'Windows_NT') {
            $Comparison = [System.StringComparison]::OrdinalIgnoreCase
        }

        if (-not $FullPath.StartsWith($RootPrefix, $Comparison)) {
            throw "Build configuration path '$Key' resolves outside repository root '$RepositoryRoot'."
        }

        $ResolvedPaths[$Key] = $FullPath
    }

    if (-not (Test-Path -LiteralPath $ResolvedPaths.SourcePath -PathType Container)) {
        throw "Configured SourcePath '$($ResolvedPaths.SourcePath)' does not exist or is not a directory."
    }

    if (-not (Test-Path -LiteralPath $ResolvedPaths.ManifestPath -PathType Leaf)) {
        throw "Configured ManifestPath '$($ResolvedPaths.ManifestPath)' does not exist or is not a file."
    }

    $SourcePrefix = $ResolvedPaths.SourcePath.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar

    if (-not $ResolvedPaths.ManifestPath.StartsWith($SourcePrefix, $Comparison)) {
        throw 'ManifestPath must resolve beneath SourcePath so the manifest is included in build artifacts.'
    }

    if ($Configuration.RequiredPowerShellVersion) {
        try {
            [void][version]$Configuration.RequiredPowerShellVersion
        }
        catch {
            throw "RequiredPowerShellVersion '$($Configuration.RequiredPowerShellVersion)' is not a valid version."
        }
    }

    $Manifest = Test-ModuleManifest -Path $ResolvedPaths.ManifestPath -ErrorAction Stop

    if ($Manifest.Name -ne [string]$Configuration.ModuleName) {
        throw "ModuleName '$($Configuration.ModuleName)' does not match manifest name '$($Manifest.Name)'."
    }

    if ($Configuration.RequiredPowerShellVersion -and
        $Manifest.PowerShellVersion -lt [version]$Configuration.RequiredPowerShellVersion) {
        throw "Manifest PowerShellVersion '$($Manifest.PowerShellVersion)' is lower than configured requirement " +
        "'$($Configuration.RequiredPowerShellVersion)'."
    }

    if ($Configuration.ExpectedManifestVersion -and
        -not (Test-KeldorPowerShellSemanticVersion -Version $Configuration.ExpectedManifestVersion)) {
        throw "ExpectedManifestVersion '$($Configuration.ExpectedManifestVersion)' is not a valid semantic version."
    }

    $ExcludedPaths = @('.DS_Store')

    if ($Configuration.ContainsKey('ExcludedPaths')) {
        $ExcludedPaths = @($Configuration.ExcludedPaths)
    }

    foreach ($ExcludedPath in $ExcludedPaths) {
        if ([string]::IsNullOrWhiteSpace([string]$ExcludedPath) -or
            [System.IO.Path]::IsPathRooted([string]$ExcludedPath) -or
            [string]$ExcludedPath -match '(^|[\\/])\.\.([\\/]|$)') {
            throw "ExcludedPaths entry '$ExcludedPath' must be a safe path relative to SourcePath."
        }
    }

    [pscustomobject]@{
        PSTypeName = 'Keldor.Build.PowerShell.Configuration'
        AnalyzerSettingsPath = $ResolvedPaths.AnalyzerSettingsPath
        ConfigurationPath = $ResolvedConfigurationPath
        ExpectedManifestVersion = [string]$Configuration.ExpectedManifestVersion
        ExcludedPaths = $ExcludedPaths
        ManifestPath = $ResolvedPaths.ManifestPath
        ModuleName = [string]$Configuration.ModuleName
        OutputPath = $ResolvedPaths.OutputPath
        RepositoryRoot = $RepositoryRoot
        RequiredPowerShellVersion = [string]$Configuration.RequiredPowerShellVersion
        SourcePath = $ResolvedPaths.SourcePath
        TestPath = $ResolvedPaths.TestPath
    }
}
