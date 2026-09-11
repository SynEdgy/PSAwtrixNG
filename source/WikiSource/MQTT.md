# Using MQTT

AWTRIX devices are MQTT clients. They must connect to a separate broker before
MQTT commands and telemetry can flow.

The module can run an MQTTnet broker inside the current PowerShell process. It
does not install a service, persist configuration, or automatically change the
clock's MQTT settings.

The packaged module selects `net461` MQTTnet assets under Windows PowerShell
5.1 and `netstandard2.0` assets under PowerShell 7.

## Start a broker

```powershell
$broker = Start-AwtrixMqttBroker -Name LocalAwtrix -Port 1883
```

Configure the AWTRIX device through its web interface to connect to the
PowerShell host and selected port.

## Publish a message

Use the MQTT prefix configured on the device:

```powershell
$publishParameters = @{
    BrokerHost = 'localhost'
    Topic      = '9451dc9d5820/cmd/apps/pushed/build'
    Payload    = @{
        text      = 'Ready'
        textColor = '#00FF00'
    }
}

Publish-AwtrixMqttMessage @publishParameters
```

Common AWTRIX topics include:

| Topic suffix | Purpose |
| --- | --- |
| `cmd/notifications` | Display a notification |
| `cmd/apps/pushed/<name>` | Create or update a pushed application |
| `cmd/settings` | Update display settings |
| `cmd/display` | Change display state |
| `cmd/apps/active` | Switch the current application |
| `state/device` | Receive device state |
| `state/screen` | Receive screen data |

Command results are published below the corresponding `cmd/.../result` topic.
The default prefix is the device MAC address in lowercase without separators
unless `mqttPrefix` is configured.

## Receive captured messages

```powershell
$receiveParameters = @{
    BrokerName = 'LocalAwtrix'
    TimeoutSec = 5
    ParseJson  = $true
}

Receive-AwtrixMqttMessage @receiveParameters
```

Messages are drained from the broker capture queue. With `-ParseJson`, valid
JSON payloads are also exposed through a `Data` property.

## Stop the broker

```powershell
Stop-AwtrixMqttBroker -Name LocalAwtrix
```

The broker also stops when its PowerShell process exits.

For a complete example that configures AWTRIX NG and controls the on-device
stopwatch, see the [MQTT stopwatch walkthrough](MQTT-Stopwatch-Walkthrough.md).
