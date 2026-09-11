<#
    .SYNOPSIS
        Sets an AWTRIX NG colored indicator.

    .DESCRIPTION
        Sets one of the three AWTRIX screen indicators using a hexadecimal color
        or an RGB array, with optional blink and fade intervals.

    .PARAMETER Device
        Specifies a host name, IP address, URI, or object returned by New-AwtrixDevice.

    .PARAMETER Indicator
        Specifies indicator 1, 2, or 3.

    .PARAMETER Color
        Specifies a six-digit hexadecimal color or an array containing three RGB
        values from 0 through 255.

    .PARAMETER Blink
        Specifies the blink interval in milliseconds.

    .PARAMETER Fade
        Specifies the fade interval in milliseconds.

    .EXAMPLE
        Set-AwtrixIndicator -Device '192.168.88.202' -Indicator 1 -Color '#FF0000'

    .EXAMPLE
        Set-AwtrixIndicator -Device '192.168.88.202' -Indicator 2 -Color 0,255,0 -Blink 500
#>
function Set-AwtrixIndicator
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
        $Indicator,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Color,

        [Parameter()]
        [ValidateRange(1, 86400000)]
        [System.Int32]
        $Blink,

        [Parameter()]
        [ValidateRange(1, 86400000)]
        [System.Int32]
        $Fade
    )

    process
    {
        $colorValues = @($Color)
        $isHexColor = $Color -is [System.String] -and $Color -match '^#?[0-9A-Fa-f]{6}$'
        $isRgbColor = $Color -isnot [System.String] -and
            $colorValues.Count -eq 3 -and
            @(
                $colorValues | Where-Object {
                    $_ -isnot [System.Byte] -and
                    ($_ -isnot [System.Int32] -or $_ -lt 0 -or $_ -gt 255)
                }
            ).Count -eq 0

        if (-not $isHexColor -and -not $isRgbColor)
        {
            throw 'Color must be a six-digit hexadecimal string or three RGB values from 0 through 255.'
        }

        $payload = [ordered] @{
            color = $Color
        }

        if ($PSBoundParameters.ContainsKey('Blink'))
        {
            $payload.blinkMs = $Blink
        }

        if ($PSBoundParameters.ContainsKey('Fade'))
        {
            $payload.fadeMs = $Fade
        }

        $resolvedDevice = Resolve-AwtrixDevice -Device $Device

        if ($PSCmdlet.ShouldProcess($resolvedDevice.BaseUri, "Set AWTRIX indicator $Indicator"))
        {
            $invokeParameters = @{
                Device  = $resolvedDevice
                Path    = "api/v1/indicators/$Indicator"
                Method  = 'Put'
                Body    = $payload
                Confirm = $false
            }

            Invoke-AwtrixApi @invokeParameters
        }
    }
}
