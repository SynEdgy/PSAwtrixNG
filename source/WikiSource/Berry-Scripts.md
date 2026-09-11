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

Press the **select** button to start or pause. Left and right retain normal app
navigation. The paused elapsed time is persisted by the device.

When MQTT is configured, reset the stopwatch and receive state changes:

```powershell
$publishParameters = @{
    BrokerHost = 'broker.local'
    Topic      = 'awtrix/stopwatch/reset'
    Payload    = 'reset'
}
Publish-AwtrixMqttMessage @publishParameters

Receive-AwtrixMqttMessage -BrokerName LocalAwtrix -TimeoutSec 30
```

By default the app publishes `running`, `paused`, and `reset` to
`awtrix/stopwatch/state`. Use `-ResetTopic` and `-StateTopic` during
installation to choose different topics.
