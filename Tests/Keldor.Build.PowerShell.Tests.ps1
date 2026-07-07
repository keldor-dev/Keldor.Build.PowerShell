BeforeAll {
    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath '..' | Join-Path -ChildPath 'Keldor.Build.PowerShell.psd1') -Force
}

Describe 'Keldor.Build.PowerShell' {
    It 'imports successfully' {
        Get-Module -Name Keldor.Build.PowerShell | Should -Not -BeNullOrEmpty
    }

    It 'exports expected commands' {
        $Commands = Get-Command -Module Keldor.Build.PowerShell | Select-Object -ExpandProperty Name

        $Commands | Should -Contain 'Clear-KeldorPowerShellBuild'
        $Commands | Should -Contain 'Invoke-KeldorPowerShellBuild'
        $Commands | Should -Contain 'Invoke-KeldorPowerShellProjectTests'
        $Commands | Should -Contain 'Publish-KeldorPowerShellProject'
        $Commands | Should -Contain 'Register-KeldorPowerShellBuildProvider'
        $Commands | Should -Contain 'Resolve-KeldorPowerShellProject'
        $Commands | Should -Contain 'Test-KeldorPowerShellProject'
    }

    It 'resolves this repository as a PowerShell module project' {
        $Project = Resolve-KeldorPowerShellProject -Path (Join-Path -Path $PSScriptRoot -ChildPath '..')

        $Project.Name | Should -Be 'Keldor.Build.PowerShell'
        $Project.ProjectType | Should -Be 'PowerShellModule'
        $Project.ManifestPath | Should -Match 'Keldor.Build.PowerShell.psd1'
    }
}
