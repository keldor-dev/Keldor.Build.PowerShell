function Test-KeldorPowerShellBuildConfiguration {
    <#
    .SYNOPSIS
        Validates a repository build configuration.

    .DESCRIPTION
        Loads an inert PowerShell data file, validates its keys and paths, and returns a normalized configuration
        object. No build output is created.

    .PARAMETER ConfigurationPath
        Specifies the repository-relative build configuration data file to validate.

    .EXAMPLE
        Test-KeldorPowerShellBuildConfiguration -ConfigurationPath ./build.config.psd1

    .OUTPUTS
        Keldor.Build.PowerShell.Configuration
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationPath
    )

    Resolve-KeldorPowerShellBuildConfiguration -ConfigurationPath $ConfigurationPath
}
