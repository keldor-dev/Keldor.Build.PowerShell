# Publish Keldor to SHFamily ProGet

SHFamily ProGet is Keldor's internal development and test feed. Publish a release candidate here, install that exact
version from the feed, and validate it before approving a public PowerShell Gallery release. See the
[Keldor release runbook](keldor-release.md) for the complete promotion sequence.

> [!IMPORTANT]
> Feed versions are immutable release candidates. Do not overwrite or routinely delete a version. Fix the source,
> select a new semantic version, rebuild, and publish the new candidate.

## Repository details

The Keldor configuration and existing repository documentation use these values:

| Setting | Value |
|---|---|
| PowerShellGet repository name | `SHRepo` |
| Feed | `PowerShell` |
| Server | `repo.shfamily.net` |
| V3 source endpoint | `https://repo.shfamily.net/nuget/PowerShell/v3/index.json` |
| Publish endpoint | `https://repo.shfamily.net/nuget/PowerShell` |

`Keldor.Build.PowerShell` currently publishes through PowerShellGet's `Publish-Module`, so both the PowerShellGet
registration used for publishing and the PSResourceGet registration used for verification are shown below.

## Prerequisites

- A clean Keldor checkout on the intended release commit. The build module does not enforce Git cleanliness.
- Windows PowerShell 5.1 or a supported PowerShell 7 release. PowerShell 7.6 LTS is the preferred release runtime.
- `Keldor.Build.PowerShell` 0.2.0, `PowerShellGet`, `Microsoft.PowerShell.PSResourceGet`, Pester 5.8.0, and
  PSScriptAnalyzer 1.25.0.
- The 1Password CLI (`op`), an authenticated session, and access to the `DevOps` vault's `SHRepo` item.
- Final semantic version and release notes. The source manifest is `src/Keldor/Keldor.psd1`.

Confirm the tools without exposing credentials:

```powershell
$ErrorActionPreference = 'Stop'

Get-Command op -ErrorAction Stop | Out-Null
op whoami | Out-Null

Get-Module -ListAvailable `
    Keldor.Build.PowerShell, PowerShellGet, Microsoft.PowerShell.PSResourceGet, Pester, PSScriptAnalyzer
```

## One-time repository registration

Register the V3 feed for modern search and isolated download operations:

```powershell
if (-not (Get-PSResourceRepository -Name SHRepo -ErrorAction SilentlyContinue)) {
    Register-PSResourceRepository `
        -Name SHRepo `
        -Uri 'https://repo.shfamily.net/nuget/PowerShell/v3/index.json' `
        -ApiVersion V3 `
        -Trusted
}
```

Register the PowerShellGet publish endpoint required by `Publish-KeldorPowerShellProject`:

```powershell
if (-not (Get-PSRepository -Name SHRepo -ErrorAction SilentlyContinue)) {
    Register-PSRepository `
        -Name SHRepo `
        -SourceLocation 'https://repo.shfamily.net/nuget/PowerShell/v3/index.json' `
        -PublishLocation 'https://repo.shfamily.net/nuget/PowerShell' `
        -InstallationPolicy Trusted
}
```

Repository credentials used to read a restricted feed are separate from the API key used to publish.

## Confirm the 1Password reference

The vault and item are known, but the API-key field label must be confirmed from metadata. This does not print field
values:

```powershell
op item get 'SHRepo' --vault 'DevOps' --format json |
    ConvertFrom-Json |
    Select-Object -ExpandProperty fields |
    Select-Object label, type, purpose
```

Replace `<api-key-field>` below with the confirmed label. Do not guess `password`, `credential`, or `api-key`:

```text
op://DevOps/SHRepo/<api-key-field>
```

## Build and validate the candidate

Run these commands from the Keldor repository root. They mirror the current CI checks and produce a staged module
directory, not a `.nupkg`. `Publish-Module` creates the package when it publishes.

```powershell
$ErrorActionPreference = 'Stop'
$version = '0.1.0' # Set the new, unreleased semantic version.

if (git status --porcelain) {
    throw 'The Keldor working tree must be clean before release.'
}

./build.ps1 -Task Validate

$analysis = Invoke-ScriptAnalyzer `
    -Path ./src/Keldor `
    -Recurse `
    -Settings ./PSScriptAnalyzerSettings.psd1
if ($analysis) {
    $analysis | Format-Table -AutoSize
    throw "PSScriptAnalyzer reported $($analysis.Count) issue(s)."
}

Invoke-Pester ./src/Keldor/Tests -CI
$artifact = ./build.ps1 -Task Release -Version $version

Test-KeldorPowerShellProject -Path $artifact.OutputPath -Analyze | Out-Null
$manifest = Test-ModuleManifest -Path $artifact.ManifestPath -ErrorAction Stop

if (Test-Path (Join-Path $artifact.OutputPath 'Tests')) {
    throw 'The release artifact contains the build-only Tests directory.'
}
if (Get-ChildItem $artifact.OutputPath -Recurse -Force -Filter '.DS_Store') {
    throw 'The release artifact contains .DS_Store.'
}

$artifactFiles = Get-ChildItem $artifact.OutputPath -File -Recurse
$artifactHashes = $artifactFiles | Get-FileHash -Algorithm SHA256

$artifact | Format-List Task, Name, OutputPath, ManifestPath, ModuleVersion
```

The current configuration stages `src/Keldor` at `out/Keldor`, removes `Tests` and `.DS_Store`, writes explicit
function exports, and changes version metadata only in the staged manifest. It does not change the source manifest.
The build does not create a Git tag or GitHub Release and does not check the branch or working tree.

Before publishing, confirm the exact version is absent. Use `-Prerelease` as well when releasing a prerelease:

```powershell
$existing = Find-PSResource `
    -Name Keldor `
    -Repository SHRepo `
    -Version $version `
    -ErrorAction SilentlyContinue
if ($existing) {
    throw "Keldor $version already exists in SHRepo. Select a new version."
}
```

## Dry run and publish

The dry run exercises project discovery and `ShouldProcess` without retrieving a key or contacting the publish
endpoint:

```powershell
Publish-KeldorPowerShellProject `
    -Path $artifact.OutputPath `
    -Repository SHRepo `
    -WhatIf
```

Retrieve the key only for the publishing command. Do not enable command tracing or a transcript around this block:

```powershell
$apiKey = op read 'op://DevOps/SHRepo/<api-key-field>'
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw '1Password returned an empty SHRepo API key.'
}

try {
    Publish-KeldorPowerShellProject `
        -Path $artifact.OutputPath `
        -Repository SHRepo `
        -NuGetApiKey $apiKey `
        -ErrorAction Stop
} finally {
    Remove-Variable apiKey -ErrorAction SilentlyContinue
}
```

`Publish-KeldorPowerShellProject` normally publishes without a confirmation prompt; add `-Confirm` when an explicit
operator prompt is desired. It returns no publication object. A duplicate version or authorization failure is a
terminating feed error when `-ErrorAction Stop` is used. Removing the variable is best-effort process hygiene, not a
guarantee that the secret has been erased from process memory.

`./build.ps1 -Task Publish` is an available rebuild-and-publish shortcut. Do not use it for promotion: it rebuilds
`out/Keldor`, while the runbook intentionally publishes the already inspected `Release` artifact.

## Verify the candidate

Allow for brief feed indexing delay, then validate an isolated download in a fresh PowerShell session:

```powershell
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) "keldor-shrepo-$version"
New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

Save-PSResource `
    -Name Keldor `
    -Version $version `
    -Repository SHRepo `
    -Path $testRoot `
    -TrustRepository

$installedManifest = Get-ChildItem $testRoot -Filter Keldor.psd1 -Recurse | Select-Object -First 1
$published = Test-ModuleManifest -Path $installedManifest.FullName -ErrorAction Stop
Import-Module $installedManifest.FullName -Force -ErrorAction Stop

$published | Select-Object Name, Version, ProjectUri, RequiredModules
Get-Command -Module Keldor | Sort-Object CommandType, Name
Get-Alias | Where-Object { $_.ResolvedCommand.ModuleName -eq 'Keldor' }
Get-KeldorPlatform

Remove-Module Keldor -ErrorAction SilentlyContinue
Remove-Item $testRoot -Recurse -Force
```

Run supported platform and integration smoke tests against this feed-installed copy before approval. Recompute the
local artifact hashes before PSGallery publication and compare them with `$artifactHashes` to detect local changes.

## Troubleshooting

| Failure | Action |
|---|---|
| `op` is missing | Install the 1Password CLI and rerun the prerequisite check. |
| `op whoami` fails | Sign in with `op signin`, then retry without printing a token. |
| Secret reference not found | Inspect metadata and correct the vault, item, or field label; never guess it. |
| Repository not registered | Register both PSResourceGet and PowerShellGet entries shown above. |
| Unauthorized or forbidden | Verify the API key's feed permission and publish endpoint. Rotate it if needed. |
| Version already exists | Increment the semantic version, rebuild, and repeat validation. |
| TLS or certificate error | Validate the server certificate chain and organizational TLS inspection configuration. |
| Artifact path not found | Run `-Task Release` from the Keldor root and inspect `$artifact.OutputPath`. |
| Manifest, test, or analyzer failure | Fix the source; do not publish the candidate. |
| Package not visible | Wait for ProGet indexing, then query the exact version again. |
| Endpoint mismatch | PSResourceGet reads the V3 URI; PowerShellGet publishes to the non-V3 publish URI. |

Unlisting or deletion is an exceptional ProGet administrator action. Follow feed policy and preserve the audit trail;
never delete a candidate merely to reuse its version.
