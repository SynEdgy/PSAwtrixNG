<#
    .SYNOPSIS
        Installs an on-device stopwatch app on AWTRIX NG.

    .DESCRIPTION
        Installs a Berry app that runs entirely on the device. Press the select
        button to start or pause it. Press select three times, with each press
        between 350 and 1200 milliseconds apart, to reset it without MQTT.
        The display includes hundredths of a second in m:ss.hh format.
        When MQTT is configured, ControlTopic accepts start, pause, toggle,
        reset, and restart commands. Publishing any payload to ResetTopic also
        resets the stopwatch.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the installed script app name.

    .PARAMETER ResetTopic
        Specifies the MQTT topic that resets the stopwatch.

    .PARAMETER ControlTopic
        Specifies the MQTT topic that accepts start, pause, toggle, reset, and
        restart commands.

    .PARAMETER StateTopic
        Specifies the MQTT topic used to publish running, paused, and reset events.

    .EXAMPLE
        Install-AwtrixStopwatch -Device 'clock.local'
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
        $ControlTopic = 'awtrix/stopwatch/control',

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

        $sourceParameters = @{
            Name  = 'Stopwatch'
            Token = @{
                APP_NAME      = $Name
                RESET_TOPIC   = $ResetTopic
                CONTROL_TOPIC = $ControlTopic
                STATE_TOPIC   = $StateTopic
            }
        }
        $source = Get-AwtrixBerryAppSource @sourceParameters

        Set-AwtrixScript -Device $resolvedDevice -Name $Name -Source $source -Confirm:$false
    }
}
