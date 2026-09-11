<#
    .SYNOPSIS
        Gets in-process AWTRIX MQTT broker instances.

    .DESCRIPTION
        Returns MQTTnet broker instances started by Start-AwtrixMqttBroker in the
        current PowerShell process.

    .PARAMETER Name
        Specifies the broker name to return. All brokers are returned when omitted.

    .EXAMPLE
        Get-AwtrixMqttBroker -Name LocalAwtrix
#>
function Get-AwtrixMqttBroker
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [System.String]
        $Name
    )

    if ($Name)
    {
        return $script:AwtrixMqttBrokers[$Name]
    }

    $script:AwtrixMqttBrokers.Values
}
