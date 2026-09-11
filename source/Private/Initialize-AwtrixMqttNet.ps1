$script:AwtrixMqttBrokers = @{}

<#
    .SYNOPSIS
        Loads the packaged MQTTnet assembly for the current PowerShell runtime.

    .DESCRIPTION
        Selects the compatible packaged MQTTnet target framework, loads the assembly
        once, and returns the MQTT factory type used by broker and publisher commands.

    .EXAMPLE
        Initialize-AwtrixMqttNet
#>
function Initialize-AwtrixMqttNet
{
    [CmdletBinding()]
    [OutputType([System.Type])]
    param ()

    $mqttFactoryType = 'MQTTnet.MqttFactory' -as [System.Type]

    $captureType = 'PSAwtrixNG.Mqtt.MqttBrokerCapture' -as [System.Type]

    if ($mqttFactoryType -and $captureType)
    {
        return $mqttFactoryType
    }

    $frameworkDirectory = if ($PSVersionTable.PSEdition -eq 'Desktop')
    {
        'net461'
    }
    else
    {
        'netstandard2.0'
    }

    $assemblyPath = Join-Path -Path $PSScriptRoot -ChildPath 'lib'
    $assemblyPath = Join-Path -Path $assemblyPath -ChildPath $frameworkDirectory
    $assemblyPath = Join-Path -Path $assemblyPath -ChildPath 'MQTTnet.dll'
    $assemblyPath = [System.IO.Path]::GetFullPath($assemblyPath)

    if (-not (Test-Path -LiteralPath $assemblyPath -PathType Leaf))
    {
        throw "The MQTTnet assembly was not found at '$assemblyPath'. Rebuild or reinstall the module."
    }

    Add-Type -Path $assemblyPath -ErrorAction Stop

    $captureAssemblyPath = Join-Path -Path (Split-Path -Path $assemblyPath -Parent) -ChildPath 'PSAwtrixNG.Mqtt.dll'

    if (-not (Test-Path -LiteralPath $captureAssemblyPath -PathType Leaf))
    {
        throw "The MQTT broker capture assembly was not found at '$captureAssemblyPath'. Rebuild or reinstall the module."
    }

    Add-Type -Path $captureAssemblyPath -ErrorAction Stop

    'MQTTnet.MqttFactory' -as [System.Type]
}
