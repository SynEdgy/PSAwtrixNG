<#
    .SYNOPSIS
        Installs an on-device stopwatch app on AWTRIX NG.

    .DESCRIPTION
        Installs a Berry app that runs entirely on the device. Press the select
        button to start or pause it. Press select three times, with each press
        between 350 and 1200 milliseconds apart, to reset it without MQTT.
        The display includes hundredths of a second in m:ss.hh format.
        Publishing any payload to ResetTopic also resets the stopwatch when MQTT
        is configured on the device.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the installed script app name.

    .PARAMETER ResetTopic
        Specifies the MQTT topic that resets the stopwatch.

    .PARAMETER StateTopic
        Specifies the MQTT topic used to publish running, paused, and reset events.

    .EXAMPLE
        Install-AwtrixStopwatch -Device '192.168.88.202'
#>
function Install-AwtrixStopwatch
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter()]
        [ValidatePattern('^[A-Za-z0-9_-]{1,32}$')]
        [System.String]
        $Name = 'Stopwatch',

        [Parameter()]
        [ValidatePattern('^[^"#\r\n]+$')]
        [System.String]
        $ResetTopic = 'awtrix/stopwatch/reset',

        [Parameter()]
        [ValidatePattern('^[^"#\r\n]+$')]
        [System.String]
        $StateTopic = 'awtrix/stopwatch/state'
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        if (-not $PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Install AWTRIX NG stopwatch '$Name'"))
        {
            return
        }

        $source = @"
# @name $Name
# @description Select starts or pauses; three paced presses reset.
class Stopwatch
  var running
  var started
  var elapsed
  var selectCount
  var lastSelect

  def init()
    self.running = false
    self.started = 0
    self.elapsed = store.get("elapsedMs", 0)
    self.selectCount = 0
    self.lastSelect = 0
  end

  def setup()
    mqtt.subscribe("$ResetTopic", def (topic, payload) self.reset() end)
  end

  def reset()
    self.running = false
    self.started = 0
    self.elapsed = 0
    self.selectCount = 0
    self.lastSelect = 0
    store.set("elapsedMs", 0)
    mqtt.publish("$StateTopic", "reset")
  end

  def on_button(btn)
    if btn == "select"
      var pressed = now_ms()
      var gap = pressed - self.lastSelect
      if self.lastSelect > 0 && gap >= 350 && gap <= 1200
        self.selectCount = self.selectCount + 1
      else
        self.selectCount = 1
      end
      self.lastSelect = pressed

      if self.selectCount >= 3
        self.reset()
        return
      end

      if self.running
        self.elapsed = self.elapsed + now_ms() - self.started
        self.running = false
        store.set("elapsedMs", self.elapsed)
        mqtt.publish("$StateTopic", "paused")
      else
        self.started = now_ms()
        self.running = true
        mqtt.publish("$StateTopic", "running")
      end
    end
  end

  def draw()
    clear()
    var elapsed = self.elapsed
    if self.running
      elapsed = elapsed + now_ms() - self.started
    end
    var total = int(elapsed / 1000)
    var minutes = int(total / 60)
    var seconds = total % 60
    var hundredths = int((elapsed % 1000) / 10)
    var secondsText = seconds < 10 ? "0" + str(seconds) : str(seconds)
    var hundredthsText = hundredths < 10 ? "0" + str(hundredths) : str(hundredths)
    var label = str(minutes) + ":" + secondsText + "." + hundredthsText
    var color = self.running ? 0x00FF00 : 0xFFAA00
    text((width() - text_ink_width(label)) / 2, 6, label, color)
  end

  def duration()
    return 60000
  end
end

return Stopwatch()
"@

        Set-AwtrixScript -Device $resolvedDevice -Name $Name -Source $source -Confirm:$false
    }
}
