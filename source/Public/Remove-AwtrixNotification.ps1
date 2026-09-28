<#
    .SYNOPSIS
        Dismisses the active AWTRIX NG notification.

    .DESCRIPTION
        Dismisses the currently displayed notification, including a notification
        sent with the hold property enabled.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Remove-AwtrixNotification -Device 'clock.local'
#>
function Remove-AwtrixNotification
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, 'Dismiss the active AWTRIX notification'))
        {
            $invokeParameters = @{
                Device  = $resolvedDevice
                Path    = 'api/v1/notifications/active'
                Method  = 'Delete'
                Confirm = $false
            }

            Invoke-AwtrixApi @invokeParameters
        }
    }
}
