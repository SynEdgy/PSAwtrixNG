<#
    .SYNOPSIS
        Converts packed AWTRIX screen data into a structured frame.

    .DESCRIPTION
        Validates an AWTRIX screen payload and expands each packed RGB24 integer
        into a pixel object containing its coordinates and color channels.

    .PARAMETER PixelData
        Specifies the packed RGB24 values returned by the AWTRIX screen API.

    .PARAMETER Width
        Specifies the matrix width reported by the device.

    .PARAMETER Height
        Specifies the matrix height reported by the device.

    .PARAMETER Device
        Specifies the normalized AWTRIX device associated with the frame.

    .EXAMPLE
        ConvertTo-AwtrixScreenFrame -PixelData $pixels -Device $device
#>
function ConvertTo-AwtrixScreenFrame
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $PixelData,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 1024)]
        [System.Int32]
        $Width,

        [Parameter(Mandatory = $true)]
        [ValidateRange(1, 1024)]
        [System.Int32]
        $Height,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Device
    )

    $expectedPixelCount = $Width * $Height

    if ($PixelData.Count -ne $expectedPixelCount)
    {
        throw "AWTRIX screen data must contain $expectedPixelCount pixels, but contained $($PixelData.Count)."
    }

    $pixels = for ($index = 0; $index -lt $PixelData.Count; $index++)
    {
        $packedColor = [System.UInt32] $PixelData[$index]

        [PSCustomObject] @{
            PSTypeName = 'PSAwtrixNG.ScreenPixel'
            X          = $index % $Width
            Y          = [System.Math]::Floor($index / $Width)
            Value      = $packedColor
            Red        = ($packedColor -shr 16) -band 0xFF
            Green      = ($packedColor -shr 8) -band 0xFF
            Blue       = $packedColor -band 0xFF
            Hex        = '#{0:X6}' -f $packedColor
        }
    }

    [PSCustomObject] @{
        PSTypeName = 'PSAwtrixNG.ScreenFrame'
        Device     = $Device
        Width      = $Width
        Height     = $Height
        CapturedAt = [System.DateTimeOffset]::Now
        Signature  = $PixelData -join ','
        Pixels     = @($pixels)
    }
}
