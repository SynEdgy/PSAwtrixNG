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
- An on-device stopwatch with select-button start/pause, a three-press local
  reset sequence, hundredths-of-a-second display, and optional MQTT reset/state
  topics.
- MQTT stopwatch control commands for idempotent start and pause, plus toggle,
  reset, and restart.
- An end-to-end MQTT stopwatch walkthrough covering the PowerShell broker,
  AWTRIX NG system configuration, reboot, app selection, control commands, and
  captured state messages.
- GIF and JPEG icon upload, listing, ID resolution, download, and removal
  commands, including device storage preflight and upload verification.
- `Get-AwtrixStorage` for total, used, and free shared filesystem capacity.
- Commands to disable and enable automatic app-to-app rotation.
- `Set-AwtrixBrightness` with absolute 0–100 percentages and constrained
  relative increase or decrease adjustments.
- `Get-AwtrixBrightness` with normalized percentage, native firmware value,
  and automatic-brightness state.
- Typed `AwtrixApp`, `AwtrixNotification`, and `AwtrixScroll` payload classes
  with bare and module-qualified type accelerators and canonical JSON property
  casing.
- Bundled static and animated GIF assets copied into the packaged module for
  use in notifications and pushed-app cards, including white terminal and
  compact PowerShell icons.
- `Get-AwtrixFile` for Get-ChildItem-style listing of the ICONS, MELODIES,
  PALETTES, and MP3 asset directories.
- An in-process MQTTnet broker with PowerShell 5.1 and PowerShell 7 assets.

### Changed

- Renamed the module and all associated types, assemblies, documentation, and
  build artifacts from `synedgy.PSAwtrixNG` to `PSAwtrixNG`.
- Added declarative length validation for icon file names and their
  firmware-facing IDs.
- Corrected the bundled Minecraft icon filenames and changed their canvases
  from 32×8 backgrounds to 8×8 side icons.
