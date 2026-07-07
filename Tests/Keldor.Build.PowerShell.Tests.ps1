BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..' 'Keldor.Build.PowerShell.psd1') -Force
}

Describe 'Keldor.Build.PowerShell' {
    It 'imports successfully' {
        Get-Module Keldor.Build.PowerShell | Should -Not -BeNullOrEmpty
    }

    It 'exports expected commands' {
        $Commands = Get-Command -Module Keldor.Build.PowerShell | Select-Object -ExpandProperty Name

        $Commands | Should -Contain 'Register-KeldorPowerShellBuildProvider'
        $Commands | Should -Contain 'Resolve-KeldorPowerShellProject'
        $Commands | Should -Contain 'Test-KeldorPowerShellProject'
        $Commands | Should -Contain 'Invoke-KeldorPowerShellBuild'
    }

    It 'resolves this repository as a PowerShell project' {
        $Project = Resolve-KeldorPowerShellProject -Path (Join-Path $PSScriptRoot '..')

        $Project.Name | Should -Be 'Keldor.Build.PowerShell'
        $Project.ProjectType | Should -Be 'PowerShellModule'
    }
}
