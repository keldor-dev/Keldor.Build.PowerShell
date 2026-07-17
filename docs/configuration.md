# Repository Build Configuration

Configuration-driven builds use an inert `.psd1` file. Every path is relative to the directory containing the data
file, which is treated as the repository root. Absolute paths, parent traversal, unknown keys, invalid versions, and
missing source or manifest paths are rejected.

```powershell
@{
    ModuleName                = 'Example'
    SourcePath                = 'src/Example'
    ManifestPath              = 'src/Example/Example.psd1'
    TestPath                  = 'src/Example/Tests'
    OutputPath                = 'out'
    AnalyzerSettingsPath      = 'PSScriptAnalyzerSettings.psd1'
    RequiredPowerShellVersion = '5.1'
    ExpectedManifestVersion   = '1.0.0'
    ExcludedPaths             = @('.DS_Store', 'Tests')
}
```

## Contract

| Key | Required | Default | Purpose |
|---|---:|---|---|
| `ModuleName` | Yes | None | Module and output directory name; must match the manifest name. |
| `SourcePath` | Yes | None | Module source directory. |
| `ManifestPath` | Yes | None | Manifest beneath `SourcePath`. |
| `TestPath` | Yes | None | Consumer test directory. |
| `OutputPath` | Yes | None | Artifact root. |
| `AnalyzerSettingsPath` | No | None | Consumer PSScriptAnalyzer settings. |
| `RequiredPowerShellVersion` | No | None | Minimum version the manifest must declare. |
| `ExpectedManifestVersion` | No | Manifest value | Expected development semantic version. |
| `ExcludedPaths` | No | `.DS_Store` | Source-relative paths omitted from artifacts. |

Use `Test-KeldorPowerShellBuildConfiguration` to validate and normalize the contract without creating output.
Configuration must never contain credentials. Pass publishing credentials from a secret store or CI environment.
