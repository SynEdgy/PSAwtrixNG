# Implementation roadmap

## Goals

Build a reliable PowerShell interface for AWTRIX NG that supports ordinary
device administration, pushed content, and on-device Berry applications.
The first demonstrator application will be a stopwatch that can run without a
continuously connected PowerShell process.

The available TC001 currently runs AWTRIX 3. Live-device validation is deferred
until it has deliberately been backed up and flashed with AWTRIX NG. Development
must use mocks and the AWTRIX NG simulator in the meantime.

## Milestone 1: Foundation

- Remove or replace the generated sample commands and classes.
- Define the supported PowerShell editions and operating systems.
- Add device and connection types without exposing credentials.
- Implement URI normalization and a shared HTTP request helper.
- Model AWTRIX NG's structured API errors.
- Add unit tests for transport-independent behavior.

**Exit criterion:** the module can retrieve `/api/v1/version` and
`/api/v1/device` and return stable PowerShell objects.

## Milestone 2: Core device control

- Read and update settings.
- Enable and disable the matrix.
- List applications and switch the active application.
- Manage indicators and other reversible display controls.
- Require explicit approval for reboot, sleep, reset, firmware, network, and
  authentication operations.

**Exit criterion:** common device operations work without requiring direct
calls to `Invoke-RestMethod`.

## Milestone 3: Pushed content

- Create, update, inspect, and remove pushed apps.
- Send and dismiss notifications.
- Represent text, colors, icons, charts, effects, and drawing instructions.
- Preserve access to advanced payload fields without weakening validation.

**Exit criterion:** a complete pushed-app lifecycle is covered by unit and
opt-in live-device tests.

## Milestone 4: Berry scripts

- List installed scripts and their state.
- Install and update raw Berry source.
- Activate, deactivate, configure, and remove scripts.
- Surface compile and runtime errors with source-line and lifecycle-hook
  information.
- Support script files as pipeline input.

**Exit criterion:** the module can deploy a script, verify that it loaded, and
remove it safely.

## Milestone 5: MQTT and callbacks

- Publish commands and subscribe to device state.
- Define structured event objects.
- Provide a documented convention for Berry scripts to publish application
  events.
- Exercise a button callback from Berry through MQTT to PowerShell.

**Exit criterion:** pressing the select button in a test script produces a
typed event that PowerShell can receive.

## Milestone 6: Stopwatch application

- Implement an on-device Berry stopwatch using `now_ms()`.
- Toggle start and pause through the select button.
- Support reset through a documented API or MQTT command.
- Persist only the state needed to recover safely after restart.
- Package the script as a module asset with installation and removal commands.

**Exit criterion:** the stopwatch continues operating without a PowerShell
process and can be managed through the module.

## Cross-cutting work

- Generate command help and WikiSource documentation.
- Test Windows PowerShell compatibility before declaring it supported.
- Test PowerShell 7 on Windows, Linux, and macOS.
- Keep live-device mutation tests opt-in and reversible.
- Track third-party notices for packaged dependencies.

## Deferred decisions

- Whether AWTRIX NG support should require PowerShell 7 or retain Windows
  PowerShell 5.1 compatibility.
- Whether MQTT support should embed MQTTnet or initially rely on an external
  broker/client.
- Whether Berry application assets should be generic resources or have
  dedicated commands for first-party applications.
