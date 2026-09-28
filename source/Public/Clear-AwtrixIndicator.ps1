<#
    .SYNOPSIS
        Clears an AWTRIX NG colored indicator.

    .DESCRIPTION
        Clears all state for one of the three AWTRIX screen indicators through
        the indicator DELETE endpoint.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Indicator
        Specifies indicator 1, 2, or 3.

    .EXAMPLE
        Clear-AwtrixIndicator -Device 'clock.local' -Indicator 1
#>
function Clear-AwtrixIndicator
{
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Object]
        $Device,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 3)]
        [System.Int32]
        $Indicator
    )

    process
    {
        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Clear AWTRIX indicator $Indicator"))
        {
            $invokeParameters = @{
                Device  = $resolvedDevice
                Path    = "api/v1/indicators/$Indicator"
                Method  = 'Delete'
                Confirm = $false
            }

            Invoke-AwtrixApi @invokeParameters
        }
    }
}
