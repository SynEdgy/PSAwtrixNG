<#
    .SYNOPSIS
        Stops an in-process AWTRIX MQTT broker.

    .DESCRIPTION
        Stops and removes a broker instance previously created in the current
        PowerShell process by Start-AwtrixMqttBroker.

    .PARAMETER Name
        Specifies the name of the in-process MQTT broker to stop.

    .EXAMPLE
        Stop-AwtrixMqttBroker -Name LocalAwtrix
#>
function Stop-AwtrixMqttBroker
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Void])]
    param
    (
        [Parameter()]
        [System.String]
        $Name = 'default'
    )

    $broker = $script:AwtrixMqttBrokers[$Name]

    if (-not $broker)
    {
        throw "No AWTRIX MQTT broker named '$Name' is running."
    }

    if ($PSCmdlet.ShouldProcess("0.0.0.0:$($broker.Port)", "Stop AWTRIX MQTT broker '$Name'"))
    {
        $stopOptions = [MQTTnet.Server.MqttServerStopOptions]::new()
        $null = $broker.Server.StopAsync($stopOptions).GetAwaiter().GetResult()
        $broker.Server.Dispose()
        $script:AwtrixMqttBrokers.Remove($Name)
    }
}
