<#
    .SYNOPSIS
        Turns on an AWTRIX NG display.

    .DESCRIPTION
        Enables the AWTRIX matrix through the display endpoint. This does not
        reboot or otherwise change the power state of the device itself.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Enable-AwtrixDisplay -Device '192.168.88.202'
#>
function Enable-AwtrixDisplay
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

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, 'Enable the AWTRIX display'))
        {
            $invokeParameters = @{
                Device  = $resolvedDevice
                Path    = 'api/v1/display'
                Method  = 'Patch'
                Body    = @{ power = $true }
                Confirm = $false
            }

            Invoke-AwtrixApi @invokeParameters
        }
    }
}
