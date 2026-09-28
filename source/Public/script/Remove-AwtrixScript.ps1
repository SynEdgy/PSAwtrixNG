<#
    .SYNOPSIS
        Removes an AWTRIX NG Berry script app.

    .DESCRIPTION
        Deletes the named script application and its registration from the
        AWTRIX NG application inventory.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the script app name.

    .EXAMPLE
        Remove-AwtrixScript -Device 'clock.local' -Name Stopwatch
#>
function Remove-AwtrixScript
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
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
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device
        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Remove Berry script '$Name'"))
        {
            Invoke-AwtrixApi -Device $resolvedDevice -Path "api/v1/apps/$Name" -Method Delete -Confirm:$false
        }
    }
}
