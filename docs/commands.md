# Commands

## `Resolve-KeldorPowerShellProject`

Discovers a PowerShell module project from a repository path.

Detection is currently based on the presence of a PowerShell module manifest (`*.psd1`).

```powershell
Resolve-KeldorPowerShellProject -Path .
```

## `Test-KeldorPowerShellProject`

Validates the module manifest and optionally runs ScriptAnalyzer.

```powershell
Test-KeldorPowerShellProject -Path .
Test-KeldorPowerShellProject -Path . -Analyze
```

## `Invoke-KeldorPowerShellBuild`

Builds a PowerShell module project into an artifact directory.

```powershell
Invoke-KeldorPowerShellBuild -Path .
Invoke-KeldorPowerShellBuild -Path . -Clean -Test
Invoke-KeldorPowerShellBuild -ConfigurationPath ./build.config.psd1 -Task Build
Invoke-KeldorPowerShellBuild -ConfigurationPath ./build.config.psd1 -Task Release -Version '1.2.3'
```

The original flat-project parameter set remains supported. The configuration parameter set supports `Validate`,
`Build`, `Release`, and `Publish`, returns structured results, and honors `-WhatIf` for artifact and publishing changes.

## `Test-KeldorPowerShellBuildConfiguration`

Validates a repository build data file and returns normalized absolute paths without creating build output.

```powershell
Test-KeldorPowerShellBuildConfiguration -ConfigurationPath ./build.config.psd1
```

## `Invoke-KeldorPowerShellProjectTests`

Runs Pester tests from the project's `Tests` directory.

```powershell
Invoke-KeldorPowerShellProjectTests -Path .
```

## `Clear-KeldorPowerShellBuild`

Removes common PowerShell build output directories.

```powershell
Clear-KeldorPowerShellBuild -Path .
```

## `Publish-KeldorPowerShellProject`

Publishes a PowerShell module project using `Publish-Module`.

```powershell
Publish-KeldorPowerShellProject -Path . -Repository PSGallery -NuGetApiKey $env:PSGALLERY_API_KEY
```

## `Register-KeldorPowerShellBuildProvider`

Registers PowerShell build behavior with the generic `Keldor.Build` provider model when `Keldor.Build` is available.

```powershell
Import-Module Keldor.Build
Import-Module Keldor.Build.PowerShell
Register-KeldorPowerShellBuildProvider -Force
```
