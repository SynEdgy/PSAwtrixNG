# Getting started

## Requirements

- An Ulanzi TC001 or compatible device running AWTRIX NG
- Network access from the PowerShell host to the device

### PowerShell compatibility

| PowerShell | Edition | MQTTnet assets |
| --- | --- | --- |
| Windows PowerShell 5.1 | Desktop on .NET Framework 4.6.1 or later | `net461` |
| PowerShell 7 | Core | `netstandard2.0` |

Both editions support the HTTP commands and the in-process MQTT broker,
including JSON publishing and captured-message parsing.

## Install the module

Once the module is published to the PowerShell Gallery:

```powershell
Install-PSResource -Name PSAwtrixNG
```

For local development, build and import the generated module:

```powershell
.\build.ps1 -Tasks build

$manifestParameters = @{
    Path    = '.\output\module\PSAwtrixNG'
    Filter  = 'PSAwtrixNG.psd1'
    Recurse = $true
}

$manifest = Get-ChildItem @manifestParameters |
    Select-Object -First 1

Import-Module -Name $manifest.FullName -Force
```

## Connect to a device

Create a reusable connection object:

```powershell
$deviceParameters = @{
    HostName = '192.168.1.50'
    Name     = 'DeskClock'
}

$clock = New-AwtrixDevice @deviceParameters
```

The host can be an IP address, DNS name, or absolute HTTP or HTTPS URI.

If authentication is enabled in the AWTRIX web interface, include a credential:

```powershell
$deviceParameters = @{
    HostName   = 'http://192.168.1.50'
    Credential = Get-Credential
}

$clock = New-AwtrixDevice @deviceParameters
```

## Verify connectivity

These commands only read device state:

```powershell
Get-AwtrixStatus -Device $clock
Get-AwtrixSettings -Device $clock
Get-AwtrixScreen -Device $clock
Show-AwtrixScreen -Device $clock
```

Continue with [Using the HTTP API](HTTP-API.md) or [Using MQTT](MQTT.md).
