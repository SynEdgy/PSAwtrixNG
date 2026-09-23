# PSAwtrixNG

`PSAwtrixNG` is a PowerShell module for managing and automating
[AWTRIX NG](https://github.com/Blueforcer/awtrix-ng) devices.

The module is being developed independently from
[`synedgy.PSAwtrix3`](https://github.com/SynEdgy/synedgy.PSAwtrix3) because
AWTRIX NG is a rewrite with a new `/api/v1` contract and on-device Berry
scripting.

## Capabilities

- Read device, settings, display, application, capability, and screen state.
- Render and continuously watch the live matrix in the terminal.
- Manage settings, read and adjust percentage-based brightness, control display
  power, and manage indicators, pushed apps, and notifications.
- Pause and resume automatic app-to-app display rotation.
- Upload, list, download, and remove GIF or JPEG icons with storage preflight.
- Report total, used, and free device filesystem space.
- Use the bundled static and animated GIF assets in notifications and app cards.
- Install, retrieve, configure, activate, and remove Berry scripts.
- Install an on-device stopwatch with select-button start/pause, a three-press
  local reset sequence, and optional MQTT start, pause, toggle, reset, and
  restart commands.
- Run an in-process MQTT broker and publish or capture MQTT messages.

## Quick start

```powershell
.\build.ps1 -Tasks build

$manifestParameters = @{
    Path    = '.\output\module\PSAwtrixNG'
    Filter  = 'PSAwtrixNG.psd1'
    Recurse = $true
}
$manifest = Get-ChildItem @manifestParameters |
    Select-Object -First 1
Import-Module $manifest.FullName -Force

$clock = New-AwtrixDevice -HostName '192.168.88.202' -Name DeskClock
Get-AwtrixStatus -Device $clock
Show-AwtrixScreen -Device $clock
Install-AwtrixStopwatch -Device $clock
Select-AwtrixApp -Device $clock -Name Stopwatch
```

See [the project documentation](docs/README.md) and
[the implementation roadmap](docs/planning/README.md).

## Development

Bootstrap dependencies and build the module through Sampler:

```powershell
.\build.ps1 -ResolveDependency -Tasks noop
.\build.ps1 -Tasks build
.\build.ps1 -Tasks test
.\build.ps1 -Tasks docs
```

GitHub Actions runs the Sampler build and package workflow, tests PowerShell 7
on Windows, Linux, and macOS, tests Windows PowerShell 5.1, and runs the module
quality checks. Pushes of `v*` tags publish the GitHub release, wiki
content, and PowerShell Gallery package, then open a pull request that moves
the released entries out of the changelog's Unreleased section.

Configure these repository Actions secrets before creating a release tag:

- `PSGALLERY_API_KEY`: PowerShell Gallery publishing API key.
- `RELEASE_PAT`: GitHub personal access token used by the Sampler release,
  wiki, branch push, and changelog pull request tasks. For a fine-grained token,
  grant this repository read/write access to Contents and Pull requests. A
  classic token requires the `repo` scope.

The dedicated PAT also allows the changelog branch push to trigger the normal
pull-request validation workflow; pushes made with the built-in
`GITHUB_TOKEN` do not trigger another workflow run.

## License

This PowerShell module is licensed under the [MIT License](LICENSE).
AWTRIX NG itself has a separate
[PolyForm Noncommercial 1.0.0 license](https://github.com/Blueforcer/awtrix-ng/blob/main/LICENSE.md).
