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
- Manage settings, display power, indicators, pushed apps, and notifications.
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

## License

This PowerShell module is licensed under the [MIT License](LICENSE).
AWTRIX NG itself has a separate
[PolyForm Noncommercial 1.0.0 license](https://github.com/Blueforcer/awtrix-ng/blob/main/LICENSE.md).
