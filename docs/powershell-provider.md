# PowerShell Provider

`Keldor.Build.PowerShell` provides PowerShell-specific build behavior for Keldor repositories.

## Responsibilities

This provider is responsible for:

- Detecting PowerShell module projects
- Validating module manifests
- Running optional script analysis
- Running Pester tests
- Copying source files into a build artifact directory
- Publishing PowerShell modules when explicitly requested

## Detection

A project is currently detected as a PowerShell module when a `.psd1` module manifest exists at the repository root.

If more than one manifest exists, the provider prefers a manifest whose base name matches the repository folder name.

## Build Output

The default build output path is:

```text
artifacts/<ModuleName>/
```

The build command copies common module assets such as:

- Root `.psd1`, `.psm1`, and `.ps1xml` files
- `Public/`
- `Private/`
- `Classes/`
- `Formats/`
- `Types/`
- `en-US/`

## Compatibility

PowerShell code should support Windows PowerShell 5.1 and PowerShell 7+ where practical.

PowerShell 2.0 compatibility should be preserved where it does not create unreasonable complexity or reduce security.

## Security Expectations

PowerShell build logic should avoid:

- Hardcoded secrets
- Direct execution of untrusted input
- Unsafe string interpolation into commands
- Platform-specific assumptions without checks

Security improvements should take priority over legacy compatibility when there is a direct conflict.
