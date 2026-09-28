<#
    .SYNOPSIS
        Stops automatic AWTRIX NG app rotation.

    .DESCRIPTION
        Disables automatic app-to-app advancement by setting autoTransition to
        false. The currently displayed app remains visible until an app is
        selected manually or automatic rotation is enabled again.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Disable-AwtrixAppRotation -Device 'clock.local'
#>
function Disable-AwtrixAppRotation
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Void])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, 'Disable automatic AWTRIX app rotation'))
        {
            Set-AwtrixSetting -Device $resolvedDevice -Setting @{
                autoTransition = $false
            } -Confirm:$false
        }
    }
}
