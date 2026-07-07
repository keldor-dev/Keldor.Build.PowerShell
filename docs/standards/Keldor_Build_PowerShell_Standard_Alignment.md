# Keldor.Build.PowerShell Standard Alignment

| Property | Value |
|---|---|
| Version | 1.0 |
| Status | Draft |
| Applies To | Keldor.Build.PowerShell |
| Last Updated | 2026-07-07 |

## Purpose

This document explains how `Keldor.Build.PowerShell` aligns with and will eventually enforce the Keldor PowerShell Engineering Standard.

## Source Standards

The canonical standards live in the `keldor-dev/Keldor` repository:

- Keldor General Engineering Standard
- Keldor PowerShell Engineering Standard

This repository should not fork those standards. It should reference and enforce them.

## Current Alignment

`Keldor.Build.PowerShell` currently aligns with the standards by providing:

- PowerShell project discovery
- Manifest validation
- Script analysis integration
- Pester test execution
- Build output generation
- Cross-platform CI on Windows, macOS, and Linux
- Repository quality files such as `.editorconfig`, `.gitattributes`, and markdown linting

## Future Enforcement Commands

Future versions should add validation commands that map to sections of the standard.

| Command | Purpose |
|---|---|
| `Test-KeldorEngineeringStandard` | Orchestrates all standard validation checks. |
| `Test-KeldorRepository` | Validates required repository files and folders. |
| `Test-KeldorDocumentation` | Validates README, docs, changelog, and public documentation expectations. |
| `Test-KeldorCommentHelp` | Validates comment-based help sections for public functions. |
| `Test-KeldorHelpUri` | Validates `HelpUri` and `.LINK` alignment. |
| `Test-KeldorNaming` | Validates approved verbs, naming conventions, and standard aliases. |
| `Test-KeldorCompatibility` | Validates compatibility expectations for selected PowerShell targets. |
| `Test-KeldorSecurity` | Validates common insecure patterns. |
| `Test-KeldorPerformance` | Flags common performance concerns such as array `+=` in loops. |
| `Test-KeldorStyle` | Validates style conventions not covered by PSScriptAnalyzer. |

## Implementation Approach

Validation commands should produce structured objects, not only text output.

Recommended result shape:

```powershell
[pscustomobject]@{
    PSTypeName   = 'Keldor.Build.PowerShell.Standard.Result'
    RuleName     = 'HelpUriMatchesLink'
    Path         = $Path
    Severity     = 'Warning'
    Passed       = $false
    Message      = 'HelpUri does not match the .LINK value.'
    Recommendation = 'Update HelpUri or .LINK so both point to the same documentation page.'
}
```

This allows results to be filtered, exported, summarized, and used in CI.

## Non-Goals

This repository should not become the canonical standards repository.

The canonical written standards should remain in `keldor-dev/Keldor`; this repository should implement and enforce them.
