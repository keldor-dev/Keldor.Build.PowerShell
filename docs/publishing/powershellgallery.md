# Publishing PowerShell Modules to the PowerShell Gallery

This document outlines the process for publishing validated PowerShell modules to the PowerShell Gallery.

The PowerShell Gallery is the public production destination for official Keldor module releases. Packages should be built, tested, and validated through the internal ProGet test feed before they are published publicly.

> [!IMPORTANT]
> Do not use the PowerShell Gallery as a testing feed. Published versions are public and cannot be replaced with a corrected package using the same version number.

---

## Purpose

The PowerShell Gallery publishing process should provide a controlled path from a validated build artifact to a public release.

The process should ensure that:

- The module version is correct and has not already been published.
- Required tests and static analysis checks have passed.
- The package installed and functioned correctly from the internal ProGet test feed.
- Release notes and documentation are complete.
- The PowerShell Gallery API key is retrieved securely.
- The published package is verified after release.

---

## Recommended Release Flow

1. Prepare the release branch or release commit.
2. Update the module version.
3. Update release notes and documentation.
4. Build the module artifact.
5. Run PSScriptAnalyzer.
6. Run Pester tests.
7. Validate the module manifest and exported commands.
8. Publish the package to the internal ProGet test feed.
9. Install the package from ProGet in a clean test environment.
10. Perform smoke and integration testing.
11. Confirm the PowerShell Gallery version does not already exist.
12. Create the Git tag and GitHub release.
13. Publish the validated artifact to the PowerShell Gallery.
14. Verify the public package metadata and installation.
15. Announce or document the release.

---

## Prerequisites

Before publishing, confirm the following:

- A PowerShell Gallery account has been created.
- The publishing account owns or has permission to publish the module.
- A valid PowerShell Gallery API key is available.
- The API key is stored securely and is not committed to source control.
- `Microsoft.PowerShell.PSResourceGet` is installed.
- The module manifest contains valid Gallery metadata.
- The target version has not already been published.

---

## Required Module Metadata

The module manifest should include, at minimum:

- `RootModule`
- `ModuleVersion`
- `GUID`
- `Author`
- `CompanyName`
- `Copyright`
- `Description`
- `PowerShellVersion`
- `FunctionsToExport`
- `CmdletsToExport`
- `AliasesToExport`
- `PrivateData.PSData.Tags`
- `PrivateData.PSData.LicenseUri`
- `PrivateData.PSData.ProjectUri`
- `PrivateData.PSData.ReleaseNotes`

The manifest should also be tested using:

```powershell
Test-ModuleManifest -Path '.\Keldor.psd1'
```

---

## Validate the Target Version

Before publishing, confirm that the version is not already present in the PowerShell Gallery:

```powershell
Find-PSResource `
    -Name 'Keldor' `
    -Repository PSGallery `
    -Version '1.0.0'
```

A production release must always use a unique semantic version.

---

## Build and Test

The exact build commands will eventually be provided by Keldor.Build.PowerShell. Until then, the release process should include:

```powershell
Invoke-ScriptAnalyzer `
    -Path '.\src\Keldor' `
    -Recurse

Invoke-Pester `
    -Path '.\tests' `
    -CI

Test-ModuleManifest `
    -Path '.\output\Keldor\Keldor.psd1'
```

The build should produce a clean, versioned module directory containing only files required by the published package.

---

## Validate Through ProGet

Before publishing publicly, publish the candidate package to the internal ProGet test feed.

> [!NOTE]
> The SHFamily ProGet instance is used only for development and testing. It is not the final production destination for official releases.

```powershell
Publish-PSResource `
    -Path '.\output\Keldor' `
    -Repository SHRepo `
    -ApiKey '<PROGET_API_KEY>'
```

Install the exact package version from ProGet into a clean test environment:

```powershell
Install-PSResource `
    -Name 'Keldor' `
    -Version '1.0.0' `
    -Repository SHRepo `
    -Scope CurrentUser
```

Validation should include:

- Importing the installed module.
- Confirming exported commands.
- Running smoke tests against the installed package.
- Confirming help files and online help links.
- Confirming dependencies install correctly.
- Testing supported PowerShell editions and operating systems.

---

## Register the PowerShell Gallery

The PowerShell Gallery is normally registered by default. Verify its configuration with:

```powershell
Get-PSResourceRepository -Name PSGallery
```

If registration is missing, restore the default repository:

```powershell
Register-PSResourceRepository -PSGallery
```

---

## Publish with PSResourceGet

PSResourceGet is the recommended publishing method.

```powershell
Publish-PSResource `
    -Path '.\output\Keldor' `
    -Repository PSGallery `
    -ApiKey '<POWERSHELL_GALLERY_API_KEY>'
```

> [!WARNING]
> Never store the API key directly in a script, repository, build log, or shell history.

---

## Legacy PowerShellGet Publishing

Legacy publishing may still be required for compatibility with older automation.

```powershell
Publish-Module `
    -Path '.\output\Keldor' `
    -Repository PSGallery `
    -NuGetApiKey '<POWERSHELL_GALLERY_API_KEY>'
```

PSResourceGet should remain the default for new automation.

---

## Secure API Key Retrieval

The publishing API key should be retrieved at runtime from a secure secret store such as:

- 1Password CLI
- Microsoft.PowerShell.SecretManagement
- GitHub Actions Secrets
- Azure Key Vault

Example placeholder workflow:

```powershell
$ApiKey = Get-KeldorSecret `
    -Vault 'DevOps' `
    -Item 'PowerShell Gallery'

Publish-PSResource `
    -Path '.\output\Keldor' `
    -Repository PSGallery `
    -ApiKey $ApiKey
```

The final implementation may retrieve the API key directly through the 1Password CLI or a Keldor.Build.PowerShell wrapper.

---

## Verify the Published Package

After publishing, confirm that the expected version is available:

```powershell
Find-PSResource `
    -Name 'Keldor' `
    -Repository PSGallery `
    -Version '1.0.0'
```

Install the public package into a clean environment:

```powershell
Install-PSResource `
    -Name 'Keldor' `
    -Version '1.0.0' `
    -Repository PSGallery `
    -Scope CurrentUser
```

Then verify the installed module:

```powershell
Import-Module Keldor -Force

Get-Command -Module Keldor

Get-Module Keldor -ListAvailable
```

---

## Failure and Recovery

A published PowerShell Gallery package cannot be overwritten using the same version number.

If a release is defective:

1. Determine whether the package should be unlisted.
2. Correct the issue in source control.
3. Increment the module version.
4. Repeat the full validation process.
5. Publish the corrected version as a new release.

Do not attempt to reuse the original version number.

---

## Future Keldor.Build.PowerShell Integration

The long-term goal is to automate this process through Keldor.Build.PowerShell.

A future publishing command may resemble:

```powershell
Publish-KeldorPowerShellModule `
    -Path '.\src\Keldor' `
    -TestRepository SHRepo `
    -PublishRepository PSGallery
```

The automated workflow should eventually:

- Validate the working tree and release branch.
- Determine and validate the module version.
- Build the module.
- Run PSScriptAnalyzer and Pester.
- Validate the manifest and package contents.
- Publish to ProGet for test validation.
- Install and test the ProGet package.
- Create a Git tag and GitHub release.
- Retrieve the PowerShell Gallery API key securely.
- Publish the validated artifact to the PowerShell Gallery.
- Verify the public release.
- Produce a release summary.

---

## Release Checklist

- [ ] Version updated
- [ ] Release notes updated
- [ ] Documentation updated
- [ ] Manifest validated
- [ ] PSScriptAnalyzer passed
- [ ] Pester tests passed
- [ ] Build artifact created
- [ ] Published to ProGet
- [ ] Installed and tested from ProGet
- [ ] Target version confirmed absent from PSGallery
- [ ] Git tag created
- [ ] GitHub release created
- [ ] PowerShell Gallery API key retrieved securely
- [ ] Published to PSGallery
- [ ] Public package verified
- [ ] Release announced or documented

---

## Related Documentation

- [Publishing to ProGet](proget.md)
- Build process documentation
- Versioning standard
- Release notes standard
- GitHub release workflow
