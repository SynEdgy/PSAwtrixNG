<#
    .SYNOPSIS
        Turns off an AWTRIX NG display.

    .DESCRIPTION
        Disables the AWTRIX matrix through the display endpoint. The device
        remains running and can be enabled again; this is not deep sleep.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .EXAMPLE
        Disable-AwtrixDisplay -Device '192.168.88.202'
#>
function Disable-AwtrixDisplay
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

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, 'Disable the AWTRIX display'))
        {
            $invokeParameters = @{
                Device  = $resolvedDevice
                Path    = 'api/v1/display'
                Method  = 'Patch'
                Body    = @{ power = $false }
                Confirm = $false
            }

            Invoke-AwtrixApi @invokeParameters
        }
    }
}
