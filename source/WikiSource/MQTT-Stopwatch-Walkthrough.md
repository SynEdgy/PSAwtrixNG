# MQTT stopwatch walkthrough

This walkthrough starts the in-process PowerShell MQTT broker, points an
AWTRIX NG device at it, selects the Stopwatch app through MQTT, and controls the
stopwatch through its Berry MQTT subscription.

The broker runs only while its PowerShell process remains open. It listens on
all network interfaces without authentication or TLS, so use it only on a
trusted local network.

## Prerequisites

- The PowerShell computer and AWTRIX NG device must be reachable on the same
  network.
- Windows Firewall or another host firewall must allow inbound TCP traffic on
  the selected broker port.
- Use the PowerShell computer's LAN address as the broker host. Do not configure
  the clock with `localhost`, because that would refer to the clock itself.

The examples use these values:

```powershell
$clock = New-AwtrixDevice -HostName '192.168.88.202' -Name 'DeskClock'
$brokerHost = '192.168.88.100'
$brokerPort = 1883
$mqttPrefix = 'deskclock'
```

Replace `$brokerHost` with the LAN address of the computer running PowerShell.
Give each AWTRIX device a unique `$mqttPrefix`.

## Install the stopwatch

Install the script over HTTP before configuring MQTT. Keeping the script topics
under the device prefix makes them easy to identify on a shared broker:

```powershell
$installParameters = @{
    Device       = $clock
    Name         = 'Stopwatch'
    ControlTopic = "$mqttPrefix/stopwatch/control"
    ResetTopic   = "$mqttPrefix/stopwatch/reset"
    StateTopic   = "$mqttPrefix/stopwatch/state"
}
Install-AwtrixStopwatch @installParameters
```

## Start the PowerShell broker

Start the broker in the PowerShell process that will remain open:

```powershell
$broker = Start-AwtrixMqttBroker -Name 'LocalAwtrix' -Port $brokerPort
$broker
```

`Get-AwtrixMqttBroker -Name LocalAwtrix` returns the running broker later in the
same PowerShell session.

## Configure MQTT on AWTRIX NG

`Set-AwtrixSetting` changes display settings and does not configure MQTT.
PSAwtrixNG does not currently have a dedicated MQTT configuration command, but
the system configuration API is available through `Invoke-AwtrixApi`:

```powershell
$mqttConfiguration = @{
    mqttEnabled = $true
    mqttHost    = $brokerHost
    mqttPort    = $brokerPort
    mqttPrefix  = $mqttPrefix
}

$configurationRequest = @{
    Device = $clock
    Path   = 'api/v1/system'
    Method = 'Put'
    Body   = $mqttConfiguration
}
Invoke-AwtrixApi @configurationRequest
```

AWTRIX NG reads MQTT connection settings at startup, so reboot the device after
changing them. Reboot is intentionally protected as a dangerous operation:

```powershell
$rebootRequest = @{
    Device                  = $clock
    Path                    = 'api/v1/device/reboot'
    Method                  = 'Post'
    AllowDangerousOperation = $true
}
Invoke-AwtrixApi @rebootRequest
```

Wait for the device to return, then inspect its MQTT connection:

```powershell
Start-Sleep -Seconds 8
(Get-AwtrixStatus -Device $clock).mqtt
```

The MQTT state should be `connected`. If it is not, check `error`, confirm that
`$brokerHost` is reachable from the clock, and check the host firewall.

## Select the Stopwatch through MQTT

AWTRIX NG native commands are below `<prefix>/cmd/`. Select the Stopwatch app
with the native `apps/switch` command:

```powershell
$selectParameters = @{
    BrokerHost = $brokerHost
    Port       = $brokerPort
    Topic      = "$mqttPrefix/cmd/apps/switch"
    Payload    = @{
        name = 'Stopwatch'
        fast = $true
    }
}
Publish-AwtrixMqttMessage @selectParameters
```

## Start, pause, and reset the stopwatch

The stopwatch control topic accepts lowercase command payloads:

```powershell
$controlParameters = @{
    BrokerHost = $brokerHost
    Port       = $brokerPort
    Topic      = "$mqttPrefix/stopwatch/control"
}

Publish-AwtrixMqttMessage @controlParameters -Payload 'start'
Start-Sleep -Seconds 3
Publish-AwtrixMqttMessage @controlParameters -Payload 'pause'
```

Other supported payloads are:

| Payload | Action |
|---|---|
| `start` | Starts if paused; does nothing if already running. |
| `pause` | Pauses if running; does nothing if already paused. |
| `toggle` | Switches between running and paused. |
| `reset` | Resets to `0:00.00` and pauses. |
| `restart` | Resets to `0:00.00` and starts immediately. |

For example:

```powershell
Publish-AwtrixMqttMessage @controlParameters -Payload 'restart'
```

## Inspect captured messages

The in-process broker captures messages published by AWTRIX NG, including
stopwatch state changes:

```powershell
$receiveParameters = @{
    BrokerName = 'LocalAwtrix'
    TimeoutSec = 5
}
Receive-AwtrixMqttMessage @receiveParameters |
    Where-Object Topic -eq "$mqttPrefix/stopwatch/state"
```

The stopwatch publishes `running`, `paused`, or `reset`. Native AWTRIX command
results are published below the command topic, such as
`$mqttPrefix/cmd/apps/switch/result`.

## Stop the broker

```powershell
Stop-AwtrixMqttBroker -Name 'LocalAwtrix'
```

Stopping the broker disconnects the clock. To disable MQTT on the device,
write `mqttEnabled = $false` to `api/v1/system` and reboot it again.
