# Keldor.Build.PowerShell

PowerShell build toolkit for the Keldor ecosystem.

`Keldor.Build.PowerShell` is the authoritative place for PowerShell-specific project detection, validation, build, test, clean, packaging, and publishing behavior.

It can integrate with the generic `Keldor.Build` orchestration layer, but it does not depend on it for normal PowerShell module workflows.

## Purpose

This module standardizes how Keldor PowerShell projects are handled across repositories.

It focuses on:

- PowerShell module discovery
- Manifest validation
- Script analysis
- Pester test execution
- Build output creation
- Optional publishing workflows
- Cross-platform PowerShell development
- Backwards-compatible PowerShell where practical
- Future enforcement of Keldor PowerShell engineering standards

## Relationship to Keldor.Build

`Keldor.Build` should remain language-agnostic.

`Keldor.Build.PowerShell` owns the PowerShell-specific behavior and can register itself as a provider with the generic orchestration module.

```text
Keldor.Build
└── Keldor.Build.PowerShell
```

Future language-specific build toolkits should follow the same pattern:

- `Keldor.Build.Python`
- `Keldor.Build.DotNet`
- `Keldor.Build.Node`
- `Keldor.Build.Go`

## Commands

```powershell
Register-KeldorPowerShellBuildProvider
Resolve-KeldorPowerShellProject
Test-KeldorPowerShellProject
Invoke-KeldorPowerShellBuild
Invoke-KeldorPowerShellProjectTests
Clear-KeldorPowerShellBuild
Publish-KeldorPowerShellProject
```

## Example

```powershell
Import-Module ./Keldor.Build.PowerShell.psd1 -Force

Resolve-KeldorPowerShellProject -Path .
Test-KeldorPowerShellProject -Path . -Analyze
Invoke-KeldorPowerShellBuild -Path . -Clean -Test
```

## Local Development

```powershell
./build/build.ps1 -Clean -Analyze -Test
```

## Keldor Standards

This repository targets the Keldor engineering standards:

- [Keldor General Engineering Standard](https://github.com/keldor-dev/Keldor/blob/main/docs/standards/Keldor_General_Engineering_Standard.md)
- [Keldor PowerShell Engineering Standard](https://github.com/keldor-dev/Keldor/blob/main/docs/standards/Keldor_PowerShell_Engineering_Standard.md)

`Keldor.Build.PowerShell` should eventually provide the validation commands that enforce those standards in CI and local builds.

## Documentation

- [Architecture](docs/architecture.md)
- [Commands](docs/commands.md)
- [Development and Security Standards](docs/development-security-standards.md)
- [PowerShell Provider](docs/powershell-provider.md)
- [Standards Alignment](docs/standards/Keldor_Build_PowerShell_Standard_Alignment.md)

## Compatibility Goals

Keldor PowerShell code should support:

- PowerShell 7+ as the preferred runtime
- Windows PowerShell 5.1 where practical
- PowerShell 2.0 compatibility where practical and safe
- Windows, macOS, and Linux where possible

Security and maintainability take priority over legacy compatibility when tradeoffs are unavoidable.

## Security Standards

Development should align with applicable guidance from:

- NIST SP 800-53
- NIST Secure Software Development Framework
- DoD cybersecurity expectations
- DISA STIG principles where applicable

This repository should avoid hardcoded secrets, unsafe command execution, and platform-specific assumptions unless clearly documented.
