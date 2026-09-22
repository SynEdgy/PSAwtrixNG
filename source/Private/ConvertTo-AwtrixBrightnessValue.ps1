<#
    .SYNOPSIS
        Converts a brightness percentage to a native AWTRIX value.

    .DESCRIPTION
        Converts a user-facing percentage from 0 through 100 to the firmware's
        native brightness scale from 0 through 255 using midpoint rounding.

    .PARAMETER Percent
        Specifies the user-facing brightness percentage from 0 through 100.

    .EXAMPLE
        ConvertTo-AwtrixBrightnessValue -Percent 50
#>
function ConvertTo-AwtrixBrightnessValue
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 100)]
        [System.Int32]
        $Percent
    )

    [System.Int32] [System.Math]::Round(
        ($Percent * 255) / 100,
        [System.MidpointRounding]::AwayFromZero
    )
}
