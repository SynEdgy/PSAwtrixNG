# Changelog for PSAwtrixNG

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- AWTRIX NG `/api/v1` device, settings, display, screen, app, notification,
  indicator, and capability commands.
- NG-native pushed-app commands without AWTRIX 3 compatibility aliases.
- Dynamic terminal rendering for the dimensions reported by the device.
- Berry script upload, download, configuration, and removal commands.
- An on-device stopwatch with select-button control and MQTT reset/state topics.
- An in-process MQTTnet broker with PowerShell 5.1 and PowerShell 7 assets.

### Changed

- Renamed the module and all associated types, assemblies, documentation, and
  build artifacts from `synedgy.PSAwtrixNG` to `PSAwtrixNG`.
