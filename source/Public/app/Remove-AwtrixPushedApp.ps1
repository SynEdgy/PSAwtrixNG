<#
    .SYNOPSIS
        Removes an AWTRIX NG pushed app.

    .DESCRIPTION
        Deletes the named pushed application from the AWTRIX NG app inventory.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Name
        Specifies the pushed app name to remove from the application inventory.

    .EXAMPLE
        Remove-AwtrixPushedApp -Device '192.168.88.202' -Name build
#>
function Remove-AwtrixPushedApp
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

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Remove AWTRIX pushed app '$Name'"))
        {
            Invoke-AwtrixApi -Device $resolvedDevice -Path "api/v1/apps/$Name" -Method Delete -Confirm:$false
        }
    }
}
