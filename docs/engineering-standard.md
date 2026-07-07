# Engineering Standard Alignment

`Keldor.Build.PowerShell` targets the Keldor PowerShell Engineering Standard.

## Target Standards

| Standard | Target Version | Source |
|---|---:|---|
| Keldor General Engineering Standard | 1.0 | `keldor-dev/Keldor/docs/standards/Keldor_General_Engineering_Standard.md` |
| Keldor PowerShell Engineering Standard | 1.0 | `keldor-dev/Keldor/docs/standards/Keldor_PowerShell_Engineering_Standard.md` |

## Purpose

This repository should eventually provide tooling that validates whether PowerShell repositories follow Keldor engineering standards.

The standard is documentation first, then automation.

## Planned Validation Commands

Future versions of `Keldor.Build.PowerShell` should provide commands such as:

```powershell
Test-KeldorEngineeringStandard
Test-KeldorRepository
Test-KeldorDocumentation
Test-KeldorCommentHelp
Test-KeldorHelpUri
Test-KeldorNaming
Test-KeldorCompatibility
Test-KeldorSecurity
Test-KeldorPerformance
Test-KeldorStyle
```

## Validation Areas

### Repository

Validate expected repository files and folders:

- `.editorconfig`
- `.gitattributes`
- `.gitignore`
- `.markdownlint.json`
- `.markdownlintignore`
- `README.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `SECURITY.md`
- `LICENSE`
- `PSScriptAnalyzerSettings.psd1`
- `.github/workflows/`

### Documentation

Validate public command documentation expectations:

- Comment-based help exists
- `HelpUri` exists
- `.LINK` exists
- `HelpUri` and `.LINK` match
- Function-specific docs URL follows `https://docs.keldor.dev/powershell/keldor/<FunctionName>`

### Naming

Validate naming expectations:

- Approved PowerShell verbs
- PascalCase public function names
- Consistent standard parameter aliases
- Consistent output property names such as `ComputerName`

### Security

Validate common risky patterns:

- `Invoke-Expression`
- Hardcoded secrets
- Missing input validation
- Missing `ShouldProcess` on modifying commands

### Compatibility

Validate compatibility expectations:

- Windows PowerShell 5.1 compatibility where practical
- PowerShell 2.0 compatibility where declared
- Cross-platform assumptions documented
- Windows-only functions placed under platform-specific folders

## Build Integration Goal

Eventually, a Keldor PowerShell build should be able to run:

```powershell
Invoke-KeldorPowerShellBuild -Path . -Analyze -Test -ValidateStandard
```

That should validate repository structure, documentation, naming, compatibility, security, style, static analysis, and tests before packaging or publishing.
