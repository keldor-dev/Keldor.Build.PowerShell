function Publish-KeldorPowerShellProject {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path,

        [Parameter()]
        [string]$Repository,

        [Parameter()]
        [string]$NuGetApiKey
    )

    $Project = Resolve-KeldorPowerShellProject -Path $Path

    $PublishCommand = Get-Command -Name Publish-Module -ErrorAction SilentlyContinue

    if (-not $PublishCommand) {
        throw 'Publish-Module is not available. Install PowerShellGet or publish manually.'
    }

    $PublishParameters = @{
        Path = $Project.Path
    }

    if ($Repository) {
        $PublishParameters.Repository = $Repository
    }

    if ($NuGetApiKey) {
        $PublishParameters.NuGetApiKey = $NuGetApiKey
    }

    if ($PSCmdlet.ShouldProcess($Project.Name, 'Publish PowerShell module')) {
        Publish-Module @PublishParameters
    }
}
