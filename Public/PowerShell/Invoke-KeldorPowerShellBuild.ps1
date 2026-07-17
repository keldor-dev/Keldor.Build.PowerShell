function Invoke-KeldorPowerShellBuild {
    [CmdletBinding(DefaultParameterSetName = 'Project', SupportsShouldProcess)]
    param(
        [Parameter(Position = 0, ParameterSetName = 'Project')]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path,

        [Parameter(Mandatory, ParameterSetName = 'Configuration')]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationPath,

        [Parameter(ParameterSetName = 'Configuration')]
        [ValidateSet('Validate', 'Build', 'Release', 'Publish')]
        [string]$Task = 'Build',

        [Parameter(ParameterSetName = 'Configuration')]
        [string]$Version,

        [Parameter(ParameterSetName = 'Configuration')]
        [string]$Repository = 'PSGallery',

        [Parameter(ParameterSetName = 'Configuration')]
        [string]$NuGetApiKey,

        [Parameter(ParameterSetName = 'Project')]
        [switch]$Clean,

        [Parameter(ParameterSetName = 'Project')]
        [switch]$Test,

        [Parameter(ParameterSetName = 'Project')]
        [string]$OutputPath
    )

    if ($PSCmdlet.ParameterSetName -eq 'Configuration') {
        $Configuration = Resolve-KeldorPowerShellBuildConfiguration -ConfigurationPath $ConfigurationPath

        return Invoke-KeldorPowerShellRepositoryBuild `
            -Configuration $Configuration `
            -Task $Task `
            -Version $Version `
            -Repository $Repository `
            -NuGetApiKey $NuGetApiKey `
            -WhatIf:$WhatIfPreference `
            -Confirm:$false
    }

    $Project = Resolve-KeldorPowerShellProject -Path $Path

    if ($Clean) {
        Clear-KeldorPowerShellBuild -Path $Project.Path
    }

    if (-not $OutputPath) {
        $OutputPath = Join-Path -Path $Project.Path -ChildPath 'artifacts'
    }

    $ModuleOutputPath = Join-Path -Path $OutputPath -ChildPath $Project.Name

    if (-not $PSCmdlet.ShouldProcess($ModuleOutputPath, 'Create PowerShell module build artifact')) {
        return
    }

    if (-not (Test-Path -Path $ModuleOutputPath)) {
        New-Item -Path $ModuleOutputPath -ItemType Directory -Force | Out-Null
    }

    $ItemsToCopy = Get-ChildItem -Path $Project.Path |
        Where-Object {
            -not $_.PSIsContainer -and
            $_.Name -match '\.(psd1|psm1|ps1xml)$'
        }

    foreach ($Item in $ItemsToCopy) {
        Copy-Item -Path $Item.FullName -Destination $ModuleOutputPath -Force
    }

    foreach ($DirectoryName in @('Public', 'Private', 'Classes', 'Formats', 'Types', 'en-US')) {
        $DirectoryPath = Join-Path -Path $Project.Path -ChildPath $DirectoryName

        if (Test-Path -Path $DirectoryPath) {
            Copy-Item -Path $DirectoryPath -Destination $ModuleOutputPath -Recurse -Force
        }
    }

    if ($Test) {
        Invoke-KeldorPowerShellProjectTests -Path $Project.Path
    }

    $Result = New-Object PSObject
    $Result | Add-Member -MemberType NoteProperty -Name PSTypeName -Value 'Keldor.Build.PowerShell.BuildResult'
    $Result | Add-Member -MemberType NoteProperty -Name Name -Value $Project.Name
    $Result | Add-Member -MemberType NoteProperty -Name SourcePath -Value $Project.Path
    $Result | Add-Member -MemberType NoteProperty -Name OutputPath -Value $ModuleOutputPath
    $Result | Add-Member -MemberType NoteProperty -Name ModuleVersion -Value $Project.ModuleVersion

    $Result
}
