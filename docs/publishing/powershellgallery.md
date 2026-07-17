# Publish Keldor to the PowerShell Gallery

The PowerShell Gallery is the public production destination for Keldor. Publish only the staged module directory that
was already published to and validated from SHFamily ProGet. Follow the
[Keldor release runbook](keldor-release.md) before using this guide.

> [!WARNING]
> A published version is public and cannot be replaced. If it is defective, fix the source, increment the semantic
> version, repeat the complete ProGet validation path, and publish the new version. Never reuse a released version.

## Release prerequisites

- The exact candidate version was published to SHRepo and passed clean-session, platform, and integration tests.
- The unchanged `out/Keldor` artifact and its recorded file hashes are still available in the release session.
- The semantic version and `PrivateData.PSData.ReleaseNotes` are final.
- Manifest metadata, explicit exports, package contents, Pester, and PSScriptAnalyzer checks passed.
- The version is absent from PSGallery.
- The Keldor working tree is clean and on the approved release commit and branch.
- The `v<version>` tag and GitHub Release requirements in Keldor's process are satisfied.
- The publisher account may publish `Keldor`, and its API key has the narrowest available package scope and
  least-privilege permissions.
- PowerShellGet, PSResourceGet, `Keldor.Build.PowerShell` 0.2.0, and an authenticated 1Password CLI are available.

The build module does not validate Git state, create tags or GitHub Releases, or confirm that SHRepo tests passed.
These remain explicit operator/release-automation gates.

## PowerShell Gallery key security

Store the key only in 1Password. Scope it to Keldor when Gallery functionality permits, use the shortest practical
expiration, and rotate it according to the team's credential policy.

This session could not confirm an existing Gallery item or field label. The recommended item is `PowerShell Gallery`
in the `DevOps` vault. Inspect metadata without displaying values:

```powershell
op item get 'PowerShell Gallery' --vault 'DevOps' --format json |
    ConvertFrom-Json |
    Select-Object -ExpandProperty fields |
    Select-Object label, type, purpose
```

If the item does not exist, create it through the approved 1Password workflow, add a concealed field for the
narrowly scoped key, and grant only the release operators access. Replace `<api-key-field>` with the confirmed label:

```text
op://DevOps/PowerShell Gallery/<api-key-field>
```

Do not guess the field label and never paste the key into documentation, configuration, shell history, or a persistent
environment variable.

## Preflight

Run from the same Keldor release session that retained `$version`, `$artifact`, and `$artifactHashes` after SHRepo
validation:

```powershell
$ErrorActionPreference = 'Stop'

Get-Command op -ErrorAction Stop | Out-Null
op whoami | Out-Null

if (git status --porcelain) {
    throw 'The Keldor working tree must be clean before public release.'
}

$currentCommit = git rev-parse HEAD
$tagCommit = git rev-list -n 1 "v$version"
if ($currentCommit -ne $tagCommit) {
    throw "Tag v$version does not identify the current release commit."
}

Get-PSResourceRepository -Name PSGallery -ErrorAction Stop | Out-Null
Get-PSRepository -Name PSGallery -ErrorAction Stop | Out-Null

$existing = Find-PSResource `
    -Name Keldor `
    -Repository PSGallery `
    -Version $version `
    -ErrorAction SilentlyContinue
if ($existing) {
    throw "Keldor $version already exists in the PowerShell Gallery."
}

$manifest = Test-ModuleManifest -Path $artifact.ManifestPath -ErrorAction Stop
if ($manifest.Version.ToString() -ne $artifact.ModuleVersion) {
    throw 'The staged manifest and build result versions differ.'
}

$currentHashes = Get-ChildItem $artifact.OutputPath -File -Recurse |
    Get-FileHash -Algorithm SHA256
$hashDifference = Compare-Object `
    -ReferenceObject $artifactHashes `
    -DifferenceObject $currentHashes `
    -Property Path, Hash
if ($hashDifference) {
    throw 'The staged artifact changed after SHRepo validation.'
}

$manifest | Select-Object Name, Version, Author, Description, ProjectUri, LicenseUri, ReleaseNotes, RequiredModules
Get-ChildItem $artifact.OutputPath -File -Recurse | Select-Object FullName, Length
```

For prereleases, include `-Prerelease` when querying the Gallery. Review aliases, `CompatiblePSEditions`, tags,
`HelpInfoUri`, icon/project/license links, and external dependencies before proceeding.

If PSGallery is missing from PSResourceGet, restore it with:

```powershell
Register-PSResourceRepository -PSGallery
```

PowerShellGet normally registers PSGallery automatically. Repair that registration using the organization's approved
PowerShellGet setup rather than inventing a new endpoint.

## Dry run and publish

The supported publishing command uses PowerShellGet's `Publish-Module` internally and publishes the existing artifact:

```powershell
Publish-KeldorPowerShellProject `
    -Path $artifact.OutputPath `
    -Repository PSGallery `
    -WhatIf
```

The dry run needs no key. For the irreversible public operation, retrieve the key only for the command lifetime. Do
not enable command tracing or a transcript around this block:

```powershell
$apiKey = op read 'op://DevOps/PowerShell Gallery/<api-key-field>'
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw '1Password returned an empty PowerShell Gallery API key.'
}

try {
    Publish-KeldorPowerShellProject `
        -Path $artifact.OutputPath `
        -Repository PSGallery `
        -NuGetApiKey $apiKey `
        -ErrorAction Stop
} finally {
    Remove-Variable apiKey -ErrorAction SilentlyContinue
}
```

The command normally runs without a confirmation prompt; add `-Confirm` to require one. It returns no structured
publication object, so verification is mandatory. Removing the variable is best-effort process hygiene, not guaranteed
memory erasure.

Do not use `./build.ps1 -Task Publish` for this promotion. That path rebuilds the module before publishing and would no
longer prove that the SHRepo-tested artifact is the public artifact.

## Verify the public release

Allow for Gallery indexing, then use a fresh PowerShell session and an isolated download directory:

```powershell
$public = Find-PSResource `
    -Name Keldor `
    -Repository PSGallery `
    -Version $version `
    -ErrorAction Stop

$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) "keldor-psgallery-$version"
New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

Save-PSResource `
    -Name Keldor `
    -Version $version `
    -Repository PSGallery `
    -Path $testRoot `
    -TrustRepository

$installedManifest = Get-ChildItem $testRoot -Filter Keldor.psd1 -Recurse | Select-Object -First 1
$published = Test-ModuleManifest -Path $installedManifest.FullName -ErrorAction Stop
Import-Module $installedManifest.FullName -Force -ErrorAction Stop

$public | Select-Object Name, Version, Repository, PublishedDate
$published | Select-Object Name, Version, ProjectUri, LicenseUri, HelpInfoUri, RequiredModules
Get-Command -Module Keldor | Sort-Object CommandType, Name
Get-Alias | Where-Object { $_.ResolvedCommand.ModuleName -eq 'Keldor' }
Get-KeldorPlatform

Remove-Module Keldor -ErrorAction SilentlyContinue
Remove-Item $testRoot -Recurse -Force
```

Confirm the Gallery page renders release notes and project links, dependencies resolve, online help works, and the
supported platform smoke tests pass.

## Failure and recovery

- If publication fails before the Gallery accepts the package, diagnose authorization, ownership, TLS, metadata, and
  endpoint errors without printing the key. Repeat only after confirming the version is still absent.
- If the version is accepted but defective, do not republish it. Fix source, increment the version, build a new
  candidate, validate it through SHRepo, and publish the new Gallery version.
- Unlist only when the release is harmful or misleading and policy supports it. Unlisting does not permit version reuse.

## API-key rotation

Rotate the value in the same 1Password field. The `op://DevOps/PowerShell Gallery/<api-key-field>` reference remains
unchanged, so no source or documentation update is required. Revoke the old Gallery key after validating the new one.
