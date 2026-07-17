# Changelog

All notable changes to this project will be documented in this file.

This project follows semantic versioning.

## 0.2.0 - Unreleased

- Add a validated, inert repository build configuration contract.
- Move semantic versioning, manifest export generation, staging, release, and publish orchestration into this module.
- Preserve the existing flat-project command interface while adding configuration-driven tasks and structured output.
- Set the supported PowerShell floor to Windows PowerShell 5.1 and add compatibility validation.

## [0.1.0] - 2026-07-07

### Added

- Initial `Keldor.Build.PowerShell` module scaffold.
- PowerShell project discovery.
- PowerShell project validation.
- PowerShell build command.
- PowerShell test command.
- PowerShell clean command.
- PowerShell publish command.
- Optional provider registration for `Keldor.Build`.
- Repository quality files.
- PSScriptAnalyzer settings.
- GitHub Actions workflow.
- Initial documentation.
