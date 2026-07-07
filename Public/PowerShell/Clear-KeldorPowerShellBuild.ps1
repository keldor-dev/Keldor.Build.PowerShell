function Clear-KeldorPowerShellBuild {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path
    )

    $Project = Resolve-KeldorPowerShellProject -Path $Path

    $DefaultPaths = @(
        'out',
        'artifacts',
        'build/output'
    )

    foreach ($RelativePath in $DefaultPaths) {
        $Item = Join-Path -Path $Project.Path -ChildPath $RelativePath

        if (Test-Path -Path $Item) {
            if ($PSCmdlet.ShouldProcess($Item, 'Remove PowerShell build output')) {
                Remove-Item -Path $Item -Recurse -Force
            }
        }
    }
}
