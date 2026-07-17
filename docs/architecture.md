# Architecture

`Keldor.Build.PowerShell` is the authoritative PowerShell build toolkit for the Keldor ecosystem.

It is intentionally PowerShell-specific. Generic orchestration belongs in `Keldor.Build`; PowerShell module behavior belongs here.

## Design Goals

- Provide direct PowerShell build commands.
- Keep PowerShell project intelligence out of the generic build orchestrator.
- Support cross-platform execution on Windows, macOS, and Linux where practical.
- Preserve backwards compatibility with older PowerShell versions where safe and maintainable.
- Support provider registration with `Keldor.Build` without requiring `Keldor.Build` for direct use.

## Command Layers

### Direct PowerShell Commands

These commands are the primary interface for PowerShell module workflows:

```powershell
Resolve-KeldorPowerShellProject
Test-KeldorPowerShellProject
Invoke-KeldorPowerShellBuild
Invoke-KeldorPowerShellProjectTests
Clear-KeldorPowerShellBuild
Publish-KeldorPowerShellProject
```

### Provider Bridge

`Register-KeldorPowerShellBuildProvider` registers this module with the generic `Keldor.Build` provider system when `Keldor.Build` is available in the session.

This keeps the dependency optional.

## Repository Responsibilities

This repository owns:

- PowerShell module discovery
- PowerShell manifest validation
- PowerShell script analysis
- PowerShell project testing
- PowerShell build output layout
- PowerShell module publishing behavior
- Repository configuration validation
- Semantic version validation and release artifact preparation
- Deterministic module staging and explicit export generation

This repository should not own:

- Python package builds
- .NET solution builds
- Node package builds
- Go module builds
- Generic language-agnostic orchestration

## Compatibility Position

PowerShell 7+ is the preferred runtime.

Windows PowerShell 5.1 should work where practical.

The supported floor is Windows PowerShell 5.1. Supported PowerShell 7 releases are preferred for full test and
analysis workflows.

## Dependency Direction

Consumer modules depend on this build module only while building. This module never imports or depends on the Keldor
runtime module, and consumer package manifests do not list it as a runtime dependency.

## Security Position

PowerShell build tooling must avoid unsafe execution patterns and must not expose secrets through logs, build output, or error messages.

Applicable practices from NIST, DoD, and DISA guidance should be followed where practical.
