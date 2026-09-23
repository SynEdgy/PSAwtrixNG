# GitHub Copilot Instructions for PSAwtrixNG

## Build and test

- Use `./build.ps1` as the only entry point for all build, test, and environment setup operations.
- Never invoke `Build-Module`, `Invoke-Pester`, or `Invoke-Build` directly.
- Never manually prepend anything to `PSModulePath`.
- Standard commands:
  - Bootstrap dependencies: `./build.ps1 -ResolveDependency -Tasks noop`
  - Build: `./build.ps1 -Tasks build`
  - Focused test: `./build.ps1 -Tasks test -PesterPath 'tests/Unit/Public/MyFunction.Tests.ps1' -CodeCoverageThreshold 0`
  - Full test suite: `./build.ps1 -Tasks test`
  - Quality gate: `./build.ps1 -Tasks test -PesterPath 'tests/QA' -CodeCoverageThreshold 0`
- Keep test environments distinct:
  - `tests/Unit` contains mocked, isolated behavior tests.
  - `tests/Integration` may use local ephemeral services but must not require an AWTRIX device.
  - `tests/playwright` is local-only live-device coverage and requires `AWTRIX_NG_URL`.

## Git workflow

- Never commit, push, tag, or publish on behalf of the user.
- Leave all Git operations to the user.

## Repository structure

- Module name: `PSAwtrixNG`
- Source folder: `source/`
- Do not edit the root module `.psm1` directly; it is generated from source files during build.
- Public functions live under `source/Public/`.
- Private functions live under `source/Private/`.

## Live-device safety

- Treat AWTRIX devices as external systems with persistent state.
- Read-only calls to documented endpoints such as `/api/v1/device`, `/api/v1/settings`, and `/api/v1/apps`, plus browser live-view pages, are safe defaults.
- Do not invoke firmware update, reboot, erase, reset settings, deep sleep, Wi-Fi, network, or authentication changes unless the user explicitly approves the exact operation.
- Display-only changes must support `ShouldProcess` and should be reversible during live validation. Capture the original value and restore it in a `finally` block.
- Never persist credentials or device secrets in tracked files. Use environment variables for live test URLs and optional credentials.

## Instruction files

Read the per-area instruction files before making changes in the relevant area:

- `.github/instructions/public-functions.instructions.md` - public function authoring rules
- `.github/instructions/private-functions.instructions.md` - private function authoring rules
- `.github/instructions/test-writing.instructions.md` - Pester test conventions
- `.github/instructions/build-tasks.instructions.md` - InvokeBuild task authoring rules
- `.github/instructions/mqttnet-dependencies.instructions.md` - MQTTnet restore, packaging, and loading rules
- `.github/instructions/playwright-live-device.instructions.md` - live AWTRIX browser test rules

## Changelog policy

- Update `CHANGELOG.md` only for module behavior changes that are visible to users.
- Do not add changelog entries for CI, pipeline, or tooling-only changes.
- Use the `## [Unreleased]` section for new entries.
- Use ASCII-only characters in `CHANGELOG.md` (no em-dashes, smart quotes, or Unicode arrows).

## PowerShell style

- Use `$null = <expression>` not `<expression> | Out-Null` to suppress output.
- Never use the PowerShell backtick for line continuation.
- Use splatting for multi-line command invocations. For multi-line expressions,
  use parentheses, script blocks, arrays, or operators placed where PowerShell
  provides natural continuation.
- Use ASCII-only characters in `.ps1` source files.
- Follow DSC Community parameter style: `[Parameter()]` attribute, type, and variable name each on their own line with a blank line between parameter declarations.
- Use explicit .NET types (`[System.String]`, `[System.Boolean]`, etc.).
- Use `[CmdletBinding()]` and `[OutputType(...)]` on all functions.
- Build multi-level paths with chained `Join-Path` calls; never use hardcoded backslash separators inside `Join-Path -ChildPath` strings.

## Long-running commands

- Always tee `./build.ps1` output to `output\agentic\` so logs survive between builds:

```powershell
$null = New-Item -Path 'output\agentic' -ItemType Directory -Force

./build.ps1 -Tasks test -PesterPath '<paths>' -CodeCoverageThreshold 0 2>&1 |
    Tee-Object -FilePath 'output\agentic\test.log'
```

- Poll the log with `Get-Content output\agentic\test.log -Tail 20` rather than re-running the build.
