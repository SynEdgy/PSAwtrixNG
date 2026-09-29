# Berry scripts and stopwatch

AWTRIX NG can execute Berry applications on the device. They continue running
without a PowerShell process and can react to the three hardware buttons.

## Manage scripts

```powershell
$source = @'
# @name Hello
class Hello
  def draw()
    clear()
    text(9, 6, "Hello", 0x00FF00)
  end
end
return Hello()
'@

Set-AwtrixScript -Device $clock -Name Hello -Source $source
Get-AwtrixScript -Device $clock -Name Hello
Select-AwtrixApp -Device $clock -Name Hello
Remove-AwtrixScript -Device $clock -Name Hello
```

`Set-AwtrixScript` checks the error object returned by the firmware. A request
can have HTTP status 200 while the Berry compiler reports an error, so the
command throws when compilation fails.

Scripts declaring `# @config` fields can be managed with:

```powershell
Get-AwtrixScriptConfiguration -Device $clock -Name Weather
Set-AwtrixScriptConfiguration -Device $clock -Name Weather -Configuration @{
    city = 'London'
}
```

## Install the stopwatch

```powershell
Install-AwtrixStopwatch -Device $clock
Select-AwtrixApp -Device $clock -Name Stopwatch
```

Press the **select** button to start or pause. To reset locally, press select
**three times**, leaving roughly half a second between presses. Each gap must be
between 0.35 and 1.2 seconds. Do not rapid-double-click: AWTRIX NG reserves a
double press within 0.3 seconds for toggling display power.

The elapsed time is displayed as `minutes:seconds.hundredths`, for example
`1:23.45`.

Left and right retain normal app navigation. The paused elapsed time is
persisted by the device. While paused, the script reuses its cached display
text instead of rebuilding the time string on every display frame.

MQTT is optional. When configured, publish a command to
`awtrix/stopwatch/control`:

```powershell
$publishParameters = @{
    BrokerHost = 'broker.local'
    Topic      = 'awtrix/stopwatch/control'
    Payload    = 'start'
}
Publish-AwtrixMqttMessage @publishParameters

Receive-AwtrixMqttMessage -BrokerName LocalAwtrix -TimeoutSec 30
```

| Payload | Action |
|---|---|
| `start` | Starts the stopwatch if it is paused. |
| `pause` | Pauses the stopwatch if it is running. |
| `toggle` | Switches between running and paused. |
| `reset` | Resets to zero and pauses. |
| `restart` | Resets to zero and starts immediately. |

`start` and `pause` are idempotent, so repeated messages do not reverse the
requested state. The legacy `awtrix/stopwatch/reset` topic remains available;
any payload published to it resets and pauses the stopwatch.

By default the app publishes `running`, `paused`, and `reset` to
`awtrix/stopwatch/state`. Use `-ControlTopic`, `-ResetTopic`, and `-StateTopic`
during installation to choose different topics.
