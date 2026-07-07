function New-KeldorPowerShellProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [System.IO.FileInfo]$Manifest
    )

    $ManifestData = Test-ModuleManifest -Path $Manifest.FullName -ErrorAction Stop

    $Project = New-Object PSObject
    $Project | Add-Member -MemberType NoteProperty -Name PSTypeName -Value 'Keldor.Build.PowerShell.Project'
    $Project | Add-Member -MemberType NoteProperty -Name Name -Value $Manifest.BaseName
    $Project | Add-Member -MemberType NoteProperty -Name Path -Value $Path
    $Project | Add-Member -MemberType NoteProperty -Name ProjectType -Value 'PowerShellModule'
    $Project | Add-Member -MemberType NoteProperty -Name ProviderName -Value 'PowerShell'
    $Project | Add-Member -MemberType NoteProperty -Name ManifestPath -Value $Manifest.FullName
    $Project | Add-Member -MemberType NoteProperty -Name ModuleVersion -Value $ManifestData.Version
    $Project | Add-Member -MemberType NoteProperty -Name RootModule -Value $ManifestData.RootModule

    $Project
}
