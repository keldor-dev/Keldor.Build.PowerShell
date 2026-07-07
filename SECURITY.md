# Security Policy

## Supported Versions

Security fixes are prioritized for the current major version of `Keldor.Build.PowerShell`.

## Reporting a Vulnerability

Please report suspected vulnerabilities privately when possible.

Do not open a public issue containing:

- Secrets
- Credentials
- Exploit details
- Sensitive logs
- Private infrastructure information

## Security Standards

This project should follow secure development practices aligned with applicable guidance from:

- NIST SP 800-53
- NIST Secure Software Development Framework
- DoD cybersecurity expectations
- DISA STIG principles where applicable

## Secure Coding Expectations

Code should:

- Validate inputs
- Avoid command injection
- Avoid unsafe dynamic execution
- Avoid leaking sensitive values in logs or errors
- Prefer explicit behavior over implicit assumptions
- Use `ShouldProcess` for destructive operations

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
