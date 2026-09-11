<#
    .SYNOPSIS
        Receives messages captured by an in-process AWTRIX MQTT broker.

    .DESCRIPTION
        Drains MQTT messages published by AWTRIX devices or other clients since the
        previous receive call. An optional timeout waits for the first message.

    .PARAMETER BrokerName
        Specifies the name supplied to Start-AwtrixMqttBroker.

    .PARAMETER TimeoutSec
        Specifies how long to wait for the first available message before returning.

    .PARAMETER ParseJson
        Adds a Data property containing parsed JSON when the payload is valid JSON.

    .EXAMPLE
        Receive-AwtrixMqttMessage -BrokerName LocalAwtrix -TimeoutSec 5 -ParseJson
#>
function Receive-AwtrixMqttMessage
{
    [CmdletBinding()]
    [OutputType([System.Object], [System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [System.String]
        $BrokerName = 'default',

        [Parameter()]
        [ValidateRange(0, 3600)]
        [System.Int32]
        $TimeoutSec = 0,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $ParseJson
    )

    $broker = $script:AwtrixMqttBrokers[$BrokerName]

    if (-not $broker)
    {
        throw "No AWTRIX MQTT broker named '$BrokerName' is running."
    }

    if ($TimeoutSec -gt 0 -and $broker.Capture.Count -eq 0)
    {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        while ($broker.Capture.Count -eq 0 -and $stopwatch.Elapsed.TotalSeconds -lt $TimeoutSec)
        {
            Start-Sleep -Milliseconds 50
        }
    }

    $messages = $broker.Capture.Drain()

    if (-not $ParseJson)
    {
        return $messages
    }

    foreach ($message in $messages)
    {
        $data = $null

        if (-not [System.String]::IsNullOrWhiteSpace($message.Payload))
        {
            try
            {
                $data = ConvertFrom-Json -InputObject $message.Payload -ErrorAction Stop
            }
            catch [System.ArgumentException]
            {
                $data = $null
            }
        }

        [PSCustomObject] @{
            PSTypeName            = 'PSAwtrixNG.MqttMessage'
            ClientId              = $message.ClientId
            Topic                 = $message.Topic
            Payload               = $message.Payload
            PayloadBytes          = $message.PayloadBytes
            Data                  = $data
            QualityOfServiceLevel = $message.QualityOfServiceLevel
            Retain                = $message.Retain
            ReceivedAt            = $message.ReceivedAt
        }
    }
}
