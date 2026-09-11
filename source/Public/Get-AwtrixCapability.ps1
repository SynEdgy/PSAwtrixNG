<#
    .SYNOPSIS
        Gets capabilities reported by an AWTRIX NG device.

    .DESCRIPTION
        Returns supported effects, transitions, overlays, palettes, audio
        hardware, and GPIO capability metadata.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Get-AwtrixCapability -Device '192.168.88.202'
#>
function Get-AwtrixCapability
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
        Invoke-AwtrixApi -Device $Device -Path 'api/v1/capabilities'
    }
}
