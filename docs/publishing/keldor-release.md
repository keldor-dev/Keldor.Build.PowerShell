# Keldor release runbook

This runbook coordinates Keldor's internal candidate validation and public release. Detailed target instructions live
in [Publish Keldor to SHFamily ProGet](proget.md) and
[Publish Keldor to the PowerShell Gallery](powershellgallery.md).

```text
Source
  -> build and validate
  -> stage one immutable candidate directory
  -> publish to SHRepo
  -> download and test the exact SHRepo version
  -> approve, tag, and create the GitHub Release as required
  -> publish the unchanged staged directory to PSGallery
  -> download and verify the PSGallery version
```

## Current build-system behavior

Keldor's supported entry point is `./build.ps1`, which pins `Keldor.Build.PowerShell` 0.2.0 and consumes
`build.config.psd1`. Its tasks are:

| Task | Behavior |
|---|---|
| `Validate` | Validates configuration and the source manifest. |
| `Build` | Replaces and stages `out/Keldor` with the development version. |
| `Release` | Stages `out/Keldor`, writes explicit exports, and applies the supplied semantic version. |
| `Publish` | Checks the latest remote version, rebuilds a release artifact, and calls `Publish-Module`. |

The artifact is a module directory at `out/Keldor`; no `.nupkg` is retained. `Publish-Module` packages it during each
publication. The build excludes `Tests` and `.DS_Store` and leaves the source manifest unchanged.

The promotion workflow deliberately uses `Release` once, then calls `Publish-KeldorPowerShellProject` twice with the
same directory. File hashes recorded before SHRepo publication must still match before PSGallery publication. This is
the build system's current support for promoting one staged artifact. It does not compare the feed-created `.nupkg`
files byte for byte.

Pester and PSScriptAnalyzer are separate gates; `Validate` and `Release` do not run them. Git cleanliness, branch,
tags, GitHub Releases, remote smoke tests, and post-publish verification are also operator or CI responsibilities.

## Operator checklist

- [ ] Select a unique final semantic version and finalize release notes and documentation.
- [ ] Use the approved branch and commit; confirm the Keldor working tree is clean.
- [ ] Confirm the pinned build module and test-tool versions are installed.
- [ ] Confirm `op` is installed, signed in, and can access the required items without printing values.
- [ ] Confirm SHRepo registration in both PSResourceGet and PowerShellGet.
- [ ] Run `./build.ps1 -Task Validate`.
- [ ] Run PSScriptAnalyzer with `PSScriptAnalyzerSettings.psd1`; require zero findings.
- [ ] Run `Invoke-Pester ./src/Keldor/Tests -CI`; require a passing result.
- [ ] Run `./build.ps1 -Task Release -Version '<version>'` exactly once.
- [ ] Validate `out/Keldor/Keldor.psd1`, exports, aliases, dependencies, and package contents.
- [ ] Record SHA-256 hashes for every file in `out/Keldor`.
- [ ] Confirm the version is absent from SHRepo.
- [ ] Run the SHRepo `-WhatIf` command.
- [ ] Read the SHRepo key with `op read`, publish the existing directory, and remove the variable in `finally`.
- [ ] Download the exact SHRepo version into an isolated directory and complete smoke/integration/platform testing.
- [ ] Record release approval; create and verify `v<version>` and the GitHub Release as required.
- [ ] Confirm the version is absent from PSGallery.
- [ ] Recompute artifact hashes and require an exact match with the pre-SHRepo inventory.
- [ ] Run the PSGallery `-WhatIf` command.
- [ ] Read the Gallery key with `op read`, publish the existing directory, and remove the variable in `finally`.
- [ ] Download and verify the exact PSGallery version, metadata, exports, aliases, dependencies, links, and help.
- [ ] Retain the release evidence and announce the release.

## Secret references

The vault/item context is:

```text
SHRepo:            op://DevOps/SHRepo/<api-key-field>
PowerShell Gallery: op://DevOps/PowerShell Gallery/<api-key-field>
```

Field labels were not confirmed because the documentation session had no authenticated 1Password session. Follow the
metadata-only checks in each target guide before replacing the placeholders. No credential belongs in
`build.config.psd1`, source control, logs, transcripts, command strings, or persistent environment variables.

## Stop conditions

Stop the release if validation fails, the working tree or artifact changes, a version already exists, a secret cannot
be read, the publisher lacks permission, or post-SHRepo testing is incomplete. Never resolve a conflict by deleting a
package and reusing its version.
