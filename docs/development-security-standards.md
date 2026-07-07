# Development and Security Standards

## Purpose

This document captures local development and security expectations for `Keldor.Build.PowerShell`.

The canonical Keldor standards live in the `keldor-dev/Keldor` repository:

- Keldor General Engineering Standard v1.0
- Keldor PowerShell Engineering Standard v1.0

This repository should follow those standards and eventually provide tooling to validate them.

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
- PowerShell 2.0 where safe and maintainable

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

## Local Validation

Run the local build script before committing changes:

```powershell
./build/build.ps1 -Clean -Analyze -Test
```

## Future Standard Enforcement

Future versions of this module should validate Keldor standards through commands documented in [Standards Alignment](standards/Keldor_Build_PowerShell_Standard_Alignment.md).
