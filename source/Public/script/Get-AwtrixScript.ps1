<#
    .SYNOPSIS
        Gets the Berry source of an AWTRIX NG script app.

    .DESCRIPTION
        Downloads and returns the raw Berry source currently installed for the
        named script application.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the script app name.

    .EXAMPLE
        Get-AwtrixScript -Device '192.168.88.202' -Name Stopwatch
#>
function Get-AwtrixScript
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]{1,32}$')]
        [System.String]
        $Name
    )

    process
    {
        Invoke-AwtrixApi -Device $Device -Path "api/v1/apps/script/$Name"
    }
}
