# Keldor.Build.PowerShell

PowerShell build provider for the Keldor ecosystem.

`Keldor.Build.PowerShell` contains PowerShell-specific project detection, validation, build, test, clean, and publish behavior. It is intended to work with the generic `Keldor.Build` orchestration layer while still exposing direct commands for PowerShell module workflows.

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

## Relationship to Keldor.Build

`Keldor.Build` should remain language-agnostic.

`Keldor.Build.PowerShell` owns the PowerShell-specific behavior and can register itself as a provider with the generic orchestration module.

```text
Keldor.Build
└── Keldor.Build.PowerShell
```

Future language-specific providers should follow the same pattern:

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
Test-KeldorPowerShellProject -Path .
Invoke-KeldorPowerShellBuild -Path . -Test
```

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
