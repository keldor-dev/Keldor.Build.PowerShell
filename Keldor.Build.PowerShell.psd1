@{
    RootModule        = 'Keldor.Build.PowerShell.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'f31a97d9-4d1d-4d1f-8e2c-7c317a16c3bb'
    Author            = 'Keldor Dev'
    CompanyName       = 'Keldor'
    Copyright         = '(c) Keldor Dev. All rights reserved.'
    Description       = 'PowerShell build provider for the Keldor ecosystem.'
    PowerShellVersion = '2.0'
    FunctionsToExport = @(
        'Clear-KeldorPowerShellBuild',
        'Invoke-KeldorPowerShellBuild',
        'Invoke-KeldorPowerShellProjectTests',
        'Publish-KeldorPowerShellProject',
        'Register-KeldorPowerShellBuildProvider',
        'Resolve-KeldorPowerShellProject',
        'Test-KeldorPowerShellProject'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags         = @('Keldor', 'Build', 'PowerShell', 'Automation', 'DevOps')
            LicenseUri   = 'https://github.com/keldor-dev/Keldor.Build.PowerShell/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/keldor-dev/Keldor.Build.PowerShell'
            ReleaseNotes = 'Initial scaffold for Keldor.Build.PowerShell.'
        }
    }
}
