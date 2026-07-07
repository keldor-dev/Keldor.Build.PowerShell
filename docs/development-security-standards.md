# Development and Security Standards

## Purpose

This document defines the development, compatibility, and security standards for `Keldor.Build.PowerShell`.

The goal is to produce PowerShell build tooling that is secure, maintainable, cross-platform where practical, and suitable for enterprise or government-adjacent environments.

## Engineering Principles

Keldor PowerShell projects should prioritize:

1. Security
2. Reliability
3. Readability
4. Maintainability
5. Portability
6. Performance

## Security Alignment

Where applicable, development should align with:

- NIST SP 800-53
- NIST Secure Software Development Framework
- DoD cybersecurity expectations
- DISA STIG principles where practical

Not every control applies directly to a PowerShell module, but applicable practices should be followed when reasonable.

## Secure Coding

Code should:

- Validate input parameters.
- Avoid command injection.
- Avoid `Invoke-Expression` unless there is a documented and reviewed reason.
- Avoid hardcoded secrets.
- Avoid logging sensitive data.
- Use `ShouldProcess` for destructive or state-changing actions.
- Fail clearly and safely.
- Prefer explicit behavior over implicit assumptions.

## Secrets

Secrets must not be committed to source control.

Examples include:

- API keys
- Tokens
- Passwords
- Private keys
- Connection strings
- Personal access tokens

Use environment variables or approved secret management mechanisms instead.

## PowerShell Compatibility

Preferred runtime:

- PowerShell 7+

Supported where practical:

- Windows PowerShell 5.1
- Windows PowerShell 2.0

PowerShell 2.0 compatibility should be preserved only when it does not weaken security, correctness, readability, or maintainability.

## Cross-Platform Support

Code should run on Windows, macOS, and Linux where practical.

Avoid assuming availability of:

- Windows Registry
- WMI
- COM objects
- Windows-only file paths
- Windows-only executables

Use platform checks when platform-specific behavior is required.

## PowerShell Style

PowerShell code should:

- Use approved verbs.
- Use clear function and parameter names.
- Prefer full cmdlet names over aliases.
- Prefer named parameters over positional parameters.
- Use four-space indentation.
- Use LF line endings.
- Include a final newline.
- Avoid unnecessary `Write-Host` usage.
- Use `Write-Verbose` and `Write-Debug` for diagnostic output.

## Testing

Public behavior should be covered by Pester tests where practical.

Tests should include:

- Successful operation
- Invalid input
- Missing dependencies
- Cross-platform assumptions

## Static Analysis

PSScriptAnalyzer should be run before merging changes.

```powershell
./build/build.ps1 -Analyze
```

## Build Validation

Before release, run:

```powershell
./build/build.ps1 -Clean -Analyze -Test
```

## Documentation

Public commands should have documentation that explains:

- Purpose
- Parameters
- Examples
- Compatibility considerations
- Security considerations when relevant

## Repository Hygiene

Keldor repositories should include:

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
