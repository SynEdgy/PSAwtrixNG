# Documentation

`synedgy.PSAwtrixNG` provides PowerShell commands for AWTRIX NG devices. It
targets the AWTRIX NG `/api/v1` HTTP API, MQTT topics, and on-device Berry
script management.

## Project scope

The module is intended to cover:

- Device discovery, identity, health, and version information.
- Display settings and reversible display controls.
- Pushed applications and notifications.
- Berry script installation, configuration, activation, and removal.
- MQTT publishing, subscriptions, and script-generated events.
- Local development and explicitly enabled live-device testing.

AWTRIX 3 uses a different API and remains supported by the separate
`synedgy.PSAwtrix3` module. Compatibility shims between the two firmware
families are not planned for the initial implementation.

## Design principles

- Model the documented AWTRIX NG API rather than translating AWTRIX 3
  behavior.
- Use `ShouldProcess` for commands that change device state.
- Keep destructive operations explicit and difficult to invoke accidentally.
- Do not store device credentials or private addresses in tracked files.
- Keep HTTP transport, MQTT transport, and public command behavior separable
  and independently testable.
- Return structured PowerShell objects instead of formatted text.

## Development workflow

Use `build.ps1` for dependency restoration, builds, tests, and packaging:

```powershell
.\build.ps1 -ResolveDependency -Tasks noop
.\build.ps1 -Tasks build
.\build.ps1 -Tasks test
.\build.ps1 -Tasks pack
```

Planning material is maintained under [`docs/planning`](planning/README.md).

## References

- [AWTRIX NG documentation](https://blueforcer.github.io/awtrix-ng/)
- [AWTRIX NG source](https://github.com/Blueforcer/awtrix-ng)
- [HTTP API v1](https://blueforcer.github.io/awtrix-ng/reference/http/)
- [MQTT reference](https://blueforcer.github.io/awtrix-ng/reference/mqtt/)
- [Berry scripting guide](https://blueforcer.github.io/awtrix-ng/guides/scripting/)
- [Sampler](https://github.com/gaelcolas/Sampler)

## Licensing

The PowerShell module is licensed under MIT. AWTRIX NG firmware is separately
licensed under PolyForm Noncommercial 1.0.0. The module must not redistribute
AWTRIX NG firmware or imply that its MIT license applies to the firmware.
