<#
    .SYNOPSIS
        Resolves an AWTRIX device input into a connection object.

    .DESCRIPTION
        Normalizes a host string, IP address, URI, or existing AWTRIX connection
        object into the internal typed connection representation used by HTTP calls.

    .PARAMETER Device
        Specifies the device value that must be normalized for an internal operation.

    .EXAMPLE
        Resolve-AwtrixDevice -Device '192.0.2.10'
#>
function Resolve-AwtrixDevice
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Device
    )

    if ($Device.PSTypeNames -contains 'PSAwtrixNG.Device')
    {
        return $Device
    }

    if ($Device -isnot [System.String])
    {
        throw 'Device must be a host name, IP address, URI, or an object returned by New-AwtrixDevice.'
    }

    $deviceValue = $Device.Trim()

    if ($deviceValue -notmatch '^[a-z][a-z0-9+.-]*://')
    {
        $deviceValue = 'http://{0}' -f $deviceValue
    }

    $uri = $null

    if (-not [System.Uri]::TryCreate($deviceValue, [System.UriKind]::Absolute, [ref] $uri))
    {
        throw "Device '$Device' is not a valid host name, IP address, or absolute URI."
    }

    [PSCustomObject] @{
        PSTypeName = 'PSAwtrixNG.Device'
        Name       = $uri.Host
        BaseUri    = $uri
        Credential = $null
        TimeoutSec = 10
    }
}
