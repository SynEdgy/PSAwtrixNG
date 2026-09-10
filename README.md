# synedgy.PSAwtrixNG

`synedgy.PSAwtrixNG` is a PowerShell module for managing and automating
[AWTRIX NG](https://github.com/Blueforcer/awtrix-ng) devices.

The module is being developed independently from
[`synedgy.PSAwtrix3`](https://github.com/SynEdgy/synedgy.PSAwtrix3) because
AWTRIX NG is a rewrite with a new `/api/v1` contract and on-device Berry
scripting.

## Planned capabilities

- Discover devices and retrieve device state.
- Manage settings, display state, indicators, pushed apps, and notifications.
- Install, update, activate, configure, and remove Berry scripts.
- Publish and receive MQTT messages, including events emitted by scripts.
- Provide safe live-device tests that keep destructive operations opt-in.

See [the project documentation](docs/README.md) and
[the implementation roadmap](docs/planning/README.md).

## Development

Bootstrap dependencies and build the module through Sampler:

```powershell
.\build.ps1 -ResolveDependency -Tasks noop
.\build.ps1 -Tasks build
.\build.ps1 -Tasks test
```

## License

This PowerShell module is licensed under the [MIT License](LICENSE).
AWTRIX NG itself has a separate
[PolyForm Noncommercial 1.0.0 license](https://github.com/Blueforcer/awtrix-ng/blob/main/LICENSE.md).
