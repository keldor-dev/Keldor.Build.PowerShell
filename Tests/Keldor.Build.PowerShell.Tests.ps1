BeforeAll {
    $RepoRoot = Join-Path -Path $PSScriptRoot -ChildPath '..'
    $ManifestPath = Join-Path -Path $RepoRoot -ChildPath 'Keldor.Build.PowerShell.psd1'

    Import-Module $ManifestPath -Force

    function New-KeldorBuildTestRepository {
        param(
            [Parameter(Mandatory)]
            [string]$Path
        )

        $SourcePath = Join-Path -Path $Path -ChildPath 'src/TestModule'
        $PublicPath = Join-Path -Path $SourcePath -ChildPath 'Public'
        $PrivatePath = Join-Path -Path $SourcePath -ChildPath 'Private'
        $TestsPath = Join-Path -Path $SourcePath -ChildPath 'Tests'

        New-Item -Path $PublicPath -ItemType Directory -Force | Out-Null
        New-Item -Path $PrivatePath -ItemType Directory -Force | Out-Null
        New-Item -Path $TestsPath -ItemType Directory -Force | Out-Null

        Set-Content -LiteralPath (Join-Path $SourcePath 'TestModule.psm1') -Value ''
        Set-Content -LiteralPath (Join-Path $PublicPath 'Get-TestValue.ps1') -Value 'function Get-TestValue { 42 }'
        Set-Content -LiteralPath (Join-Path $PrivatePath 'Get-PrivateValue.ps1') -Value 'function Get-PrivateValue { 7 }'
        Set-Content -LiteralPath (Join-Path $TestsPath 'Package.Tests.ps1') -Value "Describe 'Package' { It 'exists' { `$true | Should -BeTrue } }"
        Set-Content -LiteralPath (Join-Path $SourcePath '.DS_Store') -Value 'not package content'
        Set-Content -LiteralPath (Join-Path $SourcePath 'TestModule.psd1') -Value @'
@{
    RootModule = 'TestModule.psm1'
    ModuleVersion = '1.2.3'
    GUID = 'b7c9f374-f4de-4e9b-9828-55d8953c5eb5'
    Author = 'Test'
    Description = 'Test module.'
    PowerShellVersion = '5.1'
    FunctionsToExport = '*'
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            # Prerelease = ''
        }
    }
}
'@
        Set-Content -LiteralPath (Join-Path $Path 'build.config.psd1') -Value @'
@{
    ModuleName = 'TestModule'
    SourcePath = 'src/TestModule'
    ManifestPath = 'src/TestModule/TestModule.psd1'
    TestPath = 'src/TestModule/Tests'
    OutputPath = 'out'
    RequiredPowerShellVersion = '5.1'
    ExpectedManifestVersion = '1.2.3'
    ExcludedPaths = @('Tests', '.DS_Store')
}
'@

        Join-Path -Path $Path -ChildPath 'build.config.psd1'
    }
}

Describe 'Keldor.Build.PowerShell module' {
    It 'imports successfully' {
        Get-Module -Name Keldor.Build.PowerShell | Should -Not -BeNullOrEmpty
    }

    It 'exports only the expected public commands' {
        $Commands = Get-Command -Module Keldor.Build.PowerShell | Select-Object -ExpandProperty Name

        $Commands | Should -Contain 'Clear-KeldorPowerShellBuild'
        $Commands | Should -Contain 'Invoke-KeldorPowerShellBuild'
        $Commands | Should -Contain 'Invoke-KeldorPowerShellProjectTests'
        $Commands | Should -Contain 'Publish-KeldorPowerShellProject'
        $Commands | Should -Contain 'Register-KeldorPowerShellBuildProvider'
        $Commands | Should -Contain 'Resolve-KeldorPowerShellProject'
        $Commands | Should -Contain 'Test-KeldorPowerShellBuildConfiguration'
        $Commands | Should -Contain 'Test-KeldorPowerShellProject'
        $Commands | Should -Not -Contain 'Resolve-KeldorPowerShellBuildConfiguration'
        $Commands | Should -Not -Contain 'Update-KeldorPowerShellManifestVersion'
    }

    It 'resolves this repository as a PowerShell module project' {
        $Project = Resolve-KeldorPowerShellProject -Path (Join-Path -Path $PSScriptRoot -ChildPath '..')

        $Project.Name | Should -Be 'Keldor.Build.PowerShell'
        $Project.ProjectType | Should -Be 'PowerShellModule'
        $Project.ManifestPath | Should -Match 'Keldor.Build.PowerShell.psd1'
    }
}

Describe 'Repository build configuration' {
    BeforeEach {
        $TestRepository = Join-Path -Path $TestDrive -ChildPath "repository with spaces $([guid]::NewGuid())"
        New-Item -Path $TestRepository -ItemType Directory -Force | Out-Null
        $ConfigurationPath = New-KeldorBuildTestRepository -Path $TestRepository
    }

    It 'validates and resolves relative paths from the repository root' {
        $Configuration = Test-KeldorPowerShellBuildConfiguration -ConfigurationPath $ConfigurationPath

        $Configuration.PSTypeNames | Should -Contain 'Keldor.Build.PowerShell.Configuration'
        $Configuration.ModuleName | Should -Be 'TestModule'
        $Configuration.RepositoryRoot | Should -Be $TestRepository
        $Configuration.SourcePath | Should -Be (Join-Path $TestRepository 'src/TestModule')
        $Configuration.OutputPath | Should -Be (Join-Path $TestRepository 'out')
    }

    It 'rejects unknown keys' {
        Add-Content -LiteralPath $ConfigurationPath -Value "`n# invalid replacement marker"
        $Content = Get-Content -LiteralPath $ConfigurationPath -Raw
        $Content = $Content -replace "(?m)^}$", "    Secret = 'value'`n}"
        Set-Content -LiteralPath $ConfigurationPath -Value $Content

        { Test-KeldorPowerShellBuildConfiguration -ConfigurationPath $ConfigurationPath } |
            Should -Throw "*unknown key 'Secret'*"
    }

    It 'rejects absolute and repository-escaping paths' {
        $Content = Get-Content -LiteralPath $ConfigurationPath -Raw
        $Content = $Content -replace "SourcePath = 'src/TestModule'", "SourcePath = '../outside'"
        Set-Content -LiteralPath $ConfigurationPath -Value $Content

        { Test-KeldorPowerShellBuildConfiguration -ConfigurationPath $ConfigurationPath } |
            Should -Throw '*outside repository root*'
    }

    It 'rejects invalid semantic versions' {
        $Content = Get-Content -LiteralPath $ConfigurationPath -Raw
        $Content = $Content -replace "ExpectedManifestVersion = '1.2.3'", "ExpectedManifestVersion = 'latest'"
        Set-Content -LiteralPath $ConfigurationPath -Value $Content

        { Test-KeldorPowerShellBuildConfiguration -ConfigurationPath $ConfigurationPath } |
            Should -Throw '*not a valid semantic version*'
    }
}

Describe 'Configuration-driven repository builds' {
    BeforeEach {
        $TestRepository = Join-Path -Path $TestDrive -ChildPath "repository with spaces $([guid]::NewGuid())"
        New-Item -Path $TestRepository -ItemType Directory -Force | Out-Null
        $ConfigurationPath = New-KeldorBuildTestRepository -Path $TestRepository
        $OriginalLocation = (Get-Location).Path
    }

    AfterEach {
        Set-Location -LiteralPath $OriginalLocation
    }

    It 'validates a configured manifest and returns structured output' {
        $Result = Invoke-KeldorPowerShellBuild -ConfigurationPath $ConfigurationPath -Task Validate

        $Result.PSTypeNames | Should -Contain 'Keldor.Build.PowerShell.ValidationResult'
        $Result.ModuleName | Should -Be 'TestModule'
        $Result.ModuleVersion | Should -Be '1.2.3'
        $Result.Succeeded | Should -BeTrue
    }

    It 'stages the module, writes explicit exports, and excludes build-only content' {
        $Result = Invoke-KeldorPowerShellBuild -ConfigurationPath $ConfigurationPath -Task Build
        $ManifestContent = Get-Content -LiteralPath $Result.ManifestPath -Raw

        $Result.PSTypeNames | Should -Contain 'Keldor.Build.PowerShell.BuildResult'
        $Result.OutputPath | Should -Be (Join-Path $TestRepository 'out/TestModule')
        $ManifestContent | Should -Match "'Get-TestValue'"
        $ManifestContent | Should -Not -Match "FunctionsToExport\s*=\s*'\*'"
        Test-Path -LiteralPath (Join-Path $Result.OutputPath 'Tests') | Should -BeFalse
        Test-Path -LiteralPath (Join-Path $Result.OutputPath '.DS_Store') | Should -BeFalse
        (Get-Location).Path | Should -Be $OriginalLocation
    }

    It 'creates a release artifact without changing the source manifest' {
        $SourceManifest = Join-Path $TestRepository 'src/TestModule/TestModule.psd1'
        $SourceBefore = Get-Content -LiteralPath $SourceManifest -Raw
        $Result = Invoke-KeldorPowerShellBuild `
            -ConfigurationPath $ConfigurationPath `
            -Task Release `
            -Version '2.0.0-preview.1'

        $Result.ModuleVersion | Should -Be '2.0.0'
        (Get-Content -LiteralPath $Result.ManifestPath -Raw) | Should -Match "Prerelease = 'preview.1'"
        (Get-Content -LiteralPath $SourceManifest -Raw) | Should -BeExactly $SourceBefore
    }

    It 'requires a version for release tasks' {
        { Invoke-KeldorPowerShellBuild -ConfigurationPath $ConfigurationPath -Task Release } |
            Should -Throw '*requires -Version*'
    }

    It 'does not mutate output under WhatIf' {
        $Result = Invoke-KeldorPowerShellBuild -ConfigurationPath $ConfigurationPath -Task Build -WhatIf

        $Result.WhatIf | Should -BeTrue
        Test-Path -LiteralPath (Join-Path $TestRepository 'out') | Should -BeFalse
    }

    It 'replaces stale output deterministically' {
        $Result = Invoke-KeldorPowerShellBuild -ConfigurationPath $ConfigurationPath -Task Build
        Set-Content -LiteralPath (Join-Path $Result.OutputPath 'stale.txt') -Value 'stale'

        Invoke-KeldorPowerShellBuild -ConfigurationPath $ConfigurationPath -Task Build | Out-Null

        Test-Path -LiteralPath (Join-Path $Result.OutputPath 'stale.txt') | Should -BeFalse
    }

    It 'propagates publishing failures without returning or logging the API key' {
        Mock -CommandName Find-Module -ModuleName Keldor.Build.PowerShell -MockWith { $null }
        Mock -CommandName Publish-Module -ModuleName Keldor.Build.PowerShell -MockWith { throw 'feed unavailable' }

        $CaughtError = $null

        try {
            Invoke-KeldorPowerShellBuild `
                -ConfigurationPath $ConfigurationPath `
                -Task Publish `
                -Version '2.0.0' `
                -NuGetApiKey 'super-secret-value'
        } catch {
            $CaughtError = $_
        }

        $CaughtError | Should -Not -BeNullOrEmpty
        ($CaughtError | Out-String) | Should -Not -Match 'super-secret-value'
        ($CaughtError | Out-String) | Should -Match 'feed unavailable'
    }
}
