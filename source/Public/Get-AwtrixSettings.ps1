<#
    .SYNOPSIS
        Gets the current AWTRIX NG display settings.

    .DESCRIPTION
        Reads the AWTRIX settings endpoint without changing device configuration
        and returns the firmware-defined settings object.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Get-AwtrixSettings -Device 'clock.local'
#>
function Get-AwtrixSettings
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'The AWTRIX endpoint and returned object represent the complete settings collection.')]
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device
    )

    process
    {
        Invoke-AwtrixApi -Device $Device -Path 'api/v1/settings'
    }
}
