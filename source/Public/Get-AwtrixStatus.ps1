<#
    .SYNOPSIS
        Gets the current AWTRIX NG device statistics.

    .DESCRIPTION
        Reads the AWTRIX stats endpoint and returns firmware, battery, sensor,
        memory, Wi-Fi, brightness, active app, and matrix state information.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Get-AwtrixStatus -Device 'clock.local'
#>
function Get-AwtrixStatus
{
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
        Invoke-AwtrixApi -Device $Device -Path 'api/v1/device'
    }
}
