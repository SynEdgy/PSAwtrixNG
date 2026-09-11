<#
    .SYNOPSIS
        Starts automatic AWTRIX NG app rotation.

    .DESCRIPTION
        Enables automatic app-to-app advancement by setting autoTransition to
        true. Apps advance using the configured app duration and transition
        settings.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Enable-AwtrixAppRotation -Device '192.168.88.202'
#>
function Enable-AwtrixAppRotation
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

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, 'Enable automatic AWTRIX app rotation'))
        {
            Set-AwtrixSetting -Device $resolvedDevice -Setting @{
                autoTransition = $true
            } -Confirm:$false
        }
    }
}
