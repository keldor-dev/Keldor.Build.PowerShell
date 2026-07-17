# Consumer Integration

Consumers install a pinned build-module version, import it from a thin root script, and invoke the configuration mode.
Keldor is the reference integration:

```powershell
Import-Module Keldor.Build.PowerShell -RequiredVersion 0.2.0 -ErrorAction Stop
Invoke-KeldorPowerShellBuild -ConfigurationPath ./build.config.psd1 -Task Build
```

CI must install the exact version before invoking the consumer entry point. Release the build module before merging a
consumer update that requires that version.

## Testing Unpublished Changes

Clone repositories anywhere; no special sibling layout is required. Pass the local module directory explicitly to a
consumer's wrapper when it supports a development override. Keldor uses:

```powershell
./build.ps1 -Task Build -BuildModulePath ../Keldor.Build.PowerShell
```

The override is explicit and is never read from release CI. Confirm the imported module reports the expected version
before testing. Publishing credentials remain outside configuration and should be provided only by the release job.

## Tasks and Results

- `Validate` validates the configuration and development manifest.
- `Build` stages a deterministic artifact and writes explicit function exports.
- `Release` builds an artifact with an explicit semantic version, leaving source metadata unchanged.
- `Publish` validates the remote version, prepares the artifact, and calls `Publish-Module` under `ShouldProcess`.

Build and validation commands return structured objects containing paths, task, module name, and version. Failures are
terminating errors suitable for CI.
