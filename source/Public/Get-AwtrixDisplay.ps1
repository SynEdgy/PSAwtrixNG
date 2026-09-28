<#
    .SYNOPSIS
        Gets the AWTRIX NG display state.

    .DESCRIPTION
        Returns matrix power, brightness, overlay, and moodlight state.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Get-AwtrixDisplay -Device 'clock.local'
#>
function Get-AwtrixDisplay
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
        Invoke-AwtrixApi -Device $Device -Path 'api/v1/display'
    }
}
