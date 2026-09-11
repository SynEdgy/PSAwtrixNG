<#
    .SYNOPSIS
        Gets stored configuration for an AWTRIX NG script app.

    .DESCRIPTION
        Returns configuration values declared by and stored for the named Berry
        script application.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the script app name.

    .EXAMPLE
        Get-AwtrixScriptConfiguration -Device '192.168.88.202' -Name Weather
#>
function Get-AwtrixScriptConfiguration
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
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
        Invoke-AwtrixApi -Device $Device -Path "api/v1/apps/$Name/config"
    }
}
