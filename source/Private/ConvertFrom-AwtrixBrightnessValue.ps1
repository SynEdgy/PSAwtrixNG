<#
    .SYNOPSIS
        Converts a native AWTRIX brightness value to a percentage.

    .DESCRIPTION
        Converts the firmware's native brightness scale from 0 through 255 to
        a user-facing percentage from 0 through 100 using midpoint rounding.

    .PARAMETER Value
        Specifies the native AWTRIX brightness value from 0 through 255.

    .EXAMPLE
        ConvertFrom-AwtrixBrightnessValue -Value 128
#>
function ConvertFrom-AwtrixBrightnessValue
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Value
    )

    if ($Value -lt 0 -or $Value -gt 255)
    {
        throw "AWTRIX returned an invalid native brightness value of $Value. Expected a value from 0 through 255."
    }

    [System.Int32] [System.Math]::Round(
        ($Value * 100) / 255,
        [System.MidpointRounding]::AwayFromZero
    )
}
