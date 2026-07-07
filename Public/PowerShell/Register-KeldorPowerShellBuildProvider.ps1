function Register-KeldorPowerShellBuildProvider {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]$Force
    )

    $RegisterCommand = Get-Command -Name Register-KeldorBuildProvider -ErrorAction SilentlyContinue

    if (-not $RegisterCommand) {
        Write-Verbose 'Keldor.Build is not currently available. Skipping generic provider registration.'
        return $false
    }

    Register-KeldorBuildProvider -Name 'PowerShell' -ProjectType 'PowerShellModule' -Force:$Force -DetectionScript {
        param($Path)

        [bool](Get-ChildItem -Path $Path -Filter '*.psd1' -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer })
    } -ValidationScript {
        param($Project)

        Test-KeldorPowerShellProject -Path $Project.Path
    } -BuildScript {
        param($Project)

        Invoke-KeldorPowerShellBuild -Path $Project.Path
    } -TestScript {
        param($Project)

        Invoke-KeldorPowerShellProjectTests -Path $Project.Path
    } -CleanScript {
        param($Project)

        Clear-KeldorPowerShellBuild -Path $Project.Path
    } -PublishScript {
        param($Project, $Repository)

        Publish-KeldorPowerShellProject -Path $Project.Path -Repository $Repository
    }
}
