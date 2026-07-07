function Invoke-KeldorPowerShellProjectTests {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path = (Get-Location).Path
    )

    $Project = Resolve-KeldorPowerShellProject -Path $Path
    $TestsPath = Join-Path -Path $Project.Path -ChildPath 'Tests'

    if (-not (Test-Path -Path $TestsPath)) {
        Write-Verbose "No Tests directory was found at '$TestsPath'."
        return $true
    }

    $PesterCommand = Get-Command -Name Invoke-Pester -ErrorAction SilentlyContinue

    if (-not $PesterCommand) {
        throw 'Pester is not available. Install the Pester module before running project tests.'
    }

    Invoke-Pester -Path $TestsPath
}
