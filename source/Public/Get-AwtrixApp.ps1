<#
    .SYNOPSIS
        Gets applications registered on an AWTRIX NG device.

    .DESCRIPTION
        Returns built-in, pushed, script, and module applications, including
        whether each app is enabled, present, and included in the rotation.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Filters the returned applications by exact name.

    .EXAMPLE
        Get-AwtrixApp -Device 'clock.local'
#>
function Get-AwtrixApp
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name
    )

    process
    {
        $response = Invoke-AwtrixApi -Device $Device -Path 'api/v1/apps'
        $apps = @(
            foreach ($app in $response)
            {
                $app
            }
        )
        if ($PSBoundParameters.ContainsKey('Name'))
        {
            $apps | Where-Object { $_.name -ceq $Name }
        }
        else
        {
            $apps
        }
    }
}
