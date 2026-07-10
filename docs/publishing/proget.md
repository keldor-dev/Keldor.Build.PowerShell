# Publishing PowerShell Modules to ProGet

This document describes how to configure PowerShell to use the SHFamily ProGet server for publishing and installing PowerShell modules.

> [!IMPORTANT]
> The SHFamily ProGet instance is intended **for development and testing only**. It serves as an internal package feed for validating modules before release. Official Keldor releases should ultimately be published to the PowerShell Gallery as part of the release process.

While **PSResourceGet** is the recommended package manager for modern PowerShell, legacy **PowerShellGet** commands are included for compatibility with existing tooling and older systems.

---

## Repository Information

| Item | Value |
|------|------|
| Repository Name | `SHRepo` |
| Feed Name | `PowerShell` |
| Server | `repo.shfamily.net` |
| PSResourceGet Feed | `https://repo.shfamily.net/nuget/PowerShell/v3/index.json` |
| Legacy Publish Endpoint | `https://repo.shfamily.net/nuget/PowerShell` |

---

## PSResourceGet (Recommended)

### Install PSResourceGet

If PSResourceGet is not already installed:

```powershell
Install-Module Microsoft.PowerShell.PSResourceGet `
    -Scope CurrentUser `
    -Force
```

---

### Register the Repository

```powershell
Register-PSResourceRepository `
    -Name 'SHRepo' `
    -Uri 'https://repo.shfamily.net/nuget/PowerShell/v3/index.json' `
    -ApiVersion V3 `
    -Trusted `
    -PassThru
```

---

### Verify Registration

```powershell
Get-PSResourceRepository SHRepo
```

---

### Find Available Modules

```powershell
Find-PSResource `
    -Repository SHRepo `
    -Name Keldor
```

---

### Install a Module

```powershell
Install-PSResource `
    -Repository SHRepo `
    -Name Keldor
```

To install a specific version:

```powershell
Install-PSResource `
    -Repository SHRepo `
    -Name Keldor `
    -Version 1.0.0
```

---

### Update a Module

```powershell
Update-PSResource `
    -Repository SHRepo `
    -Name Keldor
```

---

### Publish a Module

```powershell
Publish-PSResource `
    -Path .\output\Keldor `
    -Repository SHRepo `
    -ApiKey '<API_KEY>'
```

> **Note**
>
> ProGet currently requires an API key to be supplied when publishing.

---

## PowerShellGet (Legacy)

These commands are provided for compatibility with Windows PowerShell 5.1 and older automation.

### Register the Repository

```powershell
Register-PSRepository `
    -Name 'SHRepo' `
    -SourceLocation 'https://repo.shfamily.net/nuget/PowerShell/v3/index.json' `
    -PublishLocation 'https://repo.shfamily.net/nuget/PowerShell' `
    -InstallationPolicy Trusted
```

---

### Install a Module

```powershell
Install-Module `
    -Repository SHRepo `
    -Name Keldor
```

---

### Publish a Module

```powershell
Publish-Module `
    -Name Keldor `
    -Repository SHRepo `
    -NuGetApiKey '<API_KEY>'
```

---

## Authentication

Publishing requires a ProGet API key.

For manual publishing:

```powershell
$ApiKey = '<API_KEY>'
```

Long-term, API keys should be retrieved securely rather than stored in scripts.

Example future workflow:

```powershell
$ApiKey = Get-KeldorSecret `
    -Vault DevOps `
    -Item SHRepo

Publish-PSResource `
    -Path .\output\Keldor `
    -Repository SHRepo `
    -ApiKey $ApiKey
```

This allows secrets to remain securely stored in systems such as:

- 1Password CLI
- Microsoft SecretManagement
- Azure Key Vault
- GitHub Actions Secrets

---

## Future Keldor.Build.PowerShell Integration

The long-term goal is to abstract the publishing process behind Keldor.Build.PowerShell.

Instead of manually running `Publish-PSResource`, publishing should eventually become as simple as:

```powershell
Publish-KeldorModule
```

A future implementation could automatically:

- Build the module
- Run PSScriptAnalyzer
- Execute Pester tests
- Validate the module manifest
- Generate release notes
- Retrieve the ProGet API key from 1Password
- Publish to ProGet
- Verify the published package
- Optionally publish to the PowerShell Gallery
- Create a GitHub Release

---

## References

| Purpose | Command |
|---------|---------|
| Register Repository | `Register-PSResourceRepository` |
| View Registered Repositories | `Get-PSResourceRepository` |
| Search for Modules | `Find-PSResource` |
| Install a Module | `Install-PSResource` |
| Update a Module | `Update-PSResource` |
| Publish a Module | `Publish-PSResource` |

---

## Recommendation

For all new development—including **Keldor**, **Keldor.Build.PowerShell**, and related projects—use **PSResourceGet**.

Retain the legacy **PowerShellGet** commands only for backward compatibility with existing automation and older versions of PowerShell.
