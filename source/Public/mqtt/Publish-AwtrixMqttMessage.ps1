<#
    .SYNOPSIS
        Publishes a message to an MQTT broker used by AWTRIX NG.

    .DESCRIPTION
        Creates a short-lived MQTTnet client, publishes a string or JSON payload,
        disconnects cleanly, and returns the MQTT publish result.

    .PARAMETER BrokerHost
        Specifies the host name or IP address of the MQTT broker.

    .PARAMETER Port
        Specifies the TCP port exposed by the MQTT broker.

    .PARAMETER Topic
        Specifies the MQTT topic, including the AWTRIX device prefix.

    .PARAMETER Payload
        Specifies a string payload or an object that will be serialized to JSON.

    .PARAMETER Credential
        Specifies the optional MQTT user name and password.

    .PARAMETER Retain
        Requests that the MQTT broker retain the published message.

    .EXAMPLE
        Publish-AwtrixMqttMessage -BrokerHost localhost -Topic 'awtrix_123/custom/build' -Payload @{ text = 'Ready' }
#>
function Publish-AwtrixMqttMessage
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $BrokerHost,

        [Parameter()]
        [ValidateRange(1, 65535)]
        [System.Int32]
        $Port = 1883,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Topic,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.Object]
        $Payload,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Retain
    )

    if ($PSCmdlet.ShouldProcess("$BrokerHost`:$Port/$Topic", 'Publish MQTT message'))
    {
        $null = Initialize-AwtrixMqttNet
        $factory = [MQTTnet.MqttFactory]::new()
        $client = $factory.CreateMqttClient()
        $clientId = 'psawtrixng-{0}' -f [System.Guid]::NewGuid().ToString('N')
        $optionsBuilder = [MQTTnet.Client.MqttClientOptionsBuilder]::new().
            WithClientId($clientId).
            WithTcpServer($BrokerHost, $Port)

        if ($Credential)
        {
            $password = $Credential.GetNetworkCredential().Password
            $null = $optionsBuilder.WithCredentials($Credential.UserName, $password)
        }

        $options = $optionsBuilder.Build()
        $payloadValue = if ($Payload -is [System.String])
        {
            $Payload
        }
        else
        {
            $jsonObject = ConvertTo-AwtrixJsonObject -InputObject $Payload
            ConvertTo-Json -InputObject $jsonObject -Depth 20 -Compress
        }

        $message = [MQTTnet.MqttApplicationMessageBuilder]::new().
            WithTopic($Topic).
            WithPayload($payloadValue).
            WithRetainFlag($Retain.IsPresent).
            Build()

        try
        {
            $cancellationToken = [System.Threading.CancellationToken]::None
            $null = $client.ConnectAsync($options, $cancellationToken).GetAwaiter().GetResult()
            $client.PublishAsync($message, $cancellationToken).GetAwaiter().GetResult()
        }
        finally
        {
            if ($client.IsConnected)
            {
                $disconnectOptions = $factory.CreateClientDisconnectOptionsBuilder().Build()
                $null = $client.DisconnectAsync($disconnectOptions, [System.Threading.CancellationToken]::None).GetAwaiter().GetResult()
            }

            $client.Dispose()
        }
    }
}
