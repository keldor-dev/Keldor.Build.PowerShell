# Contributing

Thank you for contributing to `Keldor.Build.PowerShell`.

## Development Standards

Contributions should follow Keldor engineering standards:

- Secure by default
- Cross-platform where practical
- Backwards compatible where safe and maintainable
- Clear, readable PowerShell
- Tested public behavior
- Documented public commands

## PowerShell Compatibility

Preferred runtime:

- PowerShell 7+

Supported where practical:

- Windows PowerShell 5.1
- Windows PowerShell 2.0

PowerShell 2.0 compatibility should not override security, correctness, or maintainability.

## Before Submitting Changes

Run:

```powershell
./build/build.ps1 -Clean -Analyze -Test
```

## Code Quality

Use:

- PSScriptAnalyzer
- Pester
- `.editorconfig`
- `.gitattributes`
- `.markdownlint.json`

## Security Expectations

Do not commit secrets, tokens, credentials, private keys, or environment-specific configuration.

Avoid unsafe execution patterns such as `Invoke-Expression` unless there is a documented and reviewed reason.

## Pull Requests

Pull requests should include:

- Description of the change
- Testing performed
- Security or compatibility considerations
- Documentation updates when behavior changes
