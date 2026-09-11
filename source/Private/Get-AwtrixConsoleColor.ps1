<#
    .SYNOPSIS
        Maps an RGB color to the nearest console color.

    .DESCRIPTION
        Selects the nearest color from the standard sixteen-color console palette
        for hosts that do not support ANSI 24-bit color sequences.

    .PARAMETER Red
        Specifies the red channel from 0 through 255.

    .PARAMETER Green
        Specifies the green channel from 0 through 255.

    .PARAMETER Blue
        Specifies the blue channel from 0 through 255.

    .EXAMPLE
        Get-AwtrixConsoleColor -Red 255 -Green 0 -Blue 0
#>
function Get-AwtrixConsoleColor
{
    [CmdletBinding()]
    [OutputType([System.ConsoleColor])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Byte]
        $Red,

        [Parameter(Mandatory = $true)]
        [System.Byte]
        $Green,

        [Parameter(Mandatory = $true)]
        [System.Byte]
        $Blue
    )

    $palette = [ordered] @{
        Black       = @(0, 0, 0)
        DarkBlue    = @(0, 0, 128)
        DarkGreen   = @(0, 128, 0)
        DarkCyan    = @(0, 128, 128)
        DarkRed     = @(128, 0, 0)
        DarkMagenta = @(128, 0, 128)
        DarkYellow  = @(128, 128, 0)
        Gray        = @(192, 192, 192)
        DarkGray    = @(128, 128, 128)
        Blue        = @(0, 0, 255)
        Green       = @(0, 255, 0)
        Cyan        = @(0, 255, 255)
        Red         = @(255, 0, 0)
        Magenta     = @(255, 0, 255)
        Yellow      = @(255, 255, 0)
        White       = @(255, 255, 255)
    }

    $nearestColor = [System.ConsoleColor]::Black
    $nearestDistance = [System.Double]::PositiveInfinity

    foreach ($entry in $palette.GetEnumerator())
    {
        $redDistance = [System.Int32] $Red - $entry.Value[0]
        $greenDistance = [System.Int32] $Green - $entry.Value[1]
        $blueDistance = [System.Int32] $Blue - $entry.Value[2]
        $distance = ($redDistance * $redDistance) +
            ($greenDistance * $greenDistance) +
            ($blueDistance * $blueDistance)

        if ($distance -lt $nearestDistance)
        {
            $nearestDistance = $distance
            $nearestColor = [System.ConsoleColor] $entry.Key
        }
    }

    $nearestColor
}
