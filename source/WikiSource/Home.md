# PSAwtrixNG

`PSAwtrixNG` provides PowerShell commands for controlling Ulanzi TC001
smart clocks and compatible devices running
[AWTRIX NG](https://github.com/Blueforcer/awtrix-ng).

The module supports the AWTRIX HTTP API and includes an in-process MQTT broker
for local automation and message capture.

## Start here

- [Getting started](Getting-Started.md)
- [Using the HTTP API](HTTP-API.md)
- [Using MQTT](MQTT.md)
- [MQTT stopwatch walkthrough](MQTT-Stopwatch-Walkthrough.md)
- [Icons and files](Icons-and-Files.md)
- [Berry scripts and stopwatch](Berry-Scripts.md)
- [Safety and testing](Safety-and-Testing.md)
- Browse the generated command pages in the wiki sidebar for complete parameter
  and example documentation.

## Quick example

```powershell
$clock = New-AwtrixDevice -HostName '192.168.1.50' -Name 'DeskClock'

Get-AwtrixStatus -Device $clock
Get-AwtrixSettings -Device $clock
Show-AwtrixScreen -Device $clock
Send-AwtrixNotification -Device $clock -Text 'Hello from PowerShell'
```

State-changing commands support PowerShell's `-WhatIf` behavior. Potentially
destructive generic API operations require an additional explicit opt-in.

## Project links

- [Source repository](https://github.com/SynEdgy/PSAwtrixNG)
- [AWTRIX NG documentation](https://blueforcer.github.io/awtrix-ng/)
- [Report a problem](https://github.com/SynEdgy/PSAwtrixNG/issues)
