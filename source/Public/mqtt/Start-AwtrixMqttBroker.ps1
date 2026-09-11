<#
    .SYNOPSIS
        Starts an in-process MQTT broker for AWTRIX NG.

    .DESCRIPTION
        Starts a background MQTTnet broker inside the current PowerShell process.
        The broker remains available until stopped or until the process exits.

    .PARAMETER Name
        Specifies the name used to identify the in-process broker instance.

    .PARAMETER Port
        Specifies the TCP port on which the MQTT broker listens.

    .EXAMPLE
        Start-AwtrixMqttBroker -Name LocalAwtrix -Port 1883
#>
function Start-AwtrixMqttBroker
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [ValidatePattern('^[A-Za-z0-9_.-]+$')]
        [System.String]
        $Name = 'default',

        [Parameter()]
        [ValidateRange(1, 65535)]
        [System.Int32]
        $Port = 1883
    )

    if ($script:AwtrixMqttBrokers.ContainsKey($Name))
    {
        throw "An AWTRIX MQTT broker named '$Name' is already running."
    }

    if ($PSCmdlet.ShouldProcess("0.0.0.0:$Port", "Start AWTRIX MQTT broker '$Name'"))
    {
        $null = Initialize-AwtrixMqttNet
        $factory = [MQTTnet.MqttFactory]::new()
        $options = [MQTTnet.Server.MqttServerOptionsBuilder]::new().
            WithDefaultEndpoint().
            WithDefaultEndpointPort($Port).
            Build()
        $server = $factory.CreateMqttServer($options)
        $capture = [PSAwtrixNG.Mqtt.MqttBrokerCapture]::new()
        $capture.Attach($server)

        $server.StartAsync().GetAwaiter().GetResult()

        $broker = [PSCustomObject] @{
            PSTypeName = 'PSAwtrixNG.MqttBroker'
            Name       = $Name
            Port       = $Port
            StartedAt  = [System.DateTimeOffset]::Now
            Server     = $server
            Capture    = $capture
        }

        $script:AwtrixMqttBrokers[$Name] = $broker
        $broker
    }
}
