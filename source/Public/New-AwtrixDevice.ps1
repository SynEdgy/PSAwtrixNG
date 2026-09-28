<#
    .SYNOPSIS
        Creates a reusable AWTRIX NG device connection object.

    .DESCRIPTION
        Creates a typed connection object containing the AWTRIX host URI, optional
        basic-authentication credential, friendly name, and HTTP timeout.

    .PARAMETER HostName
        Specifies the AWTRIX host name, IP address, or absolute HTTP or HTTPS URI.

    .PARAMETER Name
        Specifies a friendly name used to identify the connection object.

    .PARAMETER Credential
        Specifies the basic-authentication credential configured in the AWTRIX web interface.

    .PARAMETER TimeoutSec
        Specifies the maximum number of seconds allowed for each HTTP API request.

    .EXAMPLE
        $clock = New-AwtrixDevice -HostName 'clock.local' -Name 'DeskClock'
#>
function New-AwtrixDevice
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('Host', 'IpAddress', 'Uri')]
        [System.String]
        $HostName,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter()]
        [ValidateRange(1, 300)]
        [System.Int32]
        $TimeoutSec = 10
    )

    process
    {
        if (-not $PSCmdlet.ShouldProcess($HostName, 'Create AWTRIX device connection object'))
        {
            return
        }

        $device = Resolve-AwtrixDevice -Device $HostName
        if ($Name)
        {
            $device.Name = $Name
        }

        $device.Credential = $Credential
        $device.TimeoutSec = $TimeoutSec
        $device
    }
}
